# telegram-bot
# Copyright (c) 2023-2024, Rev. Duncan Ross Palmer (2E0EOL),
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  3. Neither the name of the project nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

package Telegram::Bot::Memes;
use Moose;

extends 'Telegram::Bot::Base';

use JSON qw(decode_json);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::Memes::Add;

Readonly my $CACHE_PATTERN => '/var/cache/telegram-bot/memes/%s/%s.%s';
Readonly our $IMAGE_ASPECT => 'original'; # TODO: revert to 'my' not 'our' after Handle/Resizer classes have been removed. f01271d8-aa81-11ee-a387-43e5c3304127
Readonly my $S3_BUCKET_DEFAULT => '58a75bba-1d73-11ee-afdd-5b1a31ab3736';
Readonly my $STORAGE_CLASS_DEFAULT => 'STANDARD';
Readonly my $S3_URI => 's3://%s/%s/%s.%s';
Readonly my $RESULTS_LIMIT => 25;

has adder => (isa => 'Telegram::Bot::Memes::Add', is => 'ro', init_arg => undef, lazy => 1, default => \&__makeAdder);
has bucket => (isa => 'Str', is => 'rw', lazy => 1, default => \&__makeBucket);
has storageClass => (isa => 'Str', is => 'rw', lazy => 1, default => \&__makeStorageClass);
has chatId => (isa => 'Int', is => 'rw', default => 0);
has user => (isa => 'Str', is => 'rw', default => '');

my %__memeExtensionCache = ( );

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = __detaint($text);
	return undef unless ($text);

	my $result = undef;
	if (my $photo = $self->__photoFromCache($text)) {
		$result = $self->__telegramCommand($photo, @words);
	} else {
		$self->__downloadMeme($text);
		if (my $photo = $self->__photoFromCache($text)) {
			$result = $self->__telegramCommand($photo, @words);
		}
	}

	if ($result) {
		$self->dic->audit->acquireSession()->memeUse({
			meme => $text,
			user => $self->user,
		});
	}

	return $result;
}

sub setUser {
	my ($self, $user) = @_;
	$self->user($user);
	return $self; # for call chaining
}

sub search {
	my ($self, $critereon) = @_;

	my @results = grep(/$critereon/, @{ $self->getList() });
	splice(@results, $RESULTS_LIMIT, $#results) if (scalar(@results) > $RESULTS_LIMIT);

	# Check for exact match; and force only one result to be returned
	# This avoids an overlapping meme being inaccessible
	foreach my $result (@results) {
		next if ($result ne $critereon);
		@results = ($result);
		last;
	}

	@results = sort(@results); # Ensure memes are lexically listed
	return \@results;
}

sub getList {
	my ($self) = @_;

	if (__memeExtensionCacheCount() > 0) {
		return __memeExtensionCacheKeys();
	} else {
		my %fileList = (); # Merge all aspects into one list
		my $fileListPerAspect = $self->__executeListingCommand($self->__buildListingCommand());
		foreach my $file (@$fileListPerAspect) {
			$fileList{$file}++;
		}
		return [keys(%fileList)];
	}
}

sub exists {
	my ($self, $name) = @_;

	my $list = $self->getList();
	foreach my $thisName (@$list) {
		return 1 if (lc($name) eq lc($thisName));
	}

	return 0;
}

sub remove {
	my ($self, $name) = @_;
	return 'Sorry, you cannot remove memes without having a Telegram username' unless ($self->user);
	return 'Meme to erase not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	my $audit = $self->dic->audit->acquireSession();

	$self->getList(); # causes extension cache to be refreshed periodically
	my $extension = __memeExtensionCacheFetch($name);
	unless ($extension) {
		my $notes = "No such meme '$name'";
		$audit->memeRemoveFail({
			meme  => $name,
			notes => $notes,
			user  => $self->user,
		});
		return $notes;
	}

	my $isOwner = $self->__isOwner($name, $self->dic->userRepo->username2User($self->user));
	unless ($isOwner || $self->dic->admins->isAdmin($self->user)) {
		my $user = $self->user;
		my $notes = "User '$user' is not an admin, nor owner of the meme '$name'";

		$audit->memeRemoveFail({
			meme  => $name,
			notes => $notes,
			user  => $self->user,
		});

		return "Sorry, \@$user, only the owner of the meme '$name', or an admin may remove it";
	}

	$self->__removeAspects($name, $extension);
	$self->__forgetOwner($name);
	__memeExtensionCacheRemove($name);

	my $notes = "Meme '$name' erased";
	$audit->memeRemoveSuccess({
		meme  => $name,
		notes => $notes,
		user  => $self->user,
	});

	return $notes;
}

sub __removeAspects {
	my ($self, $name, $extension) = @_;

	$self->__runCommand($self->__buildDeleteCommand($name, $extension));
	if (my $path = __makeCachePattern($name, $extension)) {
		unlink($path);
	}

	return;
}

sub add {
	my ($self, $name, $picId) = @_;
	return 'Sorry, you cannot add memes without having a Telegram username' unless ($self->user);
	return 'Meme to add not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	if ($self->exists($name)) {
		$self->dic->audit->acquireSession()->memeAddFail({
			meme  => $name,
			notes => "Meme conflict; '$name' already exists",
			user  => $self->user,
		});

		return "A meme by the name '$name' aleady exists, use /$name to see it, or /meme rm $name to delete it";
	}

	unless ($picId) {
		return 'There is no staged meme - please PM the bot with a photo or picture, and then try this message again';
	}

	my $response = $self->adder->add($name, $picId, $self->user);

	$self->dic->audit->acquireSession()->memeAddSuccess({
		meme  => $name,
		notes => "Meme '$name' added",
		user  => $self->user,
	});

	__memeExtensionCacheStore($name, 'jpg'); # Important; or isn't listable or removable
	return $response;
}

sub addToBucket {
	my ($self, $path, $name) = @_;
	$self->__runCommand($self->__buildUploadCommand($name, $path));
	return;
}

sub __isOwner {
	my ($self, $name, $user) = @_;

	my $sth = $self->dic->db->getHandle()->prepare('SELECT owner FROM meme WHERE name = ?');
	$sth->execute($name);

	while (my $row = $sth->fetchrow_hashref()) {
		if ($row->{owner} == $user->id) {
			return 1;
		}
	}

	return 0;
}

sub __forgetOwner {
	my ($self, $name) = @_;

	my $sth = $self->dic->db->getHandle()->prepare('DELETE FROM meme WHERE name = ?');
	$sth->execute($name);

	return;
}

sub __buildListingCommand {
	my ($self) = @_;

	return sprintf("aws --output json s3api list-objects --bucket %s --prefix '%s/'",
	    $self->bucket, $IMAGE_ASPECT);
}

sub __executeListingCommand {
	my ($self, $command, $mockOutput) = @_;
	my @fileList;
	my $output = defined($mockOutput) ? $mockOutput : `$command`;
	$output = decode_json($output);
	foreach my $fileEnt (@{ $output->{Contents} }) {
		push(@fileList, __removeSizePrefix($fileEnt->{Key}));
		my ($memeName, $extension) = split(m/\./, $fileList[-1]);
		__memeExtensionCacheStore($memeName, $extension);
		$fileList[-1] = $memeName; # remove file exension
	}

	return \@fileList;
}

sub __removeSizePrefix {
	my ($key) = @_;
	return (split(m/\//, $key))[1];
}

#TODO: Move to utils
sub __extensionFromPath {
	my ($path) = @_;
	return (split(m/\./, $path))[-1];
}

sub __telegramCommand {
	my ($self, $photo, @words) = @_;

	my $extension = 'jpg';
	if ($photo && ref($photo) && ref($photo) eq 'HASH') {
		$extension = __extensionFromPath($photo->{file});
		$self->dic->logger->debug("Extracted extension '$extension' from path '$photo->{file}'");
	}

	my %private = (
		extension => $extension,
	);

	if (
		$self->chatId != -407509267
		&& $photo
		&& ref($photo)
		&& ref($photo) eq 'HASH'
		&& $extension eq 'gif'
	) {
		return +{
			__private => \%private,
			animation => $photo,
			caption   => join(' ', @words),
			method    => 'sendAnimation',
		};
	}

	return +{
		__private => \%private,
		caption   => join(' ', @words),
		method    => 'sendPhoto',
		photo     => $photo,
	};
}

sub storePhotoIdInCache {
	my ($self, $name, $extension, $photoId) = @_;

	my $key = __makeCacheKey($name, $extension);
	$self->dic->cache->set($key, $photoId, 180);

	return;
}

sub __photoFromCache {
	my ($self, $name) = @_;

	if (my $extension = __memeExtensionCacheFetch($name)) {
		if (my $id = $self->dic->cache->get(__makeCacheKey($name, $extension))) {
			return $id;
		}

		my $path = __makeCachePattern($name, $extension);
		$self->dic->logger->debug("Checking if '$path' exists (used extension cache)");
		return { file => $path } if (-f $path);
	} else {
		foreach my $extension (qw(png gif jpg JPG jpeg)) {
			if (my $id = $self->dic->cache->get(__makeCacheKey($name, $extension))) {
				return $id;
			}

			my $path = __makeCachePattern($name, $extension);
			$self->dic->logger->debug("Checking if '$path' exists (not in extension cache)");
			return { file => $path } if (-f $path);
		}
	}

	return undef;
}

sub __makeCacheKey {
	my ($name, $extension) = @_;
	return sprintf('%s/%s.%s', $IMAGE_ASPECT, $name, $extension);
}

sub __detaint {
	my ($command) = @_;
	$command = substr($command, 1) if (index($command, '/') == 0);
	if ($command =~ m/^([a-z0-9]+)/i) {
		return lc($1);
	}

	return '_unknown';
}

sub __generateS3URI {
	my ($self, $name, $ext) = @_;
	return sprintf($S3_URI, $self->bucket, $IMAGE_ASPECT, $name, $ext);
}

sub __makeCachePattern {
	my ($name, $ext) = @_;
	sprintf($CACHE_PATTERN, $IMAGE_ASPECT, $name, $ext);
}

sub __buildCommand {
	my ($self, $name, $ext) = @_;
	return sprintf(
		'aws s3 cp %s %s',
		$self->__generateS3URI($name, $ext),
		__makeCachePattern($name, $ext),
	);
}

sub __buildUploadCommand {
	my ($self, $name, $path) = @_;
	return sprintf(
		'aws s3 cp --storage-class=%s %s %s',
		$self->storageClass,
		$path,
		$self->__generateS3URI($name, 'jpg'),
	);
}

sub __buildDeleteCommand {
	my ($self, $name, $ext) = @_;
	return sprintf(
		'aws s3 rm %s',
		$self->__generateS3URI($name, $ext),
	);
}

sub __downloadMeme {
	my ($self, $name) = @_;

	$self->getList(); # causes extension cache to be refreshed periodically
	if (my $extension = __memeExtensionCacheFetch($name)) {
		my $command = $self->__buildCommand($name, $extension);
		$self->__runCommand($command);
	}

	return;
}

sub __runCommand {
	my ($self, $command) = @_;
	$self->dic->logger->debug("Running $command");
	return system($command);
}

sub __makeAdder {
	my ($self) = @_;
	return Telegram::Bot::Memes::Add->new({
		dic   => $self->dic,
		owner => $self,
	});
}

sub __makeBucket {
	my ($self) = @_;
	my $value = $self->__getConfigSection()->getValueByKey('bucket');
	return $value if ($value);
	return $S3_BUCKET_DEFAULT;
}

sub __makeStorageClass {
	my ($self) = @_;
	my $value = $self->__getConfigSection()->getValueByKey('storage_class');
	return $value if ($value);
	return $STORAGE_CLASS_DEFAULT;
}

sub __getConfigSection() {
	my ($self) = @_;

	my $section = $self->dic->config->getSectionByName(__PACKAGE__);
	die('Cannot find [' . __PACKAGE__ . '] section') unless ($section);

	return $section;
}

sub __memeExtensionCacheStore {
	my ($memeName, $extension) = @_;
	$__memeExtensionCache{$memeName} = $extension;
	return;
}

sub __memeExtensionCacheFetch {
	my ($memeName) = @_;
	return $__memeExtensionCache{$memeName};
}

sub __memeExtensionCacheCount {
	return scalar(keys(%__memeExtensionCache));
}

sub __memeExtensionCacheKeys {
	return [ keys(%__memeExtensionCache) ];
}

sub __memeExtensionCacheRemove {
	my ($memeName) = @_;
	delete($__memeExtensionCache{$memeName});
}

1;

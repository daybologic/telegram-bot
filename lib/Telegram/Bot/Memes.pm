# telegram-bot
# Copyright (c) 2023, Rev. Duncan Ross Palmer (2E0EOL),
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
Readonly my $IMAGE_ASPECT_CONFIG => 'preferred_aspect';
Readonly my $IMAGE_ASPECT_DEFAULT => '4x';
Readonly my $S3_BUCKET => '58a75bba-1d73-11ee-afdd-5b1a31ab3736';
Readonly my $S3_URI => 's3://%s/%s/%s.%s';
Readonly my $RESULTS_LIMIT => 25;

has chatId => (isa => 'Int', is => 'rw', default => 0);

has adder => (isa => 'Telegram::Bot::Memes::Add', is => 'ro', init_arg => undef, lazy => 1, default => \&__makeAdder);

my %__memeExtensionCache = ( );

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = __detaint($text);
	return undef unless ($text);

	if (my $path = $self->__pathFromCache($text)) {
		return $self->__telegramCommand($path, @words);
	} else {
		$self->__downloadMeme($text);
		if (my $path = $self->__pathFromCache($text)) {
			return $self->__telegramCommand($path, @words);
		}
	}

	return undef;
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
		foreach my $imageAspect ($self->getAspects()) {
			my $fileListPerAspect = $self->__executeListingCommand($self->__buildListingCommand($imageAspect));
			foreach my $file (@$fileListPerAspect) {
				$fileList{$file}++;
			}
		}
		return [keys(%fileList)];
	}
}

sub getAspects {
	my ($self) = @_;

	my ($section, $preference);
	if ($self->dic) {
		$section = $self->dic->config->getSectionByName(__PACKAGE__);
		$preference = $section->getValueByKey($IMAGE_ASPECT_CONFIG) if ($section);
	}
	$preference = $IMAGE_ASPECT_DEFAULT unless ($preference);

	my $preferenceSeen = 0;
	my @aspects = ('original', '4x', '2x', '1x');
	for (my $i = 0; $i < scalar(@aspects); $i++) {
		if ($aspects[$i] eq $preference) {
			$preferenceSeen = 1;

			if ($i > 0) {
				my $tmp = $aspects[0]; # save original preference
				$aspects[0] = $preference; # override preference
				$aspects[$i] = $tmp; # move original preference to this pos
				last;
			}
		}
	}

	die('[' . __PACKAGE__ . "] $IMAGE_ASPECT_CONFIG invalid/unrecognized: '$preference'")
	    unless ($preferenceSeen);

	return @aspects;
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
	my ($self, $name, $user) = @_;
	return 'Sorry, you cannot remove memes without having a Telegram username' unless ($user);
	return 'Meme to erase not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	$self->getList(); # causes extension cache to be refreshed periodically
	my $extension = __memeExtensionCacheFetch($name);
	return "No such meme '$name'" unless ($extension);

	my $isOwner = $self->__isOwner($name, $self->dic->userRepo->username2User($user));
	unless ($isOwner || $self->dic->admins->isAdmin($user)) {
		return "Sorry, \@$user, only the owner of the meme '$name', or an admin may remove it";
	}

	$self->__removeAspects($name, $extension);
	$self->__forgetOwner($name);
	__memeExtensionCacheRemove($name);
	return "Meme '$name' erased";
}

sub __removeAspects {
	my ($self, $name, $extension) = @_;

	foreach my $aspect ($self->getAspects()) {
		$self->__runCommand(__buildDeleteCommand($name, $extension, $aspect));
		if (my $path = __makeCachePattern($name, $extension, $aspect)) {
			unlink($path);
		}
	}

	return;
}

sub add {
	my ($self, $name, $picId, $user) = @_;
	return 'Sorry, you cannot add memes without having a Telegram username' unless ($user);
	return 'Meme to add not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	if ($self->exists($name)) {
		return "A meme by the name '$name' aleady exists, use /$name to see it, or /meme rm $name to delete it";
	}

	unless ($picId) {
		return 'There is no staged meme - please PM the bot with a photo or picture, and then try this message again';
	}

	my $response = $self->adder->add($name, $picId, $user);
	__memeExtensionCacheStore($name, 'jpg'); # Important; or isn't listable or removable
	return $response;
}

sub addToBucket {
	my ($self, $path, $name, $aspect) = @_;
	$self->__runCommand(__buildUploadCommand($name, $path, $aspect));
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
	my ($self, $imageAspect) = @_;

	return sprintf("aws --output json s3api list-objects --bucket %s --prefix '%s/'",
	    $S3_BUCKET, $imageAspect);
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

sub __telegramCommand {
	my ($self, $path, @words) = @_;

	if ($path =~ m/gif$/ && $self->chatId != -407509267) {
		return +{
			animation => { file => $path },
			caption   => join(' ', @words),
			method    => 'sendAnimation',
		};
	}

	return +{
		caption => join(' ', @words),
		method  => 'sendPhoto',
		photo   => { file => $path },
	};
}

sub __pathFromCache {
	my ($self, $name) = @_;

	if (my $extension = __memeExtensionCacheFetch($name)) {
		foreach my $aspect ($self->getAspects()) {
			my $path = __makeCachePattern($name, $extension, $aspect);
			$self->dic->logger->trace("Checking if '$path' exists (used extension cache)");
			return $path if (-f $path);
		}
	} else {
		foreach my $extension (qw(png gif jpg JPG jpeg)) {
			foreach my $aspect ($self->getAspects()) {
				my $path = __makeCachePattern($name, $extension, $aspect);
				$self->dic->logger->trace("Checking if '$path' exists (not in extension cache)");
				return $path if (-f $path);
			}
		}
	}

	return undef;
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
	my ($name, $ext, $aspect) = @_;
	$aspect = $IMAGE_ASPECT_DEFAULT unless ($aspect);
	return sprintf($S3_URI, $S3_BUCKET, $aspect, $name, $ext);
}

sub __makeCachePattern {
	my ($name, $ext, $aspect) = @_;
	$aspect = $IMAGE_ASPECT_DEFAULT unless ($aspect);
	sprintf($CACHE_PATTERN, $aspect, $name, $ext);
}

sub __buildCommand {
	my ($name, $ext, $aspect) = @_;
	return sprintf(
		'aws s3 cp %s %s',
		__generateS3URI($name, $ext, $aspect),
		__makeCachePattern($name, $ext, $aspect),
	);
}

sub __buildUploadCommand {
	my ($name, $path, $aspect) = @_;
	return sprintf(
		'aws s3 cp %s %s',
		$path,
		__generateS3URI($name, 'jpg', $aspect),
	);
}

sub __buildDeleteCommand {
	my ($name, $ext, $aspect) = @_;
	return sprintf(
		'aws s3 rm %s',
		__generateS3URI($name, $ext, $aspect),
	);
}

sub __downloadMeme {
	my ($self, $name) = @_;

	$self->getList(); # causes extension cache to be refreshed periodically
	if (my $extension = __memeExtensionCacheFetch($name)) {
		foreach my $imageAspect ($self->getAspects()) {
			my $command = __buildCommand($name, $extension, $imageAspect);
			$self->__runCommand($command);
		}
	}

	return;
}

sub __runCommand {
	my ($self, $command) = @_;
	$self->dic->logger->trace("Running $command");
	return system($command);
}

sub __makeAdder {
	my ($self) = @_;
	return Telegram::Bot::Memes::Add->new({
		dic   => $self->dic,
		owner => $self,
	});
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

package Telegram::Bot::Memes;
use Moose;

use Data::Dumper;
use JSON qw(decode_json);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::Memes::Add;

Readonly my $CACHE_PATTERN => '/var/cache/telegram-bot/memes/%s/%s.%s';
Readonly my $IMAGE_ASPECT => '4x';
Readonly my $S3_BUCKET => '58a75bba-1d73-11ee-afdd-5b1a31ab3736';
Readonly my $S3_URI => 's3://%s/%s/%s.%s';

has chatId => (isa => 'Int', is => 'rw', default => 0);

has adder => (isa => 'Telegram::Bot::Memes::Add', is => 'ro', init_arg => undef, lazy => 1, default => \&__makeAdder);

has api => (is => 'rw', isa => 'WWW::Telegram::BotAPI');

my %__memeExtensionCache = ( );

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = __detaint($text);
	return undef unless ($text);

	if (my $path = __pathFromCache($text)) {
		return $self->__telegramCommand($path, @words);
	} else {
		$self->__downloadMeme($text);
		if (my $path = __pathFromCache($text)) {
			return $self->__telegramCommand($path, @words);
		}
	}

	return undef;
}

sub search {
	my ($self, $critereon) = @_;

	my @results = grep(/$critereon/, @{ $self->getList() });

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
		return $self->__executeListingCommand($self->__buildListingCommand());
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
	return 'Meme to erase not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	$self->getList(); # causes extension cache to be refreshed periodically
	my $extension = __memeExtensionCacheFetch($name);
	return "No such meme '$name'" unless ($extension);

	foreach my $aspect ('original', '4x', '2x', '1x') { # TODO: Can iterate through aspects?
		$self->__runCommand(__buildDeleteCommand($name, $extension, $aspect));
		if (my $path = __makeCachePattern($name, $extension, $aspect)) {
			unlink($path);
		}
	}

	__memeExtensionCacheRemove($name);

	return "Meme '$name' erased";
}

sub add {
	my ($self, $name, $picId) = @_;
	return 'Meme to add not specified' unless (defined($name) && length($name) > 0);
	return 'Illegal meme name' if ($name !~ m/^[a-z0-9]+$/i);

	if ($self->exists($name)) {
		return "A meme by the name '$name' aleady exists, use /$name to see it, or /meme rm $name to delete it";
	}

	unless ($picId) {
		return 'There is no staged meme - please PM the bot with a photo or picture, and then try this message again';
	}

	my $response = $self->adder->add($name, $picId);
	__memeExtensionCacheStore($name, 'jpg'); # Important; or isn't listable or removable
	return $response;
}

sub addToBucket {
	my ($self, $path, $name, $aspect) = @_;
	$self->__runCommand(__buildUploadCommand($name, $path, $aspect));
	return;
}

sub __buildListingCommand {
	my ($self) = @_;

	return sprintf("aws --output json s3api list-objects --bucket %s --prefix '%s/'",
	    $S3_BUCKET, $IMAGE_ASPECT);
}

sub __executeListingCommand {
	my ($self, $command) = @_;
	my @fileList;
	my $output = `$command`;
	$output = decode_json($output);
	foreach my $fileEnt (@{ $output->{Contents} }) {
		push(@fileList, substr($fileEnt->{Key}, 3)); # Remove size-related prefix
		my ($memeName, $extension) = split(m/\./, $fileList[-1]);
		__memeExtensionCacheStore($memeName, $extension);
		$fileList[-1] = $memeName; # remove file exension
	}

	return \@fileList;
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
	my ($name) = @_;

	if (my $extension = __memeExtensionCacheFetch($name)) {
		my $path = __makeCachePattern($name, $extension);
		warn "Checking if '$path' exists";
		return $path if (-f $path);
	} else {
		foreach my $extension (qw(png gif jpg JPG jpeg)) {
			my $path = __makeCachePattern($name, $extension);
			warn "Checking if '$path' exists";
			return $path if (-f $path);
		}
	}

	return undef;
}

sub __detaint {
	my ($command) = @_;
	$command = substr($command, 1) if (index($command, '/') == 0);
	$command = $1 if ($command =~ m/([a-z0-9]+)/);
	return $command;
}

sub __generateS3URI {
	my ($name, $ext, $aspect) = @_;
	$aspect = $IMAGE_ASPECT unless ($aspect);
	return sprintf($S3_URI, $S3_BUCKET, $aspect, $name, $ext);
}

sub __makeCachePattern {
	my ($name, $ext, $aspect) = @_;
	$aspect = $IMAGE_ASPECT unless ($aspect);
	sprintf($CACHE_PATTERN, $aspect, $name, $ext);
}

sub __buildCommand {
	my ($name, $ext) = @_;
	return sprintf(
		'aws s3 cp %s %s',
		__generateS3URI($name, $ext),
		__makeCachePattern($name, $ext),
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
		my $command = __buildCommand($name, $extension);
		$self->__runCommand($command);
	}

	return;
}

sub __runCommand {
	my ($self, $command) = @_;
	warn "Running $command";
	return system($command);
}

sub __makeAdder {
	my ($self) = @_;
	return Telegram::Bot::Memes::Add->new({
		api   => $self->api,
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

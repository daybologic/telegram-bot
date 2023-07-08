package Telegram::Bot::Memes;
use Moose;

use POSIX qw(EXIT_SUCCESS);
use Readonly;

Readonly my $CACHE_PATTERN => '/var/cache/telegram-bot/memes/%dx/%s.%s';
Readonly my $IMAGE_SIZE => 4;
Readonly my $S3_BUCKET => '58a75bba-1d73-11ee-afdd-5b1a31ab3736';
Readonly my $S3_URI => 's3://%s/%dx/%s.%s';

has chatId => (isa => 'Int', is => 'rw', default => 0);

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = __detaint($text);
	return undef unless ($text);

	if (my $path = pathFromCache($text)) {
		return $self->__telegramCommand($path, @words);
	} else {
		$self->__downloadMeme($text);
		if (my $path = pathFromCache($text)) {
			return $self->__telegramCommand($path, @words);
		}
	}

	return undef;
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

sub pathFromCache {
	my ($name) = @_;
	foreach my $ext (qw(png gif jpg JPG jpeg)) {
		my $path = __makeCachePattern($name, $ext);
		warn "Checking if '$path' exists";
		return $path if (-f $path);
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
	my ($name, $ext) = @_;
	return sprintf($S3_URI, $S3_BUCKET, $IMAGE_SIZE, $name, $ext);
}

sub __makeCachePattern {
	my ($name, $ext) = @_;
	sprintf($CACHE_PATTERN, $IMAGE_SIZE, $name, $ext);
}

sub __buildCommand {
	my ($name, $ext) = @_;
	return sprintf(
		'aws s3 cp %s %s',
		__generateS3URI($name, $ext),
		__makeCachePattern($name, $ext),
	);
}

sub __downloadMeme {
	my ($self, $name) = @_;

	foreach my $ext (qw(png gif jpg JPG jpeg)) {
		last if ($self->__runCommand(__buildCommand($name, $ext)) == EXIT_SUCCESS);
	}
}

sub __runCommand {
	my ($self, $command) = @_;
	warn "Running $command";
	return system($command);
}

1;

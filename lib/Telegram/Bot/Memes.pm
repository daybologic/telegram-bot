package Telegram::Bot::Memes;
use Moose;

use Readonly;

Readonly my $PATH_PATTERN => '/home/palmer/workspace/emoticons/4x/%s.%s';
Readonly my $IMAGE_SIZE => 4;
Readonly my $S3_BUCKET => '58a75bba-1d73-11ee-afdd-5b1a31ab3736';
Readonly my $S3_URI => 's3://%s/%dx/%s.%s';

has chatId => (isa => 'Int', is => 'rw', default => 0);

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = __decommand($text);

	foreach my $ext (qw(png gif jpg JPG jpeg)) {
		my $path = sprintf($PATH_PATTERN, $text, $ext);
		warn "Checking if '$path' exists";
		if (-f $path) {
			if ($ext eq 'gif' && $self->chatId != -407509267) {
				return +{
					method => 'sendAnimation',
					animation => { file => $path },
					caption => join(' ', @words),
				};
			} else {
				return +{
					method  => 'sendPhoto',
					photo   => { file => $path },
					caption => join(' ', @words),
				};
			}
		}
	}

	return undef;
}

sub __decommand {
	my ($command) = @_;
	$command = substr($command, 1) if (index($command, '/') == 0);
	return $command;
}

sub __generateS3URI {
	my ($name, $extension) = @_;
	return sprintf($S3_URI, $S3_BUCKET, $IMAGE_SIZE, $name, $extension);
}
#[081058Z JUL 23][palmer@trinity] telegram-bot meme [2]$ aws s3 cp s3://$U/4x/troll.png /tmp/

1;

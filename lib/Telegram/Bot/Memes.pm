package Telegram::Bot::Memes;
use Moose;

use Readonly;

Readonly my $PATH_PATTERN => '/home/palmer/workspace/emoticons/4x%s.%s';

has chatId => (isa => 'Int', is => 'rw', default => 0);

sub run {
	my ($self, @words) = @_;

	my $text = shift(@words);
	$text = "/${text}" if (index($text, '/') != 0);

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

1;

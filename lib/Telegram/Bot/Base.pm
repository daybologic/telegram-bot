package Telegram::Bot::Base;
use Moose;

has _quiet => (isa => 'Bool', is => 'rw', default => 0);

sub _warn {
	my ($self, $message) = @_;

	return if ($self->_quiet);
	warn($message);

	return;
}

1;

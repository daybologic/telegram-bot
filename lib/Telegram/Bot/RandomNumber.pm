package Telegram::Bot::RandomNumber;
use Moose;

use Readonly;

Readonly my $LIMIT => 65536;

sub run {
	return 1 + int(rand($LIMIT));
}

1;

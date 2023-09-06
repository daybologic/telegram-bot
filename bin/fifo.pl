#!/usr/bin/env perl

use Fcntl;
use POSIX qw(:errno_h);
use strict;
use warnings;

my $fifo_file = '/var/run/telegram-bot/timed-messages.fifo';
my $BUFSIZ = 1024;

sub handle_fifo_record {
	my ($record) = @_;
	chomp($record);
	printf("Record received: %s\n", $record);
	return;
}

sysopen(MESSAGES, $fifo_file, O_NONBLOCK|O_RDONLY)
    or die( "The FIFO file \"$fifo_file\" is missing, and this program can't run without it.");

my $rv;
do {
	my $buffer;
	$rv = sysread(MESSAGES, $buffer, $BUFSIZ);
	sleep(1);
	if (!defined($rv) && $! == EAGAIN) {
		# would block
	} elsif ($rv > 0) {
		&handle_fifo_record($buffer);
	}
} while (1);

# should never really come down here ...
close(MESSAGES);
exit(0);

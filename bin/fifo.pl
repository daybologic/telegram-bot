#!/usr/bin/env perl

use strict;
use warnings;

my $fifo_file = '/var/run/telegram-bot/timed-messages.fifo';
my $fifo_fh;

sub handle_fifo_record {
	my ($record) = @_;
	chomp($record);
	printf("Record received: %s\n", $record);
	return;
}

open($fifo_fh, "+< $fifo_file") or die "The FIFO file \"$fifo_file\" is missing, and this program can't run without it.";

# just keep reading from the fifo and processing the events we read
while (<$fifo_fh>) {
	&handle_fifo_record($_);
}

# should never really come down here ...
close($fifo_fh);
exit(0);

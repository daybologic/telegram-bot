#!/usr/bin/env perl

package main;
use Telegram::Bot;
use strict;
use warnings;

sub main {
	return Telegram::Bot->new->run();
}

exit(main());

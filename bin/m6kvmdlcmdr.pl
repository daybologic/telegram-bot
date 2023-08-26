#!/usr/bin/env perl

package main;
use strict;
use warnings;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
#use Telegram::Bot;

Readonly my $INSTALLED_ERROR => 42; # arbitary

sub main {
	if (my $exitCode = rootCheck()) {
		print(STDERR "Don't run the bot as the super-user!\n");
		return $exitCode;
	}

	return Telegram::Bot->new->run();
}

sub rootCheck {
	return $INSTALLED_ERROR if ($EUID == 0);
	return EXIT_SUCCESS;
}

exit(main());

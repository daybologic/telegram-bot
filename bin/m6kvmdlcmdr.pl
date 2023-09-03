#!/usr/bin/env perl

package main;
use strict;
use warnings;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot;

Readonly my $INSTALLED_ERROR => 42; # arbitary

sub main {
	if (my $exitCode = rootCheck()) {
		return $exitCode;
	}

	#return Telegram::Bot->new->run(); # FIXME: This is not an object; need to fix that
}

sub rootCheck {
	return EXIT_SUCCESS if ($EUID > 0);

	print(STDERR "Don't run the bot as the super-user!\n");
	return $INSTALLED_ERROR;
}

exit(main());

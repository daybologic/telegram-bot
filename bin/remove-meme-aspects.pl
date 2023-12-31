#!/usr/bin/env perl

package main;
use strict;
use warnings;
use English qw(-no_match_vars);
use POSIX qw(EXIT_FAILURE EXIT_SUCCESS);
use Telegram::Bot::Memes::Migrate;

sub main {
	if (my $exitCode = rootCheck()) {
		return $exitCode;
	}

	return Telegram::Bot::Memes::Migrate->new->run();
}

sub rootCheck {
	return EXIT_SUCCESS if ($EUID > 0);

	print(STDERR "Don't run as the super-user!\n");
	return EXIT_FAILURE;
}

exit(main());

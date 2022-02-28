#!/usr/bin/env perl

package main;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use POSIX qw(EXIT_SUCCESS);

WriteMakefile(
	NAME         => 'Telegram::Bot',
	VERSION_FROM => 'lib/Telegram/Bot.pm',
	EXE_FILES    => [glob q('bin/*')],
);

exit(EXIT_SUCCESS);

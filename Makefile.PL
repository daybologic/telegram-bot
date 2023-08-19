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
	AUTHOR       => 'Duncan Ross Palmer (palmer@overchat.org)',
	ABSTRACT     => 'Multipurpose bot for Telegram',
	PREREQ_PM => {
		'Config::INI'  => 0, # libconfig-ini-perl
		'LWP'          => 0,
		'Moose'        => 0,
		'DateTime'     => 0,
	}, BUILD_REQUIRES => {
		'Test::Output'    => 0,
		'Test::Exception' => 0,
	},
);

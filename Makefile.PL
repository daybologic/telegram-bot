#!/usr/bin/env perl

package main;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Telegram::Bot',
	VERSION_FROM => 'lib/Telegram/Bot.pm',
	EXE_FILES    => [glob q('bin/*')],
	AUTHOR       => 'Rev. Duncan Ross Palmer (2e0eol@gmail.com)',
	ABSTRACT     => 'Multipurpose bot for Telegram',
	PREREQ_PM => {
		'Config::INI'                  => 0, # libconfig-ini-perl
		'Data::Money'                  => 0, # libdata-money-perl
		'DateTime'                     => 0, # libdatetime-perl
		'DBD::mysql'                   => 0, # libdbd-mysql-perl
		'DBI'                          => 0, # libdbi-perl
		'Geo::Weather::Visualcrossing' => 0, # libgeo-weather-visualcrossing-perl
		'JSON::MaybeXS'                => 0, # libjson-maybexs-perl
		'LWP::UserAgent'               => 0, # libwww-perl
		'Moose'                        => 0, # libmoose-perl
		'Time::Duration'               => 0, # libtime-duration-perl
		'UNIVERSAL::require'           => 0, # libuniversal-require-perl
		'URI::Encode'                  => 0, # liburi-encode-perl
		'WWW::Telegram::BotAPI'        => 0, # libwww-telegram-botapi-perl
	}, BUILD_REQUIRES => {
		'Config::INI'                  => 0, # libconfig-ini-perl
		'Data::Money'                  => 0, # libdata-money-perl
		'DateTime'                     => 0, # libdatetime-perl
		'DBD::mysql'                   => 0, # libdbd-mysql-perl
		'DBI'                          => 0, # libdbi-perl
		'Geo::Weather::Visualcrossing' => 0, # libgeo-weather-visualcrossing-perl
		'LWP::UserAgent'               => 0, # libwww-perl
		'Moose'                        => 0, # libmoose-perl
		'Time::Duration'               => 0, # libtime-duration-perl
		'Test::Deep'                   => 0, # libtest-deep-perl
		'Test::Module::Runnable'       => 0, # libtest-module-runnable-perl
		'Test::Output'                 => 0, # libtest-output-perl
		'UNIVERSAL::require'           => 0, # libuniversal-require-perl
		'URI::Encode'                  => 0, # liburi-encode-perl
		'WWW::Telegram::BotAPI'        => 0, # libwww-telegram-botapi-perl
	},
);

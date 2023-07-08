#!/usr/bin/perl
package MemesTests_generateS3URI;
use strict;
use warnings;
use Moose;
extends 'Test::Module::Runnable';

use Telegram::Bot::Memes;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;

sub test {
	my ($self) = @_;
	plan tests => 1;

	my $result = Telegram::Bot::Memes::__generateS3URI('troll', 'png');
	is($result, 's3://58a75bba-1d73-11ee-afdd-5b1a31ab3736/4x/troll.png', "URL: '$result'");

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(MemesTests_generateS3URI->new->run);

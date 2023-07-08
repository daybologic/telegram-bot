#!/usr/bin/perl
package MemesTests;
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

sub setUp {
	my ($self) = @_;

	$self->sut(Telegram::Bot::Memes->new());

	return EXIT_SUCCESS;
}

sub testNotFound {
	my ($self) = @_;
	plan tests => 1;

	is($self->sut->run('/nonsense'), undef, 'run with nonsense returned <undef>');

	return EXIT_SUCCESS;
}

sub testYUNO { # a valid and important meme
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/yuno'), {
		caption => '',
		method  => 'sendPhoto',
		photo   => {
			file => '/home/palmer/workspace/emoticons/4x/yuno.png',
		},
	}, 'run with yuno returned correct data');

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(MemesTests->new->run);

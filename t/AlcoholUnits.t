#!/usr/bin/env perl
#
# telegram-bot
# Copyright (c) 2023-2024, Rev. Duncan Ross Palmer (2E0EOL),
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  3. Neither the name of the project nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

package AlcoholUnitsTests;
use lib 'lib';
use Moose;
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::AlcoholUnits;
use Telegram::Bot::DI::Container;
use Test::More 0.96;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

Readonly my $GUINNESS => 2.3288; # pint
Readonly my $BUCKFAST => 11.25; # bottle
Readonly my $WINE     => 9.375; # bottle

sub setUp {
	my ($self, %params) = @_;

	my $dic = Telegram::Bot::DI::Container->new();
	$self->sut(Telegram::Bot::AlcoholUnits->new({ dic => $dic }));

	return $self->SUPER::setUp(%params);
}

sub testUnits {
	my ($self) = @_;
	plan tests => 4;

	my $abv = 4;
	my $quantity = 1;
	my $size = 568; # UK pint
	is(Telegram::Bot::AlcoholUnits::__units($abv, $quantity, $size), 2.272, 'a weak pint');

	$abv = 7.9;
	$quantity = 1;
	$size = 750; # bottle
	is(Telegram::Bot::AlcoholUnits::__units($abv, $quantity, $size), 5.925, 'a bottle of Taste the Difference special ale');

	$abv = 4.2;
	$quantity = 1;
	$size = 568; # UK pint
	is(Telegram::Bot::AlcoholUnits::__units($abv, $quantity, $size), 2.3856, 'a pint-sized can of Hobgoblin Gold');

	$abv = 7.2;
	$quantity = 1;
	$size = 440; # UK large can
	is(Telegram::Bot::AlcoholUnits::__units($abv, $quantity, $size), 3.168, 'a can of Caroline');

	return EXIT_SUCCESS;
}

sub testGuinness {
	my ($self) = @_;
	plan tests => 9;

	is($self->sut->run('/units pint of Guinness'), $GUINNESS, 'Units in pint of Guinness');
	is($self->sut->run('/units a pint of Guinness'), $GUINNESS, 'Units in a pint of Guinness');
	is($self->sut->run('/units two pints of Guinness'), $GUINNESS * 2, 'Units in two pints of Guinness');
	is($self->sut->run('/units three pints of Guinness'), $GUINNESS * 3, 'Units in three pints of Guinness');
	is($self->sut->run('/units four pints of Guinness'), $GUINNESS * 4, 'Units in four pints of Guinness');
	is($self->sut->run('/units FiVe pints of Guinness'), $GUINNESS * 5, 'Units in five pints of Guinness');
	is($self->sut->run('/units 8 pints of Guinness'), $GUINNESS * 8, 'Units in 8 pints of Guinness');
	is($self->sut->run('/units half a pint of Guinness'), $GUINNESS / 2, 'Units in half a pint of Guinness');
	is($self->sut->run('/units half a Guinness'), $GUINNESS / 2, 'Units half a Guinness');

	return EXIT_SUCCESS;
}

sub testBuckfast {
	my ($self) = @_;
	plan tests => 4;

	is($self->sut->run('/units a bottle of Buckfast'), $BUCKFAST, 'Units in a bottle of Buckfast');
	is($self->sut->run('/units bottle of Buckie'), $BUCKFAST, 'Units in bottle of Buckie');
	is($self->sut->run('/units one bottle of Bucky'), $BUCKFAST, 'Units one bottle of Bucky');
	is($self->sut->run('/units half a bottle of Bucky'), $BUCKFAST / 2, 'Units in half a bottle of Bucky');

	return EXIT_SUCCESS;
}

sub testWine {
	my ($self) = @_;
	plan tests => 6;

	is($self->sut->run('/units in a bottle of wine'), $WINE, 'Units in a bottle of wine');
	is($self->sut->run('/units in a large glass of wine'), $WINE / 3, 'Units in a large glass of wine');
	is($self->sut->run('/units in a glass of wine'), $WINE / 3, 'Units in a glass of wine');
	is($self->sut->run('/units in a medium glass of wine'), 2.1875, 'Units in a medium glass of wine');
	is($self->sut->run('/units in a small glass of wine'), 1.5625, 'Units in a small glass of wine');
	is($self->sut->run('/units in a smol glass of wine'), 1.5625, 'Units in a smol glass of wine');

	return EXIT_SUCCESS;
}

sub testCansOfBeer {
	my ($self) = @_;
	plan tests => 4;

	is($self->sut->run('/units in a large can of Timeline'), 2.376, 'Units in a large can of Timeline');
	is($self->sut->run('/units in a small can of Timeline'), 1.782, 'Units in a small can of Timeline');
	is($self->sut->run('/units in a smol can of Timeline'), 1.782, 'Units in a smol can of Timeline');
	is($self->sut->run('/units in a can of Timeline'), 2.376, 'Units in a can of Timeline');

	return EXIT_SUCCESS;
}

sub testWhiskey {
	my ($self) = @_;
	plan tests => 4;

	is($self->sut->run('/units in two measures of whisky'), 2, 'Units in two measures of whisky');
	is($self->sut->run('/units in a measure of whiskey'), 1, 'Units in a measure of whiskey');
	is($self->sut->run('/units in a shot of whisky'), 1, 'Units in a shot of whisky');
	is($self->sut->run('/units in a large measure of whisky'), 2, 'Units in a large measure of whisky');

	return EXIT_SUCCESS;
}

sub testVodka {
	my ($self) = @_;
	plan tests => 4;

	is($self->sut->run('/units in two measures of vodka'), 2, 'Units in two measures of vodka');
	is($self->sut->run('/units in a measure of vodka'), 1, 'Units in a measure of vodka');
	is($self->sut->run('/units in a shot of vodka'), 1, 'Units in a shot of vodka');
	is($self->sut->run('/units in a large measure of vodka'), 2, 'Units in a large measure of vodka');

	return EXIT_SUCCESS;
}

sub testFreeForm {
	my ($self) = @_;
	plan tests => 3;

	is($self->sut->run('/units in 440ml of 5.8'), 2.552, 'units in 440ml of 5.8');
	is($self->sut->run('/units in 20cl of 11%'), 2.2, 'units in 20cl of 11%');
	is($self->sut->run('/units in 33cl of 8.4'), 2.772, 'units in 33cl of 8.4');

	return EXIT_SUCCESS;
}

sub testRawUnits {
	my ($self) = @_;
	plan tests => 3;

	is($self->sut->run('/units 10'), 10, '10 raw units');
	is($self->sut->run('/units 2.552'), 2.552, '2.552 raw units');
	is($self->sut->run('/units 1.1'), 1.1, '1.1 raw units');;

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(AlcoholUnitsTests->new()->run());

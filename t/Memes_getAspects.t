#!/usr/bin/perl
#
# telegram-bot
# Copyright (c) 2023, Rev. Duncan Ross Palmer (2E0EOL),
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

package MemesGetAspectsTests;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

use Telegram::Bot::Config::Section;
use Telegram::Bot::Config;
use Telegram::Bot::DI::Container;
use Telegram::Bot::Memes;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::More;

has config => (is => 'rw', isa => 'Telegram::Bot::Config');

sub setUp {
	my ($self) = @_;

	my $dic = Telegram::Bot::DI::Container->new();
	$self->config(Telegram::Bot::Config->new({ dic => $dic }));

	$self->sut(Telegram::Bot::Memes->new({ dic => $dic }));

	return EXIT_SUCCESS;
}

sub tearDown {
	my ($self) = @_;
	$self->clearMocks();
	return EXIT_SUCCESS;
}

sub testDefaults {
	my ($self) = @_;
	plan tests => 1;

	Readonly my @ASPECTS => (qw(original 4x 2x 1x));

	my @results = $self->sut->getAspects();
	cmp_deeply(\@results, \@ASPECTS, 'correct order');

	return EXIT_SUCCESS;
}

sub testConfigOverride {
	my ($self) = @_;
	plan tests => 1;

	Readonly my $OVERRIDE => '2x';
	Readonly my @ASPECTS  => ($OVERRIDE, qw(4x original 1x));

	Readonly my %KEYS => (
		preferred_aspect => $OVERRIDE,
	);

	$self->mock('Telegram::Bot::Config', 'getSectionByName', [
		Telegram::Bot::Config::Section->new({
			'keys' => \%KEYS,
			name   => 'Telegram::Bot::Memes',
			owner  => $self->config,
		}),
	]);

	my @results = $self->sut->getAspects();
	cmp_deeply(\@results, \@ASPECTS, 'correct order');

	return EXIT_SUCCESS;

}

package main;
use strict;
use warnings;
exit(MemesGetAspectsTests->new->run);

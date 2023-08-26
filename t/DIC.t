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

package DICTests;
use strict;
use warnings;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::DI::Container;
use Test::Deep qw(all cmp_deeply isa methods shallow);
use Test::More;

sub setUp {
	my ($self) = @_;

	$self->sut(Telegram::Bot::DI::Container->new());

	return EXIT_SUCCESS;
}

sub testAPI {
	my ($self) = @_;

	Readonly my %MAP => (
		'WWW::Telegram::BotAPI' => 'api',
	);

	plan tests => scalar(keys(%MAP));

	# TODO: Hmm, what can we test about the API contruction?
	while (my ($package, $name) = each(%MAP)) {
		cmp_deeply($self->sut->$name, all(
			isa($package),
		), $name);
	}

	return EXIT_SUCCESS;
}

sub testAttributesSimple {
	my ($self) = @_;

	Readonly my %MAP => (
		'Telegram::Bot::Admins'            => 'admins',
		'Telegram::Bot::Audit'             => 'audit',
		'Telegram::Bot::Ball8'             => 'ball8',
		'Telegram::Bot::CatClient'         => 'catClient',
		'Telegram::Bot::Config'            => 'config',
		'Telegram::Bot::DB'                => 'db',
		'Telegram::Bot::DrinksClient'      => 'drinksClient',
		'Telegram::Bot::GenderClient'      => 'genderClient',
		'Telegram::Bot::Memes'             => 'memes',
		'Telegram::Bot::MusicDB'           => 'musicDB',
		'Telegram::Bot::Karma'             => 'karma',
		'Telegram::Bot::RandomNumber'      => 'randomNumber',
		'Telegram::Bot::User::Repository'  => 'userRepo',
		'Telegram::Bot::UUIDClient'        => 'uuidClient',
		'Telegram::Bot::Weather::Location' => 'weatherLocation',
	);

	plan tests => scalar(keys(%MAP));

	while (my ($package, $name) = each(%MAP)) {
		cmp_deeply($self->sut->$name, all(
			isa($package),
			methods(dic => shallow($self->sut)),
		), $name);
	}

	return EXIT_SUCCESS;
}

sub testUA {
	my ($self) = @_;
	plan tests => 2;

	isa_ok($self->sut->ua, 'LWP::UserAgent', 'ua');
	is($self->sut->ua->timeout, 120, 'timeout');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(DICTests->new->run);

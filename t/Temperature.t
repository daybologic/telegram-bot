#!/usr/bin/perl
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

package TemperatureTests;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

use Telegram::Bot::DI::Container;
use Telegram::Bot::Food;
use POSIX qw(EXIT_SUCCESS);
use Test::More;

has config => (is => 'rw', isa => 'Telegram::Bot::Config');

sub setUp {
	my ($self) = @_;

	my $dic = Telegram::Bot::DI::Container->new();
	$self->sut(Telegram::Bot::Temperature->new({ dic => $dic }));

	return EXIT_SUCCESS;
}

sub testC {
	my ($self) = @_;
	plan tests => 1;

	is(Telegram::Bot::Temperature::c_to_f(10), 50, '10C is 50F');

	return EXIT_SUCCESS;
}

sub testF {
	my ($self) = @_;
	plan tests => 1;

	is(Telegram::Bot::Temperature::f_to_c(50), 10, '50F is 10C');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(TemperatureTests->new->run);

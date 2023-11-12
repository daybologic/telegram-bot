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

package KappagenTests;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

use Telegram::Bot::DI::Container;
use Telegram::Bot::Kappagen;
use POSIX qw(EXIT_SUCCESS);
use Test::More;

has config => (is => 'rw', isa => 'Telegram::Bot::Config');

sub setUp {
	my ($self) = @_;

	my $dic = Telegram::Bot::DI::Container->new();
	$self->sut(Telegram::Bot::Kappagen->new({ dic => $dic }));

	return EXIT_SUCCESS;
}

sub testSimple {
	my ($self) = @_;
	plan tests => 3;

	my $output = $self->sut->run(3, 'x');
	is($output, 'xxx', 'count first, term next');

	$output = $self->sut->run('x', 3);
	is($output, 'xxx', 'term first, count next');

	$output = $self->sut->run('x', 1);
	is($output, 'x', 'once only');

	return EXIT_SUCCESS;
}

sub testMixedSet {
	my ($self) = @_;
	plan tests => 4;

	my $output = $self->sut->run('x', 'y', 'z', 7);
	is($output, 'xyzxyzx', 'terms first, count last');

	$output = $self->sut->run(7, 'x', 'y', 'z');
	is($output, 'xyzxyzx', 'count first, terms last');

	$output = $self->sut->run('x', 7, 'y', 'z');
	is($output, 'xyzxyzx', 'count in arbitary place');

	$output = $self->sut->run('x', 7, 'y', 'z', 6);
	is($output, 'xyz6xyz', 'first count applies only');

	return EXIT_SUCCESS;
}

sub testUnspecifiedCount {
	my ($self) = @_;
	my $testCount = 6666;
	plan tests => $testCount + 1;

	my $seenMinimum = 999_999;
	my $seenMaximum = 0;

	for (my $i = 1; $i <= $testCount; $i++) {
		my $thing = 'x';
		my $output = $self->sut->run($thing);
		like($output, qr/^x{8,64}$/, sprintf("'%s' between 8 and 64 characters (%d/%d)",
		    $thing, $i, $testCount));

		my $l = length($output);
		$seenMinimum = $l if ($l < $seenMinimum);
		$seenMaximum = $l if ($l > $seenMaximum);
	}

	subtest 'min/max' => sub {
		plan tests => 2;

		is($seenMinimum, 8, 'Minimum (8) was seen');
		is($seenMaximum, 64, 'Maximum (64) was seen');
	};

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(KappagenTests->new->run);

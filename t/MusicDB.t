#!/usr/bin/env perl
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

package MusicDBTests;
use lib 'lib';
use File::Temp qw(tempfile);
use Moose;
use POSIX qw(EXIT_SUCCESS);
use Telegram::Bot::DI::Container;
use Telegram::Bot::MusicDB;
use Test::More;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

has __dic => (is => 'rw', isa => 'Telegram::Bot::DI::Container');
has __handle => (is => 'rw');

sub setUp {
	my ($self, %params) = @_;
	$self->__dic(Telegram::Bot::DI::Container->new());
	return $self->SUPER::setUp(%params);
}

sub tearDown {
	my ($self, %params) = @_;
	$self->__handle(undef);
	return $self->SUPER::tearDown(%params);
}

sub testDefaultLocation {
	my ($self) = @_;
	plan tests => 1;

	$self->sut(Telegram::Bot::MusicDB->new({ dic => $self->__dic }));

	my $username = qx(whoami);
	chomp($username);

	my $path = "/var/lib/$username/telegram-bot/music-database.list";
	is($self->sut->__location, $path, $path);

	return EXIT_SUCCESS;
}

sub testSearchEmptyNoneFound {
	my ($self) = @_;
	plan tests => 1;

	$self->__makeSUT(0);

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedNoneFound {
	my ($self) = @_;
	plan tests => 1;

	$self->__makeSUT(1);

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedTwoFound {
	my ($self) = @_;
	plan tests => 1;

	$self->__makeSUT(1);

	is_deeply($self->sut->search('    Judge       '), [
		'yyy Judge Jules',
		'xxx Judge Dredd',
	], 'two found');

	return EXIT_SUCCESS;
}

sub testSearchPopulated {
	my ($self) = @_;
	plan tests => 2;

	$self->__makeSUT(1);

	my $limit = 10;
	$self->sut->limit($limit);

	my $result = $self->sut->search('F');
	cmp_ok(scalar(@$result), '>=', 5, 'at least 5 results');
	cmp_ok(scalar(@$result), '==', $limit, "not more than $limit results");

	return EXIT_SUCCESS;
}

sub __makeDatabase {
	my ($handle) = @_;

	for (my $i = 0; $i < 100; $i++) {
		if ($i == 9) {
			print($handle "yyy Judge Jules\n");
		} elsif ($i == 79) {
			print($handle "xxx Judge Dredd\n");
		} else {
			printf($handle "%08X\n", rand(0xffffffff));
		}
	}

	close($handle);

	return;
}

sub __makeSUT {
	my ($self, $populate) = @_;

	my ($handle, $location) = tempfile();
	$self->__handle($handle);

	__makeDatabase($handle) if ($populate);

	$self->sut(Telegram::Bot::MusicDB->new(
		dic        => $self->__dic,
		__location => $location,
		_quiet     => 1,
	));

	return $self->sut;
}

package main;
use strict;
use warnings;
exit(MusicDBTests->new()->run());

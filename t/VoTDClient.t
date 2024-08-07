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

package VoTDClientTests;
use lib 'lib';
use HTTP::Response;
use Moose;
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::DI::Container;
use Telegram::Bot::VoTD::Client;
use Test::Deep qw(all cmp_deeply isa methods);
use Test::More 0.96;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

sub setUp {
	my ($self, %params) = @_;

	my $dic = Telegram::Bot::DI::Container->new();
	$self->sut(Telegram::Bot::VoTD::Client->new({ dic => $dic }));

	return $self->SUPER::setUp(%params);
}

sub testFailure {
	my ($self) = @_;
	plan tests => 2;

	my $errorCode = 500;
	my $errorMsg = 'Failed miserably';
	$self->mock(ref($self->sut->dic->ua), 'get', [
		HTTP::Response->new($errorCode, $errorMsg),
	]);

	$self->mock(ref($self->sut->dic->logger), 'error');

	my $votd = $self->sut->run();
	diag(explain($votd));

	my $mockCalls = $self->mockCalls(ref($self->sut->dic->ua), 'get');
	cmp_deeply($mockCalls, [[ 'https://chleb-api.daybologic.co.uk/1/votd' ]], 'URL get')
	    or diag(explain($mockCalls));

	$mockCalls = $self->mockCalls(ref($self->sut->dic->logger), 'error');
	cmp_deeply($mockCalls, [[ sprintf('%d %s', $errorCode, $errorMsg) ]], 'error logged')
	    or diag(explain($mockCalls));

	return EXIT_SUCCESS;
}

sub testSuccess {
	my ($self) = @_;
	plan tests => 3;

	my $content = '{"included":[{"relationships":{"book":{"data":{"id":28,"type":"book"}}},"id":"28/8","attributes":{"book":"Hosea","ordinal":8},"type":"chapter"},{"type":"book","attributes":{"testament":"old","ordinal":28},"id":28,"relationships":{}}],"links":{},"data":[{"id":"28/8/8","relationships":{"chapter":{"links":{},"data":{"type":"chapter","id":"28/8"}},"book":{"links":{},"data":{"type":"book","id":28}}},"type":"verse","attributes":{"ordinal":8,"book":"Hosea","chapter":8,"text":"Israel is swallowed up: now shall they be among the Gentiles as a vessel wherein [is] no pleasure."}}]}';

	my $errorCode = 200;
	my $errorMsg = 'Success';
	$self->mock(ref($self->sut->dic->ua), 'get', [
		HTTP::Response->new($errorCode, $errorMsg, undef, $content),
	]);

	$self->mock(ref($self->sut->dic->logger), 'error');

	my $votd = $self->sut->run();
	cmp_deeply($votd, all(
		isa('Telegram::Bot::VoTD'),
		methods(
			book => 'Hosea',
			chapterOrdinal => 8,
			text => 'Israel is swallowed up: now shall they be among the Gentiles as a vessel wherein [is] no pleasure.',
			verseOrdinal => 8,
		),
	), 'votd') or diag(explain($votd));

	my $mockCalls = $self->mockCalls(ref($self->sut->dic->ua), 'get');
	cmp_deeply($mockCalls, [[ 'https://chleb-api.daybologic.co.uk/1/votd' ]], 'URL get')
	    or diag(explain($mockCalls));

	$mockCalls = $self->mockCalls(ref($self->sut->dic->logger), 'error');
	cmp_deeply($mockCalls, [], 'error *NOT* logged')
	    or diag(explain($mockCalls));

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(VoTDClientTests->new()->run());

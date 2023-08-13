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
			file => '/var/cache/telegram-bot/memes/4x/yuno.png',
		},
	}, 'run with yuno returned correct data');

	return EXIT_SUCCESS;
}

sub testCaption {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/troll', 'just to', 'wind you up'), {
		caption => 'just to wind you up',
		method  => 'sendPhoto',
		photo   => {
			file => '/var/cache/telegram-bot/memes/4x/troll.png',
		},
	}, 'caption and image path correct');

	return EXIT_SUCCESS;
}

sub testGIF {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/hotpotato'), {
		caption   => '',
		method    => 'sendAnimation',
		animation => {
			file => '/var/cache/telegram-bot/memes/4x/hotpotato.gif',
		},
	}, 'caption and image path correct') or diag(explain($self->sut->run('/hotpotato')));

	return EXIT_SUCCESS;
}

sub testNoSlash {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('rubberstamp'), {
		caption => '',
		method  => 'sendPhoto',
		photo   => {
			file => '/var/cache/telegram-bot/memes/4x/rubberstamp.png',
		},
	}, 'correct data');

	return EXIT_SUCCESS;
}

sub testSearchRap {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('rap');
	cmp_deeply($result, [
		'itsatrap',
		'ohcrap',
		'philosoraptor',
	], 'results') or diag(explain($result));

	return EXIT_SUCCESS;
}

sub testSearchFatherJack {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('fatherjack');
	cmp_deeply($result, ['fatherjack']); # 'fatherjack2' does not come back

	return EXIT_SUCCESS;
}

sub testSearchDanger {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('danger');
	cmp_deeply($result, ['dangerwillrobinson']);

	return EXIT_SUCCESS;
}

sub testAli {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('ali');
	cmp_deeply($result, ['alig']);

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(MemesTests->new->run);

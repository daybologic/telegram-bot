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

package MemesExecuteListingCommandTests;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
extends 'Test::Module::Runnable';

use Telegram::Bot::Memes;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::More;

sub setUp {
	my ($self) = @_;

	$self->sut(Telegram::Bot::Memes->new());

	return EXIT_SUCCESS;
}

sub test {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->__executeListingCommand('/bin/true', __makeJson());
	cmp_deeply($result, ['alreadydidsomething', 'bernie'], 'meme name list; two items');

	return EXIT_SUCCESS;
}

sub __makeJson {
	return '{
		"Contents": [
			{
				"Key": "original/alreadydidsomething.jpg",
				"LastModified": "2023-08-10T14:41:21+00:00",
				"ETag": "\"fffffffffffffffffffffffffffff499\"",
				"Size": 35882,
				"StorageClass": "STANDARD",
				"Owner": {
					"ID": "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff51a"
				}
			},
			{
				"Key": "original/bernie.jpg",
				"LastModified": "2023-08-23T15:40:42+00:00",
				"ETag": "\"fffffffffffffffffffffffffffff264\"",
				"Size": 314263,
				"StorageClass": "STANDARD",
				"Owner": {
					"ID": "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff51a"
				}
			}
		]
	}';
}

package main;
use strict;
use warnings;
exit(MemesExecuteListingCommandTests->new->run);

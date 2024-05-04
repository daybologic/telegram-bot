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

package Telegram::Bot::Bible;
use strict;
use warnings;
use Moose;
extends 'Telegram::Bot::Base';

use Readonly;

Readonly my $ROOT => 'data/static/kjv';

Readonly my %BOOK_NAME_MAP => ( # TODO: use index.cvs?
	'duff1'=> 'duff2', # TODO: If a mapping is unused, trap it
	'Isa'  => 'isaiah',
	'Prov' => 'Proverbs',
	'Judg' => 'Judges',
	'Col'  => 'Colossians',
	'Josh' => 'Joshua',
	'2Ki'  => '2 Kings',
	'1Chr' => '1 Chronicles',
	'Jer'  => 'Jeremiah',
	'Num'  => 'Numbers',
	'1Sam' => '1 Samuel',
	'Psa'  => 'Psalms',
	'Eph'  => 'Ephesians',
	'1Tim' => '1 Timothy',
	'Hag'  => 'Haggai',
	'1Cor' => '1 Corinthians',
	'kjv'  => sub { die 'oops kjv is not a book'; },
);

has books => (is => 'ro', isa => 'HashRef', default => sub {{}});

sub BUILD {
	my ($self) = @_;
	$self->__loadPath($ROOT);
	return;
}

sub __loadPath {
	my ($self, $path) = @_;

	local *dirHandle;
	if (opendir(dirHandle, $path)) {
		while (my $filename = readdir(dirHandle)) {
			next if ($filename eq 'index.cvs');
			my $fqSubPath = join('/', $path, $filename);
			if (-d $fqSubPath) {
				next if (index($filename, '.') >= 0);
				$self->__loadPath($fqSubPath);
			} else {
				my $bookName = __extractBookName($fqSubPath);
				$self->books->{$bookName}++; # TODO This is not a list of chapters
			}
		}
		closedir(dirHandle);
	}

	return;
}

sub __extractBookName {
	my ($path) = @_;

	my @parts = split(m/\//, $path);
	my $book = $parts[-2];

	if (my $bookNameMapped = $BOOK_NAME_MAP{$book}) {
		if (ref($bookNameMapped) eq 'CODE') {
			return $bookNameMapped->();
		}
		return $bookNameMapped;
	}

	return $book;
}

1;

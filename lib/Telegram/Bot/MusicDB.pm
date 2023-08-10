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

package Telegram::Bot::MusicDB;
use Moose;
use Readonly;

extends 'Telegram::Bot::Base';

Readonly my $LIMIT => 20;

has __db => (isa => 'ArrayRef[Str]', is => 'rw', default => sub {
	return [ ];
});

has __location => (is => 'ro', lazy => 1, isa => 'Str', default => sub {
	return "/var/lib/$ENV{USER}/telegram-bot/music-database.list";
});

has limit => (is => 'rw', isa => 'Int', default => $LIMIT);

sub BUILD {
	my ($self) = @_;
	$self->__reload();
	return;
}

sub __reload {
	my ($self) = @_;

	@{ $self->__db } = (); # flush

	my $fh = IO::File->new();
	if ($fh->open($self->__location, 'r')) {
		while (my $line = <$fh>) {
			chomp($line);
			push(@{ $self->__db }, $line);
		}
		$self->_warn(sprintf("%d tracks loaded\n", scalar(@{ $self->__db })));
		$fh->close();
	}

	return;
}

sub search {
	my ($self, $criteria) = @_;

	$criteria =~ s/\W//g;

	my @results = grep(/$criteria/i, @{ $self->__db });
	$#results = $self->limit - 1 if (scalar(@results) > $self->limit);

	$self->_warn(sprintf(
		"Query '%s' returned %d results (%d entries total)\n",
		$criteria,
		scalar(@results),
		scalar(@{ $self->__db }),
	));

	return \@results;
}

1;

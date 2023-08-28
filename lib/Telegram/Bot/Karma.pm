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

package Telegram::Bot::Karma;
use Moose;

extends 'Telegram::Bot::Base';

use English qw(-no_match_vars);
use Readonly;
use Telegram::Bot::DI::Container;

#Readonly my SQL_UPDATE has __sthUpdate => 'UPDATE karma SET score = score + ? WHERE term = ?';
Readonly my $SQL_UPDATE =>
    'INSERT INTO karma(term, score) VALUES(?, ?) ON DUPLICATE KEY UPDATE score = score + ?';

Readonly my $SQL_SELECT => 'SELECT score FROM karma WHERE term = ?';

has __sthUpdate => (is => 'rw', isa => 'DBI::st');
has __sthGet => (is => 'rw', isa => 'DBI::st');

# TODO: not concurrency-safe; Works because we are not concurrent; we might need a lock
# to ensure run is a critical section, or refactor.
has __term => (is => 'rw', isa => 'Str');
has __increaseOrNot => (is => 'rw', isa => 'Bool');

sub run {
	my ($self, $text) = @_;
	$text = substr($text, 3); # trim '/k '

	my ($term, $diff);
	eval {
		($term, $diff) = $self->__extractCommand($text);
	};
	if (my $evalError = $EVAL_ERROR) {
		$self->dic->logger->warn($evalError);
		return "ERROR: $evalError";
	}

	$self->__sthUpdate($self->dic->db->getHandle()->prepare($SQL_UPDATE)) unless ($self->__sthUpdate);
	$self->__sthUpdate->execute($term, $diff, $diff);

	$self->__sthGet($self->dic->db->getHandle()->prepare($SQL_SELECT)) unless ($self->__sthGet);
	$self->__sthGet->execute($self->__term);
	while (my $row = $self->__sthGet->fetchrow_hashref()) {
		my $term = $self->__term;
		my $direction = $self->__increaseOrNot ? 'increased' : 'decreased';
		return $self->__debugLogAndReturn("Karma for $term $direction to $row->{score}");
	}

	return $self->__debugLogAndReturn("$term is now at karma level 0"); # "can't happen"
}

sub __debugLogAndReturn {
	my ($self, $msg) = @_;
	$self->dic->logger->debug($msg);
	return $msg;
}

sub __extractCommand {
	my ($self, $text) = @_;

	$self->__increaseOrNot(0);
	if ($text =~ m/\+\+$/) {
		$self->__increaseOrNot(1);
	#} else {
		#die("Syntax: /k term++\n");
	}

	# FIXME: Can't handle -- '—' which is Unicode crap

	my $diff = -1;
	if ($self->__increaseOrNot) {
		$diff = 1; # TODO: should support '+++++++'
	}

	if ($text =~ m/^([a-z0-9]+)/i) {
		return ($self->__term(lc($1)), $diff);
	}

	die("Term can't be extracted/detainted, perhaps unusual characters?\n");
}

1;

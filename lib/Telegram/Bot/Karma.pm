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

use English;
use Readonly;
use Telegram::Bot::DB;

has __db => (is => 'ro', isa => 'Telegram::Bot::DB', init_arg => 'db', required => 1);

#Readonly my SQL_UPDATE has __sthUpdate => 'UPDATE karma SET score = score + ? WHERE term = ?';
Readonly my $SQL_UPDATE =>
    'INSERT INTO karma(term, score) VALUES(?, ?) ON DUPLICATE KEY UPDATE score = score + ?';

has __sthUpdate => (is => 'rw', isa => 'DBI::st');

sub run {
	my ($self, $text) = @_;
	$text = substr($text, 3); # trim '/k '

	my ($term, $diff);
	eval {
		($term, $diff) = __extractCommand($text);
	};
	if (my $evalError = $EVAL_ERROR) {
		return "ERROR: $evalError";
	}

	$self->__sthUpdate($self->__db->getHandle()->prepare($SQL_UPDATE)) unless ($self->__sthUpdate);
	$self->__sthUpdate->execute($term, $diff, $diff);

	return 'done';
}

sub __extractCommand {
	my ($text) = @_;

	my $increaseOrNot = 0;
	if ($text =~ m/\+\+$/) {
		$increaseOrNot = 1;
	#} else {
		#die("Syntax: /k term++\n");
	}

	# FIXME: Can't handle -- '—' which is Unicode crap

	my $diff = -1;
	if ($increaseOrNot) {
		$diff = 1; # TODO: should support '+++++++'
	}

	if ($text =~ m/^([a-z0-9]+)/i) {
		return (lc($1), $diff);
	}

	die("Term can't be extracted/detainted, perhaps unusual characters?\n");
}

#sub __makeU

1;

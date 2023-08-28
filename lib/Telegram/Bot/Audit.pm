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

package Telegram::Bot::Audit;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use Telegram::Bot::Audit::Session;

sub acquireSession {
	my ($self) = @_;
	return Telegram::Bot::Audit::Session->new({
		dic   => $self->dic,
		id    => $self->__getEventSession(),
		owner => $self,
	});
}

sub __getEventSession {
	my ($self) = @_;

	$self->dic->uuidClient->count(1);
	$self->dic->uuidClient->version(1);

	my $results = $self->dic->uuidClient->generate();
	return $results->[0];
}

sub _typeLookup {
	my ($self, $typeMnemonic) = @_;

	my $sth = $self->dic->db->getHandle()->prepare('SELECT id FROM audit_event_type WHERE mnemonic = ?');
	$sth->execute($typeMnemonic);

	while (my $row = $sth->fetchrow_hashref()) {
		return $row->{id};
	}

	return 0;
}


1;

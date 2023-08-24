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

#use Readonly;

sub recordStartup {
	my ($self) = @_;
	# TODO: event ID must be different every time; not 640d9f32-3c81-11ee-8596-63ec67873f69
	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_event (type, event, is_system, notes) VALUES(?,?,?,?)');
	$sth->execute(1, '640d9f32-3c81-11ee-8596-63ec67873f69', 1, "Telegram $Telegram::Bot::VERSION is starting up (2)");

	return;
}

sub memeUse {
	my ($self) = @_;

	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_log (type, event, user, notes) VALUES(?,?,?,?)');
	$sth->execute(12, 'ea0028fa-427e-11ee-b29e-4f8a9c2b0b78', 1, 'TODO');

	return;
}

1;

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

package Telegram::Bot::User::Repository;
use Moose;

use Data::Dumper;
use Readonly;
use Telegram::Bot::User;

has __db => (is => 'ro', isa => 'Telegram::Bot::DB', init_arg => 'db', required => 1);

sub fetchById {
	my ($self) = @_;
	...
}

sub fetchByName {
	my ($self, $user) = @_;

	my $sth = $self->__db->getHandle()->prepare('SELECT id, name, enabled FROM user WHERE name = ?');
	$sth->execute($user);

	while (my $row = $sth->fetchrow_hashref()) {
		my %params = ( %$row, repo => $self );
		return Telegram::Bot::User->new(\%params);
	}

	return undef; # FIXME: Must be Telegram::Bot::User
}

sub save {
	my ($self) = @_;
	...

	#return;
}

sub create {
	my ($self, $user) = @_;

	if (!ref($user)) { # raw username
		$user = Telegram::Bot::User->new({
			name => $user,
			repo => $self,
		});
	}

	my $handle = $self->__db->getHandle();
	my $sth = $handle->prepare('INSERT INTO user (name, enabled) VALUES(?,?)');
	$sth->execute($user->name, $user->enabled);
	$user->id($handle->last_insert_id());

	return $user;
}

sub username2User {
	my ($self, $user) = @_;

	if (my $existingUser = $self->fetchByName($user)) {
		return $existingUser;
	}

	return $self->create($user);
}

sub username2Id {
	my ($self, $user) = @_;
	return $self->username2User($user)->id;
}

1;

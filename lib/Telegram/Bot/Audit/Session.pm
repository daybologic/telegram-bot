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

package Telegram::Bot::Audit::Session;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;

Readonly my $EVENT_START                   => 'START';
Readonly my $EVENT_MEME_ADD_FAIL           => 'MEME_ADD_FAIL';
Readonly my $EVENT_MEME_ADD_SUCCESS        => 'MEME_ADD_SUCCESS';
Readonly my $EVENT_MEME_RM_FAIL            => 'MEME_RM_FAIL';
Readonly my $EVENT_MEME_RM_SUCCESS         => 'MEME_RM_SUCCESS';
Readonly my $EVENT_WEATHER_LOCATION_UPDATE => 'WEATHER_LOCATION_UPDATE';
Readonly my $EVENT_WEATHER_API             => 'WEATHER_API';
Readonly my $EVENT_WEATHER_LOOKUP          => 'WEATHER_LOOKUP';
Readonly my $EVENT_CAT_API                 => 'CAT_API';
Readonly my $EVENT_CAT_LOOKUP              => 'CAT_LOOKUP';
Readonly my $EVENT_MEME_USE_SUCCESS        => 'MEME_USE_SUCCESS';
Readonly my $EVENT_MEME_NOT_FOUND          => 'MEME_NOT_FOUND';
Readonly my $EVENT_COMMAND_NOT_FOUND       => 'COMMAND_NOT_FOUND';
Readonly my $EVENT_COUNTER_INC             => 'COUNTER_INC';
Readonly my $EVENT_COUNTER_FETCH           => 'COUNTER_FETCH';
Readonly my $EVENT_CURRENCY_API            => 'CURRENCY_API';
Readonly my $EVENT_CURRENCY_LOOKUP         => 'CURRENCY_LOOKUP';
Readonly my $EVENT_ADMIN_PROMOTE           => 'ADMIN_PROMOTE';
Readonly my $EVENT_ADMIN_DEMOTE            => 'ADMIN_DEMOTE';
Readonly my $EVENT_ADMIN_USER_BAN          => 'ADMIN_USER_BAN';
Readonly my $EVENT_ADMIN_USER_UNBAN        => 'ADMIN_USER_UNBAN';
Readonly my $EVENT_MEME_API                => 'MEME_API';
Readonly my $EVENT_MEME_SEARCH             => 'MEME_SEARCH';
Readonly my $EVENT_MUSIC_SEARCH            => 'MUSIC_SEARCH';
Readonly my $EVENT_UUID_INFO               => 'UUID_INFO';
Readonly my $EVENT_UUID_GEN                => 'UUID_GEN';
Readonly my $EVENT_UUID_API                => 'UUID_API';
Readonly my $EVENT_COST_AWS_LAMBDA         => 'COST_AWS_LAMBDA';
Readonly my $EVENT_COST_AWS_S3             => 'COST_AWS_S3';
Readonly my $EVENT_COST_AWS_DYNAMO         => 'COST_AWS_DYNAMO';
Readonly my $EVENT_GENDER_SET              => 'GENDER_SET';
Readonly my $EVENT_GENDER_API              => 'GENDER_API';
Readonly my $EVENT_INSULTED                => 'INSULTED';
Readonly my $EVENT_ADMIN_UNAUTH            => 'ADMIN_UNAUTH';
Readonly my $EVENT_CRASH                   => 'CRASH';
Readonly my $EVENT_KARMA_INC               => 'KARMA_INC';
Readonly my $EVENT_KARMA_DEC               => 'KARMA_DEC';
Readonly my $EVENT_KARMA_GET               => 'KARMA_GET';
Readonly my $EVENT_KARMA_REPORT            => 'KARMA_REPORT';
Readonly my $EVENT_COMMAND_RATE_LIMIT      => 'COMMAND_RATE_LIMIT';

has id => (is => 'ro', isa => 'Str', required => 1);

has owner => (is => 'ro', isa => 'Telegram::Bot::Audit', required => 1);

sub __typeLookup {
	my ($self, $typeMnemonic) = @_;
	return $self->owner->_typeLookup($typeMnemonic);
}

sub recordStartup {
	my ($self) = @_;

	my $type = $self->__typeLookup($EVENT_START);
	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_event (type, event, is_system, notes) VALUES(?,?,?,?)');
	$sth->execute($type, $self->id, 1, "Telegram $Telegram::Bot::VERSION is starting up (2)");

	return;
}

sub memeUse {
	my ($self, $args) = @_;
	my ($meme, $user) = @{$args}{qw(meme user)};

	my $type = $self->__typeLookup($EVENT_MEME_USE_SUCCESS);
	$user = $self->dic->userRepo->username2Id($user);
	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_event (type, event, user, notes) VALUES(?,?,?,?)');
	$sth->execute($type, $self->id, $user, "Meme name: '$meme'");

	return;
}

sub memeRemoveFail {
	my ($self, $args) = @_;
	my ($meme, $user, $notes) = @{$args}{qw(meme user notes)};

	my $type = $self->__typeLookup($EVENT_MEME_RM_FAIL);
	$user = $self->dic->userRepo->username2Id($user);
	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_event (type, event, user, notes) VALUES(?,?,?,?)');
	$sth->execute($type, $self->id, $user, $notes);

	return;
}

sub memeRemoveSuccess {
	my ($self, $args) = @_;
	my ($meme, $user, $notes) = @{$args}{qw(meme user notes)};

	my $type = $self->__typeLookup($EVENT_MEME_ADD_SUCCESS);
	$user = $self->dic->userRepo->username2Id($user);
	my $sth = $self->dic->db->getHandle()->prepare('INSERT INTO audit_event (type, event, user, notes) VALUES(?,?,?,?)');
	$sth->execute($type, $self->id, $user, $notes);

	return;

}

1;

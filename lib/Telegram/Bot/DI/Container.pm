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

package Telegram::Bot::DI::Container;
use Moose;

use LWP::UserAgent;
use Telegram::Bot::Admins;
use Telegram::Bot::Audit;
use Telegram::Bot::Ball8;
use Telegram::Bot::CatClient;
use Telegram::Bot::Config;
use Telegram::Bot::DB;
use Telegram::Bot::DrinksClient;
use Telegram::Bot::GenderClient;
use Telegram::Bot::Memes;
use Telegram::Bot::MusicDB;
use Telegram::Bot::RandomNumber;
use Telegram::Bot::User::Repository;
use Telegram::Bot::UUIDClient;
use Telegram::Bot::Weather::Location;
use WWW::Telegram::BotAPI;

has admins => (is => 'rw', isa => 'Telegram::Bot::Admins');
has api => (is => 'rw', isa => 'WWW::Telegram::BotAPI');
has audit => (is => 'rw', isa => 'Telegram::Bot::Audit');
has ball8 => (is => 'rw', isa => 'Telegram::Bot::Ball8');
has catClient => (is => 'rw', isa => 'Telegram::Bot::CatClient');
has config => (is => 'rw', isa => 'Telegram::Bot::Config', lazy => 1, builder => '_makeConfig');
has db => (is => 'rw', isa => 'Telegram::Bot::DB');
has drinksClient => (is => 'rw', isa => 'Telegram::Bot::DrinksClient');
has genderClient => (is => 'rw', isa => 'Telegram::Bot::GenderClient');
has memes => (is => 'rw', isa => 'Telegram::Bot::Memes');
has musicDB => (is => 'rw', isa => 'Telegram::Bot::MusicDB');
has randomNumber => (is => 'rw', isa => 'Telegram::Bot::RandomNumber');
has ua => (is => 'rw', isa => 'LWP::UserAgent', lazy => 1, builder => '_makeUserAgent');
has userRepo => (is => 'rw', isa => 'Telegram::Bot::User::Repository');
has uuidClient => (is => 'rw', isa => 'Telegram::Bot::UUIDClient');
has weatherLocation => (is => 'rw', isa => 'Telegram::Bot::Weather::Location');

sub _makeConfig {
	my ($self) = @_;
	return Telegram::Bot::Config->new();
}

sub _makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120); # TODO: From config
	$ua->env_proxy;

	return $ua;
}

1;

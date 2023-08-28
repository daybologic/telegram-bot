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
use lib './externals/libwww-telegram-botapi-perl/lib';
use Moose;

use LWP::UserAgent;
use Log::Log4perl;
use Telegram::Bot::Admins;
use Telegram::Bot::Audit;
use Telegram::Bot::Ball8;
use Telegram::Bot::CatClient;
use Telegram::Bot::Config;
use Telegram::Bot::DB;
use Telegram::Bot::DrinksClient;
use Telegram::Bot::GenderClient;
use Telegram::Bot::Karma;
use Telegram::Bot::Memes;
use Telegram::Bot::MusicDB;
use Telegram::Bot::RandomNumber;
use Telegram::Bot::User::Repository;
use Telegram::Bot::UUIDClient;
use Telegram::Bot::Weather::Location;
use Telegram::Bot::XKCD;
use WWW::Telegram::BotAPI;

has admins => (is => 'rw', isa => 'Telegram::Bot::Admins', lazy => 1, builder => '_makeAdmins');
has api => (is => 'rw', isa => 'WWW::Telegram::BotAPI', lazy => 1, builder => '_makeAPI');
has audit => (is => 'rw', isa => 'Telegram::Bot::Audit', lazy => 1, builder => '_makeAudit');
has ball8 => (is => 'rw', isa => 'Telegram::Bot::Ball8', lazy => 1, builder => '_makeBall8');
has catClient => (is => 'rw', isa => 'Telegram::Bot::CatClient', lazy => 1, builder => '_makeCatClient');
has config => (is => 'rw', isa => 'Telegram::Bot::Config', lazy => 1, builder => '_makeConfig');
has db => (is => 'rw', isa => 'Telegram::Bot::DB', lazy => 1, builder => '_makeDB');
has drinksClient => (is => 'rw', isa => 'Telegram::Bot::DrinksClient', lazy => 1, builder => '_makeDrinksClient');
has genderClient => (is => 'rw', isa => 'Telegram::Bot::GenderClient', lazy => 1, builder => '_makeGenderClient');
has karma => (is => 'rw', isa => 'Telegram::Bot::Karma', lazy => 1, builder => '_makeKarma');
has logger => (is => 'rw', isa => 'Log::Log4perl::Logger', lazy => 1, builder => '_makeLogger');
has memes => (is => 'rw', isa => 'Telegram::Bot::Memes', lazy => 1, builder => '_makeMemes');
has musicDB => (is => 'rw', isa => 'Telegram::Bot::MusicDB', lazy => 1, builder => '_makeMusicDB');
has randomNumber => (is => 'rw', isa => 'Telegram::Bot::RandomNumber', lazy => 1, builder => '_makeRandomNumber');
has ua => (is => 'rw', isa => 'LWP::UserAgent', lazy => 1, builder => '_makeUserAgent');
has userRepo => (is => 'rw', isa => 'Telegram::Bot::User::Repository', lazy => 1, builder => '_makeUserRepo');
has uuidClient => (is => 'rw', isa => 'Telegram::Bot::UUIDClient', lazy => 1, builder => '_makeUuidClient');
has weatherLocation => (is => 'rw', isa => 'Telegram::Bot::Weather::Location', lazy => 1, builder => '_makeWeatherLocation');
has xkcd => (is => 'rw', isa => 'Telegram::Bot::XKCD', lazy => 1, builder => '_makeXkcd');

sub _makeAPI {
	my ($self) = @_;

	my $token = $self->config->getSectionByName('Telegram::Bot')->getValueByKey('api_key');
	die 'No API token' unless ($token);

	# ... but error handling is available as well.
	#my $result = eval { $api->getMe->{result}{username} }
	#    or die 'Got error message: ', $api->parse_error->{msg};
	#warn $result;
	#Mojo::IOLoop->start;
	# Bump up the timeout when Mojo::UserAgent is used (LWP::UserAgent uses 180s by default)

	my $api = WWW::Telegram::BotAPI->new (
		#async => 1, # WARNING: may fail if Mojo::UserAgent is not available!
		token => $token,
	);

	$api->agent->can('inactivity_timeout') and $api->agent->inactivity_timeout(45);
	return $api;
}

sub _makeAdmins {
	my ($self) = @_;
	return Telegram::Bot::Admins->new(dic => $self);
}

sub _makeAudit {
	my ($self) = @_;
	return Telegram::Bot::Audit->new(dic => $self);
}

sub _makeBall8 {
	my ($self) = @_;
	return Telegram::Bot::Ball8->new(dic => $self);
}


sub _makeCatClient {
	my ($self) = @_;
	return Telegram::Bot::CatClient->new(dic => $self);
}

sub _makeConfig {
	my ($self) = @_;
	return Telegram::Bot::Config->new(dic => $self);
}

sub _makeDB {
	my ($self) = @_;
	return Telegram::Bot::DB->new(dic => $self);
}

sub _makeDrinksClient {
	my ($self) = @_;
	return Telegram::Bot::DrinksClient->new(dic => $self);
}

sub _makeGenderClient {
	my ($self) = @_;
	return Telegram::Bot::GenderClient->new(dic => $self);
}

sub _makeKarma {
	my ($self) = @_;
	return Telegram::Bot::Karma->new(dic => $self);
}

sub _makeLogger {
	Log::Log4perl->init('etc/log4perl.conf');
	return Log::Log4perl->get_logger('telegram.bot');
}

sub _makeMemes {
	my ($self) = @_;
	return Telegram::Bot::Memes->new(dic => $self);
}

sub _makeMusicDB {
	my ($self) = @_;
	return Telegram::Bot::MusicDB->new(dic => $self);
}

sub _makeRandomNumber {
	my ($self) = @_;
	return Telegram::Bot::RandomNumber->new(dic => $self);
}

sub _makeUuidClient {
	my($self) = @_;
	return Telegram::Bot::UUIDClient->new(dic => $self);
}

sub _makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120); # TODO: From config
	$ua->env_proxy;

	return $ua;
}

sub _makeUserRepo {
	my ($self) = @_;
	return Telegram::Bot::User::Repository->new(dic => $self);
}

sub _makeWeatherLocation {
	my ($self) = @_;
	return Telegram::Bot::Weather::Location->new(dic => $self);
}

sub _makeXkcd {
	my ($self) = @_;
	return Telegram::Bot::XKCD->new(dic => $self);
}

1;

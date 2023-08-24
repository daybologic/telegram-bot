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

package Telegram::Bot::DB;
use Moose;

extends 'Telegram::Bot::Base';

use DBI;
use English;
use Readonly;
use Telegram::Bot::Config;
use Telegram::Bot::Config::Section;

Readonly my $DRIVER => 'mysql';

has handle => (is => 'rw', isa => 'DBI::db', init_arg => undef);

has __config => (is => 'ro', isa => 'Telegram::Bot::Config::Section', lazy => 1, default => \&__getConfig, init_arg => undef);
has __user => (is => 'ro', isa => 'Str', lazy => 1, default => \&__getUser, init_arg => undef);
has __pass => (is => 'ro', isa => 'Str', lazy => 1, default => \&__getPass, init_arg => undef);
has __db => (is => 'ro', isa => 'Str', lazy => 1, default => \&__getDB, init_arg => undef);
has __host => (is => 'ro', isa => 'Str', lazy => 1, default => \&__getHost, init_arg => undef);
has __dsn => (is => 'ro', isa => 'Str', lazy => 1, default => \&__getDSN, init_arg => undef);

sub getHandle {
	my ($self) = @_;

	unless ($self->handle) {
		my $handle = $self->handle($self->__connect()); # also sets handle
		$self->handle->{mysql_auto_reconnect} = 1;
	}

	return $self->handle;
}

sub __getConfig {
	my ($self) = @_;

	my $section = $self->dic->config->getSectionByName($DRIVER);
	die("Cannot find [$DRIVER] section; required for database access") unless ($section);

	return $section;
}

sub __getUser {
	my ($self) = @_;
	return $self->__config->getValueByKey('user');
}

sub __getPass {
	my ($self) = @_;
	return $self->__config->getValueByKey('pass');
}

sub __getDB {
	my ($self) = @_;
	return $self->__config->getValueByKey('db');
}

sub __getHost {
	my ($self) = @_;
	return $self->__config->getValueByKey('host');
}

sub __getDSN {
	my ($self) = @_;

	return sprintf(
		'DBI:%s:database=%s;host=%s;port=3306',
		$DRIVER,
		$self->__db,
		$self->__host,
	);
}

sub __connect {
	my ($self) = @_;
	my $dbh = DBI->connect($self->__dsn, $self->__user, $self->__pass);
	die($DBI::errstr) unless ($dbh);
	return $dbh;
}

1;

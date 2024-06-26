# telegram-bot
# Copyright (c) 2023-2024, Rev. Duncan Ross Palmer (2E0EOL),
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

package Telegram::Bot::Admins;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use Telegram::Bot::Admin;

Readonly my $SECTION_NAME => 'Telegram::Bot';

has admins => (is => 'rw', isa => 'ArrayRef[Telegram::Bot::Admin]', default => sub {[]});

sub load {
	my ($self) = @_;

	if (my $section = $self->dic->config->getSectionByName($SECTION_NAME)) {
		if (my $valueStr = $section->getValueByKey('admins')) {
			$valueStr =~ s/\s+//;
			my @names = split(m/,/, $valueStr);
			foreach my $name (@names) {
				push(@{ $self->admins }, $self->makeAdmin($name));
			}
		}
	}
}

sub makeAdmin {
	my ($self, $name) = @_;
	return Telegram::Bot::Admin->new(
		type  => __detectType($name),
		value => $self->__logAddingAdmin(lc($name)),
	);
}

sub __logAddingAdmin {
	my ($self, $name) = @_;
	$self->dic->logger->info("Added admin '$name'");
	return $name;
}

sub isAdmin {
	my ($self, $name) = @_;

	my $type = __detectType($name, 1);
	if (!defined($type)) {
		$name = '@' . $name;
	} elsif ($type eq 'number') {
		return 0; # TODO: We don't handle this yet
	}

	foreach my $admin (@{ $self->admins }) {
		if ($admin->value eq lc($name)) {
			$self->dic->logger->info("name '$name' *IS* an admin");
			return 1;
		}
	}

	$self->dic->logger->debug("name '$name' is *NOT* an admin");
	return 0;
}

sub __detectType {
	my ($name, $force) = @_;

	if ($name =~ m/^\+/) {
		return 'number';
	} elsif ($name =~ m/^\@/) {
		return 'handle';
	}

	return undef if ($force);
	die("The specified admin, '$name', must begin with '+' for a number or '\@' for a handle");
}

1;

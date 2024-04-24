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

package Telegram::Bot::UUIDClient;
use Moose;

extends 'Telegram::Bot::Base';

use Data::Dumper;
use Readonly;
use JSON qw(decode_json);
use MIME::Base64;
use URI;

Readonly my $URL_GENERATE => 'http://perlapi.daybologic.co.uk/v2/uuid/generate';
Readonly my $URL_INFO     => 'http://perlapi.daybologic.co.uk/v2/uuid/info/%s';

has [qw(count version)] => (is => 'rw', isa => 'Int', default => 1);

sub generate {
	my ($self) = @_;

	my %opts = (
		n => $self->count,
		v => $self->version,
	);

	my $uri = URI->new($URL_GENERATE);
	$uri->query_form(\%opts);

	my @results;
	my $response = $self->dic->ua->get($uri);
	if ($response->is_success) {
		my $decoded = decode_json(decode_base64($response->decoded_content));
		foreach my $result (@{ $decoded->{results} }) {
			push(@results, sprintf("%s\n", $result->{value}));
		}
	} else {
		$self->dic->logger->error($response->status_line);
	}

	$self->dic->logger->debug(sprintf('%d results generated.', scalar(@results)));
	return \@results;
}

sub info {
	my ($self, $uuid) = @_;

	my $response = $self->dic->ua->get(sprintf($URL_INFO, $uuid));
	unless ($response->is_success) {
		$self->dic->logger->error($response->status_line);
		return $response->status_line;
	}

	return Dumper decode_json(decode_base64($response->decoded_content));
}

1;

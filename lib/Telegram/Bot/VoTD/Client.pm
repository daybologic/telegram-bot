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

package Telegram::Bot::VoTD::Client;
use Moose;

extends 'Telegram::Bot::Base';

use English qw(-no_match_vars);
use JSON qw(decode_json);
use Readonly;
use Telegram::Bot::VoTD;

Readonly my $VOTD_API_URL => 'https://chleb-api.daybologic.co.uk/1/votd';

sub run {
	my ($self) = @_;

	my $response = $self->dic->ua->get($VOTD_API_URL);
	if ($response->is_success) {
		my $decodedContent = $response->decoded_content;

		my $verseStruct = eval { decode_json($decodedContent) };
		if (my $evalError = $EVAL_ERROR) {
			$self->dic->logger->error($evalError);
			return Telegram::Bot::VoTD->new({
				success => 0,
				text    => $evalError,
			});
		}

		my $data = $verseStruct->{data};
		my $included = $verseStruct->{included};
		my $relationships = $verseStruct->{relationships};
		my $attributes = $data->[0]->{attributes};

		return Telegram::Bot::VoTD->new({
			book           => $attributes->{book},
			chapterOrdinal => $attributes->{chapter},
			verseOrdinal   => $attributes->{ordinal},
			text           => $attributes->{text},
		});
	}

	$self->dic->logger->error($response->status_line);
	return Telegram::Bot::VoTD->new({
		success => 0,
		text    => "Can't retrieve verse of the day at the moment",
	});
}

1;

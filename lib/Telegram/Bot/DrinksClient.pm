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

package Telegram::Bot::DrinksClient;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use URI;
use URI::Encode;

Readonly my $LAMBDA_URL => 'https://4rkhnkrdqaaqfijye73f2zfb6a0ypkpr.lambda-url.eu-west-2.on.aws/?user=%s&type=%s&platform=telegram';

sub run {
	my ($self, $username, $type) = @_;

	my $uri = URI->new($LAMBDA_URL);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username, $type));

	$self->dic->logger->debug("GET: $uri");
	my $response = $self->dic->ua->get($uri);
	if ($response->is_success) {
		my $content = $response->decoded_content;
		if ($content =~ m/ their /) {
			my $gender = $self->dic->genderClient->get($username);
			if ($gender->value eq 'female') {
				$content =~ s/ their / her /;
			} elsif ($gender->value eq 'male') {
				$content =~ s/ their / his /;
			}
		}
		return $content;
	} else {
		$self->dic->logger->error($response->status_line);
	}

	return $response;
}

1;

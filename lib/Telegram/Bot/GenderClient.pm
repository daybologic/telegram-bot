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

package Telegram::Bot::GenderClient;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use Telegram::Bot::Gender;
use URI;
use URI::Encode;

Readonly my $GENDER_LAMBDA_URL => 'https://z5odrowet74mkrowq7djkflfd40uhjyg.lambda-url.eu-west-2.on.aws?user=%s&platform=telegram';

sub run {
	my ($self, $username, $gender) = @_;

	if ($gender && substr($gender, 0, 1) eq '@') {
		$username = substr($gender, 1);
		$gender = undef;
	}

	$username = '' unless ($username);

	my $uri = $GENDER_LAMBDA_URL;
	$uri .= '&gender=' . $gender if ($gender);
	$uri = URI->new($uri);

	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username));

	my $decodedContent = $self->dic->ua->get($uri)->decoded_content;
	return $decodedContent;
}

sub get {
	my ($self, $username) = @_;

	my $result = $self->run($username);
	if ($result =~ m/^we don't know/i) {
		$result = 'unspecified';
	} elsif ($result =~ m/female/i) {
		$result = 'female';
	} else {
		$result = 'male'; # bit sub-standard.  Need JSON API or local API
	}

	return Telegram::Bot::Gender->new(value => $result);
}

1;

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

package Telegram::Bot::Weather::Location;
use strict;
use warnings;
use LWP::UserAgent;
use Moose;
use Readonly;
use URI;
use URI::Encode;
use URI::Escape;

Readonly my $LOCATION_LAMBDA_URL => 'https://oz4r4y4h2a2q2an2z2qtg7hwaa0ruejk.lambda-url.eu-west-2.on.aws?user=%s&platform=telegram';

has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent { # TODO: Should be shared, and possibly use same UA as Telegram API client
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub run {
	my ($self, $username, $location) = @_;

	$username = '' unless ($username);

	my $uri = $LOCATION_LAMBDA_URL;

	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username));

	$uri .= '&location=' . uri_escape($location) if ($location);
	$uri = URI->new($uri);

	return $self->__ua->get($uri)->decoded_content;
}

1;

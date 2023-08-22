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

package Telegram::Bot::CatClient;
use Moose;

extends 'Telegram::Bot::Base';

use IO::File;
use Readonly;
use URI;
use URI::Encode;

Readonly my $CAT_URL => 'https://http.cat/%d';

sub run {
	my ($self, $code) = @_;
	return undef unless ($code);

	my $file = $self->__getFile($code, undef);
	return $file if ($file);

	my $uri = URI->new($CAT_URL);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, int($code)));

	my $response = $self->dic->ua->get($uri);
	if ($response->is_success) {
		printf(STDERR "HTTP cat %d: %s\n", $code, $uri);
		return $self->__getFile($code, $response->decoded_content);
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	return $self->run(404);
}

sub __getFile {
	my ($self, $code, $content) = @_;
	mkdir('/tmp/palmer');
	mkdir('/tmp/palmer/m6kvmdlcmdr');
	my $name = sprintf('/tmp/palmer/m6kvmdlcmdr/%d.jpg', $code);
	return $name if -f $name;

	return undef unless ($content);

	my $fh = IO::File->new("> $name");
	if (defined $fh) {
		print $fh $content;
		$fh->close();
	} else {
		die("Sorry, cannot create $name: $!");
	}

	return $name;
}

1;

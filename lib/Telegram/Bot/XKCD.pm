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

package Telegram::Bot::XKCD;
use Moose;

extends 'Telegram::Bot::Base';

use IO::File;
use Readonly;
use URI;
use URI::Encode;

Readonly my $URL => 'https://xkcd.com/%d/';

has rootPath => (is => 'ro', isa => 'Str', default => '/var/cache/telegram-bot/xkcd');

sub run {
	my ($self, $ident) = @_;
	return undef unless ($ident);

	my $file = $self->__getCachedFile($ident);
	return $file if ($file);

	if (my $html = $self->__getHtml($ident)) {
		if (my $pngLocation = __pngFromHtml($html)) {
			return $self->__downloadImageToCache($ident, $pngLocation);
		}
	}

	return undef;
}

sub __pngFromHtml {
	my ($html) = @_;
	my @lines = split(m/\n/, $html);

	foreach my $line (@lines) {
		if ($line =~ m/^Image URL .*(https.*png|jpg)/i) {
			return $1;
		}
	}

	return undef;
}

sub __getCachedFile {
	my ($self, $ident) = @_;
	mkdir($self->rootPath);
	my $path = $self->__cachePath($ident);
	return $path if -f $path;
	return undef;
}

sub __cachePath {
	my ($self, $ident) = @_;
	return sprintf('%s/%d.png', $self->rootPath, $ident);
}

sub __getHtml {
	my ($self, $ident) = @_;

	my $uri = URI->new($URL);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, int($ident)));

	my $response = $self->dic->ua->get($uri);
	if ($response->is_success) {
		printf(STDERR "xkcd %d: %s\n", $ident, $uri);
		my $html = $response->content;
		return $html;
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	return undef;
}

sub __downloadImageToCache {
	my ($self, $ident, $pngLocation) = @_;

	my $uri = URI->new($pngLocation);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode($pngLocation);

	my $response = $self->dic->ua->get($uri);
	if ($response->is_success) {
		return __writeFile($self->__cachePath($ident), $response->content);
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	return undef;
}


sub __writeFile {
	my ($path, $content) = @_;
	my $fh = IO::File->new($path, 'w');
	if (defined $fh) {
		print $fh $content;
		$fh->close();
	} else {
		die("Sorry, cannot create $path: $!");
	}

	return $path;
}

1;

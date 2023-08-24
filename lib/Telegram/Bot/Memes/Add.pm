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

package Telegram::Bot::Memes::Add;
use Moose;

extends 'Telegram::Bot::Base';

use File::Copy;
use File::Temp qw/ tempfile tempdir tmpnam /;
use Telegram::Bot::Memes::Add::Resizer;

has owner => (is => 'ro', isa => 'Telegram::Bot::Memes', required => 1);

sub add {
	my ($self, $name, $fileId, $user) = @_;

	my $filePath = $self->__fetchViaAPI($fileId);
	warn $filePath;

	my $resizer = $self->resizer($filePath, $name);
	$self->owner->addToBucket($resizer->original->path, $name, 'original');
	for (my $size = 4; $size >= 1; $size /= 2) { # TODO: Do we need an all sizes iterator within the object?
		my $aspect = sprintf('%dx', $size);
		my $attribName = "size${aspect}";
		$self->owner->addToBucket($resizer->$attribName->path, $name, $aspect);
	}

	$self->__recordOwner($name, $user);

	return 'Thankyou, @' . $user . ", successfully added meme '$name', type '/$name' to use it, "
	    . "'/meme rm $name' to delete, if it isn't right";
}

sub resizer {
	my ($self, $filePath, $name) = @_;

	my $resizer = Telegram::Bot::Memes::Add::Resizer->new();
	$resizer->setOriginalFile(__makeFileName($name));
	move($filePath, $resizer->original->path);

	return $resizer;
}

sub __recordOwner {
	my ($self, $name, $user) = @_;

	my $sth = $self->dic->db->getHandle()->prepare('REPLACE INTO meme (name, owner) VALUES(?,?)');
	$sth->execute($name, $self->dic->userRepo->username2Id($user));

	return;
}

sub __makeFileName {
	my ($name) = @_;
	return join('.', $name, 'jpg');
}

sub __fetchViaAPI {
	my ($self, $fileId) = @_;

	my $file = $self->dic->api->api_request('getFile', {
		file_id => $fileId,
	});

	my $resultFilePath = $file->{result}->{file_path};
	my $token = $self->dic->api->{token};
	my $url = "https://api.telegram.org/file/bot${token}/${resultFilePath}";

	my $response = $self->dic->api->agent->get($url);
	unless ($response->is_success) {
		return "Can't get your meme via the API! - " . $response->status_line;
	}

	my ($fh, $filePath) = tmpnam();
	print $fh $response->content;

	return $filePath;
}

1;

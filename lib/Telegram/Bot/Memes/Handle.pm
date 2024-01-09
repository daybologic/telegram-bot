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

package Telegram::Bot::Memes::Handle;
use Moose;

use Telegram::Bot::Memes;

has rootPath => (is => 'ro', isa => 'Str', default => '/var/cache/telegram-bot/memes');
has file => (isa => 'Str', is => 'ro', required => 1);
has path => (isa => 'Str', is => 'ro', lazy => 1, default => \&__makePath);
has __aspectPath => (isa => 'Str', is => 'ro', lazy => 1, default => \&__makeAspectPath);

sub __makePath {
	my ($self) = @_;
	return join('/', $self->__aspectPath, $self->file);
}

sub __makeAspectPath {
	my ($self) = @_;
	my $aspectPath = join('/', $self->rootPath, $Telegram::Bot::Memes::IMAGE_ASPECT);
	mkdir($aspectPath);
	return $aspectPath;
}

1;

# TODO: Resizer and Handler classes could be removed due to removal of meme aspects.
# May be worth trying to work on other meme features first in case they become useful again.
# f01271d8-aa81-11ee-a387-43e5c3304127

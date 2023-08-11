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

package Telegram::Bot::Memes::Add::Resizer;
use Moose;
use Readonly;

use Telegram::Bot::Memes::Handle;

has rootPath => (is => 'ro', isa => 'Str', default => '/var/cache/telegram-bot/memes');
has original => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw');

# We keep the original Hipchat sizing scheme.  Each of these are just-in
# time delivery mechanisms, which fetch from the on-disk cache, or
# generate the files dynamically.

has size4x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize4x);
has size2x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize2x);
has size1x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize1x);

sub setOriginalFile {
	my ($self, $file) = @_;

	$self->original(Telegram::Bot::Memes::Handle->new({
		rootPath => $self->rootPath,
		aspect   => 'original',
		file     => $file,
	}));

	return;
}

sub __makeSize4x {
	my ($self) = @_;
	return $self->__resizeWrapper(4);
}

sub __makeSize2x {
	my ($self) = @_;
	return $self->__resizeWrapper(2);
}

sub __makeSize1x {
	my ($self) = @_;
	return $self->__resizeWrapper(1);
}

sub __resizeWrapper {
	my ($self, $size) = @_;

	my $newHandle = Telegram::Bot::Memes::Handle->new({
		rootPath => $self->rootPath,
		aspect   => sprintf('%dx', $size),
		file     => $self->original->file,
	});

	unless (-f $newHandle->path) {
		$self->__resize($newHandle, $size);
	}

	return $newHandle;
}

sub __resize {
	my ($self, $newHandle, $size) = @_;

	my $cmd = $self->__buildCommand($newHandle, $size);
	system(@$cmd) == 0
	    or die "system @$cmd failed: $?";
}

sub __buildCommand {
	my ($self, $newHandle, $size) = @_;

	$size = $self->__getSize($size);
	my @cmd = (
		'convert',
		$self->original->path,
		'-resize',
		$size,
		'-extent',
		$size,
		'-quality',
		'75',
		$newHandle->path,
	);

	return \@cmd;
}

sub __getSize {
	my ($self, $size) = @_;

	Readonly my %SIZE_MAP => (
		1 => 30,
		2 => 60,
		4 => 120,
	);

	if (exists($SIZE_MAP{$size})) {
		$size = $SIZE_MAP{$size};
	} elsif (defined($size)) {
		die("Illegal size: $size");
	} else {
		die('Undefined size!');
	}

	return sprintf('%dx%d', $size, $size);
}

1;

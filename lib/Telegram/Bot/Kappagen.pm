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

package Telegram::Bot::Kappagen;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use Scalar::Util qw(looks_like_number);
use utf8;

Readonly my $MAX_USER_COUNT => 2048;
Readonly my $MIN_RANDOM_COUNT => 8;
Readonly my $MAX_RANDOM_COUNT => 64;
Readonly my $MAX_RANDOM_THINGS => 5;

sub run {
	my ($self, @args) = @_;

	my $count = 1;
	my @things = ();
	my $wantRandomCount = 1;

	foreach my $arg (@args) {
		if (looks_like_number($arg) && $wantRandomCount) {
			$count = int($arg);
			$wantRandomCount = 0;
			$self->dic->logger->debug(sprintf('Set %s Kappagen count %d', \@things, $count));
		} else {
			push(@things, $arg);
			$self->dic->logger->debug(sprintf("Added %s Kappagen thing: '%s', present set size %d",
			    \@things, $arg, scalar(@things)));
		}
	}

	if ($wantRandomCount) {
		$count = $self->__randomCount();
	} elsif ($count > $MAX_USER_COUNT ) {
		$count = $MAX_USER_COUNT;
	}

	if (scalar(@things) == 0) {
		for (my $i = 0; $i < $MAX_RANDOM_THINGS; $i++) {
			push(@things, $self->__randomEmoji());
		}
	}

	return __processThings(\@things, $count);
}

sub __processThings {
	my ($things, $count) = @_;
	my $output = '';

	for (my $i = 0; $i < $count; $i++) {
		$output .= $things->[$i % scalar(@$things)];
	}

	return $output;
}

sub __randomCount {
	my ($self) = @_;

	my $r = $self->dic->randomNumber->run();
	$r = $r % (($MAX_RANDOM_COUNT+1) - $MIN_RANDOM_COUNT);
	$r += $MIN_RANDOM_COUNT;

	$self->dic->logger->debug(sprintf('Chose random count for you:%d (min:%d, max %d)',
	    $r, $MIN_RANDOM_COUNT, $MAX_RANDOM_COUNT));

	return $r;
}

sub __randomEmoji {
	my ($self) = @_;

	my @ranges = (
		[127744,  129782],
	);

	my $rangeIndex = $self->dic->randomNumber->run() % scalar(@ranges);
	my $range = $ranges[$rangeIndex];

	$self->dic->logger->debug(sprintf('range %s-%s', $range->[0], $range->[1]));
	my $chr = int(rand((1+$range->[1]) - $range->[0])) + $range->[0];

	$self->dic->logger->debug(sprintf('Chose %s', $chr));

	return chr($chr);
}

1;

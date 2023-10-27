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

package Telegram::Bot::AlcoholUnits;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;
use Scalar::Util qw(looks_like_number);

Readonly my $BOTTLE  => 750;
Readonly my $PINT_UK => 568;
Readonly my $PINT_US => 473;

sub run {
	my ($self, $command) = @_;

	my (@words) = split(m/\s+/, $command);
	shift(@words); # drop /units
	return __syntax() unless ($words[0]);

	if (lc($words[0]) eq 'in' && $words[1] && lc($words[1]) eq 'a') {
		shift(@words);
	}

	my $divisor = 1;
	if (lc($words[0]) eq 'third') {
		$divisor = 0.33;
		shift(@words);
	} elsif (lc($words[0]) eq 'half') {
		$divisor = 0.5;
		shift(@words);
	}

	my $quantity;
	if (lc($words[0]) eq 'a') {
		$quantity = 1;
		shift(@words);
	} elsif ($quantity = __cardinalToNum($words[0])) {
		shift(@words);
	} else {
		$quantity = 1;
	}

	my $jarType = $words[0];
	if (__strengthFromName($jarType)) { # oops, it's a drink
		$jarType = 'pint';
	} else {
		shift(@words);
	}
	shift(@words) if ($words[0] && lc($words[0]) eq 'of');
	my $drinkType = $words[0];
	shift(@words);

	my $ml = __mlFromJarType($jarType);
	my $abv = __strengthFromName($drinkType);
	my $result = __units($abv, $quantity * $divisor, $ml);

	return $result if ($result);
	return __syntax();
}

sub __syntax {
	return "I don't know about that, say something like: /units half a pint of Guinness";
}

sub __units {
	my ($abv, $quantity, $size) = @_;
	return ($abv*($quantity*$size))/1000;
}

sub __mlFromJarType {
	my ($jarType) = @_;

	if ($jarType =~ m/pint/i) {
		return $PINT_UK;
	} elsif ($jarType =~ m/bottle/i) {
		return $BOTTLE;
	}

	return $PINT_UK;
}

sub __strengthFromName {
	my ($name) = @_;

	my %map = (
		buckfast => 15,
		caroline => 7.2,
		fosters  => 4,
		guinness => 4.1,
		stella   => 4.6,
		wine     => 12.5,
	);

	my %aliases = (
		buckie => 'buckfast',
		bucky  => 'buckfast',
	);

	if ($name) {
		$name = lc($name);
	} else {
		return 0;
	}

	$name = $aliases{$name} if (exists($aliases{$name}));
	return $map{$name} || 0;
}

sub __cardinalToNum {
	my ($word) = @_;

	return $word if (looks_like_number($word));

	$word = lc($word);
	Readonly my @CARDINAL => (qw(
		zero
		one
		two
		three
		four
		five
		six
		seven
		eight
		nine
		ten
		eleven
		twelve
		thirteen
		fourteen
		fifteen
		sixteen
		seventeen
		eighteen
		nineteen
		twenty
	));

	for (my $ordinal = 0; $ordinal < scalar(@CARDINAL); $ordinal++) {
		if ($CARDINAL[$ordinal] eq $word) {
			return $ordinal;
		}
	}

	return 0;
}

1;

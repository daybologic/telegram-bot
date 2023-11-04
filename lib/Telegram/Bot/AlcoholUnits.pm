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

use Data::Dumper;
use Readonly;
use Scalar::Util qw(looks_like_number);
use Telegram::Bot::DrinkInfo;

Readonly my $BOTTLE         => 750;
Readonly my $CAN_L          => 440;
Readonly my $CAN_S          => 330;
Readonly my $GLASS_L        => 250;
Readonly my $GLASS_M        => 175;
Readonly my $GLASS_S        => 125;
Readonly my $PINT_UK        => 568;
Readonly my $PINT_US        => 473;
Readonly my $SPIRIT_ENGLAND => 25;

has __previousDrinks => (is => 'rw', isa => 'HashRef[Telegram::Bot::DrinkInfo]', default => sub { { } });

sub run {
	my ($self, $command, $username) = @_;

	my (@words) = split(m/\s+/, $command);
	shift(@words); # drop /units
	return __syntax() unless ($words[0]);

	if ($words[0] eq 'record') {
		if (!$username) {
			return "Sorry, only users with a '\@username' may record units";
		} elsif (my $drinkInfo = $self->__previousDrinks->{$username}) {
			my $result = $drinkInfo->record($username);
			delete($self->__previousDrinks->{$username});
			return $result;
		} else {
			return 'No drink info to record';
		}
	} elsif ($words[0] eq 'report') {
		if ($username) {
			return $self->__report($username);
		} else {
			return "Sorry, only users with a '\@username' may obtain a drinking report";
		}
	} elsif ($words[0] eq 'undo') {
		if ($username) {
			return $self->__undo($username);
		} else {
			return "Sorry, only users with a '\@username' may undo the last item from the drinking report";
		}
	}

	if (lc($words[0]) eq 'in') {
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
	return __syntax() unless ($jarType);
	my $sizeType = 'default';
	$jarType = lc($jarType);
	if ($jarType eq 'large' || $jarType eq 'medium' || $jarType eq 'small') {
		$sizeType = shift(@words);
	}
	$jarType = $words[0];

	if (__strengthFromName($jarType)) {
		$jarType = 'pint'; # oops, it's a drinkType
	} else {
		shift(@words);
	}
	shift(@words) if ($words[0] && lc($words[0]) eq 'of');
	my $drinkType = shift(@words);

	my $ml = __mlFromJarType($jarType, $sizeType);
	my $abv = __strengthFromName($drinkType, 1);
	my $result = __units($abv, $quantity * $divisor, $ml);

	$self->dic->logger->debug(sprintf('drinkType: %s, jarType: %s, sizeType: %s, ABV: %s, ml: %d', $drinkType, $jarType, $sizeType, $abv, $ml));

	return __syntax() unless ($result);
	if ($username) {
		$self->__previousDrinks->{$username} = Telegram::Bot::DrinkInfo->new({
			abv   => $abv,
			dic   => $self->dic,
			name  => $drinkType,
			units => $result,
		});
	}

	return $result;
}

sub __undo {
	my ($self, $username) = @_;

	my $items = 1;
	my $sth = $self->dic->db->getHandle()->prepare('DELETE FROM drinks WHERE user = ? ORDER BY id DESC LIMIT ?');
	$sth->execute($self->dic->userRepo->username2Id($username), $items);

	$items = $sth->rows;
	if ($items < 0) {
		return "Can't delete drinks for $username, see log";
	} elsif ($items == 0) {
		return "No more drinks to delete for $username";
	}

	my $plural = '';
	$plural = 's' if ($items != 1);
	return sprintf('Deleted the previous %d drink%s for %s', $items, $plural, $username);
}

sub __report {
	my ($self, $username) = @_;

	my $report = '';
	my $days = 7;
	my $sth = $self->dic->db->getHandle()->prepare('SELECT d.name,d.units FROM drinks d, user u WHERE u.name = ? AND d.user=u.id AND d.when_utc >= DATE(NOW() - INTERVAL ? DAY)');
	$sth->execute($username, $days);

	my $weeklyUnits = 0;
	my $totalDrinks = 0;
	while (my $ref = $sth->fetchrow_hashref()) {
		$self->dic->logger->trace(Dumper $ref);
		$weeklyUnits += $ref->{units};
		$totalDrinks++;
	}

	$report .= sprintf('%s drank %.1f units in the past %d days, over %d separate drinks...', $username,
	    $weeklyUnits, $days, $totalDrinks);

	my $their = $self->dic->genderClient->get($username)->their();
	$report .= "\n" . sprintf('%s average drink contained %.2f units.', $their, $weeklyUnits / $totalDrinks);

	$report .= sprintf("\nThat's %.2f units a day", $weeklyUnits / $days);
	$report .= __govWarning($weeklyUnits);

	return $report;
}

sub __govWarning {
	my ($weeklyUnits) = @_;
	return '' if ($weeklyUnits <= 14);

	my $message = "\nWARNING: The UK CMO advises against regularly imbibing more than 14 units in a week.";
	$message .= "\nThe CMO advises over 50 units a week is high risk drinking." if ($weeklyUnits > 50);
	return $message;
}

sub __syntax {
	return "I don't know about that, say something like: /units half a pint of Guinness";
}

sub __units {
	my ($abv, $quantity, $size) = @_;
	return ($abv*($quantity*$size))/1000;
}

sub __mlFromJarType {
	my ($jarType, $sizeType) = @_;

	if ($jarType =~ m/^(\d+)([cm]l)$/i) {
		my ($ml, $si) = ($1, $2);
		$ml *= 10 if (lc($si) eq 'cl');
		return $ml;
	} elsif ($jarType =~ m/pint/i) {
		return $PINT_UK;
	} elsif ($jarType =~ m/bottle/i) {
		return $BOTTLE;
	} elsif ($jarType =~ m/glass/i) {
		if ($sizeType =~ m/small/i) {
			return $GLASS_S;
		} elsif ($sizeType =~ m/medium/i) {
			return $GLASS_M;
		}

		return $GLASS_L;
	} elsif ($jarType =~ m/can/i) {
		if ($sizeType =~ m/small/i) {
			return $CAN_S;
		}

		return $CAN_L;
	} elsif ($jarType =~ m/measure/i || $jarType =~ m/shot/i) {
		if ($sizeType =~ m/large/i) {
			return $SPIRIT_ENGLAND * 2;
		}

		return $SPIRIT_ENGLAND;
	}

	return $PINT_UK;
}

sub __strengthFromName {
	my ($name, $checkForABV) = @_;

	my %map = (
		buckfast => 15,
		caroline => 7.2,
		fosters  => 4,
		guinness => 4.1,
		kestrel  => 9,
		stella   => 4.6,
		timeline => 5.4,
		vodka    => 40,
		wine     => 12.5,
		whiskey  => 40,
		gin      => 38,
		modelo   => 4.5,
	);

	my %aliases = (
		buckie  => 'buckfast',
		bucky   => 'buckfast',
		guiness => 'guinness',
		whisky  => 'whiskey',
	);

	if ($name) {
		if ($checkForABV && $name =~ m/^\d+/) {
			$name =~ s/\%$//;
			return $name if (looks_like_number($name));
		}
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

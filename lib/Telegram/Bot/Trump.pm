# telegram-bot
# Copyright (c) 2023-2024, Rev. Duncan Ross Palmer (2E0EOL),
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

package Telegram::Bot::Trump;
use Moose;

extends 'Telegram::Bot::Base';

use List::Util qw(shuffle);

my @our = (
	# TODO: Automate selections from available verbs
	'The Great President',
	'The Glorious President',
	'The Beloved President',
	'The Great, Beloved President',
	'The Heroic President',
	'The Great, Heroic President',
	'The Heroic, Magnificent President',
	'The Magnificent President',
	'The Great, Magnificent, Heroic, Fighting President',
	'The Beloved, Magnificent, Heroic President',
	'The Great, Beloved, Magnificent, Fighting President',
	'The Fighting President',
	'The Heroic, Fighting President',
);

my @moniker = (
	'The Man of Action',
	'The Can-do President',
	'The People\’s President',
	'The Great Economic Revitalizer',
	'The Kick Ass President',
	'The Fighting Back President',
	'The Get Things Done President',
	'The Straight Talk President',
	'The Pro Tax-Payer President',
	'The Hard Working President',
	'The Man Who Does What he has Promised President',
	'The Honest Straight Talk President',
	'The Counter Punch Knock Out President',
	'The Great Protector',
	'The Take No BS President',
	'The Results Oriented President',
	'The Prodigious Working President',
	'The Economic Miracle President',
	'The Knock Em Out with One Punch President',
	'The Man Without a Party',
	'The Kicking ass and Taking Names President',
	'The America First Last and Always President',
	'The Man Who Loves America',
	'The Alpha Male President',
	'The Man Who Loves Liberty',
	'The Man Who Speaks for the Unspoken',
	'The Moving Forward President',
	'The Man who never stops moving',
	'The Man of Constant Action',
	'The Representative of the People',
	'The Triumphal President',
	'The Titan of Industry',
	'The No Holds Barred President',
	'The Whirlwind Economic Superman',
	'The Tax Cut President',
	'The Knife in the Heart of the Obama Scam Mandate President',
	'The Crusading President',
	'The Bomb the Crap out of Isis President',
	'The Energy Independence President',
	'The Speaking the Truth President',
	'The Man Who Can Do Anything',
	'The Fearless President',
	'The One Man Economic Power House',
	'The Working Man\'s President',
	'The Prosperity President',
	'The Bang the Drums for Liberty President',
	'The Walking Tall & Standing Proud President',
	'The Warrior for Peace',
	'The Future Nobel Prize Winner',
	'The Real Man in the White House',
	'The Man of Unsung Triumphs',
	'The Eviscerater of the Left',
	'The Negotiating Diplomatic Genius',
	'The Prince of Peace',
	'The Making the World Safe President',
	'The Economic Champion of America',
	'The Stable Diplomatic Genius',
	'The Modest President',
	'The Force of Nature',
	'The Political Juggernaut',
	'The Strict Constructionist picking Pro Constitution President',
	'A wonderful friend but a fearsome enemy',
	'The Promises Made Promises Kept President',
	'The fearless Man with Backbone',
	'The Break Water against the Forces of Anti Americanism',
	'The Nationalist President',
	'The Making America Safe President',
	'The Iron Wall President',
	'The slashing Regulations & Jobs President',
	'The Defender of the Borders President',
	'The Legal Immigration President',
	'The Free Enterprise President',
	'The Slayer of the Crooked Old Bitch',
	'The Art of The Deal President',
	'The keeping America safe and sure and prosperous president',
	'The friend of Israel president',
	'The Build a Wall, American Security President',
	'The No Russian Collusion President',
);

sub run {
	my ($self) = @_;

	@our = shuffle(@our);
	@moniker = shuffle(@moniker);

	if (rand(1) < 0.5) {
		return sprintf("%s - \"DJT\", God bless him, %s\n", $our[0], $moniker[0]);
	}

	return sprintf("%s - \"DJT\", %s\n", $our[0], $moniker[0]);
}

1;

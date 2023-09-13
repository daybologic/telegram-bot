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

package Telegram::Bot::Bugger;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;

has previous => (isa => 'Int', is => 'rw', default => -1);

Readonly my @ARTICLES => (
	"a fish fork",
	"a sheep shearer",
	"an Olympic-sized swimming pool",
	"a pickled herring",
	'whatever takes your fancy, really',
	"an emu",
	"some cheese",
	"an acquired medicinal ice cream",
	"a spotted dick",
	"a trance track",
	"a Telegram",
	"a SIP router",
	"a bottle of craft beer",
	"an iPhone",
	"an Android phone",
	"Thursday",
	"a mug of coffee",
	"a pint of lard",
	"a pie from The Raven of Bath",
	'a spade',
	'a wee dram',
	'a horse box',
	'a prominent member of the Royal Family',
	"Prince Henry's biography",
	'Borneo',
	'Australia',
	'Antarctica',
	'Greenland',
	'Iceland',
	'The Isle of Wight',
	'The North Pole',
	'The South Pole',
	"a few teabags",
	"a Perry Como record",
	"an Apple Crumble",
	"a jazz hand",
	"an appliance",
	"a clawhammer",
	"a sledgehammer",
	"a Stanley knife",
	"an expensive, silver cutlery set",
	"a fish hook",
	"a Linux boxen",
	"a Windows 95 computer",
	"a shoe-shiner",
	"a trouser-press",
	"a heron",
	"a microphone",
	"a cache key",
	"a bottle of glue",
	"an old picture frame",
	"the Greatest Living Artist",
	"a lubricated horse cock",
	"an urban dictionary",
	"a wine glass",
	"a pot noodle",
	"an electric kettle",
	"a glass of wine",
	"an eggplant",
	"an aubergine",
	"Mohammed Fayed",
	"a walrus-face",
	"The Nautilus",
	"a border router",
	"an edge connector",
	"a session border controller",
	"a bottle of hot sauce",
	"an extra-hot burrito",
	"a can of baked-beans",
	"a loudspeaker",
	"a glass bottle",
	"a VHS tape",
	"a Betamax tape",
	"a cassette tape",
	"a flatscreen TV",
	"a cathode-ray tube",
	'a spatula',
	'a tin-opener',
	'a rubber dinghy',
	'a telescope',
	'a pair of binoculars',
	'The Greatest Living Artist',
	"Benedict's gardener",
	"Benedict's laptop",
	"Palmer's sink",
	'stamp duty',
	'an exhaust pipe',
	'a trash compactor',
	'a pitchfork',
	'a remote control',
	'a large microphone',
	'a conveyer-belt',
	'a leather belt',
	'a tube of Smarties',
	'a tube of Rolos',
	"the Elephant's foot",
);

sub run {
	my ($self) = @_;

	my $idx;
	do {
		$idx = int(rand(scalar(@ARTICLES)));
	} while ($idx == $self->previous);

	$self->previous($idx);
	return 'Well bugger me with ' . $ARTICLES[$idx];
}

1;

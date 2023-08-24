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

package Telegram::Bot::Ball8;
use Moose;

extends 'Telegram::Bot::Base';

use Readonly;

Readonly my @YES_REMARK => (
	"I reckon yes",
	"I should say so",
	"yarp",
	"do it!",
	"Hmmm... yes?",
	"I think so",
	"You are correct, Sir... YES!",
	"Affirmative",
	'yes',
	'Y U NO?', # TODO: Can we direct to a meme via some sort of magic?
	'indubitably',
	'I did so yesterday'.
	'what are you waiting for?',
);


Readonly my @NO_REMARK => (
	"I wouldn't, if I were you",
	"Absolutely not - no",
	"Naaaaah maaaaaaate",
	"I don't think so, Governor",
	"Negative",
	"Negatory",
	'no',
);

sub run {
	my $pct = int(rand(101));
	if ($pct < 50) {
		return __yes();
	}

	return __no();
}

sub __yes {
	return __lookup(\@YES_REMARK);
}

sub __no {
	return __lookup(\@NO_REMARK);
}

sub __lookup {
	my ($remark) = @_;
	my $i = int(rand(scalar(@$remark)));
	return $remark->[$i];
}

1;

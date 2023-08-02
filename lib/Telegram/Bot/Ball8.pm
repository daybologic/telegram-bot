package Telegram::Bot::Ball8;
use Moose;

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

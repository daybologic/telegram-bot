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

package Telegram::Bot;
use strict;
use warnings;
use Data::Dumper;
use Data::Money::Amount 0.2.0;
use Data::Money::Currency::Converter::Repository::APILayer 0.2.0;
use English;
use Geo::Weather::VisualCrossing;
use HTTP::Status qw(status_message);
use Readonly;
use Telegram::Bot::Admins;
use Telegram::Bot::Ball8;
use Telegram::Bot::CatClient;
use Telegram::Bot::Config;
use Telegram::Bot::DrinksClient;
use Telegram::Bot::GenderClient;
use Telegram::Bot::Memes;
use Telegram::Bot::MusicDB;
use Telegram::Bot::RandomNumber;
use Telegram::Bot::UUIDClient;
use Telegram::Bot::Weather::Location;
use Time::Duration;
use WWW::Telegram::BotAPI;
use URI::URL;
use POSIX;
use utf8;

BEGIN {
	our $VERSION = '1.3.1';
}

my $api = __makeAPI();
# ... but error handling is available as well.
#my $result = eval { $api->getMe->{result}{username} }
#    or die 'Got error message: ', $api->parse_error->{msg};
#warn $result;

#Mojo::IOLoop->start;

# Bump up the timeout when Mojo::UserAgent is used (LWP::UserAgent uses 180s by default)
$api->agent->can('inactivity_timeout') and $api->agent->inactivity_timeout(45);
my $me = $api->getMe or die;
my ($offset, $updates) = 0;

my $musicDb = Telegram::Bot::MusicDB->new();
my $uuidClient = Telegram::Bot::UUIDClient->new();
my $drinksClient = DrinksClient->new();
my $genderClient = GenderClient->new();
my $memes = Telegram::Bot::Memes->new(api => $api);
my $startTime = time();
my $config;
my $admins;
my $visualCrossing;

sub source {
	return "Source code for the bot can be obtained from https://git.sr.ht/~m6kvm/telegram-bot\n" .
	    'Patches and memes may be sent to palmer@overchat.org with subject "telegram-bot"';
}

sub breakfast {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off 'breakfast'
	my $name = $words[0] ? $words[0] : 'jesscharlton';
	$name = '@' . $name if (index($name, '@') != 0);
	return "Has old $name had their breakfast yet?";
}

sub version {
	my @output = `git rev-parse HEAD`;
	unshift(@output, $Telegram::Bot::VERSION);
	return join("\n", @output);
}

sub memeSearch {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my $id = $input[0]->{chat}->{id};

	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off '/m'

	my $name = shift(@words);
	$name =~ s/\s+//g; # no spaces
	$name =~ s/^\#//; # Telegram tag not required but useful for tab completion

	$memes->chatId($id);
	my $results = $memes->search($name);
	if (scalar(@$results) == 0) {
		return "There is no meme like that.  Send me a PM or tag me in an image and then use '/meme add <name>'";
	} elsif (scalar(@$results) == 1) {
		if (my $meme = $memes->run($results->[0], @words)) {
			return $meme;
		}
	} else {
		return "Multiple matches, could be any of these:\n" . join("\n", @$results);
	}
}

sub memeAddRemove {
	my ($picId, @input) = @_;
	my $syntax = 0;
	my $text = $input[0]->{text};

	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off '/meme'

	my ($op, $name) = @words;
	if ($op) {
		if ($op eq 'add' || $op eq 'new') {
			return $memes->add($name, $picId);
		} elsif ($op eq 'remove' || $op eq 'delete' || $op eq 'del' || $op eq 'rm' || $op eq 'erase' || $op eq 'expunge' || $op eq 'purge') {
			return $memes->remove($name);
		} elsif ($op eq 'post') {
			my $url;
			(undef, $url, @words) = @words;
			return +{
				method  => 'sendPhoto',
				photo   => $url,
				caption => join(' ', @words),
			};

		} else {
			$syntax = 1;
		}
	} else {
		$syntax = 1;
	}

	if ($syntax) {
		return 'syntax: /meme [add|rm] <meme name>';
	}

	return "Can't get here";
}

sub ball8 {
	return Telegram::Bot::Ball8->new()->run();
}

sub randomNumber {
	return Telegram::Bot::RandomNumber->new()->run();
}

sub insult {
	return 'You manky Scotch git';
}

sub __makeAPI {
	$config = Telegram::Bot::Config->new();
	my $token = $config->getSectionByName(__PACKAGE__)->getValueByKey('api_key');
	die 'No API token' unless ($token);

	$admins = Telegram::Bot::Admins->new(config => $config);
	$admins->load();

	$visualCrossing = Geo::Weather::VisualCrossing->new({
		apiKey => $config->getSectionByName('Telegram::Bot::Weather::Client')->getValueByKey('api_key'),
	});

	$Data::Money::Currency::Converter::Repository::APILayer::apiKey =
	    $config->getSectionByName('Data::Money::Currency::Converter::Repository::APILayer')
	    ->getValueByKey('api_key');

	return WWW::Telegram::BotAPI->new (
		#async => 1, # WARNING: may fail if Mojo::UserAgent is not available!
		token => $token,
	);
}

# The commands that this bot supports.
my $pic_id; # file_id of the last sent picture
my $commands = {
	'yt' => sub {
		my (@input) = @_;
		warn Dumper $input[0];
		my $text = $input[0]->{text};

		if ($text =~ m/^\/yt\s+(https.*)/) {
			my $url = URI::URL->new($1);
			my %attribs = split(m/&/, $url->query);
			#my $id;
			#while (my ($k, $v) = each(%pairs)) {
			#	my %attribs = split(m/&/, $url->query);
			#	next if ($k ne 'v');
			#	$id = $v;
			#	last;
			#}
			my $id = 0;

			return "No 'v' video param identified in the URL" if (!$id);

			$url = "https://youtube.com/watch?v=$id";
			return "Would download from $url";
		} elsif ($text =~ m/^\/yt\s+(\w+)/) {
			my $id = $1;
			my $url = "https://youtube.com/watch?v=$1";
			return "Would download from $url";
		} else {
			return "I don't recognize the ID or URL";
		}
	},
	'version' => \&version,
	'search' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		$text = $words[1];
		if ($text) {
			my $results = $musicDb->search($text);
			if (scalar(@$results)) {
				return join("\n", @$results);
			} else {
				return "I don't have that track :(";
			}
		} else {
			return 'Missing criteria';
		}
	},
	'm' => \&memeSearch,
	'meme' => sub {
		memeAddRemove($pic_id, @_); # FIXME: Setting pic_id = undef after call doesn't work properly, even though I need to do it.
	},
	'me' => sub {
		my (@input) = @_;
		if (my $text = $input[0]->{text}) {
			if ($text =~ m/\s+tea/) {
				return 'I should like mine with milk and no sugar, thanks';
			} elsif ($text =~ m/onder.*poo-poo/) {
				return "I think everybody is balls-deep :(";
			} elsif ($text =~ m/eat.*desk/i) {
				return 'you filthy animal :(';
			}
			return '';
		}
	},
	'8ball', => \&ball8,
	'random' => \&randomNumber,
	'horatio' => sub { return 'licking Ben\'s roast potato' },
	'insult' => \&insult,
	'ben' => sub { return 'He\'s at the garage having his tires rotated' },
	'breakfast' => \&breakfast,
	'source' => \&source,
	'miles' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my (undef, $amount) = @words;
		return sprintf('%s miles', $amount * 0.62137119);
	},
	'usd' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my ($currencyStandard, $amount) = @words;
		$currencyStandard = uc(substr($currencyStandard, 1, 3));
		my $gbpAmount = Data::Money::Amount->fromPounds($amount, 'GBP')->convert($currencyStandard);
		return $gbpAmount ? $gbpAmount->toString() : 'Something went wrong'; # TODO: should be able to get messages from library
	},
	'gbp' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my ($currencyStandard, $amount) = @words;
		$currencyStandard = uc(substr($currencyStandard, 1, 3));
		my $usdAmount = Data::Money::Amount->fromPounds($amount, 'USD')->convert($currencyStandard);
		return $usdAmount ? $usdAmount->toString() : 'Something went wrong'; # TODO: should be able to get messages from library
	},
	'weather' => sub {
		my (@input) = @_;
		my $user = $input[0]->{from}{username};
		my $text = $input[0]->{text};

		my @words = split(m/\s+/, $text);
		shift(@words);

		my $location = Telegram::Bot::Weather::Location->new(); # TODO: Global?

		#detaint
		my @place;
		for (my $i = 0; $i < scalar(@words); $i++) {
			if ($words[$i] && $words[$i] =~ m/([a-z,]+)/i) {
				push(@place, $words[$i]);
			}
		}

		if (scalar(@place)) {
			$location->run($user, join(' ', @place)); # store for next go
		} else {
			$place[0] = $location->run($user);
			$place[0] = 'Bath,GB' if ($place[0] eq 'nowhere');
		}

		my $report = $visualCrossing->lookup(join(' ', @place));
		return '[ERROR: CITY ' . join(' ', @place) . ' NOT FOUND]' unless ($report);
		return $report->getScorpStuffFormat();
	},
	'lyfe' => sub {
		return 'Such is the drinking lyfe 😩';
	},
	'error' => sub {
		# TODO: You should use https://s5ock2i7gptq4b6h5rlvw6szva0wojrd.lambda-url.eu-west-2.on.aws/ now
		my $key = 1 + int(rand(462));
		my $error = `aws --profile palmer dynamodb get-item --table-name excuses4 --key='{ "ident": { "S": "$key" } }' --cli-read-timeout 1800 | jq -a -r .Item.english.S`;
		return $error;
	},
	'tableflip' => sub {
		return '(┛ಠ_ಠ)┛彡┻━┻';
	},
	'disapproval' => sub {
		return 'ಠ_ಠ';
	},
	'sis' => sub {
		return '🚢🐿️';
	},
	'bird' => sub {
		return '🕊️';
	},
	'bitbucket' => sub {
		return '0️⃣1️⃣🪣';
	},
	'shrug' => sub {
		return '¯\_(ツ)_/¯';
	},
	'uuid' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my ($version, $count) = (1, 1);
		my $results;
		shift(@words); # Sack off 'uuid'

		foreach my $word (@words) {
			if ($word =~ m/^v(\d)$/i) {
				$version = $1;
				return "Sorry, only versions 1 or 4 supported, but I'm working on it" unless ($version == 1 || $version == 4);
			} elsif ($word =~ m/^\d{1,2}$/) {
				$count = $word;
			} elsif ($word =~ m/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/io) {
				$results = $uuidClient->info($word);
			} else {
				return "Usage: /uuid v[version] [count] [uuid]\n"
				    . "Default UUID version is 1, count up to 99 is allowed, the default is 1.\n"
				    . "Versions supported: 1, 4\n\n"
				    . "If a UUID is supplied, information about the UUID is returned.";
			}
		}

		unless ($results) {
			printf(STDERR "count has been set to %s\n", $uuidClient->count($count));
			printf(STDERR "version has been set to %s\n", $uuidClient->version($version));

			$results = $uuidClient->generate();
		}

		if (scalar(@$results) > 0) {
			return join("\n", @$results);
		} else {
			return "Something went wrong";
		}
	},
	'beer' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'beer');
	},
	'🍺' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'beer');
	},
	'coffee' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'coffee');
	},
	'☕️' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'coffee');
	},
	'tea' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'tea');
	},
	'🫖' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'tea');
	},
	'water' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'water');
	},
	'💦' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'water');
	},
	'gender' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my $username = $input[0]->{from}{username};
		return $genderClient->run($username, $words[1]);
	},
	'uptime' => sub {
		my $uname = `uname -a`;
		my $sysUptime = `uptime`;
		my $uptime = duration_exact(time() - $startTime);

		chomp($uname);
		chomp($sysUptime);

		my $value = "$uname\n$sysUptime\n\nScript uptime: $uptime";

		return $value;
	},
	'ynyr' => sub { return "Not as old as all that" },
	# Example demonstrating the use of parameters in a command.
	'say' => sub {
		join " ", splice @_, 1 or "Usage: /say something"
	},
	'cat' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		$text = $words[1];
		my $message = 'unknown';
		eval { $message = status_message($text) };
		my $file = Telegram::Bot::CatClient->new->run($text);
		+{
			method  => "sendPhoto",
			photo   => {
				file => $file,
			},
			caption => sprintf("HTTP %d: '%s'", $text, $message),
		},
	},
	'_unknown' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my $id = $input[0]->{chat}->{id};
		my @words = split(m/\s+/, $text);

		$memes->chatId($id);
		if (my $meme = $memes->run(@words)) {
			return $meme;
		}

		return "Unknown command :( Try /start";
	},
};

# Generate the command list dynamically.
$commands->{start} = "Hello! Try /" . join " - /", grep !/^_/, keys %$commands;

# Special message type handling
my $message_types = {
	# Save the picture ID to use it in `lastphoto`.
	'photo' => sub {
			$pic_id = shift->{photo}[-1]{file_id};
			+{
				method     => 'sendMessage',
				text       => "OK I've seen your meme, now say /meme add <name>.\n"
				    . 'NOTE: This operation is slow, please be patient, the bot may not respond for up to a minute.',
			},
	},
};

printf "Hello! I am %s. Starting...\n", $me->{result}{username};

my $breakfastDone = 0;
my $backCounter = 0;
sub backgroundTasks {
	my $chatId = 0;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time());

	return if ($wday == 0 || $wday == 6); # No action at the weekend

	$backCounter++;
	return;
	if ((time() % 125) == 0) {
		my $message;
		if (($backCounter % 3) == 0) {
			$message = 'What year is it?';
		} elsif (($backCounter % 9) == 0) {
			$message = "Where am I?";
		} else {
			$message = "Who's the President?";
		}

		$api->sendMessage({
			chat_id => $chatId,
			(
				text => $message,
			),
		});

		return;
	} elsif ((time() % 194) == 0) {
		$api->sendMessage({
			chat_id => $chatId,
			(
				text => 'actio Benedict est actio dei',
			),
		});
	}

	return if ($hour != 17 || $min != 15); # only operate for 1 min a day
	return if ($breakfastDone); # FIXME need to clear once a day... or store the date in a HASH

	#eval {
		$api->sendMessage({
			chat_id => $chatId,
			(
				text => breakfast({
					text => '/breakfast @m6kvm',
				}),
			),
		});
	#};

	$breakfastDone++;

	return;
}

while (1) {
	eval {
		$updates = $api->getUpdates ({
			timeout => 30, # Use long polling
			$offset ? (offset => $offset) : ()
		});
	};
	if (my $evalError = $EVAL_ERROR) {
		sleep 300;
	}

	backgroundTasks();

    unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
        warn "WARNING: getUpdates returned a false value - trying again...";
        next;
    }

    for my $u (@{$updates->{result}}) {
        warn $u->{message}{chat}{id};
        $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
        if (my $text = $u->{message}{text}) { # Text message
            printf "Incoming text message from \@%s\n", ($u->{message}{from}{username} // '<undef>');
            printf "Text: %s\n", $text;
            next if (index($text, '/') != 0); # Not a command
            my ($cmd, @params) = split / /, $text;
            my $res = $commands->{substr($cmd, 1)} || $commands->{_unknown};
            # Pass to the subroutine the message object, and the parameters passed to the cmd.
            $res = $res->($u->{message}, @params) if ref $res eq "CODE";
            next unless $res;
            my $method = ref $res && $res->{method} ? delete $res->{method} : "sendMessage";
            eval {
		    $api->$method ({
			chat_id => $u->{message}{chat}{id},
			ref $res ? %$res : ( text => $res )
		    });
            };
            print "Reply sent.\n";
        }
        # Handle other message types.
        for my $type (keys %{$u->{message} || {}}) {
            next unless exists $message_types->{$type} and
                        ref (my $res = $message_types->{$type}->($u->{message}));
            my $method = delete($res->{method}) || "sendMessage";
            $api->$method({
                chat_id => $u->{message}{chat}{id},
                %$res
            });
        }
    }
}

1;

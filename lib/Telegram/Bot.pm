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

# When running from the git clone --recursive checkout
use lib './externals/libdata-money-perl/lib';
use lib './externals/libdata-geo-weather-visualcrossing-perl/lib';

use Data::Dumper;
use Data::Money::Amount 0.2.0;
use Data::Money::Currency::Converter::Repository::APILayer 0.2.0;
use English qw(-no_match_vars);
use Fcntl;
use Geo::Weather::VisualCrossing;
use HTTP::Status qw(status_message);
#use Log::Log4perl;
use Readonly;
use Telegram::Bot::Admins;
use Telegram::Bot::Audit;
use Telegram::Bot::Ball8;
use Telegram::Bot::CatClient;
use Telegram::Bot::Config;
use Telegram::Bot::DB;
use Telegram::Bot::DI::Container;
use Telegram::Bot::DrinksClient;
use Telegram::Bot::GenderClient;
use Telegram::Bot::Karma;
use Telegram::Bot::Memes;
use Telegram::Bot::MusicDB;
use Telegram::Bot::RandomNumber;
use Telegram::Bot::User::Repository;
use Telegram::Bot::UUIDClient;
use Telegram::Bot::Weather::Location;
use Time::Duration;
use URI::URL;
use POSIX qw(:errno_h);
use utf8;

BEGIN {
	our $VERSION = '2.4.0';
}

Readonly my $FIFO_PATH   => '/var/run/telegram-bot/timed-messages.fifo';
Readonly my $FIFO_BUFSIZ => 1024;

my $stop = 0;
my $dic = Telegram::Bot::DI::Container->new();
my $api = $dic->api;
my $me = $dic->api->getMe or die;
my ($offset, $updates) = 0;

my $startTime = time();
my $visualCrossing;
__startup(); ## FIXME

sub karma {
	my (@input) = @_;
#	my $user = $input[0]->{from}{username};
#	my $text = $input[0]->{text};

#	my (@words) = split(m/\s+/, $text);
#	return $karma->run($words[0], 1);
	return $dic->karma->run($input[0]->{text});
}

sub source {
	return 'Source code for the bot can be obtained from '
	    . "https://git.sr.ht/~m6kvm/telegram-bot/refs/v${Telegram::Bot::VERSION}\n"
	    . 'Patches and memes may be sent to 2e0eol@gmail.com with subject "telegram-bot"';
}

sub units {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my $user = $input[0]->{from}{username}; # optional, used only for /units record
	return $dic->alcoholUnits->run($text, $user);
}

sub bugger {
	return $dic->bugger->run();
}

sub xkcd {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my @words = split(m/\s+/, $text);
	my $ident = $words[1];

	if ($ident) {
		if (my $url = $dic->xkcd->run($ident)) {
			return +{
				method  => 'sendPhoto',
				photo   => {
					file => $url,
				},
			};
		}
	} else {
		return 'Usage: /xkcd <nnnn>';
	}

	return 'oops, no comic';
}

sub food {
	my (@input) = @_;
	return 'You should all eat ' . $dic->food->run();
}

sub breakfast {
	my (@input) = @_;
	my $user = $input[0]->{from}{username} || 'anonymous';
	my $text = $input[0]->{text};

	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off 'breakfast'
	my $name = $words[0] ? $words[0] : $user;
	$name = '@' . $name if (index($name, '@') != 0);

	my $their = $dic->genderClient->get($name)->their();
	return "Has old $name had $their breakfast yet?";
}

sub version {
	my @output = `git rev-parse HEAD`;
	unshift(@output, $Telegram::Bot::VERSION);
	return join("\n", @output);
}

sub memeSearch {
	my (@input) = @_;
	my $user = $input[0]->{from}{username};
	my $text = $input[0]->{text};
	my $id = $input[0]->{chat}->{id};

	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off '/m'

	my $name = shift(@words);
	$name =~ s/\s+//g; # no spaces
	$name =~ s/^\#//; # Telegram tag not required but useful for tab completion

	$dic->memes->chatId($id);
	my $results = $dic->memes->search($name);
	if (scalar(@$results) == 0) {
		return "There is no meme like that.  Send me an image in a PM and then use '/meme add <name>'";
	} elsif (scalar(@$results) == 1) {
		if (my $meme = $dic->memes->setUser($user)->run($results->[0], @words)) {
			return $meme;
		}
	} else {
		return "Multiple matches, could be any of these:\n" . join("\n", @$results);
	}
}

sub memeAddRemove {
	my ($picId, @input) = @_;
	my $syntax = 0;
	my $user = $input[0]->{from}{username} || '';
	my $text = $input[0]->{text};

	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off '/meme'

	my ($op, $name) = @words;
	if ($op) {
		if ($op eq 'add' || $op eq 'new') {
			return $dic->memes->setUser($user)->add($name, $picId);
		} elsif ($op eq 'remove' || $op eq 'delete' || $op eq 'del' || $op eq 'rm' || $op eq 'erase' || $op eq 'expunge' || $op eq 'purge') {
			return $dic->memes->setUser($user)->remove($name);
		} elsif ($op eq 'post') {
			my $url;
			(undef, $url, @words) = @words;
			return +{
				method  => 'sendPhoto',
				photo   => { file => $url },
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
	return $dic->ball8->run();
}

sub kappagen {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my @words = split(m/\s+/, $text);
	shift(@words); # discard /kappagen

	return $dic->kappagen->run(@words);
}

sub randomNumber {
	return $dic->randomNumber->run();
}

sub insult {
	return 'You manky Scotch git';
}

sub recordStartup {
	$dic->logger->info(sprintf("Telegram-bot (@%s). Starting.  For full documentation, say /source to the bot.  To increase debug, send SIGUSR1 to %s", $me->{result}{username}, $$));
	$dic->audit->acquireSession()->recordStartup();

	return;
}

sub recordShutdown {
	$dic->logger->info('Shutting down');
	$stop = 1;

	return;
}

sub logLevelChange {
	my ($delta) = @_;
	my $logger = $dic->logger;

	if ($delta > 0) {
		$logger->more_logging($delta);
		$logger->info('Increased log level via SIGUSR1');
	} else {
		$delta = abs($delta);
		$logger->info('Decreased log level via SIGUSR2');
		$logger->less_logging($delta);
	}

	return;
}

sub installSignals {
	$SIG{USR1} = sub { logLevelChange(1) };
	$SIG{USR2} = sub { logLevelChange(-1) };
	$SIG{TERM} = $SIG{INT} = \&recordShutdown;

	return;
}

# FIXME: This method should not exist.  use DI Container!
sub __startup {
	$dic->logger->warn('TODO: Legacy __startup called');
	$dic->admins->load();

	$visualCrossing = Geo::Weather::VisualCrossing->new({
		apiKey => $dic->config->getSectionByName('Telegram::Bot::Weather::Client')->getValueByKey('api_key'),
	});

	$Data::Money::Currency::Converter::Repository::APILayer::apiKey =
	    $dic->config->getSectionByName('Data::Money::Currency::Converter::Repository::APILayer')
	    ->getValueByKey('api_key');
}

my %pic_id; # file_id of the last sent picture (per user)
sub __setPicId {
	my ($user, $picId) = @_;
	$pic_id{$user} = $picId;
	$picId = $picId ? "'$picId'" : '<undef>';
	$dic->logger->debug("Set user '$user' staged meme to $picId");
	return;
}

# The commands that this bot supports.
my $commands = {
	'yt' => sub {
		my (@input) = @_;
		$dic->logger->trace(Dumper $input[0]);
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
	'units' => \&units,
	'bugger' => \&bugger,
	'version' => \&version,
	'search' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		$text = $words[1];
		if ($text) {
			my $results = $dic->musicDB->search($text);
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
		my (@input) = @_;
		my $user = $input[0]->{from}{username} || 'anonymous';
		my $answer = memeAddRemove($pic_id{$user}, @_);
		__setPicId($user, undef);
		return $answer;
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
	'8ball' => \&ball8,
	'xkcd' => \&xkcd,
	'k' => \&karma,
	'kappagen' => \&kappagen,
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
		my $gbpAmount = Data::Money::Amount->fromPounds($amount, 'GBP')->convert($currencyStandard); # FIXME: DIC
		return $gbpAmount ? $gbpAmount->toString() : 'Something went wrong'; # TODO: should be able to get messages from library
	},
	'gbp' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my ($currencyStandard, $amount) = @words;
		$currencyStandard = uc(substr($currencyStandard, 1, 3));
		my $usdAmount = Data::Money::Amount->fromPounds($amount, 'USD')->convert($currencyStandard); # FIXME: DIC
		return $usdAmount ? $usdAmount->toString() : 'Something went wrong'; # TODO: should be able to get messages from library
	},
	'weather' => sub {
		my (@input) = @_;
		my $user = $input[0]->{from}{username};
		my $text = $input[0]->{text};

		my @words = split(m/\s+/, $text);
		shift(@words);

		my $location = $dic->weatherLocation;

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
		my $error = `aws --profile telegram dynamodb get-item --table-name excuses4 --key='{ "ident": { "S": "$key" } }' --cli-read-timeout 1800 | jq -a -r .Item.english.S`;
		return $error;
	},
	'food' => \&food,
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
				$results = [$dic->uuidClient->info($word)];
			} else {
				return "Usage: /uuid v[version] [count] [uuid]\n"
				    . "Default UUID version is 1, count up to 99 is allowed, the default is 1.\n"
				    . "Versions supported: 1, 4\n\n"
				    . "If a UUID is supplied, information about the UUID is returned.";
			}
		}

		unless ($results) {
			printf(STDERR "count has been set to %s\n", $dic->uuidClient->count($count));
			printf(STDERR "version has been set to %s\n", $dic->uuidClient->version($version));

			$results = $dic->uuidClient->generate();
		}

		if (scalar(@$results) > 0) {
			return join("\n", @$results);
		} else {
			return "Something went wrong";
		}
	},
	'beer' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'beer');
	},
	'🍺' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'beer');
	},
	'coffee' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'coffee');
	},
	'☕️' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'coffee');
	},
	'tea' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'tea');
	},
	'🫖' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'tea');
	},
	'water' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'water');
	},
	'💦' => sub {
		my $username = shift->{from}{username};
		return $dic->drinksClient->run($username // 'anonymous', 'water');
	},
	'gender' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my $username = $input[0]->{from}{username};
		return $dic->genderClient->run($username, $words[1]);
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
		my $file = $dic->catClient->run($text);
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
		my $user = $input[0]->{from}{username};
		my $text = $input[0]->{text};
		my $id = $input[0]->{chat}->{id};
		my @words = split(m/\s+/, $text);

		$dic->memes->chatId($id);
		if (my $meme = $dic->memes->setUser($user // '')->run(@words)) {
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
		my (@input) = @_;
		my $user = $input[0]->{from}{username} || 'anonymous';
		__setPicId($user, shift->{photo}[-1]{file_id});
		+{
			method     => 'sendMessage',
			text       => "OK I've seen your meme, now say /meme add <name>.\n"
			    . 'NOTE: This operation is slow, please be patient, the bot may not respond for up to a minute.',
		},
	},
};

recordStartup();
installSignals();

my @backgroundTaskQueue = ();

sub handle_fifo_record {
	my ($record) = @_;
	$dic->logger->trace('FROM FIFO: ' . $record); # FIXME: Ignored
	my (@attribs) = split(m/\|/, $record);

	my %params = (
		chat_id => 0,
		target => 'M6KVM',
		text => '(none)',
	);

	foreach my $attrib (@attribs) {
		my ($key, $value) = split(m/:/, $attrib);
		my $skip = (!defined($key) || !defined($value));

		$key = '<undef>' unless (defined($key));
		$value = '<undef>' unless (defined($value));
		$dic->logger->trace("handle_fifo_record: key: $key, value: $value");

		if ($skip) {
			$dic->logger->warn('Skipping incomplete background command attribute');
			next;
		}

		if (exists($params{$key})) {
			$params{$key} = $value;
		}
	}

	$dic->logger->trace(Dumper \%params);

	push(@backgroundTaskQueue, {
		ok => 1,
		result => [
			{
				message => {
					from => {
						#first_name => 'Duncan',
						language_code => 'en',
						username => 'M6KVM',
						#last_name => 'Palmer',
						is_bot => 1, # from script
						id => 1135496320,
					},
					entities => [
						{
							length => length($params{text}),
							offset => 0,
							type => 'bot_command'
						},
					],
					text => $params{text},
					chat => {
						last_name => 'Palmer',
						first_name => 'Duncan',
						id => $params{chat_id},
						username => $params{target},
						type => 'private'
					},
					date => time(),
					message_id => 1 + int(rand(999999999)),
				},
				update_id => 0,
			},
		],
	});

	return;
}

my $buffer = '';
sub loadNextBackgroundTasks {
	my $command = '';
	my ($rv);

	if (length($buffer) > 0) {
		$dic->logger->warn("BUFFER CONTENT UNCLEARED: $buffer");
		$buffer = '';
	}

	do {
		if ($rv = sysread(MESSAGES, $buffer, $FIFO_BUFSIZ)) {
			if ($rv > 0) {
				my @commands = split(m/\n/, $buffer);
				foreach my $command (@commands) {
					$dic->logger->debug("Queueing background command: '$command'");
					&handle_fifo_record($command);
				}
			}
		}
	} while ($rv || $! == EAGAIN);

	return;
}

sysopen(MESSAGES, $FIFO_PATH, O_NONBLOCK|O_RDONLY)
    or die("The FIFO file \"$FIFO_PATH\" is missing, and this program can't run without it.");

sub getNextUpdates {
	loadNextBackgroundTasks();

	if (my $backgroundUpdates = pop(@backgroundTaskQueue)) { # Doesn't matter if empty or not
		$dic->logger->debug("Background task retrieved from queue");
		return $backgroundUpdates;
	}

	my $foregroundUpdates;
	eval {
		$foregroundUpdates = $api->getUpdates ({
			timeout => 30, # Use long polling
			$offset ? (offset => $offset) : ()
		});
	};
	if (my $evalError = $EVAL_ERROR) {
		sleep 30;
	}

	return $foregroundUpdates;
}

while (0 == $stop) {
	my $updates = undef;
	do {
		$updates = getNextUpdates();
		sleep(1) unless ($updates);
	} while (!$updates);

    unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
        $dic->logger->warn('getUpdates returned a false value - trying again...');
        next;
    }

    for my $u (@{$updates->{result}}) {
	$dic->logger->trace(Dumper $u);
	$dic->logger->trace('chat id ' . $u->{message}{chat}{id});
        $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
        if (my $text = $u->{message}{text}) { # Text message
            $dic->logger->debug(sprintf("Incoming text message from \@%s", ($u->{message}{from}{username} // '<undef>')));
            $dic->logger->trace(sprintf("Text: %s\n", $text));
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
            $dic->logger->debug('Reply sent');
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

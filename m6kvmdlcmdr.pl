#!/usr/bin/env perl

package CatClient;
use strict;
use warnings;
use LWP::UserAgent;
use Moose;
use Readonly;
use URI;
use URI::Encode;

Readonly my $CAT_URL => 'https://http.cat/%d';

has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub run {
	my ($self, $code) = @_;
	return undef unless ($code);

	my $file = $self->__getFile($code, undef);
	return $file if ($file);

	my $uri = URI->new($CAT_URL);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, int($code)));

	my $response = $self->__ua->get($uri);
	if ($response->is_success) {
		printf(STDERR "HTTP cat %d: %s\n", $code, $uri);
		return $self->__getFile($code, $response->decoded_content);
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	return $self->run(404);
}

sub __getFile {
	my ($self, $code, $content) = @_;
	mkdir('/tmp/palmer');
	mkdir('/tmp/palmer/m6kvmdlcmdr');
	my $name = sprintf('/tmp/palmer/m6kvmdlcmdr/%d.jpg', $code);
	return $name if -f $name;

	return undef unless ($content);

	my $fh = IO::File->new("> $name");
	if (defined $fh) {
		print $fh $content;
		$fh->close();
	} else {
		die("Sorry, cannot create $name: $!");
	}

	return $name;
}

package GenderClient;
use strict;
use warnings;
use LWP::UserAgent;
use Moose;
use Readonly;
use URI;
use URI::Encode;

Readonly my $GENDER_LAMBDA_URL => 'https://z5odrowet74mkrowq7djkflfd40uhjyg.lambda-url.eu-west-2.on.aws?user=%s&platform=telegram';

has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub run {
	my ($self, $username, $gender) = @_;

	if ($gender && substr($gender, 0, 1) eq '@') {
		$username = substr($gender, 1);
		$gender = undef;
	}

	$username = '' unless ($username);

	my $uri = $GENDER_LAMBDA_URL;
	$uri .= '&gender=' . $gender if ($gender);
	$uri = URI->new($uri);

	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username));

	return $self->__ua->get($uri)->decoded_content;
}

package DrinksClient;
use strict;
use warnings;
use LWP::UserAgent;
use Moose;
use Readonly;
use URI;
use URI::Encode;

Readonly my $LAMBDA_URL => 'https://4rkhnkrdqaaqfijye73f2zfb6a0ypkpr.lambda-url.eu-west-2.on.aws/?user=%s&type=%s&platform=telegram';

has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub run {
	my ($self, $username, $type) = @_;

	my $uri = URI->new($LAMBDA_URL);
	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username, $type));

	my $response = $self->__ua->get($uri);
	if ($response->is_success) {
		return $response->decoded_content;
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	return $response
}

package UUIDClient;
use strict;
use warnings;
use Moose;
use Readonly;
use Getopt::Std;
use JSON qw(decode_json);
use LWP::UserAgent;
use MIME::Base64;
use URI;

Readonly my $URL => 'http://perlapi.daybologic.co.uk/v2/uuid/generate';
Readonly my $URL_2 => 'http://perlapi.daybologic.co.uk/v2/uuid/info';

has [qw(count version)] => (is => 'rw', isa => 'Int', default => 1);
has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub info {
	my ($self, $uuidStr) = @_;

	my $uri = URI->new(join('/', $URL_2, $uuidStr));
	$uri->query_form({});

	my @results;
	printf(STDERR "%s\n", $uri);

	my $response = $self->__ua->get($uri);
	if ($response->is_success) {
		my $decoded = decode_json(decode_base64($response->decoded_content));
		foreach my $key (keys(%$decoded)) {
			next unless (defined($decoded->{$key}));
			my $value = $decoded->{$key};
			push(@results, "$key: $value");
		}
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	printf(STDERR "%d results generated.\n", scalar(@results));
	return \@results;
}

sub generate {
	my ($self) = @_;

	my %opts = (
		n => $self->count,
		v => $self->version,
	);

	my $uri = URI->new($URL);
	$uri->query_form(\%opts);

	my @results;
	#my @args = join('=', each(%opts));
	#my $uri = $URL . join('&', @args);
	printf(STDERR "%s\n", $uri);

	my $response = $self->__ua->get($uri);
	if ($response->is_success) {
		my $decoded = decode_json(decode_base64($response->decoded_content));
		foreach my $result (@{ $decoded->{results} }) {
			push(@results, sprintf("%s\n", $result->{value}));
		}
	} else {
		printf(STDERR "%s\n", $response->status_line);
	}

	printf(STDERR "%d results generated.\n", scalar(@results));
	return \@results;
}

package MusicDB;
use strict;
use warnings;
use Moose;
use Readonly;

Readonly my $MUSIC_DB => '/var/lib/palmer/music-database.list';
Readonly my $LIMIT => 20;

has __db => (isa => 'ArrayRef[Str]', is => 'rw', default => sub {
	return [ ];
});

sub BUILD {
	my ($self) = @_;

	$self->__reload();
}

sub __reload {
	my ($self) = @_;

	@{ $self->__db } = (); # flush

	my $fh = IO::File->new();
	if ($fh->open("< $MUSIC_DB")) {
		while (my $line = <$fh>) {
			chomp($line);
			push(@{ $self->__db}, $line);
		}
		warn sprintf("%d tracks loaded\n", scalar(@{ $self->__db }));
		$fh->close;
	}

	return;
}

sub search {
	my ($self, $criteria) = @_;

	$criteria =~ s/\W//g;

	my @results = grep(/$criteria/i, @{ $self->__db });
	$#results = $LIMIT - 1 if (scalar(@results) > $LIMIT);

	warn(sprintf("Query '%s' returned %d results\n", $criteria, scalar(@results)));
	return \@results;
}

package main;
use strict;
use warnings;
use Data::Dumper;
use Data::Money::Amount;
use English;
use HTTP::Status qw(status_message);
use Readonly;
use Time::Duration;
use WWW::Telegram::BotAPI;
use URI::URL;
use POSIX;

my $api = WWW::Telegram::BotAPI->new (
    #async => 1, # WARNING: may fail if Mojo::UserAgent is not available!
    token => '1702305769:AAHX_qVERvhB6velZ_jgLRAgR8Ax0_VWdDU',
);
# ... but error handling is available as well.
#my $result = eval { $api->getMe->{result}{username} }
#    or die 'Got error message: ', $api->parse_error->{msg};
#warn $result;

#Mojo::IOLoop->start;

# Bump up the timeout when Mojo::UserAgent is used (LWP::UserAgent uses 180s by default)
$api->agent->can('inactivity_timeout') and $api->agent->inactivity_timeout(45);
my $me = $api->getMe or die;
my ($offset, $updates) = 0;
my $musicDb = MusicDB->new();
my $uuidClient = UUIDClient->new();
my $drinksClient = DrinksClient->new();
my $genderClient = GenderClient->new();
my $startTime = time();

sub breakfast {
	my (@input) = @_;
	my $text = $input[0]->{text};
	my @words = split(m/\s+/, $text);
	shift(@words); # Sack off 'breakfast'
	my $name = $words[0] ? $words[0] : 'jesscharlton';
	$name = '@' . $name if (index($name, '@') != 0);
	return "Has old $name had their breakfast yet?";
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
	'me' => sub {
		my (@input) = @_;
		if (my $text = $input[0]->{text}) {
			if ($text =~ m/\s+tea/) {
				return 'I should like mine with milk and no sugar, thanks';
			} elsif ($text =~ m/onder.*poo-poo/) {
				return "I think everybody is balls-deep :(";
			}
			return '';
		}
	},
	'horatio' => sub { return 'licking Ben\'s roast potato' },
	'ben' => sub { return 'He\'s at the garage having his tires rotated' },
	'breakfast' => \&breakfast,
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
		my @text = `lynx -dump 'https://api.scorpstuff.com/weather.php?units=imperial&city=bath,GB'`;
		return join("\n", @text);
	},
	'error' => sub {
		# TODO: You should use https://s5ock2i7gptq4b6h5rlvw6szva0wojrd.lambda-url.eu-west-2.on.aws/ now
		my $key = 1 + int(rand(462));
		my $error = `aws --profile palmer dynamodb get-item --table-name excuses4 --key='{ "ident": { "S": "$key" } }' --cli-read-timeout 1800 | jq -a -r .Item.english.S`;
		return $error;
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
	'irnbru' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'beer');
	},
	'monster' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'beer');
	},
	'redbull' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'beer');
	},
	'coffee' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'coffee');
	},
	'tea' => sub {
		my $username = shift->{from}{username};
		return $drinksClient->run($username // 'anonymous', 'tea');
	},
	'water' => sub {
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
    "say"      => sub { join " ", splice @_, 1 or "Usage: /say something" },
    # Example showing how to use the result of an API call.
    "whoami"   => sub {
        sprintf "Hello %s, I am %s! How are you?", shift->{from}{username}, $me->{result}{username}
    },
    # Example showing how to send multiple lines in a single message.
    "knock"    => sub {
        sprintf "Knock-knock.\n- Who's there?\n@%s!", $me->{result}{username}
    },
    # Example displaying a keyboard with some simple options.
    "keyboard" => sub {
        +{
            text => "Here's a cool keyboard.",
            reply_markup => {
                keyboard => [ [ "a" .. "c" ], [ "d" .. "f" ], [ "g" .. "i" ] ],
                one_time_keyboard => \1 # \1 maps to "true" when being JSON-ified
            }
        }
    },
    # Let me identify yourself by sending your phone number to me.
    "phone" => sub {
        +{
            text => "Would you allow me to get your phone number please?",
            reply_markup => {
                keyboard => [
                    [
                        {
                            text => "Sure!",
                            request_contact => \1
                        },
                        "No, go away!"
                    ]
                ],
                one_time_keyboard => \1
            }
        }
    },
    # Test UTF-8
    "encoding" => sub { "Привет! こんにちは! Buondì!" },
    # Example sending a photo with a known picture ID.
    "lastphoto" => sub {
        return "You didn't send any picture!" unless $pic_id;
        +{
            method  => "sendPhoto",
            photo   => $pic_id,
            caption => "Here it is!"
        }
    },
	'cat' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		$text = $words[1];
		my $message = 'unknown';
		eval { $message = status_message($text) };
		my $file = CatClient->new->run($text);
		+{
			method  => "sendPhoto",
			photo   => {
				file => $file,
			},
			caption => sprintf("HTTP %d: '%s'", $text, $message),
		},
	},
    "_unknown" => "Unknown command :( Try /start"
};

# Generate the command list dynamically.
$commands->{start} = "Hello! Try /" . join " - /", grep !/^_/, keys %$commands;

# Special message type handling
my $message_types = {
    # Save the picture ID to use it in `lastphoto`.
    "photo" => sub { $pic_id = shift->{photo}[0]{file_id} },
    # Receive contacts!
    "contact" => sub {
        my $contact = shift->{contact};
        +{
            method     => "sendMessage",
            parse_mode => "Markdown",
            text       => sprintf (
                            "Here's some information about this contact.\n" .
                            "- Name: *%s*\n- Surname: *%s*\n" .
                            "- Phone number: *%s*\n- Telegram UID: *%s*",
                            $contact->{first_name}, $contact->{last_name} || "?",
                            $contact->{phone_number}, $contact->{user_id} || "?"
                        )
        }
    }
};

printf "Hello! I am %s. Starting...\n", $me->{result}{username};

my $breakfastDone = 0;
my $backCounter = 0;
sub backgroundTasks {
	#my $chatId = -1001540092066; # dummy channel
	my $chatId = -417147095; # The firm

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
            next if $text !~ m!^/[^_].!; # Not a command
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

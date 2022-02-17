#!/usr/bin/env perl

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

has [qw(count version)] => (is => 'rw', isa => 'Int', default => 1);
has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1,);

sub __makeUserAgent {
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
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
use English;
use Readonly;
use WWW::Telegram::BotAPI;
use URI::URL;

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
	'me' => sub { '' }, # no-op
	'uuid' => sub {
		my (@input) = @_;
		my $text = $input[0]->{text};
		my @words = split(m/\s+/, $text);
		my ($version, $count) = (1, 1);
		shift(@words); # Sack off 'uuid'
		foreach my $word (@words) {
			if ($word =~ m/^v(\d)$/i) {
				$version = $1;
				return "Sorry, only versions 1 or 4 supported, but I'm working on it" unless ($version == 1 || $version == 4);
			} elsif ($word =~ m/^\d{1,2}$/) {
				$count = $word;
			} else {
				return "Usage: /uuid v[version] [count]\n"
				    . "Default UUID version is 1, count up to 99 is allowed, the default is 1.\n"
				    . "Versions supported: 1, 4";
			}
		}

		printf(STDERR "count has been set to %s\n", $uuidClient->count($count));
		printf(STDERR "version has been set to %s\n", $uuidClient->version($version));

		my $results = $uuidClient->generate();
		if (scalar(@$results) > 0) {
			return join("\n", @$results);
		} else {
			return "Something went wrong";
		}
	},
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

    unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
        warn "WARNING: getUpdates returned a false value - trying again...";
        next;
    }
    for my $u (@{$updates->{result}}) {
        $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
        if (my $text = $u->{message}{text}) { # Text message
            printf "Incoming text message from \@%s\n", ($u->{message}{from}{username} // '<undef>');
            printf "Text: %s\n", $text;
            next if $text !~ m!^/[^_].!; # Not a command
            my ($cmd, @params) = split / /, $text;
            my $res = $commands->{substr ($cmd, 1)} || $commands->{_unknown};
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
            my $method = delete ($res->{method}) || "sendMessage";
            $api->$method ({
                chat_id => $u->{message}{chat}{id},
                %$res
            })
        }
    }
}

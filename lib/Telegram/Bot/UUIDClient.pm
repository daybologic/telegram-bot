package Telegram::Bot::UUIDClient;
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

1;

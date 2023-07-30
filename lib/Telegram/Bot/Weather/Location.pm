package Telegram::Bot::Weather::Location;
use strict;
use warnings;
use LWP::UserAgent;
use Moose;
use Readonly;
use URI;
use URI::Encode;
use URI::Escape;

Readonly my $LOCATION_LAMBDA_URL => 'https://oz4r4y4h2a2q2an2z2qtg7hwaa0ruejk.lambda-url.eu-west-2.on.aws?user=%s&platform=telegram';

has __ua => (is => 'rw', isa => 'LWP::UserAgent', default => \&__makeUserAgent, lazy => 1);

sub __makeUserAgent { # TODO: Should be shared, and possibly use same UA as Telegram API client
	my ($self) = @_;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(120);
	$ua->env_proxy;

	return $ua;
}

sub run {
	my ($self, $username, $location) = @_;

	$username = '' unless ($username);

	my $uri = $LOCATION_LAMBDA_URL;

	my $encoder = URI::Encode->new({double_encode => 0});
	$uri = $encoder->encode(sprintf($uri, $username));

	$uri .= '&location=' . uri_escape($location) if ($location);
	$uri = URI->new($uri);

	return $self->__ua->get($uri)->decoded_content;
}

1;

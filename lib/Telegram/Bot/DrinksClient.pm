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

1;

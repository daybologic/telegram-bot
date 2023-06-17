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

1;

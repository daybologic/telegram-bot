package Telegram::Bot::CatClient;
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

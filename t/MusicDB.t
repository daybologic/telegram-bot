#!/usr/bin/env perl
package MusicDBTests;
use lib 'lib';
use Moose;
use POSIX qw(EXIT_SUCCESS);
use Telegram::Bot::MusicDB;
use Test::More;

extends 'Test::Module::Runnable';

sub testDefaultLocation {
	my ($self) = @_;
	plan tests => 1;

	$self->sut(Telegram::Bot::MusicDB->new());

	my $username = qx(whoami);
	chomp($username);

	my $path = "/var/lib/$username/telegram-bot/music-database.list";
	is($self->sut->__location, $path, $path);

	return EXIT_SUCCESS;
}

exit(MusicDBTests->new()->run());

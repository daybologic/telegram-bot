#!/usr/bin/env perl
package MusicDBTests;
use lib 'lib';
use File::Temp qw(tempfile);
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

sub testSearchEmptyNoneFound {
	my ($self) = @_;
	plan tests => 1;

	my ($handle, $location) = tempfile();
	$self->sut(Telegram::Bot::MusicDB->new(__location => $location));

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedNoneFound {
	my ($self) = @_;
	plan tests => 1;

	my ($handle, $location) = tempfile();
	__makeDatabase($handle);
	$self->sut(Telegram::Bot::MusicDB->new(__location => $location));

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedTwoFound {
	my ($self) = @_;
	plan tests => 1;

	my ($handle, $location) = tempfile();
	__makeDatabase($handle);
	$self->sut(Telegram::Bot::MusicDB->new(__location => $location));

	is_deeply($self->sut->search('Judge'), [
		'yyy Judge Jules',
		'xxx Judge Dredd',
	], 'two found');

	return EXIT_SUCCESS;
}

sub __makeDatabase {
	my ($handle) = @_;

	for (my $i = 0; $i < 100; $i++) {
		if ($i == 9) {
			print($handle "yyy Judge Jules\n");
		} elsif ($i == 79) {
			print($handle "xxx Judge Dredd\n");
		} else {
			printf($handle "%08X\n", rand(0xffffffff));
		}
	}

	close($handle);

	return;
}

package main;
use strict;
use warnings;
exit(MusicDBTests->new()->run());

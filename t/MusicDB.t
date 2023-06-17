#!/usr/bin/env perl
package MusicDBTests;
use lib 'lib';
use File::Temp qw(tempfile);
use Moose;
use POSIX qw(EXIT_SUCCESS);
use Telegram::Bot::MusicDB;
use Test::More;

extends 'Test::Module::Runnable';

has __handle => (is => 'rw');

sub tearDown {
	my ($self, %params) = @_;
	$self->__handle(undef);
	return $self->SUPER::tearDown(%params);
}

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

	$self->__makeSUT(0);

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedNoneFound {
	my ($self) = @_;
	plan tests => 1;

	$self->__makeSUT(1);

	is_deeply($self->sut->search('Obama'), [], 'none');

	return EXIT_SUCCESS;
}

sub testSearchPopulatedTwoFound {
	my ($self) = @_;
	plan tests => 1;

	$self->__makeSUT(1);

	is_deeply($self->sut->search('    Judge       '), [
		'yyy Judge Jules',
		'xxx Judge Dredd',
	], 'two found');

	return EXIT_SUCCESS;
}

sub testSearchPopulated {
	my ($self) = @_;
	plan tests => 2;

	$self->__makeSUT(1);

	my $limit = 10;
	$self->sut->limit($limit);

	my $result = $self->sut->search('F');
	cmp_ok(scalar(@$result), '>=', 5, 'at least 5 results');
	cmp_ok(scalar(@$result), '==', $limit, "not more than $limit results");

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

sub __makeSUT {
	my ($self, $populate) = @_;

	my ($handle, $location) = tempfile();
	$self->__handle($handle);

	__makeDatabase($handle) if ($populate);

	$self->sut(Telegram::Bot::MusicDB->new(
		__location => $location,
		_quiet      => 1,
	));

	return $self->sut;
}

package main;
use strict;
use warnings;
exit(MusicDBTests->new()->run());

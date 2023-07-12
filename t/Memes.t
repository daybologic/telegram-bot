#!/usr/bin/perl
package MemesTests;
use strict;
use warnings;
use Moose;
extends 'Test::Module::Runnable';

use Telegram::Bot::Memes;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;

sub setUp {
	my ($self) = @_;

	$self->sut(Telegram::Bot::Memes->new());

	return EXIT_SUCCESS;
}

sub testNotFound {
	my ($self) = @_;
	plan tests => 1;

	is($self->sut->run('/nonsense'), undef, 'run with nonsense returned <undef>');

	return EXIT_SUCCESS;
}

sub testYUNO { # a valid and important meme
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/yuno'), {
		caption => '',
		method  => 'sendPhoto',
		photo   => {
			file => '/var/cache/telegram-bot/memes/4x/yuno.png',
		},
	}, 'run with yuno returned correct data');

	return EXIT_SUCCESS;
}

sub testCaption {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/troll', 'just to', 'wind you up'), {
		caption => 'just to wind you up',
		method  => 'sendPhoto',
		photo   => {
			file => '/var/cache/telegram-bot/memes/4x/troll.png',
		},
	}, 'caption and image path correct');

	return EXIT_SUCCESS;
}

sub testGIF {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('/hotpotato'), {
		caption   => '',
		method    => 'sendAnimation',
		animation => {
			file => '/var/cache/telegram-bot/memes/4x/hotpotato.gif',
		},
	}, 'caption and image path correct') or diag(explain($self->sut->run('/hotpotato')));

	return EXIT_SUCCESS;
}

sub testNoSlash {
	my ($self) = @_;
	plan tests => 1;

	cmp_deeply($self->sut->run('rubberstamp'), {
		caption => '',
		method  => 'sendPhoto',
		photo   => {
			file => '/var/cache/telegram-bot/memes/4x/rubberstamp.png',
		},
	}, 'correct data');

	return EXIT_SUCCESS;
}

sub testSearchRap {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('rap');
	cmp_deeply($result, [
		'itsatrap',
		'ohcrap',
		'philosoraptor',
	], 'results') or diag(explain($result));

	return EXIT_SUCCESS;
}

sub testSearchFatherJack {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('fatherjack');
	cmp_deeply($result, ['fatherjack']); # 'fatherjack2' does not come back

	return EXIT_SUCCESS;
}

sub testSearchDanger {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('danger');
	cmp_deeply($result, ['dangerwillrobinson']);

	return EXIT_SUCCESS;
}

sub testAli {
	my ($self) = @_;
	plan tests => 1;

	my $result = $self->sut->search('ali');
	cmp_deeply($result, ['alig']);

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(MemesTests->new->run);

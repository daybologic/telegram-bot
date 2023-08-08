#!/usr/bin/perl
package Memes_AddResizerTests;
use Moose;
extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Readonly;
use Telegram::Bot::Memes::Add::Resizer;
use Telegram::Bot::Memes::Handle;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;

Readonly my $ROOT_PATH => 't/data';
Readonly my $ORIGINAL_FILE => 'timpalmer.jpg';

sub setUp {
	my ($self, %params) = @_;

	if ($params{method} eq 'testDefaults') {
		$self->sut(Telegram::Bot::Memes::Add::Resizer->new());
	} else {
		$self->sut(Telegram::Bot::Memes::Add::Resizer->new(
			rootPath => $ROOT_PATH,
		));
	}

	return EXIT_SUCCESS;
}

sub testDefaults {
	my ($self) = @_;
	plan tests => 2;

	my $rootPath = '/var/cache/telegram-bot/memes';
	is($self->sut->rootPath, $rootPath, "root path: '$rootPath'");
	is($self->sut->original, undef, 'original <undef>');

	return EXIT_SUCCESS;
}

sub testConvertOriginal {
	my ($self) = @_;
	plan tests => 4;

	$self->sut->setOriginalFile($ORIGINAL_FILE);

	my $originalPath = 't/data/original/timpalmer.jpg';
	is($self->sut->original->file, $ORIGINAL_FILE, "original set - '$ORIGINAL_FILE'");
	is($self->sut->original->path, $originalPath, "original path - '$originalPath'");
	ok(-f $originalPath, "original path exists - '$originalPath'");

	subtest aspects => sub {
		plan tests => 3;

		for (my $size = 4; $size >= 1; $size /= 2) {
			my $aspect = sprintf('%dx', $size);

			subtest $aspect => sub {
				plan tests => 4;
				my $attribName = "size${aspect}";

				is($self->sut->$attribName->file, $self->sut->original->file, "$aspect file is the same as original file");
				isnt($self->sut->$attribName->path, $self->sut->original->path, "$aspect path is *NOT* the same as original path");

				my $aspectPath = "t/data/$aspect/timpalmer.jpg";
				is($self->sut->$attribName->path, $aspectPath, "$aspect path path - '$aspectPath'");
				ok(-f $self->sut->$attribName->path, "$aspect size file exists - '$aspectPath'");
			};
		}
	};

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(Memes_AddResizerTests->new->run);

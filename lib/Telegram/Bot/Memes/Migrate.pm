package Telegram::Bot::Memes::Migrate;
use strict;
use warnings;
use Moose;

use Data::Dumper;
use JSON;
use POSIX;

sub run {
	my ($self) = @_;
	my $bucketContents = $self->__getBucketContent();
	my (%aspectMap, %nameMap);
	foreach my $filePath (sort(keys(%$bucketContents))) {
		my ($aspect, $filename) = split(m/\//, $filePath, 2);
		$aspectMap{$filename}->{$aspect} = 1;
		$nameMap{$aspect}->{$filename} = 1;
	}

	my @deleteList = ( );
	foreach my $originalFilename (sort(keys(%{ $nameMap{original} }))) {
		foreach my $aspect (qw(1x 2x 4x)) {
			if ($nameMap{$aspect}->{$originalFilename}) {
				# because the original size exists, this ?x aspect is redundant, and may be removed
				push(@deleteList, join('/', $aspect, $originalFilename));
			}
		}
	}

	foreach my $aspect (qw(1x 2x 4x)) { # order is important in order to get best quality image
		foreach my $nonOriginalAspectFilename (sort(keys(%{ $nameMap{$aspect} }))) {
			next if ($nameMap{original}->{$nonOriginalAspectFilename}); # original exists, don't look at aspects, they have been deleted (or will be)
			my $remotePathSource = join('/', $aspect, $nonOriginalAspectFilename);
			my $remotePathTarget = join('/', 'original', $nonOriginalAspectFilename);
			my $data = `aws s3 cp s3://d947d0bc-457b-11ee-96b5-8fe750da9949/$remotePathSource s3://d947d0bc-457b-11ee-96b5-8fe750da9949/$remotePathTarget`;
			warn("$data\n");
			push(@deleteList, $remotePathSource); # we can remove the ?x aspect later on
		}
	}

	# Execute all queued deletes
	__deletes(\@deleteList);

	return EXIT_SUCCESS;

}

sub __deletes {
	my ($deleteList) = @_;
	warn(sprintf("%d files to delete\n", scalar(@$deleteList)));
	sleep(10);
	foreach my $filePath (@$deleteList) {
		my $output = `aws s3 rm s3://d947d0bc-457b-11ee-96b5-8fe750da9949/$filePath`;
		warn("$output\n");
	}
}

sub __getBucketContent {
	my %files = ( );
	my $data = `aws --output json s3api list-objects --bucket d947d0bc-457b-11ee-96b5-8fe750da9949`;
	my $json = JSON->new->allow_nonref;
	$json = $json->decode($data);
	$json = $json->{Contents};
	foreach my $item (@$json) {
		my ($aspect, $filename) = split(m/\//, $item->{Key}, 2);
		__validateAspect($aspect, $filename);
		$files{ $item->{Key} } = $item->{Size};
	}
	return \%files;
}

my %__aspects = map { $_ => 1 } (qw(original 4x 2x 1x));
sub __validateAspect {
	my ($aspect, $filename) = @_;
	unless ($__aspects{$aspect}) {
		die(sprintf(
			"aspect must be one of: %s -- file: '%s'.  Delete this file before migration.",
			join(', ', reverse(sort(keys(%__aspects)))), join('/', $aspect, $filename),
		));
	}
	return;
}

1;

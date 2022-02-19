package MusicDB;
use strict;
use warnings;
use Moose;
use Readonly;

Readonly my $MUSIC_DB => '/var/lib/palmer/music-database.list';
Readonly my $LIMIT => 20;

has __db => (isa => 'ArrayRef[Str]', is => 'rw', default => sub {
	return [ ];
});

sub BUILD {
	my ($self) = @_;

	$self->__reload();
}

sub __reload {
	my ($self) = @_;

	@{ $self->__db } = (); # flush

	my $fh = IO::File->new();
	if ($fh->open("< $MUSIC_DB")) {
		while (my $line = <$fh>) {
			chomp($line);
			push(@{ $self->__db}, $line);
		}
		warn sprintf("%d tracks loaded\n", scalar(@{ $self->__db }));
		$fh->close;
	}

	return;
}

sub search {
	my ($self, $criteria) = @_;

	$criteria =~ s/\W//g;

	my @results = grep(/$criteria/i, @{ $self->__db });
	$#results = $LIMIT - 1 if (scalar(@results) > $LIMIT);

	warn(sprintf("Query '%s' returned %d results\n", $criteria, scalar(@results)));
	return \@results;
}

1;

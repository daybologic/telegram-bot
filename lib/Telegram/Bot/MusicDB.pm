package Telegram::Bot::MusicDB;
use Moose;
use Readonly;

extends 'Telegram::Bot::Base';

Readonly my $LIMIT => 20;

has __db => (isa => 'ArrayRef[Str]', is => 'rw', default => sub {
	return [ ];
});

has __location => (is => 'ro', lazy => 1, isa => 'Str', default => sub {
	return "/var/lib/$ENV{USER}/telegram-bot/music-database.list";
});

has limit => (is => 'rw', isa => 'Int', default => $LIMIT);

sub BUILD {
	my ($self) = @_;
	$self->__reload();
	return;
}

sub __reload {
	my ($self) = @_;

	@{ $self->__db } = (); # flush

	my $fh = IO::File->new();
	if ($fh->open($self->__location, 'r')) {
		while (my $line = <$fh>) {
			chomp($line);
			push(@{ $self->__db }, $line);
		}
		$self->_warn(sprintf("%d tracks loaded\n", scalar(@{ $self->__db })));
		$fh->close();
	}

	return;
}

sub search {
	my ($self, $criteria) = @_;

	$criteria =~ s/\W//g;

	my @results = grep(/$criteria/i, @{ $self->__db });
	$#results = $self->limit - 1 if (scalar(@results) > $self->limit);

	$self->_warn(sprintf(
		"Query '%s' returned %d results (%d entries total)\n",
		$criteria,
		scalar(@results),
		scalar(@{ $self->__db }),
	));

	return \@results;
}

1;

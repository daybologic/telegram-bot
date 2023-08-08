package Telegram::Bot::Memes::Add::Resizer;
use Moose;
use Readonly;

use Telegram::Bot::Memes::Handle;

has rootPath => (is => 'ro', isa => 'Str', default => '/var/cache/telegram-bot/memes');
has original => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw');

# We keep the original Hipchat sizing scheme.  Each of these are just-in
# time delivery mechanisms, which fetch from the on-disk cache, or
# generate the files dynamically.

has size4x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize4x);
has size2x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize2x);
has size1x => (isa => 'Telegram::Bot::Memes::Handle', is => 'rw', lazy => 1, default => \&__makeSize1x);

sub setOriginalFile {
	my ($self, $file) = @_;

	$self->original(Telegram::Bot::Memes::Handle->new({
		rootPath => $self->rootPath,
		aspect   => 'original',
		file     => $file,
	}));

	return;
}

sub __makeSize4x {
	my ($self) = @_;
	return $self->__resizeWrapper(4);
}

sub __makeSize2x {
	my ($self) = @_;
	return $self->__resizeWrapper(2);
}

sub __makeSize1x {
	my ($self) = @_;
	return $self->__resizeWrapper(1);
}

sub __resizeWrapper {
	my ($self, $size) = @_;

	my $newHandle = Telegram::Bot::Memes::Handle->new({
		rootPath => $self->rootPath,
		aspect   => sprintf('%dx', $size),
		file     => $self->original->file,
	});

	unless (-f $newHandle) {
		$self->__resize($newHandle, $size);
	}

	return $newHandle;
}

sub __resize {
	my ($self, $newHandle, $size) = @_;

	my $cmd = $self->__buildCommand($newHandle, $size);
	system(@$cmd) == 0
	    or die "system @$cmd failed: $?";
}

sub __buildCommand {
	my ($self, $newHandle, $size) = @_;

	$size = $self->__getSize($size);
	my @cmd = (
		'convert',
		$self->original->path,
		'-resize',
		$size,
		'-extent',
		$size,
		'-quality',
		'75',
		$newHandle->path,
	);

	return \@cmd;
}

sub __getSize {
	my ($self, $size) = @_;

	Readonly my %SIZE_MAP => (
		1 => 30,
		2 => 60,
		4 => 120,
	);

	if (exists($SIZE_MAP{$size})) {
		$size = $SIZE_MAP{$size};
	} elsif (defined($size)) {
		die("Illegal size: $size");
	} else {
		die('Undefined size!');
	}

	return sprintf('%dx%d', $size, $size);
}

1;

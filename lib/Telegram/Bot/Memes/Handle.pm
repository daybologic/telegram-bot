package Telegram::Bot::Memes::Handle;
use Moose;

has rootPath => (is => 'ro', isa => 'Str', default => '/var/cache/telegram-bot/memes');
has ['aspect', 'file'] => (isa => 'Str', is => 'ro', required => 1);
has path => (isa => 'Str', is => 'ro', lazy => 1, default => \&__makePath);
has __aspectPath => (isa => 'Str', is => 'ro', lazy => 1, default => \&__makeAspectPath);

sub __makePath {
	my ($self) = @_;
	return join('/', $self->__aspectPath, $self->file);
}

sub __makeAspectPath {
	my ($self) = @_;
	my $aspectPath = join('/', $self->rootPath, $self->aspect);
	mkdir($aspectPath);
	return $aspectPath;
}

1;

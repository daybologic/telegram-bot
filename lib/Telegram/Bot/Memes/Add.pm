package Telegram::Bot::Memes::Add;
use Moose;

use Data::Dumper;
use File::Copy;
use File::Temp qw/ tempfile tempdir tmpnam /;
use Telegram::Bot::Memes::Add::Resizer;

has api => (is => 'ro', isa => 'WWW::Telegram::BotAPI', required => 1);
has owner => (is => 'ro', isa => 'Telegram::Bot::Memes', required => 1);

sub add {
	my ($self, $name, $fileId) = @_;

	my $filePath = $self->__fetchViaAPI($fileId);
	warn $filePath;

	my $resizer = $self->resizer($filePath, $name);
	$self->owner->addToBucket($resizer->original->path, $name, 'original');
	for (my $size = 4; $size >= 1; $size /= 2) { # TODO: Do we need an all sizes iterator within the object?
		my $aspect = sprintf('%dx', $size);
		my $attribName = "size${aspect}";
		$self->owner->addToBucket($resizer->$attribName->path, $name, $aspect);
	}

	return "Successfully added meme '$name', type '/$name' to use it, '/meme rm $name' to delete, if it isn't right";
}

sub resizer {
	my ($self, $filePath, $name) = @_;

	my $resizer = Telegram::Bot::Memes::Add::Resizer->new();
	$resizer->setOriginalFile(__makeFileName($name));
	move($filePath, $resizer->original->path);

	return $resizer;
}

sub __makeFileName {
	my ($name) = @_;
	return join('.', $name, 'jpg');
}

sub __fetchViaAPI {
	my ($self, $fileId) = @_;

	my $file = $self->api->api_request('getFile', {
		file_id => $fileId,
	});

	my $resultFilePath = $file->{result}->{file_path};
	my $token = $self->api->{token};
	my $url = "https://api.telegram.org/file/bot${token}/${resultFilePath}";

	my $response = $self->api->agent->get($url);
	unless ($response->is_success) {
		return "Can't get your meme via the API! - " . $response->status_line;
	}

	my ($fh, $filePath) = tmpnam();
	print $fh $response->content;

	return $filePath;
}

1;

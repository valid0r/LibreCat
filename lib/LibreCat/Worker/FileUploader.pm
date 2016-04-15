package LibreCat::Worker::FileUploader;

use Moo;
use Catmandu::Util;
use IO::File;
use namespace::clean;

#with 'LibreCat::Worker';

has files      => (is => 'ro' , required => 1);
has file_store => (is => 'lazy');

sub _build_file_store {
    my ($self) = @_;

    my $file_store = $self->files->{package};
    my $file_opts  = $self->files->{options} // {};

    my $pkg = Catmandu::Util::require_package($file_store,'LibreCat::FileStore');
    $pkg->new(%$file_opts);
}

sub do_work {
    my ($self, $key, $filename, $path) = @_;

    return -1 unless defined $key && $key =~ /^\d{9}$/;
    return -1 unless defined $filename;
    return -1 unless defined $path && -f $path && -r $path;

    $self->log->info("loading container $key");
    my $container = $self->file_store->get($key);

    unless ($container) {
        $self->log->info("$key not found");
        $self->log->info("creating a new container $key");
        $container = $self->file_store->add($key);
    }

    if ($container) {
        $self->log->info("storeing $filename in container $key");

        $container->add($filename, IO::File->new($path));
        $container->commit;

        return 1;
    }
    else {
        $self->log->error("failed to create container $key");
        return -1;
    }
}

1;

__END__

=pod

=head1 NAME

LibreCat::Worker::FileUploader - a worker for uploading files into the repostitory

=head2 SYNOPSIS

    use LibreCat::Worker::FileUploader;

    my $uploader = LibreCat::Worker::FileUploader->new(
                    files => {
                        package => 'Simple', 
                        options => {
                            root => '/data2/librecat/file_uploads'
                        }
                   });

    $uploader->do_work($key,$filename,$filepath);

=head2 CONFIGURATION

=over

=item files

Required. The LibreCat::FileStore implementation to use.

=back

=head2 SEE ALSO

L<LibreCat::Worker>

=cut

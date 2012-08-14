package serialize_data;

# this module is a wrapper for Data::Serializer PERL module

use strict;
# use warnings;

use Data::Serializer;
use Data::Dumper;

use atomlog;

BEGIN {
    use Exporter ();

    our @ISA;
    our @EXPORT;
    
    @ISA = qw(Exporter);
    @EXPORT = qw(
        ser_pack
        ser_unpack
    );
}

sub ser_pack {

    my $data = shift;
    if (! defined $data) {
        $data = '';
    }
    my $obj = Data::Serializer->new(
        serializer => 'Data::Dumper',
        encoding => 'b64',
        compress => 1,
    );
    
    return $obj->serialize($data);
}

sub ser_unpack {

    my $data = shift;
    if (! defined $data) {
        return '';
    }
    my $obj = Data::Serializer->new(
        serializer => 'Data::Dumper',
        encoding => 'b64',
        compress => 1,
    );
    
    return $obj->deserialize($data);
}

1;

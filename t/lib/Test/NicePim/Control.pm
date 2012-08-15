package Test::NicePim::Control;

use strict;
use warnings;

use base qw(Test::Class::NicePim);
use Test::More;
use Test::Exception;
use Storable qw(freeze thaw);

sub setup :Test(startup => 1) {
    use_ok('NicePim::Control');
}

sub default :Test(7) {
    ok(

    );
}

sub set_value_recursive :Test(9) {
    ok(  );

    my $hash_ref = {};

}

sub dispatch :Test(5) {
    ok( );

    throws_ok();

}

1;

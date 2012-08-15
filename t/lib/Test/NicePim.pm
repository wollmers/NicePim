package Test::NicePim;
use strict;
use warnings;
use Test::More;
use base qw(Test::Class::NicePim);

sub setup :Test(startup => 2) {
    use_ok('NicePim');
}

sub default_workflow :Test(2) {
    ok( );

}

1;

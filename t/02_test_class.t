#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Spec;

BEGIN {
    require lib;
    lib ->import(
        map {
            my $path = dirname(__FILE__) . "/$_";
            -d $path ? $path : ();
        } qw(../lib/ lib)
    );
}
our %PATH_OF = (
    t    => dirname(__FILE__),
    libs => [
        map {
            my $path = dirname(__FILE__) . "/$_";
            -d $path ? $path : ();
        } qw(../lib/ lib)
    ],
);

use Test::Class::NicePim;

use Test::NicePim;

#use Test::NicePim::Foo;

#--------------------------------
Test::Class::NicePim->runtests();




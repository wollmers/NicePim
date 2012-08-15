#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

$ENV{RELEASE_TESTING}
    or plan(
        skip_all => 'Author test.  Set $ENV{RELEASE_TESTING} to a true value to run.'
    );

eval 'use Test::Prereq::Build';

if ( $EVAL_ERROR ) {
    my $msg = 'Test::Prereq::Build not installed; skipping';
    plan( skip_all => $msg );
}
else {
    # workaround, cause this method is missing in Test::Prereq::Build
    no warnings qw(once);
    *Test::Prereq::Build::add_build_element = sub {};
}

# workaround for the bugs of Test::Prereq::Build
my @skip_workaround = qw{
    Test::Class::NicePim
    Test::NicePim::Foo
    
};


# These modules should not go into Build.PL
my @skip_devel_only = qw{
    Test::Kwalitee
    Test::Perl::Critic
    Test::Prereq::Build
};

my @skip = (
    'Apache2::RequestUtil', # optional
    @skip_workaround,
    @skip_devel_only,
);

prereq_ok( undef, undef, \@skip );

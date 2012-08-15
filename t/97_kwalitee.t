#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

$ENV{RELEASE_TESTING}
    or plan(
        skip_all => 'Author test.  Set $ENV{RELEASE_TESTING} to a true value to run.'
    );

eval 'use Test::Kwalitee';

if ( $EVAL_ERROR ) {
    my $msg = 'Test::Kwalitee not installed; skipping';
    plan( skip_all => $msg );
}

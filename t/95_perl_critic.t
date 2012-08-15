#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use Test::More;
use English qw(-no_match_vars);

$ENV{RELEASE_TESTING}
    or plan(
        skip_all => 'Author test.  Set $ENV{RELEASE_TESTING} to a true value to run.'
    );

eval 'use Test::Perl::Critic;';

$EVAL_ERROR and plan(
    skip_all => 'Test::Perl::Critic required to criticise code'
);

#my $rcfile = File::Spec->catfile( 't', 'perlcriticrc' );
#Test::Perl::Critic->import( -profile => $rcfile );
Test::Perl::Critic->import( -severity => 5 );
all_critic_ok( qw{
    t
    t/lib
    lib
    cgi-bin
}  );

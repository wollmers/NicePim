#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use File::Basename;
use Test::More;

my $lib_path = dirname(__FILE__) . '/../lib';
my %LIST;
find(
    sub {
        if ( $File::Find::name =~
            m{ (lib [/] NicePim [/] [A-Za-z0-9_/-]+ [.]pm) $ }xms
        ) {
                $LIST{"../$1"} = 1;
            }
    },
    $lib_path,
);

plan ( tests => 4 * (scalar keys %LIST) );

for my $module (sort keys %LIST) {
    open( my $file, '<', "$lib_path/$module" ) or die "cannnot open file $module";
    local $/;
    my $text = <$file>;

    ok( 1 && $text !~ m{[\x0D]}g, "$module has no DOS line ending (CR)");
    ok( 1 && $text !~ m{[\x09]}g, "$module uses no TABs");
    ok( 1 && $text !~ m{[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\xFF]}g , "$module is free of shit");
    ok( 1 && $text !~ m{[ ][\x0D\x0A]}g , "$module has no trailing space");
}


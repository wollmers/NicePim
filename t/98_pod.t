#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

use File::Basename;
use File::Spec;
use version;

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

eval 'use Test::Pod 1.0; 1;'
 or plan skip_all => 'Test::Pod 1.00 required for testing POD';

eval 'use Test::Pod::Content; 1;'
 or plan skip_all => 'Test::Pod 1.00 required for testing POD';

# Try lib, bin, cgi-bin one level up if run from t/
# perl Build test or make test run from top-level dir.
my @dirs = ();       # empty is fine - default include lib/
if (-d '../t/') {    # we are inside t/
    @dirs = (
        '../lib',
        '../doc',
    );
}

# skip undocumented NSelect
my @files = grep { $_ !~ m{NSelect\.pm\z}xms; } all_pod_files(@dirs);

plan tests => scalar(2 * @files );

for my $file (@files) {
    pod_file_ok( $file );
    my $class = $file;
    $class =~ s{(?: /|\\)}{::}xmsg;
    $class =~ s{\A(?: .*?::)? lib::}{}xms;
    $class =~ s{\.pm}{}xms;

    my ( $version )
        = version->new(eval "use $class; \$${class}::VERSION;" || q{})
        =~ m{( [\d\.]+ )}xms;

    pod_section_like(
        $file,
        'VERSION',
        qr{
            This \s document \s describes \s $class \s $version
        }xms,
        "$class version info",
    );
}


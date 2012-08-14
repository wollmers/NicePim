#!/usr/bin/perl

use lib '/home/pim/lib/';


use strict;
use atomsql;
use atomcfg;
use atomlog;

my $id = $ENV{QUERY_STRING};

opendir(DIR,$atomcfg{'download_path'});
my @files = grep{ /^$id\.\w\w\w/ } readdir DIR;
my $file = $files[0];
if($file =~m/\.(.{3,4})\Z/){
my $type = lc($1);

if($type eq 'jpeg' || $type eq 'jpg'){
 print "Content-Type: image/jpeg\n\n";
} elsif($type eq 'gif'){
 print "Content-Type: image/gif\n\n";
} else { print "Content-Type: text/plain\n\nError\n"; exit; }

 open(IMG, $atomcfg{'download_path'}.'/'.$file);
 print <IMG>;
 close(IMG);
} 





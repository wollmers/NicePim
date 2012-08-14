#!/usr/bin/perl

use strict;

use lib '/home/pim/lib';

$SIG{ALRM} = sub { die "\n" };
alarm 60;

#my $load = `cat /proc/loadavg`;
#my $load = (split(' ',$load)) [0];

#if($load > 30){
#print "Content-type: text/xml\n\n";
#print "<?xml version=\"1.0\"?><Error>Server is too busy. Please, retry later!</Error>\n";
#} else {
use icecat_server2;
use atom_html;
&icecat_server_main();
#}

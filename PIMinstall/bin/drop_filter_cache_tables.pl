#!/usr/bin/perl

#$Id: drop_filter_cache_tables.pl 1927 2009-10-29 10:56:41Z alexey $

#
# drop_filter_cache_tables
#

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';
#use lib '/home/alexey/icecat/bo/lib';
use strict;

use atomcfg;
use atomsql;
use atomlog;

use Data::Dumper;

$| = 1;

# begin
my $period = 60 * 60; # drop the tables out of this period (in seconds)

my $arrTbls = &do_query("show tables like 'itmp\\_f\\_%\\_end\\_%'");
my $timeCreated;
my $currentTime = &do_query("SELECT UNIX_TIMESTAMP()")->[0][0];

foreach (@$arrTbls) {
	$_->[0] =~ /(\d+)$/;
	$timeCreated = $1;
	my $interval = $currentTime - $timeCreated;
	print "Difference ".$interval." sec. Table ".$_->[0]." ";
	if (($currentTime - $timeCreated) > $period) {
		&do_statement("DROP TABLE ".$_->[0]); 
		print " Dropped";
	}
	else {
		print " Skipped";
	}
	print "\n";
}

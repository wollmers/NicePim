#!/usr/bin/perl

#$Id: multimedia_object_prg4apache2.pl 1877 2009-10-15 14:40:23Z dima $

use lib '/home/pim/lib';
#use lib '/home/dima/gcc_svn/lib';

use strict;

$| = 1;

use atomcfg;
use atomlog;
use atomsql;

#use Data::Dumper;

while (<STDIN>) {
	/^(\d+)\-(\d+)\.html$/;
	unless ($1) { # return NULL if bad request
		print STDOUT "NULL\n";
	}
	else {
		print STDOUT &do_query("select link from product_multimedia_object where product_id=".$1." and id=".$2." and keep_as_url=1 limit 1")->[0][0] || 'NULL';
		print STDOUT "\n";
	}
}

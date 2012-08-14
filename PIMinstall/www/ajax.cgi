#!/usr/bin/perl

#/usr/bin/speedy -- -M10

$| = 1;

use lib '/home/pim/lib';

#use CGI::SpeedyCGI;

use atomcfg;
use atomsql;
use atomlog;
use ajax_unmodperl;

open(atomlog::log_fh,">>".$atomcfg{'logfile'});
#&log_printf(Dumper(\%ENV));
#my $sp = CGI::SpeedyCGI->new;
#$sp->add_shutdown_handler(sub { $atomsql::dbh->disconnect()});
#$atomsql::speedy_mode = 1;
#my $str = "DBI:mysql:$atomcfg{dbname}:$atomcfg{dbhost};mysql_local_infile=1";
#my $user = $atomcfg{dbuser};
#my $pass = $atomcfg{dbpass};
#$atomsql::dbh = DBI->connect($str,$user,$pass,{PrintError=>1,AutoCommit=>1});
#$atomsql::dbh->do("set names utf8");

lp('------------>>>>>>>>>>>>>>>>>>>>> NOT!!! MOD PERL');

print "Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\n";
print "Pragma: no-cache\n";
print "Content-type: text/plain; charset=utf-8\n";
print "Content-Encoding: gzip\n\n";

ajax();

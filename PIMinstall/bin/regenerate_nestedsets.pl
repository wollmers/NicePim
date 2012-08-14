#!/usr/bin/perl
#use lib '/home/alexey/icecat/bo/lib';
use lib "/home/pim/lib";
 
use Data::Dumper;
use atomsql;
use atomlog;
use nested_sets;
use utf8;
use Time::HiRes;

$| = 1;

print "Start:\n";

$time_start= Time::HiRes::time();
#$avialble_langs=&do_query("SELECT langid FROM language");
$avialble_langs=['1'];
&do_statement('REPLACE INTO category (catid,pcatid) VALUES(1,1)');
&do_statement('REPLACE INTO product_family (family_id,parent_family_id) VALUES(1,0)');

foreach my $lang (@{$avialble_langs}) {
	print "\t".$lang->[0]."\n";
	#&check_tree('category','catid','pcatid','force','value',$lang->[0],'vocabulary','sid');
	&check_tree('product_family','family_id','parent_family_id','force','value',$lang->[0],'vocabulary','sid');
}

print "takes --> ".(Time::HiRes::time()-$time_start)."\n\n";

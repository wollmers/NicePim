#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atom_mail;
use atomcfg;
my $time_start = Time::HiRes::time();

my $day_from='2010-12-09 00:00';
my $day_to='2010-12-10 00:00';

my $month_from='2010-11-01 00:00';
my $month_to='2010-12-01 00:00';

my $year_from='2010-01-01 00:00';
my $year_to='2011-01-01 00:00';

my @top_cats=('computers','components','print & scan','networks','software','data storage','monitors, TVs & projectors','audio & video','bags & cases','cameras','data-entry & controls','PDA, GPS & mobile');
&do_statement('DROP TABLE aaa_tmp_category');
&do_statement('CREATE TABLE aaa_tmp_category (catid int(13) not null default 0, PRIMARY KEY(catid))');
foreach my $top_cat (@top_cats){
	my $cat_params=&do_query('SELECT c.catid,ns.left_key,ns.right_key FROM category c 
							  JOIN category_nestedset ns ON c.catid=ns.catid AND ns.langid=1
							  JOIN vocabulary v ON v.sid=c.sid and v.langid=1 WHERE v.value='.&str_sqlize($top_cat));
	
	if(!$cat_params->[0]){
		print "Err: no such category ".$top_cat."\n";
		next;
	}
	
	&do_statement("INSERT IGNORE INTO aaa_tmp_category SELECT c.catid FROM category c 
					JOIN category_nestedset ns ON c.catid=ns.catid AND ns.langid=1
					JOIN vocabulary v ON v.sid=c.sid and v.langid=1 
					WHERE ns.left_key>=".$cat_params->[0][1]." and ns.right_key<=".$cat_params->[0][2]);	
}
my $editors_day=&do_query("SELECT count(*) FROM (SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN editor_journal ej USING(product_id) 
		   WHERE ej.product_table = 'product' AND  ej.date>unix_timestamp('$day_from') and 
		   ej.date<unix_timestamp('$day_to') GROUP BY p.product_id) as tbl");
my $editors_month=&do_query("SELECT count(*) FROM (SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN editor_journal ej USING(product_id) 
		   WHERE ej.product_table = 'product' AND  ej.date>unix_timestamp('$month_from') and 
		   ej.date<unix_timestamp('$month_to') GROUP BY p.product_id) as tb");
my $editors_year=&do_query("SELECT count(*) FROM (SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN editor_journal ej USING(product_id) 
		   WHERE ej.product_table = 'product' AND  ej.date>unix_timestamp('$year_from') and 
		   ej.date<unix_timestamp('$year_to') GROUP BY p.product_id) as tbl");

my $suppliers_day=&do_query("SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN users u USING(user_id) 
		   WHERE  unix_timestamp(p.date_added)>unix_timestamp('$day_from') and unix_timestamp(p.date_added)<unix_timestamp('$day_to') AND u.user_group='supplier'");
my $suppliers_month=&do_query("SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN users u USING(user_id) 
		   WHERE  unix_timestamp(p.date_added)>unix_timestamp('$month_from') and unix_timestamp(p.date_added)<unix_timestamp('$month_to') AND u.user_group='supplier'");
my $suppliers_year=&do_query("SELECT count(*) FROM product p JOIN aaa_tmp_category USING(catid) 
		   JOIN users u USING(user_id) 
		   WHERE  unix_timestamp(p.date_added)>unix_timestamp('$year_from') and unix_timestamp(p.date_added)<unix_timestamp('$year_to') AND u.user_group='supplier'");

print "Daily: $day_from - $day_to Products: ".($editors_day->[0][0]+$suppliers_day->[0][0])."\n"; 		   
print "Monthly: $month_from - $month_to Products: ".($editors_month->[0][0]+$suppliers_month->[0][0])."\n";
print "Yearly: $year_from - $year_to Products: ".($editors_year->[0][0]+$suppliers_year->[0][0])."\n";


print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);

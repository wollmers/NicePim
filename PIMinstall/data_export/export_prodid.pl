#!/usr/bin/perl

use strict;

#$Id: export_prodid.pl 2272 2010-03-05 14:12:41Z dima $

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';

use atomcfg;
use atomsql;
use atomlog;
use atom_misc;

$| = 1;

###
### This script generates list of ProdID for described products
###
###  16/08/2003  Andrew Novikov 
###  11.06.2007  Dimtry Mitko  (totally reworked)
###  19.09.2008  Dimtry Mitko  (moved to new XML server)
###  18.08.2009  Dmitry Mitko  (optimizing with SQL fixing & using product_memory table)
###

my $d = "\t\t\t";
my $outfile = $atomcfg{'base_dir'}.'data_export/prodid_d.txt';

## add several useful tmp tables

# supplier
&do_statement("create temporary table tmp_supplier (
  `supplier_id` int(13) primary key,
  `name` varchar(255) NOT NULL default '')");
&do_statement("insert into tmp_supplier(supplier_id,name) select supplier_id,name from supplier");

# quality
&do_statement("create temporary table tmp_quality (
  `user_id` int(13) primary key,
  `measure` varchar(50) NOT NULL)");
&do_statement("insert into tmp_quality(user_id,measure)
select u.user_id, ugmm.measure from users u inner join user_group_measure_map ugmm using (user_group)");

# category
&do_statement("create temporary table tmp_category (
  `catid` int(13) primary key,
  `value` varchar(255) default NULL)");
&do_statement("insert into tmp_category(catid,value)
select c.catid, v.value from category c inner join vocabulary v on c.sid=v.sid and v.langid=1");

# ean_codes
&do_statement("create temporary table tmp_product_ean_codes (
  `product_id` int(13) primary key,
  `ean_code` text NOT NULL default '')");

my @arr = &get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');
my $b_cond;
foreach $b_cond (@arr) {
	&do_statement("insert into tmp_product_ean_codes(product_id,ean_code)
select p.product_id, GROUP_CONCAT(pec.ean_code SEPARATOR ';')
from product_memory p
inner join product_ean_codes pec using (product_id)
where ".$b_cond."
group by p.product_id");
}

# on_market
&do_statement("create temporary table tmp_on_market (
  `product_id` int(13) primary key,
  `on_market`  char(1) NOT NULL default 'N')");

&do_statement("insert ignore into tmp_on_market(product_id,on_market)
select product_id, if(existed=1 and active=1,'Y','N') from country_product order by existed desc, active desc");

# original_prod_id
&do_statement("create temporary table tmp_product_original_data (
product_id   int(13) NOT NULL,
misc_prod_id varchar(255) default NULL,
UNIQUE KEY (product_id, misc_prod_id))");

@arr = &get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');
my $b_cond;
foreach $b_cond (@arr) {
	&do_statement("insert into tmp_product_original_data(product_id,misc_prod_id) select p.product_id, p.prod_id from product_memory p where ".$b_cond); # using product_memory table
}

@arr = &get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');
foreach $b_cond (@arr) {
	&do_statement("insert ignore into tmp_product_original_data(product_id,misc_prod_id)
select ds.product_id,ds.original_prod_id from distributor_product ds
inner join product_memory p using (product_id) where p.prod_id != ds.original_prod_id and ".$b_cond); # using product_memory table
}

&do_statement("create temporary table tmp_res_prod (
product_id     int(13) NOT NULL default 0,
prod_id        varchar(235) NOT NULL default '',
supplier_name  varchar(255) NOT NULL default '',
measure        varchar(50) NOT NULL,
value          varchar(255) default NULL,
name           varchar(255) NOT NULL default '',
ean_code       char(13) NOT NULL default '',
on_market      char(1) NOT NULL default 'N',
UNIQUE KEY (product_id,prod_id))");

@arr = &get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');
foreach $b_cond (@arr) {
	&do_statement("insert ignore into tmp_res_prod  
select tpo.product_id, tpo.misc_prod_id, ts.name, tq.measure, tc.value, p.name, tpec.ean_code, tom.on_market
from tmp_product_original_data tpo
inner join product_memory p using (product_id) /* using product_memory table */
inner join tmp_supplier ts using (supplier_id)
inner join tmp_quality tq using (user_id)
inner join tmp_category tc using (catid)
left join tmp_product_ean_codes tpec on p.product_id=tpec.product_id
left join tmp_on_market tom on p.product_id=tom.product_id
where ".$b_cond);
}

my $select = "select prod_id, supplier_name, measure, value, name, ean_code, on_market from tmp_res_prod";

my $sth = $atomsql::dbh->prepare($select);
my $rv = $sth->execute;
my @p;

open(OUTFILE, '>'.$outfile.'.tmp');
binmode(OUTFILE,":bytes");
open(OUTFILE_GZ,"| gzip -c9 >".$outfile.".gz.tmp");
binmode(OUTFILE_GZ,":bytes");
my $header = "Part number".$d."Brand".$d."Quality".$d."Category".$d."Model Name".$d."EAN".$d."Market Presence"."\n";
my $txt;
print OUTFILE $header;
print OUTFILE_GZ $header;
while (@p = $sth->fetchrow_array) {
	if (!$p[6]) {
		$p[6] = 'N';
	}
	if ($p[1] && $p[2]) {
		$txt = join($d,@p)."\n";
		print OUTFILE $txt;
		print OUTFILE_GZ $txt;
	}
}
close(OUTFILE);
close(OUTFILE_GZ);

`mv $outfile.tmp $outfile`;
`mv $outfile.gz.tmp $outfile.gz`;

foreach ('tmp_supplier','tmp_quality','tmp_category','tmp_product_ean_codes','tmp_on_market','tmp_product_original_data','tmp_res_prod') {
	&do_statement("drop temporary table ".$_);
}

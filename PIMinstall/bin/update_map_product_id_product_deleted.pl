#!/usr/bin/perl

use strict;

use lib '/home/pim/lib';
#use lib '/home/dima/gcc_svn/lib';

use atomsql;
use atomlog;
use stat_report;
use icecat_mapping;
use atom_util;

use POSIX;
use Time::HiRes;

$| = 1;

my $time_start = Time::HiRes::time();

print "Start update_map_product_id_product_deleted.pl: ";

&do_statement('DROP TABLE tmp_product_deleted');
&do_statement('CREATE TABLE tmp_product_deleted LIKE  product_deleted');

&do_statement('INSERT INTO tmp_product_deleted SELECT * FROM product_deleted');
&do_statement("ALTER TABLE `tmp_product_deleted` DROP map_product_id");

print "temporary table added (" . sprintf("%.2f",Time::HiRes::time()-$time_start) . " secs), ";
$time_start = Time::HiRes::time();

&prod_id_mapping({'table' => 'tmp_product_deleted'});

print "mapping was finished (" . sprintf("%.2f",Time::HiRes::time()-$time_start) . " secs), ";
$time_start = Time::HiRes::time();

#&do_statement("ALTER TABLE `product_deleted` ADD `map_product_id` INT( 13 ) NOT NULL DEFAULT '0' AFTER `prod_id`");
&do_statement('UPDATE product_deleted pd 
				JOIN tmp_product_deleted tpd ON pd.product_id=tpd.product_id AND pd.del_time=tpd.del_time
				JOIN product p ON p.prod_id=tpd.map_prod_id AND p.supplier_id=tpd.map_supplier_id
				SET pd.map_product_id=p.product_id');

print "product_deleted table was updated successfully (" . sprintf("%.2f",Time::HiRes::time()-$time_start) . " secs)\n\n";

#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atom_mail;
use atomcfg;
my $time_start = Time::HiRes::time();
my $products=&do_query('SELECT p.product_id,p.prod_id,s.name,count(pe.ean_id) as cnt FROM product p 
					    JOIN supplier s USING(supplier_id) 
					    JOIN product_ean_codes pe USING(product_id) 
					    GROUP BY p.product_id HAVING cnt>1 LIMIT 10');
my $csv_report='';
foreach my $product (@$products){
	my $eans=&do_query('SELECT ean_code,ean_id FROM product_ean_codes WHERE product_id='.$product->[0]);
	foreach my $ean1 (@$eans){
		next if !$ean1->[0];
		my $trim_ean1=substr($ean1->[0],0,length($ean1->[0])-1);
		$trim_ean1=~s/^[0]+//;
		foreach my $ean2 (@$eans){
			if($ean1->[0] ne $ean2->[0]){
				my $trim_ean2=$ean2->[0];
				$trim_ean2=~s/^[0]+//;
				if($trim_ean1 eq $trim_ean2){
					#&do_statement('DELETE FROM product_ean_codes WHERE ean_id='.$ean2->[0]);
					#&do_statement('UPDATE FROM product_modification_time SET modification_time=unix_timestamp() WHERE product_id='.$product->[0]);
					$csv_report.=toCSV($product->[1]).','.toCSV($product->[2]).','.toCSV($ean1->[0]).','.toCSV($ean2->[0])."\n";
					$ean2->[0]='';		
				}
			}
		}
	}
}
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => 'Dublicate EANs report',
		'default_encoding'=>'utf8',
		'text_body' =>" Dublicates found",
		'attachment_name' => 'dublicates.csv',
		'attachment_content_type' => 'text/csv',
		'attachment_body' => $csv_report,						
		};
	&simple_sendmail($mail);
	
sub toCSV{
	my $str=shift;
	$str=~s/"/""/gs;
	return $str;	
}

print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);

exit();

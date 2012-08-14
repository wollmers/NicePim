#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atom_mail;
use atomcfg;
use Spreadsheet::ParseExcel;
use atom_util;
my $time_start = Time::HiRes::time();

my ($base_brand_col,$base_prod_id_col,$rel_brand_col,$rel_prod_id_col,$base_name_col,$rel_name_col)=(0,1,2,3,0,2);

&do_statement('DROP TABLE aaa_tmp_related ');
&do_statement("CREATE TABLE aaa_tmp_related (
				id int(13) not null auto_increment,
				base_brand varchar(255) not null default '',
				base_prod_id varchar(40) not null default '',
				rel_prod_id varchar(40) not null default '',
				rel_brand varchar(255) not null default '',
				base_name varchar(255) not null default '',
				rel_name varchar(255) not null default '',
				base_supplier_id int(13) not null default 0,
				rel_supplier_id int(13) not null default 0,
				base_product_id int(13) not null default 0,
				rel_product_id int(13) not null default 0,
				is_present tinyint(1) not null default 0, 
				PRIMARY KEY(id)
				)");
my $excel_obj=Spreadsheet::ParseExcel->new()->Parse('/home/alex/icecat/one_time/realted_20101220/printer_supplies.xls');
my $firstSheet=$excel_obj->{Worksheet}->[0]; 
	for(my $i=1; $i<$firstSheet->{MaxRow}; $i++){
			#$firstSheet->{Cells}[$i][$j];
			my $base_brand=(($firstSheet->{Cells}[$i][$base_brand_col])?$firstSheet->{Cells}[$i][$base_brand_col]->value():"");
			my $rel_brand=(($firstSheet->{Cells}[$i][$base_brand_col])?$firstSheet->{Cells}[$i][$base_brand_col]->value():"");
			$base_brand=&trim($base_brand);
			$rel_brand=&trim($rel_brand);
			$base_brand=~s/([^\s]+).+/$1/gs;
			$rel_brand=~s/([^\s]+).+/$1/gs;
			&do_statement('INSERT INTO aaa_tmp_related (base_brand,base_prod_id,rel_prod_id,rel_brand,base_name,rel_name) VALUES('.
				&str_sqlize(($firstSheet->{Cells}[$i][$base_brand_col])  ?$base_brand:"''").','.
				&str_sqlize(($firstSheet->{Cells}[$i][$base_prod_id_col])?trim($firstSheet->{Cells}[$i][$base_prod_id_col]->value()):"''").','.
				&str_sqlize(($firstSheet->{Cells}[$i][$rel_prod_id_col]) ?trim($firstSheet->{Cells}[$i][$rel_prod_id_col]->value()):"''").','.
				&str_sqlize(($firstSheet->{Cells}[$i][$rel_brand_col])   ?$rel_brand:"''").','.
				&str_sqlize(($firstSheet->{Cells}[$i][$base_name_col])   ?$firstSheet->{Cells}[$i][$base_name_col]->value():"''").','.
				&str_sqlize(($firstSheet->{Cells}[$i][$rel_name_col])    ?$firstSheet->{Cells}[$i][$rel_name_col]->value():"''").')'
				);									
	}

&do_statement('ALTER TABLE aaa_tmp_related ADD KEY (base_brand),ADD KEY (rel_brand)');
&do_statement('UPDATE aaa_tmp_related tr JOIN supplier s ON tr.base_brand=s.name 
										 SET tr.base_supplier_id=s.supplier_id');
&do_statement('UPDATE aaa_tmp_related tr JOIN data_source_supplier_map s ON tr.base_brand=s.symbol 
										 SET tr.base_supplier_id=s.supplier_id WHERE s.data_source_id=1 and tr.base_supplier_id=0');										 
&do_statement('UPDATE aaa_tmp_related tr JOIN supplier s ON tr.rel_brand=s.name 
										 SET tr.rel_supplier_id=s.supplier_id');
&do_statement('UPDATE aaa_tmp_related tr JOIN data_source_supplier_map s ON tr.rel_brand=s.symbol 
										 SET tr.rel_supplier_id=s.supplier_id WHERE s.data_source_id=1 and tr.rel_supplier_id=0');										 
&do_statement('ALTER TABLE aaa_tmp_related ADD KEY (base_supplier_id,base_prod_id),ADD KEY (rel_supplier_id,rel_prod_id)');


&do_statement('UPDATE aaa_tmp_related tr JOIN product p ON tr.base_supplier_id=p.supplier_id AND 
														   tr.base_prod_id=p.prod_id  
										 SET tr.base_product_id=p.product_id');
&do_statement('UPDATE aaa_tmp_related tr JOIN product p ON tr.rel_supplier_id=p.supplier_id AND 
														   tr.rel_prod_id=p.prod_id  
										 SET tr.rel_product_id=p.product_id');
# mark existed links
&do_statement('UPDATE aaa_tmp_related tr JOIN product_related pr 
				ON  tr.base_product_id=pr.product_id AND tr.rel_product_id=pr.rel_product_id
				SET tr.is_present=1');
# mark existed links vice versa				
&do_statement('UPDATE aaa_tmp_related tr JOIN product_related pr 
				ON  tr.base_product_id=pr.rel_product_id AND tr.rel_product_id=pr.product_id
				SET tr.is_present=1');

&do_statement('INSERT IGNORE INTO product_related (product_id,rel_product_id,data_source_id) 
			   SELECT base_product_id,rel_product_id,666 FROM aaa_tmp_related
			   WHERE rel_product_id!=0 AND base_product_id!=0');
my $csv="";
my $delim=",";
my $nl="\n";
$csv.='"BASE brand"'.$delim.'"Base partcode"'.$delim.'"Related brand"'.$delim.'"Related partcode"'.$delim.'"Base name"'.$delim.'"Related name "'.$nl;

my $added_rows=&do_query('SELECT base_brand,base_prod_id,rel_brand,rel_prod_id,base_name,rel_name FROM aaa_tmp_related WHERE  base_product_id!=0 AND rel_product_id!=0 AND is_present=0');
foreach my $row (@$added_rows){
	$csv.='"'.toCSV($row->[0]).'"'.$delim.'"'.toCSV($row->[1]).'"'.$delim.'"'.toCSV($row->[2]).'"'.$delim.'"'.toCSV($row->[3]).'"'.$delim.'"'.toCSV($row->[4]).'"'.$delim.'"'.toCSV($row->[5]).'"'.$nl;
}

$csv.="Already EXISTED ".$nl.$nl.$nl;
my $existed_rows=&do_query('SELECT base_brand,base_prod_id,rel_brand,rel_prod_id,base_name,rel_name FROM aaa_tmp_related WHERE  base_product_id!=0 AND rel_product_id!=0 AND is_present=1');
foreach my $row (@$existed_rows){
	$csv.='"'.toCSV($row->[0]).'"'.$delim.'"'.toCSV($row->[1]).'"'.$delim.'"'.toCSV($row->[2]).'"'.$delim.'"'.toCSV($row->[3]).'"'.$delim.'"'.toCSV($row->[4]).'"'.$delim.'"'.toCSV($row->[5]).'"'.$nl;
}

$csv.="IGNORED ".$nl.$nl.$nl;
my $ignored_rows=&do_query('SELECT base_brand,base_prod_id,rel_brand,rel_prod_id,base_name,rel_name FROM aaa_tmp_related WHERE  base_product_id=0 OR rel_product_id=0');
foreach my $row (@$ignored_rows){
	$csv.='"'.toCSV($row->[0]).'"'.$delim.'"'.toCSV($row->[1]).'"'.$delim.'"'.toCSV($row->[2]).'"'.$delim.'"'.toCSV($row->[3]).'"'.$delim.'"'.toCSV($row->[4]).'"'.$delim.'"'.toCSV($row->[5]).'"'.$nl;
}
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => 'One time related import',
		'default_encoding'=>'utf8',
		'text_body' =>" One time related import",
		'attachment_name' => 'result.csv',
		'attachment_content_type' => 'text/csv',
		'attachment_body' => $csv,						
		};
	&simple_sendmail($mail);
print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);
sub toCSV{
	my $str=shift;
	$str=~s/"/""/gs;
	return $str;
}
exit();

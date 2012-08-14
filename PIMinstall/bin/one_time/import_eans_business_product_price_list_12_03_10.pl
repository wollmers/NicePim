#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atom_mail;
use atomcfg;
use icecat_util;
use coverage_report;
use Spreadsheet::WriteExcel::Big;
#use Spreadsheet::ParseExcel;
my $time_start = Time::HiRes::time();
#my $excel = Spreadsheet::XLSX->new('/home/www/Business_Product_Price_List_12-03-10.xlsx');
my $excel = Spreadsheet::ParseExcel->new()->Parse('/home/www/TomTom_EAN_Codes_201101.xls');
			
my $start_row=2;

my $sheets=scalar(@{$excel->{Worksheet}});
print $sheets;
&do_statement("drop TABLE if exists aaa_eans ");
&do_statement("CREATE TABLE aaa_eans (
	ean_code varchar(255) not null default '',
	name varchar(255) not null default '',
	vendor varchar(255) not null default '',
	prod_id varchar(40) not null default '',
	product_id int(13) not null default 0,
	supplier_id int(13) not null default 0,	
	existed int(1) not null default 0
)");
open my $fh, '>', \my $xls;
my $workbook=Spreadsheet::WriteExcel::Big->new($fh);
my $added_page=$workbook->add_worksheet("Added") ;
my $unmatch_page=$workbook->add_worksheet("Unmatched");
my $existed_page=$workbook->add_worksheet("Already existed");
my $err_page=$workbook->add_worksheet("Errors") ;

for(my $i=0;$i<$sheets;$i++){
	#print $excel->{Worksheet}->[$i]->{Name}."----".$excel->{Worksheet}->[$i]->{MaxRow}."\n";
	my $brand=$excel->{Worksheet}->[$i]->{Name};
	$brand='TomTom';
	for(my $j=$start_row;$j<=$excel->{Worksheet}->[$i]->{MaxRow};$j++){
		my ($partcode,$ean,$name);
		$name=    ($excel->{Worksheet}->[$i]->{Cells}[$j][1])?$excel->{Worksheet}->[$i]->{Cells}[$j][1]->value():'';
		$partcode=($excel->{Worksheet}->[$i]->{Cells}[$j][0])?$excel->{Worksheet}->[$i]->{Cells}[$j][0]->value():'';
		$ean=     ($excel->{Worksheet}->[$i]->{Cells}[$j][2])?$excel->{Worksheet}->[$i]->{Cells}[$j][2]->value():'';
		if($ean and $partcode){		
			&do_statement('INSERT INTO aaa_eans (ean_code,prod_id,vendor,name) 
					   VALUES('.&str_sqlize($ean).','.&str_sqlize($partcode).','.&str_sqlize($brand).','.&str_sqlize($name).')');
		}else{
			$err_page->{max_rows}++;						
			$err_page->write_string($err_page->{max_rows},0,$name);
			$err_page->write_string($err_page->{max_rows},1,$ean);
			$err_page->write_string($err_page->{max_rows},2,$partcode);
			$err_page->write_string($err_page->{max_rows},3,$brand);
		}
	}		
}
&do_statement("UPDATE aaa_eans SET ean_code=LPAD(ean_code,13,'0') 
WHERE length(ean_code)<13 and ean_code!=''");
&do_statement("ALTER TABLE aaa_eans ADD KEY(ean_code)");
coverage_by_table('aaa_eans',{});
my $products=&do_query('SELECT name,ean_code,prod_id,vendor FROM aaa_eans WHERE product_id=0');
foreach my $prod (@$products){
			$unmatch_page->{max_rows}++;
			$unmatch_page->write_string($unmatch_page->{max_rows},0,$prod->[0]);
			$unmatch_page->write_string($unmatch_page->{max_rows},1,$prod->[1]);
			$unmatch_page->write_string($unmatch_page->{max_rows},2,$prod->[2]);
			$unmatch_page->write_string($unmatch_page->{max_rows},3,$prod->[3]);		
}
&do_statement("DELETE FROM aaa_eans WHERE product_id=0");
&do_statement("UPDATE aaa_eans t 
			   JOIN product_ean_codes pe ON t.ean_code=pe.ean_code
			   SET existed=1");
$products=&do_query('SELECT name,ean_code,prod_id,vendor FROM aaa_eans WHERE existed=1');
foreach my $prod (@$products){
			$existed_page->{max_rows}++;
			$existed_page->write_string($existed_page->{max_rows},0,$prod->[0]);
			$existed_page->write_string($existed_page->{max_rows},1,$prod->[1]);
			$existed_page->write_string($existed_page->{max_rows},2,$prod->[2]);
			$existed_page->write_string($existed_page->{max_rows},3,$prod->[3]);		
}

$products=&do_query('SELECT name,ean_code,prod_id,vendor FROM aaa_eans WHERE existed!=1');
foreach my $prod (@$products){
			$added_page->{max_rows}++;
			$added_page->write_string($added_page->{max_rows},0,$prod->[0]);
			$added_page->write_string($added_page->{max_rows},1,$prod->[1]);
			$added_page->write_string($added_page->{max_rows},2,$prod->[2]);
			$added_page->write_string($added_page->{max_rows},3,$prod->[3]);		
}
#&do_statement('INSERT IGNORE INTO product_ean_codes (product_id,ean_code) 
#			   SELECT product_id,ean_code FROM aaa_eans WHERE product_id!=0 and existed!=1');
$workbook->close();
	my $mail = {
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Eans import",
		'default_encoding'=>'utf8',
		'html_body' => 'Eans import',
		'attachment_name' => 'report.xls',
		'attachment_content_type' => 'application/vnd.ms-excel',
		'attachment_body' => $xls,
		};
&complex_sendmail($mail);
print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);

exit();
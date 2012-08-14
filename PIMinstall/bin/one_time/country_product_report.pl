#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atom_mail;
use atomcfg;
use icecat_util;
my $time_start = Time::HiRes::time();

my @countries=('Danmark','France','Germany','Italy','Norway','Poland','Spain','Sweden','Turkey');
#my @countries=('Poland','Norway');
my $summary;
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "country report",
		'default_encoding'=>'utf8',
		'html_body' => $summary
		#'attachment_name' => $file_name.'.zip',
		#'attachment_content_type' => 'application/zip',
		#'attachment_body' => $gziped,
		};
my $attach_cnt=1;
		
foreach my $country (@countries){
	print $country."\n";
	my $country_id=&do_query("SELECT country_id FROM country c JOIN vocabulary v ON c.sid=v.sid and v.langid=1 WHERE v.value='$country'")->[0][0];
	if(!$country_id){
		print 'No country !!!!!';
		next;
	}
	&do_statement('drop temporary TABLE IF EXISTS tmp_country_product');
	&do_statement("CREATE temporary TABLE tmp_country_product (
					product_id int(13) not null, 
					prod_id varchar(40) not null,
					supplier_id int(13) not null, 
					catid int(13) not null,
					user_id int(13) not null,
					high_pic varchar(255) not null default '',
					date_added timestamp,
					primary key(product_id) ) ");
	&do_statement("INSERT INTO tmp_country_product (product_id,prod_id,supplier_id,date_added,catid,high_pic,user_id) 
					SELECT p.product_id,p.prod_id,p.supplier_id,p.date_added,p.catid,p.high_pic,p.user_id  FROM product p 
					JOIN country_product cp ON p.product_id=cp.product_id AND cp.country_id=$country_id");
	$summary.='---------'.uc($country).'------------'."\n<br/>";
	
	my $features=&do_query("SELECT count(*) FROM (SELECT p.product_id FROM tmp_country_product p 
			   JOIN product_feature pf ON pf.product_id=p.product_id
			   WHERE pf.value!=''			   
			   GROUP BY p.product_id) as tbl")->[0][0];
	my $features_loc=&do_query("SELECT count(*) FROM (SELECT p.product_id FROM tmp_country_product p 
			   JOIN product_feature_local pf ON pf.product_id=p.product_id
			   WHERE pf.value!=''			   
			   GROUP BY p.product_id) as tbl")->[0][0];
	$summary.='Products with features :'.($features+$features_loc)."\n<br/>";
	
	my $products=&do_query("SELECT count(*) FROM tmp_country_product p ")->[0][0];
	$summary.='Products with EAN codes/vendor part number :'.($products)."\n<br/>";
	
	my $with_gallery=&do_query("SELECT count(*) FROM (SELECT p.product_id FROM tmp_country_product p			   
			   JOIN product_gallery pg ON pg.product_id=p.product_id
			   WHERE p.high_pic='' and pg.link!=''			   
			   GROUP BY p.product_id) as tbl")->[0][0];
	my $with_head_img=&do_query("SELECT count(p.product_id) FROM tmp_country_product p			   			   
			   WHERE p.high_pic!=''")->[0][0];
			   
	$summary.='Products with pictures (images/pictures) :'.($with_head_img+$with_gallery)."\n<br/>";
	
	my $prices=&do_query("SELECT count(*) FROM (SELECT p.product_id FROM tmp_country_product p 			   
			   JOIN product_price pp ON p.product_id=pp.product_id
			   WHERE pp.price!=0			   
			   GROUP BY p.product_id) as tbl")->[0][0];
	$summary.='products with price offers from resellers :'.($prices)."\n<br/>";
	
	my %cats_uniq;
	my $cats=&do_query("SELECT v.value FROM tmp_country_product p 			   
			   JOIN product_feature pf ON pf.product_id=p.product_id
			   JOIN category c USING(catid)
			   JOIN vocabulary v ON c.sid=v.sid AND v.langid=1
			   WHERE pf.value!=''
			   GROUP BY c.catid");				   
	foreach my $cat (@$cats){
		$cats_uniq{$cat->[0]}=1;;	
	}
	my $cats=&do_query("SELECT v.value FROM tmp_country_product p 			   
			   JOIN product_feature_local pf ON pf.product_id=p.product_id
			   JOIN category c USING(catid)
			   JOIN vocabulary v ON c.sid=v.sid AND v.langid=1
			   WHERE pf.value!=''
			   GROUP BY c.catid");
	foreach my $cat (@$cats){
		$cats_uniq{$cat->[0]}=1;;	
	}
	my @cats_sorted=keys(%cats_uniq);
	@cats_sorted=sort(@cats_sorted);
	my $cnt=0;
	$summary.='Categories with product specifications (what categories):'.scalar(@cats_sorted)."\n<br/><table><tr>";
	foreach my $cat (@cats_sorted){
		$cnt++;
		$summary.='<td>'.$cat.'</td>';
		if($cnt==10){
			$cnt=0;
			$summary.="</tr><tr>";
		}
	}
	$summary.="</tr></table>\n<br/>";
	my $country_products=&do_query("SELECT p.product_id,p.prod_id,s.name,s.is_sponsor,u.login,mm.measure,cp.active,p.date_added 
			   FROM tmp_country_product p
			   JOIN country_product cp ON p.product_id=cp.product_id AND cp.country_id=$country_id
			   JOIN supplier s USING(supplier_id)
			   JOIN users u ON u.user_id=p.user_id
			   JOIN user_group_measure_map mm USING(user_group)
			   ");
	print scalar(@$country_products)."\n";	   
	my $csv='"ID","PARTCODE","BRAND","SPONSORED","USER","QUALITY","ON MARKED","ADDED","LINK"'."\n";
	print (scalar(@$country_products))." products in list\n";				   
	foreach my $product (@$country_products){
		if($product->[3]){
				$product->[3]='Y'
		}else{
			$product->[3]='N'
		};
		if($product->[6]){
				$product->[6]='Y'
		}else{
			$product->[6]='N'
		};
		 
		foreach my $cell (@$product){
			$csv.=toCSV($cell).',';
		}
		$csv.='"http://icecat.biz/EN/p/'.encode_url($product->[2]).'/'.encode_url($product->[1]).'/desc.htm"';
		$csv.="\n";
	}	
	#$mail->{'attachment'.(($attach_cnt==1)?'':$attach_cnt).'_name'} = $country.'.csv.gz';
	#$mail->{'attachment'.(($attach_cnt==1)?'':$attach_cnt).'_content_type'} = 'application/gzip';
	#$mail->{'attachment'.(($attach_cnt==1)?'':$attach_cnt).'_body'} =$$tmp;	
	my $tmp=gzip_data_by_ref(\$csv);	
	open F,'>'.$atomcfg{'base_dir'}.'bin/one_time/'.$country.'.csv.gz';
	print F $$tmp;
	close(F);
	$attach_cnt++;
}
	$mail->{'html_body'}=$summary;
	&complex_sendmail($mail);
sub toCSV{
	my $str=shift;
	$str=~s/"/""/gs;
	return '"'.$str.'"';	
}	
print $summary;
print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);
exit();

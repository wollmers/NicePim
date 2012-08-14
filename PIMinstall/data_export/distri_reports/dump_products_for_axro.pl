#!/usr/bin/perl

#$Id: dump_product_info_expanded 2504 2010-04-28 12:00:24Z dima $

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';
#use lib "/home/alex/icecat/bo/trunk/lib";
use strict;

use atomcfg;
use atomlog;
use atomsql;
use HTML::Entities;
use Getopt::Long;
use atom_html;
use Data::Dumper;
use atom_mail;
use Spreadsheet::XLSX;
# init
use Time::Piece;
$| = 1;

my $lang = 1; # default lang
my $brand = 0; # default brand
my $category = 0; # default category
my $verbose = undef; # default verbose mode
my $class = 0; # default class value
my $all = 0; # default all value
my $distri_code=0;
my $Getopt_Long_result = GetOptions(
	'lang=s' => \$lang,
	'brand=s' => \$brand,
	'category=s' => \$category,
	'verbose' => \$verbose,
	'class=s' => \$class,
	'all' => \$all,
	);
# configs
my $sep = "\t";
my $nl = "\n";
#my $dump_dir="/home/alexey/icecat/info/Axro/test/";
my $dump_dir="/home/pim/data_export/distri_reports/";
my $features_file=$atomcfg{'base_dir'}.'data_export/distri_reports/Axro_featuremapped.xls';
my $distri_name='Axro'; 
my $distri_id=&do_query("SELECT distributor_id FROM distributor WHERE name='$distri_name'")->[0][0];
# start
if(!$distri_id){
	email_error($distri_name,'No such distributor');
	exit();
}

#print $distri_id;
my $feats_xls = Spreadsheet::ParseExcel->new()->Parse($features_file);
if(!$feats_xls or !$feats_xls->{Worksheet}->[0]){
	email_error($distri_name,'File with features was not opened');
	exit();
}
my $firstSheet=$feats_xls->{Worksheet}[0];
if(!defined($firstSheet->{MaxCol}) or !defined($firstSheet->{MaxRow})){# sheet looks empty 
	email_error($distri_name,'File with features is empty');
	exit();	
}

&do_statement('DROP TEMPORARY TABLE IF EXISTS tmp_feat_mapping');
&do_statement("CREATE TEMPORARY TABLE tmp_feat_mapping (
			  name varchar(255) not null,
			  measure_sign varchar(40) not null default '',
			  orderby int(13) not null default 0
			  )");
my $insert_sql='INSERT INTO tmp_feat_mapping (name,measure_sign,orderby) VALUES ';			  
for(my $i=1; $i<$firstSheet->{MaxRow}+1; $i++){
	$insert_sql.='('.str_sqlize(($firstSheet->{Cells}[$i][0])?$firstSheet->{Cells}[$i][0]->value:'').','.
					 str_sqlize(($firstSheet->{Cells}[$i][1])?$firstSheet->{Cells}[$i][1]->value:'').','.
					 str_sqlize(($firstSheet->{Cells}[$i][2])?$firstSheet->{Cells}[$i][2]->value:'').'),';
}
$insert_sql=~s/,$//;
&do_statement($insert_sql);
&do_statement('ALTER IGNORE TABLE tmp_feat_mapping ADD UNIQUE KEY(name)');
 
&do_statement('DROP TEMPORARY TABLE IF EXISTS tmp_required_feats');
&do_statement("CREATE TEMPORARY TABLE tmp_required_feats AS (SELECT f.feature_id,tf.measure_sign,tf.orderby,v.value as feature_name FROM tmp_feat_mapping tf 
			   JOIN vocabulary v ON v.value=tf.name and v.langid=1 
			   JOIN feature f on f.sid=v.sid WHERE 1)"); 
&do_query('ALTER TABLE tmp_required_feats ADD KEY(feature_id)');
my $feature_measure_map=&do_query('SELECT feattmp_required_feats');;
my $langs=&do_query("SELECT langid,short_code FROM language WHERE published='Y' and langid in (1,3,4)");
my $req_en_feats={};
foreach my $lang (@$langs){
	print "LANG: $lang->[1] product properties ";
	&do_statement("DROP temporary TABLE IF EXISTS tmp_prop_selection ");
	&do_statement("CREATE temporary TABLE tmp_prop_selection AS (
					SELECT p.product_id,dp.original_prod_id,p.prod_id,pn.name,vf.value as family,v.value as category,
						   pd.short_desc, pd.long_desc, s.name as brand, p.low_pic, p.high_pic,p.thumb_pic,
						   pd.pdf_url, pd.warranty_info,p.name as product_name,dp.active,mf.modification_time,p.date_added,
					      GROUP_CONCAT(DISTINCT pg.link SEPARATOR '~') as images,
						  GROUP_CONCAT(DISTINCT TRIM(LEADING '0' FROM pec.ean_code) SEPARATOR '~') as eans 
					FROM product p JOIN supplier s USING(supplier_id) 
					JOIN distributor_product dp ON dp.product_id=p.product_id and dp.distributor_id=$distri_id
					JOIN category c ON p.catid=c.catid 
					JOIN vocabulary v ON v.sid=c.sid AND v.langid=$lang->[0]  
					JOIN users u ON u.user_id=p.user_id 
					JOIN user_group_measure_map USING(user_group) 
					LEFT JOIN product_description pd ON pd.product_id=p.product_id AND pd.langid=$lang->[0] 
					LEFT JOIN product_ean_codes pec ON pec.product_id=p.product_id 
					LEFT JOIN product_gallery pg ON p.product_id=pg.product_id
					LEFT JOIN product_name pn ON pn.product_id=p.product_id AND pn.langid=$lang->[0]
					LEFT JOIN product_family pf ON pf.family_id=p.family_id
					LEFT JOIN vocabulary vf ON vf.sid=pf.sid AND vf.langid=1
					LEFT JOIN product_modification_time mf ON mf.product_id=p.product_id
					 WHERE 1 
					GROUP BY p.product_id LIMIT 10)");
	&do_statement("ALTER TABLE tmp_prop_selection ADD UNIQUE KEY(product_id)");
	print " product features ";
	my $req_feats=&do_query("SELECT f.feature_id,IF(v2.value IS NULL,v.value,v2.value),rf.measure_sign,rf.orderby,v.value
							FROM tmp_required_feats rf 
						    JOIN feature f ON f.feature_id=rf.feature_id  
						    JOIN vocabulary v ON v.sid=f.sid and v.langid=1						    
						    LEFT JOIN vocabulary v2 ON v2.sid=f.sid and v2.langid=$lang->[0]
						    LEFT JOIN measure_sign ms ON ms.measure_id=f.measure_id and ms.langid=1
						    GROUP BY v.value ORDER BY rf.orderby");
	my $req_feats_hash={};						    
	foreach my 	$req_feat (@$req_feats){
		$req_feats_hash->{$req_feat->[4]}={'order'=>$req_feat->[3],
			        					   'name'=>$req_feat->[1],
			        					   'main_measure'=>$req_feat->[2]};
	}
	if($lang->[0] ==1){
		$req_en_feats=$req_feats_hash;
	}	
	#my $max_imgs=&do_query("SELECT max(length(images)-length(REPLACE(images,'~',''))) FROM tmp_prop_selection")->[0][0];
	#if($max_imgs==0){
	#	$max_imgs=1;
	#}elsif(!$max_imgs){
	#	$max_imgs=0;
	#}
	my $max_eans=&do_query("SELECT max(length(eans)-length(REPLACE(eans,'~',''))) FROM tmp_prop_selection")->[0][0];
	if($max_eans==0){
		$max_eans=1;
	}elsif(!$max_eans){
		$max_eans=0;
	}	
	
	print " go to foreach \n ";	
	my $rows=&do_query('SELECT tps.product_id,tps.original_prod_id,tps.eans,tps.prod_id,tps.name,family,category,short_desc,long_desc,
							  brand,low_pic,high_pic,thumb_pic,pdf_url,warranty_info,product_name,active,date_added,modification_time
													 
						FROM tmp_prop_selection tps 					  	 
					  	ORDER BY tps.product_id');
	if(!(-d $dump_dir.$lang->[1])){
		`mkdir $dump_dir$lang->[1]`;
	}
	open(CSV,'>'.$dump_dir.$lang->[1].'/products.csv');	
	binmode CSV, ":utf8";
	my $csv_str='';
	my ($feature_table,$lang_sql);
	if($lang->[0]==1){
		$feature_table='product_feature';
	}else{
		$feature_table='product_feature_local';
		$lang_sql=' AND pf.langid='.$lang->[0];
	}
	my $csv_header=toCSV('axroartikelnummer').$sep;
	#for (my $i=0;$i<$max_imgs;$i++){
	#	$csv_header.='Image # '.$i.$sep;
	#}
	for (my $i=0;$i<$max_eans;$i++){
		$csv_header.=toCSV('EAN # '.$i).$sep;
	}
	$csv_header.=toCSV('Product Code').$sep.toCSV('Product name').$sep.toCSV('Product family').$sep.toCSV('Category').$sep.
				 toCSV('Short description').$sep.toCSV('Long description').$sep.toCSV('Brand').$sep.toCSV('Picture_Low resolution').$sep.
				 toCSV('Picture_High resolution').$sep.toCSV('Picture_Thumbnail').$sep.toCSV('PDF').$sep.toCSV('Warranty').$sep;
	foreach my $req_feat (@$req_feats){
		my $feature_name=$req_feat->[1];
		if(!$feature_name){
			$feature_name=$req_feats_hash->{$req_feat->[0]};
		}
		$csv_header.=toCSV($feature_name).$sep;
	}
	$csv_header.=toCSV('Alternatives').$sep.toCSV('ICEcat_XML').$sep.toCSV('ICEcat_URL').$sep.
				 toCSV('ICECat_on_Market').$sep.toCSV('ICECat_creation_date').$sep.toCSV('ICECat_update');
	print CSV $csv_header.$nl;
	my $features_cnt=scalar(@$req_feats);
	foreach my $row (@$rows){
		$csv_str=props2csv($row,$max_eans);#$max_imgs
		if($row->[0]==94894){
			my $aa=1;
		}
		my $features=do_query("SELECT v.value,pf.value,tr.feature_name,ms.value FROM $feature_table pf 
								JOIN category_feature cf USING(category_feature_id)
								JOIN tmp_required_feats tr ON cf.feature_id=tr.feature_id
								JOIN feature f ON f.feature_id=tr.feature_id
								JOIN vocabulary v ON v.sid=f.sid AND v.langid=1 
								LEFT JOIN measure_sign ms ON f.measure_id=ms.measure_id AND ms.langid=1
								WHERE pf.product_id=$row->[0] and pf.value!='' $lang_sql 
								ORDER BY IF(ms.value = tr.measure_sign,1,0) DESC");
			my @out_features;
			$out_features[$features_cnt]='';				
			foreach my $feature (@$features){
				if($req_feats_hash->{$feature->[0]}){
					my $req_feature=$req_feats_hash->{$feature->[0]};
					if(!$out_features[$req_feature->{'order'}]){
						$out_features[$req_feature->{'order'}]=toCSV(measure_conversion($feature->[1],$feature->[3],$req_feature->{'main_measure'},$feature->[2]));
						
					}
				}
				my $aa=1;
			}
		$csv_str.=$sep.join($sep,@out_features);
		my $xml_link="http://data.icecat.biz/export/level4/$lang->[1]/$row->[0].xml";
		$csv_str.=$sep.toCSV($xml_link);
		my $http_link="http://icecat.biz/$lang->[1]/p/".&str_htmlize(&decode_entities($row->[9]))."/".&str_htmlize(&decode_entities($row->[3]))."/axro.html";
		$csv_str.=$sep.toCSV($http_link);
		#$csv_str.=$sep.(($row->[15])?toCSV('Y'):toCSV('N'));
		$csv_str.=$sep.$row->[16];
		my $update_date;
		
		if($row->[18]){
			$update_date=Time::Piece->new($row->[18]);
		} 
		$csv_str.=$sep.toCSV($row->[17]).$sep.toCSV($update_date);
		$csv_str=~s/\n//gs; # remove all new lines
		$csv_str=~s/\r//gs; # remove all new lines
		print CSV $csv_str.$nl;
		print '.';
	}
	close(CSV);
	print "\n";							  
	#test_tables();
}

print " done\n\n";

exit(0);

# sub
sub measure_conversion{
	my ($value,$sign,$needed_sign,$feature_name)=@_;
	
	if($sign eq $needed_sign){
		if($needed_sign eq 'g' and $value=~/kg[\s]*$/){# if we have kilograms in gramms
			$sign='kg';
			$value=~s/kg[\s]*$//;
		}else{
			$value=~s/\Q$needed_sign\E//;
			return $value;						
		}
	}
	my $coof_table={'mm'};
	$value=~s/\Q$sign\E//;
	if($sign eq 'kg' and $needed_sign eq 'g'){
		return common_conversion($value,$sign,1000);		
	}elsif($sign eq 'g' and $needed_sign eq 'kg'){
		return common_conversion($value,$sign,0.0001);
	}elsif($sign eq 'm' and $needed_sign eq 'mm'){
		return common_conversion($value,$sign,100);
	}elsif($sign eq 'cm' and $needed_sign eq 'mm'){
		return common_conversion($value,$sign,10);
	}elsif($sign eq '"' and $needed_sign eq 'mm'){
		return common_conversion($value,$sign,25.4);		
	}elsif($sign eq 'mm' and $needed_sign eq 'm'){
		return common_conversion($value,$sign,0.01);
	}elsif($sign eq 'cm' and $needed_sign eq 'm'){
		return common_conversion($value,$sign,0.1);
	}else{
		return $value;
	}
}

sub common_conversion{
	my ($value,$sign,$coof)=@_;
	$value=~s/,/./gs;
	my $trans_value;
	if($value!~/x/){	# dimension
		my @parsts=split(/ /,$value);
		foreach my $part (@parsts){
			if($part=~/^[\d\s\.]+$/){
				$part=~s/\s//;
				$part=$part*$coof;
			}
			$trans_value.=$part.' ';
		}
		$trans_value=~s/\s$//s;
	}else{
		my @parsts=split(/x/i,$value);
		foreach my $part (@parsts){
			if($part=~/^[\d\s\.]+$/){
				$part=$part*$coof;
			}
			$trans_value.=$part.'x';
		}
		$trans_value=~s/x$//s;
	}
	return $trans_value; 
	
}

sub props2csv{
	my ($row,$max_eans,$max_imgs)=@_;
	my $first_str=toCSV($row->[1]).$sep;
	#my @img_urls=split('~',$row->[4]);
	#for( my $i=0; $i<$max_imgs; $i++){
	#	$first_str.=toCSV($img_urls[$i]).$sep;
	#}
	my @eans=split('~',$row->[2]);
	for( my $i=0; $i<$max_eans; $i++){
		$first_str.=toCSV($eans[$i]).$sep;
	}
	my $model=$row->[4];
	if(!$model){
		$model=$row->[15];
	}
	$first_str.=toCSV($row->[3]).$sep.toCSV($model).$sep.toCSV($row->[5]).$sep.toCSV($row->[6]).
					   $sep.toCSV($row->[7]).$sep.toCSV($row->[8]).$sep.toCSV($row->[9]).
					   $sep.toCSV($row->[10]).$sep.toCSV($row->[11]).$sep.toCSV($row->[12]).$sep.
					   toCSV($row->[13]).$sep.toCSV($row->[14]);
	return $first_str;
}
sub toCSV{
	my ($str)=@_;
	$str=~s/"/""/gs;
	return '"'.$str.'"';	
}

sub test_tables{
	sub create_aaa_test{
		my $table=shift;
		&do_statement("DROP TABLE IF EXISTS aaa_$table");
		&do_statement("CREATE TABLE aaa_$table LIKE $table");
		&do_statement("INSERT INTO aaa_$table SELECT * FROM $table");
	}
	&create_aaa_test('tmp_prop_selection');	
	&create_aaa_test('tmp_required_feats');
	&create_aaa_test('tmp_feat_mapping');
	
}

sub email_error{
	my($name,$err_msg)=@_;
	my $mail = {
			'to' => 'alexey@bintime.com',
			'from' =>  $atomcfg{'mail_from'},
			'subject' => "Error!!! Export for $name failed",
			'default_encoding'=>'utf8',
			'html_body' => ''.$err_msg,
			};
	print $err_msg."\n";			
	&complex_sendmail($mail);
}
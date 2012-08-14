#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use XML::XPath;
my $time_start = Time::HiRes::time();
use utf8;
use atomcfg;
use atom_util;
use icecat_util;
use atom_misc;
use Spreadsheet::WriteExcel::Big;
use pricelist;
use atomlog;
use atom_mail;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Message;
use thumbnail;
use Encode;


use Digest::MD5 qw(md5 md5_base64);
#use MIME::Base64;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request::Common;


my $onlyReport=1;


my $source={
'washing machines'=>{# category of feature
	'Washing programs'=>[ #destination feture
		'delicate wash', # removed and grouped features
		'Hand wash',
		'Pre-wash',
		'Quick wash',
	]
  },
'dishwashers'=>{
	'Washing programs'=>['Quick wash'],
  }  
};

my %name2restrictedVal=(# should be lower-cased
'delicate wash'=>'delicate/silk',
'hand wash'=>'hand/wool',
'pre-wash'=>'pre-wash',
'quick wash'=>'quick'
);
	   

# checking data 
# make everything lovercase			   
my $tmp_source={};			   
foreach my $cat (keys %{$source}){
	my @dst_feats=keys(%{$source->{$cat}});
	foreach my $dst_feat (@dst_feats){		
		my @arr=map {lc($_)} @{$source->{$cat}->{$dst_feat}};
		$tmp_source->{lc($cat)}->{lc($dst_feat)}=\@arr;		
	}
}
$source=$tmp_source; 
			   
my $source_ids={};
my @cat_names=keys(%$source);
my $cat_ids=&do_query("SELECT lcase(v.value),c.catid FROM category c 
					   JOIN vocabulary v ON c.sid=v.sid and v.langid=1 
					   WHERE lcase(v.value) IN ('".join('\',\'',@cat_names)."')");
if(scalar(@$cat_ids)<1 or scalar(@$cat_ids)!=scalar(@cat_names)){
	err("Will not import with no category mapped");
	exit();
}
my $err_status=undef;
foreach my $cat (@$cat_ids){
	if($source->{$cat->[0]}){
		my $cat_feats=$source->{$cat->[0]};
		my @dst_feats_arr=keys(%{$source->{$cat->[0]}});
		my $dst_feat_ids=&do_query("SELECT lcase(v.value),cf.category_feature_id,f.type 
									FROM category_feature cf 
					  	 			JOIN feature f ON f.feature_id=cf.feature_id 
					  	 			JOIN vocabulary v ON f.sid=v.sid and v.langid=1
					   				WHERE cf.catid=$cat->[1] AND lcase(v.value) IN ('".join('\',\'',@dst_feats_arr)."')");
		if(scalar(@$dst_feat_ids)<1 or scalar(@$dst_feat_ids)!=scalar(@dst_feats_arr)){
			&err("This category $cat->[0] has no destination features. exit");
			exit();
		}
		foreach my $dst_feat_id (@$dst_feat_ids){
			if($source->{$cat->[0]}->{$dst_feat_id->[0]}){
				my @rm_feat_ids_arr=@{$source->{$cat->[0]}->{$dst_feat_id->[0]}};
				my $rm_feat_ids=&do_query("SELECT lcase(v.value),cf.category_feature_id 
									FROM category_feature cf 
					  	 			JOIN feature f ON f.feature_id=cf.feature_id 
					  	 			JOIN vocabulary v ON f.sid=v.sid and v.langid=1
					   				WHERE cf.catid=$cat->[1] AND  lcase(v.value) IN ('".join('\',\'',@rm_feat_ids_arr)."')");
				if(scalar(@$rm_feat_ids)<1 or scalar(@$rm_feat_ids)!=scalar(@rm_feat_ids_arr)){
					&err("This destionation feature $source->{$cat->[0]}->{$dst_feat_id->[0]}->[0] has no replaced features. exit");
					exit();
				}
				my $restricted_vals_arr;
				my %restricted_vals;
				$restricted_vals_arr=&do_query("SELECT f.restricted_values FROM category_feature cf 
										   JOIN feature f ON cf.feature_id=f.feature_id 
										   WHERE cf.catid=$cat->[1] AND cf.category_feature_id=$dst_feat_id->[1]");
				%restricted_vals=map {lc($_)=>1} split("\n",$restricted_vals_arr->[0][0]);
				foreach my $val (@rm_feat_ids_arr){					
					if(!$restricted_vals{$val} and !$restricted_vals{$name2restrictedVal{$val}}){
						&err("This feature '$val' is not mapped in restricted values '".join(' | ',keys(%restricted_vals))."' of feature '$dst_feat_id->[0]'");
						$err_status=1;
					}
				}
				
				my @tmp_arr=map { $_->[1] } @$rm_feat_ids;
				$source_ids->{$cat->[1]}->{$dst_feat_id->[1]}=\@tmp_arr;	
			}else{
				&err("This category feature $dst_feat_id->[0] does not exits in the source hash. Which is strange. exit. ");
				exit();
			}
		}		   				
		
	}else{
		err("This category '$cat->[0]' does not exits in the source hash. Which is strange. exit. ");
		exit();
	}
}


if($err_status){
	&err("Will not import untill everything will be good. Exit");
	exit();	
}

# -----------GROUPING DATA---------------
foreach my $cat_name (keys(%$source)){
	my $catid=&do_query('SELECT c.catid FROM category c 
						JOIN vocabulary v ON v.langid=1 and v.sid=c.sid
						WHERE v.value ='.&str_sqlize($cat_name))->[0][0];
	print $cat_name." Catid: $catid\n";
	foreach my $dst_name (keys(%{$source->{$cat_name}})){
		my $dst_catfeat=&do_query("SELECT cf.category_feature_id,f.restricted_values FROM category_feature cf 
								   JOIN feature f USING(feature_id)
								   JOIN vocabulary v ON v.sid=f.sid and v.langid=1
								   WHERE cf.catid=$catid AND v.value=".&str_sqlize($dst_name))->[0];
		print '   '.$dst_name." Dst cat feat id : $dst_catfeat->[0]\n";
		my %dst_rvals= map {lc($_)=>1} split(/\n/,$dst_catfeat->[1]);
		
		my $rm_cat_feats_sql;
		my %rm_feat_map;
		foreach my $rm_fname (@{$source->{$cat_name}->{$dst_name}}){
			my $rm_catfeat=&do_query("SELECT cf.category_feature_id FROM category_feature cf 
								   JOIN feature f USING(feature_id)
								   JOIN vocabulary v ON v.sid=f.sid and v.langid=1
								   WHERE cf.catid=$catid AND v.value=".&str_sqlize($rm_fname))->[0][0];
			$rm_cat_feats_sql.=$rm_catfeat.',';
			$rm_feat_map{$rm_catfeat}=$rm_fname;	
			print '     \''.$rm_fname."\' Dst feat_id : $rm_catfeat\n";
			
		}
		$rm_cat_feats_sql=~s/,$//;
		my $products=&do_query('SELECT product_id,prod_id FROM product p 
								JOIN product_feature pf USING(product_id)
								WHERE pf.category_feature_id in ('.$rm_cat_feats_sql.') 
								GROUP BY p.product_id');										
		foreach my $product (@$products){
			my $new_feature;
			my $rm_feats=&do_query("SELECT product_feature_id,category_feature_id,value FROM product_feature 
									WHERE product_id=$product->[0] and 
										  category_feature_id in (".$rm_cat_feats_sql.")");
			foreach my $rm_feat (@$rm_feats){
				if($rm_feat->[2] and lc($rm_feat->[2]) ne 'n' and  lc($rm_feat->[2]) ne 'not' and  lc($rm_feat->[2]) ne 'n/a'){
					if($dst_rvals{lc($rm_feat_map{$rm_feat->[1]})} or $dst_rvals{lc($name2restrictedVal{$rm_feat_map{$rm_feat->[1]}})}){												
						if($dst_rvals{lc($rm_feat_map{$rm_feat->[1]})}){
							$new_feature.=$rm_feat_map{$rm_feat->[1]}.',';
						}else{
							$new_feature.=$name2restrictedVal{lc($rm_feat_map{$rm_feat->[1]})}.',';
						};
					}else{
						print "Unexpected mapping missmatch for product $product->[0] \n";
					}
				}else{
					
				}
				#&do_statement("DELETE FROM product_feature WHERE product_feature_id=$rm_feat->[0]");
			}
			$new_feature=~s/,$//;
			print $product->[1].' '.$new_feature."\n";
			#my $prev_feature=&do_statement("REPLACE INTO product_feature (product_id,category_feature_id,value) 
			#								VALUES($product->[0],$dst_catfeat->[0],".&str_sqlize($new_feature).")");
			
							  
		}								
										
	}
} 
	
	my $mail = {
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "features grouping report",
		'default_encoding'=>'utf8',
		'html_body' => "report_updated.csv is a copy of table ",
		'attachment_name' => 'report_updated.csv.gz',
		'attachment_content_type' => 'application/x-gzip',
		'attachment_body' => '',
		
		'attachment2_name' => 'report_deleted.csv.gz',
		'attachment2_content_type' => 'application/x-gzip',
		'attachment2_body' => '',
		
		};
		
	#&complex_sendmail($mail);

sub err{
	print "ERROR: ".shift."\n";
}
					   
print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);

exit();
			

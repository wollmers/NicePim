#!/usr/bin/perl

#use lib "/home/alex/icecat/bo/trunk/lib";
use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
my $time_start = Time::HiRes::time();
use atomsql;
use atomcfg;
use strict;
use utf8;
#use atom_misc;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Message;
use atom_mail;
use Image::Compare;
use Imager;
use process_manager;
#print compare_url_images('/home/alex/tmp/2/2219232_2758.jpg','/home/alex/tmp/2/2219232_7105.jpg');
#print compare_url_images('/home/alex/tmp/3/832860-4.jpg','/home/alex/tmp/3/832860-1.jpg');
if (&get_running_perl_processes_number('image_dublicates.pl') != 1) {
	print "'image_dublicates.pl' already running. exit.\n";
  exit;
}

open LASTDATE,$atomcfg{'base_dir'}.'bin/testing/image_dublicates.date'; 
my $last_check=<LASTDATE>;
$last_check=~s/\n\s\t//gs;
if(!$last_check){
	$last_check=315522000;#1980-01-01 00:00:00
}
close LASTDATE;
my $products=&do_query("SELECT p.product_id,p.prod_id,s.name,count(pg.id) as cnt FROM product p JOIN supplier s USING(supplier_id) 
					   JOIN product_gallery pg USING(product_id) WHERE pg.updated>= FROM_UNIXTIME($last_check) GROUP BY p.product_id");
					   #p.product_id=2148783
my $curr_time=&do_query('SELECT unix_timestamp()')->[0][0];					   
open LASTDATE,'>'.$atomcfg{'base_dir'}.'bin/testing/image_dublicates.date';
print LASTDATE $curr_time;
close LASTDATE;
		   
my $csv_report;
my $csv_d=",";
my $csv_n="\n";
my $dublicates_cnt=0;
foreach my $product (@$products){
	my $urls=&do_query("SELECT link,'',id FROM product_gallery WHERE product_id =".$product->[0]);
	next if scalar(@$urls)<2;
	print "$product->[1].\n";
	foreach my $url (@$urls){
		if(!$url->[1]){
			my $img2_path=$atomcfg{'session_path'}.'compare_url_images_'.rand().'.jpg';
			`wget -c $url->[0] -O $img2_path`;
			$url->[1]=$img2_path;
		}
	}				
	foreach my $url (@$urls){		
		my $i=0;
		foreach my $url1 (@$urls){
			if($url1->[0] ne $url->[0]){
				my $result=compare_url_images($url1->[1],$url->[1]);
				if($result){
					delete($urls->[$i]);
					$dublicates_cnt++;
					print 'Dublicates found '.$url->[0].' ----------- '.$url1->[0]."\n";
					if((-s $url->[1]) >= (-s $url1->[1])){
						&do_statement("delete from product_gallery WHERE id=".$url1->[2]);
						&do_statement("delete from product_gallery_imported WHERE product_gallery_id=".$url1->[2]);																				
					}else{
						&do_statement("delete from product_gallery WHERE id=".$url->[2]);
						&do_statement("delete from product_gallery_imported WHERE product_gallery_id=".$url->[2]);																				
					}
					&do_statement('UPDATE product_gallery SET updated=now() WHERE product_id='.$product->[0]);
					$csv_report.=toCSV($product->[1]).','.toCSV($product->[2]).','.toCSV($url->[0]).','.toCSV($url1->[0])."\n";
				}
			}
			$i++;
		}
	}
}
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => 'Dublicate images report',
		'default_encoding'=>'utf8',
		'text_body' =>" Dublicates found: $dublicates_cnt",
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


sub compare_url_images{
	my ($img1_path,$img2_path)=@_;
	my $img1=Imager->new();
	my $img2=Imager->new();
	return '' if !(-s $img2_path) or !(-s $img1_path); 
	eval{$img1->read(file=>$img1_path)};
	eval{$img2->read(file=>$img2_path)};
	return '' if !$img1->getheight() or !$img2->getheight();	
	if($img1->getheight() > $img2->getheight() and $img1->getwidth() > $img2->getwidth()){
		my $tmp_img=scale_img($img1,$img2);
		if($tmp_img and (-e $img2_path)){
			`rm $img2_path`;
			if($tmp_img->write(file=>$img2_path)){
				return  cmp_images($img1_path,$img2_path)
			}else{
				return '';
			};
		}else{
			return '';
		}
	}elsif($img2->getheight() > $img1->getheight() and $img2->getwidth() > $img1->getwidth()){
		my $tmp_img=scale_img($img2,$img1);
		if($tmp_img and (-e $img1_path)){
			`rm $img1_path`;
			if($tmp_img->write(file=>$img1_path)){
				return cmp_images($img1_path,$img2_path);
			}else{
				return '';
			}
		}else{
			return '';
		}
		
	}elsif($img2->getheight() == $img1->getheight() and $img2->getwidth() == $img1->getwidth()){
		return cmp_images($img1_path,$img2_path);
	}else{
		return ''; # we can't compare these images
	}
}

sub cmp_images{
	my ($file1,$file2)=@_;
	my($cmp) = Image::Compare->new();
	$cmp->set_image1(
	     img  => $file1,
	 );
	 $cmp->set_image2(
	     img  => $file2,
	 );
	 $cmp->set_method(
	     method => &Image::Compare::THRESHOLD,
	     args   => 200,
	 );
	return eval{$cmp->compare()};	
}

sub scale_img{
	my ($sample_img,$scaled_img)=@_;
	my ($width,$height)=($sample_img->getwidth(),$sample_img->getheight());
	my $tmp_scaled=$scaled_img->scale(xpixels=>$width);	
	if($tmp_scaled->getheight() == $height){# $sample_img and $scaled_img have propotional dimensions 
		return $tmp_scaled; 	
	}else{
		return '';
	}
}

print "\n---------->".(Time::HiRes::time()-$time_start);

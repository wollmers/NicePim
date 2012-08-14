#!/usr/bin/perl
#use lib '/home/alexey/icecat/bo/trunk/lib';
use lib '/home/pim/lib';
use Data::Dumper;
use atomsql;
use atomlog;
use atomcfg;
use Time::HiRes;
use utf8;
use process_manager;
use atom_util;
use atom_mail;
use HTML::Entities;

my $eans_invalid=&do_query('SELECT count(*) FROM product_ean_codes WHERE length(ean_code)<13')->[0][0];
my $eans_big=&do_query('SELECT count(*) FROM product_ean_codes WHERE length(ean_code)>13')->[0][0];
if($eans_invalid or $eans_big){
	my $report="Small eans: $eans_invalid\n Big eans: $eans_big";
	print $report;
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => 'invalid eans found',
		'default_encoding'=>'utf8',
		'html_body' => $report
		};
	&complex_sendmail($mail);
	
}else{
	print 'OK';
}

1;
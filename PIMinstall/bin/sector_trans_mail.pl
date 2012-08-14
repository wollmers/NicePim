#!/usr/bin/perl
use lib "/home/pim/lib";
use lib "/home/alex/icecat/bo/big_tasks/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use strict;
use atomsql;
use atom_html;
use POSIX;
use XML::XPath;
use atom_mail;
use atomcfg;

my $time_start = Time::HiRes::time();

my $sectors=&do_query('SELECT sector_id FROM sector');
my $report_txt='';

	my $langs=&do_query("SELECT l.langid,l.short_code FROM  language l  						  
						 WHERE l.published='Y' ORDER BY l.langid");
foreach my $sector (@$sectors){
	my $no_empty_lang;
	my $empty_langs='';
	foreach my $lang (@$langs){
		my $lang_name=&do_query("SELECT name FROM sector_name WHERE sector_id=$sector->[0] AND langid=".$lang->[0])->[0][0];
		if($lang_name and !$no_empty_lang){
			$no_empty_lang=$lang_name;
		}elsif(!$lang_name){
			$empty_langs.=', '.$lang->[1];
		}
	}
	if($empty_langs){
		$empty_langs=~s/, $//;
		if(!$no_empty_lang){
			$no_empty_lang='Empty name';
		}
		$report_txt.="This sector '$no_empty_lang' has not following transalations: ".$empty_langs."\n";
	}
}
if($report_txt){
	my $mail = {
		#'to' => 'karina_minano@icecat.biz, alexey@bintime.com, dima@icecat.biz',
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Untranslated sector names have been found ",
		'default_encoding'=>'utf8',
		'text_body' => $report_txt,
		#'attachment_name' => $file_name.'.zip',
		#'attachment_content_type' => 'application/zip',
		#'attachment_body' => $gziped,
		};
	print $report_txt;
	&simple_sendmail($mail);
}
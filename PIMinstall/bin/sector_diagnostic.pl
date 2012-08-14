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


############# MERGE SECTORS BY the same ENGLISH name  ##############
my $merge_report;
my $dubl_names=&do_query("SELECT sn.name,count(sn.sector_name_id) as cnt FROM sector s 
			  JOIN sector_name sn ON s.sector_id=sn.sector_id AND sn.langid=1 
			  WHERE sn.name!='' GROUP BY sn.name HAVING cnt>1");
foreach my $dubl_name (@$dubl_names){
	my $dubl_sectors=&do_query('SELECT sector_id FROM sector_name WHERE langid=1 and  name='.str_sqlize($dubl_name->[0]));
	my @sector_prio;
	# find the best described sector	
	foreach my $dubl_sector (@$dubl_sectors){
		my $trans_cnt=&do_query('SELECT count(*) FROM sector_name WHERE sector_id='.$dubl_sector->[0]);
		push(@sector_prio,{'sector_id'=>$dubl_sector->[0],'trans_count'=>$trans_cnt->[0][0]});
	}
	my @sector_prio_sort=sort {$b->{'trans_count'}<=>$a->{'trans_count'}} @sector_prio;
	my $given_sector=shift(@sector_prio_sort);
	my @sector_ids=map {$_->{'sector_id'}} @sector_prio_sort;
	my $sector_cnt=join(',',@sector_ids);
	#$merge_report.="Name: '$dubl_name->[0]' Going to merge the same sector_ids $sector_cnt  into $given_sector->{'sector_id'}\n";
	$merge_report.="Name '$dubl_name->[0]'. Going to merge the same sector_ids $sector_cnt  into $given_sector->{'sector_id'}\n";
	foreach my $del_sector (@sector_prio_sort){
		do_statement("UPDATE contact SET sector_id = $given_sector->{'sector_id'} WHERE sector_id = " . $del_sector->{'sector_id'} );
		if(!&do_query('SELECT count(*) FROM contact WHERE sector_id='.$del_sector->{'sector_id'})->[0][0]){
			&delete_sector($del_sector->{'sector_id'});
		}
	}
	
}
################## REMOVE sectors with empty translations #################
my $others_sector_id=&do_query('SELECT sector_id FROM sector_name WHERE name=\'Other\' and langid=1 ')->[0][0];
if(!$others_sector_id){
	my $mail = {
		'to' => 'alexey@bintime.com, dima@icecat.biz',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Sector 'Other' is default replacement for empty sector. But IT WAS NOT FOUND!!!!!!!!!",
		'default_encoding'=>'utf8',
		'text_body' => 'Panic!!! Panic!!! Panic!!! Panic!!!',
		};
	&simple_sendmail($mail);	
}else{
	my $empty_eng_sectors=&do_query("SELECT sector_id FROM sector_name WHERE trim(name)='' and langid=1");
	foreach my $empty_ector (@$empty_eng_sectors){
		my $all_transl=&do_query('SELECT name FROM sector_name WHERE sector_id='.$empty_ector->[0]);
		my $all_empty=1;
		foreach my $empty_name (@$all_transl){
			if(trimAll($empty_name->[0])){
				$all_empty=0;
				last;	
			}
		}
		if($all_empty){
			do_statement("UPDATE contact SET sector_id = $others_sector_id WHERE sector_id = $empty_ector->[0]");
			&delete_sector($empty_ector->[0]);
			$merge_report.="Delete empty sector id: $empty_ector->[0]\n";
		} 
	}
	
}


if($merge_report){
	my $mail = {
		'to' => 'alexey@bintime.com, dima@icecat.biz',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Sector merge report ",
		'default_encoding'=>'utf8',
		'text_body' => $merge_report,
		};
	print $merge_report;
	&simple_sendmail($mail);
}else{
	#my $mail = {
	#	'to' => 'alexey@bintime.com, dima@icecat.biz',
	#	'from' =>  $atomcfg{'mail_from'},
	#	'subject' => "Sector merge report ",
	#	'default_encoding'=>'utf8',
	#	'text_body' => 'Nothing to merge',
	#	};
	#&simple_sendmail($mail);	
}
sub trimAll{
	my $value=shift;
	$value=~s/[\n\t\s\r]+//gs;
	return $value;
}

sub delete_sector {
    my $sector_id = shift;
    do_statement('DELETE FROM sector WHERE sector_id = ' . $sector_id);
    do_statement('DELETE FROM sector_name WHERE sector_id = ' . $sector_id);
}

print "\n---------->>>>>>>>>>>>>>>>>".(Time::HiRes::time()-$time_start);
1;

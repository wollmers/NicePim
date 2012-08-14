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

if (&get_running_perl_processes_number('errors_regular_report.pl') != 1)  {
	print "already running. exit!";
	exit;
}
while(&get_running_perl_processes_number('xml_generation_checker.pl')!=0){
	sleep(15);
}
	my $hash={};
	my $pers_data_path=$atomcfg{'www_path'}.'../bin/testing/xml_generation_checker.data';
	my $data_open=open(PERS_DATA,'<',$pers_data_path);# persistent data
	if($data_open){# load stored data
		my $persDataStr=join("",<PERS_DATA>);
		$persDataStr=~s/\$VAR1[\s]*=//;
		$hash=eval($persDataStr);
	}
	close(PERS_DATA);
	
	my $report_html;
	if(ref ($hash->{'aggregated_err_report'}) eq 'HASH' ){
		my $style='style="border: 1px solid gray; font-size: 10pt"';
		foreach my $section (keys(%{$hash->{'aggregated_err_report'}})){
			print $section."\n";
			$report_html.="<br/><table $style>\n<caption style=\"font-size: 15pt; width:300px\">$section</caption>\n<tr><th>File</th><th>Error message</th></tr>\n";
			if(ref($hash->{'aggregated_err_report'}->{$section}) ne 'ARRAY'){
				email('This section of report errors_regular_report.pl is wrong !!! '.$section);
				next;
			};
			foreach my $err_item (@{$hash->{'aggregated_err_report'}->{$section}}){
				$report_html.="<tr><td $style>$err_item->{'file'}</td><td $style>$err_item->{'err_msg'}</td></tr>\n";
			}
			$hash->{'aggregated_err_report'}->{$section}=[];
			$report_html.='</table>';		
		}
		
	}else{
		email('report errors_regular_report.pl is not working !!! ');
	}
	my $loged_erros=`sed -n '/<stack_trace>/,/<\\/stack_trace>/p' '$atomcfg{'logfile'}'`;
	my @errs=$loged_erros=~/<stack_trace>(.+?)<\/stack_trace>/gs;
	if(scalar(@errs)>0){	
			$report_html.=create_sql_err_report($hash,\@errs);
	}
	
	&email($report_html,'Regular error report');
	
	open(PERS_DATA,'>',$pers_data_path);
	print PERS_DATA Dumper($hash);	
	close(PERS_DATA);

sub email{
	my ($report,$subject)=@_;
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => $subject,
		'default_encoding'=>'utf8',
		'html_body' => $report
		#'attachment_name' => $file_name.'.zip',
		#'attachment_content_type' => 'application/zip',
		#'attachment_body' => $gziped,
		};
	&complex_sendmail($mail);	
}

sub create_sql_err_report{
	my ($hash,$errs_arr)=@_;
	my $sql_err_hash={}; 
	foreach my $err (@$errs_arr){
		my $aaa=1;
		$err=~s/^.+(atomsql::do_statement|atomsql::do_query)/$1/gs;
		$err=~/^((atomsql::do_statement|atomsql::do_query)[^\n]+\n)/gs;
		my $sql_err=$1;
		if($sql_err=~/'(.+)'/g){
			$sql_err=$1;
		}else{
			next;
		}
		my @err_key_arr=($err=~/(called\sat[^\n]+)\n/gs);
		my $err_key=$sql_err."\n".join("\n",@err_key_arr);
		$err=&encode_entities($err);
		$err=~s/\n/<br>\n/gs;
		if($sql_err_hash->{$err_key}){
			$sql_err_hash->{$err_key}->{'cnt'}++;
			$sql_err_hash->{$err_key}->{'sql'}=$sql_err;
			$sql_err_hash->{$err_key}->{'err'}=$err;
		}else{
			$sql_err_hash->{$err_key}={'cnt'=>1,'sql'=>$sql_err,'err'=>$err};
		}		
	}
	my $style='style="border: 1px solid gray; font-size: 10pt"';
	my $html_report="<table><caption style=\"font-size: 15pt; width:300px\">SQL errors</caption>
							<tr><th $style>SQL</th>
							<th $style>#</th>
							<th $style>call stack</th></tr>";
							
	foreach my $err_key (keys %$sql_err_hash){		
		$html_report.="<tr><td $style>".&encode_entities($sql_err_hash->{$err_key}->{'sql'})."</td><td $style>".
								 &encode_entities($sql_err_hash->{$err_key}->{'cnt'})."</td><td $style>".
								 $sql_err_hash->{$err_key}->{'err'}.'</td></tr>';
	}
	$html_report.='</table>';
	return $html_report;
}	

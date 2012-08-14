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
use File::stat;
use atom_mail;
use XML::LibXML;
use XML::SAX::ParserFactory;
use XML::Validator::Schema;
use XML::SAX::ExpatXS ;
use HTML::Entities;

if (&get_running_perl_processes_number('xml_generation_checker.pl') != 1)  {
	print "already running. exit!";
	exit;
}
while(&get_running_perl_processes_number('errors_regular_report.pl')!=0){
	sleep(15);
}

my $pers_data_path=$atomcfg{'www_path'}.'../bin/testing/xml_generation_checker.data';
my $hash={};
my $data_open=open(PERS_DATA,'<',$pers_data_path);# persistent data
if($data_open){# load stored data
	my $persDataStr=join("",<PERS_DATA>);
	$hash=eval($persDataStr);
}

### GENERATE_XML check
$hash=handle_files_check($hash,'generate_xml',[$atomcfg{'xml_path'}.'level4/'],'check_index_files');

### DUMP_ALL_REFS check
$hash=handle_files_check($hash,'dump_all_refs',[$atomcfg{'xml_path'}.'level4/refs'],'check_refs_files');

### EXPORT_URLS check
$hash=handle_files_check($hash,'export_urls',[$atomcfg{'xml_export_path'},$atomcfg{'xml_export_path'}.'freeurls/'],'check_export_urls_files');


### EXPORT_SPONSOR_REPOSITORIES check
my $sponsors = &get_rows('supplier',"(is_sponsor='Y' and user_id!=0) or (public_login != '' and public_login is not null)");
my @sponsors_dirs=map {$atomcfg{'xml_path'}.'vendor.int/'.string2fat_name(lc($_->{'name'})).'/'} @$sponsors;
$hash=handle_files_check($hash,'generate_xml_vendors',\@sponsors_dirs,'check_index_files');

### GENERATE_XML check
$hash=handle_files_check($hash,'generate_xml_free',[$atomcfg{'xml_path'}.'freexml.int/'],'check_index_files');


### update_product_xml_chunk  check
check_process_queue($hash);

### check logs for SQL ERRORS

my $last_lines=`tail --lines=1000 $atomcfg{'logfile'}`;
my @errs=$last_lines=~/<stack_trace>(.+?)<\/stack_trace>/gs;
if(scalar(@errs)>0){	
	&start_panic(create_sql_err_report($hash,\@errs),'SQL errs found');
}


close(PERS_DATA);
open(PERS_DATA,'>',$pers_data_path);
print PERS_DATA Dumper($hash);
close(PERS_DATA);
print "\ndone";
####################### SUUUUUUUUUUUUUUUUBS  #################

sub check_process_queue{
	my $hash=shift;
	my $current_date=&do_query('SELECT unix_timestamp(date(now()))')->[0][0];
	my $obsolete_items=&do_query('SELECT product_id FROM process_queue WHERE queued_date<(unix_timestamp() - 15*24*3600) ORDER BY queued_date LIMIT 10');
	if(scalar(@$obsolete_items)>0){# obsolete items found in the queue
		my $err_report;
		my $obsolete_list=[];
		foreach my $obsolete_item (@$obsolete_items){
				if($hash->{'update_product_xml_chunk'}->{'obsolete_list'} and !scalar(grep(/$obsolete_item->[0]/,@{$hash->{'update_product_xml_chunk'}->{'obsolete_list'}}))){# we havn't mailed about it before
					$err_report.="OBSOLETE product_id($obsolete_item->[0]) was found in the queue \n<br/>";
					add2aggregated_report($hash,'Product XML','OBSOLETE product_id($obsolete_item->[0]) was found in the queue !!!','');
				}elsif(!$hash->{'update_product_xml_chunk'}->{'obsolete_list'}){
					$err_report.="OBSOLETE product_id($obsolete_item->[0]) was found in the queue \n<br/>";
					add2aggregated_report($hash,'Product XML','OBSOLETE product_id($obsolete_item->[0]) was found in the queue !!!','');
				}
				push(@$obsolete_list,$obsolete_item->[0]);
		} 
		$hash->{'update_product_xml_chunk'}->{'obsolete_list'}=$obsolete_list;
		if($err_report){
			start_panic($err_report,'Queue check');
		}
	}
	my $last_processed=&do_query("SELECT product_id,langid_list FROM process_queue pq JOIN product p USING(product_id) 
								  JOIN users u ON p.user_id=u.user_id JOIN user_group_measure_map gm ON u.user_group=gm.user_group
								  WHERE pq.started_date!=0 and pq.finished_date!=0 and process_status_id=30
								  and p.publish!='N'  and p.public!='L' and gm.measure in ('ICECAT','SUPPLIER')
								  ORDER BY pq.finished_date DESC limit 3");
	my $xml_obj = XML::LibXML->new;
	my $langs=&do_query('SELECT langid,short_code FROM language WHERE published=\'Y\' ');
	my %lang_map=map {$_->[0]=>$_->[1]} @{$langs};	 
	
	$xml_obj->validation(1);		
	if($last_processed->[0]){# check english
		my @lang_ids=split(',',$last_processed->[0][1]);		
		if(scalar(@lang_ids)<1){
			check_product_xml($hash,'EN',$last_processed->[0][0],$xml_obj,$validator);
		}else{
			for(my $i=0;$i<3;$i++){
				if($lang_map{$lang_ids[$i]}){
					check_product_xml($hash,uc($lang_map{$lang_ids[$i]}),$last_processed->[0][0],$xml_obj,$validator);
				}
			}		
		}
	}
	if($last_processed->[1]){# check NL
		my @lang_ids=split(',',$last_processed->[1][1]);
		if(scalar(@lang_ids)<1){
			check_product_xml($hash,'NL',$last_processed->[1][0],$xml_obj,$validator);
		}else{
			for(my $i=0;$i<3;$i++){
				if($lang_map{$lang_ids[$i]}){
					check_product_xml($hash,uc($lang_map{$lang_ids[$i]}),$last_processed->[1][0],$xml_obj,$validator);
				}
			}		
		}
	}	
	if($last_processed->[2]){# check RU
		my @lang_ids=split(',',$last_processed->[2][1]);
		if(scalar(@lang_ids)<1){
			check_product_xml($hash,'RU',$last_processed->[2][0],$xml_obj,$validator);
		}else{
			for(my $i=0;$i<3;$i++){
				if($lang_map{$lang_ids[$i]}){
					check_product_xml($hash,uc($lang_map{$lang_ids[$i]}),$last_processed->[2][0],$xml_obj,$validator);
				}
			}
		}
	}		
	return $hash;
}

sub check_product_xml{
	my ($hash,$lang,$product_id,$xml_obj,$validator)=@_;
	my $xml_path=$atomcfg{'xml_path'}."level4/$lang/".&get_smart_path($product_id).'/'.$product_id.'.xml.gz';
	if(!(-s $xml_path)){
		&start_panic("This file is empty $xml_path or does not exists!!!\n<br/>",'Queue check');
		add2aggregated_report($hash,'Product XML','This file is empty or does not exists',$xml_path);
		return '';
	}
	my $unziped_xml=$xml_path;
	$unziped_xml=~s/.gz$//;
	`gzip -d -c $xml_path > $unziped_xml`;
	my $tags_count=`grep -c '</' $unziped_xml`;
	$tags_count=&trim($tags_count);
	if($tags_count>2000){# do not validate very big XMLs
		`rm $unziped_xml` if -e $unziped_xml;
		return 1;
	}
	 if(!eval{$xml_obj->parse_file($unziped_xml)}){
	 	&start_panic("This file $xml_path is not validated by DTD\n<br/>",'Queue check');
	 	add2aggregated_report($hash,'Product XML','This file is not validated by DTD',$xml_path);	 	
	 }
	 $validator = eval{XML::Validator::Schema->new(file => $atomcfg{'www_path'}.'xsd/ICECAT-interface_response.xsd')};
	 if(!$validator){
		start_panic("CAN't parse the Schema!!!!!! ".$atomcfg{'www_path'}.'xsd/ICECAT-interface_response.xsd','Queue check. CANt parse the schema');
		return '';
	 }	 
	 if(!eval{XML::SAX::ExpatXS->new(Handler => $validator)->parse_uri($unziped_xml)}){
	 	&start_panic("This file $xml_path is not validated by XSD\n<br/>",'Queue check');
	 	add2aggregated_report($hash,'Product XML','This file is not validated by XSD',$xml_path);
	 }
	`rm $unziped_xml` if -e $unziped_xml;
}

sub handle_files_check{
	my ($hash,$script,$dirs,$sub)=@_;
	my $genarte_xml_process=&get_running_perl_processes_number($script);
	if($genarte_xml_process and $hash->{$script}->{'detected_time'}){#generate xml was detected before and it is still running 
		#do nothing
	}elsif($genarte_xml_process and !$hash->{$script}->{'detected_time'}){#generate_xml was finished before and now it is here again
		$hash->{$script}->{'detected_time'}=time();
	}elsif(!$genarte_xml_process and $hash->{$script}->{'detected_time'}){#genarate xml was detected before and now it finished it's job. Lets start checking what was done 
		&{$sub}($hash,$script,$dirs);
		$hash->{$script}->{'detected_time'}=undef;
	}elsif(!$genarte_xml_process and !$hash->{$script}->{'detected_time'}){#nobody starts generate_xml yet
		#do nothing
	};
	return $hash;
}

sub check_index_files{
	my ($hash,$script,$dirs)=@_;
	my $files=['daily.index.csv','daily.index.xml','files.index.csv','files.index.xml',
			   'nobody.index.csv','nobody.index.xml','on_market.index.csv','on_market.index.xml',
			   ];
			   #'supplier_mapping.xml'
			   #'product_mapping.xml',
	my $langs=&do_query("SELECT short_code FROM language WHERE published='Y'");
	my $err_report;
	foreach my $dir (@$dirs){
		foreach my $lang (@$langs){
			foreach my $file(@$files){
				my $file_path=$dir.$lang->[0].'/'.$file;
				$err_report.=check_file($hash,$script,$file_path,'Index generation');
			}
		}
	}	
	if($err_report){
		start_panic($err_report,'Generate index files');
	}
}

sub check_refs_files{
	my ($hash,$script,$dirs)=@_;
	my $files=['CategoriesList.xml.gz','CategoryFeaturesList.xml.gz','DistributorList.xml.gz',
			   'FeaturesList.xml.gz','FeatureValuesVocabularyList.xml.gz','LanguageList.xml.gz',
			   'MeasuresList.xml.gz','SupplierProductFamiliesListRequest.xml.gz','SuppliersList.xml.gz'];
	my $err_report;
	foreach my $dir (@$dirs){
		foreach my $file(@$files){
			my $file_path=$dir.'/'.$file;
			$err_report.=check_file($hash,$script,$file_path,'Refs generation');
		}
	}
	$err_report.=check_file($hash,$script,$atomcfg{'xml_path'}.'level4/refs.xml','Refs generation');
	if($err_report){
		start_panic($err_report,'Generate refs files');
	}
}

sub check_export_urls_files{
	my ($hash,$script,$dirs)=@_;
	my $common_files=['daily.export_urls_rich.txt','daily.export_urls_rich.xml','daily.export_urls.txt','export_suppliers.txt','export_urls_rich.txt','export_urls_rich.xml','export_urls.txt','on_market.export_urls_rich.txt','on_market.export_urls_rich.xml','on_market.export_urls.txt'];
	my $full_repo_files=['daily.export_urls.xml','export_urls.xml','on_market.export_urls.xml'];
	my $err_report;	
	foreach my $dir (@$dirs){
		my $files;
		if($dir=~/freeurls\/$/){
			$files=@$common_files;
		}else{
			$files=[@$common_files,@$full_repo_files];
		}
		foreach my $file(@$files){
			my $file_path=$dir.$file;
			$err_report.=check_file($hash,$script,$file_path,'export URLs generation');
		}
	}
	if($err_report){
		start_panic($err_report,'Generate refs files');
	}
}


sub check_file{
	my ($hash,$script,$file_path,$msg)=@_;

	my $file_stat=stat($file_path);
	if($file_path!~/daily/ and $file_path!~/vendor/ and $file_path!~/Language/i and $file_path!~/Distributor/i  and (-s $file_path) < 50000){
		$err_report.=$msg.': THIS file is too small '.(-s $file_path).' bytes '.$file_path."\n<br/>";
		add2aggregated_report($hash,$msg,'THIS file is too small '.(-s $file_path).' bytes ',$file_path);		
	}
	my $err_report='';
	if(!$file_stat){
		$err_report.=$msg.': this file does not exists '.$file_path."\n<br/>";
		add2aggregated_report($hash,$msg,'this file does not exists',$file_path);
		return $err_report;
	}
	if(!$file_stat->size()){
		$err_report.=$msg.': this file is empty '.$file_path."\n<br/>";
		add2aggregated_report($hash,$msg,'this file is empty',$file_path);
		return $err_report;
	}
	if($file_path=~/daily/){
		my @file_date_part =localtime($file_stat->mtime());
		my @detected_date_part =localtime($hash->{$script}->{'detected_time'});
		my $date_detected=$detected_date_part[3].$detected_date_part[4].$detected_date_part[5];
		$date_detected=$date_detected*1;
		my $date_file=$file_date_part[3].$file_date_part[4].$file_date_part[5];
		$date_file=$date_file*1;
		if($date_detected>$date_file){
			$err_report.=$msg.': This vital file was not renewed '.$file_path."\n<br/>";
			add2aggregated_report($hash,$msg,'This vital file was not renewed',$file_path);
		};	
	}else{
		if($file_stat->mtime()<($hash->{$script}->{'detected_time'}-(10*60))){
			$err_report.=$msg.': This vital file was not renewed '.$file_path."\n<br/>";
			add2aggregated_report($hash,$msg,'This vital file was not renewed',$file_path);
		}
	}
	return $err_report; 	
}

sub add2aggregated_report{
	my ($hash,$section,$err_text,$file)=@_;
	#$cnt,$err_key - for sql errors
	if(ref($hash->{'aggregated_err_report'}) ne 'HASH'){
		$hash->{'aggregated_err_report'}={};
	}
	if(ref($hash->{'aggregated_err_report'}->{$section}) ne 'ARRAY'){
		$hash->{$section}=[];
	}
	push(@{$hash->{'aggregated_err_report'}->{$section}},{'err_msg'=>$err_text,'file'=>$file});
	return $hash;
}

sub create_sql_err_report{
	my ($hash,$errs_arr)=@_;
	my $sql_err_hash={}; 
	foreach my $err (@$errs_arr){
		$err=~s/^.+(atomsql::do_statement|atomsql::do_query)/$1/gs;
		$err=~/^((atomsql::do_statement|atomsql::do_query)[^\n]+\n)/gs;
		my $sql_err;
		if($err=~/<err_text>(.+?)<\/err_text>/gs){
			$sql_err=$1;
		}else{
			next;
		};
		my @err_key_arr=($err=~/(called\sat[^\n]+)\n/gs);
		my $err_key=$sql_err."\n".join("\n",@err_key_arr);
		$err=&encode_entities($err);
		$err=~s/\n/<br>\n/gs;
		$err=~s/&lt;err_text&gt;(.+?)&lt;\/err_text&gt;/<b>$1<\/b>/gs;
		if($sql_err_hash->{$err_key}){
			$sql_err_hash->{$err_key}->{'cnt'}++;
			$sql_err_hash->{$err_key}->{'sql'}=$sql_err;
			$sql_err_hash->{$err_key}->{'err'}=$err;
		}else{
			$sql_err_hash->{$err_key}={'cnt'=>1,'sql'=>$sql_err,'err'=>$err};
		}		
	}	
	my $style='style="border: 1px solid gray; font-size: 10pt"';
	my $html_report="<table>
							<tr><th $style>Error</th>
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

sub start_panic{
	my ($report,$subject)=@_;
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Alarm!!! ".$subject,
		'default_encoding'=>'utf8',
		'html_body' => $report
		#'attachment_name' => $file_name.'.zip',
		#'attachment_content_type' => 'application/zip',
		#'attachment_body' => $gziped,
		};
	print $report;	
	&complex_sendmail($mail);	
}

exit();

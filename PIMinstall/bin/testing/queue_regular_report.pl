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

if (&get_running_perl_processes_number('queue_regular_report.pl') != 1)  {
	print "already running. exit!";
	exit;
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
	if(ref($hash->{'avg_queue_wait'}) eq 'ARRAY'){# bin/testing/queue_report will report this data and empties the array
		#push (@{$hash->{'avg_queue_wait'}},{'from'=>$from,'to'=>$to,'avg'=>$avg_wait});
		my $report_str="Average waiting time\n<br/>";
		foreach my $item (@{$hash->{'avg_queue_wait'}}){
			$report_str.="From $item->{'from'} To $item->{'to'}  Average waiting time <b>".seconds_to_days_hours_minutes($item->{'avg'})." sec</b>\n<br/>"; 	
		}
		$report_str.="<br/>\nAverage processing speed time\n<br/>";
		foreach my $item (@{$hash->{'avg_queue_speed'}}){
			$report_str.="From $item->{'from'} To $item->{'to'}  Average speed <b>".seconds_to_days_hours_minutes($item->{'avg'})."</b> sec \n<br/>"; 	
		}
		print $report_str;
	my $mail = {
		#'to' => $atomcfg{'bugreport_email'},
		'to' => 'alexey@bintime.com',
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Average queue waiting and speed report FROM $hash->{'avg_queue_wait'}->[0]->{'from'} TO ".$hash->{'avg_queue_wait'}->[scalar(@{$hash->{'avg_queue_wait'}})-1]->{'to'},
		'default_encoding'=>'utf8',
		'html_body' => $report_str
		#'attachment_name' => $file_name.'.zip',
		#'attachment_content_type' => 'application/zip',
		#'attachment_body' => $gziped,
		};
	&complex_sendmail($mail);
	}
	
	$hash->{'avg_queue_wait'}=[];			
	$hash->{'avg_queue_speed'}=[];
	open(PERS_DATA,'>',$pers_data_path);
	print PERS_DATA Dumper($hash);	
	close(PERS_DATA);

sub seconds_to_days_hours_minutes {
        my ($s) = @_;

        return "N/A" if ($s<0);

        my ($old_m, $m, $h, $d, $out);

        if ($s >= 60) {
                $m = int($s / 60);
                $s %= 60;
                if ($m >= 60) {
                        $h = int($m / 60);
                        $m %= 60;
                        if ($h >= 24) {
                                $d = int($h / 24);
                                $h %= 24;
                                $out .= sprintf("%.f",$d) . " day" . ($d>=2?"s":"") . " " ;
                        }
                        $out .= sprintf("%1.f",$h) . " h ";
                }
                else {
                        $out .= "";
                }
                $out .= sprintf("%2.f",$m) . " min ";
        }
        else {
                $out .= "";
        }
        $out .= sprintf("%2.f",$s);

        return $out;
} # sub seconds_to_days_hours_minutes
	
	

1;	

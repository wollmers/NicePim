#!/usr/bin/perl

use strict;

#use lib '/home/sergeyka/pim/trunk/lib';
use lib '/home/pim/lib';

use atomsql;
use atomcfg;
use atom_mail;
use data_management;
use icecat_util;
use atomlog;
use atom_misc;
use atom_util;
use process_manager;

use HTTP::Request;
use LWP::UserAgent;
use Image::ExifTool;

use Data::Dumper;

my $email = 'dima@icecat.biz, alexey@bintime.com';
#my $email = "dima\@icecat.biz, martijn\@icecat.biz, editor\@icecat.biz";

my $wrong = 0;
my $domain="objects.icecat.biz";
#my $domain="icecat.office";

my $f_list = &do_query("select id,keep_as_url,link,product_id,langid,short_descr,size,content_type 
						from product_multimedia_object 
						where content_type <> 'text/html' and 
							  content_type <> 'application/x-zip-compressed' and 
							  content_type <> 'text/plain' and 
							  content_type <> 'application/download'");

my $fname = "media_validation.html";
open(TXT, "> /tmp/".$fname);
binmode(TXT,":utf8");

print TXT "<table border='1'>
		<tr>
		<th>id</th><th>product_id</th><th>URL</th><th>language</th><th>description</th>
		</tr>";

foreach my $file(@$f_list){
log_printf("file:".$file->[2]);	
	if($file->[1] == 0){
		my $path = $file->[2];
		$path =~s#^http://.*?\.?$domain/##i; 
		$path = $atomcfg{'www_path'}.$path;
		 
		if(-e $path){#our resource
			log_printf($path);
			my ($lang,$size);
			$lang = &do_query("select code from language where langid=".$file->[4])->[0][0];
			my $content_type=&trim(`file -i -b $path`);
			$size= -s $path;			
			if((!&compare_by_word($content_type,$file->[7]) and $content_type ne 'application/octet-stream') or $size!=$file->[6]){
				print TXT "<tr><td>".$file->[0]."</td><td>".$file->[3]."</td><td>".$file->[2]."</td><td>".$lang."</td>
						   <td>content types does not match each other(file: $content_type db: $file->[7])</td></tr>";
#				print $path." content types does not match each other(file: $content_type db: $file->[7]) \n";				
				$wrong = 1;
			}
		}else{# external resourse
			my $lang = &do_query("select code from language where langid=".$file->[4])->[0][0];
			# trying if it's external link
			my $req = new HTTP::Request HEAD => $file->[2];
			my $ua = new LWP::UserAgent;
			my $res = $ua->request($req);
			if($res->is_success){
				print "checked:".$file->[2]." status:wrong store_as_link\n";
				print TXT "<tr style='font-weight:bold; background-color:red;'><td>".$file->[0]."</td><td>status:wrong store_as_link</td><td>".$file->[2]."</td><td>".$lang."</td><td>this file is external, but is stored in database as internal</td></tr>";
			}else{
				print "checked:".$file->[2]." status:no file\n";
				print TXT "<tr><td>".$file->[0]."</td><td>".$file->[3]."</td><td>".$file->[2]."</td><td>".$lang."</td><td>url does not exists</td></tr>";
			}
			$wrong = 1;
		}
	}else{
		my $req = new HTTP::Request HEAD => $file->[2];
		my $ua = new LWP::UserAgent;
		my $res = $ua->request($req);
		my $lang = &do_query("select code from language where langid=".$file->[4])->[0][0];
		#print "checked:".$file->[2]." status:".($res->is_success and $res->{'_headers'}->{'content-type'} eq $file->[7]) ."\n";		
		if(!$res->is_success){
			print TXT "<tr><td>".$file->[0]."</td><td>".$file->[3]."</td><td>".$file->[2]."</td><td>".$lang.
					   "</td>url not exists<td></td></tr>";
			print "$file->[2] url not exists\n";
			$wrong = 1;			
		}elsif(!&compare_by_word($res->{'_headers'}->{'content-type'},$file->[7])){
			my $content_type=$res->{'_headers'}->{'content-type'};
			print TXT "<tr><td>".$file->[0]."</td><td>".$file->[3]."</td><td>".$file->[2]."</td><td>".$lang.
					   "</td><td>content types does not match each other(db: $file->[7],file: $content_type)</td></tr>";
			print "$file->[2] wrong content type\n";
			$wrong = 1;
		}
	}
}

close TXT;

my $cmd = "cd /tmp/ && /usr/bin/zip -r ".$fname.".zip ".$fname;
`$cmd`;
open(ZIP, "< /tmp/".$fname.".zip");
binmode(ZIP,":bytes");
my $zip = join('', <ZIP>);
close ZIP;
my $cmd = "/bin/rm -f /tmp/".$fname.".zip && /bin/rm -f /tmp/".$fname;
`$cmd`;

my $mail = {
	'to' => $email,
	'from' =>  $atomcfg{'mail_from'},
	'subject' => "media validation Report",
	'text_body' => "These files are absent or corrupted (see in attachment).",
	'attachment_name' => "MEDIAvalidation_report.zip",
	'attachment_content_type' => 'application/zip',
	'attachment_body' => $zip
	};

&complex_sendmail($mail) if($wrong);

sub compare_by_word{
	my($str1,$str2)=@_;
	$str1=lc($str1);
	$str2=lc($str2);
	$str1=~s/[^\w]+/,/gi;
	$str2=~s/[^\w]+/,/gi;		
	my @str1words=split(/[^\w]/,$str1);	
	my $str2words={map {$_=>$_} split(/[^\w]/,$str2)};
	foreach my $word (@str1words){
		if($str2words->{$word} and length($word)>2 ){#match found
			return 1;
		}
	}
	return undef;
}
  
  sub trim{
	  my $str = shift;
	  $str=~s/^\s*(.*?)\s*$/$1/;
	  $str=~s/^\n*(.*?)\n*$/$1/;
	  return $str;   	
  }

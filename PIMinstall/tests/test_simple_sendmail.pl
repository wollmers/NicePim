#!/usr/bin/perl

use lib "/home/alex/icecat/bo/trunk/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use atomcfg;
use icecat_import;
use strict;
use XML::XPath;
my $time_start = Time::HiRes::time();
use utf8;
#use atom_misc;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Message;
use thumbnail;
use Encode;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use XML::LibXML;
#use MIME::Base64;
use HTTP::Request;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTML::Entities;
use GD::Graph::lines;
use XML::SAX::ExpatXS;
use XML::Validator::Schema;
use icecat_import;
use icecat_util;
use GD::Image;
use atom_mail;

my $mail={
	'to'=>'alexey@bintime.com',
	'from'=>$atomcfg{'mail_from'},
	'reply_to'=>$atomcfg{'mail_from'},
	'subject'=>'test subject',
	'default_encoding'=>'utf8',
	'html_body'=>'<b>OKййй</b>'
};
$mail->{"subject"}=" text/html";
&simple_sendmail($mail);
$mail->{"subject"}=" text/plain";
$mail->{'text_body'}=$mail->{'html_body'};
$mail->{'html_body'}='';
&simple_sendmail($mail);
$mail->{'html_body'}=$mail->{'text_body'};
$mail->{'text_body'}='';

$mail->{"subject"}=" text/html and attachments";
open ZIP,'./test.zip' or die();
binmode ZIP;
my ($buf,$n,$zip); 
while (($n = read ZIP, $buf, 4) != 0) { 
	$zip .= $buf; 
}; 
close(ZIP);
$mail->{'attachment_body'}=$zip;
$mail->{'attachment_name'}="test.zip";
$mail->{'attachment_content_type'}="application/zip";

open XLS,'./text.xls' or die();
binmode XLS;
$buf='';
$n='';
my $xls; 
while (($n = read XLS, $buf, 4) != 0) { 
	$xls .= $buf; 
}; 
close(XLS);
$mail->{'attachment2_body'}=$xls;
$mail->{'attachment2_name'}="text.xls";
$mail->{'attachment2_content_type'}="application/ms-excel";

&simple_sendmail($mail);

$mail->{'subject'}='text/plain and attachment';
$mail->{'text_body'}=$mail->{'html_body'};
$mail->{'html_body'}='';

$mail->{'attachment_body'}='';
$mail->{'attachment_name'}='';
$mail->{'attachment_content_type'}='';

&simple_sendmail($mail);

print "\n---------->".(Time::HiRes::time()-$time_start);




exit;
			
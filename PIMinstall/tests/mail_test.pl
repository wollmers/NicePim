#!/usr/bin/perl


#use lib "/home/alexey/icecat/bo/lib";

use atom_mail;
use atomcfg;
my $mail={
#	'to'=>'alexey@bintime.com,matijsdejong@mac.com,mjong@magnafacta.nl,alexandr_kr@icecat.biz',
	'from'=>$atomcfg{'mail_from'},
	'reply_to'=>$atomcfg{'mail_from'},
	'subject'=>'test subject',
	'default_encoding'=>'utf8',
};


$mail->{"subject"}=" plain/text and attachments";
$mail->{'attachment_name'}="zip.zip";
$mail->{'attachment_content_type'}="application/zip";
open ZIP,'./test.zip' or die();
binmode ZIP;
my ($buf,$n,$zip); 
while (($n = read ZIP, $buf, 4) != 0) { 
	$zip .= $buf; 
}; 
close(ZIP);
$mail->{'attachment_body'}=$zip;

open IMG,'./logo.gif' or die();
binmode IMG;
my ($buf1,$n1,$img); 
while (($n1 = read IMG, $buf1, 4) != 0) { 
	$img .= $buf1; 
}; 
close(IMG);
#$mail->{'attachment2_name'}=i"image.gif";
#$mail->{'attachment2_content_type'}="image/gif";
#$mail->{'attachment2_body'}=$img;


delete $mail->{'text_body'};

$mail->{'html_body'}='<b>Hello Matijs</b><br/>This is test email. It was sent to you by ICEcat team just  to verify what it is displayed  correctly <br/>
					  <b>some text</b><br/>&nbsp;</div>';
$mail->{"subject"}="Test message from icecat team";
print "\tsending text/html with emmbeded image and attachments\n";
simple_sendmail($mail);



print "\nOK\n";  

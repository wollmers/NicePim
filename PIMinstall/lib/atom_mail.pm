package atom_mail;

#$Id: atom_mail.pm 3605 2010-12-21 14:46:37Z alexey $

use strict;

$| = 1;

use atomlog;
use atomsql;
use atomcfg;

use Socket;
use MIME::Base64 qw(encode_base64);
use Encode qw(encode decode);

use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&sendmail &complex_sendmail &simple_sendmail &errmail);
}

my ($fromuser, $fromsmtp, $touser, $tosmtp, $subject, $msgbody) = @_;

sub sendmail
{
	my ($msg,$to,$from,$subj,$reply_to) = @_;
	
	log_printf("sendmail(to = $to, from = $from, subj = $subj)");
	
	if ($to eq '' || $from eq '') {
		log_printf("SENDMAIL: to & from are MANDATORY");
		return;
	}

	if ($subj ne '') { $msg = "Subject: $subj\n\n$msg"; }
	
	# the best way is to use MTA
	if ($atomcfg{MTA_cmdline}) {
		local (*FM);
		open (FM, "|".$atomcfg{MTA_cmdline}) || error_printf("Could not start MTA program \'".$atomcfg{MTA_cmdline}."\'");
		binmode(FM,":utf8");
		print FM "To: $to\n";
		print FM "From: $from\n";
		if ($reply_to){	print FM "Reply-To: $reply_to\n";	}
		print FM $msg;
		print FM "\n";
		close(FM);
		return;
	}
}

sub errmail{
	my ($to,$msg)=@_;
	my $mail = {
			'to' => $to,
			'from' =>  $atomcfg{'mail_from'},
			'subject' => "Error!!! ".$msg,
			'default_encoding'=>'utf8',
			'text_body' => $msg,
			};
	simple_sendmail($mail);
}

sub simple_sendmail{
	my ($mail) = @_;
	my $default_mode = ':utf8';
	my $default_encoding = 'UTF-8';
	my $rand = atom_misc::make_code(32);
	my $size=0;
	if ($mail->{'default_encoding'} ne 'utf8') { # always set to latin1
#	if (($mail->{'subject'} =~ /Report on/i) || ($mail->{'to'} =~ /zoom\.com/i)) { # switch to latin1-mode for 'Report on...' and ...@zoom.com mails
		$default_mode = ':bytes';
		$default_encoding = 'ISO-8859-1';
	}
	my $attach_cnt=0;
	for my $suffix ('',2,3,4,5,6,7) {
		if ($mail->{'attachment'.$suffix.'_name'}) {
			$attach_cnt++;
		}
	}
	
	open (MAIL, "|".$atomcfg{MTA_cmdline}) or log_printf("can't open mailing program ".$atomcfg{MTA_cmdline});
	
	#open (MAIL, ">/home/alex/icecat/bo/trunk/www/img/tmp/mail.txt") or log_printf("can't open mailing program ".$atomcfg{MTA_cmdline});
	
	binmode(MAIL, $default_mode);
	print MAIL "To: ".$mail->{'to'}."\n";
	if ($mail->{'bcc'}) {
		print MAIL "Bcc:".$mail->{'bcc'}."\n";
	}
	print MAIL "From: ".$mail->{'from'}."\n";
	print MAIL "Subject: ".$mail->{'subject'}."\n";
	print MAIL "MIME-version: 1\.0 \n";
	my $boundary=$rand;
	my $section_boundary='--'.$boundary;	
	if($mail->{'text_body'} and !$attach_cnt){
		print MAIL "Content-Type: text/plain; charset=".$default_encoding."\n";
		print MAIL $mail->{'text_body'};
		$size+=bytes::length($mail->{'text_body'});
	}elsif($mail->{'html_body'} and !$attach_cnt){
		print MAIL "Content-Type: text/html; charset=".$default_encoding."\n";
		print MAIL $mail->{'html_body'};
		$size+=bytes::length($mail->{'html_body'});
	}elsif(($mail->{'html_body'} or $mail->{'text_body'}) and $attach_cnt){
		print MAIL "Content-Type: multipart/mixed;\n boundary=\"$boundary\"\r\n";
		print MAIL $section_boundary."\n";
		if($mail->{'html_body'}){
			print MAIL "Content-Type: text/html; charset=".$default_encoding."\n\n";
			#print MAIL "Content-Transfer-Encoding: 7bit\n\n";
			print MAIL $mail->{'html_body'}."\n";
			$size+=bytes::length($mail->{'html_body'});
		}else{
			print MAIL "Content-Type: text/plain; charset=".$default_encoding."\n\n";
			#print MAIL "Content-Transfer-Encoding: 7bit\n\n";
			print MAIL $mail->{'text_body'}."\n";
			$size+=bytes::length($mail->{'text_body'});
		}
		
		for my $suffix ('',2,3,4,5,6,7,8,9,10,11,12,13,14,15) {
			if ($mail->{'attachment'.$suffix.'_name'}) {				
				print MAIL "\n".$section_boundary."\n";
				print MAIL "Content-Type: ".$mail->{'attachment'.$suffix.'_content_type'}.";\n name=\"".$mail->{'attachment'.$suffix.'_name'}."\"\n";
				#print MAIL "Content-ID: <".$mail->{'attachment'.$suffix.'_name'}.">\n";
				print MAIL "Content-Transfer-Encoding: base64\n";			
				print MAIL "Content-Disposition: attachment;\n filename=\"".$mail->{'attachment'.$suffix.'_name'}."\"\n\n";
				binmode(MAIL,":raw");
				my $tmp=encode_base64($mail->{'attachment'.$suffix.'_body'});
				$size+=bytes::length($tmp);			
				print MAIL $tmp;
				binmode(MAIL,$default_mode);
			}
		}
		print MAIL $boundary.'--'."\n";
	}else{
		lp('simple_sendmail. text to send!!!!!!!!!!!!!!!');
	}
	
	close MAIL;
	log_printf("simple sendmail(to = $mail->{'to'}, from = $mail->{'from'}, subj = $mail->{'subject'}), size=$size");	
	return 1;
		
}

sub complex_sendmail {
	my ($mail) = @_;

	# $mail is hash 
# {
#  'to', 'from', 'subject', 'reply_to', 'text_body', 'html_body', 
#  'attachment_name', 'attachment_cotent_type', 'attachment_body'
# }

#log_printf("mail = ".Dumper($mail));
	my $default_mode = ':utf8';
	my $default_encoding = 'utf8';
	my $rand = atom_misc::make_code(32);
	my $size=0;
	if ($mail->{'default_encoding'} ne 'utf8') { # always set to latin1
#	if (($mail->{'subject'} =~ /Report on/i) || ($mail->{'to'} =~ /zoom\.com/i)) { # switch to latin1-mode for 'Report on...' and ...@zoom.com mails
		$default_mode = ':bytes';
		$default_encoding = 'ISO-8859-1';
	}
	
	
	open (MAIL, "|".$atomcfg{MTA_cmdline}) or log_printf("can't open mailing program ".$atomcfg{MTA_cmdline});
	
	#open (MAIL, ">/home/alex/icecat/bo/trunk/www/img/tmp/mail.txt") or log_printf("can't open mailing program ".$atomcfg{MTA_cmdline});
	
	binmode(MAIL, $default_mode);
	print MAIL "To: ".$mail->{'to'}."\n";
	if ($mail->{'bcc'}) {
		print MAIL "Bcc:".$mail->{'bcc'}."\n";
	}
	print MAIL "From: ".$mail->{'from'}."\n";
	print MAIL "Subject: ".$mail->{'subject'}."\n";
	print MAIL "MIME-version: 1\.0 \n";
#print MAIL "Content-Base: http://my\.com \n";
#print MAIL "Content-Disposition: inline \n";
	if ($mail->{'reply_to'}) {
		print MAIL "Reply-To: ".$mail->{'reply_to'}."\n";
	}
	
	my $hasAttachment=undef;
	# headers for attachments	
	for my $suffix ('',2,3,4,5) {
		if ($mail->{'attachment'.$suffix.'_name'}) {
			print MAIL "Content-Type: multipart/related; boundary=\"zzz".$rand."zzz\";\n\n";
			print MAIL "--zzz".$rand."zzz"."\n";
			$hasAttachment=1;
			last;
		}
	}
	
	# headers for html mails
	if ($mail->{'html_body'}) {
		print MAIL "Content-Type: multipart/alternative;\n boundary=\"xxx".$rand."xxx\"\n\n";
		print MAIL "--xxx".$rand."xxx\n";
	}
	
	# for plain mails
	if ($mail->{'text_body'}) {
		print MAIL "Content-Type: text/plain; charset=".$default_encoding."\n";
		if ($default_mode eq ':utf8') {
			print MAIL "Content-Transfer-Encoding: base64\n";
		}
		print MAIL "\n";
		binmode(MAIL,":bytes");
		if ($default_mode eq ':utf8') {
			my $tmp=encode_base64(Encode::encode("UTF-8",$mail->{'text_body'}));
			$size+=bytes::length($tmp);
			print MAIL $tmp;
		}
		else {
			$size+=bytes::length($mail->{'text_body'});
			print MAIL $mail->{'text_body'} . "\n";
		}
		print MAIL "\n";
	}
	
	# html mails body
	if ($mail->{'html_body'}) {
		print MAIL "--xxx".$rand."xxx\n";
		print MAIL "Content-Type: text/html; charset=".$default_encoding."\n";
		if ($default_mode eq ':utf8') {
			print MAIL "Content-Transfer-Encoding: base64\n";
		}
		print MAIL "\n";
		binmode(MAIL,":bytes");
		if ($default_mode eq ':utf8') {
			my $tmp=encode_base64(encode("UTF-8",$mail->{'html_body'}));
			$size+=bytes::length($tmp);
			print MAIL $tmp;
		}
		else {
			$size+=bytes::length($mail->{'html_body'});
			print MAIL $mail->{'html_body'} . "\n";
		}

		print MAIL "\n";
		print MAIL "--xxx".$rand."xxx--\n";
	}
	
	# attachments body
	my $start_mixed = 0;
	for my $suffix ('',2,3,4,5,6,7,8,9,10,11,12,13,14,15) {
		if ($mail->{'attachment'.$suffix.'_name'}) {
			$start_mixed = 1;
			print MAIL "--zzz".$rand."zzz\n";
			print MAIL "Content-Type: ".$mail->{'attachment'.$suffix.'_content_type'}.";\tname=\"".$mail->{'attachment'.$suffix.'_name'}."\"\n";
			print MAIL "Content-ID: <".$mail->{'attachment'.$suffix.'_name'}.">\n";
			print MAIL "Content-Transfer-encoding: base64\n";			
			print MAIL "Content-Disposition: attachment;\tfilename=\"".$mail->{'attachment'.$suffix.'_name'}."\"\n\n";
			binmode(MAIL,":raw");
			my $tmp=encode_base64($mail->{'attachment'.$suffix.'_body'});
			$size+=bytes::length($tmp);			
			print MAIL $tmp;
			binmode(MAIL,$default_mode);
		}
	}
	print MAIL "--zzz".$rand."zzz--\n" if ($start_mixed);
	
	close MAIL;
	log_printf("complex sendmail(to = $mail->{'to'}, from = $mail->{'from'}, subj = $mail->{'subject'}), size=$size");	
	return 1;
}

1;

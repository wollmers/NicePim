#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/pim/lib/';
use atom_mail;
use atomlog;
use atomcfg;

my $tmp = $atomcfg{'session_path'};

# default file for deferred mail
my $mail_file = $email_about_custom->{'deferred_file'} ? $email_about_custom->{'deferred_file'} : $tmp . 'mail_about_custom.txt';
my $path_to_old = $email_about_custom->{'path_to_old'} ? $email_about_custom->{'path_to_old'} : $tmp;

my $from = $email_about_custom->{'from'} ? $email_about_custom->{'from'} : 'info@icecat.biz';
my $to = $email_about_custom->{'to'} ? $email_about_custom->{'to'} : 'ilya@icecat.biz';
my $title = $email_about_custom->{'title'} ? $email_about_custom->{'title'} : 'Custom values have been used';

log_printf("Sender for deferred messages");

log_printf("FROM  : " . $from);
log_printf("TO    : " . $to);
log_printf("TITLE : " . $title);

open my $MAIL, '<', $mail_file;
my $mail_content = '';
while (<$MAIL>) {
	$mail_content .= $_;
}
close $MAIL;
if($mail_content!=''){
	sendmail($mail_content, $to, $from, $title);
}

# store outdated messages
my $suffix = localtime();
$suffix =~ s/\s/_/g;
$suffix =~ s/:/-/g;

rename $mail_file, $path_to_old . 'old_custom_values_' . $suffix;

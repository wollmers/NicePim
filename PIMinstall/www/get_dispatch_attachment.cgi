#!/usr/bin/perl

#$Id: get_dispatch_attachment.cgi 2373 2010-04-01 12:40:56Z dima $

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';

use atom_engine;
use atom_html;
use atom_engine;
use atomsql;
use atomlog;

&html_start();
my $data = &do_query("select attachment_name, attachment_content_type, attachment_body from mail_dispatch where id = ".&str_sqlize($hin{'id'}));

print "Content-type: ".$data->[0][1]."\n";
print "Content-Disposition: filename=\"".$data->[0][0]."\"\n\n";

binmode $data->[0][2];
binmode STDOUT;

print $data->[0][2];
STDOUT->flush();

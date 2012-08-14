#!/usr/bin/perl

use lib '/home/pim/lib';

use atom_engine;
use atom_html;
use atom_engine;
use atomsql;
use atomlog;

html_start();

my $data = do_query(
    "select attachment_name, attachment_content_type, attachment_body from mail_dispatch where id = "
    . str_sqlize( $hin{'id'} )
);

print "Content-type: ".$data->[0][1]."\n";
print "Content-Disposition: filename=\"" .$data->[0][0] ."\"\n\n";

binmode $data->[0][2];
binmode STDOUT;

print $data->[0][2];
STDOUT->flush();

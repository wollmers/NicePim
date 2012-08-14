#!/usr/bin/perl

use lib '/home/pim/lib';
use atom_engine;
use atom_html;
use atom_util;
use atomsql;
use atom_commands;
use atomlog;
use Data::Dumper;

html_start();
init_atom_engine();

unless($USER->{'user_group'} eq 'superuser' or $USER->{'user_group'} eq 'supereditor') {
	log_printf('-------->>>>>>>>>>get_track_list_report.cgi: unrestricted access: '.$USER->{'user_group'});
	die();
}

my $track_list_name = do_query('SELECT name FROM  track_list where track_list_id='
    .$hin{'track_list_id'})->[0][0];
    
$track_list_name=~s/[^\w]/_/g;

print "Content-type: application/xls\n";
print "Content-Disposition: attachment; filename=\"$track_list_name.xls\"\n";
print "Cache-Control: no-cache, must-revalidate\n";
print "Expires: Sat, 26 Jul 1997 05:00:00 GMT\n\n";

binmode STDOUT;
my $tmp = command_proc_get_track_list_report();
print $tmp;
STDOUT->flush();
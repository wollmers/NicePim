package BO_Apache2_AJAX;
# This module is a mod_perl handler which is used instead old CGI script ajax.cgi

$| = 1;

use lib '/home/pim/lib';

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Connection;

#use modperl2env;
use atomcfg;
use atomsql;
use atomlog;
use ajax;

sub handler {

    my $r = shift;
	atomsql::init_connection();
#    open(atomlog::log_fh,">>".$atomcfg{'logfile'});
    
    # adapter for mod_perl and current CGI interface
    # after this we can use casual request processing
    $ENV{'QUERY_STRING'} = $r->args();
    $ENV{'REMOTE_ADDR'} = $r->connection->remote_ip();
    
		my $answer;
    $answer = ajax();
    
		my $size;
		$size = bytes::length($answer);

    $r->content_type('text/plain');
    $r->content_encoding('gzip');
		$r->set_content_length($size) if $r->can('set_content_length');
		
		$r->rflush();		
    $r->write($answer);
	atomsql::close_connection();
	
    return Apache2::Const::OK;
}

1;

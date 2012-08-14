#!/usr/bin/perl

use strict;
use warnings;

use Log::Dispatch;
use LWP::UserAgent;

use lib '/home/pim/lib';
use atomsql;
use atomlog;
    
    # valid invocation only with 5 or 7 params
    usage() if ( (scalar @ARGV != 5) && (scalar @ARGV != 7) );
    usage() if ( ($ARGV[0] ne 'CHECK_ONLY') && ($ARGV[0] ne 'CHECK_AND_UPDATE') );

    # parameters example:    
    # CHECK_ONLY 
    # product 
    # product_id 
    # high_pic 
    # high_pic_size 
    # high_pic_width 
    # high_pic_height 

    my $operation = $ARGV[0];
    my $table_name = $ARGV[1];
    
    my $f_id = $ARGV[2];
    my $f_url = $ARGV[3];
    my $f_size = $ARGV[4];    
    
    my ($f_width, $f_height);
    if (scalar @ARGV == 7) {
        $f_width = $ARGV[5];
        $f_height = $ARGV[6];
    } 

    my $log;
    init_log();
    
    my $ans;
    # Create a user agent object
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1 ");
    
    # make SQL request    
    my $req;
    my $mode;
    if (scalar @ARGV == 7) {
        $req = "SELECT $f_id, $f_url, $f_size, $f_width, $f_height FROM $table_name";
        $mode = 1;
    } 
    if (scalar @ARGV == 5) {
        $req = "SELECT $f_id, $f_url, $f_size FROM $table_name";
        $mode = 2;
    }    
    $log->warning("--- $req ---");
    
    # SQL request    
    $ans = do_query($req);

    # work vars
    my ($res, $type, $width, $height, $size, $resp);
    my ($present, $match);
    my ($db_url, $db_size, $db_width, $db_height, $db_id);
    my ($c_absent, $c_match, $c_not_match, $total ) = (0, 0, 0);
    foreach (@$ans) {
    
        $db_id = $_->[0];
        $db_url = $_->[1];
        
        # if empty
        next unless ($db_url);
        
        # only local URLs for testing purposes
        # next if ($db_url !~ /http:\/\/127\.0\.0\.1\// );
        
        # global counter
        $total++;
        
        # get file size in bytes
        # Create a request
        $req = HTTP::Request->new(HEAD => $db_url);
        $resp = $ua->request($req);         
        $size = $resp->{'_headers'}->{'content-length'} || "---";
        
        # do not use 'identify' if file not found
        if (($size ne '---') && ($mode == 1)) {
            # use identify utility
            $res = qx(identify $db_url);
        
            # parse result (' ' is a delimiter)
            # result cantsin size in kb, so do not touch it
            $res =~ /^(?:[^\s]+) ([^\s]+) (?:([^\s]+)x([^\s]+))/;
            
            $type = $1 || "---";
            $width = $2 || "---";
            $height = $3 || "---";
        } 
        else {
            $type = "---";
            $width = "---";
            $height = "---";        
        }
            
        # compare and get statuses
        # if present
        if ($size eq '---') {
            $present = "NO";
            $c_absent++;
        }
        else {
            $present = "YES";
        }
        
        # get params from req
        $db_size = $_->[2];
        if ($mode == 1) {
            $db_width = $_->[3];
            $db_height = $_->[4];
        }
        else {
            $db_width = '---';
            $db_height = '---';
        }
        
        # match db and real information
        # check only if the file is present 
        if ($present eq 'YES') {
            if ($mode == 1) {
                # match size, width and height
                if ( ($size == $db_size) && ($width == $db_width) && ($height == $db_height) ) {
                    $match = "MATCH";
                    $c_match++;
                }
                else {
                    $match = "NOT_MATCH";
                    $c_not_match++;
                }
            }
            else {
                # match size only
                if ($size == $db_size) {
                    $match = "MATCH";
                    $c_match++;
                }
                else {
                    $match = "NOT_MATCH";
                    $c_not_match++;
                }
            }
        } 
        else {
            $match = "---";
        } 
        
        # update if CHECK_AND_UPDATE
        if ( ($operation eq 'CHECK_AND_UPDATE') && ($present eq 'YES') && ($match eq 'NOT_MATCH') ) {
            
            # case 1 : for long request
            if ($mode == 1) {
                atomsql::update_rows(
                    $table_name,
                    $f_id . ' = ' . $db_id,
                    {
                        $f_size => $size,
                        $f_width => $width,
                        $f_height => $height,
                        'updated' => 'updated',
                    }
                );
            }
            # case 2 : for short request
            if ($mode == 2) {
                atomsql::update_rows(
                    $table_name,
                    $f_id . ' = ' . $db_id,
                    {
                        $f_size => $size,
                        'updated' => 'updated',
                    }
                );
            }
        } # if update
        
        # log message
        $log->warning(
            $present . ' ' . $match . ' ' . 
            $size . "($db_size) " . $width . "($db_width) " . $height . "($db_height) " .
            $type . ' ' . $db_url . ' ' . $db_id 
        );
        
    } # foreach
    
    $log->warning("--- absent : $c_absent, match : $c_match, not_match : $c_not_match, total URLs : $total");
    
exit 0;


# make container with a logger
sub init_log {
    
    $log = Log::Dispatch->new( outputs => [ 
	[ 'File',   min_level => 'info', filename => 'log', mode => '>>', callbacks => 
	    sub {
    	    # all components in this message shuld be without spaces
	        my %mess = @_;
	        if ($mess{'message'} !~ /^---/ ) {
	            my @arr = split(/ /, $mess{'message'});
    		    return sprintf("%4s %10s %18s %18s %18s %8s %s >> %s\n", $arr[0], $arr[1], $arr[2], $arr[3], $arr[4], $arr[5], $arr[6], $arr[7]);
	        } 
	        else {
    	        # do not perform formating operation for title messages
	            return "\n" . $mess{'message'} . "\n\n";
	        }
	    }
	]
    ] );

    return;
}

sub usage {
    print("Usage : pic_test.pl <CHECK_ONLY|CHECK_AND_UPDATE> <table_name> <id_field> <URL_field> <size_field> [width_field height_field] \n");
    exit(-1);
}

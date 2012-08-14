#!/usr/bin/perl

use strict;
use warnings;

use Log::Dispatch;
use DBI;
use Search::Tools::UTF8;
use Encode;

# DB
use constant HOST => '192.168.1.42';
use constant DBNAME => 'gccdb1';
use constant USER => 'gcc';
use constant PASSWORD => 'WV120xA';

# other
use constant LOG_UPDATE =>  './_update.log';
use constant LOG_WARNING => './_warning.log';
#@ARGV=('product_description','long_desc','product_description_id','LOG_ONLY');

# regex for UTF8 validation
my $valid_utf8_regexp = <<'.' ;
        [\x{00}-\x{0E}\x{1F}-\x{7f}]
| [\x{c2}-\x{df}][\x{80}-\x{bf}]
|         \x{e0} [\x{a0}-\x{bf}][\x{80}-\x{bf}]
| [\x{e1}-\x{ec}][\x{80}-\x{bf}][\x{80}-\x{bf}]
|         \x{ed} [\x{80}-\x{9f}][\x{80}-\x{bf}]
| [\x{ee}-\x{ef}][\x{80}-\x{bf}][\x{80}-\x{bf}]
|         \x{f0} [\x{90}-\x{bf}][\x{80}-\x{bf}]
| [\x{f1}-\x{f3}][\x{80}-\x{bf}][\x{80}-\x{bf}][\x{80}-\x{bf}]
|         \x{f4} [\x{80}-\x{8f}][\x{80}-\x{bf}][\x{80}-\x{bf}]
.

#
# main
#

    my ($p1, $p2, $p3, $update_mode);
    if (scalar @ARGV != 4) {
	usage();
    } 
    else {
	if ($ARGV[3] && $ARGV[3] eq 'AUTO_UPDATE' ) {
	    $update_mode = 1;
	}
	elsif ($ARGV[3] && $ARGV[3] eq 'LOG_ONLY') {
	    $update_mode = 0;
	} 
	else {
	    usage();
	}
    
	$p1 = $ARGV[0];
	$p2 = $ARGV[1];
	$p3 = $ARGV[2];
	print "Table name                : $p1\n";
	print "Field name                : $p2\n";
	print "Primary key field name    : $p3\n";
	print "Update mode               : $update_mode\n";
    }

    my $log1;
    my $log2;
    init_logs();

    my $dsn = "DBI:mysql:database=" . DBNAME . ";host=" . HOST;
    my $user = USER;
    my $password = PASSWORD;
    my $dbh = DBI->connect($dsn, $user, $password);

    if (!$dbh) {
	print "Unable to connect\n";
	exit(-1);
    } else {
	print "Connection - OK\n";
    }

# ===========================================

    checker($p1, $p2, $p3);
    # example : checker('product_name', 'name', 'product_name_id');
    
# ===========================================
use lib '/home/pim/lib';
use atom_mail;
my $mail = {
                'to' => 'alexey@bintime.com',
                'from' =>  'info@icecat.biz',
                'subject' => "XML cheking finished",
                'default_encoding'=>'utf8',
                'html_body' => 'OK',
         };
&complex_sendmail($mail);

    exit(0);

#
# subroutines
#


sub checker {
    my $table = shift;
    my $field = shift;
    my $primary_key = shift;
    
    $log1->warning("\n=======================================================\n");
    $log1->warning("TABLE: $table FIELD: $field");
    $log1->warning("\n=======================================================\n");
    $log2->warning("\n=======================================================\n");
    $log2->warning("TABLE: $table FIELD: $field");
    $log2->warning("\n=======================================================\n");
    
    my $sth = $dbh->prepare('SELECT ' . $field . ',' . $primary_key . ' FROM ' . $table );
    $sth->execute();
    
    my $row_ref;
    my $c = 0;
    my $e = 0;
    my $latin1_detected = 0;
    my $latin1_fixed = 0;
    my $try;
    my $st;
    while ( $row_ref = $sth->fetchrow_arrayref() ) {
	if (! my_is_utf8($row_ref->[0]) ) {
	    $e++;
	    
	    if (is_latin1($row_ref->[0])) {
		$latin1_detected++;
		$try = encode('utf8', decode('latin1', $row_ref->[0] ));
		if ( my_is_utf8($try) ) {
		
		    # SQL update statement
		    if ($update_mode == 1) {
			# log and update
			$st = "UPDATE " . $table . " SET " . $field . " = " . str_sqlize($try) . " WHERE " . $primary_key . " = " . $row_ref->[1];
			my $sth_up = $dbh->prepare($st);
			$sth_up->execute();
			$log2->warning($st);
			$latin1_fixed++;
		    } 
		    else {
			# log only
			$st = sprintf("%s = %10d CONVERTED VALUE = %s", $primary_key, $row_ref->[1], $try );
			$log2->warning($st);
		    }
		}
		else {
		    $log1->warning("Unable to convert latin1 : " . $row_ref->[0] . " $primary_key = " . $row_ref->[1] );
		}
	    }
	    else {
		$log1->warning(sprintf("%10d %s", $row_ref->[1], $row_ref->[0]) );
	    }
	}
	$c++;
    }
    
    print sprintf("%s.%s records total %d/%d , latin1 fixed %d/%d , unfixed %d \n", $table, $field, $e, $c, $latin1_fixed, $latin1_detected, $e - $latin1_fixed);

    return;
}

sub my_is_utf8 {
    
    return 1 if (! $_[0]);

    if ($_[0] =~ /^($valid_utf8_regexp)*+$/x) {
	return 1;
    } else {
	return 0;
    }
}

# make 2 containers with a 1 logger
sub init_logs {
    
    $log1 = Log::Dispatch->new( outputs => [ 
	[ 'File',   min_level => 'info', filename => LOG_WARNING, mode => '>', callbacks => 
	    sub {
		my %h = @_;
		return sprintf("%s\n", $h{'message'});
	    } 
	]
    ] );

    $log2 = Log::Dispatch->new( outputs => [ 
	[ 'File',   min_level => 'info', filename => LOG_UPDATE, mode => '>', callbacks => 
	    sub {
		my %h = @_;
		return sprintf("%s\n", $h{'message'});
	    } 
	]
    ] );
    
    return;
}

sub str_sqlize
{
    my $str = $_[0];
    
    $str =~ s/\\/\\\\/g;
    $str =~ s/\'/\\\'/g;
    $str = "\'".$str."\'";

    return $str;
}

sub usage {
    print("Usage : utf8check <table_name> <field_name> <primary_key_field_name> <AUTO_UPDATE|LOG_ONLY> \n");
    exit(-1);
}


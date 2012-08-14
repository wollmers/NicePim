#!/usr/bin/perl

use strict;
use warnings;

use lib '/home/pim/lib';

use Algorithm::CheckDigits;
use atomsql;
use atomcfg;
my $first_para = $ARGV[0];
if (scalar @ARGV != 1) {
    usage();
}
elsif ( ($first_para ne 'LOG_ONLY') && ($first_para ne 'KILL') ) {
    usage();
}

my $ans = do_query("
    SELECT ean_code, product_id, updated, ean_id
    FROM product_ean_codes
");

# create EAN checker
my $ean = CheckDigits('ean');

# create UPC checker
my $upc = CheckDigits('upc');

# erorrs
my ($BACKUP, $BACKUP2, $BACKUP_LEN);

# for incorrect EAN and UPC
open $BACKUP, ">", $atomcfg{'sql_log_path'} . '/removed_EANs_' . localtime() . '.sql';
open $BACKUP2, ">", $atomcfg{'sql_log_path'} . '/removed_UPCs_' . localtime() . '.sql';

# for not 12 or 13 characters
open $BACKUP_LEN, ">", $atomcfg{'sql_log_path'} . '/removed_eans_wrong_length_' . localtime() . '.sql';

my (
    $total,
    $ok_ean, $not_ok_ean, $total_ean,
    $ok_upc, $not_ok_upc, $total_upc,
    $length_error,
    $pid, $up, $ean_id, $c
);

foreach my $code (@$ans) {

    $c = $code->[0];
    $pid = $code->[1];
    $up = $code->[2];
    $ean_id = $code->[3];
    
    $total++;
    
    if ( (length($c) != 13) && (length($c) != 12) ) {
        $length_error++;
        
        print $BACKUP_LEN "INSERT INTO product_ean_codes (ean_code, product_id, updated) VALUES (" . str_sqlize($c) . ", $pid, " . str_sqlize($up) . " );\n";
        kill_ean($ean_id,$c) if ($first_para eq 'KILL');
    }
    
    if (length($c) == 13) {
        $total_ean++;
        if ($ean->is_valid($c) ) {
            $ok_ean++;
        }
        else {
            $not_ok_ean++;
            print $BACKUP "INSERT INTO product_ean_codes (ean_code, product_id, updated) VALUES (" . str_sqlize($c) . ", $pid, " . str_sqlize($up) . " );\n";
            kill_ean($ean_id,$c) if ($first_para eq 'KILL');
        }
    }
    if (length($c) == 12) {
        $total_upc++;
        if ($upc->is_valid($c) ) {
            $ok_upc++;
        }
        else {
            $not_ok_upc++;
            print $BACKUP2 "INSERT INTO product_ean_codes (ean_code, product_id, updated) VALUES (" . str_sqlize($c) . ", $pid, " . str_sqlize($up) . " );\n";
            kill_ean($ean_id,$c) if ($first_para eq 'KILL');
        }
    }
}

print "Total : " . $total . "\n";
print "---------------------------------\n";
print "Invalid length (neither 12 nor 13): " . $length_error . "\n";

print "Length = 12 (UPC) : " . $total_upc . "\n";
print "   OK     : " . $ok_upc . "\n";
print "   NOT OK : " . $not_ok_upc . "\n";

print "Length = 13 (EAN) : " . $total_ean . "\n";
print "   OK     : " . $ok_ean . "\n";
print "   NOT OK : " . $not_ok_ean . "\n";

close $BACKUP;
close $BACKUP2;
close $BACKUP_LEN;

exit 0;

sub kill_ean {
    my ($id,$ean) = @_;
    print $ean."\n";     
    do_statement("
        DELETE FROM product_ean_codes
        WHERE ean_id = $id
    ");
    return;
}

sub usage {
    print "Usage: kill_incorrect_EANs.pl <KILL|LOG_ONLY>\n";
    exit 0;
}

#!/usr/bin/perl

use strict;
#use warnings;

use lib '/home/pim/lib';

use atomcfg;
use atomsql;
use icecat_util;

use constant DEST_FILENAME => 'CategoryFeatureIntervalsList.xml';

my $debug = 0;

    my $table = do_query('SELECT 
        category_feature_interval_id, 
        category_feature_id, 
        intervals, 
        updated, 
        valid, 
        invalid,
        in_each    
        FROM category_feature_interval'
    );
    
    my $row_ref;    
    my $cnt = '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    my ($id, $valid, $invalid, $ratio, $up, $min, $max);
    my @ints;
    my @counts;
    $cnt .= "<!DOCTYPE search_intervals SYSTEM \"" . $atomcfg{host} . "dtd/ICECAT-search_intervals.dtd\">";
    $cnt .= "<ICECAT-interface>\n";
    $cnt .= source_message() . "\n";
    
    foreach $row_ref (@$table) {
        
        @counts = split /\n/, $row_ref->[6];
        @ints = split /\n/, $row_ref->[2];
        
        $valid = $row_ref->[4];
        $invalid = $row_ref->[5];
       
        if (($valid + $invalid) != 0) {
            $ratio = $valid / ($valid + $invalid);
        } 
        else {
            $ratio = 0;
        }
        
        $id = $row_ref->[1];
        $up = $row_ref->[3];
        
        if ($debug) {
            my $a = do_query("SELECT searchable FROM category_feature WHERE category_feature_id = $id");
            print $a->[0]->[0] . " ";
        }
        
        # update ints for sorting procedure
        for (my $i = 0 ; $i <= $#ints ; $i++ ) {
            $ints[$i] = $ints[$i] . '~' . $counts[$i];
        }

        # sort intervals, using first elem before '-'
        my @ints = sort { ($a =~ /^(.*)-/)[0] <=> ($b =~ /^(.*)-/)[0] } @ints;

        # update back
        for (my $i = 0 ; $i <= $#ints ; $i++ ) {
            $ints[$i] =~ /^(.*)~(.*)$/;
            $ints[$i] = $1;
            $counts[$i] = $2;
        }                                          

        # make record
        $cnt .= "<CategoryFeatureIntervals category_feature_id='$id' valid='$valid' invalid='$invalid' ratio='$ratio' updated='$up'>\n";
        # all intervals
        for (my $i = 0 ; $i <= $#ints ; $i++ ) {  
            $cnt .= "\t<Interval amount='" .$counts[$i] . "' order='" . ($i + 1) . "'>\n";
            
            $ints[$i] =~ /^([^-]*)-([^-]*)$/;
            $min = $1;
            $max = $2;
            
            $cnt .= "\t\t<Min>$min</Min>\n";
            $cnt .= "\t\t<Max>$max</Max>\n";
            
            # $cnt .= "\t\t<Min><![CDATA[$min]]></Min>\n";
            # $cnt .= "\t\t<Max><![CDATA[$max]]></Max>\n";
            
            $cnt .= "\t</Interval>\n";
        }
        $cnt .= '</CategoryFeatureIntervals>' . "\n"; 
        
    } # while for each record in DB
    $cnt .= "</ICECAT-interface>\n";

    my $path = $atomcfg{'xml_path'}.'level4/refs/';
    if (! -d $path) {
        qx(mkdir $path);
    }
    my $filename = $path . DEST_FILENAME;
    
    print $path . "\n";
    print $filename . "\n";
    
    open my $FILE, '>', $filename or die 'Unable to create file';
    binmode $FILE, ":utf8";
    print $FILE $cnt;
    close $FILE;
    
    print "intervals.xml has been created\n";

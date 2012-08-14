#!/usr/bin/perl

use strict;
use warnings;

    my $oper = $ARGV[0];
    if (($oper ne 'CHECK_AND_UPDATE') && ($oper ne 'CHECK_ONLY')) {
        print "The first paramether should be CHECK_AND_UPDATE or CHECK_ONLY\n";
        exit(-1);
    }
    
    # delete an old log file 
    unlink('./log') if (-e './log');
    
    # long 
    `./pic_test.pl $oper product product_id high_pic high_pic_size high_pic_width high_pic_height`;
    `./pic_test.pl $oper product product_id low_pic low_pic_size low_pic_width low_pic_height`;    
    `./pic_test.pl $oper product_gallery id link size width height`;
    
    # short for thumb (without width and height)
    `./pic_test.pl $oper product product_id thumb_pic thumb_pic_size`;
    `./pic_test.pl $oper product_gallery id thumb_link thumb_size`;
        

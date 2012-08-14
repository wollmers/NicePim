#!/usr/bin/perl

# periodical task for cron

use lib '/home/pim/lib';

use atomsql;
use atom_util;

    my $table = do_query('SELECT category_feature_id FROM category_feature WHERE searchable = 1');
    my $row_ref;    
    
    my ($cf_id);
    foreach $row_ref (@$table) {
        $cf_id = $row_ref->[0];
        make_category_feature_intervals($cf_id);        
    }


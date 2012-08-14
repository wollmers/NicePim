#!/usr/bin/perl

# periodical task for cron

# @author <vadim@bintime.com>

use lib '/home/pim/lib';

use atomcfg;
use atomlog;
use atomsql;
use atom_util;

print "Starting refresh_categoryfeature_intervals.pl: \n";

my $table  = do_query('SELECT category_feature_id FROM category_feature WHERE searchable = 1');

# create temporary table for new and updated intervals
do_statement("DROP TEMPORARY TABLE IF EXISTS cf_interval");
do_statement("CREATE TEMPORARY TABLE cf_interval LIKE category_feature_interval");

foreach my $row_ref (@$table) {
	make_category_feature_intervals($row_ref->[0]);        
}

# delete values from original tables that were not updated
do_statement("DELETE FROM category_feature_interval
	WHERE NOT EXISTS
	(SELECT category_feature_id FROM cf_interval WHERE
	cf_interval.category_feature_id = category_feature_interval.category_feature_id)");

# update original table
do_statement("UPDATE category_feature_interval cf
	JOIN cf_interval USING(category_feature_id) SET
	cf.intervals=cf_interval.intervals,
	cf.in_each=cf_interval.in_each,
	cf.valid=cf_interval.valid,
	cf.invalid=cf_interval.invalid,
	cf.invalid_values=cf_interval.invalid_values,
	cf.updated=cf_interval.updated");

# insert into original table new values from temporary table
do_statement("INSERT IGNORE INTO category_feature_interval SELECT * FROM cf_interval");

print "End\n";

#!/usr/bin/perl

#$Id: make_product_index_cache.pl 3758 2011-01-25 15:56:30Z dima $

use strict;

# TODO: add keys to updated fields of 5 source tables!..

use lib '/home/pim/lib';
#use lib '/home/dima/gcc_svn/lib';

use atomlog;
use atomcfg;
use atomsql;
use data_management;
use icecat_server2_repository;
use icecat_util;
use process_manager;

use POSIX qw(strftime);
use Encode;
use Time::Piece;

$| = 1;

if (&get_running_perl_processes_number('make_product_index_cache.pl') != 1) {
	print "'make_product_index_cache.pl' already running. exit.\n";
  exit;
}

print "Find the last run date... ";

my $timestamp_file_path = $atomcfg{'base_dir'}.'bin/make_product_index_cache.pl.timestamp';
my $stat_file_path = $atomcfg{'base_dir'}.'bin/make_product_index_cache.pl.stat';

# empty the statistics, if rows > 1000
my $num_rows = `cat $stat_file_path | wc -l`;
chomp($num_rows);

if ($num_rows > 100) {
	`rm -f $timestamp_file_path`;
	`rm -f $stat_file_path`;
}

my $current_timestamp = &do_query("select unix_timestamp()")->[0][0];
my $POSIX_current_timestamp = &do_query("select from_unixtime(".$current_timestamp.")")->[0][0];
my $timestamp = 0;
my $POSIX_timestamp = 'from the beginning';
my $condition = ' where 1 ';
my $filter_table = 'itmp_product_cache_res';

if ((-f $timestamp_file_path) && (!-z $timestamp_file_path)) {
	$timestamp = `cat $timestamp_file_path`;
	chomp($timestamp);

	if ($timestamp =~ /^\d+$/) {
		$POSIX_timestamp = &do_query("select from_unixtime(".$timestamp.")")->[0][0];
		# we set the product updated info grsbbing from the specific date
		$condition = ' where updated >= '.&str_sqlize($POSIX_timestamp);
	}
	else {
		# ... or - use the whole time frames
		$timestamp = 0;
	}
}

print $timestamp ? $POSIX_timestamp : "no date, the global run";

print "\n\n";

print "Make product index cache... ";

my $cond = {
	'on_market' => 1,
	'table_name' => 'itmp_product'
};

my ($collect, $handles, $handle, $file);

my (
	$xml, $csv, $xml_all, $csv_all,
	$pid, $cache_update, $cache_insert,
	$updated, $date_added, $m_prod_ids, $cmd,
	@m_prod_ids, $prod_id_prev, @ean_upcs, $ean2file, $current,
	@countries, $country2file
	);

&do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_product_cache");
&do_statement("
	    CREATE TEMPORARY TABLE itmp_product_cache (
	    itmp_product_cache_id int(13)   NOT NULL AUTO_INCREMENT,
	    product_id            int(13)   NOT NULL DEFAULT 0,
	    updated               timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,

	    PRIMARY KEY (`itmp_product_cache_id`),
	    KEY (`product_id`)
	    )
	");

&do_statement("DROP TEMPORARY TABLE IF EXISTS ".$filter_table);
&do_statement("
	    CREATE TEMPORARY TABLE ".$filter_table." (
	    itmp_product_cache_res_id int(13)   NOT NULL AUTO_INCREMENT,
	    product_id                int(13)   NOT NULL DEFAULT 0,
	    updated                   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,

	    PRIMARY KEY (`itmp_product_cache_res_id`),
	    KEY (`product_id`),
	    KEY (`updated`)
	    )
	");

# 5 tables 
# 'product' 
# 'country_product'
# 'product_ean_codes'
# 'distributor_product'
# 'aggregated_product_count'

# fill tmp table

&do_statement("alter table itmp_product_cache disable keys");

&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT product_id, updated FROM product ".$condition."
	");

print "P".&rc;

my @arr = &get_primary_key_set_of_ranges('country_product', 'country_product', 100000, 'product_id');
my $rc = 0;
my $b_cond = '';
foreach $b_cond (@arr) {
	&do_statement("lock tables country_product write");
	&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT product_id, MAX(updated) FROM country_product ".$condition." AND ".$b_cond." GROUP BY product_id
	");
	$rc += &do_query("select row_count()")->[0][0];
	&do_statement("unlock tables");
}

print "CP".&rc($rc);

&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT product_id, MAX(updated) FROM product_ean_codes ".$condition." GROUP BY product_id
	");

print "PEC".&rc;

@arr = &get_primary_key_set_of_ranges('distributor_product', 'distributor_product', 100000, 'product_id');
$rc = 0;
foreach $b_cond (@arr) {
	&do_statement("lock tables distributor_product write");
	&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT product_id, MAX(updated) FROM distributor_product ".$condition." AND " . $b_cond . " GROUP BY product_id
	");
	$rc += &do_query("select row_count()")->[0][0];
	&do_statement("unlock tables");
}

print "DP".&rc($rc);

&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT product_id, updated FROM aggregated_product_count ".$condition."
	");

print "APC".&rc;

&do_statement("
	    INSERT INTO itmp_product_cache (product_id, updated)
	    SELECT p.product_id, p.updated FROM product p where p.product_id > (select max(product_id) from product_index_cache)
	");

print "?P".&rc;

&do_statement("alter table itmp_product_cache enable keys");

print "EK ";

# fill result table
&do_statement("
	    INSERT INTO ".$filter_table." (product_id, updated)
	    SELECT product_id, MAX(updated) FROM itmp_product_cache GROUP BY product_id
	");

print "iPC->iPCR - filled".&rc."\n";

print "Trying to remove all products from '".$filter_table."', that already present into 'product_index_cache'...\n\n";

my $ans = &do_query("
	    SELECT COUNT(*) FROM ".$filter_table."
	")->[0][0];

print "Records into '".$filter_table."' (filter) before DELETE = $ans\n";

# delete products
&do_statement("
	    DELETE res FROM ".$filter_table." res
	    INNER JOIN product_index_cache pic USING (product_id)
	    WHERE res.updated <= pic.updated
	");

$ans = &do_query("
	    SELECT COUNT(*) FROM ".$filter_table."
	")->[0][0];

print "Records into '".$filter_table."' (filter) after DELETE = $ans\n\n";

if ($ans == 0) {
	print "No records for processing... Exiting.\n";

	exit 0;
}

# get products
my $table_name = &get_products4repository({'updated' => 1, 'table_name' => 'itmp_product', 'use_filter' => $filter_table }, '');

my $p4rep = &do_query("
	    SELECT COUNT(*)
	    FROM $table_name
	")->[0][0];

print "records into 'itmp_product' (from get_product4repository): $p4rep\n";

my $query = "
	    SELECT
  	    product_id,      supplier_id,    prod_id,        catid,              user_id,
        content_measure, updated,        mapped,         orig_set,           date_added,
        ean_upc_set,     on_market,      only_vendor,    country_market_set, name,
        quality,         agr_prod_count, distri_set,     high_pic,           high_pic_size,
        high_pic_width,  high_pic_height
        
        FROM itmp_product
    ";

my ($sth, $p, $i, $pair, $rows);
$sth = $atomsql::dbh->prepare($query);
$sth->execute();

# print "Products fetched for 'itmp_products': " . $sth->rows . "\n";

$cache_insert = 0;
$cache_update = 0;

$rows = $sth->rows;

# all fetched records should be INSERT or UPDATE into 'product_index_cache'

while ($p = $sth->fetchrow_arrayref) {
	$i++;

	$pid = $p->[0];

	$pair = &create_index_pair({
		'product_id'         => $p->[0],
		'supplier_id'        => $p->[1],
		'prod_id'            => $p->[2],
		'catid'              => $p->[3],
		'user_id'            => $p->[4],
		'content_measure'    => $p->[5],
		'updated'            => $p->[6],
		'mapped'             => $p->[7],
		'orig_set'           => $p->[8],
		'date_added'         => $p->[9],
		'ean_upc_set'        => $p->[10],
		'on_market'          => $p->[11],
		'only_vendor'        => $p->[12],
		'country_market_set' => $p->[13],
		'name'               => $p->[14],
		'quality'            => $p->[15],
		'agr_prod_count'     => $p->[16],
		'distri_set'         => $p->[17],
		'high_pic'           => $p->[18],
		'high_pic_size'      => $p->[19],
		'high_pic_width'     => $p->[20],
		'high_pic_height'    => $p->[21]
														 });

	# sqlize them...
	
	$xml_all = str_sqlize($pair->{'xml'});
	$csv_all = str_sqlize($pair->{'csv'});
	
### INSERT or UPDATE

	# get the latest time from 'itmp_product_cache_res'
	my $latest_time = &do_query("SELECT updated FROM itmp_product_cache_res WHERE product_id = ".$pid)->[0][0];

	my $ex = &do_query("SELECT 1 FROM product_index_cache WHERE product_id = ".$pid)->[0][0];
	
	# INSERT or UPDATE
	if (! $ex) {
		&do_statement("
                INSERT IGNORE INTO product_index_cache 
                (product_id, xml_info, csv_info, updated)
                VALUES
                ( ".$pid.", ".$xml_all.", ".$csv_all.", " . str_sqlize($latest_time) . " )
            ");
		$cache_insert++;
		print "+";
	}
	else {
		&do_statement("
                UPDATE product_index_cache 
                SET xml_info = ".$xml_all.", csv_info = ".$csv_all.", updated = " . str_sqlize($latest_time) . "
                WHERE product_id = ".$pid."
            ");
		$cache_update++;
		print ".";
	}

	print "(".$i." of ".$rows.")" unless $i % 1000;
	
} # while

print "\n";
print "INSERTs to 'product_index_cache': $cache_insert\n";
print "UPDATEs to 'product_index_cache': $cache_update\n";

my $cache_size = &do_query("
    SELECT COUNT(*)
    FROM product_index_cache
")->[0][0];

print "COUNT(*) for 'product_index_cache': $cache_size\n";

print "\n";

print "Store the last run date... ";

`echo '$current_timestamp' > $timestamp_file_path`;
`echo '$POSIX_current_timestamp: insterted = $cache_insert, updated = $cache_update' >> $stat_file_path`;

print $POSIX_timestamp." - ".$POSIX_current_timestamp;

print "\n\n";

exit(0);


 ########
## subs ##
 ########

sub rc {
	my ($rc) = @_;
	return " (" . ( defined $rc ? $rc : &do_query("select row_count()")->[0][0] ) . ") ";
} # sub rc

sub db_date2unixtime {
	my $tmp = shift;

	my $ut = Time::Piece->strptime($tmp, "%Y-%m-%d %H:%M:%S");
	my $t = $ut->epoch();

	return $t;
}

sub format_date {
	my ($time) = @_;

	my $generated = strftime("%Y%m%d%H%M%S", localtime($time));

	return $generated;
}

sub getDistri_xml_tags { # need to think, if we can make this more abstract...
	my $distri_set = shift;
	
	my @distris;

	if ($distri_set) {
		@distris = split /\t/, $distri_set;
	}
	
	return '' if $#distris == -1;

	my $xml = "\n\t\t\t<Distributors>\n";
	
	foreach (@distris) {
		my @attrs = split /;/, $_;
		if ($#attrs != -1) {
			$xml .= "\n\t\t\t\t".'<Distributor ID="'.$attrs[0].'" Name="'.$attrs[1].'" Country="'.$attrs[2].'" ProdlevId="'.$attrs[3].'"/>'."\n";
		}
	}
	
	$xml .= "\n\t\t\t</Distributors>\n";
	
	print $xml , "\n";
	
	return $xml;
}

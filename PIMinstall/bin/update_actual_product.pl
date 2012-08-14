#!/usr/bin/perl

#$Id: update_actual_product.pl 3760 2011-01-26 09:29:20Z dima $

#
# The result is:
#
# actual_product_table (product_id + langid), that will be useful for 
#

use lib '/home/pim/lib/';
#use lib '/home/dima/gcc_svn/lib/';

use strict;

use atomsql;
use atomlog;
use process_manager;

use Time::HiRes;

################### INSERT INTO ACTUAL PRODUCT

#
################### VOCABULARY
#

$| = 1;

if (&get_running_perl_processes_number('update_actual_product.pl') != 1) {
	print "'update_actual_product.pl' already running. exit.\n";
  exit;
}

my $now = &do_query("select now()")->[0][0];
my $timer = 0;
my $show_explains = 0;
my $two_days_ago = 2 * 24 * 60 * 60;

my $described_only_join = '
INNER JOIN users u USING (user_id)
INNER JOIN user_group_measure_map ugmm USING (user_group)
INNER JOIN content_measure_index_map cmim ON ugmm.measure=cmim.content_measure AND cmim.quality_index > 0';

print "\033[1mRefresh actual product table: ".$now."\033[0m\n\n";

# products touched by categories
my $c_select = "SELECT p.product_id, icu.langid, icu.updated, 0
FROM itmp_category_updated icu
INNER JOIN product_memory p  ON p.catid = icu.catid AND icu.updated > p.updated
".$described_only_join."
LEFT  JOIN actual_product ap USING (product_id,langid)
WHERE icu.updated > ap.updated OR ap.updated IS NULL
GROUP BY 1,2,3";

$timer = &ts;
&do_statement("drop temporary table if exists itmp_category_updated");
&do_statement("create temporary table if not exists itmp_category_updated (
catid   int(13)     not null,
langid  smallint(5) not null,
updated timestamp,
key        (updated, catid),
unique key (catid, langid))");

&do_statement("INSERT INTO itmp_category_updated(catid, langid, updated)
SELECT c.catid, v.langid, v.updated
FROM       vocabulary v
INNER JOIN category c ON c.sid = v.sid
WHERE v.updated > v.last_published");

print &do_query_dump("EXPLAIN ".$c_select) if $show_explains;

&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated) ".$c_select);

print "\tcategories:\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# products touched by feature
my $f_select = "SELECT p.product_id, ifu.langid, ifu.updated, 0
FROM       itmp_feature_updated ifu
INNER JOIN product_memory p ON p.catid = ifu.catid AND ifu.updated > p.updated
".$described_only_join."
LEFT  JOIN actual_product ap USING (product_id,langid)
WHERE ifu.updated > ap.updated OR ap.updated IS NULL
GROUP BY 1,2,3";

$timer = &ts;
&do_statement("drop temporary table if exists itmp_feature_updated");
&do_statement("create temporary table if not exists itmp_feature_updated (
catid   int(13)     not null,
langid  smallint(5) not null,
updated timestamp,
key        (updated, catid),
unique key (catid, langid))");

&do_statement("INSERT INTO itmp_feature_updated(catid, langid, updated)
SELECT cf.catid, v.langid, max(v.updated)
FROM       vocabulary v
INNER JOIN feature f           ON f.sid = v.sid
INNER JOIN category_feature cf ON cf.feature_id = f.feature_id
where v.updated > v.last_published
group by catid, langid");

print &do_query_dump("EXPLAIN ".$f_select) if $show_explains;

&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated) ".$f_select);

print "\tfeatures:\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# products touched by measure
my $m_select = "SELECT p.product_id, imu.langid, imu.updated, 0
FROM       itmp_measure_updated imu
INNER JOIN product_memory p ON p.catid = imu.catid AND imu.updated > p.updated
".$described_only_join."
LEFT  JOIN actual_product ap USING (product_id,langid)
WHERE imu.updated > ap.updated OR ap.updated IS NULL
GROUP BY 1,2,3";

$timer = &ts;
&do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_measure_updated");
&do_statement("CREATE TEMPORARY TABLE IF NOT EXISTS itmp_measure_updated (
catid   int(13)     NOT NULL,
langid  smallint(5) NOT NULL,
updated timestamp,
KEY        (updated, catid),
UNIQUE KEY (catid, langid))");

&do_statement("INSERT INTO itmp_measure_updated(catid, langid, updated)
SELECT cf.catid, v.langid, max(v.updated)
FROM       vocabulary v
INNER JOIN measure m           ON m.sid = v.sid
INNER JOIN feature f           ON m.measure_id = f.measure_id
INNER JOIN category_feature cf ON cf.feature_id = f.feature_id
where v.updated > v.last_published
group by catid, langid");

print &do_query_dump("EXPLAIN ".$m_select) if $show_explains;

&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated) ".$m_select);

print "\tmeasures:\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# products touched by feature_group
my $fg_select = "SELECT p.product_id, ifgu.langid, ifgu.updated, 0
FROM       itmp_feature_group_updated ifgu
INNER JOIN product_memory p ON p.catid = ifgu.catid AND ifgu.updated > p.updated
".$described_only_join."
LEFT  JOIN actual_product ap USING (product_id,langid)
WHERE ifgu.updated > ap.updated OR ap.updated IS NULL
GROUP BY 1,2,3";

$timer = &ts;
&do_statement("drop temporary table if exists itmp_feature_group_updated");
&do_statement("create temporary table if not exists itmp_feature_group_updated (
catid   int(13)     not null,
langid  smallint(5) not null,
updated timestamp,
key        (updated, catid),
unique key (catid, langid))");

&do_statement("INSERT INTO itmp_feature_group_updated(catid, langid, updated)
SELECT cfg.catid, v.langid, max(v.updated)
FROM       vocabulary v
INNER JOIN feature_group fg           ON fg.sid = v.sid
INNER JOIN category_feature_group cfg ON cfg.feature_group_id = fg.feature_group_id
where v.updated > v.last_published
group by catid, langid");

print &do_query_dump("EXPLAIN ".$fg_select) if $show_explains;

&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated) ".$fg_select);

print "\tfeature_groups:\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# update last_published value for vocabulary table

$timer = &ts;
&do_statement("update vocabulary set last_published = " . &str_sqlize($now) . ", updated = updated");
print "\tupdate vocabulary with the new dates:\t" . &rc . " rows were modified (".&dts($timer)." sec)\n\n";

#
################### MEASURE_SIGN
#

# products touched by measure_sign
my $ms_select = "SELECT p.product_id, imsu.langid, imsu.updated, 0
FROM itmp_measure_sign_updated imsu
INNER JOIN product_memory p ON p.catid = imsu.catid
".$described_only_join."
LEFT  JOIN actual_product ap USING (product_id,langid)
WHERE imsu.updated > p.updated
AND   (imsu.updated > ap.updated OR ap.updated IS NULL)
GROUP BY 1,2,3";

$timer = &ts;
&do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_measure_sign_updated");
&do_statement("CREATE TEMPORARY TABLE IF NOT EXISTS itmp_measure_sign_updated (
catid   int(13)     NOT NULL,
langid  smallint(5) NOT NULL,
updated timestamp,
KEY        (updated, catid),
UNIQUE KEY (catid, langid))");

&do_statement("INSERT INTO itmp_measure_sign_updated(catid, langid, updated)
SELECT cf.catid, ms.langid, ms.updated
FROM measure_sign ms
INNER JOIN measure m ON ms.measure_id = m.measure_id
INNER JOIN feature f ON m.measure_id = f.measure_id
INNER JOIN category_feature cf ON cf.feature_id = f.feature_id
WHERE ms.updated > ms.last_published");

print &do_query_dump("EXPLAIN ".$ms_select) if $show_explains;

&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated) ".$ms_select);

print "\tmeasure_signs:\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# update last_published value for measure_sign table

$timer = &ts;
&do_statement("update measure_sign set last_published = " . &str_sqlize($now) . ", updated = updated");
print "\tupdate measure_sign with the new dates:\t" . &rc . " rows were modified (".&dts($timer)." sec)\n\n";


#
################### FEATURE_VALUES_VOCABULARY
#

# get category_features list (where we have standardized values)
&do_statement("drop temporary table if exists itmp_cf");
&do_statement("create temporary table itmp_cf (category_feature_id int(13) primary key)");
&do_statement("insert ignore into itmp_cf (category_feature_id)
select category_feature_id from category_feature where trim(restricted_search_values) != ''");

# get key_value + langid list (updated only)
&do_statement("drop temporary table if exists itmp_voc");
&do_statement("create temporary table itmp_voc (
value   varchar(255) primary key,
langid  int(13)      not null default 0,
updated timestamp,
key (value, langid),
key (langid))");

&do_statement("insert ignore into itmp_voc (value, langid, updated)
select key_value value, langid, max(updated) updated
from feature_values_vocabulary
where updated > last_published
group by key_value, langid");

# complete actual_product table with the new product_id + langid values from fvv 
# langid = 0 (INT)
$timer = &ts;
&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated)
SELECT pf.product_id, '1' AS langid, tv.updated, 0
FROM product_feature pf
INNER JOIN itmp_cf  tc       ON pf.category_feature_id = tc.category_feature_id
INNER JOIN itmp_voc tv       ON pf.value = tv.value
INNER JOIN product_memory p  ON p.product_id = pf.product_id
".$described_only_join."
LEFT  JOIN actual_product ap ON p.product_id = ap.product_id AND ap.langid = 1
WHERE tv.langid = 1
AND   tv.updated > p.updated
AND   (tv.updated > ap.updated OR ap.updated IS NULL)
GROUP BY pf.product_id");

print "\tfeature values vocabulary (International):\t" . &rc . " products+langids were inserted (".&dts($timer)." sec)\n";

# langid > 0 (EN, NL, ...)
$timer = &ts;
my $pfl_langids = &do_query("select langid from product_feature_local group by 1");
my $pfl_count = 0;
foreach my $l (@$pfl_langids) {
	&do_statement("REPLACE INTO actual_product (product_id, langid, updated, xml_updated)
SELECT pfl.product_id, ".$l->[0].", tv.updated, 0
FROM product_feature_local pfl
INNER JOIN itmp_cf  tc       ON pfl.category_feature_id = tc.category_feature_id
INNER JOIN itmp_voc tv       ON pfl.value = tv.value AND pfl.langid = tv.langid
INNER JOIN product_memory p  ON p.product_id = pfl.product_id
".$described_only_join."
LEFT  JOIN actual_product ap ON p.product_id = ap.product_id AND ap.langid = tv.langid
WHERE tv.updated > p.updated
AND   (tv.updated > ap.updated OR ap.updated IS NULL)
AND   pfl.langid = ".$l->[0]." AND tv.langid = ".$l->[0]." AND ap.langid = ".$l->[0]."
GROUP BY pfl.product_id");
	$pfl_count += &do_query("select row_count()")->[0][0];
}

print "\tfeature values vocabulary (Localized):\t\t" . &rc($pfl_count) . " products+langids were inserted (".&dts($timer)." sec)\n";

$timer = &ts;
&do_statement("update feature_values_vocabulary v inner join itmp_voc tv on v.key_value = tv.value set v.last_published = NOW(), v.updated = v.updated");
print "\tupdate feature_values_vocabulary with the new dates:\t" . &rc . " rows were modified (".&dts($timer)." sec)\n\n";

# remove obsolete product_id+langid pairs

$timer = &ts;
my $langs = &do_query("SELECT langid, short_code FROM language ORDER BY langid ASC");
print "\tremove obsolete product_id+langid pairs:\t";
foreach my $lang (@$langs) {
	print $lang->[1]."(";
	&do_statement("DELETE ap FROM actual_product ap INNER JOIN product_memory p USING (product_id) WHERE ap.updated < p.updated and ap.langid = ".$lang->[0]);
	print &rc.") ";
}

print "products+langids were removed (".&dts($timer)." sec)\n";

$timer = &ts;
&do_statement("delete from actual_product where updated < from_unixtime(unix_timestamp() - ".$two_days_ago.")");
print "\t".&rc." ancient products+langids were removed (".&dts($timer)." sec)\n";

print "\nACTUAL PRODUCT+LANGID PAIRS:\t\033[1m\033[32m" . &do_query("SELECT COUNT(*) FROM actual_product")->[0][0] . "\033[37m\033[0m\n";

exit(0);

 ########
## subs ##
 ########

sub ts {
	my $t_ts = Time::HiRes::time();
	return sprintf("%.2f", $t_ts);
} # sub ts

sub dts {
	my ($old) = @_;
	my $t_ts = Time::HiRes::time();
	my $res = sprintf("%.2f", $t_ts - $old);
	$res =~ s/^-//;
	return "\033[1m\033[31m".$res."\033[37m\033[0m";
} # sub dts

sub rc {
	my ($value) = @_;
	my $rcnt = defined $value ? $value : &do_query("select row_count()")->[0][0];
	return "\033[1m\033[3".($rcnt?"2":"7")."m".$rcnt."\033[37m\033[0m";
} # sub rc

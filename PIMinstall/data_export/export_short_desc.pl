#!/usr/bin/perl

use lib '/home/pim/lib';
#use lib '/home/dima/gcc_svn/lib';

use atomcfg;
use atomsql;
use atomlog;
use atom_util;
use Data::Dumper;

use strict;

my $csv_file;
my $dir_path = $atomcfg{'www_path'}."export/levelplus/";
`/bin/mkdir -p $dir_path`;
my $csv_file_path = $dir_path."products_summary.csv";
my $langid = 1;
my $all_product_ids = &do_query("SELECT product_id FROM product");
my @product_ids;
foreach my $temp(@$all_product_ids) {
    push (@product_ids, $temp->[0])
}
print "processing...\n";
for (my $i=0; $i<@product_ids; $i++) {
  my $product_id = @product_ids[$i];
  my $product = &do_query("SELECT supplier_id, prod_id, name FROM product WHERE product_id = ".&str_sqlize($product_id));
  my $supplier_id = $product->[0][0];
  my $supplier_name = &do_query("SELECT name FROM supplier WHERE supplier_id = ".&str_sqlize($supplier_id));
  $csv_file .= "$product_id \t $product->[0][1] \t $supplier_name->[0][0] \t $product->[0][2] \t ";
  my $specs = &do_query("SELECT vocabulary.value, product_feature.value, measure.sign, 
				category_feature_group.feature_group_id, my_vocab.value
	FROM product_feature, category_feature, feature, vocabulary, measure, category_feature_group, feature_group,
	    vocabulary AS my_vocab
	WHERE product_feature.category_feature_id = category_feature.category_feature_id
	    AND feature.measure_id = measure.measure_id
    	    AND feature.feature_id = category_feature.feature_id
	    AND category_feature.category_feature_group_id = category_feature_group.category_feature_group_id
	    AND category_feature_group.feature_group_id != 0
    	    AND feature_group.feature_group_id = category_feature_group.feature_group_id
	    AND vocabulary.sid = feature.sid
    	    AND vocabulary.langid = ".&str_sqlize($langid)."
	    AND my_vocab.sid = feature_group.sid
	    AND my_vocab.langid = ".&str_sqlize($langid)."
	    AND product_feature.value <> ''
	    AND product_feature.product_id = ".&str_sqlize($product_id)."
	ORDER BY category_feature_group.no DESC, (category_feature.searchable * 10000000 + (1 - feature.class) * 100000 + category_feature.no) DESC");
  my ($specs_string, %seen, $flag);
  for (my $i=0; $i<=$#$specs; $i++) {
    $flag = 0;
    for (my $k=($i+1); $k<=$#$specs; $k++) {
      if ($specs->[$i][3] == $specs->[$k][3]) {
        $flag = 1;
      }
    }
    if (($specs->[$i][1] eq 'N') or ($specs->[$i][1] eq 'Y') or ($specs->[$i][1] eq 'no') or ($specs->[$i][1] eq 'yes')) {
      if (!$flag) {
        substr($specs_string, -2) = "";
	$specs_string .= "; "
      }
      next;
    }
    if (($seen{$specs->[$i][1]}) and ($seen{$specs->[$i][3]})) {
      if (!$flag) {
        substr($specs_string, -2) = "";
	$specs_string .= "; "
      }
      next;
    }
    my $flag2 = 0;
    for (my $k=0; $k<$i; $k++) {
      if ($specs->[$i][1] lt $specs->[$k][1]) {
        $flag2 = 1;
      }
    }
    if (($flag2) and ($seen{$specs->[$i][3]})) {
      if (!$flag) {
        substr($specs_string, -2) = "";
	$specs_string .= "; "
      }
      next;
    }
    if (!$seen{$specs->[$i][3]}) {
      $specs_string .= $specs->[$i][4].": ";
    }
    $specs_string .= $specs->[$i][1].$specs->[$i][2];
    if (!$flag) {
      $specs_string .= "; ";
    } else {
      $specs_string .= ", ";
    }
    $seen{$specs->[$i][1]} = 1;
    $seen{$specs->[$i][3]} = 1;
  }
  
  $specs_string =~s/[\r\n]/ /gsm;
  $specs_string =~s/ +/ /gsm;
  
  
  $csv_file .= $specs_string."\n";
}

print "done...\n";
open(CSV, ">".$csv_file_path) or die "can't open $csv_file_path: $!";
binmode CSV, ":utf8";
print CSV $csv_file;
close CSV;
print "file saved...\n";

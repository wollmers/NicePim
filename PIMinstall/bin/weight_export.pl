#!/usr/bin/perl

use lib "/home/pim/lib";
use atomsql;

my $filename = "./weights.txt";

my $products = &do_query("SELECT p.product_id, p.prod_id, s.supplier_id, s.name, p.name FROM product p LEFT JOIN supplier s ON p.supplier_id=s.supplier_id WHERE p.user_id <> 1");

open(DATAFILE, '>'.$filename);
print DATAFILE "product_id\tprod_id\tsupplier_id\tsupplier_name\tproduct_name\tnetto\tbrutto\n";

foreach(@$products){
   my $weight_1 = &do_query("SELECT pf.value FROM product_feature pf JOIN category_feature cf ON cf.category_feature_id = pf.category_feature_id JOIN feature f ON cf.feature_id = f.feature_id WHERE f.feature_id = 14 AND pf.product_id=".&str_sqlize($_->[0]))->[0][0];
   my $weight_2;
   if(!$weight_1 || $weight_1 =~ /[^0-9.,]/){
      $weight_2 = &do_query("SELECT pf.value FROM product_feature pf JOIN category_feature cf ON cf.category_feature_id = pf.category_feature_id JOIN feature f ON cf.feature_id = f.feature_id WHERE f.feature_id = 94 AND pf.product_id=".&str_sqlize($_->[0]))->[0][0];
   }
   my $weight_3 = &do_query("SELECT pf.value FROM product_feature pf JOIN category_feature cf ON cf.category_feature_id = pf.category_feature_id JOIN feature f ON cf.feature_id = f.feature_id WHERE f.feature_id = 762 AND pf.product_id=".&str_sqlize($_->[0]))->[0][0];

   if($weight_1 && $weight_1 !~ /[^0-9.,]/){
      $_->[5] = $weight_1 * 1000.0;
   }elsif($weight_2 && $weight_2 !~ /[^0-9.,]/){
      $_->[5] = $weight_2 * 1.0;
   }else{
      $_->[5] = -1;
   }
   if($weight_3 && $weight_3 !~ /[^0-9.,]/){
      $_->[6] = $weight_3 * 1.0;
   }else{
      $_->[6] = -1;
   }
   
   print DATAFILE $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t".$_->[4]."\t".$_->[5]."\t".$_->[6]."\n";
}

close DATAFILE;


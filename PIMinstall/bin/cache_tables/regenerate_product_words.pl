#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
use atomsql;
use atomcfg;
use strict;
use process_manager;
my $time_start = Time::HiRes::time();
use utf8;


if (&get_running_perl_processes_number('regenerate_product_words.pl') != 1) {
	print "'regenerate_product_words.pl' already running. exit.\n";
	 exit;
}

#&do_statement("DROP temporary TABLE tmp_product_words");
&do_statement("CREATE temporary TABLE tmp_product_words LIKE product_words");

open LASTDATE,$atomcfg{'base_dir'}.'bin/cache_tables/regenerate_product_words.date'; 
my $last_check=<LASTDATE>;
$last_check=~s/\n\s\t//gs;
my $date_sql;
my $csv_file=$atomcfg{'base_dir'}.'bin/cache_tables/regenerate_product_words_all_products.csv';
if(!$last_check){
	$date_sql='';
	open CSV,'>'.$csv_file;
}else{
	$date_sql="WHERE unix_timestamp(updated)>=$last_check";
}
close LASTDATE;


my $curr_time=&do_query('SELECT unix_timestamp()')->[0][0];					   
my $products=&do_query("SELECT product_id,prod_id,name FROM product ".$date_sql.' ');
my $file=$atomcfg{'base_dir'}.'bin/cache_tables/regenerate_product_words.date';
open LASTDATE,'>',$file;
print LASTDATE $curr_time;
close LASTDATE;


my $spliter="\\s\\n\\-,\\.&\\(\\)=_;";
foreach my $product (@$products){
        my $prod_id=$product->[1];
        my $name=$product->[2];
        my @words=(split(/[$spliter]+/,$prod_id), split(/[$spliter]+/,$name));
        my $cnt=0;
        # word combinations by prod_id
        while($prod_id=~/^([^$spliter]+)[$spliter]+/i){
                $prod_id=~s/^[^$spliter]+[$spliter]+//;
                push(@words,$prod_id);
                $cnt++;
                last if $cnt==1000;
        }
        push(@words,$prod_id);# the rest
        push(@words,$product->[1]);# original value
        # word combinations by name
        while($name=~/^([^$spliter]+)[$spliter]+/i){
                my $tmp=$1;
                $name=~s/^[^$spliter]+[$spliter]+//;
                push(@words,$name);
                $cnt++;
                last if $cnt==1000;
        }
        push(@words,$name);# the rest
        push(@words,$product->[2]);# original value
        if($date_sql){
	        my $sql='INSERT IGNORE INTO tmp_product_words (product_id,word,word_rev) VALUES ';
	        my %tmp_hash=map {$_=>1} @words;
	        my @clean_words= keys(%tmp_hash);        
	        foreach my $word (@clean_words){
	                next if length($word)<3;
	                $sql.="($product->[0], ".&str_sqlize($word).", REVERSE(".&str_sqlize($word).")),";
	        }
	        $sql=~s/,$//;
	        &do_statement($sql);
        }else{
	        my %tmp_hash=map {$_=>1} @words;
	        my @clean_words= keys(%tmp_hash);
	        my $csv_str;        
	        foreach my $word (@clean_words){
	                next if length($word)<3;
	                my $rev_word=reverse($word);
	                print CSV $product->[0].','.toCSV($word).','.toCSV($rev_word)."\n"; 
	        }        	
        }

}
if($date_sql){
	&do_statement('CREATE TEMPORARY TABLE tmp_product_words_id AS 
					SELECT product_id FROM tmp_product_words GROUP BY product_id');
	&do_statement('ALTER TABLE tmp_product_words_id ADD UNIQUE KEY(product_id)');						
	&do_statement('DELETE product_words pw FROM product_words pw  JOIN tmp_product_words_id tpw  USING(product_id) ');
	&do_statement('INSERT IGNORE INTO product_words (product_id,word,word_rev) 
				   SELECT product_id,word,word_rev FROM tmp_product_words');
}else{	
	close(CSV);
	&do_statement("TRUNCATE TABLE product_words");
	&do_statement("load data local infile '$csv_file' into table product_words fields 
					TERMINATED by ',' ENCLOSED BY '\"' 
					(\@var1,\@var2,\@var3) SET product_id=\@var1, word=\@var2, word_rev=\@var3");	
}
sub toCSV{
	my $str=shift;
	$str=~s/"/""/gs;
	return '"'.$str.'"';	
}
print "\n---------->".(Time::HiRes::time()-$time_start);



exit;
        
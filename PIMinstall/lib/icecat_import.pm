package icecat_import;

#$Id: icecat_import.pm 3773 2011-02-01 14:06:18Z alexey $

# imports engine for ICEcat
# dima@icecat.biz

use strict;

use atomcfg;
use atomlog;
use atomsql;
use thumbnail;
use atom_misc;
use icecat_util;

use data_management;
use feature_values;
use atom_util;
use icecat_mapping;

use XML::LibXML;

use HTML::Entities;
use Data::Dumper;
use IO::File;

use vars qw($time $tmp_tables $cd $br $ua $feature_code_extractor);

 ########
##      ##
## init ##
##      ##
 ########

$| = 1;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw(
							 &get_basic_hash
							 &get_prefs
							 &get_text_tag

							 &download_datapacks

							 &prepare_tables

							 &open_CSVs
							 &load_to_CSVs
							 &close_CSVs

							 &loading_CSVs_to_tables
							 &additional_columns_to_tables

							 &first_category_mapping
							 &second_category_mapping
							 &post_category_mapping_report
							 &feature_mapping
							 &feature_values_mapping
							 &post_feature_mapping_report
							 &category_feature_mapping
							 &post_category_feature_mapping_report
							 &product_related_id_mapping
							 &post_product_related_id_mapping
							 &product_ean_codes_mapping
							 &drop_unmapped_mappings
							 &generate_updated_and_added_product_list

							 &add_products
							 &add_product_names
							 &add_product_descriptions
							 &product_features_preprocessing
							 &power_feature_values_mapping
							 &add_product_features
							 &add_product_related
							 &add_product_related_2
							 &add_product_ean_codes
							 &add_product_bullets
							 &fill_product_locals
							 &product_id_mapping
							 &reload_tmp_icecat_product
							 &add_product_gallery
							 &product_gallery_mapping
							 
							 &add_symbols2mapping

							 &get_picture_last_modified_from_server
							 &get_picture_size_from_server
							 &get_picture_size_from_file
							 &get_picture_content_length_from_server
							 &parse_doc
							 &supplier_mapping
							 &child
							 &childs
							 &attr
							 &text_value
							 &xml2db
							 &name

							 &get_picture_content_type_from_server
							 &post_supplier_mapping_report
							 &translate_features
							 &cleanup_tmp_feature_values
							 &email_error
							 );

	$time = 0;
	$tmp_tables = {
		'P' =>   'product',
		'PN' =>  'product_name',
		'PD' =>  'product_description',
		'PF' =>  'product_feature',
		'PR' =>  'product_related',
		'PEC' => 'product_ean_codes',
		'PB' =>  'product_bullet',
		'PFL' => 'product_file',
		'PG' =>  'product_gallery'
	};

	# mapping units
	$cd = "\\"; # category delimiter
	$br = "\n"; # feature value breaker
	
	$ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;
	$ua->agent('Mozilla/5.0');
	$feature_code_extractor='';
}
sub get_basic_hash {
	my ($hash,$datapacks_dir_name) = @_;

	# main IDs
	$hash->{'data_source_id'} = do_query("select data_source_id from data_source where code=".str_sqlize($hash->{'data_source_code'}))->[0][0] || return undef;
	$hash->{'supplier_id'} = do_query("select supplier_id from supplier where name=".str_sqlize($hash->{'supplier_name'}))->[0][0] || return undef;
	
	# user IDs
	$hash->{'own_user_id'} = do_query("select user_id from supplier where name=".str_sqlize($hash->{'supplier_name'}))->[0][0] || return undef;
	$hash->{'nobody_user_id'} = do_query("select user_id from users where login='nobody'")->[0][0] || return undef;
	
	# import paths
	$hash->{'base'} = $atomcfg{'base_dir'}.'data_source/'.$hash->{'data_source_code'}.'/';
	chomp($datapacks_dir_name);
	$hash->{'datapacks_path'} = $hash->{'base'}.($datapacks_dir_name?$datapacks_dir_name:lc($hash->{'data_source_code'})).'/';
	$hash->{'archive_path'} = $hash->{'base'}.'/archive/';
	$hash->{'history_path'} = $hash->{'base'}.'/history/';
	$hash->{'csv_path'} = $hash->{'base'}.'/csv/';
	$hash->{'server_path'} = $atomcfg{'www_path'};

	# check the import starting
	do_statement("update data_source set updated=now() where data_source_id=".$hash->{'data_source_id'});

	return 1;
} # sub get_basic_hash

sub get_prefs {
	my ($hash) = @_;

	my $prefs = get_rows('data_source', " code = ".str_sqlize($hash->{'data_source_code'}))->[0];
	$prefs->{'total_products'} = 0;
	$prefs->{'updated_products'} = 0;
	$prefs->{'added_products'} = 0;
	$prefs->{'not_updated'} = 0;
	$prefs->{'ignored_products'} = 0; 

	return $prefs;
} # sub get_prefs

sub download_datapacks {
	my ($hash,$download_debug) = @_;
	return if ($download_debug);
	my ($cmd);

	my $subs = $hash->{'subscription'};
	for my $s (@$subs) {
		$cmd = "/bin/rm ".$hash->{'datapacks_path'}.$s;
		print "$cmd\n";
		`$cmd`;
		$cmd = "/usr/bin/wget -q ".$hash->{'ftp'}.$s." -O ".$hash->{'datapacks_path'}.$s." -a ".$atomcfg{'logfile'};
		print "$cmd\n";
		`$cmd`;
	}
} # sub download_datapacks

sub prepare_tables {
	my ($hash) = @_;
	my $tables = $hash->{'tables'};
	# product table
	do_statement("create temporary table tmp_product ( 	
tmp_product_id int(13)      not null default '0',
prod_id        varchar(255) not null default '',
cat            varchar(255) not null default '',
name           varchar(255) not null default '',
low_pic        varchar(255) not null default '',
high_pic       varchar(255) not null default '',
thumb_pic      varchar(255) not null default '',
file           varchar(255) not null default '',
supplier       varchar(255) not null default '')");

	# product_name table
	if ($tables->{'product_name'}) {
		do_statement("create temporary table tmp_product_name (
tmp_product_name_id int(13)      not null primary key auto_increment,
tmp_product_id      int(13)      not null default '0',
name                varchar(255) not null default '',
langid              int(5)       not null default '0')");
	}

	# product_description
	if ($tables->{'product_description'}) {
		do_statement("create temporary table tmp_product_description (
tmp_product_description_id int(13)      not null primary key auto_increment,
tmp_product_id             int(13)      not null default '0',
langid                     int(5)       not null default '0',
short_desc                 text,
long_desc                  text,
url                        varchar(255) not null default '',
pdf_url                    varchar(255) not null default '',
warranty_info              mediumtext,
option_field_1             mediumtext,
manual_pdf_url             varchar(255) not null default '')");
	}

	# product_feature (field feature_name - for automated features naming)
	if ($tables->{'product_feature'}) {
		do_statement("create temporary table tmp_product_feature (
tmp_product_feature_id int(13)      not null primary key auto_increment,
tmp_product_id         int(13)      not null default '0',
langid                 int(5)       not null default '0',
symbol                 varchar(255) not null default '',
feature_name           varchar(255) not null default '',
value                  text,
level                  varchar(30)  not null default '')");
	}
	
	# product_related
	if ($tables->{'product_related'}) {
		do_statement("create temporary table tmp_product_related (
tmp_product_related_id int(13)       not null primary key auto_increment,
tmp_product_id         int(13)       not null default '0',
related_prod_id        varchar(255)  not null default '',
preferred_option       int(1)        not null default '0')");
	}

	# product_ean_codes (should be another product_id mapping)
	if ($tables->{'product_ean_codes'}) {
		do_statement("create temporary table tmp_product_ean_codes (
tmp_product_ean_codes_id int(13)      not null primary key auto_increment,
tmp_product_id           int(13)      not null default '0',
prod_id                  varchar(255) not null default '0',
ean_code                 char(13)     not null default '')");
	}

	# product_bullet
	if ($tables->{'product_bullet'}) {
		do_statement("create temporary table tmp_product_bullet (
tmp_product_bullet_id int(13)      not null primary key auto_increment,
tmp_product_id        int(13)      not null default '0',
langid                int(5)       not null default '0',
code                  varchar(255) not null default '',
value                 varchar(255) not null default '')");
	}

	# product_file
	if ($tables->{'product_file'}) {
		do_statement("create temporary table tmp_product_file (
tmp_product_file_id int(13)      not null primary key auto_increment,
tmp_product_id      int(13)      not null default '0',
external_id         int(13)      not null default '0',
file                varchar(255) not null default '')");
	}

	# product_gallery
	if ($tables->{'product_gallery'}) {
		do_statement("create temporary table tmp_product_gallery (
tmp_product_gallery_id int(13)      not null primary key auto_increment,
tmp_product_id         int(13)      not null default '0',
type                   varchar(60)  not null default '',
url                    varchar(255) not null default '',
content_length         int(13)      not null default 0,
product_id	       int(13)      not null default 0,
UNIQUE KEY (tmp_product_id,type),
key (tmp_product_id))");
	}

	## after mappings
	# product_locals
	do_statement("create temporary table tmp_locals (
tmp_locals_id    int(13) not null primary key auto_increment,
product_id       int(13) not null default '0',
product_id_local int(13) not null default '0',
owned            int(5)  not null default '1')");
} # sub prepare_tables

sub open_CSVs {
	my ($hash,$fake) = @_;
	my $handle;
	for my $file (keys %$tmp_tables) {
		if ($hash->{'tables'}->{$tmp_tables->{$file}}) {
			$hash->{'filenames'}->{$file} = $tmp_tables->{$file};
			next if $fake;
			$handle = new IO::File;
			open($handle, "> ".$hash->{'csv_path'}.$tmp_tables->{$file}.".csv");
			$handle->binmode(":utf8");
			$hash->{'handles'}->{$file} = $handle;
		}
	}
} # sub open_CSVs

sub load_to_CSVs {
	my ($hash) = @_;
#	print Dumper($hash);
#	die;
	my ($hndl);
	my $handles = $hash->{'handles'};
	for my $bfile (keys %$handles) {
		$hndl = $hash->{'handles'}->{$bfile};
		print $hndl $hash->{'content'}->{$bfile};
	}
} # sub load_to_CSVs

sub close_CSVs {
	my ($hash) = @_;
	my $handles = $hash->{'handles'};	
	for my $file (keys %$handles) {
		undef $hash->{'handles'}->{$file};
	}
} # sub close_CSVs

sub loading_CSVs_to_tables {
	my ($hash,$prefs) = @_;
	my ($handles);
	my $handles = $hash->{'filenames'};
	for my $file (keys %$handles) {
		do_statement("load data local infile \"".$hash->{'csv_path'}.$handles->{$file}.".csv\" into table tmp_".$handles->{$file}." fields escaped by '' terminated by ".str_sqlize($hash->{'csvd'})." lines terminated by ".str_sqlize($hash->{'csvn'}));
	}
	$prefs->{'total_products'} = do_query("select count(*) from tmp_product")->[0][0];
} # sub loading_CSVs_to_tables

sub additional_columns_to_tables {
	my ($hash) = @_;

	# columns
	if ($hash->{'tables'}->{'product'}) {
		do_statement("alter table tmp_product add column product_id int(13) not null default 0,
add column catid int(13)       not null default 0,
add column supplier_id int(13) not null default 0,
add key (prod_id),
add key (tmp_product_id),
add key (product_id)");
	}

	if ($hash->{'tables'}->{'product_name'}) {
		do_statement("alter table tmp_product_name add key (tmp_product_id)");
	}

	if ($hash->{'tables'}->{'product_description'}) {
		do_statement("alter table tmp_product_description add key (tmp_product_id)");
	}

	if ($hash->{'tables'}->{'product_feature'}) {
		do_statement("alter table tmp_product_feature
add column pattern                    varchar(255) not null default '',
add column feature_id                 int(13)      not null default '0',
add column category_feature_id        int(13)      not null default '0',
add column data_source_feature_map_id int(13)      not null default '0',
add key (tmp_product_id),
add key (level),
add key (symbol),
add key (value(255))");
	}
	
	if ($hash->{'tables'}->{'product_related'}) {
		do_statement("alter table tmp_product_related add column product_id int(13) not null default '0',
add column related_product_id int(13) not null default '0',
add key (related_prod_id),
add key (tmp_product_id)");
	}

	if ($hash->{'tables'}->{'product_ean_codes'}) {
		do_statement("alter table tmp_product_ean_codes add column product_id int(13) not null default '0',
add key (tmp_product_id)");
	}

	if ($hash->{'tables'}->{'product_bullet'}) {
		do_statement("alter table tmp_product_bullet add column product_id int(13) not null default '0',
add key (tmp_product_id)");
	}

	if ($hash->{'tables'}->{'product_file'}) {
		do_statement("alter table tmp_product_file add key (tmp_product_id)");
	}
} # sub additional_columns_to_tables

# $select - select catid, symbol from table

sub first_category_mapping {
	my ($select,$update_symbols) = @_;
	my ($case,$us);
  # first mapping
  do_statement("create temporary table tmp_category_map (
tmp_category_map_id int(13)      NOT NULL PRIMARY KEY auto_increment,
catid               int(13)      NOT NULL default '0',
symbol              varchar(255) NOT NULL default '')");
  # insert nonregexp values
  do_statement("insert into tmp_category_map(catid,symbol)".$select);
  # alter table keys
	if ($update_symbols) {
		do_statement("alter table tmp_product add column cat_pattern varchar(255) not null default ''");
		$us = $update_symbols;
		$us =~ s/\*/cat/s;
		do_statement("update tmp_product set cat_pattern=".$us);
		do_statement("alter table tmp_category_map add column symbol_pattern varchar(255) not null default ''");
		$us = $update_symbols;
		$us =~ s/\*/symbol/s;
		do_statement("update tmp_category_map set symbol_pattern=".$us);

		$case = "tp.cat_pattern=tcm.symbol_pattern";
		do_statement("alter table tmp_category_map add key (catid), add key (symbol_pattern)");		
		do_statement("alter table tmp_product add key cat_pattern (cat_pattern)");		
	}
	else {
		$case = "tp.cat=tcm.symbol";
		do_statement("alter table tmp_category_map add key (catid), add key (symbol)");
	}
  do_statement("update tmp_product tp inner join tmp_category_map tcm on ".$case." set tp.catid=tcm.catid where tp.catid=0");
  do_statement("drop temporary table tmp_category_map");
	
	if ($update_symbols) {
		do_statement("alter table tmp_product drop key cat_pattern");
		do_statement("alter table tmp_product drop column cat_pattern");
	}	
  return do_query("select count(*) from tmp_product where catid!=0")->[0][0];
} # sub first_category_mapping

sub second_category_mapping {
	my ($hash) = @_;

	# begin from pricelist.txt
	# making left pattern table
	do_statement("create temporary table tmp_catid_patterns (
tmp_catid_patterns_id       int(13)      not null primary key auto_increment,
data_source_category_map_id int(13)      not null,
catid                       int(13)      not null,
left_mysql_pattern          varchar(255) not null,
pattern                     varchar(255) not null,
frequency                   int(13)      not null,
distributor_id              int(13)      not null)");
	# load local infile
	icecat2mysql_mapping($hash,"select data_source_category_map_id,catid,symbol,frequency,distributor_id from data_source_category_map
where data_source_id=".$hash->{'data_source_id'}." and symbol like '%*%' order by catid","tmp_catid_patterns");
	
	# create a tmp tmp_product table with catid=0 values
	do_statement("create temporary table tmp_nonmapped_products (
tmp_product_id int(13)      not null primary key,
cat            varchar(255) not null,
catid          int(13)      not null,
mapped         tinyint(3)   not null default '0')");
	do_statement("insert into tmp_nonmapped_products(tmp_product_id,cat,catid,mapped)
select tmp_product_id,cat,catid,0 from tmp_product where catid=0");	
	do_statement("alter table tmp_nonmapped_products add key (cat), add key (mapped)");

	# second mapping
	my $mappings = do_query("select catid,left_mysql_pattern,tmp_catid_patterns_id from tmp_catid_patterns order by frequency desc");
	my $freq = 0;
	for my $map (@$mappings) {
		do_statement("update tmp_nonmapped_products set mapped=1, catid=".$map->[0]." where mapped=0 and cat REGEXP '".$map->[1]."'");
		$freq = do_query("select ROW_COUNT()")->[0][0];
		if ($freq) {
#			print "map = ".$freq." ".$map->[1]."\n";
			do_statement("update tmp_catid_patterns set frequency=".$freq." where tmp_catid_patterns_id=".$map->[2]);
		}
	}
	
	do_statement("update data_source_category_map set frequency=0 where data_source_id=".$hash->{'data_source_id'});
	do_statement("update data_source_category_map dscm inner join tmp_catid_patterns tcp
on dscm.data_source_category_map_id=tcp.data_source_category_map_id
set dscm.frequency=tcp.frequency");
	do_statement("drop temporary table tmp_catid_patterns");
	do_statement("alter table tmp_nonmapped_products add key (catid)");
	
	# update pricelist
	my $second_catid_mapped_count = do_query("select count(*) from tmp_product where catid=0")->[0][0];
	do_statement("update tmp_product tp inner join tmp_nonmapped_products tnp on tp.tmp_product_id=tnp.tmp_product_id set tp.catid=tnp.catid");
	$second_catid_mapped_count -= do_query("select count(*) from tmp_product where catid=0")->[0][0];
	do_statement("drop temporary table tmp_nonmapped_products");
	
	# add catid key
	do_statement("alter table tmp_product add key (catid)");

	return $second_catid_mapped_count;	
} # sub second_category_mapping

sub post_category_mapping_report {
	my ($hash,$prefs) = @_;

	my ($ignored_products);
	# reports about undefcat_values
	my $undef_cats = do_query("select prod_id, name, cat from tmp_product where catid=0");
	for (@$undef_cats) {
    log_ignored_product($prefs, {
			'productcode vendor' => $_->[0],
			'supplier' => $hash->{'data_source_code'},
			'name' => $_->[1],
			'subcat' => $_->[2]}, 'category missing');
		$hash->{'missing'}->{'category'}->{$_->[2]}=0;
	}

	# delete unmapped products
	$ignored_products = delete_products_by_query($hash,"select tmp_product_id from tmp_product where catid=0");
	$prefs->{'ignored_products'} += $ignored_products;

	return $ignored_products;
} # sub post_category_mapping_report

sub post_supplier_mapping_report {
	my ($hash,$prefs) = @_;

	my ($ignored_products);
	# reports about undefcat_values
	my $undef_suppliers = do_query("select prod_id, supplier, name from tmp_product where supplier_id=0");
	for (@$undef_suppliers) {
    log_ignored_product($prefs, {
			'productcode vendor' => $_->[0],
			'supplier' => $_->[1] !~ /^\s*$/s ? $_->[1] : '(unassigned brand)',
			'name' => $_->[2],
												 }, 
												 'supplier missing');
		$hash->{'missing'}->{'supplier'}->{$_->[1]}=0;
	}

	# delete unmapped products
	$ignored_products = delete_products_by_query($hash,"select tmp_product_id from tmp_product where supplier_id=0");
	$prefs->{'ignored_products'} += $ignored_products;

	return $ignored_products;		
}

sub feature_mapping {
	my ($hash,$set,$no_Perl_formatting) = @_;
	## use default $set if absent
	$set = 'symbol' unless $set;
	$feature_code_extractor=$set;

	## creating feature mapping tmp table
	do_statement("create temporary table tmp_feature_map (
data_source_feature_map_id int(13)      NOT NULL default '0',
feature_id                 int(13)      not null default '0',
symbol                     varchar(255) not null default '',
pattern                    varchar(64)  not null default '',
override_value_to          mediumtext,
coef                       varchar(255) NOT NULL default '',
format                     varchar(255) not null default '',
only_product_values        tinyint      not null default '0',
catid                      int(13)      not null default '0')");
	
	do_statement("insert into tmp_feature_map (data_source_feature_map_id,feature_id,symbol,pattern,override_value_to,coef,format,only_product_values,catid) select data_source_feature_map_id,feature_id,symbol,'',override_value_to,coef,format,only_product_values,catid from data_source_feature_map where data_source_id = ".$hash->{'data_source_id'});

	do_statement("update tmp_feature_map set pattern = ".$set);
	do_statement("alter table tmp_feature_map add key (pattern,catid), add key (data_source_feature_map_id), add key (only_product_values)");

	do_statement("update tmp_product_feature set pattern = ".$set);
	do_statement("alter table tmp_product_feature add key (pattern)");

	## execute mapping
	do_statement("update tmp_product_feature tpf
inner join tmp_feature_map tfm on tpf.pattern=tfm.pattern
inner join tmp_product tp on tp.tmp_product_id=tpf.tmp_product_id and tfm.catid=tp.catid
set tpf.feature_id=tfm.feature_id, tpf.data_source_feature_map_id=tfm.data_source_feature_map_id");
#	my $first_feature_id_mapped_count = do_query("select ROW_COUNT()")->[0][0];
	do_statement("update tmp_product_feature tpf
inner join tmp_feature_map tfm on tpf.pattern=tfm.pattern and tfm.catid=1
set tpf.feature_id=tfm.feature_id, tpf.data_source_feature_map_id=tfm.data_source_feature_map_id
where tpf.feature_id=0");
#	$first_feature_id_mapped_count += do_query("select ROW_COUNT()")->[0][0];
	do_statement("alter table tmp_product_feature add key (feature_id), add key (data_source_feature_map_id)");
	
	# COLLECT example values 
	my $available_langs=do_query("SELECT langid FROM tmp_product_feature WHERE 1 GROUP BY langid");
	sub cleanup{# to be used in map statement
		my $str=shift;
		$str=~tr/[\r\n]/ /;
		return $str;
	}
	do_statement('DROP TEMPORARY TABLE IF EXISTS tmp_feature_map_info');
	do_statement('CREATE TEMPORARY TABLE `tmp_feature_map_info` (
					 `data_source_feature_map_info_id` int(13) NOT NULL auto_increment,
					 `langid` int(13) NOT NULL,
					 `symbol` mediumtext NOT NULL,
					 `example_values` text,
					 `data_source_id` int(13) NOT NULL,
					 `used_in` int(13) NOT NULL default 0,
					 PRIMARY KEY  (`data_source_feature_map_info_id`),
					 UNIQUE KEY `symbol` (`symbol`(255),`langid`,`data_source_id`)
					) ENGINE=MyISAM');
		do_statement('ALTER TABLE tmp_product_feature ADD column unique_code varchar(255) not null default \'\',ADD key(unique_code) ');
		do_statement('UPDATE tmp_product_feature SET unique_code='.$set);
		my $feature_names=do_query("SELECT unique_code FROM tmp_product_feature WHERE 1 GROUP BY unique_code");
		for my $feature_name (@$feature_names) {
		my $often_values=[];
		my $seldom_values=[];
		my $longest_values=[];
		my $shortest_values=[];
		$feature_name->[0]=str_sqlize($feature_name->[0]);
		for my $available_lang (@$available_langs){
			if(do_query("SELECT 1 FROM tmp_product_feature where langid=$available_lang->[0] 
						AND value!='' and unique_code = $feature_name->[0] LIMIT 1")->[0][0]){
				$often_values=do_query("SELECT value,count(tmp_product_feature_id) as cnt from 
										tmp_product_feature  WHERE  unique_code = $feature_name->[0]
										 and value!='' and langid=".$available_lang->[0]." 
										GROUP BY value HAVING cnt>1 ORDER BY cnt DESC limit 5");
				$seldom_values=do_query("SELECT value,count(tmp_product_feature_id) as cnt from 
										tmp_product_feature  WHERE  unique_code = $feature_name->[0]
										and value!='' and langid=".$available_lang->[0]." 
										GROUP BY value ORDER BY cnt ASC limit 5");
				$longest_values=do_query("SELECT value from 
										tmp_product_feature  WHERE  unique_code =$feature_name->[0]
										 and value!='' and langid=".$available_lang->[0]."
										GROUP BY value
										ORDER BY length(value) DESC limit 5");
				$shortest_values=do_query("SELECT value from 
										tmp_product_feature  WHERE  unique_code = $feature_name->[0]
										 and value!='' and langid=".$available_lang->[0]."
										GROUP BY value
										ORDER BY length(value) ASC limit 5");
										
				my %unique_values=map {cleanup($_->[0])=>1} (@{$often_values},@{$seldom_values},@{$longest_values},@{$shortest_values});
				my $example_data=join("\n",keys(%unique_values));
				do_statement("INSERT IGNORE INTO tmp_feature_map_info							 
							SET langid=$available_lang->[0],
							symbol=".$feature_name->[0].",
							example_values=".str_sqlize($example_data).",
							data_source_id=".$hash->{'data_source_id'})						
			}																									
		}
		}
	#do_statement('ALTER TABLE tmp_product_feature DROP column unique_code');
	# remember the count of used feature values
	do_statement('DROP temporary TABLE IF EXISTS tmp_feature_use_count');		   
	do_statement('CREATE temporary TABLE tmp_feature_use_count(
						  	symbol mediumtext not null,
						  	data_source_id int(13) not null,
						  	cnt int(13) not null default 0,
						  	UNIQUE KEY(symbol(255),data_source_id))');
	do_statement("INSERT IGNORE INTO tmp_feature_use_count (symbol,data_source_id,cnt) 
				   SELECT fm.symbol,fm.data_source_id,count(tf.tmp_product_id) FROM  tmp_feature_map_info fm
				   JOIN  tmp_product_feature tf ON fm.symbol=tf.unique_code and fm.data_source_id=$hash->{'data_source_id'}
				   GROUP BY fm.data_source_feature_map_info_id");
	do_statement("UPDATE tmp_feature_map_info mi JOIN tmp_feature_use_count cn  USING(symbol,data_source_id) SET mi.used_in=cn.cnt");
			
	## execute not good values deleting
	do_statement("delete tpf from tmp_product_feature tpf
inner join tmp_feature_map tfm using (pattern)
where tfm.only_product_values=1 and tpf.level!='product'");

	unless ($no_Perl_formatting) {
		## execute Perl formatting
		my $feature = do_query("select tpf.tmp_product_feature_id, tfm.coef, tfm.format, tfm.override_value_to, tpf.value, tpf.feature_id
from tmp_product_feature tpf inner join tmp_feature_map tfm using (data_source_feature_map_id)
where tpf.feature_id!=0");
		my ($value);
		for (@$feature) {
		($value, undef) = map_feature_value($_->[5],format_feature_value({'coef' => $_->[1], 'format' => $_->[2], 'override_value_to' => $_->[3]}, $_->[4], ''), $hash->{'missing'});
			do_statement("update tmp_product_feature set value=".str_sqlize($value)." where tmp_product_feature_id=".$_->[0]);
		}
	}
  do_statement("drop temporary table tmp_feature_map");
  cleanup_tmp_feature_values($hash); # remove measure sign or anything else if feature values 
  return do_query("select count(*) from tmp_product_feature where feature_id!=0")->[0][0];
} # sub feature_mapping

sub correct_feature_values {
	my $query = "UPDATE tmp_product_feature SET value='Y' WHERE TRIM(value)='Yes'";
	do_statement($query);
	$query = "UPDATE tmp_product_feature SET value='N' WHERE TRIM(value)='No'";
	do_statement($query);

	$query = "SELECT value, langid FROM feature_values_vocabulary WHERE key_value = 'Yes' AND TRIM(value) != ''";
	my $yes  = do_query($query);
	for (@$yes) {
		$query = "UPDATE tmp_product_feature SET value='Y' WHERE langid=".str_sqlize($_->[1])." AND TRIM(value)=".str_sqlize($_->[0]);
		do_statement($query);
	}

	$query = "SELECT value, langid FROM feature_values_vocabulary WHERE key_value = 'No' AND TRIM(value) != ''";
	my $no  = do_query($query);
	for (@$no) {
		$query = "UPDATE tmp_product_feature SET value='N' WHERE langid=".str_sqlize($_->[1])." AND TRIM(value)=".str_sqlize($_->[0]);
		do_statement($query);
	}
}

sub power_feature_values_mapping {
	my ($dot) = @_;
	correct_feature_values();
	do_statement("alter table tmp_product_feature add column new_value text");
	do_statement("update tmp_product_feature set new_value=value");
	my $feature_id = do_query("select distinct feature_id from tmp_product_feature");

	for (@$feature_id) {
		power_mapping_per_feature_and_measure({'feature_id' => $_->[0]}, 'tmp_product_feature');
		print $dot if ($dot);
	}
	$icecat_mapping::G_table_name = '';
	do_statement("alter table tmp_product_feature drop column value");
	do_statement("alter table tmp_product_feature change new_value value text");
} # sub powerfeature_values_mapping

sub post_feature_mapping_report {
	my ($hash,$prefs) = @_;
	my ($ignored_products);
	## autonaming features (for advice)
	# use it for autonaming cleaning
	do_statement("create temporary table tmp_vocabulary (
  `sid` int(13) NOT NULL default '0',
  `langid` int(3) NOT NULL default '0',
  `value` varchar(255) default NULL,
  UNIQUE KEY `sid_2` (`sid`,`langid`),
  KEY `langid` (`langid`),
  KEY `sid` (`sid`))");
	# update vocabulary with new names & mark autonaming to OFF
	do_statement("update vocabulary v
inner join feature f on v.sid=f.sid 
inner join tmp_product_feature tpf on f.feature_id=tpf.feature_id and v.langid=tpf.langid
inner join feature_autonaming fa on tpf.feature_id=fa.feature_id and tpf.langid=fa.langid and fa.data_source_id=".$hash->{'data_source_id'}."
set v.value=tpf.feature_name, fa.data_source_id=0");
	# insert into tmp_vocabulary values for addding
	do_statement("insert into tmp_vocabulary(sid,langid,value)
select distinct f.sid, tpf.langid, tpf.feature_name from tmp_product_feature tpf
inner join feature f on f.feature_id=tpf.feature_id
inner join feature_autonaming fa on tpf.feature_id=fa.feature_id and fa.data_source_id=".$hash->{'data_source_id'}."
left join vocabulary v on v.sid=f.sid and v.langid=tpf.langid
where v.value is null");
	# delete from autonaming all added values
	do_statement("delete fa from feature_autonaming fa inner join tmp_vocabulary tv on fa.langid=tv.langid inner join feature f on fa.feature_id=f.feature_id and f.sid=tv.sid");
	# clean autonaming
	do_statement("delete from feature_autonaming where data_source_id=0");
	# add values into vocabulary
	do_statement("insert ignore into vocabulary(sid,langid,value) select sid,langid,value from tmp_vocabulary");
	# drop tmp
	do_statement("drop temporary table tmp_vocabulary");

	# reports about undeffeat_values
	do_statement("create temporary table tmp_nonmapped_product_feature (
tmp_product_id int(13) not null,
pattern varchar(255) not null default '',
symbol varchar(255) not null default '',
key (tmp_product_id),
unique key (pattern))");

	do_statement("insert ignore into tmp_nonmapped_product_feature (tmp_product_id,pattern,symbol)
select tmp_product_id,pattern,symbol from tmp_product_feature
where feature_id=0 order by langid asc");
	
	my $undef_feats = do_query("select distinct tp.prod_id,tp.name,tnpf.symbol from tmp_nonmapped_product_feature tnpf
left join tmp_product tp using (tmp_product_id)");

	for (@$undef_feats) {
		$hash->{'missing'}->{'feature'}->{$_->[2]} = {};
		log_ignored_product($prefs, {'productcode vendor' => $_->[0],
                                  'supplier' => $hash->{'data_source_code'},
                                  'name' => $_->[1],
                                  'subcat' => $_->[2]}, 'feature missing');		                                  
	}

	do_statement("drop temporary table tmp_nonmapped_product_feature");

	my $ignored_features = do_query("select count(*) from tmp_product_feature where feature_id=0")->[0][0];
	if ($prefs->{'clean_unmapped_features'}) {
		do_statement("delete from tmp_product_feature where feature_id=0");
	}
	else {
		# drop all product with unmapped feature_ids
		$prefs->{'ignored_products'} += delete_products_by_query($hash,"select distinct tmp_product_id from tmp_product_feature where feature_id=0");
	}	
	return $ignored_features;
} # sub post_feature_mapping_report

sub category_feature_mapping {
	do_statement("create temporary table tmp_icecat_category_feature (
  `category_feature_id` int(13) NOT NULL,
  `feature_id` int(13) NOT NULL default '0',
  `catid` int(13) NOT NULL default '0')");
	do_statement("insert into tmp_icecat_category_feature(category_feature_id,feature_id,catid)
select category_feature_id,feature_id,catid from category_feature");

	do_statement("alter ignore table tmp_icecat_category_feature add primary key (category_feature_id), add unique key (feature_id,catid)");

	do_statement("update tmp_product_feature tpf
inner join tmp_product tp using (tmp_product_id)
inner join tmp_icecat_category_feature ticf on tpf.feature_id=ticf.feature_id and ticf.catid=tp.catid
set tpf.category_feature_id=ticf.category_feature_id");
  my $category_feature_id_mapped_count = do_query("select ROW_COUNT()")->[0][0];
	do_statement("alter table tmp_product_feature add key (category_feature_id)");
	return $category_feature_id_mapped_count;
} # sub category_feature_mapping

sub post_category_feature_mapping_report {
	my ($hash,$prefs) = @_;
	# create category template
	do_statement("create temporary table tmp_icecat_category (
catid int(13) not null primary key,
value varchar(255) not null default '')");
	do_statement("insert into tmp_icecat_category(catid,value)
select catid, CONCAT(v.value,'(',c.catid,')') as value from category c
inner join vocabulary v on c.sid=v.sid and v.langid=1 where catid<>1
order by catid");
	# create feature template
	do_statement("create temporary table tmp_icecat_feature (
feature_id int(13) not null primary key,
value varchar(255) not null default '')");
	do_statement("insert into tmp_icecat_feature(feature_id,value)
select feature_id, CONCAT(fv.value,'(',mv.value,')') as value from feature f
inner join measure m using (measure_id)
inner join vocabulary fv on f.sid=fv.sid and fv.langid=1
inner join vocabulary mv on m.sid=mv.sid and mv.langid=1
order by feature_id");

	# cat_feat to report
	do_statement("create temporary table tmp_category_feature2report (
tmp_product_id int(13) not null default '0',
catid int(13) not null default '0',
feature_id int(13) not null default '0',
value varchar(255) not null default '',
unique key (catid, feature_id))");
	do_statement("insert ignore into tmp_category_feature2report(tmp_product_id,catid,feature_id,value)
select tp.tmp_product_id, tp.catid, tpf.feature_id, CONCAT(tic.value,' - ',tif.value) from tmp_product_feature tpf
left join tmp_product tp using (tmp_product_id)
left join tmp_icecat_category tic using (catid)
left join tmp_icecat_feature tif using (feature_id)
where tpf.category_feature_id=0");
	
	my $undef_catfeats = do_query("select value from tmp_category_feature2report order by catid");
	for (@$undef_catfeats) {
		$hash->{'missing'}->{'category_feature'}->{$_->[0]} = 1;
	}

	my $ignored_cat_feat = do_query("select count(*) from tmp_product_feature where category_feature_id=0")->[0][0];
	if ($prefs->{'clean_unmapped_features'}) {
		do_statement("delete from tmp_product_feature where category_feature_id=0");
	}
	else {
		$prefs->{'ignored_products'} += delete_products_by_query($hash,"select distinct tmp_product_id from tmp_product_feature where category_feature_id=0");
	}

	do_statement("drop table tmp_icecat_category");
	do_statement("drop table tmp_icecat_feature");
	do_statement("drop table tmp_category_feature2report");
	return $ignored_cat_feat;
} # sub post_category_feature_mapping_report

sub add_products {
	my ($hash,$prefs,$locals_pattern) = @_;

	# first product_id_mapping
	product_id_mapping($hash);

	# add additional field to tmp_product to know, what info can be updated (prioritize)
	do_statement("alter table tmp_product add column owned tinyint(1) not null default 1");
	do_statement("update tmp_product tp inner join tmp_icecat_product tip using (product_id)
set tp.owned=0 where tip.user_id!=".$hash->{'own_user_id'}." and tip.user_id!=".$hash->{'nobody_user_id'});
	do_statement("alter table tmp_product add key (owned)");
	
	unless($hash->{'update_only'}){
	## insert products
		do_statement("insert ignore into product(supplier_id,prod_id,catid,user_id,name,date_added)
	select " . ( $hash->{'with_supplier'} ? "supplier_id" : $hash->{'supplier_id'} ) . ", prod_id, catid, '".$hash->{'own_user_id'}."', name, now() from tmp_product where product_id=0");
		$prefs->{'added_products'} = do_query("select ROW_COUNT()")->[0][0];
	}
	# second product_id_mapping
	product_id_mapping($hash);
	
	# fill locals -> now, tmp_locals table appeared
	fill_product_locals($hash,$locals_pattern);
	my $owner_sql;
	if(!$hash->{'ignore_owner'}){
		$owner_sql=", p.user_id=".$hash->{'own_user_id'};
	}
	## update owned products (owned=1)
	do_statement("update product p
inner join tmp_locals tl on p.product_id=tl.product_id_local
inner join tmp_product tp on tl.product_id=tp.product_id
set p.catid=tp.catid, p.name= " . (  $hash->{'data_source_code'} eq 'Brodit' ? "if(p.name='',tp.name,p.name)" : "tp.name" ) . $owner_sql." where tl.owned=1");

	$prefs->{'updated_products'} = do_query("select ROW_COUNT()")->[0][0];
	$prefs->{'not_updated'} = do_query("select count(*) from tmp_locals where owned=0")->[0][0];
} # sub add_products

sub fill_product_locals {
	my ($hash,$locals_pattern) = @_;
	my ($insert);
	do_statement("create temporary table tmp_icecat_product_with_hashes (
product_id int(13)      not null default '0',
prod_id    varchar(255) not null default '',
user_id    int(13)      not null default '0')");
	do_statement("insert into tmp_icecat_product_with_hashes(product_id,prod_id,user_id)
select product_id, prod_id, user_id from tmp_icecat_product");

	my $prods = do_query("select product_id, prod_id, owned from tmp_product where product_id!=0");
	for my $p (@$prods) {
		$insert = "insert into tmp_locals (product_id,product_id_local,owned)
values('".$p->[0]."','".$p->[0]."','".$p->[2]."')";
		if ($locals_pattern) {
			my $locals = do_query("select product_id, if(user_id!=".$hash->{'own_user_id'}." and user_id!=".$hash->{'nobody_user_id'}.",'0','1')
from tmp_icecat_product_with_hashes where prod_id REGEXP '^".$p->[1].$locals_pattern."\$'");
			for my $l (@$locals) {
				$insert .= ",('".$p->[0]."','".$l->[0]."','".$l->[1]."')";
			}
		}
		do_statement($insert);
	}
	do_statement("drop temporary table tmp_icecat_product_with_hashes");
	do_statement("alter table tmp_locals add key (product_id), add key (product_id_local, product_id), add key (owned)");
} # sub fill_product_locals

sub generate_updated_and_added_product_list {
	do_statement("create temporary table tmp_product_snapshot (
product_id int(13)      not null,
prod_id    varchar(235) not null,
name       varchar(255) not null)");
	my @arr = get_primary_key_set_of_ranges('product','product',100000,'product_id');
	for my $b_cond (@arr) {
		do_statement("insert into tmp_product_snapshot(product_id,prod_id,name) select product_id,prod_id,name from product WHERE " . $b_cond);
	}
	do_statement("alter table tmp_product_snapshot add primary key (product_id)");
	my $products = do_query("select tl.product_id_local, tps.prod_id, tps.name
from tmp_locals tl
inner join tmp_product_snapshot tps on tl.product_id_local=tps.product_id
left join tmp_product tp on tp.product_id=tl.product_id
order by tl.product_id_local, tp.prod_id");
	do_statement("drop temporary table tmp_product_snapshot");
	open(GEN,">./import.report");
	binmode(GEN,":utf8");
	print GEN "action\tprod_id\tname\n";
	for (@$products) {
		print GEN ($_->[0]?$_->[0]:"(added)")."\t".$_->[1]."\t".$_->[2]."\n";
	}
	close(GEN);
} # sub generate_updated_and_added_product_list

sub product_related_id_mapping {
	my ($hash) = @_;

	do_statement("update tmp_product_related tpr inner join tmp_icecat_product tip on tip.prod_id = tpr.related_prod_id set tpr.related_product_id = tip.product_id");
	do_statement("update tmp_product_related tpr inner join tmp_product tp using (tmp_product_id) set tpr.product_id = tp.product_id");
	do_statement("update tmp_product_related tpr inner join " . ( do_query("show tables like 'product_memory'")->[0][0] ? "product_memory" : "product" ) . " pm on pm.prod_id=tpr.related_prod_id set tpr.related_product_id=pm.product_id where tpr.related_product_id=0") if $hash->{'use_all_products_during_mapping'};
	do_statement("alter ignore table tmp_product_related add unique key (related_product_id,product_id), add key (product_id)");

	return do_query("select count(*) from tmp_product_related where related_product_id!=0 and product_id!=0")->[0][0];
} # sub product_related_id_mapping

sub post_product_related_id_mapping {

	do_statement("delete from tmp_product_related where related_product_id=0");
	my $ignored = do_query("select row_count()")->[0][0];

	do_statement("delete from tmp_product_related where product_id=0");
	$ignored += do_query("select row_count()")->[0][0];

	return $ignored;
} # sub post_product_related_id_mapping

sub product_ean_codes_mapping {
	my $withEans = shift;
	if ($withEans) {
		do_statement("update tmp_product_ean_codes tpec inner join tmp_icecat_product tip on tip.prod_id=tpec.prod_id AND tip.supplier_id=tpec.supplier_id  set tpec.product_id=tip.product_id");
	}else{
		do_statement("update tmp_product_ean_codes tpec inner join tmp_icecat_product tip on tip.prod_id=tpec.prod_id set tpec.product_id=tip.product_id");
	}
	do_statement("alter table tmp_product_ean_codes add key (product_id)");
	do_statement("delete from tmp_product_ean_codes where product_id=0");
	do_statement("delete tpec from tmp_product_ean_codes tpec inner join tmp_locals tl on tpec.product_id=tl.product_id_local where tl.owned=0");
} # sub product_ean_codes_mapping

sub add_product_names {
	## product_name_id mapping
	# prepare tmp_locals_name table
	do_statement("create temporary table tmp_locals_name (
product_id_local      int(13) not null default '0',
langid                int(5)  not null default '0',
product_name_id_local int(13) not null default '0',
tmp_product_name_id   int(13) not null default '0')");
  
	# insert & update tmp table
	do_statement("insert into tmp_locals_name(product_id_local,langid,product_name_id_local,tmp_product_name_id)
select tl.product_id_local,tpn.langid,0,tpn.tmp_product_name_id
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_name tpn on tpn.tmp_product_id=tp.tmp_product_id");
	do_statement("alter table tmp_locals_name add key (tmp_product_name_id), add key (product_id_local,langid)");
	do_statement("update tmp_locals_name tln
inner join product_name pn on tln.product_id_local=pn.product_id and tln.langid=pn.langid
set tln.product_name_id_local=pn.product_name_id");
	do_statement("alter table tmp_locals_name add key (product_name_id_local)");

	# update & insert DB table
	do_statement("update product_name pn
inner join tmp_locals_name tln on pn.product_name_id=tln.product_name_id_local
inner join tmp_product_name tpn on tpn.tmp_product_name_id=tln.tmp_product_name_id
set pn.name=tpn.name
where tln.product_name_id_local!=0");

	do_statement("insert into product_name(product_id,name,langid)
select tln.product_id_local,tpn.name,tpn.langid
from tmp_product_name tpn
inner join tmp_locals_name tln on tln.tmp_product_name_id=tpn.tmp_product_name_id
where tln.product_name_id_local=0");
	do_statement("drop temporary table tmp_locals_name");
	do_statement("drop temporary table tmp_product_name");
} # sub add_product_names

sub add_product_descriptions {
	my ($do_drop_tmp,$doUpdateEditorsDesc,$doReplaceEmptyLong)=@_;
	## prepare tmp_locals_description table
	do_statement("create temporary table tmp_locals_description (
product_id_local             int(13) not null default '0',
langid                       int(5)  not null default '0',
product_description_id_local int(13) not null default '0',
tmp_product_description_id   int(13) not null default '0',
owned                        int(5)  not null default '0')");
	# insert & update tmp table	
	do_statement("insert into tmp_locals_description(product_id_local,langid,product_description_id_local,tmp_product_description_id,owned)
select tl.product_id_local,tpd.langid,0,tpd.tmp_product_description_id,tl.owned
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_description tpd on tpd.tmp_product_id=tp.tmp_product_id");
	do_statement("alter table tmp_locals_description add key (tmp_product_description_id), add key (product_id_local,langid)");
	do_statement("update tmp_locals_description tld
	inner join product_description pd on tld.product_id_local=pd.product_id and tld.langid=pd.langid
	set tld.product_description_id_local=pd.product_description_id");
	do_statement("alter table tmp_locals_description add key (product_description_id_local)");

	if($doUpdateEditorsDesc){# update all matched
		do_statement("update product_description pd
		inner join tmp_locals_description tld on pd.product_description_id=tld.product_description_id_local
		inner join tmp_product_description tpd on tld.tmp_product_description_id=tpd.tmp_product_description_id
		set pd.short_desc=IF(tpd.short_desc!='',tpd.short_desc,pd.short_desc), 
			pd.long_desc=IF(tpd.long_desc!='',tpd.long_desc,pd.long_desc), 
			pd.official_url=IF(tpd.url!='',tpd.url,pd.official_url), 
			pd.pdf_url=IF(tpd.pdf_url!='',tpd.pdf_url,pd.pdf_url), 
			pd.warranty_info=IF(tpd.warranty_info!='',tpd.warranty_info,pd.warranty_info), 
			pd.option_field_1=IF(tpd.option_field_1!='',tpd.option_field_1,pd.option_field_1), 
			pd.manual_pdf_url=IF(tpd.manual_pdf_url!='',tpd.manual_pdf_url,pd.manual_pdf_url)");
			
	}else{
		# update non-owned & owned
		for my $where ("pd.short_desc=''  and tld.owned=0","tld.owned=1") {
			do_statement("update product_description pd
			inner join tmp_locals_description tld on pd.product_description_id=tld.product_description_id_local
			inner join tmp_product_description tpd on tld.tmp_product_description_id=tpd.tmp_product_description_id
			set pd.short_desc=tpd.short_desc, pd.long_desc=tpd.long_desc, pd.official_url=tpd.url, pd.pdf_url=tpd.pdf_url, pd.warranty_info=tpd.warranty_info, pd.option_field_1=tpd.option_field_1, pd.manual_pdf_url=tpd.manual_pdf_url
			where ".$where);
		}
		if($doReplaceEmptyLong){
		do_statement("update product_description pd
			inner join tmp_locals_description tld on pd.product_description_id=tld.product_description_id_local
			inner join tmp_product_description tpd on tld.tmp_product_description_id=tpd.tmp_product_description_id
			set 
			pd.long_desc=tpd.long_desc, 
			pd.official_url=IF(pd.official_url='',tpd.url,pd.official_url), 
			pd.pdf_url=IF(pd.pdf_url='',tpd.pdf_url,pd.pdf_url), 
			pd.warranty_info=IF(pd.warranty_info='',tpd.warranty_info,pd.warranty_info), 
			pd.option_field_1=IF(pd.option_field_1='',tpd.option_field_1,pd.option_field_1), 
			pd.manual_pdf_url=IF(pd.manual_pdf_url='',tpd.manual_pdf_url,pd.manual_pdf_url)
			where pd.long_desc='' and tld.owned=0");
		}
	}
	# insert
	do_statement("insert ignore into product_description(product_id,short_desc,long_desc,official_url,pdf_url,warranty_info,option_field_1,langid,manual_pdf_url)
select tld.product_id_local,tpd.short_desc,tpd.long_desc,tpd.url,tpd.pdf_url,tpd.warranty_info,tpd.option_field_1,tpd.langid,tpd.manual_pdf_url
from tmp_product_description tpd
inner join tmp_locals_description tld on tpd.tmp_product_description_id=tld.tmp_product_description_id
where tld.product_description_id_local=0");
	unless($do_drop_tmp){
		do_statement("drop temporary table tmp_locals_description");
		do_statement("drop temporary table tmp_product_description");
	}
} # sub add_product_descriptions

sub product_features_preprocessing {
	my ($hash) = @_;
	do_statement("create temporary table tmp_product_feature_cutted like tmp_product_feature");
	do_statement("alter table tmp_product_feature_cutted drop column symbol, drop column pattern");
	do_statement("insert into tmp_product_feature_cutted(tmp_product_id,langid,value,feature_id,category_feature_id)
select tmp_product_id,langid,GROUP_CONCAT(DISTINCT value ORDER BY feature_id ASC SEPARATOR ".str_sqlize($hash->{'br'})."),feature_id,category_feature_id
from tmp_product_feature group by tmp_product_id,category_feature_id,langid");
	do_statement("truncate table tmp_product_feature");
	do_statement("insert into tmp_product_feature(tmp_product_id,langid,value,feature_id,category_feature_id)
select tmp_product_id,langid,value,feature_id,category_feature_id from tmp_product_feature_cutted");
	do_statement("drop temporary table tmp_product_feature_cutted");
} # sub product_features_preprocessing

sub add_product_features {
	### product_feature_local ###
	## prepare tmp_locals_feature table
	my ($doUpdateEditorsFeat,$only_local_features,$updateEditorLocalOnly) = @_;
	do_statement("create temporary table tmp_locals_feature (
product_id_local               int(13) not null default '0',
langid                         int(5)  not null default '0',
category_feature_id            int(13) not null default '0',
product_feature_local_id_local int(13) not null default '0',
tmp_product_feature_id         int(13) not null default '0',
owned                          tinyint not null default '0')");

	# insert & update tmp table
	do_statement("insert into tmp_locals_feature(product_id_local,langid,category_feature_id,product_feature_local_id_local,tmp_product_feature_id,owned)
select tl.product_id_local,tpf.langid,tpf.category_feature_id,0,tpf.tmp_product_feature_id,tl.owned
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_feature tpf on tpf.tmp_product_id=tp.tmp_product_id");
	do_statement("alter table tmp_locals_feature add key (tmp_product_feature_id), add key (category_feature_id,product_id_local,langid), add key (product_id_local), add key (owned)");
	do_statement("update tmp_locals_feature tlf
inner join product_feature_local pf on tlf.product_id_local=pf.product_id and tlf.langid=pf.langid and tlf.category_feature_id=pf.category_feature_id
set tlf.product_feature_local_id_local=pf.product_feature_local_id");
	do_statement("alter table tmp_locals_feature add key (product_feature_local_id_local)");
	## Deleting unneed old local features
	# create a table with old DB values, only current and owned (to deleting yet unneed)
	do_statement("create temporary table tmp_old_product_local_feature (
product_feature_local_id int(13) not null default '0',
product_id               int(13) not null default '0',
langid                   int(5)  not null default '0',
exist                    char(1) not null default '')");
	do_statement("insert into tmp_old_product_local_feature(product_feature_local_id,product_id,langid)
select pfl.product_feature_local_id, pfl.product_id, pfl.langid from product_feature_local pfl
inner join tmp_locals tl on pfl.product_id=tl.product_id_local and tl.owned=1");
	do_statement("alter table tmp_old_product_local_feature add key (product_feature_local_id), add key (product_id,langid)");
	# select old features
	do_statement("update tmp_old_product_local_feature toplf
inner join tmp_locals_feature tlf on toplf.product_feature_local_id=tlf.product_feature_local_id_local
set exist='Y'");

	### add exist='Y' for languages, that TOTALLY absent in import now (cause they will be removed, if I don't do that)
	# very strange and powerful algorithm - I'll make it all second half of working day - keep it in warm place! 	
	do_statement("create temporary table tmp_product_id_and_langid_for_keeping (
product_id int(13) not null default '0',
langid     int(5)  not null default '0',
dummy      char(1) null)");
	do_statement("insert into tmp_product_id_and_langid_for_keeping(product_id,langid,dummy)
select p.product_id, pfl.langid, GROUP_CONCAT(toplf.exist separator '') as group_exist
from tmp_old_product_local_feature toplf
left join product_feature_local pfl on pfl.product_feature_local_id=toplf.product_feature_local_id
left join product p on p.product_id=pfl.product_id
group by p.product_id, pfl.langid
having group_exist = ''");
	do_statement("alter table tmp_product_id_and_langid_for_keeping add key (product_id,langid)");
	do_statement("update tmp_old_product_local_feature toplf
inner join tmp_product_id_and_langid_for_keeping t using (product_id,langid)
set exist = 'Y'");
	### end of very strange and powerful algorithm
	# delete old feature local values
	do_statement("delete pfl from product_feature_local pfl
inner join tmp_old_product_local_feature toplf on pfl.product_feature_local_id=toplf.product_feature_local_id
where exist is null");
	do_statement("drop temporary table tmp_old_product_local_feature");

	# the pfl updating goes too long and eats too much MySQL I/O time ans slows the MySQL working at all, so, I want to split it to the several parts
	my $category_feature_id_set = do_query("select distinct category_feature_id from tmp_locals_feature where category_feature_id > 0");
	
	# update product_feature_local for non-owned (if feature local value is void) & owned
	
	my $update_pfl_array = $doUpdateEditorsFeat ? ['1'] : [ "pfl.value='' and tlf.owned=0", "tlf.owned=1" ];
	
	for my $where (@$update_pfl_array) {

		for my $cf_id (@$category_feature_id_set) {

#			log_printf(do_query_dump("explain select * from  product_feature_local pfl
#inner join tmp_locals_feature tlf on tlf.product_id_local=pfl.product_id and tlf.langid=pfl.langid and pfl.category_feature_id=tlf.category_feature_id
#inner join tmp_product_feature tpf using (tmp_product_feature_id)
#where ".$where." and tlf.product_feature_local_id_local!=0 and tpf.value!='' and pfl.category_feature_id=".$cf_id->[0]." and tlf.category_feature_id=".$cf_id->[0]));
			
			do_statement("update product_feature_local pfl
			inner join tmp_locals_feature tlf on tlf.product_id_local=pfl.product_id and tlf.langid=pfl.langid and pfl.category_feature_id=tlf.category_feature_id
			inner join tmp_product_feature tpf using (tmp_product_feature_id)
			set pfl.value=tpf.value
			where ".$where." and tlf.product_feature_local_id_local!=0 and tpf.value!='' and pfl.category_feature_id=".$cf_id->[0]." and tlf.category_feature_id=".$cf_id->[0]);

		}

	}
	## insert product_feature_local
	do_statement("insert ignore into product_feature_local(product_id,category_feature_id,value,langid)
select tlf.product_id_local,tpf.category_feature_id,tpf.value,tpf.langid
from       tmp_locals_feature tlf
inner join tmp_product_feature tpf on tlf.tmp_product_feature_id=tpf.tmp_product_feature_id
				where tlf.product_feature_local_id_local=0 and tpf.value!=''");
 
	## delete unneed tables
	do_statement("drop temporary table tmp_locals_feature");

	### product features internationalization (from Martijn's letter "Re: HPProvisioner import testing") ###

	product_feature_internationalization;

	### product_feature ###

	## prepare tmp_locals_feature table
	do_statement("create temporary table tmp_locals_feature (
product_id_local         int(13) not null default '0',
category_feature_id      int(13) not null default '0',
product_feature_id_local int(13) not null default '0',
tmp_product_feature_id   int(13) not null default '0',
owned                    tinyint not null default '0')");

	# insert & update tmp table
	do_statement("insert into tmp_locals_feature(product_id_local,category_feature_id,product_feature_id_local,tmp_product_feature_id,owned)
select tl.product_id_local,tpf.category_feature_id,0,tpf.tmp_product_feature_id,tl.owned
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_feature tpf on tpf.tmp_product_id=tp.tmp_product_id");

	do_statement("alter table tmp_locals_feature
add key tpfi (tmp_product_feature_id),
add key pilncfi (product_id_local,category_feature_id),
add key pilncfio (product_id_local,category_feature_id,owned)");
	do_statement("update tmp_locals_feature tlf
inner join product_feature pf on tlf.product_id_local=pf.product_id and tlf.category_feature_id=pf.category_feature_id
set tlf.product_feature_id_local=pf.product_feature_id");
	do_statement("alter table tmp_locals_feature add key pfil (product_feature_id_local)");

	## Deleting unneed old features
	# create a table with old DB values, only current and owned (to deleting yet unneed)
	do_statement("create temporary table tmp_old_product_feature (
product_feature_id int(13) not null default '0',
exist              char(1) null)");
	do_statement("insert into tmp_old_product_feature(product_feature_id)
select product_feature_id from product_feature pf
inner join tmp_locals tl on pf.product_id=tl.product_id_local and tl.owned=1");
	do_statement("alter table tmp_old_product_feature add key (product_feature_id)");

	# select old features
	do_statement("update tmp_old_product_feature topf
inner join tmp_locals_feature tlf on topf.product_feature_id=tlf.product_feature_id_local
set exist='Y'");
	# delete old feature values
	do_statement("delete pf from product_feature pf
inner join tmp_old_product_feature topf on pf.product_feature_id=topf.product_feature_id
where exist is null");
	do_statement("drop temporary table tmp_old_product_feature");
	if(!$only_local_features){
		$category_feature_id_set = do_query("select distinct category_feature_id from tmp_locals_feature where category_feature_id > 0");
		## update product_feature for owned
		for my $cf_id (@$category_feature_id_set) {
			do_statement("update product_feature pf
		inner join tmp_locals_feature tlf on tlf.product_id_local=pf.product_id and pf.category_feature_id=tlf.category_feature_id " . ( ($doUpdateEditorsFeat and !$updateEditorLocalOnly) ? "" : " and tlf.owned=1 " ) . "
		inner join tmp_product_feature tpf using (tmp_product_feature_id)
		set pf.value=tpf.value
		where tlf.product_feature_id_local!=0 and tpf.value!='' and pf.category_feature_id=".$cf_id->[0]." and tlf.category_feature_id=".$cf_id->[0]);
			
		}
		## update product_feature for non-owned - absent
		#do_statmenet("select 1");
	
		## insert product_feature
		do_statement("insert ignore into product_feature(product_id,category_feature_id,value)
	select tlf.product_id_local,tpf.category_feature_id,tpf.value
	from       tmp_locals_feature tlf
	inner join tmp_product_feature tpf on tlf.tmp_product_feature_id=tpf.tmp_product_feature_id
					where tlf.product_feature_id_local=0 and tpf.value!=''");
	}
	## delete unneed tables
	do_statement("drop temporary table tmp_locals_feature");
} # sub add_product_features
sub test_tables{
	sub create_aaa_test{
		my $table=shift;
		do_statement("DROP TABLE IF EXISTS aaa_$table");
		do_statement("CREATE TABLE aaa_$table LIKE $table");
		do_statement("INSERT INTO aaa_$table SELECT * FROM $table");
	}
	create_aaa_test('tmp_locals_feature');
	create_aaa_test('tmp_locals');
	create_aaa_test('tmp_product');
	create_aaa_test('tmp_product_feature');
}

sub product_feature_internationalization {
	# create additional table for langid=1 COPIED from langid!=1 values
	do_statement("create temporary table tmp_product_feature_additional like tmp_product_feature");

	# add numeric values to INT tab
  do_statement("insert into tmp_product_feature_additional (tmp_product_id,langid,value,feature_id,category_feature_id)
select tmp_product_id,1,value,feature_id,category_feature_id from tmp_product_feature where langid!=1 and value REGEXP '^[0-9]+\$'");

	# add category_feature dropdown values to INT tab
	do_statement("create temporary table tmp_category_feature_dropdown (
category_feature_id int(13)      not null default '0',
value               varchar(255) not null default '')");
	my $query = do_query("select category_feature_id,restricted_search_values from category_feature where use_dropdown_input='Y'");
	my ($out, $array);
	for my $str (@$query) {
		chomp($str->[1]);
		@$array = split(/\n/,$str->[1]);
		for (@$array) {
			$out .= "('".$str->[0]."',".str_sqlize($_).")," if ($_);
		}
	}
	chop($out);
	do_statement("insert into tmp_category_feature_dropdown(category_feature_id,value) values".$out) if ($out);
	do_statement("alter table tmp_category_feature_dropdown add key (value)");
	do_statement("insert ignore into tmp_product_feature_additional (tmp_product_id,langid,value,feature_id,category_feature_id)
select tpf.tmp_product_id,1,tpf.value,tpf.feature_id,tpf.category_feature_id from tmp_product_feature tpf
inner join tmp_category_feature_dropdown tcfd
where tpf.value=tcfd.value and tpf.category_feature_id=tcfd.category_feature_id and tpf.langid!=1");
	do_statement("drop temporary table tmp_category_feature_dropdown");

	# add feature dropdown values to INT tab
	do_statement("create temporary table tmp_feature_dropdown (
feature_id int(13)      not null default '0',
value      varchar(255) not null default '')");
	my $query = do_query("select feature_id,restricted_values from feature where type='dropdown'");
	my ($out, $array);
	for my $str (@$query) {
		chomp($str->[1]);
		@$array = split(/\n/,$str->[1]);
		for (@$array) {
			$out .= "('".$str->[0]."',".str_sqlize($_).")," if ($_);
		}
	}
	chop($out);
	do_statement("insert into tmp_feature_dropdown(feature_id,value) values".$out) if ($out);
	do_statement("alter table tmp_feature_dropdown add key (value)");
	do_statement("insert ignore into tmp_product_feature_additional (tmp_product_id,langid,value,feature_id,category_feature_id)
select tpf.tmp_product_id,1,tpf.value,tpf.feature_id,tpf.category_feature_id from tmp_product_feature tpf
inner join tmp_feature_dropdown tfd
where tpf.value=tfd.value and tpf.feature_id=tfd.feature_id and tpf.langid!=1");
	do_statement("drop temporary table tmp_feature_dropdown");

	# deleting unneed values
	do_statement("delete from tmp_product_feature where langid!=1");

	# fill tmp_product_feature
	do_statement("insert ignore into tmp_product_feature (tmp_product_id,langid,value,feature_id,category_feature_id)
select tmp_product_id,1,value,feature_id,category_feature_id from tmp_product_feature_additional");
	do_statement("repair table tmp_product_feature quick");
} # sub product_feature_internationalization

sub add_product_related {
	my ($hash) = @_;

	my ($results);

	## prepare tmp_locals_description table
	do_statement("create temporary table tmp_locals_related (
product_id_local         int(13)     not null default 0, /* main product_id */
related_product_id_local int(13)     not null default 0, /* related product_id */
product_related_id_local int(13)     not null default 0, /* id from product_related */
preferred_option         tinyint(1)  not null default 0,  /* value from tmp_product_related */

unique key (product_id_local,related_product_id_local))");

	# insert & update tmp table
	do_statement("insert ignore into tmp_locals_related(product_id_local,related_product_id_local,product_related_id_local,preferred_option)
select tl.product_id_local,tpr.related_product_id,0,tpr.preferred_option
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_related tpr on tpr.tmp_product_id=tp.tmp_product_id");

	do_statement("update tmp_locals_related tlr
inner join product_related pr on tlr.product_id_local=pr.product_id and tlr.related_product_id_local=pr.rel_product_id
set tlr.product_related_id_local=pr.product_related_id");

	do_statement("alter table tmp_locals_related add key product_related_id_local (product_related_id_local)");

	do_statement("update tmp_locals_related tlr
inner join product_related pr on tlr.product_id_local=pr.rel_product_id and tlr.related_product_id_local=pr.product_id
set tlr.product_related_id_local=pr.product_related_id
where tlr.product_related_id_local=0");

	if ($hash->{'supplier_name'} eq "Samsung" ||  $hash->{'supplier_name'} eq "Xerox" || $hash->{'supplier_name'} =~ /^Vogel/i || $hash->{'supplier_name'} eq 'Lexmark' || $hash->{'supplier_name'} eq 'Brodit' || $hash->{'supplier_name'} eq 'Pelikan' || $hash->{'supplier_name'} =~ /^sony$/i || $hash->{'supplier_name'} =~ /^epson$/i || $hash->{'supplier_name'} =~ /^gigabyte$/i) {
		# update relations (correct data_source_id) - DISABLED!.. It isn't a good idea to grab editor's relations
#		do_statement("update product_related pr
#inner join tmp_locals_related tlr on pr.product_related_id=tlr.product_related_id_local set pr.data_source_id=".$hash->{'data_source_id'}."
#where tlr.product_related_id_local!=0 and pr.data_source_id!=".$hash->{'data_source_id'});
#		$results->{'updated'} = do_query("select row_count()")->[0][0];

		# remove old relations from live server
		do_statement("create temporary table tmp_product_related2delete (product_related_id int(13) not null primary key)");
		do_statement("insert ignore into tmp_product_related2delete(product_related_id) select product_related_id from product_related where data_source_id=".$hash->{'data_source_id'});
		do_statement("delete tpr2d from tmp_product_related2delete tpr2d inner join tmp_locals_related tlr on tpr2d.product_related_id=tlr.product_related_id_local");
		do_statement("delete pr from product_related pr inner join tmp_product_related2delete tpr2d using (product_related_id)");
		$results->{'delete old'} = do_query("select row_count()")->[0][0];

		# remove already exist relations
		do_statement("delete from tmp_locals_related where product_related_id_local!=0");
		$results->{'delete existed from tmp'} = do_query("select row_count()")->[0][0];

		# add new relations
		do_statement("insert ignore into product_related(product_id,rel_product_id,preferred_option,data_source_id)
select product_id_local, related_product_id_local, 0, ".$hash->{'data_source_id'}." from tmp_locals_related");
		$results->{'insert new'} = do_query("select row_count()")->[0][0];
	} # Xerox && Vogel's && Lexmark && Brodit && Pelikan

	do_statement("drop temporary table tmp_locals_related");
	do_statement("drop temporary table tmp_product_related");

	return $results;
} # sub add_product_related

sub add_product_related_2 {
	my ($h) = @_;

	my $Deleted = 0;
  my $Updated = 0;
  my $Inserted = 0;

  my ($product_ids, $additional_set);

  if (do_query("select count(*) from tmp_product_related")->[0][0] > 0) {
    print "\n" if ($h->{'show'});

		do_statement("create temporary table if not exists tmp_product_related_useful (
product_related_id int(13) not null default 0,
product_id         int(13) not null default 0,
related_product_id int(13) not null default 0,
preferred_option   int(1)  not null default 0,
key                (product_related_id),
key                (product_id, related_product_id),
key                (related_product_id))");

		# MAJOR - add product_related_id to tmp_product_related - for I, U, D (U - complete it, I - use it after U competing)
		do_statement("alter table tmp_product_related add column product_related_id int(13) not null default 0, add key (product_related_id)");

    $product_ids = do_query("select SQL_BUFFER_RESULT distinct product_id from tmp_product_related order by product_id asc");

		if ($h->{'related_no_additional_params'}) {
			$additional_set = '';
		}
		else {
			$additional_set = 'pr.preferred_option=tpr.preferred_option, ';
		}

    for (@$product_ids) {
      print $_->[0]." \033[1m" . do_query("select prod_id from product where product_id=".$_->[0])->[0][0] . "\033[0m: " if ($h->{'show'});

      do_statement("truncate table tmp_product_related_useful");
      do_statement("alter table tmp_product_related_useful DISABLE KEYS");
      do_statement("insert into tmp_product_related_useful(product_related_id,product_id,related_product_id,preferred_option)
select product_related_id,product_id,related_product_id,preferred_option from tmp_product_related where product_id=".$_->[0]);
      do_statement("alter table tmp_product_related_useful ENABLE KEYS");

      do_statement("delete pr from product_related pr
left join tmp_product_related_useful tpr on pr.product_id=tpr.product_id and pr.rel_product_id=tpr.related_product_id
where pr.data_source_id=".$h->{'data_source_id'}." and tpr.product_id IS NULL and pr.product_id=".$_->[0]);
      $Deleted = do_query("select row_count()")->[0][0];
      print "D=" . ( $Deleted ? "\033[31m" . $Deleted . "\033[37m" : $Deleted ) if ($h->{'show'});

      do_statement("update product_related pr
inner join tmp_product_related_useful tpr on pr.product_id=tpr.product_id and pr.rel_product_id=tpr.related_product_id
set ".$additional_set."tpr.product_related_id=pr.product_related_id
where pr.data_source_id=".$h->{'data_source_id'});
      $Updated = do_query("select row_count()")->[0][0];
      print "\tU=" . ( $Updated ? "\033[32m". $Updated . "\033[37m" : $Updated ) . ( $additional_set ? "" : " fake" ) if ($h->{'show'});

      do_statement("insert ignore into product_related(product_id,rel_product_id,preferred_option,data_source_id)
select product_id,related_product_id,preferred_option,".$h->{'data_source_id'}."
from tmp_product_related_useful
where product_related_id=0");
      $Inserted = do_query("select row_count()")->[0][0];
      print "\tI=" . ( $Inserted ? "\033[1;32m" . $Inserted . "\033[0;37m" : $Inserted ) . "\n" if ($h->{'show'});
    }
  }
  else {
    print "No relations (" if ($h->{'show'});
  }
} # sub add_product_related_2

sub add_product_ean_codes {	
	do_statement("UPDATE tmp_product_ean_codes SET ean_code=LPAD(ean_code,13,'0') WHERE length(ean_code)<13 and ean_code!=''");
	do_statement("insert ignore into product_ean_codes(product_id,ean_code) select product_id,ean_code from tmp_product_ean_codes");
} # add product_ean_codes

sub add_product_bullets {
	## product_bullet_id mapping
	# prepare tmp_locals_bullet table
	do_statement("create temporary table tmp_locals_bullet (
product_id_local        int(13)      not null default '0',
langid                  int(5)       not null default '0',
code                    varchar(60)  not null default '0',
product_bullet_id_local int(13)      not null default '0',
tmp_product_bullet_id   int(13)      not null default '0')");
	# insert & update tmp table
	do_statement("insert into tmp_locals_bullet(product_id_local,langid,code,product_bullet_id_local,tmp_product_bullet_id)
select tl.product_id_local,tpb.langid,tpb.code,0,tpb.tmp_product_bullet_id
from tmp_locals tl
inner join tmp_product tp on tl.product_id=tp.product_id
inner join tmp_product_bullet tpb on tpb.tmp_product_id=tp.tmp_product_id");
	do_statement("alter table tmp_locals_bullet add key (product_id_local,langid,code), add key (tmp_product_bullet_id)");
	do_statement("update tmp_locals_bullet tlb
inner join product_bullet pb on tlb.product_id_local=pb.product_id and tlb.langid=pb.langid and tlb.code=pb.code
set tlb.product_bullet_id_local=pb.product_bullet_id");
	do_statement("alter table tmp_locals_bullet add key (product_bullet_id_local)");

	# update & insert DB table
	do_statement("update product_bullet pb
inner join tmp_locals_bullet tlb on pb.product_bullet_id=tlb.product_bullet_id_local
inner join tmp_product_bullet tpb on tlb.tmp_product_bullet_id=tpb.tmp_product_bullet_id
set pb.value=tpb.value
where tlb.product_bullet_id_local!=0");

	do_statement("insert into product_bullet(product_id,code,value,langid)
select tlb.product_id_local,tpb.code,tpb.value,tpb.langid
from tmp_product_bullet tpb
inner join tmp_locals_bullet tlb on tlb.tmp_product_bullet_id=tpb.tmp_product_bullet_id
where tlb.product_bullet_id_local=0");
	do_statement("drop temporary table tmp_locals_bullet");
	do_statement("drop temporary table tmp_product_bullet");
} # sub add_product_bullets

sub get_picture_content_length_from_server {
	my ($url) = @_;
	my ($req, $res, $ua);
	
	$ua = new LWP::UserAgent;
	$req = new HTTP::Request HEAD => $url;
	$res = $ua->request($req);
	
	if ($res->is_success && $res->headers()->{'content-type'} =~ /^image/) {
		return $res->headers()->{'content-length'};
	}
	else {
		return 0;
	}
} # get_picture_content_length_from_server

sub get_picture_content_type_from_server {
	my ($url) = @_;
	my ($req, $res, $ua);
	
	$ua = new LWP::UserAgent;
	$req = new HTTP::Request HEAD => $url;
	$res = $ua->request($req);
	
	if ($res->is_success && $res->headers()->{'content-type'} =~ /^image/) {
		return $res->headers()->{'content-type'};
	}else {
		return 0;
	}
} # get_picture_content_type_from_server

sub product_gallery_mapping{
	print "\t\033[1mProduct gallery mapping\033[0m: ";
	do_statement("update tmp_product_gallery tpg
			inner join tmp_product tp using (tmp_product_id)
			inner join tmp_icecat_product tip on tp.product_id=tip.product_id
			set tpg.product_id=tip.product_id");
	print "U \n";
	do_statement("alter table tmp_product_gallery add key (product_id)");
	do_statement("delete from tmp_product_gallery where product_id=0");
	print "D (".do_query("select row_count()")->[0][0]." values deleted as nonmapped products) \n";
}

sub add_product_gallery {
	my ($h) = @_;
	my $gallery_pics_path=$h->{'gallery_pics_path'};
	my $data_source_code=$h->{'data_source_code'};
	my $data_source_id=$h->{'data_source_id'};
	do_statement("delete pgi from product_gallery_imported pgi left join product_gallery pg on pgi.product_gallery_id=pg.id where pg.id is null");

	# select new / fresh only
	my $new_fresh = do_query("select tpg.product_id, tpg.type, tpg.url, pgi.product_gallery_id, pgi.product_gallery_imported_id, tpg.content_length, pgi.content_length from tmp_product_gallery tpg left join product_gallery_imported pgi on tpg.product_id=pgi.product_id and tpg.type=pgi.type");

	my ($dst_link, $fname, $pic_hash, $thumb, $insert_id, $cmd);
	for (@$new_fresh) {
		# checking content lenght
		if(!$_->[5]){ # we don't have image size so it will be taken  from the server 
			$_->[5]=get_picture_content_length_from_server($_->[2]);
		}
		if($_->[5]==$_->[6]){ # we already have this image
			next; # do not add it
			print "$_->[5]\n";
		}
		#$_->[2] =~ s/&/\\&/gs;
		$data_source_code=~s/[^\w\d]/_/gs;
		
		""=~/(.*)/;#it empties $1 varable
		$_->[2]=~/\.(\w{1,5})$/;
		my $file_ext=$1;
		if(!$file_ext){# trying to extract file extention from content-type
			#print $_->[2]."\n"; 
			my $content_type=get_picture_content_type_from_server($_->[2]);
			$content_type=~/([\w]{1,5})$/;
			$file_ext=$1;
			next unless($file_ext);
		}
		$fname = $_->[0].'-'.$data_source_code.'-'.$_->[1].'.'.$file_ext;
		$cmd = "/usr/bin/wget -q '".$_->[2]."' -O '".$gallery_pics_path.$fname."'";
		print $cmd."\n";
		`$cmd`;
		my $file_name=convert_to_jpg($gallery_pics_path.$fname);
		$pic_hash = get_gallery_pic_params($file_name);
		if(ref($pic_hash) eq 'HASH' and scalar(keys(%{$pic_hash}))<1){
			print 'Cant get image params. ignore image '.$file_name;
			next;
		}
		if(ref($pic_hash) eq 'HASH' and !$pic_hash->{'size'}){
			print 'Cant get image size. ignore image '.$file_name;
			next;			
		}
		$file_name=~/\/([^\/]+)$/;		
		$dst_link = add_image($file_name,'img/gallery/',$atomcfg::targets,$1);
		# insert new gallery picture or update it if present		 
		if($_->[3]){
			update_rows("product_gallery", "id = ".$_->[3], $pic_hash);
			$insert_id = $_->[3];
		}elsif(do_query("SELECT 1 FROM product_gallery WHERE size=$pic_hash->{'size'} and product_id=$_->[0]")->[0][0]){# if we dont have image with the same size. a case when supplier changes the url or image id
			print "Dublicate image $file_name\n"; 
		}else{# insert image 
			$pic_hash->{'product_id'}=$_->[0];
			$pic_hash->{'link'}=str_sqlize($dst_link);
			insert_rows('product_gallery', $pic_hash);
			$insert_id = sql_last_insert_id();
		}
		
		$thumb = thumbnailize_product_gallery({'gallery_id' => $insert_id, 'product_id' => $_->[0], 'gallery_pic' => $dst_link});
#		$pic_hash->{'thumb_link'} = str_sqlize($thumb);
		#update_rows("product_gallery", "id = ".$insert_id, $pic_hash);

		# update
		if ($_->[3]) {
			do_statement("delete from product_gallery_imported where product_gallery_imported_id=".$_->[4]);
			do_statement("delete from product_gallery where id=".$_->[3]);
		}

		# add new imported file
		do_statement("insert into product_gallery_imported(product_id,type,content_length,data_source_id,product_gallery_id) 
						values(".$_->[0].",".str_sqlize($_->[1]).",".$_->[5].",".$data_source_id.",".$insert_id.")");
	}
} # sub add_product_gallery

sub add_symbols2mapping {
	my ($hash,$prefs,$what) = @_; 
	add_symbols_to_mapping($prefs, $hash->{'missing'}, $what);
} # sub add_symbols2mapping

sub get_picture_last_modified_from_server {
	my ($url) = @_;
	my ($req, $res, $lm);
	
	my $months = {'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4, 'may' => 5, 'jun' => 6, 'jul' => 7, 'aug' => 8, 'sep' => 9, 'oct' => 10, 'nov' => 11, 'dec' => 12};
	
	$req = new HTTP::Request HEAD => $url;
	$res = $ua->request($req);
	
	if ($res->is_success && $res->headers()->{'content-type'} =~ /^image/) {
		$lm = $res->headers()->{'last-modified'};
		$lm =~ s/^.*,\s+(.*)\s+\w+$/$1/;
		$lm =~ tr/:/ /;
		my ($day, $month, $year, $hour, $minute, $second) = split(/\s/, $lm);
		return Array2Epoch($year, $months->{lc($month)}, $day, $hour, $minute, $second);
	}
	else {
		return 0;
	}
} # sub get_picture_last_modified_from_server

sub get_picture_size_from_server {
	my ($url) = @_;
	my ($req, $res, $lm);
	
	my $months = {'jan' => 1, 'feb' => 2, 'mar' => 3, 'apr' => 4, 'may' => 5, 'jun' => 6, 'jul' => 7, 'aug' => 8, 'sep' => 9, 'oct' => 10, 'nov' => 11, 'dec' => 12};
	
	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;
	$ua->agent('Mozilla/5.0');

	$req = new HTTP::Request HEAD => $url;
	$res = $ua->request($req);
	
	if ($res->is_success && $res->headers()->{'content-type'} =~ /^image/) {
		return $res->headers()->{'content-length'};
	}
	else {
		return 0;
	}
} # sub get_picture_size_from_server

sub get_picture_size_from_file {
	my $file = shift;

	return undef unless (-f $file);

	my (undef, undef, undef, undef, undef, undef, undef, $size, undef, undef, undef, undef, undef) = stat($file);

	return $size;
} # sub get_picture_size_from_file

sub drop_unmapped_mappings {
	my ($hash) = @_;

	do_statement("delete from data_source_supplier_map where data_source_id=".$hash->{'data_source_id'}." and supplier_id=0");
	do_statement("delete data_source_feature_map_info fmi from data_source_feature_map fm 
					JOIN data_source_feature_map_info fmi USING(data_source_feature_map_id) 
					where fm.data_source_id=".$hash->{'data_source_id'}." and fm.feature_id=0");
	do_statement("delete from data_source_feature_map where data_source_id=".$hash->{'data_source_id'}." and feature_id=0");
	do_statement("delete from data_source_category_map where data_source_id=".$hash->{'data_source_id'}." and catid=0");
} # sub drop_unmapped_mappings

 ######################
## miscellaneous subs ##
 ######################

sub product_id_mapping {
	my ($hash) = @_;

	reload_tmp_icecat_product($hash);

	# update tmp_product with tmp_icecat_product product_ids on prod_id
	do_statement("update tmp_product tp
inner join tmp_icecat_product tip
on tp.prod_id=tip.prod_id and tip.supplier_id = " . ( $hash->{'with_supplier'} ?  'tp.supplier_id' : $hash->{'supplier_id'} ) . "
set tp.product_id=tip.product_id");
} # sub product_id_mapping

sub supplier_mapping {
	my ($hash) = @_;

	do_statement("update tmp_product tp
inner join supplier s on s.name = tp.supplier
set tp.supplier_id = s.supplier_id");
	my $affected_rows = do_query("select row_count()")->[0][0];
	   
	do_statement("update tmp_product tp 
inner join data_source_supplier_map ds on tp.supplier = ds.symbol
set tp.supplier_id = ds.supplier_id 
where data_source_id = ".$hash->{'data_source_id'}." and tp.supplier=0 and ds.supplier_id!=0 and symbol not like '%*%'");

	$affected_rows += do_query("select row_count()")->[0][0];

	do_statement("update tmp_product tp 
inner join data_source_supplier_map ds
on tp.supplier like replace(replace(replace(ds.symbol,'_','\\_'),'%','\\%'),'*','%')
set tp.supplier_id = ds.supplier_id 
where data_source_id = ".$hash->{'data_source_id'}." and symbol like '%*%' and tp.supplier_id=0 and ds.supplier_id!=0");

	$affected_rows += do_query("select row_count()")->[0][0];

	do_statement("alter table tmp_product add key (supplier_id)");

	return $affected_rows;	 
}

#
# more improvements to the reload icecat product sub:
# - $hash->{'with_supplier'} - =1, when we have a deal with more than 1 brand in one data source
# - $hash->{'no_datasource'} - =1, when we will map the brands, using supplier and pricelist datasource sources, instead of native datasource
#
# TODO:
# - using between ... and ...
#

sub reload_tmp_icecat_product {
	my ($hash) = @_;

  # product
  do_statement("drop temporary table if exists tmp_icecat_product");

  if ($hash->{'with_supplier'}) {
  	do_statement("create temporary table tmp_icecat_product (
`product_id`  int(13)     NOT NULL default '0',
`prod_id`     varchar(60) NOT NULL default '',
`user_id`     int(13)     NOT NULL default '0',
`supplier_id` int(13)     NOT NULL default '0',

unique key (product_id),
key (prod_id),
key (user_id),
key (supplier_id))");

		do_statement("alter table tmp_icecat_product disable keys");
		if ($hash->{'no_datasource'}) {
			do_statement("drop temporary table if exists tmp_supplier_for_insert");
			do_statement("create temporary table tmp_supplier_for_insert (supplier_id int(13) not null default 0, key (supplier_id))");
			do_statement("alter table tmp_supplier_for_insert disable keys");
			do_statement("insert into tmp_supplier_for_insert (supplier_id)
select supplier_id from tmp_product
where supplier_id is not null and supplier_id!=0
group by supplier_id");
			do_statement("alter table tmp_supplier_for_insert enable keys");
			do_statement("insert into tmp_icecat_product(product_id,prod_id,user_id,supplier_id)
select p.product_id,p.prod_id,p.user_id,p.supplier_id
from product p join tmp_supplier_for_insert s using (supplier_id)");
			do_statement("drop temporary table if exists tmp_supplier_for_insert");
		}
		else { # SLOW!.. we lock the product table more than 9 minutes...
			do_statement("insert into tmp_icecat_product(product_id,prod_id,user_id,supplier_id) 
select product_id,prod_id,user_id,p.supplier_id 
from product p JOIN data_source_supplier_map sm 
ON p.supplier_id = sm.supplier_id
WHERE sm.data_source_id = ".$hash->{'data_source_id'}." 
GROUP BY p.product_id");
		}
		do_statement("alter table tmp_icecat_product enable keys");
		# add index to `product_id`, `prod_id`+`supplier_id`
#  	do_statement("alter table tmp_icecat_product add primary key (product_id), add unique key (prod_id,supplier_id)");  
  }
	else {
  	do_statement("create temporary table tmp_icecat_product (
`product_id`  int(13)      NOT NULL default '0',
`prod_id`     varchar(60)  NOT NULL default '',
`user_id`     int(13)      NOT NULL default '0',
`name`        varchar(255) NOT NULL default '',
`supplier_id` int(13)      NOT NULL default 0,

primary key (product_id),
key (prod_id),
key (user_id),
key (name),
unique key (supplier_id,prod_id))");

		do_statement("alter table tmp_icecat_product disable keys");
		my @arr = get_primary_key_set_of_ranges('product','product',100000,'product_id');
		for my $b_cond (@arr) {
			do_statement("insert into tmp_icecat_product(product_id,prod_id,user_id,name,supplier_id)
select product_id,prod_id,user_id,name,supplier_id from product WHERE " . $b_cond . " AND " . ( $hash->{'use_all_products_during_mapping'} ? '1' : " supplier_id = ".$hash->{'supplier_id'} ) );
		}
		do_statement("alter table tmp_icecat_product enable keys");

#	  # add index to `product_id`, `prod_id`+`supplier_id`
#	  do_statement("alter table tmp_icecat_product add primary key (product_id), add unique key (prod_id)");
  }
} # sub reload_tmp_icecat_product

sub delete_products_by_query {
	my ($hash,$query) = @_;
	my ($delete_products);
	# create tmp table, inserting & keys
	do_statement("create temporary table tmp_products2delete (tmp_product_id int(13) not null default '0')");
  do_statement("insert into tmp_products2delete(tmp_product_id) ".$query);
  do_statement("alter ignore table tmp_products2delete add unique key (tmp_product_id)");
	# delete from tables
	if ($hash->{'tables'}->{'product_feature'}) {
		do_statement("delete tpf from tmp_product_feature tpf inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_description'}) {
		do_statement("delete tpd from tmp_product_description tpd inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_name'}) {
		do_statement("delete tpn from tmp_product_name tpn inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_related'}) {
		do_statement("delete tpr from tmp_product_related tpr inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_file'}) {
		do_statement("delete tpf from tmp_product_file tpf inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_ean_codes'}) {
		do_statement("delete tpec from tmp_product_ean_codes tpec inner join tmp_products2delete using (tmp_product_id)");
	}
	if ($hash->{'tables'}->{'product_bullet'}) {
		do_statement("delete tpb from tmp_product_bullet tpb inner join tmp_products2delete using (tmp_product_id)");
	}
	$delete_products = 0;
	if ($hash->{'tables'}->{'product'}) {
		do_statement("delete tp from tmp_product tp inner join tmp_products2delete using (tmp_product_id)");
		$delete_products = do_query("select ROW_COUNT()")->[0][0];
	}
  do_statement("drop temporary table tmp_products2delete");
	return $delete_products;
} # sub delete_products_by_query

sub parse_doc {
	my ($xml_file) = @_;
	open(FH, "<".$xml_file);
	binmode(FH,":utf8");
	my $xml_message = join('', <FH>);
	close(FH);
	$xml_message =~ s/^\x{FEFF}?//;
	my $parser = XML::LibXML->new();
	my $doc = $parser->parse_chunk( $xml_message, 1 );
	my $elem = $doc->getDocumentElement;
	return $elem;
} # sub parse_doc

sub log_ignored_product {
	my ($prefs, $row, $text) = @_;
	#$prefs->{'ignored_products'}++;
	push @{$prefs->{'ignored_products_list'}},
	{
		'prod_id'  => $row->{'productcode vendor'},
		'name'     => $row->{'name'},
		'ocat'     => $row->{'subcat'},
		'reason'   => $text,
		'supplier' => $row->{'supplier'}
	};
} # sub log_ignored_product

sub get_text_tag
{
	my $test_parser = XML::LibXML->new();
	my $test_doc = $test_parser->parse_chunk( "<a>a</a>", 1 );
	my $test_elem = $test_doc->getDocumentElement;
	my @test_child_nodes = $test_elem->childNodes;

	return undef if ($#test_child_nodes == -1);
	return $test_child_nodes[0]->nodeName;
} # sub get_text_tag

sub text_value {
  my ($node,$libxml_text_tag) = @_;
  return undef unless($node);
  my $t;
  if ($t = ${$node->getChildrenByTagName($libxml_text_tag)}[0]) {
    return my_chomp($t->nodeValue);
  }
  else {
    return undef;
  }
} # sub text_value

sub child {
	my ($doc,$string,$same) = @_;
	return undef unless($doc);
	return ${$doc->getChildrenByTagName($string)}[0] || ($same ? $doc : undef);
} # sub child

sub childs {
	my ($doc,$string) = @_;
	return undef unless($doc);
#	mprint("ds = ".Dumper($doc->getChildrenByTagName($string)));
	return $doc->getChildrenByTagName($string);
} # sub childs

sub attr {
	my ($doc,$string,$libxml_text_tag) = @_;
	$string = $string || $libxml_text_tag;
#	mprint($doc->nodeName."\n");
#	mprint(Dumper($doc)."\n");
	return undef unless($doc);
	return my_chomp($doc->getAttribute($string));
} # sub attr

sub name {
	my ($doc) = @_;
	return undef unless ($doc);
	return $doc->nodeName;
} #sub name

sub xml2db {
  return decode_entities(shift);
} # sub xml2db

sub my_chomp {
  my ($str) = @_;
  $str =~ s/^\s+//s;
  $str =~ s/\s+$//s;
# $str =~ s/[[:cntrl:]]//gs;
  return $str;
} # sub my_chomp

sub nice_string {
  join("",
       map { $_ > 255 ?         # if wide character...
               sprintf("\\x{%04X}", $_) : # \x{...}
               chr($_) =~ /[[:cntrl:]]/ ? # else if control character ...
               sprintf("\\x%02X", $_) : # \x..
               quotemeta(chr($_)) # else quoted or as themselves
             } unpack("U*", $_[0])); # unpack Unicode characters
} # sub nice_string

# ENSURE you have symbol_md5 field in tmp_product_feature with md5 of feature name into it
sub translate_features{
	my($prefs)=@_;
	my $features_langs=do_query('SELECT langid FROM tmp_product_feature WHERE langid!=1 GROUP BY langid');
	
	my $trans_limit=200;
	my ($toTranslate_sql);
	for my $langid(@$features_langs){
		do_statement('DROP TEMPORARY TABLE IF EXISTS tmp_feature_translation');
		do_statement(' CREATE TEMPORARY TABLE tmp_feature_translation(
								symbol_md5 varchar(255) not null,
								feature_transl varchar(255) not null,
								PRIMARY KEY (symbol_md5))');
										
		my $features_count=do_query("SELECT COUNT(*) FROM (
									  	SELECT symbol FROM 	tmp_product_feature 
									  	WHERE langid=$langid->[0] GROUP BY symbol_md5) as tbl")->[0][0];
		print "translating $features_count features for lang ".$langid->[0].'   ';				
		for(my $i=0; $i<=$features_count+$trans_limit;$i=$i+$trans_limit){
			$toTranslate_sql = do_query("SELECT symbol,tmp_product_feature_id,symbol_md5 FROM 
										  tmp_product_feature WHERE langid=$langid->[0]  
										  GROUP BY symbol_md5 
										  LIMIT $i,$trans_limit ");
			translate_features_array($prefs,$toTranslate_sql,$langid);
			print '...'.$i;
		}# for() features langid
		do_statement("UPDATE tmp_product_feature f JOIN tmp_feature_translation ft USING(symbol_md5) 
					   SET symbol=CONCAT(ft.feature_transl,'---',f.symbol)
					   WHERE f.langid=$langid->[0] and ft.symbol_md5!='' and ft.feature_transl!=''");		
		print "\n";
	}# langid
}

sub translate_features_array{
	my ($prefs,$toTranslate_sql,$langid)=@_;
	use atom_mail;
	my (@toTranslate,%toTranslateMap,$results);
			#%toTranslateMap=map {$_->[0]=>$_->[1]} @$toTranslate_sql;
			#@toTranslate=keys(%toTranslateMap);
			@toTranslate=map {$_->[0]} @$toTranslate_sql;
			my %toTraslateMD5=map {$_->[0]=>$_->[2]} @$toTranslate_sql;
			my $cnt=0;
			while(ref($results) ne 'HASH'){				
				$results=translate_from_google(\@toTranslate,$langid->[0],'1');
				$cnt++;
				if($cnt==12){
					last();
				};
				if(ref($results) ne 'HASH'){
					print " FAIL ";
					sleep(10);					
				};
			}
			if(ref($results) ne 'HASH'){
				print "Cant translate some features. Ignoring....\n";
				my $mail = {
								'to' => $prefs->{'email'},
								'from' =>  $atomcfg{'mail_from'},
								'subject' => "Error!!!.Googlle translations does not work on lang ".$langid->[0],
								'default_encoding'=>'utf8',
								'html_body' => ' ',
								};
				complex_sendmail($mail);									
				last();					
			};
			
			
			my $insert_sql="INSERT IGNORE INTO tmp_feature_translation (symbol_md5,feature_transl) VALUES";
			for my $result(keys(%{$results})){
				$insert_sql.='('.str_sqlize($toTraslateMD5{$result}).',';
				$insert_sql.=str_sqlize($results->{$result}).'),';
			}
			$insert_sql=~s/,$//;
			do_statement($insert_sql) if scalar(keys(%{$results}))>0;
			#for my $result(keys(%{$results})){
				#$toTranslateMap{$result}=~s/,$//gs;
			#	do_statement("UPDATE tmp_product_feature SET 
			#				   symbol=CONCAT(".str_sqlize($results->{$result}).",'---',symbol)							   
			#				   WHERE langid=$langid->[0] and  symbol_md5 = ".str_sqlize($toTraslateMD5{$result}));
			#}
}

sub cleanup_tmp_feature_values{
	my ($hash)=@_;
	my $max_replaces=do_query("
						SELECT max(cnt) FROM 
						(SELECT count(fmr.value) as cnt FROM `tmp_product_feature` tf 
						JOIN data_source_feature_map fm ON fm.feature_id=tf.feature_id and fm.data_source_id=$hash->{'data_source_id'}  
						JOIN data_source_feature_map_info fmi ON fmi.data_source_feature_map_id=fm.data_source_feature_map_id and tf.langid=fmi.langid
						JOIN data_source_feature_map_replaces fmr ON fmr.data_source_feature_map_info_id=fmi.data_source_feature_map_info_id
						WHERE tf.feature_id!=0 GROUP BY tf.tmp_product_feature_id) as foo"
							)->[0][0];
	my $curr_time=time;
	my $tmp_table_name='tmp_replacements_'.$curr_time;
	do_statement("DROP TABLE IF EXISTS $tmp_table_name");							
	do_statement("CREATE TABLE $tmp_table_name(
				   tmp_product_feature_id int(11) not null,
				   replacement varchar(255) not null default '',
				   update_done int(1) not null default 0,
				   KEY(tmp_product_feature_id)
				   )");
	do_statement("INSERT INTO $tmp_table_name (tmp_product_feature_id,replacement)
					SELECT tf.tmp_product_feature_id,fmr.value FROM `tmp_product_feature` tf 
					JOIN data_source_feature_map fm ON fm.feature_id=tf.feature_id and fm.data_source_id=$hash->{'data_source_id'}  
					JOIN data_source_feature_map_info fmi ON fmi.data_source_feature_map_id=fm.data_source_feature_map_id AND tf.langid=fmi.langid
					JOIN data_source_feature_map_replaces fmr ON fmr.data_source_feature_map_info_id=fmi.data_source_feature_map_info_id
					WHERE tf.feature_id!=0 and fmr.value!='' ORDER BY length(fmr.value) DESC");		
	for(my $i=1; $i<=$max_replaces;$i++){
		do_statement("UPDATE tmp_product_feature tf,$tmp_table_name tr 
					  SET tf.value=TRIM(REPLACE(tf.value,tr.replacement,''))
					  WHERE tr.tmp_product_feature_id=tf.tmp_product_feature_id AND
					  tf.value LIKE CONCAT('%',replace(replace(replace(tr.replacement,'_','\\_'),'%','\\%'),'*','%'),'%')");
		my $aa=1;					  
	}
	do_statement("DROP TABLE IF EXISTS $tmp_table_name");
}
sub email_error{
	my($prefs,$err_msg)=@_;
	my $mail = {
			'to' => $prefs->{'email'},
			'from' =>  $atomcfg{'mail_from'},
			'subject' => "Error!!! Import on  $prefs->{'code'} failed",
			'default_encoding'=>'utf8',
			'html_body' => ''.$err_msg,
			};
	complex_sendmail($mail);
}	
1;

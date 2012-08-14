package data_management;

#$Id: data_management.pm 3756 2011-01-25 12:11:39Z dima $

use strict;
use atomlog;
use atomcfg;
use atom_util;
use atom_html;
use atomsql;
use atom_mail;
use icecat_util;
use atom_misc;
use icecat_server2_repository;
use icecat_mapping;

use feature_values;

use POSIX qw(strftime);

use Data::Dumper;


use vars qw ($atomid @errors);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
							 &merge_features
							 &merge_categories
							 &merge_category_features
							 &conform_product_feature_catid
	
							 &load_flat_file
							 &write_out_flat_file
							 &load_mapping_file
							 
							 &smart_update
							 &smart_update_prodname
							 &smart_update_feature_local
							 &load_data_source_prefs
							 &send_report
							 
							 &create_category_feature
							 &create_product_feature
							 
							 &save_snapshot
							 &delete_last_snapshot
							 &load_last_snapshot
							 
							 &copy_product
							 &copy_product_start
							 &copy_product_rest
							 
							 &delete_product
							 &delete_product_rest
							 
							 &download_file
							 
							 &add_symbols_to_mapping
							 
							 &build_active_symbol_hash
							 
							 &get_feature_map_rows
							 &format_feature_value
							 
							 &put_missing_category_feature
							 
							 &get_preview_product_mapping_rule
							 &match_single_product_regexp
							 &match_cat_symbol_regexp
							 &get_mapped_prod_id
							 
							 &get_product_date
							 &get_product_date_cached
							 &clear_product_date_cache

							 &get_product_date_cached_for_vendor_mailing							 
							 &get_rating_params
							 
							 &get_products_market
							 &get_products4repository
							 &get_products_for_repository_via_index_cache

							 &create_prodid_mapping
							 &create_supplier_mapping
               &store_product_mapping
               &store_supplier_mapping

               &product_mapping_header_footer
               &product_mapping_header_footer_end
               &product_mapping_end
               &supplier_mapping_header_footer
               &supplier_mapping_header_footer_end
               &supplier_mapping_end

							 &solve_product_ambugiuty

							 &get_summary_descriptions
							 &get_overall_features_info_per_product

							 &get_product_id_list_from_raw_batch

							 &get_supplier_id4product
							 &get_supplier_id_by_name
							 &get_catid4product
							);
}

use vars qw	( $category_features $category_features_ref $category_feature_groups $category_feature_groups_ref $standard_values_local );

sub get_supplier_id4product {
	my ($p_id) = @_;
	return undef if $p_id !~ /^\d+$/;
	return do_query("select supplier_id from product where product_id=".$p_id)->[0][0] || undef;
} # sub get_supplier_id4product

sub get_supplier_id_by_name {
	my ($name) = @_;
	chomp($name);
	$name =~ s/^\s+|\s+$//gs;
	return 0 if $name eq '';
	return do_query("select supplier_id from supplier where name = ".str_sqlize($name))->[0][0] || 0;
} # sub get_supplier_id_by_name

sub get_catid4product {
	my ($p_id) = @_;
	return undef if $p_id !~ /^\d+$/;
	return do_query("select catid from product where product_id=".$p_id)->[0][0] || undef;
} # sub get_catid4product

sub get_product_id_list_from_raw_batch {
	my ($raw_batch, $supplier_id) = @_;
	
	# split by space & newline
	my $related = $raw_batch;
	$related =~ s/[\s\n]+/~/gs;
	my @related_arr = split(/~/, $related);

	# split by newline only
	my $related_nl = $raw_batch;
	$related_nl =~ s/\n/~/gs;
	my @related_nl_arr = split(/\s*~\s*/, $related_nl);

	# join two arrays
	push (@related_arr, @related_nl_arr);
	$#related_nl_arr = -1;

	my ($rel_product_ids, $bg_result, $unique_partcodes, $unmatchedCount, $alreadyHave, $collect_product_ids, $additional_hash);
	$unique_partcodes = {};
	$unmatchedCount = 0;
	
	for my $related (@related_arr) {
		next if length($related) < 3; # ignore partcodes with characters less than 3

		# fight with duplicates
		next if $unique_partcodes->{$related}; # do not process duplicates
		$unique_partcodes->{$related} = 1;
		
		$rel_product_ids = $supplier_id ? do_query("select product_id from product where prod_id = ".str_sqlize($related)." and supplier_id = ".$supplier_id) : [ [ undef ] ];

		unless ($rel_product_ids->[0][0]) {
			$rel_product_ids = do_query("select product_id from product where prod_id = ".str_sqlize($related));
		}

		my $howMany = 0;
		for (@$rel_product_ids) {
			push @$collect_product_ids, $_->[0];
			$howMany++;
#			log_printf("hoMany = ".$howMany);
		}

		$additional_hash->{$related} = $howMany;
	}

	return [ $collect_product_ids, $additional_hash ];
} # sub get_product_id_list_from_raw_batch

sub get_overall_features_info_per_product {
	my ($p_id, $langid, $option) = @_;

	unless ($option->{'catid'}) {
		$option->{'catid'} = do_query("select catid from product where product_id=".$p_id)->[0][0];
	}

	return undef unless $option->{'catid'};

	my ($p_f_l_id, $p_f_pr_value, $lang_clause, $local_table, $localized, $ms_value, $f_g_value);

	if ($langid) {
		$p_f_l_id = 'if(pfl.product_feature_local_id is not null, pfl.product_feature_local_id, 0)';
		$p_f_pr_value = 'if(pfl.product_feature_local_id is not null, pfl.value, pf.value)';
		$lang_clause = ' and langid in ('.$langid.',1)';
		$local_table = 'left  join product_feature_local pfl on cf.category_feature_id = pfl.category_feature_id and pfl.product_id = '.$p_id.' and pfl.langid = '.$langid.' and pfl.value != \'\'';
		$localized = 'if(pfl.product_feature_local_id is not null, 1, 0)';
		$f_g_value = '(select fgv.value from vocabulary fgv where fg.sid=fgv.sid and fgv.langid='.$langid.')';
	}
	else {
		$p_f_l_id = '0';
		$p_f_pr_value = 'pf.value';
		$lang_clause = '';
		$local_table = '';
		$localized = '0';
		$f_g_value = "''";
	}

	$ms_value = "if((msl.value != '' and msl.value is not null),msl.value,ms1.value)";
	
	# TODO: using local values if INT values are absent!

	do_statement("drop temporary table if exists itmp_category_feature");
	do_statement("create temporary table itmp_category_feature (
category_feature_id       int(13) primary key,
feature_id                int(13) not null default '0',
catid                     int(13) not null default '0',
category_feature_group_id int(13) not null default '0',
searchable                int(3)  not null default '0',
no                        int(5)  not null default '0',
restricted_search_values  text,
mandatory                 tinyint(2) not null default '0',
key (catid, feature_id),
key (feature_id))");

	do_statement("alter table itmp_category_feature disable keys");
	
	# pf

	do_statement("insert into itmp_category_feature
(category_feature_id,category_feature_group_id,feature_id,catid,searchable,no,restricted_search_values,mandatory)
select SQL_BUFFER_RESULT cf.category_feature_id,cf.category_feature_group_id,cf.feature_id,cf.catid,cf.searchable,cf.no,cf.restricted_search_values,cf.mandatory
from product_feature pf
inner join category_feature cf using (category_feature_id)
where pf.product_id = ".$p_id." and cf.catid = ".$option->{'catid'}." and pf.value != ''");

	if ($langid) {
		do_statement("insert ignore into itmp_category_feature
(category_feature_id,category_feature_group_id,feature_id,catid,searchable,no,restricted_search_values,mandatory)
select SQL_BUFFER_RESULT cf.category_feature_id,cf.category_feature_group_id,cf.feature_id,cf.catid,cf.searchable,cf.no,cf.restricted_search_values,cf.mandatory
from product_feature_local pfl
inner join category_feature cf using (category_feature_id)
where pfl.product_id = ".$p_id." and cf.catid = ".$option->{'catid'}." and pfl.value != '' and pfl.langid = ".$langid);
	}

	do_statement("alter table itmp_category_feature enable keys");

#
#   0 - product_feature_id
#s  1 - product feature international value
#s  2 - product feature language-specific value (without artificially adding the measure unit), otherwise - product feature international value
#   3 - feature_id
#   4 - measure_id
#   5 - category_feature_id
#   6 - category_feature_group_id
#   7 - sorting
#   8 - feature name cache
#   9 - sign name cache
#  10 - measure sign old (deprecated, only for XML to deprecated field)
#s 11 - measure sign new
#  12 - localized
#s 13 - translated vocabulary value
#
#s 14 - feature_group value (new, for products_overall) for langid=1
#s 15 - feature_group value (new, for products_overall) for langid=N
#s 16 - measure sign english
#  17 - feature english name
#
#  18 - product_feature_local_id
#

	my $feats = do_query("select if(pf.product_feature_id is not null, pf.product_feature_id, 0) id, pf.value pf_value, ".$p_f_pr_value." pf_pr_value, f.feature_id, f.measure_id, cf.category_feature_id,
/* 6 */ cf.category_feature_group_id,
/* 7 */ (cf.searchable * 10000000 + (1 - f.class) * 100000 + cf.no) sorting,

/* 8 */ (select group_concat(pxc.xmlfeature_chunk order by pxc.langid desc separator '') from product_xmlfeature_cache pxc where pxc.feature_id = cf.feature_id ".$lang_clause." group by cf.feature_id) fn,

/* 9 */ (select group_concat(concat('<Sign ID=\"',ms.measure_sign_id,'\" langid=\"',ms.langid,'\">',ms.value,'</Sign>') order by ms.langid desc separator '') from measure_sign ms where ms.measure_id=f.measure_id and ms.value != '' ".$lang_clause." group by ms.measure_id) ms,

/* 10 */ m.sign ms_old,

/* 11 */ if((msl.value != '' and msl.value is not null),msl.value,ms1.value) ms_new,

/* 12 */ ".$localized." localized,

/* 13 */ if((cf.restricted_search_values != '' or f.restricted_values != ''),(select fvv.value from feature_values_vocabulary fvv where fvv.langid=".$langid." and fvv.key_value = pf_pr_value),'') voc_value,

/* 14 */ (select fgv1.value from vocabulary fgv1 where fg.sid=fgv1.sid and fgv1.langid=1) f_g_value_1,

/* 15 */ ".$f_g_value." f_g_value,

/* 16 */ ms1.value ms_English,

/* 17 */ fv.value f_English_name,

/* 18 */ ".$p_f_l_id." local_id,
/* 19 */ cf.mandatory,
/* 20 */ cf.searchable,
/* 21 */ f.type
from itmp_category_feature cf
left  join product_feature pf on cf.category_feature_id = pf.category_feature_id and pf.product_id = ".$p_id." and pf.value != ''
inner join feature f using (feature_id)
left  join vocabulary fv on f.sid=fv.sid and fv.langid=1
left  join category_feature_group cfg using (category_feature_group_id)
left  join feature_group fg using (feature_group_id)
left  join measure m on f.measure_id=m.measure_id
left  join measure_sign msl on f.measure_id=msl.measure_id and msl.langid=".$langid."
left  join measure_sign ms1 on f.measure_id=ms1.measure_id and ms1.langid=1

".$local_table."

where cf.catid = ".$option->{'catid'}." ".$option->{'condition'}." order by f.class asc, cfg.no desc, cfg.category_feature_group_id asc, cf.searchable desc, cf.no desc");

	do_statement("drop temporary table if exists itmp_category_feature");
	if ($langid && $langid != 1) {
		for my $feat (@$feats) {
			if (scalar(grep(/^$feat->[21]$/, ('dropdown','multi_dropdown','text','textarea','')))) {
				my @multi_feats = split(',', @$feat->[2]);
				next if (scalar(@multi_feats) <= 1 || $feat->[2] ne $feat->[1]); # have only one value or none it should be translated before or we have local value
				my $trans_value;
				my $statement_count=0;
				my $is_all_translated=1;
				for	my $multi_feat (@multi_feats) {
					my $trans_feat = do_query('SELECT value FROM feature_values_vocabulary WHERE langid = '.$langid.' and key_value = '.str_sqlize(trim($multi_feat)))->[0][0];
					if ($trans_feat) {
						$trans_value = $trans_value . ', ' . $trans_feat;
					}
					else {
						$is_all_translated = 0;# not all values were translated
						$trans_value = $trans_value . ', ' . trim($multi_feat);
					}
					$statement_count++ if $trans_feat =~ /[\s\n\t]+/;
				}
				 			
				if ($feat->[21] eq 'multi_dropdown' && $trans_value) { # if type is multi_dropdown and we have something to show					
					$trans_value =~ s/^,\s//;	
					$feat->[13] = $trans_value;
				}
				elsif ($is_all_translated && $statement_count > 1) { # we had statement but thet all was translated
					$trans_value =~ s/^,\s//;	
					$feat->[13] = $trans_value;
				}
				elsif ($statement_count == 0 && !$is_all_translated) { # we had not all translated but there was no statement   
					$trans_value =~ s/^,\s//;	
					$feat->[13] = $trans_value;
				}
			}
		}
	}
	return $feats;
} # sub get_overall_features_info_per_product

sub get_summary_descriptions {
	my ($product_id, $langid, $option) = @_;
	
	unless ($option->{'supplier_name'}) { # set main variables
		my $other = do_query("select p.name, pn.name, trim(v1.value), trim(vn.value), s.name from product p
inner join supplier s on p.supplier_id=s.supplier_id
left join product_family pf using (family_id)
left join vocabulary v1 on pf.sid=v1.sid and v1.langid=1
left join vocabulary vn on pf.sid=vn.sid and vn.langid=" . ( $langid || 0 ) . "
left join product_name pn on p.product_id=pn.product_id and pn.langid=" . ( $langid || 0 ) . "
where p.product_id=".$product_id." limit 1")->[0];

		#$option->{'name'} =          ($other->[1] || $other->[0]);
		$option->{'long_name'} =     $langid < 1 ? $other->[0] : ( $other->[1] || $other->[0] );
		$option->{'name'}     =      $option->{'long_name'}; 
		#$option->{'family'} =        $other->[2];
		$option->{'long_family'} =   $other->[3] || $other->[2];
		$option->{'family'}      = 	 $option->{'long_family'};   
		$option->{'supplier_name'} = $other->[4];
	}

	return undef unless ($option->{'supplier_name'});
		
	my ($group, $tab2, $tab3, $f_pr_value, $f_value, $j, $f_g_value, $not_touch_f_value, $not_touch_f_pr_value);
	
	# TAB 2 - short summary desc
	$tab2 = '';
	$tab2 = $option->{'supplier_name'}." ".$option->{'name'}; # BN PN
	$tab2 .= " ".$option->{'family'} if $option->{'family'}; # FN
	
	# TAB 3 - long summary desc
	$tab3 = '';
	$tab3 = $option->{'supplier_name'}." ".$option->{'long_name'}; # BN PN
  $tab3 .= ", ".$option->{'long_family'} if $option->{'long_family'}; # FN
	
	$j = 0;
	
	my $pf = get_overall_features_info_per_product($product_id, $langid, {'condition' => 'and f.class=0 and fg.feature_group_id > 0'});

	for (@$pf) {
		$f_g_value = $_->[15] ? $_->[15] : $_->[14];

#		print $_->[13] . "\t" . $_->[2] ."\n";

		#$f_value = form_presentation_value($_->[1], $_->[16]);
		#$f_value =~ s/<br>//sg;
		#_truncate_long_values(\$f_value);

		$f_pr_value = form_presentation_value($_->[13] ne '' ? $_->[13] : $_->[2], $_->[11]);
		$f_pr_value =~ s/<br>//sg;
		_truncate_long_values(\$f_pr_value);


		#$not_touch_f_value = 0;
		#if (($f_value eq '') || ($f_value =~ /^\d+$/) || (_is_a_standard_value($f_value,$_->[1],$langid))) {
		#	$not_touch_f_value = 1;
		#}
		
		$not_touch_f_pr_value = 0;
		if (($f_pr_value eq '') || ($f_pr_value eq '-') || ($f_pr_value =~ /^\d+$/) || (_is_a_standard_value($f_pr_value,$_->[1],$langid))) {
			$not_touch_f_pr_value = 1;
		}


		#unless ($not_touch_f_value) {
		#	if ($j < 6) {
		#		$j++;
		#		$f_value =~ s/\t/ /sg;
		#		$f_value =~ s/\r\n/ /sg;
		#		$f_value =~ s/\n/ /sg;
		#		$tab2 .= ", ".$f_value;
		#	}
		#}


		unless ($not_touch_f_pr_value) {
			if ($group ne $f_g_value) {
				$tab3 .= ". ".$f_g_value.": ";
			}
			else {
				$tab3 .= ", ";
			}
			
			$f_pr_value =~ s/\t/ /sg;
			$f_pr_value =~ s/\r\n/ /sg;
			$f_pr_value =~ s/\n/ /sg;
			$tab3 .= $f_pr_value;
			
			if($j < 6){
				$tab2 .= ", ".$f_pr_value;
			}
			$j++;
			$group = $f_g_value;
		}

	} # for
	
	return { 'short' => $tab2, 'long' => $tab3 };
} # sub get_summary_descriptions

sub _is_a_standard_value {
  my ($value, $value_wo_unit, $langid) = @_;

	my $standard_values = {
		1 => [ 'Y',
					 'N',
					 'Yes',
					 'No',
					 'na',
					 'n/a' ]
	};
	
	my $standard_values_EN = $standard_values->{1};
	
	# complete standard values with localized standard values
	if ($standard_values_local == undef) {
		my $standard_values_local_from_database = do_query("select value, langid from feature_values_vocabulary where key_value in ('" . ( join "','", @$standard_values_EN ) . "') and key_value != value");
		for (@$standard_values_local_from_database) {
			push @{$standard_values_local->{$_->[1]}}, $_->[0];
		}
	}

	# check ENglish values only
  for (@$standard_values_EN) {
#		log_printf("EN: ".$_);
    return 1 if ((lc($value) eq lc($_)) || (lc($value_wo_unit) eq lc($_)));
  }

	my $standard_values_specific_lang = $standard_values_local->{$langid};

	# check $langid-specific values
  for (@$standard_values_specific_lang) {
#		log_printf("nonEN (".$langid."): ".$_);
    return 1 if ((lc($value) eq lc($_)) || (lc($value_wo_unit) eq lc($_)));
  }
	
  return 0;
} # sub _is_a_standard_value

sub _truncate_long_values {
  my $rstr = shift;

  if (length($$rstr) > 100) { # long value
    $$rstr = substr($$rstr, 0, 100);
    $$rstr =~ s/^(.*)\r?\n.*?$/$1/s;
    $$rstr =~ s/\r$//s;
    $$rstr = '' if length($$rstr) == 100;
  }
} # sub _truncate_long_values


sub load_data2globals
{
 if(!defined $category_features){
	my $raw_category_features =	do_query('select category_feature_id, catid, feature_id, category_feature_group_id, no from category_feature');
  for my $row (@$raw_category_features){
	 $category_features->{$row->[1]}->{$row->[2]} = $row->[0];
	 $category_features_ref->{$row->[0]} = 
								 {
									 'feature_id' => $row->[2],
									 'catid'			=> $row->[1],
									 'category_feature_group_id' => $row->[3],
									 'no'					=> $row->[4]
								 };
  }
	
	my $raw_category_feature_groups = do_query("select category_feature_group_id, feature_group_id, catid, no from category_feature_group");
	for my $row (@$raw_category_feature_groups){
	 $category_feature_groups->{$row->[2]}->{$row->[1]} = $row->[0];
	 $category_feature_groups_ref->{$row->[0]} =
			 {
			  'feature_group_id'		=> $row->[1],
				'catid'								=> $row->[2],
				'no'									=> $row->[3]
			 }; 
	}
 }

}

sub merge_categories
{
 my ($src_catid, $dst_catid) = @_;

 load_data2globals();

 my $src_cat_feats = do_query("select category_feature_id from category_feature where catid = $src_catid");

 for my $row(@$src_cat_feats){
  my $src_category_feature_id = $row->[0];
	
	
	my $feature_id = $category_features_ref->{$src_category_feature_id}->{'feature_id'};

	
	my $new_category_feature_id = $category_features->{$dst_catid}->{$feature_id};

	if(!$new_category_feature_id){
	 my $feature_group_id = $category_feature_groups_ref->{$category_features_ref->{$src_category_feature_id}->{'category_feature_group_id'}}->{'feature_group_id'};
	 my $group_no 				= $category_feature_groups_ref->{$category_features_ref->{$src_category_feature_id}->{'category_feature_group_id'}}->{'no'};

	 my $hash = {
								'catid' 			=> $dst_catid,
								'feature_id'	=> $feature_id,
								'no'					=> $category_features_ref->{$src_category_feature_id}->{'no'},
								'category_feature_group_id' => $category_feature_groups->{$dst_catid}->{$feature_group_id}
							};
	 $new_category_feature_id = raw_create_category_feature($hash, $feature_group_id, $group_no);
	}
	
	update_rows('product_feature', " category_feature_id = ".str_sqlize($src_category_feature_id),
 									 {
										 "category_feature_id" => $new_category_feature_id,
									 }
				 ); 
 }

 # changing product records
 update_rows('product', " catid = ".str_sqlize($src_catid), 
		{
		 "catid" => $dst_catid
		});

 # changing category mappings
 update_rows('data_source_category_map', " catid = ".str_sqlize($src_catid), 
		{
		 "catid" => $dst_catid
		});
 # changing product families

 update_rows('product_family', " catid = ".str_sqlize($src_catid), 
		{
		 "catid" => $dst_catid
		});
 # changing category parents of the childs
 update_rows('category', " pcatid = ".str_sqlize($src_catid),
               {
                "pcatid" => $dst_catid
               });
 
 # cleaning up 
  my $row = do_query("select sid, tid from category where catid = $src_catid limit 1")->[0];
    delete_rows('vocabulary', " sid = $row->[0] ");
    delete_rows('tex', " tid = $row->[1] ");
		
 	delete_rows('category', " catid = $src_catid ");		
 	delete_rows('category_feature', " catid = $src_catid ");		
 	delete_rows('category_feature_group', " catid = $src_catid ");		
	
}

sub conform_product_feature_catid {
	my $product_id = shift;
	my $catid = do_query("select catid from product where product_id = " . $product_id)->[0]->[0];
	load_data2globals();
	my $product_features = do_query("select product_feature_id, category_feature_id from product_feature where product_id = " . $product_id);
	
	for my $row(@$product_features) {
		# moving each product feature
		my $new_category_feature_id;
		my $feature_id = $category_features_ref->{$row->[1]}->{'feature_id'};
		my $old_catid = $category_features_ref->{$row->[1]}->{'catid'};
		my $old_category_feature_group_id = $category_features_ref->{$row->[1]}->{'category_feature_group_id'};
		my $feature_group_id = $category_feature_groups_ref->{$old_category_feature_group_id}->{'feature_group_id'};
		
		if($old_catid == $catid){ next; }
		
		if ($category_features->{$catid}->{$feature_id}) {
			$new_category_feature_id = $category_features->{$catid}->{$feature_id};
		} else {
			# this would create an extra category feature link of the destination cat doesn't have it	 
			#	   my $new_category_feature_group_id = $category_feature_groups->{$catid}->{$feature_group_id};
			#		 my $group_no 		= $category_feature_groups_ref->{$old_category_feature_group_id}->{'no'};
			#		 my $feature_no 	= $category_features_ref->{$row->[1]}->{'no'};
			#		 my $hash = {
			#								 'catid'			=> $catid,
			#								 'feature_id'	=> $feature_id,
			#								 'no'					=> int($feature_no),
			#								 'category_feature_group_id' => $new_category_feature_group_id
			#								};
			#		 
			#		 $new_category_feature_id = raw_create_category_feature($hash, $feature_group_id, $group_no);
			#		 $category_feature_groups->{$catid}->{$feature_group_id} = $hash->{'category_feature_group_id'};

			# but we don't wan't this, so just deleting this category feature
		 	delete_rows('product_feature', " product_feature_id = $row->[0]");
		 	next;
		}
		update_rows ('product_feature', " product_feature_id = $row->[0]",
			{
				'category_feature_id' => $new_category_feature_id
			}
		);
	}
}

sub raw_create_category_feature
{
 my ($hash, $feature_group_id, $group_no) = @_;
 
 my $category_feature_id;

 if(!$hash->{'category_feature_group_id'}){
  if(!$feature_group_id){ $feature_group_id = 0 }
	$hash->{'category_feature_group_id'} = raw_create_category_feature_group( 
																						{
																						 'feature_group_id'	=> $feature_group_id,
																						 'catid'						=> $hash->{'catid'},
																						 'no'								=> int($group_no)
																						});
 }
 
 if(insert_rows('category_feature', $hash)){
		 $category_feature_id = sql_last_insert_id();
 }
}

sub raw_create_category_feature_group
{
my ($hash) = @_;
	my $category_feature_group_id;

	if(insert_rows('category_feature_group', $hash)){
		$category_feature_group_id = sql_last_insert_id();
	}
	return $category_feature_group_id;
}

sub merge_features
{
my ($src_id, $dst_id) = @_;

# first getting cats to which the $src is assigned

my $assigned_src = do_query("select catid, category_feature_id,category_feature_group_id from category_feature where feature_id = $src_id");
my $assigned_dst = do_query("select catid, category_feature_id,category_feature_group_id from category_feature where feature_id = $dst_id");

for my $row(@$assigned_src){
# for entry we are checking if there exists $dst_id feature in category features

my $dst_is_assigned = 0;
my $cat_feat_id; # of dst category feature

  for my $row1(@$assigned_dst){
	 # if catid the same - we are in
	  if($row->[0] == $row1->[0]){
     $dst_is_assigned = 1;		
		 $cat_feat_id = $row1->[1];
		}
	}
# now we knows if dst is assigned to this src row
	 if(!$dst_is_assigned){
 # we should assign dst feature to category src row
 
		 insert_rows('category_feature', { 'catid' 			=> $row->[0],
																		'feature_id' 	=> $dst_id,
																		'category_feature_group_id' => $row->[2]
																	});
		 $cat_feat_id = sql_last_insert_id();
  	 push @$assigned_dst, [ $row->[0], $cat_feat_id ];
 
	 }
	# now dst is definitely assigned to category row $row

	# category features merging
	merge_category_features($row->[1], $cat_feat_id);
}

my $data = do_query("select sid,tid from feature where feature_id = $src_id");
if(defined $data->[0]){
 my $sid = $data->[0][0];
 my $tid = $data->[0][1];

 if($sid){ 
	 delete_rows("sid_index", " sid = $sid");
	 delete_rows("vocabulary", " sid = $sid");
 }
 
 if($tid){ 
	 delete_rows("tid_index", " tid = $sid");
	 delete_rows("tex", " tid = $sid");
 }
}

update_rows('IGNORE data_source_feature_map', " feature_id = $src_id", { 'feature_id' => $dst_id });
delete_rows('data_source_feature_map', " feature_id = $src_id");
delete_rows('feature', " feature_id = $src_id");

}

sub merge_category_features
{
my ($src_cat_feat_id, $cat_feat_id) =@_;

# getting all product_feature data

my $pr_feat_src = do_query("select product_feature_id, product_id, value from product_feature where category_feature_id = $src_cat_feat_id");

for my $pr_row(@$pr_feat_src){
# 
	my $pr_feat_dst = do_query("select product_feature_id, value from product_feature where product_id = $pr_row->[1] and category_feature_id = $cat_feat_id");
	my $value;

	 if(defined  $pr_feat_dst->[0]){
			# we have product_feature entry 

			if($pr_row->[2]){
					# we have src value

					 if($pr_feat_dst->[0][1]){
							 # we have dst value
	 
							  if($pr_feat_dst->[0][1] ne $pr_row->[2]){
							  	# we have dst value and they are different
								  $value = $pr_feat_dst->[0][1].', '.$pr_row->[2];
								} else {
								  $value = $pr_feat_dst->[0][1]; # they are the same
								}
					 } else {
						  $value = $pr_row->[2]; # dst value is empty
					 }
			} else {
			  $value = $pr_feat_dst->[0][1]; # src value is empty
			}
	
		  update_rows('product_feature', " product_feature_id = $pr_feat_dst->[0][0]",
			  {
				 "value" => str_sqlize($value)
				});	
			delete_rows('product_feature', " product_feature_id = $pr_row->[0]");
 } else {
 # we have src only
 
		  update_rows('product_feature', " product_feature_id = $pr_row->[0]", 
				  {
					 'category_feature_id' => $cat_feat_id
					});
 }
}

 delete_rows('category_feature', " category_feature_id = $src_cat_feat_id");
}


sub load_flat_file
{
my ($path, $options) = @_;

my $res = [];

if(!$options->{'delimiter'}){
 $options->{'delimiter'} = "\t"; # by default
}


open(FILE, "<".$path) or log_printf("fatal: can't open file $path: $!\n");

my $line = 0;

my $file = join('', <FILE>);

if($options->{'conversion'} eq 'utf82latin'){
 $file = utf82latin($file);
#log_printf('Converted '.$path.' to'."\n".$file);
}

$file =~s/\r//g;

if($options->{'kill'}){
 for my $item(@{$options->{'kill'}}){
		$file =~s/$item//gsm;
 }
}

my @file = split(/\n/, $file);
my $header;
my $undef = 'CODED UNDEF';
while($_ = shift @file){
 chomp;
 s/\r//g; # removing trash
 s/($options->{'delimiter'})$options->{'delimiter'}/$1$undef$1/m;
 my @data = split ( /$options->{'delimiter'}/ );
 
# log_printf(join('!',@data)."\n\n".$_);

 if(my $strip = $options->{'strip'}){
  for my $elem(@data){
 	 $elem =~s/^$strip//;
	 $elem =~s/$strip$//;
	}
	
 }

  for my $elem(@data){
	 if($elem eq $undef){
	  $elem = '';
	 }
	}
 
 if(!$line && $options->{'skip_header'}){
  $header = \@data; 
  $line++;
#	log_printf(Dumper($header));
	next;
 } 
 
 my $reference = \@data;
 
 if($options->{'map_by_header'} && $options->{'skip_header'}){
    if(!$options->{'add_missed_fields'}){
		  if( $#$header != $#data ){
			 log_printf("data rows and header are mismatch ( $#$header \!\= $#data) in line $line");
	 		} else {
		 		my %data_map = map { $header->[$_] => $data[$_]  } (0..$#$header);
		 		$reference = \%data_map;
			}
		} else {
 			if( $#$header != $#data ){
#			 $data[$#data+1..$#$header] = '';
	 		} 
		 		my %data_map = map { $header->[$_] => $data[$_]  } (0..$#$header);
		 		$reference = \%data_map;
		}
 } 
# log_printf(Dumper($reference));
 $line++;
 push @$res, $reference;
}


close(FILE);

return $res;

}

sub load_mapping_file
{
 my ($path, $options) = @_;
 
 my $hash = {};
 
 if(!$options->{'delimiter'}){
  $options->{'delimiter'} = '=>';
 }
 
 open(FILE, "<".$path);
 
 while(<FILE>){
  s/\r//g;
  my ($entry, $value) = split( $options->{'delimiter'} );
	
	$value =~s/\s+\Z//;
	$value =~s/^\s+//;	
	$entry =~s/\s+\Z//;
	$entry =~s/^\s+//;	
	
	$hash->{$entry} = $value if ($entry);
#	print " \$hash->{$entry} = !$value!; \n";
 }
 
 close(FILE);
 
 return $hash;
} 

sub smart_update
{
my ($table, $key_attr, $hash) = @_;
my $res;

if($hash->{$key_attr}){
 # we already have such record
 my $key_val = $hash->{$key_attr};
 my $saved = $hash->{$key_attr};
 
 delete $hash->{$key_attr};
 
 $res = update_rows($table, " $key_attr = ".str_sqlize($key_val), $hash);
 return $hash->{$key_attr} = $saved;
} else {
 # inserting
 delete $hash->{$key_attr};
 if(insert_rows($table, $hash)){
	 $hash->{$key_attr} = sql_last_insert_id();
#	 log_printf("\$hash->{$key_attr}  = $hash->{$key_attr} ");
	 return $hash->{$key_attr};
 } 
}

}

sub load_data_source_prefs
{
my ( $code, $langid, $shadow, $suppliers ) = @_;

if(!$langid){
 $langid = 1; # default english
}

 my $prefs = get_rows('data_source', " code = ".str_sqlize($code));
 
#debug only!!!
# return $prefs; 

 if(defined $prefs&defined $prefs->[0]){

	$prefs = $prefs->[0];
	$prefs->{'ignored_products_list'} = []; 
  $prefs->{'total_products'} = 0;
  $prefs->{'added_products'} = 0;	
	$prefs->{'updated_products'} = 0;
	$prefs->{'ignored_products'} = 0;
	

	# now loading cats mapping
	my $cats = do_query("select symbol, catid from data_source_category_map where data_source_id = ".$prefs->{'data_source_id'}." order by catid asc");
  # each symbol should be unique!
	# making a hash
	my %cats = map { uc($_->[0]) => $_->[1]  } @$cats;
	$prefs->{'category_map'} = \%cats;
	log_printf("\ncats loaded");

  # now loading features mapping
	unless ( $shadow->{'feature_map'}){
		my $feat = do_query("select symbol, feature_id, override_value_to, catid, coef,format from data_source_feature_map where data_source_id = ".$prefs->{'data_source_id'});
 	 # each symbol should be unique!
		# making a hash
		for(@$feat){
		    push @{$prefs->{'feature_map'}->{$_->[0]}->{$_->[3]}}, 
		    { 
			'feature_id' 				=> $_->[1],
			'override_value_to'	=> $_->[2],
			'coef'							=> $_->[4],
			'format'						=> $_->[5]
			};
		    
		}	
		log_printf("\nfeatures loaded");
	}
  # now loading suppliers mapping
	my $supp = do_query("select symbol, supplier_id from data_source_supplier_map where data_source_id = ".$prefs->{'data_source_id'}." order by supplier_id asc");
  # each symbol should be unique!
	# making a hash
	my %supp = map { uc($_->[0]) => uc($_->[1])  } @$supp;
	$prefs->{'supplier_map'} = \%supp;
	log_printf("\nsupplier loaded");
	
	# if need (defined @$suppliers) - create temporary table products_suppliers
	my $condition; # 1 or 2 or 3 etc.
	if (defined @$suppliers) {
	    my @s = @$suppliers;
	    for (0 .. $#s) { $condition.=" supplier_id='".$s[$_]."' or " }
	    $condition =~ s/(.*)\sor\s/$1/g;
	    my $tmpq = "create temporary table product_supplier select product_id from product where ".$condition;
	    #print $tmpq."\n";
	    do_statement($tmpq);
	}
	
	# now loading products info
	unless ( $shadow->{'product'}){
		my $data;
		if (defined @$suppliers) {
		    $data = do_query("select supplier_id, prod_id, user_id, catid, product_id, low_pic, high_pic from product where ".$condition);
		}
		else {
		    $data = do_query("select supplier_id, prod_id, user_id, catid, product_id, low_pic, high_pic from product");
		}
		for my $row(@$data){
			$prefs->{'product'}->{$row->[0]}->{uc($row->[1])} = 
			  {
				  'user_id'		=>	$row->[2],
					'catid'			=>	$row->[3],
					'product_id'=> 	$row->[4],
					'low_pic'		=>	$row->[5],
					'high_pic'	=>	$row->[6]
				};
				
		}
		log_printf("\nproducts loaded");
  }
	# product descriptions	
	unless (  $shadow->{'product_description'} ){
		my $data;
		if (defined @$suppliers) {
		    $data = do_query("select p.product_id, p.product_description_id, p.langid from product_description as p inner join product_supplier as p2 on p.product_id=p2.product_id");
		}
		else {
		    $data = do_query("select product_id, product_description_id, langid from product_description");
		}
		for my $row(@$data){
			$prefs->{'product_description'}->{$row->[0]}->{$row->[2]} = $row->[1];
		}	
	}
	# now loading category features
	unless ( $shadow->{'category_feature'} ){
		my $cat_feat_ref = do_query("select category_feature_id, feature_id, catid from category_feature");
		for my $cat_feat(@$cat_feat_ref){
			$prefs->{'category_feature'}->{$cat_feat->[2]}->{$cat_feat->[1]} = $cat_feat->[0];
			$prefs->{'category_feature_ref'}->{$cat_feat->[0]}  = 
			  { 'feature_id' => $cat_feat->[1],
					'catid' =>  $cat_feat->[0]};
		}
	}
	# now loading product features
	unless (  $shadow->{'product_feature'} ){
#		my $product_feat_ref = do_query("select product_feature_id, category_feature_id, product_id from product_feature");
#		for my $product_feat(@$product_feat_ref){
#			$prefs->{'product_feature'}->{$product_feat->[2]}->{$product_feat->[1]} = $product_feat->[0];
#		}
#		my $query = 'select distinct product_id from product_feature';
		my $query;
		if (defined @$suppliers) {
		    $query = "select distinct pf.product_id from product_feature as pf inner join product_supplier as ps on pf.product_id=ps.product_id";
		}
		else {
		    $query = "select distinct product_id from product_feature";
		}
		my $product_id = do_query($query);
		for my $product ( @$product_id ) {
			$query = "select product_feature_id, category_feature_id, product_id from product_feature where product_id='".$product->[0]."'";
			my $product_feat_ref = do_query($query);
			for my $product_feat(@$product_feat_ref){
				$prefs->{'product_feature'}->{$product_feat->[2]}->{$product_feat->[1]} = $product_feat->[0];
			}
		}
	}
	# now loading features info
	unless (  $shadow->{'feature'} ){
		my $data = do_query("select f.feature_id, v.value, ms.value, mn.value, f.measure_id, f.sid, f.tid
from feature f
inner join vocabulary v on f.sid=v.sid and v.langid=".str_sqlize($langid)."
left  join measure_sign ms on f.measure_id = ms.measure_id and ms.langid=v.langid
inner join measure m on f.measure_id = m.measure_id
inner join vocabulary mn on m.sid = mn.sid and mn.langid = v.langid");
		for my $row(@$data){
			$prefs->{'feature'}->{$row->[0]} = 
		  	{
					'name' 		=>	$row->[1],
					'sign'		=> 	$row->[2],
					'measure_name' => $row->[3],
					'measure_id' => $row->[4],
					'sid'			=> $row->[5],
					'tid'			=> $row->[6]
				};
		}
	}
	# now loading categories info
	my $data = do_query("select catid, vocabulary.value, pcatid, ucatid from category, vocabulary where category.sid = vocabulary.sid and vocabulary.langid = ".str_sqlize($langid)." and category.catid <> 1 ");
	for my $row(@$data){
		$prefs->{'category'}->{$row->[0]} = 
		  {
				'name' 		=>	$row->[1],
				'pcatid'	=> 	$row->[2],
				'uncatid'	=>	$row->[3],
				'catid'		=> $row->[0]
			};
	}
	unless ( $shadow->{'category_feature_group'}){	
		my $raw_category_feature_groups = do_query("select category_feature_group_id, feature_group_id, catid from category_feature_group");
		for my $row (@$raw_category_feature_groups){
	 	$prefs->{'category_feature_group'}->{$row->[2]}->{$row->[1]} = $row->[0];
		}
	}
	
	if (defined @$suppliers) { do_statement("drop temporary table product_supplier") }
	
	return $prefs;
 } else {
	return {};
 }
}

sub send_report {
	my ($prefs, $missing) = @_;

	my $related_found = $prefs->{'related_added'};
	my $missed_urls = $prefs->{'miss_pl_url'};

	my $miss_supp = join("\n", sort keys %{$missing->{'supplier'}});
	my $miss_feat = join("\n", sort keys %{$missing->{'feature'}});
	my $miss_cat = join("\n", sort keys %{$missing->{'category'}});
	my $miss_cat_feat = join("\n", sort keys %{$missing->{'category_feature'}});
	my $miss_dist;

	for (sort keys %{$missing->{'distributor'}}) {
		$miss_dist .= $_ . " (" . $missing->{'distributor'}->{$_} . " products)\n";
	}
	chop($miss_dist);

	my $miss_feat_val = '';
	my $miss_cat_mismatch = '';

	for my $feature_id (keys %{$missing->{'feature_value_mapping'}}) {
		$miss_feat_val .= "\n".$prefs->{'feature'}->{$feature_id}->{'name'}.'('.$prefs->{'feature'}->{$feature_id}->{'measure_name'}.")\n\t\t";
		$miss_feat_val .= join("\n\t\t", sort keys %{$missing->{'feature_value_mapping'}->{$feature_id}});
	}

	my $ignored_products = '';
	my $ignored_products_grouped = {};

	my $row;
	
	for $row (@{$prefs->{'ignored_products_list'}}) {
		push @{$ignored_products_grouped->{$row->{'reason'}}->{$row->{'ocat'}}}, $row;
	}
	
	for my $reason (keys %$ignored_products_grouped) {
		$ignored_products .= "  ".$reason.":\n";
		for my $ocat (sort keys %{$ignored_products_grouped->{$reason}}) {
			$ignored_products .= "        ".$ocat.":\n";
			for $row (@{$ignored_products_grouped->{$reason}->{$ocat}}) {
				$ignored_products .= sprintf("              %-18s %-18s %-60s\n", $row->{'prod_id'}, $row->{'supplier'}, $row->{'name'});
			}
		}
	}

	# NEW!!! for HP Provisioner only!!! check category mismatches

#	print Dumper($missing->{'category_mismatch'});

	my $miss_prod_ids = $missing->{'category_mismatch'};
	my ($cats, $miss_cats, $miss_new_cats);
	if ($miss_prod_ids) {
		my $categories = do_query("select c.catid, v.value from category c inner join vocabulary v on c.sid=v.sid and v.langid=1");
		for (@$categories) {
			$cats->{$_->[0]} = $_->[1];
		}

		for my $prod_id (sort {$a cmp $b} keys %$miss_prod_ids) {
			$miss_cats = $miss_prod_ids->{$prod_id};
			for (keys %$miss_cats) {
				$miss_new_cats = $miss_cats->{$_};
				$miss_cat_mismatch .= sprintf("  %-25s: %s => ", $prod_id, $cats->{$_});
				for (@$miss_new_cats) {
					$miss_cat_mismatch .= $cats->{$_}.", ";
				}
				chop($miss_cat_mismatch);
				chop($miss_cat_mismatch);
				$miss_cat_mismatch .= "\n";
			}
		}
	}
	
	if (!$ignored_products) {
		$ignored_products = 'None';
	}
	if (!$miss_supp) {
		$miss_supp = 'None found';
	}
	if (!$miss_feat) {
		$miss_feat = 'None found';
	}
	if (!$miss_cat) {
		$miss_cat = 'None found';
	}
	if (!$miss_cat_feat) {
		$miss_cat_feat = 'None found';
	}
	if (!$miss_feat_val) {
		$miss_feat_val = 'None found';
	}
	elsif ($prefs->{'ignore_feature_values_mapping_list'}) {
		$miss_feat_val = 'Disabled';
	}
	if (!$miss_cat_mismatch) {
		$miss_cat_mismatch = 'None found';
	}
	
	my $unmap_brand='';
	$unmap_brand="Deleted by unmapped brands products:".$prefs->{'deleted_by_brand'} if $prefs->{'deleted_by_brand'};
	my $body = "DATA SOURCE IMPORT REPORT\n\n
Data source: ".$prefs->{'code'}."\n

Products      : ".$prefs->{'total_products'}." \n
Added         : ".$prefs->{'added_products'}." \n
Updated       : ".$prefs->{'updated_products'}." \n
Ignored       : ".$prefs->{'ignored_products'}." \n
Already edited: ".$prefs->{'not_updated'}." \n
%%icecat_pub_attachment_links%%
$unmap_brand
Missing following structures:\n\n".
($miss_dist ? "Distributors: \n" . $miss_dist . "\n\n" : "")."
Suppliers: \n".$miss_supp."\n\n
Categories: \n".$miss_cat."\n\n
Category-feature links: \n".$miss_cat_feat."\n\n
Features: \n".$miss_feat."\n\n
Feature value mappings: \n".$miss_feat_val."\n\n".
	($missed_urls ?("Such pricelists weren't downloaded: \n".$missed_urls."\n\n"):"").
	($miss_cat_mismatch ne 'None found'?("Category mismatches: \n".$miss_cat_mismatch."\n\n"):"").
	($related_found ?("Made up such product relations: \n".$related_found."\n\n"):"");
	
	my $pub_attachment_links = '';
	
	if ($prefs->{'send_report'}) {
		my $mail = {
			'to' => $prefs->{'email'},
			'from' => 'data source',
			'subject' => 'DATA SOURCE IMPORT REPORT'
			};

		$mail->{'default_encoding'} = $prefs->{'default_encoding'} if (defined $prefs->{'default_encoding'});
		
		if ($prefs->{'ignore_attachment'} != 1) {
			my $attached = "Ignored products list:\n\n".$ignored_products."\n";
			
			$mail->{'attachment_name'} = "report_".$prefs->{'code'}.".gz";
			$mail->{'attachment_content_type'} = 'application/x-gzip';
			$mail->{'attachment_body'} = gzip_data($attached,"report_".$prefs->{'code'}.".txt");
		}

		# add 2..5 attachments, just in case
		for my $suffix (2..5) {
			if ($prefs->{'ignore_attachment'.$suffix} != 1) {
				if (($prefs->{'pub_attachment'.$suffix}) && ($prefs->{'attachment'.$suffix.'_name'})) { # store to the pub folder (15.12.2009)
					# get the attachment filesize
					my (undef,undef,undef,undef,undef,undef,undef,$size,undef,undef,undef,undef,undef) = stat($atomcfg{'pub_path'}.$prefs->{'attachment'.$suffix.'_name'}.'.gz');
					# add the attachment info to the body
					$pub_attachment_links .= 'Attachment '.$atomcfg{'bo_host'}.'pub/'.$prefs->{'attachment'.$suffix.'_name'}.'.gz ('.$size." bytes) \n";
				}
				else { # send as attachment
					if ($prefs->{'attachment'.$suffix.'_name'}) {
						$mail->{'attachment'.$suffix.'_name'} = $prefs->{'attachment'.$suffix.'_name'}.".gz";
						$mail->{'attachment'.$suffix.'_content_type'} = 'application/x-gzip';
						$mail->{'attachment'.$suffix.'_body'} = atom_html::gzip_data($prefs->{'attachment'.$suffix.'_body'},$prefs->{'attachment'.$suffix.'_name'},$prefs->{'attachment'.$suffix.'_binmode'} eq 'raw' ? 'raw' : 'utf8');
					}
				}
			}
		}
		if($prefs->{'invalid_products'}){
			$mail->{'attachment6_name'} = "invalid_products.csv";
			$mail->{'attachment6_content_type'} = 'text/csv';
			$mail->{'attachment6_body'} = $prefs->{'invalid_products'};			
		}
		$body =~ s/%%icecat_pub_attachment_links%%/$pub_attachment_links/s;

		# store text body
		$mail->{'text_body'} = $body;

#		if ($prefs->{'send_xml'}){
#                        $mail->{'attachment_name'} = "nonmapped_products.xls.gz";
#                        $mail->{'attachment_content_type'} = 'application/x-gzip';
#                        $mail->{'attachment_body'} = $prefs->{'xls'};
#		}

#		log_printf(Dumper($mail));

    atom_mail::complex_sendmail($mail);
	}
	
	return $body;
}

sub  create_category_feature
{
my ($prefs, $feature_id, $catid, $no, $searchable)	= @_;

if(!$prefs->{'data_source_id'}){
 return -1;
}

 unless($prefs->{'category_feature'}->{$catid}->{$feature_id}){
    my $hash = {
																							 'catid' 			=> $catid,
																							 'feature_id'	=> $feature_id,
																							 'no'					=> $no,
																							 'searchable' => $searchable,
																							 'category_feature_group_id'	=> $prefs->{'category_feature_group'}->{$catid}->{$feature_id}
							 };
				
		if(!defined $searchable){ delete $hash->{'searchable'}};
		if(!defined $no){ delete $hash->{'no'}};
		
		
		$prefs->{'category_feature'}->{$catid}->{$feature_id}	= raw_create_category_feature($hash,0);
		$prefs->{'category_feature_group'}->{$catid}->{$feature_id} = $hash->{'category_feature_group_id'};
 }

return $prefs->{'category_feature'}->{$catid}->{$feature_id};
}

sub create_product_feature
{
my ($prefs, $product_id, $category_feature_id, $value, $missing)	= @_;

if(ref($prefs) ne 'HASH'){
 return -1;
}

# added suppressing feature values (Dima 14.06.2007)
#$value = suppress_feature_value({'value' => $value, 'category_feature_id' => $category_feature_id});

my ($mvalue, $err) = map_feature_value($prefs->{'category_feature_ref'}->{$category_feature_id}->{'feature_id'}, $value, $missing);

my $hash = 
  {
	  'product_feature_id'	=> $prefs->{'product_feature'}->{$product_id}->{$category_feature_id},
		'product_id'					=> $product_id,
		'category_feature_id'	=> $category_feature_id,
		'value'								=> str_sqlize($mvalue)
	};

smart_update('product_feature', 'product_feature_id', $hash);

$prefs->{'product_feature'}->{$product_id}->{$category_feature_id} 
  = $hash->{'product_feature_id'};

return $hash->{'product_feature_id'};
}

sub save_snapshot
{
my ($prefs) = @_;

insert_rows('snapshot', { 'data_source_id' => $prefs->{'data_source_id'},
													 'date'						=> time
												 });

my $snapshot_id = $prefs->{'shapshot'}->{'snapshot_id'} = sql_last_insert_id();


# snapping categories mapping
for my $symbol(keys %{$prefs->{'category_map'}}){
 if($prefs->{'category_map'}->{$symbol}){
	 
	 insert_rows('snapshot_category_map', { 'snapshot_id' => $snapshot_id,
																				 'symbol'			 => str_sqlize($symbol),
																				 'catid' 			 => str_sqlize($prefs->{'category_map'}->{$symbol})
																			  }
							);
 }
}

# snapping features mapping
for my $symbol(keys %{$prefs->{'feature_map'}}){
	for my $catid(keys %{$prefs->{'feature_map'}->{$symbol}}){
	 for my $hash($prefs->{'feature_map'}->{$symbol}->{$catid}->{'feature_id'}){
			if($hash->{'feature_id'}){
	 	 			insert_rows('snapshot_feature_map', { 'snapshot_id' => $snapshot_id,
																				 'symbol'			 => str_sqlize($symbol),
																				 'catid' 			 => str_sqlize($catid),
																				 'override_value_to' => str_sqlize($hash->{'override_value_to'}),
																				 'feature_id' 			 => str_sqlize($hash->{'feature_id'}),
																				 'coef'							 => str_sqlize($hash->{'coef'}),
																				 'format'						 => str_sqlize($hash->{'format'})
																			  }
							);
	 		}
		}
	 }
}

}

sub delete_last_snapshot
{
my ($prefs) = @_;

 my $snapshot_row = do_query("select snapshot_id from snapshot where data_source_id = ".$prefs->{'data_source_id'}." order by date desc limit 1")->[0];
 if($snapshot_row&&$snapshot_row->[0]){
  my $snapshot_id = $snapshot_row->[0];
	delete_rows('snapshot_category_map', " snapshot_id = ".$snapshot_id);
	delete_rows('snapshot_feature_map', " snapshot_id = ".$snapshot_id);
 }

}

sub load_last_snapshot
{
my ($prefs) = @_;
 
 my $snapshot_row = do_query("select snapshot_id from snapshot where data_source_id = ".$prefs->{'data_source_id'}." order by date desc limit 1")->[0];
 if($snapshot_row&&$snapshot_row->[0]){
  my $snapshot_id = $prefs->{'last_snapshot_id'} = $snapshot_row->[0];

	# now loading cats mapping
	my $cats = do_query("select symbol, catid from snapshot_category_map where snapshot_id = ".$snapshot_id);	
  # each symbol should be unique!
	# making a hash
	my %cats = map { $_->[0] => $_->[1]  } @$cats;
	$prefs->{'snapshot_category_map'} = \%cats;

  # now loading features mapping
	my $feat = do_query("select symbol, feature_id, override_value_to, catid, coef from snapshot_feature_map where snapshot_id = ".$prefs->{'last_snapshot_id'});	
  # each symbol should be unique!
	# making a hash
	for(@$feat){
	 push @{$prefs->{'snapshot_feature_map'}->{$_->[0]}->{$_->[3]}}, 
															{ 
	                              'feature_id' 				=> $_->[1],
																'override_value_to'	=> $_->[2],
																'coef'							=> $_->[4]
															};

	 }	

  }

}


sub copy_product 
##
## new capability - update dest product from source.
## for update set $update_flag to nonzero
## and set $product_ins->{'product_id'} to dest product_id:
##
##   $dest_prod->{'product_id'}=12345;
##   $copy_product(45678,$dest_prod,'UPDATE',$shadow); 
##   if ($shadow->{'user_no_change'}) then user don't changes
{
my ($source_product_id, $product_ins, $update_flag, $shadow) = @_;

my $product_id = copy_product_start($source_product_id, $product_ins, $update_flag, $shadow);
 if($product_id){
	copy_product_rest($source_product_id, $product_id, $shadow);
	return $product_id;
 }
}

sub copy_product_start ## new capability - update dest product from source, see comments on 'copy_product'
{
my ($source_product_id, $product_ins, $update_flag, $shadow) = @_;

my $source = get_rows('product', " product_id = $source_product_id ");
if($source){ $source = $source->[0]; }

for my $item(keys %$product_ins){
 $source->{$item} = $product_ins->{$item};
}

for my $item(keys %$source){
 $source->{$item} = str_sqlize($source->{$item});
}

delete $source->{'product_id'};
delete $source->{'updated'};

if ($update_flag){
    if ($shadow->{'user_no_change'}) {
	delete $source->{'user_id'};
    }
  my $update_product_id = $product_ins->{'product_id'};
  my $res = update_rows('product', " product_id = $update_product_id ", $source);
    #log_printf("source = ".Dumper($source));
    #log_printf("shadow = ".Dumper($shadow));
  if ($res) {
    delete_product_rest($update_product_id,$shadow);
    return $update_product_id;
  }
}

insert_rows('product', $source);
return sql_last_insert_id();
}

sub copy_product_rest { ## copying product's info from related tables
##
## $shadow (if $shadow->{'*'} - this table's datas couldn't be copy):
##    description, feature, realted, bundled, gallery, multimedia_object, ean_codes, name, feature_local
##
	my ($source_product_id, $product_id, $shadow) = @_;
	
	unless ($shadow->{'description'}) {
    _copy_related('product_description', 'langid,short_desc,long_desc,warranty_info,specs_url,support_url,official_url,pdf_url,manual_pdf_url', $source_product_id, $product_id);
	}
	unless ($shadow->{'feature'}) {
    _copy_related('product_feature', 'category_feature_id,value', $source_product_id, $product_id);
	}
	unless ($shadow->{'related'}) {
    _copy_related('product_related', 'rel_product_id', $source_product_id, $product_id);
	}
	unless ($shadow->{'bundled'}) {
    _copy_related('product_bundled', 'bndl_product_id', $source_product_id, $product_id);
	}
	unless ($shadow->{'gallery'}) {
    _copy_related('product_gallery', 'link,thumb_link,height,width,size,quality', $source_product_id, $product_id);
	}
	unless ($shadow->{'multimedia_object'}) {
    _copy_related('product_multimedia_object', 'link,short_descr,langid,size,content_type,keep_as_url,type,data_source_id', $source_product_id, $product_id);
	}
	unless ($shadow->{'ean_codes'}) {
    _copy_related('product_ean_codes', 'ean_code', $source_product_id, $product_id);
	}
# < dv copy
	unless ($shadow->{'name'}) {
    _copy_related('product_name','name,langid',$source_product_id,$product_id);
	}
	unless ($shadow->{'feature_local'}) {
    _copy_related('product_feature_local','category_feature_id,value,langid',$source_product_id,$product_id);
	}
}

sub _copy_related {
## wrapper for copying product's info from specified related table
## uses internally in 'copy_product_rest'
	my ($table, $fields_to_copy, $source_product_id, $product_id) = @_;
	
	my $rows = do_query("select $product_id, $fields_to_copy from $table where product_id = $source_product_id"); 
	for my $row(@$rows){
		for(my $entry = 0; $entry <= $#$row; $entry++){
			$row->[$entry] = str_sqlize($row->[$entry]);
		}
		do_statement("insert into $table (product_id, $fields_to_copy) values (". join(',', @$row) .")"); 
	}
}

sub delete_product {
	my ($product_id) = @_;
	delete_product_rest($product_id);
	delete_rows('product', "product_id=" . $product_id);
}

sub delete_product_rest {
    my ($product_id,$shadow) = @_;
    unless ($shadow->{'description'}) {
		delete_rows('product_description', "product_id = " . $product_id);
    }
    unless ($shadow->{'feature'}) {
		delete_rows('product_feature', "product_id = " . $product_id);
    }
    unless ($shadow->{'related'}) {
		delete_rows('product_related', "product_id = " . $product_id);
    }
    unless ($shadow->{'bundled'}) {
		delete_rows('product_bundled', "product_id = " . $product_id);
    }
    unless ($shadow->{'price'}) {
		delete_rows('product_price', "product_id = " . $product_id);
    }
    unless ($shadow->{'gallery'}) {
		delete_rows('product_gallery', "product_id = " . $product_id);
    }
    unless ($shadow->{'multimedia_object'}) {
		delete_rows('product_multimedia_object', "product_id = " . $product_id);
    }
    unless ($shadow->{'ean_codes'}) {
		delete_rows('product_ean_codes', "product_id = " . $product_id);
    }
    unless ($shadow->{'name'}) {
		delete_rows('product_name', "product_id = " . $product_id);
    }
    unless ($shadow->{'feature_local'}) {
		delete_rows('product_feature_local', "product_id = " . $product_id);
    }
}

sub download_file
{
	my ($url, $fn, $debug, $count) = @_;

	my ($ua, $req, $res);
	
	$count = 1 unless ($count);

	if(!$debug){ 
		$ua = new LWP::UserAgent;
		$ua->timeout($atomcfg{'http_request_timeout'});
		for (my $i=1;$i<=$count;$i++) {
			$req = new HTTP::Request GET => $url;
#		$req->authorization_basic($un,$pw); 
			$res = $ua->request($req, $fn);
			last if ($res->is_success);
		}
		if(!$res->is_success){
			log_printf("Can't download $url!\n Reason: ".$res->status_line);
			return undef;
		}
		return 1;
	}
	else {
		return undef;
	}
}

sub build_active_symbol_hash
{
my ($prefs, $active_symbol, $catid) = @_;
		for my $symbol(keys %{$prefs->{'feature_map'}}){
		 if($prefs->{'feature_map'}->{$symbol}->{$catid}){
		  push @{$active_symbol->{$symbol}}, $catid;
		 }
		 if($prefs->{'feature_map'}->{$symbol}->{'1'}){
		  push @{$active_symbol->{$symbol}}, '1';
		 }
		}

}

sub add_symbols_to_mapping {
	my ($prefs, $missing, $list) = @_;

	my ($item, $symbol, $ref, $empty, $sql_symbol, $rows, $dist_clause, $ds_item);
	
	for $item (@$list) {
# log_printf($item);
		for $symbol (keys %{$missing->{$item}}) {
# log_printf($symbol.' '.$missing->{$item}->{$symbol}.' '.Dumper($prefs->{$item.'_map'}->{$symbol}));
			$ref = $prefs->{$item.'_map'}->{$symbol};
			$empty = 0;
			
			if (!defined $ref) {
				$empty = 1;
			}
			
			if (ref($ref) eq 'ARRAY') {
				if (!(@$ref)) {
					$empty = 1;
				}
			}

			if (ref($ref) eq 'HASH') {
				if (!(%$ref)) {
					$empty = 1;
				}
			}
			
      # some major changes - dima
			$ds_item = undef;
      $ds_item = ($item ne 'feature') ? do_query("select data_source_".$item."_map_id, distributor_id from data_source_".$item."_map where symbol=".str_sqlize($symbol)." and data_source_id=".$prefs->{'data_source_id'}." limit 1")->[0] : undef;
      my $distributor_id;
	  if(ref($missing->{$item}->{$symbol}) eq 'HASH'){
		$distributor_id=$missing->{$item}->{$symbol}->{'distributor_id'};	  	
	  }else{
	  	$distributor_id=$missing->{$item}->{$symbol};
	  }
      if (($ds_item->[0]) && ($distributor_id ne $ds_item->[1])) {
				do_statement("update data_source_".$item."_map set distributor_id=0 where data_source_".$item."_map_id=".$ds_item->[0]);
      }
			elsif (($empty) && (defined $missing->{$item}->{$symbol})) {
				$sql_symbol = str_sqlize($symbol);
				$dist_clause = ($item ne 'feature') ? " and distributor_id=".$distributor_id : "";

				my $existed = do_query("select count(*) from data_source_".$item."_map where data_source_id=".$prefs->{'data_source_id'}." and symbol = ".$sql_symbol.$dist_clause)->[0][0];
				my $like_existed = do_query("select count(*) from data_source_".$item."_map where data_source_id=".$prefs->{'data_source_id'}." and ".$sql_symbol." like ".to_like_operand('symbol')." ".$dist_clause)->[0][0];

				if (($existed == 0) && ($like_existed == 0)) {
					$rows = {
						'data_source_id' => $prefs->{'data_source_id'},
						'symbol'         => $sql_symbol,
						'distributor_id' => (($distributor_id)?$distributor_id:0)
					};
					
					insert_rows('data_source_'.$item.'_map', $rows);

					log_printf(">> new ".$item." symbol to mapping added: `".$symbol."`");
				}
				else {
					log_printf(">> mapping is already existed: `".$symbol."`, exact|like = ".$existed."|".$like_existed);
				}
			}
		} 
		my $code_extractor=$icecat_import::feature_code_extractor;
		$code_extractor=~s/symbol/fm.symbol/gs;
		if(!$code_extractor){
			$code_extractor='fm.symbol';
		}
		# insert and update example values gathered in tmp_feature_map_info
		if($item eq 'feature' and do_query('SELECT 1 from tmp_feature_map_info limit 1')->[0][0] ){
			do_statement('DROP temporary TABLE IF EXISTS tmp_feature_map_key');
			do_statement("CREATE temporary TABLE tmp_feature_map_key AS 
						  (SELECT fm.data_source_feature_map_id,$code_extractor as code 
						   FROM  data_source_feature_map fm 
						   WHERE data_source_id=$prefs->{'data_source_id'})");
			do_statement("ALTER IGNORE TABLE tmp_feature_map_key ADD UNIQUE KEY(code(255))");
			do_statement("ALTER IGNORE TABLE tmp_feature_map_key ADD UNIQUE KEY(data_source_feature_map_id)");
									  
			do_statement("UPDATE data_source_feature_map_info dsi
						   JOIN data_source_feature_map fm USING(data_source_feature_map_id)
						   JOIN tmp_feature_map_key fmk ON fmk.data_source_feature_map_id=fm.data_source_feature_map_id
						   JOIN tmp_feature_map_info tfi ON fmk.code=tfi.symbol AND tfi.langid=dsi.langid AND tfi.data_source_id=fm.data_source_id    
						   SET dsi.example_values=tfi.example_values");
			do_statement("INSERT IGNORE data_source_feature_map_info (data_source_feature_map_id,langid,example_values) 
						   SELECT fm.data_source_feature_map_id,tf.langid,tf.example_values FROM tmp_feature_map_info tf
						   JOIN  tmp_feature_map_key fmk ON fmk.code=tf.symbol 
						   JOIN  data_source_feature_map fm ON  fmk.data_source_feature_map_id=fm.data_source_feature_map_id AND tf.data_source_id=fm.data_source_id
						   WHERE tf.example_values!=''");
			# fill the count of used values			   
			do_statement("UPDATE data_source_feature_map fm
						   JOIN tmp_feature_map_key fmk ON fmk.data_source_feature_map_id=fm.data_source_feature_map_id
						   LEFT JOIN tmp_feature_map_info tc ON tc.symbol=fmk.code
						   SET fm.used_in=IF(tc.used_in IS NULL and fm.used_in=0,fm.used_in-1,tc.used_in)
						   WHERE fm.data_source_id=$prefs->{'data_source_id'}");									   
		}
	}
} # sub add_symbols_to_mapping

sub get_feature_map_rows
{
my ($prefs, $feature_name, $catid, $missing) = @_;
my $rows;
 if($prefs->{'feature_map'}->{$feature_name}->{$catid}){
  $rows = $prefs->{'feature_map'}->{$feature_name}->{$catid};
 } elsif($prefs->{'feature_map'}->{$feature_name}->{'1'}) {
  $rows = $prefs->{'feature_map'}->{$feature_name}->{'1'};
 } else {
  $missing->{'feature'}->{$feature_name} = 1;
 }
return $rows;
}

sub format_feature_value {
	my ($row, $value, $feature_name) = @_;
	
	if ($row->{'coef'} =~m/^\d+[\.]{0,1}\d*\Z/ &&
			$value =~m/^\d+[\.]{0,1}\d*\Z/) {
		$value *= $row->{'coef'};
		if ($row->{'format'} && $row->{'format'} =~m/^\d+[\.]{0,1}\d*\Z/) {
			my $nb = int($row->{'format'});
			$value = sprintf("%.".$nb."f", $value);
		}
	}
	
	if ($row->{'override_value_to'} eq 'collect_me') {
		$value = $feature_name.': '.$value;
	}
	return $value;
}

sub put_missing_category_feature
{
my ($prefs, $missing, $catid, $feature_id) = @_ ;

				 $missing->{'category_feature'}->{
				 
				  $prefs->{'category'}->{$catid}->{'name'}.'('.$catid.') - '.
				  $prefs->{'feature'}->{$feature_id}->{'name'}.
					'('.$prefs->{'feature'}->{$feature_id}->{'measure_name'}.')'
					
					} = 1;

}

sub write_out_flat_file {
	my ($filename, $header, $data, $options) = @_;
	
	open(FILE, ">".$filename) or log_printf("write_out_flat_file: fatal - can't open fiel $filename: $!");
	if ($options->{'encoding'}) {
		binmode(FILE,":".$options->{'encoding'});
	}
	
	if (!$options->{'delimiter'}) {
		$options->{'delimiter'} = "\t";
	}
	if (!$options->{'new_line'}) {
		$options->{'new_line'} = "\n";
	}
	
	my $file = '';
	
	if ($options->{'write_header'}) {
		my $line = '';
		for my $item (@$header) {
			if ($line) {
				$line .= $options->{'delimiter'};
			}
			$line .= $item;
		}
		$line .= $options->{'new_line'};
		$file .= $line;
	}
	
	my $lines = [];
	
	for my $row(@$data) {
		my $line;
		for my $item (@$header) {
			if (defined $line) {
				$line .= $options->{'delimiter'};
			}
			my $value = $row->{$item};
			
			$value =~s/\n/\\n/gs;
			$value =~s/\r/\\r/gs;
			$value =~s/\t/\\t/gs;
			
			
			if (defined $value) {
				$line .= $value;
			}
			else {
				$line .= '';
			}
		}
		$line .= $options->{'new_line'};
		
		push @$lines, $line;
	}
	
	if ($options->{'make_lines_unique'}) {
		my %lines = map { $_ => 1 } @$lines;
		@$lines = sort keys %lines;
	}
	
	$file .= join('', @$lines);
	if ($options->{'encoding'} eq 'bytes') {
		print FILE utf82latin($file);
	}
	else {
		print FILE $file;
	}
	
	close (FILE);
}

#use vars qw ( $glob_mapping_rules );

sub get_mapped_prod_id {
	my ($product) = @_;
	
	do_statement("drop temporary table if exists itmp_prod_id_validate");
	do_statement("create temporary table itmp_prod_id_validate (
product_id  int(13)     not null default 0,
prod_id     varchar(60) not null default '',
supplier_id int(13)     not null default 0,
key (product_id),
key (prod_id, supplier_id),
key (supplier_id))");

#	do_statement("alter table itmp_prod_id_validate disable keys");
	do_statement("insert into itmp_prod_id_validate(product_id,prod_id,supplier_id)
values(" . ( $product->{'product_id'} || 0 ) . ",".str_sqlize($product->{'prod_id'}).",".$product->{'supplier_id'}.")");
#	do_statement("alter table itmp_prod_id_validate enable keys");

	prod_id_mapping({'table' => 'itmp_prod_id_validate'});

	my $mapped = do_query("select map_prod_id, supplier_id, map_supplier_id from itmp_prod_id_validate where map_prod_id!=prod_id or map_supplier_id!=supplier_id limit 1")->[0];

	do_statement("drop temporary table if exists itmp_prod_id_validate");

	if ($mapped->[0]) {
		return [$mapped->[0], $mapped->[1] != $mapped->[2] ? do_query("select name from supplier where supplier_id=".$mapped->[2])->[0][0] : undef ];
	}
	else {
		return undef;
	}
}

sub get_preview_product_mapping_rule
{
my ($rule) = @_;
my $where = '1 ';

my $mapped = {};

 if($rule->{'supplier_id'}){
  $where .= ' and product.supplier_id = '.str_sqlize($rule->{'supplier_id'});
 }

my $products = do_query("select product_id, product.supplier_id, prod_id, product.user_id, users.user_group, users.login, supplier.name
from product
inner join users using (user_id)
inner join supplier using (supplier_id)
where ".$where);

 for my $row(@$products){
	 push @{$mapped->{$row->[1]}->{$row->[2]}}, 
	   {
		  "product_id" 	=> $row->[0],
			"old_prod_id" => $row->[2],
			"m_prod_id" 	=> $row->[2],
			"user_id"			=> $row->[3],
			"user_group"	=> $row->[4],
			"login"				=> $row->[5],
			"supplier_name" => $row->[6]
     } 

 }

 for my $row(@$products){
  my $m_prod_id = match_product_regexp($rule->{'patterns'}, $row->[2]);
	if($m_prod_id){
	 push @{$mapped->{$row->[1]}->{$m_prod_id}}, 
	   {
		  "product_id" 	=> $row->[0],
			"old_prod_id" => $row->[2],
			"user_id"			=> $row->[3],
			"user_group"	=> $row->[4],
			'mapped'			=> 1,
			'm_prod_id' 	=> $m_prod_id,
			"login"				=> $row->[5],
			"supplier_name" => $row->[6]

		 } 
	}
 }
 
 for my $supplier_id(keys %$mapped){
  for my $prod_id(keys %{$mapped->{$supplier_id}}){
	
#	log_printf("new $prod_id has $#{$mapped->{$supplier_id}->{$prod_id}} items:\n".Dumper($mapped->{$supplier_id}->{$prod_id}));
	
   if($#{$mapped->{$supplier_id}->{$prod_id}} == 0 &&
			!$mapped->{$supplier_id}->{$prod_id}->[0]->{'mapped'}){
			 delete $mapped->{$supplier_id}->{$prod_id};
			}	
	 if($#{$mapped->{$supplier_id}->{$prod_id}} >= 0){
	   solve_product_ambugiuty($mapped->{$supplier_id}->{$prod_id});
	 }
	}
 }

return $mapped;
}

sub solve_product_ambugiuty
{
 my ($prods) = @_;
 my ($supplier, $editor, $noeditor, $exeditor);
 
for my $row(@$prods)
{
	if($row->{'user_group'} eq 'supplier')
	{
		if($supplier)
		{
			if ($supplier->{'map_supplier_name'} ne $supplier->{'supplier_name'})
			{
				$supplier = $row if ($row->{'map_supplier_name'} eq $row->{'supplier_name'});
			}
		} 
		else 
		{ 
			$supplier = $row;
		}
	}
	elsif( $row->{'user_group'} eq 'editor' || $row->{'user_group'} eq 'supereditor'|| $row->{'user_group'} eq 'category_manager'|| $row->{'user_group'} eq 'superuser')
	{
		if($editor)
		{
			if ($editor->{'map_supplier_name'} ne $editor->{'supplier_name'})
			{
				$editor = $row if ($row->{'map_supplier_name'} eq $row->{'supplier_name'});
			}
		} 
		else 
		{
			$editor = $row;
		}
	}
	elsif($row->{'user_group'} eq 'exeditor')
	{
			if ($exeditor)
			{
				if ($exeditor->{'map_supplier_name'} ne $exeditor->{'supplier_name'})
				{
					$exeditor = $row if ($row->{'map_supplier_name'} eq $row->{'supplier_name'});
				}
			}
			else
			{
				$exeditor = $row;
			}
	}	
	else 
	{
		if ($noeditor)
		{
			if ($noeditor->{'map_supplier_name'} ne $noeditor->{'supplier_name'})
			{
					$noeditor = $row if ($row->{'map_supplier_name'} eq $row->{'supplier_name'});
			}
		}
		else
		{
			$noeditor = $row;
		}
	}
 }

 # priorities: editor > supplier > exeditor > noeditor
 
 if($editor){
  $editor->{'best'} = 1;
 } elsif($supplier){
  $supplier->{'best'} = 1;
 } elsif($exeditor){
  $exeditor->{'best'} = 1;
 } else {
  $noeditor->{'best'} = 1;
 }
 
}

sub match_product_regexp {
	my ($patterns, $value) = @_;
	
	if (!$patterns) {
		return ;
	}
	
	my $orig_value = $value;
	
	$patterns =~s/\r//g;
	my @patterns = sort { length($b) <=> length($a) } split("\n", $patterns);
	my $match_flag = 0;

	my $i = 0;
	
	while ($i < 3) {
		
		$i++;
		
		for my $pattern (@patterns) {
			if (! ($pattern =~ /.\=./) || ($pattern =~ /^[\*]+\=/) ) {
				next;
			}
			my $tmp = $value;
			$value = match_single_product_regexp($pattern, $value);
			if ($value ne $tmp) {
				$match_flag = 1;
				last;
			}
		}
	}
	
	if ($match_flag) {
		return $value;
	}
	else {
		return ;
	}
}

sub match_cat_symbol_regexp
{
my ($pattern, $value) = @_;

my $m_pattern = $pattern;
$m_pattern =~s/\*//g;

$pattern .='='.$m_pattern;

$value = match_single_product_regexp($pattern, $value);

return $value;
}

sub match_single_product_regexp {
	my ($pattern, $value) = @_;

#log_printf($pattern." ".$value);
	my ($lp, $rp);# = split(/[^\\]\=/, $pattern);
	
	$pattern =~ s/\%\%/\x02/g;
	$pattern =~ s/\%\*/\x01/g;
	$pattern =~ s/\%\=/\x03/g;
	
	$pattern =~ /^(.*?[^\\]{0,1})\=(.*)$/;

	$lp = $1; $rp = $2;
#log_printf($lp.' = '.$rp);
# ending \s off
	$rp =~ s/\s+$//g;
	$lp =~ s/\\=/\=/g;
	
	return $value if ($rp eq '');

	my ($lr, $rr);
	my $num = 1;
	
#log_printf($lp.' = '.$rp);
	
	while ($lp =~ /\*/) {
		$lp =~ s/([^\*]*)\*//;
		my $left = '';
		
		if (defined $1) {
			$left .= quotemeta($1);
		}
		$lr .= $left.'(.*)';
		
#log_printf("before: $rp");
		
		if ($rp =~ s/([^\*]*)\*//) {
			
			my $left1 = '';
			
			if ($1) {
#log_printf('hi dude: '.$1);
#				if ($rr) { $left1 = '.'}
				$left1 .= '"'.quotemeta($1).'".';
			}
			$rr .= $left1.'$'.$num.'.';
			$num++;
		}
#log_printf($lr."\n".$rr."\n");
	}
	
#log_printf($lr."\n".$rr."\n");
	
	my $left = '';
	if (defined $lp) {
		$left .= quotemeta($lp);
	}
	
	$lr .= $left; 
	
	my $left1 = '';
	if ($rp) {
#		if ($rr) { $left1 = '.'}
		$left1 .= '"'.quotemeta($rp).'"';
	}
	else {
		chop($rr);
	}
	$rr .= $left1;

	$rr =~ s/\x01/\*/g;
	$lr =~ s/\x01/\*/g;
	
	$rr =~ s/\x02/\%/g;
	$lr =~ s/\x02/\%/g;
	
	$rr =~ s/\x03/\=/g;
	$lr =~ s/\x03/\=/g;

#log_printf("\n'".$lr."'\n'".$rr."'\n");
	
	$value =~ s/^$lr$/eval($rr)/ei;
	
#log_printf($value);
	
	return $value;
}

sub get_product_date {
	my ($product_id) = @_;
	my ($date, $data, $data_rel);
	
	my $tables = [ 'product', 'product_description', 'product_feature', 'product_related', 'product_gallery', 'product_multimedia_object' ];
	
	for my $table (@$tables) {
		if ($table eq 'product_related') {
			$data_rel = undef;
			$data_rel = do_query("select max(unix_timestamp(updated)) from product_related where rel_product_id = ".str_sqlize($product_id))->[0][0];
		}
		$data = undef;
		$data = do_query("select max(unix_timestamp(updated)) from ".$table." where product_id = ".str_sqlize($product_id))->[0][0];
		$data = $data_rel<$data ? $data : $data_rel;
		$date = $date<$data ? $data : $date;
	}
	
	return $date;
}

use vars qw ($product_date_cached_data);

sub get_product_date_cached
{
my ($product_id) = @_;
my $date;

if(!$product_date_cached_data){
	my $tables = ['product', 'product_description', 'product_feature', 'product_related' ];

 		for my $table(@$tables){
  	 my $data = do_query("select product_id, max(unix_timestamp(updated)) from $table group by product_id ");
  	 for my $row(@$data){
				if( $product_date_cached_data->{$row->[0]} < $row->[1]){
    				$product_date_cached_data->{$row->[0]}	= $row->[1];
		 		}
		}
		undef $data;
	 }
}

return $product_date_cached_data->{$product_id};
}

sub clear_product_date_cache
{

undef %$product_date_cached_data;
$product_date_cached_data = {};
undef $product_date_cached_data;

}

sub get_rating_params{
#select A,B, Period
    my $params = do_query("select configuration from data_source where code='importance_index'")->[0][0];
    my %hash;
    my $formula_arr=get_rating_prop('formula',$params);
    my $period_arr=get_rating_prop('period',$params);
    
    $hash{'formula'}=$formula_arr->[0] if !$formula_arr->[1]; # if we have double params return error
    $hash{'Period'}=$period_arr->[0] if !$period_arr->[1];
    $hash{'formula'}=~s/formula[\s]*://i;
    $hash{'Period'}=~s/period[\s]*://i;
    $hash{'formula'}=trim($hash{'formula'});
    $hash{'Period'}=trim($hash{'Period'});
    return \%hash;
}
		    
sub get_product_date_cached_for_vendor_mailing
{
my ($product_id) = @_;
my $max_date = 0;
my $bits = '';

my $tables = ['product', 'product_description', 'product_feature', 'product_related'];

 for my $table(@$tables){
	my $data;
	if($table eq 'product_feature'){
 	 $data = do_query("select max(unix_timestamp(updated)) from $table  where product_id = $product_id and value != ''");
	}else{
	 $data = do_query("select max(unix_timestamp(updated)) from $table where product_id = $product_id");
	}
	if(!$data->[0][0]){ next;}
	if(($max_date == 0) || ($max_date < $data->[0][0])){
    $max_date = $data->[0][0];
  	$bits .= '1';
  }else{
 		$bits .= '0';
 	}
 	undef $data;
 }
 if($bits eq '1000'){ $max_date = 0;}
 return $max_date;
}

sub get_products_market
{
 my ($market) = @_;
 my $result_hash;
 my $product_id = $market->{'product_id'};
 my $country_id = $market->{'country_id'};

 my $market_data = do_query("select existed, active, stock from country_product where product_id = ".$product_id." and country_id = ".$country_id);
 my $state = $market_data->[0][0];
 my $active = $market_data->[0][1];
 my $stock = $market_data->[0][2];
 $result_hash->{'stock'} = $stock;
 
 #product present in the market
 if($state&&$active){ $result_hash->{'state'} = 1;}
 #product not present in the market
 if(!$state&&!$active){ $result_hash->{'state'} = 0;}
 #product not present but presented in the market
 if($state&& !$active){ $result_hash->{'state'} = -1;}

 #$result_hash->{'state'} - products market state
 #$result_hash->{'stock'} - products market stock
 return $result_hash;
}

sub get_products4repository {
	my ($cond, $progress) = @_;

	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';

	print " Start, " if $progress;
 
  # fullfill product table
	do_statement("drop temporary table if exists ".$table_name);
	do_statement("create temporary table ".$table_name." (
`product_id`         int(13)      NOT NULL default 0,
`supplier_id`        int(13)      NOT NULL default 0,
`prod_id`            varchar(60)  NOT NULL default '',
`catid`              int(13)      NOT NULL default 0,
`user_id`            int(13)      NOT NULL default 1,
`quality`            int(13)      NOT NULL default 0,
`updated`            int(13)      NOT NULL default 0,
`date_added`         int(13)      NOT NULL default 0,
`mapped`             char(1)      NOT NULL default '',
`public`             char(1)      NOT NULL default 'Y',
`orig_set`           text,
`ean_upc_set`        text,
`distri_set`         text,
`on_market`          tinyint(1)   NOT NULL default 0,
`country_market_set` text,
`only_vendor`        tinyint(1)   NOT NULL default 0,
`name` 		           varchar(254) NOT NULL default '',
`agr_prod_count` 	   int(11)      NOT NULL default 0,
`high_pic`           varchar(255) NOT NULL default '',
`high_pic_size`      int(13)      NOT NULL default 0,
`high_pic_width`     int(13)      NOT NULL default 0,
`high_pic_height`    int(13)      NOT NULL default 0,
`content_measure`    varchar(60)  NOT NULL default '',

PRIMARY KEY (`product_id`),
key (product_id, prod_id),
key (updated))");

	my $supplier_id_cond = undef;
	my $supplier_id = undef;
	my $only_vendor_cond = undef;
	my $quality_cond = undef;
	my $on_market = undef;

	if ($cond->{'supplier_name'}) {
		$supplier_id = do_query("select supplier_id from supplier where name=".str_sqlize($cond->{'supplier_name'}))->[0][0];
		if ($supplier_id) {
			$supplier_id_cond = " and p.supplier_id = ".$supplier_id;
		}
	}

	if (($cond->{'supplier_id'}) && ($cond->{'supplier_id'} =~ /^\d+(,\d+)*$/)) {
		$supplier_id_cond .= " and p.supplier_id in (".$cond->{'supplier_id'}.")";
	}

	my $product_id_cond = '';

#	log_printf("cond = ".Dumper($cond));

	if (defined $cond->{'product_id'}) {
#		log_printf("ref ".ref($cond->{'product_id'}));
		if (ref($cond->{'product_id'}) eq '') {
			if ($cond->{'product_id'} =~ /\d+/) {
				$product_id_cond = ' and p.product_id = '.$cond->{'product_id'};
			}
			else {
				$product_id_cond = ' and 0';
			}
		}
		elsif (ref($cond->{'product_id'}) eq 'ARRAY') {
			my $product_ids = $cond->{'product_id'};
			if ($#$product_ids == 0) {
				$product_id_cond = " and p.product_id = ".$product_ids->[0];
			}
			elsif ($#$product_ids > 0) {
				$product_id_cond = " and p.product_id in (";
				$product_id_cond .= join ',', @$product_ids;
				$product_id_cond .= ")";
			}
			else {
				$product_id_cond = ' and 0';				
			}
		}
	}

	# by public ('','Yes','Limited'): remove Limited
	# AND
	# by publish ('','Yes','No','Approved'): remove No
	if (defined $cond->{'public'}) {
		$only_vendor_cond = " and p.public != 'L' and p.publish != 'N' ";
	}

	# by quality (a set of qualities)
	if ((defined $cond->{'quality'}) && ($cond->{'quality'} =~ /^\d+(,\d+)*$/)) {
		$quality_cond = " and cmim.quality_index in (".$cond->{'quality'}.")";
	}

	print "products collect, " if $progress;

	# first, we must create a itmp_users table
#	do_statement("drop temporary table if exists itmp_users");
#	do_statement("create temporary table itmp_users like users");
#	do_statement("alter table itmp_users DISABLE KEYS");
#	do_statement("insert into itmp_users select * from users");
#	do_statement("alter table itmp_users ENABLE KEYS");

	# now, we collect all necessary info from product_memory table
	do_statement("alter table ".$table_name." DISABLE KEYS");

	my @arr = get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');

	if ($product_id_cond) {
		@arr = ('1');
	}

	my ($stmt_i, $stmt_s);
	for my $b_cond (@arr) {
		$stmt_i = "
		    insert ignore into " . $table_name . " (
    		    product_id,      supplier_id,    prod_id,        catid,         user_id,
            quality,         updated,        date_added,     mapped,        only_vendor,
            name,            agr_prod_count, high_pic,       high_pic_size, high_pic_width,
            high_pic_height, public,         content_measure
    		)";

		$stmt_s = "select 
    		p.product_id,         p.supplier_id,           p.prod_id,                    p.catid,                          p.user_id,            /* 0  -  4 */
        cmim.quality_index,   p.pmt_modification_time, unix_timestamp(p.date_added), if(dp.product_id IS NULL,'','Y'), if(p.public='L',1,0), /* 5  -  9 */
        p.name,               apc.count,               p.high_pic,                   p.high_pic_size,                  p.high_pic_width,     /* 10 - 14 */
        p.high_pic_height,    p.public,                cmim.content_measure                                                                  /* 15 - 17 */

			 from product_memory p
			 inner join users u using (user_id)
			 inner join user_group_measure_map ugmm on u.user_group = ugmm.user_group
			 inner join content_measure_index_map cmim on ugmm.measure = cmim.content_measure
			 left join  distributor_product dp on p.product_id = dp.product_id
			 LEFT JOIN aggregated_product_count apc ON p.product_id = apc.product_id " .
			 ( $cond->{'use_filter'} ? 'INNER JOIN '.$cond->{'use_filter'}.' fltr ON fltr.product_id = p.product_id ' : '') .

			 " where 1" . $supplier_id_cond . $product_id_cond.$only_vendor_cond . $quality_cond . " AND " . $b_cond;
		
		log_printf(do_query_dump("explain ".$stmt_s));
		
		do_statement($stmt_i." ".$stmt_s);
	}
	
	log_printf('All inserts done...');
	
#	do_statement("drop temporary table if exists itmp_users");

	print "refresh indexes, " if $progress;

	do_statement("alter table ".$table_name." ENABLE KEYS");
	
	## filter product datas
	# by updated
	if ($cond->{'updated'}) {
		print "only updated, " if $progress;
		do_statement("delete from ".$table_name." where updated != 0 and (supplier_id = 0 or prod_id = '' or catid = 0)");
	}
 
	# fullfill distributor_product
	do_statement("drop temporary table if exists itmp_distributor_product");
	do_statement("create temporary table itmp_distributor_product (
product_id       int(13) primary key,
original_prod_id text    NOT NULL default '')");

	print "distri info collect, " if $progress;

	do_statement("insert into itmp_distributor_product(product_id,original_prod_id)
select p.product_id, GROUP_CONCAT(dp.original_prod_id SEPARATOR '\t')
from ".$table_name." p
inner join distributor_product dp using (product_id)
where p.prod_id!=dp.original_prod_id".$product_id_cond."
group by p.product_id");
	print "distri info update, " if $progress;

	do_statement("update ".$table_name." p inner join itmp_distributor_product dp using (product_id) set p.orig_set = dp.original_prod_id");
	do_statement("drop temporary table if exists itmp_distributor_product");
	
	# fullfill distributor_product full list
	if ($cond->{'do_add_distri'}) {
		do_statement("drop temporary table if exists itmp_distributors_product");
		do_statement("create temporary table itmp_distributors_product (
product_id int(13) primary key,
distri_set text    NOT NULL default '')");
		
		print "distri info collect, " if $progress;
		
		do_statement("INSERT INTO itmp_distributors_product(product_id, distri_set)
				  SELECT p.product_id, GROUP_CONCAT(CONCAT(d.distributor_id, ';', REPLACE(d.name,';',''), ';', c.code, ';', dp.dist_prod_id) SEPARATOR '\t')
				  FROM ".$table_name." p
					INNER JOIN distributor_product dp USING (product_id)
					INNER JOIN distributor d USING (distributor_id)
					INNER JOIN country c USING (country_id)
					WHERE 1 ".$product_id_cond." and d.direct = 1 /* we use only direct distributors */
					GROUP BY p.product_id");
		
		do_statement("update ".$table_name." p inner join itmp_distributors_product dp using (product_id) set p.distri_set=dp.distri_set");
		do_statement("drop temporary table if exists itmp_distributor_product");
	}

	# fullfill product_ean_codes
	do_statement("drop temporary table if exists itmp_product_ean_codes");
	do_statement("create temporary table itmp_product_ean_codes (
product_id int(13) primary key,
ean_codes  text    NOT NULL default '')");

	print "EAN collect, " if $progress;

	do_statement("insert into itmp_product_ean_codes(product_id,ean_codes)
select p.product_id, GROUP_CONCAT(pec.ean_code SEPARATOR '\t')
from ".$table_name." p
inner join product_ean_codes pec using (product_id)
where 1".$product_id_cond."
group by p.product_id");

	print "EAN update, " if $progress;
	
	do_statement("update ".$table_name." p inner join itmp_product_ean_codes pec using (product_id) set p.ean_upc_set=pec.ean_codes");
	do_statement("drop temporary table if exists itmp_product_ean_codes");

	# update on_market
	do_statement("drop temporary table if exists itmp_product_country");
	do_statement("create temporary table itmp_product_country (
`product_id`         int(13) primary key,
`country_market_set` text)");

	print "country collect, " if $progress;

	do_statement("insert into itmp_product_country(product_id,country_market_set)
select p.product_id, group_concat(c.code separator '\t')
from country_product p
inner join country c using (country_id)
where p.existed=1 and p.active=1".$product_id_cond."
group by p.product_id");

	print "country update, " if $progress;

	do_statement("update ".$table_name." p inner join itmp_product_country cp using (product_id) set p.country_market_set=cp.country_market_set, p.on_market=1");
	do_statement("drop temporary table if exists itmp_product_country");

	if ((defined $cond->{'on_market'}) && ($cond->{'on_market'} =~ /^\d+(,\d+)*$/)) {
		print "remove absent on market, " if $progress;
		$on_market = $cond->{'on_market'};
		do_statement("delete from ".$table_name." where on_market != " . $on_market);
	}

	if (!$cond->{'product_id'} && (!$cond->{'quality'} || $cond->{'quality'} =~ /0/)) { # TODO: need to import last few days only products...
		do_statement("drop temporary table if exists ".$table_name."_deleted");
		do_statement("create temporary table ".$table_name."_deleted (
			product_id  int(13)      primary key,
			del_time    timestamp    NOT NULL default CURRENT_TIMESTAMP,
			catid       int(13)      NOT NULL default '0',
			name        varchar(255) NOT NULL default '',
			supplier_id int(13)      NOT NULL default '0',
			user_id     int(13)      NOT NULL default '0',
			prod_id     varchar(235) NOT NULL default '',
			key del_time (del_time))");
		
		do_statement("alter table ".$table_name."_deleted DISABLE KEYS");

		print "add removed products " if $progress;

		do_statement("insert into ".$table_name."_deleted (product_id,del_time,catid,name,supplier_id,user_id,prod_id) 
			select p.product_id,p.del_time,p.catid,p.name,p.supplier_id,p.user_id,p.prod_id from product_deleted p 
			where 1 ".$supplier_id_cond.$product_id_cond." AND del_time > from_unixtime(current_timestamp() - (60 * 60 * 24 * 3))"); # last 3 days info is enough...
		do_statement("alter table ".$table_name."_deleted ENABLE KEYS");
	}

	return $table_name;
} # sub get_products4repository

sub get_products_for_repository_via_index_cache {
	my ($cond, $progress) = @_;

	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';

	print " Start, " if $progress;
 
  # fullfill product table
	do_statement("DROP TEMPORARY TABLE IF EXISTS ".$table_name);
	do_statement("CREATE TEMPORARY TABLE ".$table_name." (
`product_id`         int(13)      NOT NULL DEFAULT 0,
`user_id`            int(13)      NOT NULL DEFAULT 1,
`only_vendor`        tinyint(1)   NOT NULL DEFAULT 0,
`on_market`          tinyint(1)   NOT NULL DEFAULT 0,
`updated`            int(13)      NOT NULL DEFAULT 0,
`date_added`         int(13)      NOT NULL DEFAULT 0,

PRIMARY KEY (`product_id`),
KEY (user_id, product_id),
KEY (only_vendor, product_id),
KEY (updated))");

	my $supplier_id_cond = undef;
	my $supplier_id_cond_join = undef;
	my $supplier_id_cond_join4product = undef;
	my $supplier_id = undef;
	my $only_vendor_cond = undef;
	my $quality_cond = undef;
	my $on_market = undef;
	
	# supplier condition
	if ($cond->{'supplier_name'}) {
		$supplier_id = do_query("SELECT supplier_id FROM supplier WHERE name = ".str_sqlize($cond->{'supplier_name'}))->[0][0];
		if ($supplier_id) {
			$supplier_id_cond = " AND p.supplier_id = ".$supplier_id;
			$supplier_id_cond_join = " INNER JOIN product_memory p using (product_id) INNER JOIN supplier s USING (supplier_id) ";
		}
	}

	if (($cond->{'supplier_id'}) && ($cond->{'supplier_id'} =~ /^\d+(,\d+)*$/)) {
		$supplier_id_cond .= " AND p.supplier_id IN (".$cond->{'supplier_id'}.")";
		$supplier_id_cond_join = " INNER JOIN product_memory p using (product_id) INNER JOIN supplier s USING (supplier_id) ";
	}

	# sponsor
	if ($cond->{'sponsor'}) {
		$supplier_id_cond .= " AND s.is_sponsor = 'Y'";
		$supplier_id_cond_join = " INNER JOIN product_memory p using (product_id) INNER JOIN supplier s USING (supplier_id) ";
		$supplier_id_cond_join4product = " INNER JOIN supplier s USING (supplier_id) ";
	}

	# some product(-s) condition
	my $product_id_cond = '';
	if (defined $cond->{'product_id'}) {
		if (ref($cond->{'product_id'}) eq '') {
			if ($cond->{'product_id'} =~ /\d+/) {
				$product_id_cond = ' and p.product_id = '.$cond->{'product_id'};
			}
			else {
				$product_id_cond = ' AND 0';
			}
		}
		elsif (ref($cond->{'product_id'}) eq 'ARRAY') {
			my $product_ids = $cond->{'product_id'};
			if ($#$product_ids == 0) {
				$product_id_cond = " AND p.product_id = ".$product_ids->[0];
			}
			elsif ($#$product_ids > 0) {
				$product_id_cond = " AND p.product_id IN (";
				$product_id_cond .= join ',', @$product_ids;
				$product_id_cond .= ")";
			}
			else {
				$product_id_cond = ' AND 0';
			}
		}
	}

	# by public ('','Yes','Limited'): remove Limited
	# AND
	# by publish ('','Yes','No','Approved'): remove No
	if (defined $cond->{'public'}) {
		$only_vendor_cond = " AND p.public != 'L' AND p.publish != 'N' ";
	}

	# by quality (a set of qualities)
	if ((defined $cond->{'quality'}) && ($cond->{'quality'} =~ /^\d+(,\d+)*$/)) {
		$quality_cond = " AND cmim.quality_index IN (".$cond->{'quality'}.")";
	}

	print "products collect, " if $progress;

	# now, we collect all necessary info from product_memory table
	do_statement("ALTER TABLE ".$table_name." DISABLE KEYS");

	my @arr = get_primary_key_set_of_ranges('p','product_memory',100000,'product_id');
	@arr = ('1') if ($product_id_cond);

	my ($stmt_i, $stmt_s);
	for my $b_cond (@arr) {
		$stmt_i = "INSERT IGNORE INTO " . $table_name . " (product_id, only_vendor, updated, date_added, user_id)";
		$stmt_s = "SELECT p.product_id, if(p.public='L',1,0), p.pmt_modification_time, unix_timestamp(p.date_added), p.user_id
			 FROM product_memory p
			 INNER JOIN users u                        USING (user_id)
			 INNER JOIN user_group_measure_map ugmm    USING (user_group)
			 INNER JOIN content_measure_index_map cmim ON ugmm.measure = cmim.content_measure " .
			 $supplier_id_cond_join4product .
			 " WHERE 1 " . $supplier_id_cond . $product_id_cond . $only_vendor_cond . $quality_cond . " AND " . $b_cond;
		
		lp(do_query_dump("EXPLAIN ".$stmt_s));
		
		do_statement($stmt_i." ".$stmt_s);
	}
	
	# update on_market
	do_statement("DROP TEMPORARY TABLE IF EXISTS ".$table_name."_active");
	do_statement("CREATE TEMPORARY TABLE ".$table_name."_active (`product_id` int(13) PRIMARY KEY)");

	print "active collect, " if $progress;

	do_statement("INSERT INTO ".$table_name."_active(product_id)
SELECT pa.product_id
FROM product_active pa
" . $supplier_id_cond_join . "
WHERE pa.active = 1 " . $product_id_cond . " " . $supplier_id_cond);

	print "active update, " if $progress;

	do_statement("UPDATE ".$table_name." p INNER JOIN ".$table_name."_active pa USING (product_id) SET p.on_market = 1");
	do_statement("DROP TEMPORARY TABLE IF EXISTS ".$table_name."_active");

#	log_printf('All inserts done...');
	
	print "refresh indexes. " if $progress;

	do_statement("alter table ".$table_name." ENABLE KEYS");
	
	return $table_name;
} # sub get_products_for_repository_via_index_cache

sub smart_update_prodname {
  my ($product_id,$name,$langid) = @_;

	$name = str_sqlize($name);
	my $exist = do_query("select 1 from product_name where product_id=$product_id and langid=$langid")->[0][0];

	if ($exist) {
		if ($name eq "''") {
			do_statement("delete from product_name where product_id=".$product_id." and langid=".$langid);
		}
		else {
			update_rows("product_name", "product_id=$product_id and langid=$langid", {'name'=>$name});
		}
	}
	else {
		insert_rows("product_name", {'product_id'=>$product_id, 'langid'=>$langid,	'name'=>$name}) if $name ne "''";
	}
} # sub smart_update_prodname

sub smart_update_feature_local {
  my ($product_id,$values,$langid,$if_void) = @_;
  my $pfl = do_query("select product_feature_local_id, category_feature_id, value
    from product_feature_local where product_id = $product_id and langid=$langid");
  my %plf_id = map { $_->[1] => $_->[0] } @$pfl;
	my %plf_value;
	if ($if_void) {
		%plf_value = map { $_->[0] => $_->[2] } @$pfl;
	}

  for my $category_feature_id(keys %$values){
		my $value;
#		$value = suppress_feature_value({'value' => $values->{$category_feature_id}, 'category_feature_id' => $category_feature_id});
		$value = $values->{$category_feature_id};
    $value =~ s/^\s+//;
    my $id = $plf_id{$category_feature_id};
    if(($value eq '') && $id){
        
            # no delete statement for deleted feature
			# delete_rows('product_feature_local',"product_feature_local_id=$id");
			# update deleted local feature to '' value
			update_rows('product_feature_local',"product_feature_local_id=$id", { 'value' => "''" } );
			
			update_rows("product_feature", "product_id=$product_id and category_feature_id=$category_feature_id", {'updated'=>'NOW()'}) if ($langid != 1);
		}
    if($value ne ''){
			unless (($if_void)&&($plf_value{$id})) {
				smart_update('product_feature_local', 'product_feature_local_id', {
					'product_feature_local_id' => $id,
					'product_id' => $product_id,
					'category_feature_id' => $category_feature_id,
					'langid' => $langid,
					'value' => str_sqlize($value)
					});
				update_rows("product_feature", "product_id=$product_id and category_feature_id=$category_feature_id", {'updated'=>'NOW()'}) if ($langid != 1);
			}
    }
  }
}

sub product_mapping_header_footer {
	open TMP, ">/tmp/".$$."_product_mapping_header";
	binmode TMP, ":utf8";
  print TMP xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-product_mapping.dtd\">\n".source_message()."\n"."<ICECAT-interface " . xsd_header("ICECAT-product_mapping") . ">\n\t<ProductMappings Generated=\"".format_date(time)."\">";
	close TMP;

	open TMP, ">/tmp/".$$."_product_mapping_footer";
	binmode TMP, ":utf8";
  print TMP "\n\t</ProductMappings>\n</ICECAT-interface>";
	close TMP;
}

sub product_mapping_header_footer_end {
	my $cmd = "/bin/rm -f /tmp/".$$."_product_mapping_header";
	`$cmd`;
	$cmd = "/bin/rm -f /tmp/".$$."_product_mapping_footer";
	`$cmd`;
}

sub product_mapping_end {
	my $cmd = "/bin/rm -f /tmp/".$$."_product_mapping";
	`$cmd`;
}

sub create_prodid_mapping {
	my ($add,$cond) = @_;
  my (@m_prod_ids, $prev, $p);

	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';

	if ($add) {
		open TMP, ">>/tmp/".$$."_prodid_mapping";
	}
	else {
		open TMP, ">/tmp/".$$."_prodid_mapping";
	}
	binmode TMP, ":utf8";

	# NEED TO COMPLETE!...

	my $sth = $atomsql::dbh->prepare("select p.product_id, pm.supplier_id, pm.prod_id,

(select group_concat(dp.original_prod_id SEPARATOR '"."\x01"."')
from distributor_product dp
where dp.product_id = p.product_id and dp.active = 1 and dp.original_prod_id != pm.prod_id group by dp.product_id)

from ".$table_name." p
inner join product_memory pm using (product_id)");
  $sth->execute;
	while ($p = $sth->fetchrow_arrayref) {
		@m_prod_ids = sort {$a cmp $b} split /\x01/, $p->[3];
		for my $m_prod_id (@m_prod_ids) {
			next unless ($m_prod_id);
			next if ($p->[2] eq $m_prod_id);
			next if ($prev eq $m_prod_id);
			print TMP "\n\t\t".'<ProductMapping product_id="'.$p->[0].'" supplier_id="'.$p->[1].'" m_prod_id="'.str_xmlize($p->[2]).'" prod_id="'.str_xmlize($m_prod_id).'"/>';
			$prev = $m_prod_id;
		}
	}

	close TMP;
} # sub create_prodid_mapping

sub supplier_mapping_header_footer {
	open TMP, ">/tmp/".$$."_supplier_mapping_header";
	binmode TMP, ":utf8";
  print TMP xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-supplier_mapping.dtd\">\n".source_message()."\n"."<ICECAT-interface " . xsd_header("ICECAT-supplier_mapping") . ">\n\t<SupplierMappings Generated=\"".format_date(time)."\">";
	close TMP;

	open TMP, ">/tmp/".$$."_supplier_mapping_footer";
	binmode TMP, ":utf8";
  print TMP "\n\t</SupplierMappings>\n</ICECAT-interface>";
	close TMP;
}

sub supplier_mapping_header_footer_end {
	my $cmd = "/bin/rm -f /tmp/".$$."_supplier_mapping_header";
	`$cmd`;
	$cmd = "/bin/rm -f /tmp/".$$."_supplier_mapping_footer";
	`$cmd`;
}

sub supplier_mapping_end {
	my $cmd = "/bin/rm -f /tmp/".$$."_supplier_mapping";
	`$cmd`;
}

sub create_supplier_mapping {
	my ($add, $cond) = @_;

  my $xml = '';
	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';
	
	if ($add) {
		open TMP, ">>/tmp/".$$."_supplier_mapping";
	}
	else {
		open TMP, ">/tmp/".$$."_supplier_mapping";
	}
	binmode TMP, ":utf8";

	do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_product_supplier");
	do_statement("CREATE TEMPORARY TABLE itmp_product_supplier (
supplier_id int(13)      NOT NULL DEFAULT 0,
name        varchar(255) NOT NULL,
KEY (supplier_id))");

	do_statement("INSERT INTO itmp_product_supplier(supplier_id, name)
SELECT DISTINCT(pm.supplier_id), s.name
FROM ".$table_name." tp
INNER JOIN product_memory pm ON tp.product_id = pm.product_id
INNER JOIN supplier s        ON pm.supplier_id = s.supplier_id");
	
	if (do_query("SELECT COUNT(*) FROM itmp_product_supplier")->[0][0] > 0) {
		my $data = do_query("SELECT tps.supplier_id, dssm.symbol, tps.name, dssm.distributor_id
FROM data_source_supplier_map dssm
RIGHT JOIN itmp_product_supplier tps ON (tps.supplier_id = dssm.supplier_id AND dssm.data_source_id = 1)
WHERE tps.supplier_id != 0
ORDER BY tps.supplier_id ASC");
		do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_product_supplier");

		my $cycle_maps = do_query("SELECT ucase(ds.symbol), s_ds.supplier_id
									FROM supplier s
									JOIN data_source_supplier_map ds ON s.name = ds.symbol
									JOIN supplier s_ds ON ds.supplier_id = s_ds.supplier_id
									WHERE ds.data_source_id = 1 AND
										    ds.supplier_id != s.supplier_id AND
										    s.supplier_id != 0 AND s.name != '#Delete'");

		my %cycle_supp = map { $_->[0] => $_->[1] } @$cycle_maps;

		# generate supplier mapping
		if ($data->[0][0]) {
			my $prev = 0;
			my $dist = '';
			for my $row (@$data) {
				if ($prev != $row->[0]) {
					if ($prev) {
						print TMP "\n\t\t".
							'</SupplierMapping>';
					}
					print TMP "\n\t\t".
						'<SupplierMapping supplier_id="'.$row->[0].'" name="'.str_xmlize($row->[2]).'">';
				}
				# unless (uc($row->[1]) eq uc($row->[2]) and $cycle_supp{$row->[1]}) {

				# set the distributor_id value
				$dist = $row->[3] ? ' distributor_id="'.$row->[3].'"' : '';

				# add the Symbol
				if ($row->[1] and !(uc($row->[1]) eq uc($row->[2]) and $cycle_supp{$row->[1]})) {
					print TMP "\n\t\t\t".
							'<Symbol'.$dist.'>'.str_xmlize($row->[1]).'</Symbol>';
				}
				elsif (!$cycle_supp{uc($row->[2])}) {
					print TMP "\n\t\t\t".
							'<Symbol'.$dist.'>'.str_xmlize($row->[2]).'</Symbol>';
				}
				$prev = $row->[0];
			}
			print TMP "\n\t\t".
				'</SupplierMapping>';
		}
	}

	close TMP;
} # sub create_supplier_mapping

sub store_product_mapping {
  my ($path,$do_not_delete) = @_;

  my $xml_file = $path."/product_mapping.xml";
	my $cmd = "/bin/cat /tmp/".$$."_product_mapping_header /tmp/".$$."_prodid_mapping /tmp/".$$."_product_mapping_footer > ".$xml_file;
	`$cmd`;
	unless ($do_not_delete) {
		$cmd = "/bin/rm -f /tmp/".$$."_prodid_mapping";
		`$cmd`;
	}
}

sub store_supplier_mapping {
  my ($path,$do_not_delete) = @_;

  my $xml_file = $path."/supplier_mapping.xml";
	my $cmd = "/bin/cat /tmp/".$$."_supplier_mapping_header /tmp/".$$."_supplier_mapping /tmp/".$$."_supplier_mapping_footer > ".$xml_file;
	`$cmd`;
	unless ($do_not_delete) {
		$cmd = "/bin/rm -f /tmp/".$$."_supplier_mapping";
		`$cmd`;
	}
}

sub format_date {
	my ($time) = @_;
	my $generated = strftime("%Y%m%d%H%M%S", localtime($time));
	return $generated;
}

1;

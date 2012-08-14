package atom_format;

#$Id: atom_format.pm 3790 2011-02-04 13:36:25Z alexey $

use strict;
use atom_html;
use atom_util;
use atom_misc;
use atomlog;
use atomsql;
use atomcfg;
use data_management;
#use charnames ':full';
#use Digest::SHA1 qw(sha1_hex);
use icecat_mapping;
use serialize_data;
use Text::Diff;
use Data::Dumper;
use history;
use utf8;
use vars qw($global_related_dropdown_query $global_related_dropdown_rows $global_group_name $global_class $temp_lang_select $as_dropdown_query $as_dropdown_rows $G_pattern_no);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw(
							 &format_as_float
							 &format_as_dropdown
							 &format_as_dropdown_name
							 &format_as_smart_dropdown
							 &format_as_multiselect
							 &format_as_dropdown_ajaxed
							 &format_as_related_dropdown
							 &format_as_fuzzy_dropdown
							 &format_as_measure_dropdown
							 &format_as_date
							 &format_as_date_three_dropdowns
							 &format_as_date_yyyy_dd_mm_hh_ss
							 &format_as_unixdate_three_dropdowns
							 &format_as_text
							 &format_as_display_text
							 &format_as_remove_control_ASCII_chars
							 &format_as_url


							 &format_as_yes_no
							 &format_as_yes_no_text
							 &format_as_yes_no_select
							 &format_as_relation_exact_value_text

							 &format_as_clipboard_indicator

							 &format_as_prod_cnt
							 &format_as_user_group
							 &format_as_statistic_enabled
							 &format_as_mail_class

							 &format_as_user_rights
							 &format_as_tree
							 &format_as_tree_ajaxed
							 &format_as_tree1
							 &format_as_short_tree
							 &format_as_trace_categories
							 &format_as_trace_categories_det

							 &format_as_feature_class

							 &format_as_warranty_info

							 &format_as_category
							 &format_as_supplier

							 &format_as_feature_type

							 &format_row_as_tree
							 &format_as_description_langid

							 &format_as_sv_user_id
							 &format_as_new_catid

							 &format_as_feature_input
							 &format_as_product_feature_id
							 &format_as_product_description_id

							 &format_as_access_restriction

							 &format_as_fcnt

							 &format_as_low_pic
							 &format_as_publish
							 &format_as_public
							 &format_as_topseller

							 &format_as_cutted_name
							 &format_as_category_feature_values

							 &format_as_product_feature_name
							 &format_as_product_distributor

							 &format_as_searchable
							 &format_as_limit_direction

							 &format_as_assorted_list
							 &format_as_assorted_list_element

							 &format_as_day
							 &format_as_month
							 &format_as_year
							 &format_as_stat_subtotal

							 &format_as_cat_feat_group_id

							 &format_as_feature_restricted_dropdown

							 &format_as_supplier_name
							 &format_as_score

							 &format_as_updated
							 &format_as_not_null

							 &format_as_expiration_date
							 &format_as_subscription_level

							 &format_as_parent_family_id
							 &format_as_family_id
							 &format_as_status_mode
							 &format_as_product_requested
							 &format_as_family_count
							 &format_as_trace_family
							 &format_as_family_name
               &format_as_status_name
               &format_as_status_id
               &format_as_hsubject
               &format_as_last_complaint_id
               &format_as_uname
               &format_as_timestamp
               &format_as_values
               &format_as_compl_msg
               &format_as_acknowledge

							 &format_as_textline_hidden
							 &format_as_nobody_complaint


							 &format_as_market_state
							 &format_as_language_flag
							 &format_as_internal_complaint
							 &format_as_internal_complaint_search

							 &format_as_mail_dispatch_groups
							 &format_as_dispatch_send_to
							 &format_as_dispatch_emails
							 &format_as_dispatch_message
							 &format_as_dispatch_status
							 &format_as_dispatch_to_groups
							 &format_as_dispatch_attach
							 &format_as_dispatch_message_type

							 &format_as_button_type

							 &format_as_gallery_pics
							 &format_as_multimedia_object

							 &format_as_journal_product
							 &format_as_journal_product_summary
							 &format_as_supplier_country
							 &format_as_supplier_contact

							 &format_as_marketing_text
							 &format_as_cat2family
							 &format_as_categories_families
 							 &format_as_lang_tabs
 							 &format_as_tab_name
 							 &format_as_tab_feature_value
 							 &format_as_tab_feature_value_ajaxed
 							 &format_as_access_repository
							 &format_as_ean_country
							 &format_as_onmarket_select
							 &format_as_input_checkbox
							 &format_as_input_checkbox_via_hidden
							 &format_as_checked_checkbox
							 &format_as_product_screen_row
							 &format_as_localized
							 &format_as_report_format
								&format_as_icetools_auth_link

								&format_as_merge_symbol
								&format_as_strip_text

								&format_as_feature_value_checking_ajax

								&format_as_has_implementation

								&format_as_power_mapping_num_features
								&format_as_power_mapping_num_measures
								&format_as_power_mapping_value_get_from_params
								&format_as_measure_power_mapping_value_get_from_params

								&format_as_initial_generic_operation_JavaScript_arrays

								&format_as_pattern_type
								&format_as_pattern_type_passive
								&format_as_pattern_move
								&format_as_pattern_edit
								&format_as_pattern_del
								&format_as_pattern_add

								&format_as_relation_amount
								&format_as_relation_set_amount
								&format_as_relation_list
								&format_as_pricelists_checkbox
								&format_as_editor_distri
								&format_as_show_all
								&format_as_URLDecode
								&format_as_URLEncode
								&format_as_str_sqlize
								&format_as_campaign_product_view

								&format_as_available_category_names_like_value

								&format_as_sponsor
								&format_as_wrong_partcode
								&format_as_system_of_measurement

								&format_as_product_xml_indicator
								&format_as_restricted_user_choice
								&format_as_from_unixtime
								&format_as_unshown_update
								&format_as_radio
								&format_as_custom_select
								&format_as_rand
								&format_as_dir_choice
								&format_as_feed_config_preview
								&format_as_csv_column_choice
								&format_as_link_to_coverage
								&format_as_coverage_summary
								&format_as_link_to_distri_pricelist
								&format_as_source_price_import
								&format_as_feed_file_name
								&format_as_feed_config_preview_button

								&format_as_interval_info

								&format_as_virtual_categories_list
								&format_as_vcategories
								&format_as_short_str
								&format_as_present
								&format_as_description_quality
								&format_as_hide_track_products_col
								&format_as_hide_track_products_col_names
								&format_as_track_product_parked
								&format_as_dropdown_multi_pair_to_user_id
								&format_as_dropdown_multi_pair_from_user_id
								&format_as_dropdown_multi_pair_to_langid
								&format_as_dropdown_multi_pair_from_langid
								&format_as_open_closed
								&format_as_track_list_priority
								&format_as_track_list_rule_status
								&format_as_tracklist_eta
								&format_as_track_list_restricted_cols
								&format_as_track_list_column_choice
								&format_as_track_list_status_color
								&format_as_vcatid_link

								&format_as_families_set

								&format_as_clever_clock
								&format_as_if_my_username
								&format_as_product_history_type
								&format_as_product_history_content
								&format_as_product_history_action

								&format_as_track_list_rule_prod_id
								&format_as_logo_pic
								&format_as_display_user_partner
								&format_as_track_list_hide_link

								&format_as_ids_save_for_clipboard
								&format_as_radio_buttons

								&format_as_sync_distri
								&format_as_ok_not_ok_for_distri
								&format_as_track_list_described_color
								&format_as_track_product_park_cause
								&format_as_track_product_rule_button
								&format_as_dictionary_langs
								&format_as_curr_dictionary_style
								&format_as_dictionary_id_list
								&format_as_track_list_graph_axis
								&format_as_track_list_graph_editors
								&format_as_dropdown_multi_pair_from_user_id_graph
								&format_as_dropdown_multi_pair_to_user_id_graph
								&format_as_product_lookup
								&format_as_DS_feature_measure
								&format_as_track_product_rule_status
								&format_as_dropdown_multi_pair_from_entrusted_user
								&format_as_dropdown_multi_pair_to_entrusted_user
								&format_as_dropdown_cached
								&format_as_ean_login
								&format_as_track_product_rule_icon
								&format_as_ssl_url
								&format_as_empty_sector_name
								&format_as_track_list_hide_link_entrusted_editors
								&format_as_series
								&format_as_series_set
								&format_as_js_langid_array
								&format_as_google_transl_return
								&format_as_rating_formula
								&format_as_rating_period
								&format_as_rating_email
								&format_as_track_product_rule_status
								&format_as_dropdown_multi_pair_from_entrusted_user
								&format_as_dropdown_multi_pair_to_entrusted_user
								&format_as_dropdown_cached
								&format_as_ean_login
								&format_as_track_product_rule_icon
								&format_as_ssl_url
								&format_as_empty_sector_name
								&format_as_track_list_hide_link_entrusted_editors
								&format_as_series
								&format_as_series_set
								&format_as_js_langid_array
								&format_as_google_transl_return
								&format_as_checked_by_supereditor
);


	$temp_lang_select = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40'; ## select 40 languages
}

sub format_as_rating_email{
	my ($value,$call,$field,$res,$hash) = @_;
	if(!$value or $value eq '%%email%%'){
		my $user_email=do_query('SELECT c.email FROM users u JOIN contact c ON c.contact_id=u.pers_cid WHERE u.user_id='.$USER->{'user_id'})->[0][0];
		return $user_email;
	}
	else{
		return $hash->{'email'};
	}
}

sub format_as_rating_formula{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hin{$field}){#we have the formula
		return $hin{$field}; 
	}else{
		my $ds_conf=$hash->{'configuration'};
		if($ds_conf=~/formula:[\s]*([^\n]+)[\n]*/){
			return $1;
		}else{
			return '';
		}
	}
}

sub format_as_rating_period{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hin{$field}){#we have the period
		return $hin{$field}; 
	}else{
		my $ds_conf=$hash->{'configuration'};
		if($ds_conf=~/period:[\s]*([^\n]+)[\n]*/){
			return $1;
		}else{
			return '';
		}
	}
}

sub format_as_google_transl_return{
	my ($value,$call,$field,$res,$hash) = @_;
	my $transl_langs;
	eval{$transl_langs=eval($hash->{'lang_ids'})};
	my $js_obj='';
	$hash->{'en_string'}=HTML::Entities::decode_entities($hash->{'en_string'});
	$hash->{'en_string'}=~s/&/and/gs;	
	for my $transl_lang (@$transl_langs){
		
		my $result_transl=translate_from_google([$hash->{'en_string'}],1,$transl_lang);
		my $result_trimed=$result_transl->{$hash->{'en_string'}};						
		if($result_trimed =~/We\sare\snot\syet\sable\sto\stranslate\sfrom/i){
			my $backup_langid=do_query('SELECT backup_langid FROM language WHERE langid='.$transl_lang)->[0][0];
			if($backup_langid){
				$result_transl=translate_from_google([$hash->{'en_string'}],1,$backup_langid);
				$result_trimed=$result_transl->{$hash->{'en_string'}};
			}			
		}		
		$result_trimed=~s/'/\\'/;
		$result_trimed=uc(substr($result_trimed,0,1)).substr($result_trimed,1);
		$js_obj.='{id:\''.$hash->{'id_pattern'}.$transl_lang.'\',value:\''.$result_trimed.'\'},';		
	}
	$js_obj=~s/,$//;
	$js_obj='['.$js_obj.']';
	return $js_obj;
}

sub format_as_js_langid_array{
	my ($value,$call,$field,$res,$hash) = @_;
	my $langs=do_query('SELECT langid FROM language WHERE langid!=1 ORDER BY langid');
	my @langids=map {$_->[0]} @$langs;
	my $arr_txt=join(',',@langids);
	$arr_txt='['.$arr_txt.']';
	$atoms->{$call->{'class'}}->{$call->{'name'}}->{'langid_list_cache'}=$arr_txt;
	return $arr_txt;
}

sub format_as_empty_sector_name{
	my ($value,$call,$field,$res,$hash) = @_;
	if(!$value){		
		return 'Empty name';
	}else{
		return $value;	
	}
}

sub format_as_track_product_rule_icon{
	my ($value,$call,$field,$res,$hash) = @_;
	if($value){
		return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_change_left'};
	}else{
		return return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_change_right'};;
	}	
}

sub format_as_track_product_rule_status{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rule_txt='';
	if($hash->{'is_reverse_rule'}){
		$rule_txt=$hash->{'rule_prod_id'}.'='.$hash->{'feed_prod_id'};
	}else{
		$rule_txt=$hash->{'feed_prod_id'}.'='.$hash->{'rule_prod_id'};
	}
	$rule_txt.="\n";
	if( $value=~/\Q$rule_txt\E/i ){
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_icons'},
						{'left_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_ok'},
						 'right_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_remove'}
						});
		
	}elsif($hash->{'rule_status'} eq '1'){
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_icons'},
						{'left_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_new'},
						 'right_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_canceled'}
						});		
	}elsif($hash->{'rule_prod_id'}){		
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_icons'},
						{'left_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_new'},
						 'right_icon'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'rule_status_remove'}
						});
	}else{
		return '';
	}		
}

sub format_as_DS_feature_measure{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hash->{'langid'} and $hash->{'data_source_feature_map_info_id'} and $hin{'measure_sign_'.$hash->{'data_source_feature_map_info_id'}}){
		return $hin{'measure_sign_'.$hash->{'data_source_feature_map_info_id'}};
	}else{
		return $hash->{'measure_signs_db'};
	}
}

sub format_as_track_list_graph_axis{
	my ($value,$call,$field,$res,$hash) = @_;
	my $tmp_table=create_assigned_id_table('occupied_user_id','tmp_graph_user_ids');
	use Time::Piece;
	my $now_date=do_query('SELECT unix_timestamp(date(now()))')->[0][0];
	my $start_interval=do_query('SELECT unix_timestamp(date(created)) FROM track_list WHERE track_list_id='.$hin{'track_list_id'})->[0][0];
	my $days_diff=floor(($now_date-$start_interval)/(24*3600));
	my $time_interval;
	if($days_diff>50){
		$start_interval=$now_date-(50*24*3600);
		$time_interval='and described_date>from_unixtime('.$start_interval.')';
	}
	my $data_str='';
	my ($curr_login,$last_date,$day_index);
	my $cumulate_count;
	# write sql selection to the string presenting 3d array like this [[[1,3],[2,4]],[[1,5],[2,7]]]
	#1 level is editor's data set
	#2 level is array with x,y pair
	my ($graph_users,$user_select);
	if(do_query('SELECT count(*) from '.$tmp_table)->[0][0]){# some users choiced to be shown
		$graph_users=do_query("SELECT u.login,u.user_id FROM  $tmp_table t JOIN users u ON t.id=u.user_id  ORDER BY u.login");
		$user_select='and u.user_id=';
	}else{ # no user choiced. show the team result
		$graph_users=[['','']];
		do_statement("INSERT INTO $tmp_table (id) SELECT user_id FROM track_list_editor WHERE track_list_id=$hin{'track_list_id'} ");

	}
	for	my $graph_user (@$graph_users){
		my $graph_data=do_query("SELECT date(described_date),count(tp.product_id),u.login,unix_timestamp(date(described_date))
				FROM track_product tp
				JOIN product p ON p.product_id=tp.product_id
				JOIN users u ON u.user_id=p.user_id
				JOIN $tmp_table tmp ON tmp.id=u.user_id
				JOIN user_group_measure_map um ON u.user_group=um.user_group
				WHERE um.measure='ICECAT' and described_date!=0 and track_list_id=$hin{'track_list_id'} $user_select $graph_user->[1]
				$time_interval
				GROUP BY date(described_date)");
		$data_str.='[';
		if($days_diff>50){
				$cumulate_count=do_query("SELECT count(*) FROM track_product tp JOIN product p USING(product_id) JOIN users u USING(user_id)
							JOIN $tmp_table tmp ON tmp.id=u.user_id
							WHERE ".(($graph_user->[1])?"u.user_id=$graph_user->[1] and":'')."  tp.described_date!=0  and track_list_id=$hin{'track_list_id'} and tp.described_date<from_unixtime($start_interval)")->[0][0];
		}else{
			$cumulate_count=0;
		}
		my $j=0;
		my $days_diff_new=floor(($now_date-$start_interval)/(24*3600))+2;
		for(my $i=1; $i<$days_diff_new; $i++){
			for($j=0; $j<scalar(@$graph_data);$j++){
				if($graph_data->[$j][3]==($start_interval + (($i-1)*24*3600))){
					$cumulate_count=$cumulate_count+$graph_data->[$j][1];
					last;
				}
			}
			$data_str.="[$i,$cumulate_count],";
		}

		$data_str=~s/,$//;
		$data_str.='],';
	}
	$data_str=~s/,$//;
	$data_str=~s/^\],//;
	$data_str='"['.$data_str.']"';
	return $data_str;
}

sub format_as_track_list_graph_editors{
	my ($value,$call,$field,$res,$hash) = @_;
	my $tmp_table=create_assigned_id_table('occupied_user_id','tmp_graph_user_ids');
	if(do_query('SELECT count(*) from '.$tmp_table)->[0][0]){# some users choiced to be shown
		my $tl_users = do_query("select u.login from $tmp_table t JOIN users u ON u.user_id=t.id ORDER BY u.login");
		my $str_arr;
		for my $tl_user (@$tl_users	){
			$str_arr.="{label:'$tl_user->[0]'},"
		}
		$str_arr=~s/,$//;
		return '"['.$str_arr.']"';
	}else{ # no user choiced. show the team result
		return '"[{label:\'team\'}]"';
	}

}

sub format_as_curr_dictionary_style{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hash->{'langid'}==1){
		return 'table-row';
	}else{
		return 'none';
	}
}

sub format_as_dictionary_langs{
	my ($value,$call,$field,$res,$hash) = @_;
	my $langs=do_query("SELECT langid,short_code FROM language WHERE 1");
	my $table='<tr>';
	my $half=floor(scalar(@$langs)/2);
	for(my $i=0; $i<scalar(@$langs);$i++){
			if($i==$half){
				$table.='</tr><tr>';
			}
			$table.=repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'lang_link'}, {'lang_code' => $langs->[$i][1],'langid'=>$langs->[$i][0]})
	}
	$table.='</tr>';
	return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'lang_table'}, {'lang_links' => $table});
}

sub format_as_dictionary_id_list{
	my ($value,$call,$field,$res,$hash) = @_;
	my $list;
	my $langs=do_query("SELECT langid FROM language WHERE 1");
	for my $lang (@$langs){
			$list.=',_rotate_html_'.$lang->[0];
	}
	$list=~s/^,//;
	return $list;
}

sub format_as_logo_pic{
 my ($value,$call,$field,$res,$hash) = @_;
 if($hash->{'is_implementation_partner'}==1 or $hin{'is_implementation_partner'} eq '1'){
 	$value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'logo_pic_html'}, {'logo_pic' => $value,'style_show'=>'block'});
 }else{
 	$value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'logo_pic_html'}, {'logo_pic' => $value,'style_show'=>'none'});
 }
 return $value;
}

sub format_as_display_user_partner{
 my ($value,$call,$field,$res,$hash) = @_;
 	if($value eq 'shop' or $hin{'user_group'} eq 'shop'){
 		return 'table-row';
 	}else{
 		return 'none';
 	}

}

sub format_as_product_xml_indicator {
	my ($value,$call,$field,$res,$hash) = @_;

	my $states = {
		'no xml' =>            '<span style="color: gray;">Not yet described, no XML</span>',
		'old xml, no queue' => '<span style="color: red;">Obsolete XML, not yet queued</span>',
		'old xml, queue' =>    '<span style="color: darkorange;">Obsolete XML, but queued</span>',
		'up-to-date xml' =>    '<span style="color: green;">Up-to-date XML</span>'
	};
	
	return $states->{'no xml'} unless $value;

	# check if this product is described
	my $i = do_query("select cmim.quality_index, pq.id, unix_timestamp(p.updated), pmt.modification_time
		from product p
		left  join process_queue pq on p.product_id=pq.product_id and pq.process_class_id=1 and pq.process_status_id!=30
		left  join product_modification_time pmt on p.product_id=pmt.product_id
		inner join users u using (user_id)
		inner join user_group_measure_map ugmm using(user_group)
		inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure
		where p.product_id=".$value." limit 1")->[0];

	if (($i) && ($i->[0] > 0)) { # described, so, we must have an xml
		if ($i->[2] == $i->[3]) {
			if ($i->[3]) { # we have an up-to-date xml
				return $states->{'up-to-date xml'};
			}
		}
		else {
			if (($i->[1]) && ($i->[1] > 0)) { # we have an old xml and queued
				return $states->{'old xml, queue'};
			}
			else { # we have an old xml, and not yet queued
				return $states->{'old xml, no queue'};
			}
		}
	}
	return $states->{'no xml'};
} # sub format_as_product_xml_indicator

sub format_as_system_of_measurement {
	my ($value,$call,$field,$res,$hash) = @_;

	my $rows = [['metric','Metric'],['imperial','Imperial']];

	# return make_select($rows, $field, $value);
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value
	} );
} # sub format_as_system_of_measurement

sub format_as_wrong_partcode {
	my ($value,$call,$field,$res,$hash) = @_;

	return '' unless $call->{'call_params'}->{'product_id'};
	return brand_prod_id_checking_by_regexp($value, { 'product_id' => $call->{'call_params'}->{'product_id'} }) ? "" : "Warning! The product probably has the wrong code. Please, check with the brand";
} # sub format_as_sponsor

sub format_as_sponsor {
	my ($value,$call,$field,$res,$hash) = @_;

	my $rows = [['','Sponsor / No sponsor'],['Y','Sponsor'],['N','No sponsor']];

	# return make_select($rows, $field, $value);
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value
	} );
} # sub format_as_sponsor

sub format_as_campaign_product_view {
	my ($value,$call,$field,$res,$hash) = @_;

	my $start_date = $call->{'call_params'}->{'start_date'};
	my $end_date = $call->{'call_params'}->{'end_date'};
	my $seconds_per_day = 60 * 60 * 24;

	return do_query("select count(*) from aggregated_request_stat where product_id=".$value . ( $start_date ? " and date >= " . $start_date : '' ) . ( $end_date ? " and date <= " . ($end_date + $seconds_per_day) : '' ))->[0][0] || '0';
} # sub format_as_campaign_product_view

sub format_as_available_category_names_like_value {
	my ($value,$call,$field,$res,$hash) = @_;
#	my $mode = lc($iatoms->{$call->{'name'}}->{$field.'_mode'}) eq 'tree' ? 'tree' : 'list';
	my $field_name;
	$field_name=($hin{'field_name'})?$hin{'field_name'}:'catid';
	my $allow_pcat_choice=$hin{'allow_pcat_choice'};
	my $query_order = 'v.value asc';
	my $query_join = '';
	my $query_add_parameter = '';
	my $query_condition = "and v.value like ".str_sqlize('%'.$value.'%')." ";
	unless ($value) {
		use nested_sets;

		check_tree('category','catid','pcatid');

		$query_order = 'cns.left_key asc';
		$query_join = ' inner join category_nestedset cns using (catid) ';
		$query_add_parameter = ', cns.level';
		$query_condition = 'and cns.langid=1';
	}

	my $values;
	$values = do_query("select c.catid, v.value, c.ucatid abstract".$query_add_parameter."
from category c ".$query_join."
inner join vocabulary v on c.sid=v.sid and v.langid=1
where 1 ".$query_condition." and c.catid!=1 and v.value != ''
order by ".$query_order);

	my $output = '';
	my $i = 0;
	my $a = 0; # the active row number. will be returned
	my $active = '';
	my $disabled = '';
	my $isDisabled = '';

	if(!$value and $hin{'add_empty'}){
		my $add_empty_value=($hin{'add_empty_value'})?$hin{'add_empty_value'}:'0';
		$output='<div id="'.$field_name.'_item_0" style="padding-left: 0px;"
				  onclick=\'javascript: smartDropdownSetValue('.$add_empty_value.',this.innerHTML,"'.$field_name.'")\'
				  onmouseover="javascript: item'.$field_name.'MouseOver(0,'.$add_empty_value.',this.innerHTML);"
				  onmouseout="javascript: item'.$field_name.'MouseOut(0,'.$add_empty_value.',this.innerHTML);"
				  class="scroll_item">'.$hin{'add_empty'}.'</div>' .
				  "\n";
	}

	for (@$values) {
		$i++;
		if ($_->[0] == $hin{$field_name}) {
			$active = '_active';
			$a = $i;
		}
		else {
			$active = '';
		}
		$isDisabled = $_->[2] =~ /00$/ && !$active && !$allow_pcat_choice;
		$disabled = $isDisabled ? "_disabled" : '';
		$output .= '<div id="'.$field_name.'_item_'.$i.'"' . " style=\"padding-left: " . ( $value ? '0' : (($_->[3] - 2) * 10)) . "px;\"" .
			( $isDisabled ? '' : "onClick='javascript: smartDropdownSetValue(" . $_->[0] . ",this.innerHTML,\"$field_name\")'
onMouseOver='javascript: item".$field_name."MouseOver(" . $i . "," . $_->[0] . ",this.innerHTML);'
onMouseOut='javascript: item".$field_name."MouseOut(" . $i . "," . $_->[0] . ",this.innerHTML);'" ) .
" class='scroll_item" . $active . $disabled .
"'>" .  $_->[1] . '</div>' . "\n";
	}

	$output .= "<!-- (" . ($#$values + 1) . ":" . $a . ") -->"; # the way to send: the number of rows : the active row

	return $output;
} # sub format_as_available_category_names_like_value




sub format_as_relation_amount {
	my ($value,$call,$field,$res,$hash) = @_;

	my $prefix = '';

	if ($iatoms->{$call->{'name'}}->{$field.'_prefix'}) {
		$prefix = $iatoms->{$call->{'name'}}->{$field.'_prefix'};
	}

	# prepare params if needed
	$hash->{$prefix.'supplier_id'} =        $hin{$prefix.'supplier_id'}        if defined $hin{$prefix.'supplier_id'};
	$hash->{$prefix.'supplier_family_id'} = $hin{$prefix.'supplier_family_id'} if defined $hin{$prefix.'supplier_family_id'};
	$hash->{$prefix.'catid'} =              $hin{$prefix.'catid'}              if defined $hin{$prefix.'catid'};
	$hash->{$prefix.'feature_id'} =         $hin{$prefix.'feature_id'}         if defined $hin{$prefix.'feature_id'};
	$hash->{$prefix.'feature_value'} =      $hin{$prefix.'feature_value'}      if defined $hin{$prefix.'feature_value'};
	$hash->{$prefix.'exact_value'} =        $hin{$prefix.'exact_value'}        if defined $hin{$prefix.'exact_value'};
	$hash->{$prefix.'prod_id'} =            $hin{$prefix.'prod_id'}            if defined $hin{$prefix.'prod_id'};
	$hash->{$prefix.'start_date'} =         $hin{$prefix.'start_date'}         if defined $hin{$prefix.'start_date'};
	$hash->{$prefix.'end_date'} =           $hin{$prefix.'end_date'}           if defined $hin{$prefix.'end_date'};

	# do it
	return get_product_relations_amount($hash->{$prefix.'supplier_id'},$hash->{$prefix.'supplier_family_id'},$hash->{$prefix.'catid'},$hash->{$prefix.'feature_id'},$hash->{$prefix.'feature_value'},$hash->{$prefix.'exact_value'},$hash->{$prefix.'prod_id'},$hash->{$prefix.'start_date'},$hash->{$prefix.'end_date'});
} # sub format_as_relation_amount

sub format_as_relation_set_amount {
	my ($value,$call,$field,$res,$hash) = @_;

	# do it
	return get_product_relations_set_amount($value, $field); # relation_id, name (if name =~ /_2/ - do 2nd parts, else 1st ones)
} # sub format_as_relation_set_amount

sub format_as_relation_list {
	my ($value,$call,$field,$res,$hash) = @_;

	my $list = get_products_related_by_product_id($hin{'product_id'});

	my ($res, $row);

	for (@$list) {
		$row = do_query("select p.prod_id, p.name, s.name from product p inner join supplier s using (supplier_id) where p.product_id=".$_." limit 1")->[0];
		$res .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'xsells_list_row'},{ 'rel_prod_id' => $row->[0], 'r_supplier_name' => $row->[2], 'r_name' => $row->[1] });
	}

	return $res;
} # sub format_as_relation_list

sub format_as_initial_generic_operation_JavaScript_arrays {
	my ($value,$call,$field,$res,$hash) = @_;

	my $value_names = '';
	my $value_codes = '';
	my $value_parameters = '';

	my $gos = do_query("select name, code, parameter from generic_operation order by code asc");

	for (@$gos) {
		$value_names .= "'".$_->[0]."',";
		$value_codes .= "'".$_->[1]."',";
		if (($_->[2] ne '1') && ($_->[2] ne '2')) {
			$_->[2] = '0';
		}
		$value_parameters .= "'".$_->[2]."',";
	}
	chop($value_names);
	chop($value_codes);
	chop($value_parameters);

	if ($value_codes) {
		return "var go_names = new Array (".$value_names.");\n".
			"var go_codes = new Array (".$value_codes.");\n".
			"var go_parameters = new Array (".$value_parameters.");";
	}
	else {
		return '';
	}

} # sub format_as_initial_generic_operation_JavaScript_arrays

sub format_as_measure_power_mapping_value_get_from_params {
	my ($value,$call,$field,$res,$hash) = @_;

#	log_printf(Dumper($hin{'power_mapping_on'}));

	return '' if $call->{'call_params'}->{'unauthorized_submit'};

	if (($hin{'power_mapping_on'}) && ($hin{'power_mapping_results'})) {
		$value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_table_head'};
		my $hash = $hin{'power_mapping_results'};
		for my $h (keys %$hash) {
			$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_content'},
												 {
													 'old' => $h,
													 'new' => $hash->{$h}->{'new_value'},
													 'mapping' => $hash->{$h}->{'history'}
												 });
		}
		$value .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_table_foot'};
		$value .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_do_apply'};
	}
	else {
		$value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_do_preview'};
	}

	return $value;

} # sub format_as_measure_power_mapping_value_get_from_params

sub format_as_pattern_edit {
	my ($value,$call,$field,$res,$hash) = @_;

	unless ($call->{'call_params'}->{'unauthorized_submit'}) {
		return '<a class="linksubmit" onClick="javascript:hideMove();patternEdit(\'%%no%%\');">edit</a>';
	}
	else {
		return '';
	}
} # sub format_as_pattern_edit

sub format_as_pattern_del {
	my ($value,$call,$field,$res,$hash) = @_;

	unless ($call->{'call_params'}->{'unauthorized_submit'}) {
		return '<a class="linksubmit" onClick="if(confirm(\'Are you sure?\')) javascript:document.getElementById(\'del_%%no%%\').submit(); ">del</a>';
	}
	else {
		return '';
	}
} # sub format_as_pattern_del

sub format_as_pattern_add {
	my ($value,$call,$field,$res,$hash) = @_;

	unless ($call->{'call_params'}->{'unauthorized_submit'}) {
		return 'inline';
	}
	else {
		return 'none';
	}
} # sub format_as_pattern_add

sub format_as_pattern_move {
	my ($value,$call,$field,$res,$hash) = @_;

	if ($G_pattern_no) {
		$G_pattern_no++;
	}
	else {
		$G_pattern_no = 1;
	}

	$value = '';
	if ($G_pattern_no != 1 && !$call->{'call_params'}->{'unauthorized_submit'}) { # do up
		$value = "<a class=\"linksubmit\" onClick=\"javascript:hideAction();showMoveUpdate();doUp(%%no%%);\"><img src=\"img/up16.gif\" alt=\"up\" border=\"0\"></a>";
	}
	if (($G_pattern_no != $call->{'call_params'}->{'found'}) && ($G_pattern_no != 1)) {
		$value .= '&nbsp;&nbsp;&nbsp;&nbsp;';
	}
	if ($G_pattern_no != $call->{'call_params'}->{'found'} && !$call->{'call_params'}->{'unauthorized_submit'}) { # do down
		$value .= "<a class=\"linksubmit\" onClick=\"javascript:hideAction();showMoveUpdate();doDown(%%no%%);\"><img src=\"img/down16.gif\" alt=\"down\" border=\"0\"></a>";
	}

	chomp($value);
#	log_printf(Dumper($call));

	return "<td class=\"td-norm\"><div id=\"pattern_move_%%no%%\">".$value."</div></td>";
} # sub format_as_pattern_move

sub format_as_pattern_type {
	my ($value,$call,$field,$res,$hash) = @_;

	unless ($icecat_mapping::G_go_hash) {
    $icecat_mapping::G_go_hash = get_generic_operations_hash;
  }

	my $parts = get_pattern_parts([$value,$hash->{'parameter1'},$hash->{'parameter2'}],'none',1);

	if ($icecat_mapping::G_go_hash->{$parts->{'left'}}->{'code'}) { # GO
		$value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'power_map_view'},
											{
												'pattern_id' => $hash->{'pattern_id'},
												'pattern_left' => $parts->{'left'},
												'pattern_right_1' => $parts->{'1'},
												'pattern_right_2' => $parts->{'2'},
												'pattern_type' => 'g',
												'pattern_show' => ($hash->{'active'} eq 'Y'?"":"<i><font color=\"grey\">") .
													"<b>" . ($icecat_mapping::G_go_hash->{$parts->{'left'}}->{'name'} || $parts->{'left'}) . "</b>" .
													"&nbsp;<font color=\"grey\">(</font>" . $parts->{'1'} .
													($parts->{'2'}?"<font color=\"grey\">,</font>".$parts->{'2'}:"") .
													"<font color=\"grey\">)</font>" .
													($hash->{'active'} eq 'Y'?"":"</font></i>")
												});
	}
	else { # pattern
		$value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'power_map_view'},
											{
												'pattern_id' => $hash->{'pattern_id'},
												'pattern_left' => $parts->{'left'},
												'pattern_right' => $parts->{'right'},
												'pattern_type' => 'p',
												'pattern_show' => ($hash->{'active'} eq 'Y'?"":"<i><font color=\"grey\">") .
													$parts->{'left'}."<font color=\"red\">=</font>".$parts->{'right'} .
													($hash->{'active'} eq 'Y'?"":"</font></i>")
											});
	}
} # sub format_as_pattern_type

sub format_as_pattern_type_passive {
	my ($value,$call,$field,$res,$hash) = @_;

	unless ($icecat_mapping::G_go_hash) {
    $icecat_mapping::G_go_hash = get_generic_operations_hash;
  }

	my $parts = get_pattern_parts([$value,$hash->{'measure_parameter1'},$hash->{'measure_parameter2'}],'none',1);

	if ($icecat_mapping::G_go_hash->{$parts->{'left'}}->{'code'}) { # GO
		$value = ($hash->{'measure_active'} eq 'Y'?"":"<i><font color=\"grey\">") . "<b>" . ($icecat_mapping::G_go_hash->{$parts->{'left'}}->{'name'} || $parts->{'left'}) . "</b>&nbsp;<font color=\"grey\">(</font>".$parts->{'1'} . ($parts->{'2'}?"<font color=\"grey\">,</font>".$parts->{'2'}:"") . "<font color=\"grey\">)</font>".($hash->{'measure_active'} eq 'Y'?"":"</font></i>");
	}
	else { # pattern
		$value = ($hash->{'measure_active'} eq 'Y'?"":"<i><font color=\"grey\">") . $parts->{'left'}."<font color=\"red\">=</font>".$parts->{'right'} . ($hash->{'measure_active'} eq 'Y'?"":"</font></i>");
	}

	return $value;
} # sub format_as_pattern_type_passive

sub format_as_strip_text {
	my ($value,$call,$field,$res,$hash) = @_;
	my ($pattern);
	$pattern = $iatoms->{$call->{'name'}}->{$field.'_pattern'};
	$value =~ s/$pattern/$1/e;
	return $value;
} # sub format_as_strip_text

sub format_as_merge_symbol {
	my ($value,$call,$field,$res,$hash) = @_;
	my ($type, $id, $joins, $join_value, $symbol, $distributor_id, $rows, $cols, $m_value, $out);

	$type = $iatoms->{$call->{'name'}}->{$field.'_type'};
	$symbol = $hin{'reload'}?$hin{'symbol'}:$value;
	$distributor_id = $hash->{'distributor_id_static'};

	$id = $type."_id";
	$id =~ s/category_/cat/;

	$join_value = 'name';

	if ($type ne 'supplier') {
		$joins = "left join ".$type." t using (".$id.")
left join vocabulary v on t.sid=v.sid and v.langid=1";
		$join_value = 'value';
	}
	else {
		$joins = "left join ".$type." v using (".$id.")";
	}

	$rows = do_query("select dsm.data_source_".$type."_map_id, dsm.symbol, if(d.name is null,'<b>Any distributor</b>',d.name), v.".$join_value." from data_source_".$type."_map dsm left join distributor d using (distributor_id) ".$joins." where symbol = ".str_sqlize($symbol)." and data_source_id=".str_sqlize($hash->{'data_source_id'}));

	my $cnt = 0;
	my $ending = '';
	my $ids;
	for (@$rows) {
		if ($hin{"data_source_".$type."_map_id"} == $_->[0]) {
			$ending = '_disabled';
		}
		else {
			$ending = '';
			$cnt++;
		}
		$out .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'foreign_distributors_row'.$ending}, {
			'row_name' => $cnt,
			'row_value' => $_->[0],
			'foreign_symbol' => $_->[1],
			'foreign_distname' => $_->[2],
			'foreign_value' => $_->[3]
		});
		$ids->{$_->[0]} = '1';
	}

	## patterns

	$rows = do_query("select dsm.data_source_".$type."_map_id, dsm.symbol, if(d.name is null,'<b>Any distributor</b>',d.name), v.".$join_value.", dsm.distributor_id from data_source_".$type."_map dsm left join distributor d using (distributor_id) ".$joins." where data_source_".$type."_map_id!=".$hin{"data_source_".$type."_map_id"}." and data_source_id=".str_sqlize($hash->{'data_source_id'}));

  for (@$rows) {
    $m_value = match_cat_symbol_regexp($symbol, $_->[1]);

    if (($m_value ne $_->[1]) && (($distributor_id == 0) || ($distributor_id == $_->[4])) && !($ids->{$_->[0]})) {
			$cnt++;
			$out .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'foreign_distributors_row'}, {
				'row_name' => $cnt,
				'row_value' => $_->[0],
				'foreign_symbol' => $_->[1],
				'foreign_distname' => $_->[2],
				'foreign_value' => $_->[3]
				});
			$ids->{$_->[0]} = '1';
		}
  }

	$out .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'foreign_distributors_row_count'},{'row_count' => $cnt});

	return $cnt?repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'foreign_distributors_body'},{'foreign_distributors_rows' => $out}):"";
}

sub format_as_report_format
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $rows = [['html','html (only for daily interval)'],['xls','xls']];
 # return make_select($rows, $field, $value);
    return make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value
    } );
}

sub format_as_localized{
  my ($value,$call,$field,$res,$hash) = @_;
	$value = $hash->{'key_value'};
	my $codes = do_query("select short_code from feature_values_vocabulary v left join language l using (langid)
		where key_value=".str_sqlize($value)." and value!=''");
  $value = [];
	push @$value, lc $_->[0] for(@$codes);
  return join(' ',@$value);
}

sub format_as_product_screen_row{
	my ($value,$call,$field,$res,$hash) = @_;

	my $usr = do_query("select user_group,login from users as u where user_id=$hash->{edit_user_id}")->[0];
  $hash->{'edit_user_group'} = $usr->[0];
	$hash->{'user_name'} = $usr->[1];

	if(!$hash->{'cat_name'}){
		$hash->{'cat_name'} = do_query("select v.value from vocabulary as v, category as c
			where v.langid=1 and c.sid=v.sid and c.catid=$hash->{catid}")->[0][0];
	}

	if(!$hash->{'supp_name'}){
    $hash->{'supp_name'}= do_query("select name from supplier where supplier_id=$hash->{supplier_id}")->[0][0];
	}
}

sub format_as_input_checkbox {
	my ($value,$call,$field,$res,$hash) = @_;
	my $attr = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_tag_attributes'};
	my $by_default = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_checked_by_default'} eq 'Y' ? 1 : undef;
	log_printf("attr=".$attr." bydef=".$by_default);
	$value = (($value == 1 || $value eq 'Y') || ($by_default && $value eq '')) ? ' checked' : '';
	return '<input type=checkbox name="' . $field . '" id="' . $field . '" value="1"' . $value . ($attr ? ' ' . $attr : '') . '>';
}

sub format_as_pricelists_checkbox
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $val = $value==1? ' checked':'';
 return '<input type=checkbox name="'.$field.'%%no%%" id="'.$field.'%%no%%" value="'.$value.'"'.$val.' disabled="true">';
}

sub format_as_input_checkbox_via_hidden
{
	my ($value,$call,$field,$res,$hash) = @_;
	$value = $value!=1?0:1;
	my $value_checked = $value==1? ' checked':'';
	return '<script language="JavaScript">
<!--
	function set_'.$field.'_value() {
		if (document.getElementById("'.$field.'_checkbox").checked) {
			document.getElementById("'.$field.'").value=1;
		}
		else {
			document.getElementById("'.$field.'").value=0;
		}
	}
//-->
</script>
<input type="checkbox" name="'.$field.'_checkbox" id="'.$field.'_checkbox" '.$value_checked.' onClick="javascript:set_'.$field.'_value();">
<input type="hidden" name="'.$field.'" id="'.$field.'" value="'.$value.'">';
}

sub format_as_checked_checkbox {
 my ($value,$call,$field,$res,$hash) = @_;
 $value = (($value ne '')&&($value ne '%%deep_search%%'))? ' checked':'';
 return $value;
}

sub format_as_onmarket_select
{
    my ($value,$call,$field,$res,$hash) = @_;
    my $distri = do_query("select distributor_id, name from distributor order by name");

    my $rows = [[0,''],['all','Any distributor']];
    for my $d (@$distri) { push @$rows, [$d->[0],$d->[1]]; }
    # return make_select($rows, $field, $value,'class=smallform');
    return make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => 'class=smallform'
    } );
}

sub format_as_yes_no_text
{
 my ($value,$call,$field,$res,$hash) = @_;
 return $value>0?'yes':'no';
}

sub format_as_relation_exact_value_text {
	my ($value,$call,$field,$res,$hash) = @_;

	return do_query("select exact_value_text from relation_exact_values where exact_value=".$value)->[0][0] || '';
}

sub format_as_yes_no_select
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $default_value=$iatoms->{$call->{'name'}}->{$field.'_yes_no_default'};
 $value=$default_value if !$value and defined($default_value);
 my $functions=$iatoms->{$call->{'name'}}->{$field.'_attrs'};
 my $rows = [[1,'yes'],[0,'no']];
    # return make_select($rows, $field, $value);
    return make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'functions'=>$functions
    } );
}

sub format_as_ean_country
{
	my ($value,$call,$field,$res,$hash) = @_;

	my $data = do_query('select value, ean_prefix from country as c, vocabulary as v where c.sid=v.sid and v.langid=1');
	my $ean = $hash->{'ean_code'};

  if($ean =~ /\d{13}/){
    for my $country (@$data) {
      my ($p1,$p2);
      my $prefix = $country->[1];
      $prefix =~ /(\d+)(\D*)(\d*)/;
      $p1 = $1;
      $p2 = $3 eq ''? $p1:$3;
      if($p1>$p2){ my $tmp=$p1; $p1=$p2; $p2=$tmp; }
      for my $p ($p1..$p2){
        $p = sprintf("%02d",$p);
        if($ean =~ /^$p/){ return $country->[0].' ('.$country->[1].')'; }
      }
    }
  }

 return '';
}

sub format_as_marketing_text {
 my ($value,$call,$field,$res,$hash) = @_;

 my $rows = 5;
 $rows = 15 if ($hin{'product_description_id'});
 my $style = '';
 $style = ' style="' . $iatoms->{$call->{'name'}}->{$field.'_style'} . '"' if $iatoms->{$call->{'name'}}->{$field.'_style'};
 $value = "<textarea cols=72 rows=$rows name=\"$field\" id=\"$field\"$style>$value</textarea>";

 return $value;
}

sub format_as_textline_hidden
{
 my ($value,$call,$field,$res,$hash) = @_;
# return $value;

 if($value){
   # no metatags

	 $value =~s/\\/\\\\/gsm;

	 $value =~ s/^\n/\\n/gsm;
	 $value =~ s/([^\\])\n/$1\\n/gsm;

#	 $value =~s/\&/\&ampe;/g;

	 # no tags

	 $value =~s/>/\&gt\;/g;
	 $value =~s/</\&lt\;/g;

	 # preventing %% to be interpreted
	 $value =~s/%/\\%/g;

	 # replace "(&quot;)
	 $value =~ s/\"/&quot;/g;

 }
 return $value;
}

sub format_as_feature_restricted_dropdown
{
 my ($value,$call,$field,$res,$hash) = @_;

	sub my_make_select {
	my ($rows,$name,$sel, $small) = @_;
	my @tmp;

	push (@tmp, "<select name=\"$name\" $small>");
	for my $i (@$rows) {
		if ($sel eq $i->[0]) {
			push (@tmp, "<option selected value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
		} elsif ($i->[0] eq '' && $i->[1] eq '') {
			push (@tmp, '<option>');
		} else {
			push (@tmp, "<option value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
		}
	}
	push (@tmp, "</select>");

	return join("\n", @tmp);
}


	  my @vals = split("\n", $hash->{'restricted_values'});
		my $sel = [ ['',''] ];;

		for my $val(@vals){
#		 log_printf('!'.$val.'!');
#		 $val = str_htmlize($val);
		 my $display = $val;
		 push @$sel, [$val, $display];
		}

   return my_make_select($sel, $field, $value);
}

sub format_as_cat_feat_group_id
{
 my ($value,$call,$field,$res,$hash) = @_;

 if($value){
  my $data = do_query('select feature_group_id from category_feature_group where category_feature_group_id = '.str_sqlize($value));
	if($data->[0]){
	 $value = $data->[0][0];
	} else {
	 $value = 0;
	}
 }

    my $rows = do_query("select feature_group_id, vocabulary.value from feature_group, vocabulary where vocabulary.sid = feature_group.sid and vocabulary.langid = ".$hl{'langid'}." order by value");
    unshift @$rows, ['',''];

    # $value = make_select($rows,$field,$value);
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value
    } );

    return $value;
}


sub format_as_stat_subtotal {
 my ($value,$call,$field,$res,$hash) = @_;

 my @values = split(',', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'subtotal_list_values'});

 my $rows;
 for my $value(@values){
	 push @$rows, [ $value,
	                $atoms->{$call->{'class'}}->{$call->{'name'}}->{'subtotal_value_'.$value}
								];
 }

# unshift @$rows, ['',$atoms->{$call->{'class'}}->{$call->{'name'}}->{.'_dropdown_empty'}];

    # $value = make_select($rows,$field,$value, 'class="smallform"');
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => 'class="smallform"'
    } );

    return $value
}

sub format_as_year
{
 my ($value,$call,$field,$res,$hash) = @_;
 my @time = localtime(time);
 my $year = 1900 + $time[5];
 my $years_ago = 5;

 # additional several years
 if ($call->{'call_params'}->{'add_more_years'}) {
	 $year += $call->{'call_params'}->{'add_more_years'};
	 $years_ago += $call->{'call_params'}->{'add_more_years'};
 }
 my $rows = [];
 $year=$year*1;
 if($iatoms->{$call->{'name'}}->{$field.'_year_plus'}){
 	 my $year_plus=$year+$iatoms->{$call->{'name'}}->{$field.'_year_plus'};
 	$year_plus=$year_plus*1;
	 for(my $i = $year; $i <= $year_plus; $i++){
	 	 push @$rows, [$year + ($i-$year), $year + ($i-$year)];
	 }
 }

 for(my $i = 0; $i < $years_ago; $i++){
  push @$rows, [$year - $i, $year - $i];
 }

 unshift @$rows, ['',''];

    # $value = make_select($rows, $field, $value, 'class="smallform"');
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => 'class="smallform"'
    } );

    return $value;
}

sub format_as_month
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $rows = [];
 for(my $i = 1; $i <= 12; $i++){
  push @$rows, [$i, sprintf("%02d", $i)];
 }

 unshift @$rows, ['',''];

    # $value = make_select($rows, $field, $value, 'class="smallform"');
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => 'class="smallform"'
    } );

    return $value;
}

sub format_as_day
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $rows = [];
 for(my $i = 1; $i <= 31; $i++){
  push @$rows, [$i, sprintf("%02d", $i)];
 }
 unshift @$rows, ['',''];

    # $value = make_select($rows, $field, $value, 'class="smallform"');
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => 'class="smallform"'
    } );

 return $value;
}


sub format_as_cutted_name
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $limit = 40;

 if(length($value) > $limit){
  $value = substr($value,0,40);
	$value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cutted_format'},
									 {'value' => $value });
 }

 return $value;
}

sub format_as_url
{
 my ($value,$call,$field,$res,$hash) = @_;
 if($value){
  return "<a href=\"$value\">$value</a>";
 }

 return $value;
}

sub format_as_warranty_info
{
 my ($value,$call,$field,$res,$hash) = @_;
 if($value){
#  log_printf($value.'!');
  return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'warranty'},
									{ 'warranty_info' => $value });
 }

 return $value;

}


sub format_as_yes_no
{
 my ($value,$call,$field,$res,$hash) = @_;

	 my $rows = [
						 ['Y', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'option_Y'}],
						 ['N', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'option_N'}]
						  ];
	 unshift @$rows, ['',''];
	 # $value = make_select($rows,$field,$value);
	 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
 return $value;
}


sub format_as_topseller
{
 my ($value,$call,$field,$res,$hash) = @_;

	 my $rows = [
						 ['Y', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_Y'}],
						 ['N', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_N'}]
						  ];
	 unshift @$rows, ['',''];
	 # $value = make_select($rows,$field,$value);
	 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
 return $value;
}



sub format_as_publish {
	my ($value,$call,$field,$res,$hash) = @_;

	if ($USER->{'user_group'} eq 'superuser') {
		my $rows = [
								 ['A', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_A'}],
								 ['Y', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_Y'}],
								 ['N', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_N'}]
								 ];
		unshift @$rows, ['',''];
		# $value = make_select($rows,$field,$value);
		$value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
	}
	else {
		if (!$value) {
			$value = 'N';
		}
		$value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'publish_'.$value};
	}

	return $value;
} # sub format_as_publish

sub format_as_public {
	my ($value,$call,$field,$res,$hash) = @_;

	if ($USER->{'user_group'} eq 'superuser') {
		my $rows = [
								 ['L', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'public_L'}],
								 ['Y', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'public_Y'}]
								 ];
		unshift @$rows, ['',''];
		# $value = make_select($rows,$field,$value);
		$value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
	}
	else {
		if (!$value) {
			$value = 'Y';
		}
		$value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'public_'.$value};
	}

	return $value;
} # sub format_as_public


sub format_as_low_pic {
 my ($value,$call,$field,$res,$hash) = @_;
 my $thumb_pic=$hash->{$iatoms->{$call->{'name'}}->{$field.'_thumb_pic'}};
 if ($value and $thumb_pic) {
	 $value =~ s/^http:\/\//https:\/\// if $atom_html::ssl; # SSL support
	 $thumb_pic=~ s/^http:\/\//https:\/\// if $atom_html::ssl; # SSL support
	 $value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'low_pic_format'}, {'value' => $value,'thumb_value'=>$thumb_pic}); 	 	 
 }elsif($value){
	 $value =~ s/^http:\/\//https:\/\// if $atom_html::ssl; # SSL support
	 $value = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'low_pic_format'}, {'value' => $value}); 	
 }

 return $value;
}

sub format_as_ssl_url {
 my ($value,$call,$field,$res,$hash) = @_;

 if ($value) {
	 $value =~ s/^http:\/\//https:\/\// if $atom_html::ssl; # SSL support
 }

 return $value;
} # sub format_as_ssl_url

sub format_as_new_catid
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $data = do_query("select count(*) from category where pcatid = $value");
 if($data->[0][0] > 0 ){
   $hash->{'new_tmpl'} = 'cats.html';
	 $hash->{'cat_func'} = 'pcatid';
 } else {
	 $hash->{'new_tmpl'} = 'cat_edit.html';
	 $hash->{'cat_func'} = 'catid';
 }

 return $value;
}

sub format_as_sv_user_id {
	my ($value,$call,$field,$res,$hash) = @_;

	my $rows;
	$value = $USER->{'user_id'} if (!$value);

	if ($USER->{'user_group'} eq 'superuser') {
		$rows = do_query("select user_id, login from users where user_group != 'shop' order by login");
		unshift @$rows, ['',''];
	}
	elsif ($USER->{'user_group'} eq 'supereditor') {
		if (do_query("select user_group from users where user_id=".str_sqlize($value))->[0][0] eq 'supplier') {
			$rows = do_query("select user_id, login from users where user_id in (".str_sqlize($value).",".str_sqlize($USER->{'user_id'}).") order by login");
		}
		else {
			$rows = do_query("select user_id, login from users where user_id in (".str_sqlize($value).") order by login");
		}
		unshift @$rows, ['',''];
	}
	else {
		$rows = do_query("select user_id, login from users where user_id = $value order by login");
	}

	# $value = make_select($rows,$field,$value);
	$value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );

	return $value;
}

sub format_as_description_langid {
	my ($value,$call,$field,$res,$hash) = @_;

  my $data = do_query("select language.langid, vocabulary.value from language, vocabulary where vocabulary.sid = language.sid and vocabulary.langid = $hl{'langid'} order by vocabulary.value");
  my $descs = do_query("select langid from product_description where product_id = $hash->{'product_id'}");
  my %dh;
	if(defined $descs && $#$descs > -1 ){
	 %dh = map { $_->[0] => 1 } @$descs;
	}
  my $new_data = [];
	for my $row(@$data){
		 if( !$dh{$row->[0]} ||
		      ( $row->[0] eq $hash->{'edit_langid'} &&
					  $call->{'class'} ne 'details'
					) ){
		 					push @$new_data, $row;
		 }
	}

  unshift @$new_data, ['',''];

	# $value = make_select($new_data, $field, $value);
	$value = make_select( { 'rows' => $new_data, 'name' => $field, 'sel' => $value } );

 return $value;
}
sub format_as_category
{
 my ($value,$call,$field,$res,$hash) = @_;
 $value = do_query("select value from vocabulary, category where vocabulary.sid = category.sid and vocabulary.langid = $hl{'langid'} and catid = $value");
 if ( defined $value->[0] ){
  return $value->[0][0];
 }
return '';
}

sub format_as_supplier
{
 my ($value,$call,$field,$res,$hash) = @_;
 $value = do_query("select value from vocabulary, supplier where vocabulary.sid = supplier.name_sid and vocabulary.langid = $hl{'langid'} and supplier_id = $value");
 if ( defined $value->[0] ){
  return $value->[0][0];
 }
return '';
}

sub format_as_tree_ajaxed {
	my ($value,$call,$field,$res,$hash) = @_;
	my ($result);

	my $query = repl_ph($iatoms->{$call->{'name'}}->{$field.'_tree_ajaxed_select'},$call->{'call_params'});

	if ($value) {
		$query .= " and catid = ".$value;
		$result = do_query($query)->[0];
	}
	else {
		$result = [0,'Select category'];
	}

	return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'category_ajax_link'},{'catid' => $result->[0], 'category_name' => $result->[1]});
}

sub format_as_tree {
	my ($value,$call,$field,$res,$hash) = @_;
	
	my $small = '';
	if($field =~m/^search_/){
		$small = ' class="smallform" ';
	}
	
	my $rows = do_query(
		repl_ph(
			$iatoms->{$call->{'name'}}->{$field.'_tree_select'},
			$call->{'call_params'}
		)
	);
	
	my ($key_i,$parent_i); # indexes
	$key_i = 0;
	$parent_i = 2;
	my $i = 0;
	
	# now got indexes found
	
	my $tmp = {};
	my $result = [];
	
	#
	# building tree structure in $tmp
	#
	
	# first pass - finding children
	
	for my $row(@$rows){
		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
		$tmp->{$row->[$key_i]}->{'data'} =  $row;
	}
	
	# this is id for root element
	my $root = 1;
	
	# second pass - finishing tree
	
	for my $id(keys %$tmp){
		if(!defined $tmp->{$id}->{'data'}&&$id != $root){
			for my $child(@{$tmp->{$id}->{'children'}}){
				push @{$tmp->{$root}->{'children'}}, $child;
			}
			delete $tmp->{$id};
		}
	}
	
	# third pass !!!
	$result = rearrange_as_tree($root,0,$tmp,1,1); # this is the new rearranged data
	
	unshift @$result, ['1',    $atoms->{$call->{'class'}}->{$call->{'name'}}->{'any_'.$field} ||
		$atoms->{$call->{'class'}}->{$call->{'name'}}->{'any_cat'}];
		
	for my $r(@$result){
		$r->[1] = ($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cat_div'} x ($r->[3]-0)).$r->[1];
	}
	
	$value = make_select( {
		'rows' => $result,
		'name' => $field,
		'sel' => $value,
		'small' => $small,
		'width' => $iatoms->{$call->{'name'}}->{$field.'_tree_width'}
	} );
	
	return $value;
}

sub format_as_tree1 {

 my ($value,$call,$field,$res,$hash) = @_;

 my $small = '';
 my $jsevents = '';
 my $field_truncate = $field;

 if($field =~m/^search_/){
  $small = ' class="smallform" ';
 }

 $jsevents = $iatoms->{$call->{'name'}}->{$field_truncate.'_tree_JavaScript'}." ".$hin{'JSEvents'};


 my $rows;

	if ( $iatoms->{$call->{'name'}}->{$field.'_tree_select'} ) {
		$rows = do_query(
			repl_ph(
				$iatoms->{$call->{'name'}}->{$field.'_tree_select'},
				$call->{'call_params'}
			)
		);
	} else {
		my ($supplier_id, $catid);
		my $langid = $call->{'call_params'}->{'langid'};
		my $product_id = $hin{'product_id'};
		if ( $product_id ) {
			my $sfc = do_query("SELECT supplier_id, catid FROM product WHERE product_id=" . $product_id)->[0];
			$supplier_id = $sfc->[0];
			$catid = $sfc->[1];
			if (
				$hin{'supplier_id'} && $supplier_id != $hin{'supplier_id'}
				|| $hin{'catid'} && $catid != $hin{'catid'}
			) { goto NOT_SYNC_DATA }
			if ( $supplier_id && $catid && $langid ) {
				$rows = do_query("SELECT pf.family_id, v.value, pf.parent_family_id FROM product_family pf JOIN vocabulary v USING(sid) WHERE pf.supplier_id=" . $supplier_id . " AND catid=" . $catid . " AND v.langid=" . $langid);
			}
		} else {
			NOT_SYNC_DATA:
			$supplier_id = $hin{'supplier_id'};
			$catid = $hin{'catid'};
			if ( $supplier_id && $catid && $langid ) {
				$rows = do_query("SELECT pf.family_id, v.value, pf.parent_family_id FROM product_family pf JOIN vocabulary v USING(sid) WHERE pf.supplier_id=" . $supplier_id . " AND catid=" . $catid . " AND v.langid=" . $langid);
			}
		}
	}

	 my ($key_i,$parent_i); # indexes
	 $key_i = 0;
	 $parent_i = 2;

	 my $i = 0;

	 # now got indexes found

	 my $tmp = {};
	 my $result = [];

	 #
	 # building tree structure in $tmp
	 #

	 # first pass - finding children

	 for my $row(@$rows){
	 		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
			$tmp->{$row->[$key_i]}->{'data'} =  $row;
	 }

	 # this is id for root element
	 my $root = 1;

	 # second pass - finishing tree

	 for my $id(keys %$tmp){
	  if(!defined $tmp->{$id}->{'data'}&&$id != $root){
#		 log_printf('!!'.$id);

		 for my $child(@{$tmp->{$id}->{'children'}}){
#		 log_printf($child);
		  push @{$tmp->{$root}->{'children'}}, $child;
		 }

		 delete $tmp->{$id};
		}
	 }

# third pass !!!
 $result = rearrange_as_tree($root,0,$tmp,1,1); # this is the new rearranged data

 unshift @$result, ['1',$atoms->{$call->{'class'}}->{$call->{'name'}}->{'any_cat'}];


 for my $r(@$result){
  $r->[1] = ($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cat_div'} x ($r->[3]-0)).$r->[1];
 }

	# for Correct AJAX
	if ($call->{'call_params'}->{'new_id'}) {
		$field = $call->{'call_params'}->{'new_id'};
	}


=cut
    # display category ID after family name
    # for debug purposes
    if ($field eq 'family_id') {
        my ($fid, $cname);
        for my $rr (@$result) {
            # log_printf(Dumper($rr));
            $fid = $rr->[0];
            $cname = do_query("
                SELECT value
                FROM product_family
                WHERE family_id = $fid
            ")->[0]->[0];

            $rr->[1] .= " ($cname)";
        }
    }
=cut

	# add functions for family_id
	my $functions = '';
	if ( $field eq 'family_id' ) {
		$functions = ' onChange="get_series_do_next_request(this.value);update_title()" ';
	}

    $value = make_select( {
	'rows' => $result,
	'name' => $field,
	'sel' => $value,
	'small' => $small." ".$jsevents,
	'width' => $iatoms->{$call->{'name'}}->{$field_truncate.'_tree_width'},
	'functions' => $functions
    } );

 return $value;
} # format_as_tree1


sub format_as_short_tree
{

 my ($value,$call,$field,$res,$hash) = @_;
 if(!$value){ $value = '1'}

 my $rows = do_query(
  						repl_ph($iatoms->{$call->{'name'}}->{$field.'_tree_select'},
											 $call->{'call_params'})
											);

	 my ($key_i,$parent_i); # indexes
	 $key_i = 0;
	 $parent_i = 2;

	 my $i = 0;

	 # now got indexes found

	 my $tmp = {};
	 my $result = [];

	 #
	 # building tree structure in $tmp
	 #

	 # first pass - finding children

	 for my $row(@$rows){
	 		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
			$tmp->{$row->[$key_i]}->{'data'} =  $row;
	 }

	 my $cid = $value;

# marking for saving the cat itself
 	 $tmp->{$cid}->{'mark'} = 1;
# marking for saving the cat's children
	 for my $child(@{$tmp->{$cid}->{'children'}}){
 		 $tmp->{$child}->{'mark'} = 1;
	 }

# tracing path
	 while( $cid != 1 ){
		$cid = $tmp->{$cid}->{'data'}->[2];
 	  $tmp->{$cid}->{'mark'} = 1;
	 }
# removing not marked elements

	 for my $id(keys %$tmp){
	  if(!$tmp->{$id}->{'mark'}){
		 delete $tmp->{$id};
		}
	 }

	 # this is id for root element
	 my $root = 1;

	 # second pass - finishing tree

	 for my $id(keys %$tmp){
	  if(!defined $tmp->{$id}->{'data'}&&$id != $root){
#		 log_printf('!!'.$id);

		 for my $child(@{$tmp->{$id}->{'children'}}){
#		 log_printf($child);
		  push @{$tmp->{$root}->{'children'}}, $child;
		 }

		 delete $tmp->{$id};
		}
	 }

# two and half


# third pass !!!

 $result = rearrange_as_tree($root,0,$tmp,1,1); # this is the new rearranged data

 unshift @$result, ['1',$atoms->{$call->{'class'}}->{$call->{'name'}}->{'any_cat'}];


 for my $r(@$result){
  $r->[1] = ($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cat_div'} x ($r->[3]-0)).$r->[1];
 }

 # $value = make_select($result,$field,$value);
 $value = make_select( { 'rows' => $result, 'name' => $field, 'sel' => $value } );

 return $value;
}

sub format_as_user_rights
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $data = [ ['',''],
							['view','view'],
							['edit','edit'],
						];

 # $value = make_select($data, $field, $value);
 $value = make_select( { 'rows' => $data, 'name' => $field, 'sel' => $value } );

 return $value;
}

sub format_as_user_group
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $data = [ ['',''],
							['editor','editor'],
							['superuser','superuser'],
							['supereditor', 'supereditor'],
							['category_manager', 'category_manager'],
							['supplier','supplier'],
							['shop','shop'],
							['partner','partner'],
							['guest','guest'],
							['exeditor','exeditor']
						];

# log_printf($value.'!!!');
 # $value = make_select($data, $field, $value);
 $value = make_select( { 'rows' => $data, 'name' => $field, 'sel' => $value, 'small'=>' onchange="hide_user_shop_sett(this)"' } );
# log_printf($value);
 return $value;
}


sub format_as_statistic_enabled{

 my ($value,$call,$field,$res,$hash) = @_;

 my $data = [ ['',''],
              ['Yes','Yes'],
              ['No','No']
            ];

# log_printf($value.'!!!');
 # $value = make_select($data, $field, $value);
 $value = make_select( { 'rows' => $data, 'name' => $field, 'sel' => $value } );
# log_printf($value);
 return $value;

}

sub format_as_mail_class {
	my ($value,$call,$field,$res,$hash) = @_;

	my $data = [
							['',   ''],
							['DSV','Dot separated values format (DSV)'],
							['CSV','Comma separated values format (CSV)'],
							['XLS','MS Excel format (XLS)'],
							['PIV','MS Excel custom format (PIV)'],
							['PSV','CSV custom format (PSV)'],
							['GDR','Graphical report']
							];

	# $value = make_select($data, $field, $value, 'class="smallform" onChange="javascript:refreshForm();"');
	$value = make_select( {
	    'rows' => $data,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'class="smallform" onChange="javascript:refreshForm();"'
	} );
	return $value;
}

sub format_as_prod_cnt
{
 my ($value,$call,$field,$res,$hash) = @_;

 $value = do_query("select count(*) from product where user_id = $hash->{'edit_user_id'}")->[0][0];

 return int($value);
}

sub format_as_remove_control_ASCII_chars {
	my ($value,$call,$field,$res,$hash) = @_;

	if ($value) {
		my $bad_ASCII_symbols = ["\x00","\x01","\x02","\x03","\x04","\x05","\x06","\x07","\x08","\x0B","\x0C","\x0E","\x0F","\x10","\x11","\x12","\x13","\x14","\x15","\x16","\x17","\x18","\x19","\x1A","\x1B","\x1C", "\x1D","\x1E","\x1F","\x7F"];

		for my $symbol (@$bad_ASCII_symbols) {
			$value =~ s/$symbol//gs;
		}
	}

	return $value;
} # sub format_as_remove_control_ASCII_chars

sub format_as_text
{
 my ($value,$call,$field,$res,$hash) = @_;
 if($value){
   # no metatags
	 $value =~s/\&/\&amp;/sg;

	 # no tags

	 $value =~s/>/\&gt\;/sg;
	 $value =~s/</\&lt\;/sg;

	 # preventing %% to be interpreted
	 $value =~s/%/\\%/sg;

	 # replace "(&quot;)
	 $value =~ s/\"/&quot;/sg;

 }
 if($value eq '\\\\'){
 	$value='\\';
 }
 return $value;
}

sub format_as_display_text {
	my ($value,$call,$field,$res,$hash) = @_;

	if($value){
		# no metatags
		$value =~s/\&/\&amp;/sg;

		# no tags
		$value =~s/>/\&gt\;/sg;
		$value =~s/</\&lt\;/sg;

		# preventing %% to be interpreted
		$value =~s/%/\\%/sg;

		# replace "(&quot;)
		$value =~ s/\"/&quot;/sg;

		# replace \n to <br>
#		$value =~ s/\n/<br>/sg;
		$value =~ s/\n/<font color="#AAAAAA">\xb6<\/font>/sg;
	}
	return $value;
}

sub format_as_checkbox {
 my ($value,$call,$field,$res,$hash) = @_;

 if($value eq 'Y'){
   $hash->{$field.'_checked'} = 'checked';
 } 
 else {
   $hash->{$field.'_checked'} = '';
 }

 return $value;
}

sub format_as_email {
 my ($value,$call,$field,$res,$hash) = @_;
 my $txt = '';

 if($txt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'email_format'}){
  $value = &repl_ph($txt, $hash);
 }

 return $value;
}

sub format_as_date {
 my ($value,$call,$field,$res,$hash) = @_;
 if(!$value){ return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'default_date'} || ''};
 if($value ne int($value)){ return $value}

 use POSIX qw (strftime);

 $value = strftime($atoms->{$call->{'class'}}->{$call->{'name'}}->{'date_format'},localtime($value));

 return $value;
}


sub format_as_date_yyyy_dd_mm_hh_ss (){
	my ( $value,$call,$field,$res,$hash ) = @_;
	if(!$value){ return ''};
#	if($value ne int($value)){ return $value}

use POSIX qw (strftime);
	my $time_stamp = do_query ("select unix_timestamp('".$value."')")->[0][0];
	$value = strftime($atoms->{$call->{'class'}}->{$call->{'name'}}->{'date_format'} || "%Y-%d-%m %H:%M",localtime($time_stamp));
	return $value;
}

sub format_as_date_three_dropdowns {
	my ($value,$call,$field,$res,$hash) = @_;

	use POSIX qw (strftime);

	my ($year, $month, $day) = split( / /, strftime("%Y %m %d",localtime($value)) );
	$day = int($day);
	$month = int($month);

	log_printf($day." ".$month." ".$year);

#	$day = 1 unless $day;
#	$month = 1 unless $month;
#	$year = 1 unless $year;

	$call->{'call_params'}->{'add_more_years'} = 2; # add more 2 years

	return format_as_day($day,$call,$field."_day",$res,$hash) . format_as_month($month,$call,$field."_month",$res,$hash) . format_as_year($year,$call,$field."_year",$res,$hash);
} # format_as_date_three_dropdowns

sub format_as_float {
 my ($value,$call,$field,$res,$hash) = @_;
 return sprintf("%.2f",$value);
}

sub format_as_dropdown_ajaxed {
 my ($value,$call,$field,$res,$hash) = @_;
 my ($result);

 my $query =  repl_ph($iatoms->{$call->{'name'}}->{$field.'_dropdown_ajaxed_select'},$call->{'call_params'});
 if ($value) {
	 $query =~ s/from supplier(\s\w\s)?/from supplier $1 where supplier_id = $value/s;
	 $result = do_query($query)->[0];
 }
 else {
	 $result = [0,'<span style="color:red">Select brand</span>'];
 }

 my $res = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_ajax_link'},{'supplier_id' => $result->[0],'map_supplier_id'=>$result->[0], 'supplier_name' => $result->[1]});
 return $res;
}

sub format_as_dropdown {
	my ($value,$call,$field,$res,$hash) = @_;
	my $small = '';
	my $jsevents = '';
	my $field_truncate = $field;

	if (($field =~ /^search_/) || ($field =~ /^request_/)) {
		$small = ' class="smallform" ';
	}
	if($iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_JavaScript'}){
		$jsevents = $iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_JavaScript'};		
	}elsif($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_dropdown_JavaScript'}){
		$jsevents = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_dropdown_JavaScript'};
	}
	$jsevents.=" ".$hin{'JSEvents'};
	if ($field =~ /_rotate_/) {
		$field_truncate =~ s/^(.*)_\d+$/$1/;
	}

	my $query =  repl_ph($iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_select'},$call->{'call_params'});
	if (($USER->{'user_group'} eq "supplier") &&(($field eq "search_supplier_id") || ($field eq "supplier_id") )) {
		$query =~ s/from supplier(\s\w\s)?/from supplier $1 where user_id = $USER->{'user_id'}/s;
	}
	my $rows;
	if ($as_dropdown_query ne $query) {
		$rows = do_query($query);
		# log_printf(Dumper($rows));
		@$as_dropdown_rows = @$rows;
		$as_dropdown_query = $query;
	}
	else {
		@$rows = @$as_dropdown_rows;
	}
	if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_dropdown_empty'} ne 'UNDEF') {
		unshift @$rows, [$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_dropdown_empty_key'},
										 $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_dropdown_empty'}];
	}

	# for complaints
	if ($field eq "search_userid") {
		my $get_cur_login = do_query("select login from users where user_id = $USER->{'user_id'}");
		my %h = map{$_->[0] => $_->[1];} @$rows;
		if (!exists $h{$USER->{'user_id'}}) {
			unshift @$rows, [$USER->{'user_id'}, $get_cur_login->[0][0]];
		}
		if (!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')) {
			$value = $USER->{'user_id'};
		}
		@$rows = sort{$a <=> $b} @$rows;
	}
	if (!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')) {
		if ($field eq "search_status_id") {
			$value = "1";
		}
	}
	if ($field eq "search_uname") {
		$field = "uname";
	}

	# for Correct AJAX
	if ($call->{'call_params'}->{'new_id'}) {
		$field = $call->{'call_params'}->{'new_id'};
	}


	# allow custom for certain atom and field
	my $allow_custom = 0;
	if ($iatoms->{$call->{'name'}}->{$field.'_dropdown_new_value_also'}) {
	    $allow_custom = 1;
	}

	# add functions for supplier_id
	my $functions = '';
	if ($field eq 'supplier_id') {
	    $functions = ' onChange="get_family_do_next_request();update_title();" ';
	}

	# $value = make_select($rows,$field,$value,$small." ".$jsevents,$iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_width'});
	$value = make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => $small." ".$jsevents,
	    'width' => $iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_width'},
	    # 'allow_custom' => $allow_custom,
	    # Custom values was disabled
	    'functions' => $functions,
	} );	
	return $value;
}

sub format_as_dropdown_cached{
	my ($value,$call,$field,$res,$hash) = @_;
	my $field_truncate=$field;
	if ($field =~ /_rotate_/) {
		$field_truncate =~ s/^(.*)_\d+$/$1/;
	}	
	my $jsevents = $iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_JavaScript'}." ".$hin{'JSEvents'};
	my $query = repl_ph($iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_select'},$call->{'call_params'});
	my $rows=[];
	#get the value from cache or save it to cache
	if(ref($iatoms->{$call->{'name'}}->{$field_truncate.'_format_as_dropdown_cache'}) eq 'ARRAY'){
		$rows=$iatoms->{$call->{'name'}}->{$field_truncate.'_format_as_dropdown_cache'};		
	}else{
		$rows = do_query($query);
		$iatoms->{$call->{'name'}}->{$field_truncate.'_format_as_dropdown_cache'}=$rows;
	}
	$value = make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => $jsevents,
	    'width' => $iatoms->{$call->{'name'}}->{$field_truncate.'_dropdown_width'},	    
	} );
		
}

sub format_as_dropdown_name {
	my ($value,$call,$field,$res,$hash) = @_;

	my $choose_another = '...choose another ';

	my $query = repl_ph($iatoms->{$call->{'name'}}->{$field.'_dropdown_name_select'},$call->{'call_params'});
	my $rows = do_query($query);

	if ($iatoms->{$call->{'name'}}->{$field.'_dropdown_name_prefill_sub'}) {
		unless ($iatoms->{$call->{'name'}}->{$field.'_dropdown_name_prefill_if_empty'} eq 'Y') {
			log_printf("Completion sub ".$iatoms->{$call->{'name'}}->{$field.'_dropdown_name_prefill_sub'}." started...");
			no strict;
			eval { &{$iatoms->{$call->{'name'}}->{$field.'_dropdown_name_prefill_sub'}} };
			use strict;
			log_printf("Completion sub ".$iatoms->{$call->{'name'}}->{$field.'_dropdown_name_prefill_sub'}." finished...");
		}
	}

	if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'} ne 'UNDEF') {
		unshift @$rows, ['', $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_name_empty'}];
	}

	my $haveItInTheList = 0;
	for (@$rows) {
		if ($_->[1] eq $value) {
			$haveItInTheList = 1;
			last;
		}
	}

	unless ($haveItInTheList) {
		push @$rows, [$value, $value ];
	}

	if ($iatoms->{$call->{'name'}}->{$field.'_dropdown_name_new_value_also'}) {
		push @$rows, ['choose_custom_'.$field, $choose_another.$field ];
	}

	# $value = make_select($rows,$field,$value,undef,$iatoms->{$call->{'name'}}->{$field.'_dropdown_width'});
	$value = make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => undef,
	    'width' => $iatoms->{$call->{'name'}}->{$field.'_dropdown_width'}
	} );

	if ($iatoms->{$call->{'name'}}->{$field.'_dropdown_name_new_value_also'}) {
		# add onChange event & add the substitution
		$value .= '
<script type="text/javascript">
<!--
        document.getElementById("'.$field.'").addEventListener(\'change\',function() {
if (document.getElementById("'.$field.'").value == "choose_custom_'.$field.'") {
document.getElementById("'.$field.'_container").innerText = "<input type=text name='.$field.' value=\'\'>";
document.getElementById("'.$field.'_container").innerHTML = "<input type=text name='.$field.' value=\'\'>";
}
        },false);
// -->
</script>
';
	}

	return $value;
} # sub format_as_dropdown_name

sub format_as_smart_dropdown {
	my ($value,$call,$field,$res,$hash) = @_;

	my $attrs = $iatoms->{$call->{'name'}}->{$field.'_smart_dropdown_attrs'};
	my $tmpl = '';
	open TMP, "<".$atomcfg{'base_dir'}.'alib/english/smart_list_template.al';
	while (<TMP>) {
		$tmpl .= $_;
	}
	binmode TMP, ':utf8';
	close TMP;
	my $add_empty=$iatoms->{$call->{'name'}}->{$field.'_add_empty'};
	my $add_empty_value=$iatoms->{$call->{'name'}}->{$field.'_add_empty_value'};
	$add_empty_value=($add_empty_value)?$add_empty_value:'0';
	$value=($value)?$value:$add_empty_value;

	my $active_value=do_query("select v.value from vocabulary v inner join category c on c.sid=v.sid and v.langid=1 and c.catid=".$value)->[0][0];
	if($add_empty and !$active_value){# display empty string if nothing to display
		$active_value=$add_empty;
		$value=$add_empty_value;
	}
	$value = repl_ph($tmpl, {
		'name' => $field,
		'value_id' => $value,
		'attrs' => $attrs,
		'product_id' => $hin{'product_id'},
		'sessid' => $sessid,
		'value' => $active_value,
		'allow_pcat_choice' =>$iatoms->{$call->{'name'}}->{$field.'_allow_pcat_choice'},
		'add_empty' =>$add_empty,
		'add_empty_value'=>$add_empty_value
										});

	return $value;
} # sub format_as_smart_dropdown

sub format_as_multiselect {
	my ($value,$call,$field,$res,$hash) = @_;

	my $field_truncate = $field;

	my $rows = do_query(repl_ph($iatoms->{$call->{'name'}}->{$field_truncate.'_multiselect_select'},$call->{'call_params'}));

	if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_multiselect_empty'} ne 'UNDEF') {
		unshift @$rows, [$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_multiselect_empty_key'},
										 $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field_truncate.'_multiselect_empty'}];
	}

	$value = make_multiselect($rows,$field,$value,"style='height: 90px;'");

	return $value;
}

sub format_as_measure_dropdown {
	my ($value,$call,$field,$res,$hash) = @_;

	my $small = '';
	my $query = repl_ph($iatoms->{$call->{'name'}}->{$field.'_dropdown_select'},$call->{'call_params'});
	my $rows = do_query($query);
	# get measure
	$call->{'call_params'}->{'symbol'} =~ /^.*\/.*\/(.*?)::.*::.*$/;
	my $measure = $1?$1:'text';
	my $text_id = 0;
	# get selected id
	$value = 0;
	for (@$rows) {
		if (lc($_->[2]) eq lc($measure)) {
			$value = $_->[0];
			last;
		}
		if (lc($_->[1]) eq 'text') {
			$text_id = $_->[0];
		}
	}
	$value = $value?$value:$text_id;
	if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'} ne 'UNDEF'){
		unshift @$rows, [$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty_key'},
										 $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'}];
	}
	# $value = make_select($rows,$field,$value,$small,$iatoms->{$call->{'name'}}->{$field.'_dropdown_width'});
	$value = make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => $small,
	    'width' => $iatoms->{$call->{'name'}}->{$field.'_dropdown_width'}
	} );
	return $value;
} # sub format_as_measure_dropdown

sub format_as_related_dropdown
{
	my ($value,$call,$field,$res,$hash) = @_;
# log_printf ('dropdown!!!'.Dumper ( $value ) );
	my $small = '';
	if(($field =~m/^search_/)||($field =~m/^request_/)){
		$small = ' class="smallform" ';
	}
	my $query = repl_ph($iatoms->{$call->{'name'}}->{$field.'_related_dropdown_select'},$call->{'call_params'});
	if(($USER->{'user_group'} eq "supplier") &&(($field eq "search_supplier_id") || ($field eq "supplier_id") )){
		$query =~ s/from supplier(\s\w\s)?/from supplier $1 where user_id = $USER->{'user_id'}/;
	}
	my $already_formed_list = 0;
	if (($global_related_dropdown_query ne $query)&&(!$global_related_dropdown_query)) {
		$global_related_dropdown_rows = do_query($query);
		$global_related_dropdown_query = $query;
	}
	else {
		$already_formed_list = 1;
	}
	if (!$already_formed_list){
		unshift @$global_related_dropdown_rows, ['',''];
		if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_related_dropdown_owned'} ne 'UNDEF'){
			my $selected=undef;
			for my $row(@$global_related_dropdown_rows) {
				if ($row->[0]==$value) {
					$selected=$row->[1];
					last;
				}
			}
			unshift @$global_related_dropdown_rows, [$value,$selected];
		}
	}
	if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_related_dropdown_empty'} ne 'UNDEF'){
		if (!$already_formed_list){
			unshift @$global_related_dropdown_rows, ['0',$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_related_dropdown_empty'}];
		}
		$value='0';
	}
#for comaplints
	if($field eq "search_userid"){
		my $get_cur_login = do_query("select login from users where user_id = $USER->{'user_id'}");
		my %h = map{$_->[0] => $_->[1];} @$global_related_dropdown_rows;
		if(!exists $h{$USER->{'user_id'}}){
			unshift @$global_related_dropdown_rows, [$USER->{'user_id'}, $get_cur_login->[0][0]];
		}
		if(!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')){$value = $USER->{'user_id'}};
		@$global_related_dropdown_rows = sort{$a <=> $b} @$global_related_dropdown_rows;
	}
	if(!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')){
		if($field eq "search_status_id"){ $value = "1";}
	}
	if($field eq "search_uname"){ $field = "uname";}
	# $value = make_select($global_related_dropdown_rows,$field,$value, $small);
	$value = make_select( {
	    'rows' => $global_related_dropdown_rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => $small
	} );

	return $value;
}

sub format_as_fuzzy_dropdown
{
 my ($value,$call,$field,$res,$hash) = @_;
# log_printf ('dropdown!!!'.Dumper ( $value ) );
 my $small = ' id="supplier_id" onChange="javascript:show_add_new_supplier()" ';
 if(($field =~m/^search_/)||($field =~m/^request_/)){
  $small .= ' class="smallform" ';
 }
 my $query =  repl_ph($iatoms->{$call->{'name'}}->{$field.'_dropdown_select'},$call->{'call_params'});
 if(($USER->{'user_group'} eq "supplier") &&(($field eq "search_supplier_id") || ($field eq "supplier_id") )){
   $query =~ s/from supplier(\s\w\s)?/from supplier $1 where user_id = $USER->{'user_id'}/s;
 }
 my $rows = do_query($query);
 my $fuzzy; # for approx()
 push @$fuzzy, $_->[1] for (@$rows);
 my $initial_rows;
 @$initial_rows = @$rows; # for search - stay virgin
 if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'} ne 'UNDEF'){
 	unshift @$rows, ['',$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'}];
}
#fuzzy
 my $pattern = $hash->{$iatoms->{$call->{'name'}}->{$field.'_dropdown_pattern'}};
 my $weights = approx($pattern,$fuzzy);
 my $i;
 @$i = sort { $weights->[$a] <=> $weights->[$b] } (0 .. $#$initial_rows);
 for (reverse(0..9)) {
	 unshift @$rows, [$initial_rows->[$i->[$_]][0],$initial_rows->[$i->[$_]][1]];
 }
 my $selected=undef;
 unshift @$rows, ['',''];
#for comaplints
 if($field eq "search_userid"){
 my $get_cur_login = do_query("select login from users where user_id = $USER->{'user_id'}");
 my %h = map{$_->[0] => $_->[1];} @$rows;
 if(!exists $h{$USER->{'user_id'}}){
    unshift @$rows, [$USER->{'user_id'}, $get_cur_login->[0][0]];
 }
 if(!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')){$value = $USER->{'user_id'}};
   @$rows = sort{$a <=> $b} @$rows;
 }
 if(!$hin{"new_search"} && ($USER->{'user_group'} ne 'superuser')){
	if($field eq "search_status_id"){ $value = "1";}
 }
 if($field eq "search_uname"){ $field = "uname";}
 # $value = make_select($rows,$field,$value, $small);

    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => $small
    } );

 return $value;
}

sub format_row_as_tree
{
 my ($row_text,$call,$res,$key,$row) = @_;

 my $i = 1;

# while($res->[$#$res]>$i){
 my $fmt;
 if($row / 2 == int($row / 2) &&
 $atoms->{$call->{'class'}}->{$call->{'name'}}->{'tree_format_even'}){
	$fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'tree_format_even'};
 } else {
	$fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'tree_format'};
 }


  $row_text = repl_ph($fmt,
   {
	   'value' => $row_text ,
	   'tree_multi' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'tree_multi'}*$res->[$#$res]#,

	 } );

 if($res->[$#$res]>1){
 	 $row_text = repl_ph($row_text,{
																		"color_shift" => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'color_shift'}
																	});
 } else {
 	 $row_text = repl_ph($row_text,{
																		"color_shift" => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'color_no_shift'}
																	});

 }

 return $row_text;
}

sub format_as_feature_type
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $types = do_query("select type, name, pattern from feature_input_type order by feature_input_type_id asc");

 my $rows = [ ['',''] ];

 for my $type(@$types){
  push @$rows, [ $type->[0], $type->[1].($type->[2]?" (".$type->[2].")":"") ];
 }


 # $value = make_select($rows,$field,$value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );

 return $value;
}

sub format_as_access_restriction
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $types = ['0','1'];

 my $rows = [ ['',''] ];

 for my $type(@$types){
  push @$rows, [$type, $atoms->{$call->{'class'}}->{$call->{'name'}}->{'access_restriction_'.$type}];
 }


 # $value = make_select($rows,$field,$value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );

 return $value;
}

sub format_as_feature_class
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $types = ['0','1'];

 my $rows = [ ['',''] ];

 for my $type(@$types){
  push @$rows, [$type, $atoms->{$call->{'class'}}->{$call->{'name'}}->{'feature_class_'.$type}];
 }


 # $value = make_select($rows,$field,$value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );

 return $value;
}

use vars qw  ( $data_format_as_product_feature_id );
use vars qw  ( $data_format_as_product_feature_local_id );
use vars qw  ( $global_langs $old_lang $total_features $count_features );

sub format_as_product_feature_id {
  my ($value,$call,$field,$res,$hash) = @_;

	# redefine $datas if lang changed
	if ($hin{'new_rotate'}) {
		undef $data_format_as_product_feature_id;
		undef $data_format_as_product_feature_local_id;
		undef $global_langs;
		undef $total_features;
		undef $count_features;
		undef $hin{'new_rotate'};
		$hin{'tab_'.$hin{lang_tab}.'_feature_value'} = '';
	}

	$field =~m/(\d+)\Z/;
	my $rot = $1;

  my $data; my $data_local;
  unless (defined $data_format_as_product_feature_id) {
		$data = do_query("select product_feature_id, value, product_feature.category_feature_id
		 from product_feature, category_feature
		 where product_feature.product_id = $hash->{'product_id'}
		 and product_feature.category_feature_id = category_feature.category_feature_id");
		$data_format_as_product_feature_id = {};
		for my $row (@$data) {
			$data_format_as_product_feature_id->{$row->[2]} = [$row];
		}
	}

  unless (defined $data_format_as_product_feature_local_id) {
		$data_local = do_query("select product_feature_local_id, value, pfl.category_feature_id, pfl.langid
		 from product_feature_local as pfl, category_feature as cf
		 where pfl.product_id = $hash->{'product_id'}
		 and pfl.category_feature_id = cf.category_feature_id");
		$data_format_as_product_feature_local_id = {};
		for my $row (@$data_local) {
			$data_format_as_product_feature_local_id->{$row->[2]}->{$row->[3]} = [$row];
		}
	}

	my @lang_arr;
	unless (defined $global_langs) {
		$global_langs = [];
		push @$global_langs, [$hin{lang_tab}] if ($hin{lang_tab}); # used with AJAX
	}

	@lang_arr = @{$global_langs};
	push @lang_arr, [''] unless ($hin{lang_tab}); # used with nonAJAX
	@lang_arr = reverse @lang_arr;

	if (!defined $total_features) {
		$total_features = $call->{'call_params'}->{'found'};
	}

	# check for mandatory - moved to the another place.

	if ($hash->{'cat_feat_mandatory'} || $hash->{'searchable'}) {
		$hash->{'cat_feat_mandatory_star'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'mandatory_star'};
	}
	else {
		$hash->{'cat_feat_mandatory_star'} = '';
	}

	my $mandatory = 0; # mandatory || searchable

	my $template='tab_feature_value';

	my $splitter = $count_features >= int(($total_features+1)/2) ? 1 : 0;

	if ($hash->{'cat_feat_mandatory_star'}) {
		$mandatory = 1;
	}

	for my $lang (@lang_arr) {

		if ($lang->[0] ne '') {
			$data = $data_format_as_product_feature_local_id->{$hash->{'category_feature_id'}}->{$lang->[0]};
		}
		else {
			$data = $data_format_as_product_feature_id->{$hash->{'category_feature_id'}};
		}

		# use sessioned nonInserted values instead of DataBased, if it so need (2.04.2007)
		if (($hl{'tab_feature_value_error'}) && ($hl{'tab_feature_value_error'} == $hin{'lang_tab'})) {
			$hash->{$lang->[0].'_rotate_value_'.$rot} = $hl{'tab_'.$hl{'tab_feature_value_error'}.'_feature_value_error_'.$rot};
			$value = $data->[0][0] || '';
		}
		else {
			my $newvalue = defined ($data->[0][1]) ? $data->[0][1] : '';
			$hash->{$lang->[0].'_rotate_value_'.$rot} = defined($hin{$lang->[0].'_rotate_value_'.$rot}) ? $hin{$lang->[0].'_rotate_value_'.$rot} : $newvalue;
			$value = $data->[0][0] || '';
		}

		my $type 										= $hash->{'type'};
		my $restricted_vals 				= $hash->{'restricted_values'};
		my $search_restricted_vals 	= $hash->{'search_restricted_values'};
		my $cat_feat_input_dropdown = $hash->{'cat_feat_input_dropdown'};
		my $pattern                 = $hash->{'pattern'};
		my $sign                    = $hash->{'sign'};

		## prepare onBlur for AJAX product feature value Allowed Value Type checking (24.01.2008)

		my $onBlur = (($lang->[0])||((!$pattern)&&(!$sign))) ? "" : repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'javascript_onBlur'}, {'function' => 'cV', 'values' => $hash->{'category_feature_id'}.",document.getElementById('".$lang->[0].'_rotate_value_'.$rot."').value"});

		if (($type eq 'textarea' || $type eq 'text') && !( $search_restricted_vals && $cat_feat_input_dropdown eq 'Y' )) {
			my $value1 = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'feature_type_'.$type.'_format'};

#	 $hash->{'_rotate_value_'.$rot} =~s/<br>/\n/gi;

			$hash->{$lang->[0].'_rotate_value_'.$rot} = str_htmlize($hash->{$lang->[0].'_rotate_value_'.$rot});
			$hash->{$lang->[0].'_rotate_value_'.$rot} = repl_ph($value1, { 'field' => $lang->[0].'_rotate_value_'.$rot,
																																			'value' => $hash->{$lang->[0].'_rotate_value_'.$rot},
																																			'javascript' => $onBlur });
		}
		elsif ($type eq 'y_n_o') {
			my $rows = [ ['',''] ];

			for my $t ('Y','N','O','U') {
				push @$rows, [$t eq 'U' ? '-' : $t, $atoms->{$call->{'class'}}->{$call->{'name'}}->{'feature_type_y_n_o_'.$t}];# if (($t ne 'U') || (!$mandatory));
			}
			$hash->{$lang->[0].'_rotate_value_'.$rot} =
			    # make_select($rows,$lang->[0].'_rotate_value_'.$rot,$hash->{$lang->[0].'_rotate_value_'.$rot},undef,200);
			    make_select( {
				'rows' => $rows,
				'name' => $lang->[0].'_rotate_value_'.$rot,
				'sel' => $hash->{$lang->[0].'_rotate_value_'.$rot},
				'small' => undef,
				'width' => 200,
				# 'allow_custom' => 1,
				# Custom values was disabled.
			    } );

		}
		elsif ($type eq 'y_n') {
			my $rows = [ ['',''] ];

			for my $type ('Y','N','U') {
				push @$rows, [$type eq 'U' ? '-' : $type, $atoms->{$call->{'class'}}->{$call->{'name'}}->{'feature_type_y_n_'.$type}];# if (($type ne 'U') || (!$mandatory));
			}
			$hash->{$lang->[0].'_rotate_value_'.$rot} =
			    # make_select($rows,$lang->[0].'_rotate_value_'.$rot,$hash->{$lang->[0].'_rotate_value_'.$rot},undef,200);
			    make_select( {
				'rows' => $rows,
				'name' => $lang->[0].'_rotate_value_'.$rot,
				'sel' => $hash->{$lang->[0].'_rotate_value_'.$rot},
				'small' => undef,
				'width' => 200,
				# 'allow_custom' => 1,
				# Custom values was disabled.
			    } );

		}elsif($type eq 'multi_dropdown'){
			my $raw_values_str=$restricted_vals;
			my $values_str=$hash->{$lang->[0].'_rotate_value_'.$rot};
			my $field=$lang->[0].'_rotate_value_'.$rot;
			my @raw_values=split(/[\n]/,$raw_values_str);
			my @values_arr=split(',',$values_str);
			my %values=map {lc($_)=>$_} @values_arr;
			my $short_length=12;
			process_atom_ilib("check_box_table");
		 	my $atoms=process_atom_lib("check_box_table");
			my $my_atom=$atoms->{'default'}->{'check_box_table'};
			my ($html,$trs_html);
			
			my $i=1;
			use POSIX 'floor';
			my $rows_count=floor(sqrt(scalar(@raw_values)));
			for my $col(@raw_values){
				$trs_html.= repl_ph($my_atom->{'td_row'},{'text'=>shortify_str($col,$short_length,'..'),
													       'value'=>$col,
													       'checked'=>(($values{lc($col)})?'checked':'')});
				if($i%$rows_count==0){
					$trs_html.=repl_ph($my_atom->{'tr_row'},{});
				}
				$i++;
			}
			for(my $j=0;$j<scalar(@values_arr);$j++){
				$values_arr[$j]=shortify_str($values_arr[$j],$short_length,'..');
			}
			my $is_left;
			if($atoms->{$call->{'class'}}->{$call->{'name'}}->{'splitter'}){
				$is_left='false';
			}else{
				$is_left='true';
			}
			my $html=repl_ph($my_atom->{'body'},{'tr_row'=>$trs_html,
												  'id'=>($rot.'0000'.$lang->[0]),
												  'short_length'=>$short_length,
												  'is_left'=>$is_left,
												  'values_joined'=>join(',',@values_arr)});

			$hash->{$lang->[0].'_rotate_value_'.$rot}=$html.'<input id="'.$rot.'0000'.$lang->[0].'_multifeature_hidden" type="hidden" name="'.$lang->[0].'_rotate_value_'.$rot.'" value="'.$hash->{$lang->[0].'_rotate_value_'.$rot}.'"/>';

		}elsif (($type eq 'dropdown') || ($search_restricted_vals && $cat_feat_input_dropdown eq 'Y')) {
			if ($search_restricted_vals && $cat_feat_input_dropdown eq 'Y') {
				$restricted_vals = $search_restricted_vals;
			}
			my @vals = split("\n", $restricted_vals);
			my $sel = [ ['',''] ];;
			my $flag = 0;

			push @vals, '-';# if (!$mandatory); # push the unspecified value here

			for my $val (@vals) {
				my $langid = $lang->[0];
				$langid = 1 if(!$langid);
				my $display = $val;

				# fix the unspecified value
				$display = 'Unspecified' if $display eq '-';

#				my $local_val = do_query("select value from feature_values_vocabulary where langid=$langid and key_value=".str_sqlize($val))->[0][0];
#				if ($local_val ne '') { $display = $local_val; }
#				if (length($display) > 20) {
#					$display = substr($display, 0, 20).'...';
#				}

#				log_printf("DV: `".$hash->{$lang->[0].'_rotate_value_'.$rot}."` `".$val."`");

				if ($hash->{$lang->[0].'_rotate_value_'.$rot} eq $val) {
					$flag = 1;
				}

				$val 		 = str_htmlize($val);
				$display = str_htmlize($display);

				push @$sel, [$val, $display];
			}

			if ((!$flag) && ($hash->{$lang->[0].'_rotate_value_'.$rot} ne '')) {
				push @$sel, [ str_htmlize($hash->{$lang->[0].'_rotate_value_'.$rot}),
											str_htmlize($hash->{$lang->[0].'_rotate_value_'.$rot}) ];
			}
			$hash->{$lang->[0].'_rotate_value_'.$rot} =
			    make_select( {
				'rows' => $sel,
				'name' => $lang->[0].'_rotate_value_'.$rot,
				'sel' => $hash->{$lang->[0].'_rotate_value_'.$rot},
				'small' => undef,
				'width' => 200,
				# 'allow_custom' => 1,
				# Custom values was disabled.
			    } );
		}else {
			my $value1 = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'feature_type_text_format'};
			$hash->{$lang->[0].'_rotate_value_'.$rot} = str_htmlize($hash->{$lang->[0].'_rotate_value_'.$rot});
			$hash->{$lang->[0].'_rotate_value_'.$rot} = repl_ph($value1, { 'field' => $lang->[0].'_rotate_value_'.$rot,
																																			'value' =>  $hash->{$lang->[0].'_rotate_value_'.$rot},
																																			'javascript' => $onBlur });
		}

	}
#  log_printf($data->[1].'!!!'.$hash->{'_rotate_value_'.$rot});

	my $feature_value;

#	log_printf("DV: ".Dumper($global_langs));

	for my $lang (@$global_langs) {
		$hash->{$lang->[0] . '_rotate_value_' . $rot} =~ s/_rotate_value_/tab_$lang->[0]_/g;
		if ($splitter) {
			$global_group_name = '';
			$hin{'tab_' . $lang->[0] . '_feature_value'} .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{split_columns};
		}
		$template = $hash->{'type'} eq 'textarea' ? 'tab_feature_value_textarea' : 'tab_feature_value';

		my $row = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{$template},
											 {
												 'tab_feature_value_groups' =>
													 (($hash->{group_name} ne $global_group_name) || ($global_class != $hash->{class})) ?
													 repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{tab_feature_value_group}, { 'group_name' => $hash->{'group_name'} } ) :
													 "",
													'feature_name' => $hash->{'cat_feat_mandatory_star'} . $hash->{feature_name},
													'feature_name_value' => str_htmlize($hash->{'cat_feat_mandatory_star'} . $hash->{feature_name}),
													'feature_value' => $hash->{$lang->[0] . '_rotate_value_' . $rot},
													'sign' => $hash->{sign},
													'mandatory_name' => "tab_feature_value_mandatory_" . $rot,
													'mandatory_value' => $mandatory,
													'name' => "tab_feature_mandatory_name_" . $rot,
													'name_value' => str_sqlize($hash->{feature_name})}
			);

#		log_printf("DV: " . ( (($hash->{group_name} ne $global_group_name) || ($global_class != $hash->{class})) ? "Yes" : "No" ));

		$hin{'tab_'.$lang->[0].'_feature_value'} .= $row;
		delete $hash->{$lang->[0].'_rotate_value_'.$rot};
	}

#	log_printf("DV: " . $hash->{group_name}." ne ". $global_group_name." || ".$global_class." != ".$hash->{class} . " (".((($hash->{group_name} ne $global_group_name) || ($global_class != $hash->{class})) ? "Yes" : "No" ).")");

	$global_group_name = $hash->{group_name};
	$global_class = $hash->{class};

	if ($splitter) {
		$count_features = 0;
	}
	$count_features++;

#	log_printf($value);
	return $value;
} # format_as_product_feature_id


sub format_as_product_description_id
{
  my ($value,$call,$field,$res,$hash) = @_;

	my $data = do_query("select product_description_id, name from product_description where product_id = $hash->{'product_id'} and langid = $hash->{'edit_langid'}");

	if(defined $data->[0]){
	 $value = $data->[0][0];
	 $hash->{'name'} = str_htmlize($data->[0][1]);
	} else {
	 $hash->{'name'} = '';
	 $value = '';

	}

	return $value;
}

use vars qw ($cache);

sub format_as_trace_categories
{
 my ($value,$call,$field,$res,$hash) = @_;
 if(!$value){ $value = '1'}

   my $rows;
	 if(!defined $cache->{'data_'.$field.'_tree_select'}){
		 $rows = do_query(
  						repl_ph($iatoms->{$call->{'name'}}->{$field.'_tree_select'},
											 $call->{'call_params'})
											);
		 $cache->{'data_'.$field.'_tree_select'} = $rows;
	 } else {
	  $rows = $cache->{'data_'.$field.'_tree_select'};
	 }


	 my ($key_i,$parent_i); # indexes
	 $key_i = 0;
	 $parent_i = 2;

	 my $i = 0;

	 # now got indexes found

	 my $tmp = {};
	 my $result = [];

	 #
	 # building tree structure in $tmp
	 #

	 # first pass - finding children

	 for my $row(@$rows){
	 		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
			$tmp->{$row->[$key_i]}->{'data'} =  $row;
	 }

	 my $cid = $value;

# marking for saving the cat itself
 	 $tmp->{$cid}->{'mark'} = 1;

# tracing path
	 while( $cid != 1 && $cid){
		$cid = $tmp->{$cid}->{'data'}->[2];
 	  $tmp->{$cid}->{'mark'} = 1;
	 }
	 if(!$cid){
	  log_printf("Can't trace path to $value!!!");
	 }

# removing not marked elements
	 for my $id(keys %$tmp){
	  if(!$tmp->{$id}->{'mark'}){
		 delete $tmp->{$id};
		}
	 }

	 # this is id for root element
	 my $root = 1;

	 # second pass - finishing tree

	 for my $id(keys %$tmp){
	  if(!defined $tmp->{$id}->{'data'}&&$id != $root){
		 for my $child(@{$tmp->{$id}->{'children'}}){
		  push @{$tmp->{$root}->{'children'}}, $child;
		 }

		 delete $tmp->{$id};
		}
	 }

# two and half


# third pass !!!

 $result = rearrange_as_tree($root,0,$tmp,1,1); # this is the new rearranged data
 $value = '';

 for my $r(@$result){
	$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cat_format'},
									{
										"name" => $r->[1], "catid" => $r->[0]
									});
 }


 return $value;

}

sub format_as_trace_categories_det
{
 my ($value,$call,$field,$res,$hash) = @_;
 if(!$value){ $value = '1'}

 my $rows = do_query(
  						repl_ph($iatoms->{$call->{'name'}}->{$field.'_tree_select'},
											 $call->{'call_params'})
											);

	 my ($key_i,$parent_i); # indexes
	 $key_i = 0;
	 $parent_i = 2;

	 my $i = 0;

	 # now got indexes found

	 my $tmp = {};
	 my $result = [];

	 #
	 # building tree structure in $tmp
	 #

	 # first pass - finding children

	 for my $row(@$rows){
	 		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
			$tmp->{$row->[$key_i]}->{'data'} =  $row;
	 }

	 my $cid = $value;

# marking for saving the cat itself
 	 $tmp->{$cid}->{'mark'} = 1;

# tracing path
	 while( $cid != 1 ){
		$cid = $tmp->{$cid}->{'data'}->[2];
 	  $tmp->{$cid}->{'mark'} = 1;
	 }

# removing not marked elements
	 for my $id(keys %$tmp){
	  if(!$tmp->{$id}->{'mark'}){
		 delete $tmp->{$id};
		}
	 }

	 # this is id for root element
	 my $root = 1;

	 # second pass - finishing tree

	 for my $id(keys %$tmp){
	  if(!defined $tmp->{$id}->{'data'}&&$id != $root){
#		 log_printf('!!'.$id);

		 for my $child(@{$tmp->{$id}->{'children'}}){
#		 log_printf($child);
		  push @{$tmp->{$root}->{'children'}}, $child;
		 }

		 delete $tmp->{$id};
		}
	 }

# two and half


# third pass !!!

 $result = rearrange_as_tree($root,0,$tmp,1,1); # this is the new rearranged data

 $value = '';
 return '' if ($#$result == -1);

 my $nmbr = $#$result;
 my $pcatid =  $result->[$nmbr]->[0];

 my $data = do_query("select count(*) from category where pcatid = $pcatid");
 unless(defined $data->[0] && $data->[0][0] > 0){
	 $result->[$#$result]->[0] = $result->[$#$result-1]->[0] if ($#$result > 0);
 }


 for my $r(@$result){
	$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'cat_format'},
									{
										"name" => $r->[1], "catid" => $r->[0]
									});
 }


 return $value;

}

sub format_as_fcnt
{
 my ($value,$call,$field,$res,$hash) = @_;
 $value = 0;

 my $data = do_query("select count(*) from category_feature where catid = $hash->{'catid'}");
 if(defined $data->[0]){
  $value=$data->[0][0];
 }

 return $value;
}


sub format_as_category_feature_values
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $catid = $hash->{'catid'};
 my $product_id = $hash->{'product_id'};

 my $data = do_query("select product_feature.value, product_feature.category_feature_id from product_feature, category_feature where category_feature.catid =".str_sqlize($catid)." and product_feature.product_id = ".str_sqlize($product_id)." and category_feature.category_feature_id = product_feature.category_feature_id");

 my %data = map { $_->[1] => $_->[0] } @$data;

 my $order = $call->{'call_params'}->{'category_feature_order'};

 my $body = '';

# log_printf(Dumper($data));
# log_printf(Dumper(%data));

 for( my $i = 0; $i <= $#$order; $i++){
    $body .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'value_entry_format'},
											{ 'value' => $data{$order->[$i]}});
 }

 $value = $body;

return $value;
}

sub format_as_product_feature_name
{
    my ($value,$call,$field,$res,$hash) = @_;

    $value = str_htmlize($value);

    # log_printf(Dumper($hash));

    my $fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'product_feature_name_'.$hash->{'class'}.$hash->{'searchable'}};
    # my $fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'product_feature_name_'.$hash->{'class'}};
    return repl_ph($fmt, { 'value' => $value});
}

sub format_as_product_distributor {
	my ($value,$call,$field,$res,$hash) = @_;	
	my $array = do_query("select GROUP_CONCAT(distinct code SEPARATOR ', '), GROUP_CONCAT(distinct name SEPARATOR ', ')
from distributor
inner join distributor_product dp using (distributor_id)
where dp.product_id=".$value."
group by product_id")->[0];

	return undef unless ($array);

	my ($code, $name) = @$array;

	if (length($code)>12) {
		$code = substr($code,0,10).'...';
	}
	
	return "<nobr><abbr title='".$name."'>".$code."</abbr></nobr>";
} # sub format_as_product_distributor

sub format_as_searchable {
	my ($value,$call,$field,$res,$hash) = @_;

	if (!$value) {
		$value = 0;
	}

	my $values = ['0', '1'];
	my $rows;
	my $small = '';

	for my $value (@$values) {
		push @$rows, [
			$value,
			$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_'.$value}
		];
	}

	unshift @$rows, [ '', $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'} ];

	# $value = make_select($rows,$field,$value, $small);
	$value = make_select( {
		'rows' => $rows,
		'name' => $field,
		'sel' => $value,
		'small' => $small
												 } );

	return $value;
}

sub format_as_limit_direction {
 my ($value,$call,$field,$res,$hash) = @_;

 my $values = ['0', '1', '2', '3'];
 my $rows;
 my $small = '';
 for my $value(@$values){
	 push @$rows, [ $value,
	                $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_'.$value}
								];
 }

 unshift @$rows, ['',$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'}];

 # $value = make_select($rows,$field,$value, $small);
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => $small
    } );

 return $value;

}

sub format_as_assorted_list
{
 my ($value,$call,$field,$res,$hash) = @_;

 my @values = split(',', $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_assorted_list_values'});

 my $rows;
 my $small = 'class="smallform"';
 for my $value(@values){
	 push @$rows, [ $value,
	                $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_value_'.$value}
								];
 }

 unshift @$rows, ['',$atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_dropdown_empty'}];

 my $funk=$iatoms->{$call->{'name'}}->{$field.'_assorted_list_attrs'};

 # $value = make_select($rows,$field,$value, $small);
    $value = make_select( {
	'rows' => $rows,
	'name' => $field,
	'sel' => $value,
	'small' => $small,
	'functions'=>$funk
    } );

 return $value;

}

sub format_as_assorted_list_element {
	my ($value,$call,$field,$res,$hash) = @_;

	$value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$field.'_value_'.$value};

	return $value;
}


sub format_as_clipboard_indicator {
	my ($value,$call,$field,$res,$hash) = @_;
	if ($field =~ m/(.*)_item_marked/) {
		if ($clipboard_objects->{$1}->{$value}) {
			return 'CHECKED';
		}
	}

	return '';
}

sub format_as_ids_save_for_clipboard {
	my ($value,$call,$field,$res,$hash) = @_;
	my $user_group=$USER->{'user_group'};	
	if(($user_group ne 'superuser') && ($user_group ne 'supereditor') && ($user_group ne 'category_manager') && !$iatoms->{$call->{'name'}}->{'clipboard_hide'}){
		return ''; 
 	}else{
		my $tmp = $hin{'clipboard_saved_list'} || [];
		push @$tmp, $value;
		$hin{'clipboard_saved_list'} = $tmp;
		return '1';
	}
}

sub format_as_supplier_name {

	my ($value,$call,$field,$res,$hash) = @_;

	my $data = do_query("select name from supplier where supplier_id =$value");
	if(defined $data->[0]){
		$value=$data->[0][0];
	}

	return $value;
}

sub format_as_score {

    my ($value,$call,$field,$res,$hash) = @_;

    my $data = do_query("select score from product_interest_score where product_id =$value");
    if(defined $data->[0]){
        $value=$data->[0][0];
    }
    else{
	$value = 0;
    }

    return $value;

}

sub format_as_updated{

    my ($value,$call,$field,$res,$hash) = @_;

    if(defined $value){
    }
    else{
	$value = 0;
    }

    return $value;

}

sub format_as_not_null{

    my ($value,$call,$field,$res,$hash) = @_;

    if((!$value) or (!defined $value)){
	$value = "";
    }
    return $value;
}

sub format_as_expiration_date{

    my ($value,$call,$field,$res,$hash) = @_;

    if(!$value){
	$value = "";
    }
    else{
#	$value = localtime($value);
    }
    return $value;

}

sub format_as_subscription_level{
 my ($value,$call,$field,$res,$hash) = @_;
 my $data = [ ['',''],
                          ['0', 'None'  ],
                          ['1', 'URL'],
                          ['2', 'URL+PRF'],
                          ['4', 'Database'],
                          ['5', 'XML free'],
                          ['6', 'URL free']
            ];

 # log_printf($value.'!!!');
 # $value = make_select($data, $field, $value);
 $value = make_select( { 'rows' => $data, 'name' => $field, 'sel' => $value, 'small' => 'onChange="javascript: hide_checks();"' } );
 # log_printf($value);
 return $value;
}

sub format_as_parent_family_id{
 my ($value,$call,$field,$res,$hash) = @_;
 my $rows;
 my $resp = do_query("select pf.family_id, v.value from product_family as pf, vocabulary as v where pf.sid = v.sid and v.langid = $hl{'langid'} and pf.supplier_id=$hin{'supplier_id'} order by v.value;");
  for my $row(@$resp){
    if($row->[0] == $hin{'family_id'}){next;}
#    log_printf("1: $row->[0] 2: $row->[1]");
    push @$rows, [$row->[0], $row->[1]];
  }
 unshift @$rows, ['',''];
 # $value = make_select($rows, $field, $value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
 return $value;

}

sub format_as_family_id{
 my ($value,$call,$field,$res,$hash) = @_;
 my $rows;
 my $resp = do_query("select pf.family_id, v.value from product_family as pf, vocabulary as v where pf.sid = v.sid and v.langid=$hl{'langid'}");
  for my $row(@$resp){
#    log_printf("1: $row->[0] 2: $row->[1]");
    push @$rows, [$row->[0], $row->[1]];
  }
 unshift @$rows, ['',''];
 # $value = make_select($rows, $field, $value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
 return $value;

}

sub format_as_status_mode{
 my ($value,$call,$field,$res,$hash) = @_;
 if($value == 0){ $value = "Undescribed";}
 if($value == 1){ $value = "Described";}
    return $value;
}

sub format_as_product_requested{
    my ($value,$call,$field,$res,$hash) = @_;
    my $params = get_rating_params();
    my $req; # = do_query("select count(1) from request_product where rproduct_id = $value  and unix_timestamp() - date < $params->{'Period'}*60*60*24");
#    $value = $req->[0][0];
    return $value;
}

sub format_as_family_count{
my ($value,$call,$field,$res,$hash) = @_;
my $req = do_query("select count(1) from product_family where supplier_id = $value");
$value = $req->[0][0];
return $value;
}

sub format_as_trace_family {
	my ($value,$call,$field,$res,$hash) = @_;
	my $expr = "";
	my $f_id = $value;
	if(!$f_id){ return "";}
	my $node=do_query("SELECT left_key, right_key FROM product_family_nestedset ns JOIN product_family pf USING(family_id) WHERE ns.family_id=$f_id and ns.langid=1");
	if(!$node){ log_printf("ERROR:: nested_sets and product_family are not sync-zed");return "";}
	my $parent_tree=do_query("SELECT v.value,family_id,parent_family_id FROM `product_family` pf
							   JOIN product_family_nestedset ns USING(family_id)
							   JOIN  vocabulary v USING(sid)
							   WHERE ns.right_key>=".$node->[0][1]." and ns.left_key<=".$node->[0][0]." and ns.langid=1 and v.langid=1
							   ORDER BY level");
	if(!$parent_tree){return '';}
	#shift @$parent_tree; #remove virtual parent family_id=1
	for my $family(@$parent_tree){
		my $f_num = family_count($family->[1]);
	    if($f_num != 0){
				$expr.= "<img src=\"/img/campaign_def/arrow.gif\" width=\"9\" alt=\"\"/>&nbsp;<a class=\"linkmenu3\"  href=\"%%base_url%%;family_id=$family->[1];supplier_id=$hin{'supplier_id'};tmpl=product_families.html\">$family->[0]</a>";
	    }
	}
	#log_printf("---------->>>>>>>".Dumper($parent_tree));
	$value = $expr;
	return $value;
}

sub format_as_family_name{
my ($value,$call,$field,$res,$hash) = @_;
my $f_id = $hash->{'family_id'};
my $req = do_query("select value from vocabulary, product_family where vocabulary.sid = product_family.sid and family_id = $f_id and langid = $hl{'langid'}");
my $f_num = 0;
$f_num = family_count($f_id);
#log_printf("f_num for $f_id is $f_num");
if($f_num == 0){
    return $req->[0][0];
}
else{
    $value = "<a href=\"%%base_url%%;tmpl=product_families.html;family_id=$f_id;supplier_id=$hin{'supplier_id'}\">$req->[0][0] ($f_num)</a>";
    return $value;
}
}

sub format_as_status_name{
	my ($value,$call,$field,$res,$hash) = @_;
  if(($hash->{'status_id'} == 1) || ($hash->{'hstatus_id'} == 1)){
		if($hash->{'complaint_email'}){
	 	 return $value = "<font class=complaint_color1>$value</font>";
		}else{
	 	 return $value = "<span style='color: #FF5555'>$value</span>";
		}
	}
	if($hash->{'status_id'} == 90 || ($hash->{'hstatus_id'} == 90)){
		if($hash->{'complaint_email'}){
	 	 return $value = "<font class=complaint_color2>$value</font>";
		}else{
	 	 return $value = "<span style='color: green'>$value</span>";
		}
	}
	if($hash->{'status_id'} == 20 || ($hash->{'hstatus_id'} == 20)){
		if($hash->{'complaint_email'}){
		 return $value = "<font class=complaint_color3>$value</font>";
		}else{
		 return $value = "<span style='color: blue'>$value</span>";
		}
	}
	if($hash->{'complaint_email'}){
	 $value = "<font class=complaint_color4>$value</font>";
	}else{
	 $value = "<span style='color: #339966;'>$value</span>";
	}
	return $value;
}

sub format_as_status_id {
	my ($value,$call,$field,$res,$hash) = @_;
	#get editor user_id
	my $editor_id = do_query("select pc.user_id from product_complaint as pc, product_complaint_history as pch  where pc.id = $hash->{'complaint_id'}");
	# only owner and supereditor can change complaint status
	if( $USER->{'user_id'} == $editor_id->[0][0] || $USER->{'user_group'} eq 'supereditor' || $USER->{'user_group'} eq 'superuser' ) {
		my $req = do_query("select code, vocabulary.value from product_complaint_status, vocabulary where vocabulary.sid = product_complaint_status.sid and langid=1");
		my %req = map{$_->[0] => $_->[1];} @$req;
		my $get_cur_status = do_query("select complaint_status_id from product_complaint where id = $hin{'complaint_id'}");
		$value = "<select name=status_id class='smallform'>";
		for my $el(keys %req) {
			if($el == $get_cur_status->[0][0]) {
				$value.="<option value=$el selected>$req{$el}";
			} else {
				$value.="<option value=$el>$req{$el}";
			}
		}
		$value.="</select>";
	} else {
		$value = $hash->{'status_name'}."<input type=hidden name=status_id value=$value>";
	}
	return $value;
}

sub format_as_hsubject{
 my ($value,$call,$field,$res,$hash) = @_;
 if($hin{'tmpl'} eq "products_complaint_details.html"){
 my $req2 = do_query("select count(id) from product_complaint_history where id <= $hash->{'hid'} and complaint_id = $hash->{'hcomplaint_id'}");
 if(!$req2->[0][0] || $req2->[0][0] == 1){ return "Re:".$value; }
	else{ return "Re[".($req2->[0][0])."]:".$value; }
 }else{
  my $req = do_query("select count(id) from product_complaint_history where complaint_id = $hin{'complaint_id'}");
	if(!$req->[0][0] || $req->[0][0] == 1){ return "Re:".$value; }
	 else{ return  "Re[".$req->[0][0]."]".$value; }
	}
}

sub format_as_last_complaint_id{
 my ($value,$call,$field,$res,$hash) = @_;
 my $req = do_query("select id from product_complaint_history where complaint_id = $hash->{'complaint_id'} order by id desc");
 if($req->[0][0]){
#    log_printf("\nin1 $hash->{'tmpl_name'} $hash->{'complaint_id'}");
	$hash->{'tmpl_name'} = "products_complaint_last_history.html";
	$value = $req->[0][0];
	return $value;
 }else{
#   log_printf("\nin2 $hash->{'tmpl_name'} $hash->{'complaint_id'}");
	$hash->{'tmpl_name'} = "products_complaint_history.html";
	$value = $hash->{'complaint_id'};
  return $value;
 }
}

sub format_as_uname {
	my ($value,$call,$field,$res,$hash) = @_;
	my $get_usr_group = do_query("select user_group from users where user_id = ".$USER->{'user_id'});
	if( $USER->{'user_group'} eq 'supereditor' || $USER->{'user_group'} eq 'superuser' ) {
		$field = "search_uname";
		$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'} = "select user_id, login from users where user_id != 1 and user_group != 'shop' and user_group != 'exeditor' order by login";
		my $get_editor = do_query("select user_id from product_complaint where id = $hin{'complaint_id'}");
		$value = $get_editor->[0][0];
		$value = format_as_dropdown($value,$call,$field,$res,$hash);
		$field = "uname";
		$hash->{'update_button'} = "<input type=submit name=update_complain value='Update complaint' class='elem'>";
		return $value;
	} else {
		return $value;
	}
}

sub format_as_timestamp{
 my ($value,$call,$field,$res,$hash) = @_;
 # $value =~ s/^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/$3.$2.$1 $4:$5:$6/;
 my $get_date = do_query("select unix_timestamp() - unix_timestamp(date) from product_complaint where id=$value");
 my $date = $get_date->[0][0];
 my $hours = sprintf("%1.f",$date/(60*60));
 my $days = sprintf("%1.f",$date/(60*60*24));
 if($hours < 24){
#as hours
 if(($hours == 1) || ($hours < 1)){
	$hash->{'date'} = "1 hour ago";
 }else{
	$hash->{'date'} = "$hours hours ago"
 }
 }else{
  if($days == 1){
    $hash->{'date'} = "1 day ago";
  }else{
    $hash->{'date'} = "$days days ago"
  }
 }
 return $value;
}

sub format_as_values{
 my ($value,$call,$field,$res,$hash) = @_;
  if($USER->{'user_group'} eq "supplier"){
    $hout{'button_type'} = "hidden";
    $hash->{'values'} = '';
    $hash->{'values_mappings'} = '';
    $hash->{'products_categories'} = '';
    $hash->{'values2'} = '';
    $hash->{'values_mappings2'} = '';
    $hash->{'products_categories2'} = '';
 }else{
    $hash->{'values'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'values'};
    $hash->{'values_mappings'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'values_mappings'};
    $hash->{'products_categories'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'products_categories'};
    $hash->{'values2'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'values2'};
    $hash->{'values_mappings2'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'values_mappings2'};
    $hash->{'products_categories2'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'products_categories2'};
    $hout{'button_type'} = "submit";
  }
 return $value;
}

sub format_as_compl_msg{
 my ($value,$call,$field,$res,$hash) = @_;
 $value=~s/\n/<BR>/gi;
 $value =~s/\"/&quot;/gi;
 $value =~s/(\s{2,})/trace_backsp($1)/gie;
 sub trace_backsp(){
	my $str = shift;
	return '&nbsp;' x length($str);
 }
 return $value;
}

sub format_as_acknowledge
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $rows = [
  ['Y', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'acknowledge_Y'}],
  ['N', $atoms->{$call->{'class'}}->{$call->{'name'}}->{'acknowledge_N'}]
 ];
 unshift @$rows, ['',''];
 # $value = make_select($rows,$field,$value);
 $value = make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );

 return $value;
}

sub format_as_nobody_complaint {
	my($value,$call,$field,$res,$hash) = @_;
	my $product_user_id = do_query("select user_id from product where product_id = ".$hin{'product_id'});
	if($product_user_id->[0][0] != 1){ return '';}
	$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'} = "select user_id, login from users where user_id != 1 and user_group != 'shop' order by login";
	$value = format_as_dropdown(1,$call,$field,$res,$hash);
	$hin{'to_nobody'} = "<tr><td class=\"main info_bold\" width=\"50\"><b>To</b></td><td class=\"main info_bold\">$value</td></tr>";
	$hin{'to_nobody_ignore_unifiedly_processing'} = 'Yes';

	return $value;
}

sub format_as_market_state {
	my ($value,$call,$field,$res,$hash) = @_;
	unless ($hin{'product_id'}) {
		return $atoms->{'default'}->{'product'}->{'no_market_info'};
	}
	$value = "";
	my $markets = do_query("select country_id, existed, active from country_product where product_id = ".$hin{'product_id'});

	if (!$markets->[0][0]) {
		return $atoms->{'default'}->{'product'}->{'no_market_info'};
	}

	for my $market (@$markets) {
		my $state = $market->[1];
		my $active = $market->[2];
		my $country_code = do_query("select code from country where country_id = ".$market->[0])->[0][0];

		#product present in market
		if ($state && $active) {
			$value .= repl_ph($atoms->{'default'}->{'product'}->{'market_color_green'}, {'country_code' => $country_code});
		}
		#product not present in market
		if (!$state && !$active) {
			$value .=  repl_ph($atoms->{'default'}->{'product'}->{'market_color_black'}, {'country_code' => $country_code});
		}
		#product not present but presented in market
		if ($state && !$active) {
			$value .= repl_ph($atoms->{'default'}->{'product'}->{'market_color_gray'}, {'country_code' => $country_code});
		}

	}
	my $suppliers = do_query("select concat('<span style=\"color: ',if(dp.active=1,'green','gray'),';\">',d.name,'</span>')
		from distributor d
		inner join distributor_product dp using (distributor_id)
		where dp.product_id = ".$hin{'product_id'});
	my $suppliers_array;
	my $suppliers_string;
	push @$suppliers_array, $_->[0] for (@$suppliers);
	$suppliers_string = join(",&nbsp;", @$suppliers_array) if ($suppliers_array);
	return "<b>".$value."&nbsp;&nbsp;"."</b>"."(".$suppliers_string.")";
} # sub format_as_market_state

sub format_as_language_flag {
	my ($value,$call,$field,$res,$hash) = @_;

	my $product_id = $value;
	my $langs_string = do_query("select language_flag from product_interest_score where product_id = $product_id")->[0][0];
	$langs_string = dec2bin($langs_string);
	my @descriptions  = unpack("A1" x length($langs_string), $langs_string);
	$value = "";

	my $codes = do_query("select langid, short_code from language order by langid desc");

	if (length($langs_string) != ($#$codes + 1)) {
    for (my $cnt; $cnt < ($#$codes + 1) - length($langs_string); $cnt++) {
			unshift (@descriptions, 0)
		}
	}


	my $cnt = 0;
 	while ($cnt <= $#descriptions) {

   	my $markets = do_query("select country_id from country_language where langid = ".$codes->[$cnt][0]);
   	my $real_market = 0;
   	for my $market (@$markets) {
     	my $market_info = do_query("select existed, active from country_product where product_id = $product_id and country_id = ".$market->[0]);
     	if ($market_info->[0][0] && $market_info->[0][1]) {
				$real_market = 1;
				last;
			}
   	}
   	if ($descriptions[$cnt]) {
     	substr($value, 0, 0)= repl_ph($atoms->{'default'}->{'products_raiting'}->{'market_color_green'}, {'country_code' => $codes->[$cnt][1]});
		}
		else {
	  	if ($real_market) {
				substr($value, 0, 0) = repl_ph($atoms->{'default'}->{'products_raiting'}->{'market_color_gray'}, {'country_code' => $codes->[$cnt][1]});
			}
		}
	 	$cnt++;
 	}

	if (length($value) == 0) {
		$value = "none";
	}

	return $value;
}

sub format_as_internal_complaint
{
 my ($value,$call,$field,$res,$hash) = @_;
 if(defined $value){
	 if($value == 1){ $hash->{'prodid'} =  repl_ph($atoms->{'default'}->{'products_complaint'}->{'internal_color'},  {'internal' => $hash->{'prodid'}});}
	 if($value == 0){ $hash->{'prodid'} =  repl_ph($atoms->{'default'}->{'products_complaint'}->{'external_color'},  {'internal' => $hash->{'prodid'}});}
 }
 return 1;
}

sub format_as_internal_complaint_search{
 my ($value,$call,$field,$res,$hash) = @_;
 my $data = [ ['',''],
                          ['0', 'Any side'  ],
                          ['1', 'internal'],
                          ['2', 'external'  ],
            ];

 # log_printf($value.'!!!');
 # $value = make_select($data, $field, 0, "class = smallform");
    $value = make_select( {
	'rows' => $data,
	'name' => $field,
	'sel' => 0,
	'small' => "class = smallform"
    } );
 # log_printf($value);
 return $value;
}

sub format_as_mail_dispatch_groups
{
 my ($value,$call,$field,$res,$hash) = @_;

 my @groups_names = split(",", $atoms->{'default'}->{'mail_dispatch'}->{'dispatch_groups_names'});
 my @groups_values = split(",", $iatoms->{'mail_dispatch'}->{'dispatch_groups_values'});
 $value = ""; my $cnt = 0;

 my $presetted_groups = {};

	if ($hin{'id'}) {
		my $query = "SELECT to_groups FROM mail_dispatch WHERE id=".str_sqlize($hin{'id'});
		my $to_groups = do_query($query);
		$to_groups = $to_groups->[0][0];
		my @groups = split(",",$to_groups);
		for (@groups) {
			$presetted_groups->{$_} = 1;
		}
	}

 for my $group_name(@groups_names){
	 my $checked = "";
	 if ($presetted_groups->{$groups_values[$cnt]} == 1) {
		$checked = "checked";
	 }
	$value .= "<tr><td valign=middle><input type=checkbox class='smallform' name='".$groups_values[$cnt]."' $checked value=1>".$group_name."</td></tr>";
	$cnt++;
 }
 return $value;
}

sub format_as_dispatch_send_to
{
 my ($value,$call,$field,$res,$hash) = @_;
 $value = ""; my $cnt = 0;

 process_atom_ilib("mail_dispatch");
 process_atom_lib("mail_dispatch");

 my @groups_names = split(",", $atoms->{'default'}->{'mail_dispatch'}->{'dispatch_groups_names'});
 my @groups_values = split(",", $iatoms->{'mail_dispatch'}->{'dispatch_groups_values'});

 $hash->{'dispatch_persons'} = ""; $hash->{'dispatch_emails'} = "";
 for my $group_value(@groups_values){
	 if($hin{$group_value} == 1){
		 $value .= "[$groups_names[$cnt]]<br>";
		 $hin{'dispatch_send_to_values'} .= "$group_value,";

		 my $where = " 1 and ";
		 $where .= $iatoms->{'mail_dispatch'}->{'dispatch_group_'.$group_value};
		 my $persons_details = do_query("select person, user_group, email from users, contact where $where and users.pers_cid = contact.contact_id");
		 for my $person(@$persons_details){
			 $hash->{'dispatch_persons'} .= "<option value='$person->[2]'>".$person->[0]." [".$person->[1]."]"." (".$person->[2].")</option>\n";
			 $hash->{'dispatch_emails'} .= $person->[2].",";
		 }
	 }
	 $cnt++;
 }

 if($hin{'dispatch_one_address_check'} == 1){
	 my @addresses = split(",", $hin{'dispatch_one_address'});
	 for my $address(@addresses){
			 $hash->{'dispatch_persons'} .= "<option value='$address'>".$address."</option>\n";
			 $value .= "<i>".$address."</i><br>";
	 }
	 $hash->{'dispatch_emails'} .= $hin{'dispatch_one_address'};
 }
 $hash->{'dispatch_emails'} =~ s/^(.+),$/$1/;
 $value =~ s/(.+)<br>$/$1/;

 return $value;
}

sub format_as_dispatch_message {
	my ($value,$call,$field,$res,$hash) = @_;

	if ($hin{'tmpl'} eq 'mail_dispatch_in.html') {
		if ($hash->{'plain_body'}) {
			$hash->{'plain_body'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'plain_message'}, {'message' => $hash->{'plain_body'}});
		}

		if ($hash->{'html_body'}) {
			$hash->{'html_body'} = repl_ph($hash->{'html_body'}, {'person' => 'Person', 'unsubscribe' => '%%dispatch_footer%%'.' link'});
			#$hash->{'html_body'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'html_message'}, {'message' => $hash->{'html_body'}});
		}
		return $value;
	}

	if ($hin{'tmpl'} eq 'mail_dispatch_prepared.html') {
		$value = "";
		$hash->{'dispatch_plain_text'} = "";
		if ($hin{'dispatch_message_type'} eq 'html text') {
			$hash->{'dispatch_html_text'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'html_message'}, {'message' => $hin{'dispatch_message'}});
			$hash->{'dispatch_plain_text'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'plain_message'}, {'message' => html2text($hin{'dispatch_message'})});
			$hin{'dispatch_html_simple_text'} = str_htmlize($hin{'dispatch_message'});
		}
		elsif ($hin{'dispatch_message_type'} eq 'plain text') {
			$hash->{'dispatch_plain_text'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'plain_message'}, {'message' => $hin{'dispatch_message'}});
#			$hash->{'dispatch_html_text'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'html_message'}, {'message' => text2html($hin{'dispatch_message'})});
		}

		return $hash->{'dispatch_html_text'};
	}
} # sub format_as_dispatch_message

sub format_as_dispatch_status
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $statuses = {
	'0' => $atoms->{'default'}->{'mail_dispatch_log'}->{'dispatch_queued'},
	'1' => $atoms->{'default'}->{'mail_dispatch_log'}->{'dispatch_delivered'},
	'2' => $atoms->{'default'}->{'mail_dispatch_log'}->{'dispatch_in_progress'}
 };
 $value = $statuses->{$value};
 return $value;
}

sub format_as_dispatch_to_groups
{
 my ($value,$call,$field,$res,$hash) = @_;

 #if one address then group eq ''
 if($value eq ''){return "[Address]";}

 process_atom_ilib("mail_dispatch");
 process_atom_lib("mail_dispatch");
 my @groups = split(",", $value);
 my @groups_names = split(",", $atoms->{'default'}->{'mail_dispatch'}->{'dispatch_groups_names'});
 my @groups_values = split(",", $iatoms->{'mail_dispatch'}->{'dispatch_groups_values'});

 my $cnt = 0;
 $hash = {};
 for my $group_value(@groups_values){
	 $hash->{$group_value} = $groups_names[$cnt]; $cnt++;
 }
 $value = "";
 for my $group(@groups){
	 $value .= "[".$hash->{$group}."] ";
 }

 $value =~ s/(.+),/$1/;
 return $value;
}

sub format_as_dispatch_attach
{
 my ($value,$call,$field,$res,$hash) = @_;

 if($hin{'tmpl'} eq 'mail_dispatch_log.html'){
	 if($value){ $value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'dispatch_attach_yes'}};
	 if(!$value){ $value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'dispatch_attach_no'}};
 }
 if($hin{'tmpl'} eq 'mail_dispatch_in.html'){
 	 if($value) { $value = "<a href=".$atomcfg{'base_url'}."/get_dispatch_attachment.cgi?sessid=".$sessid.";id=%%id%%>".$value."</a>"};
	 if(!$value){ $value = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'dispatch_attach_no'}};
 }

 return $value;
}

sub format_as_dispatch_message_type
{
 my ($value,$call,$field,$res,$hash) = @_;

 my $message_types = {0 => 'plain text' , 1 => 'html text', 2 => 'html plain text'};
 return $message_types->{$value};
}

sub format_as_dispatch_emails
{
 my ($value,$call,$field,$res,$hash) = @_;

 my @emails = split(",", $value);
 my $cnt=0; $value='';
#build unic emails
 my $unic_hash;
 for my $email(@emails){
	 $unic_hash->{$email} = 1;
 }
 for my $email(keys %$unic_hash){
	 $value .= $email.", "; $cnt++;
	 if($cnt == 2){ $value .= "\r\n"; $cnt=0;}
 }
 $value =~ s/(.+),\s$/$1/;
 return $value
}

sub format_as_button_type
{
 my ($value,$call,$field,$res,$hash) = @_;
 my $user_group = do_query("select user_group from users where user_id = ".$USER->{'user_id'})->[0][0];
 $hash->{'search_clause'} = $call->{'call_params'}->{'search_clause'};
# lp('------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'.$iatoms->{$call->{'name'}}->{'clipboard_hide'});
 if(($user_group ne 'superuser') && ($user_group ne 'supereditor') && ($user_group ne 'category_manager') && !$iatoms->{$call->{'name'}}->{'clipboard_hide'}){
	 return "hidden";
 }else{
	 $call->{'call_params'}->{'group_action_buttons'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'group_action_buttons'};
	 return "checkbox";
 }
}

sub format_as_gallery_pics {
	my ($value,$call,$field,$res,$hash) = @_;
	
	my $gallery_pics = do_query("select id, thumb_link, size/1000, link from product_gallery where product_id = ".$value." order by id");
# $value = "<tr  width=100% colspan=3 bgcolor=white align=right>";
	$value = '';
	my $cnt = 0;
	for my $gallery_pic (@$gallery_pics) {
		$cnt ++;
		$gallery_pic->[1] =~ s/^http:\/\//https:\/\// if $atom_html::ssl; # SSL support
		$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'gallery_pic_format'},
											 {
												 'value'    => $gallery_pic->[1],
												 'pic_size' => $gallery_pic->[2] . 'Kb',
												 'id'       => $gallery_pic->[0],
												 'pic_src'  => $gallery_pic->[3]
											 });
		if ($hin{'tmpl'} eq 'product_details.html') {
			$value .= '<br>';
		}
#  if ($cnt > 7){ $cnt = 0; $value .= "</tr><tr width=100% colspan=3 bgcolor=white align=right>";}
	}
# $value .= "</tr>";
	$hin{'default_pic'} = $gallery_pics->[0][1];
	
	return $value;
}

sub format_as_multimedia_object
{
 my ($value,$call,$field,$res,$hash) = @_;
# return $value = "<a href=".$atomcfg{'base_url'}."/get_multimedia_object.cgi?sessid=".$sessid.";id=".$hash->{'object_id'}.">".$value."</a>";
 return $value = "<a href='".$value."'>".$hash->{'object_descr'}."</a>";
}

sub format_as_journal_product {

	my ($value,$call,$field,$res,$hash) = @_;

	$hash->{'product'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

    # old style feature counter
	# $hash->{'features'} = do_query("
	#    select count(product_id)
	#    from editor_journal ej
    #    where user_id = ".$hin{'editor_id'}."
    #    and product_id = ".$hash->{'product_id'}."
    #    and product_table = 'product_feature'
    #    and ".$call->{'call_params'}->{'from_date_prepared'}."
    #    and ".$call->{'call_params'}->{'to_date_prepared'}."
    #    and score = 1
    # ")->[0][0];

    # new style feature counter
    $hash->{'features'} = count_features_for_ej(
        {
            'user_id' => $hin{'editor_id'},
            'product_id' => $hash->{'product_id'},
            'from_date' => $call->{'call_params'}->{'from_date_prepared'},
            'to_date' => $call->{'call_params'}->{'to_date_prepared'},
        }
    );

	$hash->{'related'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_related' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

	$hash->{'bundled'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_bundled' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

	$hash->{'objects'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_multimedia_object' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

	$hash->{'gallery'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_gallery' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

	$hash->{'ean_codes'} = do_query("select count(product_id) from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_ean_codes' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1")->[0][0];

	my $descriptions = do_query("select product_table_id from editor_journal ej
where user_id = ".$hin{'editor_id'}." and product_id = ".$hash->{'product_id'}."
and product_table = 'product_description' and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and score = 1");

	$hash->{'descriptions'} = '';
	for my $description (@$descriptions) {
		$hash->{'descriptions'} .= do_query("select short_code from language l inner join product_description pd using (langid)
where pd.product_description_id = ".$description->[0])->[0][0]."&nbsp;";
	}

	if (length($hash->{'descriptions'}) == 0) {
		$hash->{'descriptions'} = 'none';
	}

	return 1;
} # sub format_as_journal_product

sub format_as_journal_product_summary {
	my ($value,$call,$field,$res,$hash) = @_;

	# for all
	my $for_user = " 1 ";

	# for user summary
	if ($hin{'tmpl'} eq 'editor_journal_edit.html') {
		$for_user = " user_id = ".$hin{'editor_id'};
	}
	my $join_distributor="";
	if ($call->{'call_params'}->{'search_distributor_prepared'}!=1 or $call->{'call_params'}->{'search_isactive_prepared'}!=1){
		$join_distributor=" LEFT JOIN distributor_product dp ON dp.product_id=ej.product_id ";
	}
	my $pids = do_query("select distinct ej.product_id from editor_journal ej  $join_distributor
where ".$for_user." and ".$call->{'call_params'}->{'from_date_prepared'}."
and ".$call->{'call_params'}->{'to_date_prepared'}." and ".$call->{'call_params'}->{'search_editor_prepared'}."
and ".$call->{'call_params'}->{'search_supplier_prepared'}." and ".$call->{'call_params'}->{'search_catid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_prodid_prepared'}." and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1");

	my $descr_hash;

	# old style feature summary counter
	# $hash->{'summary_features'} =
	#     do_query("
	#         select count(id) from editor_journal ej $join_distributor
    #         where ".$for_user." and product_table = 'product_feature'
    #         and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
    #         and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
    #         and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
    #         and ".$call->{'call_params'}->{'search_distributor_prepared'}."
    #         and ".$call->{'call_params'}->{'search_isactive_prepared'}."
    #         and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1
    #    ")->[0][0];

    # new style feature summary counter
    $hash->{'summary_features'} = count_features_for_ej(
        {
            'user_id' => $call->{'call_params'}->{'search_editor_prepared'},
            'from_date' => $call->{'call_params'}->{'from_date_prepared'},
            'to_date' => $call->{'call_params'}->{'to_date_prepared'},
            'search_tail' =>
                $call->{'call_params'}->{'search_supplier_prepared'} .  " AND " .
                $call->{'call_params'}->{'search_catid_prepared'} . " AND " .
                $call->{'call_params'}->{'search_prodid_prepared'} . " AND " .
                $call->{'call_params'}->{'search_distributor_prepared'} . " AND " .
                $call->{'call_params'}->{'search_isactive_prepared'} . " AND " .
                $call->{'call_params'}->{'search_changetype_prepared'}
        }
    );

	$hash->{'summary_related'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_related'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_supplier_prepared'}." and ".$call->{'call_params'}->{'search_catid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_prodid_prepared'}." and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	$hash->{'summary_bundled'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_bundled'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	$hash->{'summary_objects'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_multimedia_object'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	$hash->{'summary_gallery'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_gallery'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	$hash->{'summary_descriptions'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_description'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	$hash->{'summary_ean_codes'} = do_query("select count(ej.product_id) from editor_journal ej $join_distributor
where ".$for_user." and product_table = 'product_ean_codes'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ".$call->{'call_params'}->{'search_changetype_prepared'}." and score = 1")->[0][0];

	my $description_details = do_query("select product_table_id, count(ej.product_id), l.short_code from editor_journal ej
inner join product_description pd on ej.product_table_id = pd.product_description_id
inner join language l on pd.langid = l.langid
$join_distributor
where ".$for_user." and product_table = 'product_description'
and ".$call->{'call_params'}->{'from_date_prepared'}." and ".$call->{'call_params'}->{'to_date_prepared'}."
and ".$call->{'call_params'}->{'search_editor_prepared'}." and ".$call->{'call_params'}->{'search_supplier_prepared'}."
and ".$call->{'call_params'}->{'search_catid_prepared'}." and ".$call->{'call_params'}->{'search_prodid_prepared'}."
and ".$call->{'call_params'}->{'search_distributor_prepared'}."
and ".$call->{'call_params'}->{'search_isactive_prepared'}."
and ". $call->{'call_params'}->{'search_changetype_prepared'}." and ej.score = 1 group by pd.langid");

	for my $description_detail (@$description_details) {
		$descr_hash->{$description_detail->[2]} += $description_detail->[1];
	}

	$hash->{'summary_description_details'} = '';

	for my $key (sort keys %$descr_hash) {
		$hash->{'summary_description_details'} .= $key.": ".$descr_hash->{$key}."&nbsp;&nbsp;";
	}

	if (length($hash->{'summary_description_details'}) == 0) {
		$hash->{'summary_description_details'} = 'none';
	}

	$hash->{'summary_product'} = $#$pids + 1;

	return 1;
} # sub format_as_journal_product_summary

sub format_as_supplier_country {
	my ($value,$call,$field,$res,$hash) = @_;

#for default manager
	if(do_query("select default_manager from supplier_contact where id = ".$hash->{'id'})->[0][0] eq 'Y'){
		$hash->{'person'} = "<b>".$hash->{'person'}."</b.";
	}

	if(!$value){ return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_country_empty'};}
	$value = do_query("select value from vocabulary as v, country as c where c.country_id=".$value." and c.sid = v.sid and v.langid = 1")->[0][0];
	return $value;
}

sub format_as_supplier_contact {
	my ($value,$call,$field,$res,$hash) = @_;
	unless ($hin{'product_id'}) {
		$call->{'call_params'}->{'supplier_det_link'} = '';
		$value = '';
		return $value;
	}

	$call->{'call_params'}->{'supplier_det_link'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_det_link'};

	my $supplier_det = do_query("select p.supplier_id, s.name from product as p, supplier as s where product_id= ".$hin{'product_id'}." and p.supplier_id = s.supplier_id");
	my $supplier_id = $supplier_det->[0][0] || '0';
	$hash->{'supplier_name'} = $supplier_det->[0][1];

	my $supplier_contacts = '';
	my $countries_u = do_query("select distinct c.country_id, c.code from country c inner join supplier_url su using (country_id) where su.supplier_id = ".$supplier_id." order by c.country_id asc");
	my $countries_c = do_query("select distinct c.country_id, c.code from country c inner join contact cn on c.country_id=cn.country_id inner join users u on cn.contact_id=u.pers_cid inner join supplier_users su on u.user_id=su.user_id where su.supplier_id = ".$supplier_id." order by c.country_id asc");
	unshift @$countries_c, [0];

	my $markets = do_query("select country_id from country_product where product_id = ".$hin{'product_id'}." and existed = 1 and active = 1");
	my $markets_hash;

	for my $row(@$markets) {
		$markets_hash->{$row->[0]} = 1;
	}
	my $country_name;
	my $cntr = {};

	for my $country (@$countries_c, @$countries_u) {
		# do not duplicate
		next if $cntr->{$country->[0]};
		$cntr->{$country->[0]} = 1 if $country;

		# go on
		my $contacts = do_query("select su.supplier_users_id, c.person, c.email, c.phone, c.position from users u inner join contact c on u.pers_cid=c.contact_id inner join supplier_users su on u.user_id=su.user_id where c.country_id = ".$country->[0]." and su.supplier_id = ".$supplier_id);
		my $urls = do_query("select id, url, v.value, description from supplier_url as su, vocabulary as v, language as l where su.country_id = ".$country->[0]." and su.langid =  l.langid and v.sid = l.sid and v.langid = 1 and supplier_id = ".$supplier_id);
		next if(!$contacts->[0][0] && !$urls->[0][0]);
		if ($country->[0] != 0) {
			$country_name = do_query("select value from vocabulary as v, country as c where c.country_id = ".$country->[0]." and c.sid = v.sid and v.langid = 1")->[0][0];
		}
		else {
			$country_name = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_country_empty'};
			$country->[1] = "INTERN";
		}
		if ($markets_hash->{$country->[0]}) {
			$country->[3] = "block";
			$country->[4] = 'minus.gif';
		}
		else {
			$country->[3] = "none";
			$country->[4] = 'plus.gif';
		}
		$supplier_contacts .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_country_format'}, {
			'country' => $country_name,
			'country_code' => $country->[1],
			'display' => $country->[3],
			'img' => $country->[4] });

		$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'table_begin'};

		# select contacts
		if ($contacts->[0][0]) {
			$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_header1'};
			my $i = 1;
			for my $row (@$contacts) {
				if ($i == 1) {
					$supplier_contacts .= "<tr>"
				}
				if ($row->[2]) {
					$row->[2] = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_email'},{'email' => $row->[2]});
				}
				if ($row->[3]) {
					$row->[3] = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_tel'},{'telephone' => $row->[3]});
				}
				$supplier_contacts .=  repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_format'}, {
					'position' => $row->[4],
					'person' => $row->[1],
					'email' => $row->[2],
					'telephone' => $row->[3] });
				$i++;
				if ($i == 4) {
					$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_row_empty'};
					$i = 1;
				}
			}
			$i--;
			while ($i != 3) {
				$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_empty'};
				$i++;
			}
			$supplier_contacts .= "</tr>";
		}
		$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'table_end'};
		$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'table_begin'};

		# select urls
		if ($urls->[0][0]) {
			$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_contact_header2'};
			my $i = 1;
			for my $row (@$urls) {
				if ($i == 1) {
					$supplier_contacts .= "<tr>";
				}
				if (!($row->[1] =~ /http/)) {
					$row->[1] = "http://".$row->[1];
				}
				$supplier_contacts .=  repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_url_format'},{
					'url_link' => $row->[1],
					'url' => format_as_cutted_name($row->[1], $call,$field,$res,$hash),
					'language' => $row->[2],
					'description' => $row->[3] });
				$i++;
				if ($i == 3) {
					$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_row_empty'};
					$i = 1;
				}
			}
			$i--;
			while ($i != 2) {
				$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'supplier_url_empty'};
				$i++;
			}
			$supplier_contacts .= "</tr>";
		}
		$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'table_end'};
		$supplier_contacts .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'div_end'};

	}
	if (length($supplier_contacts) == 0) {
		$call->{'call_params'}->{'supplier_det_link'} = ''
	};
	$value = $supplier_contacts;
	return $value;
}

sub format_as_cat2family {
 my ($value,$call,$field,$res,$hash) = @_;

 $value = '';
 my $cats = do_query("select catid from category");

 for my $cat(@$cats){
	if(do_query("select product_family.family_id, vocabulary.value, parent_family_id from
							 product_family,	vocabulary where product_family.sid = vocabulary.sid and
							 vocabulary.langid = ".$hl{'langid'}."  and product_family.family_id <> 1
							 and product_family.catid = ".$cat->[0]." and supplier_id = ".$hin{'supplier_id'})->[0][0]){

 	 $iatoms->{$call->{'name'}}->{'4cat'.$cat->[0].'_tree_select'}	= "select product_family.family_id, vocabulary.value, parent_family_id from
	 product_family,	vocabulary where product_family.sid = vocabulary.sid and
	 vocabulary.langid = ".$hl{'langid'}."  and product_family.family_id <> 1
	 and product_family.catid = ".$cat->[0]." and supplier_id = ".$hin{'supplier_id'};

	 $atoms->{$call->{'class'}}->{$call->{'name'}}->{'any_4cat'.$cat->[0]} = 'Any family';
	 my $fam = format_as_tree($value,$call,'4cat'.$cat->[0],$res,$hash);
	 $fam =~ s/<select/<select style=\"display:none\" id=$cat->[0]/g;
	 $value .= $fam;
	}
 }
 $hash->{'catid'} =~ s/<select/<select $atoms->{$call->{'class'}}->{$call->{'name'}}->{'javascript_function'}/;
 return $value;
}

sub format_as_categories_families{
 my ($value,$call,$field,$res,$hash) = @_; $value = '';

 my $cats_fams = do_query("select id, catid, family_id, include_subcat, include_subfamily from supplier_contact_category_family where contact_id = ".$hin{'id'});
 for my $cat_fam(@$cats_fams){
	my $cat_name = do_query("select value from vocabulary as v, category as c where c.catid = ".$cat_fam->[1]."
	and c.sid = v.sid and v.langid = ".$hl{'langid'})->[0][0];
	my $fam_name = do_query("select value from vocabulary as v, product_family as pf where pf.family_id = ".$cat_fam->[2]."
	and pf.sid = v.sid and v.langid = ".$hl{'langid'})->[0][0];
	$call->{'call_params'}->{'cat_fam_id'} = $cat_fam->[0];
	if($cat_fam->[3] eq 'Y'){ $cat_name = "<b>".$cat_name."</b>";}
	if($cat_fam->[4] eq 'Y'){ $fam_name = "<b>".$fam_name."</b>";}
	if($fam_name eq '<b></b>'){ $fam_name = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'empty_family'};}
	if($cat_name eq '<b></b>'){ $cat_name = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'empty_category'};}
	$call->{'call_params'}->{'category'} = $cat_name;
	$call->{'call_params'}->{'family'} = $fam_name;
	$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'category_family'},
										  $call->{'call_params'});
 }

 return $value;
}

sub format_as_lang_tabs{
 my ($value,$call,$field,$res,$hash) = @_; $value = '';
 my $tabs = do_query("select value, l.langid from vocabulary as v, language as l where l.langid in($temp_lang_select) and l.sid = v.sid and v.langid = 1 order by l.langid");
 my  $international = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{lang_2}, {
	 'lang2' => "International",
	 'tab_id' => 0});
 $value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{lang2_tab},
										 {'tab_id' => 0,
										  'lang' => $international});
 my $cnt = 0;	my $i = 0;
 for my $tab(@$tabs){
	 $i++;
	 if (!($i % 8)) {
		 $value .= "</tr><tr>";
	 }
	 my $lang = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{lang_1},
											 {'lang1' => $tab->[0],
												'tab_id' => $tab->[1]});
	 $value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{lang1_tab},
											{'tab_id' => $tab->[1],
											 'lang' => $lang});

	 $cnt = ($tab->[1]>$cnt)?$tab->[1]:$cnt;
 }
 $hash->{'javascript'} = repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{javascript}, {'tabs_col' => ($cnt + 1)});
 return $value;
}

sub format_as_tab_name {
	my ($value,$call,$field,$res,$hash) = @_;
	$value = '';
	return $value unless $hin{'product_id'};

	my $names = do_query("select pn.name, l.langid from language l left join product_name pn on l.langid=pn.langid and pn.product_id=".$hin{'product_id'}." where l.langid in ($temp_lang_select)");
	for (@$names) {
		$value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'product_name'}, { 'tab_id' => $_->[1], 'tab_name' => str_htmlize($_->[0]) } );
	}

	return $value;
}

sub format_as_tab_feature_value{
 my ($value,$call,$field,$res,$hash) = @_; $value = '';
 my $langs = do_query("select langid from language where langid in ($temp_lang_select)");
 for my $lang(@$langs){
	 $value .= repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{div_format},
											{'tab_id' => $lang->[0]});
 }

 return $value;
}

sub format_as_tab_feature_value_ajaxed{
 my ($value,$call,$field,$res,$hash) = @_; $value = '';
 $hash->{div_format} = $hin{'tab_'.$hin{langid}.'_feature_value'};
 return $value;
}

sub format_as_access_repository{
 my ($value,$call,$field,$res,$hash) = @_; $value = '';

 my $langs = do_query("select langid, short_code, published from language order by langid asc");
 my $users_access = do_query("select access_repository from users where user_id = ".$hash->{edit_user_id})->[0][0] || "";
 my @reps = unpack("A1" x length($users_access ), $users_access);
 my $i=1;

 for my $lang(@$langs) {
	 my $var = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'repository_check'};
	 $var =~ s/repository_/repository_$lang->[0]/;
	 if ($lang->[2] eq 'Y') {
		 if ($reps[$i]) {
			 $var =~ s/>/checked>/;
		 }
		 $value .= $var.$lang->[1].'&nbsp;';
	 }
	 $i++;
 }

 my $var = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'repository_check'};
 $var =~ s/repository_/repository_0/;
 if ($reps[0]) {
	 $var =~ s/>/checked>/;
 }
 $value = $var."INT".'&nbsp;'.$value;
 my $access_reps = do_query("select subscription_level from users where user_id=".$USER->{user_id})->[0][0];
 if (($access_reps == 4)||($USER->{'user_group'} eq 'superuser')) {
	 $value = "<div id='access_reps' style='display:inline'>".$value."</div>";
 }
 else {
	 $value = "<div id='access_reps' style='display:none'>".$value."</div>";
 }

 return $value;
}

sub format_as_feature_value_checking_ajax {
	my ($value,$call,$field,$res,$hash) = @_;

	$hin{'lang_tab'} = $hin{'category_feature_id'}; # returns as 1st parameter

	return '#FFFFFF' if((!$hin{'value'}) || ($hin{'value'} eq '-')); # - is the unspecified value (1018179: Creating "unspecified" option)

	my ($fit_pattern, $sign) = ($hash->{'fit_pattern'}, $hash->{'sign'});

	$fit_pattern = icecat2perl_pattern($fit_pattern);

	chomp($fit_pattern);

	#log_printf("fit-pattern = ".$fit_pattern);

	my $result = '#FFDDDD';

	if ($fit_pattern) {
		if ($hin{'value'} =~ /^$fit_pattern$/) {
			$result = '#DDFFDD';
		}
	}
	else {
		$result = '#FFFFFF';
	}

	return $result;
} # sub format_as_feature_value_checking_ajax

sub format_as_icetools_auth_link {
	my ($value,$call,$field,$res,$hash) = @_;

#	my $link = $atomcfg{'icetoolshost'}."?page=login&auth=".&sha1_hex($hash->{'login'}.$hash->{'password'})."&id=".$hin{'edit_user_id'};

	my $link = $atomcfg{'icetoolshost'}."?page=login&admin_id=35&admin_auth=b3d1ea0f77660d96e1fe9e08bc22700c1dd9ad59&icecat_user_id=".$hin{'edit_user_id'};

	return ($USER->{'user_group'} eq 'superuser') && (do_query("select user_group from users where user_id=".$hin{'edit_user_id'})->[0][0] eq 'shop')
		? "<font size=\"2\"><a href=\"".$link."\" target=\"_blank\">ICEimport details</a></font>"
		: '';
} # sub format_as_icetools_auth_link

sub format_as_has_implementation {
	my ($value,$call,$field,$res,$hash) = @_;

	no strict;
	eval { &{'generic_operation_'.$value}; };
	if ($@) {
		return '<font color="red">No</font>';
	}
	else {
		return 'Yes';
	}
} # sub format_as_has_implementation

sub format_as_power_mapping_value_get_from_params {
	my ($value,$call,$field,$res,$hash) = @_;

	$hin{'value_history'} = $hin{'power_mapping_results'}->{'history'}->{$hash->{'value'}};
	$value = $hin{'power_mapping_results'}->{'new_value'}->{$hash->{'value'}};

	my $str = "
<textarea name=\"old_value_%%no%%\" style=\"display: none;\">%%old_value%%</textarea>
		<input type=\"hidden\" name=\"old_product_feature_id_%%no%%\" value=\"$hash->{'old_product_feature_id'}\">
          </td>
          <td class=\"main info_bold\">
          <textarea name=\"new_value_%%no%%\" id=\"new_value_%%no%%\" style=\"width: 300px; height: 22px; overflow: auto;".($hin{'value_history'}?" background-color: #AAFFAA;":"")."\" onFocus=\"javascript:lastid = focus_textarea('new_value_%%no%%',lastid);\">".$value."</textarea>
          ".($hin{'value_history'}?'<input type="hidden" name="new_value_mapped_%%no%%" value="1">':"")."
          </td>
          <td class=\"main info_bold\">
          ".$hin{'value_history'}."
          </td>

<script language=\"JavaScript\">
<!--
  if (lastid == '') \{
    document.getElementById('new_value_%%no%%').style.height=h3;
    //document.getElementById('new_value_%%no%%').style.overflow='auto';
    lastid = 'new_value_%%no%%';
  \}
// -->
</script>";

	return $str;
} # sub format_as_power_mapping_value_get_from_params

sub format_as_power_mapping_num_features {
	my ($value,$call,$field,$res,$hash) = @_;
	return do_query("select count(*) from feature_value_regexp where value_regexp_id=".$value)->[0][0] || "";
} # sub format_as_power_mapping_num_features

sub format_as_power_mapping_num_measures {
	my ($value,$call,$field,$res,$hash) = @_;
	return do_query("select count(*) from measure_value_regexp where value_regexp_id=".$value)->[0][0] || "";
} # sub format_as_power_mapping_num_measures

sub format_as_editor_distri {
	my ($value,$call,$field,$res,$hash) = @_;
	my $toReturn = '';
	if ($hin{'search_editor'}) {
		my $summary=do_query("SELECT d.name, count(distinct ej.product_id) cnt FROM editor_journal ej
					JOIN distributor_product dp ON ej.product_id=dp.product_id
					JOIN distributor d ON d.distributor_id=dp.distributor_id
					WHERE ej.user_id=$hin{'search_editor'}
					AND $call->{'call_params'}->{'from_date_prepared'}
					AND $call->{'call_params'}->{'to_date_prepared'}
					GROUP BY d.code order by cnt DESC");
		for my $row (@$summary) {
			$toReturn .= "<nobr>$row->[0] <b>($row->[1])</b></nobr>, ";
		}
		chop($toReturn);
		chop($toReturn);
	}
	return $toReturn;
}
sub format_as_show_all {
	my ($value,$call,$field,$res,$hash) = @_;
	if ($value>$hin{'limit'}){
		return 'Show all';
	}else{
		return '';
	}
}
sub format_as_URLDecode {
	my ($value,$call,$field,$res,$hash) = @_;
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
	$value =~ s/<!–(.|\n)*–>//g;
	return $value;
}

sub format_as_URLEncode {
	my ($value,$call,$field,$res,$hash) = @_;
	$value =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
	return $value;
}
sub format_as_str_sqlize {
	my ($value,$call,$field,$res,$hash) = @_;
	$value =~ s/\'/\\'/g;
	return $value;
}
sub format_as_restricted_user_choice{
	my ($value,$call,$field,$res,$hash) = @_;
	my $current_user=do_query("SELECT user_group,login FROM users WHERE user_id=".$hl{'user_id'}." LIMIT 1");
	if($current_user and  grep(/$current_user->[0][0]/,('editor','exeditor','shop'))){
		$atoms->{$call->{'class'}}->{$call->{'name'}}->{'search_editor_dropdown_empty'}='UNDEF';
		$iatoms->{$call->{'name'}}->{'search_editor_dropdown_select'}="select user_id, login from users where user_id=".$hl{'user_id'};
	}
	return format_as_dropdown($value,$call,$field,$res,$hash);
}
sub format_as_from_unixtime{
	my ($value,$call,$field) = @_;
	my $year=do_query("SELECT year(from_unixtime($value))")->[0][0];
	return '' if $year<=1970;
	my $stamp=$iatoms->{$call->{'name'}}->{$field.'_from_unixtime_stamp'};
	if($stamp){
		$stamp=',\''.$stamp.'\'';
	}
	return do_query("SELECT from_unixtime($value$stamp)")->[0][0];
}

sub format_as_unshown_update{
	my ($value,$call) = @_;
	my $pk=$iatoms->{$call->{'name'}}->{'unshown_update_pk'};
	my $field=$iatoms->{$call->{'name'}}->{'unshown_update_field'};
	if($hin{$pk}){
		return '<input type="hidden" name="'.$field.'" value="'.$value.'"/>'.$value;

	}else{
		return '<input type="text" size="40" name="'.$field.'" value="'.$value.'"/>';
	}
}

sub format_as_radio{
	my ($value,$call,$field) = @_;
	my $default_field=$iatoms->{$call->{'name'}}->{$field.'_radio_default_field'};
	my $attrs=$iatoms->{$call->{'name'}}->{$field.'_radio_attrs'};
	$value=~s/%%[^%]+%%//;;
	my $out_str="<table class=\"radio_block_table\">\n";
	my $radio_values=[];
	my $value_cnt=0;
	my $my_atom=$atoms->{$call->{'class'}}->{$call->{'name'}};
	for my $atom_key( keys %{$my_atom}){
		if($atom_key=~/$field[.]{0}_radio_value/ and $my_atom->{$atom_key} ){
			""=~/(.*)/;#it empties $1 varable
			$atom_key=~/([\d]+)$/;
			my $order=$1;
			if($my_atom->{$field.'_radio_text_'.$order}){
				my $tmp_value=$my_atom->{$atom_key};
				$tmp_value=~s/\\}/}/g;
				push(@$radio_values,{'order'=>$order+0,
									'value'=>unescape(trim($tmp_value)),
									'text'=>$my_atom->{$field.'_radio_text_'.$order}});
				$value_cnt++;
			}
		}
	}

	my @radio_values_sorted=sort {($a->{'order'}*1) <=> ($b->{'order'}*1)} @$radio_values;


	use POSIX qw(floor);
	my $midle=floor(((scalar(@radio_values_sorted)/2) +0.5));
	my $match_found=undef;
	for(my $i=0; $i<$midle; $i++){
		my $checked_left="";
		my $checked_right="";
		if($value){
			$checked_left=" CHECKED " if $radio_values_sorted[$i]->{'value'} eq $value;
			$checked_right=" CHECKED " if $radio_values_sorted[$i+$midle]->{'value'} eq $value;
		}else{
			$checked_left=" CHECKED " if $radio_values_sorted[$i]->{'value'} eq $default_field;
			$checked_right=" CHECKED " if $radio_values_sorted[$i+$midle]->{'value'} eq $default_field;
		}
		$match_found=1 if $checked_left or $checked_right;
		$out_str.='<tr>
		<td class="main info_bold"><input type="radio" '.$checked_left.' name="'.$field.'" value="'.$radio_values_sorted[$i]->{'value'}.'" '.$attrs.' />
			'.$radio_values_sorted[$i]->{'text'}.'
		</td>';
		if ($radio_values_sorted[$i+$midle]->{'text'}){
			$out_str.='<td class="main info_bold">
				<input type="radio" '.$checked_right.' name="'.$field.'" value="'.$radio_values_sorted[$i+$midle]->{'value'}.'" '.$attrs.' />
				'.$radio_values_sorted[$i+$midle]->{'text'}.'
			</td>
			</tr>';
		}else{
			$out_str.='</tr>';
		};
	}
	if(!$match_found){
		$out_str=~s/value="custom"/name="custom" CHECKED /gs;
	}
	$out_str.="</table>\n";
	return $out_str;
}

sub format_as_radio_buttons{
	my ($value,$call,$field) = @_;
	my $default_field=$iatoms->{$call->{'name'}}->{$field.'_radio_default_field'};
	my $attrs=$atoms->{$call->{'name'}}->{$field.'_radio_attrs'};
	$value=~s/%%[^%]+%%//;;
	my $out_str;
	my $radio_values=[];
	my $value_cnt=0;
	my $my_atom=$atoms->{$call->{'class'}}->{$call->{'name'}};
	for my $atom_key( keys %{$my_atom}){
		if($atom_key=~/$field[.]{0}_radio_value/){
			""=~/(.*)/;#it empties $1 varable
			$atom_key=~/([\d]+)$/;
			my $order=$1;
			if($my_atom->{$field.'_radio_text_'.$order}){
				my $tmp_value=$my_atom->{$atom_key};
				$tmp_value=~s/\\}/}/g;
				push(@$radio_values,{'order'=>$order+0,
									'value'=>unescape(trim($tmp_value)),
									'text'=>$my_atom->{$field.'_radio_text_'.$order}});
				$value_cnt++;
			}
		}
	}
	my @radio_values_sorted=sort {($a->{'order'}*1) <=> ($b->{'order'}*1)} @$radio_values;
	my $out_str="<table>";
	my $checked='';
	for my $radio_value(@radio_values_sorted){
		if($radio_value->{'value'} eq $value){
			$checked='checked';
		}else{
			$checked='';
		}
		$out_str.='<tr>'.repl_ph($radio_value->{'text'},
								 {'checked'=>$checked,'value'=>$radio_value->{'value'},
								  'field'=>$field,'attrs'=>$attrs}).'</tr>';
	}
	$out_str.="</table>";
	#log_printf('-------------->>>>>>>>>>>>'.Dumper($out_str));
	return $out_str;
}

sub format_as_custom_select {
	my ($value,$call,$field,$res,$hash) = @_;

	my $default_field=$iatoms->{$call->{'name'}}->{$field.'_custom_select_default'};
	$value=~s/%%[^%]+%%//;
	$value=$default_field unless($value);
	my $rows=[];
	my $my_atom=$atoms->{$call->{'class'}}->{$call->{'name'}};

	for my $atom_key( keys %{$my_atom}){
		if($atom_key=~/$field[.]{0}_custom_select_value/ and defined($my_atom->{$atom_key}) ){
			""=~/(.*)/;#it empties $1 varable
			$atom_key=~/([\d]+)$/;
			my $order=$1;
			if(defined($my_atom->{$field.'_custom_select_value_'.$order})){
				my $tmp_value=$my_atom->{$atom_key};
				$tmp_value=~s/\\}/}/g;
				push(@$rows,[unescape(trim($tmp_value)),
							$my_atom->{$field.'_custom_select_text_'.$order},
							$order+0,
							]);
			}
		}
	}
	my @rows_sorted=sort {($a->[2]*1) <=> ($b->[2]*1)} @$rows;

	my $attrs=$iatoms->{$call->{'name'}}->{$field.'_custom_select_attrs'};
	return make_select( { 'rows' => \@rows_sorted, 'name' => $field, 'sel' => $value,'functions'=>$attrs } );
} # sub format_as_system_of_measurement



sub format_as_csv_column_choice{
	my ($value,$call,$field,$res,$hash) = @_;
	return '' if(!$hash->{'feed_config_id'});
	use pricelist;
	use icecat_util;
	my $dir_files_txt=`find $atomcfg{'session_path'}$hash->{'feed_config_id'}/`;
	$dir_files_txt=~s/\Q$atomcfg{'session_path'}$hash->{'feed_config_id'}\/\E//gs;
	$dir_files_txt=~s/^[\n]+//gs;
	my @dir_files=split(/\n/,$dir_files_txt);
	my $csv_file;
	my $rows=[['','']];
	if(scalar(@dir_files)<1){
		#push(@user_errors,"Temporary directory with datapack is empty. Please download the pricelist first") if $hin{'atom_update'};
	}elsif(scalar(@dir_files)==1){
		$csv_file=$atomcfg{'session_path'}.$hash->{'feed_config_id'}.'/'.$dir_files[0];
	}elsif(scalar(@dir_files)>1 and $hash->{'user_choiced_file'}){
		$csv_file=$atomcfg{'session_path'}.$hash->{'feed_config_id'}.'/'.$hash->{'user_choiced_file'};
	}
	my $feed_type=($hash->{'feed_type'})?$hash->{'feed_type'}:$hin{'feed_type'};

	if(!( -e $csv_file)){
		#push(@user_errors,"Temporary directory with datapack is empty. Please download the pricelist first") if $hin{'atom_update'};
	}else{
		my $first_rows;
		if($feed_type eq 'csv' or $feed_type eq 'xml'){
			$first_rows=get_csv_rows($csv_file,$hash->{'delimiter'},$hash->{'newline'},$hash->{'escape'},1);
		}elsif($feed_type eq 'xls'){
			# code below looks like a hack. In fact each time we call format_as_csv_column_choice excel file will be complitely parsed again
			# so natturaly we save parsed object in some global var($iatoms in this case) and other calls may use it as without parsing
			my $excel=$iatoms->{$call->{'name'}}->{'tmp_xls_object'};
			if(!$excel){
				if(quick_checkExcel2007($csv_file)){
					use Spreadsheet::XLSX;
					$excel=Spreadsheet::XLSX->new($csv_file);
				}else{
					$excel=Spreadsheet::ParseExcel->new()->Parse($csv_file);
				}
				$iatoms->{$call->{'name'}}->{'tmp_xls_object'}=$excel;
			}
			$first_rows=get_xls_rows($csv_file,1,$excel);
		}else{
			log_printf('ERROR( sub format_as_csv_column_choice): Can\'t find out type of feed');
			return '';
		}
		if(!$first_rows or ref($first_rows) ne 'ARRAY' or ref($first_rows->[0]) ne 'ARRAY'){
			push(@user_errors,"File does not exist or delimiter is not defined. Please reupload the file" ) if (scalar(@user_errors)<1);
			return ''
		};
		my $first_row;
		$first_row=$first_rows->[0];
		for(my $i=0;$i<scalar(@$first_row);$i++){
			if(($hash->{'is_first_header'}*1)){
				push(@$rows,[$i+1,($first_row->[$i])?shortify_str($first_row->[$i],20,'...'):'<Empty> '.($i+1)]);
				#$rows->[$i][1]= if !;
			}else{
				push(@$rows,[$i+1,'Column #'.($i+1)]);
			}

		}

		#my @tmp=sort {lc($b->[1])<=>lc($a->[1])} @$rows;
		#$rows=\@tmp;
		if($hin{'feed_config_commands'} eq 'reupload_price_feed' or 1){# currently is not checked
			my $autodetect_keys=$iatoms->{$call->{'name'}}->{$field.'_autodetect_keys'};
			if(!$value or $value eq '0' and $autodetect_keys and $hash->{'is_first_header'}){# try to auto detect column
				my @field_parts=split(/,/,$autodetect_keys);

				my @candidates;
				for my $row(@$rows){
					my $a=1;
					for my $field_part(@field_parts){
						if(uc(trim($row->[1])) eq uc($field_part)){
							push(@candidates,$row->[0]);
							goto MATCH_FOUND;#full match found
						}elsif($row->[1]=~/\Q$field_part\E/i){
							push(@candidates,$row->[0]);
						}
					}
				}
				MATCH_FOUND:;
				if(scalar(@candidates)==1){
					$value=$candidates[0];
				}
			}
		}

		return make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
	}
	return '';
}

sub format_as_rand{
	my ($value,$call) = @_;
	if(!$value){
		use POSIX qw(floor);
		return floor(rand(100000000));
	}else{
		return $value;
	}
}

sub format_as_dir_choice{
	my ($value,$call,$field,$res,$hash) = @_;
	return '' if(!$hash->{'feed_config_id'} or !($hash->{'feed_url'} or $hin{'feed_file'}));

	my $dir_files_txt=`find $atomcfg{'session_path'}$hash->{'feed_config_id'}/`;
	$dir_files_txt=~s/$atomcfg{'session_path'}$hash->{'feed_config_id'}\///gs;
	$dir_files_txt=~s/^[\n]+//gs;
	my @dir_files=split(/\n/,$dir_files_txt);
	if(scalar(@dir_files)<1){
		push(@user_errors,"Temporary directory with datapack is empty. Please download the pricelist first") if !$hin{'atom_update'};
		return '';
	}elsif(scalar(@dir_files)==1){
		return '';# if there only one file it's default
	}else{
		my $rows=[];
		for my $dir_file (@dir_files){
			push(@$rows,[$dir_file,$dir_file]) if !(-d $atomcfg{'session_path'}.$hash->{'feed_config_id'}.'/'.$dir_file);
		}
		return 'Choice file in archive '.make_select( { 'rows' => $rows, 'name' => $field, 'sel' => $value } );
	}
}

sub format_as_feed_config_preview{
	my ($value,$call,$field,$res,$hash) = @_;
	use pricelist;
	my $result=get_preview_html(30,$hash);
	if(ref($result) eq 'ARRAY'){
		push(@user_errors,$result->[0]);
		return '';
	}else{
		return $result;
	}
}

sub format_as_feed_file_name{
	my ($value,$call,$field,$res,$hash) = @_;
	return '' if(!($hash->{'feed_config_id'} or $hin{'feed_config_id'}) or $hin{'feed_url'});
	my $feed_config_id;
	if(!$hash->{'feed_config_id'}){
		$feed_config_id=$hin{'feed_config_id'};
	}else{
		$feed_config_id=$hash->{'feed_config_id'};
	}

	my $dir_files_txt=`find $atomcfg{'session_path'}$feed_config_id/`;
	$dir_files_txt=~s/$atomcfg{'session_path'}$feed_config_id\///gs;
	$dir_files_txt=~s/^[\n]+//gs;
	my @dir_files=split(/\n/,$dir_files_txt);
	if(scalar(@dir_files)<1){
#		log_printf("----------->>>>>>>>>>>>>>>>format_as_feed_file_name: no files found in temporary directory $atomcfg{'session_path'}$hash->{'feed_config_id'}");
		return '';
	}elsif(scalar(@dir_files)==1){
		return $dir_files[0];# if there only one file it's default
	}elsif($hin{'user_choiced_file'}){
		return $hin{'user_choiced_file'};
	}else{
#		log_printf("----------->>>>>>>>>>>>>>>>format_as_feed_file_name: cant find out which file to parse $atomcfg{'session_path'}$hash->{'feed_config_id'}");
		return '';
	}
}

sub format_as_link_to_coverage{
	my ($value,$call,$field,$res,$hash) = @_;


	my $str='<input type="submit" value="Go to coverage" onclick="go_to_feed_coverage()"/>';
	return $str;
}



sub format_as_coverage_summary{
	my ($value,$call,$field,$res,$hash) = @_;

	return $hs{'coverage_summary'};
}


sub format_as_link_to_distri_pricelist{
	my ($value,$call,$field,$res,$hash) = @_;
	#log_printf(Dumper($hash));
	return '' if $hash->{'source_raw'} ne 'icecat' or $hash->{'code'}=~/^PRF-/;

	my $do_write_add=(defined($hash->{'distributor_pl_id'}))?'Edit settings':'Add catalog upload';
	return '<a href="%%base_url%%;tmpl=distri_prices.html;mi=%%mi%%;group_code='.$hash->{'group_code'}.';distributor_id='.$hash->{'distributor_id'}.';distributor_pl_id='.$hash->{'distributor_pl_id'}.'">'.$do_write_add.'</a>';
}


sub format_as_source_price_import{
	my ($value) = @_;
	my $map={'prf' => 'Front office', 'icecat' => 'Back office', 'iceimport' => 'ICEimport'};
	return $map->{$value};
}

sub format_as_feed_config_preview_button{
	my ($value,$call,$field,$res,$hash) = @_;

	if($hin{'feed_config_id'}){
		return '<input type="submit" value="preview" onclick="preview_feed()">';
	}else{
		return '<input type="submit" value="preview" disabled="disabled" onclick="preview_feed()">';
	}
}

sub format_as_interval_info {

    my ($value,$call,$field,$res,$hash) = @_;

    my @ints = split /\n/, $hash->{'intervals'};
    my @counts = split /\n/, $hash->{'in_each'};
    my $res;

    # update ints for sorting procedure
    for (my $i = 0 ; $i <= $#ints ; $i++ ) {
        $ints[$i] = $ints[$i] . '~' . $counts[$i];
    }

    # sort intervals, using first elem before '-'
    my @ints = sort { ($a =~ /^(.*)-/)[0] <=> ($b =~ /^(.*)-/)[0] } @ints;

    # update back
    for (my $i = 0 ; $i <= $#ints ; $i++ ) {
        $ints[$i] =~ /^(.*)~(.*)$/;
        $ints[$i] = $1;
        $counts[$i] = $2;
    }


    for (my $i = 0 ; $i < scalar @ints ; $i++ ) {
        $res .= '<tr>';

        $res .= '<td class="main info_bold">';
        $res .= $ints[$i];
        $res .= '</td>';

        $res .= '<td class="main info_bold">';
        $res .= $counts[$i];
        $res .= '</td>';

        $res .= '</tr>';
    }

    return $res;
}

sub get_vcategories {

    my $hr = shift;

    my $value = $hr->{'value'};
    my $product_id = $hr->{'product_id'};
    my $mode = $hr->{'display_mode'};
    my $is_search_oper = $hr->{'is_search_operation'};
    my $search_hash_ref = $hr->{'search_hash_ref'};

    # main SQL query
    # we need to get a virtual category list for all cases
    if (! $value) {
        # if no catid (for search_product atom)
        return '';
    }
    my $ans = do_query('SELECT name,virtual_category_id FROM virtual_category WHERE category_id = ' . $value);

    # additional queries
    # a product_id is defined only for a product_detail page
    my ($vcats_set, $check);
    if ($mode eq 'catid') {
        $vcats_set = do_query("SELECT virtual_category_id FROM virtual_category_product WHERE product_id = $product_id");

        # checker for abstract categories
        $check = do_query('SELECT ucatid FROM product INNER JOIN category USING (catid) WHERE product_id = ' . $product_id );
        if ($check->[0]->[0] =~ /00$/) {
            return '';
        }
    }

    my $output = '';
    my $checked = '';
    my $vcatid;
    my $tmp;
    my $s_checked_counter = 0;
    for (@$ans) {

        # get virtual category id for this product
        $vcatid = $_->[1];

        # make controls list
        # different output for different target atoms (different modes)
        if ($mode eq 'catid' ) {

            # switch on checkbox if present
            my $is_present = 0;
            for my $tmp (@$vcats_set) {
                if ($vcatid == $tmp->[0]) {
                    $is_present = 1;
                    last;
                }
            }

            if ($is_present) {
                $checked = 'checked';
            }
            else {
                $checked = '';
            }

            $tmp = '<input type="checkbox" value="' . $vcatid . '" id="vcat_' . $_->[0] . '" name="vcat_' .  $_->[0] . '" ' . $checked . ' >' . $_->[0] . '  ';
            $output .= '<span style="white-space: nowrap">' . $tmp . '</span> <span style="white-space: normal"> </span>';
        }
        elsif ($mode eq 'search_catid') {

            my $s_checked = '';

            if (($is_search_oper) && ($search_hash_ref->{$vcatid})) {
                $s_checked = ' checked';
                $s_checked_counter++;
            }

            $tmp = '<input type="checkbox" value="' . $vcatid . '" id="search_vcat_' . $_->[0] . '" name="search_vcat_' .  $_->[0] .
                '" onClick="update_vcats_list(this)" ' . $s_checked . ' >' . $_->[0];
            $output .= '<span style="white-space: nowrap">' . $tmp . '</span> ' . '<span style="white-space: normal"> </span>';
        }
    } # for

    # add head for search atom case
    if ($mode eq 'search_catid') {

        # add 'ANY' checkbox if vcats list not empty
        if (scalar @$ans > 0 ) {

            my $checked_all = '';
            my $display = 'none';
            if ($s_checked_counter > 0) {
                $checked_all = ' checked';
                $display = 'block';
            }

            $output = '<span id="hide_vcats" style="display: ' . $display . ';" >' . $output . '</span>';
            $output = '<span style="white-space: nowrap"><input type="checkbox" id="vcats_set" name="vcats_set" value="1" onClick="allow_any_vcat()" ' . $checked_all . ' >Specify virtual categories set</span> <span style="white-space: normal"></span>' . $output;

            # JavaScript for smart behavior was placed in product_search.al
        }
    }

    return $output;
}

sub format_as_vcategories {
    my ($value,$call,$field,$res,$hash) = @_;

    # for AJAX requests only

    # not perform any actions for non product_detail page (if not defined product_id)
    my $product_id = $call->{'call_params'}->{'product_id'};

    my $mode = $call->{'call_params'}->{'tag_id'};

    # mode for group action page should be the same as for search atom
    if ($mode eq 'search_category_list') {
        $mode = 'search_catid';
    }
    # log_printf('>>>>>>>>>>>>>>>>>>>>>> MODE = ' . $mode);

    # there are two modes for get_vcategories function
    # 1. 'catid' is a mode for product detail page
    # 2. 'search_catid' is a mode for product search atom and for group action page

    my $res = get_vcategories( {
            'value' => $value,
            'product_id' => $product_id,
            'display_mode' => $mode,
            'is_search_operation' => 0,
        } );

    # for debug purposes
    # log_printf("----------------------------------------");
    # log_printf($res);
    # log_printf("----------------------------------------");

    return $res;
}

sub format_as_virtual_categories_list {
    my ($value,$call,$field,$res,$hash) = @_;

    # simple page loading (not AJAX)

    my $product_id = $call->{'call_params'}->{'product_id'};

    my $mode;
    # for 'mode' identification purpose I use the same constants as for AJAX requests
    if ($hash->{'search_catid'}) {
        $mode = 'search_catid';
    }
    else {
        $mode = 'catid';
    }

    # get AL file
    my $attrs = $iatoms->{$call->{'name'}}->{$field.'_very_smart_dropdown_attrs'};
	my $tmpl = '';
	open TMP, "<".$atomcfg{'base_dir'}.'alib/english/very_smart_list_template.al';
	while (<TMP>) {
		$tmpl .= $_;
	}
	binmode TMP, ':utf8';
	close TMP;

    my $is_search = 0;
    my $vcats_set = {};
    if ($call->{'call_params'}->{'new_search'} eq 'Search') {
        $is_search = 1;

        # get checked list if search was performed
        while ($call->{'call_params'}->{'vcat_enable_list'} =~ /_(\d+)_/g) {
            $vcats_set->{$1} = 1;
        }
    }

	my $content = get_vcategories( {
    	    'value' => $value,
	        'product_id' => $product_id,
	        'display_mode' => $mode,
	        'is_search_operation' => $is_search,
    	    'search_hash_ref' => $vcats_set,
	    } );

	$value = repl_ph($tmpl, {
		'content_from_outside' => $content
	} );

    return $value;
}


sub format_as_short_str{
	my ($value,$call,$field,$res,$hash) = @_;
	my $size=$iatoms->{$call->{'name'}}->{'def_short_str_size'} || 15;
	my $end=$iatoms->{$call->{'name'}}->{'def_short_str_end'} || '..';
	$size=$iatoms->{$call->{'name'}}->{$field.'_short_str_size'} if $iatoms->{$call->{'name'}}->{$field.'_short_str_size'};
	if(length($value)>$size){
		return '<span title="'.$value.'">'.shortify_str($value,$size,$end).'</span>';
	}else{
		return $value;
	}
}

sub format_as_hide_track_products_col{
	my ($value,$call,$field,$res,$hash) = @_;
	my $allowed_columns;
	if(!defined($iatoms->{$call->{'name'}}->{'cache_allowed_cols'})){
		my $track_list_id=($hin{'track_list_id'})?$hin{'track_list_id'}:$hash->{'track_list_id'};
		my $allowed_columns_arr=do_query("SELECT tc.symbol,tc.name
		FROM track_column_name tc
		LEFT JOIN track_user_columns uc ON tc.track_column_name_id=uc.track_column_name_id AND
										   uc.track_list_id=$track_list_id AND
										   uc.user_id=$USER->{'user_id'}
		LEFT JOIN track_restricted_columns trc ON trc.track_column_name_id=tc.track_column_name_id AND
												  trc.track_list_id=$track_list_id
		WHERE  uc.track_column_name_id IS NULL AND trc.track_column_name_id IS NULL");

		my %allowed_columns_hash= map {$_->[0]=>$_->[1]} @$allowed_columns_arr if ref($allowed_columns_arr) eq 'ARRAY';
		$iatoms->{$call->{'name'}}->{'cache_allowed_cols'}=\%allowed_columns_hash;
		$allowed_columns=\%allowed_columns_hash;
	}else{
		$allowed_columns=$iatoms->{$call->{'name'}}->{'cache_allowed_cols'};
	}

	if(ref($allowed_columns) eq 'HASH' and !$allowed_columns->{$field}){
		return ''; # forbiden column
	}
	$hash->{'head_'.$field}='<th class="main info_header">
				<a href="%%icecat_bo_hostname%%index.cgi?sessid=%%sessid%%;tmpl=%%tmpl%%;track_list_id=%%track_list_id%%;order_track_products_track_products='.$field.'">
				'.$allowed_columns->{$field}.'</a>
			   </th>';
	if($field eq 'extr_ean'){
		if($value){
			$value='Y';
		}else{
			$value='N';
		}
	}elsif($field eq 'extr_quality'){
		if($value eq 'icecat'){
			$value='<span >editor</span>';
		}elsif($value eq 'supplier'){
			$value='<span style="color:blue">supplier</span>';
		}elsif($value eq 'nobody' and $hash->{'product_id'}){
			$value='<span style="color:red">nobody</span>';
		}elsif($value eq 'nobody' and !$hash->{'product_id'}){
			$value='<span style="color:black">none</span>';
		}

	}elsif($field eq 'actions'){
		my $html='<table cellpadding="0" cellspacing="0" style="margin: 0px; padding: 0px"><tr>';
		if(!$value or !$hash->{'real_product_id'}){
	    	my $prod_id=$hash->{'feed_prod_id'};
	    	$prod_id=~s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
	    	my $name=$hash->{'name'};
	    	$name=~s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;

	    	$html.='<td>'.repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'add_product_link'},
	    					{'supplier_id'=>$hash->{'supplier_id'},'name'=>$name,
	    					 'prod_id'=>$prod_id,'track_product_id'=>$hash->{'track_product_id'}}).'</td>';
	    }else{
	    	$html.='<td>'.(repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'edit_product_link'},
	    					{'product_id'=>$value})).'</td>';
	    }
	 	$html.='<td>'.(format_as_track_product_parked($hash->{'is_parked'},$call,'is_parked',$res,$hash)).'</td>';
	 	$value=$html.'</tr></table>';
	}elsif($field eq 'is_rule_confirmed'){
		$value=format_as_track_list_rule_status($value,$call,$field,$res,$hash);
	}elsif($field eq 'map_prod_id' and $hash->{'feed_prod_id'} eq $value){
		$value='';
	}
	my $title=(($value=~/</)?'':$value);
	my $id;
	if($field eq 'changer'){
		$title=$hash->{'changer_action'};
		$id='id="'.$hash->{'track_product_id'}.'_changer'.(($hin{'ajaxed'})?'_ajaxed':'').'"';
	}
	return '<td '.$id.' class="'.(($field eq 'actions' or $field eq 'is_rule_confirmed')?'':'main').'"  style="height: 18px;vertical-align: middle; '.(($field eq 'actions')?'width:60px"':'').'">
			 <div title="'.$title.'" style="height: 85%; overflow: hidden" >'.$value.'</div>
			</td>';
}

sub format_as_hide_track_products_col_names{
	my ($value,$call,$field,$res,$hash) = @_;

	$field=~s/^head_//i;

	my ($allowed_columns,$custom_columns);
	if(!defined($iatoms->{$call->{'name'}}->{'cache_allowed_cols'})){# cache the results of query
		my $allowed_columns_arr=do_query("SELECT tc.symbol,tc.name
		FROM track_column_name tc
		LEFT JOIN track_user_columns uc ON tc.track_column_name_id=uc.track_column_name_id AND
										   uc.track_list_id=$hin{'track_list_id'} AND
										   uc.user_id=$USER->{'user_id'}
		LEFT JOIN track_restricted_columns trc ON trc.track_column_name_id=tc.track_column_name_id AND
												  trc.track_list_id=$hin{'track_list_id'}
		WHERE  uc.track_column_name_id IS NULL AND trc.track_column_name_id IS NULL");

		my %allowed_columns_hash= map {$_->[0]=>$_->[1]} @$allowed_columns_arr if ref($allowed_columns_arr) eq 'ARRAY';
		$iatoms->{$call->{'name'}}->{'cache_allowed_cols'}=\%allowed_columns_hash;
		$allowed_columns=\%allowed_columns_hash;
	}else{
		$allowed_columns=$iatoms->{$call->{'name'}}->{'cache_allowed_cols'};
	}

	if(!defined($iatoms->{$call->{'name'}}->{'cache_custom_column_names'})){# cache the results of query
		my $custom_columns_arr=do_query("SELECT ext_col1_name,ext_col2_name,ext_col3_name
										   FROM track_list
			   							   WHERE track_list_id=".$hin{'track_list_id'});

		$custom_columns={'ext_col1'=>$custom_columns_arr->[0][0],
				         'ext_col2'=>$custom_columns_arr->[0][1],
						 'ext_col3'=>$custom_columns_arr->[0][2]
						};
		$iatoms->{$call->{'name'}}->{'cache_custom_column_names'}=$custom_columns;
	}else{
		$custom_columns=$iatoms->{$call->{'name'}}->{'cache_custom_column_names'};
	}

	if(ref($allowed_columns) eq 'HASH' and !$allowed_columns->{$field}){
		return ''; # forbiden column
	}else{
		my $all_columns;
		if(!defined($iatoms->{$call->{'name'}}->{'cache_all_cols'})){
			my $all_columns_arr=do_query("SELECT tc.symbol,tc.name
										   FROM track_column_name tc");
			my %all_columns_hash= map {$_->[0]=>$_->[1]} @$all_columns_arr if ref($all_columns_arr) eq 'ARRAY';
			$iatoms->{$call->{'name'}}->{'cache_all_cols'}=\%all_columns_hash;
			$all_columns=\%all_columns_hash;
		}else{
			$all_columns=$iatoms->{$call->{'name'}}->{'cache_all_cols'};
		}

		return '<th class="main info_header" >
				<a href="%%icecat_bo_hostname%%index.cgi?sessid=%%sessid%%;tmpl=%%tmpl%%;track_list_id=%%track_list_id%%;order_track_products_track_products='.$field.'">
				'.(($custom_columns->{$field})?$custom_columns->{$field}:$all_columns->{$field}).'</a>
			   </th>';
	}
}

sub format_as_track_list_rule_status{
	my ($value,$call,$field,$res,$hash) = @_;

	if(!$hash->{'feed_prod_id'} or !$hash->{'feed_supplier'}){
		return '<span id="is_rule_confirmed_'.$hash->{'track_product_id'}.'">
					<a style="margin-top:15px;" href="javascript:void(0)" onclick="get_map_pair(event,\'%%sessid%%\','.$hash->{'track_product_id'}.',\'ajax_overlay_result_id\',this,true)"><img src="/img/track_lists/add.png"/></a>
				 </span>';
	}

	my $html='<span id="is_rule_confirmed_'.$hash->{'track_product_id'}.'">
						<a style="margin-top:15px;" href="javascript:void(0)" onclick="get_rule_prod_id(event,\'%%sessid%%\','.$hash->{'track_product_id'}.',\'ajax_overlay_result_id\',this,true,\'track_products.html\')">';
	#lp($hash->{'is_reverse_rule'}.'--'.$hash->{'rule_prod_id'}.'--'.$hash->{'prod_id'});	
	if($hash->{'is_reverse_rule'} and $hash->{'rule_prod_id'} and $hash->{'feed_prod_id'} eq $hash->{'prod_id'}){
		$html.='<img src="/img/track_lists/arrow_left.png"/>';
	}elsif(!$hash->{'is_reverse_rule'} and $hash->{'map_prod_id'} eq $hash->{'rule_prod_id'} and $hash->{'rule_prod_id'}){
		$html.='<img src="/img/track_lists/arrow_right.png"/>';
	}elsif($hash->{'extr_quality_raw'} eq 'icecat' or !$hash->{'feed_prod_id'}){
		return '';
	}elsif($hash->{'rule_prod_id'} ne $hash->{'map_prod_id'} and $hash->{'rule_prod_id'} and $hash->{'map_prod_id'}){
		$html.='<img src="/img/track_lists/pause.png"/>';
	}elsif(!$hash->{'rule_prod_id'} or !$hash->{'map_prod_id'}){
		$html.='<img src="/img/track_lists/check.png"/>';
	}else{
		return 'Err';
	}
	$html.="</a>
				</span>";
	return $html;
}

sub format_as_track_product_parked{
	my ($value,$call,$field,$res,$hash) = @_;
	if($value){
		return '<span style="cursor: pointer" class="track_product_red" id="ajax_track_products_'.$hash->{'track_product_id'}.'_parked_return">
					<img src="/img/track_lists/cancel.png" onclick="call_park(event,\'%%sessid%%\','.$hash->{'track_product_id'}.',\'ajax_overlay_result_id\',this,true)" />
				</span>';
	}elsif($hash->{'extr_quality_raw'} eq 'icecat'){
		return '<span style="cursor: pointer" class="track_product_green" id="ajax_track_products_'.$hash->{'track_product_id'}.'_parked_return">
					<img src="/img/track_lists/chat.png" onclick="call_park(event,\'%%sessid%%\','.$hash->{'track_product_id'}.',\'ajax_overlay_result_id\',this,true)"/>
				</span>';
	}else{
		return '<span style="cursor: pointer" id="ajax_track_products_'.$hash->{'track_product_id'}.'_parked_return">
					<img src="/img/track_lists/chat.png" onclick="call_park(event,\'%%sessid%%\','.$hash->{'track_product_id'}.',\'ajax_overlay_result_id\',this,true)"/>
				</span>';
	}
}

sub format_as_track_product_park_cause{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hash->{'map_prod_id'} and $hash->{'rule_prod_id'} and $hash->{'rule_prod_id'}!=$hash->{'map_prod_id'}){
		return '';
	}else{
		format_as_radio_buttons($value,$call,$field,$res,$hash)
	}
}

sub format_as_unixdate_three_dropdowns {
	my ($value,$call,$field,$res,$hash) = @_;
	my ($year, $month, $day);
	my $date=eval{Time::Piece->new($value)};
	my $choicendate=eval{Time::Piece->strptime($hin{$field.'_year'}.'-'.$hin{$field.'_month'}.'-'.$hin{$field.'_day'},'%Y-%m-%d')};
	if(defined($hin{$field.'_year'}) or defined($hin{$field.'_month'}) or defined($hin{$field.'_day'})){# user select something
		($year, $month, $day)=($hin{$field.'_year'},$hin{$field.'_month'},$hin{$field.'_day'});
		$value=($choicendate)?$choicendate->epoch:'';
	}elsif($date){
		($year, $month, $day)=($date->year,$date->mon,$date->mday);
	}
	return '<input type="hidden" name="'.$field.'" value="'.$value.'"  />'.
			format_as_day($day,$call,$field."_day",$res,$hash).
			format_as_month($month,$call,$field."_month",$res,$hash).
			format_as_year($year,$call,$field."_year",$res,$hash);
} # format_as_date_three_dropdowns

sub format_as_dropdown_multi_pair_from_user_id{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rows=[];
	use Time::Piece;
	my $month3ago=Time::Piece->new(localtime());
	$month3ago->add_months(-3);
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$rows=do_query("SELECT u.user_id,u.login,
						(SELECT count(*) FROM track_list_editor te1 JOIN track_list tl1 USING(track_list_id) WHERE te1.user_id=u.user_id AND tl1.is_open=1),
						count(ej.id)
						FROM  users u
						LEFT JOIN  track_list_editor te ON u.user_id=te.user_id AND te.track_list_id=$hash->{'track_list_id'}
						LEFT JOIN editor_journal  ej ON ej.user_id = u.user_id and ej.product_table='product' and date>".$month3ago->epoch()."
						WHERE  te.user_id IS null and u.user_group='editor'
						GROUP BY ej.user_id,u.user_id
						ORDER BY u.login");
	}else{
		my $tmp_table=create_assigned_id_table('occupied_user_id','tmp_assigned_ids');
		$rows=do_query("SELECT u.user_id,u.login,
							(SELECT count(*) FROM track_list_editor te1 JOIN track_list tl1 USING(track_list_id) WHERE te1.user_id=u.user_id AND tl1.is_open=1),
							count(ej.id)
							FROM  users u
							LEFT JOIN  track_list_editor te ON u.user_id=te.user_id AND te.track_list_id=$hash->{'track_list_id'}
							LEFT JOIN editor_journal  ej ON ej.user_id = u.user_id and ej.product_table='product' and date>".$month3ago->epoch()."
							WHERE  te.user_id IS null and u.user_group='editor'
							GROUP BY ej.user_id,u.user_id
							ORDER BY u.login");
	}
	add_load_productiv_starts($rows);
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );
	#return format_as_dropdown($value,$call,$field,$res,$hash);
}

sub format_as_dropdown_multi_pair_to_user_id{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rows=[];
	use Time::Piece;
	my $month3ago=Time::Piece->new(localtime());
	$month3ago->add_months(-3);
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$rows=do_query("SELECT te.user_id,u.login,
						 (SELECT count(*) FROM track_list_editor te1 JOIN track_list tl1 USING(track_list_id) WHERE te1.user_id=u.user_id AND tl1.is_open=1),
						 count(ej.id)
						 FROM track_list_editor te
						 JOIN users u USING(user_id)
						 LEFT JOIN editor_journal  ej ON ej.user_id = u.user_id and ej.product_table='product' and date>".$month3ago->epoch()."
						 WHERE te.track_list_id=$hash->{'track_list_id'}
						 GROUP BY ej.user_id,u.user_id
						 ORDER BY u.login");
	}else{
		my $tmp_table=create_assigned_id_table($field,'tmp_assigned_ids');
		$rows=do_query("SELECT u.user_id,u.login,
						 (SELECT count(*) FROM track_list_editor te1 JOIN track_list tl1 USING(track_list_id) WHERE te1.user_id=u.user_id AND tl1.is_open=1),
						 count(ej.id)
						 FROM users u
						 JOIN $tmp_table t ON u.user_id=t.id
						 LEFT JOIN editor_journal  ej ON ej.user_id = u.user_id and ej.product_table='product' and date>".$month3ago->epoch()."
						 GROUP BY ej.user_id,u.user_id
						 ORDER BY u.login");


	}
	add_load_productiv_starts($rows);
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );
}

sub add_load_productiv_starts{
	my $array=$_[0];
	return [] if(ref($array) ne 'ARRAY' and  ref($array->[0]) ne 'ARRAY');
	#2 - indicator of loading
	#3 - indicator of productivity
	for my $el(@$array){
		if($el->[2]<=1){
			$el->[1].='  *';
		}elsif($el->[2]>1 and $el->[2]<=3){
			$el->[1].='  **';
		}elsif($el->[2]>3){
			$el->[1].='  ***';
		}

		if($el->[3]<=1){
			$el->[1].='  +';
		}elsif($el->[3]>1 and $el->[3]<=3){
			$el->[1].='  ++';
		}elsif($el->[3]>3){
			$el->[1].='  +++';
		}

	}
}

sub format_as_dropdown_multi_pair_from_user_id_graph{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rows=[];
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$rows=do_query("SELECT u.user_id,u.login
						FROM  users u
						JOIN  track_list_editor te ON u.user_id=te.user_id AND te.track_list_id=$hash->{'track_list_id'}
						WHERE  1
						ORDER BY u.login");
	}else{
		my $tmp_table=create_assigned_id_table('occupied_user_id','tmp_assigned_ids');
		$rows=do_query("SELECT u.user_id,u.login
							FROM  users u
							JOIN  track_list_editor te ON u.user_id=te.user_id AND te.track_list_id=$hash->{'track_list_id'}
							LEFT JOIN $tmp_table t ON u.user_id=t.id
							WHERE  t.id is null
							ORDER BY u.login");
	}	
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );
}

sub format_as_dropdown_multi_pair_to_user_id_graph{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rows=[];
	my $tmp_table=create_assigned_id_table($field,'tmp_assigned_ids');
	$rows=do_query("SELECT u.user_id,u.login
						 FROM users u
						 JOIN $tmp_table t ON u.user_id=t.id
						 ORDER BY u.login");
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );
}

sub format_as_dropdown_multi_pair_from_entrusted_user{
	my ($value,$call,$field,$res,$hash) = @_;	
	my $rows=[];
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$rows=do_query("SELECT u.user_id,u.login
						FROM  users u 
						LEFT JOIN track_list_entrusted_users te ON u.user_id=te.user_id
						WHERE u.user_group in ('editor','supereditor','superuser') and te.user_id is NULL
						ORDER BY u.login");
												 		
	}else{
		my $tmp_table=create_assigned_id_table('occupied_user_id','tmp_assigned_ids');
		$rows=do_query("SELECT u.user_id,u.login
							FROM  users u 							
							LEFT JOIN $tmp_table t ON u.user_id=t.id 
							WHERE  t.id is null and u.user_group in ('editor','supereditor','superuser')
							ORDER BY u.login");
	}	
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );		
}

sub format_as_dropdown_multi_pair_to_entrusted_user{
	my ($value,$call,$field,$res,$hash) = @_;
	my $rows=[];
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$rows=do_query("SELECT u.user_id,u.login
						FROM  users u 
						JOIN track_list_entrusted_users te ON u.user_id=te.user_id
						WHERE u.user_group in ('editor','supereditor','superuser')
						ORDER BY u.login");	
	}else{
		my $tmp_table=create_assigned_id_table($field,'tmp_assigned_ids');
		$rows=do_query("SELECT u.user_id,u.login
						 FROM users u 
						 JOIN $tmp_table t ON u.user_id=t.id  
						 ORDER BY u.login");
	}
	return make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    'sel' => $value,
	    'small' => 'multiple size="'.$iatoms->{$call->{'name'}}->{'def_multidropdown_size'}.'"',
	    'width' => $iatoms->{$call->{'name'}}->{'def_multidropdown_width'},
	    'allow_custom' => ''
	} );	
}

sub format_as_dropdown_multi_pair_from_langid{
	my ($value,$call,$field,$res,$hash) = @_;
	$iatoms->{$call->{'name'}}->{$field.'_dropdown_JavaScript'}='multiple size="10"';
	$iatoms->{$call->{'name'}}->{$field.'_dropdown_width'}='200';
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'}="SELECT l.langid,l.short_code FROM  language l
																 LEFT JOIN  track_list_lang tl ON l.langid=tl.langid AND tl.track_list_id=$hash->{'track_list_id'}
																 WHERE  tl.langid IS null and l.published='Y'".'
																 ORDER BY l.short_code';
	}else{
		my $tmp_table=create_assigned_id_table('occupied_langid','tmp_assigned_ids');
		$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'}="SELECT l.langid,l.short_code  FROM  language l
																 LEFT JOIN $tmp_table t ON l.langid=t.id
																 WHERE  t.id IS null AND l.published='Y'".'
																 ORDER BY l.short_code';
	}
	return format_as_dropdown($value,$call,$field,$res,$hash);
}

sub format_as_dropdown_multi_pair_to_langid{
	my ($value,$call,$field,$res,$hash) = @_;
	$iatoms->{$call->{'name'}}->{$field.'_dropdown_width'}='200';
	$iatoms->{$call->{'name'}}->{$field.'_dropdown_JavaScript'}='multiple size="10"';
	if(!defined($hin{'atom_name'})){# user does not submit anything
		$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'}="SELECT tl.langid,l.short_code FROM track_list_lang tl
																 JOIN language l USING(langid)
																 WHERE tl.track_list_id=$hash->{'track_list_id'}".'
																 ORDER BY l.short_code';
		return format_as_dropdown($value,$call,$field,$res,$hash);
	}else{
		my $tmp_table=create_assigned_id_table($field,'tmp_assigned_ids');
		$iatoms->{$call->{'name'}}->{$field.'_dropdown_select'}="SELECT l.langid,l.short_code FROM language l
																 JOIN $tmp_table t ON l.langid=t.id ".'
																 ORDER BY l.short_code';
		return format_as_dropdown($value,$call,$field,$res,$hash);
	}
}


sub create_assigned_id_table{
	my ($field,$table_name)=@_;
	my @assigned=$hin{'REQUEST_BODY'}=~/$field=([\d]+)/gs;
	my $values='';
	for my $id(@assigned){
		$values.=" ($id) ,";
	}
	$values=~s/,$//;
	do_statement('DROP TEMPORARY TABLE IF EXISTS '.$table_name);
	do_statement('CREATE TEMPORARY TABLE '.$table_name.' (id int(13) not null, PRIMARY KEY(id))');
	if($values){
		do_statement("INSERT INTO $table_name (id) VALUES ".$values);
	}
	return $table_name;
}

sub format_as_open_closed{
	my ($value) = @_;
	if($value){
		return '<span style="color:green">Open</span>';
	}else{
		return '<span>Closed</span>';
	}
}

sub format_as_track_list_priority{
	my ($value) = @_;
	if($value eq '1'){
		return '<span style="color:red">High</span>';
	}elsif($value eq '2'){
		return '<span style="color: teal">Normal</span>';
	}elsif($value eq '3'){
		return '<span >Low</span>';
	}else{
		return 'error';
	}
}


sub format_as_tracklist_eta{
	my ($value,$call,$field,$res,$hash) = @_;
	use Time::Piece;
	use POSIX 'floor';
	if(!$hash->{'prods_count_free'} or !$hash->{'prods_editor_described'}){
		return '0';
	};
	my $time_gone=time()-$hash->{'created'};
	if(!$time_gone){
		log_printf('--->>>>>>>>>>>>>ERR: division by zero');
		return '';
	}
	my $avg_time=$time_gone/$hash->{'prods_editor_described'};
	if(!$avg_time){
		return 'N/A';
	}elsif($hash->{'editors_descs_cnt'}==$hash->{'prods_count'}){
		return 'done';
	}
	my $goal_coverage=$hash->{'goal_coverage'};
	$goal_coverage=100 if !$goal_coverage;
	if(($hash->{'prods_count'}*($goal_coverage/100))<$hash->{'prods_described'}){
		return 'N/A';
	}
	my $eta_time=Time::Piece->new(time());
	$eta_time=$eta_time+($avg_time*$hash->{'prods_count_free'});

	if($field eq 'prods_desc_pers_color'){
		return $eta_time;
	}

	if($hash->{'deadline_date'}<$eta_time->epoch()){
		return $eta_time->date();
	}else{
		return $eta_time->datetime();
	}
}

sub format_as_track_list_restricted_cols{
	my ($value,$call,$field,$res,$hash) = @_;
	my $restricted_cols=do_query('SELECT tcn.name,tcn.symbol,trc.track_column_name_id,tcn.track_column_name_id
								   FROM track_column_name tcn
								   LEFT JOIN track_restricted_columns trc ON
								   									tcn.track_column_name_id=trc.track_column_name_id AND
								   									trc.track_list_id='.$hin{'track_list_id'}.'
								   WHERE is_restricted=1');

	my $custom_columns_arr=do_query("SELECT ext_col1_name,ext_col2_name,ext_col3_name
									  FROM track_list
			   						  WHERE track_list_id=".$hin{'track_list_id'});
	my $custom_columns={'ext_col1'=>$custom_columns_arr->[0][0],
				    	'ext_col2'=>$custom_columns_arr->[0][1],
					 	'ext_col3'=>$custom_columns_arr->[0][2]};
	my $check_boxes='<table style="width:100%"><tr>';
	my $i=1;
	for my $col(@$restricted_cols){
		$check_boxes.= '<td class="main info_bold">'.(($custom_columns->{$col->[1]})?$custom_columns->{$col->[1]}:$col->[0]).'
					   		<input type="checkbox" name="restricted_col"  value="'.$col->[3].'" '.(($col->[2])?'':'checked').' />
					   	</td>';
		if($i%4==0){
			$check_boxes.='</tr><tr>';
		}
		$i++;
	}
	$check_boxes.='</tr></table>';
	return $check_boxes;
}

sub format_as_track_list_column_choice{
	my ($value,$call,$field,$res,$hash) = @_;
	if(defined($iatoms->{$call->{'name'}}->{'format_as_track_list_column_choice_processed'})){
		return $iatoms->{$call->{'name'}}->{'format_as_track_list_column_choice_processed'};
	}
	process_atom_ilib("track_list_column_choice");
 	my $atoms=process_atom_lib("track_list_column_choice");
	my $my_atom=$atoms->{'default'}->{'track_list_column_choice'};
	my $columns=do_query("
		SELECT tc.name,tc.track_column_name_id,uc.track_user_columns_id
		FROM track_column_name tc
		LEFT JOIN track_user_columns uc ON tc.track_column_name_id=uc.track_column_name_id AND
										   uc.track_list_id=$hin{'track_list_id'} AND
										   uc.user_id=$USER->{'user_id'}
		LEFT JOIN track_restricted_columns trc ON trc.track_column_name_id=tc.track_column_name_id AND
												  trc.track_list_id=$hin{'track_list_id'}
		WHERE  trc.track_column_name_id IS NULL ORDER BY tc.order");
	my $custom_columns_arr=do_query("SELECT ext_col1_name,ext_col2_name,ext_col3_name
									  FROM track_list
			   						  WHERE track_list_id=".$hin{'track_list_id'});
	my $custom_columns={'ext_col1'=>$custom_columns_arr->[0][0],
				    	'ext_col2'=>$custom_columns_arr->[0][1],
					 	'ext_col3'=>$custom_columns_arr->[0][2]};
	my $i=1;
	my($td_str,$tr_str,$html);
	for my $col(@$columns){
		$td_str.=repl_ph($my_atom->{'td_row'},{ 'title'=>($custom_columns->{$col->[0]})?$custom_columns->{$col->[0]}:$col->[0],
												'name'=>$field,
												'value'=>$col->[1],
												'checked'=>($col->[2])?'':'checked'});
		if($i%4==0){
			$tr_str.=repl_ph($my_atom->{'tr_row'},{'td_row'=>$td_str});
			$td_str='';
		}
		$i++;
	}

	$tr_str.=repl_ph($my_atom->{'tr_row'},{'td_row'=>$td_str}) if $td_str;
	$html=repl_ph($my_atom->{'body'},{'tr_row'=>$tr_str,'track_list_id'=>$hin{'track_list_id'}});
	$iatoms->{$call->{'name'}}->{'format_as_track_list_column_choice_processed'}=$html;
	return $html;
}

sub format_as_track_list_status_color{
	my ($value,$call,$field,$res,$hash) = @_;
	if($hash->{'is_parked_raw'}){
		return 'track_product_red';
	}elsif($hash->{'extr_quality_raw'} eq 'icecat'){
		return 'track_product_green';
	}else{
		return '';
	}
}

sub format_as_track_list_described_color{
	my ($value,$call,$field,$res,$hash) = @_;
	use Time::Piece;
	my $eta=format_as_tracklist_eta('1',$call,'prods_desc_pers_color',$res,$hash);
	if(ref($eta) eq 'Time::Piece' and $eta->epoch() > $hash->{'deadline_date'}){
		return 'color: red';
	}else{
		return '';
	}
}

sub format_as_vcatid_link {
    my ($value,$call,$field,$res,$hash) = @_;

    # get ucatid
    my $ucatid = $hash->{'ucatid'};

    # no links for abstract categories
    if ($ucatid =~ /00$/) {
        $value = '';
    }
    else {
        $value = "Virtuals ($value)";
    }

    return $value;
}

sub format_as_families_set {
    my ($value,$call,$field,$res,$hash) = @_;

    my $supplier_id = $call->{'call_params'}->{'supplier_id'};
    my $catid = $call->{'call_params'}->{'category_id'};

    # log_printf("====================================");
    # log_printf("Try to receive families list for CATID = $catid and SUPPLIER_ID = $supplier_id");

    my $ans = do_query("
        SELECT level, v.value, pf.family_id, left_key, right_key
        FROM product_family pf
        INNER JOIN product_family_nestedset ns ON (ns.family_id = pf.family_id AND ns.langid = 1)
        INNER JOIN vocabulary v ON (pf.sid = v.sid AND v.langid = 1)
        WHERE catid = $catid
        AND supplier_id = $supplier_id
        ORDER BY 4
    ");

    my $str;
    my $rows = [];
    # void value
    push @$rows, ['1', 'None'];
    for (@$ans) {
        $str = '';
        for (my $i = 1 ; $i < $_->[0] - 1 ; $i++ ) {
            $str .= '---';
        }
        $str .= $_->[1];
        # log_printf($str);
        push @$rows, [$_->[2], $str];
    }

    # add functions for family_id
	my $functions = '';
	if ($field eq 'family_id') {
		$functions = ' onChange="get_series_do_next_request(this.value);update_title();" ';
	}

	$res = make_select( {
	    'rows' => $rows,
	    'name' => $field,
	    # 'sel' => $value
	    'functions' => $functions
	} );

	# log_printf($res);
	# log_printf("====================================");

	return $res;
}

sub format_as_clever_clock {
    my ($value,$call,$field,$res,$hash) = @_;

    # this is my version of localtime function
    my ($min,$hour,$mday,$mon,$year);
    my $i = time() - $value;

use integer;
    $hour = ($i / 3600) % 24;
    $min = ($i / 60) % 60;
    $mday = ($i / (3600 * 24) ) % 30;
    $mon = ($i / (3600 * 24 * 30) ) % 12;
    $year = ($i / (3600 * 24 * 365) ) ;
no integer;
    # log_printf("$year $mon $mday : $hour $min ");

    # possible answers:
    # ================= long =====================
    # more than 2 years
    # more than 1 year 11 months
    # more than 1 year 1 month
    # more than 1 year
    # more than 11 months
    # more than 1 month
    # ================= short =====================
    # more than 22 days
    # more than 1 day
    # ================= very short =====================
    # 11h 11m

    # long periods (months yesrs)
    # default prefix
    my $prefix = 'more than ';

    if ($year >= 2) {
        # that is all
        return $prefix . "$year years";
    }
    if ($year == 1) {
        # in this case (and 0 years) we should add months amount
        $prefix .= "1 year ";
    }
    if ($mon >= 2) {
        return $prefix . " $mon months";
    }
    if ($mon == 1) {
        $prefix .= "1 month ";
    }
    unless ($prefix eq 'more than ') {
        return $prefix;
    }

    # if interval less than 1 month than short periods (days) will processed
    if ($mday >= 2) {
        return $prefix . "$mday days";
    }
    if ($mday == 1) {
        return $prefix . "$mday day";
    }

    # less than one day intevals
    if ($hour > 0) {
        return "${hour}h ${min}m";
    }
    else {
        return "${min}m";
    }
}

sub format_as_if_my_username {

    my ($value,$call,$field,$res,$hash) = @_;
    my $format;
    if ($USER->{'login'} eq $value) {
        # highlighted row
        return "color: black;";
    }
    else {
        # casual format
        return "color: grey;";
    }
}

sub format_as_product_history_type {
    my ($value,$call,$field,$res,$hash) = @_;

    return $value;

    if ($value eq 'product_feature' ) {
        return 'FEATURE';
    }
    elsif ($value eq 'product_name' ) {
        return 'PRODUCT NAME';
    }
    elsif ($value eq 'product_feature_local' ) {
        return 'FEATURE LOCAL';
    }
    elsif ($value eq 'product') {
        return 'P';
    }
    elsif ($value eq 'product_description') {
        return 'DESC';
    }
    elsif ($value eq 'product_multimedia_object') {
        return 'MULTIMEDIA';
    }
    elsif ($value eq 'product_ean_codes') {
        return 'EAN CODE';
    }
    elsif ($value eq 'product_gallery') {
        return 'GALLERY';
    }
    elsif ($value eq 'product_related') {
        return 'PRODUCT RELATED';
    }
    else {
        return '-- UNKNOWN --';
    }
}

sub format_as_product_history_content {
    my ($value,$call,$field,$res,$hash) = @_;

    my $content_id = $hash->{'h_content_id'};
    my $table = $hash->{'h_product_table'};
    my $product_id = $call->{'call_params'}->{'product_id'};
    my $pt_id = $hash->{'h_product_table_id'};
    my $id = $hash->{'h_id'};
    my $submit_date = $hash->{'h_date'};

    # get action form EJ for all cases
    my $action = do_query("SELECT action_type FROM editor_journal WHERE id = $id")->[0]->[0];

        # field names to WEB captions
        my $rename_field = sub {
            my $s = shift;

            # product
            $s =~ s/\b supplier_id  \b/Brand,/x;
            $s =~ s/\b prod_id      \b/Part number,/x;
            $s =~ s/\b user_id      \b/Owner,/x;
            $s =~ s/\b catid        \b/Category,/x;
            $s =~ s/\b name         \b/Model name,/x;
            $s =~ s/\b low_pic      \b/Low res picture URL,/x;
            $s =~ s/\b high_pic     \b/High res picture URL,/x;
            $s =~ s/\b thumb_pic    \b/Thumbnail URL,/x;
            $s =~ s/\b publish      \b/Publish,/x;
            $s =~ s/\b public       \b/Public,/x;
            $s =~ s/\b family_id    \b/Product family,/x;
            $s =~ s/\b series_id    \b/Product series,/x;
            $s =~ s/\b checked_by_supereditor    \b/Checked by supereditor status,/x;

            # description + MMO
            $s =~ s/\b langid       \b/Language,/x;
            $s =~ s/\b short_desc   \b/Short description,/x;

            # description
            $s =~ s/\b long_desc        \b/Marketing text,/x;
            $s =~ s/\b official_url     \b/URL,/x;
            $s =~ s/\b warranty_info    \b/Warranty info,/x;
            $s =~ s/\b pdf_url          \b/PDF URL,/x;
            $s =~ s/\b manual_pdf_url   \b/Manual PDF URL,/x;

            # MMO
            $s =~ s/\b content_type     \b/Content_type,/x;
            $s =~ s/\b keep_as_url      \b/Keep as URL,/x;
            $s =~ s/\b type             \b/Type,/x;

            # kill last comma (just before ')' char )
            $s =~ s/,\)/)/;
            $s =~ s/,$//;

            return $s;
        };

        my $is_custom_field = sub {
            my $name = shift;
            if ($name =~ /^###_/) {
                return 1;
            }
            else {
                return 0;
            }
        };

        # make table with 2 cols
        my $make_table = sub {
            my $d = shift;

            my $res = '
                <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr><td style="padding-top:10px">
                <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
                <tr><td>
                <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">';


            sub format_arrow {
                my $s = shift;
                $s =~ s/ >>> /<span style="color:gray;"> >>> <\/span>/g;
                return $s;
            }

            # custom fields should have ###_ prefix
            for (keys %$d) {

                next if (! $d->{$_} );

                if ( $is_custom_field->($_) ) {
                    s/^###_//;
                    $res .= '<tr><td class="info_bold" align="left" width="30%">*&nbsp;' . $_;
                    $res .= '</td><td class="" align="left">' . format_arrow($d->{'###_' . $_}) . '</td></tr>';
                }
                else {
                    $res .= '<tr><td class="info_bold" align="left" width="30%">' .
                    $rename_field->($_);
                    $res .= '</td><td class="" align="left">' . format_arrow($d->{$_}) . '</td></tr>';
                }
            }

            # add empty row and close table
            $res .= '<tr><td>&nbsp;</tr></td>';
            $res .= '</table></td></tr></table></td></tr></table>';
            return $res;
        };


    # ------------------------------------------------------------------------
    if ($table eq 'product_feature') {

        my $verdict = '';
        
        my $get_english_name = sub {
            my $product_feature_id = shift;
            my $ans = do_query("SELECT v.value
                FROM product_feature
                INNER JOIN category_feature USING (category_feature_id)
                INNER JOIN feature USING (feature_id)
                INNER JOIN vocabulary v USING (sid)
                WHERE product_feature_id = $product_feature_id AND v.langid=1
            ");
            return $ans->[0]->[0];
        };

        #
        # get current and
        #
        my $ans1 = do_query("
            SELECT data
            FROM editor_journal_product_feature_pack
            WHERE content_id = " . $content_id
        );
        my $data;
        $data = ser_unpack($ans1->[0]->[0]) if ($ans1->[0]->[0]);

        # output for web

        $verdict .= (scalar (keys %$data) ) . " feature(s) changed ";

        $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
        $hash->{'h_changes'} = '';
        my %cnt;
        for my $feature (keys %$data) {
            $data->{$feature} =~ s/\x{0}/ >>> /;
            $cnt{ $get_english_name->($feature) } = $data->{$feature};
        }

        $hash->{'h_changes'} = $make_table->(\%cnt);
        return $verdict;
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_feature_local') {

        my $get_english_name = sub {
            my $product_feature_local_id = shift;
            my $ans = do_query("SELECT v.value
                FROM product_feature_local
                INNER JOIN category_feature USING (category_feature_id)
                INNER JOIN feature USING (feature_id)
                INNER JOIN vocabulary v USING (sid)
                WHERE product_feature_local_id = $product_feature_local_id AND v.langid=1
            ");
            return $ans->[0]->[0];
        };

        #
        # get current and prev
        #
        my $ans1 = do_query("
            SELECT data
            FROM editor_journal_product_feature_local_pack
            WHERE content_id = " . $content_id
        );
        my $data;
        $data = ser_unpack($ans1->[0]->[0]) if ($ans1->[0]->[0]);

        # output for web

        my $verdict = (scalar (keys %$data) - 1) . " local feature(s) changed ";
        my $lng = do_query("
            SELECT code
            FROM language
            WHERE langid = " . $data->{'langid'}
        )->[0]->[0];

        $verdict .= " [" . $lng . "] ";

        $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
        $hash->{'h_changes'} = '';
        my %cnt;
        for my $feature (keys %$data) {

            next if ($feature eq 'langid');
            $data->{$feature} =~ s/\x{0}/ >>> /;

            $cnt{ $get_english_name->($feature) } = $data->{$feature};
        }

        $hash->{'h_changes'} = $make_table->(\%cnt);

        return $verdict;
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_ean_codes') {
        my $ans1 = do_query('
            SELECT ean_code
            FROM editor_journal_product_ean_codes
            WHERE content_id = ' . $content_id
        );

        return $ans1->[0]->[0];
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_name') {

        my $ans = do_query('
            SELECT name, code
            FROM editor_journal_product_name
            INNER JOIN language USING (langid)
            WHERE content_id = ' . $content_id
        );

        # get previous if exists
        my $ans0 = do_query("
            SELECT name
            FROM editor_journal
            INNER JOIN editor_journal_product_name USING (content_id)
            WHERE product_id = $product_id
            AND product_table_id = $pt_id
            AND product_table = 'product_name'
            AND id <> $id
            AND date <= $submit_date
            ORDER BY date DESC LIMIT 1
        ");

        return '' if ($action == 0);

        if ($action == 1) {
            return $ans->[0]->[0] . " [" . $ans->[0]->[1] . "]";
        }

        if ($action == 2) {
            return $ans0->[0]->[0] . " [" . $ans->[0]->[1] . "]";
        }

        return $ans0->[0]->[0] . ' >>> ' . $ans->[0]->[0] . " [" . $ans->[0]->[1] . "]";
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_gallery') {

        my $verdict = '';
        if ($action == 1) {
            $verdict = 'New picture';

            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my $ans = do_query("
                SELECT link
                FROM editor_journal_product_gallery
                WHERE content_id = $content_id
            ")->[0]->[0];

            my %cnt;
            $cnt{'Local link'} = $ans;

            # there is no any field except dynamic ones
            my $cust = get_and_unpack_custom_data('product_gallery', $content_id );
            if ($cust) {
                for (keys %$cust) {
                    $cnt{'###_' . $_} = $cust->{$_};
                }
            }

            $hash->{'h_changes'} = $make_table->(\%cnt);

            return $verdict;
        }

        if ($action == 2) {

            # get previous if exists
            my $old_link = do_query("
                SELECT link
                FROM editor_journal
                INNER JOIN editor_journal_product_gallery USING (content_id)
                WHERE content_id = $content_id
            ")->[0]->[0];

            $verdict = 'Delete existed';
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my %cnt;

            # add link if outdated image was removed to remote server
            if ($old_link) {
                my $link = 'http://' . $atomcfg{'outdated_images_host'} . '/' . $atomcfg{'outdated_images_www_path'};
                $link .= get_name_from_url($old_link);
                $cnt{'Link to removed'} = "(outdated image: <a href='$link'>$link</a>)";
            }
            else {
                $cnt{'Link to removed'} = " ";
            }

            $hash->{'h_changes'} = $make_table->(\%cnt);

            return $verdict;
        }


    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_multimedia_object') {

        my $verdict;

        # get first
        my $ans1 = do_query('
             SELECT short_descr, langid, content_type, keep_as_url, type, code, link
             FROM editor_journal_product_multimedia_object
             INNER JOIN language USING (langid)
             WHERE content_id = ' . $content_id
        );

        # get previous content_id if exists
        my $cont_id = do_query("
            SELECT content_id
            FROM editor_journal
            WHERE product_id = $product_id
            AND product_table = 'product_multimedia_object'
            AND product_table_id = $pt_id
            AND id <> $id
            AND date <= $submit_date
            ORDER BY date DESC LIMIT 1
        ")->[0]->[0];

        # get prev
        my $ans2 = do_query('
             SELECT short_descr, langid, content_type, keep_as_url, type, code, link, content_id
             FROM editor_journal_product_multimedia_object
             INNER JOIN language USING (langid)
             WHERE content_id = ' . $cont_id
        ) if ($cont_id);

        if ($action == 1) {
            $verdict = $ans1->[0]->[0] . " [" . $ans1->[0]->[5] . "]";
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my %cnt;

            if ($ans1->[0]->[0]) {
                $cnt{'short_desc'} = $ans1->[0]->[0];
            }
            if ($ans1->[0]->[1]) {
                $cnt{'langid'} = $ans1->[0]->[5] . " [" . $ans1->[0]->[1] . "]";
            }
            if ($ans1->[0]->[2]) {
                $cnt{'content_type'} = $ans1->[0]->[2];
            }
            if ($ans1->[0]->[3]) {
                $cnt{'keep_as_url'} = $ans1->[0]->[3];
            }
            if ($ans1->[0]->[4]) {
                $cnt{'type'} = $ans1->[0]->[4];
            }
            if ($ans1->[0]->[6]) {
                $cnt{'Link'} = $ans1->[0]->[6];
            }

            #
            # add custom fields
            #

            # current
            my $cust = get_and_unpack_custom_data('product_multimedia_object', $content_id );
            if ($cust) {
                for (keys %$cust) {
                    $cnt{'###_' . $_} = $cust->{$_};
                }
            }

            $hash->{'h_changes'} = $make_table->(\%cnt);
            return $verdict;
        }

        if ($action == 2) {

            $verdict = $ans2->[0]->[0] . " [" . $ans2->[0]->[5] . "]";
            return $verdict;

            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my %cnt;

            # there is no record about 'delete' operation in ej_pmmo, so get previous one
            my $old_link = do_query("
                SELECT link
                FROM editor_journal
                INNER JOIN editor_journal_product_multimedia_object USING (content_id)
                WHERE product_table = 'product_multimedia_object'
                AND product_table_id = $pt_id
                AND id <> $id
                AND date <= $submit_date
                ORDER BY date DESC LIMIT 1
            ")->[0]->[0];

            if ($old_link) {
                my $link = 'http://' . $atomcfg{'outdated_images_host'} . '/' . $atomcfg{'outdated_images_www_path'};
                $link .= get_name_from_url($old_link);
                $cnt{'Link to removed'} = "(outdated image: <a href='$link'>$link</a>)";
            }
            else {
                $cnt{'Link to removed'} = "No link";
            }

            $hash->{'h_changes'} = $make_table->(\%cnt);

            return $verdict;
        }

        # diff
        $verdict .= 'short_desc '   unless ($ans1->[0]->[0] eq $ans2->[0]->[0]);
        $verdict .= 'langid '       unless ($ans1->[0]->[1] eq $ans2->[0]->[1]);
        $verdict .= 'content_type ' unless ($ans1->[0]->[2] eq $ans2->[0]->[2]);
        $verdict .= 'keep_as_url '  unless ($ans1->[0]->[3] eq $ans2->[0]->[3]);
        $verdict .= 'type '         unless ($ans1->[0]->[4] eq $ans2->[0]->[4]);
        $verdict .= 'link '         unless ($ans1->[0]->[6] eq $ans2->[0]->[6]);

        if (! $verdict) {

            return 'No changes';
        }

        $verdict =~ s/\s$//;
        $verdict = 'CHANGES(' . $verdict . ')';

        # a-tag for popup
        if ($verdict) {
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
        }

        # make note about changes
        my $tmp = '';
        my %cnt;

        if ($verdict =~ /\bshort_desc\b/) {
            $cnt{'short_desc'} = $ans2->[0]->[0] . " >>> " . $ans1->[0]->[0];
        }
        if ($verdict =~ /\blangid\b/) {
            $cnt{'langid'} = $ans2->[0]->[5] . " [" . $ans2->[0]->[1] . "] >>> " . $ans1->[0]->[5] . " [" . $ans1->[0]->[1] . "]";
        }
        if ($verdict =~ /\bcontent_type\b/) {
            $cnt{'content_type'} = $ans2->[0]->[2] . " >>> " . $ans1->[0]->[2];
        }
        if ($verdict =~ /\bkeep_as_url\b/) {
            $cnt{'keep_as_url'} = $ans2->[0]->[3] . " >>> " . $ans1->[0]->[3];
        }
        if ($verdict =~ /\btype\b/) {
            $cnt{'type'} = $ans2->[0]->[4] . " >>> " . $ans1->[0]->[4];
        }
        if ($verdict =~ /\blink\b/) {
            $cnt{'Link'} = $ans2->[0]->[6] . " >>> " . $ans1->[0]->[6];
        }

        #
        # add custom fields
        #

        # prev
        my $cust = get_and_unpack_custom_data('product_multimedia_object', $ans2->[0]->[7] );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} = $cust->{$_};
            }
        }

        # current
        $cust = get_and_unpack_custom_data('product_multimedia_object', $content_id );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} .= " >>> " . $cust->{$_};
            }
            # kill useless
            for (keys %$cust) {
                if ($cnt{'###_' . $_} =~ /^(.*) >>> \1$/ )  {
                    $cnt{'###_' . $_} = undef;
                }
            }
        }

        # update old style
        $verdict = $rename_field->($verdict);
        $verdict =~ s!^CHANGES\((.*?)\)!$1!;

        $hash->{'h_changes'} = $make_table->(\%cnt);

        return $verdict;
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_description') {

        my $verdict = '';

        #
        # get new data
        #
        my $ans1 = do_query('
             SELECT m.langid, m.short_desc, m.long_desc, m.official_url, m.warranty_info, m.pdf_url, m.manual_pdf_url, l.code
             FROM editor_journal_product_description m
             INNER JOIN language l ON (m.langid = l.langid)
             WHERE content_id = ' . $content_id
        );

        # get previous content_id if exists
        my $ans0 = do_query("
            SELECT content_id FROM editor_journal
            WHERE product_id = $product_id
            AND product_table = 'product_description'
            AND id <> $id
            AND product_table_id = $pt_id
            AND date <= $submit_date
            ORDER BY date DESC LIMIT 1
        ") if ($action != 1);

        #
        # get info about prev
        #
        my $ans2 = do_query('
            SELECT m.langid, m.short_desc, m.long_desc, m.official_url, m.warranty_info, m.pdf_url, m.manual_pdf_url, l.code,
            m.content_id
            FROM editor_journal_product_description m
            INNER JOIN language l ON (m.langid = l.langid)
            WHERE content_id = ' . $ans0->[0]->[0]
        ) if ($ans0->[0]->[0]);

        # unpack long_desc
        $ans1->[0]->[2] = ser_unpack($ans1->[0]->[2]);
        $ans2->[0]->[2] = ser_unpack($ans2->[0]->[2]);

        # delete description
        if ($action == 2) {
            $verdict = $ans2->[0]->[1] . " [" . $ans2->[0]->[7] . "]";

            # easy way to add popup for record
            # $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
            # $hash->{'h_changes'} = Dumper($ans2);

            return $verdict;
        }

        # insert description
        if ($action == 1) {
            $verdict = $ans1->[0]->[1] . " [" . $ans1->[0]->[7] . "]";
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my %cnt;

            if ($ans1->[0]->[0]) {
                $cnt{'langid'} = $ans1->[0]->[7] . " [" . $ans1->[0]->[0] . "]";
            }
            if ($ans1->[0]->[1]) {
                $cnt{'short_desc'} = $ans1->[0]->[1];
            }
            if ($ans1->[0]->[2]) {
                $cnt{'long_desc'} = $ans1->[0]->[2];
            }
            if ($ans1->[0]->[3]) {
                $cnt{'official_url'} = $ans1->[0]->[3];
            }
            if ($ans1->[0]->[4]) {
                $cnt{'warranty_info'} = $ans1->[0]->[4];
            }
            if ($ans1->[0]->[5]) {
                $cnt{'pdf_url'} = $ans1->[0]->[5];
            }
            if ($ans1->[0]->[6]) {
                $cnt{'manual_pdf_url'} = $ans1->[0]->[6];
            }

            # custom
            my $cust = get_and_unpack_custom_data('product_description', $content_id );
            if ($cust) {
                for (keys %$cust) {
                    $cnt{'###_' . $_} = $cust->{$_};
                }
            }

            $hash->{'h_changes'} = $make_table->(\%cnt);
            return $verdict;
        }

        # diff
        $verdict .= 'langid '           unless ($ans1->[0]->[0] eq $ans2->[0]->[0]);
        $verdict .= 'short_desc '       unless ($ans1->[0]->[1] eq $ans2->[0]->[1]);
        $verdict .= 'long_desc '        unless ($ans1->[0]->[2] eq $ans2->[0]->[2]);
        $verdict .= 'official_url '     unless ($ans1->[0]->[3] eq $ans2->[0]->[3]);
        $verdict .= 'warranty_info '    unless ($ans1->[0]->[4] eq $ans2->[0]->[4]);
        $verdict .= 'pdf_url '          unless ($ans1->[0]->[5] eq $ans2->[0]->[5]);
        $verdict .= 'manual_pdf_url '   unless ($ans1->[0]->[6] eq $ans2->[0]->[6]);

        if (! $verdict) {
            # log_printf(Dumper($ans1));
            # log_printf(Dumper($ans2));
            # Same records or unable to show difference
            return ''
        }

        $verdict =~ s/\s$//;
        $verdict = 'CHANGES(' . $verdict . ')';
        # $verdict .= '[' . . ']';

        # a-tag for popup
        if ($verdict) {
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
        }

        # make note about changes
        my $tmp = '';
        my %cnt;

        if ($verdict =~ /\blangid\b/) {
            $tmp .= "langid         : " . $ans2->[0]->[7] . " [" . $ans2->[0]->[0] . "] >>> " . $ans1->[0]->[7] . " [" . $ans1->[0]->[0] . "]<br>";
            $cnt{'langid'} = $ans2->[0]->[7] . " [" . $ans2->[0]->[0] . "] >>> " . $ans1->[0]->[7] . " [" . $ans1->[0]->[0] . "]";
        }
        if ($verdict =~ /\bshort_desc\b/) {
            $tmp .= "short_desc     : " . $ans2->[0]->[1] . " >>> " . $ans1->[0]->[1] . "<br>";
            $cnt{'short_desc'} = $ans2->[0]->[1] . " >>> " . $ans1->[0]->[1];
        }
        if ($verdict =~ /\blong_desc\b/) {
            $tmp .= "long_desc :<br>";
            my $diff = diff \($ans2->[0]->[2] . "\n"), \($ans1->[0]->[2] . "\n"), {
                # STYLE => 'Context',
            };

            # update diff for web
            # alt title for hunks
            # $diff =~ s/^@@ -(\d+).*@@$/=== Hunk from line : $1 ===/gm;
            $diff =~ s/\n/<br>/g;

            # add colors for diff
            $diff =~ s/
                    <br>-(.*?)(?=<br>)
                /
                    <br><span style="color: red;">-$1<\/span>
                /gmsx;

            $diff =~ s/
                    <br>\+(.*?)(?=<br>)
                /
                    <br><span style="color: green;">\+$1<\/span>
                /gmsx;

            $tmp .= $diff . "<br>";

            $cnt{'long_desc'} = $diff;
        }
        if ($verdict =~ /\bofficial_url\b/) {
            $tmp .= "official_url   : " . $ans2->[0]->[3] . " >>> " . $ans1->[0]->[3] . "<br>";
            $cnt{'official_url'} = $ans2->[0]->[3] . " >>> " . $ans1->[0]->[3];
        }
        if ($verdict =~ /\bwarranty_info\b/) {
            $tmp .= "warranty_info  : " . $ans2->[0]->[4] . " >>> " . $ans1->[0]->[4] . "<br>";
            $cnt{'warranty_info'} = $ans2->[0]->[4] . " >>> " . $ans1->[0]->[4];
        }
        if ($verdict =~ /\bpdf_url\b/) {
            $tmp .= "pdf_url        : " . $ans2->[0]->[5] . " >>> " . $ans1->[0]->[5] . "<br>";
            $cnt{'pdf_url'} = $ans2->[0]->[5] . " >>> " . $ans1->[0]->[5];
        }
        if ($verdict =~ /\bmanual_pdf_url\b/) {
            $tmp .= "manual_pdf_url : " . $ans2->[0]->[6] . " >>> " . $ans1->[0]->[6] . "<br>";
            $cnt{'manual_pdf_url'} = $ans2->[0]->[6] . " >>> " . $ans1->[0]->[6];
        }

        #
        # custom fields
        #

        # prev
        my $cust = get_and_unpack_custom_data('product_description', $ans2->[0]->[8] );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} = $cust->{$_};
            }
        }

        # current
        my $cust = get_and_unpack_custom_data('product_description', $content_id );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} .= " >>> " . $cust->{$_};
            }
            # remove empty
            for (keys %$cust) {
                if ($cnt{'###_' . $_} =~ /^(.*) >>> \1$/ )  {
                    $cnt{'###_' . $_} = undef;
                }
            }
        }

        $verdict = $rename_field->($verdict);
        $verdict =~ s!^CHANGES\((.*?)\)!$1!;

        $hash->{'h_changes'} = $make_table->(\%cnt);
        # $hash->{'h_changes'} = $tmp;

        return $verdict;
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product') {

        my $verdict = '';

        # get inserted
        my $ans1 = do_query("
            SELECT ejp.supplier_id, ejp.prod_id, ejp.catid, ejp.user_id, ejp.name, ejp.low_pic, ejp.high_pic, ejp.publish, ejp.public, ejp.thumb_pic, ejp.family_id, ejp.series_id, checked_by_supereditor
            FROM editor_journal_product ejp
            WHERE content_id = $content_id
        ");

        #
        # details
        #

        my $supplier_name_after = do_query("
	    SELECT name
	    FROM supplier
	    WHERE supplier_id = " . $ans1->[0]->[0]
        )->[0]->[0] if ($ans1->[0]->[0]);

        my $user_after = do_query("
    	    SELECT login
    	    FROM users
    	    WHERE user_id = " . $ans1->[0]->[3]
        )->[0]->[0] if ($ans1->[0]->[3]);

        my $cat_after = do_query("
    	    SELECT value
    	    FROM category
    	    INNER JOIN vocabulary USING (sid)
    	    WHERE catid = " . $ans1->[0]->[2] . " AND langid=1"
        )->[0]->[0] if ($ans1->[0]->[2]);

        my $family_after = do_query("
    	    SELECT value
    	    FROM product_family
    	    LEFT JOIN vocabulary USING (sid)
    	    WHERE family_id = " . $ans1->[0]->[10] . " AND langid=1"
        )->[0]->[0] if ($ans1->[0]->[10]);
        
        my $series_after = do_query("
    	    SELECT value
    	    FROM product_series
    	    LEFT JOIN vocabulary USING (sid)
    	    WHERE series_id = " . $ans1->[0]->[11] . " AND langid=1"
        )->[0]->[0] if ($ans1->[0]->[11]);

        $ans1->[0]->[10] = 1 if ($ans1->[0]->[10] == 0);
        $family_after = "None" if (($ans1->[0]->[10] == 1) || ($ans1->[0]->[10] == 0) );

        if ($action == 1) {
            $verdict = 'A product has been created';
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';

            my %cnt;

            $cnt{'supplier_id'} = $supplier_name_after . " [" . $ans1->[0]->[0] . "]";
            $cnt{'prod_id'} = $ans1->[0]->[1];
            $cnt{'catid'} = $cat_after . " [" . $ans1->[0]->[2] . "]";
            $cnt{'user_id'} = $user_after . " [" . $ans1->[0]->[3] . "]";
            $cnt{'name'} = $ans1->[0]->[4];
            $cnt{'low_pic'} = $ans1->[0]->[5];
            $cnt{'high_pic'} = $ans1->[0]->[6];
            $cnt{'publish'} = $ans1->[0]->[7];
            $cnt{'public'} = $ans1->[0]->[8];
            $cnt{'thumb_pic'} = $ans1->[0]->[9];
            $cnt{'family_id'} = $family_after . " [" . $ans1->[0]->[10] . "]";
            $cnt{'series_id'} = $series_after . " [" . $ans1->[0]->[11] . "]";
            $cnt{'checked_by_supereditor'} = $ans1->[0]->[12];

            #
            # custom fields
            #

            # current
            my $cust = get_and_unpack_custom_data('product', $content_id );
            for (keys %$cust) {
                $cnt{'###_' . $_} = $cust->{$_};
            }

            # remove empty custom
            for (keys %$cust) {
               if ($cnt{'###_' . $_} =~ /^\s*$/ )  {
                   $cnt{'###_' . $_} = undef;
               }
            }

            $verdict = $rename_field->($verdict);
            $hash->{'h_changes'} = $make_table->(\%cnt);

            return $verdict;
        }
        # else $action == 3 (no 'delete' operation for product general)

        # product_id = product_table_id, so this request is simplier than another ones
        my $ans2 = do_query("
            SELECT ejp.supplier_id, ejp.prod_id, ejp.catid, ejp.user_id, ejp.name, ejp.low_pic, ejp.high_pic, ejp.publish, ejp.public, ejp.thumb_pic, ejp.family_id,
            ej.content_id, ejp.series_id, ejp.checked_by_supereditor
            FROM editor_journal ej
            INNER JOIN editor_journal_product ejp ON (ej.content_id = ejp.content_id )
            WHERE ej.id <> $id
            AND ej.product_id = $product_id
            AND ej.product_table = 'product'
            AND ej.date <= $submit_date
            ORDER BY ej.date DESC LIMIT 1
        ");

        #
        # details
        #

        my $supplier_name_before = do_query("
    	    SELECT name
	        FROM supplier
	        WHERE supplier_id = " . $ans2->[0]->[0]
        )->[0]->[0] if ($ans2->[0]->[0]);

        my $user_before = do_query("
    	    SELECT login
    	    FROM users
    	    WHERE user_id = " . $ans2->[0]->[3]
        )->[0]->[0] if ($ans2->[0]->[3]);

        my $cat_before = do_query("
    	    SELECT value
    	    FROM category
    	    INNER JOIN vocabulary USING (sid)
    	    WHERE catid = " . $ans2->[0]->[2] . " AND langid=1"
        )->[0]->[0] if ($ans2->[0]->[2]);

        my $family_before = do_query("
    	    SELECT value
    	    FROM product_family
    	    LEFT JOIN vocabulary USING (sid)
    	    WHERE family_id = " . $ans2->[0]->[10] . " AND langid=1"
        )->[0]->[0] if ($ans2->[0]->[10]);
        
        my $series_before = do_query("
    	    SELECT value
    	    FROM product_series
    	    LEFT JOIN vocabulary USING (sid)
    	    WHERE series_id = " . $ans2->[0]->[12] . " AND langid=1"
        )->[0]->[0] if ($ans2->[0]->[12]);

        $ans2->[0]->[10] = 1 if ($ans2->[0]->[10] == 0);
        $family_before = "None" if ($ans2->[0]->[10] == 1);
        $series_before = "None" if ($ans2->[0]->[12] == 1);

        # diff
        $verdict .= 'supplier_id '  unless ($ans1->[0]->[0] eq $ans2->[0]->[0]);
        $verdict .= 'prod_id '      unless ($ans1->[0]->[1] eq $ans2->[0]->[1]);
        $verdict .= 'catid '        unless ($ans1->[0]->[2] eq $ans2->[0]->[2]);
        $verdict .= 'user_id '      unless ($ans1->[0]->[3] eq $ans2->[0]->[3]);
        $verdict .= 'name '         unless ($ans1->[0]->[4] eq $ans2->[0]->[4]);
        $verdict .= 'low_pic '      unless ($ans1->[0]->[5] eq $ans2->[0]->[5]);
        $verdict .= 'high_pic '     unless ($ans1->[0]->[6] eq $ans2->[0]->[6]);
        $verdict .= 'publish '      unless ($ans1->[0]->[7] eq $ans2->[0]->[7]);
        $verdict .= 'public '       unless ($ans1->[0]->[8] eq $ans2->[0]->[8]);
        $verdict .= 'thumb_pic '    unless ($ans1->[0]->[9] eq $ans2->[0]->[9]);
        $verdict .= 'family_id '    unless ($ans1->[0]->[10] eq $ans2->[0]->[10]);
        $verdict .= 'series_id '    unless ($ans1->[0]->[11] eq $ans2->[0]->[12]);
        $verdict .= 'checked_by_supereditor '    unless ($ans1->[0]->[12] eq $ans2->[0]->[13]);

        if (! $verdict) {
            # return "No changes for 'product' table";
            return "";
        };

        $verdict =~ s/\s$//;
        $verdict = 'CHANGES(' . $verdict . ')';

        # a-tag for popup
        if ($verdict) {
            $verdict .= ' <a id="ej_' . $id . '" onClick="showDiff(this)" >more</a>';
        }

        # make note about changes
        my %cnt;

        if ($verdict =~ /\bsupplier_id\b/) {
            $cnt{'supplier_id'} = $supplier_name_before . " [" . $ans2->[0]->[0] . "] >>> " . $supplier_name_after . " [" . $ans1->[0]->[0] . "]";
        }
        if ($verdict =~ /\bprod_id\b/) {
            $cnt{'prod_id'} = $ans2->[0]->[1] . " >>> " . $ans1->[0]->[1];
        }
        if ($verdict =~ /\bcatid\b/) {
            $cnt{'catid'} = $cat_before . " [" . $ans2->[0]->[2] . "] >>> " . $cat_after . " [" . $ans1->[0]->[2] . "]";
        }
        if ($verdict =~ /\buser_id\b/) {
            $cnt{'user_id'} = $user_before . " [" . $ans2->[0]->[3] . "] >>> " . $user_after . " [" . $ans1->[0]->[3] . "]";
        }
        if ($verdict =~ /\bname\b/) {
            $cnt{'name'} = $ans2->[0]->[4] . " >>> " . $ans1->[0]->[4];
        }
        if ($verdict =~ /\blow_pic\b/) {
            $cnt{'low_pic'} = $ans2->[0]->[5] . " >>> " . $ans1->[0]->[5];
        }
        if ($verdict =~ /\bhigh_pic\b/) {
            $cnt{'high_pic'} = $ans2->[0]->[6] . " >>> " . $ans1->[0]->[6];

            # add link if outdated image was removed to remote server
            if ($ans2->[0]->[6]) {
                $cnt{'high_pic'} .= "<br>";
                my $link = 'http://' . $atomcfg{'outdated_images_host'} . '/' . $atomcfg{'outdated_images_www_path'};
                $link .= get_name_from_url($ans2->[0]->[6]);
                $cnt{'high_pic'} .= "(outdated image: <a href='$link'>$link</a>)";
            }
        }
        if ($verdict =~ /\bpublish\b/) {
            $cnt{'publish'} = $ans2->[0]->[7] . " >>> " . $ans1->[0]->[7];
        }
        if ($verdict =~ /\bpublic\b/) {
            $cnt{'public'} = $ans2->[0]->[8] . " >>> " . $ans1->[0]->[8];
        }
        if ($verdict =~ /\bthumb_pic\b/) {
            $cnt{'thumb_pic'} = $ans2->[0]->[9] . " >>> " . $ans1->[0]->[9];
        }
        if ($verdict =~ /\bfamily_id\b/) {
            $cnt{'family_id'} = $family_before . " [" . $ans2->[0]->[10] . "] >>> " . $family_after . " [" . $ans1->[0]->[10] . "]";
        }
        if ($verdict =~ /\bseries_id\b/) {
            $cnt{'series_id'} = $series_before . " [" . $ans2->[0]->[12] . "] >>> " . $series_after . " [" . $ans1->[0]->[11] . "]";
        }
        if ($verdict =~ /\bchecked_by_supereditor\b/) {
            $cnt{'checked_by_supereditor'} = ($ans2->[0]->[13] == 1 ? "YES" : "NO") . " >>> " . ($ans1->[0]->[12] == 1 ? "YES" : "NO");
        }

        #
        # custom fields
        #

        # prev
        my $cust = get_and_unpack_custom_data('product', $ans2->[0]->[11] );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} = $cust->{$_};
            }
        }

        # current
        my $cust = get_and_unpack_custom_data('product', $content_id );
        if ($cust) {
            for (keys %$cust) {
                $cnt{'###_' . $_} .= " >>> " . $cust->{$_};
            }
        }

        # remove empty
        if ($cust) {
            for (keys %$cust) {
                if ($cnt{'###_' . $_} =~ /^(.*) >>> \1$/ )  {
                    $cnt{'###_' . $_} = undef;
                }
            }
        }

        $verdict = $rename_field->($verdict);
        $verdict =~ s!^CHANGES\((.*?)\)!$1!;

        $hash->{'h_changes'} = $make_table->(\%cnt);

        return $verdict;
    }
    # ------------------------------------------------------------------------
    elsif ($table eq 'product_related') {

        my $ans = do_query("
            SELECT rel_product_name, prod_id
            FROM editor_journal_product_related
            INNER JOIN editor_journal USING (content_id)
            WHERE content_id = $content_id
        ");

        if ($ans->[0]->[0]) {
            return $ans->[0]->[0] ." [" . $ans->[0]->[1] . "]";
        }
        else {
            return "[" . $ans->[0]->[1] . "]";
        }
    }
    # ------------------------------------------------------------------------
    else {
        return '--- UNKNOWN --- ' . $table;
    }

    return $value;
}

sub format_as_product_history_action {
    my ($value,$call,$field,$res,$hash) = @_;

    return 'insert' if ($value == 1);
    return 'delete' if ($value == 2);
    return 'update' if ($value == 3);
    return 'fake_update' if ($value == 4);
    return 'first_record' if ($value == 5);
    return '';
}

sub format_as_track_list_rule_prod_id{
	my ($value,$call,$field,$res,$hash) = @_;
	if($field eq 'rule_prod_id_html'){
		if($hash->{'is_reverse_rule'}){
			return ''
		}else{
			return $value;
		};
	}elsif($field eq 'rule_prod_id_rev'){
		if($hash->{'is_reverse_rule'}){
			return $value;
		}else{
			return '';
		};
	}else{
		return $value;
	}
}


sub format_as_track_list_hide_link{
	my ($value,$call,$field,$res,$hash) = @_;
	if($USER->{'user_group'} eq 'superuser' or $USER->{'login'} eq 'superilya'){
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field},{'bo_host'=>$atomcfg{'bo_host'}});
	}else{
		return '';
	}
}
sub format_as_track_list_hide_link_entrusted_editors{
	my ($value,$call,$field,$res,$hash) = @_;
	my $entusted_editor=do_query('SELECT 1 FROM track_list_entrusted_users WHERE user_id='.$USER->{'user_id'})->[0][0];	
	if($USER->{'user_group'} eq 'superuser' or $USER->{'login'} eq 'superilya' or $entusted_editor){
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{$field},{'bo_host'=>$atomcfg{'bo_host'}});
	}else{
		return '';
	}
}

sub format_as_track_product_rule_button{
	my ($value,$call,$field,$res,$hash) = @_;
	if($value){
		return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'submit_button_err'};
	}else{
		return repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'submit_button_ok'},{'track_list_id'=>$hash->{'track_list_id'}});
		#return $atoms->{$call->{'class'}}->{$call->{'name'}}->{'submit_button_ok'};
	}
}
sub format_as_sync_distri {
	my ($value,$call,$field,$res,$hash) = @_;
	return sync_all_distributors();
}

sub format_as_ok_not_ok_for_distri {
    my ($value,$call,$field,$res,$hash) = @_;

    # log_printf(Dumper(\%hin));

    my $did = $hin{'distributor_id'};

    return '---' if ($hash->{'source'} ne 'iceimport');
    if ($value == 0) {
        return '<span style="color: red;">NOT OK</span> ' . get_remote_distributor($did);
    }
    else {
        return '<span style="color: green;">OK</span>';
    }
}

sub format_as_product_lookup {

	my ($value,$call,$field,$res,$hash) = @_;
	my $products_max = 3; # maximum count of best products
	my $error1 = "<tr><td class=\"main info_bold\" align=\"center\"><span style=\"color: red;\">Sorry, but our best editors hadn't described any products like this</span></td></tr>";

	################# QUERY BLOCK ##########################################
	do_statement("DROP TEMPORARY TABLE IF EXISTS top_users");
	do_statement("DROP TEMPORARY TABLE IF EXISTS top_products");
	do_statement("DROP TEMPORARY TABLE IF EXISTS new_products");
	do_statement("CREATE TEMPORARY TABLE top_users (user_id INT(13), pdu INT(13), UNIQUE KEY (user_id))");
	do_statement("CREATE TEMPORARY TABLE top_products (product_id INT(13), user_id INT(13), fd INT(13), UNIQUE KEY (product_id), KEY (product_id,user_id))");
	do_statement("CREATE TEMPORARY TABLE new_products (product_id INT(13), user_id INT(13), UNIQUE KEY (product_id), KEY (product_id,user_id))");
	do_statement("INSERT INTO top_products (product_id, user_id, fd)
	    SELECT p.product_id, p.user_id, COUNT(*) FROM product p
	    JOIN product_feature pf USING (product_id)
	    JOIN category_feature cf ON cf.category_feature_id=pf.category_feature_id AND p.catid=cf.catid
	    JOIN feature f USING (feature_id)
	    WHERE p.supplier_id=$hash->{brand} AND p.catid=$hash->{ctgr} AND pf.value <> '' AND p.user_id > 1 AND p.product_id <> $value AND f.class=0
	    GROUP BY 1 ORDER BY 3 DESC");

	do_statement("INSERT INTO top_users (user_id, pdu)
	    SELECT p.user_id, COUNT(*) FROM product p
	    JOIN users u USING (user_id)
	    WHERE u.user_group IN  ('editor','supereditor','superuser')
	    GROUP BY 1 ORDER BY 2 DESC");

	do_statement("INSERT INTO new_products (product_id, user_id)
	    SELECT ej.product_id, ej.user_id FROM editor_journal ej
	    WHERE ej.product_table IN ('product', 'product_feature') AND ej.supplier_id=$hash->{brand} AND ej.catid=$hash->{ctgr} AND ej.date>=UNIX_TIMESTAMP('2010-01-01')
	    GROUP BY ej.product_id");

	my $top_query = "SELECT tp.product_id, tp.user_id, tp.fd, tu.pdu FROM top_products tp
	    JOIN new_products np USING (product_id)
	    JOIN top_users tu ON tu.user_id = np.user_id
	    ORDER BY 3 DESC LIMIT $products_max";

	my $products = do_query($top_query);

	return $error1 unless (scalar @$products);
	my $links;
	$links .= "<tr>
		<td class=\"main info_bold\" align=\"center\">
			Part code
		</td>
		<td class=\"main info_bold\" align=center>
			Name
		</td>
		<td class=\"main info_bold\" align=center>
			Editor
		</td>
		<td class=\"main info_bold\" align=center>
			Additional info
		</td>
	</tr>";
	for my $row (@$products) {
	    my $features_max = do_query("SELECT COUNT(*) FROM category_feature cf JOIN feature f USING (feature_id) WHERE cf.catid=$hash->{ctgr} and f.class=0")->[0]->[0];
	    my $prod = do_query("SELECT prod_id, name FROM product WHERE product_id = $row->[0]");
	    my $user = do_query("SELECT login FROM users WHERE user_id = $row->[1]")->[0]->[0];
	    my $descr_cnt = do_query("SELECT COUNT(*) FROM product_description WHERE product_id=$row->[0]")->[0]->[0];
	    $links .=
		    "<tr><td class=\"main info_bold\">
			    <a href=\"index.cgi?sessid=%%sessid%%;product_id=$row->[0];cproduct_id=$row->[0];tmpl=product_details.html\">$prod->[0]->[0]</a>
		    </td>
		    <td class=\"main info_bold\">
			    $prod->[0]->[1]
		    </td>
		    <td class=\"main info_bold\">
			    $user
		    </td>
		    <td class=\"main info_bold\">
			    Product has: <span style=\"color: Seagreen;\">$row->[2]</span> from <span style=\"color: Seagreen;\">$features_max</span> features described and  <span style=\"color: Seagreen;\">$descr_cnt</span> translated description(s); Editor described <span style=\"color: Seagreen;\">$row->[3]</span> products<br/>
		    </td></tr>";
	}

	return $links;
}

sub format_as_ean_login {
	my ($value,$call,$field,$res,$hash) = @_;
	my $login = do_query("select u.login from product_ean_codes pec JOIN editor_journal ej USING (product_id) JOIN editor_journal_product_ean_codes ejpec on ejpec.content_id=ej.content_id AND ejpec.ean_code=pec.ean_code JOIN users u ON u.user_id=ej.user_id WHERE pec.product_id=" . $call->{'call_params'}->{'product_id'} . " AND pec.ean_code =" . str_sqlize($hash->{'ean_code'}) . " group by pec.ean_code order by ej.date DESC")->[0]->[0];
	my $res = $login || 'Autoimport';
	return $res;
}

sub format_as_series {
	my ($value,$call,$field,$res,$hash) = @_;

	my $no_result = [1, 'None'];

	my $rows;
	my $product_id = $hin{'product_id'};
	my $langid = $call->{'call_params'}->{'langid'};
	if ( $product_id ) {
		my $scf = do_query("SELECT supplier_id, catid, family_id FROM product WHERE product_id=" . $product_id)->[0];
		my ( $supplier_id, $catid, $family_id ) = ( $scf->[0], $scf->[1], $scf->[2] );
		goto FAM_WRONG if ( $hin{'family_id'} && $family_id != $hin{'family_id'});
		if ( $supplier_id && $catid && $family_id && $langid ) {
			$rows =
				do_query("SELECT ps.series_id, v.value
					FROM product_series ps
					JOIN vocabulary v USING (sid)
					WHERE v.langid=" . $langid . " AND ps.supplier_id=" . $supplier_id . " AND ps.catid=" . $catid . " AND ps.family_id=" . $family_id . " AND ps.series_id <> 1 GROUP BY 1");
		}
	} 
	else {
		FAM_WRONG:
		my $supplier_id = $hin{'supplier_id'};
		my $catid = $hin{'catid'};
		my $family_id = $hin{'family_id'};
		if ( $supplier_id && $catid && $family_id && $langid ) {
			$rows =
				do_query("SELECT ps.series_id, v.value
					FROM product_series ps
					JOIN vocabulary v USING (sid)
					WHERE v.langid=" . $langid . " AND ps.supplier_id=" . $supplier_id . " AND ps.catid=" . $catid . " AND ps.family_id=" . $family_id . " AND ps.series_id <> 1 GROUP BY 1");
		}
	}

	my $result = [];

	push @$result, $no_result;

	for ( @$rows ) {
		push @$result, [$_->[0], $_->[1]];
	}

	$value = make_select(
		{
			'rows' => $result,
			'name' => $field,
			'sel' => $value
		}
	);

	return $value;
}

sub format_as_series_set {
	my ($value,$call,$field,$res,$hash) = @_;

	my $no_result =  [1, 'None'];

	my $supplier_id = $call->{'call_params'}->{'supplier_id'};
	my $catid = $call->{'call_params'}->{'category_id'};
	my $family_id = $call->{'call_params'}->{'family_id'};
	my $langid = $call->{'call_params'}->{'langid'};

	return unless ( $supplier_id && $catid && $family_id && $langid);

	my $ans =
		do_query("SELECT ps.series_id, v.value
			FROM product_series ps
			JOIN vocabulary v USING (sid)
			WHERE v.langid=" . $langid . " AND ps.supplier_id=" . $supplier_id . " AND ps.catid=" . $catid . " AND ps.family_id=" . $family_id . " AND ps.series_id <> 1 GROUP BY 1");

	my $rows = [];

	push @$rows, $no_result;

	for ( @$ans ) {
		push @$rows, [$_->[0], $_->[1]];
	}

	$res = make_select(
		{
			'rows' => $rows,
			'name' => $field
		}
	);

	return $res;
}

sub format_as_checked_by_supereditor {
	my ($value,$call,$field,$res,$hash) = @_;
	if( $USER->{'user_group'} eq 'supereditor' || $USER->{'user_group'} eq 'superuser' ) {
		return format_as_input_checkbox($value,$call,$field,$res,$hash);
	} else {
		return $value ? "<div style='color:green;'>YES</div>" : "<div style='color:red;'>NO</div>";
	}
}

1;

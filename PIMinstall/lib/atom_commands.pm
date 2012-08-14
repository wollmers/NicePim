package atom_commands;

#$Id: atom_commands.pm 3789 2011-02-04 13:33:32Z alexey $

use strict;

use atomcfg;
use atom_html;
use atomlog;
use atom_util;
use atom_misc;
use atomsql;
use atom_mail;
use data_management;
use feature_values;
use LWP::Simple;
use LWP::Simple qw($ua); $ua->timeout($atomcfg{'http_request_timeout'});
use Data::Dumper;
use Time::Local;
use MIME::Base64;
use thumbnail;
use icecat_util;
use icecat_mapping;
use process_manager qw(&run_bg_command &queue_process &get_running_perl_processes_number);
use Time::localtime;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::FmtUnicode;
use Encode qw/decode/;
use pricelist;
use coverage_report;
use serialize_data;
use SOAP::Lite;
use history;
use history_sql;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw(
		&command_proc_login_user
		&command_proc_refresh_user_cid
		&command_proc_product_copy
		&command_proc_product_delete_daemon

		&command_proc_merge_features
		&command_proc_merge_features_in_category
		&command_proc_change_product_category

		&command_proc_chown_nobody_products
		&command_proc_preview_apply_pattern
		&command_proc_preview_apply_localizations
		&command_proc_preview_apply_cat_pattern
		&command_proc_feature_group_delete_daemon
		&command_proc_feature_values_group_delete_daemon

		&command_proc_merge_categories
		&command_proc_merge_symbol

		&command_proc_create_mapping

		&command_proc_htpass_add_user

		&command_proc_family

		&command_proc_get_obj_url
		&command_proc_update_xml_due_product_update
		&command_proc_update_xmls_due_product_related_update
		&command_proc_update_score
		&command_proc_add_complaint_history
		&command_proc_post_complain
		&command_proc_update_complain

		&command_proc_update_language_flag
		&command_proc_mail_dispatch_prepare

		&command_proc_product_group_action
		&command_proc_product_complaint_group_action
		&command_proc_exec_clipboard_processing

		&command_proc_get_gallery_pic
		&command_proc_get_object_url
		&command_proc_add2editors_journal

		&command_proc_add_new_category_family
		&command_proc_delete_category_family
		&command_proc_add_related_batch
		&command_proc_add_related_batch_p
		&command_proc_insert_tab_feature_value
		&command_proc_insert_tab_name
		&command_proc_update_feature_chunk
		&command_proc_update_users_repo_access

		&command_proc_product2vendor_notification_queue

		&command_proc_add_new_supplier
		&command_proc_add_new_feature


		&command_proc_movement_value_regexp
		&command_proc_edit_value_regexp
		&command_proc_add_value_regexp
		&command_proc_del_value_regexp

		&command_proc_manage_relation_group
		&command_proc_manage_relation_rule
		&command_proc_manage_relation_set

		&command_proc_apply_measure_power_mapping

		&command_proc_lang_export
		&command_proc_distri_data_export
		&command_proc_distri_save_attrs
		&command_proc_lang_import
		&command_proc_imp_prev

		&command_proc_blacklist_update

		&command_proc_manage_campaign_kit
		&command_proc_manage_campaigns

		&command_proc_recreate_category_nestedset
		&command_proc_change_nestedset
		&command_proc_change_family_ns
		&command_proc_reupload_price_feed
		&command_proc_coverage_report_from_file

		&command_proc_send_email_about_custom_value_in_select

		&command_proc_update_sector_name_table
		&command_proc_delete_from_sector_table
		&command_proc_merge_sectors
		&command_proc_add_custom_sector

		&command_proc_merge_platforms
		&command_proc_platform_name_update
		&command_proc_platform_name_delete

		&command_proc_refresh_category_feature_intervals

		&command_proc_delete_from_virtual_category_table

		&command_proc_update_virtual_categories_for_product
		&command_proc_coverage_report_track_list
		&command_proc_add_tracklist_products
		&command_proc_update_track_product
		&command_proc_set_is_parked
		&command_proc_save_track_list_settings
		&command_proc_set_track_product_rule_prod_id
		&command_proc_get_track_list_report
		&command_proc_save_user_track_list_cols
		&command_proc_update_family_for_product

		&command_proc_update_default_warranty_info
		&command_proc_delete_default_warranty_info
		&command_proc_insert_default_warranty_info

		&command_proc_save_values_for_history_product
		&command_proc_save_values_for_history_product_description
		&command_proc_save_values_for_history_product_multimedia_object
		&command_proc_save_values_for_history_product_feature
		&command_proc_save_values_for_history_product_feature_local

		&command_proc_update_remote_distributor

		&command_proc_store_pics_origin
		&command_proc_store_pics_origin_mmo
		&command_proc_store_pics_origin_mmo_update
		&command_proc_store_pics_origin_gallery
		&command_proc_store_pics_origin_gallery_update

		&command_proc_update_pdf_origin_for_new_product_description

		&command_proc_track_product_all_group_action
		&command_proc_remove_stat_report
		&command_proc_remove_distri_pricelist
		&command_proc_set_distri_groupcode
		&command_proc_set_track_product_pair

		command_proc_add_new_product_restrictions
		command_proc_delete_existed_product_restrictions
		command_proc_delete_certain_product_restriction
		command_proc_update_certain_product_restriction
		&command_proc_dictionary_cleanup_html

		&command_proc_user_brands_manage
		&command_proc_brand_users_manage

		&command_proc_update_ds_measure_sign
		&command_proc_save_backup_languages
		&command_proc_add_track_product_rule
		&command_proc_set_entrusted_editor
		&command_proc_set_track_list_brand_map

		&command_proc_add_new_default_user_and_contact
		&command_proc_link_user_with_brand
		&command_proc_track_product_group_action
		&command_proc_delete_track_product_rule
		command_proc_series
		&command_proc_set_rating_formula
	);
}

sub command_proc_set_rating_formula{
	
	if(scalar(@user_errors)>1){
		return '';
	}
	my $formula=$hin{'formula'};
	my @allowed_vars=('stock','price','product_requested');
	for my $allowed_var (@allowed_vars){
		$formula=~s/$allowed_var/1/gsi;
	}
	my $result=&do_query('SELECT '.$formula)->[0][0];
	if(!$result){
		  push(@user_errors,'Formula is not valid');
		  return '';
	}
	$hin{'period'}=&trim($hin{'period'});
	if(!$hin{'period'} or $hin{'period'}!~/^[\d\.]+$/){
		  push(@user_errors,'Period is not valid');
		  return '';		
	}
	my $config_arr=&do_query("SELECT configuration FROM  data_source WHERE code='importance_index'")->[0];
	if(!$config_arr->[0]){
		&errmail('alexey@bintime.com','Data source importance_index does not exist. Rating is not working');
		return '';
	}
	my $config=$config_arr->[0];
	my ($last_formula,$last_period);
	my $formula_arr=get_rating_prop('formula',$config);
	if($formula_arr->[1]){# we have a lot of formulas
		&errmail('alexey@bintime.com','Configuration in importance_index is not valid. Rating is not working');
		return '';
	}
	$last_formula=$formula_arr->[0];
	my $period_arr=get_rating_prop('period',$config);
	if($period_arr->[1]){# we have a lot of periods
		&errmail('alexey@bintime.com','Configuration in importance_index is not valid. Rating is not working');
		return '';
	}
	$last_period=$period_arr->[0];	
	$config=~s/\Q$last_formula\E//i;
	$config=~s/\Q$last_period\E//i;
	$config=~s/[\n\s]*$//gs;
	
	$formula=$hin{'formula'};
	$config.="\nformula: ".$formula."\n".'period: '.$hin{'period'};
	&do_statement('UPDATE data_source SET configuration='.&str_sqlize($config)." WHERE code='importance_index'");
	if($hin{'save_start'}){
		use process_manager;
		my $import_pid=get_pid('data_source/Product_interest/import');
		`kill -9 $import_pid` if ($import_pid);
		&run_bg_command($atomcfg{'base_dir'}.'data_source/Product_interest/import '.$hin{'email'}.' &');
	}
	return 1;
}

sub command_proc_set_track_list_brand_map{
	my $supplier_id=$hin{'map_supplier_id'};
	$supplier_id='0' if !$hin{'map_supplier_id'};
	&do_statement('UPDATE track_list_supplier_map SET supplier_id='.$supplier_id.' WHERE track_list_supplier_map_id='.$hin{'track_list_supplier_map_id'});
	return 1;
}

sub command_proc_set_entrusted_editor{
	use track_lists;
	my @assigned_users=$hin{'REQUEST_BODY'}=~/occupied_user_id=([\d]+)/gs;
	&lp(Dumper(\@assigned_users));
	my $values='';
	my $insert_sql='INSERT INTO track_list_entrusted_users (user_id) VALUES ';		
	for my $user_id(@assigned_users){
		$values.=" ($user_id),";
			
	}
	$values=~s/,$//;
	&do_statement('TRUNCATE TABLE track_list_entrusted_users');
	if(scalar(@assigned_users)>0){
		&do_statement($insert_sql.$values);
	}
	return 1;
}

sub command_proc_add_track_product_rule{
	use track_lists;
	add_track_product_rule($hin{'track_product_id'});	
	return 1
}
sub command_proc_delete_track_product_rule{
	use track_lists;
	delete_track_product_rule($hin{'track_product_id'});	
	return 1
}

sub command_proc_link_user_with_brand {
	if ($hin{'atom_submit'}) {
		my $new_user_id = &do_query("select user_id from users where login=".&str_sqlize($hin{'login'}))->[0][0];
		log_printf("supplier_id = ".$hin{'link_supplier_id'});
		log_printf(Dumper(\%hin));
		if (($hin{'link_supplier_id'} =~ /^\d+$/) && ($new_user_id =~ /^\d+$/)) {
			log_printf("supplier_id = ".$hin{'link_supplier_id'}." and NEW user_id = ".$new_user_id ." are linked");
			&do_statement("insert into supplier_users(supplier_id, user_id) values(".$hin{'link_supplier_id'}.",".$new_user_id .")");
		}
	}

	return 1;
} # sub command_proc_link_user_with_brand

sub command_proc_add_new_default_user_and_contact {
	return 0 unless $hin{'name'};

	if ($hin{'supplier_id'}) {
		lp("new supplier is: ".$hin{'supplier_id'});
		my $s_user_id = &do_query("select user_id from users where login=".&str_sqlize(lc($hin{'name'})))->[0][0];
		unless ($s_user_id) {
			# contact creating
			&do_statement("insert into contact(person) values(".&str_sqlize($hin{'name'}).")");
			my $s_contact_id = &do_query("select last_insert_id()")->[0][0];

			# making pass
			my $newpass = `/usr/bin/makepasswd`;
			chomp($newpass);
			# creating a new user
			&do_statement("insert into users(login,user_group,password,pers_cid) values(".str_sqlize(lc($hin{'name'})).",'supplier',".str_sqlize($newpass).",".$s_contact_id.")");
			$s_user_id = &do_query("select last_insert_id()")->[0][0];
		}
		lp("new supplier has default user_id: ".$s_user_id);

		&do_statement("insert ignore into supplier_users(supplier_id,user_id) values(".$hin{'supplier_id'}.",".$s_user_id.")");
		&do_statement("update supplier set user_id = ".$s_user_id." where supplier_id = ".$hin{'supplier_id'});
	}

	return 1;
} # sub command_proc_add_new_default_user_and_contact

sub command_proc_brand_users_manage {
	if ($hin{'action'} eq 'add') {
		# check the consistency
		return 0 unless $hin{'user_id_new'};
		return 0 unless $hin{'supplier_id'};

		# add new supplier <-> user link
		&do_statement("insert IGNORE into supplier_users(supplier_id, user_id) values(".$hin{'supplier_id'}.",".$hin{'user_id_new'}.")");

		# check the supplier.user_id and add this if nothing else we have
		if (&do_query("select user_id from supplier where supplier_id = ".$hin{'supplier_id'})->[0][0] == 0) {
			&do_statement("update supplier set user_id = ".$hin{'user_id_new'}.", updated = updated where supplier_id = ".$hin{'supplier_id'});
		}
	}
	elsif ($hin{'action'} eq 'del') {

#		lp("DV = ".$hin{'user_id_cur'}.", ".$hin{'supplier_id'});

		# check the consistency
		return 0 unless $hin{'user_id_cur'};
		return 0 unless $hin{'supplier_id'};

		# add new supplier <-> user link
		&do_statement("delete from supplier_users where supplier_id = ".$hin{'supplier_id'}." and user_id = ".$hin{'user_id_cur'});

		# check the supplier.user_id and add this if nothing else we have
		if (&do_query("select user_id from supplier where supplier_id = ".$hin{'supplier_id'})->[0][0] == $hin{'user_id_cur'}) {
			&do_statement("update supplier set user_id = " . ( &do_query("select user_id from supplier_users where supplier_id = ".$hin{'supplier_id'}." order by user_id asc limit 1")->[0][0] || 0 ) . ", updated = updated where supplier_id = ".$hin{'supplier_id'});
		}
	}

	return 1;
} # sub command_proc_user_brands_manage

sub command_proc_user_brands_manage {
	if ($hin{'action'} eq 'add') {
		# check the consistency
		return 0 unless $hin{'supplier_id_new'};
		return 0 unless $hin{'edit_user_id'};

		# add new supplier <-> user link
		&do_statement("insert IGNORE into supplier_users(supplier_id, user_id) values(".$hin{'supplier_id_new'}.",".$hin{'edit_user_id'}.")");

		# check the supplier.user_id and add this if nothing else we have
		if (&do_query("select user_id from supplier where supplier_id = ".$hin{'supplier_id_new'})->[0][0] == 0) {
			&do_statement("update supplier set user_id = ".$hin{'edit_user_id'}.", updated = updated where supplier_id = ".$hin{'supplier_id_new'});
		}
	}
	elsif ($hin{'action'} eq 'del') {
		# check the consistency
		return 0 unless $hin{'supplier_id'};
		return 0 unless $hin{'edit_user_id'};

		# do not remove it!..
		return 0 if &do_query("select name from supplier where supplier_id = ".$hin{'supplier_id'})->[0][0] eq &do_query("select login from users where user_id = ".$hin{'edit_user_id'})->[0][0];

		# delete supplier <-> user link
		&do_statement("delete from supplier_users where supplier_id = ".$hin{'supplier_id'}." and user_id = ".$hin{'edit_user_id'});

		# update supplier.user_id, if user_id is absent in link table
		if ((&do_query("select count(*) from supplier where supplier_id = ".$hin{'supplier_id'}." and user_id = ".$hin{'edit_user_id'})->[0][0] > 0) &&
				(&do_query("select count(*) from supplier_users where supplier_id = ".$hin{'supplier_id'})->[0][0] > 0)) {
			&do_statement("update supplier s
set s.user_id = (select su.user_id from supplier_users su where su.supplier_id = ".$hin{'supplier_id'}." order by su.user_id asc limit 1),
s.updated = s.updated
where s.supplier_id = ".$hin{'supplier_id'});
		}
	}

	return 1;
} # sub command_proc_user_brands_manage

sub command_proc_update_ds_measure_sign{
	if($hin{'atom_update'} and scalar(@user_errors)<1){
		my @measure_keys=grep(/^measure_sign_[\d]+$/,keys(%hin));
		my $ds_feature_mapping_info_id;
		for my $measure_key(@measure_keys){
			if($measure_key=~/^measure_sign_([\d]+)$/){
				$ds_feature_mapping_info_id=$1;
			}else{
				next;
			}
			if($hin{$measure_key}){
				my $measure=$hin{$measure_key};
				$measure=~s/[\n\s\t]{2,}/\n/gs;
				my @measure_signs=split("\n",$measure);
				if(scalar(@measure_signs)>0){
					&do_statement('DELETE FROM data_source_feature_map_replaces WHERE data_source_feature_map_info_id='.$ds_feature_mapping_info_id);
				}
				for my $measure_sign (@measure_signs){
					&do_statement('INSERT INTO data_source_feature_map_replaces (value,data_source_feature_map_info_id) VALUES
								  ('.&str_sqlize($measure_sign).','.$ds_feature_mapping_info_id.')');

					#&do_statement('INSERT IGNORE INTO data_source_feature_map_replaces SET value='.&str_sqlize($measure_sign).',
					#			   data_source_feature_map_info_id='.$ds_feature_mapping_info_id);
				}
			}else{
				&do_statement('DELETE FROM data_source_feature_map_replaces WHERE data_source_feature_map_info_id='.$ds_feature_mapping_info_id);
			}
		}
		return 1;
	}elsif($hin{'atom_delete'} and scalar(@user_errors)<1){
		return 1;
	}else{
		return 1;
	}
}

sub command_proc_dictionary_cleanup_html{
	my @hin_keys=keys(%hin);
	for my $hin_key (@hin_keys){
		if($hin_key=~/^_rotate_html_[\d]+$/ and $hin{$hin_key}=~/<p>/gs and $hin{$hin_key}!~/<p\s[^>]+?>/gs){
			my @all_tags=$hin{$hin_key}=~/<[^\>\<]+?>/gs;
			my @p_tags=$hin{$hin_key}=~/<[\/]{0,1}p>/gs;
			if(scalar(@all_tags)==scalar(@p_tags)){
				$hin{$hin_key}=~s/<[\/]{0,1}p>//gs;
			}
		}
	}

	return 1;
}

sub command_proc_set_distri_groupcode {
	if (!$hin{'group_code'}) {
		$hin{'group_code'} = $hin{'code'};
	}
	else {
		my $exited_pl_id = &do_query('SELECT distributor_pl_id FROM distributor_pl WHERE code='.&str_sqlize($hin{'group_code'}))->[0][0];
		if ($exited_pl_id and scalar(@user_errors)<1) { # this is needed to avoid insertion of already existed group code and use updation instead of
			$hin{'distributor_pl_id'} = $exited_pl_id;
		}
	}

	return 1;
}

sub command_proc_remove_distri_pricelist {
	if ($hin{'atom_delete'} and $hin{'group_code'}) {
		my $needed_pricelists = &do_query('SELECT COUNT(*) FROM distributor WHERE group_code='.&str_sqlize($hin{'group_code'}))->[0][0];
		if ($needed_pricelists == 1) {
			&do_query('DELETE FROM distributor_pl WHERE code='.&str_sqlize($hin{'group_code'}));
		}
	}
	elsif ($hin{'atom_update'} and $hin{'group_code'}) {
		my $old_grop_code=&do_query('SELECT group_code FROM distributor WHERE distributor_id='.$hin{'distributor_id'})->[0][0];
		if ($hin{'group_code'} ne $old_grop_code) {
			my $needed_pricelists = &do_query('SELECT COUNT(*) FROM distributor WHERE group_code='.&str_sqlize($old_grop_code))->[0][0];
			if ($needed_pricelists == 1) {
				&do_query('DELETE FROM distributor_pl WHERE code='.&str_sqlize($old_grop_code));
			}
		}
	}

	return 1;
}

sub command_proc_platform_name_update {

	my $old_name = $hin{'platform_old_name'};
	$old_name =~ s/^\s+|\s+$//gs;
	return 0 unless $old_name;

	my $new_name = &do_query("select name from platform where platform_id = ".$hin{'platform_id'})->[0][0];
	$new_name =~ s/^\s+|\s+$//gs;
	return 0 unless $new_name;

	&do_statement("update users set platform=".&str_sqlize($new_name)." where platform=".&str_sqlize($old_name)." and platform != '' and ".&str_sqlize($new_name)." != ''");

} # sub command_proc_platform_name_update

sub command_proc_platform_name_delete {

	my $old_name = $hin{'platform_old_name'};
	$old_name =~ s/^\s+|\s+$//gs;
	return 0 unless $old_name;

	&do_statement("update users set platform='' where platform=".&str_sqlize($old_name)." and platform != ''");

} # sub command_proc_platform_name_delete

sub command_proc_merge_platforms {

#	log_printf("DV: init values ".$hin{'platforms_id2merge'}.", ".$hin{'platform_id_default'});

	# init values
	$hin{'platforms_id2merge'} =~ s/^,+|,+$//gs;
	$hin{'platforms_id2merge'} =~ s/,+/,/gs;

	return 0 if $hin{'platforms_id2merge'} !~ /^\d+(,\d+)*$/;

	my @list = split /,/, $hin{'platforms_id2merge'};
	my $default_platform = $hin{'platform_id_default'};

	my $defInTheList = 0;
	return 0 if $default_platform !~ /^\d+$/;
	# now, the def plaform is set!
#	log_printf("DV: default platform = ".$default_platform);

	# check for default in the list
	for (@list) {
		$defInTheList = 1 if $default_platform eq $_;
		return 0 unless /^\d+$/;
	}
	return 0 unless $defInTheList;
	# now, the list is set and def platform is the part of the list!
#	log_printf("DV: list of platforms to merge = " . (join ',', @list));

	# select the platform name of default platform
	my $platform_name = &do_query("select name from platform where platform_id=".$default_platform)->[0][0];
	return 0 unless $platform_name;
#	log_printf("DV: name of default platform is = " . $platform_name);

	# select the all others platform names
	my %namesList = map { $_->[0] => 1 } @{&do_query("select name from platform where platform_id in (" . (join ',', @list) . ")")};
#	log_printf("DV: hash = " . Dumper(\%namesList));

	# update the platform table
	&do_statement("delete from platform where platform_id in (" . (join ',', @list) . ") and platform_id != ".$default_platform);
#	log_printf("DV: delete platforms in platform = ". &do_query("select row_count()")->[0][0] ." times");

	# all ok, let's update the user table
	for (keys %namesList) {
		next if $platform_name eq $_;
		&do_statement("update users set platform=".&str_sqlize($platform_name)." where platform=".&str_sqlize($_)." and platform != ''");
#		log_printf("DV: update platforms in users (".$_.") = ". &do_query("select row_count()")->[0][0] ." times");
	}

} # sub command_proc_merge_platforms


sub command_proc_recreate_category_nestedset {
	use nested_sets;

	&log_printf("recreate category table");

	#&check_tree('category', 'catid', 'pcatid', 'force');

	&check_tree('category','catid','pcatid','','value',1,'vocabulary','sid');

} # sub command_proc_recreate_category_nestedset

sub command_proc_change_nestedset{
	use nested_sets;

	if($hin{'atom_update'}){

		my $old_cat=&do_query('SELECT catid,left_key,right_key,level FROM category_nestedset WHERE catid='.$hin{'catid'})->[0];
		my $parent=&do_query('SELECT catid,left_key,right_key,level FROM `category_nestedset`
							  WHERE left_key<'.$old_cat->[2].'. and right_key>'.$old_cat->[1].' and level='.$old_cat->[3].'-1')->[0];
			&delete_element('category','catid','pcatid',$hin{'catid'},'value','vocabulary','sid');
			&add_element('category','catid','pcatid', $hin{'pcatid'}, $hin{'catid'}, '1','value','','vocabulary','sid');# just in case
		if($parent->[0]!=$hin{'pcatid'}){#have to move
			&move_element('category', 'catid', 'pcatid',  $hin{'pcatid'}, $hin{'catid'},'value','vocabulary','sid');
		}
	}
	if($hin{'atom_delete'}){
		&delete_element('category','catid','pcatid', $hin{'catid'}, 'value','vocabulary','sid');
	}
	if($hin{'atom_submit'}){
		&add_element('category','catid','pcatid', $hin{'pcatid'}, $hin{'catid'}, '1','value','','vocabulary','sid');
	}

} # sub command_proc_change_nestedset

sub command_proc_change_family_ns{
	use nested_sets;
	if($hin{'atom_update'}){
		my $old_cat=&do_query('SELECT family_id,left_key,right_key,level FROM product_family_nestedset WHERE family_id='.$hin{'family_id'})->[0];
		my $parent=&do_query('SELECT family_id,left_key,right_key,level FROM `product_family_nestedset`
							  WHERE left_key<'.$old_cat->[2].'. and right_key>'.$old_cat->[1].' and level='.$old_cat->[3].'-1')->[0];
			&delete_element('product_family','family_id','parent_family_id',$hin{'family_id'},'value','vocabulary','sid');
			&add_element('product_family','family_id','parent_family_id', $hin{'parent_family_id'}, $hin{'family_id'}, '1','value','','vocabulary','sid');# just in case
		if($parent->[0]!=$hin{'parent_family_id'}){#have to move
			&move_element('product_family', 'family_id', 'parent_family_id',  $hin{'parent_family_id'}, $hin{'family_id'},'value','vocabulary','sid');
		}
	}
	if($hin{'atom_delete'}){
		&delete_element('product_family','family_id','parent_family_id', $hin{'family_id'}, 'value','vocabulary','sid');
	}
	if($hin{'atom_submit'}){
		&add_element('product_family','family_id','parent_family_id', $hin{'parent_family_id'}, $hin{'family_id'}, '1','value','','vocabulary','sid');
	}
	return 1;
}

sub command_proc_manage_campaigns {
	return 0 if (($USER->{'user_group'} ne "supplier") && ($USER->{'user_group'} ne "superuser"));
	return 0 unless $hin{'atom_delete'};

	&do_statement("delete ck from campaign_kit ck left join campaign c using (campaign_id) where c.campaign_id is null");
} # sub command_proc_manage_campaigns

sub command_proc_manage_campaign_kit {
	return 0 if (($USER->{'user_group'} ne "supplier") && ($USER->{'user_group'} ne "superuser"));

	my $action = '';
	if ($hin{'add_submit'}) {
		$action = 'add';
	}
	elsif ($hin{'del_submit'}) {
		$action = 'del';
	}
	elsif ($hin{'del_all_submit'}) {
		$action = 'del_all';
	}
	elsif ($hin{'landing_page_submit'}) {
		$action = 'landing_page';
	}

	my $id = $hin{'campaign_id'};
	my $supplier_id = &do_query("select group_concat(supplier_id separator ',') from supplier where user_id = ".$USER->{'user_id'}." group by user_id")->[0][0];

	if ($id) {
		if ($action eq 'add') {

			# now we get all products and add them to database, campaign_kit table (1,2,3,4)
			my $product_ids = &get_product_id_list_from_prod_id_set($hin{'prod_id'} || $hin{'prod_id_set'},{ 'supplier_id' => $supplier_id }); # returned { set, not defined }
			my $actually_added = &do_query("select count(*) from campaign_kit where campaign_id=".$id)->[0][0];

			for (split / /, $product_ids->{'set'}) {
				&do_statement("insert ignore into campaign_kit(campaign_id,product_id) values(".$id.",".$_.")");
				# stats
			}

			$actually_added = &do_query("select count(*) from campaign_kit where campaign_id=".$id)->[0][0] - $actually_added;
			$product_ids->{'found'} -= $actually_added;
			$hin{'campaign_warnings_text'} .= "<b>".$actually_added."</b> product" . ( $actually_added != 1 ? "s were" : " was" ) . " added to campaign<br />" if ($actually_added >=0 );
			$hin{'campaign_warnings_text'} .= "<b>".$product_ids->{'not_defined'}."</b> product" . ( $product_ids->{'not_defined'} != 1 ? "s were" : " was" ) . "n't defined in catalogue<br />" if $product_ids->{'not_defined'};
			$hin{'campaign_warnings_text'} .= "<b>".$product_ids->{'found'}."</b> product" . ( $product_ids->{'found'} != 1 ? "s have" : " has" ) . " already present in campaign<br />" if $product_ids->{'found'};
		}
		elsif ($action eq 'del') { # delete unnecessary products
			my $total = $hin{'product_found'};
			return 0 unless $total; # return if no products found

			# for all campaigns (1,2,3,4)
			my $deleted_number = 0;
			for (my $i=1; $i<= $total; $i++) {
				if ($hin{'product_'.$i.'_checkbox'}) {
					&do_statement("delete from campaign_kit where campaign_id = ".$id." and product_id = ".$hin{'product_'.$i});
					# stats
					$deleted_number += &do_query("select row_count()")->[0][0];
				}
			}
			$hin{'campaign_warnings_text'} .= "<b>".$deleted_number."</b> product" . ( $deleted_number != 1 ? "s were" : " was" ) . " removed from campaign<br />" if ($deleted_number >= 0);
		}
		elsif ($action eq 'del_all') { # delete ALL products
			my $total = $hin{'product_found'};
			return 0 unless $total; # return if no products found

			&do_statement("delete from campaign_kit where campaign_id = ".$id);
			my $deleted_number = &do_query("select row_count()")->[0][0];

			$hin{'campaign_warnings_text'} .= "<b>".$deleted_number."</b> product" . ( $deleted_number != 1 ? "s were" : " was" ) . " removed from campaign<br />" if ($deleted_number >= 0);
		}
		elsif ($action eq 'landing_page') {
			# landing page
			&do_statement("update campaign set link=".&str_sqlize($hin{'landing_page'})." where campaign_id=".$id);
		}

		if ($hin{'campaign_warnings_text'}) {
			$hin{'campaign_warnings_text'} = "<br><div class=\"campaign_warning\">".$hin{'campaign_warnings_text'}."</div>";
			$hin{'campaign_warnings_text_ignore_unifiedly_processing'} = 'Yes';
		}
	}
} # sub command_proc_manage_campaign_kit

sub command_proc_manage_relation_group {
	return 0 if (($USER->{'user_group'} ne "superuser") && ($USER->{'user_group'} ne "supereditor"));

	my $action = $hin{'manage_relation_group'};
	my $id = $hin{'relation_group_id'};
	if ($action eq 'del') {
		if ($id > 1) {

			# make group = 0
#			&do_statement('update relation set relation_group_id=0 where relation_group_id='.$id);

			# delete group and its relations
			my $r_ids = &do_query("select relation_id from relation where relation_group_id=".$id);
			&do_statement("drop temporary table if exists itmp_product2update");
			&do_statement("create temporary table itmp_product2update (product_id int(13) not null primary key)");

			my $prods;

			for (@$r_ids) {
				$prods = &get_product_relations_set_amount($_->[0], '', 1);
				&do_statement("insert ignore into itmp_product2update values (".join('),(',@$prods).")");
				$prods = &get_product_relations_set_amount($_->[0], '_2', 1);
				&do_statement("insert ignore into itmp_product2update values (".join('),(',@$prods).")");

				&_remove_relation($_->[0]);
			}

			&do_statement('delete from relation_group where relation_group_id='.$id);

			my $num = &process_manager::queue_processes('itmp_product2update', 1, 'update_products');

			$hin{'products2process_queue'} = $num;
			if ($hin{'products2process_queue'}) {
				$hin{'products2process_queue'} .= ' products added to process queue<br><br>';
			}
			else {
				$hin{'products2process_queue'} = '';
			}

			&do_statement("drop temporary table if exists itmp_product2update");
		}
	}
	elsif ($action eq 'edit') {
		if ($id > 1) {
			&do_statement('update relation_group set name='.&str_sqlize($hin{'name'}).', description='.&str_sqlize($hin{'description'}).' where relation_group_id='.$id);
		}
	}
	elsif ($action eq 'add') {
		chomp($hin{'name'});
		if ($hin{'name'}) {
			&do_statement('insert into relation_group(name,description) values('.&str_sqlize($hin{'name'}).','.&str_sqlize($hin{'description'}).')');
		}
	}
} # sub command_proc_manage_relation_group

sub _remove_relation {
	my ($id) = @_;

	return undef unless $id;

	my $ids = &do_query('select include_set_id, exclude_set_id, include_set_id_2, exclude_set_id_2 from relation where relation_id='.$id)->[0];
	for (0..3) {
		&do_statement('delete from relation_set where relation_set_id='.$ids->[$_]) if $ids->[$_];
	}

	&do_statement('delete from relation where relation_id='.$id);
} # sub

sub command_proc_manage_relation_rule {
	# safe using
	return 0 if (($USER->{'user_group'} ne "superuser") && ($USER->{'user_group'} ne "supereditor"));
	return 0 unless $hin{'relation_group_id'};

	my $action = $hin{'manage_relation_rule'};
	my $id = $hin{'relation_id'};
	if ($action eq 'del') {
		if ($id) {
			# move all products, that were in the rule - to the process queue - to clean them from formet x-sells (Jeroen's bug, 10.12.2009)
			&do_statement("drop temporary table if exists itmp_product2update_remove_relation");
			&do_statement("create temporary table itmp_product2update_remove_relation (product_id int(13) not null primary key)");
			my $prods = &get_product_relations_set_amount($hin{'relation_id'}, '', 1);
			&do_statement("insert ignore into itmp_product2update_remove_relation values (".join('),(',@$prods).")");
			$prods = &get_product_relations_set_amount($hin{'relation_id'}, '_2', 1);
			&do_statement("insert ignore into itmp_product2update_remove_relation values (".join('),(',@$prods).")");

			# remove relation with their set
			&_remove_relation($id);

			# move products to queue
			my $num = &process_manager::queue_processes('itmp_product2update_remove_relation', 1, 'update_products');

			&log_printf("The total number of moved to the queue products is ".$num);
		}
		&remove_old_rules;
	}
	elsif ($action eq 'edit') {
		if ($id) {
			&do_statement('update relation set name='.&str_sqlize($hin{'name'}).' where relation_id='.$id);
		}
	}
	elsif ($action eq 'add') {
		chomp($hin{'name'});
		if ($hin{'name'}) {
			&do_statement('insert into relation(name,relation_group_id) values('.&str_sqlize($hin{'name'}).','.$hin{'relation_group_id'}.')');
		}
	}
} # sub command_proc_manage_relation_rule

sub command_proc_manage_relation_set {
	# safe using
	return 0 if (($USER->{'user_group'} ne "superuser") && ($USER->{'user_group'} ne "supereditor"));
	return 0 unless $hin{'relation_group_id'};
	return 0 unless $hin{'relation_id'};

	# variables
	my ($relation_rule_ids, $ie_name, $ie_suffix, $ie_suffix_alt, $ie_id, $prods);

	# fix ProdId
	chomp($hin{'prodid'});

	# left_right
	if ($hin{'left_right'} != 1) {
		$hin{'left_right'} = 0;	$ie_suffix = '_2'; $ie_suffix_alt = '';
	}
	else {
		$hin{'left_right'} = 1;	$ie_suffix = ''; $ie_suffix_alt = '_2';
	}

	# include_exclude
	if ((!$hin{'include_exclude'}) && ($ie_suffix)) { # exclude & right part
		$hin{'include_exclude'} = 0; $ie_name = 'exclude_set_id'.$ie_suffix;
	}
	else { # all others
		$hin{'include_exclude'} = 1; $ie_name = 'include_set_id'.$ie_suffix;
	}

	## get all products - part 1

	# static one
	&do_statement("drop temporary table if exists itmp_product2update_1");
	&do_statement("create temporary table itmp_product2update_1 (product_id int(13) not null primary key)");
	$prods = &get_product_relations_set_amount($hin{'relation_id'}, $ie_suffix, 1);
	&do_statement("insert ignore into itmp_product2update_1 values (".join('),(',@$prods).")");

	# unstatic one
	&do_statement("drop temporary table if exists itmp_product2update_2");
	&do_statement("create temporary table itmp_product2update_2 (product_id int(13) not null primary key)");
	$prods = &get_product_relations_set_amount($hin{'relation_id'}, $ie_suffix_alt, 1);
	&do_statement("insert ignore into itmp_product2update_2 values (".join('),(',@$prods).")");

	# check for completeness
	if (($hin{'action'} eq 'add') || ($hin{'action'} eq 'edit')) {

		unless ($hin{'supplier'} || $hin{'category'}) { # only this combination
			if ($hin{'prodid'} eq '') { # prod_id can replace the whole rule! if prod_id, all other values should be null
				&process_atom_ilib('errors');
				&process_atom_lib('errors');
				push @user_errors, $atoms->{'default'}->{'errors'}->{'relation_are_too_global'};
				&atom_cust::proc_custom_processing_errors;
				return 0;
			}
		}

		# fix datas
		$hin{'start_date'} = &do_query("select unix_timestamp(".&str_sqlize($hin{'start_date'}).")")->[0][0] ? $hin{'start_date'} : '0000-00-00';
		$hin{'end_date'} = &do_query("select unix_timestamp(".&str_sqlize($hin{'end_date'}).")")->[0][0] ? $hin{'end_date'} : '0000-00-00';

		# fix values
		$hin{'supplier'} = $hin{'supplier'} || 0;
		if ($hin{'prodid'} ne '') { # avoid all values

			# check the prod_id completeness
			$hin{'prodid_set'} = &get_prod_ids_list($hin{'prodid'}, $hin{'action'} eq 'edit' ? 1 : 0);

			$hin{'supplierfamily'} = 0;
			$hin{'category'} = 0;
			$hin{'feature'} = 0;
			$hin{'featurevalue'} = '';
			$hin{'exact_value'} = 0;
		}
		else { # fix all values
			$hin{'supplierfamily'} = $hin{'supplierfamily'} || 0;
			$hin{'category'} = $hin{'category'} || 0;
			$hin{'feature'} = $hin{'feature'} || 0;
			$hin{'exact_value'} = $hin{'exact_value'} || 0;
			unless ($hin{'feature'}) {
				$hin{'featurevalue'} = '';
				$hin{'exact_value'} = 0;
			}
		}

		# get new_existed id
		$relation_rule_ids = &new_relation_rule_id;
	}

	# add or edit or del
	if ($hin{'action'} eq 'add') {
		for (@$relation_rule_ids) {
			$ie_id = &do_query('select '.$ie_name.' from relation where relation_id='.$hin{'relation_id'})->[0][0];
			if ($ie_id) { # existed set
				&do_statement('insert ignore into relation_set(relation_set_id,relation_rule_id) values('.$ie_id.','.$_.')');
			}
			else { # absent set
				$ie_id = &do_query('select max(relation_set_id) from relation_set')->[0][0] + 1;
				&do_statement('insert into relation_set(relation_set_id,relation_rule_id) values('.$ie_id.','.$_.')'); # the new rule set appears
				&do_statement('update relation set '.$ie_name.'='.$ie_id.' where relation_id='.$hin{'relation_id'});
			}
		}
	}
	elsif ($hin{'action'} eq 'edit') {
		&do_statement('update ignore relation_set set relation_rule_id='.$relation_rule_ids->[0].' where relation_rule_id='.$hin{'relation_rule_id'}.' and relation_set_id='.$hin{'relation_set_id'});
	}
	elsif ($hin{'action'} eq 'del') {
		&do_statement('delete from relation_set where relation_set_id='.$hin{'relation_set_id'}.' and relation_rule_id='.$hin{'relation_rule_id'});
		unless (&do_query('select count(*) from relation_set where relation_set_id='.$hin{'relation_set_id'})->[0][0]) {
			&do_statement('update relation set '.$ie_name.'=0 where relation_id='.$hin{'relation_id'});
		}
	}

	# remove all old rules
	if (($hin{'action'} eq 'edit') || ($hin{'action'} eq 'del')) {
		&remove_old_rules;
	}

	## get all products - part 2
	# unstatic one
	&do_statement("drop temporary table if exists itmp_product2update_3");
	&do_statement("create temporary table itmp_product2update_3 (product_id int(13) not null primary key)");
	$prods = &get_product_relations_set_amount($hin{'relation_id'}, $ie_suffix_alt, 1);
	&do_statement("insert ignore into itmp_product2update_3 values (".join('),(',@$prods).")");

	# remove all existed
	&do_statement("delete t2,t3 from itmp_product2update_2 t2 inner join itmp_product2update_3 t3 using (product_id)"); # intersection (xor)
	&do_statement("insert ignore into itmp_product2update_1 select * from itmp_product2update_3");
	&do_statement("insert ignore into itmp_product2update_1 select * from itmp_product2update_2");

	## show values and put products to queue
	my $num = &process_manager::queue_processes('itmp_product2update_1', 1, 'update_products');

	$hin{'products2process_queue'} = $num;
	if ($hin{'products2process_queue'}) {
    $hin{'products2process_queue'} .= ' products added to process queue<br><br>';
  }
  else {
    $hin{'products2process_queue'} = '';
  }

#	&log_printf("Total number of products to update = ".Dumper(&do_query("select p.product_id, p.prod_id, p.name from itmp_product2update_1 inner join product p using (product_id)")));

	&do_statement("drop temporary table if exists itmp_product2update_1");
	&do_statement("drop temporary table if exists itmp_product2update_2");
	&do_statement("drop temporary table if exists itmp_product2update_3");
} # sub command_proc_manage_relation_set

sub new_relation_rule_id {
	my $set = $hin{'prodid_set'}->[0] ? $hin{'prodid_set'} : [ $hin{'prodid'} ];
	my $out;

	for my $prod_id (@$set) {
		# add ALL product with same prod_id and many suppliers
		my $suppliers = $hin{'supplier'} ? [ [ $hin{'supplier'} ] ] : &do_query("select supplier_id from product where trim(prod_id) != '' and prod_id=".&str_sqlize($prod_id));
		$suppliers = [ [ 0 ] ] unless $suppliers->[0][0];

		for my $supplier (@$suppliers) {
			my $id = &do_query("select relation_rule_id from relation_rule where supplier_id=".$supplier->[0].
												 " and supplier_family_id=".$hin{'supplierfamily'}.
												 " and catid=".             $hin{'category'}.
												 " and feature_id=".        $hin{'feature'}.
												 " and feature_value=".     &str_sqlize($hin{'featurevalue'}).
												 " and exact_value=".       $hin{'exact_value'}.
												 " and prod_id=".           &str_sqlize($prod_id).
												 " and start_date=".        &str_sqlize($hin{'start_date'}).
												 " and end_date=".          &str_sqlize($hin{'end_date'}))->[0][0];

			unless ($id) { # insert new
				&do_statement("insert into relation_rule(supplier_id,supplier_family_id,catid,feature_id,feature_value,exact_value,prod_id,start_date,end_date) values(".
											$supplier->[0].",".
											$hin{'supplierfamily'}.",".
											$hin{'category'}.",".
											$hin{'feature'}.",".
											&str_sqlize($hin{'featurevalue'}).",".
											$hin{'exact_value'}.",".
											&str_sqlize($prod_id).",".
											&str_sqlize($hin{'start_date'}).",".
											&str_sqlize($hin{'end_date'}).")");
				$id = &do_query("select last_insert_id()")->[0][0];
			}
			push @$out, $id;
		}
	}

	return $out;
} # sub new_relation_rule_id

sub remove_old_rules {
	&do_statement("delete rr from relation_rule rr where (select count(*) from relation_set rs where rs.relation_rule_id=rr.relation_rule_id) = 0");
} # sub remove_odl_rules

sub command_proc_apply_measure_power_mapping {
	if ($hin{'power_mapping_apply'}) {
		my $already_have = &do_query("select t.measure_id, unix_timestamp()-t.start_date, u.login from value_regexp_bg_processes t inner join users u using (user_id) where t.measure_id=".$hin{'measure_id'})->[0];

		if ($already_have->[0]) { # if another process running per such measure - drop current process
			&process_atom_ilib('errors');
			&process_atom_lib('errors');
			push @user_errors, &repl_ph($atoms->{'default'}->{'errors'}->{'multiple_measure_map'},{'login'=>$already_have->[2],'secs'=>$already_have->[1]});
			&atom_cust::proc_custom_processing_errors;
		}
		else {
			&do_statement("update measure_value_regexp set active='Y' where measure_id=".$hin{'measure_id'});
			&log_printf("run in BG: ".$atomcfg{'base_dir'}.'bin/do_measure_power_mapping '.$hin{'measure_id'}." ".$USER->{'user_id'}." &");
			&run_bg_command($atomcfg{'base_dir'}.'bin/do_measure_power_mapping '.$hin{'measure_id'}." ".$USER->{'user_id'}." &");
		}
	}
} # sub command_proc_apply_measure_power_mapping

sub get_power_mapping_table_name {
	my $name;

	if ($hin{'atom_name'} eq 'measure_power_mapping') {
		$name = 'measure';
	}
	elsif ($hin{'atom_name'} eq 'feature_power_mapping') {
		$name = 'feature';
	}
	else {
		return undef;
	}

	return $name;
} # sub

sub command_proc_del_value_regexp {
	my $name = &get_power_mapping_table_name;

	return undef unless ($name);

	my $id2del = $hin{'id'};
	my $no2del = &do_query('select no from '.$name.'_value_regexp where id='.$id2del)->[0][0];
	&do_statement("delete from ".$name."_value_regexp where id=".$id2del);
	&do_statement("update ".$name."_value_regexp set no=no-1 where ".$name."_id=".$hin{$name.'_id'}." and no>".$no2del);

	# remove unused value_regexp
	&do_statement("delete vr from value_regexp vr where (
select count(*) from feature_value_regexp fvr where fvr.value_regexp_id=vr.value_regexp_id) +
(select count(*) from measure_value_regexp mvr where mvr.value_regexp_id=vr.value_regexp_id) = 0");
} # sub command_proc_del_value_regexp

sub command_proc_add_value_regexp {
	my $name = &get_power_mapping_table_name;

	return undef unless ($name);

	my $store_value = '';
	my $store_value_1 = '';
	my $store_value_2 = '';
	if ($hin{'id_type_add'} eq 'g') { # generic operation add
		return undef unless ($hin{'left_select_add'});
		$store_value = $hin{'left_select_add'};
		$store_value_1 = $hin{'right_variable_1_add'};
		$store_value_2 = $hin{'right_variable_2_add'};
		chomp($store_value);
		chomp($store_value_1);
		chomp($store_value_2);
	}
	elsif ($hin{'id_type_add'} eq 'p') { # pattern add
		return undef unless ($hin{'left_part_add'});
		$store_value = $hin{'left_part_add'}.'='.$hin{'right_part_add'};
	}

	# exists or present? get new value_regexp_id
	my $value_regexp_id = &do_query("select value_regexp_id from value_regexp where pattern=".&str_sqlize($store_value)." and parameter1=".&str_sqlize($store_value_1)." and parameter2=".&str_sqlize($store_value_2))->[0][0];
	unless ($value_regexp_id)  {
		&do_statement("insert into value_regexp(pattern,parameter1,parameter2) values(".&str_sqlize($store_value).",".&str_sqlize($store_value_1).",".&str_sqlize($store_value_2).")");
		$value_regexp_id = &do_query("select last_insert_id()")->[0][0];
	}

	# check no
	my $new_no = &do_query("select max(no) from ".$name."_value_regexp where ".$name."_id=".$hin{$name.'_id'})->[0][0];
	$new_no++;

	&do_statement("insert into ".$name."_value_regexp(value_regexp_id,".$name."_id,no) values(".$value_regexp_id.",".$hin{$name.'_id'}.",".$new_no.")");
} # sub command_proc_add_value_regexp

sub command_proc_edit_value_regexp {
	my $name = &get_power_mapping_table_name;

	return undef unless ($name);

	my $store_value = '';
	my $store_value_1 = '';
	my $store_value_2 = '';

	my $type = $hin{'id_type'};

	if ($type eq 'g') { # generic operation edit
		$store_value = $hin{'left_select'};
		$store_value_1 = $hin{'right_variable_1'};
		$store_value_2 = $hin{'right_variable_2'};
		chomp($store_value);
		chomp($store_value_1);
		chomp($store_value_2);
	}
	elsif ($type eq 'p') { # pattern edit
		$store_value = $hin{'left_part'}.'='.$hin{'right_part'};
	}

	# get id
	my $old_value_regexp_id = &do_query("select value_regexp_id from ".$name."_value_regexp where id=".$hin{$type.'_id'})->[0][0];

	# exists or present? get new value_regexp_id
	my $value_regexp_id = &do_query("select value_regexp_id from value_regexp where pattern=".&str_sqlize($store_value)." and parameter1=".&str_sqlize($store_value_1)." and parameter2=".&str_sqlize($store_value_2))->[0][0];
	unless ($value_regexp_id)  {
		&do_statement("insert into value_regexp(pattern,parameter1,parameter2) values(".&str_sqlize($store_value).",".&str_sqlize($store_value_1).",".&str_sqlize($store_value_2).")");
		$value_regexp_id = &do_query("select last_insert_id()")->[0][0];
	}

	# update if differs
	if ($value_regexp_id ne $old_value_regexp_id) {
		&do_statement("update ".$name."_value_regexp set value_regexp_id=".$value_regexp_id.", active='N' where id=".$hin{$type.'_id'});
	}

	# remove unused value_regexp
	&do_statement("delete vr from value_regexp vr where (
select count(*) from feature_value_regexp fvr where fvr.value_regexp_id=vr.value_regexp_id) +
(select count(*) from measure_value_regexp mvr where mvr.value_regexp_id=vr.value_regexp_id) = 0");
} # sub command_proc_edit_value_regexp

sub command_proc_movement_value_regexp {
	my $orderedList = $hin{'ordered_list'};

	my $i = 1;

#	&log_printf("orderedList = ".Dumper($orderedList));
#	&log_printf("hin = ".Dumper(\%hin));

	my $name = &get_power_mapping_table_name;

	return undef unless ($name);

	my @orderedListArr = split /;/, $orderedList;

	for (@orderedListArr) {
		next unless $_;
		&do_statement("update ".$name."_value_regexp set no=".$i." where id=".$_);
		$i++;
	}
} # sub command_proc_movement_value_regexp

sub command_proc_create_mapping {
	my $feature_id 				= $hin{'feature_id'};
	my $maintain_mapping 	= $hin{'maintain_mapping'};
	my $make_dropdown 		= $hin{'make_dropdown'};

	if ($USER->{'user_group'} eq 'superuser' ||
			$USER->{'user_group'} eq 'category_manager' ||
			$USER->{'user_group'} eq 'supereditor') {

		my $mapping = [];
		my $i = $hin{'feature_values_start_row'}+1;
		my ($db_old_value);
		while (defined $hin{'old_value_'.$i}) {
		  if (defined $hin{'new_value_'.$i}) {

				$hin{'old_value_'.$i} =~s/\&quot\;/\"/g;
				$hin{'old_value_'.$i} =~s/\&lt\;/\</g;
				$hin{'old_value_'.$i} =~s/\&gt\;/\>/g;
				$hin{'old_value_'.$i} =~s/\&ampe\;/\&/g;
				$hin{'old_value_'.$i} =~s/\&amp\;/\&/g;
				$hin{'old_value_'.$i} =~s/\\\\/\x01/g;
				$hin{'old_value_'.$i} =~s/\\n/\n/g;
				$hin{'old_value_'.$i} =~s/\x01/\\/g;

				$hin{'new_value_'.$i} =~s/\&quot\;/\"/g;
				$hin{'new_value_'.$i} =~s/\&lt\;/\</g;
				$hin{'new_value_'.$i} =~s/\&gt\;/\>/g;
				$hin{'new_value_'.$i} =~s/\&ampe\;/\&/g;
				$hin{'new_value_'.$i} =~s/([^\\])\\n/$1\n/g;
				$hin{'new_value_'.$i} =~s/\\\\/\x01/g;
				$hin{'new_value_'.$i} =~s/\x01/\\/g;
				$hin{'new_value_'.$i} =~s/\\n/\n/g;
				$db_old_value=&do_query('SELECT value FROM product_feature WHERE product_feature_id='.$hin{'old_product_feature_id_'.$i})->[0][0];								
				if ($db_old_value ne $hin{'new_value_'.$i}) {					
					&log_printf("pushing ".$hin{'old_value_'.$i}." => ".$hin{'new_value_'.$i});
					if($hin{'new_value_'.$i}){
						$hs{'new_value_hand_'.$i}=$hin{'new_value_'.$i};
					}
				}
				push @$mapping, { 'ext_value' => $db_old_value,
								  'int_value' => $hin{'new_value_'.$i},
								  'old_post_value' => $hin{'old_value_'.$i},
								  'product_feature_id' => $hin{'old_product_feature_id_'.$i},
								   };
												   
			}
			$i++;
		}
		&create_feature_values_mapping($feature_id, $mapping, $maintain_mapping, $make_dropdown);
		&apply_feature_values_mapping($feature_id, $mapping, $maintain_mapping, $make_dropdown);
		return 1;
	}
}

sub command_proc_merge_categories
{
	my ($src_catid, $dst_catid) = ($hin{'src_catid'}, $hin{'dst_catid'}) ;
	if($src_catid != $dst_catid &&
	   $src_catid && $dst_catid &&
		 $USER->{'user_group'} eq 'superuser' &&
		 $hin{'atom_submit'}){

		 		 &merge_categories($src_catid, $dst_catid);
		 		 use nested_sets;
				 &merge_elements('category', 'catid', 'catid', $src_catid, $dst_catid, 'value','vocabulary','sid');
				 return 1;

		 }
}

sub command_proc_merge_symbol {
	my ($type);
	if ($hin{'tmpl'} =~ /category/) {
		$type = 'category';
	}
	elsif ($hin{'tmpl'} =~ /supplier/) {
		$type = 'supplier';
	}
	else {
		return 1;
	}

	my ($id, $symbol) = ($hin{"data_source_".$type."_map_id"}, $hin{'symbol'});
	my (@ids);
	if (defined $hin{'merge_symbols'} &&
			($hin{'atom_submit'} || $hin{'atom_update'}) &&
			$hin{'data_source_id'} &&
			( $USER->{'user_group'} eq 'supereditor' ||
				$USER->{'user_group'} eq 'category_manager' ||
				$USER->{'user_group'} eq 'superuser' )) {
		for (my $i=1; $i<=$hin{'row_count'}; $i++) {
			if ($hin{'row_'.$i} && $hin{'row_'.$i.'_item'} != $id) {
				push @ids, $hin{'row_'.$i.'_item'};
			}
		}
		if ($#ids > -1) {
			&do_statement("delete from data_source_".$type."_map where data_source_".$type."_map_id in (".join(",",@ids).")");
#			&do_statement("update data_source_".$type."_map set distributor_id=0 where data_source_".$type."_map_id=".$id);
		}
	}
	return 1;
}

sub command_proc_change_product_category {
	if ($hin{'product_id'}) {
		if (($hin{'old_catid'} ne $hin{'catid'}) &&	($hin{'atom_update'})) {
			&conform_product_feature_catid($hin{'product_id'});
		}
	}
	return 1;
}

sub command_proc_preview_apply_cat_pattern
{
# this is usd to show categories mappings that are covered
# by the current map(it may include '*' signs);

if($hin{'reload'} && $hin{'data_source_id'}){

	&process_atom_ilib('data_source_category_map');
	&process_atom_lib('data_source_category_map');

	my $tmp = $atoms->{'default'}->{'data_source_category_map'}->{'preview_body'};

	my $body = '';

	my $preview_row = $atoms->{'default'}->{'data_source_category_map'}->{'preview_row'};

	my $data_source_id = $hin{'data_source_id'};
	my $pattern = $hin{'symbol'};
	my $distributor_id = $hin{'distributor_id'};
	my $data_source_category_map_id = $hin{'data_source_category_map_id'};

	my $data = &do_query("select symbol, data_source_category_map_id from data_source_category_map where data_source_id = ".&str_sqlize($data_source_id)." and distributor_id=".$distributor_id." order by symbol");

	for my $row(@$data){
	  my $value = $row->[0];
		my $m_value = &match_cat_symbol_regexp($pattern, $value);

	  if($m_value ne $value){
		 $body .= &repl_ph($preview_row, {'value' => &str_htmlize($value) });
		}
	}
	$hin{'preview_body'} = &repl_ph($tmp, {'preview_rows' => $body });

return 1;
}

if( ($hin{'atom_submit'} || $hin{'atom_update'}) && $hin{'data_source_id'} &&
    (  $USER->{'user_group'} eq 'supereditor' ||
	$USER->{'user_group'} eq 'category_manager' ||
	   	 $USER->{'user_group'} eq 'superuser' )
 ){

	my $data_source_id = $hin{'data_source_id'};
	my $pattern = $hin{'symbol'};
	my $distributor_id = $hin{'distributor_id'};
	my $data_source_category_map_id = $hin{'data_source_category_map_id'};

	my $data = &do_query("select symbol, data_source_category_map_id from data_source_category_map where data_source_id = ".&str_sqlize($data_source_id)." and distributor_id=".$distributor_id." order by symbol");

	for my $row(@$data){
	  my $value = $row->[0];
		my $m_value = &match_cat_symbol_regexp($pattern, $value);

	  if($m_value ne $value && $data_source_category_map_id ne $row->[1]){
     &delete_rows('data_source_category_map', " data_source_category_map_id = ".$row->[1]);
		}
	}


return 1;
}

return 1;
}

sub command_proc_preview_apply_localizations {
	if ($hin{'apply'}) {
		#&log_printf("start copying localizations\n");
		if (($USER->{'user_group'} ne 'supereditor') &&
				($USER->{'user_group'} ne 'superuser')) { return 0; }

		for (my $i = 1; $i<=$hin{'last_row'}; $i++) {
	    if ($hin{'row_'.$i}) {
#		&log_printf("\tcopying $hin{'product_id'} to $hin{'row_'.$i.'_item'}\n");
				my $dest_prod;
				$dest_prod->{'product_id'} = $hin{'row_'.$i.'_item'};
				$dest_prod->{'prod_id'} = $hin{'row_'.$i.'_item2'};
				my $shadow = {};
				if ($hin{'change_owner'}=='1') {
					$dest_prod->{'user_id'} = $USER->{'user_id'};
				}
				else {
					$shadow->{'user_no_change'} = 1;
				}
				$shadow->{'ean_codes'} = 1;
				&copy_product($hin{'product_id'},$dest_prod,'UPDATE',$shadow);
	    }
		}
	}
	else {
		#&log_printf("\%hin = ".Dumper($USER));

		my $tmp = '';
		my $localization_rows = '';
		my $lrow;

		&process_atom_ilib('product_update_localizations');
		&process_atom_lib('product_update_localizations');

		$tmp = $atoms->{'default'}->{'product_update_localizations'}->{'localization_body'};
		my $apply_submit = $atoms->{'default'}->{'product_update_localizations'}->{'apply_submit'};
		my $apply_void = $atoms->{'default'}->{'product_update_localizations'}->{'apply_void'};
		my $localization_row = $atoms->{'default'}->{'product_update_localizations'}->{'localization_row'};
		my $localization_disable_row = $atoms->{'default'}->{'product_update_localizations'}->{'localization_disable_row'};
		my $data = &do_query("select distinct s.supplier_id,s.name,p.prod_id,s.template from supplier as s left join product as p on p.supplier_id = s.supplier_id where p.product_id = '".$hin{'product_id'}."'");
		my $supplier_id = $data->[0][0];
		my $supplier_name = $data->[0][1];
		my $prod_id = $data->[0][2];
		my @templs = split("\n",$data->[0][3]);
		my $regexps = '';

		if ($#templs>-1) {
	    for my $template (@templs) {
				$template =~ s/\s+//;
				my $lr = str_unsqlize($template);
				if ($lr eq '') { next; }
				$prod_id =~ /(.*)$lr$/;
				my $prod_id_main = $1;
				if ($prod_id_main eq '') { $prod_id_main = $prod_id; }
				$lr = regexp2mysql($lr);
				$regexps .= " prod_id REGEXP '^".$prod_id.$lr."\$' or";
				$regexps .= " prod_id REGEXP '^".$prod_id."\$' or";
				$regexps .= " prod_id REGEXP '^".$prod_id_main.$lr."\$' or";
				$regexps .= " prod_id REGEXP '^".$prod_id_main."\$' or";
	    }
		}
		if ($regexps eq '') {
	    $hin{'apply_body'} = $apply_void;
			$hin{'apply_body_ignore_unifiedly_processing'} = 'Yes';
	    return 0;
		}

		chop($regexps);
		chop($regexps);

		my $numlocals = &do_query("select count(product_id) from product where supplier_id = '".$supplier_id."' and (".$regexps.")")->[0][0];
		$data = &do_query("select product_id,prod_id,name from product where supplier_id = '".$supplier_id."' and (".$regexps.") order by prod_id limit 30");
		if (int($numlocals)>int($#$data+1)) {
	    &process_atom_ilib('errors');
	    &process_atom_lib('errors');
	    push @user_errors, &repl_ph($atoms->{'default'}->{'errors'}->{'pattern_invalid'},{'num'=>$numlocals});
	    &atom_cust::proc_custom_processing_errors;
		}

		my $num = 0;
		for my $row(@$data) {
	    if ($row->[0] == $hin{'product_id'}) {
				$lrow = $localization_disable_row;
	    }
	    else {
				$lrow = $localization_row; $num++;
	    }
	    $localization_rows .= &repl_ph($lrow,{'no' => $num,
																						'nos' => $#$data,
																						'product_id' => $row->[0],
																						'prod_id' => $row->[1],
																						'name' => $row->[2]});
		}

		if ($num > 0) {
	    $hin{'localization_body'} = &repl_ph($tmp, {'localization_rows' => $localization_rows, 'nos' => $#$data});
	    $hin{'apply_body'} = $apply_submit;
	    $hin{'nos'} = $#$data;
		}

		$hin{'localization_body_ignore_unifiedly_processing'} = 'Yes';
		$hin{'nos_ignore_unifiedly_processing'} = 'Yes';
		$hin{'apply_body_ignore_unifiedly_processing'} = 'Yes';

		return 0;
	}
}

sub command_proc_preview_apply_pattern {
	&process_atom_ilib('product_map');
	&process_atom_lib('product_map');

	my $tmp = $atoms->{'default'}->{'product_map'}->{'preview_body'};
	my $preview_row = $atoms->{'default'}->{'product_map'}->{'preview_row'};
	my $preview_row_best = $atoms->{'default'}->{'product_map'}->{'preview_row_best'};
	my $preview_separator = $atoms->{'default'}->{'product_map'}->{'preview_separator'};

	my $stat_row = $atoms->{'default'}->{'product_map'}->{'stat_row'};
	my $statistics = $atoms->{'default'}->{'product_map'}->{'statistics'};


	my ($stat_u, $stat_d, $preview_rows, $type, $mapped_flag);


	if($hin{'reload'}) {
		$type = 'preview';
		$hin{'visible'} = '';
	}
	elsif (($hin{'atom_submit'} || $hin{'atom_update'}) && $hin{'atom_name'} eq 'product_map' && (($USER->{'user_group'} eq 'superuser') || ($USER->{'user_group'} eq 'supereditor'))) {
		$type = 'update';
		$hin{'visible'} = 'none';
	}

	&do_statement("drop temporary table if exists itmp_product2map");
	&do_statement("create temporary table itmp_product2map (
product_id int(13) not null default 0,
prod_id varchar(60) not null default '',
supplier_id int(13) not null default 0,
unique key (product_id),
key (prod_id, supplier_id),
key (supplier_id))");
	&do_statement("alter table itmp_product2map disable keys");
	&do_statement("insert into itmp_product2map(product_id,prod_id,supplier_id) select product_id, prod_id, supplier_id from product" . ( $hin{'supplier_id'} ? " where supplier_id = ".$hin{'supplier_id'} : "" ));
	&do_statement("alter table itmp_product2map enable keys");

	&prod_id_mapping({'table' => 'itmp_product2map', 'pattern' => $hin{'pattern'}, 'supplier_id' => $hin{'supplier_id'}, 'dest_supplier_id' => $hin{'dest_supplier_id'}});

	&do_statement("DROP TEMPORARY TABLE IF EXISTS `itmp_product`");
	&do_statement("CREATE TEMPORARY TABLE `itmp_product` (
            `product_id`      int(13)         NOT NULL DEFAULT '0',
            `prod_id`         varchar(60)     NOT NULL DEFAULT '',
            `old_prod_id`     varchar(60)     NOT NULL DEFAULT '',
            `supplier_id`     int(13)         NOT NULL DEFAULT '0',
            `old_supplier_id` int(13)         NOT NULL DEFAULT '0',
            `mapped`          int(13)         NOT NULL DEFAULT '0',
            PRIMARY KEY(`product_id`),
            key (prod_id,supplier_id),
            key (supplier_id),
            key (old_supplier_id, supplier_id),
            key (mapped, product_id, supplier_id, old_supplier_id))");

	&do_statement("alter table itmp_product DISABLE KEYS");

	if ($hin{'supplier_id'}) {
		$hin{'dest_supplier_id'} = 0 unless $hin{'dest_supplier_id'};
		&do_statement("INSERT INTO itmp_product (product_id, prod_id, old_prod_id, supplier_id, old_supplier_id) SELECT product_id, prod_id, prod_id, supplier_id, supplier_id FROM product where supplier_id in (".$hin{'supplier_id'}.",".$hin{'dest_supplier_id'}.") and supplier_id!=0");
	}
	else {
		&do_statement("INSERT INTO itmp_product (product_id, prod_id, old_prod_id, supplier_id, old_supplier_id) SELECT product_id, prod_id, prod_id, supplier_id, supplier_id FROM product where supplier_id!=0");
  }

	&do_statement("alter table itmp_product ENABLE KEYS");

	&do_statement("UPDATE itmp_product tp INNER JOIN itmp_product2map tpim ON tp.product_id = tpim.product_id SET tp.prod_id = tpim.map_prod_id, tp.supplier_id = tpim.map_supplier_id");

	&do_statement("UPDATE itmp_product tp INNER JOIN itmp_product2map tpim ON tp.prod_id = tpim.map_prod_id AND tp.supplier_id = tpim.map_supplier_id SET tp.mapped = 1 where tpim.prod_id != tpim.map_prod_id or tpim.supplier_id != tpim.map_supplier_id");

	my $prods = &do_query("SELECT tp.prod_id, tp.supplier_id, tp.product_id, tp.old_prod_id, p.user_id, u.user_group, u.login, s.name, s2.name, tp.old_supplier_id

FROM itmp_product tp
inner join product p using (product_id)
inner join users u using (user_id)
left  join supplier s on s.supplier_id=tp.old_supplier_id
left  join supplier s2 on s2.supplier_id=tp.supplier_id

where tp.mapped=1 order by tp.prod_id, tp.supplier_id");

	my ($s_id, $p_id, $ar, $q);
	$s_id = 0; $p_id=''; $ar = [];

	for my $prod (@$prods,(['',0])) {

#		&log_printf("DV: ".$s_id." ".$prod->[1].", ".$p_id." ".$prod->[0]);

		unless (($s_id == $prod->[1]) && ($p_id eq $prod->[0]) && ($s_id != 0)) { # another one product

#			&log_printf("DV: NEXT!..");

			&solve_product_ambugiuty($ar);

			for my $p (sort { $a->{'best'} <=> $b->{'best'} } @$ar) {
				if ($type eq 'preview') {
					if ($p->{'best'}) {
						$preview_rows .= &repl_ph($preview_row_best, {'supplier_name' => $p->{'supplier_name'}, 'm_supplier_name' => $p->{'map_supplier_name'}, 'm_prod_id' => $p->{'prod_id'}, 'old_prod_id' => $p->{'old_prod_id'}, 'login' => $p->{'login'}, 'user_group' => $p->{'user_group'}});
						$preview_rows .= $preview_separator;
					}
					else {
						$preview_rows .= &repl_ph($preview_row, {'supplier_name' => $p->{'supplier_name'}, 'm_supplier_name' => $p->{'map_supplier_name'}, 'm_prod_id' => $p->{'prod_id'}, 'old_prod_id' => $p->{'old_prod_id'}, 'login' => $p->{'login'}, 'user_group' => $p->{'user_group'}});
					}

					$mapped_flag = 1;
				}
				elsif ($type eq 'update') {
					if ($p->{'best'}) { # update only
						if (($p->{'prod_id'} ne $p->{'old_prod_id'}) || ($p->{'supplier_id'} ne $p->{'old_supplier_id'})) {
							&do_statement("update product set prod_id=trim(".&str_sqlize($p->{'prod_id'})."), supplier_id=".$p->{'supplier_id'}." where product_id=".$p->{'product_id'});
						}

						$stat_u .= &repl_ph($stat_row, {
							'supplier_name' => $p->{'supplier_name'},
							'm_supplier_name' => $p->{'map_supplier_name'},
							'm_prod_id' => $p->{'prod_id'},
							'old_prod_id' => $p->{'old_prod_id'},
							'login' => $p->{'login'},
							'user_group' => $p->{'user_group'}
																});
						$stat_u .= $preview_separator;

					}
					else { # delete
						&do_statement("delete from product where product_id=".$p->{'product_id'});
						##!!!!
						$stat_d .= &repl_ph($stat_row, {
							'supplier_name' => $p->{'supplier_name'},
							'm_supplier_name' => $p->{'map_supplier_name'},
							'm_prod_id' => $p->{'prod_id'},
							'old_prod_id' => $p->{'old_prod_id'},
							'login' => $p->{'login'},
							'user_group' => $p->{'user_group'}
																});
						$stat_d .= $preview_separator;

					}
				}
      }

			$#$ar = -1;
		}

		push @$ar, {
			"prod_id"           => $prod->[0],
			"supplier_id"       => $prod->[1],
			"product_id"        => $prod->[2],
			"old_prod_id"       => $prod->[3],
			"user_id"           => $prod->[4],
			"user_group"        => $prod->[5],
			"login"             => $prod->[6],
			"supplier_name"     => $prod->[7],
			"map_supplier_name" => $prod->[8],
			"old_supplier_id"   => $prod->[9]
		};

		# save old values
		$s_id = $prod->[1];
		$p_id = $prod->[0];

		last if (($s_id == 0) && ($p_id eq ''));

	}

	# last steps

	if ($mapped_flag)	{
		if ($hin{'product_map_id'}) {
			$hin{'update_action'} = $atoms->{'default'}->{'product_map'}->{'update_action'};
			$hin{'update_action_ignore_unifiedly_processing'} = 'Yes';
		}
		else {
			$hin{'insert_action'} = $atoms->{'default'}->{'product_map'}->{'insert_action'};
			$hin{'insert_action_ignore_unifiedly_processing'} = 'Yes';
		}
	}

	if ($type eq 'update') {
		$hin{'preview_body'} .= &repl_ph($statistics, { 'action' => 'Updated products','statistics' => $stat_u}) if ($stat_u ne '');
		$hin{'preview_body'} .= &repl_ph($statistics, { 'action' => 'Deleted products','statistics' => $stat_d}) if ($stat_d ne '');
		$hin{'preview_body_ignore_unifiedly_processing'} = 'Yes';
	}
	elsif ($type eq 'preview') {
		$hin{'preview_body'} = &repl_ph($tmp, { 'preview_rows' => $preview_rows});
		$hin{'preview_body_ignore_unifiedly_processing'} = 'Yes';
	}

	return 0;
} # sub command_proc_preview_apply_pattern

sub command_proc_login_user {
	my $res = &login_user($hin{'login'},$hin{'password'});
	if($res){
		$hl{'hl_permanent_list'}->{'user_id'} = 1;
	}

	return $res;
}

sub command_proc_refresh_user_cid
{
my $item = $hin{'item'};
my $user_id = $hin{'edit_user_id'};
my $contact_id = $hin{'contact_id'};

my $hash = {
						 'pers' => 'pers_cid',
						 'bill'	=> 'bill_cid',
						 'tech'	=> 'tech_cid',
						 'sales'=> 'sales_cid'
					 };

if($hash->{$item}&&$user_id&&$contact_id){
 &update_rows('users', " user_id = ".&str_sqlize($user_id),
										 {
											$hash->{$item} => $contact_id
										 });
}

return 1;
}


sub command_proc_product_copy ## modified for update capability
{
my $source_product_id = $hin{'source_product_id'};
my $product_id = $hin{'product_id'};
my $update = $hin{'need_update'};

if($USER->{'user_group'} ne 'superuser' &&
#	 $USER->{'user_group'} ne 'editor'&&
	 $USER->{'user_group'} ne 'category_manager' &&
	 $USER->{'user_group'} ne 'supereditor'){ return 0; }

if ($update) { &delete_product_rest($product_id) if ($product_id); }
&copy_product_rest($source_product_id, $product_id);
return 1;
}

sub command_proc_feature_values_group_delete_daemon
{
 return 1 if (!$hin{'atom_delete'});
 my $id = $hin{'feature_values_group_id'};

 my $data = &do_query("select feature_values_group_id from feature_values_group where feature_values_group_id=".&str_sqlize($id));

 if(defined $data && defined $data->[0]){
  # no way! this feature values group stil exists in database
 } else {
  # this product is not in database. We can clean ref. tables
  &update_rows('feature_values_vocabulary', "feature_values_group_id=$id", {'feature_values_group_id'=>1});
 }

 return 1;
}

sub command_proc_feature_group_delete_daemon
{
 return 1 if (!$hin{'atom_delete'});
 my $feature_group_id = $hin{'feature_group_id'};

 my $data = &do_query("select feature_group_id from feature_group where feature_group_id = ".&str_sqlize($feature_group_id));

 if(defined $data && defined $data->[0]){
  # no way! this feature group stil exists in database
 } else {
  # this product is not in database. We can clean ref. tables
	&update_rows('category_feature_group', "feature_group_id = $feature_group_id",
	  {
		 'feature_group_id' => 0
		});

 }

 return 1;
}

sub command_proc_product_delete_daemon {
	return 1 if (!$hin{'atom_delete'});
 	my $data = &do_query("select product_id from product where product_id = " . $hin{'product_id'});
 	if(defined $data && defined $data->[0]) {
	 	# no way! this product stil exists in database
 	} else {
	 	# this product is not in database. We can clean ref. tables
	 	&delete_product_rest($hin{'product_id'});
	 	$hin{'tmpl_if_success_cmd'} = "products.html";
 	}
 	return 1;
}

sub command_proc_merge_features
{
my $src_feature_id = &str_sqlize($hin{'src_feature_id'});
my $dst_feature_id = &str_sqlize($hin{'dst_feature_id'});
my $res = 1;

if($USER->{'user_group'} ne 'superuser' &&
	$USER->{'user_group'} ne 'category_manager' &&
	 $USER->{'user_group'} ne 'supereditor'){
   $res = 0;
return $res;
}
if($src_feature_id&&$dst_feature_id&&$src_feature_id ne $dst_feature_id){
 &merge_features($src_feature_id, $dst_feature_id );
} else {
$res = 0;
#&log_printf("$src_feature_id $dst_feature_id");
}
return $res;
}

sub command_proc_merge_features_in_category {

	my $src_feature_id = &str_sqlize($hin{'src_feature_id'});
	my $dst_feature_id = &str_sqlize($hin{'dst_feature_id'});
	my $cat_id = &str_sqlize($hin{'catid'});


	my $res = 1;

	if($USER->{'user_group'} ne 'superuser' &&
	  $USER->{'user_group'} ne 'category_manager' &&
 	  $USER->{'user_group'} ne 'supereditor'){
 	  $res = 0;
		return $res;
	}
	if($src_feature_id&&$dst_feature_id&&$src_feature_id ne $dst_feature_id){
		my $cat_feat_id_src = &do_query("select category_feature_id from category_feature where feature_id = $src_feature_id and catid=$cat_id")->[0][0];
		my $cat_feat_id_dst = &do_query("select category_feature_id from category_feature where feature_id = $dst_feature_id and catid=$cat_id")->[0][0];
#		&log_printf ("Src ".$cat_feat_id_src );
#		&log_printf ("Dst ".$cat_feat_id_dst );
		&merge_category_features ($cat_feat_id_src, $cat_feat_id_dst);
		my $query;
		$query = "select data_source_id from data_source";
		my $ds_array = &do_query ( $query );
		for my $ds ( @$ds_array ){
			my $ds_id = $ds->[0];
			if ( &feature_isset( $ds_id, $src_feature_id, $cat_id ) ){
				&create_feature_in_category ( $ds_id, $src_feature_id, $cat_id );
			}
		}
		&do_statement("update data_source_feature_map set feature_id=$dst_feature_id where feature_id=$src_feature_id and catid=$cat_id ");
		&do_statement("delete from data_source_feature_map where feature_id=$src_feature_id and catid=$cat_id");

	} else {
		$res = 0;
#		&log_printf("$src_feature_id $dst_feature_id");
	}
	return $res;
}

sub feature_isset (){
	my ( $data_source_id, $feature_id, $cat_id ) = @_;
	my $query = "select distinct feature_id from data_source_feature_map where feature_id=$feature_id and data_source_id=$data_source_id and ( catid=1 or catid=$cat_id)";
	my $row = &do_query($query)->[0];
	if ( $row->[0] ){
		return 1;
	}else{
		return 0;
	}

}

sub create_feature_in_category (){
	my ( $data_source_id, $feature_id, $cat_id ) = @_;
	my $query = "select feature_id from data_source_feature_map where catid=$cat_id and feature_id=$feature_id and data_source_id=$data_source_id";
	my $rows = &do_query ( $query );
	if ( $rows->[0][0] ){
		return 1;
	}else{
		$query = "select data_source_id, symbol, override_value_to,feature_id,catid, coef, format  from data_source_feature_map where catid=1 and feature_id=$feature_id and data_source_id=$data_source_id";
		my $rows = &do_query ( $query );
		for my $row ( @{$rows} ){
			my $new_data_source = &str_sqlize ( $row->[0] );
			my $new_symbol = &str_sqlize ( $row->[1] );
			my $new_override_value_to = &str_sqlize ( $row->[2] );
			my $new_feature_id = &str_sqlize ( $row->[3] );
			my $new_catid = $cat_id;
			my $new_coef = &str_sqlize ( $row->[5] );
			my $new_format = &str_sqlize ( $row->[6] );
			$query = "insert into data_source_feature_map ( data_source_id, symbol, override_value_to, feature_id, catid, coef, format ) values ( $new_data_source, $new_symbol, $new_override_value_to, $new_feature_id, $new_catid, $new_coef, $new_format)";
			&do_statement($query);
		}

	}
}

sub command_proc_chown_nobody_products {
	my $product_id = $hin{'product_id'};
	my $data = &do_query("select user_id from product where product_id =" . $product_id);
	return 1 unless defined $data->[0]->[0]; # happens when product is already deleted
	my $owner = &get_row('users', "user_id = " . $data->[0]->[0]);
	if (($owner->{'user_group'} eq 'category_manager') && ($hin{'atom_update'})) {
		$hin{'atom_submit'} = 1;
	}
	if (($data->[0]->[0] eq '19')&&($hin{'atom_update'})) {
		$hin{'atom_submit'} = 1;
	}
	if ( ($owner->{'user_group'} eq 'category_manager' ||
								$data->[0]->[0] eq '1' ||			#nobody
								$data->[0]->[0] eq '19')			#fake
			&& (
				$USER->{'user_group'} eq 'supereditor' ||
				$USER->{'user_group'} eq 'category_manager' ||
				$USER->{'user_group'} eq 'superuser' ||
				$USER->{'user_group'} eq 'editor')
			&& $hin{'atom_submit'}) {
				&update_rows('product', " product_id = " . $product_id,
					 { 'user_id' => $USER->{'user_id'}	} );
			}
	return 1;
}

sub command_proc_htpass_add_user {
	my $ex = 0;
	if ($hin{'subscription_level'} < 4) {
		if (!open(HTFILE, "< $atomcfg{'httpd_path4'}")) {
	    &log_printf("can't open $atomcfg{'httpd_path4'}");
	    return 1;
		}
		my @fa = <HTFILE>;
		my @na;
		for my $ae (@fa) {
	    if ($ae =~ /$hin{'login'}:/) {
				&log_printf("$ae login exist");
				$ex = 1;
				next;
	    }
	    push @na, $ae;
		}
		close(HTFILE);
		if (!open(HTFILE, "> $atomcfg{'httpd_path4'}")) {
	    &log_printf("can't open $atomcfg{'httpd_path4'}");
	    return 1;
		}
		print HTFILE @na or &log_printf("$!");
		close (HTFILE);
		if ($hin{'subscription_level'} == 0) {
	    if ($ex == 0) {
    		if (!open(HTFILE1, "< $atomcfg{'httpd_path'}")) {
					&log_printf("can't open $atomcfg{'httpd_path'}");
					return 1;
				}
				my @fa = <HTFILE1>;
				my @na;
				for my $ae (@fa) {
					if ($ae =~ /$hin{'login'}:/) {
						&log_printf("$ae login exist");
						next;
					}
					push @na, $ae;
				}
				close(HTFILE1);
				if (!open(HTFILE1, "> $atomcfg{'httpd_path'}")) {
					&log_printf("can't open $atomcfg{'httpd_path'}");
					return 1;
				}
				print HTFILE1 @na or &log_printf("$!");
				close (HTFILE1);
				return 1;
	    }
	    else {
				return 1;
	    }
		}
		eval{`/home/gcc/bin/auth_url_user $hin{'login'}&`};
		if ($@) {
			&log_printf("(htpasswd) error while user $hin{'login'} ");
		}
	}
	elsif ($hin{'subscription_level'} == 4) {
		eval{`/home/gcc/bin/auth_level4_user $hin{'login'}&`};
		if ($@) {
			&log_printf("(htpasswd) error while user $hin{'login'} ");
		}
	}
	return 1;
}

sub command_proc_family {
	if (
	    $hin{'atom_delete'} and
	    $hin{'exchange_family'} and
	    $hin{'exchange_family'} ne '1' and
	    $hin{'family_id'} and
	    $hin{'family_id'} ne '1' and
	    $hin{'family_id'} ne '0'
	) {
		&do_statement("UPDATE product SET family_id=$hin{'exchange_family'} WHERE family_id=$hin{'family_id'}");
	}
	return 1;
}

sub command_proc_get_obj_url {
	# all info about picture will be stored to this hash
	my $hash = {};

	# remove zero sized content at all
	$hin{'high_pic_filename'} = '' if (-z $hin{'high_pic_filename'});
	$hin{'low_pic_filename'} = '' if (-z $hin{'low_pic_filename'});
	$hin{'family_pic_filename'} = '' if (-z $hin{'family_pic_filename'});
	$hin{'supplier_pic_filename'} = '' if (-z $hin{'supplier_pic_filename'});

	if ($hin{'atom_update'} || $hin{'atom_submit'}) {

		if (($hin{'tmpl'} eq "product_details.html") || ($hin{'tmpl'} eq "product_new.html") || ($hin{'tmpl'} eq "product_description.html")) {

			if (defined $hin{'pdf_url'}) {
				$hash = {
					'link' => $hin{'pdf_url'},
					'dest' => 'pdf/',
					'dbtable' => 'product_description', 'dbfield' => 'pdf_url', 'id' => 'product_description_id', 'id_value' => $hin{'product_description_id'} 
				};

				my $old_pdf_url = &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where ".$hash->{'id'}."=".$hash->{'id_value'})->[0][0];

				if ($old_pdf_url ne $hash->{'link'}) {
					get_obj_url($hash);
				}
				unless ($hin{'pdf_url'}) {
					do_statement("update ".$hash->{'dbtable'}." set ".$hash->{'dbfield'}."='', pdf_size=0, pdf_url_origin='' where ".$hash->{'id'}."=".$hash->{'id_value'});
				}

			}
			if (defined $hin{'manual_pdf_url'}) {
				$hash = {
					'link' => $hin{'manual_pdf_url'},
					'dest' => 'pdf/',
					'dbtable' => 'product_description', 'dbfield' => 'manual_pdf_url', 'id' => 'product_description_id', 'id_value' => $hin{'product_description_id'} 
				};

				my $old_manual_pdf_url = &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where ".$hash->{'id'}."=".$hash->{'id_value'})->[0][0];

				if ($old_manual_pdf_url ne $hash->{'link'}) {
					get_obj_url($hash);
				}
				unless ($hin{'manual_pdf_url'}) {
					do_statement("update ".$hash->{'dbtable'}." set ".$hash->{'dbfield'}."='', manual_pdf_size=0, manual_pdf_url_origin='' where ".$hash->{'id'}."=".$hash->{'id_value'});
				}

			}


			if (defined $hin{'high_pic'} || defined $hin{'high_pic_filename'}) {
				my $old_high_pic = &do_query("SELECT high_pic FROM product WHERE product_id = " . $hin{'product_id'} )->[0]->[0];

				my $new_high_pic;
				if (-s $hin{'high_pic_filename'}) {
				 	$new_high_pic = $hin{'high_pic_filename'};
				}
				else {
					$new_high_pic = $hin{'high_pic'};
				}
				log_printf("old vs new = ".$old_high_pic." vs ".$new_high_pic);

				if (!$new_high_pic) { # remove product image

				    # store outdated picture to remote host
				    if ( ($atomcfg{'outdated_images_user'}) && ($atomcfg{'outdated_images_host'}) && ($atomcfg{'outdated_images_path'}) ) {
    				    my $source = $atomcfg{'images_user'} . '@' . url2scp_path($old_high_pic );
			    	    my $drain =
				            $atomcfg{'outdated_images_user'} . '@' .
				            $atomcfg{'outdated_images_host'} . ":" .
				            $atomcfg{'outdated_images_path'} . get_name_from_url($old_high_pic);
    				    log_printf("scp $source $drain");
	    			    qx(scp $source $drain);
	    			}

					&do_statement("update product set high_pic='', low_pic_size=0, high_pic_size=0, thumb_pic_size=0, high_pic_width=0, high_pic_height=0, low_pic_width=0, low_pic_height=0, low_pic='', thumb_pic=null where product_id=".$hin{'product_id'});
				}
				elsif ($old_high_pic ne $new_high_pic) { # product image was changed

				    if ( ($atomcfg{'outdated_images_user'}) && ($atomcfg{'outdated_images_host'}) && ($atomcfg{'outdated_images_path'}) ) {
				        # if previous is not empty
    				    if ($old_high_pic !~ /^\s*$/) {
        				    # store outdated picture to remote host
    	    			    my $source = $atomcfg{'images_user'} . '@' . url2scp_path($old_high_pic );
	    			        my $drain =
		    		            $atomcfg{'outdated_images_user'} . '@' .
    			    	        $atomcfg{'outdated_images_host'} . ":" .
	    			            $atomcfg{'outdated_images_path'} . get_name_from_url($old_high_pic);
		    		        log_printf("scp $source $drain");
    		    		    qx(scp $source $drain);
    		    		}
	    			}


					# store thumb pic size as well as high pic or low pic ones
					my $thumb = &thumbnailize_product (
						&normalize_product_pics({
							'product_id' => $hin{'product_id'},
							'high_pic' => $new_high_pic
																		}));

					$hash = {
						'link' => $hin{'thumb_pic'}, 'dest' => 'thumbs/',
						'dbtable' => 'product',	'dbfield' => 'thumb_pic', 'id' => 'product_id',	'id_value' => $hin{'product_id'}
					};

					get_obj_size($hash, 'thumb_pic_size');

					if (!$thumb) {
						&process_atom_ilib('errors');
						&process_atom_lib('errors');
						push @user_errors, $atoms->{'default'}->{'errors'}->{'thumb_bad'};
						&atom_cust::proc_custom_processing_errors;
						return 0;
					}
				}
			}
		}

		if ($hin{'tmpl'} eq 'cat_edit.html') {
			$hash = {
				'link' => $hin{'low_pic'} || $hin{'low_pic_filename'},
				'dest' => 'img/low_pic/',
				'dbtable' => 'category', 'dbfield' => 'low_pic', 'id' => 'catid',	'id_value' => $hin{'catid'} };

			my $old_low_pic = &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where ".$hash->{'id'}."=".$hash->{'id_value'})->[0][0];

			unless ($hash->{'link'}) { # remove category image
				log_printf("Remove category image...");
				&do_statement("update ".$hash->{'dbtable'}." set ".$hash->{'dbfield'}." = '', thumb_pic=NULL where ".$hash->{'id'}."=".$hash->{'id_value'});
			}
			elsif ($old_low_pic eq $hash->{'link'}) {
				log_printf("Do not touch category image...");
			}
			else {
				get_obj_url($hash);
				use thumbnail;
				&thumbnailize_category({'catid' => $hin{'catid'}, 'low_pic' => $hash->{'link'}});
			}
		}
		if ($hin{'tmpl'} eq 'supplier_edit.html') {
			$hash = {
				'link' => $hin{'low_pic'} || $hin{'supplier_pic_filename'},
				'dest' => 'img/supplier/',
				'dbtable' => 'supplier', 'dbfield' => 'low_pic', 'id' => 'supplier_id', 'id_value' => $hin{'supplier_id'} };

			my $old_low_pic = &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where ".$hash->{'id'}."=".$hash->{'id_value'})->[0][0];

			unless ($hash->{'link'}) { # remove supplier image
				log_printf("Remove supplier image...");
				&do_statement("update ".$hash->{'dbtable'}." set ".$hash->{'dbfield'}." = NULL, thumb_pic=NULL where ".$hash->{'id'}."=".$hash->{'id_value'});
			}
			elsif ($old_low_pic eq $hash->{'link'}) {
				log_printf("Do not touch supplier image...");
			}
			else {
				get_obj_url($hash);
				use thumbnail;
				&thumbnailize_supplier({'supplier_id' => $hin{'supplier_id'}, 'low_pic' => $hash->{'link'}});
			}
		}
		if ($hin{'tmpl'} eq 'family_edit.html') {
			if ($hin{'low_pic'} || $hin{'family_pic_filename'}) {
				$hash = {
					'link' => $hin{'low_pic'} || $hin{'family_pic_filename'},
					'dest' => 'img/families/',
					'dbtable' => 'product_family', 'dbfield' => 'low_pic', 'id' => 'family_id', 'id_value' => $hin{'family_id'} 
				};

				my $old_low_pic = &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where ".$hash->{'id'}."=".$hash->{'id_value'})->[0][0];

				unless ($hash->{'link'}) { # remove family image
					log_printf("Remove family image...");
					&do_statement("update ".$hash->{'dbtable'}." set ".$hash->{'dbfield'}." = NULL, thumb_pic=NULL where ".$hash->{'id'}."=".$hash->{'id_value'});
				}
				elsif ($old_low_pic eq $hash->{'link'}) {
					log_printf("Do not touch family image...");
				}
				else {
					get_obj_url($hash);
				}
			}
		}
		if ($hin{'tmpl'} eq 'campaign_kit.html') {
			if ($hin{'logo_pic'}) {
				&log_printf("Campaign gallery - URL link...");

				$hash = {
					'link' => $hin{'logo_pic'},
					'dest' => 'img/campaign/',
					'dbtable' => 'campaign_gallery',
					'dbfield' => 'logo_pic',
					'id' => 'campaign_gallery_id',
					'id_value' => $hin{'campaign_gallery_id'}
				};
				get_obj_url($hash);
				use thumbnail;
				&thumbnailize_campaign_gallery({'campaign_gallery_id' => $hin{'campaign_gallery_id'}, 'logo_pic' => $hin{'logo_pic'}});
			}
			else {
				if ($hin{'campaign_gallery_id'}) {
					&do_statement("delete from campaign_gallery where campaign_gallery_id=".$hin{'campaign_gallery_id'});
				}
			}
		}
	}
	return 1;
}

sub command_proc_update_xml_due_product_update {
	if ($hin{'atom_update'} || $hin{'atom_delete'}) {
		&update_product_bg($hin{'product_id'});
  }
	return 1;
}

sub command_proc_update_xmls_due_product_related_update {
	&log_printf("fork: ".$hin{'atom_submit'}?"1":"0");
	if ($hin{'atom_submit'} || $hin{'atom_delete'}) {
		my $p_id = $hin{'product_id'};
		my $r_p_id = $hin{'rel_product_id'} || &do_query("select product_id from product where prod_id=".&str_sqlize($hin{'rel_prod_id'})." and supplier_id=".$hin{'r_supplier_id'})->[0][0];
		&update_product_bg($p_id);
		&update_product_bg($r_p_id) if ($r_p_id);
  }
  return 1;
}

sub update_product_bg {
	my ($p_id) = @_;
	my ($cmd);
	return undef unless ($p_id);

	my $bg_product_prio = 2;

	my $max_processes = &do_query("select max_processes from process_class")->[0][0] * 1.5;
	$max_processes = int($max_processes);

#	&update_rows('product', "product_id=".$p_id, { 'updated' => 'NOW()' }); # disabled (8.06.2010), not necessary

	$cmd = $atomcfg{'base_dir'}.'bin/update_product_xml_chunk';

	my $remote = '/usr/bin/ssh www@'.$atomcfg{'host_raw'};

	# switch off bg processes - totally queued updates with prio = 2

#	if (&get_running_perl_processes_number($cmd, $remote) > $max_processes) {
	if (1) {
		&log_printf("queue(".$cmd." ".$p_id.")");
		&queue_process($cmd." ".$p_id, { 'product_id' => $p_id, 'process_class_id' => 1, 'prio' => $bg_product_prio });
		return 'queued';
	}
	else {
#		$cmd = $atomcfg{'base_dir'}."bin/update_product_xml_chunk ".$p_id;
#		&log_printf("fork(".$cmd.")");
#		&run_bg_command($cmd);

		$cmd = $atomcfg{'base_dir'}."bin/update_product_xml_chunk ".$p_id;
		if (&get_running_perl_processes_number($cmd, $remote) > 0) {
			&log_printf("!fork(".$remote." ".$cmd."), already in process");
			return '!bg';
		}
		else {
			$cmd .= " > /dev/null &";
			&log_printf("fork(".$remote." ".$cmd.")");
			&run_bg_command($remote." ".$cmd);
			return 'bg';
		}
	}
}
sub get_rating_catid_restrict{
		my @null_stock_categories=('software licenses/upgrades','warranty & support extensions');
		my @null_stock_catids;
		for my $nullStockCateg (@null_stock_categories){ 
			my $null_stock_catid=&do_query('SELECT catid FROM category c 
										JOIN vocabulary v ON v.sid=c.sid and v.langid=1 
										WHERE v.value ='.&str_sqlize($nullStockCateg))->[0][0];
			if($null_stock_catid){
				push (@null_stock_catids,$null_stock_catid);	
			}else{
				&errmail('alexey@bintime.com','pricelist import: no cat named '.$nullStockCateg);	
			}									
		}
		return \@null_stock_catids;
} 

sub update_null_stock_rating{
	my ($null_stock_catids,$catid,$product_id,$formula_params)=@_;
	return '' if ref($null_stock_catids) ne 'ARRAY';
	if(grep(/^$catid$/i,@{$null_stock_catids})){		
		if(!$formula_params->{'formula'} or !$formula_params->{'Period'}){
			&errmail('alexey@bintime.com','Cant regenerate rating import!!!!!');
		}else{
			&do_statement('UPDATE product_price SET stock=0 WHERE product_id='.$product_id);
			&do_statement("UPDATE product_interest_score JOIN product_price USING(product_id) 
						SET score=$formula_params->{'formula'} WHERE product_id=".$product_id);
		}			
	}
}

sub command_proc_update_score {
	if ($hin{'atom_update'}) {
		my $p_id = $hin{'product_id'};
		&update_rows("describe_product_request", "product_id=".&str_sqlize($p_id), {"status" => 1});
		&update_rows("product_interest_score", "product_id=".&str_sqlize($p_id), {"status" => 1});
		my $null_stock_catids=get_rating_catid_restrict();
		update_null_stock_rating($null_stock_catids,$hin{'catid'},$hin{'product_id'},&get_rating_params());
	}
	return 1;
}

sub command_proc_add_complaint_history{
  my $cid = $hin{'complaint_id'};
  my $csid = $hin{'status_id'};
  my $user_id = $USER->{'user_id'};
  my $msg = $hin{'new_msg'};
	my $dbmsg = $msg;

  &insert_rows("product_complaint_history",
               {"complaint_id" => $cid,
                "complaint_status_id" => $csid,
                "user_id" => $user_id,
                "message" => &str_sqlize($dbmsg),
                'date' => &str_sqlize(`date "+%Y-%m-%d %H:%M:%S"`)
               });
 &update_rows("product_complaint", "id = $cid", { "complaint_status_id" => $csid});

 &load_email_template("email_complaint");
 if(! defined $hin{'langid'}){ $hin{'langid'} = 1;}
 my $html_body = &get_complaint_email_body($atoms, $hin{'complaint_id'}, $hin{'langid'});
 my $complaint_status = &do_query("select v.value from product_complaint as pc, product_complaint_status as pcs, vocabulary as v where pc.complaint_status_id = pcs.code and pcs.sid = v.sid and v.langid =".$hin{'langid'}." and pc.id = ".$cid)->[0][0];
 my $get_reply_to = do_query("select c.email from product_complaint_history as pch, users as u, contact as c where pch.id =".&sql_last_insert_id()." and pch.user_id = u.user_id and u.pers_cid = c.contact_id")->[0][0];

#email to respondent
 my $mail_to_respondent;

 $mail_to_respondent->{'html_body'} = $html_body;
 $mail_to_respondent->{'text_body'} = &html2text($html_body);
 $mail_to_respondent->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'history_subject_to_respondent'},{'id' => $hin{'complaint_id'}, 'status' => $complaint_status});

 my $get_email_login_to = &do_query("select person, email from contact, users where users.user_id = $hin{'userid'} and users.pers_cid = contact.contact_id");
 my $get_email_login_from = &do_query("select login, person, email from contact, users where users.user_id = $USER->{'user_id'} and users.pers_cid = contact.contact_id");
 my $get_prodid_supplier = &do_query("select pc.prod_id, s.name from product_complaint as pc, supplier as s where pc.id = $cid and pc.supplier_id = s.supplier_id");

 $mail_to_respondent->{'to'} = $get_email_login_to->[0][1];
 $mail_to_respondent->{'from'} = $atomcfg{'complain_from'};
 $mail_to_respondent->{'reply_to'} = $get_reply_to;

 if($hin{'userid'} != $USER->{'user_id'}){
   &atom_mail::complex_sendmail($mail_to_respondent);
 }

#email to editor
 my $mail_to_editor;

 $mail_to_editor->{'html_body'} = $html_body;
 $mail_to_editor->{'text_body'} = &html2text($html_body);;
 $mail_to_editor->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'history_subject_to_editor'},{'id' => $hin{'complaint_id'}, 'status' => $complaint_status});

 my $get_email_login_to2 = &do_query("select person, contact.email from contact, users, product_complaint where product_complaint.id = $hin{'complaint_id'} and users.user_id =product_complaint.user_id  and users.pers_cid = contact.contact_id");
 my $get_email_login_from2 = &do_query("select login, person, email from contact, users where users.user_id = $USER->{'user_id'} and users.pers_cid = contact.contact_id");

 $mail_to_editor->{'to'} = $get_email_login_to2->[0][1];
 $mail_to_editor->{'from'} = $atomcfg{'complain_from'};
 $mail_to_editor->{'reply_to'} = $get_reply_to;

 &atom_mail::complex_sendmail($mail_to_editor);

#email to sender (waiting for response)
 if($hin{'status_id'} == 20){
 my $mail_to_sender;

 $mail_to_sender->{'html_body'} = $html_body;
 $mail_to_sender->{'text_body'} = &html2text($html_body);;
 $mail_to_sender->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'history_subject_to_sender_waiting'},{'id' => $hin{'complaint_id'}, 'status' => $complaint_status});

 my $get_sender_data = &do_query("select subject, name, email from product_complaint where id = $hin{'complaint_id'}");

 $mail_to_sender->{'to'} = $get_sender_data->[0][2];
 $mail_to_sender->{'from'} = $atomcfg{'complain_from'};
 $mail_to_sender->{'reply_to'} = $get_reply_to;
 &atom_mail::complex_sendmail($mail_to_sender);

 }

#email to sender (complaint closed)
 if($hin{'status_id'} == 90){
 my $mail_to_sender;

 $mail_to_sender->{'html_body'} = $html_body;
 $mail_to_sender->{'text_body'} = &html2text($html_body);;
 $mail_to_sender->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'history_subject_to_sender_close'},{'id' => $hin{'complaint_id'}, 'status' => $complaint_status});

 my $get_sender_data = &do_query("select subject, name, email from product_complaint where id = $hin{'complaint_id'}");

 $mail_to_sender->{'to'} = $get_sender_data->[0][2];
 $mail_to_sender->{'from'} = $atomcfg{'complain_from'};
 $mail_to_sender->{'reply_to'} = $get_reply_to;
 &atom_mail::complex_sendmail($mail_to_sender);

 }
 return 1;
}

sub command_proc_post_complain {
	my($p_id, $pr_id, $s_id, $cl_email, $date, $cl_msg, $cl_name, $editor, $cl_subj);

	$p_id = $hin{'product_id'};

	my $get_prid_sid = &do_query("select prod_id, supplier_id from product where product_id = $p_id");
	$pr_id = $get_prid_sid->[0][0];
	$s_id = $get_prid_sid->[0][1];

	my $get_email_name = &do_query("select login, email from users, contact where users.user_id = $USER->{'user_id'} and users.pers_cid = contact.contact_id");
	$cl_email = $get_email_name->[0][1];
	$cl_name = $get_email_name->[0][0];
	$cl_msg = $hin{'message'};
	$cl_subj = $hin{'subject'};

	my $get_editor = &do_query("select user_id from product where product_id=".&str_sqlize($p_id));
	if (!$get_editor || ($get_editor->[0][0] == 1)) {
		$editor = $hin{'search_nobody_select'};
	}
	else {
		$editor = $get_editor->[0][0];
	}

	# complaints to user_groups 'supplier' and 'exeditor' redirected to super_user
	my $user_group = &do_query("select user_id, user_group from users where user_id=".&str_sqlize($editor));
	if (($user_group->[0][1] eq 'supplier') or ($user_group->[0][1] eq 'exeditor') or ($user_group->[0][0] == 19)) {
		my $default_super_user = &do_query("select value from sys_preference where name = 'default_superuser_id'");
		$editor = $default_super_user->[0][0];
	}

	my $stat = 1;
	my $user_id = $USER->{'user_id'};
	my $cl_dbmsg = $cl_msg;
	&insert_rows('product_complaint', {
		'product_id' => &str_sqlize($p_id),
		'prod_id' => &str_sqlize($pr_id),
		'supplier_id' => &str_sqlize($s_id),
		'email' => &str_sqlize($cl_email),
		'fuser_id' => &str_sqlize($user_id),
		'message' => &str_sqlize($cl_dbmsg),
		'subject' => &str_sqlize($cl_subj),
		'date' => &str_sqlize(`date "+%Y-%m-%d %H:%M:%S"`),
		'complaint_status_id' => &str_sqlize($stat),
		'name' => &str_sqlize($cl_name),
		'user_id' => &str_sqlize($editor),
		'internal' => '1'
							 });

	# add history
	my $c_id = &sql_last_insert_id();
	&insert_rows("product_complaint_history", {
		"complaint_id" => $c_id,
		"complaint_status_id" => 1,
		"user_id" => $USER->{'user_id'},
		"message" => &str_sqlize("New complaint received"),
		'date' => &str_sqlize(`date "+%Y-%m-%d %H:%M:%S"`)
							 });

	# email to responsibe editor
	my $mail_to_editor;
	&load_email_template("email_complaint");
	if (!defined $hin{'langid'}) {
		$hin{'langid'} = 1;
	}
	$hin{'complaint_id'} = $c_id;
	my $html_body = &get_complaint_email_body($atoms, $hin{'complaint_id'}, $hin{'langid'});

	$mail_to_editor->{'html_body'} = $html_body;
	$mail_to_editor->{'text_body'} = &html2text($html_body);;
	$mail_to_editor->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'post_subject'},{'id' => $hin{'complaint_id'}});

	my $get_email_login_to;

	# nobody product
	if ($hin{'search_nobody_select'}) {
		$get_email_login_to = &do_query("select person, contact.email from contact, users where users.user_id = $editor and users.pers_cid = contact.contact_id");
	}
	else {
		$get_email_login_to = &do_query("select person, contact.email from contact, users, product where product.product_id = $hin{'product_id'} and users.user_id = product.user_id and users.pers_cid = contact.contact_id");
	}
	if (!$get_email_login_to->[0][1]) {
		$get_email_login_to = &do_query("select person, email from users, contact, sys_preference where sys_preference.name='default_superuser_id' and sys_preference.value = users.user_id and users.pers_cid = contact.contact_id");
	}
	my $get_email_login_from = &do_query("select person, email, login from users, contact where users.user_id = $USER->{'user_id'} and users.pers_cid = contact.contact_id");
	my $get_prodid_supplier = &do_query("select prod_id, supplier.name from product, supplier where product.product_id = $p_id and product.supplier_id = supplier.supplier_id");

	$mail_to_editor->{'to'} = $get_email_login_to->[0][1];
	$mail_to_editor->{'from'} = $atomcfg{'complain_from'};

	&atom_mail::complex_sendmail($mail_to_editor);
	return 1;
}

sub command_proc_update_complain{
 if(!$hin{'update_complain'}){
   return 1;
 }else{

 &update_rows("product_complaint", "id=".$hin{'complaint_id'}, {"user_id" => $hin{'uname'}});

 my $mail_to_editor;
 &load_email_template("email_complaint");
 if(! defined $hin{'langid'}){ $hin{'langid'} = 1;}
 my $html_body = &get_complaint_email_body($atoms, $hin{'complaint_id'}, $hin{'langid'});

 $mail_to_editor->{'html_body'} = $html_body;
 $mail_to_editor->{'text_body'} = &html2text($html_body);;
 $mail_to_editor->{'subject'} = &repl_ph($atoms->{'default'}->{'email_complaint'}->{'updated_subject'},{'id' => $hin{'complaint_id'}});

 my $get_email_login_to = &do_query("select person, email from contact, users where users.user_id = $hin{'uname'} and users.pers_cid = contact.contact_id");
 my $get_email_login_from = &do_query("select login, contact.email from contact, users, product_complaint where users.user_id = product_complaint.user_id and users.pers_cid = contact.contact_id and product_complaint.id = $hin{'complaint_id'}");
 my $get_prodid_supplier = &do_query("select pc.prod_id, s.name from product_complaint as pc,	 supplier as s where pc.id = $hin{'complaint_id'} and pc.supplier_id = s.supplier_id");

 $mail_to_editor->{'to'} = $get_email_login_to->[0][1];
 $mail_to_editor->{'from'} = $atomcfg{'complain_from'};
 &atom_mail::complex_sendmail($mail_to_editor);

 }
 return 1;
}

sub command_proc_update_language_flag
{

 my $product_id = $hin{'product_id'};
 my $language_flag = &get_language_flag($hin{'product_id'});

 &update_rows("product_interest_score", "product_id = ".$hin{'product_id'}, { "language_flag" => $language_flag});

}

sub get_receivers_for_mail_dispatch {

	my $hash = {};

	&process_atom_ilib("mail_dispatch");
	&process_atom_lib("mail_dispatch");

	my @groups_names = split(",", $atoms->{'default'}->{'mail_dispatch'}->{'dispatch_groups_names'});
	my @groups_values = split(",", $iatoms->{'mail_dispatch'}->{'dispatch_groups_values'});

	$hash->{'dispatch_persons'} = ""; $hash->{'dispatch_emails'} = "";

	my $extra_where = '';
	my $country = $hin{'country_id_set'};

	if ($country ne '-1') {
		$extra_where = ' country_id = '.&str_sqlize($country).' AND ';
	}

	for my $group_value(@groups_values){
		if($hin{$group_value} == 1){
			$hin{'dispatch_send_to_values'} .= "$group_value,";

			my $where = " 1 and " . $extra_where;

			$where .= $iatoms->{'mail_dispatch'}->{'dispatch_group_'.$group_value};

			my $persons_details = &do_query("select person, user_group, email from users, contact where $where and users.pers_cid = contact.contact_id");

			for my $person(@$persons_details){
				$hash->{'dispatch_persons'} .= "<option value='$person->[2]'>".$person->[0]." [".$person->[1]."]"." (".$person->[2].")</option>\n";
				$hash->{'dispatch_emails'} .= $person->[2].",";
			}
		}
	}

	if($hin{'dispatch_one_address_check'} == 1){
		my @addresses = split(",", $hin{'dispatch_one_address'});
		for my $address(@addresses){
			$hash->{'dispatch_persons'} .= "<option value='$address'>".$address."</option>\n";
		}
		$hash->{'dispatch_emails'} .= $hin{'dispatch_one_address'};
	}
	$hash->{'dispatch_emails'} =~ s/^(.+),$/$1/;


	return $hash;

}

sub command_proc_mail_dispatch_prepare {
	my $inserts;

	&process_atom_ilib('errors');
	&process_atom_lib('errors');

	my $hash = &get_receivers_for_mail_dispatch;

	# check user group
	my $user_group = &do_query("select user_group from users where user_id=".$USER->{'user_id'})->[0][0];
	if (($user_group ne 'superuser') && ($user_group ne 'supereditor') && ($user_group ne 'category_manager')) {
		&atom_html::html_finish();
		return 1;
	}

	$inserts->{'subject'} = &str_sqlize($hin{'dispatch_subject'});
	$inserts->{'salutation'} = &str_sqlize($hin{'dispatch_salutation'});
	$inserts->{'plain_body'} = &str_sqlize($hin{'dispatch_plain_message'});
	$inserts->{'html_body'} = &str_unhtmlize($hin{'dispatch_html_message'});
	$inserts->{'html_body'} = &str_sqlize('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'."\n".'<html xmlns="http://www.w3.org/1999/xhtml">'."\n".'<head>'."\n".'<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'."\n".'<title>'.&str_htmlize($inserts->{'subject'}).'</title>'."\n".'</head>'."\n".'<body>'."\n".$inserts->{'html_body'}."\n</body></html>");

	$inserts->{'footer'} = &str_sqlize($hin{'dispatch_footer'});
	$inserts->{'to_groups'} = &str_sqlize($hin{'dispatch_send_to_values'});
	# &log_printf("\n".$hin{'dispatch_persons'});
	$inserts->{'to_emails'} = &str_sqlize($hash->{'dispatch_emails'});
	$inserts->{'status'} = 0;

	$inserts->{'date_queued'} = $hin{'dispatch_date'};
	$inserts->{'date_queued'} =~ s/\s(.+)\s/$1/;
	if (($inserts->{'date_queued'} eq 'now') || (!$inserts->{'date_queued'})) {
		$inserts->{'date_queued'} = time;
	}
	else {
		$inserts->{'date_queued'} =~ /^\s*(\d+)\s*-\s*(\d+)\s*-\s*(\d+)\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*/;
		if (!$1 || ($2 < 2) || !$3) {
			push @user_errors, &repl_ph($atoms->{'default'}->{'errors'}->{'login_expiration_date'},{'name' => $inserts->{'date_queued'}});
			&atom_cust::proc_custom_processing_errors;
			return 1;
		}
		$inserts->{'date_queued'} = timelocal($6, $5, $4, $3, $2 - 1, $1);
	}

	my $message_types = {'plain text' => 0, 'html text' => 1, 'html plain text' => 2};
	$inserts->{'message_type'} = $message_types->{$hin{'dispatch_message_type'}};

	$inserts->{'attachment_name'} = &str_sqlize($hin{'dispatch_attachment'});
	if ($inserts->{'attachment_name'} ne '') {
		if ($hin{'file_content_type'} and $hin{'dispatch_attachment_filename'}) {
			$inserts->{'attachment_content_type'} = &str_sqlize($hin{'file_content_type'});
			$inserts->{'attachment_body'} = &str_sqlize($hin{'dispatch_attachment_filename'});
			$hin{'origin_id'} = undef if ($hin{'origin_id'}); # undefine it to make sure that we upload new attachment. Dima <dmitrryuglach@bintime.com>
		} elsif ($hin{'origin_id'}) {
			my $attachment_data = do_query("SELECT attachment_content_type, attachment_body FROM mail_dispatch WHERE id=".&str_sqlize($hin{'origin_id'}));
			$inserts->{'attachment_content_type'} = &str_sqlize($attachment_data->[0][0]);
			$inserts->{'attachment_body'} = &str_sqlize($attachment_data->[0][1]);
		}
	}

	# not all paramteres filled
	if (!$inserts->{'to_emails'} || !$inserts->{'date_queued'} || !$inserts->{'subject'} || (!$inserts->{'html_body'} && !$inserts->{'plain_body'})) {
		push @user_errors, $atoms->{'default'}->{'errors'}->{'complete_email_params'};
		&atom_cust::proc_custom_processing_errors;
		return 1;
	}

	$inserts->{'country_id'}		= &str_sqlize($hin{'country_id_set'});
	$inserts->{'single_email'}	=	&str_sqlize($hin{'dispatch_one_address'});

	# insert into dispatch log
	&insert_rows("mail_dispatch", $inserts);
	# &log_printf(Dumper($inserts));

	# insert attachment into BLOB field
	if ($inserts->{'attachment_body'} && !$hin{'origin_id'}) {
		open(FILE, "$hin{'dispatch_attachment_filename'}");
		binmode FILE;
		my $data = '';
		my $buff;
		while (read(FILE, $buff, 2)) {
			$data .= $buff;
		}
		&do_statement("UPDATE mail_dispatch set attachment_body = ".&str_sqlize($data)." where id = ".&sql_last_insert_id());
		system("rm", "-f", $hin{'dispatch_attachment_filename'})
	}

	return 1;
}

sub command_proc_product_group_action {

	&process_atom_ilib('product_group_actions_list');
	&process_atom_lib('product_group_actions_list');

	&process_atom_ilib('errors');
	&process_atom_lib('errors');

	my @group_actions = split(",", $iatoms->{'product_group_actions_list'}->{'actions_list'});
	my @denied_actions = split("#", $iatoms->{'product_group_actions_list'}->{'actions_denied_variants'});
	my %denied_actions = map{$_ => 1} @denied_actions;

	my @actual_actions;

	for my $action (@group_actions) {
		if ($hin{$action} == 1) {
			push @actual_actions, $action;
		}
	}

	# check for empty actions list
	if ($#actual_actions == -1) {
		push @user_errors, $atoms->{'default'}->{'errors'}->{'group_actions_empty'};
		&atom_cust::proc_custom_processing_errors;
		return 0;
	}

	# check for denied actions pares
	my @errors;

	for my $action1 (@actual_actions) {
		for my $action2 (@actual_actions) {
			if ($denied_actions{$action1.",".$action2}) {
				push @errors, $atoms->{'default'}->{'errors'}->{'group_actions'}."(".$atoms->{'default'}->{'product_group_actions_list'}->{$action1}.",".$atoms->{'default'}->{'product_group_actions_list'}->{$action2}.")";
			}
		}
	}
	if ($#errors != -1) {
		@user_errors = @errors;
		&atom_cust::proc_custom_processing_errors;
		return 0;
	}

	# directly actions
	my @product_ids = split(",", $hin{'product_id_list'});
	my %changed_poducts;

	for my $action (@actual_actions) {
		# &log_printf("DV action: ".$action);

		if ($action eq 'supplier_list') {
			$hin{'supplier_list_checked'} = 'checked';
			my $list_merges = '';
			my $dst_list_merges = '';

			for my $product_id (@product_ids) {
				my $data = &get_row('product',"product_id = '$product_id'");
				my $prod_id = $data->{'prod_id'};
				$data = &get_row('product',"supplier_id = '$hin{'search_supplier_list'}' and prod_id = '$prod_id'");
				#&log_printf("DV \$data: ".Dumper($data));
				if (defined($data->{'product_id'})) {
					#&log_printf("DV defined");
					$list_merges .= $product_id.",";
					$dst_list_merges .= $data->{'product_id'}.",";
				}
			}

			$list_merges =~ s/,$//;
			$dst_list_merges =~ s/,$//;
			#&log_printf("DV \$hin: ".Dumper(%hin));

			if ($list_merges ne '') {
				if (!defined $hin{'apply_merge'}) {
					$hin{'list_merges'} = $list_merges; # write warning
					$hin{'list_merges_ignore_unifiedly_processing'} = 'Yes';
					push @user_errors, $atoms->{'default'}->{'errors'}->{'merge_products'};
					&atom_cust::proc_custom_processing_errors;

					&process_atom_ilib('product_mergings'); # prepare atom product_mergings
					&process_atom_lib('product_mergings');

					my $tmp = $atoms->{'default'}->{'product_mergings'}->{'mergings_body'};
					my $mergings_row = $atoms->{'default'}->{'product_mergings'}->{'mergings_row'};
					my $mergings_row_best = $atoms->{'default'}->{'product_mergings'}->{'mergings_row_best'};
					my $mergings_rows = '';
					my $mergings_separator = $atoms->{'default'}->{'product_mergings'}->{'mergings_separator'};

					my @arr_merges = split(",", $list_merges);

					my $merges = '';

					for my $src_product_id (@arr_merges) {
						my $prods;
						my $src_data = &do_query("select product_id, product.supplier_id, product.prod_id, product.user_id, users.user_group, users.login, supplier.name from product, users, supplier where product.supplier_id = supplier.supplier_id and users.user_id = product.user_id and product_id = '".$src_product_id."' ")->[0];
						push @$prods, {
							"product_id" => $src_data->[0],
							"old_prod_id" => $src_data->[2],
							"m_prod_id" => $src_data->[2],
							"user_id" => $src_data->[3],
							"user_group" => $src_data->[4],
							"login" => $src_data->[5],
							"supplier_name" => $src_data->[6],
							"mapped" => 1
						};

						my $dst_data = &do_query("select product_id, product.supplier_id, product.prod_id, product.user_id, users.user_group, users.login, supplier.name from product, users, supplier where product.supplier_id = supplier.supplier_id and users.user_id = product.user_id and prod_id = '".$src_data->[2]."' and product.supplier_id = '".$hin{'search_supplier_list'}."' ")->[0];

						push @$prods, {
							"product_id" => $dst_data->[0],
							"old_prod_id" => $dst_data->[2],
							"m_prod_id" => $dst_data->[2],
							"user_id" => $dst_data->[3],
							"user_group" => $dst_data->[4],
							"login" => $dst_data->[5],
							"supplier_name" => $dst_data->[6],
							"mapped" => 1
						};

						# &log_printf("DV src_data: ".Dumper($src_data));
						# &log_printf("DV dst_data: ".Dumper($dst_data));

						&data_management::solve_product_ambugiuty($prods);

						for my $row (@$prods) {
							# $mapped_flag = 1;
							if ($row->{'best'}) {
								$mergings_rows .= &repl_ph($mergings_row_best, $row);
								$merges .= $row->{'product_id'}.",";
							}
							else {
								$mergings_rows .= &repl_ph($mergings_row, $row);
							}
						}
						if (@$prods) {
							$mergings_rows .= $mergings_separator;
						}
					}

					$hin{'mergings_body'} = &repl_ph($tmp,{'mergings_rows'=>$mergings_rows});
					$hin{'mergings_body_ignore_unifiedly_processing'} = 'Yes';
					$hin{'apply_merge_body'} = $atoms->{'default'}->{'product_group_actions_list'}->{'apply_merge_body'};
					$hin{'apply_merge_body_ignore_unifiedly_processing'} = 'Yes';
					$dst_list_merges =~ s/,+$//s;
					$merges =~ s/,+$//s;
					$hin{'dst_list_merges'} = $dst_list_merges;
					$hin{'dst_list_merges_ignore_unifiedly_processing'} = 'Yes';
					$hin{'merges'} = $merges;
					$hin{'merges_ignore_unifiedly_processing'} = 'Yes';
					#&log_printf("DV \$hin: ".Dumper(%hin));

					return 0;
				}
				else { # $hin{'apply_merge'} IS DEFINED!!!!!!!!!!!!!!!!!!!!!!!!

					if ($USER->{'user_group'} ne 'superuser' && $USER->{'user_group'} ne 'supereditor') {
						push @user_errors, $atoms->{'default'}->{'errors'}->{'merge_products_error'};
						&atom_cust::proc_custom_processing_errors;
						return 0;
					}

					#&log_printf("DV apply \$hin: ".Dumper(%hin));
					my @arr_list_merges = split(",", $hin{'list_merges'});
					my @arr_dst_list_merges = split(",", $hin{'dst_list_merges'});
					my @arr_merges = split(",", $hin{'merges'});

					#&log_printf("DV start resolving");
					# use product_mergings atom sources
					&process_atom_ilib('product_mergings');
					&process_atom_lib('product_mergings');

					my $mergings_row = $atoms->{'default'}->{'product_mergings'}->{'mergings_row'};
					my $mergings_row_best = $atoms->{'default'}->{'product_mergings'}->{'mergings_row_best'};
					my $mergings_body = $atoms->{'default'}->{'product_mergings'}->{'mergings_report_body'};

					$hin{'product_merging_removed_products'} = '';
					$hin{'product_merging_saved_products'} = '';
					$hin{'product_mergings_report'} = '';

					for (my $i=0; $i<=$#arr_list_merges; $i++) {
						if ($arr_list_merges[$i] == $arr_merges[$i]) { # keep source
							## deleting destination product AT ALL
#			 &log_printf("delete dest_product_id: ".$arr_dst_list_merges[$i]." & keep src_product_id: ".$arr_list_merges[$i]);

							my $p_removed = &do_query("select p.product_id, p.supplier_id, p.prod_id, p.user_id, u.user_group, u.login, s.name
from product p
inner join users u using (user_id)
inner join supplier s using (supplier_id)
where p.product_id = ".&str_sqlize($arr_dst_list_merges[$i]))->[0];

							$hin{'product_merging_removed_products'} .= &repl_ph($mergings_row,
																																	 {
																																		 'product_id'    => $p_removed->[0],
																																		 'old_prod_id'   => $p_removed->[2],
																																		 'm_prod_id'     => $p_removed->[2],
																																		 'user_id'       => $p_removed->[3],
																																		 'user_group'    => $p_removed->[4],
																																		 'login'         => $p_removed->[5],
																																		 'supplier_name' => $p_removed->[6],
																																	 }) if $p_removed->[0];

							my $p_saved = &do_query("select p.product_id, p.supplier_id, p.prod_id, p.user_id, u.user_group, u.login, s.name
from product p
inner join users u using (user_id)
inner join supplier s using (supplier_id)
where p.product_id = ".&str_sqlize($arr_list_merges[$i]))->[0];

							$hin{'product_merging_saved_products'} .= &repl_ph($mergings_row_best,
																																 {
																																	 'product_id'    => $p_saved->[0],
																																	 'old_prod_id'   => $p_saved->[2],
																																	 'm_prod_id'     => $p_saved->[2],
																																	 'user_id'       => $p_saved->[3],
																																	 'user_group'    => $p_saved->[4],
																																	 'login'         => $p_saved->[5],
																																	 'supplier_name' => $p_saved->[6],
																																 }) if $p_saved->[0];

							&data_management::delete_product($arr_dst_list_merges[$i]);
						}
						else { # keep destination
							## deleting source product AT ALL & make src<-dest
#			 &log_printf("delete src_product_id: ".$arr_list_merges[$i].", keep dest_product_id: ".$arr_dst_list_merges[$i]." && exchange product_id_list {=} destination_list ");

							my $p_removed = &do_query("select p.product_id, p.supplier_id, p.prod_id, p.user_id, u.user_group, u.login, s.name
from product p
inner join users u using (user_id)
inner join supplier s using (supplier_id)
where p.product_id = ".&str_sqlize($arr_list_merges[$i]))->[0];

							$hin{'product_merging_removed_products'} .= &repl_ph($mergings_row,
																																	 {
																																		 'product_id'    => $p_removed->[0],
																																		 'old_prod_id'   => $p_removed->[2],
																																		 'm_prod_id'     => $p_removed->[2],
																																		 'user_id'       => $p_removed->[3],
																																		 'user_group'    => $p_removed->[4],
																																		 'login'         => $p_removed->[5],
																																		 'supplier_name' => $p_removed->[6],
																																	 }) if $p_removed->[0];

							my $p_saved = &do_query("select p.product_id, p.supplier_id, p.prod_id, p.user_id, u.user_group, u.login, s.name
from product p
inner join users u using (user_id)
inner join supplier s using (supplier_id)
where p.product_id = ".&str_sqlize($arr_dst_list_merges[$i]))->[0];

							$hin{'product_merging_saved_products'} .= &repl_ph($mergings_row_best,
																																 {
																																	 'product_id'    => $p_saved->[0],
																																	 'old_prod_id'   => $p_saved->[2],
																																	 'm_prod_id'     => $p_saved->[2],
																																	 'user_id'       => $p_saved->[3],
																																	 'user_group'    => $p_saved->[4],
																																	 'login'         => $p_saved->[5],
																																	 'supplier_name' => $p_saved->[6],
																																 }) if $p_saved->[0];

							&data_management::delete_product($arr_list_merges[$i]);

							for (my $j=0; $j<=$#product_ids; $j++) {
								if ($product_ids[$j] == $arr_list_merges[$i]) {
									$product_ids[$j] = $arr_dst_list_merges[$i];
								}
							}
						}
					}

					my $new_id_list = '';
					for (my $i=0; $i<=$#product_ids; $i++) {
						$new_id_list .= $product_ids[$i].",";
					}

					$new_id_list =~ s/,+$//s;
					$hin{'product_id_list'} = $new_id_list;

					# report about removed & saved products
					$hin{'product_mergings_report'} = &repl_ph($mergings_body, {
						'mergings_removed_rows' => $hin{'product_merging_removed_products'},
						'mergings_saved_rows' => $hin{'product_merging_saved_products'}
																										});
					$hin{'product_mergings_report_ignore_unifiedly_processing'} = 'Yes';
					$hin{'product_merging_removed_products'} = '';
					$hin{'product_merging_saved_products'} = '';
				}

			} # end if $list_merges ne ''

			#return 0; # < dv temporary
		}

		#if ($iatoms->{'product_group_actions_list'}->{$action.'_param'} eq 'script') {			
		#	for my $product_id (@product_ids) {
		#		my $statement = &repl_ph($iatoms->{'product_group_actions_list'}->{$action.'_action'}, {
		#			'product_id' => $product_id
		#														 });
		#		$statement = '/home/gcc/bin/'.$statement;
		#		#&log_printf("\nSCRIPT: ".$statement);
		#		`$statement`;
		#	}
		#	next;
		#}
		if ($action eq 'public' or $action eq 'publish' ) {
			for my $product_id (@product_ids) {
				my $sql_pub;
				if($action eq 'public'){
					$sql_pub=' public='.&str_sqlize($hin{'search_public'}).' '
				}elsif($action eq 'publish'){
					$sql_pub=' publish='.&str_sqlize($hin{'search_publish'}).' '
				}
				&do_statement('UPDATE product SET '.$sql_pub.' WHERE product_id='.$product_id);
				&do_statement("REPLACE into process_queue(process_class_id,command,product_id,prio,queued_date,process_status_id) 
							   VALUES ('1','/home/gcc/bin/update_product_xml_chunk $product_id',$product_id,'50',unix_timestamp(),'1')");
			}
			
			next;
		}

		if ($USER->{'user_group'} eq 'category_manager') {
			if ($action eq 'category_list') {
				for my $product_id (@product_ids) {
					my $prod = get_row('product',"product_id = $product_id");
					my $prod_uid = $prod->{'user_id'};
  		            my $prod_usr = get_row('users',"user_id = $prod_uid");

					if ($prod_uid == 1 || $prod_usr->{'user_group'} eq 'supplier') {
						$prod_uid = $USER->{'user_id'}; ## catch ownership
					}
					my $update;
					$update->{'catid'} = $hin{'search_category_list'};
					$update->{'user_id'} = $prod_uid;
					&update_rows('product',"product_id = $product_id",$update);
					$changed_poducts{$product_id}=1;
					# change features due category changes
					&data_management::conform_product_feature_catid($product_id);


				}
				next;
			}
			## other actions
			for my $pid (@product_ids) {
				$changed_poducts{$pid}=1;
			}
		}

		my $statement = &repl_ph($iatoms->{'product_group_actions_list'}->{$action.'_action'}, {
			$iatoms->{'product_group_actions_list'}->{$action.'_param'} => $hin{'search_'.$action},
			'product_id' => $hin{'product_id_list'}
														 });

#	 &log_printf("\nST: $statement");

		&do_statement($statement);
		
		# change features due category changes
		if ($action eq 'category_list') {			
		    # log_printf(Dumper(\%hin));
			my $null_stock_catids=get_rating_catid_restrict();
			my $formula_params=&get_rating_params();
			for my $product_id (@product_ids) {
				&data_management::conform_product_feature_catid($product_id);
				update_null_stock_rating($null_stock_catids,$hin{'search_'.$action},$product_id,$formula_params);
				# if update virtual categories
                # update with or without virtual categories tags
                my $is_vcats = $hin{'vcats_set'};
                if ($is_vcats) {

                    # subroutine 'update_virtual_...' is oriented for 'vcat_' but we have 'search_vcat_' keys
                    for (keys %hin) {
                        if (/^search_vcat_(.+)$/) {
                            $hin{'vcat_' . $1} = $hin{$_};
                        }
                    }
                    update_virtual_categories_for_certain_product($product_id);
                }

	        }
		}

	} # for for all actions

	if ($USER->{'user_group'} eq 'category_manager') {
		for my $pid (keys %changed_poducts) { ## log changed products to editors journal
			&command_proc_add2editors_journal($pid);
		}
	}
	undef $hin{'action_group_product'};

	return 1;
}

sub command_proc_product_complaint_group_action {
	 &log_printf($hin{'search_status_list'});
	 $hin{'search_status_id'}=$hin{'search_status_list'};
	 &process_atom_ilib('product_group_actions_list');
	 &process_atom_lib('product_group_actions_list');

	 &process_atom_ilib('errors');
	 &process_atom_lib('errors');

	 my @group_actions = split(",", $iatoms->{'product_complaint_group_actions_list'}->{'actions_list'});
	 my @denied_actions = $iatoms->{'product_complaint_group_actions_list'}->{'actions_denied_variants'};
	 my %denied_actions = map{$_ => 1} @denied_actions;
	 &log_printf(Dumper(\@denied_actions));
	 my @actual_actions;
	 for my $action(@group_actions){
		 if($hin{$action} == 1){
			 push @actual_actions, $action;
	 }}

	 #check for empty actions list
	 if($#actual_actions == -1){
		 push @user_errors, $atoms->{'default'}->{'errors'}->{'group_actions_empty'};
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }

	 #check for denied actions pares
	 my @errors;
	 for my $action1(@actual_actions){
		 for my $action2(@actual_actions){
			if($denied_actions{$action1."#".$action2}){
				push @errors, $atoms->{'default'}->{'errors'}->{'group_actions'}."(".$atoms->{'default'}->{'product_complaint_group_actions_list'}->{$action1}.",".$atoms->{'default'}->{'product_complaint_group_actions_list'}->{$action2}.")";
	 }}}
	 if($#errors != -1){
		 @user_errors = @errors;
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }

	 for my $action (@actual_actions){
		 my $statement = &repl_ph($iatoms->{'product_complaint_group_actions_list'}->{$action.'_action'}, {
			 $iatoms->{'product_complaint_group_actions_list'}->{$action.'_param'} => $hin{'search_'.$action},
			 'complaint_id' => $hin{'complaint_id_list'}
		 });
		 &log_printf("\nST: $statement\n --------> action: $action");
	 	 &do_statement($statement);
		 if($action eq 'delete'){
			$statement = &repl_ph($iatoms->{'product_complaint_group_actions_list'}->{'delete_action_sub'}, {
				$iatoms->{'product_complaint_group_actions_list'}->{$action.'_param'} => $hin{'search_'.$action},
				'complaint_id' => $hin{'complaint_id_list'}
			});
			&log_printf("\nST: $statement\n --------> action: $action");
			&do_statement($statement);
		 }
	 }

	 return 1;
}

sub command_proc_exec_clipboard_processing {
 &atom_cust::proc_custom_processing_clipboard;

 return 1;
}

sub command_proc_track_product_all_group_action {
	 &process_atom_ilib('track_products_all_actions');
	 &process_atom_lib('track_products_all_actions');

	 &process_atom_ilib('errors');
	 &process_atom_lib('errors');

	 my @group_actions = split(",", $iatoms->{'track_products_all_actions'}->{'actions_list'});
	 my @denied_actions = $iatoms->{'track_products_all_actions'}->{'actions_denied_variants'};
	 my %denied_actions = map{$_ => 1} @denied_actions;
	 &log_printf(Dumper(\@denied_actions));
	 my @actual_actions;
	 for my $action(@group_actions){
		 if($hin{$action} == 1){
			 push @actual_actions, $action;
	 }}

	 #check for empty actions list
	 if($#actual_actions == -1){
		 push @user_errors, $atoms->{'default'}->{'errors'}->{'group_actions_empty'};
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }

	 #check for denied actions pares
	 my @errors;
	 for my $action1(@actual_actions){
		 for my $action2(@actual_actions){
			if($denied_actions{$action1."#".$action2}){
				push @errors, $atoms->{'default'}->{'errors'}->{'group_actions'}."(".$atoms->{'default'}->{'track_products_all_actions'}->{$action1}.",".$atoms->{'default'}->{'track_products_all_actions'}->{$action2}.")";
	 }}}
	 if($#errors != -1){
		 @user_errors = @errors;
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }
	 use track_lists;
	 my $params_cleaned=$hin{'track_product_id_list'};
	 for my $action (@actual_actions){
	 	 my @ids=split(',',$params_cleaned);
	 	 if($action eq 'delete'){
	 	 	for my $id (@ids){	 	 		 
	 	 		delete_track_product_rule($id);
	 	 	}
	 	 }elsif($action eq 'add_mapping'){
			 for my $id (@ids){
			 	&lp('----->>>>>>>>>>>>>>>>>>>>>>>>'.$id);
			 	add_track_product_rule($id);
			 }		 	
		 }
	 }
	$hl{'track_product_all_saved_values'}='';
	 return 1;
}

sub command_proc_track_product_group_action{
	 &process_atom_ilib('track_products_actions');
	 &process_atom_lib('track_products_actions');

	 &process_atom_ilib('errors');
	 &process_atom_lib('errors');

	 my @group_actions = split(",", $iatoms->{'track_products_actions'}->{'actions_list'});
	 my @denied_actions = $iatoms->{'track_products_actions'}->{'actions_denied_variants'};
	 my %denied_actions = map{$_ => 1} @denied_actions;
	 &log_printf(Dumper(\@denied_actions));
	 my @actual_actions;
	 for my $action(@group_actions){
		 if($hin{$action} == 1){
			 push @actual_actions, $action;
	 }}

	 #check for empty actions list
	 if($#actual_actions == -1){
		 push @user_errors, $atoms->{'default'}->{'errors'}->{'group_actions_empty'};
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }

	 #check for denied actions pares
	 my @errors;
	 for my $action1(@actual_actions){
		 for my $action2(@actual_actions){
			if($denied_actions{$action1."#".$action2}){
				push @errors, $atoms->{'default'}->{'errors'}->{'group_actions'}."(".$atoms->{'default'}->{'track_products_actions'}->{$action1}.",".$atoms->{'default'}->{'track_products_actions'}->{$action2}.")";
	 }}}
	 if($#errors != -1){
		 @user_errors = @errors;
		 &atom_cust::proc_custom_processing_errors;
		 return 0;
	 }
	 my $params_cleaned=$hin{'track_product_id_list'};	 
	 my @ids=split(',',$params_cleaned);
	 for my $action (@actual_actions){
	 	 if($action eq 'park'){
			 for my $id (@ids){
			 	my $is_parked=&do_query('SELECT is_parked FROM track_product WHERE track_product_id='.$id)->[0][0];
			 	if(!$is_parked){
			 		&do_statement("UPDATE track_product SET is_parked=1,remarks=".&str_sqlize($hin{'remarks'}).",changer=$USER->{'user_id'},changer_action='Parks product' WHERE track_product_id=".$id);
			 	}# nothing to park
			 }		 		 	 	
	 	 }elsif($action eq 'unpark'){
			 for my $id (@ids){
			 	my $was_parked=&do_query('SELECT is_parked FROM track_product WHERE track_product_id='.$id)->[0][0];
			 	if($was_parked){			 	
			 		&do_statement("UPDATE track_product SET is_parked=0,remarks='',changer=$USER->{'user_id'},changer_action='Unparks product' WHERE track_product_id=".$id);
			 	}
			 }		 	
		 }
	 }
	 return 1;
}

sub command_proc_get_gallery_pic {

	my $hash = {};

    &process_atom_ilib('product_multimedia_gallery');
	&process_atom_lib('product_multimedia_gallery');

	&process_atom_ilib('errors');
	&process_atom_lib('errors');

	# delete picture
 	if ($hin{'atom_submit'} eq $atoms->{'default'}->{'product_multimedia_gallery'}->{'delete_picture_value'}) {
 	    my $url = $hin{'gallery_pic'};

 	    # after this delete we should store info about picture into EJ
 	    # So, we should save URL

		&delete_rows("product_gallery", "link = " . str_sqlize($url) );
		$hin{'product_gallery_stored_link'} = $url;

		my $ans = do_query("
		    SELECT ROW_COUNT()
		")->[0]->[0];
		if ($ans == 0) {
		    push @user_errors, "URL is missed or incorrect";
		    return 1;
		}

		# store outdated picture to remote host
		if ( ($atomcfg{'outdated_images_user'}) && ($atomcfg{'outdated_images_host'}) && ($atomcfg{'outdated_images_path'}) ) {
    	    my $source = $atomcfg{'images_user'} . '@' . url2scp_path($url);
			my $drain =
			    $atomcfg{'outdated_images_user'} . '@' .
				$atomcfg{'outdated_images_host'} . ":" .
				$atomcfg{'outdated_images_path'} . get_name_from_url($url);
    		log_printf("scp $source $drain");
	    	qx(scp $source $drain);
	    }

	}
	else {
		# add picture
		if(-s $hin{'gallery_pic_filename'}) {
			$hash->{'link'} = $hin{'gallery_pic_filename'}
		}
		else {
			$hash->{'link'} = $hin{'gallery_pic'};
		}

		$hash->{'dir_path'} = $atomcfg{'base_dir'}.'/www/img/gallery/';
		$hash->{'hosted'} = $atomcfg{'bo_host'}.'img/gallery/';
		$hash->{'dbtable'} = "product_gallery";
		$hash->{'dbfield'} = "link";
		$hash->{'id'} = "product_id";
		$hash->{'id_value'} = $hin{'product_id'};

		my $pic_hash = &get_gallery_pic_params($hash->{'link'}); # FIX THIS CAREFULLY!!! ?????????????????????????????

        srand;
        my $rand_index = int(rand(10000));
        while (&do_query("select id from product_gallery_reverse where link like REVERSE('%".$hin{'product_id'}."_".$rand_index.".jpg')")->[0][0]) {
            srand;
            $rand_index = int(rand(10000));
        }

		$hash->{'link'} = &thumbnail::mirror_image($hash->{'link'});
		my $dst_link = &add_image($hash->{'link'}, 'img/gallery/', $atomcfg::targets, $hin{'product_id'}.'_'.$rand_index.'.jpg');

		&insert_rows($hash->{'dbtable'}, {
			$hash->{'id'} => $hash->{'id_value'},
			'link' => &str_sqlize($dst_link)
			}
		);

		my $thumb_hash = {
			'gallery_id' => &sql_last_insert_id(),
			'product_id' => $hash->{'id_value'},
			'gallery_pic' => $dst_link
		};

		my $thumb = &thumbnailize_product_gallery($thumb_hash);

		if (!$thumb) {
			push @user_errors, $atoms->{'default'}->{'errors'}->{'gallery_thumbnail'};
			&atom_cust::proc_custom_processing_errors;
			&delete_rows('product_gallery', "id = ".&str_sqlize(&sql_last_insert_id()));
			return 1;
		}

		my $gallery_hash = {
			'dbfield' => "link",
			'dbtable' => "product_gallery",
			'id' => 'id',
			'id_value' => $thumb_hash->{'gallery_id'}
		};

		get_obj_size($gallery_hash, 'size');
		get_obj_width_and_height($gallery_hash, 'width', 'height');

		$pic_hash->{'thumb_link'} = &str_sqlize($thumb);

		$hin{'gallery_pic'} = $dst_link;
	}

	return 1;
} # sub command_proc_get_gallery_pic

sub command_proc_get_object_url {
	my $hash = {};

	if ($hin{'tmpl'} eq 'product_multimedia_object_details') {
		&process_atom_ilib('product_multimedia_object_details');
		&process_atom_lib('product_multimedia_object_details');
	}

	# delete picture from objects details
 	if ($hin{'atom_submit'} eq $atoms->{'default'}->{'product_multimedia_object_details'}->{'delete_object_value'}) {
		&delete_rows("product_multimedia_object", "id = ".$hin{'object_id'});
	}
	else {
		$hin{'object_url_filename'} = undef if -z $hin{'object_url_filename'};

		# add picture

		$hash->{'dbtable'} = "product_multimedia_object";
		$hash->{'dbfield'} = "link";
		$hash->{'id'} = "product_id";
		$hash->{'id_value'} = $hin{'product_id'};
		$hash->{'link'} = $hin{'object_url'} || $hin{'object_url_filename'};

		# check if the same link

		my $old_link = $hin{'object_id'} ? &do_query("select ".$hash->{'dbfield'}." from ".$hash->{'dbtable'}." where id=".$hin{'object_id'})->[0][0] : '';
		my $skip_object_update = 0;

		if (($old_link eq $hash->{'link'}) && ($hin{'object_id'})) {
			$skip_object_update = 1;
			goto skip_object_update;
		}

		# init

		my $fileext;
		my $type;
		my $rand_index;
		my $src_file;

		if (! $hin{'keep_as_url'}) {

			$hash->{'dir_path'} = $atomcfg{'base_dir'} . '/www/objects/';
			$hash->{'hosted'} = $atomcfg{'objects_host'} . 'objects/';

			# own get_obj_url procedure because of two keys (id, product_id)
			if ($hash->{'link'} =~ /^.+(\..+)$/) {
				$fileext = $1;
			}
			if ($hash->{'link'} =~ /(\..{3,4})$/) {
				$type = $1;
			}

			if (length($type) > 5) {
				$type = '';
			}

			if (length($fileext) > 5) {
				$fileext = '';
			}

			srand;
			$rand_index = int(rand(10000));
			while (&do_query("select id from product_multimedia_object_reverse where link like REVERSE('%".$hin{'id_value'}."_".$rand_index.$type."')")->[0][0]) {
				srand;
				$rand_index = int(rand(10000));
			}

			$src_file = $atomcfg{'base_dir'}.'tmp/'.$hash->{'id_value'}.'_'.$rand_index.$fileext.".copied";

			if ($hash->{'link'} =~ /^(ht|f)tps?:\/\//) {
				`wget -q '$hash->{'link'}' -O '$src_file'`;
			}
			else {
				`cp '$hash->{'link'}' '$src_file'`;
			}

			log_printf("OBJ = ".$hash->{'link'}.", SRC = ".$src_file." size SRC = " . (-s $src_file));

			return 1 unless -f $src_file;

			$hin{'object_url'} = &add_image($src_file, 'objects/', $atomcfg::object_targets, $hash->{'id_value'}.'_'.$rand_index.$fileext, 'keep src file');

		}
		else {

		}

		# insert/update hash forming

    	skip_object_update:

	    my $ct;
	    if ($src_file) {
    	    $ct = `file -b --mime '$src_file'`;
    	    chomp($ct);
    	}

		my $ui_hash = {
			$hash->{'id'}  => $hash->{'id_value'},
			'short_descr'  => &str_sqlize($hin{'object_descr'}),
			'langid'       => $hin{'object_langid'},
			'size'         => ($hin{'keep_as_url'}) ? 0 : ((-s $src_file) || 0),
			'link'         => &str_sqlize(($hin{'keep_as_url'}) ? $hash->{'link'} : $hin{'object_url'}),
			'content_type' => &str_sqlize($ct),
			'type'         => &str_sqlize($hin{'type'} || 'standard'),
			'keep_as_url'  => $hin{'keep_as_url'} || 0,
			'height'       => $hin{'height'} || 0,
			'width'        => $hin{'width'} || 0,
		};

		if ($skip_object_update) { # do not touch link settings if link isn't changed

			log_printf("DO NOT CHANGE MO!.. (pmo.id=".$hin{'object_id'}.")");

			delete $ui_hash->{'link'};
			delete $ui_hash->{'size'};
			delete $ui_hash->{'content_type'};
			delete $ui_hash->{'type'};
			delete $ui_hash->{'keep_as_url'};
			delete $ui_hash->{'height'};
			delete $ui_hash->{'width'};
		}

		# do insert/update

		if ($hin{'atom_submit'} eq $atoms->{'default'}->{'product_multimedia_object_details'}->{'update_object_value'}) {
			# update object from objects details
			&update_rows($hash->{'dbtable'}, "id = $hin{'object_id'}", $ui_hash);
		}
		else {
			# insert new object
			&insert_rows($hash->{'dbtable'}, $ui_hash);
		}

		`/bin/rm -f $src_file`;
#		if (!$hin{'keep_as_url'}) {
#			$hin{'object_url'} = $hash->{'hosted'}.$hash->{'id_value'}.'_'.$rand_index.$fileext;
#		}
	}

	return 1;
} # sub command_proc_get_object_url

## new capability to log group actions
## applied in 'command_proc_product_group_action'
sub command_proc_add2editors_journal {
	my ($batch_pid) = @_;
	my ($atom2table, $table2table_id, $table2table_id_value);
	
	$atom2table = {
		'product'							=> 'product',
		'product_description'				=> 'product_description',
		'product_description_new'			=> 'product_description',
		'product_features'					=> 'product_feature',
		'product_bundled'					=> 'product_bundled',
		'product_related'					=> 'product_related',
		'product_multimedia_gallery'		=> 'product_gallery',
		'product_multimedia_object_details'	=> 'product_multimedia_object',
		'product_multimedia_object_edit'	=> 'product_multimedia_object',
		'product_ean_codes'					=> 'product_ean_codes',
		'product_features_local_ajax'		=> 'product_feature_local',
		'product_related'					=> 'product_related',
		'product_gallery'					=> 'product_gallery'
	};
	
	$table2table_id = {
		'product'							=> 'product_id',
		'product_description'				=> 'product_description_id',
		'product_feature'					=> 'product_feature_id',
		'product_related'					=> 'product_related_id',
		'product_bundled'					=> 'id',
		'product_gallery'					=> 'id',
		'product_multimedia_object'			=> 'id',
		'product_ean_codes'					=> 'ean_id',
		'product_feature_local'				=> 'product_feature_local_id',
		'product_related'					=> 'product_related_id'
	};

	$table2table_id_value = {
		'product'							=> 'product_id',
		'product_description'				=> 'product_description_id',
		'product_feature'					=> 'product_feature_id',
		'product_related'					=> 'product_related_id',
		'product_bundled'					=> 'product_bundled_id',
		'product_gallery'					=> 'gallery_id',
		'product_multimedia_object'			=> 'object_id',
		'product_ean_codes'					=> 'ean_id',
		'product_feature_local'				=> 'product_feature_local_id',
		'product_related'					=> 'product_related_id'
	};

    # define hash to insert into the 'editor_journal'
    my $hash2insert = {};
    
    $hash2insert->{'user_id'} = $USER->{'user_id'};
    
    if (defined $batch_pid) {
        $hash2insert->{'product_table'} = 'product';
    } else {
        $hash2insert->{'product_table'} = $atom2table->{$hin{'atom_name'}};
    }
    
    $hash2insert->{'date'} = "unix_timestamp()";

    # get product table id-s
    # -----------------------------------------------------
    my $product_table_ids;
    
    if (defined $batch_pid) {
        $product_table_ids->[0]->[0] = $batch_pid;
    } else {
        $product_table_ids->[0]->[0] = $hin{$table2table_id_value->{$hash2insert->{'product_table'}}};
    }

    #
    # Main query to get ID
    #

    if (($hash2insert->{'product_table'} ne 'product_feature') && !$product_table_ids->[0]->[0]) {
        my $q = "SELECT MAX(" . $table2table_id->{$hash2insert->{'product_table'}} . ") FROM " . $hash2insert->{'product_table'};
	    $product_table_ids = &do_query($q);
    } elsif ($hash2insert->{'product_table'} eq 'product_feature') {
	    $product_table_ids = &do_query("
	        select product_feature_id
	        from product_feature
	        where product_id = ".$hin{'product_id'}." and (unix_timestamp(updated) >= ".$hin{'feature_updated'}.")
	    ");
    }

    #
    # Different exceptions for reaching ID
    #

    # 'product_featue_local' case
    if ($hash2insert->{'product_table'} eq 'product_feature_local') {
        my $req = "SELECT product_feature_local_id FROM product_feature_local WHERE product_id = " . $hin{'product_id'} .
            " AND (unix_timestamp(updated) >= " . $hin{'feature_updated'} . " )";
        $product_table_ids = &do_query($req);
    }

    # 'product_related' case
    if ($hash2insert->{'product_table'} eq 'product_related') {

        # this request return something if we have done 'insert' operation
        my $req = "SELECT product_related_id FROM product_related WHERE product_id = " . $hin{'product_id'} .
            " AND (unix_timestamp(updated) >= " . $atomsql::current_ts . "  ) ";
        $product_table_ids = &do_query($req);

        # in another way check for 'delete' operation
        # we can delete only single related product, so...
        if ($hin{'atom_delete'} eq 'Delete' ) {
            push @$product_table_ids, [ $hin{'product_related_id'} ];
        }
    }

    # add fake ID for already removed record
    if ($hash2insert->{'product_table'} eq 'product_gallery') {
        # fake ID
        # just to enter into 'for' loop below
        if ($hin{'atom_submit'} eq 'Delete picture') {
            $product_table_ids = [ [ 0 ] ];
        }
    }

    # -----------------------------------------------------

    if (defined $batch_pid) {
        $hash2insert->{'product_id'} = $batch_pid;
    }
    else {
        $hash2insert->{'product_id'} = $hin{'product_id'};
    }

    my $product_data = &do_query("select supplier_id, catid, prod_id from product where product_id = ".$hash2insert->{'product_id'})->[0];
    
    $hash2insert->{'supplier_id'} = $product_data->[0];
    $hash2insert->{'catid'} = $product_data->[1];
    $hash2insert->{'prod_id'} = &str_sqlize($product_data->[2]);
    
    if (defined $batch_pid) {
        $hash2insert->{'product_table'} = &str_sqlize('product');
    } else {
        $hash2insert->{'product_table'} = &str_sqlize($atom2table->{$hin{'atom_name'}});
    }

    # in the past
    # $product_table_ids - is empty in case of 'product_feature_local'
    # but now it contsins id-s list

    # exit if empty changeset
    return 1 if (scalar @$product_table_ids == 0);

    # some new vars for 'product_feature_case'
    my $upd_features = {};
    my $last_id = @$product_table_ids[scalar @$product_table_ids - 1]->[0];
    my $ins_counter = 0;
    my $del_counter = 0;
    my $all_counter = 0;

    for my $product_table_id (@$product_table_ids) {

	    $hash2insert->{'product_table_id'} = $product_table_id->[0];

        # score
	    if (&do_query(
	        "SELECT id FROM editor_journal WHERE product_table = " . $hash2insert->{'product_table'} .
	        " AND user_id = " . $hash2insert->{user_id} .
	        " AND product_table_id = " . $product_table_id->[0])->[0]->[0]) {
		    $hash2insert->{'score'} = 0;
	    } else {
		    $hash2insert->{'score'} = 1;
	    }

	    #
	    # get submitted values to history tables for different situations
	    #

	    # used for: mm_objects and gallery
	    my $action_type = 0;
	    # 0 - undef
	    # 1 - insert
	    # 2 - delete
	    # 3 - update
	    my $is_cancel_ej = 0;

	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------

	    if ($hash2insert->{'product_table'} eq "'product_feature'") {

	        # process features one by one
	        my $get_prev_value = sub {
	            my $cfid = shift;
	            # log_printf("ARG = " . $cfid);
	            # log_printf(Dumper($hin{'prev_feature_values'} ) );
	            my $arr_ref = $hin{'prev_feature_values'};
	            for (@$arr_ref) {
	                if ($_->[0] == $cfid) {
	                    return $_->[1];
	                }
	            }
	            return '';
	        };

	        # get current feature value
	        my $ans = get_certain_product_feature($hash2insert->{'product_table_id'} );
	        my $curr = $ans->[0]->[0];

	        # add to hash
	        my $tmp1 = $get_prev_value->($ans->[0]->[2]);
	        my $tmp2 = $ans->[0]->[0];
	        $upd_features->{ $ans->[0]->[1] } = $tmp1 . chr(0) . $tmp2;

	        $ins_counter++ if ( (! $tmp1) and ($tmp2) );
	        $del_counter++ if ( ($tmp1) and (! $tmp2) );
	        $all_counter++;

    	    # insert into 'editor_journal_product_feature_pack'
            # add record only for last feature in list
            if ($last_id == $product_table_id->[0] ) {

                insert_into_ej_product_feature_pack(ser_pack($upd_features));
                if ($ins_counter == $all_counter) {
                    $action_type = 1;
                }
                elsif ($del_counter == $all_counter) {
                    $action_type = 2;
                }
                else {
                    $action_type = 3;
                }
            }
            else {
                $is_cancel_ej = 1;
            }

	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    elsif ($hash2insert->{'product_table'} eq "'product_description'") {

	        # fields sequence for 'product_description'
	        # langid, short_desc, long_desc, official_url, warranty_info, pdf_url, manual_pdf_url

	        # get current
	        my $ans = get_certain_product_description($hash2insert->{'product_table_id'} );

	        # get prev
	        # prev long description has been already packed
	        my $prev = get_previous_product_description($hash2insert->{'date'}, $hash2insert->{'product_table_id'} );

	        # if delete
	        if ($hin{'atom_delete'} eq '.') {
	            $action_type = 2;
	        }
	        # if insert
	        if ( ($hin{'atom_update'} eq '.') && ($hin{'atom_name'} eq 'product_description_new' ) ) {
	            $action_type = 1;
	        }
	        # if update
	        if ( ($hin{'atom_update'} eq '.') && ($hin{'atom_name'} eq 'product_description' ) ) {
	            $action_type = 3;
	        }

	        # create fake specific EJ_PD records for 'update' and 'delete' actions
	        if ( ($action_type == 2) || ($action_type == 3) ) {

	            if (! $prev->[0]->[0]) {

    	            # if prev not existed, try to fing place for fake
	                my $existed_ej_rec_id = get_previous_ej_id_for_fake_description($hash2insert->{'date'}, $hash2insert->{'product_table_id'} );

	                $prev = $hin{'prev_product_description'};
                    $prev->[0]->[2] = ser_pack($prev->[0]->[2]);
                    insert_into_ej_product_description($prev);
                    my $ejpd_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];

                    # if existed
                    if ($existed_ej_rec_id) {
                        do_statement("
                            UPDATE editor_journal SET content_id = $ejpd_id, action_type = 4
                            WHERE id = $existed_ej_rec_id
                        ");
                    }
                    else {
                        # there is no site in EJ for prev data
                        my $ej = {
                            user_id => $USER->{'user_id'},
                            product_table => 'product_description',
                            product_table_id => $hash2insert->{'product_table_id'},
                            date => ( $atomsql::current_ts - 1 ),
                            product_id => $hin{'product_id'},
                            supplier_id => 0,
                            prod_id => 0,
                            catid => 0,
                            score => 0,
                            action_type => 5,
                            content_id => $ejpd_id
                        };
                        insert_into_ej($ej);
                    }
                }
	        }

	        # pack current description before 'is_diff' calc
	        $ans->[0]->[2] = ser_pack($ans->[0]->[2]);

	        my $is_diff = 0;
         	for ( my $i = 0 ; $i < scalar (@{$ans->[0]}) ; $i++ ) {
      	        if ($ans->[0]->[$i] ne $prev->[0]->[$i] ) {
           	        $is_diff = 1;
           	    }
           	}

	        if ( ($action_type == 1) || ($action_type == 3) ) {
	            if ($is_diff) {
	                insert_into_ej_product_description($ans);
	            }
	            else {
	                $is_cancel_ej = 1;
	            }
	        }
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # 'product_name' and 'product' (one submit button for 2 tables)
	    # if product has been deleted we should not perform any actions
	    elsif (($hash2insert->{'product_table'} eq "'product'") && (! $hin{'atom_delete'})) {

	        # changes for 'product_name' table in EJ marked like changes in 'product' table
	        # so, we should check changes in 'product_name' for current product_id

	        # this request will extract all 'product_name' records except deleted
	        my $req =
	            "SELECT product_name_id FROM product_name WHERE product_id = " . $hin{'product_id'} .
	            " AND (unix_timestamp(updated) >= " . $atomsql::current_ts . "  )";

	        my $ids = do_query($req);

            # if present any changes into 'product_name'
            for my $pn_id (@$ids) {

                # get current from product_name
                my $name_rec = get_certain_product_name($pn_id->[0]);

                # try get prev
                my $prev = get_previous_product_name( $hash2insert->{'date'}, $pn_id->[0] );
    	        my $p_name = $prev->[0]->[0];

                if (! $prev->[0]->[0]) {

                    my $existed_ej_rec_id = get_previous_ej_id_for_fake_name($hash2insert->{'date'}, $name_rec->[0]->[2] );

                    # if existed
                    if ($existed_ej_rec_id) {

                        # select value with certain langid
                        my $arr_ref = $hin{'prev_product_name'};
                        for (@$arr_ref) {
                            if ($_->[1] == $name_rec->[0]->[1]) {
                                $p_name = $_->[0];
                                last;
                            }
                        }

                        insert_into_ej_product_name($p_name, $name_rec->[0]->[1]);
                        my $ejpn_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];
                        do_statement("
                            UPDATE editor_journal SET content_id = $ejpn_id, action_type = 4
                            WHERE id = " . $existed_ej_rec_id
                        );
                    }
                    else {
                        # No place for FAKE update
                    }
                }

        	    my $curr = $name_rec->[0]->[0];

        	    $action_type = 0;
        	    $action_type = 1 if ($curr and !$p_name);
	            $action_type = 2 if (!$curr);
	            $action_type = 3 if ($curr and $p_name);

                # insert into EJ_product_name
                insert_into_ej_product_name($name_rec->[0]->[0], $name_rec->[0]->[1]);
                my $id = do_query('SELECT LAST_INSERT_ID()');

                # new fields for EJ table
                my %hash2insert_local = %$hash2insert;
	            $hash2insert_local{'content_id'} = $id->[0]->[0];
	            $hash2insert_local{'action_type'} = $action_type;
	            $hash2insert_local{'product_table'} = "'product_name'";
	            $hash2insert_local{'product_table_id'} = $pn_id->[0];

	            # insert to EJ
	            # this is local invocation
	            # global is placed below
    	        insert_rows("editor_journal", \%hash2insert_local);
            }

            ####################################################
            # detect deleted 'product_name' instances (no records in 'product_name' but saved by precommand)
            ####################################################

            my $pname_now = do_query("
                SELECT name, langid
                FROM product_name
                WHERE product_id = " . $hin{'product_id'}
            );
            my $sql_ans2hash = sub {
                my $arg = shift;
                my $res = {};
                my ($langid, $val);
                for (@$arg) {
                    $langid = $_->[1];
                    $val = $_->[0];
                    $res->{$langid} = $val;
                }
                return $res;
            };

            my $ns_prev = $sql_ans2hash->($hin{'prev_product_name'} );
            my $ns_now = $sql_ans2hash->($pname_now);

            my $deleted = {};
            for (keys %$ns_prev) {
                if ( ($ns_prev->{$_}) and (! $ns_now->{$_}) ) {
                    $deleted->{$_} = $ns_prev->{$_};
                }
            }

            for (keys %$deleted) {
                # insert into EJ_product_name
                insert_into_ej_product_name($deleted->{$_}, $_);
                my $id = do_query('SELECT LAST_INSERT_ID()');

                # new fields for EJ table
                my %hash2insert_local = %$hash2insert;
	            $hash2insert_local{'content_id'} = $id->[0]->[0];
	            $hash2insert_local{'action_type'} = 2;
	            $hash2insert_local{'product_table'} = "'product_name'";
	            $hash2insert_local{'product_table_id'} = 0;

    	        insert_rows("editor_journal", \%hash2insert_local);
    	    }

            ####################################################

	        # -------------------------------------------
	        # -------------------------------------------
	        # -------------------------------------------
	        # general product info

	        # fields order for 'product' table
	        # supplier_id, prod_id, catid, user_id, name, low_pic, high_pic, publish, public, thumb_pic, family_id

	        # get current state
	        my $ans = get_certain_product($hash2insert->{'product_table_id'} );

	        # get previous state (before or eq 'date' and same 'id' )
	        my $prev = get_previous_product($hash2insert->{'date'}, $hash2insert->{'product_table_id'} );

            # if previous not exists try to find prev record in 'ej' and insert some "earlier" update for 'ej_product'
            # use 'catid' for detection
            if (! $prev->[0]->[2] && $hin{'prev_product'}) {

                # get prev value from pre command
                $prev = $hin{'prev_product'};

                # try to get prev 'id' from ej
                my $existed_ej_rec_id = get_previous_ej_id_for_fake($hash2insert->{'date'}, $hash2insert->{'product_id'} );
                insert_into_ej_product($prev);
                my $ejp_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];

                if ($existed_ej_rec_id) {
                    # A site for for FAKE record is present
                    do_statement("
                        UPDATE editor_journal
                        SET content_id = $ejp_id, action_type = 4
                        WHERE id = $existed_ej_rec_id;
                    ");
                }
                else {
                    # No place in EJ for FAKE record
                    my $ej = {
                        user_id => $USER->{'user_id'},
                        product_table => 'product',
                        product_table_id => $hash2insert->{'product_table_id'},
                        date => ( $atomsql::current_ts - 1 ),
                        product_id => $hin{'product_id'},
                        supplier_id => $prev->[0]->[0],
                        prod_id => $prev->[0]->[1],
                        catid => $prev->[0]->[2],
                        score => 0,
                        action_type => 5,
                        content_id => $ejp_id
                    };
                    my $new_id = insert_into_ej($ej);
                }
            }

            # if different
        	my $is_diff = 0;
        	my $diff_reason = -1;
         	for ( my $i = 0 ; $i < scalar (@{$ans->[0]}) ; $i++ ) {

         	    # non family_id case
         	    if ($i != 10) {
         	        if ($ans->[0]->[$i] ne $prev->[0]->[$i]) {
             	        $is_diff = 1;
             	        $diff_reason = $i;
             	    }
         	    }
         	    else {
         	        # family_id case
         	        next if ($ans->[0]->[$i] == 0) && ($prev->[0]->[$i] == 1);
         	        next if ($ans->[0]->[$i] == 1) && ($prev->[0]->[$i] == 0);
         	        if ($ans->[0]->[$i] ne $prev->[0]->[$i]) {
         	            $is_diff = 1;
         	            $diff_reason = $i;
         	        }
         	    }
           	}

           	# if store info about prev than 'update' else 'insert'
           	if ($hin{'atom_submit'} ) {
                $action_type = 1;
            }
            else {
                $action_type = 3;
            }

        	if ($is_diff) {
        	    insert_into_ej_product($ans);
    	    }
    	    else {
    	        $is_cancel_ej = 1;
    	        # log_printf('There is no new info to submit');
    	    }
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    elsif ($hash2insert->{'product_table'} eq "'product_feature_local'") {

	        # process local features one by one
	        # $hin{'prev_feature_local_values'}

	        my $get_prev_value = sub {
	            my $cfid = shift;
	            # log_printf("ARG = " . $cfid);
	            # log_printf(Dumper($hin{'prev_feature_local_values'} ) );
	            my $arr_ref = $hin{'prev_feature_local_values'};
	            for (@$arr_ref) {
	                if ($_->[0] == $cfid) {
	                    return $_->[1];
	                }
	            }
	            return '';
	        };

	        # use product_feature_local_id instead product_feature_id as key for packed hash
	        my $ans = get_certain_product_feature_local($hash2insert->{'product_table_id'} ,  $hin{'prev_feature_local_language'} );

            # add to hash
    	    my $tmp1 = $get_prev_value->($ans->[0]->[2]);
    	    my $tmp2 = $ans->[0]->[0];
    	    $upd_features->{ $ans->[0]->[1] } = $tmp1 . chr(0) . $tmp2;

            $ins_counter++ if ( (! $tmp1) and ($tmp2) );
            $del_counter++ if ( ($tmp1) and (! $tmp2) );
            $all_counter++;

	        if ($last_id == $product_table_id->[0] ) {
	            # insert if last
	            my $langid = $hin{'prev_feature_local_language'};
	            $upd_features->{'langid'} = $langid;

	            insert_into_ej_product_feature_local_pack( ser_pack($upd_features) );

	            # set action
	            if ($ins_counter == $all_counter) {
	                $action_type = 1;
	            }
	            elsif ($del_counter == $all_counter) {
	                $action_type = 2;
	            }
	            else {
	                $action_type = 3;
	            }
	        }
	        else {
	            $is_cancel_ej = 1;
	        }
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # we should not do any actions if user's error occurred
	    elsif ( ($hash2insert->{'product_table'} eq "'product_gallery'") && (scalar @user_errors == 0) ) {

	        # no update action for 'product_gallery'
	        # only insert and delete

	        # INSERT
	        if ($hin{'atom_submit'} eq 'Add picture') {

	            # get a single para for history
    	        my $link = do_query("
	                SELECT link
	                FROM product_gallery
	                WHERE id = " . $hash2insert->{'product_table_id'}
    	        )->[0]->[0];

                do_statement("
                    INSERT INTO editor_journal_product_gallery (link) VALUES ( " . str_sqlize($link) . " )
                ");

	            $action_type = 1;
	        }

	        # DELETE
	        if ($hin{'atom_submit'} eq 'Delete picture') {
	            do_statement("
                    INSERT INTO editor_journal_product_gallery (link) VALUES ( " . str_sqlize($hin{'product_gallery_stored_link'}) . " )
                ");
	            $action_type = 2;
	        }
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    elsif ($hash2insert->{'product_table'} eq "'product_ean_codes'") {

	        # if insert
	        if ($hin{'atom_submit'} eq '.') {
	            $action_type = 1;

	            my $ans = do_query("SELECT ean_code FROM product_ean_codes WHERE ean_id = " . $hash2insert->{'product_table_id'} );
    	        do_statement("INSERT INTO editor_journal_product_ean_codes (ean_code) VALUES (" . str_sqlize($ans->[0]->[0]) . ") ");
	        }

	        # if delete
	        if ($hin{'atom_delete'} eq '.') {
	            my $del_ean = $hin{'ean_code'};
	            do_statement("INSERT INTO editor_journal_product_ean_codes (ean_code) VALUES (" . str_sqlize($del_ean) . ")");
	            $action_type = 2;
	        }
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    elsif ($hash2insert->{'product_table'} eq "'product_name'") {
    	    # changes for 'product_name' table looks like changes for 'product' table
	        # so this section is empty
	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    elsif ($hash2insert->{'product_table'} eq "'product_multimedia_object'") {

				# correct fields order
				# short_descr, langid, content_type, keep_as_url, type, link

				# get current ( exist if add new or update )
				my $ans = get_certain_product_mmo($hash2insert->{'product_table_id'} );

				# try to get prev ( exist if delete or update )
				my $prev = get_previous_product_mmo( $hash2insert->{'date'}, $hash2insert->{'product_table_id'} );

				$action_type = 1 if ($hin{'atom_submit'} eq 'Add object');
				$action_type = 2 if ($hin{'atom_submit'} eq 'Delete object');
				$action_type = 3 if ($hin{'atom_submit'} eq 'Update object');

				if ( ($action_type == 2) || ($action_type == 3) ) {

					if (! $prev->[0]->[0]) {

						# if prev not existed, try to find place for fake
						my $existed_ej_rec_id = get_previous_ej_id_for_fake_mmo($hash2insert->{'date'}, $hash2insert->{'product_table_id'} );

						$prev = $hin{'prev_product_multimedia_object'};

						insert_into_ej_product_mmo($prev);
						
						my $ejpmmo_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];

						if ($existed_ej_rec_id) {
							do_statement("
                            UPDATE editor_journal SET content_id = $ejpmmo_id, action_type = 4
                            WHERE id = $existed_ej_rec_id;
                        ");
						}
						else {
							# no place for FAKE, add new rec to EJ
							my $ej = {
								'user_id' => $USER->{'user_id'},
								'product_table' => 'product_multimedia_object',
								'product_table_id' => $hash2insert->{'product_table_id'},
								'date' => ( $atomsql::current_ts - 1 ),
								'product_id' => $hin{'product_id'},
								'supplier_id' => 0,
								'prod_id' => 0,
								'catid' => 0,
								'score' => 0,
								'action_type' => 5,
								'content_id' => $ejpmmo_id
							};
							my $new_id = insert_into_ej($ej);
						}
					}
					else {
						# previous record present in EJ
					}
				}

				if ( ($action_type == 1) || ($action_type == 3) ) {
					my $is_diff = 0;
					if ($ans) {
						for ( my $i = 0 ; $i < scalar (@{$ans->[0]}) ; $i++ ) {
							if ($ans->[0]->[$i] ne $prev->[0]->[$i]) {
								$is_diff = 1;
								last;
							}
						}
						if ($is_diff) {
							insert_into_ej_product_mmo($ans);
						}
						else {
							$is_cancel_ej = 1;
						}
					}
				}
	    }

	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------

	    elsif ($hash2insert->{'product_table'} eq "'product_related'") {

	        # if insert
	        if ($hin{'add_related_batch'} eq 'Add batch') {
    	        $action_type = 1;

	            my $ans = do_query("
	                SELECT rel_product_id, name
    	            FROM product_related pr
    	            INNER JOIN product p ON (p.product_id = pr.rel_product_id)
	                WHERE product_related_id = " . $hash2insert->{'product_table_id'}
	            );

	            do_statement("
	                INSERT INTO editor_journal_product_related (rel_product_id, rel_product_name)
	                VALUES (" .
	                $ans->[0]->[0] . ", " . str_sqlize($ans->[0]->[1]) . ")"
	            );
	        }

	        # if delete
	        if ($hin{'atom_delete'} eq 'Delete') {
    	        $action_type = 2;

    	        my $rpid = $hin{'rel_product_id'};
    	        my $pid = $hin{'product_id'};

    	        # get symbolic name
    	        my $ans = do_query("
	                SELECT rel_product_name
    	            FROM editor_journal_product_related ejpr
    	            INNER JOIN editor_journal ej
    	            ON (ejpr.content_id = ej.content_id AND ej.product_table = 'product_related' AND product_id = " . $pid . ")
	                WHERE rel_product_id = " . $rpid
	            );

	            do_statement("
	                INSERT INTO editor_journal_product_related (rel_product_id, rel_product_name)
	                VALUES (" .
	                $rpid . ", " . str_sqlize($ans->[0]->[0]) . ")"
	            );
    	    }

	    }
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    # ------------------------------------------------------------------------------------------------------
	    else {
	        # Unknown table for editor_journal
	    }

	    # cancel some inserts to 'editor_journal' table
	    # if user_errors occurred

	    my $is_inserted_to_ej = 0;
	    my $content_id;
	    unless ($user_errors[0] or $is_cancel_ej) {

	        # new fields for EJ table
    	    $content_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];

    	    # new fields for product history
	        $hash2insert->{'content_id'} = $content_id;
	        $hash2insert->{'action_type'} = $action_type;

	        insert_rows("editor_journal", $hash2insert);
	        $is_inserted_to_ej = 1;
	    }

	    #
	    # custom fields processing (not for all tables)
	    #

	    if ( ($is_inserted_to_ej) && ($content_id) ) {

	        # mmo
    	    if ($hash2insert->{'product_table'} eq "'product_multimedia_object'") {
	            my $d = get_custom_data('product_multimedia_object', 'id',  $hash2insert->{'product_table_id'} );
	            add_custom_data('product_multimedia_object', $content_id, $d);
    	    }

    	    # product
    	    if ($hash2insert->{'product_table'} eq "'product'") {
    	        my $d = get_custom_data('product', 'product_id',  $hash2insert->{'product_table_id'} );
    	        add_custom_data('product', $content_id, $d);
    	    }

    	    # product_gallery
    	    if ($hash2insert->{'product_table'} eq "'product_gallery'") {
    	        my $d = get_custom_data('product_gallery', 'id',  $hash2insert->{'product_table_id'} );
    	        add_custom_data('product_gallery', $content_id, $d);
    	    }

    	    # product_description
    	    if ($hash2insert->{'product_table'} eq "'product_description'") {
    	        my $d = get_custom_data('product_description', 'product_description_id',  $hash2insert->{'product_table_id'} );
    	        add_custom_data('product_description', $content_id, $d);
    	    }
    	}
    }
    return 1;
}

sub command_proc_add_new_category_family{

	&process_atom_ilib('errors');
	&process_atom_lib('errors');

# if($hin{'add_cat_fam'} && $hin{'catid'} == 1){
#	 push @user_errors, $atoms->{'default'}->{'errors'}->{'empty_category'};
#	 &atom_cust::proc_custom_processing_errors;
#	 return 0;
# }

 if($hin{'inc_subcat'}){ $hin{'inc_subcat'} = 'Y'}else{ $hin{'inc_subcat'} = 'N'};
 if($hin{'inc_subfam'}){ $hin{'inc_subfam'} = 'Y'}else{ $hin{'inc_subfam'} = 'N'};
 my $family_id = $hin{'4cat'.$hin{'catid'}};
 if(!$family_id){ $family_id = 1;}
 &insert_rows('supplier_contact_category_family', {
	'catid' => $hin{'catid'},
	'family_id' => $family_id,
	'contact_id' => $hin{'id'},
	'include_subcat' => &str_sqlize($hin{'inc_subcat'}),
	'include_subfamily' => &str_sqlize($hin{'inc_subfam'})}
	);

 return 1;
}

sub command_proc_delete_category_family{

 if($hin{'del_cat_fam'}){
	&delete_rows("supplier_contact_category_family", "id = ".$hin{'cat_fam_id'});
 }
 return 1;
}

sub command_proc_add_related_batch {

	&process_atom_ilib('product_related');
	&process_atom_lib('product_related');

	if ($hin{'add_related_batch'}) {

		&update_product_bg($hin{'product_id'});

		my $res = &get_product_id_list_from_raw_batch($hin{'related_batch'}, &do_query("select supplier_id from product where product_id = ".$hin{'product_id'})->[0][0]);
		my $set_of_product_ids = $res->[0];
		my $additional_hash = $res->[1];

		log_printf(Dumper($res));

		my $howMany = 0;
		my $unmatchedCount = 0;
		my $bg_result;

		# update product relations
		for my $pid (@$set_of_product_ids) {

#			log_printf("dumper victim = ".Dumper($rel_product_ids));

#			$alreadyHave = 0;

			$bg_result = &update_product_bg($pid);

			unless (&do_query("select product_related_id from product_related where rel_product_id=".&str_sqlize($hin{'product_id'})." and product_id='".$pid."'")->[0][0] ||
							&do_query("select product_related_id from product_related where product_id=".&str_sqlize($hin{'product_id'})." and rel_product_id='".$pid."'")->[0][0]) {
				&do_statement("insert ignore into product_related(product_id,rel_product_id) values(".&str_sqlize($hin{'product_id'}).",'".$pid."')");
				$howMany++;
			}
#			else {
#				$alreadyHave = 1;
#			}

#			if ($alreadyHave) {
#				if ($bg_result eq 'bg') {
#					$bg_result = $atoms->{'default'}->{'product_related'}->{'ok_related'};
#				}
#				elsif ($bg_result eq '!bg') {
#					$bg_result = $atoms->{'default'}->{'product_related'}->{'ok_in_process_related'};
#				}
#				else {
#					$bg_result = $atoms->{'default'}->{'product_related'}->{'ok_queued_related'};
#				}
#			}
#			else {
#				$bg_result = $atoms->{'default'}->{'product_related'}->{'ok_already_have'};
#			}
		}

		# collect unmatched products output
		while (my ($string, $number) = each (%$additional_hash)) {

			log_printf($string." ".$number);

			if ($number) {
				$hin{'related_report'} .= &repl_ph($atoms->{'default'}->{'product_related'}->{'related_string'}, { 'code' => $string . ( $number > 1 ? " (".$number." times)" : '') } );
			}
			else {
				$hin{'related_report_unmatched'} .= "<span style='color: grey;'>".$string."</span>, ";
				$unmatchedCount++;
			}
		}

		chop($hin{'related_report_unmatched'});
		chop($hin{'related_report_unmatched'});
		$hin{'related_report'} .= &repl_ph($atoms->{'default'}->{'product_related'}->{'related_string_colspan2'},{ 'content' => "List of unmatched symbols: <span class='linksubmit' id='show_unmatched_list_button' onClick='javascript: document.getElementById(\"show_unmatched_list_button\").style.display=\"none\"; document.getElementById(\"show_unmatched_list\").style.display=\"\"; '>show ".$unmatchedCount." symbols</span><span id='show_unmatched_list' style='display: none;'>".$hin{'related_report_unmatched'}.'</span>' } );
		$hin{'related_report_unmatched'} = undef;
	}

	$hin{'related_report_ignore_unifiedly_processing'} = 'Yes';

	return 1;
} # sub command_proc_add_related_batch

### !!!
sub command_proc_insert_tab_feature_value_old {
 $hin{'hidden_tab_id'} =~ /feat_tab_id_(\d+)/;
 my $tab_id = $1;
 my $tab_value = &do_query("select code from language where langid = $tab_id")->[0][0];
 if($tab_id){
	&process_atom_ilib('errors');
	&process_atom_lib('errors');
	my $features = &do_query("select product_feature_id, category_feature_id from product_feature where product_id = ".$hin{'product_id'});
	for my $feature(@$features){
		my $value = $hin{$tab_id.'tab_'.$tab_id.'_'.$feature->[1]};
		if(!$value && $hin{'tab_feature_value_mandatory_'.$feature->[1]}){
   	 push @user_errors, &repl_ph($atoms->{'default'}->{'errors'}->{'missing_mandatory_feature_value_tab'},
			{'feature_name' => $hin{'tab_feature_mandatory_name_'.$feature->[1]},
			 'tab' => $tab_value}
			);
		 next;
		}
	}
	if($#user_errors != -1){
	  &atom_cust::proc_custom_processing_errors;
		return 0;
	}
	my $local_feats = &do_query("select pfl.category_feature_id, pfl.value,
	pfl.langid from product_feature_local as pfl where
	pfl.product_id = ".$hin{'product_id'});
	my $local_feats_hash;
	for my $f(@$local_feats){ $local_feats_hash->{$f->[0]} = $f;}
	for my $feature(@$features){
	 my $value = $hin{$tab_id.'tab_'.$tab_id.'_'.$feature->[1]};
	 if(!$value&&$local_feats_hash->{$feature->[1]}->[1]){
		&delete_rows("product_feature_local", "category_feature_id
		= ".$feature->[1]." and product_id = ".$hin{'product_id'}."
		and langid = $tab_id");
	 }
	if($value&&($value ne '')){
 	 my $category_feature_id = $feature->[1];
	 my $key = &do_query("select product_feature_local_id from product_feature_local where product_id = ".$hin{'product_id'}." and
	 category_feature_id = ".$feature->[1]." and langid = ".$tab_id)->[0][0];
	 &smart_update('product_feature_local', 'product_feature_local_id', {
		'product_feature_local_id' => $key,
		'product_id' => $hin{product_id},
		'category_feature_id' => $feature->[1],
		'langid' => $tab_id,
		'value' => &str_sqlize($value)
	 });
	}
 }
 }
 return 1;
}

sub command_proc_insert_tab_feature_value {
	$hin{'hidden_tab_id'} =~ /feat_tab_id_(\d+)/;
	my $tab_id = $1;
	if ($tab_id) {
		my $tab_value = &do_query("select code from language where langid = $tab_id")->[0][0];
		&process_atom_ilib('errors');
		&process_atom_lib('errors');
		my $features = &do_query("select category_feature_id from product inner join category_feature using (catid) where product_id = ".$hin{'product_id'});
		my $values;
		delete $hl{'tab_feature_value_error'};
		for my $feature (@$features) {
			my $value = &icecat_util::get_corrected_product_feature_value($hin{$tab_id.'tab_'.$tab_id.'_'.$feature->[0]}, $tab_id);
			$values->{$feature->[0]} = $value;
			$hs{'tab_'.$tab_id.'_feature_value_error_'.$feature->[0]} = $hin{$tab_id.'tab_'.$tab_id.'_'.$feature->[0]};
			if ((!defined $value || $value eq '') && $hin{'tab_feature_value_mandatory_'.$feature->[0]}) {
				$hs{'tab_feature_value_error'} = $tab_id;
				push @user_errors, &repl_ph($atoms->{'default'}->{'errors'}->{'missing_mandatory_feature_value_tab'},
																		{'feature_name' => $hin{'tab_feature_mandatory_name_'.$feature->[0]},
																		 'tab' => $tab_value}
																		);
				next;
			}
		}
		if ($#user_errors != -1) {
			&atom_cust::proc_custom_processing_errors;
			&process_atom_ilib('ajax_product_features_local');
			&process_atom_lib('ajax_product_features_local');
			&atom_cust::proc_custom_processing_ajax_product_features_local;
			return 0;
		}

		# clean sessions
		for (values %$values) {
			delete $hs{'tab_'.$tab_id.'_feature_value_error_'.$_};
		}
		&smart_update_feature_local($hin{'product_id'},$values,$tab_id);
	}
	return 1;
} # sub command_proc_insert_tab_feature_value

sub command_proc_insert_tab_name {
	my $values = &do_query("SELECT l.langid, pn.name from language l 
		LEFT JOIN product_name pn ON pn.product_id=" . $hin{'product_id'} . " AND pn.langid=l.langid");
	for my $val (@$values) {
		my $prodname = $hin{'value_tab_' . $val->[0]};
		if ( !$prodname && defined $val->[1] ) {
			&do_statement("delete from product_name where product_id=" . $hin{'product_id'} . " and langid=" . $val->[0]);
		} elsif ( defined $val->[1] && $prodname ne $val->[1] ) {
			&update_rows("product_name", "product_id=" . $hin{'product_id'} . " and langid=" . $val->[0], {'name'=>&str_sqlize($prodname)});
		} elsif ( $prodname && !defined $val->[1]) {
			&insert_rows("product_name", {'product_id'=>$hin{'product_id'}, 'langid'=>$val->[0],	'name'=>&str_sqlize($prodname)});
		}
		#&smart_update_prodname($hin{'product_id'}, $prodname, $lang->[0]);
	}
	return 1;
}

sub command_proc_update_users_repo_access{
	my $langs = &do_query("select langid, short_code from language order by langid asc");
	my $uid = &do_query("select user_id from users where login = ".&str_sqlize($hin{'login'}))->[0][0];
	my $langs2ins;
  for my $lang(@$langs) {
		if ($hin{'repository_'.$lang->[0]}) {
			$langs2ins .= '1';
		}
		else {
			$langs2ins .= '0';
		}
	}
	if ($hin{'repository_0'}) {
		$langs2ins = '1'.$langs2ins;
	}
	else {
		$langs2ins = '0'.$langs2ins;
	}

	if ($hin{'subscription_level'} != 4) {
		$langs2ins = '';
		for my $lang(@$langs) {
			$langs2ins .= '0';
		}
		$langs2ins = '0'.$langs2ins;
	}
	&update_rows("users", "user_id = $uid", { 'access_repository' => &str_sqlize($langs2ins)});
	return 1;
}

sub command_proc_update_feature_chunk {
	my $f_id;

	if ($hin{feature_id}) {
		$f_id = $hin{feature_id};
		&update_rows("feature", "feature_id = $f_id", {'updated' => 'NOW()'});
	}
	else {
		$f_id = shift;
	}

	my $names = &do_query("select value, langid, unix_timestamp(f.updated), record_id from vocabulary as v, feature as f
where f.feature_id = $f_id and f.sid = v.sid");
	my %names = map{$_->[1] => $_ } @$names;
	my $exist;

	for my $lang (keys %names) {
		my $chunk = "<Name ID=\"%%id%%\" Value=\"%%val%%\" langid=\"%%langid%%\"/>";
		$chunk = &repl_ph( $chunk, {
			'id' => $names{$lang}->[3],
			'val' => &str_xmlize($names{$lang}->[0]),
			'langid' => $lang});
		if ($names{$lang}->[0]) {
			$exist = &do_query("select 1 from product_xmlfeature_cache where feature_id = ".$f_id." and langid = ".$lang)->[0][0];
			if ($exist) {
				&update_rows("product_xmlfeature_cache", "feature_id = $f_id and langid = $lang",
										 {'xmlfeature_chunk' => &str_sqlize($chunk),
											'updated' => &str_sqlize($names{$lang}->[2])
										 });
			}
			else {
				&insert_rows("product_xmlfeature_cache", {
					'feature_id' => $f_id,
					'xmlfeature_chunk' => &str_sqlize($chunk),
					'updated' => &str_sqlize($names{$lang}->[2]),
					'langid' => $lang
										 });
			}
		}
		else {
			&do_statement("delete from product_xmlfeature_cache where feature_id=".$f_id." and langid=".$lang);
		}
	}

	return 1;
}


 ##########################################################
 sub command_proc_add_related_batch_p
 {
 if($hin{'quantity'}){
			my $ext=1;
			while($ext<=$hin{'quantity'}){
		     	if ($hin{'gallery_pic_filename'.$ext}){
	  	       $hin{'gallery_pic_filename'} = $hin{'gallery_pic_filename'.$ext};
						 &atom_store::store_as_gallery_pic_uploaded();
	      	   &command_proc_get_gallery_pic();
	        	 &command_proc_add2editors_journal();
 					}
     $ext++;
 		 }
 }
 if($hin{'add_related_batch'}){
 		  my $related = $hin{'related_batch'};
   		$related =~ s/\s+/~/g;
   		my @related_arr = split("~", $related);
    	for my $related(@related_arr){
      		$hin{'gallery_pic'}=$related;
		      &command_proc_get_gallery_pic();
		      &command_proc_add2editors_journal();
    	}
	}
 return 1;
}

sub command_proc_product2vendor_notification_queue {
	my $product_id = $hin{'product_id'};
	my $tables = ['product','product_name','product_description','product_feature','product_related','product_gallery','product_multimedia_object'];
	my $max_timestamp = 0;
	for my $table (@$tables) {
		my $data = &do_query("select product_id, unix_timestamp(updated) from $table where product_id ='".$product_id."'");
		if ($max_timestamp < $data->[0][1]) {
			$max_timestamp = $data->[0][1];
		}
	}
	if (($max_timestamp > $atomsql::current_ts)&&(!&do_query("select id from vendor_notification_queue where product_id='".$product_id."'")->[0][0])) {
		&do_statement("insert into vendor_notification_queue (id,product_id,updated) values('','".$product_id."','".$max_timestamp."')");
	}
	return 1;
}

sub command_proc_add_new_supplier {
	&process_atom_ilib('errors');
	&process_atom_lib('errors');
	if ($hin{'is_new_supplier'} == 1) {
		chomp($hin{'new_supplier_name'});
		if ($hin{'new_supplier_name'} eq '') { # if new_supplier_name void - ERROR
			push @user_errors, $atoms->{'default'}->{'errors'}->{'supplier_name_void'};
		}
		else {
			my $supplier_id = &do_query("select supplier_id from supplier where name = ".&str_sqlize($hin{'new_supplier_name'}));
			if ($#$supplier_id > -1) { # if this supplier exist - change $hin{'supplier_id'} to ours
				$hin{'supplier_id'} = $supplier_id;
			}
			else { # insert a new supplier
				&insert_rows("supplier",{'name'=>&str_sqlize($hin{'new_supplier_name'})});
				$hin{'supplier_id'} = &sql_last_insert_id;
			}
		}
		if ($#user_errors != -1) {
			&atom_cust::proc_custom_processing_errors;
			return 0;
		}
	}
	return 1;
} # sub command_proc_add_new_supplier

sub command_proc_add_new_feature {
	&process_atom_ilib('errors');
	&process_atom_lib('errors');

	my $main_lang=1;

	if ($hin{'is_new_feature'} == 1) {
		chomp($hin{'feature_name'});
		if ($hin{'feature_name'} eq '') {
			push @user_errors, $atoms->{'default'}->{'errors'}->{'feature_name_void'};
		}
		elsif ($hin{'measure_id'} eq '') {
			push @user_errors, $atoms->{'default'}->{'errors'}->{'measure_id_void'};
		}
		else { # working
			&do_statement("insert into sid_index(sid) values('')");
			my $sid = &do_query("select LAST_INSERT_ID()")->[0][0];
			&do_statement("insert into tid_index(tid) values('')");
			my $tid = &do_query("select LAST_INSERT_ID()")->[0][0];
			&do_statement("insert into feature(sid,tid,measure_id,class) values('".$sid."','".$tid."','".$hin{'measure_id'}."','1')");
			$hin{'feature_id'} = &do_query("select LAST_INSERT_ID()")->[0][0];
			&do_statement("insert into vocabulary(sid,langid,value) values('".$sid."','".$main_lang."','".$hin{'feature_name'}."')");
			my $langs = &do_query("select langid from language where langid!=".$main_lang);
			for (@$langs) {
				&do_statement("insert into feature_autonaming(feature_id,langid,data_source_id)
												values('".$hin{'feature_id'}."','".$_->[0]."','".$hin{'data_source_id'}."')") if ($hin{'data_source_id'});
			}
		}
		if ($#user_errors != -1) {
			&atom_cust::proc_custom_processing_errors;
			return 0;
		}
	}
	return 1;
} # sub command_proc_add_new_feature

sub translate_table{
	my ($table_name,$key_name,$key_type,$langid,$sql)=@_;
	my $degug_tmp="TEMPORARY";
	&do_statement("DROP $degug_tmp TABLE IF EXISTS $table_name");
	$key_type='int(13)' if !$key_type;
	&do_statement("CREATE $degug_tmp TABLE $table_name ($key_name $key_type not null, 
											en_value text not null default '',
											trans_value text not null default '')");
	my $lang_code=&do_query('SELECT short_code FROM language WHERE langid = '.$langid)->[0][0];											
	return '' if uc($lang_code) eq 'US' or uc($lang_code) eq 'EN'; # no sense to translate 
		 
	&do_statement("INSERT INTO  $table_name ($key_name,en_value) $sql");	
	&do_statement("ALTER IGNORE TABLE $table_name ADD UNIQUE KEY($key_name)");

	my $test_trans=&do_query("SELECT en_value  FROM $table_name WHERE en_value!='' LIMIT 1")->[0][0];
	my $test_result=&translate_from_google([$test_trans],1,$langid);	
	if(ref($test_result) eq 'HASH' and $test_result->{$test_trans} =~/We\sare\snot\syet\sable\sto\stranslate\sfrom/i){#check if google able to translate given lang if it dont use backup language
		my $backup_langid=&do_query('SELECT backup_langid FROM language WHERE langid='.$langid)->[0][0];
		$langid=$backup_langid if($backup_langid);		
	}
	my $indx=0;
	my $limit=20;
	while(1){
		my $rows=&do_query("SELECT en_value  FROM $table_name LIMIT $indx,$limit");
		if(scalar(@$rows)==0){
			last;
		}
		my @toTranslate=map {$_->[0]} @$rows;		
		my $result_hash=&translate_from_google(\@toTranslate,1,$langid);
		#my $result_hash={};
		if(ref($result_hash) ne 'HASH'){# if group transaltion failed try to translate them one by one 
			&lp('---------->>>>>>>>>>>>>>>>>>>> group trasnlation failed. transaltion one by one...');
			$result_hash={};
			for my $src_text (@toTranslate){
				my $tmp_result=&translate_from_google([$src_text],1,$langid);
				if(ref($tmp_result) eq 'HASH'){
					$result_hash->{$src_text}=$tmp_result->{$src_text};
				}else{
					&lp('---------->>>>>>>>>>>>>>>>>>>>Something untranslatable in lang $langid '.Dumper($src_text));
				}
			};
		}
		for my $src_str (@toTranslate){
			$result_hash->{$src_str}=&trim($result_hash->{$src_str});
			$result_hash->{$src_str}=~s/\.$//;			
			&do_statement("UPDATE $table_name SET trans_value=".&str_sqlize($result_hash->{$src_str})."
					       WHERE en_value=".&str_sqlize($src_str));
		}  
		$indx+=$limit;
	}
	#my $rows=&do_query("SELECT en_value  FROM $table_name");
	#for my $row (@$rows){ 
	#	my $src_str=$row->[0];
	#	my $result_hash=&translate_from_google([$src_str],1,$langid);
	#	next if ref($result_hash) ne 'HASH';
	#	$result_hash->{$src_str}=&trim($result_hash->{$src_str});
	#	$result_hash->{$src_str}=~s/\.$//;			
	#	&do_statement("UPDATE $table_name SET trans_value=".&str_sqlize($result_hash->{$src_str})."
	#				       WHERE en_value=".&str_sqlize($src_str));			
	#}
	
}

sub command_proc_lang_export()
{
	my $category 					= "false";
	my $category_descript			= "false";
	my $feature 					= "false";
	my $feature_catf_relations		= "false";
	my $feature_descript			= "false";
	my $feature_group 				= "false";
	my $measure 					= "false";
	my $feature_values_vocabulary 	= "false";
	my $measure_sign 				= "false";
	my $sector 						= "false";
	#&lp(Dumper(\%hin));
	$category 			= $hin{'category'} 			if ($hin{'category'});
	$category_descript 	= $hin{'category_descript_flag'}
													if ($hin{'category_descript_flag'});
	$feature 			= $hin{'feature'} 			if ($hin{'feature'});
	$feature_catf_relations
						= $hin{'feature_flag'} 		if ($hin{'feature_flag'});
	$feature_descript	= $hin{'feature_descript_flag'}
													if ($hin{'feature_descript_flag'});
	$feature_group 		= $hin{'feature_group'} 	if ($hin{'feature_group'});
	$measure 			= $hin{'measure'} 			if ($hin{'measure'});
	$feature_values_vocabulary
						= $hin{'feature_values_vocabulary'}
													if ($hin{'feature_values_vocabulary'});
	$measure_sign 		= $hin{'measure_sign'} 	if ($hin{'measure_sign'});
	$sector 			= $hin{'sector'} 			if ($hin{'sector'});

	my $mail = $hin{'mail'};

	# array with selected languages
	my $lng = [];
	my $lng_arr = &do_query("SELECT langid FROM language");

	# &log_printf("========= GET SELECTED LANGUAGES =============");

	for my $value(@$lng_arr) {
		if (($hin{$value->[0]}) && ($hin{$value->[0]} eq 'true')) {
			push (@$lng, $value->[0]);
		}
	}

	if (($category eq 'false') & \
		($feature eq 'false') & \
			($feature_group eq 'false') & \
				($measure eq 'false') & \
					($feature_values_vocabulary eq 'false') & \
						($measure_sign eq 'false') & \
							($sector eq 'false'))
	{
		return 0;
	} else {
		################ GENERATE XLS ####################

		my $path = $atomcfg{'base_dir'} . '/bin/';
		my $xls_path = $atomcfg{'base_dir'} . 'tmp/';
		my $xls_name = 'export.xls';
		my $xls = $xls_path . $xls_name;
		my $col ;
		my $row ;
		my $query;

		my $tm=localtime;
		my ($day,$month,$year,$wday)=($tm->mday,$tm->mon,$tm->year,$tm->wday);

		#if ($month==0){$month='January'}
		#if ($month==1){$month='February'}
		#if ($month==2){$month='March'}
		#if ($month==3){$month='April'}
		#if ($month==4){$month='May'}
		#if ($month==5){$month='June'}
		#if ($month==6){$month='July'}
		#if ($month==7){$month='August'}
		#if ($month==8){$month='September'}
		#if ($month==9){$month='October'}
		#if ($month==10){$month='November'}
		#if ($month==11){$month='December'}

		#$month++;
		my $date=$day." ".$month." ". $year;

		&log_printf("Generete XLS");

		# Due to CPAN this module is deprecated
		# my $workbook  = Spreadsheet::WriteExcel::Big->new($xls);
		my $workbook  = Spreadsheet::WriteExcel->new($xls);

		# set properties for MS EXCEL
		$workbook->set_properties(
			title => 'Export languages',
			author => 'icecat.biz',
			comments => 'Export procedure report',
			subject => 'Info about categories, features and so on',
			utf8 => 1,
		);
		my $gogle_format = $workbook->add_format();
    	$gogle_format->set_color('red');
		
		################################ category #######################################

		if ($category eq 'true' || $category_descript eq 'true')
		{
			my $col = 1;	# for column to display category
			my $init_id = 'true'; # we shall init id column only once

			if ($category eq 'true' && $category_descript eq 'false') {
				my $out = $workbook->add_worksheet("Category " . $date);
				$out->write(0,0,"sid");
				my $trans_table='aaa_tmp_trans_values';
				for my $i(@$lng) {
					translate_table($trans_table,'sid','',$i,"SELECT c.sid,v_en.value FROM category c 
												JOIN vocabulary v_en ON c.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON c.sid=v.sid AND v.langid=$i 
												WHERE c.catid > 1 and (v.value is NULL or v.value='')");
																													
					&generate_xls($out,'category',$i,$col, {
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);
					$col+=2; # next column for next language
					$init_id = 'false';
				}
			} elsif ($category eq 'true' && $category_descript eq 'true') {
				my $cout = $workbook->add_worksheet("Category " . $date);
				$cout->write(0,0,"sid");
				my $dout = $workbook->add_worksheet("Category Description " . $date);
				$dout->write(0,0,"tid");
				$dout->write(0,1, "Category Name");
				my $cat_col=1;
				my $trans_table='aaa_tmp_trans_values';
				for my $i(@$lng) {
					translate_table($trans_table,'sid','',$i,"SELECT c.sid,v_en.value FROM category c 
												JOIN vocabulary v_en ON c.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON c.sid=v.sid AND v.langid=$i 
												WHERE c.catid > 1 and (v.value is NULL or v.value='')");
																				
					&generate_xls($cout,'category',$i,$cat_col, {
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);													
					$cat_col+=2;
					$col++; # important
					&generate_xls($dout,'category_descript',$i,$col, {
								'init_id' => $init_id
								});
					$init_id = 'false';
				}
			} else {
				my $out = $workbook->add_worksheet("Category Description " . $date);
				$out->write(0,0,"tid");
				$out->write(0,1, "Category Name");
				$col = 2;
				for my $i(@$lng) {
						&generate_xls($out,'category_descript',$i,$col, {
								'init_id' => $init_id
								});
						$col++; # next column for next language
						$init_id = 'false';
				}
			}
		}

		################################ feature ###########################################

		if ($feature eq 'true' || $feature_descript eq 'true' || $feature_catf_relations eq 'true')
		{
			my $col = 1;	# for column to display feature
			my $init_id = 'true'; # we shall init id column only once

			if ($feature eq 'true' && $feature_descript eq 'false' && $feature_catf_relations eq 'false') {
				my $out = $workbook->add_worksheet("Feature " . $date);
				$out->write(0,0,"sid");
				my $trans_table='aaa_tmp_trans_values';
				for my $i(@$lng) {
					translate_table($trans_table,'sid','',$i,"SELECT f.sid,v_en.value FROM feature f 
												JOIN vocabulary v_en ON f.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$i 
												WHERE v.value is NULL or v.value=''");					
					&generate_xls($out,'feature',$i,$col, {
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);
					$col+=2; # next column for next language
					$init_id = 'false';
				}
			} elsif ($feature eq 'true' && $feature_descript eq 'true' && $feature_catf_relations eq 'false') {
				my $fout = $workbook->add_worksheet("Feature " . $date);
				$fout->write(0,0,"sid");
				my $dout = $workbook->add_worksheet("Feature Description " . $date);
				$dout->write(0,0,"tid");
				$dout->write(0,1, "Feature Name");
				my $trans_table='aaa_tmp_trans_values';
				my $feat_col=1;
				for my $i(@$lng) {
					translate_table($trans_table,'sid','',$i,"SELECT f.sid,v_en.value FROM feature f 
												JOIN vocabulary v_en ON f.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$i 
												WHERE v.value is NULL or v.value=''");					
					&generate_xls($fout,'feature',$i,$feat_col, {
								'with_descr' => 'true',
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);
					$col++; # important
					$feat_col+=2;
					&generate_xls($dout,'feature_descript',$i,$col, {
								'init_id' => $init_id
								});
					$init_id = 'false';
				}
			} elsif ($feature_descript eq 'true' && $feature_catf_relations eq 'false') {
				my $out = $workbook->add_worksheet("Feature Description " . $date);
				$out->write(0,0,"tid");
				$out->write(0,1, "Feature Name");
				$col = 2;
				for my $i(@$lng) {
					&generate_xls($out,'feature_descript',$i,$col, {
								'init_id' => $init_id
								});
					$col++; # next column for next language
					$init_id = 'false';
				}
			} elsif ($feature_catf_relations eq 'true') {
				my $out = $workbook->add_worksheet("Feature " . $date);
				$out->write(0,0,"sid");
				$out->write(0,1,"Category");
				$out->write(0,2,"Feature group");
				$col = 3;
				# gather statistic
				do_statement('DROP TEMPORARY TABLE IF EXISTS itmp_max_cat');
				do_statement('CREATE TEMPORARY TABLE itmp_max_cat SELECT COUNT(product_id) as s1, catid FROM product WHERE user_id > 1 GROUP BY catid');
				do_statement('ALTER TABLE itmp_max_cat ADD KEY (catid)');
				my $sheet = [];
				my $trans_table='aaa_tmp_trans_values';
				
				for my $i(@$lng) {
					translate_table($trans_table,'sid','',$i,"SELECT f.sid,v_en.value FROM feature f 
												JOIN vocabulary v_en ON f.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$i 
												WHERE v.value is NULL or v.value=''");					
					&generate_xls($out,'feature_improved',$i,$col, {
								'sheet' => $sheet,
								'init_id' => $init_id
								},$trans_table);
					$col+=2; # next column for next language
					$init_id = 'false';
				}
				my @tmp = @$sheet;
				my @sorted;
				@sorted = sort { $a->[1] cmp $b->[1] } @tmp;
				for (my $i = 1; $i <= scalar @sorted - 1; $i++ ) {
					for (my $j = 0; $j <= $col - 1; $j++ ) {
						if ($sorted[$i]->[$j]) {
							if($j>2 and $j%2==0){
								$out->write_string($i, $j, $sorted[$i]->[$j],$gogle_format);
							}else{
								$out->write_string($i, $j, $sorted[$i]->[$j]);
							}
						}
						else {
							$out->write_string($i, $j, ' ');
						}
					}
				}
				if ($feature_descript eq 'true') {
					$init_id = 'true';
					my $out2 = $workbook->add_worksheet("Feature Description " . $date);
					$out2->write(0,0,"tid");
					$out2->write(0,1, "Feature Name");
					$col = 2;
					for my $i(@$lng) {
						&generate_xls($out2,'feature_descript',$i,$col, {
								'init_id' => $init_id
								});
						$col++; # next column for next language
						$init_id = 'false';
					}
				}
			}
		}

		################################ feature_group ##################################

        if ($feature_group eq 'true')
        {
			my $out = $workbook->add_worksheet("Feature_group " . $date);
			$out->write(0,0,"sid");
			my $col = 1;
			my $init_id = 'true'; # we shall init id column only once
			my $trans_table='aaa_tmp_trans_values';
			my $feat_col=1;			
			for my $i(@$lng) {
				translate_table($trans_table,'sid','',$i,"SELECT f.sid,v_en.value FROM feature_group f 
												JOIN vocabulary v_en ON f.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$i 
												WHERE v.value is NULL or v.value=''");									
				&generate_xls($out,'feature_group',$i,$col, {
							'init_id' => $init_id,
							'google_format'=>$gogle_format
							},$trans_table);
				$col+=2;
				$init_id = 'false';
			}
        }

		################################ Measure ########################################

        if ($measure eq 'true')
        {
                my $out = $workbook->add_worksheet("Measure " . $date);
				$out->write(0,0,"sid");
                my $col = 1;
				my $init_id = 'true'; # we shall init id column only once
				my $trans_table='aaa_tmp_trans_values';
                for my $i(@$lng) {
				translate_table($trans_table,'sid','',$i,"SELECT m.sid,v_en.value FROM measure m 
												JOIN vocabulary v_en ON m.sid=v_en.sid AND v_en.langid=1
												LEFT JOIN vocabulary v ON m.sid=v.sid AND v.langid=$i 
												WHERE v.value is NULL or v.value=''");													
					&generate_xls($out,'measure',$i,$col, {
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);
					$col+=2;
					$init_id = 'false';
                }

        }

		################################ Feature_values_vocabulary ######################

		if ($feature_values_vocabulary eq 'true')
        {
			my $out = $workbook->add_worksheet("Feature_val_voc " . $date);
			$out->write(0,0,"key_value");
            my $col = 1;
			my $init_id = 'true'; # we shall init id column only once
			my $trans_table='aaa_tmp_trans_values';
            for my $i(@$lng) {
				translate_table($trans_table,'key_value','varchar(255)',$i,"SELECT f_en.key_value,f_en.key_value FROM feature_values_vocabulary f_en							 
												LEFT JOIN feature_values_vocabulary f_loc  ON f_en.key_value = f_loc.key_value and f_loc.langid = $i
												WHERE f_en.langid=1 and (f_loc.value is NULL or f_loc.value='')");													
				&generate_xls($out,'feature_values_vocabulary',$i,$col, {
							'init_id' => $init_id,
							'google_format'=>$gogle_format
							},$trans_table);
				$col+=2;
				$init_id = 'false';
           }
	
     }

		################################ Measure_sign ###################################

        if ($measure_sign eq 'true')
        {
			my $out = $workbook->add_worksheet("Measure_sign " . $date);
			$out->write(0,0,"measure_id");
			my $col = 1;
			my $init_id = 'true'; # we shall init id column only once
			my $trans_table='aaa_tmp_trans_values';
			for my $i(@$lng) {
				translate_table($trans_table,'measure_id','',$i,"SELECT m.measure_id,ms.value FROM measure m 
												JOIN measure_sign ms ON ms.measure_id=m.measure_id and ms.langid=1
												LEFT JOIN measure_sign ms_loc ON ms_loc.measure_id=m.measure_id and ms_loc.langid=$i 
												WHERE ms_loc.value is NULL or ms_loc.value=''");									
				&generate_xls($out,'measure_sign',$i,$col, {
							'init_id' => $init_id,
							'google_format'=>$gogle_format
							},$trans_table);
				$col+=2;
				$init_id = 'false';
			}
			
	    }

		################################ Sector #########################################

        if ($sector eq 'true')
        {
                my $out = $workbook->add_worksheet("Sector " . $date);
				$out->write(0,0,"sector_id");
                my $col = 1;
				my $init_id = 'true'; # we shall init id column only once
				my $trans_table='aaa_tmp_trans_values';
                for my $i(@$lng) {
					translate_table($trans_table,'sector_id','',$i,"SELECT s.sector_id,sn.name FROM sector s 
												JOIN sector_name sn ON sn.sector_id=s.sector_id and sn.langid=1
												LEFT JOIN sector_name sn_loc ON sn_loc.sector_id=s.sector_id and sn_loc.langid=$i 
												WHERE sn_loc.name  is NULL or sn_loc.name=''");                	
					&generate_xls($out,'sector',$i,$col, {
								'init_id' => $init_id,
								'google_format'=>$gogle_format
								},$trans_table);
					$col+=2;
					$init_id = 'false';
                }
        }

		$workbook->close();

		################################## SEND XLS ####################################

		my $buffer;
		my $file;
		
		open(GZIPPED,"gzip -c9 ".$xls." |");
		binmode GZIPPED, ":bytes";
		while(read(GZIPPED,$buffer,4096)){ $file .= $buffer;}
		close(GZIPPED);

		my $mail = {
			'to'                    => $mail,
			'from'                  => 'support@'.$atomcfg{'company_name'},
			'reply_to'              => 'support@'.$atomcfg{'company_name'},
			'subject'               => 'Export languages',
			'text_body'             => 'XLS file attachment',
			'attachment_name'       => 'export.gz',
			'attachment_cotent_type'=> 'application/x-gzip',
			'attachment_body'       => $file
		};

		&complex_sendmail($mail);

		&log_printf("Generete XLS finish\n");

		unlink $xls;

		return 0;
	}
}

sub command_proc_distri_data_export {
	my $on_stock 		= $hin{on_stock} ? "> 0" : "IS NOT NULL";
	my $undescribed		= $hin{undescribed} ? "=0" : "<>0";
	my $distri_id		= $hin{distri_id} ? "= $hin{distri_id}" : "IS NOT NULL";
	my $mail			= $hin{mail};

	my $suppliers = "=";
	my @sup_ids = split(/\x0/, $hin{supplier_id});
	for (@sup_ids) {
		$suppliers .= "$_ OR supplier_id=" if $_;
	}
	$suppliers =~ s/\ OR\ supplier_id=$//; # delete the last OR statement
	my $supplier_id = $suppliers eq "=" ? "IS NOT NULL" : $suppliers;

	################ GENERATE XLS ####################

	my $tm = localtime;
	my ($day,$month,$year) = ($tm->mday,$tm->mon,$tm->year);
	my $date  = $day . ' ' . $month . ' ' . $year;
	my $date_ = $day . '_' . $month . '_' . $year; # date for usgae in a filename

	my $xls = $atomcfg{'base_dir'} . 'tmp/' . 'distributor_report_' . $date_ . '.xls';

	&log_printf("Generete XLS");

	my $workbook  = Spreadsheet::WriteExcel->new($xls);

	# set properties for MS EXCEL
	$workbook->set_properties(
		title => 'Export distributor data',
		author => 'icecat.biz',
		comments => 'Export procedure report',
		subject => 'Info about distributor data',
		utf8 => 1,
	);

	my $query = &do_query("SELECT s.name, p.prod_id, pd.original_name FROM distributor_product dp JOIN distributor d USING (distributor_id) JOIN supplier s ON dp.original_supplier_id=s.supplier_id JOIN product p USING (supplier_id,product_id) JOIN users u ON p.user_id=u.user_id JOIN user_group_measure_map ugmm USING (user_group) JOIN content_measure_index_map cmim ON ugmm.measure=cmim.content_measure JOIN product_original_data pd USING (product_id,distributor_id) WHERE (s.supplier_id $supplier_id) AND dp.distributor_id $distri_id AND dp.stock $on_stock AND cmim.quality_index $undescribed");

	my $row = 1;
	my $part = 1;
	my $out = &new_worksheet();

	for my $value(@$query) {
		my $col = 0;
		$out->write_string($row,$col++,$value->[0]);
		$out->write_string($row,$col++,$value->[1]);
		$out->write_string($row++,$col,$value->[2]);
		if ($row == 65536) {
			$row = 1;
			$part++;
			$out = &new_worksheet();
		}
	}
	$workbook->close();

	sub new_worksheet {
		my $out = $workbook->add_worksheet("Distributor data " . ($part > 1 ? "part $part " : ""));
		$out->write(0,0,"Vendor name");
		$out->write(0, 1, "Product code");
		$out->write(0, 2, "Short description");
		$out->set_column(0, 2, 40);
		return $out;
	}

	################################## SEND XLS ####################################

	my $buffer;
	my $file;

	open(GZIPPED,"gzip -c9 ".$xls." |");
	binmode GZIPPED, ":bytes";
	while(read(GZIPPED,$buffer,4096)){ $file .= $buffer }
	close(GZIPPED);

	my $mail = {
		'to'                    => $mail,
		'from'                  => 'support@'.$atomcfg{'company_name'},
		'reply_to'              => 'support@'.$atomcfg{'company_name'},
		'subject'               => 'Distributor report '.$date,
		'text_body'             => 'XLS file attachment',
		'attachment_name'       => 'distributor_report_'.$date_.'.gz',
		'attachment_cotent_type'=> 'application/x-gzip',
		'attachment_body'       => $file
	};

	&complex_sendmail($mail);
	&log_printf("Generete XLS finish\n");
	unlink $xls;
}

sub command_proc_distri_save_attrs {

	my $lang_ids = &do_query("SELECT langid FROM language ORDER BY langid");
	my $values = {};

	return if ($hin{"label_1"} eq ''); # english name can't be empty

	# build hash of values need to be updated
	for my $i(@$lang_ids) {
		$values->{$i->[0]} = $hin{"label_$i->[0]"};
	}

	my $dict = $hin{'dictid'};
	# check for correct dictionary_id
	return unless ($dict =~ /^\d+$/);

	my $dist = $hin{'distributor_id'};
	# check for correct distributor_id
	return unless ($dist =~ /^\d+$/);

	while((my $a, my $b) = each %$values) {
		my $html = &do_query("SELECT html FROM dictionary_text WHERE langid=$a AND dictionary_id=$dict AND distributor_id=$dist")->[0]->[0];

		my $operation;

		if ((defined $html) && ($html ne $b)) {
		    $operation = 'UPD';
		} elsif ((not defined $html) && ($b ne '')) {
		    $operation = 'INS';
		} else {
		    next;
		}

		if ($operation eq 'INS') {
		    &do_statement("INSERT INTO dictionary_text (html, langid, dictionary_id, distributor_id) VALUES ('$b', $a, $dict, $dist)");
		} else {
		    &do_statement("UPDATE dictionary_text SET html='$b' WHERE langid=$a AND dictionary_id=$dict AND distributor_id=$dist");
		}
	}
}

sub generate_xls()
{
	my ($out, $table, $lang, $col, $flags,$trans_table) = @_;
	my $row = 0;
	my $query = '';
	my $colsize = 40;
	my $lng = &do_query("SELECT v.value FROM language l LEFT JOIN vocabulary v on l.sid=v.sid and v.langid = 1 WHERE l.langid = $lang")->[0][0];

    my $all = $flags->{'sheet'};

    # language caption
	$out->write($row,$col,$lng);
	if($trans_table){
		$out->write($row,$col+1,'Google translates for '.$lng);
	}
    # WARNING !!!
    # each EXCEL cell should be written only once (else MS EXCEL will display error message)

	$row++;

    # ---------------------------------------------------------------------------------------------
	if ($table eq 'category')
	{
		my $query;
		$query = &do_query("SELECT c.sid, v.value,trs.trans_value FROM category c LEFT JOIN vocabulary v ON c.sid=v.sid AND v.langid=$lang
							LEFT JOIN  $trans_table trs ON c.sid=trs.sid
							LEFT JOIN tex t USING (tid, langid) WHERE c.catid > 1 GROUP BY c.sid");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);	# print sid
			}			
		}
		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);	# print value
			$out->write($row,$col+1,$value->[2],$flags->{'google_format'});	# print google translation 
			$row++;
		}
				
	}
	# ---------------------------------------------------------------------------------------------
	if ($table eq 'category_descript')
	{
		my $query = &do_query("SELECT c.tid, t.value FROM category c LEFT JOIN vocabulary v ON c.sid=v.sid AND v.langid=$lang LEFT JOIN tex t USING (tid, langid) WHERE c.catid > 1 GROUP BY c.sid");
		# for category name in english
		my $ctgr_nam_query = &do_query("SELECT v.value FROM category c LEFT JOIN vocabulary v ON c.sid=v.sid AND v.langid=1 LEFT JOIN tex t USING (tid, langid) WHERE c.catid > 1 GROUP BY c.sid");

		$out->set_column(1, $col, $colsize);

		my $init_tid = $flags->{'init_id'};
		if ($init_tid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0 , $value->[0]);# print tid
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row++,$col, $value->[1]);	# print value
		}
		if ($init_tid eq 'true') {
			$row = 1;
			for my $ct_nam(@$ctgr_nam_query) {
				$out->write($row++,1, $ct_nam->[0]);# print category name
			}
		}
		
	}
	# ---------------------------------------------------------------------------------------------
	if ($table eq 'feature')
	{
		my $query;
		if ($flags->{'with_descr'}) {
		    $query = &do_query("SELECT f.sid, v.value,trs.trans_value FROM feature f LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$lang
		    					LEFT JOIN  $trans_table trs ON f.sid=trs.sid 
		    					LEFT JOIN tex t USING (tid, langid) GROUP BY f.sid");
		} else {
			$query = &do_query("SELECT f.sid, v.value, trs.trans_value FROM feature f 
								LEFT JOIN vocabulary v ON f.sid = v.sid and v.langid = $lang
								LEFT JOIN  $trans_table trs ON f.sid=trs.sid 
								GROUP BY f.sid");
		}

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);	# print sid
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]); 	# print value
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'}); 	# print value
			$row++;
		}
	}

	# ---------------------------------------------------------------------------------------------
	if ($table eq 'feature_descript')
	{
		my $query = &do_query("SELECT f.tid, t.value, f.sid FROM feature f LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=$lang LEFT JOIN tex t USING (tid, langid) GROUP BY f.sid");
		# for feature name in english
		my $feat_nam_query = &do_query("SELECT v.value FROM feature f LEFT JOIN vocabulary v ON f.sid=v.sid AND v.langid=1 LEFT JOIN tex t USING (tid, langid) GROUP BY f.sid");

		$out->set_column(1, $col, $colsize);

		my $init_tid = $flags->{'init_id'};
		if ($init_tid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0 , $value->[0]);# print tid
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row++,$col, $value->[1]);	# print value
		}

		if ($init_tid eq 'true') {
			$row = 1;
			for my $feat_name(@$feat_nam_query) {
				$out->write($row++,1, $feat_name->[0]);	# print feature name
			}
		}
	}
	# ---------------------------------------------------------------------------------------------
	if ($table eq 'feature_improved') {
		my $query = &do_query("SELECT f.sid, v.value, f.feature_id,trs.trans_value FROM feature f 
							   LEFT JOIN vocabulary v ON f.sid = v.sid and v.langid=$lang
							   LEFT JOIN  $trans_table trs ON f.sid=trs.sid 
							   GROUP BY f.sid");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query)
			{
				$out->write($row++,0, $value->[0]);	# print sid
			}
		}

		$row = 1;
		my $ans;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			# deferred writing
			$all->[$row]->[0] = $value->[0];
			$all->[$row]->[$col] = $value->[1];
			$all->[$row]->[$col+1] = $value->[3];
			$ans = do_query(
				"SELECT v.value, v2.value " .
				"FROM category_feature cf " .
				"INNER JOIN itmp_max_cat mc ON (cf.catid = mc.catid) " .
				"INNER JOIN category ON (mc.catid = category.catid) " .
				"INNER JOIN vocabulary v ON (category.sid = v.sid) " .
				"INNER JOIN category_feature_group USING (category_feature_group_id) " .
				"INNER JOIN feature_group USING (feature_group_id) " .
				"INNER JOIN vocabulary v2 ON (feature_group.sid = v2.sid) " .
				"WHERE v.langid = 1 AND v2.langid = 1 AND cf.feature_id = " . $value->[2] . " " .
				"GROUP BY mc.catid ORDER BY mc.s1 DESC LIMIT 1 "
			);
			# deferred writing
			$all->[$row]->[1] = $ans->[0]->[0];
			$all->[$row]->[2] = $ans->[0]->[1];			
			$row++;
		}
	}
    # ---------------------------------------------------------------------------------------------
	if ($table eq 'feature_group') {
		$query = &do_query("SELECT f.sid, v.value, trs.trans_value FROM feature_group f 
							LEFT JOIN vocabulary v ON f.sid = v.sid and v.langid = $lang
							LEFT JOIN  $trans_table trs ON f.sid=trs.sid");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);	# print sid
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'});
			$row++;
		}

	}
	if ($table eq 'feature_values_vocabulary') {
		$query = &do_query("SELECT f_en.key_value, f_loc.value,trs.trans_value FROM feature_values_vocabulary f_en							 
							LEFT JOIN feature_values_vocabulary f_loc  ON f_en.key_value = f_loc.key_value and f_loc.langid = $lang
							LEFT JOIN  $trans_table trs ON f_en.key_value=trs.key_value
							WHERE f_en.langid=1");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'});
			$row++;
		}

	}
	
    # ---------------------------------------------------------------------------------------------
	if ($table eq 'measure') {
		$query = &do_query("SELECT m.sid, v.value,trs.trans_value FROM measure m							 
							LEFT JOIN vocabulary v ON m.sid = v.sid and v.langid = $lang
							LEFT JOIN  $trans_table trs ON m.sid=trs.sid");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'});
			$row++;
		}

	}	
	if ($table eq 'measure_sign') {
		$query = &do_query("SELECT m.measure_id, ms.value ,trs.trans_value FROM measure m							 
							LEFT JOIN measure_sign ms ON ms.measure_id=m.measure_id AND ms.langid=$lang 
							LEFT JOIN  $trans_table trs ON m.measure_id=trs.measure_id");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'});
			$row++;
		}

	}
	
    # ---------------------------------------------------------------------------------------------
	if ($table eq 'sector') {
		$query = &do_query("SELECT s.sector_id, n.name,trs.trans_value FROM sector s 
							LEFT JOIN sector_name n ON s.sector_id = n.sector_id and n.langid = $lang
							LEFT JOIN  $trans_table trs ON s.sector_id=trs.sector_id");

		$out->set_column(1, $col, $colsize);

		my $init_sid = $flags->{'init_id'};
		if ($init_sid eq 'true') {
			for my $value(@$query) {
				$out->write($row++,0, $value->[0]);
			}
		}

		$row = 1;
		for my $value(@$query) {
			$out->write($row,$col, $value->[1]);
			$out->write($row,$col+1, $value->[2],$flags->{'google_format'});
			$row++;
		}
	}
}

sub command_proc_lang_import {
	#my $hin=shift;
	my $tmpfn = $hin{'temp'};
	my $import_file = $atomcfg{'base_dir'}.'tmp/'.$tmpfn.'.xls';

	if (!-e $import_file) {
		$hin{'import'} = "file not exists";
		return 0;
	}

	#extract lang ids from the request
	my $database_langs=&do_query('SELECT langid FROM language');
	my $langs;

	for my $i (@{$database_langs}) {
		if ($hin{'lang_'.$i->[0]}) {
			my $lang_id=$hin{'lang_'.$i->[0]};
			$lang_id=~s/lang_//g;
			$langs->{$i->[0]}=$lang_id;
		}
	}

	$hin{'csvd'}="\x01";
	$hin{'csvn'}="\x02";
	$hin{'sid_key_name'}='sid';
	$hin{'tid_key_name'}='tid';
	$hin{'key_value_name'}='key_value';
	$hin{'measure_id_name'}="measure_id";
	$hin{'sector_id_name'}="sector_id";

	my $errorMsgs = {
		'nokey'=>'Can\'t find key_column for this sheet: ',
		'notValidKey'=>'key value of given sheet is not valid in the first row. Please remove it and verify other key values. Sheet: ',
		'errEncKeys'=>'Weird encoding was found(check for ?? signs in the values) for key: ',
		'wrongSequence'=>'Sequence of language columns are different from defined in a first sheet.<br/>Note: languages and their sequence in the first row should be the same into others. Sheet: ',
		'unmatchedKeys'=>'There are too much unmatched keys have been found (more than 7%). Please verify if this key is correct: '
	};

	open(my $sid_csv,"> ".$atomcfg{'base_dir'}.'tmp/'.$hin{'sid_key_name'}.'.csv');
	binmode($sid_csv,":utf8");

	open(my $tid_csv,"> ".$atomcfg{'base_dir'}.'tmp/'.$hin{'tid_key_name'}.'.csv');
	binmode($tid_csv,":utf8");

	open(my $key_value_csv,"> ".$atomcfg{'base_dir'}.'tmp/'.$hin{'key_value_name'}.'.csv');
	binmode($key_value_csv,":utf8");

	open(my $measureId_csv,"> ".$atomcfg{'base_dir'}.'tmp/'.$hin{'measure_id_name'}.'.csv');
	binmode($measureId_csv,":utf8");

	open(my $sectorId_csv,"> ".$atomcfg{'base_dir'}.'tmp/'.$hin{'sector_id_name'}.'.csv');
	binmode($sectorId_csv,":utf8");

	my $keys_and_files={$hin{'sid_key_name'}=>$sid_csv,
						$hin{'tid_key_name'}=>$tid_csv,
						$hin{'key_value_name'}=>$key_value_csv,
						$hin{'measure_id_name'}=>$measureId_csv,
						$hin{'sector_id_name'}=>$sectorId_csv};
	&log_printf($import_file);

	my $oFmtJ = Spreadsheet::ParseExcel::FmtUnicode->new(Unicode_Map=>'UTF8');
	my $excel = Spreadsheet::ParseExcel::Workbook->Parse($import_file,$oFmtJ);

	my $err_sheets = {};
	$err_sheets = &create_transl_csv($excel,$langs,$errorMsgs,$keys_and_files);
	close($sectorId_csv);
	my $aa=\%hin;

	$err_sheets = {} if !$err_sheets; # we want to put this var into sub and then use it modified. If it would be undef nothing happens
	&backup('vocabulary');
	$hin{'import'}.=&_import($hin{'sid_key_name'},$err_sheets,$errorMsgs);
	&backup('tex');
	$hin{'import'}.=&_import($hin{'tid_key_name'},$err_sheets,$errorMsgs);
	&backup('feature_values_vocabulary');
	$hin{'import'}.=&_import($hin{'key_value_name'},$err_sheets,$errorMsgs);
	&backup('measure_sign');
	$hin{'import'}.=&_import($hin{'measure_id_name'},$err_sheets,$errorMsgs);
	&backup('sector_name');
	$hin{'import'}.=&_import($hin{'sector_id_name'},$err_sheets,$errorMsgs);

	my @keys = keys %$err_sheets;

	if (@keys!=0) {
		$hin{'import'}.="<h3>Errors have been found</h3>";

		for (keys %{$err_sheets}) {
			$hin{'import'}.="The $_ sheet has following errors: ";

			for ( @{$err_sheets->{$_}}) {
				$hin{'import'}.="<p><font size='2' style=\"color:red\">
			    	<ul>
				    <li>".$_."</li>
			        </ul></font></p>";
			}
		}
	}
	my $mail = {
			'to' => $atomcfg{'bugreport_email'},
			'from' =>  $atomcfg{'mail_from'},
			'subject' => "Translation import is done by ".$USER->{'login'},
			'default_encoding'=>'utf8',
			'html_body' => $hin{'import'},
			};
	&complex_sendmail($mail);

	$hin{'import_ignore_unifiedly_processing'} = 'Yes';
}

sub create_transl_csv(){
	my ($excel,$langs,$errorMsgs,$keys_files)=@_;

	# sign of 1-st sheet language column offset
	my $sign = 0;

	sub getVal(){
		my $cell=shift;
		if ($cell->{Code} eq 'ucs2'){
			return &trim(&Encode::decode("UCS-2BE", $cell->{Val}));
		}else{
			return &trim($cell->{Val});
		}
	}#sub getVal()

	sub trim{
	  my $str = shift;
	  $str=~s/^\s*(.*?)\s*$/$1/;
	  return $str;
  	}#sub trim

	sub get_lang_col_offset {
		my $sheet = shift;
		# contains language column offset
		my $lc_off = 0;
		if ($sheet->{Cells}[0][1]->{Val} eq 'Category Name' ||
			$sheet->{Cells}[0][1]->{Val} eq 'Feature Name') {
				$lc_off = 1;
		} elsif ($sheet->{Cells}[0][1]->{Val} eq 'Category' &&
				 $sheet->{Cells}[0][2]->{Val} eq 'Feature group') {
					 $lc_off = 2; # ignore two columns
		}
		return $lc_off;
	}

	#return a hash with:
	#1) number of column where is key value(could be 0 or 1) or undef if if sheet hasn't keys in first two cells
	#2) link to csv file header. This file will be populated with sheet values for given key.
	#3) hash of error messages if any
	sub check_sheet{
		my ($sheet,$errorMsgs,$keys_files,$langNameSequence)=@_;
		my @errors;
		my $key_col;
		my $foundKey;
		my $foundFile;
		#	Do given sheet relate to one of the given keys in the hash $keys_files
		for my $key (keys %{$keys_files}){
			if(&getVal($sheet->{Cells}[0][0]) ne $key and &getVal($sheet->{Cells}[0][1]) ne $key){
				$key_col=undef;
			}else{
				$foundKey=$key;
			}
		}
		if($foundKey){
			$foundFile=$keys_files->{$foundKey}; # now we know the file to write to
			$key_col=0 if &getVal($sheet->{Cells}[0][0]) eq $foundKey;# check where the found key really is
			$key_col=1 if &getVal($sheet->{Cells}[0][1]) eq $foundKey;
		}else{
			push(@errors,$errorMsgs->{'nokey'}.$sheet->{Name});
		}
		# check if sequence of language names in the first row of sheet match to first sheet's language sequence - $langNameSequence
		if($langNameSequence){# be sure we are not checking first sheet
			my $tmap = get_lang_col_offset($sheet);
			for (keys %{$langNameSequence}){
				if(&getVal($sheet->{Cells}[0][$_+$tmap+$sign]) ne $langNameSequence->{$_}){
					push(@errors,$errorMsgs->{'wrongSequence'}.$sheet->{Name});
					$key_col=undef;
					last;
				}
			}
		}
		#extended check f.e. sid should be a digit, key_value can't be empty. Only the first row is being checked
		if($foundKey ne $hin{'key_value_name'} and !(&getVal($sheet->{Cells}[1][$key_col])=~/^[\d]+$/)){
			$key_col=undef;
			push(@errors,$errorMsgs->{'notValidKey'}.$sheet->{Name});
		}
		elsif(!&getVal($sheet->{Cells}[1][$key_col])){
			$key_col=undef;
			push(@errors,$errorMsgs->{'notValidKey'}.$sheet->{Name});
		}
		return {'key_column'=>$key_col,'csv_file'=>$foundFile,'errors'=>\@errors};
	}#sub check_sheet

	my $err_sheets;
	my $key_name;
	my $langNameSequence;

	for my $sheet (@{$excel->{Worksheet}}){
		my $result=check_sheet($sheet,$errorMsgs,$keys_files,$langNameSequence);
		my $key_col=$result->{'key_column'};
		my $csv_file=$result->{'csv_file'};
		my $tmap = get_lang_col_offset($sheet);
		#we need to figure out first sheet to remember its language names
		if($sheet->{Name} eq @{$excel->{Worksheet}}[0]->{Name}) {
			$sign -= $tmap;
			for my $lang_pos (keys %{$langs}){
				$langNameSequence->{$lang_pos}=&getVal($sheet->{Cells}[0][$lang_pos]);
			}
		}
		if(defined($key_col)){
				my $csv_str;
				for my $lang_pos (keys %{$langs}){# iterate through langs given from user input
					$csv_str='';
					if ($langs->{$lang_pos}==1){# we should ignore such langs. 1 means not to import
						next;
					}
					for my $row ($sheet->{MinRow}+1 .. $sheet->{MaxRow}){ #first row of the sheet is a header
							$csv_str=&getVal($sheet->{Cells}[$row][$key_col]).$hin{'csvd'}.
									 &getVal($sheet->{Cells}[$row][$lang_pos+$tmap+$sign]).$hin{'csvd'}.
									 $langs->{$lang_pos}.$hin{'csvd'}.
									 $sheet->{Name}.$hin{'csvn'};#$sheet->{Name} is used only in statistic puprose
							print $csv_file $csv_str;
						}
				}#for langs
		}else {
			$err_sheets->{$sheet->{Name}}=\@{$result->{'errors'}};
		}
			#print $csv_file "\n\n" if $csv_file;
	}

	for my $key (keys %{$keys_files}){
		close($keys_files->{$key})
	}
	return $err_sheets;
}

sub _import
{
    my ($key_name,$err_sheets,$errorMsgs) = @_;
	sub delete_unmatched_keys{
		my ($key_name,$table_name)=@_;
		my $err_sheets=&do_query("SELECT sheet_name FROM import_temp tmp
					   LEFT JOIN $table_name tbl ON tbl.$key_name=tmp.$key_name
					   WHERE tbl.$key_name IS NULL and tmp.value!='' GROUP BY sheet_name");
		my $unmatched_by_pk=&do_query("SELECT count(distinct tmp.$key_name) FROM import_temp tmp
									   LEFT JOIN $table_name tbl ON tbl.$key_name=tmp.$key_name
									   WHERE tbl.$key_name IS NULL and tmp.value!=''")->[0][0];
	    &do_statement("DELETE tmp FROM import_temp tmp
					   LEFT JOIN $table_name tbl ON tbl.$key_name=tmp.$key_name
					   WHERE tbl.$key_name IS NULL and tmp.value!=''");
		my $total_count=&do_query("SELECT count(DISTINCT $key_name ) FROM import_temp ")->[0][0];
		return 1 if !$total_count; # we dont want to divide by zero.
		if($unmatched_by_pk/$total_count>0.07){# 0.07 it should be in a config
			log_printf("delete_unmatched_keys: key_name = ".$key_name.", table_name = ".$table_name.". Percentage is: ".($unmatched_by_pk * 100 / $total_count)." %");
			my @err_sheets_to_return;
			for(@{$err_sheets}){# this ugly procesing is needed to implode array elements with 'join' function
				push(@err_sheets_to_return,$_->[0]);
			}
			return \@err_sheets_to_return;
		}else{
			return 0;
		}
	}
	sub check_encoding{
		my ($key_name,$table_name)=@_;
		my $err_sheets=&do_query("SELECT sheet_name FROM import_temp tmp
					   			  WHERE tmp.value rlike '[?][^?]*[?]' GROUP BY sheet_name");
		if(scalar(@$err_sheets)>0){# we have ? in the value
			my @err_sheets_to_return;
			for(@{$err_sheets}){# this ugly procesing is needed to implode array elements with 'join' function
				push(@err_sheets_to_return,$_->[0]);
			}
			return \@err_sheets_to_return;
		}else{
			return 0;
		}
	}
	####### end subs

    my $csv=$atomcfg{'base_dir'}.'tmp/'.$key_name.'.csv';
    if (!-e $csv)
    {
    	$hin{'import'} .= "Import error! Given temporary csv file is not readable";
    	return 0;
    }
    my $langid;
    my $langname;
    my $quantity;
    my $null;
    my $unmatched_by_pk;
	if ($key_name eq $hin{'sid_key_name'})
	{
	    &do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	    &do_statement("CREATE TEMPORARY TABLE `import_temp` ( `sid` int(13) NOT NULL default '0',
	    													 `value` text NOT NULL,
	    													 langid int(11) NOT NULL,
	    													 sheet_name varchar(255) NOT NULL default '')");
	    #&do_statement("ALTER TABLE `import_temp` ENGINE=MyISAM");
	    &do_statement("LOAD DATA LOCAL INFILE '$csv' INTO TABLE `import_temp` FIELDS TERMINATED BY '$hin{'csvd'}' LINES TERMINATED BY '$hin{'csvn'}'");
		my $key_err_sheet=&delete_unmatched_keys('sid','vocabulary');
		return '' if $key_err_sheet==1;# 1 means import_temp is empty something goes wrong before and errors already assigned
		my $err_enc_sheet=&check_encoding('sid','vocabulary');
		if(!$key_err_sheet and !$err_enc_sheet){
			&do_statement("DELETE ipt FROM vocabulary v INNER JOIN import_temp ipt USING (sid,value,langid)");
	    	&do_statement("REPLACE INTO `vocabulary` (sid, langid, value) SELECT sid, langid, value FROM `import_temp` WHERE value != '' ");
		}elsif($key_err_sheet){
  	    	my @tmp=($errorMsgs->{'unmatchedKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$key_err_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}elsif($err_enc_sheet){
  	    	my @tmp=($errorMsgs->{'errEncKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$err_enc_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}
	}
	if ($key_name eq $hin{'tid_key_name'})
	{
	    &do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	    &do_statement("CREATE TEMPORARY TABLE `import_temp` ( `tid` int(13) NOT NULL default '0',
	    													 `value` text NOT NULL,
	    													 langid int(11) NOT NULL,
	    													 sheet_name varchar(255) NOT NULL default '')");
	    #&do_statement("ALTER TABLE `import_temp` ENGINE=MyISAM");
	    &do_statement("LOAD DATA LOCAL INFILE '$csv' INTO TABLE `import_temp` FIELDS TERMINATED BY '$hin{'csvd'}' LINES TERMINATED BY '$hin{'csvn'}'");
		my $key_err_sheet=&delete_unmatched_keys('tid','tex');
		return '' if $key_err_sheet==1;# 1 means import_temp is empty something goes wrong before and errors already assigned
		my $err_enc_sheet=&check_encoding('tid','tex');
		if(!$key_err_sheet and !$err_enc_sheet){
			&do_statement("DELETE ipt FROM tex t INNER JOIN import_temp ipt USING (tid,value,langid)");
	    	&do_statement("REPLACE INTO `tex` (tid, langid, value) SELECT tid, langid, value FROM `import_temp` WHERE value != '' ");
		}elsif($key_err_sheet){
  	    	my @tmp=($errorMsgs->{'unmatchedKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$key_err_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}elsif($err_enc_sheet){
  	    	my @tmp=($errorMsgs->{'errEncKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$err_enc_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}
	}
	elsif ($key_name eq $hin{'key_value_name'})
	{
	    &do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	    &do_statement("CREATE TEMPORARY TABLE `import_temp` ( `key_value` text NOT NULL,
	    													`value` text NOT NULL,
	    													langid int(11) NOT NULL,
	    													sheet_name varchar(255) NOT NULL default '',
	    													feature_values_group_id int(11) NOT NULL default 0)");
	    #&do_statement("ALTER TABLE `import_temp` ENGINE=MyISAM");
	    &do_statement("LOAD DATA LOCAL INFILE '$csv' INTO TABLE `import_temp` FIELDS TERMINATED BY '$hin{'csvd'}' LINES TERMINATED BY '$hin{'csvn'}'");
	    my $key_err_sheet=&delete_unmatched_keys('key_value','feature_values_vocabulary');
	    return '' if $key_err_sheet==1;# 1 means import_temp is empty something goes wrong before and errors already assigned
	    my $err_enc_sheet=check_encoding('key_value','feature_values_vocabulary');
		if(!$key_err_sheet and !$err_enc_sheet){
			&do_statement("DELETE ipt FROM feature_values_vocabulary f INNER JOIN import_temp ipt USING (key_value,value,langid)");
	    	&do_statement("UPDATE import_temp it
                       INNER JOIN feature_values_vocabulary v ON it.key_value=v.key_value AND v.langid=it.langid
                       SET it.feature_values_group_id=v.feature_values_group_id");
	    	&do_statement("REPLACE INTO `feature_values_vocabulary` (key_value, langid, feature_values_group_id, value)
                       SELECT key_value, langid, feature_values_group_id,  value FROM `import_temp` WHERE value != '' ");
		}elsif($key_err_sheet){
			$err_sheets->{join(', ',@{$key_err_sheet})}=[$errorMsgs->{'unmatchedKeys'}.$key_name];
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}elsif($err_enc_sheet){
  	    	my @tmp=($errorMsgs->{'errEncKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$err_enc_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
		}

	}
	elsif ($key_name eq $hin{'measure_id_name'})
	{
	    &do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	    &do_statement("CREATE TEMPORARY TABLE `import_temp` (measure_id int(11) NOT NULL default 0,
	    													 value varchar(250) NOT NULL,
	    													 langid int(11) NOT NULL,
	    													 sheet_name varchar(255) NOT NULL default '')");
	    #&do_statement("ALTER TABLE `import_temp` ENGINE=MyISAM");
	    &do_statement("LOAD DATA LOCAL INFILE '$csv' INTO TABLE `import_temp` FIELDS TERMINATED BY '$hin{'csvd'}' LINES TERMINATED BY '$hin{'csvn'}'");
	    my $key_err_sheet=&delete_unmatched_keys('measure_id','measure_sign');
	    return '' if $key_err_sheet==1;# 1 means import_temp is empty something goes wrong before and errors already assigned
	    my $err_enc_sheet=check_encoding('measure_id','measure_sign');

	    if(!$key_err_sheet and !$err_enc_sheet){
			&do_statement("DELETE ipt FROM measure_sign m INNER JOIN import_temp ipt USING (measure_id,value,langid)");
	    	&do_statement("REPLACE INTO `measure_sign` (measure_id, langid,value)
                       SELECT measure_id, langid,value FROM `import_temp` WHERE value != '' ");
	    }elsif($key_err_sheet){
  	    	my @tmp=($errorMsgs->{'unmatchedKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$key_err_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
	    }elsif($err_enc_sheet){
  	    	my @tmp=($errorMsgs->{'errEncKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$err_enc_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
	    }
	}
	elsif ($key_name eq $hin{'sector_id_name'}){
	    &do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	    &do_statement("CREATE TEMPORARY TABLE `import_temp` (sector_id int(11) NOT NULL default 0,
	    													 value varchar(250) NOT NULL,
	    													 langid int(11) NOT NULL,
	    													 sheet_name varchar(255) NOT NULL default '')");
	    #&do_statement("ALTER TABLE `import_temp` ENGINE=MyISAM");
	    &do_statement("LOAD DATA LOCAL INFILE '$csv' INTO TABLE `import_temp` FIELDS TERMINATED BY '$hin{'csvd'}' LINES TERMINATED BY '$hin{'csvn'}'");
	    my $key_err_sheet=&delete_unmatched_keys('sector_id','sector_name');
	    return '' if $key_err_sheet==1;# 1 means import_temp is empty something goes wrong before and errors already assigned
	    my $err_enc_sheet=check_encoding('measure_id','measure_sign');
	    if(!$key_err_sheet and !$err_enc_sheet){
			&do_statement("DELETE ipt FROM sector_name s INNER JOIN import_temp ipt USING (sector_id,value,langid)");
	    	&do_statement("REPLACE INTO `sector_name` (sector_id, langid,name)
                       SELECT sector_id, langid,value FROM `import_temp` WHERE value != '' ");
  	    }elsif($key_err_sheet){
  	    	my @tmp=($errorMsgs->{'unmatchedKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$key_err_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
	    }elsif($err_enc_sheet){
  	    	my @tmp=($errorMsgs->{'errEncKeys'}.$key_name);
	    	$err_sheets->{join(', ',@{$err_enc_sheet})}=\@tmp;
			&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
			return '';
	    }

	}else{
		&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
		return "";
	}
	my $report;
	my $goodRowsBySheet=&do_query("SELECT sheet_name,count(value) c_name
									  FROM import_temp WHERE value!=''
									  GROUP BY sheet_name ORDER BY sheet_name");
	my $ignoreRowsBySheet=&do_query("SELECT sheet_name,count(value) c_name
									  FROM import_temp WHERE value=''
									  GROUP BY sheet_name ORDER BY sheet_name");
	my $i=0;
	for(@{$goodRowsBySheet}){
		my $unimported_html="<li><b>Quantity of records which have not been imported:
								</b>$ignoreRowsBySheet->[$i][1]</li>" if $ignoreRowsBySheet->[$i][1];
		$report.="<p><font size='2'>
			    	Importing records from <b>".$_->[0]."</b> successfully complete!
			    	<ul >
			    	<li style=\"color:green\">".(($_->[1])?$_->[1]:0)." records were imported.</li>"
			        .$unimported_html.
			        "</ul></font></p>";
		$i++;
	}
	&do_statement("DROP TEMPORARY TABLE IF EXISTS `import_temp`");
	return $report;
}



#!!!tmp
#sub test_tables{
#	sub create_aaa_test{
#		my $table=shift;
#		&do_statement("DROP TABLE IF EXISTS aaa_$table");
#		&do_statement("CREATE TABLE aaa_$table LIKE $table");
#		&do_statement("INSERT INTO aaa_$table SELECT * FROM $table");
#	}
#	&create_aaa_test('import_temp');
#}


sub backup($) {
	my ($table) = @_;
	my $time = time();
	my $bak_table = $table . "_backup_" . $time;

	&do_statement("DROP TABLE IF EXISTS `$bak_table`");
	&do_statement("CREATE TABLE $bak_table LIKE $table");
	&do_statement("ALTER TABLE `$bak_table` ENGINE=MyISAM");
	&do_statement("INSERT INTO $bak_table SELECT * FROM $table");
}

sub command_proc_imp_prev {
	my $import_file = $hin{'import_file'};
	my $file_name = $hin{'file_name'};
	my $tmpfn = &make_code(8);
	my $temp = $atomcfg{'base_dir'}.'tmp/'.$tmpfn.'.xls';
	$hin{'temp'} = $tmpfn;
	my $inf = {};
	my $i = 0;
	my $type = 'null';
	#my $dspl = 0;
	my $tmp = '';

	my @import;
	my $imp_arr;
	#my $cat_max;

	if ($hin{'imp'} eq "true") {
	}
	else {
		open(XLS, $hin{'import_file'});
		open(TMP, "> $temp");
		my @content = <XLS>;
		print TMP @content;
		close(XLS);
		close(TMP);
		$import_file = $temp;
		my $oFmtJ = Spreadsheet::ParseExcel::FmtUnicode->new(Unicode_Map=>'UTF8');
		my $excel = Spreadsheet::ParseExcel::Workbook->Parse($import_file,$oFmtJ);

		for my $sheet (@{$excel->{Worksheet}}) {
			&log_printf("Sheet: $sheet->{Name}");
			$sheet->{MaxRow} ||= $sheet->{MinRow};
			$type = $sheet->{Cells}[0][0]->{Val};

			for my $row ($sheet->{MinRow} .. $sheet->{MaxRow}) {
				$sheet->{MaxCol} ||= $sheet->{MinCol};

				for my $col ($sheet->{MinCol} ..  $sheet->{MaxCol}) {
					my $cell = $sheet->{Cells}[$row][$col];

					if ($cell) {
						$inf->{$i}->{$col} = &xlsDecode($cell->{Code},$cell->{Val});
					}
				}
				$i++;
			}
		}

		# &log_printf("========= Import languages preview =========");

		my $pos = 0; # row
		my $value = $inf;
		my @import;

		while (defined($value->{$pos})) {
			if (defined($value->{$pos})) {
				my $i = 0; # column
				my $prj = $value->{$pos};

				for ($i; $i<=50; $i++) {
					if ($prj->{$i}) {
						$import[$pos]->{$i} = $prj->{$i};
						$imp_arr->{$pos}->{$i} = $prj->{$i};
					}
					#$i++;
				}
			}
			$pos++;
		}

		my $pos = 1;
		my $ret ;
		my $p = 0;

		if ($type eq "null") {
			&process_atom_ilib('errors');
			&process_atom_lib('errors');
			push @user_errors, $atoms->{'default'}->{'errors'}->{'incorrect_file_type'};
			&atom_cust::proc_custom_processing_errors;
		}
		else {
			my $lang = &do_query("SELECT l.langid, v.value FROM language l LEFT JOIN vocabulary v on l.sid=v.sid and v.langid = 1");
			my $sel = "";
			my $count = 0;

			while (defined($lang->[$count])) {
				my $value = $lang->[$count];
				my $lng = $value->[0];
				if ($lng == 1) {
					$sel .= "<option value='1'>Not to import</option>";
				}
				else {
					$sel .= "<option value='$value->[0]'>$value->[1]</option>";
				}
				$count++;
			}

			my $imp_rows = "<table width='100%'>";
			my $preview = "<font size='2'>Preview imported rows: ";
			my $script  = "\n<script language='JavaScript'>";
			my $div = "\n";
			my $scr_pre = "function preview(id)\n{\n";
			my $scr_des = "\nfunction deselect() {";

			# while (defined($import[0]->{$p}))
			for my $first_row (keys %{$import[0]}) {
				if (($import[0]->{$first_row} ne 'sid') &&
					($import[0]->{$first_row} ne 'id') &&
					($import[0]->{$first_row} ne 'tid') &&
					($import[0]->{$first_row} ne 'key_value') &&
					($import[0]->{$first_row} ne 'Category Name') &&
					($import[0]->{$first_row} ne 'Feature Name') &&
					($import[0]->{$first_row} ne 'Category')  &&
					($import[0]->{$first_row} ne 'Feature group')) {
						$imp_rows .= "\n<tr><td width='25%'><font size='2'>";
						$imp_rows .= $import[0]->{$first_row};
						$imp_rows .= "</font></td>";
						$imp_rows .= "<td width='75%'>";
						$imp_rows .= "<select name='lang_$first_row'>" . $sel . "</select>";
						$imp_rows .= "</td></tr>\n";
				}

				$preview .= "<a href='javascript://' onClick=\"preview('$import[0]->{$first_row}');\">$import[0]->{$first_row}</a> ";
				$scr_pre .= "\nif (id == '$import[0]->{$first_row}')";
				$scr_pre .= "\n{ ";
				$scr_pre .= "\ndeselect();";
				$scr_pre .= "\ndocument.getElementById('$import[0]->{$first_row}').style.display='';";
				$scr_pre .= "\n}";
				$scr_des .= "\n document.getElementById('$import[0]->{$first_row}').style.display='none';";
				my $pos = 1;
				$div .= "\n<div id='" . $import[0]->{$first_row} . "' style='display: none;' name='$first_row'><hr>";

				#while (defined($import[$pos]->{$p}))
				for my $row_num (@import) {
					$div .= $row_num->{$first_row} . ";&nbsp; ";
					$pos++;
				}
				$div .= "</div>\n";
			}

			$scr_des .= "}";
			$scr_pre .= "}";

			$imp_rows .= "</table>";
			$preview .= "</font>";
			$script .= $scr_des . "\n" . $scr_pre . "\n" . "</script>";
			$ret .= "<br />";
			$ret .= "</font>";
			#$hin{'import'}   = "<font size='2'>" . $fl_type . "<u>Choose language:</u><br />" . $imp_rows;
			$hin{'import'}   = "<font size='2'>" . "<u>Choose language:</u><br />" . $imp_rows;
			$hin{'import'}  .= "<hr>" . $preview . "&nbsp;&nbsp;|&nbsp;&nbsp;<a href='javascript://' onClick='deselect()'><font size='2'>hide</font></a>";
			$hin{'import'}  .= $script . $div;
			# &log_printf("============================================");
			$hin{'import'} .= "<input type=\"hidden\" name=\"imp\" value=\"true\">";
			#$hin{'import'} .= "<input type=\"hidden\" name=command value=\"lang_import\">";
			$hin{'import_ignore_unifiedly_processing'} = 'Yes';
			$hin{'button'}  = "";
			$hin{'button_ignore_unifiedly_processing'} = 'Yes';

			return 1;
		}
	}
}

sub xlsDecode
{
	my ($encoding, $value) = @_;

	if ($encoding eq 'ucs2')
	{
		$value = &Encode::decode("UCS-2BE", $value);
	}

	return $value;
}

sub command_proc_blacklist_update
{
	my $langid = &do_query("SELECT langid FROM language");
	my $lng;
	my $words;

	my $time = time();
	my $table = "language_blacklist";

	&do_statement("TRUNCATE TABLE $table");

	for my $id (@$langid)
	{
		$lng = $id->[0];
		if (defined($hin{$lng}))
		{
			@$words = split(" ",$hin{$lng});

			#$hin{'text'} = $words;

			for my $word (@$words)
			{
				&do_statement("INSERT INTO $table SET langid = " . &str_sqlize($lng) . ", value = " . &str_sqlize($word)) if ($word ne " ");
			}
		}
	}

	$hin{'confirm_msg'} = "Update seccussfully complete!";

	return 1;
}

sub command_proc_reupload_price_feed{
	$hin{'feed_url'}=&trim($hin{'feed_url'});# some sanitarity processing
	&process_atom_ilib('feed_config');
	&process_atom_lib('feed_config');
	my $result=&reupload_price_feed(\%hin);
	if(ref($result) eq 'ARRAY'){
		push(@user_errors,@$result);
	}else{
	}
	return '';
}

sub command_proc_coverage_report_from_file {
	my $file_to_load=&get_feed_file($atomcfg{session_path}.$hin{'feed_config_id'}.'/');
	return '' unless($file_to_load);

	my $result=get_cov_report_file_first_row($file_to_load);
	return '' unless($result);
	my ($first_row,$file_to_load,$delimiter,$newline,$escape)=@{$result};
	use coverage_report qw(coverage_by_table);
	my %columns=($hin{'ean_col'}=>'ean',
				 $hin{'brand_prodid_col'}=>'prod_id',
				 $hin{'brand_col'}=>'vendor');
	my @max_arr=sort {$b<=>$a} keys(%columns);

	#return '' unless($max_arr[0]);
	my $vars=" ( ";
	my $sets=" SET ";
	my $column_count;
	if(ref($first_row) eq 'ARRAY' and scalar(@{$first_row->[0]})>$max_arr[0]){
		$column_count=scalar(@{$first_row->[0]});
	}else{
		$column_count=$max_arr[0];
	}
	my $extended_cols='';
	my $rep_hash={};
	my @ext_header;
	use POSIX qw(floor);
	my %eans_cols=map {$_=>1} split(',',$hin{'feed_ean_cols'});
	my $ean_column='';
	for(my $i=1; $i<=$column_count;$i++){
		$vars.=" \@var$i, ";
		if($columns{$i} and $columns{$i} ne 'ean'){
			$sets.=$columns{$i}."=TRIM(\@var$i), ";
		}elsif($columns{$i} and $columns{$i} eq 'ean'){
			$ean_column=$columns{$i};
		}else{
			my $ext_col=&trim($first_row->[0][$i-1]);

			if($hin{'is_first_header'} and $ext_col){
				$ext_col=~s/[^\w]+/_/gs;
				$ext_col=&shortify_str('Info_'.$i.'_'.$ext_col,20,'');
			}else{
				$ext_col="Column_$i";
			}
			if($rep_hash->{$ext_col}){
				$ext_col=$ext_col.'_'.&floor(rand(1000));
				$rep_hash->{$ext_col}=1;
			}else{
				$rep_hash->{$ext_col}=1;
			}
			push(@ext_header,$ext_col);
			$extended_cols.=" $ext_col text not null default '',\n";
			$sets.=$ext_col."=\@var$i, "
		}
	}
	my $ean_set;
	if($hin{'ean_col'} and scalar(keys(%eans_cols))>0){
		#ean=CONCAT(VAR1,',',VAR2,',',VAR3)
		if(!$eans_cols{$hin{'ean_col'}}){
			$eans_cols{$hin{'ean_col'}}=1;
		}
		$ean_set=$ean_column."=CONCAT( ";
		for my $ean_col(keys(%eans_cols)){
			$ean_set.='TRIM(@VAR'.$ean_col."),'".(',')."',";
		}
		$ean_set=~s/,[^,]*,$//;
		$ean_set=~s/,[^,]*$//;
		$ean_set.=') ';
	}elsif($hin{'ean_col'} and scalar(keys(%eans_cols))<=0){
		$ean_set=$ean_column.'='.'TRIM(@VAR'.$hin{'ean_col'}.')';
	}
	$sets.=$ean_set;
	&do_statement("DROP TEMPORARY TABLE IF EXISTS itmp_cov_report");
	&do_statement("CREATE TEMPORARY TABLE  itmp_cov_report (
					prod_id varchar(60)  not null default '',
					vendor  varchar(255) not null default '',
					ean     varchar(255) not null default '',
					$extended_cols
					key (prod_id, vendor),
					key (vendor),
					key (ean))");

	$vars=~s/,[\s]*$//;
	$sets=~s/,[\s]*$//;
	$vars.=" ) ";

	my $sql="LOAD DATA LOCAL INFILE '$file_to_load'
			 INTO TABLE itmp_cov_report
			 FIELDS TERMINATED BY '".$delimiter."'
				 		ESCAPED BY ".&str_sqlize($escape)."
				 		OPTIONALLY ENCLOSED BY '\"'
			 LINES
				 TERMINATED BY '$newline'\n"
				 .(($hin{'is_first_header'}*1)?" IGNORE 1 LINES \n":" \n ").$vars."\n".$sets;

	&do_statement("alter table itmp_cov_report disable keys");
	&do_statement($sql);
	&do_statement("alter table itmp_cov_report enable keys");
	&do_statement("UPDATE itmp_cov_report SET ean='' WHERE ean rlike '^[,]+\$'");
#	log_printf(Dumper(&do_query("select * from itmp_cov_report")));

	my $count_loaded=&do_query('SELECT count(*) FROM itmp_cov_report')->[0][0];
	coverage_by_table('itmp_cov_report',{ 'ean' => $hin{'ean_col'},'lang_code'=>$hin{'link_lang'}});
	my $count_deleted=$count_loaded-&do_query('SELECT count(*) FROM itmp_cov_report')->[0][0];
	&do_statement('UPDATE itmp_cov_report t
					JOIN product p USING(product_id)
					JOIN supplier s ON p.supplier_id=s.supplier_id
					SET map_supplier_id=s.supplier_id
					WHERE t.product_id!=0 AND map_supplier_id=0');

	#filter=supp:1,type:1,scat:1,col:2
	my $current_time=&do_query("SELECT unix_timestamp()")->[0][0];
	my $cache_table='itmp_f_table_coverage_end_'.$current_time;
	my $feed_coverage_duplicates=&create_cov_cache_table('itmp_cov_report',$cache_table);
	$hin{'coverage_cache_table'}=$cache_table;
	if($hin{'feed_type'} eq 'xls' and (-e $file_to_load)){
		`rm '$file_to_load'`;
	}

	# insert bad products saved by coverage_by_table into table <name>_saved
	my $ext_cols_str=join(',',@ext_header);
	if($ext_cols_str){ # there can be no extended columns
		&do_statement("INSERT INTO itmp_cov_report ($ext_cols_str) SELECT $ext_cols_str FROM  itmp_cov_report_saved");
	}
	my ($cover_html,$cover_txt)=@{get_coverage_sumary_by_table('itmp_cov_report',$feed_coverage_duplicates,$count_deleted,$cache_table,$count_deleted)};
	$hs{'coverage_summary'}=$cover_html;
	$hl{'coverage_summary'}=$cover_html;

	# if user wants report via email
	return '' if !$hin{'user_email'};
	my ($report_body,$report_type);
	if($hin{'report_type'} eq 'xls'){
		# write xls file
		($report_body,$report_type)=@{get_xls_cov_report('itmp_cov_report',\@ext_header,$hin{'link_lang'})};
	}else{#write csv file
		($report_body,$report_type)=@{get_csv_cov_report('itmp_cov_report',\@ext_header,$hin{'link_lang'})};
		$report_body=Encode::encode_utf8($report_body);
	}
	# send mail
	&send_coverage_from_file_report($report_body,$cover_txt,$report_type,$file_to_load);

	return '';
}


sub command_proc_coverage_report_track_list {
	my $file_to_load=&get_feed_file($atomcfg{session_path}.$hin{'feed_config_id'}.'/');
	return '' unless($file_to_load);
	my $result=get_cov_report_file_first_row($file_to_load);
	return '' unless(ref($result) eq 'ARRAY');
	my ($first_row,$file_to_load,$delimiter,$newline,$escape)=@{$result};
	my $cov_result=&load_coverage_track_list($first_row,$file_to_load,$delimiter,$newline,$escape,'itmp_cov_report');
	my ($ext_header,$count_deleted)=($cov_result->{'ext_header'},$cov_result->{'count_deleted'});

	#filter=supp:1,type:1,scat:1,col:2
	my $current_time=&do_query("SELECT unix_timestamp()")->[0][0];
	my $cache_table='itmp_f_table_coverage_end_'.$current_time;
	my $feed_coverage_duplicates=&create_cov_cache_table('itmp_cov_report',$cache_table);
	$hin{'coverage_cache_table'}=$cache_table;
	if($hin{'feed_type'} eq 'xls' and (-e $file_to_load)){
		`rm '$file_to_load'`;#clean up
	}

	my ($cover_html,$cover_txt)=@{get_coverage_sumary_by_table('itmp_cov_report',$feed_coverage_duplicates,$count_deleted,$cache_table,$count_deleted)};
	$hs{'coverage_summary'}=$cover_html;
	$hl{'coverage_summary'}=$cover_html;

	# if user wants report via email
	return '' if !$hin{'user_email'};
	my ($report_body,$report_type);
	if($hin{'report_type'} eq 'xls'){
		# write xls file
		($report_body,$report_type)=@{get_xls_cov_report('itmp_cov_report',$ext_header)};
	}else{#write csv file
		($report_body,$report_type)=@{get_csv_cov_report('itmp_cov_report',$ext_header)};
	}
	# send mail
	&send_coverage_from_file_report($report_body,$cover_txt,$report_type,$file_to_load);

	return '';
}

sub command_proc_add_tracklist_products{
	my $file_to_load=&get_feed_file($atomcfg{session_path}.$hin{'feed_config_id'}.'/');
	unless( -e $file_to_load){
		push(@user_errors,'Can\'t save tracking list');
		return '';
	};

	my $result=&get_cov_report_file_first_row($file_to_load);
	unless(ref($result) eq 'ARRAY'){
		push(@user_errors,'Can\'t save tracking list');
		return '';
	};
	my ($first_row,$file_to_load,$delimiter,$newline,$escape)=@{$result};
	&load_coverage_track_list($first_row,$file_to_load,$delimiter,$newline,$escape,'itmp_cov_report_load');
	if($hin{'feed_type'} eq 'xls' and (-e $file_to_load)){
		`rm '$file_to_load'`;
	}
	if(!$hin{'track_list_id'}){
		return '';
	}
	if(!&do_query('SELECT count(*) FROM itmp_cov_report_load')->[0][0]){
		push(@user_errors,'There are no products to be added');
		return '';
	};
	if($hin{'atom_submit'}){
		&do_statement("UPDATE track_list SET created=current_timestamp() WHERE track_list_id=$hin{'track_list_id'}");
	}

	&do_statement("DELETE FROM itmp_cov_report_load_saved WHERE prod_id='' AND vendor='' AND
				   		  name='' AND ext_col1='' AND ext_col2='' AND ext_col3=''");# remove 100% useless products

	&do_statement("UPDATE track_list SET user_id=".$USER->{'user_id'}." WHERE track_list_id=$hin{'track_list_id'}");
	&do_statement("ALTER TABLE track_product ADD COLUMN tmp_id int(11) not null");
	&do_statement('DELETE track_product_ean te FROM track_product_ean te
				   JOIN track_product t USING(track_product_id)
				   WHERE track_list_id='.$hin{'track_list_id'});
	&do_statement('DELETE FROM track_product WHERE track_list_id='.$hin{'track_list_id'});
	&do_statement("alter table track_product disable keys");
	&do_statement("INSERT INTO track_product (track_list_id,product_id,feed_prod_id,map_prod_id,feed_supplier,
											  supplier_id,name,ext_col1,ext_col2,ext_col3,quality,by_ean_prod_id,tmp_id)
				   SELECT $hin{'track_list_id'},product_id,prod_id,map_prod_id,vendor,
				   		  map_supplier_id,name,ext_col1,ext_col2,ext_col3,quality,IF(by_ean_prod_id='',0,1),id
				   FROM itmp_cov_report_load");

	&do_statement("INSERT INTO track_product_ean (track_product_id,ean,product_id)
				   SELECT tp.track_product_id,tean.ean,tean.product_id
				   FROM itmp_cov_report_load_eans tean JOIN track_product tp ON tp.tmp_id=tean.id
				   WHERE tp.tmp_id IS NOT null");
	&do_statement("INSERT INTO track_product (track_list_id,product_id,feed_prod_id,feed_supplier,
											  name,ext_col1,ext_col2,ext_col3)
				   SELECT $hin{'track_list_id'},product_id,prod_id,vendor,
				   		  name,ext_col1,ext_col2,ext_col3
				   FROM itmp_cov_report_load_saved");

	&do_statement("ALTER TABLE track_product DROP COLUMN tmp_id");
	&do_statement("alter table track_product enable keys");

	&do_statement("UPDATE track_product tp
	JOIN track_list tl ON tl.track_list_id=tp.track_list_id
	JOIN product p ON p.product_id=tp.product_id
	JOIN users u ON p.user_id=u.user_id
	JOIN user_group_measure_map gm ON u.user_group=gm.user_group
	LEFT JOIN product_ean_codes pe ON pe.product_id=p.product_id
	SET
	extr_langs      = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id GROUP BY pd.product_id),
	extr_pdf_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.pdf_url!='' GROUP BY pd.product_id),
	extr_man_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.manual_pdf_url!='' GROUP BY pd.product_id),
	extr_rel_count  = (SELECT count(pr.product_related_id) FROM product_related pr WHERE pr.product_id=p.product_id),
	extr_feat_count = (SELECT count(pf.product_feature_id) FROM product_feature pf WHERE pf.product_id=p.product_id),
	extr_quality    = lcase(gm.measure),
	extr_ean        = pe.ean_code,
	track_product_status = (IF(tp.is_parked=1,'parked',IF(gm.measure='ICECAT','described','not_described'))),
	rule_prod_id=IF(feed_prod_id!=map_prod_id and tp.product_id!=0 and by_ean_prod_id=0,map_prod_id,''),
	is_reverse_rule=IF(feed_prod_id!=map_prod_id and tp.product_id!=0 and by_ean_prod_id=0,0,1),
	remarks=IF(feed_prod_id!=map_prod_id and tp.product_id!=0 and by_ean_prod_id=0,CONCAT('AUTO:correct part code is ',map_prod_id),'')
	WHERE tp.track_list_id=".$hin{'track_list_id'});
	&do_statement("UPDATE track_product tp SET
				eans_joined = (SELECT group_concat(ean separator ',') FROM track_product_ean te
				   WHERE te.track_product_id=tp.track_product_id GROUP BY te.track_product_id)
				 WHERE tp.track_list_id=".$hin{'track_list_id'});
	&do_statement("INSERT IGNORE INTO track_list_supplier_map (symbol,client_id) 
				   (SELECT feed_supplier,$hin{'client_id'} FROM track_product 
				    WHERE track_list_id=$hin{'track_list_id'} AND extr_quality!='icecat' AND supplier_id=0 AND feed_supplier!='')");
	&do_statement("UPDATE track_product SET track_product_status='parked' where product_id=0 and is_parked=1");
	&do_statement("UPDATE track_product SET track_product_status='not_described' where product_id=0 and is_parked=0");
	return '1';
}

sub command_proc_send_email_about_custom_value_in_select {

	# get custom values, which was entered by user
	my @custom_list = ();
	for (keys %hin) {
	    if (/^(.*)_use_custom$/) {
		unshift @custom_list, $1;
	    }
	}
	# exit if no custom values
	return 1 if (scalar @custom_list == 0);

	log_printf("Custom value has been used");

	# tmp reference
	my $ref;

	# get locale (international case or symbolic name from DB)
	my $locale;
	my $locale_id = 0;
	log_printf($hin{'hidden_tab_id'});
	if ($hin{'hidden_tab_id'} eq '0') {
	    $locale = "International";
	} else {
	    $hin{'hidden_tab_id'} =~ /_(\d+)$/;
	    $locale_id = $1;
	    $ref = do_query("SELECT code FROM language WHERE langid=" . $1);
	    $locale = $ref->[0]->[0];
	}

	my $mail_content = "Product with ID " . $hin{'product_id'} . " use " . scalar @custom_list . " custom value(s)\n\n";

	# get part number (prod_id FROM product)
	$ref = do_query("SELECT * FROM product WHERE product_id = " . $hin{'product_id'} );
	my $part_number = $ref->[0]->[2];

	my $supplier_id = $ref->[0]->[1];
	my $catid = $ref->[0]->[3];

	# get brand (name FROM supplier)
	$ref = do_query("SELECT name FROM supplier WHERE supplier_id = " . $supplier_id);
	my $supplier = $ref->[0]->[0];

	# get category (name FROM vocabulary)
	$ref = do_query("SELECT sid FROM category WHERE catid = " . $catid );
	my $sid = $ref->[0]->[0];
	$ref = do_query("SELECT value FROM vocabulary WHERE langid=1 AND sid = " . $sid);
	my $categ = $ref->[0]->[0];

	$mail_content .= "\n";

	# $mail_content .= "Category feature ID : $category_feature_id\n";
	# $mail_content .= "Feature ID          : $feature_id\n";
	# $mail_content .= "CatID               : $catid\n";

	$mail_content .= "Part number       : $part_number\n";
	$mail_content .= "Supplier (Brand)  : $supplier\n";
	$mail_content .= "Category          : $categ\n";
	$mail_content .= "\n";
	$mail_content .= "------------------------------\n\n";


	my $new_custom_values = 0;
	# loop for processing each custom value
	for (@custom_list) {

	    # get if from para name
	    /_(\d+)$/;
	    my $category_feature_id = $1;

	    # get restricted values and check user's value
	    # 1. get a feature_id from a category_feature table
	    # 2. get a list of restricted values
	    $ref = do_query("SELECT feature_id FROM category_feature WHERE category_feature_id = " . $category_feature_id );
	    my $feature_id = $ref->[0]->[0];
	    $ref = do_query("SELECT restricted_values FROM feature WHERE feature_id = " . $feature_id );
	    my @restricted_values = split(/\n/, $ref->[0]->[0]);

	    $ref = do_query("SELECT restricted_search_values FROM category_feature WHERE category_feature_id = " . $category_feature_id );
	    my @restricted_search_values = split(/\n/, $ref->[0]->[0]);

	    # get feature name
	    $ref = do_query("SELECT sid FROM feature WHERE feature_id = " . $feature_id );
	    my $sid = $ref->[0]->[0];
	    $ref = do_query("SELECT value FROM vocabulary WHERE langid=1 AND sid=" . $sid);
	    my $value = $ref->[0]->[0];

	    # get used value from HIN (2 cases : international or with not zero locale)
	    my $used_value = '';
	    my $key ='';
	    if ($locale_id == 0) {
		# international case
		$key = '_rotate_value_' . $category_feature_id;
	    } else {
		# not international case
		$key = $locale_id . "tab_" . $locale_id . "_" . $category_feature_id;
	    }
	    $used_value = $hin{$key};

	    # check if a feature value inside restricted array
	    @restricted_values = (@restricted_values, @restricted_search_values);
	    my $position = -1;
	    my $decision;
	    for (my $i = 0 ; $i <= $#restricted_values ; $i++) {
		if ($restricted_values[$i] eq $used_value) {
			$position = $i;
			last;
		}
	    }
	    if ($position == -1) {
		$new_custom_values++;
		$decision = "Not present in restricted array";
	    }
	    else {
		$decision = $position + 1;
	    }

	    # add to email
	    $mail_content .= "Category feature ID   : $category_feature_id\n";
	    # $mail_content .= "Feature ID          : $feature_id\n";
	    # $mail_content .= "CatID               : $catid\n";
	    $mail_content .= "Name                  : $value\n";
	    $mail_content .= "Used value            : $used_value\n";
	    $mail_content .= "Restricted            : @restricted_values\n";
	    $mail_content .= "Present               : $decision\n";
	    $mail_content .= "\n";
	    $mail_content .= "------------------------------\n\n";
	}

	$mail_content .= "\n";
	# get login from global hash
	$mail_content .= "Used by             : " . $USER->{'login'} . "\n";
	$mail_content .= "Locale              : " . $locale . "\n\n";

	# store mail in log
	log_printf($mail_content);

	# Default values will be used if hash is not defined
	# my $from = $email_about_custom->{'from'} ? $email_about_custom->{'from'} : 'info@icecat.biz';
	# my $to = $email_about_custom->{'to'} ? $email_about_custom->{'to'} : 'ilya@icecat.biz';
	# my $title = $email_about_custom->{'title'} ? $email_about_custom->{'title'} : 'Custom values have been used';

	# log_printf("FROM  : " . $from);
	# log_printf("TO    : " . $to);
	# log_printf("TITLE : " . $title);

	if ($new_custom_values > 0) {
	    # in old variant a letter about new custon value sent immediately
	    # sendmail($mail_content, $to, $from, $title);
	    # but now it appends to

	    my $tmp_dir = $atomcfg{'session_path'};
	    my $filename = $email_about_custom->{'deferred_file'} ? $email_about_custom->{'deferred_file'} : $tmp_dir . 'mail_about_custom.txt';
	    open my $F, '>>', $filename;
	    print $F $mail_content;
	    close $F;

	    log_printf("A message about custom value has appended to a daily report");
	}
	else {
	    log_printf("No new values. No mail.");
	}

	return 1;
}

sub command_proc_update_sector_name_table {

    my $sector_id = $hin{'sector_id'};

    # get keys from hin
    my @used_langids = ();
    for (keys %hin) {
    	if (/^value_(\d+)$/) {
	        unshift @used_langids, $1;
    	}
    }

    # english name checker
    my $list = do_query("SELECT name FROM sector_name WHERE langid = 1 AND sector_id != $sector_id ");

    my ($st, $ans, $sector_name_id);
    for (@used_langids) {

	    # log_printf($hin{'value_' . $_});

    	$ans = do_query("SELECT sector_name_id FROM sector_name WHERE sector_id = $sector_id AND langid = $_");
	    $sector_name_id = $ans->[0]->[0];

    	# get name
	    my $nm = $hin{'value_' . $_};
	    # cut whitespaces
	    $nm =~ s/^\s+//;
	    $nm =~ s/\s+$//;

	     if ($_ == 1) {
            for my $eng_name (@$list) {
                if ($eng_name->[0] eq $nm) {
                    &process_atom_ilib('errors');
                    &process_atom_lib('errors');
                    $atoms->{'default'}->{'errors'}->{'error_with_english_name'} = 'English name should be unique';
                    push @user_errors, $atoms->{'default'}->{'errors'}->{'error_with_english_name'};
                    &atom_cust::proc_custom_processing_errors;
                    return 0;
                }
            }

            if (!$nm) {
                &process_atom_ilib('errors');
                &process_atom_lib('errors');
                $atoms->{'default'}->{'errors'}->{'error_with_english_name'} = 'English name should not be an empty string';
                push @user_errors, $atoms->{'default'}->{'errors'}->{'error_with_english_name'};
                &atom_cust::proc_custom_processing_errors;
                return 0;
            }
        }

	    if ($sector_name_id) {
	        $st =  "UPDATE sector_name SET name = '" . $nm . "' ";
    	    $st .= "WHERE sector_id = " . $sector_id . " AND langid = " . $_;
    	}
    	else {
	        if ($nm) {
    		    $st = "INSERT INTO sector_name (sector_id, name, langid) VALUES ($sector_id, '$nm', $_)";
	        }
	        else {
    		    $st= '';
	        }
    	}

	    # log_printf($st);
    	do_statement($st) if ($st);
    }

    return 1;
}

sub delete_sector {
    my $sector_id = shift;

    do_statement('DELETE FROM sector WHERE sector_id = ' . $sector_id);
    do_statement('DELETE FROM sector_name WHERE sector_id = ' . $sector_id);
}

sub command_proc_delete_from_sector_table {

    # we should delete a record from a sector table and all records with same sector id from sector_name

    # record with sector_id = 1 is immortal
    my $sector_id = $hin{'sector_id'};
    if ($sector_id != 1) {

	    delete_sector($sector_id);
	    do_statement("UPDATE contact SET sector_id = 1 WHERE sector_id = " . $sector_id );
    }
    else {
	log_printf("Sector with ID = 1 is immortal. You can not remove it from a DB");
    }

    return 1;
}

sub command_proc_merge_sectors {

    my $target = $hin{'sector_id_radio'};
    if (! $target) {
	log_printf("Target sector should be defined");
	return;
    }

    # get a set of ids for megre
    my @set = ();
    for (keys %hin) {
	if (/^checked_sector_(\d+)$/) {
	    if (($1 == 1) && ($target != 1)) {
		log_printf("Target sector should be IT in this case");
		return;
	    }
	    push @set, $1;

	}
    }

    if (scalar @set < 1) {
	log_printf("Not enough sectors for the merge operation");
	return;
    }

    # log about action
    log_printf("Merge sector(s) with id(s) : @set");
    log_printf("To a target sector with an id : $target");

    for (@set) {
	next if ($_ == $target);
	do_statement("UPDATE contact SET sector_id = $target WHERE sector_id = " . $_);
        delete_sector($_);
    }

    return 1;
}

sub command_proc_add_custom_sector {

    # return if not use custom
    return 1 unless ($hin{'sector_id_use_custom'});
    my $eng_name = $hin{'sector_id'};
    my $ans;

    # check for duplicate
    $ans = do_query('SELECT name FROM sector_name WHERE langid = 1');
    my $skip_insert = 0;
    for (@$ans) {
	if ($eng_name eq $_->[0]) {
	    # log_printf("Duplicate English name !!!");
	    $skip_insert = 1;
	    last;
	}
    }

    # insert
    my $sector_id;
    if ($skip_insert) {
	$sector_id = 1;
    } else {
	do_statement("INSERT INTO sector (dummy) VALUES ('')");
	$ans = do_query('select last_insert_id()');
	$sector_id = $ans->[0]->[0];
	log_printf('SECTOR_ID = ' . $sector_id);
    do_statement("INSERT INTO sector_name (name, sector_id, langid) VALUES ('$eng_name', $sector_id, 1)");
    }

    # update user contact
    do_statement("UPDATE contact SET sector_id = $sector_id WHERE contact_id = " . $hin{'pers_cid'});
    return 1;
}

sub command_proc_refresh_category_feature_intervals {

    my $cf_id = $hin{'category_feature_id'};
    # all code was moved to atom_util.pm
    make_category_feature_intervals($cf_id);

    return 1;
}

sub command_proc_delete_from_virtual_category_table {
    my $id = $hin{'virtual_category_id'};

    # delete a virtual category
    do_statement('DELETE FROM virtual_category WHERE virtual_category_id = ' . $id);

    # delete all enteries from 'virtual_category_product' table
    do_statement('DELETE FROM virtual_category_product WHERE virtual_category_id = ' . $id);

    return 1;
}

# this subroutine will process virtual categories during 'update' and 'delete' operations
sub update_virtual_categories_for_certain_product {
    my $pid = shift;

    # delete all old instances for product
    do_statement('DELETE FROM virtual_category_product WHERE product_id = ' . $pid);

    # that is all if we perform a delete operation for product
    return if ($hin{'atom_delete'});

    # add new set
    my $vcatid;
    for (keys %hin) {
        if (/^vcat_/) {
            # log_printf($_ .  " " . $hin{$_} );
            $vcatid = $hin{$_};
            do_statement("INSERT INTO virtual_category_product (product_id, virtual_category_id) VALUES ($pid, $vcatid)");
        }
    }

    return;
}

sub command_proc_update_track_product{
	if(scalar(@user_errors)<1 and $hin{'product_id'} and $hin{'atom_update'}){
		my $track_product=&do_statement('UPDATE track_product
									 SET described_date=IF(extr_quality!=\'icecat\',now(),described_date),
									 extr_quality=\'icecat\'
									 WHERE product_id='.$hin{'product_id'});

	}elsif(scalar(@user_errors)<1 and $hin{'product_id'} and $hin{'atom_submit'} and $hin{'track_product_id'}){
		my $feed_prod_id=&do_query('SELECT map_prod_id FROM track_product WHERE track_product_id='.$hin{'track_product_id'})->[0][0];
		my $rule_prod_id_sql='';
		if($feed_prod_id and $hin{'prod_id'} ne $feed_prod_id){
		use track_lists;									 			 
			$rule_prod_id_sql='rule_prod_id='.&str_sqlize($hin{'prod_id'}).",is_reverse_rule=0,\n";
		}
		my $track_product=&do_statement('UPDATE track_product
									 SET product_id='.$hin{'product_id'}.',
									 extr_quality=\'icecat\',
									 '.$rule_prod_id_sql.'
									 described_date=now()
									 WHERE track_product_id='.$hin{'track_product_id'});
		add_track_product_rule($hin{'track_product_id'});
	}
	return 1;
}

sub command_proc_set_is_parked{
	my $remarks=$hin{'remarks'};
	$remarks=~s/\n/<br\/>/gs;
	$remarks=&str_htmlize($remarks);
	my $prev_params=&do_query('SELECT is_parked,remarks
							   FROM track_product WHERE track_product_id='.$hin{'track_product_id'})->[0];
	my $action='';
	#&lp("--------->>>>>>>>>>>>>>>>>>>".Dumper($prev_params).'      '.Dumper($hin{'is_parked'}).' '.Dumper($hin{'remarks'}));
	if((!$prev_params->[0] ^ !$hin{'is_parked'}) and $hin{'is_parked'} and $prev_params->[1] ne $remarks){
		$action='Parks product and change the remark';
	}elsif((!$prev_params->[0] ^ !$hin{'is_parked'}) and $hin{'is_parked'}){
		$action='Parks product';
	}elsif($prev_params->[0] and !$hin{'is_parked'}){
		$action='Unparks product';
	}elsif(!(!$prev_params->[0] ^ !$hin{'is_parked'}) and $prev_params->[1] ne $remarks and $remarks){
		$action="Changes the remark only";
	}elsif(!(!$prev_params->[0] ^ !$hin{'is_parked'}) and $prev_params->[1] ne $remarks and !$remarks){
		$action="Empties the remark";
	}else{# nothing changes
		return 1;
	}

	&do_statement("UPDATE track_product
				   SET is_parked=".($hin{'is_parked'}?'1':'0').",
				   park_cause='$hin{'is_parked'}',
				   remarks=".str_sqlize($remarks).",
				   changer=$USER->{'user_id'},
				   changer_action=".str_sqlize($action)."
				   WHERE track_product_id=".$hin{'track_product_id'});
	return 1;
}

sub command_proc_save_track_list_settings{
	if(scalar(@user_errors)<1 and $hin{'track_list_id'} and ($hin{'atom_update'} or $hin{'atom_submit'})){
		# PROCESS ASSIGNED USERS
		my @assigned_users=$hin{'REQUEST_BODY'}=~/occupied_user_id=([\d]+)/gs;
		my $values='';
		my $editors_before=&do_query("SELECT user_id FROM track_list_editor WHERE track_list_id=$hin{'track_list_id'}");
		my %editors_before_map=map {$_->[0]=>1} @$editors_before;
		for my $user_id(@assigned_users){
			$values.=" ($hin{'track_list_id'} , $user_id) ,";
			unless($editors_before_map{$user_id}){# send notification to new added user
				my $editor_info=&do_query("SELECT c.person,c.email,u.login FROM users u
										   LEFT JOIN contact c ON c.contact_id=u.pers_cid  WHERE u.user_id=$user_id");
				my $tl_info=&do_query("SELECT tl.name,c.person,u.login FROM track_list tl
									   JOIN users u USING(user_id)
									   LEFT JOIN contact c ON c.contact_id=u.pers_cid
									   WHERE tl.track_list_id=$hin{'track_list_id'}");
				mail_atom_template('track_list_invite_mail',$editor_info->[0][1],'Assing to the list: '.$tl_info->[0][0],
								  {'name'=>$editor_info->[0][0],'list_name'=>$tl_info->[0][0],
								  	'manager_name'=>(($tl_info->[0][1])?$tl_info->[0][1]:$tl_info->[0][2])}
								  	);

			}
		}
		$values=~s/,$//;

		&do_statement("DELETE FROM track_list_editor WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("INSERT IGNORE INTO track_list_editor (track_list_id,user_id)
						   VALUES $values");

		# PROCESS ASSIGNED LANGUAGES
		my @assigned_langs=$hin{'REQUEST_BODY'}=~/occupied_langid=([\d]+)/gs;
		$values='';
		for my $langid(@assigned_langs){
			$values.=" ($hin{'track_list_id'} , $langid) ,";
		}
		$values=~s/,$//;
		&do_statement("DELETE FROM track_list_lang WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("INSERT IGNORE INTO track_list_lang (track_list_id,langid)
					   VALUES $values");

		# PROCESS ASSIGNED RESTRICTED COLUMNS
		my @assigned_cols=$hin{'REQUEST_BODY'}=~/restricted_col=([\d]+)/gs;
		&do_statement("DELETE FROM track_restricted_columns WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("INSERT IGNORE INTO track_restricted_columns (track_list_id,track_column_name_id)
						   SELECT $hin{'track_list_id'}, track_column_name_id FROM track_column_name
						   WHERE track_column_name_id NOT IN (".join(',',(@assigned_cols,"''")).") and is_restricted=1 ");

	}elsif(scalar(@user_errors)<1 and $hin{'track_list_id'} and $hin{'atom_delete'}){
		#cleaning up
		&do_statement("DELETE FROM track_list_lang WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("DELETE FROM track_list_editor WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("DELETE track_product_ean tpe
					   FROM track_product tp
					   JOIN track_product_ean tpe USING(track_product_id)
					   WHERE tp.track_list_id=$hin{'track_list_id'}");
		&do_statement("DELETE FROM track_product WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("DELETE FROM track_user_columns WHERE track_list_id=$hin{'track_list_id'}");
		&do_statement("DELETE FROM track_restricted_columns WHERE track_list_id=$hin{'track_list_id'}");
	}
	return 1;
}

sub  command_proc_set_track_product_rule_prod_id{
		#if($hin{'rule_prod_id'} or $hin{'rule_supplier_id'}){
		use track_lists;
		my $prev_params=&do_query('SELECT supplier_id,is_reverse_rule,rule_prod_id,map_prod_id
								   FROM track_product WHERE track_product_id='.$hin{'track_product_id'})->[0];
		if(!$prev_params->[0] and !$hin{'supplier_id'} and $hin{'rule_prod_id'}){
			&lp('command_proc_set_track_product_rule_prod_id: Nothing chnages');
			return '';
		}								   
		$prev_params->[0]='' if !$prev_params->[0];
		$prev_params->[1]='' if !$prev_params->[1];
		$hin{'rule_prod_id'}=&trim($hin{'rule_prod_id'});		
		if($prev_params->[0] ne $hin{'supplier_id'} or $prev_params->[1] ne $hin{'reverse_rule'} or $prev_params->[2] ne $hin{'rule_prod_id'}){
			my $product_id_sql;
			# if we have supplier changed and rule partcode was not changed 
			# try to find the new product. If rule partcode was changed when wait untill somebody applies the rule unless entrusted user inputs  partcode
			my $trusted_user;
			if(&do_query('SELECT 1 FROM track_list_entrusted_users WHERE user_id='.$USER->{'user_id'})->[0][0]){
				$trusted_user='Yes';
			}
			my $product_id;
			if($trusted_user and $hin{'rule_prod_id'}){
				$product_id=&do_query('SELECT product_id FROM product WHERE 
										prod_id='.&str_sqlize($hin{'rule_prod_id'}).
										' AND supplier_id='.(($hin{'supplier_id'})?$hin{'supplier_id'}:$prev_params->[0]))->[0][0];				
			}elsif($prev_params->[0] ne $hin{'supplier_id'} and $hin{'supplier_id'} and (!$hin{'rule_prod_id'} or $hin{'rule_prod_id'} eq $prev_params->[2])){
				$product_id=&do_query('SELECT product_id FROM product WHERE 
										prod_id='.&str_sqlize($prev_params->[3]).
										' AND supplier_id='.$hin{'supplier_id'})->[0][0];				
			}
			if($product_id){
				$product_id_sql=' product_id = '.$product_id.', ';					 					
				if($trusted_user and $hin{'rule_prod_id'}){
					$product_id_sql.=' map_prod_id='.&str_sqlize($hin{'rule_prod_id'}).', ';				
				}
			}
			&do_statement("UPDATE track_product
					   SET rule_prod_id=".&str_sqlize($hin{'rule_prod_id'}).",
					   	   supplier_id=".(($hin{'supplier_id'})?$hin{'supplier_id'}:'0').",					   	   
					   	   is_reverse_rule=".(($hin{'reverse_rule'})?'1':'0').",
					   	   remarks=".(($hin{'rule_prod_id'})?&str_sqlize('correct code is '.$hin{'rule_prod_id'}):"''").",
					   	   rule_user_id=$USER->{'user_id'},
					   	   rule_status=0,
					   	   changer=$USER->{'user_id'},
					   	   $product_id_sql
					   	   changer_action='".(($hin{'rule_prod_id'})?'Changes mapping':'Removes mapping')."'
					   WHERE track_product_id=".$hin{'track_product_id'});
			add_track_product_rule($hin{'track_product_id'}) if $trusted_user and $hin{'rule_prod_id'};					   
		}else{
			&lp('command_proc_set_track_product_rule_prod_id: Nothing chnages');
		}
		#}

}

sub  command_proc_get_track_list_report{
	use Spreadsheet::WriteExcel::Big;
	use Time::Piece;
	open my $fh, '>', \my $xls;
	my $workbook=Spreadsheet::WriteExcel::Big->new($fh);
	my $header_format = $workbook->add_format(size => 12,bold=>1);
	my $red_format = $workbook->add_format(size => 10,bold=>0,bg_color=>'red',indent=>3);
	my $green_format = $workbook->add_format(size => 10,bold=>0,bg_color=>'green',indent=>3);

	my $default_format= $workbook->add_format(size => 10,bold=>0);
	my $time=Time::Piece->new(&do_query('SELECT unix_timestamp()')->[0][0]);
	my $worksheet=$workbook->add_worksheet("Report on Track_list");
	my $header=["File's\nsupplier","Files's\nPart code","Files's\nEANs","File's\nName",
					"ICEcat\nSupplier","ICEcat\nPart code","Editor\nRemarks","Editor"];
	$worksheet->write_row('A1',$header);
	if($hin{'track_list_id'}){
		my $rows=&do_query("SELECT feed_supplier,feed_prod_id,
				(SELECT group_concat(ean separator ',') as eans_joined FROM track_product_ean te WHERE te.track_product_id=tp.track_product_id GROUP BY tp.track_product_id),
				tp.name,
				s.name,
				p.prod_id,
				IF(tp.remarks='' and tp.rule_prod_id!='' and tp.feed_prod_id!='' and tp.is_parked=0,CONCAT('correct code is ',tp.rule_prod_id),tp.remarks),
				u.login, tp.extr_quality,tp.is_parked ".
				#"
				#extr_langs      = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id GROUP BY pd.product_id),
				#extr_pdf_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.pdf_url!='' GROUP BY pd.product_id),
				#extr_man_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.manual_pdf_url!='' GROUP BY pd.product_id),
				#extr_rel_count  = (SELECT count(pr.product_related_id) FROM product_related pr WHERE pr.product_id=p.product_id),
				#extr_feat_count = (SELECT count(pf.product_feature_id) FROM product_feature pf WHERE pf.product_id=p.product_id),
				#extr_quality    = (IF(u.user_group='category_manager' or u.user_group='editor' or u.user_group='supereditor' or u.user_group='superuser','editor',IF(u.user_group='supplier','supplier','nobody'))),
				#extr_ean        = pe.ean_code,
				#track_product_status = (IF(tp.is_parked=1,'parked',IF(u.user_group='editor','described','not_described')))
				#".
				"FROM track_product tp
				LEFT JOIN product p ON p.product_id=tp.product_id
				LEFT JOIN supplier s ON s.supplier_id=tp.supplier_id
				LEFT JOIN users u ON p.user_id=u.user_id ".
				#"
				#LEFT JOIN product_ean_codes pe ON pe.product_id=p.product_id
				#".
				"
				WHERE tp.track_list_id=".$hin{'track_list_id'}.' ORDER BY tp.product_id DESC');# GROUP BY tp.track_product_id


		$worksheet->set_row(0, 15, $header_format);
		$worksheet->set_column(0, 5, 20, $default_format);
		for(my $i=0;$i<scalar(@$rows);$i++){
			for(my $j=0;$j<scalar(@$header);$j++){
				if($rows->[$i][8] eq 'icecat'){
					$worksheet->write_string($i+1,$j,$rows->[$i][$j],$green_format);
				}elsif($rows->[$i][9]){
					$worksheet->write_string($i+1,$j,$rows->[$i][$j],$red_format);
				}else{
					$worksheet->write_string($i+1,$j,$rows->[$i][$j]);
				}
			}
		}
	}
	$workbook->close();
	return $xls;
}

sub command_proc_save_user_track_list_cols{
	# PROCESS ASSIGNED COLUMNS
	my @assigned_cols=$hin{'REQUEST_BODY'}=~/user_column_choice=([\d]+)/gs;
	&log_printf(Dumper(\@assigned_cols));
	&do_statement("DELETE FROM  track_user_columns WHERE track_list_id=$hin{'track_list_id'}");
	&do_statement("INSERT IGNORE INTO  track_user_columns (track_list_id,user_id,track_column_name_id)
				   SELECT $hin{'track_list_id'},$USER->{'user_id'}, tc.track_column_name_id FROM track_column_name tc
				   LEFT JOIN track_restricted_columns trc ON trc.track_column_name_id=tc.track_column_name_id AND trc.track_list_id=$hin{'track_list_id'}
				   WHERE tc.track_column_name_id NOT IN (".join(',',(@assigned_cols,"''")).") AND trc.track_column_name_id is NULL");
}

sub command_proc_update_virtual_categories_for_product {
    # this subroutine is a wrapper for 'update_virtual_categories_for_certain_product'
    my $pid = $hin{'product_id'};
    update_virtual_categories_for_certain_product($pid);
    return 1;
}

sub command_proc_update_family_for_product {

    my $product_id = $hin{'product_id'};
    my $family_id = $hin{'flist'};

    my $req = "UPDATE product SET family_id = $family_id WHERE product_id = $product_id";
    if (($family_id) && ($product_id)) {
        do_statement($req);
    }
    else {
        # log_printf("Unable to execute : $req");
    }

    return 1;
}

sub command_proc_update_default_warranty_info {

    my $catid = $hin{'catid'};
    my $supplier_id = $hin{'supplier_id'};

    my @langs = ();
    for (keys %hin) {
        if (/^w_text_(\d+)$/) {
            push @langs, $1;
            # log_printf($hin{'w_text_' . $1});
        }
    }

    for my $l (@langs) {

        # if exists
        my $is_present = do_query("
            SELECT default_warranty_info_id FROM default_warranty_info
            WHERE catid = $catid AND supplier_id = $supplier_id AND langid = $l
        ")->[0]->[0];

        if ($is_present) {
            do_statement("
                UPDATE default_warranty_info
                SET warranty_info = " . str_sqlize($hin{'w_text_' . $l}) . "
                WHERE catid = $catid AND supplier_id = $supplier_id AND langid = $l
            ");
        }
        else {
            do_statement("
                INSERT INTO default_warranty_info (catid, supplier_id, langid, warranty_info)
                VALUES ($catid, $supplier_id, $l, " . str_sqlize($hin{'w_text_' . $l}) . ")
            ");
        }
    }
    return 1;
}

sub command_proc_delete_default_warranty_info {

    my $catid = $hin{'catid'};
    my $supplier_id = $hin{'supplier_id'};

    do_statement("
        DELETE FROM default_warranty_info
        WHERE catid = $catid AND supplier_id = $supplier_id
    ");

    return 1;
}

sub command_proc_insert_default_warranty_info {

    my $catid = $hin{'add_catid'};
    my $supplier_id = $hin{'add_supplier_id'};
    my $txt = $hin{'w_text_new'};

    do_statement("
        INSERT INTO default_warranty_info (catid, supplier_id, langid, warranty_info)
        VALUES ($catid, $supplier_id, 1, " . str_sqlize($txt). ")
    ");

    return 1;
}

sub command_proc_save_values_for_history_product {
    my $product_id = $hin{'product_id'};
    
    return 0 unless $product_id;
    
    # 'product' table
    
    my $ans = do_query("
        SELECT supplier_id, prod_id, catid, user_id, name, low_pic, high_pic, publish, public, thumb_pic, family_id
        FROM product
        WHERE product_id = $product_id
    ");
    $hin{'prev_product'} = $ans;

    # 'product_name' table

    my $name_ans = do_query("
        SELECT name, langid
        FROM product_name
        WHERE product_id = $product_id
    ");
    $hin{'prev_product_name'} = $name_ans;

    return 1;
}

sub command_proc_save_values_for_history_product_description {

    my $pd_id = $hin{'product_description_id'};
    my $ans = do_query("
        SELECT langid, short_desc, long_desc, official_url, warranty_info, pdf_url, manual_pdf_url
        FROM product_description
        WHERE product_description_id = $pd_id
    ");
    $hin{'prev_product_description'} = $ans;

    update_pdf_origin_info_for_product_description($pd_id);

    return 1;
}

sub command_proc_save_values_for_history_product_multimedia_object {

    my $id = $hin{'object_id'};
    my $ans = do_query("
        SELECT short_descr, langid, content_type, keep_as_url, type, link
        FROM product_multimedia_object
        WHERE id = $id
    ");
    $hin{'prev_product_multimedia_object'} = $ans;

    return 1;
}

sub command_proc_save_values_for_history_product_feature {

    my $product_id = $hin{'product_id'};

    my $ans = do_query("
        SELECT category_feature_id, value
        FROM product_feature
        WHERE product_id = $product_id
    ");
    $hin{'prev_feature_values'} = $ans;

    return 1;
}

sub command_proc_save_values_for_history_product_feature_local {

    my $product_id = $hin{'product_id'};
    my $langid = 0;

    # get langid
    for (keys %hin) {
        if (/^(\d+)tab_\1_/) {
            $langid = $1;
            last;
        }
    }

    my $ans = do_query("
        SELECT category_feature_id, value
        FROM product_feature_local
        WHERE product_id = $product_id AND langid = $langid
    ");

    $hin{'prev_feature_local_values'} = $ans;
    $hin{'prev_feature_local_language'} = $langid;

    return 1;
}

sub command_proc_update_remote_distributor {

    my $distri_code = $hin{'code'};

    my $local_visible = $hin{'visible'};

    my %countries;
    my $countries = do_query("SELECT country_id, code FROM country");
    for (@$countries) {
        $countries{$_->[0]} = $_->[1];
    }
    my $local_country_id = $countries{ $hin{'country_id'} };

    log_printf("==================================");
    log_printf($distri_code);
    log_printf($local_country_id);
    log_printf($local_visible);

    log_printf("--- sync for : " . $distri_code );
    my $soap = SOAP::Lite->service($atomcfg{'soap_url'});
    my $res_up = $soap->updateDistriInfoForICEcat( $distri_code , $local_country_id , $local_visible );
    # result message to log
    log_printf($res_up);



    if ($res_up =~ /success/) {
        log_printf("SOAP update success");
        do_statement("UPDATE distributor SET sync = 1 WHERE code = " . atomsql::str_sqlize($distri_code) );
        $hin{'soap_error'} = '';
    }
    else {
        log_printf("SOAP update failed");
        do_statement("UPDATE distributor SET sync = 0 WHERE code = " . atomsql::str_sqlize($distri_code) );
        $hin{'soap_error'} = $res_up;
    }
    log_printf("==================================");

    return 1;
}

sub command_proc_store_pics_origin {
    # prepare 'high_pic_origin'
    my $host = $atomcfg{'images_host'};
    my $product_id = $hin{'product_id'};
    
    return 0 unless $product_id;

	my $ans = do_query("
	    SELECT high_pic_origin
	    FROM product
	    WHERE product_id = $product_id
	");

	$hin{'high_pic_origin'} = $ans->[0]->[0];

	if ($hin{'high_pic'} !~ /^${host}/ ) {
	    # overwrite value from DB
	    if ($hin{'high_pic'}) {
        	$hin{'high_pic_origin'} = $hin{'high_pic'};
        }
    }

    return 1;
}

sub command_proc_store_pics_origin_mmo {

	# there is no record in 'product_multimedia_object' yet, so we just only
    # save value

	$hin{'obj_origin'} = $hin{'object_url'};

	# log_printf("------------------------------- STORED MMO ");
    # log_printf($hin{'object_url'});
    # log_printf("-------------------------------");

    return 1;
}

sub command_proc_store_pics_origin_mmo_update {

    my $host = $atomcfg{'images_host'};
    my $product_id = $hin{'product_id'};
    my $origin = $hin{'obj_origin'};

    # present during 'update' operation only
    my $obj_id = $hin{'object_id'};

    if ($origin =~ /^${host}/ ) {
        log_printf("No update for MMO origin : Local URL");
        return 1;
    }

    # log_printf("------------------------------- UPDATE ");
    # log_printf($origin);
    # log_printf($obj_id);
    # log_printf(Dumper(\%hin));
    # log_printf("-------------------------------");

    # for 'update' MMO
	if ($obj_id) {
	    do_statement("
	        UPDATE product_multimedia_object
    	    SET link_origin = " . str_sqlize($origin) . "
	        WHERE id = $obj_id
    	");
    }

    # for 'insert' MMO
    if ( ($origin !~ /^${host}/ ) and ($hin{'atom_submit'} eq 'Add object' ) ) {

        my $max_mmo_id = do_query("
            SELECT MAX(id)
	        FROM product_multimedia_object
	        WHERE product_id = $product_id
	    ")->[0]->[0];
        do_statement("
	        UPDATE product_multimedia_object
    	    SET link_origin = " . str_sqlize($origin) . "
	        WHERE id = $max_mmo_id
    	");
    }

    return 1;
}

sub command_proc_store_pics_origin_gallery {

    # there is no record in 'product_gallery' yet, so we just only
    # save value

    $hin{'pic_origin'} = $hin{'gallery_pic'};

    return 1;
}

sub command_proc_store_pics_origin_gallery_update {

    my $host = $atomcfg{'images_host'};
    my $product_id = $hin{'product_id'};
    my $origin = $hin{'pic_origin'};

    # get image id
    # we can use MAX(id) function because we always insert new records (no updates)
    my $id = do_query("
        SELECT MAX(id)
        FROM product_gallery
        WHERE product_id = $product_id
    ")->[0]->[0];

	if ( ($origin !~ /^${host}/ ) and ($id) ) {
	    do_statement("
	        UPDATE product_gallery
    	    SET link_origin = " . str_sqlize($origin) . "
	        WHERE id = $id
    	");
    }
    return 1;
}

sub command_proc_remove_stat_report{
	my $report_id=$hin{'report_bg_processes_id'};
	return undef if $report_id!~/^[\d]+$/;
	my $ps_strs=`ps aux | grep  'do_generate_stat_report_and_mail_it $report_id'`;
	my @ps_arr=split("\n",$ps_strs);
	my $result_ps_str;
	for my $ps_str (@ps_arr){
		if($ps_str!~/grep/ and $ps_strs=~/do_generate_stat_report_and_mail_it/){
			$result_ps_str=$ps_str;
		}
	}
	my @ps_res=split(' ',$result_ps_str);
	my $ps_id=$ps_res[1];

	my $connection_id=&do_query('SELECT connection_id FROM generate_report_bg_processes
								 WHERE generate_report_bg_processes_id='.$report_id)->[0][0];
	&register_slave('slave_1',$atomcfg{'dbslavehost'},$atomcfg{'dbslaveuser'},$atomcfg{'dbslavepass'});									 
	&do_statement('KILL '.$connection_id,'slave_1') if $connection_id;
	&do_statement('DELETE FROM generate_report_bg_processes WHERE generate_report_bg_processes_id='.$report_id);
	&log_printf('--------->>>>>>>>>command_proc_remove_stat_report :'."kill -9 $ps_id");
	if($ps_id and $ps_id!~/[0\.]+/){
		`kill -9 $ps_id`;
	}
	unlink($atomcfg{'session_path'}.$ps_id.'_working');
	return 1;
}

sub command_proc_set_track_product_pair{
	my $product_id=&do_query('SELECT product_id from product WHERE prod_id='.&str_sqlize($hin{'manual_map_prod_id'}).' and supplier_id='.$hin{'manual_supplier_id'})->[0][0];
	return '' if(!$product_id);
	my $prev_params=&do_query('SELECT map_prod_id,supplier_id,product_id FROM track_product WHERE track_product_id='.$hin{'search_track_product_id'})->[0];
	if($prev_params->[0] ne $hin{'manual_map_prod_id'} or $prev_params->[1] ne $hin{'manual_supplier_id'} or $prev_params->[2] ne $product_id){
		&do_statement('UPDATE track_product SET map_prod_id='.&str_sqlize($hin{'manual_map_prod_id'}).',
											supplier_id='.$hin{'manual_supplier_id'}.',
											product_id='.$product_id.',
											changer='.$USER->{'user_id'}.',
				   							changer_action=\'Changes mapping manually\'
					   WHERE track_product_id='.$hin{'search_track_product_id'});
	}
	return 1;
}


# store and update PDF origin
sub update_pdf_origin_info_for_product_description {

    my $pd_id = shift;

    my $host = $atomcfg{'pdfs_host'};

    my $pdf_url_origin = $hin{'pdf_url'};
    my $manual_pdf_url_origin = $hin{'manual_pdf_url'};

    # log_printf('------------------------------------------------------------ from HIN');
    # log_printf($pdf_url_origin);
    # log_printf($manual_pdf_url_origin);
    # log_printf('------------------------------------------------------------');

    if ( ($pdf_url_origin) and ($pdf_url_origin !~ /^${host}/ ) and ($pd_id) ) {
        do_statement("
            UPDATE product_description
            SET pdf_url_origin = " . str_sqlize($pdf_url_origin) . "
            WHERE product_description_id = $pd_id
        ");
        # log_printf('================== NEW PDF =======================');
        # log_printf($pdf_url_origin);
        # log_printf($pd_id);
        # log_printf('================== NEW PDF =======================');
    }

    if ( ($manual_pdf_url_origin) and ($manual_pdf_url_origin !~ /^${host}/ ) and ($pd_id) ) {
        do_statement("
            UPDATE product_description
            SET manual_pdf_url_origin = " . str_sqlize($manual_pdf_url_origin) . "
            WHERE product_description_id = $pd_id
        ");
        # log_printf('================== NEW MANUAL PDF =======================');
        # log_printf($manual_pdf_url_origin);
        # log_printf($pd_id);
        # log_printf('================== NEW MANUAL PDF =======================');
    }

    return 1;
}

sub command_proc_update_pdf_origin_for_new_product_description {

    my $pd_id = $hin{'product_description_id'};
    update_pdf_origin_info_for_product_description($pd_id);

    return 1;
}

sub command_proc_add_new_product_restrictions {

    my $lang = $hin{'new_langid'};
    my $access = $hin{'new_subscription_level'};
    my $supplier = $hin{'new_supplier_id'};

    # try to found same restriction
    my $is_present = do_query("
        SELECT 1
        FROM product_restrictions
        WHERE supplier_id = $supplier AND langid = $lang
    ")->[0]->[0];

    if ($is_present) {
        push @user_errors, "Restriction for selected 'Brand' and 'Language' pair already has been inserted";
        return 1;
    }

    # add restriction
    do_statement("
        INSERT INTO product_restrictions (supplier_id, langid, subscription_level)
        VALUES ($supplier, $lang, $access)
    ");
    my $rest_id = do_query('SELECT LAST_INSERT_ID()')->[0]->[0];

    my $txt = $hin{'text_new'};
    my $res = get_product_id_list_from_raw_batch($txt, 0);
    my $pids = $res->[0];

    # add restriction details
    for my $id (@$pids) {
        do_statement("
            INSERT INTO product_restrictions_details (restriction_id, product_id)
            VALUE ($rest_id, $id)
        ");
    }

    return 1;
}

sub command_proc_delete_existed_product_restrictions {

    my $id = $hin{'rest_id'};
    do_statement("DELETE FROM product_restrictions WHERE id = $id");
    do_statement("DELETE FROM product_restrictions_details WHERE restriction_id = $id ");
    return 1;
}

sub command_proc_delete_certain_product_restriction {

    my $id = $hin{'r_id'};
    do_statement("
        DELETE FROM product_restrictions_details WHERE id = $id
    ");
    return 1;
}

sub command_proc_update_certain_product_restriction {

    my $rest_id = $hin{'restriction_id'};
    my $txt = $hin{'text_new'};

    my $res = get_product_id_list_from_raw_batch($txt, 0);
    my $pids = $res->[0];

    # put pids into hash
    my %p;
    for my $id (@$pids) {
        $p{$id} = 1;
    }

    # get existed
    my $existed = do_query("
        SELECT product_id
        FROM product_restrictions_details
        WHERE restriction_id = $rest_id
    ");

    # delete already existed from hash
    for my $id_ref (@$existed) {
        if ($p{$id_ref->[0]}) {
            delete $p{$id_ref->[0]};
        }
    }

    # bulk insert
    my $c = 0;
    for my $id (keys %p) {
        do_statement("
            INSERT INTO product_restrictions_details (restriction_id, product_id)
            VALUE ($rest_id, $id)
        ");
        $c++;
    }

    return 1;
}

sub command_proc_save_backup_languages {
    my $backup_list = [split /\x{0}/, $hin{'backup_langid'}];
    my $langs = do_query("SELECT langid FROM language ORDER BY 1");
    my $backup_hash = {};
    my $i = 0;
    for (@$langs) {
    	unless ($backup_list->[$i]) {
    	    $backup_hash->{$_->[0]} = 'NULL';
    	}
    	else {
    	    $backup_hash->{$_->[0]} = $backup_list->[$i];
    	}
    	$i++;
    }
    for (keys %$backup_hash) {
    	my $backup_id = do_query("SELECT backup_langid FROM language WHERE langid = $_")->[0]->[0];
    	$backup_id = 'NULL' unless ($backup_id);
    	unless ($backup_id == $backup_hash->{$_}) {
    	    do_statement("UPDATE language SET backup_langid = $backup_hash->{$_} WHERE langid = $_");
    	}
    }
    return 0;
}

sub command_proc_series {
	if (
	    $hin{'atom_delete'} and
	    $hin{'exchange_series'} and
	    $hin{'series_id'}
	) {
		do_statement("UPDATE product SET series_id=$hin{'exchange_series'} WHERE series_id=$hin{'series_id'}");
	}
	return 1;
}

1;

package atom_store;

#$Id: atom_store.pm 3605 2010-12-21 14:46:37Z alexey $

use strict;
use atom_html;
use atomlog;
use atom_util;
use atom_misc;
use atomcfg;
use atomsql;
use atom_util;
use thumbnail;
use icecat_util;
use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw( &store_as_checkbox
								&store_as_date
								
								&store_as_fake_user_id
								
								&store_as_low_pic_uploaded
								&store_as_high_pic_uploaded
								
								&store_as_publish
								&store_as_public
								&store_as_prod_id
								
								&store_as_textarea
								&store_as_cat_feat_group_id
								
								&store_as_clean_textarea
								&store_as_pdf_uploaded
								&store_as_manual_pdf_uploaded
								&store_as_user_reference
								&store_as_family_pic_uploaded
								&store_as_supplier_pic_uploaded																	
								&store_as_dispatch_attachment_uploaded
								&store_as_gallery_pic_uploaded
								&store_as_object_url_uploaded
								&store_as_campaign_gallery_pic_uploaded
								&store_as_get_date
								&store_as_user_partner_id
								&store_as_feature_values
								&store_as_feature_value
								
								&store_as_list_of_templates
                &store_as_folder_name

								&store_as_feature_power_mapping
								&store_as_measure_power_mapping

								&store_as_related_prod_id

								&store_as_generic_operation_set_code

								&store_as_force_HP_products_update
								
								&store_as_logo_pic_uploaded
								&store_as_delete_also_category_feature
								&store_as_delete_also_category_feature_groups

								&store_as_date_three_dropdowns
								&store_as_multiselect

								&store_as_category_nestedset
								&store_as_supplier
								&store_as_escape
								&store_as_ready_feed
								&store_as_track_list_feed
								&store_as_unixdate_three_dropdowns
								&store_as_pricelist_feed
								&store_as_dictionary_code
								&store_as_ean_code
							 );
}

sub store_as_ean_code{
	my ($call,$field,$value) = @_;
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and  scalar(@user_errors)<1 and length($value)<13){
		for(my $i=length($value); $i<13; $i++){
			$value='0'.$value;
		}
		return $value;
	}else{
		return $value;		
	}		
} 

sub store_as_dictionary_code{
	my ($call,$field,$value) = @_;
	
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and  scalar(@user_errors)<1){
		my $tmp_name=$hin{'name'};
		$tmp_name=~s/[^\w\d]/_/gs;
		$tmp_name=~s/[_]+/_/gs;
		my $code_check=do_query("SELECT 1 FROM dictionary where code ='$tmp_name'".
					  ($hin{'atom_update'}?" and dictionary_id!=$hin{'dictionary_id'}":''))->[0][0];
		if($code_check){
			push(@user_errors,'This code "'.$tmp_name.'" already exists. Please change the name to change the code');
			return ''
		}else{					  
			return $tmp_name;
		}
	}	
}
sub store_as_unixdate_three_dropdowns{
	my ($call,$field,$value) = @_;
	my $choicendate=eval{Time::Piece->strptime($hin{$field.'_year'}.'-'.$hin{$field.'_month'}.'-'.$hin{$field.'_day'},'%Y-%m-%d')};
	if($choicendate){
		return $choicendate->epoch;
	}else{
		return 0;
	}
	
}

sub store_as_track_list_feed{
	my ($call,$field,$value) = @_;
	#if user submit a feed we should save it from being removed   
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and $hin{'feed_config_id'} and scalar(@user_errors)<1){
		my $tmp_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/';
		my $ready_dir=$atomcfg{"base_dir"}.'track_lists/'.$hin{'feed_config_id'};
		`rm -R $ready_dir` if -d $ready_dir;
		`mkdir $ready_dir`;
		`cp -R $tmp_dir* $ready_dir`;
		`chmod 777 -R $ready_dir`;
	}
	return $value;
}

sub store_as_pricelist_feed{
	my ($call,$field,$value) = @_;
	#if user submit a feed we should save it from being removed   
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and $hin{'feed_config_id'} and scalar(@user_errors)<1){
		my $tmp_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/';
		my $ready_dir=$atomcfg{"base_dir"}.'pricelists/'.$hin{'feed_config_id'};
		`rm -R $ready_dir` if -d $ready_dir;
		`mkdir $ready_dir`;
		`cp -R $tmp_dir* $ready_dir`;
		`chmod 777 -R $ready_dir`;
	}
	return $value;
}

sub store_as_ready_feed{
	my ($call,$field,$value) = @_;
	#if user submit a feed we should save it from being removed   
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and $hin{'feed_config_id'} and scalar(@user_errors)<1){
		my $tmp_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/';
		my $ready_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'__ready__/';
		`rm -R $ready_dir` if -d $ready_dir;
		`mkdir $ready_dir`;
		`cp -R $tmp_dir* $ready_dir`;
		`chmod 777 -R $ready_dir`;
	}
}


sub store_as_escape{
	my ($call,$field,$value) = @_;
	if($value eq '\\'){
		return '\\\\';
	}else{
		return $value;
	}
}

sub store_as_supplier {
	my ($call,$field,$supplier_name) = @_;

	return $supplier_name if $hin{'user_group'} !~ /super/;

	if (
		((scalar(@user_errors) < 1) && (scalar(@errors) < 1) && ($hin{'atom_update'}) ||
		 $hin{'atom_submit'})
		) {
		my $deleted_maps = do_query("SELECT ds.symbol, s_ds.name
									FROM supplier s
									JOIN data_source_supplier_map ds ON s.name = ds.symbol
									JOIN supplier s_ds ON ds.supplier_id = s_ds.supplier_id
									WHERE ds.data_source_id = 1 AND
										  ds.supplier_id != s.supplier_id AND
										  s.supplier_id != 0 AND s.name != '#Delete'");
		if ($deleted_maps and scalar(@$deleted_maps) >= 1) {
			my $mappings_html = '<div>';
			for my $map (@$deleted_maps) {
				$mappings_html .= '<div style="font-weight:bold"><span style="font-weight:normal">' . $map->[0] . "</span>&nbsp;-&gt;&nbsp;" . $map->[1] . '</div>';
			}
			$mappings_html .= '</div>';
			push @user_warnings, '<div style="width:400px">Following mappings are redundant and should be removed:</div>
								<span style="display:none" id="redundant_mapings_id">'.$mappings_html.'</span>
								<span><a href="#" onclick="display_redundant_mappings(this,0)">show mappings</a></span>';
		}
	}
	
	return $supplier_name;
}

sub store_as_category_nestedset {
	my ($call,$field,$value) = @_;

	use atom_commands;

	command_proc_recreate_category_nestedset();

	return $value;
} # sub store_as_category_nestedset

sub store_as_multiselect {
	my ($call,$field,$value) = @_;

	log_printf("value = ".Dumper($value));

	$value =~ s/\x00/,/gs;

	# check for 0
	my @selects = split ',', $value;
	my %hsel = map { $_ => 1 } @selects;

	$value = 0 if ($hsel{0});

	return $value;
} # sub store_as_date_three_dropdowns

sub store_as_date_three_dropdowns {
	my ($call,$field,$value) = @_;

	return 0 if (!$hin{$field."_year"} || !$hin{$field."_month"} || !$hin{$field."_day"});
	return Array2Epoch($hin{$field."_year"},$hin{$field."_month"},$hin{$field."_day"});
} # sub store_as_date_three_dropdowns

sub store_as_delete_also_category_and_product_feature {
	my ($call,$field,$value) = @_;
	
	if ($hin{'atom_delete'} && $value) {
		do_statement("delete from category_feature where feature_id=".$value);
#		do_statement("delete pf from product_feature pf left join category_feature cf on pf.category_feature_id=cf.category_feature_id where cf.category_feature_id is null");
#		do_statement("delete pfl from product_feature_local pfl left join category_feature cf on pfl.category_feature_id=cf.category_feature_id where cf.category_feature_id is null");
	}

	return $value;
} # sub store_as_delete_also_category_and_product_feature

sub store_as_delete_also_category_feature_groups {
	my ($call,$field,$value) = @_;

	if ($hin{'atom_delete'} && $value) {
		do_statement("delete from category_feature_group where feature_group_id=".$value);
	}

	return $value;
} # sub store_as_delete_also_category_feature_groups

sub store_as_force_HP_products_update {
	my ($call,$field,$value) = @_;

	return $value unless ($hin{'data_source_id'});
	return $value unless (do_query("select data_source_id from data_source where data_source_id=".$hin{'data_source_id'}." and code='HPProvisioner'")->[0][0]);
	return $value unless ($hin{'data_source_feature_map_id'});

	my $old_value = do_query("select only_product_values from data_source_feature_map where data_source_feature_map_id=".$hin{'data_source_feature_map_id'});

	my $hp_id;

	if ($old_value ne $value) {
		$hp_id = do_query("select supplier_id from supplier where name='HP'")->[0][0];
		if ($hp_id) {
			do_statement("insert ignore into features_to_reupdate(feature_id,supplier_id) values (".$hin{'feature_id'}.",".$hp_id.")");
		}
	}

	return $value;
} # sub store_as_force_HP_products_update

sub store_as_generic_operation_set_code {
	my ($call,$field,$value) = @_;

	return string2fat_name($hin{'name'});
} # sub store_as_generic_operation_set_code

sub store_as_user_partner_id
{
 my ($call,$field,$value) = @_;
 if($hin{'user_group'} ne 'shop'){ $value = 0; }
 return $value;
}

sub store_as_feature_value
{
  my ($call,$field,$value) = @_;
	my $lang = do_query("select langid from language");
	for my $langid(@$lang){
		$hin{$field.'_'.$langid->[0]} =~ s/\s+/ /g;
		$hin{$field.'_'.$langid->[0]} =~ s/(^\s)|(\s$)//;
	}
	my $en = $hin{$field.'_1'};
	if($en ne ''){
		$hin{'key_value'}=$en;
  	return undef;
	}else{
		my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
		push @user_errors, repl_ph($error, {'name'=>'English value'});
    atom_cust::proc_custom_processing_errors;
	}
}

sub store_as_feature_values
{
  my ($call,$field,$value) = @_;

  $value =~s/(\r)|(\t)//g;
  my @lines = split("\n",$value);
  my @values;
  for $value(@lines){
    $value =~s/\s+/ /g;
    $value =~s/(^\s)|(\s$)//g;
    if($value ne ''){
			push @values, $value;
			if($hin{'autoinsert'}){
				my $keyval = str_sqlize($value);
				my $key = do_query("select key_value from feature_values_vocabulary where langid=1 and key_value=$keyval")->[0][0];
				if(!$key){
					my $tmp_keyval=$keyval;
					$tmp_keyval=~s/\.,//gs;
					next if $tmp_keyval=~/[\d]+/ and $tmp_keyval!~/\s/;					  
					insert_rows('feature_values_vocabulary',{'key_value'=>$keyval,'langid'=>1,'value'=>$keyval});
					my $lang = do_query("select langid from language where langid!=1");
					for my $langid(@$lang){
						insert_rows('feature_values_vocabulary',{'key_value'=>$keyval,'langid'=>$langid->[0]});
					}
				}
			}
		}
  }
  $value = join("\n",@values);
  return $value;
}

sub store_as_clean_textarea
{
  my ($call,$field,$value) = @_;
	
	$value =~s/\r//g;
	
	return $value;
}

sub store_as_cat_feat_group_id
{
  my ($call,$field,$value) = @_;
	 
	 log_printf("checking connection of catid=$hin{'catid'} to feature_id=$value");
	 my $cat_feat_group_id =  maintain_category_feature_group(int($value), $hin{'catid'});
	 return $cat_feat_group_id;
}

sub store_as_textarea
{
 my ($call,$field,$value) = @_;
 
 $value =~s/\n/<BR>/gi;
 
 return $value;
}

sub store_as_prod_id {
	my ($call,$field,$value) = @_;

	$value = uc $value;

	# OLD SOLUTIONS!..
	
#	my $product_id = $hin{'product_id'};
#	my ($o_prod_id, $o_supplier_id);
#	my $data_ref = do_query("select prod_id, supplier_id from product where product_id = ".str_sqlize($product_id));
	
#	$o_prod_id = $data_ref->[0][0];
#	$o_supplier_id = $data_ref->[0][1];
	
#	if ($o_prod_id eq $hin{'prod_id'} && $o_supplier_id eq $hin{'supplier_id'}) {
		# nothing to do
#	}
#	else {
		# updating requests table
		# removing old records
		# update_rows("request_product", " rprod_id = ".str_sqlize($o_prod_id)." and rsupplier_id = ".str_sqlize($o_supplier_id),
		#						 {
		#							 "product_found" => 0,
		#						 });
		
		# adding new one
		# update_rows("request_product", " rprod_id = ".str_sqlize($hin{'prod_id'})." and rsupplier_id = ".str_sqlize($hin{'supplier_id'}),
		#						 {
		#							 "product_found" => 1,
		#						 });
#	}
	
	return $value;
}

sub store_as_publish {
	my ($call,$field,$value) = @_;
	
	if ($USER->{'user_group'} ne 'superuser' ) {
		if ($call->{'call_params'}->{'product_id'}) {
			$value = do_query("select publish from product where product_id = ".$call->{'call_params'}->{'product_id'})->[0][0];
		}
		else {
			$value = 'Y';
		}
	} 

	return $value;
} # sub store_as_publish

sub store_as_public {
	my ($call,$field,$value) = @_;
	
	if ($USER->{'user_group'} ne 'superuser' ) {
		if ($call->{'call_params'}->{'product_id'}) {
			$value = do_query("select public from product where product_id = ".$call->{'call_params'}->{'product_id'})->[0][0];
		}
		else {
			$value = 'Y';
		}
	} 
	
	return $value;
} # sub store_as_public

sub store_as_user_reference
{
 my ($call,$field,$value) = @_;
 
 if($USER->{'user_group'} ne 'superuser' ){
	 if($call->{'call_params'}->{'edit_user_id'}){
 		$value = do_query("select reference from users where user_id = ".$call->{'call_params'}->{'edit_user_id'})->[0][0];
	 } else {
	  $value = '';
	 }
 } 

 return $value;
}

sub store_as_checkbox
{
 my ($call,$field,$value) = @_;
 my $r = '';
 if($value){ $r = 'Y' }
  else { $r = 'N' }

 return $r;
}

sub store_as_date
{
 use POSIX qw (mktime);
 my ($call,$field,$value) = @_;
 
 my @a = split(/-/, $value);
 $a[2] -= 1900;
 $a[1] -= 1;
   
 $value = mktime(0,0,0,@a);
 
 return $value;
}

sub store_as_fake_user_id {
	my ($call,$field,$value) = @_;

# log_printf($value);

	my ($orig_user_id, $orig_user_group);
	if ($hin{'product_id'}) {
		$orig_user_id = do_query('select user_id from product where product_id = '.str_sqlize($hin{'product_id'}))->[0][0];
		$orig_user_group = do_query('select user_group from users where user_id = '.$orig_user_id)->[0][0];
	}

	# we do not change the user at all, if we have the same user: we, old, new
	return $value if (($value eq $USER->{'user_id'}) && ($value eq $orig_user_id));

	if ($USER->{'user_group'} ne 'superuser') {
		# for supereditors, that can change the vendor products
		if (($USER->{'user_group'} eq 'supereditor') && ($orig_user_group eq 'supplier') && ($USER->{'user_id'} eq $value)) {
			#$value = $USER->{'user_id'};
		}

		# for all others
		elsif (defined $orig_user_id) {
			if ($orig_user_id ne '1') {
				# if the product isn't nobody and logged in user isn't superuser - leave the product owner as it was
				$value = $orig_user_id;
			}
			elsif ($orig_user_id eq '1') {
				# if the product is nobody and logged in user isn't superuser - we change the user owner to yours
				$value = $USER->{'user_id'};
			}
		}
		else {
			# if we add a new product  and logged in user isn't superuser - we change the user owner to yours
			$value = $USER->{'user_id'};
		}
	}
	
# log_printf($value);
	
	return $value;
}

sub store_as_low_pic_uploaded
{

	my ($call,$field,$value) = @_;
	
	
	 my $filename = $hin{'low_pic_filename'};
	 
	 if($filename =~m/(\..{3,4})$/){
	  my $type = $1;
		insert_rows("uploaded_image", { "referenced" => 0});
		my $id = sql_last_insert_id();
#  	system("mv",$filename,$atomcfg{"base_dir"}.'/www/img/low_pic/'.$id.$type);	 
		$value = add_image($filename,'img/low_pic/',$atomcfg::targets,$id.$type);
   }
 return $value;
}

sub store_as_pdf_uploaded {
	my ($call,$field,$value) = @_;

	my $cmd;

	my $filename = $hin{'pdf_url_filename'};
	
	if ($filename =~m/(\..{3,4})$/) {
	  my $type = $1;
		my $fake_product_description_id = $hin{'product_id'}."-".$hin{'edit_langid'};
		$cmd = '/bin/mkdir -p '.$atomcfg{"base_dir"}.'/www/pdf/';
		`$cmd`;
		$cmd = "/bin/rm -f ".$atomcfg{"base_dir"}."/www/pdf/".$fake_product_description_id.$type;
		`$cmd`;
		$cmd = "/bin/cp ".$filename." ".$atomcfg{"base_dir"}."/www/pdf/".$fake_product_description_id.$type;
  	`$cmd`;
		$value = $atomcfg{'bo_host'}.'pdf/'.$fake_product_description_id.$type;
	}

	return $value;
} # sub store_as_pdf_uploaded

sub store_as_manual_pdf_uploaded {
	my ($call,$field,$value) = @_;

	my $cmd;

	my $filename = $hin{'manual_pdf_url_filename'};
	
	if ($filename =~m/(\..{3,4})$/) {
	  my $type = $1;
		my $fake_product_description_id = $hin{'product_id'}."-".$hin{'edit_langid'};
		$cmd = '/bin/mkdir -p '.$atomcfg{"base_dir"}.'/www/pdf/';
		`$cmd`;
		$cmd = "/bin/rm -f ".$atomcfg{"base_dir"}."/www/pdf/".$fake_product_description_id."-manual".$type;
		`$cmd`;
		$cmd = "/bin/cp ".$filename." ".$atomcfg{"base_dir"}."/www/pdf/".$fake_product_description_id."-manual".$type;
  	`$cmd`;
		$value = $atomcfg{'bo_host'}.'pdf/'.$fake_product_description_id."-manual".$type;
	}
	return $value;
} # sub store_as_manual_pdf_uploaded

sub store_as_high_pic_uploaded
{

	my ($call,$field,$value) = @_;
	
	
	 my $filename = $hin{'high_pic_filename'};
	 
	 if($filename =~m/(\..{3,4})$/){
	  my $type = $1;
		insert_rows("uploaded_image", { "referenced" => 0});
		my $id = sql_last_insert_id();
#  	system("mv",$filename,$atomcfg{"base_dir"}.'/www/img/high_pic/'.$id.$type);	 
		$value = add_image($filename,'img/high_pic/',$atomcfg::targets,$id.$type);
   }
 return $value;
}

sub store_as_logo_pic_uploaded{
	my ($call,$field,$value) = @_;
	return '' if scalar(@user_errors)>1;
	
	my $filename = $hin{'logo_pic_file'};
	if($filename =~m/(\..{3,4})$/){
	  my $type = $1;
		#insert_rows("uploaded_image", { "referenced" => 0});
		#my $id = sql_last_insert_id();
		my $result=create_thumbnail($filename,'img/users/logo/',$hin{'edit_user_id'}.'_'.time(),'100','');
		$value =$result->{'link'};
		push(@user_errors,'Image cannot be processed') if!$value;
 		return $value;
    }else{
    	return $value;
    }
}

sub store_as_family_pic_uploaded {
  my ($call,$field,$value) = @_;
	
#  my $filename = $hin{'family_pic_filename'};
	
#  if ($filename =~m/(\..{3,4})$/) {
#		my $type = $1;
#		insert_rows("uploaded_image", { "referenced" => 0});
#		my $id = sql_last_insert_id();
#		system("mv",$filename,$atomcfg{"base_dir"}.'/www/img/families/'.$id.$type);
#		$value = add_image($filename,'img/families/',$atomcfg::targets,$id.$type);
#	}
  return $value;
} # sub store_as_family_pic_uploaded
																
sub store_as_supplier_pic_uploaded {

  my ($call,$field,$value) = @_;
	
  my $filename = $hin{'supplier_pic_filename'};
		 
  if ($filename =~ /(\..{3,4})$/) {
   my $type = $1;
   insert_rows("uploaded_image", { "referenced" => 0});
   my $id = sql_last_insert_id();
#	 system("mv",$filename,$atomcfg{"base_dir"}.'/www/img/supplier/'.$id.$type);
	 $value = add_image($filename,'img/supplier/',$atomcfg::targets,$id.$type);
	}
	log_printf("scp ".$value." ".$filename);
  return $value;
}

sub store_as_dispatch_attachment_uploaded {
  my ($call,$field,$value) = @_;
	
  my $filename = $hin{'dispatch_attachment_filename'};
	
  if ($filename =~ /(\..{3,4})$/) {
		$hin{'dispatch_attachment_size'} = "(".(-s $filename)." bytes)";
		my $type = $1;
		$value = $hin{'dispatch_attachment'}.$type;
		system("mv",$filename,$atomcfg{"base_dir"}.'/download/'.$value);
		$hin{'dispatch_attachment_filename'} = $atomcfg{"base_dir"}.'/download/'.$value;
	}
	if (($hin{'dispatch_attachment'} eq '') && ($hin{'file_name'})) {
		if (!($hin{'file_name'} =~ s/.+\\(.+)/$1/)) {
			$hin{'file_name'} =~ s/.+\/(.+)/$1/;
		}
		$value = $hin{'file_name'};
		$hin{'dispatch_attachment'} = $hin{'file_name'};
	}
	else {
		$hin{'dispatch_attachment'} = $value;
	}

  return $value;
}

sub store_as_gallery_pic_uploaded {
  my ($call,$field,$value) = @_;
	
#	my ($dst_link);
#
#  my $filename = $hin{'gallery_pic_filename'};
#	if (!$filename || ($filename eq '')) {
#		return 1;
#	}
#
#	log_printf("store continuing");
#
#	my $product_id = $hin{'product_id'};
#	
#  if ($filename =~ /(\..{3,4})$/) {
#		my $type = $1;
#		insert_rows("uploaded_image", { "referenced" => 0});
#		srand;
#		my $rand_index = int(rand(10000));
#		while (do_query("select id from product_gallery_reverse where link like REVERSE('%".$product_id."_".$rand_index.$type."')")->[0][0]) {
#			srand;
#			$rand_index = int(rand(10000));
#		}
#		
#		# * -> jpg
#		my $f = system("/usr/bin/convert", "-quality", "99", $filename, "jpeg:".$filename.'.jpg');		
#		if (!$f) {
#			log_printf("converted from to jpeg");
#			$filename .= '.jpg';
#		}
#		
#		my $pic_hash = get_gallery_pic_params($filename);
#		$dst_link = add_image($filename,'img/gallery/',$atomcfg::targets,$product_id.'_'.$rand_index.$type);
#		# system("mv",$filename,$atomcfg{"base_dir"}.'/www/img/gallery/'.$product_id.'_'.$rand_index.$type);
#		
#		insert_rows('product_gallery', {
#			'product_id' => $product_id,
#			'link' => str_sqlize($dst_link)
#			});
#		
#		my $thumb = thumbnailize_product_gallery({'gallery_id' => sql_last_insert_id(), 'product_id' => $product_id, 'gallery_pic' => $dst_link});
#		if (!$thumb) {
#	    push @user_errors, $atoms->{'default'}->{'errors'}->{'gallery_thumbnail'};
#	    atom_cust::proc_custom_processing_errors;
#	    delete_rows('product_gallery', "id = ".str_sqlize(sql_last_insert_id()));
#	    return 1;
#		}
#		
#		$pic_hash->{'thumb_link'} = str_sqlize($thumb);
#		update_rows("product_gallery", "id = ".sql_last_insert_id(), $pic_hash);
#		$hin{'gallery_pic'} = $dst_link;
#		
#		# to prevent loading from atom_commands
#		$hin{'store_worked'} = 1;
#	}
#
#  return $dst_link || $value;

  return $value;
} # sub store_as_gallery_pic_uploaded

sub store_as_campaign_gallery_pic_uploaded {
  my ($call,$field,$value) = @_;

	return 1 unless $hin{'campaign_id'};
	
	my ($dst_link);

  my $filename = $hin{'logo_pic_filename'};

	return 1 if (!$filename || ($filename eq ''));

	log_printf("Campaign gallery - upload from PC...");

	unless ($hin{'campaign_gallery_id'}) {
		do_statement("insert into campaign_gallery(campaign_id) values(".$hin{'campaign_id'}.")");
		$hin{'campaign_gallery_id'} = do_query("select last_insert_id()")->[0][0];		
	}
	
	my $campaign_gallery_id = $hin{'campaign_gallery_id'};
	
  if ($filename =~ /(\..{3,4})$/) {
		my $type = lc($1);

		srand;
		my $rand_index = int(rand(10000));
		
		if (($type ne '.jpg') && ($type ne '.jpeg')) {
      my $f = system("/usr/bin/convert", "-quality", "99", $filename, "jpeg:".$filename.'.jpg');
			
  		if (!$f) {
				$filename .= '.jpg';
			}
		}
		
		$dst_link = add_image($filename,'img/campaign/',$atomcfg::targets,$campaign_gallery_id.'-'.$rand_index.$type);

		thumbnailize_campaign_gallery({'campaign_gallery_id' => $campaign_gallery_id, 'logo_pic' => $dst_link});

		do_statement("update campaign_gallery set logo_pic=".str_sqlize($dst_link)." where campaign_gallery_id=".$campaign_gallery_id);

		$hin{'logo_pic'} = $dst_link;
		
		# to prevent loading from atom_commands
		$hin{'store_worked'} = 1;
	}

  return $dst_link || $value;
} # sub store_as_campaign_gallery_pic_uploaded

sub store_as_object_url_uploaded {

  my ($call,$field,$value) = @_;
	
#  my $filename = $hin{'object_url_filename'};
#	if(!$filename or ($filename eq '') or ($hin{'object_descr'} eq '') or !$hin{'object_langid'}){ return $value;}
#	my $product_id = $hin{'product_id'};
		 
#  if($filename =~ /(\..{3,4})$/){
#   my $type = $1;
#	 srand;
#   my $rand_index = int(rand(10000));
#	 while (do_query("select id from product_multimedia_object_reverse where link like REVERSE('%".$product_id."_".$rand_index.$type."')")->[0][0]) {
#		 srand;
#  	 $rand_index = int(rand(10000));
#	 }
#
#	 system("mv",$filename,$atomcfg{"base_dir"}.'/www/objects/'.$product_id.'_'.$rand_index.$type);

#	 $value = $atomcfg{"base_dir"}.'/www/objects/'.$product_id.'_'.$rand_index.$type;
#	 $value = $atomcfg{'objects_host'}.'objects/'.$product_id.'_'.$rand_index.$type;
#	 goto skip_this;
#	 my $cmd = "scp -qrB ".$atomcfg{"base_dir"}."/www/objects/".$product_id.'_'.$rand_index.$type." www\@objects.icecat.biz:/data/www/objects/".$product_id.'_'.$rand_index.$type;
#	 `$cmd`;
#	 log_printf($cmd);
#	 $cmd = "scp -qrB ".$atomcfg{"base_dir"}."/www/objects/".$product_id.'_'.$rand_index.$type." www\@192.168.1.157:/data/www/objects/".$product_id.'_'.$rand_index.$type;
#	 `$cmd`;
#	 log_printf($cmd);
	 
#	 insert_rows('product_multimedia_object', {
#     'product_id' => $product_id,
#	   'link' => str_sqlize($value),
#		 'langid' => $hin{'object_langid'},
#		 'short_descr' => str_sqlize($hin{'object_descr'}),
#		 'size' => (-s $atomcfg{"base_dir"}.'/www/objects/'.$product_id.'_'.$rand_index.$type),
#		 'content_type' => str_sqlize($hin{'file_content_type'})
#	 });
#
#   $hin{'object_url'} = $atomcfg{"base_dir"}.'/www/objects/'.$product_id.'_'.$rand_index.$type;
					 
	 #to prevent loading from atom_commands
#	 $hin{'store_worked'} = 1;

#	}

# skip_this:
  return $value;
}

sub store_as_get_date
{
  my ($call,$field,$value) = @_;
	$hin{'feature_updated'} = do_query("select unix_timestamp(now())")->[0][0];
	return time;
}

sub store_as_list_of_templates {
  my ($call,$field,$value) = @_;
  
	my @arr_templates = split("\n",$value);
	$value = '';
	for my $t(@arr_templates) {
		$t =~ s/\s+//g;
		if ($t ne '') {
			$value .= $t."\n";
		}
	}
	$value =~ s/\n$//m;
	
	return $value;
} # sub store_as_list_of_templates

sub store_as_folder_name {
  my ($call,$field,$value) = @_;
  
	$value = string2fat_name($hin{'name'});
	
	return $value;
} # sub store_as_folder_name

sub store_as_measure_power_mapping {
	$_[3] = 'measure';
	return store_as_feature_power_mapping(@_);
} # sub store_as_measure_power_mapping

sub store_as_feature_power_mapping {
	my ($call,$field,$value,$is_measure) = @_;

	my $unit = $is_measure || 'feature';

	return undef unless ($hin{$unit.'_id'});

	my ($value_regexp_id, $id);
	my $order = 0;

	# save all ids
	my $ids1 = do_query("select group_concat(value_regexp_id separator ',') from ".$unit."_value_regexp where ".$unit."_id=".$hin{$unit.'_id'}." group by ".$unit."_id")->[0][0];
	my @ids = split(/,/,$ids1);
	my $ids;
	for (@ids) {
		$ids->{$_} = 1;
	}

	my @values = split(/\n/,$value);

	for my $value (@values) {
		$value =~ s/\s+$//;
		next unless ($value);
		$order++;
		$value_regexp_id = do_query("select value_regexp_id from value_regexp where pattern = ".str_sqlize($value))->[0][0];
		unless ($value_regexp_id) {
			do_statement("insert into value_regexp(pattern) values(".str_sqlize($value).")");
			$value_regexp_id = do_query("select last_insert_id()")->[0][0];
		}
		$id = do_query("select id from ".$unit."_value_regexp where value_regexp_id=".$value_regexp_id." and ".$unit."_id=".$hin{$unit.'_id'})->[0][0];
		if ($id) {
			do_statement("update ".$unit."_value_regexp set no=".$order." where id=".$id);
		}
		else {
			do_statement("insert into ".$unit."_value_regexp(value_regexp_id,".$unit."_id,no) values('".$value_regexp_id."','".$hin{$unit.'_id'}."','".$order."')");
			$id = do_query("select last_insert_id()")->[0][0];
		}
		$ids->{$value_regexp_id} = 0;
	}

	# remove unused $unit."_value_regexp"
	my $remove_ids = '';
	for (keys %$ids) {
		if ($ids->{$_}) {
			$remove_ids .= ($remove_ids?",":"").$_;
		}
	}
	if ($remove_ids) {
		do_statement("delete from ".$unit."_value_regexp where value_regexp_id in (".$remove_ids.") and ".$unit."_id=".$hin{$unit.'_id'});
	}

	# remove unused value_regexp
	do_statement("delete vr from value_regexp vr where (
select count(*) from feature_value_regexp fvr where fvr.value_regexp_id=vr.value_regexp_id) +
(select count(*) from measure_value_regexp mvr where mvr.value_regexp_id=vr.value_regexp_id) = 0");

	return undef;
} # sub store_as_power_mapping

sub store_as_related_prod_id {
	my ($call,$field,$value) = @_;

	my (@values, $product_id);
	@values = split(/\s+/, $value);

	if ($hin{'atom_submit'}) {
		for my $prod_id (@values) {
			$product_id = do_query("select product_id from product prod_id=".str_sqlize($prod_id))->[0][0];
			if (do_query("select product_related_id from product_related where rel_product_id='".$hin{'product_id'}."' and product_id=".$product_id)->[0][0]) {
				push @user_errors, $atoms->{'default'}->{'errors'}->{'related_duplicate'};
				atom_cust::proc_custom_processing_errors;
				return 1;
			}
			do_statement("insert ignore into product_related(product_id,rel_product_id) values('".$hin{'product_id'}."','".$product_id."')");
		}
	}
	elsif ($hin{'atom_delete'}) {
		do_statement("delete from product_related where product_related_id = ".$hin{'product_related_id'});
	}

	return $value;
} # sub store_as_related_prod_id

1;

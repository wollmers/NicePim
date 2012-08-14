package atom_validate;

#$Id: atom_validate.pm 3778 2011-02-03 15:15:42Z vadim $

use strict;
use atomcfg;
use atomsql;
use atom_html;
use atom_util;
use atom_misc;
use data_management;
use atomlog;
use LWP::Simple;
use LWP::Simple qw($ua); $ua->timeout($atomcfg{'http_request_timeout'});
use Data::Dumper;
use WebService::Validator::HTML::W3C;
use icecat_util;
use Search::Tools::UTF8;
use Encode;
use XML::LibXML;
use Algorithm::CheckDigits;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw(
							    &validate_as_email
								&validate_as_mandatory
							    &validate_as_mandatory_rel_product_add
							  
								&validate_as_url
								&validate_as_date
								&validate_as_feature_to_del
								
								&validate_as_numeric
								&validate_as_assigned_rows
								
								&validate_as_prod_id
								&validate_as_stat_period
								&validate_as_mandatory_bndl_product_add

								&modify_as_product_feature_value
								&validate_as_product_feature_value
								&validate_as_feature_name
								&validate_as_category_name
								
								&validate_as_login_expiration_date
								
								&validate_as_uploaded_obj
								&validate_as_family_id
								
								&validate_as_parent_family_id
								
								&validate_as_catid
								&validate_as_dispatch_groups

								&validate_as_default
								&validate_as_need_update
								&validate_as_sponsor
								&validate_as_ean_code

								&validate_as_html
								&validate_as_start_less_than_end
								&validate_as_unique_text_voc
								&validate_as_yyyy_mm_dd_and_probably_hh_mm_ss
								&validate_as_shop_user
								&validate_as_htmltype_to_daily
								&validate_as_define_subst_family
								&validate_as_unique
								&validate_as_strict_brand_prod_id
								&validate_as_unupdated
								&validate_as_onechar
								&validate_as_url_exists
								&validate_as_pricelist_columns
								&validate_as_pricelist_price
								&validate_as_unmandatory_email
								&validate_as_csv_delimiter
								&validate_as_correct_utf8_text
								&validate_as_unique_virtual_category
								&validate_as_all_or_nothing
								&validate_as_tree_part_date
								&validate_as_mandatory_number
								&validate_as_user_partner_logo
								&validate_as_prod_id_pair
								&validate_as_num_interval
								&validate_as_product_access
								&validate_as_series_id
								validate_as_define_subst_series
							 );
}

sub validate_as_product_access{
	my ($call, $field) = @_;
	my @allowed_groups=('superuser' , 'supereditor','category_manager','supplier');	
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and $hin{'product_id'} and !grep(/^$USER->{'user_group'}$/,@allowed_groups)){
		my $user_info=&do_query('select u.user_id,measure from product p 
							   JOIN users u USING(user_id) 
							   JOIN user_group_measure_map ug USING(user_group)							   
							   where product_id='.$hin{$field});
		if($user_info->[0][0] and $user_info->[0][0]!=$USER->{'user_id'} and $user_info->[0][1] eq 'ICECAT'){			
			push(@user_errors, 'You are not allowed to edit this product');
		}
	}
}

sub validate_as_strict_brand_prod_id {
	my ($call, $field) = @_;
	return 0 unless $hin{'supplier_id'};
	use icecat_mapping;
	unless (&brand_prod_id_checking_by_regexp($hin{$field},{'supplier_id' => $hin{'supplier_id'}})) {
		my $templates = &do_query("select prod_id_regexp from supplier where supplier_id=".$hin{'supplier_id'})->[0][0];
		my @tmpls = split "\n", $templates;
		my $out = '';
		foreach my $tmpl (@tmpls) {
			$tmpl =~ s/^\s*(.*?)\s*$/$1/gs;
			next unless $tmpl;
			$out .= '<b>' . $tmpl . '</b>, ';
		}
		chop($out);
		chop($out);
		return &repl_ph($atoms->{'default'}->{'errors'}->{'check_prod_id_strictness'},{'regexps' => $out});
	}
	else {
		return 0;
	}
} # sub validate_as_strict_brand_prod_id

sub validate_as_yyyy_mm_dd_and_probably_hh_mm_ss {
	my ($call,$field) = @_;
	
	if (($hin{$field} !~ /^\d{4}\-\d{1,2}\-\d{1,2}(\s+\d{2}\:\d{2}\:\d{2})?$/) && ($hin{$field} != 'now')) {
		return $atoms->{'default'}->{'errors'}->{'check_date'};
	}

	return;
} # sub validate_as_yyyy_mm_dd_and_probably_hh_mm_ss

sub validate_as_start_less_than_end {
	my ($call,$field) = @_;

	my $start_date_year = $hin{'start_'.$field.'_year'};
	my $start_date_month = $hin{'start_'.$field.'_month'};
	my $start_date_day = $hin{'start_'.$field.'_day'};

	my $end_date_year = $hin{'end_'.$field.'_year'};
	my $end_date_month = $hin{'end_'.$field.'_month'};
	my $end_date_day = $hin{'end_'.$field.'_day'};

	return if (!$start_date_year);
	return if (!$end_date_year);

	if ($start_date_year > $end_date_year) {
		goto goto_errors;
	}
	elsif ($start_date_year == $end_date_year) {
		if ($start_date_month > $end_date_month) {
			goto goto_errors;
		}
		elsif ($start_date_month == $end_date_month) {
			if ($start_date_day > $end_date_day) {
				goto goto_errors;
			}
		}
	}

	return;

 goto_errors:
  return $atoms->{'default'}->{'errors'}->{'check_dates'};

} # sub validate_as_start_less_than_end

sub validate_as_ean_code {
	my ($call,$field) = @_;

	if ($hin{'atom_delete'}) {
		return;
	}

	my $ean = $hin{$field};
	my $ean_id = undef;
	my $error;
	my $prod = undef;
	my $errors = [];
	my $valid = 0;
	
	# create EAN and UPC checkers
	my $ean_checker = CheckDigits('ean');
	my $upc_checker = CheckDigits('upc');
	
	# check length
	if ( ($ean !~ /^\d{13}$/) && ($ean !~ /^\d{12}$/) ) {
	    # length or content error
	}
	else {
	    # check content
	    if (length($ean) == 12) {
	        $valid = 1 if ($upc_checker->is_valid($ean) );
	    }
	    
	    if (length($ean) == 13) {
	        $valid = 1 if ($ean_checker->is_valid($ean) );
	    }
	}

	if ($valid) {
		$ean_id = &do_query("select ean_id from product_ean_codes where ean_code=".&str_sqlize($ean))->[0][0];
		if ($ean_id) {
		    # we have ean in database
			$prod = &do_query("select product_id, prod_id from product inner join product_ean_codes using (product_id) where ean_code=".&str_sqlize($ean)." limit 1")->[0];
			if ($prod->[0]) { # we have this product with this ean
				$error = $atoms->{'default'}->{'errors'}->{'already_present_ean_code'};
				push @$errors, &repl_ph($error, {'code' => $ean, 'prod_id' => $prod->[1]});
			}
			else {
			    # we have ean but haven't product - so, this is the orphan ean. remove it before inserting
				&do_statement("delete from product_ean_codes where ean_id=".$ean_id);
				log_printf("Orphan ean was removed from database: ".$ean);
			}
		}
	}
	else {
		$error = $atoms->{'default'}->{'errors'}->{'invalid_ean_code'};
		push @$errors, &repl_ph($error, {'code' => $ean});
	}
 
	return $errors;
}

sub validate_as_need_update
{
my ($call,$field) = @_;

my $update = $hin{'need_update'};
my $sup_id = $hin{'new_supplier_id'};
my $prod_id = $hin{'prod_id'};
my $source = &get_rows('product', "prod_id = ".&str_sqlize($prod_id)." AND supplier_id = $sup_id");
my $product_id = $source->[0]->{'product_id'};
my $user_id = $source->[0]->{'user_id'};
my $errors;

if($update){
	$hin{'product_id'} = $product_id;
	if($product_id){				## if dest product exists
		$hin{'edit_user_id'} = $user_id;	## dest product's ownership won't change
	}
}else{
	$errors = $atoms->{'default'}->{'errors'}->{'dest_part_number_not_unique'} if ($product_id);
}

return $errors;
}

sub validate_as_sponsor {
	my ($call,$field) = @_;
	
	my $is_sponsor = $hin{$field};
	my $errors = [];
	my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
	
	if ($is_sponsor eq 'Y') {
		push @$errors, &repl_ph($error, {'name'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{'public_login'}}) if(!$hin{'public_login'});
		push @$errors, &repl_ph($error, {'name'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{'public_password'}}) if(!$hin{'public_password'});
		push @$errors, &repl_ph($error, {'name'=>$atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{'edit_user_id'}}) if(!$hin{'edit_user_id'});
	}
	return $errors;
}

sub modify_as_product_feature_value 
{
	my $errors = [];
	my ($call,$field, $r_arr) = @_;

	foreach my $row(@$r_arr) {
		my $value = $hin{'_rotate_value_'.$row->[0]};
		$hin{'_rotate_value_'.$row->[0]} = &get_corrected_product_feature_value($value);
	}

	return $errors;
}


sub validate_as_product_feature_value
{
my ($call,$field, $r_arr) = @_;

my $errors = [];

 foreach my $row(@$r_arr){

  my $searchable = $hin{'_rotate_searchable_'.$row->[0]};
	my $value 		 = $hin{'_rotate_value_'.$row->[0]};
	my $name			 = $hin{'_rotate_feature_name_'.$row->[0]};
  my $mandatory = $hin{'_rotate_cat_feat_mandatory_'.$row->[0]};

  if($searchable && $value eq ''){
	 push @$errors, 
	  &repl_ph($atoms->{'default'}->{'errors'}->{'missing_feature_value'}, 
		 {
		  'feature_name' => $name		 
		 });
	}
#	&log_printf("\n\nname: $mandatory; $value");
	if($mandatory && $value eq ''){
	 push @$errors, 
	  &repl_ph($atoms->{'default'}->{'errors'}->{'missing_mandatory_feature_value'}, 
		 {
		  'feature_name' => $name		 
		 });
	}
	if ((!$hl{'warned_feature_name_nonEn_'.$row->[0]}) ||
			($hl{'warned_feature_name_nonEn_'.$row->[0]} ne $value)) {
		my $nonEn = &nonEn_value($value);
		if ($#$nonEn > -1) {
			push @$errors, 
			&repl_ph($atoms->{'default'}->{'errors'}->{'nonenglish_feature_value'},
							 {
								 'feature_name' => $name,	 
								 'feature_value' => $value
								 });
			$hs{'warned_feature_name_nonEn_'.$row->[0]} = $value;
		}
	} elsif ($hl{'warned_feature_name_nonEn_'.$row->[0]}) {
		$hs{'warned_feature_name_nonEn_'.$row->[0]} = $hl{'warned_feature_name_nonEn_'.$row->[0]};
	}
 }

return $errors;
}

sub validate_as_feature_name
{
my ($call,$field, $r_arr) = @_;

my $errors = [];

 foreach my $row(@$r_arr){

	 my $value = $hin{'_rotate_label_'.$row->[0]};

  if((!$value)&&($row->[0] == 1)){
	 push @$errors, 
	  &repl_ph($atoms->{'default'}->{'errors'}->{'missing_feature_name'}, 
		 {
		  'language' => $row->[1]
		 });
	}
#	&log_printf("\n\nfeature_name language: $row->[1]");
 }

return $errors;
}

sub validate_as_category_name
{
my ($call,$field, $r_arr) = @_;

my $errors = [];

 foreach my $row(@$r_arr){

	 my $value = $hin{'_rotate_label_'.$row->[0]};

  if((!$value) && (lc($row->[1]) eq 'english')){
	 push @$errors, 
	  &repl_ph($atoms->{'default'}->{'errors'}->{'missing_category_name'}, 
		 {
		  'language' => $row->[1]
		 });
	}
#	&log_printf("\n\ncategory_name language: $row->[1]");
 }

return $errors;
}

sub validate_as_prod_id {
	my ($call,$field) = @_;
	my $value = $hin{$field};
	
	my $product = {
		"product_id"  => $hin{'product_id'},
	  	"supplier_id" => $hin{'supplier_id'},
		"prod_id"	  => $value
	};
	
	if ( $hin{'product_id'} ) {
		my $cur_prod_data = &do_query("SELECT prod_id, user_id FROM product WHERE product_id=" . $hin{'product_id'})->[0];
		return if ( ($value eq $cur_prod_data->[0]) && ($hin{'edit_user_id'} == $cur_prod_data->[1] || $hin{'edit_user_id'} == 1));
	}
	
	my $m_prod_id = &get_mapped_prod_id($product);
	if ($m_prod_id->[0] && (!$hl{'warned_prod_id_should_be_mapped'} || $hl{'warned_prod_id_should_be_mapped'} eq $value)) {
		$product->{'m_prod_id'} = $m_prod_id->[0];
		if ($m_prod_id->[1]) {
			$product->{'map_supplier_name'} = ' (and to <b>'.$m_prod_id->[1].'</b> vendor)';
		}
		my $warn = $atoms->{'default'}->{'errors'}->{'prod_id_should_be_mapped'};
		$warn = &repl_ph($warn, $product);
		$hs{'warned_prod_id_should_be_mapped'} = $value;
		return $warn;
	}
}

sub validate_as_assigned_rows
{
my ($call,$field) = @_;
my $value = $hin{$field};

unless($hin{'atom_delete'}){
 return
}

 my $error = $atoms->{'default'}->{'errors'}->{'assigned_rows_exists'};
 
 my @list = split(',', $iatoms->{$call->{'name'}}->{$field.'_assigned_tables'});
 my @keys = split(',', $iatoms->{$call->{'name'}}->{$field.'_assigned_tables_keys'});
 my $delimiter = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'delimit_assigned_table'} || ', ';
 my $f = 0;
 my $respond_value = '';
  
 for(my $i = 0; $i <= $#list; $i++){
   
 my $data = &do_query("select count(*) from ".$list[$i]." where ".( $keys[$i] || $field )." = ".&str_sqlize($value));

 if($data->[0] && $data->[0][0] > 0){
  my $name = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'assigned_table_'.$list[$i]} || $list[$i];
  $f = 1;
	if($respond_value){
	 $respond_value .= $delimiter.$name
	} else { 	 $respond_value = $name }
 }
 
 }
 
 if($f){
  return &repl_ph($error, {'value' => $respond_value });
 }

}

sub validate_as_category_assigned_cat
{
my ($call,$field) = @_;
my $value = $hin{$field};
 my $error = $atoms->{'default'}->{'errors'}->{'category_assigned_cat'};

 my $data = &do_query("select count(*) from category where pcatid = $value");
 if($data->[0] && $data->[0][0] > 0){
   return $error; 
 }
}

sub validate_as_numeric
{
my ($call,$field) = @_;

my $value = $hin{$field};

if ($value ){

 my $error = $atoms->{'default'}->{'errors'}->{'numeric'};

if ($value =~m/^\d+[\.]{0,1}\d*\Z/){
 
} else {
  return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
}
}

}

sub validate_as_feature_to_del
{
 my ($call,$field) = @_;
 my $atom = $atoms->{'default'}->{'errors'};
 
 if($hin{'atom_delete'} && $hin{'atom_name'} eq 'feature'){
  my $ref_data = &do_query("select distinct data_source.code from data_source, data_source_feature_map where data_source.data_source_id = data_source_feature_map.data_source_id and data_source_feature_map.feature_id = ".&str_sqlize($hin{'feature_id'}));

  my $source = '';
	foreach my $row(@$ref_data){
	 $source .= ' '.$row->[0].',';
	}
	chop $source;
 
  if($source){							
	 return &repl_ph($atom->{'integrity_validation_fails'}, {'sources' => $source });
	}
 }
}


sub validate_as_email
{
 my ($call,$field) = @_;

 if(!($hin{$field} =~m/.+?\@.+/)){
	my $error = $atoms->{'default'}->{'errors'}->{'email'};
  return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
 }

} 

sub validate_as_mandatory_rel_product_add {
	my ($call,$field) = @_; 
	
	my $value = $hin{'rel_prod_id'};
	my $value_supplier = $hin{'r_supplier_id'} || 0;
	
	if (($hin{'product_id'}) && ($value)) {
		my $data;
		if ($value_supplier) {
			$data = &do_query("select product_id from product where prod_id = ".&str_sqlize($value)." and supplier_id = ".&str_sqlize($value_supplier));
		}
		else {
			$data = &do_query("select product_id from product where prod_id = ".&str_sqlize($value));
		}
		
		if ($data) {
			$hin{'rel_product_id'} = '';
			foreach my $row (@$data) {
				$hin{'rel_product_id'} .= ($hin{'rel_product_id'}?"\t":"").$row->[0];
			}
		}
	}

	# if prod_id is void - return an error
	if (!$hin{$field}) {
		my $error = $atoms->{'default'}->{'errors'}->{'related_incorrect'};
		return $error;
	}
} # sub validate_as_mandatory_rel_product_add

sub validate_as_mandatory_bndl_product_add
{
 my ($call,$field) = @_; 
 
 my $value = $hin{'bndl_prod_id'};
 
	if($hin{'product_id'}&&$value){

	my $data = &do_query("select product_id from product where prod_id = ".&str_sqlize($value));
 
 if($data->[0]){  
	my $srow = shift @$data;
	$hin{'bndl_product_id'} = $srow->[0];
		
	foreach my $row(@$data){
    &insert_rows('product_bundled', 
				 {
				  'product_id' => &str_sqlize($hin{'product_id'}),
					'bndl_product_id' => $row->[0]
				 });	
	}
 }
 }

 if(!$hin{$field}){
	  
	my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
  return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
 }

}

sub validate_as_mandatory {
    my ($call,$field) = @_; 
 
    if ( (! (defined ($hin{$field}))) || ($hin{$field} eq '') ) {
	    my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
        return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
    }
    return;
}

sub validate_as_date
{
 my ($call,$field) = @_; 
 if($hin{$field}){
 if(!($hin{$field} =~m/\d\d\-\d\d\-\d\d\d\d/)){
  
	my $error = $atoms->{'default'}->{'errors'}->{'date'};
  return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
 }
 }
} 

sub validate_as_url
{
 my ($call,$field) = @_; 
 if($hin{$field} && !($hin{$field} =~m/http\:\/\/.+?\..+?/i)){
	my $error = $atoms->{'default'}->{'errors'}->{'url'};
  return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
 }
} 

sub validate_as_stat_period
{
 my ($call,$field) = @_; 
 my $value = $hin{$field};
 if($value < 2){
	my $error = $atoms->{'default'}->{'errors'}->{'stat_period'};
  return $error;
  
 }
}

sub validate_as_login_expiration_date{
	my ($call,$field) = @_;
  if($hin{$field}){
    if($hin{$field} =~ /^\s*(\d\d\d\d)\s*-\s*(\d\d)\s*-\s*(\d\d)\s+(\d\d)\s*:\s*(\d\d)\s*:\s*(\d\d)\s*$/){
#			my $year = $1;
			my $month = $2;
			my $day = $3;
			my $hour = $4;
			my $minute = $5;
			my $second = $6;
			if (
				($month >= 1) && ($month <= 12) &&
				($day >= 1) && ($day <= 31) &&
				($hour >= 0) && ($hour <= 23) &&
				($minute >= 0) && ($minute <= 59) &&
				($second >= 0) && ($second < 59)
					) {
				return undef;
			}
    }
	}
	else {
		return undef;
	}
	my $error = $atoms->{'default'}->{'errors'}->{'login_expiration_date'};
	return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
}

sub validate_as_uploaded_obj {
	my ($call, $field) = @_;

#	log_printf("validator validate_as_uploaded_obj started");

# &log_printf("field = ".Dumper($field));
	if ($hin{$field} && $hin{$field} ne '' && !$hin{'atom_delete'}) {
		$ua->agent('Mozilla/5.0');
		my $rc = $ua->head($hin{$field});

		unless ($rc->is_success) {
			log_printf("URL validate failed, reason: ".$rc->status_line);
			my $error = $atoms->{'default'}->{'errors'}->{$field};
			return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
		}
	}
	return;
}

sub validate_as_user_partner_logo{
 my ($call,$field) = @_;
 &log_printf('---------->>>>>>>>>>>>>>>>> validate_as_user_partner_logo '.$hin{'logo_pic_file'});
 if(($hin{'is_implementation_partner'}*1)){
 	if($hin{$field}){
 		my $result=validate_as_uploaded_obj($call,$field);
 		return $result;
 	}elsif(!( -s $hin{'logo_pic_file'})){
 		return 'If user is implementation partner provide the image for its logo please';
 	}else{
 		return '';
 	}
 }
 return '';
}

sub validate_as_family_id {
 my ($call,$field) = @_;
 return unless $hin{'family_id'};
 return if $hin{'atom_delete'};
#validate supplier/category products family mandatory if exists
  my $get_family_by_sup_cat = &do_query("select family_id from product_family where supplier_id =".$hin{'supplier_id'}." and catid =".$hin{'catid'});	 
	if($get_family_by_sup_cat->[0][0] && ($hin{'family_id'} == 1)){
	 my $error = $atoms->{'default'}->{'errors'}->{'sup_cat_family'};
	 return $error;
	}	
# my $suppliers_family_count = &do_query("select count(family_id) from product_family where supplier_id = ".&str_sqlize($hin{'supplier_id'}));
# if($suppliers_family_count->[0][0] > 0){
#  if($hin{$field} == 1){
#	 my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
#   return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
#  }		
# }
 my $resp = &do_query("select supplier_id from product_family where family_id=".$hin{$field});
   if($hin{'field'} && $resp->[0][0] != $hin{'supplier_id'}){
       my $error = $atoms->{'default'}->{'errors'}->{$field};
       return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
    }
}
	    
sub validate_as_parent_family_id{
 my ($call,$field) = @_;
 if($hin{$field} == 1){
#	my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
# return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
 }
 return;
}


sub validate_as_catid
{
   my ($call,$field) = @_;
#mandatory on catid
	 if($hin{$field} == 1){
		my $error = $atoms->{'default'}->{'errors'}->{'mandatory'};
 		return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
	 }
# sergey: checking if selected category is enabled for a selection
  my $cat_data 	= &do_query("select ucatid from category where catid = ".&str_sqlize($hin{$field}));
	my $error 		= $atoms->{'default'}->{'errors'}->{'category_not_allowed'};

	if($cat_data->[0] && $cat_data->[0][0]){
	 	my $unspsc = $cat_data->[0][0];
	 	if($unspsc =~m/00$/){
	 		return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
	 	}
	} else {
	 	return &repl_ph($error, { 'name' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} });
	}	

#products family
   my $fid = $hin{'family_id'};
   if(($fid == 1) || ($fid == 0) || !$fid){return;}
	 if(!$hin{'parent_family_id'}){
#validate updated supplier_id and families supplier_id
   my $get_sup_fid = &do_query("select supplier_id from product_family where family_id = $fid");
#   &log_printf("\n $get_sup_fid->[0][0] - $hin{'supplier_id'}");
   if($get_sup_fid->[0][0] != $hin{'supplier_id'}){
    return $atoms->{'default'}->{'errors'}->{'sup_family_id_mismatch'};
   }
#validate products category and products family category
#select family catid
#   my $fcatid = &do_query("select catid from product_family where family_id = $fid");
#	  &log_printf("\nfcatid: $fcatid->[0][0]; $hin{$field}");
#   if(($fcatid->[0][0] == $hin{$field}) || ($fcatid->[0][0] == 1)){ return;}
#	 my $error = $atoms->{'default'}->{'errors'}->{'catid_mismatch'};
#	 return $error;
 }	 
}
 
sub validate_as_dispatch_groups {
	my ($call,$field) = @_;
	
	&process_atom_ilib("mail_dispatch");
  &process_atom_lib("mail_dispatch");

	my @groups_names = split(",", $atoms->{'default'}->{'mail_dispatch'}->{'dispatch_groups_names'});
	my @groups_values = split(",", $iatoms->{'mail_dispatch'}->{'dispatch_groups_values'});
	
	my $cnt = 0;
  foreach my $group_value (@groups_values) {
		if ($hin{$group_value} == 1) {
			$cnt++;
		}
	}
  if (($cnt == 0) && ($hin{'dispatch_one_address_check'} != 1)) {
		return $atoms->{'default'}->{'errors'}->{'dispatch_groups'};
	}
}

sub validate_as_default {
  my ($call,$field) = @_;

	my $def = &do_query("select c.contact_id
from supplier_users su
inner join users u on su.user_id=u.user_id
inner join contact c on u.pers_cid=c.pers_cid
inner join supplier_contact_report scr on c.supplier_contact_report_id=scr.supplier_contact_report_id
where su.supplier_id=".$hin{'supplier_id'}." and scr.default_manager='Y'")->[0][0];

  if ($def && ($hin{'default'} eq 'Y') && ($def != $hin{'id'})) {
		return $atoms->{'default'}->{'errors'}->{'default_manager'};
  }
} # sub validate_as_default

sub validate_as_html {
	my ($call,$field) = @_;

	return;
		
	my $html_source = $hin{$field};
	my $html_file = $atomcfg{'base_dir'} . 'tmp/source-' . &make_code(4) .'.html';
	my $html;
	my $ret;

	$html_source =~ s/&/&amp;/sg;

	open HTML, "> $html_file";
	binmode HTML, ":utf8";

	print HTML "<!DOCTYPE HTML SYSTEM>";
	print HTML "<html>";
	print HTML "<head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"><title>validate</title></head><body>";
	print HTML $html_source;
	print HTML "</body></html>";
	
	close HTML;

	$html = WebService::Validator::HTML::W3C->new();
	$html->validate_file($html_file);

	if (!$html->is_valid) {
		&process_atom_ilib('errors');
		&process_atom_lib('errors');
	
		$ret = &repl_ph($atoms->{'default'}->{'errors'}->{'html_validation'}, {'name' => 'Short description' }) if ($field eq 'short_desc');
		$ret = &repl_ph($atoms->{'default'}->{'errors'}->{'html_validation'}, {'name' => 'Marketing text' }) if ($field eq 'long_desc');
	}	

	`chmod 777 $html_file`;
	`rm $html_file`;

	return $ret;	
}

sub validate_as_unique_text_voc{
	my ($call,$field) = @_;
	return if $hin{'atom_delete'};
	my $table=$iatoms->{$call->{'name'}}->{'table_validate_unique_text'};
	my $voc_record_id=$iatoms->{$call->{'name'}}->{'voc_record_id_validate_unique_text'};
	my $value=$hin{$field};
	$voc_record_id=$hin{$voc_record_id};
	# selected category
	my $catid = $hin{'catid'};
	my $supplier_id = $hin{'supplier_id'};
	my $sql_record;
	$sql_record =" and v.record_id!=$voc_record_id " if $voc_record_id;
	# some brands are allowed to have same family names for their products but in different categories
	if ( $table eq 'product_family' ) {
		# returns true if categories are equal
		# else if categories are not equal
		# returns true if supplier is not allowed to have duplicate families
		$sql_record .= " AND (t.catid = $catid OR t.supplier_id NOT IN (SELECT supplier_id FROM multi_families_supplier WHERE supplier_id=$supplier_id)) ";
	}
	my $result=&do_query("SELECT v.value FROM vocabulary v 
						  JOIN $table t ON v.sid=t.sid 
						  WHERE v.langid=1 AND v.value=".&str_sqlize($value)." $sql_record 
						  LIMIT 1");
	if($result->[0][0]){
		return "This value $value is not unique";
	}else{	
		return '';
	}
}

sub validate_as_shop_user{
	my ($call,$field) = @_;

	return; #fro PIM only
	if ($hin{$field} eq 'shop' and $hin{'atom_submit'}  ){
		return $atoms->{'default'}->{'errors'}->{'adding_shop_isnot_allowed'}; 
	}else{
		return '';
	}
}

sub validate_as_htmltype_to_daily{
	my ($call,$field) = @_;
	my $report_type=&do_query("SELECT name FROM time_interval WHERE interval_id=$hin{'interval_id'}")->[0][0];		
	if ($hin{$field} eq 'html' and $report_type and $report_type ne 'daily' and ($hin{'atom_submit'} or $hin{'atom_update'})){
		return &repl_ph($atoms->{'default'}->{'errors'}->{'report_type_and_interval'},{'report_type'=>$report_type});
		#return 'errr'; 
	}else{
		return '';
	}
}

sub validate_as_define_subst_family {
	if ($hin{'atom_delete'} and $hin{'exchange_family'} eq '1' and &do_query("SELECT product_id FROM product WHERE family_id=$hin{'family_id'} LIMIT 1")->[0][0]) { # should we bother the user
	 	if (!grep {$_ =~'^you must define a substitute'} @user_errors) {
	 		return "you must define a substitute for the deleted family 
	 						<script type=\"text/javascript\">
              <!--
								function appear_exchange_family() {
									document.getElementById('exchange_section_family').style.display = 'table-row';
								}
								window.onload = appear_exchange_family;
              //-->
							</script>";
		}
	}

	return '';
}

sub validate_as_unique{#this assumes what post's params names are equal to corresponding table fields 
	my ($call,$field) = @_;
	my $table=$iatoms->{$call->{'name'}}->{'unique_table'};	
	my $id_field=$iatoms->{$call->{'name'}}->{'unique_table_id'};
	
	my $self_value=$hin{$id_field};
	my $value=$hin{$field};
	my $result=&do_query("SELECT $id_field FROM $table  
						  WHERE $field=".&str_sqlize($value)." AND $id_field!=".&str_sqlize($self_value)."
						  LIMIT 1");
	if($result->[0][0]){
		return "This value $value is not unique. Please, use another one";
	}else{	
		return '';
	}
}

sub validate_as_unupdated{
	my ($call,$field) = @_;
	if($hin{'atom_update'}){
		my $table=$iatoms->{$call->{'name'}}->{'unupdated_table'};	
		my $id_field=$iatoms->{$call->{'name'}}->{'unupdated_table_id'};
		
		my $self_value=$hin{$id_field};
		my $value=$hin{$field};
		my $result=&do_query("SELECT $id_field FROM $table  
							  WHERE $field=".&str_sqlize($value)." AND $id_field=".&str_sqlize($self_value)."
							  LIMIT 1");
		if($result->[0]){
			return '';
		}else{
			return "This value $value can not be changed.";
		}

	}else{
		return '';
	}		
}

sub validate_as_onechar{
	my ($call,$field) = @_;
	if(substr($hin{$field},0,1) eq '\\' and length($hin{$field})>2){
		return $field.' should consists of one character or \\ + character . Current value is : '.$hin{$field};
	}elsif(length($hin{$field})>1){
		return $field.' should consists of one character or \\ + character . Current value is : '.$hin{$field};
	}else{
		return ''; 
	}
}

sub validate_as_url_exists{
	my ($call,$field) = @_;
	my $url=$hin{$field};
	return '' if (-e $hin{'feed_file'} and !$hin{$field}); # user uploaded file via http
	 
		if($url=~/^[\B]*ftp:/){
			
			if($url=~/\[maxmtime\]/){#find out max time under given url
				$url=~s/\[maxmtime\]//;
				$url=&get_ftp_newest_file($url,$hin{'feed_login'},$hin{'feed_pwd'});
				if(!$url){
					return ' Can\'t find files under given remote dir $url'
				}
			}
			$url=~/^[\B]*ftp:\/\/([^\/]+)\//i;			
			my $domain=$1;
			return "URL  $url is wrong" unless($domain);
			""=~/(.*)/;
			$url=~/^[\B]*ftp:\/\/[^\/]+\/(.+)/i;			
			my $path=$1;
			return "URL  $url is wrong" unless($path);
			use Net::FTP;
    		my $ftp = Net::FTP->new($domain, Debug => 0);
    		return "Link $url to file is wrong" unless($ftp);
			if($hin{'feed_login'} and $hin{'feed_pwd'}){
  		    	$ftp->login($hin{'feed_login'} ,$hin{'feed_pwd'} );
			}else{
				$ftp->login('anonymous' ,'-anonymous@');
			}
			return "Link $url to file is wrong or authefication details are invalid" unless($ftp->size($path)); 
		}else{# assume basic auth via HTTP 
			use HTTP::Request;
			use LWP::UserAgent;	
			my $ua = new LWP::UserAgent;
			$ua->agent('Mozilla/5.0');
			my $req = new HTTP::Request(HEAD => $url);
			if($hin{'feed_login'} and $hin{'feed_pwd'}){
				$req->authorization_basic($hin{'feed_login'} ,$hin{'feed_pwd'});
			}
			my $res = $ua->request($req);
			if(!$res->is_success){
				return "Link $url to file is wrong or authefication details are invalid";
			}			
		}
	return undef;
}

sub validate_as_pricelist_columns{
	my ($call,$ean_field) = @_;
	my @errors;	
	if($hin{'atom_update'} or $hin{'atom_submit'}){
		if(!(($hin{$ean_field}*1)) and ($hin{'brand_col'}*1) and !($hin{'brand_prodid_col'}*1)){
			push(@errors,"Part code or EAN(UPC) are requried");
		}elsif(!($hin{$ean_field}*1) and !($hin{'brand_col'}*1) and !($hin{'brand_prodid_col'}*1)){
			push(@errors,"Part code and Brand name or EAN(UPC) are requried");
		}elsif(($hin{$ean_field}*1) and !($hin{'brand_col'}*1) and ($hin{'brand_prodid_col'}*1)){
			push(@errors,"Part code and Brand name or EAN(UPC) are requried");
		}
		
		if(($hin{$ean_field}*1) and ($hin{$ean_field} eq $hin{'brand_prodid_col'} or $hin{$ean_field} eq $hin{'brand_col'})){
			push(@errors,"Part code, Brand name and EAN(UPC) should have diffrent columns");
		}elsif(($hin{'brand_prodid_col'}*1) and ($hin{'brand_prodid_col'}==$hin{$ean_field} or $hin{'brand_prodid_col'}==$hin{'brand_col'})){
			push(@errors,"Part code, Brand name and EAN(UPC) should have diffrent columns");
		}elsif(($hin{'brand_col'}*1) and ($hin{'brand_col'}==$hin{$ean_field} or $hin{'brand_col'}==$hin{'brand_prodid_col'})){
			push(@errors,"Part code, Brand name and EAN(UPC) should have diffrent columns");
		}
		
		if(scalar(@errors)=>1){
			#&log_printf('---------->>>>>>>>>>>>>>>>>>>>ean: '.$hin{$ean_field}.' brand: '.$hin{'brand_col'}.'  partcode: '.$hin{'brand_prodid_col'});
			return \@errors;
		} 
	}
}

sub validate_as_pricelist_price{
	my ($call,$field) = @_;
	if(($hin{'atom_update'} or $hin{'atom_submit'}) and $hin{'price_vat_col'}){
		if(!($hin{'price_vat_col'}*1)){
			return "Price with VAT is invalid"; 			
		}else{
			return '';
		}
		#elsif($hin{'price_vat_col'}==$hin{'ean_col'} or $hin{'price_vat_col'}==$hin{'brand_col'} or $hin{'price_vat_col'}==$hin{'brand_prodid_col'}){
		#	return "Part code, Brand name, EAN(UPC) and price with VAT should have diffrent columns";			
		#}
	}
}

sub validate_as_unmandatory_email
{
 my ($call,$field) = @_;

 if($hin{$field} and !($hin{$field} =~m/.+?\@.+/)){
  	return "This email $hin{$field} is invalid";
 }else{
 	return '';
 }

}

sub validate_as_csv_delimiter
{
 my ($call,$field) = @_;
 if(!$hin{'delimiter'} and $hin{'feed_type'} eq 'csv'){
 	return 'Delimiter is mandatory';
 }else{
 	return '';
 }
}

sub validate_as_correct_utf8_text {
    my ($call, $field) = @_;

#		return '';
    
    my $text = $hin{$field};
    
    my $filename = $atomcfg{'base_dir'} . 'tmp/tmp_test.xml';
    
    if (! is_valid_utf8($text)) {
        log_printf("Invalid UTF8 text in $field");
    	my @errors;
    	push @errors, "Invalid UTF8 text (is_valid_utf8 test failed)";
	    return \@errors;
    }
    
    my $create_xml = sub {
        my $txt = shift;
        my $FILE;
        open $FILE, ">:utf8", $filename;
        print $FILE '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
        print $FILE "<!DOCTYPE description_test SYSTEM \"" . $atomcfg{host} . "dtd/description_test.dtd\">";
        print $FILE "<root>\n";
        print $FILE str_xmlize($txt);
        print $FILE "</root>\n";
        close $FILE;
        return;
    };

    my $is_corrupted_data_for_xml = sub {
        my $num = shift;
        my $parser = XML::LibXML->new();
        my $doc;
    
        # try to create document
        eval {
            $doc = $parser->parse_file($filename);
        };
        if ($@) {
            return 1 
        } 
        else {
            return 0;
        }
    
        # try to validate
        eval {
            $doc->validate($doc->externalSubset);
        };
        if ($@) {
					return 1;
        } 
        else {
					return 0;
        }
    };
    
    # create XML and validate
    $create_xml->($text);
    if (! $is_corrupted_data_for_xml->() ) {
    	return '';
    } 
    else {
    	log_printf("Insane UTF8 text in $field");
    	my @errors;
    	push @errors, "Insane UTF8 text";
	    return \@errors;
    }
}

sub validate_as_unique_virtual_category {
    my ($call, $field) = @_;
    
    # by default this validator is used durind insert and delete operation
    # we should avoid the second case
    if ($hin{'command'} eq 'delete_from_virtual_category_table' ) {
        return '';
    }
    
    
    $hin{$field} = str_htmlize($hin{$field});
    my $new_name = $hin{$field};
    my $category_id = $hin{'catid'};
    
    my $ans = do_query("SELECT name FROM virtual_category WHERE name = '$new_name' AND category_id = $category_id"  );
    if ($ans->[0]) {
	my @errors;
	push @errors, "Duplicate name";
	return \@errors;
    } else {
	return '';
    }
}

sub validate_as_all_or_nothing{
	my ($call,$fields) = @_;
	my @params=split('&',$fields);		
	if(scalar(@params)<2){
		&log_printf("----->>>>>>>>>>validate_as_all_or_nothing: wrong fields are set: $fields");
		return '';
	}
	my ($def_found,$undef_found);
	foreach my $param (@params){
		if($hin{$param}){
			$def_found=1;
		}else{
			$undef_found=1;
		}
	}
	if($def_found and $undef_found){
		return 'These fields "'.$iatoms->{$call->{'name'}}->{join('_',@params).'_validate_as_all_or_nothing_names'}.'" should be all defined or not defined at all';
	}else{
		return '';
	}
}

sub validate_as_tree_part_date{
	my ($call,$field) = @_;
	my $date=eval{Time::Piece->strptime($hin{$field.'_year'}.'-'.$hin{$field.'_month'}.'-01','%Y-%m-%d')};
	if(!$date){
		return 'Date is not valid' ;
	}elsif(!$hin{$field.'_day'} or $hin{$field.'_day'}>$date->month_last_day()){
		return 'Day of date is not valid' ;
	}else{
		return '';
	}
}

sub validate_as_mandatory_number{
	my ($call,$field) = @_;
	my $tmp=validate_as_numeric($call,$field);
	return $tmp if $tmp;
	if(!$hin{$field} or $hin{$field} eq '0'){
		return "This field $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{$field} is invalid"; 
	}else{
		return '';
	}		
}
sub validate_as_prod_id_pair{
	my ($call,$field) = @_;
	my $product=&do_query('SELECT product_id from product WHERE prod_id='.&str_sqlize($hin{$field}).' and supplier_id='.$hin{'manual_supplier_id'})->[0][0];
	if(!$product){
		return 'This product does not exists';
	}else{
		return '';
	}			
}
sub validate_as_num_interval{
	my ($call,$field) = @_;
	if($hin{$field} and ($hin{$field}<$iatoms->{$call->{'name'}}->{$field.'_num_interval_left'} or $hin{$field} > $iatoms->{$call->{'name'}}->{$field.'_num_interval_right'})){
		return $iatoms->{$call->{'name'}}->{$field.'_num_interval_msg'};
	}else{
		return '';
	}
} 

sub validate_as_series_id {
	my ($call,$field) = @_;
	return unless $hin{'family_id'};
	return unless $hin{'series_id'};
	return if $hin{'atom_delete'};
	my $get_series_by_family = &do_query("select series_id from product_series where family_id=" . $hin{'family_id'});
	if( $get_series_by_family->[0]->[0] && $hin{'series_id'} == 1 &&  $hin{'family_id'} != 1){
		return "For this family, series is mandatory";
	}
}

sub validate_as_define_subst_series {
	if ( $hin{'atom_delete'} &&
		$hin{'exchange_series'} == 1 &&
		&do_query("SELECT product_id FROM product WHERE series_id=$hin{'series_id'} LIMIT 1")->[0][0]) {
	 			return "you must define a substitute for the deleted series 
	 						<script type=\"text/javascript\">
              		<!--
								function appear_exchange_series() {
									document.getElementById('exchange_section_series').style.display = 'table-row';
								}
								window.onload = appear_exchange_series;
              		//-->
							</script>";
	}
	return '';
}

1;


package atom_util;

#$Id: atom_util.pm 3615 2010-12-22 18:30:49Z dima $

use strict;

use vars qw ($lang_code);

use vars qw($atomer_domain $atomer_lib @errors @user_errors @user_warnings $last_path $commands $atoms $iatoms $formats $global_hash $template_prefix);
use vars qw ( $USER $AUTH $AUTH_SUBMIT );

use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_misc;

use icecat_util;
use serialize_data;

use LWP::Simple;
use LWP::Simple qw($ua); $ua->timeout($atomcfg{'http_request_timeout'});

use POSIX qw(mktime strftime);
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);

use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&load_template
							 &push_error
							 &push_user_error
							 $iatoms 
							 $formats
							 $commands
							 $atoms	
							 $global_hash
							 $template_prefix
							 
							 @errors
							 @user_errors
							 @user_warnings
							 &load_atomer_params
							 &get_errors
							 $atomer_domain 
							 $atomer_lib
							 
							 $USER $AUTH $AUTH_SUBMIT 
							 
							 &get_atoms_text
							 &get_atom_structure
							 &get_iatom_structure
							 &get_errors_text
							 &push_dmesg
							 
							 &make_select
							 &make_multiselect
							 &make_nmtable
							 &rearrange_as_tree
							 
							 &process_atom_lib
							 &process_atom_ilib
							 
							 &load_complex_template
							 &load_email_template
							 
							 &form_bit_strings
							 &dec2bin
							 &bin2dec
							 &html2text
							 &text2html
							 &remove_www_links
							 &code
							 &Array2Epoch
							 &regexp2mysql
                             &get_smart_path

							 &mapping_header
							 &mapping_footer

							 &get_product_id_list_from_prod_id_set
							 &shortify_str
							 &trim

							 &platform_table_complete
							 
							 &get_langid_hash
							 &get_percent
							 
							 &make_category_feature_intervals

							 &string2fat_name

							 &diff_table_md5
							 &update_table_md5
							 &_prepare_table_md5
							 &_get_table_md5_from_cache
							 
							 &sync_all_distributors
							 &get_remote_distributor
							 
							 &get_name_from_url
							 &url2scp_path
							 
							 count_features_for_ej
							 
							 get_restricted_products_from_db
							 );
}

sub platform_table_complete {
	do_statement("insert ignore into platform(name) select trim(platform) from users where trim(platform) != '' and platform not like '%>%' and length(platform) > 2 group by 1");

} # sub platform_table_complete

sub get_product_id_list_from_prod_id_set {
	my ($prod_id_set, $filter) = @_;

	return { 'set' => '', 'not_defined' => 0 } unless $prod_id_set;

	my ($set, $supplier_clause, $not_defined);

	# filter
	if ($filter->{'supplier_id'}) {
		$supplier_clause = 'and supplier_id in ('.$filter->{'supplier_id'}.')';
	}

	# clean prod_ids
	$prod_id_set =~ s/^\s*(.*?)\s*$/$1/s;
	$prod_id_set =~ s/\s+/ /sg;

	my @total_raw_products = split(/\s/, $prod_id_set);
	for (@total_raw_products) {
		$set .= do_query("select group_concat(product_id separator ' ') from product where prod_id=".str_sqlize($_)." ".$supplier_clause." group by prod_id")->[0][0];
		$set .= ' ';
	}

	$set =~ s/^\s*(.*?)\s*$/$1/s;
	$set =~ s/\s+/ /sg;

	my @total_products = split /\s/, $set;

	my $not_defined = $#total_raw_products - $#total_products;
	$not_defined = $not_defined < 0 ? 0 : $not_defined;

	return { 'set' => $set, 'not_defined' => $not_defined, 'found' => $#total_products + 1 };
} # sub get_product_id_list_from_prod_id_set

sub get_smart_path {
  my ($product_id) = @_;
  return undef unless $product_id;
  my $path = undef;
  while ($product_id =~ s/^(..)//) {
    $path .= $1.'/';
  }
  return $path;
} # sub get_smart_path

sub string2fat_name {
	my $str = lc(shift);

  $str =~ s/\//\-/g;
  $str =~ s/[^a-z0-9_\-\s]//g;
  $str =~ s/\s+/_/g;

  return $str;
} # sub string2fat_name

sub make_nmtable {
	my ($nmt,$dbt) = @_;
	my ($nh,$i,$value,$j);
	for ($j = 0; $j <= $#{$nmt}; $j ++) {
		$value = $nmt->[$j];
		$nh = {};
		for ($i = 0; $i <= $#{$dbt}; $i ++) {	$nh->{$dbt->[$i]} = $value->[$i]; }
		$nmt->[$j] = $nh;
	}
}


sub load_atomer_params {
	check_params();
}

sub check_params {
	if ($hin{'sel_langid'}) {
		my $res = atomsql::do_query("select langid from language where langid = ".atomsql::str_sqlize($hin{'sel_langid'}));
		if (defined $res->[0]) {
			$hl{'langid'} =  $hin{'sel_langid'};
		}
	}
	if (!defined $hl{'langid'}) {
		$hl{'langid'} = $atomcfg{'default_langid'};
	}
}

sub load_template
{
 my ($path,$langid) = @_;

#use lib '/home/pim/data_source/IcecatToPIMImport/';
#use PIMConfiguration;
#my $pwd_cnf = PIMConfiguration->new();

#return if ($path eq 'warning.html' && $pwd_cnf->{'xml_password'} ne ('freeaccess'));

 
 my $without_prefix = $path;

 # are we trying to load a .ail or .al file?
	if($template_prefix &&!( $path =~m/\.a[i]{0,1}l/ )){ 
 # no
	 $path = $template_prefix.$path; 
 }
 my $r_path;
 $r_path=rindex($without_prefix,'/');
 if ($r_path >= 0) {	
   $r_path = substr($without_prefix,0,$r_path+1);
 } else { $r_path = ''; }
 
 my $prefix = '';
 my $filename = '';
 if($langid){
	 if(!defined $lang_code->{$langid}){
 		# we are trying to load an atom lib
 		$prefix 	= atomsql::do_query("select code from language where langid = $langid")->[0][0];
		$lang_code->{$langid} = $prefix;
	 } else {
	  $prefix = $lang_code->{$langid};
	 }
	 if($path =~m/\.al\z/){
		$filename = $atomcfg{'atom_lib_path'}.$prefix.'/'.$path;
	 } else {
		$filename = $atomcfg{'templates_path'}.$prefix.'/'.$path;	 
	 }
 } else {
  $filename = $atomcfg{'atom_inner_lib_path'}.'/'.$path; 
 }
 
 $last_path = $filename; # passing to global
 open(TMPL,"<$filename") 
	  or log_printf('load_template: can\'t open file '.$filename.': '.$!);
 binmode(TMPL,":utf8");
 my $tmpl = join('',<TMPL>);
 close(TMPL);	

 $tmpl =~ s/\$\$INCLUDE[ \t]+([^\$]+)[ \t]*\$\$/{load_template($r_path.$1,$langid)}/ge;

 
 return $tmpl;
}

sub push_error {
	my ($error_msg) = @_;

	if ($last_path) {
		push @errors, str_htmlize($last_path.": ".$error_msg)."<BR>\n";  # After McAfee XSS test (9-03-2010)
		log_printf($last_path.": ".$error_msg);
	}
	else {	 
		push @errors, str_htmlize($error_msg)."<BR>\n";
		log_printf($error_msg);
	}
} # sub push_error

sub push_user_error {
	my ($error_msg) = @_;

	if (!ref($error_msg)) {
		push @user_errors, str_htmlize($error_msg);
	}
	else {
		for (my $i = 0; $i <= $#$error_msg; $i++) {
			$error_msg->[$i] = str_htmlize($error_msg->[$i]);
		}
		push @user_errors, @$error_msg; 
	}

#	# additionally, restore <b> and </b>
#	for (@user_errors) {
#		s/\&lt\;b\&gt\;/\<b\>/ig;
#		s/\&lt\;\/b\&gt\;/\<\/b\>/ig;
#	}
} # sub push_user_error

sub get_errors_text {
	my $tmp;

	for my $error (@errors) {
		$tmp .= '<LI>'.$error;
	}
	if ($tmp) {
		return "<UL>Errors:<BR>$tmp</UL>";
	}
	else {
		return undef;
	}
} # get_errors_text

sub get_atoms_text
{
 my ($tmp) =	@_;
 my $tatoms;

 $tmp =~s/\n/\x1/gm;

 while($tmp =~ s/([^\\]|^){(.*?[^\\])}/$1/m){
	 my $atom 	= $2;
#	 $atom =~ s/\x1/\n/g;

	 push @$tatoms, $atom;
 }

 return $tatoms;
}

sub get_atom_structure
{
 my ($chunk) = @_;
 my $atom = {};
 my $struct_names = [];
 use vars qw ($var_names);
 
 $var_names = {};
 
 sub filter_params
 {
  my ($name,$value) = @_;
		$name 	=~ s/[\t\s\x1]//g;
		# filtering ending ";"
		# and forming an array if needed
		if($value 	=~ s/[\t\s]*([^\x1\;]*)\;[\t\s\x1]*\z/$1/){
		 $value =~ s/[\s\t]*\,[\s\t]*/,/g; # eleminating spaces
		}
		$value	=~ s/\x1/\n/g;
		$value  =~ s/\\\:/\:/g;

		if($name eq 'body' || $name =~m/_row$/){
		 # looking for var names
		 while(	$value =~s/\~(.*?)\~/$1/s){
		  my $var_desc = $1;
			my $var_name = '';
			if($value =~m/$var_desc.*?%%(.+?)%%/s){
			 $var_name = $1;
			 $var_names->{$var_name} = $var_desc;
			}
		 }
		}

  return ($name,$value);
 }
 my $flag = 1;
 
 while($flag){
  $flag = $chunk =~ s/\s*(\w+)\s*\:(.*?)(\x1\s*(\w+)\s*\:)/$3/;
	my ($name,$value) = filter_params($1,$2);
	$atom->{$name} = $value;
	push @$struct_names, $name;
 }

 if($chunk =~ s/\s*(\w+)\s*\:(.*)//){
	my ($name,$value) = filter_params($1,$2);
	$atom->{$name} = $value;
	push @$struct_names, $name;
 }
 
 # passing var names

 %{$atom->{'var_names'}} = %$var_names;
 # passing structure names
 
 $atom->{'struct_names'} = $struct_names; 
 return $atom;
}

sub get_iatom_structure
{
 my ($chunk) = @_;
 # this will build helpers lists
 my $atom = get_atom_structure($chunk);
 $atom->{'_resource_list'} = [];
 $atom->{'_tmpresource_list'} = [];
 $atom->{'_selector_list'} = []; 
 
 # forming lists
 for my $name(@{$atom->{'struct_names'}}){
  if($name =~/_resource_(.*)/
	   && $name ne '_resource_list'){
	 my $new_struct = $1;
	 if(!($new_struct=~m/_iq\Z/)&&
			!($new_struct=~m/_key\Z/)&&
			!($new_struct=~m/_rearrange_as\Z/)&&
			!($new_struct=~m/_type\Z/)&&
			!($new_struct=~m/_def_order_mode\Z/)&&
			!($new_struct=~m/_skey\Z/)&&
			!($new_struct=~m/_def_order\Z/)&&
			!($new_struct=~m/_imply_fields\Z/)&&
			!($new_struct=~m/_straight_join_approve\Z/)&&
			!($new_struct=~m/_order_by_tables_order_.*$/)&&
			!($new_struct=~m/_order_by_tables_order_default$/)&&
			!($new_struct=~m/_def_search\Z/)&&
			!($new_struct=~m/_bitwise_search\Z/)&&
			!($new_struct=~m/_disable_sql_calc_found_rows\Z/)&&
			!($new_struct=~m/_bitwise_field\Z/)&&
			!($new_struct=~m/_additional_search\Z/)&&
			!($new_struct=~m/_nav_bar\Z/)){
		 push @{$atom->{'_resource_list'}}, $new_struct;		 
	 }
  }

  if($name =~/_tmpresource_(.*)/
	   && $name ne '_tmpresource_list'){
		my $new_struct = $1;
		if(!($new_struct=~m/_tables\Z/)&&
			 !($new_struct=~m/_\d+_name\Z/)&&
			 !($new_struct=~m/_\d+_create\Z/)){
			push @{$atom->{'_tmpresource_list'}}, $new_struct;
		}
	}

  if($name =~/_selector_(.*)/
	   && $name ne '_selector_list'){
	 push @{$atom->{'_selector_list'}}, $1;	 
	}

 }

return $atom; 
}


sub push_dmesg
{
 my ($level,$mesg) = @_;
 if($level <=  $debug_level){
  log_printf($mesg);
 }
}

# this function invoked for features with restricted set of data
sub make_select {
	# now function receive a single param
	my $hash_ref = shift;
	my ($rows, $name, $sel, $small, $width, $allow_custom,$functions);
	$rows = $hash_ref->{'rows'};
	$name = $hash_ref->{'name'};
	$sel = $hash_ref->{'sel'};
	$small = $hash_ref->{'small'};
	$width = $hash_ref->{'width'};
	$allow_custom = $hash_ref->{'allow_custom'};
	$functions=$hash_ref->{'functions'};
	
	my (@tmp, $isSelected);
  
	$width = $width?"style=\"width: ".$width."px\"":"";
	
	# add div container if allow_custom case
	# container will be used by java script from .al file
	if ($allow_custom) {
	    push @tmp, "<div id=\"" . $name . "_container\">";
	}
	
	# add ref to onChange subroutine if custom values have been allowed
	# or various action and sub
	if ($allow_custom) {
	    push @tmp, "<select ".$width." id=\"$name\" name=\"$name\" $small $functions onchange='update_combobox(this)'>";
	} 
	else {
	    push @tmp, "<select ".$width." id=\"$name\" name=\"$name\" $functions $small>";
	}
	
	$isSelected = 0;

	for my $i (@{$rows}) {
		if (($sel eq $i->[0]) && (!$isSelected)) {
			push (@tmp, "<option selected value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
			$isSelected = 1;
		} elsif ($i->[0] eq '' && $i->[1] eq '') {
			push (@tmp, '<option>');
		} else {
			push (@tmp, "<option value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
		}
	}
	
	# if allow_custom is true, last options in select will be "Custom..."
	# BUT... we should not add a "Custom..." option, if a select control use Y/N style
	# So, we check an options list
	
	my $yes_no_style = 1;
	for my $i (@{$rows}) {
	    if (($i->[1] !~ /\b(y|n|yes|no|unspecified)\b/i) && ($i->[1] ne '')) {
		$yes_no_style = 0;
		last;
	    }
	}
	
	if (($allow_custom) && (! $yes_no_style)) {
	    push @tmp, "<option value=\"Custom...\">Custom...";
	}
	
	# close select for all cases
	push (@tmp, "</select>");
	
	# close div container (for custom case only)
	if ($allow_custom) {
	    push @tmp, "</div>";
	}
	
	return join("\n", @tmp);
}

sub make_multiselect {
	my ($rows,$name,$sel,$style) = @_;
	my @tmp;

	# prepare select values
	my @selects = split ',', $sel;
	my %hsel = map { $_ => 1 } @selects;

	log_printf(Dumper($sel));
	log_printf(Dumper(\@selects));
	log_printf(Dumper(\%hsel));
  
	push (@tmp, "<select multiple='multiple' ".$style." id=\"$name\" name=\"$name\">");

	for my $i (@$rows) {
		if ($hsel{$i->[0]}) {
			push (@tmp, "<option selected value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
		}
		elsif ($i->[0] eq '' && $i->[1] eq '') {
			push (@tmp, '<option>');
		}
		else {
			push (@tmp, "<option value=\"".str_htmlize($i->[0])."\">".str_htmlize($i->[1]));
		}
	}
	push (@tmp, "</select>");

	return join("\n", @tmp);
}

sub make_radio {
	my ($rows,$name,$sel) = @_;
	my @tmp;	
	
	for my $i (@{$rows}) {
		if ($sel eq $i->[0]) {
			push (@tmp, "<input name=\'$name\' type=radio checked value=\"".storehtml::str_htmlize($i->[0])."\">".$i->[1]);
		} else {
			push (@tmp, "<input name=\'$name\' type=radio value=\"".storehtml::str_htmlize($i->[0])."\">".$i->[1]);
		}
	}

	return join("\n", @tmp);
}

sub rearrange_as_tree
{
 my ($id,$level,$tmp, $sort, $multi) = @_;
 my $rows = [];


# adding $id to list
if(defined $tmp->{$id}->{'data'}){
	my $m = $#{$tmp->{$id}->{'data'}};
	$tmp->{$id}->{'data'}->[$m+2] = $level;
	$tmp->{$id}->{'data'}->[$m+1] = ($level-1)*$multi+int($multi/2);
	push @$rows, $tmp->{$id}->{'data'}; 
}


# following for its children

my @list;

if(defined $tmp->{$id}->{'children'} && $sort && $#{$tmp->{$id}->{'children'}} > -1){
 @list = sort { $tmp->{$a}->{'data'}->[1] cmp $tmp->{$b}->{'data'}->[1]   } @{$tmp->{$id}->{'children'}};
} else {
 @list = @{$tmp->{$id}->{'children'}} if( defined $tmp->{$id}->{'children'} );
}

for my $child(@list){
	push @$rows,@{rearrange_as_tree($child,$level+1,$tmp,$sort,$multi)} if(defined $tmp->{$child}->{'data'}->[1]); # recursive call for the children
 }

return $rows;
}

sub process_atom_lib
{
 my ($atom_name) = @_;
 
 my $al = load_template($atom_name.'.al',$hl{'langid'});
 my $atoms_text = get_atoms_text($al);

 for my $text(@$atoms_text){

  my $new_atom = get_atom_structure($text);

	if($new_atom->{'name'} ne $atom_name){

#		log_printf(Dumper($new_atom));

    push_error('process_atom_lib: suspicious atom name. Please, see '.$atom_name.'.al');
	}

	unless(defined $iatoms->{$new_atom->{'name'}}){
	  push_error('Can\'t load atom with invalid name');
	} else{ 
	   unless(defined $new_atom->{'class'}){
		   $new_atom->{'class'} = 'default';
		 }
	   $atoms->{$new_atom->{'class'}}->{$new_atom->{'name'}} = $new_atom; 
	}
 }
 return $atoms;
}

sub process_atom_ilib
{
 my ($atom_name) = @_;
 my $tmp = '';

 my $ail = load_template($atom_name.'.ail');
 my $atoms_text = get_atoms_text($ail);

 for my $text(@$atoms_text){
  my $new_atom = get_iatom_structure($text);
	if($new_atom->{'name'} ne $atom_name){
    push_error('process_atom_ilib: suspicious atom name. Please, see '.$atom_name.'.ail');
	}

	unless($new_atom->{'name'}){
    push_error('process_atom_ilib: can\'t load atom with undefined name');
	} else{ 
	  $iatoms->{$new_atom->{'name'}} = $new_atom; 
	}
 }
 return $tmp;
}

sub load_complex_template
{
my ($file, $langid) = @_;

my $text = '';
$text = load_template($file,$langid);

$atoms = '';
$atoms = get_atoms_text($text);

my $template;
   $template = get_atom_structure($atoms->[0]) if ($atoms->[0]);

for my $item(keys %$template){
	$template->{$item} =~s/\\([\{\}])/$1/g;
}

return $template;
}

sub load_email_template{
	my ($template_id) = @_;	
	my $email_text;

	if(!$hl{'langid'}){ $hl{'langid'} = 1;}
	
 	process_atom_ilib($template_id);
 	process_atom_lib($template_id);
	
#  process_atom_ilib("email");
#  process_atom_lib("email");
  return $email_text;
}

sub form_bit_strings {
	my $key = shift;
	my $search_string = "";
	my $field;
	
	#search by descriptions in products ratings
	if ($key eq 'rating') {
		$field = '_description';
	}
	elsif ($key eq 'vocabulary') {
		$field = '_local_value';
	}
	else {
		return;
	}
	
	my $lang_flag = shift;
	my $pattern = "";
	my $mask = "";
	my $lang_codes = do_query("select short_code from language order by langid asc");
	my @arr;

	for my $code (@$lang_codes) {
		push @arr, $code->[0];
	}
	
	my @descriptions;
	for (my $i = 0; $i <=$#arr; $i++) {
	  $descriptions[$i] = $hin{$arr[$i].$field};
	}
	
	# form string in define/undefine format
	# def_undef = '101' => en = 1, nl = 0/1, fr = 1
	for (my $cnt = 0; $cnt <= $#descriptions; $cnt++) {
		if (! defined $descriptions[$cnt] || ($descriptions[$cnt] == 0)) {
			substr($pattern, 0, 0) = "0";
		}
		else {
			substr($pattern, 0, 0) = "1";
		}
	}
	
	# form mask define/undefine
	# search = 'Def Undef Def' => $mask = 010
	for (my $cnt = 0; $cnt <= $#descriptions; $cnt++) {
		if (! defined $descriptions[$cnt]) {
			substr($mask, 0, 0) = "1";
		}
		else {
			substr($mask, 0, 0) = "0";
		}
	}
	
	#form not mask, not pattern
	my $not_pattern = 2**($#descriptions + 1) -1 - bin2dec($pattern);
	my $not_mask = 2**($#descriptions + 1) -1 - bin2dec($mask);

#	log_printf("mask = ".$mask.", pattern = ".$pattern);
	
	$mask = bin2dec($mask);
	$pattern = bin2dec($pattern);
	$search_string = "((($mask | $lang_flag) & $pattern) = $pattern) and ((($not_mask & $lang_flag) & $not_pattern) = 0)";
	
	#fo future sessions
	for (my $i = 0; $i <=$#arr; $i++) {
		if (defined $hin{$arr[$i].$field}) {
			$hout{$arr[$i].$field.'_saved'} = $hin{$arr[$i].$field};
		}
	}
	
	return $search_string;
} # sub form_bit_strings																																	

sub dec2bin {
	 my $str = unpack("B32", pack("N", shift));
	 $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
	 return $str;
}

sub bin2dec {
	 return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub html2text
{
  my ($text) = @_; my $tags;
	
  @{$tags} = ("<a>", "<br>", "<i>", "<b>", "<h1>", "<h2>", "<h3>", "<h4>", "<table>", "<tr>", "<td>", "<li>", "<ul>", "<p>", "<div>");
			
  $text =~ s/(<\s*\/?([^\s=>]*).*?>)   # match exactly html tag
  / grep(m|^\Q$2\E$|i, @{$tags}) # if the first non-whitespace token in the tag
  # can be found in @tags, keep it
  ? $1 : "" /isegx;     # otherwise, remove tag
							
 return $text;
}

sub text2html {
  my ($text) = @_;

	use HTML::FromText;

	my $t2h = HTML::FromText->new({
		lines => 1,
																});
	my $html = $t2h->parse($text);

	return $html;
}

sub remove_www_links {
  my $str = shift;
	return undef unless $str;
	$str =~ s/([a-z\.\-\_]+\.(?:com|nl|org|net))//gsi;
	return $str;
} # sub remove_www_links

sub code{
  my ($str) = @_;
  $str =~ s/\//\|/g;
  my $hp = escape('#');
  my $plus = escape('+');
  my $quest = escape('?');
  $str =~ s/#/$hp/g;
  $str =~ s/\+/$plus/g;
  $str =~ s/\?/$quest/g;
  return $str;
}

sub Array2Epoch {
    my ($y,$m,$d,$h,$mm,$ss) = @_;
    
    return mktime($ss || 0, $mm || 0, $h || 0, $d || 1, ($m || 1)-1, $y - 1900, 0, 0, -1);
} # sub Array2Epoch

sub regexp2mysql {
	my ($str) = @_;
	$str =~ s/\\d/[[:digit:]]/g;
	$str =~ s/\\W/[[:digit:]]/g;
	$str =~ s/\\w/([[:alpha:]]|[[:digit:]])/g;
	$str =~ s/\\D/[[:alpha:]]/g;
	return $str;
}

sub shortify_str{
	my($str,$cnt,$end_str)=@_;
	my $result=substr($str,0,$cnt);
	if($result ne $str){
		return $result.$end_str;
	}else{
		return $str;
	}	 
}

sub trim{
	  my $str = shift;
	  $str=~s/^\s*(.*?)\s*$/$1/;
	  return $str;   	
}

# return hash for import purposes
# key = short_code, value = langid
sub get_langid_hash {

    my $ref = {};
    my $ans = atomsql::do_query('SELECT langid, short_code FROM language');
    for (@$ans) {
	$ref->{$_->[1]} = $_->[0];
    }
    return $ref;
}

sub get_percent{
	my ($value,$from) = @_;
	if(!$from){
		return '';
	}else{
		my $float=$value/$from*100;
		
		$float=~/(^[^\.]+[\.]{0,1}.{0,2})/;
		if($1){
			return $1.'%';
		}else{
			return '0%';
		}
	};
}

sub make_category_feature_intervals {

    my $cf_id = shift;
    my $ans = atomsql::do_query("SELECT value,COUNT(*) FROM product_feature
	WHERE category_feature_id = " . $cf_id. " GROUP BY 1");
    my ($a_total, $a_fract, $a_dec, $sum_invalid) = (0,0,0,0);
    my $fracts = {};
    my $decimals = {};
    my $invalid = {};
	
    # analyze a set of values
    for (@$ans) {
        $a_total += $_->[1];
	# if decimal fract
        if ($_->[0] =~ /^([1-9][0-9]*|0)\.[0-9]+$/x) {
	    $_->[0] =~ s/\.*0+$//g; # delete last zero's
            $a_fract += $_->[1];
	    if ($fracts->{$_->[0]}) {
		$fracts->{$_->[0]} += $_->[1];
	    } else {
		$fracts->{$_->[0]} = $_->[1];
	    }
	# if decimal
        } elsif ($_->[0] =~ /^([1-9][0-9]*|0)$/ ) {
            $a_dec += $_->[1];
	    $decimals->{$_->[0]} = $_->[1];
        } else {
	    $invalid->{$_->[0]} = $_->[1];
            $sum_invalid += $_->[1];
	}
    }
	
    # danger!!!, division by zero can happen
    return if (! $a_total);

    # select best valid array
    my ($valid, $sum_valid) = ($a_fract / $a_total > 0.05) ? 
	    ($fracts, $a_fract) :
	    ($decimals, $a_dec);
		
    # sorted array of valid keys
    my $valids = [sort {$a <=> $b} keys %$valid];
    
    # count of valid keys
    my $count = scalar @$valids;

    return if $count <= 1; # can't split one value into intervals
    
    my $target = 7; # split into 7 intervals

    my $result = {};

    my ($begin, $end, $size, $idx, $interval) = (0,0,0,0,1);

    # if we can't split into target intervals
    if ($count < ($target * 2)) {
	my $rest = $count % $target;
	my $step = int ($count / $target);
	my $from = ($valids->[0]) ? '...' : 0;
	my $i = 0;
	my $steps = {}; # intervals
	my $sums = []; # product's counts in the intervals

	# make intervals uniformly distributed if there are more than target features
	if ($step == 1 && $rest > 0) {
	    for (my $j = 0; $j < $rest; $j++) {
		my $tmp_key = shift @$valids;
		$from = shift @$valids;
		$steps->{$tmp_key} = $from;
		push @$sums, ($valid->{$tmp_key} + $valid->{$from});
	    }
	}

	# make a hash of intervals
	for (@$valids) {
	    $steps->{$from} = $_;
	    unless ($from) {
		push @$sums, $valid->{$_};
	    } else {
		push @$sums, ($valid->{$from} + $valid->{$_});
	    }
	    $from = $valids->[$i++];
	}
	    
	# add infinity interval to the end if there are less than target features
	if ($step == 0) {
	    $steps->{$from} = '...';
	    push @$sums, $valid->{$from};
	}
	
	my $interval = 1;

	# make result
	for (sort {$a <=> $b} keys %$steps) {
	    my $sum = shift @$sums;
	    $result->{$interval} = 
		$_ . '-' . $steps->{$_} . " <" . $sum . ">";
	    $interval++;
	}
    }
    # if we can split into target intervals
    else {
	my $rest = $count % $target;
	my $steps = [(int ($count / $target)) x $target];
    
	# make intervals uniformly distributed
	if ($rest > 1) {
	    my $i = scalar @$steps - 1;
	    while ($rest--) { $steps->[$i--]++ }
	} elsif ($rest == 1) {
	    $steps->[scalar @$steps - 1]++;
	}

	# make result
	for my $step (@$steps) {
	    $begin = $idx;
	    while ($idx < ($begin + $step)) {
		$size += $valid->{$valids->[$idx]};
		$idx++;
	    }
	    $end = $idx - 1;
	    $result->{$interval} = 
			    $valids->[$begin] . '-' . $valids->[$end] . " <" . $size . ">";
	    $interval++;
	    $size = 0;
	}
    }
    
    # make record for DB
    
    my $inter_arr = [];
    my $in_each_arr = [];
    
    for (values %$result) {
        /^(.*)\s<(\d+)>$/;
        push @$inter_arr, $1;
        push @$in_each_arr, $2;
    }
	
    my $inter = join "\n", @$inter_arr;
    my $in_each = join "\n", @$in_each_arr;
    my $invalid_values = join "\n", keys %$invalid;

    $invalid_values = atomsql::str_sqlize($invalid_values);
    $inter = atomsql::str_sqlize($inter);
    $in_each = atomsql::str_sqlize($in_each);
    # insert new values into temporary table
    atomsql::do_statement("INSERT INTO cf_interval
	(category_feature_id, intervals, in_each, valid, invalid, invalid_values) VALUES
	($cf_id, $inter, $in_each, $sum_valid, $sum_invalid, $invalid_values)");
    
    return;
}

sub diff_table_md5 {
	my ($table, $id) = @_;

	# get the cached md5
	my $cached_md5 = _get_table_md5_from_cache($table, $id);
	
	# generate the current md5
	my $new_md5 = _prepare_table_md5($table, $id);

	# return diff

	return $cached_md5 ne $new_md5->[0];
} # sub diff_table_md5

sub _prepare_table_md5 {
	my ($table, $id) = @_;
	
	my $new_md5 = '';
	my $string = '';
	my $lang_clause = ' and langid = 1 '; # cause of 2010-12-17 fatal product changes and we already have multilingual issue for daily indexes also (thanks to Alexey Artukh :D and me)
#	my $lang_clause = ' ';

	if ($table eq 'measure') {

		$string = encode_utf8(atomsql::do_query("select concat(

(select group_concat(v.value separator ',') from vocabulary v where v.sid = m.sid ".$lang_clause." group by v.sid order by v.langid asc),
(select group_concat(ms.value separator ',') from measure_sign ms where ms.measure_id = m.measure_id ".$lang_clause." group by ms.measure_id order by ms.langid asc),
m.sign, ',',
m.system_of_measurement

) from measure m where m.measure_id = ".$id)->[0][0]);
		$new_md5 = md5_hex($string);

	}
	elsif ($table eq 'feature') {

		$string = encode_utf8(atomsql::do_query("select concat(

(select group_concat(v.value separator ',') from vocabulary v where v.sid = f.sid ".$lang_clause." group by v.sid order by v.langid asc),
f.type, ',',
f.class, ',',
f.limit_direction, ',',
f.searchable

) from feature f where f.feature_id = ".$id)->[0][0]);
		$new_md5 = md5_hex($string);

	}
	elsif ($table eq 'category') {
		
		$string = encode_utf8(atomsql::do_query("select concat(

(select group_concat(v.value separator ',') from vocabulary v where v.sid = c.sid ".$lang_clause." group by v.sid order by v.langid asc),
c.pcatid, ',',
c.ucatid, ',',
c.searchable, ',',
c.visible, ',',
c.low_pic

) from category c where c.catid = ".$id)->[0][0]);
		$new_md5 = md5_hex($string);

	}

	return [ $new_md5, length($string) ];
} # sub _prepare_table_md5

sub _get_table_md5_from_cache {
	my ($table, $id) = @_;
	
	return atomsql::do_query("select md5_hash from update_product_md5_cache where table_name = ".atomsql::str_sqlize($table)." and table_id = ".$id)->[0][0];
} # sub _get_table_md5_from_cache

sub update_table_md5 {
	my ($table, $ids) = @_;

#	print "sub update_table_md5 = ".Dumper(\@_);

	$ids =~ s/^\((.*)\)$/$1/s;
	my @arr = split ',', $ids;

	for (@arr) {
#		print $_." ";
		my $new_md5 = _prepare_table_md5($table, $_);
		if (atomsql::do_query("select 1 from update_product_md5_cache where table_name=".atomsql::str_sqlize($table)." and table_id=".$_)->[0][0]) {
			atomsql::do_statement("update update_product_md5_cache set md5_hash=".atomsql::str_sqlize($new_md5->[0]).", size=".$new_md5->[1]."
where table_name=".atomsql::str_sqlize($table)." and table_id=".$_);
		}
		else {
			atomsql::do_statement("insert into update_product_md5_cache(md5_hash,table_name,table_id,size)
values(".atomsql::str_sqlize($new_md5->[0]).",".atomsql::str_sqlize($table).",".$_.",".$new_md5->[1].")");
		}
	}

} # sub update_table_md5

sub get_remote_distributor {

    my $did = shift;

    my $soap = SOAP::Lite->service($atomcfg{'soap_url'});
    
    my $req = do_query("
        SELECT code FROM distributor
        WHERE distributor_id = $did
    ")->[0][0];
    
    my $res = $soap->getDistriInfoForICEcat($req);
	return '' if ref($res) ne 'HASH';    
    my $vis = ($res->{'icecat_distri_info'}->{'visibility'} == 0) ? 'no' : 'yes';
    my $str =
        " (remote visibility = " . $vis . ", ".
        "remote country = " . $res->{'icecat_distri_info'}->{'country_code'}. ")";
    
    # log_printf(Dumper($res));
    
    return $str;
}

sub sync_all_distributors {

    log_printf("Distributors SYNC in action ...");
    my $soap = SOAP::Lite->service($atomcfg{'soap_url'});
    my $res;
    
    my $dist_codes = atomsql::do_query("SELECT code FROM distributor WHERE source = 'iceimport'");
    
    # make countries hash
    my %countries;
    my $countries = atomsql::do_query("SELECT country_id, code FROM country");
    for (@$countries) {
        $countries{$_->[0]} = $_->[1];
    }
    
    my $local_d;
    my $local_country_id;
    my $local_is_direct;
    my $local_visible;
    
    my $remote_visible;
    my $remote_country_id;
    
    my $req = '';
    # make SOAP request
    
    my $cc = 0;
    for (@$dist_codes) {
        $req .= $_->[0] . "^";
        $cc++;
    }
    $req =~ s/\^$//;
    
    log_printf("TO SOAP " . $cc);
    # execute SOAP request
    $res = $soap->getDistriInfoForICEcat($req);
    
    # exit if no answer
    if (! $res) {
        log_printf('No answer for SOAP request');
        return;
    }
    
    my @dist_info = @{ $res->{'icecat_distri_info'} };
    log_printf("FROM SOAP " . scalar @dist_info );
    
    my $upd_distri = sub {
        my $code = shift;
        my $val = shift;
        if ($val) {
            atomsql::do_statement("UPDATE distributor SET sync = 1 WHERE code = " . atomsql::str_sqlize($code) );
            log_printf("Update -- OK");
        }
        else {
            atomsql::do_statement("UPDATE distributor SET sync = 0 WHERE code = " . atomsql::str_sqlize($code) );
            log_printf("Update -- NOT OK");
        }
        return;
    };
    
    my $add_remote_data = sub {
        my $dist_id = shift;
        my $visible = shift;
        my $country = shift;
        
        my $res = '<input type="hidden" id="remote_visible_value_for_' . $dist_id . '" value="' . $visible . '">';
        $res .= '<input type="hidden" id="remote_country_value_for_' . $dist_id . '" value="' . $country . '">';
        return $res;
    };
    
    my $result;
    my $c = 0;
	
    for ( @dist_info ) {
		
        $result .= $_->{'distri_code'} . '^';
        $c++;
        
        if ((! $_->{'visibility'}) and (! $_->{'country_code'} ) ) {
            log_printf("ERROR !!! No data for " . $_->[0]);
            $result .= "UNDEF\n";
            next;
        }
        
        if (! $_->{'country_code'} ) {
            log_printf("ERROR !!! Empty country for : " . $_->[0]);
            $result .= "UNDEF\n";
            next;
        }
        
        $remote_visible = $_->{'visibility'};
        $remote_country_id = $_->{'country_code'};
        
        # get local data
        my $q = "SELECT country_id,visible,direct FROM distributor WHERE code = " . atomsql::str_sqlize($_->{'distri_code'} );
        $local_d = atomsql::do_query($q);
        $local_visible = $local_d->[0]->[1];
        $local_is_direct = $local_d->[0]->[2];
        $local_country_id = $countries{ $local_d->[0]->[0] };
        
        log_printf($_->{'distri_code'} . " : local = ($local_visible, $local_country_id) remote = ($remote_visible, $remote_country_id)" );
        
        if ( $local_is_direct == 0) {
            $result .= "<span>---</span>\n";
            next;
        }
        
        if ( ($local_visible != $remote_visible) || ($local_country_id ne $remote_country_id) ) {
            $upd_distri->($_->{'distri_code'}, 0 );
            $result .= "<span style='color: red;'>NOT&nbsp;OK</span>\n";
        } 
        else {
            $upd_distri->($_->{'distri_code'}, 1 );
            $result .= "<span style='color: green;' >OK</span>\n";
        }
    }
    log_printf("TOTAL : " . $c);
    
    $result =~ s/\n$//;
	
	# build array of codes that weren't been retreived via SOAP	
	my %seen = ();
	my @local_only = ();
	
	for my $item (@dist_info) { $seen{$item->{'distri_code'}} = 1 };
	
	for my $item(@$dist_codes) {
		unless ($seen{$item->[0]}) {
			push @local_only, $item->[0];
		}
	}
	
	for (@local_only) {
		atomsql::do_statement("UPDATE distributor SET sync = NULL WHERE code = '$_'");
            log_printf("Update -- NULL");
	}
    
    return $result;
}

sub url2scp_path {
    my $s = shift;
    # http://127.0.0.1/img/norm/high/3950943-9219.jpg
    $s =~ /:\/\/([^\/]+?)\/(.*)$/;
    $s = $1 . ":" . $atomcfg{'images_www_path'} . $2;
    return $s;
};

sub get_name_from_url {
    my $s = shift;
    $s =~ /\/([^\/]+)$/;
    my $name = $1;
    return $name;
};

sub count_features_for_ej {
    my $p = shift;
    
    # this 2 args contain SQL conditions for EJ column 'date'
    # $p->{'to_date'});
    # $p->{'from_date'});
    
    # casual integer values
    # $p->{'user_id'};      # contain 'ej.user_id = x' in second case
    # $p->{'product_id'};   # will not contain anything in second case
    
    # if search tail defined we should invoke SQL request for summary value
    my $search_tail = $p->{'search_tail'};
    my $uid = $p->{'user_id'};
    my $pid = $p->{'product_id'};
    my $d1 = $p->{'to_date'};
    my $d2 = $p->{'from_date'};
    
    my $ans;
    if (! $search_tail) {
        # for certain product
        $ans = do_query("
            SELECT data
            FROM editor_journal INNER JOIN editor_journal_product_feature_pack USING (content_id)
            WHERE product_table = 'product_feature'
            AND user_id = $uid
            AND product_id = $pid
            AND $d1 AND $d2
        ");
    }
    else {
        # any product + search tail
        $ans = do_query("
            SELECT data
            FROM editor_journal ej INNER JOIN editor_journal_product_feature_pack USING (content_id)
            WHERE product_table = 'product_feature'
            AND $uid
            AND $d1 AND $d2
            AND $search_tail
        ");
    }
    
    return -666 if (! $ans);
    
    my $warehouse = {};
    my $add_to_warehouse = sub {
        my $a = shift;
        for my $elem (keys %$a) {
            $warehouse->{$elem} = 1;
        }
        return;
    };

    my $c = 0;
    my ($d, $ref);
    for my $r (@$ans) {
        $d = $r->[0];
        $ref = ser_unpack($d);
        $add_to_warehouse->($ref);
    }
    
    return scalar keys %{$warehouse};
}

sub get_restricted_products_from_db {
    
    my $langid = shift;
    my $supplier_id = shift;
    my $subscription_level = shift;
    
    my $res = [];
    my $q;
    
    # make query
    $q = "SELECT supplier_id,id FROM product_restrictions WHERE langid = $langid ";
    if ($supplier_id != 0) {
        $q .= " AND supplier_id = $supplier_id";
    }
    if ($subscription_level eq 'all') {
        $q .= " AND subscription_level = 1";
    }
    if ($subscription_level eq 'freexml') {
        $q .= " AND ( subscription_level = 1 OR subscription_level = 2 )";
    }
    my $suppliers = atomsql::do_query($q);
    
    # fetch RES data
    for my $s (@$suppliers) {
        
        my $element = {};
        $element->{'supplier_id'} = $s->[0];
        
        my $rest_id = $s->[1];
        $q = "
            SELECT prod_id, p.product_id
            FROM product_restrictions_details prd
            INNER JOIN product p ON (prd.product_id = p.product_id)
            WHERE restriction_id = $rest_id
        ";
        my $ans = atomsql::do_query($q);
        # convert answer to comma separated list
        my $list = '';
        my $list2 = '';
        for my $x ( @$ans ) {
            $list .= $x->[0] . ",";
            $list2 .= $x->[1] . ",";
        }
        $list =~ s/,$//;
        $list2 =~ s/,$//;
        
        $element->{'prod_id_set'} = $list;
        $element->{'product_id_set'} = $list2;
        
        push @$res, $element;
    }
    
    # lp(Dumper($res)) if ($langid == 1);
    
    return $res;
};

1;


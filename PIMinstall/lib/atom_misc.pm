package atom_misc;

#$Id: atom_misc.pm 3737 2011-01-18 15:30:09Z dima $

use strict;

use atomcfg;
use atomsql;
use atomlog;

use atom_html;
use atom_util;
use atom_mail;

use thumbnail;
use icecat_util;

use Data::Dumper;
use Time::Local;
use LWP::Simple;
use LWP::Simple qw($ua); $ua->timeout($atomcfg{'http_request_timeout'});

use MIME::Types;
use Text::Levenshtein qw/fastdistance/;

use POSIX qw(strftime);

use vars qw ($clipboard_objects $foreign_words);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw(
    &make_code
    $clipboard_objects
	&escape
    &unescape
    &repl_ph
    &s_repl_ph
							 
	&login_user
							 
	&get_ip_addr
	&verify_address
							 
	&get_quality_measure
	&get_quality_index
							 
	&maintain_category_feature_group
							 
	&get_obj_url
	&family_count
							 
	&verify_login_expiration_date
							 
	&get_language_flag
	&get_complaint_email_body
							 
	&get_gallery_pic_params
	&get_obj_size
	&get_obj_width_and_height
	&makedir
	&make_authmysql_htaccess
	&in_selected_sponsors
	&symlink
	&generate_html_key
	&get_supplier_user_id

	&nonEn_value

	&approx

	&get_product_relations_amount
	&get_product_relations_set_amount
	&get_products_related_by_product_id

	&get_family_children_list

    &get_prod_ids_list

	&xsd_header
	&xml_utf8_tag

	&remove_Philips_DE_content
	&remove_index_xml_item_by_supplier_id
	&remove_index_csv_item_by_supplier_id

	&form_presentation_value
	&format_date

	&get_exponent

	&months2numbers
    );
}

sub months2numbers {
	my ($w) = @_;

	my $w2d = {
		'Jan' => '01',
		'Feb' => '02',
		'Mar' => '03',
		'Apr' => '04',
		'May' => '05',
		'Jun' => '06',
		'Jul' => '07',
		'Aug' => '08',
		'Sep' => '09',
		'Oct' => '10',
		'Nov' => '11',
		'Dec' => '12'
	};

	return $w2d->{$w};
} # sub months2numbers

sub get_exponent {
	my ($number) = @_;

	return 0 unless $number;

	my $exponent = 0;

	$number = 0 - $number if $number < 0;

	if ($number >= 1) { # from 1 to unlimited
		while ($number >= 1) {
			$number /= 10;
			$exponent++;
		}
	}
	else { # from -1 to -unlimited
		while ($number < 1) {
			$number *= 10;
			$exponent--;
		}
	}

	return $exponent;
} # sub get_exponent

sub format_date {
	my ($time) = @_;
	my $generated = strftime("%Y%m%d%H%M%S", localtime($time));
	return $generated;
}

sub form_presentation_value {
	my ($value, $unit) = @_;

	return (($value =~ /([^a-zA-Z]|^)[0-9]+\s*$/) && ($unit ne '')) ? $value.(($unit ne '')?" ":"").$unit : $value;
} # sub form_presentation_value

sub get_prod_ids_list {
	my ($list, $save_only_1st) = @_;
	
	my ($prod_ids, $prod_ids_raw);

	$list =~ s/^\s*(.*?)\s*$/$1/s;
	@$prod_ids_raw = split "\n", $list;

	$#$prod_ids_raw = 0 if ($save_only_1st);

	for (@$prod_ids_raw) {
		s/^\s*(.*?)\s*$/$1/s;
		next if $_ eq '';
		push @$prod_ids, $_;
	}

	return $prod_ids;
} # sub get_prod_ids_list

sub get_products_related_by_product_id { # was updated - via MySQL stored procedures
	my ($product_id) = @_;

	my ($result_pids);
	my $rels = atomsql::do_query("CALL main_relations_by_product($product_id)");
	return undef unless $rels->[0][0];

	for my $rel (@$rels) {
		my $tmp_arr = get_product_relations_set_amount($rel->[0], $rel->[1], 1);
		for my $pids (@$tmp_arr) {
		 push @$result_pids, $pids;
		}
	}

	return $result_pids;
} # get_products_related_by_product_id

sub get_product_relations_amount { # to update, obsolete
	my ($supplier_id, $supplier_family_id, $catid, $feature_id, $feature_value, $exact_value, $prod_id, $start_date, $end_date) = @_;

	my $jc = _get_join_and_condition($supplier_id, $supplier_family_id, $catid, $feature_id, $feature_value, $exact_value, $prod_id, $start_date, $end_date);

	my $result = atomsql::do_query("select count(distinct local_p.product_id) from product local_p ".$jc->{'join'}." where ".$jc->{'condition'})->[0][0];

	return $result;
} # sub get_product_relations_amount

#
# get_product_relations_set_amount - to count number of products per specified part (left or right) of relation (x-sell) rule
#

sub get_product_relations_set_amount {
	my ($relation_id, $field, $is_products) = @_;

	# select proper part of rule
	my $suffix = '';
	if ($is_products) { # checking if subroutine was invoked by get_products_related_by_product_id()
		if ($field !~ /\_2$/) {
			$suffix = '_2';
		}
	}
	else {
		if ($field =~ /\_2$/) {
			$suffix = '_2';
		}
	}

	my $i_id = atomsql::do_query("select rr.supplier_id, rr.supplier_family_id, rr.catid, rr.feature_id, rr.feature_value, rr.exact_value, rr.prod_id, rr.start_date, rr.end_date
from relation r
inner join relation_set rs  on r.include_set_id".$suffix."=rs.relation_set_id
inner join relation_rule rr on rs.relation_rule_id=rr.relation_rule_id
where r.relation_id=".$relation_id);

	my $jc;

	atomsql::do_statement("drop temporary table if exists itmp_decide_products");
	atomsql::do_statement("create temporary table itmp_decide_products (product_id int(13) not null, unique key (product_id))");

	for (@$i_id) {
		$jc = _get_join_and_condition($_->[0], $_->[1], $_->[2], $_->[3], $_->[4], $_->[5], $_->[6], $_->[7], $_->[8]);
		atomsql::do_statement("insert ignore into itmp_decide_products(product_id) select distinct local_p.product_id from product local_p ".$jc->{'join'}." where ".$jc->{'condition'});
	}

	my $e_id = atomsql::do_query("select rr.supplier_id, rr.supplier_family_id, rr.catid, rr.feature_id, rr.feature_value, rr.exact_value, rr.prod_id, rr.start_date, rr.end_date
from relation r
inner join relation_set rs  on r.exclude_set_id".$suffix."=rs.relation_set_id
inner join relation_rule rr on rs.relation_rule_id=rr.relation_rule_id
where r.relation_id=".$relation_id);

	for (@$e_id) {
		$jc = _get_join_and_condition($_->[0], $_->[1], $_->[2], $_->[3], $_->[4], $_->[5], $_->[6], $_->[7], $_->[8]);
		atomsql::do_statement("drop temporary table if exists itmp_products_to_delete");
		atomsql::do_statement("create temporary table itmp_products_to_delete (product_id int(13) not null, unique key (product_id))");
		atomsql::do_statement("LOCK TABLES product local_p READ");
		atomsql::do_statement("insert into itmp_products_to_delete(product_id) select distinct local_p.product_id from product local_p ".$jc->{'join'}." where ".$jc->{'condition'});
		atomsql::do_statement("UNLOCK TABLES");
		atomsql::do_statement("delete tdp from itmp_decide_products tdp inner join itmp_products_to_delete tptd using (product_id)");
		atomsql::do_statement("drop temporary table if exists itmp_products_to_delete");
	}

	my $result;
	if ($is_products) {	# checking if subroutine was invoked by get_products_related_by_product_id()
		my $res = atomsql::do_query("select product_id from itmp_decide_products");
		@$result = map {$_->[0]} @$res;
	}
	else {
		$result = atomsql::do_query("select count(product_id) from itmp_decide_products")->[0][0];
	}
	atomsql::do_statement("drop temporary table if exists itmp_decide_products");

	return $result;	
} # get_product_relations_set_amount

sub get_product_relations_list {
	my ($relation_ids) = @_;

	my ($result, $r_id, $jc);
	atomsql::do_statement("drop temporary table if exists itmp_rel_products");
	atomsql::do_statement("create temporary table itmp_rel_products (product_id int(13) not null primary key)");
	for my $id (@$relation_ids) {
		$r_id = atomsql::do_query("select supplier_id, supplier_family_id, catid, feature_id, feature_value, exact_value, prod_id, start_date, end_date from relation where relation_id=".$id." limit 1")->[0];
		$jc = _get_join_and_condition($r_id->[0], $r_id->[1], $r_id->[2], $r_id->[3], $r_id->[4], $r_id->[5], $r_id->[6], $_->[7], $_->[8]);
		atomsql::do_statement("insert ignore into itmp_rel_products(product_id) select distinct local_p.product_id from product local_p ".$jc->{'join'}." where ".$jc->{'condition'});
	}

	$result = atomsql::do_query("select product_id from itmp_rel_products");
	atomsql::do_statement("drop temporary table if exists itmp_rel_products");
	return $result;
} # sub get_product_relations_list

sub _get_join_and_condition { # should be reworked
	my ($supplier_id, $supplier_family_id, $catid, $feature_id, $feature_value, $exact_value, $prod_id, $start_date, $end_date) = @_;

	my $ijoin = '';
  my $icondition = ' 1 ';

	# add HARD condition - owned products only (dima, from Martijn's answer on letter (25-05-2009): "Re: Dynamical relations current problem.")
	$icondition .= ' and local_p.user_id > 1 ';

  my $ijoin_local = '';
  my $icondition_local = ' 1 ';

	$prod_id =~ s/^\s*(.*)\s*$/$1/s;

	# add date/time condition
	if (($start_date != '') || ($end_date != '')) {
		if (atomsql::do_query('select unix_timestamp('.atomsql::str_sqlize($start_date).')')->[0][0]) {
			$icondition .= ' and local_p.date_added >= '.atomsql::str_sqlize($start_date);
		}
		if (atomsql::do_query('select unix_timestamp('.atomsql::str_sqlize($end_date).')')->[0][0]) {
			$icondition .= ' and local_p.date_added <= '.atomsql::str_sqlize($end_date);
		}
	}

	# add prod_id condition
	if ($prod_id ne '') {

		# check prod_ids
		my $prod_ids = get_prod_ids_list($prod_id);

		for (my $i=0; $i<=$#$prod_ids; $i++) {
			$prod_ids->[$i] = atomsql::str_sqlize($prod_ids->[$i]);
		}

		if ($#$prod_ids == 0) {
			$icondition .= ' and local_p.prod_id = '.$prod_ids->[0];
		}
		elsif ($#$prod_ids > 0) {
			$icondition .= ' and local_p.prod_id in ('.join(',',@$prod_ids).')';
		}
		else {
			$icondition .= ' 0';
		}

		if ($supplier_id) {
			$icondition .= ' and local_p.supplier_id = '.$supplier_id;
		}
	}
	else { # if prod_id is empty
		# add supplier condiiton
		if ($supplier_id) {
			$icondition .= ' and local_p.supplier_id='.$supplier_id;
			$ijoin_local = ' inner join product local_p on pf.product_id=local_p.product_id ';
			$icondition_local = $icondition;
			
			if ($supplier_family_id > 1) { # get all children of family_id
				my $children_arr = get_family_children_list($supplier_family_id);
				$icondition .= ' and local_p.family_id in ('.(join(',',@$children_arr)).')';
			}
		}
		
		# add category condition
		if ($catid) {
			# add feature condition
			if ($feature_id && defined $feature_value && ($feature_value ne '')) {
				my $pfvalue = ' 1 ';
				if ($exact_value == 2) { # exact-mode
					$pfvalue = 'pf.value = '.atomsql::str_sqlize($feature_value);
				}
				elsif ($exact_value == 3) { # > mode
					$pfvalue = 'convert(pf.value, decimal(32,3)) > convert('.atomsql::str_sqlize($feature_value).', decimal(32,3))';
				}
				elsif ($exact_value == 4) { # < mode
					$pfvalue = 'convert(pf.value, decimal(32,3)) < convert('.atomsql::str_sqlize($feature_value).', decimal(32,3))';
				}
				elsif ($exact_value == 5) { # <> mode
					$pfvalue = 'pf.value <> '.atomsql::str_sqlize($feature_value);
				}
				elsif ($exact_value == 1) { # like-mode
					$feature_value =~ s/\%/\\\%/gs;
					$feature_value =~ s/\_/\\\_/gs;
					$feature_value = '%'.$feature_value.'%';
					$pfvalue = 'pf.value like '.atomsql::str_sqlize($feature_value);
				}
				else {
					$pfvalue = '0'; # do not touch anything
				}
				atomsql::do_statement("drop temporary table if exists itmp_product");
				atomsql::do_statement("create temporary table itmp_product (product_id int(13) not null primary key)");
				atomsql::do_statement("insert into itmp_product (product_id)
select distinct pf.product_id
from category_feature cf
inner join product_feature pf on cf.category_feature_id=pf.category_feature_id ".$ijoin_local."
where cf.catid=".$catid." and cf.feature_id=".$feature_id." and ".$pfvalue." and ".$icondition_local);
				
				$ijoin .= ' inner join itmp_product tp using (product_id) ';
			}
			else {
				$icondition .= ' and local_p.catid='.$catid;
			}
		}
		elsif (!$supplier_id) {
			$icondition = ' 0 ';
		}
	}

	return { 'join' => $ijoin, 'condition' => $icondition };
} # sub _get_join_and_condition

sub get_supplier_user_id{
	my $product_id = $_[0];
	return atomsql::do_query("select u.user_id from supplier s,product p, users u where s.supplier_id=p.supplier_id and s.user_id=u.user_id and product_id=$product_id")->[0][0];
}

sub generate_html_key {
	my($product_id,$action,$fuser_id) = @_;
	
	my $key = '';
	my @chars = ('a'..'z');

	for (my $i=1; $i<120; $i++) {
		$key .= $chars[rand($#chars)];
	}

	if ((defined $product_id) && (defined $action) && ($product_id > 0) && ($action ne '')) {
		if ((!defined $fuser_id) || ($fuser_id == 0)) {
			$fuser_id = get_supplier_user_id($product_id);
		}

		if (!$fuser_id) {
			return;
		}

		insert_rows("product_html_key", {
			'user_id' => $fuser_id,
			'product_id' => $product_id,
			'date' => 'NOW()',
			'html_key' => atomsql::str_sqlize($key),
			'action' => atomsql::str_sqlize($action)
		});
	}

	return $key;
}

sub symlink {
	my ($src,$link,$file,$ignore) = @_;
	if (((-e $src.$file)&&(!-e $link.$file)) || ($ignore)) {
	    my $cmd = '/bin/ln -s -f '.$src.$file.' '.$link.$file;
	    `$cmd`; 
	}
} # sub symlink

sub in_selected_sponsors {
	my $sp = atomsql::do_query("select supplier_id from supplier where is_sponsor='Y'");
	my @sponsors;
	for (@$sp) { push @sponsors, $_->[0]; }
	return ' in ('.join(',',@sponsors).')';
}

sub makedir
{
	my ($path) = @_;
	my $cmd;
	if (!-e $path){ $cmd = "mkdir $path";`$cmd`; }
}

sub make_authmysql_htaccess
{
	my ($path,$auth_params) = @_;
	return if (!-e $path);
	open(FH,">$path/.htaccess");
	print FH
		($auth_params->{'directory_index'}?"DirectoryIndex ".$auth_params->{'directory_index'}."\n":"").
		"AuthName \"".$auth_params->{'auth_name'}."\"\n".
		"AuthType Basic\n".
		"AuthBasicAuthoritative Off\n".
		"AuthMySQLHost ".$atomcfg{'dbhost'}."\n".
		"AuthMySQLDB ".$atomcfg{'dbname'}."\n".
		"AuthMySQLUser ".$atomcfg{'dbuser'}."\n".
		"AuthMySQLPassword ".$atomcfg{'dbpass'}."\n".
		"AuthMySQLPwEncryption none\n".
		"AuthMySQLUserTable ".$auth_params->{'user_table'}."\n".
		"AuthMySQLNameField ".$auth_params->{'name_field'}."\n".
		"AuthMySQLPasswordField ".$auth_params->{'pass_field'}."\n".
		"AuthMySQLUserCondition \"".$auth_params->{'condition'}."\"\n".
		"require valid-user";
	close(FH);
}

sub get_quality_measure
{
my ($ug) = @_;
my $q_rate = '';

	 if ($ug eq 'editor' || $ug eq 'supereditor' || $ug eq 'category_manager' || $ug eq 'exeditor' || $ug eq 'superuser'){
	  $q_rate = 'ICECAT'
	 } elsif($ug eq 'supplier'){
    $q_rate = 'SUPPLIER';	 
	 } else {
	  $q_rate = 'NOEDITOR'
	 }

return $q_rate;
}

sub get_quality_index
{
my ($q_rate) = @_;

my $map = 
		{
		 'NOEDITOR' => 0,
		 'ICECAT'		=> 1,
		 'SUPPLIER' => 2
		};

return $map->{$q_rate};

}


sub get_ip_addr
{
 use Socket;
 
 my ($name) = @_;

 my $host = inet_ntoa(inet_aton($name));
 
 return $host;
}

sub login_user
{
my ($login, $pass) = @_;

if($pass){
 my $user_id = atomsql::do_query("select user_id, access_restriction, access_restriction_ip, login_expiration_date, subscription_level from users where login = ".atomsql::str_sqlize($login)." and password = ".atomsql::str_sqlize($pass))->[0];

 if(defined $user_id){
	return 0 if(($user_id->[4]==5)||($user_id->[4]==6));
  if(verify_address($user_id->[1], $user_id->[2], $ENV{'REMOTE_ADDR'} )){
		if($user_id->[3]){
		    $user_id->[3] =~ /^\s*(\d+)\s*-\s*(\d+)\s*-\s*(\d+)\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*/;
		    if(!$1){
			return 0;
		    }
		    log_printf("timelocal: ".timelocal($6, $5, $4, $3, $2 - 1, $1)." time".time);
		    eval{timelocal($6, $5, $4, $3, $2 - 1, $1)};
		    if($@){
			log_printf("login expiration date is wrong: $@");
			return 0;
		    }
		    if(timelocal($6, $5, $4, $3, $2 - 1, $1) < time){
			return 0;
		    }

		}
 		$atom_html::hl{'user_id'} = $user_id->[0];		

 		$atom_util::USER = get_rows('users',"user_id = $atom_html::hl{'user_id'}")->[0];
		
		return 1;
	} else {
	 return 0;
	}
 }
  return 0;
} elsif($login){
 
	my $row = atomsql::do_query('select password, email, login from users,contact where contact_id=pers_cid and login='.atomsql::str_sqlize($login));

	if(!$row->[0][1]){ return 0 }

	my $msg = atom_util::load_template('passwd.al', $atom_html::hl{'langid'});

	$msg = repl_ph($msg,	{
												 "password" => $row->[0][0],
												 "login" 		=> $row->[0][2]
												});

	sendmail($msg,$row->[0][1],$atomcfg{'mail_from'});

 return 0;
}
}

sub make_code 
{
	my $n = shift;
	my ($i,$s,$c);
	$s = '';

	for ($i = 0; $i < $n; $i++) {
		$c = int(rand(62));
		if ($c < 26) { $c = chr(ord('a')+$c); }
		elsif ($c < 52) { $c = chr(ord('A')+$c-26); }
		elsif ($c < 62) { $c = chr(ord('0')+$c-52); }
		$s .= $c;
	}
	
	return $s;
}

# unescape URL-encoded data
sub unescape {
	my $todecode = shift;
	return undef unless defined($todecode);
	$todecode =~ tr/+/ /;       # pluses become spaces
	$todecode =~ s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
	utf8::decode($todecode);
	return $todecode;
}

# URL-encode data
sub escape {
	my $toencode = shift;
	return undef unless defined($toencode);
	utf8::encode($toencode);
	$toencode=~s/([^a-zA-Z0-9_.\-])/uc sprintf("%%%02x",ord($1))/eg;
#	$toencode=~s/ /+/g;
	return $toencode;
}

sub s_repl_ph {
	my ($text, $hash) = @_;
		if($text=~/<DictItem[\s]*[^><]*>.+?<\/DictItem>/){
			my @items=($text=~/(<DictItem[\s]*[^><]*>.+?<\/DictItem>)/gs);
			for my $item (@items){
				if($item=~/<DictItem[\s]*[^><]*>(.+)<\/DictItem>/){
					my $token=$1;
					my $lang;
					if($item=~/<DictItem[\s]+lang="([\w]+)"/){
						$lang=$1;
					}
					my $replacement=atomsql::do_query('
										SELECT dt.html FROM dictionary_text dt 
										JOIN dictionary d USING(dictionary_id)
										JOIN language l USING(langid) '.
										'WHERE d.code='.atomsql::str_sqlize($token).' AND (l.langid=1 '.
										(($lang)?' or l.short_code='.atomsql::str_sqlize($lang):'').') 
										ORDER BY l.langid DESC');
					if($replacement->[0][0]){# we have local translation										
						$text=~s/\Q$item\E/$replacement->[0][0]/g;
					}else{# use english transaltion
						$text=~s/\Q$item\E/$replacement->[1][0]/g;
					}
				}else{
					$text=~s/<DictItem><\/DictItem>//gs;
				}
			}		
		}
		for my $i (keys %{$hash}) {
			$text =~ s/\%\%$i\%\%/$hash->{$i}/gs;
		}

  	return $text;
}

sub repl_ph {
	my ($text, $hash) = @_;
	return s_repl_ph($text, $hash);
#	my $curr =m/[^\\]*%%(.+?)%%[^\\]*/g;
	my $curr;
	$curr=~m/%%.+?%%/gs;
  my $prev = -1;
		
	while( $curr != $prev ){
	  $prev = $curr;
#		log_printf("\$prev = $prev");
		$text = s_repl_ph($text,$hash);
   	 $curr =~m/%%.+?%%/gs;
#		log_printf("\$curr = $curr");
	}

return $text;
}


sub verify_address
{
 use Socket;
 my ( $access_restriction, $access_restriction_ip, $ip ) = @_;
 log_printf(" input $access_restriction, $access_restriction_ip, $ip )");
 my $result = 1; # ok

    #$ip = eval { inet_ntoa(inet_aton($ip)) };
 my @ip = split(/\./, $ip);

 if($access_restriction){ # enabled
  $result = 0;
	
	my @allowed_hosts = split(' ', $access_restriction_ip);
 	 for my $allowed_host(@allowed_hosts){
	  last if $result;
#		 log_printf(" chk $allowed_host");		
 		if($allowed_host =~m/[\d\/]+\.[\d\/]+\.[\d\/]+\.[\d\/]+/){
		 # ip mask given
#		 log_printf(" pattern $allowed_host");
		 my @ip_pattern = split(/\./, $allowed_host);

		 $result = 1; # assuming

		 for(my $i = 0; $i < 4; $i++){
			 my ($low, $hi ) = split('/', $ip_pattern[$i]);
			 # checking consitently
			 if($low > $hi ){ my $tmp = $hi; $hi = $low; $low = $tmp; }

			 if(!defined $hi){ $hi = $low } # when no pattern given
			 if(!defined $low){ $low = $hi } # when no pattern given
# log_printf( " $low vs $hi are given from $ip_pattern[$i]" );
			 # verification
# log_printf( " $ip[$i] < $low || $ip[$i] > $hi ");
			 if( $ip[$i] < $low || $ip[$i] > $hi ){
			  $result = 0; # verification failed
			 }
		 }
		} else {
			# some name is given
			my $between_ip = inet_aton($allowed_host);
			if ($between_ip) {
				my $allowed_ip = inet_ntoa($between_ip);
				if($allowed_ip eq $ip){
					$result = 1;
				}
			}
		}
	 }
 
 }
 return $result;
}

sub maintain_category_feature_group {
	my ($feature_group_id, $catid) = @_;
	
	my $category_feature_group_id;
	
  my $category_feature_group_id = atomsql::do_query('select category_feature_group_id from category_feature_group where catid = '.atomsql::str_sqlize($catid).' and feature_group_id = '.atomsql::str_sqlize($feature_group_id))->[0][0];

	unless ($category_feature_group_id) {
		insert_rows('category_feature_group', 
								 {
									 'catid' => atomsql::str_sqlize($catid),
									 'feature_group_id'	=> atomsql::str_sqlize($feature_group_id)
									 });
		$category_feature_group_id = atomsql::sql_last_insert_id();
	}
	
	return $category_feature_group_id;
} # sub maintain_category_feature_group

sub get_obj_url {
	my ($hash) = @_;

	my $cmd;
	my $convert = "/usr/bin/convert";
	my $rand_index = int(rand(10000));

	# for manual_pdf
	if (($hash->{'dbtable'} eq 'product_description') && ($hash->{'dbfield'} eq 'manual_pdf_url')) {
		$rand_index .= '-manual';
	}

	my $fileext = '';
	if ($hash->{'link'} =~ /^.+(\..{3,4})$/) {
		$fileext = $1;
	}

	my $name = $hash->{'id_value'}.'-'.$rand_index;
	my $tmp_file = '/tmp/'.$name.$fileext;

	my $src_file = $hash->{'link'};

	my $rc = '';

	if (-f $src_file) {
		`cp -f $src_file $tmp_file`;
	}
	else {
		$rc = my_mirror($src_file, \$tmp_file, \$fileext);
	}

	# my_mirror src to images_cache, then add_image!!!

	if ($rc eq 'uploading error') {
		log_printf('uploading error!!!');

		return 1;
	}

	# get the file result
	$fileext = get_ext_by_file_content($tmp_file);

	log_printf("$src_file uploaded to $tmp_file");

	my $res = getJpeg($tmp_file);
	$name = $res->[0];
	$fileext = $res->[1];
#	log_printf("res = ".Dumper($res));

	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	$tmp_file = $name.$fileext;
	
	unless (-e $tmp_file) {
		log_printf("file ".$tmp_file." is absent. Exiting.");
		return 1;
	}

	# choose the proper target
	my $trg = $atomcfg::targets;
	if ($hash->{'dbtable'} eq 'product_description') {
		$trg = $atomcfg::pdf_targets;
	}
	elsif ($hash->{'dbtable'} eq 'product_multimedia_object') {
		$trg = $atomcfg::object_targets;
	}

	# run add_image
	my $target = add_image($tmp_file,
													$hash->{'dest'},
													$trg);

	log_printf("target = ".$target);

	unless ($hash->{'dont_touch_base'}) {

		atomsql::update_rows($hash->{'dbtable'},
													$hash->{'id'}."=".$hash->{'id_value'},
													{
														$hash->{'dbfield'} => atomsql::str_sqlize($target)
													});
	}

	log_printf("Removing ".$tmp_file);
	`rm -f $tmp_file`;

	return $target;
} # sub get_obj_url

sub get_family_children_list {
	my ($id) = @_;

#	my $children = atomsql::do_query("select family_id from product_family where parent_family_id = ".$id);
#	push @$arr, $id;
#	for (@$children) {
#		get_family_children_list($_->[0], $arr);
#	}

	my $arr = [];
	
	my $left_right_langid_1 = atomsql::do_query("select left_key, right_key from product_family_nestedset where family_id=".$id." and langid=1")->[0];
	my $children = atomsql::do_query("select pf.family_id from product_family pf inner join product_family_nestedset pfn using (family_id) where pfn.langid=1 and pfn.left_key > ".$left_right_langid_1->[0]." and pfn.right_key < ".$left_right_langid_1->[1]);

	for (@$children) {
		push @$arr, $_;
	}

	return $arr;
} # sub get_family_chilren_list

sub family_count {
    my $id = shift;

#   my $f_num = 0;
#		my $i = 0;
#    my $req = atomsql::do_query("select family_id from product_family where parent_family_id = $f_id");

#    while ($req->[$i][0]) {
#			$i++;
#    }

#    $f_num = $f_num + $i; $i = 0;

#    while ($req->[$i][0]) {
#			$f_num = $f_num + family_count($req->[$i][0]);$i++;
#    }

		my $left_right_langid_1 = atomsql::do_query("select left_key, right_key from product_family_nestedset where family_id = ".$id." and langid = 1")->[0];
		return 0 unless $left_right_langid_1->[0];
			my $cnt = atomsql::do_query("select count(pf.family_id) from product_family pf inner join product_family_nestedset pfn using (family_id) where pfn.langid=1 and pfn.left_key > ".$left_right_langid_1->[0]." and pfn.right_key < ".$left_right_langid_1->[1])->[0][0];

#	for (@$children) {
#		push @$arr, $_;
#	}

		return $cnt;

#    return $f_num;
}
				
sub my_mirror {
	my ($src, $dst_file, $fileext) = @_;
	my $ua = LWP::UserAgent->new;
	$ua->timeout($atomcfg{'http_request_timeout'});
	$ua->agent("Mozilla/5.0");
	my $req = HTTP::Request->new( GET => $src );
	my $res = $ua->request($req);
	if ($res->is_success) {
		# exepction for files without file extention
    if ($res->header('Content_Type') eq 'application/pdf') {
			if ($$fileext ne '.pdf') {
				$$fileext = '.pdf';
				$$dst_file .= $$fileext;
			}
		}	 
		my $mime_type;
		$res->header('Content_Type') =~ /^(\w+\/?[^;\s]*);?\s*?/;
		$mime_type = $1;
		if ($$fileext eq '') {
			my $mimetypes = MIME::Types->new;
			my MIME::Type $mimetype = $mimetypes->type($mime_type);
			my @ext = $mimetype->extensions;
			$$fileext = '.'.$ext[0];
			$$dst_file .= $$fileext;
		}
		if (!open(DST, "> $$dst_file")) {
			log_printf("can't open $$dst_file for writing, fileext = ".$$fileext);
			return 'uploading error';
		}
		binmode DST;
		print DST $res->content();
		close(DST);
		return $mime_type;	
	}
	else {
		log_printf("can't load $src, reason: ".$res->status_line);
		return "uploading error";
	}
}

sub verify_login_expiration_date
{
 my($uid) = @_[0];
 if(!$uid){ return 0;}
 my $date = atomsql::do_query("select login_expiration_date from users where user_id = $uid");
 if($date->[0][0]){
  $date->[0][0] =~ /^\s*(\d+)\s*-\s*(\d+)\s*-\s*(\d+)\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*/;
  if(!$1){ return 0;}
  log_printf("timelocal: ".timelocal($6, $5, $4, $3, $2 - 1, $1)." time: ".time);
  eval{timelocal($6, $5, $4, $3, $2 - 1, $1)};
  if($@){
    log_printf("login expiration date is wrong: $@");
    return 0;
  }
  if(timelocal($6, $5, $4, $3, $2 - 1, $1) < time){ return 0;  }
 }
 return 1;
}

sub get_language_flag {
	my ($product_id, $langs) = @_;

	if (!$langs) {
		$langs = atomsql::do_query("select langid from language order by langid asc");
	}
	
	# binary flags calculating
	my $language_flag = 0b000000;
	my $pattern;
	my $prod_desc = atomsql::do_query("select langid from product_description where product_id = ".atomsql::str_sqlize($product_id)." and short_desc != '' and langid!=0");
	for (@$prod_desc) {
		$pattern = 1;
		$pattern <<= ($_->[0] - 1);
		$language_flag |= $pattern;
	}

	return $language_flag;
}

sub get_complaint_email_body
{
 my ($atoms, $complaint_id, $langid, $nohistory) = @_;
 
 #get complaints details
 my $get_complaint_details = atomsql::do_query("select pc.name, pc.company, pc.email, pc.prod_id, pc.subject, pc.message, DATE_FORMAT(pc.date, '%d.%c.%Y %H:%i:%s'), s.name, u.login,v.value, pcs.code
from product_complaint as pc, vocabulary as v,  product_complaint_status as pcs, users as u, supplier as s
where pc.id = $complaint_id and  pc.complaint_status_id = pcs.code and  pcs.sid = v.sid and v.langid = $langid  and pc.user_id = u.user_id and pc.supplier_id = s.supplier_id");
 
 my $hash; $hash->{'status_id'} = $get_complaint_details->[0][10]; $hash->{'complaint_email'} = 1;
 $get_complaint_details->[0][9] = atom_format::format_as_status_name($get_complaint_details->[0][9], '', '', '', $hash);
 $get_complaint_details->[0][5] =~s/\n/<BR>/gi;  $get_complaint_details->[0][4] =~s/\n/<BR>/gi;
 $get_complaint_details->[0][5] =~s/\s/&nbsp;/gi;  $get_complaint_details->[0][4] =~s/\s/&nbsp;/gi;
 $get_complaint_details->[0][5] =~s/\"/&quot;/gi;  $get_complaint_details->[0][4] =~s/\"/&quot;/gi;
					
 my $replases = {
 	'from_name' => $get_complaint_details->[0][0],
	'company' => $get_complaint_details->[0][1],
	'from_email' => $get_complaint_details->[0][2],
	'prodid' => $get_complaint_details->[0][3],
	'subject' => $get_complaint_details->[0][4],
	'message' => $get_complaint_details->[0][5],
	'date' => $get_complaint_details->[0][6],
	'supplier_name' => $get_complaint_details->[0][7],
	'to_name' => $get_complaint_details->[0][8],
	'status' => $get_complaint_details->[0][9]
 };
 
 #get complains history
 my $get_complaint_history = atomsql::do_query("select pc.subject, pch.message, DATE_FORMAT(pch.date, '%d.%c.%Y %H:%i:%s'), u.login, c.email, v.value, pch.complaint_status_id, pch.id
 from product_complaint_history as pch,	product_complaint as pc, vocabulary as v, users as u, product_complaint_status as pcs, contact as c 
 where pch.complaint_id = pc.id and pch.user_id = u.user_id and pch.complaint_status_id = pcs.code and pcs.sid = v.sid and v.langid = $langid and pc.id = $complaint_id and u.pers_cid = c.contact_id");
 
 my $histories;
 for my $history(@$get_complaint_history){
	 my $hash; $hash->{'status_id'} = $history->[6]; $hash->{'complaint_email'} = 1;
	 $history->[5] = atom_format::format_as_status_name($history->[5], '', '', '', $hash);
	 $history->[0] =~s/\n/<BR>/gi;	$history->[1] =~s/\n/<BR>/gi;
	 $history->[0] =~s/\s/&nbsp;/gi;  $history->[1] =~s/\s/&nbsp;/gi;
	 $history->[0] =~s/\"/&quot;/gi;  $history->[1] =~s/\"/&quot;/gi;
	 $history->[0] = get_subject($history->[7], $complaint_id, $history->[0]);
	 
	 my $replases = {
	 'history_from_name' => $history->[3],
	 'history_from_email' => $history->[4],
	 'history_status' => $history->[5],
	 'history_date' => $history->[2],
	 'history_subj' => $history->[0],
	 'history_mess' => $history->[1]
	 };
	 $histories .= repl_ph($atoms->{'default'}->{'email_complaint'}->{'history_row'}, $replases);
 }
 
 if(!$nohistory){
	$replases->{'history_rows'} = $histories;
	$replases->{'history_header'} = $atoms->{'default'}->{'email_complaint'}->{'history_header'};
	$replases->{'history_begin'} = $atoms->{'default'}->{'email_complaint'}->{'history_begin'};
	$replases->{'history_end'} = $atoms->{'default'}->{'email_complaint'}->{'history_end'};
 }else{
	$replases->{'history_rows'} = '';
	$replases->{'history_header'} = '';
	$replases->{'history_begin'} = '';
	$replases->{'history_end'} = '';
 }
 my $body = repl_ph($atoms->{'default'}->{'email_complaint'}->{'body'}, $replases);
 
 sub get_subject
 {
  my $req2 = atomsql::do_query("select count(id) from product_complaint_history where id <= $_[0] and complaint_id = $_[1]");
  if(!$req2->[0][0] || $req2->[0][0] == 1){ return "Re:".$_[2]; }
	else{ return "Re[".($req2->[0][0])."]:".$_[2]; }
 }

 return $body;
}

sub get_gallery_pic_params {
	my ($pic_path) = @_;

	my $pic_hash = {};

	return undef unless $pic_path;


#	my ($width, $height)= $src->getBounds();
#	($pic_hash->{'width'}, $pic_hash->{'height'}) = ($width, $height);
#	my $size = (-s $pic_path);
#	$pic_hash->{'size'}  = $size;
#	
#	if(($pic_hash->{'height'} > 500) || ($pic_hash->{'width'} > 500)){ $pic_hash->{'quality'} = 1;}
#	else { $pic_hash->{'quality'} = 0;}

	my $identify_results = `identify -format '%[fx:w] %[fx:h] %b' '$pic_path'`;
	my @params=split(' ',$identify_results);
	$params[2]=~s/b$//i;
	if($params[0]!~/^[\d]+$/ or $params[1]!~/^[\d]+$/ or $params[2]!~/^[\d]+$/){
		my $mail = {
		'to' => $atomcfg{'bugreport_email'},
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "identify does not work as expected !!",
		'default_encoding'=>'utf8',
		'html_body' => "identify does not work as expected !! in get_gallery_pic_params() for ".$pic_path,
		};	
		complex_sendmail($mail);	
	}else{
		$pic_hash->{'width'}=$params[0];
		$pic_hash->{'height'}=$params[1];
		$pic_hash->{'size'}=$params[2];
		if(($pic_hash->{'height'} > 500) || ($pic_hash->{'width'} > 500)){ 
				$pic_hash->{'quality'} = 1;
		}
		else { 
			$pic_hash->{'quality'} = 0;
		}		
	}
	
	return $pic_hash;
} # sub get_gallery_pic_params

sub get_obj_size {
	my ($phash, $size_field) = @_;

	my $data = atomsql::do_query("select ".$phash->{'dbfield'}." from ".$phash->{'dbtable'}." where ".$phash->{'id'}." = ".$phash->{'id_value'})->[0][0];
	if ($data) {
		my $data_path = $data;
		log_printf($data_path);
		$data_path =~ s/^http:\/\/.*?\//$atomcfg{'base_dir'}www\//;
		log_printf($data_path);
		my $size = (-s $data_path);
		if ($size) {
			atomsql::update_rows($phash->{'dbtable'}, $phash->{'id'}." = ".$phash->{'id_value'}, {$size_field => $size});
			return $size;
		}
	}

	return 0; 
}

sub get_obj_width_and_height {
    my ($phash, $wf, $hf) = @_;

    my $data = atomsql::do_query("select ".$phash->{'dbfield'}." from ".$phash->{'dbtable'}." where ".$phash->{'id'}." = ".$phash->{'id_value'})->[0][0];
		if ($data) {
			my $data_path = $data;
		 	$data_path =~ s/^http:\/\/.*?\//$atomcfg{'base_dir'}www\//;
			my $ans = qx(identify $data_path);
			log_printf('Identify utility in action ... ');
			log_printf($ans);		
			$ans =~ /^(?:[^\s]+) (?:[^\s]+) (\d+)x(\d+)/;
			my $width = $1;
			my $height = $2;		

			if (($width) && ($height)) {
				atomsql::update_rows($phash->{'dbtable'}, $phash->{'id'}." = ".$phash->{'id_value'}, {
					$wf => $width,
					$hf => $height,
															} );
			}

			log_printf("ANS = ".$width." x ".$height);
    }

    return;
}

sub nonEn_value {
	my ($value) = @_;

	if (!$foreign_words) {
		my $fws = atomsql::do_query("select langid,value from language_blacklist");
		for (@$fws) {
			chomp($_->[1]);
			push @{$foreign_words->{$_->[0]}}, $_->[1];
		}
	}

	my $result = [];
	for my $langid(%$foreign_words) {
		my $match = undef;
		my $pattern;
		for (my $i=0;$i<=$#{$foreign_words->{$langid}};$i++) {
			$pattern = $foreign_words->{$langid}->[$i];
			if (($value =~ /\b$pattern\b/im)&&($value !~ /\b$pattern-/im)&&($value !~ /-$pattern-/im)) {
				$match = $langid;
			}
		}
		push @$result, $match if ($match);
	}
	return $result;
} # nonEn_value

sub approx {
  my ($pattern,$victim) = @_;
  my $output;
  for (@$victim) {
    push @$output, fastdistance(lc($pattern),lc($_));
  }
  return $output;
} # approx

sub xsd_header {
	my ($schema) = @_;
	my $xsd = $atomcfg{'xsd_active'};
	my $header = "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"".$atomcfg{host}."xsd/" . $schema . ".xsd\"";
	
	if ($xsd == 1) {
		return $header;
	}
}

sub xml_utf8_tag {
	return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
} # sub xml_utf8_tag

sub remove_index_xml_item_by_supplier_id {
	my ($rxml, $supplier_id, $prod_id_set) = @_;

	$prod_id_set = _prod_id_set2perlre($prod_id_set);

	log_printf(" <=> ".$supplier_id." ".$prod_id_set);

#  $$rxml =~ s/\t*\<file\s[^\>]*?Supplier_id="$supplier_id".*?(?:\<\/file\>|On_Market="\d"[^\n]*?\/\>)\n*//sg;
	unless ($prod_id_set) {
		$$rxml =~ s/<file\s[^\>]+?Supplier_id="$supplier_id"[^\>]+?>.*?<\/file>\s*//sg;
	}
	else {
		$$rxml =~ s/<file\s[^\>]+?Supplier_id="$supplier_id"[^\>]+?Prod_ID="(?:$prod_id_set)"[^\>]+?>.*?<\/file>\s*//sg;
	}

} # sub remove_index_xml_item_by_supplier_id

sub remove_index_csv_item_by_supplier_id {
	my ($rcsv, $supplier_id, $prod_id_set) = @_;

	$prod_id_set = _prod_id_set2perlre($prod_id_set);

  my $line = '';
  my @lines = split "\n", $$rcsv;

  for (@lines) {
		if ($prod_id_set) {
			next if /^.*?\t\d+\t\d+\t\w+\t$supplier_id\t(?:$prod_id_set)/;
			$line .= $_ . "\n";
		}
		else {
			next if /^.*?\t\d+\t\d+\t\w+\t$supplier_id/;
			$line .= $_ . "\n";
		}
  }

  $$rcsv = $line;
} # sub remove_index_csv_item_by_supplier_id

sub _prod_id_set2perlre {
	my ($prod_id_set) = @_;
	
	if ($prod_id_set) {
		chomp($prod_id_set);
		my @arr = split ',', $prod_id_set;
		$prod_id_set = '';
		for (@arr) {
			next unless $_;
			$prod_id_set .= quotemeta($_) . '|';
		}
		chop($prod_id_set);
	}

	return $prod_id_set;
} # sub _prod_id_set2perlre

sub remove_Philips_DE_content {
  my ($c, $id) = @_;

  return unless $id;

  ## remove from XMLs
# <file path="export/level4/INT/3246.xml" Product_ID="3246" Updated="20080613185327" Quality="ICECAT" Supplier_id="33" Prod_ID="SU044-1" Catid="984" On_Market="1">
#                        <M_Prod_ID>91.42R01.32H#L2</M_Prod_ID>
#                        <M_Prod_ID>91.42R01.32H#L3</M_Prod_ID>
#
#                        <EAN_UPCS>
#                                <EAN_UPC Value="0731304011279"/>
#                        </EAN_UPCS>
#                        <Country_Markets>
#                                <Country_Market Value="SE"/>
#                        </Country_Markets>
#                </file>
#
# BAD SOLUTION - TO USE `On_Market="\d"\/\>`
#
  print "[xml: files";
  $c->{'xml'} =~ s/\t*\<file\s[^\>]*?Supplier_id="$id".*?(?:\<\/file\>|On_Market="\d"[^\n]*?\/\>)\n*//sg; # the same
  print ", on market";
  $c->{'on_market'} =~ s/\t*\<file\s[^\>]*?Supplier_id="$id".*?(?:\<\/file\>|On_Market="\d"[^\n]*?\/\>)\n*//sg; # the same
  print ", nobody";
  $c->{'nobody'} =~ s/\t*\<file\s[^\>]*?Supplier_id="$id".*?(?:\<\/file\>|On_Market="\d"[^\n]*?\/\>)\n*//sg; # the same
  print "] ";

  print "[daily";
  $c->{'daily'} =~ s/\t*\<file\s[^\>]*?Supplier_id="$id".*?(?:\<\/file\>|On_Market="\d"[^\n]*?\/\>)\n*//sg; # the same
  print "] ";

  print "[csv: files";
  my $line = '';
  my @lines = split "\n", $c->{'csv'};
  for (@lines) {
    $line .= $_."\n" unless (/^.*?\t\d+\t\d+\t\w+\t$id/);
  }
  $c->{'csv'} = $line;
  print ", on_market";
  $line = '';
  @lines = split "\n", $c->{'on_market_csv'};
  for (@lines) {
    $line .= $_."\n" unless (/^.*?\t\d+\t\d+\t\w+\t$id/);
  }
  $c->{'on_market_csv'} = $line;
  print ", nobody";
  $line = '';
  @lines = split "\n", $c->{'nobody_csv'};
  for (@lines) {
    $line .= $_."\n" unless (/^.*?\t\d+\t\d+\t\w+\t$id/);
  }
  $c->{'nobody_csv'} = $line;
  print "] ";
} # sub remove_Philips_DE_content

1;

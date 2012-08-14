package ModernSponsorsRepository;

# $Id: ModernSponsorsRepository.pm 3656 2010-12-30 01:09:44Z dima $
# File: ModernSponsorsRepository.pm

use strict;
#use warnings FATAL => 'all';

use Apache2::RequestRec ();
#use Apache2::Response ();
use Apache2::RequestIO ();
use Apache2::Access ();
use Apache2::Connection;
use Apache2::Const -compile => qw(OK NOT_FOUND FORBIDDEN AUTH_REQUIRED);

use lib '/home/pim/lib';

use atomlog;
use atomcfg;
use atomsql;
use atom_util;
use process_manager;
use bytes;

use Data::Dumper;
use PerlIO::gzip;

sub handler {
	my $r = shift; # get path	

	$r->ap_auth_type('Basic');
	
	goto skip_slave;
	my $slave_ip = do_query("select SQL_CACHE ip from slave_status limit 1")->[0][0];

	if ($slave_ip) {
		register_slave('slave1',$slave_ip,$atomcfg{'dbslaveuser'},$atomcfg{'dbslavepass'});
#		log_printf("DV: register slave: ".$slave_ip);
		unregister_main();
	}
	else {
#		log_printf('!!! SLAVE NOT FOUND !!!');
		register_slave('slave1',$atomcfg{'dbhost'},$atomcfg{'dbuser'},$atomcfg{'dbpass'});
	}

 skip_slave:
	
	binmode STDOUT, ":utf8";

	# Basic Authorization: get login & password
	return undef unless defined($r);

	my ($res, $sent_pw) = $r->get_basic_auth_pw();
		
	my $login = $r->user;
	my $pass = $sent_pw;
	my $ip = $r->connection->remote_ip();
	my $host = $r->connection->remote_host();

	# Now, we have user, password, remote_ip, remote_host
	# NEW!!!
	if ($res != Apache2::Const::OK) {
		log_printf("DV ".$login.": weird get_basic_auth_pw() \$res wrong auth: ".$login.", ".$pass.", ".$ip);
		return $res;
	}

	my $result = Apache2::Const::NOT_FOUND; # result module

	my $path = $r->unparsed_uri();

	# prepare path
	$path =~ s/\/{2,}/\//gs;

	log_printf("URL(".$path.") access: login=".$login.", password=".$pass.", ip=".$ip.", host=".$host);

	# parse path
	my @a = split /\//, $path;

	shift @a;
	shift @a;
	
	my $type = shift @a; # get a type of repo: freexml or vendor
	my $lang = undef; # lang of product: INT, EN, NL etc...
	my $int = undef;

	# if vendor -> get supplier_id
	my $supplier_name = undef; # supplier_id
	my $supplier_id = undef; # supplier_id
	
	my $item = ''; # product_id value
	my $nitem = undef;
	my $item_path = undef;

	my $cmd = '';	

	# get type
	if (($type =~ /^(freexml|vendor)(\.int)?/) || ($type =~ /^(level4)?/)) {

		$type = $1;
		$int = $2;
		
		if ($type =~ /^vendor(\.int)?$/) {
			# supplier_id
			$supplier_name = shift @a;
			$supplier_id = do_query("select SQL_CACHE supplier_id from supplier where folder_name=".str_sqlize($supplier_name))->[0][0];
		}
		
		# get lang (complicated, should be simpler)
		$lang = (($type eq 'level4')||(($int)&&($int eq '.int'))) ? shift @a : '?INT'; # ?INT - by default
		my $langid = -1;
		if ($lang) {
			if (($lang eq 'INT') || ($lang eq 'repository')) {
				$lang = 'INT';
				$langid = 0;
			}
			elsif ($lang eq '?INT') { # probably-INT (for non-product /freexml/* requests)
				# do nothing
			}
			else {
				$lang = 'ES' if ($lang eq 'SP');
				$lang = 'ZH' if ($lang eq 'CN');
				$lang = 'DE' if ($lang eq 'GE');
				$lang = 'SV' if ($lang eq 'SE');
#				$lang = uc $lang;
				$langid = do_query("select langid from language where short_code=" . (uc str_sqlize($lang)))->[0][0] || -1;
				if ($langid == -1) {
					unshift @a, $lang; # bring non-language to their place
					$lang = '';
				}
			}
		}
		else {
			$lang = '';
		}
		
		if (get_auth($type,$login,$pass,$ip,$host,$langid,$supplier_id,$path)) {

			# get item type
			while (1) {
				$nitem = shift @a;
				last unless defined $nitem;
				$item .= '/' if $item;
				$item .= $nitem;
			}
			if ((!$item) && ($langid != -1)) {
				$item = 'daily.index.xml'; # like a DirectoryIndex
			}
			$item_path = get_item_path($type,$item,$supplier_id,$supplier_name,$lang,$login);

			log_printf("item path = ".$item_path);

			# get XML
			if ($item_path) {
				if (-f $item_path) {
					$result = Apache2::Const::OK;
					if ($item_path =~ /(\d+)\.xml\.gz$/i) { # gzipped
						my $product_id = $1;
						my $gzipped_flag = $path =~ /\.gz$/i ? 1 : 0;

						# to output
						if ($gzipped_flag ? open XMLGZ, "<", $item_path : open XMLGZ, "<:gzip", $item_path) {
							my $ungz = '';
							if ($gzipped_flag) {
								binmode($ungz,":raw");
								$r->content_type('application/x-gzip-compressed');
							}
							else {
								binmode($ungz,":utf8");
								$r->content_type('application/xml');
							}
							$ungz = join("",<XMLGZ>);
							close XMLGZ;

							my (undef,undef,undef,undef,undef,undef,undef,undef,undef,$mtime,undef,undef,undef) = stat($item_path);
							my $size = bytes::length($ungz);
							$r->set_content_length($size) if $r->can('set_content_length');
							$r->set_last_modified($mtime) if $r->can('set_last_modified');;
							$r->rflush();
							$r->write($ungz);
						}
						else { # file is broken - reloading
							if ($product_id) {
								$cmd = $atomcfg{'base_dir'}.'bin/update_product_xml_chunk';
								queue_process($cmd." ".$product_id, { 'product_id' => $product_id, 'process_class_id' => 1, 'prio' => 2 });
							}
							$result = Apache2::Const::NOT_FOUND;
						}
					}
					else {
						set_content_type($r,$item_path);
						my (undef,undef,undef,undef,undef,undef,undef,$size,undef,$mtime,undef,undef,undef) = stat($item_path);
						$r->set_content_length($size) if $r->can('set_content_length');
						$r->set_last_modified($mtime) if $r->can('set_last_modified');;
						$r->rflush();
						$r->sendfile($item_path);
					}
					#log_printf("send from: ".$item_path);
				}
				elsif ((-d $item_path) && ($item_path =~ /\/(csv|prf|refs|level4|freexml|freexml\.int|vendor|vendor\.int)\/*/)) {
					$result = Apache2::Const::OK;
					$r->content_type("text/html; charset=utf-8");
					$r->rflush();
					$r->write(get_index_html($path, $item_path));
				}else{					
					goto PRINT_XML;
				} 
			}
			else {
					PRINT_XML:
					$result = Apache2::Const::NOT_FOUND;
					my $new_item_path = $path;
					my $err_xml = '';
					my $product_id = 0;

					if ($new_item_path =~ /(\d+)\.xml.*$/i) {
						$product_id = $1;
						my $new_product_id = do_query("SELECT p.product_id from product_deleted pd 
							   JOIN product p ON pd.map_product_id=p.product_id
							   WHERE pd.product_id=$product_id and pd.product_id!=pd.map_product_id");
						
						if (scalar(@$new_product_id) > 0) {
							$new_item_path = $atomcfg{'xml_path'}.'level4/'.$lang.'/'.get_smart_path($new_product_id->[0][0]).$new_product_id->[0][0].'.xml.gz';
						}
						if (-e $new_item_path) {
							$err_xml = '<ICECAT-interface><Product Code="-1" ID="?'.$product_id.'?" ErrorMessage="Product was replaced with" Map_product_id="'.$new_product_id->[0][0].'"/></ICECAT-interface>';
						}
						else {
							goto product_no_data;
						}
					}
					else {
					product_no_data:
						$err_xml = '<ICECAT-interface><Product Code="-1" ID="?'.$product_id.'?" ErrorMessage="No xml data for this product or product code incorrect"/></ICECAT-interface>';
					}

					$r->status($result);
					$r->custom_response($result, $err_xml);
			}
		}
		else {
			$r->note_basic_auth_failure();
			$result = Apache2::Const::AUTH_REQUIRED;
		} # if get_auth
	}
	else {
		$result = Apache2::Const::NOT_FOUND;
	}	

	return $result;
} # sub handler

sub set_content_type {
	my ($r, $item) = @_;

	if ($item =~ /\.gz/i) {
		$r->content_type('application/x-gzip');
	}
	elsif ($item =~ /\.xml/i) {
		$r->content_type('application/xml');		
	}
	elsif ($item =~ /(\.txt|\.csv)(\.utf8)?$/i) {
		if ($item =~ /\.utf8/i) {
			$r->content_type('text/plain; charset=utf-8');
		}
		else {
			$r->content_type('text/plain; charset=ISO-8859-1');
		}
	}
	else {
		$r->content_type('text/plain');
	}
} # sub set_content_type

sub get_auth {
	my ($type,$login,$pass,$ip,$host,$langid,$supplier_id,$url) = @_;

	my $any_symbols = '';
	if ($langid > -1) {
		$any_symbols = '_' x $langid;
	}

	my $ips = " or 0";
	my $prf2host = '';
	if ($atomcfg{'datahost'}) { $ips .= " or ".str_sqlize($atomcfg{'datahost'})."=".str_sqlize($ip); }
	if ($atomcfg{'datahost2'}) { $ips .= " or ".str_sqlize($atomcfg{'datahost2'})."=".str_sqlize($ip); }
	if ($atomcfg{'prf2host'}) { $prf2host = " or ".str_sqlize($atomcfg{'prf2host'})."=".str_sqlize($ip); }

	# preparing expiration request
	my $exp_date = " and (trim(login_expiration_date)='' or login_expiration_date is null or unix_timestamp(login_expiration_date) >= unix_timestamp(".str_sqlize($atomsql::current_day)."))";

	if ($type eq 'freexml') { # get freexml file
	brand_assigned_users:
		unless (do_query("select 1 from users where login=".str_sqlize($login)." and password=".str_sqlize($pass)." and (subscription_level in (1,2,4,5) or ".str_sqlize($ip)."=".str_sqlize($atomcfg{'prfhost'}).$prf2host.$ips.") and user_group='shop'".$exp_date)->[0][0]) {
			return 0;
		}
	}
	elsif ($type eq 'vendor') { # get vendor file
		unless ($supplier_id) {
			return 0;
		}
		unless (do_query("select 1 from supplier where supplier_id=".$supplier_id." and public_login=".str_sqlize($login)." and public_password=".str_sqlize($pass))->[0][0]) {

			# check the brand assigned users
			if (do_query("select 1 from brand_assigned_users bau inner join users u using (user_id) where bau.supplier_id=".$supplier_id." and u.login=".str_sqlize($login))->[0][0]) {
				goto brand_assigned_users;
			}
			return 0;
		}
	}
	elsif ($type eq 'level4') { # get level4 file
		if ($ip) { $ips .= " or access_restriction_ip like ".str_sqlize("%".$ip."%"); }
		if ($host) { $ips .= " or access_restriction_ip like ".str_sqlize("%".$host."%"); }
		unless (do_query("select 1 from users where login=".str_sqlize($login)." and password=".str_sqlize($pass)." and ((subscription_level=4 and (access_restriction=0 ".$ips.") and access_repository like ".str_sqlize($any_symbols."1%").") or (subscription_level in (1,2) and (".str_sqlize($atomcfg{'prfhost'})."=".str_sqlize($ip).$prf2host."))) and user_group='shop'".$exp_date)->[0][0]) {
			return 0;
		}
	}

	return 1;
} # sub get_auth

sub add2request_history {
	my ($login, $pass, $ip, $url) = @_;

	my $login_pass_match = do_query("select 'Y' from users where login=".str_sqlize($login)." and password=".str_sqlize($pass))->[0][0] || 'N';
	
	do_statement("insert delayed into request_history(login,password,ip,url,date) values(".str_sqlize($login).",".str_sqlize($login_pass_match).",".str_sqlize($ip).",".str_sqlize($url).",unix_timestamp())");
} # sub add2request_history

sub get_item_path {
	my ($type,$item,$supplier_id,$supplier_name,$lang,$login) = @_;

#	log_printf("type/lang/item: ".$type." ".$lang." ".$item);

	my $product_table_postfix = '_memory';

	my $allow = 0;
	my $product = 0;
	my $product_id = 0;
	my ($xml, $cmd);
	
	# product XML or other?
	if ($item =~ /^\d+\.xml(\.gz)?$/) {
		$product = 1; # link to product XML
		$product_id = $item;
		$product_id =~ s/\.xml(\.gz)?$//;

		# allow or deny?
		if ($type eq 'freexml') { # get freexml file
			$allow = do_query("select 1 from product".$product_table_postfix." p inner join supplier s using (supplier_id) where p.product_id=".$product_id." and p.public!='L' and p.publish!='N' and s.is_sponsor='Y'")->[0][0];
		}
		elsif ($type eq 'vendor') { # get vendor file
			$allow = do_query("select 1 from product".$product_table_postfix." p inner join supplier s using (supplier_id) where p.product_id=".$product_id." and s.supplier_id=".$supplier_id)->[0][0];
		}
		elsif ($type eq 'level4') { # get level4 file
			$allow = do_query("select 1 from product".$product_table_postfix." p inner join supplier s using (supplier_id) where p.product_id=".$product_id." " . ( $login eq '_multiprf' ? '' : " and p.public!='L' " ) . " and p.publish!='N'")->[0][0];
		}

		# SPECIFIC PARAMS / LIMITATIONS

		# 1007307: Deny access to free & full Philips DEutsch XML products (for clients only, _multiprf stays the same)
		# 1022629: hide Pelikan for Germany 
		# 1024212: Exclude Sony DE products from ICEcat repository (OpenICEcat only).
		# Vogel's Erik solution - 711 - do not show in icecat.biz

		$supplier_id = do_query("select supplier_id from product where product_id = ".$product_id)->[0][0] unless $supplier_id;

		if ((($login ne '_multiprf') || ($supplier_id == 711)) && ($type !~ /vendor/)) {
			# allow -> disallow, if products were restricted
			if ($allow) {
				$allow = DeniedByProductsRestricted($product_id, $product_table_postfix, $type, $lang);
			}
		}
		
		# allow denied products for BAU
		unless ($allow) {
			if ($supplier_id) {
				if (do_query("select 1 from brand_assigned_users bau inner join users u using (user_id) where bau.supplier_id = ".$supplier_id." and u.login = ".str_sqlize($login))->[0][0] eq '1') {
					$allow = 1;
				}
			}
		}

	}
	else { # link to index, mapping, others files
		$allow = 1;
	}

	# note!
	# if $lang =~ /^\?// - use /freexml/* paths

	# form XML path
	if ($allow) {
		if ($product) { # only to level4
			$lang =~ s/^\??//; # remove 1st ?, if present
			$xml = $atomcfg{'xml_path'}.'level4/'.$lang.'/'.get_smart_path($product_id).$product_id.".xml.gz" if (-e $atomcfg{'xml_path'}.'level4/'.$lang.'/'.get_smart_path($product_id).$product_id.".xml.gz");
		}
		else { # freexml -> to freexml, level4 -> to level4, vendor -> to vendor
#			log_printf('simple paths ///');
			if (($type eq 'freexml') || ($type eq 'vendor')) {
				$type .= '.int';
				$type .= '/'.$supplier_name if ($type eq 'vendor.int');
			}
			if (($lang =~ /^\?/) && ($item !~ /\.index\./)) {
				$lang = '';
			}
			elsif ($lang) {
				$lang =~ s/^\?//;
				$lang .= '/';
			}
			$xml = $atomcfg{'xml_path'}.$type.'/'.$lang.$item;
		}
	}
	else {
		$xml = undef;
	}

	log_printf('returned path = '.$xml) if $xml;

	return $xml;
} 

sub get_index_html {
	my ($url, $path) = @_;

	my ($ls, $is_dir, $date, $size, $name, $gif_pic);

	$ls = "";

	$url =~ s/\/+$//;

	my $prev_url = $url;
	$prev_url =~ s/^(.*)\/.+?$/$1/;

	open LS, "/bin/ls -l --group-directories-first -B --time-style=long-iso --color=never -p -h -G --dereference ".$path." |";
	binmode LS, ":utf8";

	foreach (<LS>) {
		next unless $_;
		/^(.).{9}\s+\d+\s+\w+\s+(.+?)\s+(\d+\-\d+\-\d+\s+\d+\:\d+)\s+(.+)$/;
		$is_dir = $1;
		$size = $2;
		$date = $3;
		$name = $4;
		next unless $name;
		next if $name =~ /\.new$/;
		$size = '-&nbsp;' if $is_dir eq 'd';

		$gif_pic = '<img src="/icons/unknown.gif" alt="[&nbsp;&nbsp;&nbsp;]">';
		if ($is_dir eq 'd') {
			$gif_pic = '<img src="/icons/folder.gif" alt="[DIR]">';
		}
		elsif ($is_dir eq 'l') {
			$gif_pic = '<img src="/icons/link.gif" alt="[&nbsp;&nbsp;&nbsp;]">';
			$name =~ s/\s+\-\>.+$//s;
		}
		elsif ($name =~ /\.gz$/) {
			$gif_pic = '<img src="/icons/compressed.gif" alt="[&nbsp;&nbsp;&nbsp;]">';
		}
		elsif (($name =~ /\.txt(\.utf8)?$/) || ($name =~ /\.csv$/)) {
			$gif_pic = '<img src="/icons/text.gif" alt="[TXT]">';
		}
		
		$ls .= "<tr><td>".$gif_pic."</td>
<td><nobr><a href=\"".$url."/".$name."\">".$name."</a></nobr></td>
<td><nobr>".$date."</nobr></td>
<td align=\"right\"><nobr>".$size."</nobr></td>
<td></td></tr>\n";
	}
	close LS;

	my $title = "Index of ".$url;

	return "<html>
<head>
  <title>".$title."</title>
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
</head>
<body>
  <h1>".$title."</h1>
  <table border=\"0\" cellpadding=\"0\" cellspacing=\"4\" width=\"100%\" style=\"font-family: Courier New; font-size: 13px;\">
  <tr><td width=\"1%\"></td><td width=\"1%\">Name</td><td width=\"1%\">Last&nbsp;modified</td><td width=\"1%\">Size</td><td width=\"*\">Description</td></tr>
  <tr><td colspan=\"5\"><hr></td></tr>
  <tr><td><img src=\"/icons/back.gif\" alt=\"[DIR]\"></td><td><a href=\"".$prev_url."\/\">Parent&nbsp;Directory</a></td><td></td><td align=\"right\">-&nbsp;</td><td></td></tr>
  ".$ls."
  <tr><td colspan=\"5\"><hr></td></tr>
  </table>
</body>
</html>";
} # sub get_index_html

sub DeniedByProductsRestricted {
	my ($p_id, $pt, $type, $lang) = @_;

	return 1 if uc($lang) eq 'INT'; # INTernational - always allow

	my $restrictions = do_query("select SQL_CACHE pr.supplier_id, upper(l.short_code), pr.subscription_level,
(select count(*) from product_restrictions_details prd where prd.restriction_id=pr.id), pr.id cnt
from product_restrictions pr
inner join language l using (langid)
where l.short_code = ".str_sqlize(uc($lang)));
	
	foreach my $restriction (@$restrictions) {
#		next if $restriction->[1] ne uc($lang); # skip if languages aren't matched

		# extra products
		my $extra_sql = '';
		if ($restriction->[3] > 0) {
			my $r_p_ids = do_query("select SQL_CACHE product_id from product_restrictions_details where restriction_id = ".$restriction->[4]);
			my $r_p_ids_arrayref = [];
			foreach my $r_p_id (@$r_p_ids) {
				push @$r_p_ids_arrayref, $r_p_id->[0];
			}
			$extra_sql = ' and product_id in (' . ( join ',', @$r_p_ids_arrayref ) . ')' if $#$r_p_ids_arrayref > -1;
		}

		# 2 conditions: product & customer type
		return 0 if do_query("select SQL_CACHE product_id from product" . $pt . " where supplier_id=" . $restriction->[0] . " and product_id = " . $p_id . " " . $extra_sql)->[0][0] &&
			( $restriction->[2] == 2 ? $type eq 'freexml' : 1 );
	}

	return 1;
} # sub DeniedByProductsRestricted

END {
	unregister_slave('slave1');	
}

1;

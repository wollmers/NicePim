package icecat_server3;

use strict;

use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_util;
use atom_misc;
use data_management;
use icecat_server2_repository;
use icecat_util;

#use Encode;
use Data::Dumper;
#use LWP::Simple;
#use HTTP::Lite;
use POSIX qw (strftime);

BEGIN {
	use Exporter ();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
	@EXPORT = qw(
								 &icecat_server_main
							);
}

sub icecat_server_main {
	
	#&log_printf('[---- script starting  ----------------]');

#	binmode STDOUT, ":utf8";
#	binmode STDIN, ":utf8";

	%hin = (); %hout = (); %hl = (); %hs = (); # for modperl
	
	atom_html::ReadParse;
	
	my $prod_id     = $hin{'prod_id'};
	my $product_id  = $hin{'product_id'};
	$product_id = 0 if $product_id !~ /^\d+$/;
	my $vendor      = $hin{'vendor'};
	my $lang        = uc $hin{'lang'};
	my $ean	        = $hin{'ean_upc'};
	my $output      = $hin{'output'};
	
#	log_printf("QS: ".$ENV{'QUERY_STRING'}."; product_id=".$product_id.", prod_id=".$prod_id.", vendor=".$vendor.", lang=".$lang);

	my $inc;
	
	my $user  = $ENV{'REMOTE_USER'};
	my $ext   = 'xml';
	my $raddr = quotemeta($ENV{'REMOTE_ADDR'});
	my $ip	  = $ENV{'REMOTE_ADDR'};
	
	my $dir = $atomcfg{'base_dir'};
	
	my $query = do_query("SELECT subscription_level, password, access_restriction, access_restriction_ip FROM `users` WHERE `login` = " . str_sqlize($user))->[0];
	
	my $access = $query->[0];
	my $password = $query->[1];
	my $access_restriction = $query->[2];
	my $access_restriction_ip = $query->[3];
	
	my $level = '';
	if ($access eq '0') { $level = ''; }                    # None
	if ($access eq '1') { $level = 'freexml.int'; }         # URL
	if ($access eq '2') { $level = 'freexml.int'; }         # URL+PRF
	if ($access eq '4') { $level = 'level4'; }              # Database
	if ($access eq '5') { $level = 'freexml.int'; }         # XML free
	if ($access eq '6') { $level = ''; }                    # URL free 
	
	my ($supplier_id, $vend, $sponsor, $join, $where, $qr);
	
	if ($level eq 'freexml.int') {
		$join = 'inner join supplier s using (supplier_id)';		
		$where = " AND s.is_sponsor = 'Y'";
	}
	my $quality;
	if ((defined($prod_id)) || (defined($product_id))) {
		
		unless ($lang) {
			no_xml(str_xmlize($prod_id),"Language should be necessarily specified");
		}

		my $qr = undef;

		if (defined($product_id)) {
			$qr = do_query("SELECT product_id FROM product WHERE public != 'L' and publish != 'N' and product_id = ".$product_id);
		}
		else {
			if (defined($vendor)) {
				$supplier_id = do_query("SELECT supplier_id FROM `supplier` WHERE `name` = ".str_sqlize($vendor))->[0][0] ||
					do_query("SELECT supplier_id FROM data_source_supplier_map WHERE data_source_id = 1 and symbol = " . str_sqlize($vendor))->[0][0];
				unless ($supplier_id) {
					no_xml(str_xmlize($prod_id),"The specified vendor does not exist");
				}
			}
			else {
				no_xml(str_xmlize($prod_id),"Vendor should be necessarily specified");
			}
			
			$vend = $supplier_id ? " AND `supplier_id` = ".str_sqlize($supplier_id) : ' AND 0';
			
			$qr = do_query("SELECT product_id FROM product WHERE public != 'L' and publish != 'N' and prod_id = ".str_sqlize($prod_id) . $vend);
			
			if (!$qr->[0][0]) {
				$qr = do_query("SELECT distinct product_id FROM distributor_product dp INNER JOIN product p using(product_id) $join  WHERE p.public != 'L' and p.publish != 'N' and dp.original_prod_id = ".str_sqlize($hin{'prod_id'}) . $where . $vend);
			}
			
			if ($#$qr > 0) {
				$output = 'metaxml';
			}
		}

		if ($#$qr == -1) {
			if(!$product_id and !$prod_id){
				no_xml(str_xmlize($prod_id),"No xml data for this product or product code is incorrect");
			}else{
				my $maped_product=do_query('SELECT map_product_id FROM product_deleted 
											 WHERE map_product_id!=0 AND
											 '.((defined($product_id))?' product_id = '.$product_id.' ':' prod_id = '.str_sqlize($prod_id).$vend));
				if($maped_product->[0] and $maped_product->[0][0]){
					no_xml(str_xmlize($prod_id),"Product was replaced with",{'Map_product_id'=>$maped_product->[0][0]});
				}else{
					no_xml(str_xmlize($prod_id),"No xml data for this product or product code is incorrect");
				}
			}
		}
		else {
			$product_id = $qr->[0][0];
			$sponsor = do_query("SELECT s.is_sponsor FROM product p INNER JOIN supplier s USING (supplier_id) WHERE p.product_id = " . str_sqlize($product_id) . $vend)->[0][0];
		}
		
		if (($level eq 'freexml.int') && ($sponsor ne 'Y')) {
			log_printf("Sponsor is " . $sponsor . ". Return no_xml");
			no_xml(str_xmlize($prod_id),"You are not allowed to have Full ICEcat access");
		}
		
		$quality = do_query("select cm.quality_index from product p INNER JOIN users u using(user_id) INNER JOIN user_group_measure_map ug ON u.user_group = ug.user_group INNER JOIN content_measure_index_map cm ON ug.measure = cm.content_measure where p.product_id = " . str_sqlize($product_id))->[0][0];
		
		#unless ($quality) {
		#	no_xml(str_xmlize($prod_id),"There is no full data-sheet for this product yet");			
		#}
		
		$inc = $hin{'prod_id'};
	}
	elsif (defined($hin{'ean_upc'})) {
		$qr = do_query("SELECT ean.product_id, s.is_sponsor FROM product_ean_codes ean INNER JOIN product p using (product_id) INNER JOIN supplier s USING (supplier_id)  WHERE p.public != 'L' and p.publish != 'N' and ean.ean_code = ".str_sqlize($ean));
		
		$inc = $hin{'ean_upc'};
		if ($#$qr == -1) {
			no_xml(str_xmlize($inc),"No xml data for this product or product code incorrect");
		}
		elsif (($qr->[0][1] ne "Y") && ($level eq 'freexml.int')) {
			no_xml(str_xmlize($inc),"You are not allowed to have Full ICEcat access");
		}
		elsif ($#$qr > 0) {
			$output = 'metaxml';			
		}
		else {
			$product_id = $qr->[0][0];
			$quality = do_query("select cm.quality_index from product p INNER JOIN users u using(user_id) INNER JOIN user_group_measure_map ug ON u.user_group = ug.user_group INNER JOIN content_measure_index_map cm ON ug.measure = cm.content_measure where p.product_id = " . str_sqlize($product_id))->[0][0];
		}
		
	}
	else {
		no_xml($inc, "Product_id or product partcode should be necessarily specified");
	}
	
	if ($access_restriction == 1) {
		if ($access_restriction_ip !~ /$raddr/) {
			no_xml($inc,"IP address not included in the user profile: $ip");
		}
	}
	
	my $pwd = do_query("SELECT password FROM `users` WHERE `login` = " . str_sqlize($user))->[0];
	
	my $pass = $pwd->[0];
	my $path = $atomcfg{'host'};
	my $xml_url = '';
	
	my $xml_path = '/export/' . $level . '/' . $lang . '/';
	
	if ($path =~ /^(http:\/\/)(.+)$/) {
		$xml_url = $1 . atom_util::escape($user) . ":" . atom_util::escape($pass) ."@" . $2;
	}
	
	$xml_url .= 'export/' . $level . '/' . $lang . '/' . $product_id . '.' . $ext;
	
	if ($output eq 'productxml') {
		
		# fixed by dima 20.11.2008, because we internally have Product XMLs in xml/level4/ only
		my $xml = $atomcfg{'xml_path'} . 'level4/' . $lang . '/' . get_smart_path($product_id) . $product_id . '.' . $ext;
		
		log_printf("GET> xml $xml");
		
		if ((-e $xml) || (-e $xml.'.gz')) {
			
			log_printf("GET> internal: ".$xml.", external: ".$xml_url);

			open XML, "/usr/bin/wget -q -O - '".$xml_url."' |";
			my $content = '';
			binmode $content, ":utf8";
			$content = join '', <XML>;
			close XML;

			if (!$content) {
		    no_xml($inc,"No access allowed to this language (folder)");
			}
			else {
		    print STDOUT "Content-type: text/xml; charset=utf-8\n\n";
		    print STDOUT $content;
			}
		}
		else {
			no_xml($inc,"No xml data for this product or product code incorrect");
		}
	}
	elsif ($output eq 'metaxml') {
		my ($hash, $hash2, $cmd);
		my $generated = format_date(time);

		log_printf("p_id = ".$product_id.", supplier_id=".$supplier_id);
		
		get_products4repository({'supplier_id' => $supplier_id, 'product_id' => $product_id, 'quality' => '0,1,2', 'do_add_distri'=>'1'});
		$hash = create_index_files(0,{'do_add_distri'=>1},0);
		# get file content
		my $hash2 = '';
		if($quality eq '0'){
			open TMP, "<".$hash->{'NOBODYXML'}->{'draftfilename'};
		}else{
			open TMP, "<".$hash->{'XML'}->{'draftfilename'};
		}
		binmode TMP, ":utf8";
		binmode $hash2, ":utf8";
		$hash2 = join '', <TMP>;
		close TMP;				
		# remove all tmp files
		for my $h (values %$hash) {
			$cmd = '/bin/rm -f '.$h->{'draftfilename'};
			`$cmd`;
		}

		$hash2 =~ s/%%target_path%%/$xml_path/gs;
		
		print "Content-type: text/xml; charset=utf-8\n\n";
		
		if ($hash2 ne '') {
			print STDOUT xml_utf8_tag .
		    "<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/files.index.dtd\">\n" .
				source_message()."\n".
		    "<ICECAT-interface " . xsd_header("files.index") . ">\n" .
		    "\t<files.index Generated=\"".$generated."\">" .
		    $hash2 . "\n" .
		    "\t</files.index>\n".
		    "</ICECAT-interface>";
		}
		else {
			print STDOUT xml_utf8_tag .
		    "<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/files.index.dtd\">\n" .
		    source_message()."\n".
		    "<ICECAT-interface " . xsd_header("files.index") . ">\n" .
		    "\t<files.index Generated=\"".$generated."\" />\n" .
		    "</ICECAT-interface>";
		}
	}
	else {
		no_xml($inc,"Syntax error");
	}
	
	undef %ENV;
	undef %hin;
}

sub _GET {
	my ($rs) = @_;
	
	my %mess;
	my @tmpl;
	my $tmp;
	my $query = $ENV{'QUERY_STRING'};
	$query =~ s/;+/;/gs;
	my @query_string = split(';',$query);
	
	if ($query eq '') {
		return 'FALSE';
		log_printf('GET > query string is NULL');
	}
	else {
		for $tmp (@query_string) {
			@tmpl = split('=',$tmp);
			if ($tmpl[1]) {
				$mess{$tmpl[0]}=$tmpl[1];		
			}
		}
	}
	
	if ($rs eq '') {
		return 'FALSE';
#		log_printf('GET > function is NULL');
	}
	else {
		if ($mess{$rs}) {
			return $mess{$rs};
		}
		else {
			return 'FALSE';
#			log_printf("GET > $rs not exists");
		}
	}
}

sub no_xml {
	my ($product_id,$error_msg,$ext_attrs) = @_;
	my $ext_attrs_txt;
	if(ref($ext_attrs) eq 'HASH'){
		for my $ext_attr(keys(%{$ext_attrs})){
			$ext_attrs_txt=' '.$ext_attr.'="'.str_xmlize($ext_attrs->{$ext_attr}).'" ' if $ext_attr and $ext_attrs->{$ext_attr};	
		}
	};
	print "Content-type: text/xml; charset=utf-8\n\n";
	print STDOUT xml_utf8_tag .
"<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-interface_response.dtd\">" .
source_message() .
"<ICECAT-interface " . xsd_header("ICECAT-interface_response") . ">\n
	<Product Code=\"-1\" ID=\"?" . str_xmlize($product_id) . "?\" ErrorMessage=\"" . str_xmlize($error_msg) . "\" $ext_attrs_txt />\n
</ICECAT-interface>
";

	exit(0);
}

sub format_date {
	my ($time) = @_;
	my $generated = strftime("%Y%m%d%H%M%S", localtime($time));
	return $generated;
}

1;

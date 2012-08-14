package icecat_server2;

#$Id: icecat_server2.pm 3625 2010-12-24 13:52:24Z vadim $

use strict;

use atomlog;
use atom_engine;
use atomsql;
use atom_misc;
use atom_mail;
use atomcfg;
use icecat_util;
use icecat_client;
use atom_html;
use atom_util;
use stat_report;
use data_management;
use POSIX qw (strftime);
use LWP::UserAgent;
use XML::LibXML;
use Data::Dumper;
use icecat_server2_repository;

## '1' = use old xml composition, '0' = use new multilang xml composition

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
								 &icecat_server_main
								 &icecat_server_main_local
								 &icecat_server_main_cgi
								 &icecat_server_main_cgi2html
								 &get_product_xml_data_OLD
								 &put_product_xml2_repo
								 &put_product_xml2_db_OLD
							);

 $SIG{ALRM} = sub { 
     my $message_text = $hin{'REQUEST_BODY'};
		 
		 if(!( $message_text=~m/xml/ )){
			 # log_printf('Trying to ungzip!');
			 $message_text = ungzip_data($message_text);
		 }

    atom_mail::sendmail(" the xml request is timed out!. The body:\n".$message_text,
							 $atomcfg{'bugreport_email'}, 'icecat', 'timeout'); 
	   
	 };
 alarm 1550;
}

sub build_xml_tree_old
{

my ($xml_message, $options) = @_;

use XML::LibXML;

my $parser = XML::LibXML->new();

my $doc = $parser->parse_string( $xml_message );

my $elem = $doc->getDocumentElement;

my $message = dump_xml($elem, $options);

#&back_parse($message, \&icecat_util::utf82latin);

return $message;
}

# this is used with LibXML
sub dump_xml
{
 my ($node, $option) = @_;
 
 my $libxml_text_tag = get_text_tag;

 my $hash = {};
 
 my @attr = $node->attributes();
 my $cnt = 0;
 for my $attr(@attr){
  if(defined $attr){
	  $cnt++;
    $hash->{$attr->nodeName} = $attr->nodeValue;
	}
 }
 
 my @nodes = $node->childNodes;

 for my $subnode(@nodes){
  if(defined $subnode){
	  my $nodename = $subnode->nodeName;
		if($nodename eq $libxml_text_tag){ 
			$nodename = 'content';
			my $nodevalue = $subnode->nodeValue;
			if(!(defined $nodevalue)){
				$hash->{$nodename} = '';
			} elsif(!($nodevalue=~m/^\n\s+$/)){
				$hash->{$nodename} = $nodevalue;
			}
		} else {
		  $cnt++;
			my $child = dump_xml($subnode, $option);
			my $key = $option->{'keyattr'}->{$nodename};
#			  print 'keyattr '.$key.' for '.$nodename."\n";
			if( $key  && ref($child) eq 'HASH' && defined $child->{$key} && ref($child->{$key}) eq ''){
			  my $childkey = $child->{$key};
				delete $child->{$key};
			  $hash->{$nodename}->{$childkey} = $child;
			} else {
				push @{$hash->{$nodename}}, $child;
			}
		}
	}
 }
if(!$cnt){
 $hash = $hash->{'content'} || '';
}
return $hash;
}


sub respond_message {

my ($message_text,$skip_validation) = @_;
my $response = {};

my $gzipped = 0;
my $plain_xml = '';
my $freeurls = 0;

if(!( $message_text=~m/xml/ )){
push_dmesg(4,'Trying to ungzip!');
 $message_text = ungzip_data($message_text);
 $gzipped = 1;
push_dmesg(4,'done');
}

my $rh = {};

push_dmesg(4,'parsing');
#log_printf($message_text);
my $message = build_xml_tree_old($message_text);
#log_printf ( Dumper ($message) );
push_dmesg(4,'done');

#  print Dumper($message);
my $root = $message->{'Request'}->[0];

my ($login, $pass, $status, $user_id);

# verifying login info
push_dmesg(4,'logging in');
$login = $root->{'Login'};
$pass	= $root->{'Password'};
$status = 1;
$user_id = '';

my $usr_data = do_query("select user_id, user_group, access_restriction, access_restriction_ip, subscription_level  from users where login =".str_sqlize($login)." and password = ".str_sqlize($pass));

if (($skip_validation) || ($usr_data && $usr_data->[0] && $usr_data->[0][1] eq 'shop' && $usr_data->[0][4]>0 && $usr_data->[0][4]!=5 && verify_address($usr_data->[0][2], $usr_data->[0][3], $ENV{'REMOTE_ADDR'}) && verify_login_expiration_date($usr_data->[0][0]))) {
	$status = 1;
	$user_id = $usr_data->[0][0];
	$freeurls = 1 if ($usr_data->[0][4]==6);
	
}
else {
	$status = -1;
}

# checking loadavg if it's too high - then denying request

my $load = `cat /proc/loadavg`;
	 $load = (split(' ',$load)) [0];
if ($load > 20){
# $status = -3;
}

#$status = 1;
$rh->{'Status'} = $status;

my $nowtime = time();

push_dmesg(4,'done');
push_dmesg(4,'logging xml request');
 $rh->{'ID'} = log_xml_request($root->{'Request_ID'}, $user_id, $status, $nowtime, $login);
push_dmesg(4,'done');

 $rh->{'Request_ID'}	= $root->{'Request_ID'}||'';
 $rh->{'Date'}	= localtime($nowtime);

my $errmsg;
if ($errmsg = req_validation($message_text)) {

	if ($errmsg eq 'DOCTYPE ERROR') {
		$rh->{'Error'} = "Warning. Standard dtd url where used. Use \"".$atomcfg{'host'}."dtd\/ICECAT-interface_request.dtd\"";
	}
	else {
		$rh->{'Error'} = $errmsg;
		return ({'Response' => [$rh]}, $gzipped);
	}
}

if ($status == 1) {

#
# FEATURE VALUES VOCABULARY
#

	if (defined $root->{'FeatureValuesVocabularyListRequest'}) {
		# get langs
		my @lang = ();
		my $v = '';
		if ($root->{'FeatureValuesVocabularyListRequest'}) {
			@lang = split(/,/, $root->{'FeatureValuesVocabularyListRequest'});
			for my $langid(@lang) {
				if (($langid eq int($langid)) && ($langid > 0)) {
					$v .= str_sqlize($langid).",";
				}
			}
			chop($v);
			$v = 'and langid in ('.$v.')' if ($v);
		}
		
		# get ...
		my $fvvs = do_query("select record_id, key_value, langid, feature_values_group_id, value from feature_values_vocabulary where trim(value) != '' ".$v." order by key_value asc, langid asc");
		my ($fvv, $fv, $prev_kv, $prev_group);
		$prev_kv = undef;
		for (@$fvvs,[undef]) {
			if (($prev_kv ne $_->[1]) && (defined $prev_kv)) {
				push @$fvv, {
					'Key_Value' => $prev_kv,
					'Group_ID' => $prev_group,
					'FeatureValue' => $fv
				} if $#$fv > -1;
				$fv = undef;
#				log_printf("\t\t2 push: key_value=".$_->[1].", f-vs = ".Dumper($fv));
			}

			push @$fv, { 'ID' => $_->[0], 'langid' => $_->[2], 'content' => $_->[4] } if ($_->[1] ne $_->[4]);

#			log_printf("\t1 push: content = ".$_->[4].", langid = ".$_->[2]);

			$prev_kv = $_->[1];
			$prev_group = $_->[3];
		}
		$rh->{'FeatureValuesVocabularyList'}->{'FeatureValuesVocabulary'} = $fvv;
	} # FeatureValuesVocabularyListRequest

#
# MEASURES
#
		
if(defined $root->{'MeasuresListRequest'}){
 # building measures list
 my $req = $root->{'MeasuresListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $v  = '0 ';
 for my $langid(@lang){
  $v  .= ' or l.langid = '.str_sqlize($langid);
 }

 do_statement("create temporary table tmp_measure (
measure_id      int(13)      NOT NULL,
sid             int(13)      NOT NULL,
tid             int(13)      NOT NULL,
langid          int(5)       NOT NULL,
sign            varchar(255) NOT NULL,
measure_sign_id int(13)      NOT NULL,
name            varchar(255) NOT NULL,
record_id       int(13)      NOT NULL,
description     mediumtext,
tex_id          int(13)     NOT NULL,
key (measure_id, langid), key (sid, langid), key (tid, langid))");

 do_statement("insert into tmp_measure(measure_id,sid,tid,langid) SELECT m.measure_id,m.sid,m.tid,l.langid FROM language l INNER JOIN measure m WHERE ($v)");

 do_statement("update tmp_measure tm inner join vocabulary v on tm.sid=v.sid and tm.langid=v.langid set tm.name=v.value, tm.record_id=v.record_id");
 do_statement("update tmp_measure tm inner join tex t on tm.tid=t.tid and tm.langid=t.langid set tm.description=t.value, tm.tex_id=t.tex_id");
 do_statement("update tmp_measure tm inner join measure_sign mn on tm.measure_id=mn.measure_id and tm.langid=mn.langid set tm.sign=mn.value, tm.measure_sign_id=mn.measure_sign_id");

 do_statement("delete from tmp_measure where record_id='0' and tex_id='0' and sign=''");

 my $measures = do_query("select measure_id, sign, record_id, langid, name, description, tex_id, measure_sign_id from tmp_measure");

 do_statement("drop temporary table if exists tmp_measure");
 
 for my $m(@$measures){
	 $rh->{'MeasuresList'}->{'Measure'}->{$m->[0]}->{"Sign"} = { 'content' => $m->[1] } if ($m->[3] == 1);
	 $rh->{'MeasuresList'}->{'Measure'}->{$m->[0]}->{"Signs"}->{"Sign"}->{$m->[7]} = { 'content' => $m->[1], 'langid' => $m->[3] };
	 $rh->{'MeasuresList'}->{'Measure'}->{$m->[0]}->{"Names"}->{"Name"}->{$m->[2]} = { 'content' => $m->[4], 'langid' => $m->[3] };
	 $rh->{'MeasuresList'}->{'Measure'}->{$m->[0]}->{"Descriptions"}->{"Description"}->{$m->[6]} = { 'content' => $m->[5], 'langid' => $m->[3] };
 }
}

#
# languages
#

if(defined $root->{'LanguageListRequest'}){
     my $lang_data = do_query("select langid,sid,code,short_code from language ");
     my $i=0;
     my $l;
     for my $lang (@$lang_data){
       $l->{$lang->[0]}={
                       'ID'        =>$lang->[0],
                       'Sid'       =>$lang->[1],
                       'Code'      =>$lang->[2],
                       'ShortCode' =>$lang->[3]
                       };
     }
     for my $key(keys %$l){
       $i=0;
       $lang_data=do_query("select record_id,langid,value from vocabulary where sid=".str_sqlize($l->{$key}->{'Sid'}));
       for my $lang (@$lang_data){
           $l->{$key}->{'Name'}->[$i]={
                               'langid'=>$l->{$lang->[1]}->{'ID'},
                               'Value' =>$lang->[2],
                               'ID'    =>$lang->[0],
                               };
       $i++;
       }
     }
     $i=0;
     for(keys %$l){
         $rh->{'LanguageList'}->{'Language'}->[$i]=$l->{$_};
         $i++;
     }
}



#
# features
#

if (defined $root->{'FeaturesListRequest'}) {
	# building measures list
	my $req = $root->{'FeaturesListRequest'}->[0];
	
	my @lang = split(/,/, $req->{'langid'});
	my $v 	= '0 ';
	my $t  = '0 ';
	my $ms = '0 ';
	for my $langid(@lang){
		$v 	 .= ' or  v.langid = '.str_sqlize($langid);
		$t	 .= ' or  t.langid = '.str_sqlize($langid);
		$ms  .= ' or ms.langid = '.str_sqlize($langid);
	}
	
	my $features = do_query("select f.feature_id, ms.value, v.record_id, v.langid, t.tex_id, v.value, t.value, ms.measure_id, f.class, ms.measure_sign_id, f.type, f.restricted_values
from feature f
left join vocabulary v on f.sid = v.sid and ($v)
left join tex t on f.tid = t.tid and ($t) and t.langid = v.langid
left join measure_sign ms on ms.measure_id = f.measure_id and ($ms) and ms.langid=v.langid");
	
	for my $f (@$features) {
		
		# $rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{'Measure'} = $f->[7];
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{'Measure'}->{$f->[7]} = { "Sign" => $f->[1] } if (($f->[3] == 1) && ($f->[7]));
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{'Measure'}->{$f->[7]}->{"Signs"}->{"Sign"}->{$f->[9]} = { "content" => $f->[1], 'langid' => $f->[3] } if ($f->[9]);
		
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{"Class"} = $f->[8];
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{"Type"} = $f->[10];
		
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{"Names"}->{"Name"}->{$f->[2]} = { "content" => $f->[5], 'langid' => $f->[3] } if ($f->[2]);
		
		if ($f->[4] ){
			$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{"Descriptions"}->{"Description"}->{$f->[4]} = { "content" => $f->[6], 'langid' => $f->[3] };
		}
		
		my @tmp = split /\n/, $f->[11];
		my @tmp2 = ();
		for (@tmp) {
			chomp;
			next if $_ eq '';
			push @tmp2, $_;
		}
		$rh->{'FeaturesList'}->{'Feature'}->{$f->[0]}->{"RestrictedValues"}->{"RestrictedValue"} = \@tmp2;
	}
}

#log_printf(Dumper($rh->{'FeaturesList'}));

#
# categories
#

if (defined $root->{'CategoriesListRequest'}) {
	# building measures list
	my $req = $root->{'CategoriesListRequest'}->[0];
	my @lang = split(/,/, $req->{'langid'});
	my $f = '0 ';
	my $f2 = join ",", @lang;
	$f .= " or v.langid in (".$f2.")" if ($f2);

	my $extra_sql = '';
	my $join_extra_sql = '';
	
	if (defined $req->{'Searchable'}) {
		$extra_sql = ' and c.searchable = '.str_sqlize($req->{'Searchable'});
		$join_extra_sql = ' and a.searchable = '.str_sqlize($req->{'Searchable'});
	}
	if (defined $req->{'Category_ID'}) {
		$extra_sql = ' and c.catid = '.str_sqlize($req->{'Category_ID'});
		$join_extra_sql = ' and a.catid = '.str_sqlize($req->{'Category_ID'});
	}
# log_printf(Dumper($req));
	if (defined $req->{'UNCATID'}) {
		$extra_sql = ' and c.ucatid = '.str_sqlize($req->{'UNCATID'});
		$join_extra_sql = ' and a.ucatid = '.str_sqlize($req->{'UNCATID'});
	}
	
	my $data = do_query("select a.catid, a.ucatid, a.sid, a.tid, a.pcatid, a.searchable, a.low_pic, a.thumb_pic, b.score, a.watched_top10, a.visible from category a left join category_statistic b on a.catid=b.catid where 1 $join_extra_sql");
	my $cat_name = {};
	my $pcat_name = {};
	my $cat_desc ={};
	my $cat_keys={};
	
# building cats	names
# my $cat_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid,tex.value,tex.tex_id, keywords,category_keywords.id from vocabulary,tex,category left join category_keywords on category_id=catid  and tex.langid=category_keywords.langid where tex.tid=category.tid and vocabulary.sid = category.sid and ($f) $extra_sql and vocabulary.langid=tex.langid");
# my $cat_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid, tex.value, tex.tex_id, keywords, category_keywords.id
# from category join category_keywords on category_id=catid
# join tex on category.sid=vocabulary.sid
# left join category_keywords on category_id=catid and category_keywords.langid=vocabulary.langid
# left join tex on category.tid=tex.tid and category_keywords.langid=tex.langid where ($f) $extra_sql");
	
my $cat_data = do_query("SELECT v.value, v.record_id, v.langid, c.catid, t.value, t.tex_id, keywords, ck.id
FROM category c
JOIN vocabulary v ON c.sid = v.sid
LEFT JOIN tex t ON c.tid = t.tid AND v.langid = t.langid
LEFT JOIN category_keywords ck ON ck.category_id = c.catid AND ck.langid = v.langid
WHERE ($f) $extra_sql");

	for my $cat_row(@$cat_data){
		push @{$cat_desc->{$cat_row->[3]}}, 
		{
			'ID' => $cat_row->[5],
			'langid' => $cat_row->[2],
			'Value'=> str_xmlize($cat_row->[4])
			} if ($cat_row->[5]);
			
		push @{$cat_keys->{$cat_row->[3]}}, 
		{
			'ID' => $cat_row->[7],
			'langid' => $cat_row->[2],
			'Value'=> str_xmlize($cat_row->[6])
			} if ($cat_row->[7]);
			
		push @{$cat_name->{$cat_row->[3]}},
		{
			'langid' 	=> 	$cat_row->[2],
			'Value'		=> 	$cat_row->[0],
			'ID'			=>	$cat_row->[1]
			} if ($cat_row->[1]);
			
		push @{$pcat_name->{$cat_row->[3]}},
		{ 
			'langid' 	=> 	$cat_row->[2],
			'content'	=> 	$cat_row->[0],
			'ID'			=>	$cat_row->[1]
			} if ($cat_row->[1]);
	}
	
	for my $row (@$data) {
	
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'UNCATID'} 	= $row->[1];
		
		for my $pcat_row (@{$pcat_name->{$row->[4]}}) {
			my $hash = {};
			%$hash = %{$pcat_row};
			push @{$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'Names'}->{'Name'}},
			$hash;
		}

		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'ID'} = $row->[4];
		# add vcategories to XML data
		my $vcats;
		$vcats = do_query("SELECT virtual_category_id, name FROM virtual_category WHERE category_id = " . $row->[0] );
		for my $vc (@$vcats) {
		    push @{$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'VirtualCategories'}->{'VirtualCategory'}}, {'Name' => str_xmlize($vc->[1]), 'ID' => $vc->[0]};
		}
		
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'LowPic'}								 = $row->[6];
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ThumbPic'}							 = $row->[7];
		if (defined $cat_name->{$row->[0]}) {
	    $rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Name'}		    = $cat_name->{$row->[0]};
		}
		if (defined $cat_keys->{$row->[0]}) {
			$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Keywords'}		= $cat_keys->{$row->[0]};
		}
		if (defined $cat_desc->{$row->[0]}) {
			$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Description'} = $cat_desc->{$row->[0]};
		}
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Searchable'} = $row->[5];
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Visible'}    = $row->[10];
		$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Score'}      = $row->[8] || 0;
		#$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'watched_top10'} = $row->[9];
	}
} # CategoriesList

#
# supplier categories
#

if(defined $root->{'SupplierCategoriesListRequest'}){
 # response code
 
 my $code = 1;
 
 my $req = $root->{'SupplierCategoriesListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 for my $langid(@lang){
  $f .= ' or vocabulary.langid = '.str_sqlize($langid);
 }

# getting supplier info from xml structure

 if(ref($req->{'Supplier'}) eq 'ARRAY'){
	$req->{'Supplier'} = $req->{'Supplier'}->[0];
  if(ref($req->{'Supplier'})){
 		$req->{'Supplier'}->{'Name'} = $req->{'Supplier'}->{'content'};
	} else {
	 	$req->{'Supplier'} = { 'Name' => $req->{'Supplier'}};
	}
 } else {
  # single element
  $req->{'Supplier'}->{'Name'} = $req->{'Supplier'};
 }

my $extra_sql = '';

# now  verifying input

 if($req->{'Supplier'}->{'Name'}||$req->{'Supplier'}->{'ID'}){
  my $where = '1 ';
	if($req->{'Supplier'}->{'Name'}){
	 $where .= 'and supplier.name = '.str_sqlize($req->{'Supplier'}->{'Name'});
	}
	if($req->{'Supplier'}->{'ID'}){
	 $where .= 'and supplier.supplier_id = '.str_sqlize($req->{'Supplier'}->{'ID'});
	}

  my $supp_data = do_query("select supplier_id, name from supplier where $where");
  if($supp_data->[0] && $supp_data->[0][1]){
	 # ok
	 $extra_sql = ' and product.supplier_id = '.$supp_data->[0][0];
	 $req->{'Supplier'}->{'ID'} = $supp_data->[0][0];
	 $req->{'Supplier'}->{'Name'} = $supp_data->[0][1];
	} else {
	 # ignoring supplier requirmets
	 # error
	 $code = 12 if ($req->{'Supplier'}->{'Name'});
	 $code = 13 if ($req->{'Supplier'}->{'ID'});
	}
 } else {
	 # ignoring supplier requirmets
	 # error
   $code = 14; # missing supplier data at all
	 $code = 12 if ($req->{'Supplier'}->{'Name'});
	 $code = 13 if ($req->{'Supplier'}->{'ID'});
 }
 
 if($code == 1){ 

   if($req->{'Searchable'}){
    $extra_sql .= ' and category.searchable = 1 ';	 
	 }

	 my $data = do_query("select product.catid, ucatid, sid, tid, pcatid, searchable from category, product where product.catid = category.catid $extra_sql group by product.catid");
	 my $cat_name = {};
	 my $pcat_name = {};


# building cats	names
	 for my $row(@$data){

		my $cat_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = $row->[0]");

		  for my $cat_row(@$cat_data){
			push @{$cat_name->{$cat_row->[3]}}, { 'langid' 	=> 	$cat_row->[2],
																						'content'	=> 	$cat_row->[0],
																						'ID'			=>	$cat_row->[1]
																					};
		  push @{$pcat_name->{$cat_row->[3]}}, { 
																						'langid' 	=> 	$cat_row->[2],
																						'content'	=> 	$cat_row->[0],
																						'ID'			=>	$cat_row->[1]
																					};
			}

		  $rh->{'SupplierCategoriesList'}->{'Category'}->{$row->[0]}->{'UNCATID'} 	= { 'content' => $row->[1] };
		  for my $pcat_row(@{$pcat_name->{$row->[4]}}){
			  my $hash = {};
				   %$hash = %{$pcat_row};
				push @{$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'Names'}->{'Name'}},
						 $hash;	
			}
			$rh->{'SupplierCategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'ID'}	= $row->[4];
			$rh->{'SupplierCategoriesList'}->{'Category'}->{$row->[0]}->{'Names'}->{'Name'}			= $cat_name->{$row->[0]};
			$rh->{'SupplierCategoriesList'}->{'Category'}->{$row->[0]}->{'Searchable'} = $row->[5];
	 }
 }
 $rh->{'SupplierCategoriesList'}->{'Supplier'}->{'Name'}->{'content'} 	= $req->{'Supplier'}->{'Name'} if ($req->{'Supplier'}->{'Name'}); 
 $rh->{'SupplierCategoriesList'}->{'Supplier'}->{'ID'} 		= $req->{'Supplier'}->{'ID'};  
 $rh->{'SupplierCategoriesList'}->{'Code'} 		= $code;  
}

#
# StatisticQueryList
#

if ( defined $root->{'StatisticQueryListRequest'} ){
#	log_printf('server');
	$rh->{'StatisticQueryListResponse'} = {};
	my $query = "select distinct stat_query.stat_query_id, stat_query.code from statistic_cache, stat_query where stat_query.stat_query_id=statistic_cache.stat_query_id and shop_id=$user_id";
	my $rows = do_query ( $query );
	for my $row ( @$rows ){
		my $statistic_query = {};
		$statistic_query->{'ID'} = $row->[0];
		$row->[1] =~m/\[shop[^\]]+\]\s*(.+)/i;
		$statistic_query->{'Code'} = $1;
		push @{$rh->{'StatisticQueryListResponse'}->{'StatisticQuery'}}, $statistic_query;
	}
}

#
# StatisticQueryDatesList
#

if ( defined $root->{'StatisticQueryDatesListRequest'} ){
	$rh->{'StatisticQueryDatesListResponse'} = {};
	my $date_start;
	my $date_end;
	# get dates for clauses 
	if ( $root->{'StatisticQueryDatesListRequest'}->[0]->{'DateStart'} ){
		$date_start = $root->{'StatisticQueryDatesListRequest'}->[0]->{'DateStart'};
		$date_start = do_query ('select unix_timestamp('.str_sqlize($date_start).")" )->[0][0];
#		log_printf ( 'Start '.$date_start );
	}
	if ( $root->{'StatisticQueryDatesListRequest'}->[0]->{'DateEnd'} ){
		$date_end = $root->{'StatisticQueryDatesListRequest'}->[0]->{'DateEnd'};
		$date_end = do_query ('select unix_timestamp('.str_sqlize($date_end).")" )->[0][0];
#		log_printf ( 'End '.$date_end );
	}

# bilding and run query from table statistic_cache

	for my $statistic_query ( @{$root->{'StatisticQueryDatesListRequest'}->[0]->{'StatisticQuery'} } ){
		my $query = "select statistic_id, date, period from statistic_cache where shop_id=$user_id and stat_query_id=".$statistic_query->{'ID'};
		if ( $date_start ){
			$query .= " and date >= $date_start";
		}

		if ( $date_end ){
			$query .= " and date <= $date_end";
		}
#		log_printf ('Query '. $query );

		my $rows = do_query ( $query );
		for my $row ( @$rows ){
			my $stat_query_hash = {};
# $stat_query_hash is hash for element StatisticQueryDate ( see dtd ) 
			$stat_query_hash->{'ID'} = $row->[0];
			$stat_query_hash->{'StatisticQuery_ID'} = $statistic_query->{'ID'};
			$stat_query_hash->{'Date'} = strftime ("%Y-%m-%d", localtime ( $row->[1] ));
			$stat_query_hash->{'Period'} = $row->[2];
			push @{$rh->{'StatisticQueryDatesListResponse'}->{'StatisticQueryDate'}}, $stat_query_hash;
		}
	}
}

#
# StatisticQueryDateDataReport
#

if ( defined $root->{'StatisticQueryDateDataReportRequest'} ){
	my $statistic_id = $root->{'StatisticQueryDateDataReportRequest'}->[0]->{'StatisticQueryDate'}->[0]->{'ID'};
#	log_printf ('ID'. $statistic_id );
	my $query = "select shop_id from statistic_cache where statistic_id=$statistic_id";
	my $user_id_from_statistic_cache = do_query($query)->[0][0];
	if ( $user_id == $user_id_from_statistic_cache ){
# Only for valid requests 
		my $head = {};
		$query = "select stat_query.code, statistic_cache.date, stat_query.period from stat_query, statistic_cache where stat_query.stat_query_id = statistic_cache.stat_query_id and statistic_cache.statistic_id=$statistic_id";
# building atributes for StatisticQueryDateDataReportResponse
		my $row = do_query( $query );
		$row->[0][0] =~m/\[shop[^\]]+\]\s*(.+)/i;
		$rh->{'StatisticQueryDateDataReportResponse'}->{'Code'} = $1;
		$rh->{'StatisticQueryDateDataReportResponse'}->{'Date'} = strftime ( "%Y-%m-%d", localtime( $row->[0][1] ) );
		$rh->{'StatisticQueryDateDataReportResponse'}->{'StatisticQueryDate_ID'} = $statistic_id;
		my $stat_query_template = load_complex_template ( 'stat_query.al', 1 );
		$rh->{'StatisticQueryDateDataReportResponse'}->{'Period'} = $stat_query_template->{'period_value_5'};

		
		
# get saved statistic dump from base;
#	this dump is hash $statistic->{'report_data'=>{}
#												  			 'query_env'=>{}
#																}

		my $statistic = statistic_from_base ( $statistic_id )->{'data'};
		my $data = $statistic->{'report_data'};
		my $query_env = $statistic->{'query_env'};
#		log_printf ( Dumper ( $query_env ) );
#		log_printf ( Dumper ( $data ) );
		my $levels = $query_env->{'levels'};

# get_dictionary is function for building dictionery;
# dictionary is hash for resolved ID of element to string value;
#
		sub get_dictionary ()
		{
		my ( $query_env, $levels ) = @_;
		my $dictionary={};
		for my $i ( 1, 2, 3 ){
			if ( exists ( $query_env->{'dictionary'}->{$i} ) ){
				my $query = $query_env->{'dictionary'}->{$i};
				my @tmp = @{ $query_env->{'all_id'} };
				if ( $#tmp >= 1 ){
					$query .= '('.join(',', @{ $query_env->{'all_id'} } ).')';
				}else{
					$query = $query_env->{'dictionary1'}->{$i};
				}
				my $rows = do_query ($query);
				if ( $levels->{$i} eq 'product.product_id' ){
#					log_printf ( 'Product '.$levels->{$i});
					for my $row (@$rows){
						my $RowValue = {};
						$RowValue->{'prod_id'} = $row->[1];
						$RowValue->{'name'} = $row->[2];
						$dictionary->{$i}->{$row->[0]} = $RowValue;
					}
				}else{
					for my $row (@$rows){
						$dictionary->{$i}->{$row->[0]} = $row->[1];
					}
				}
			}
		}
		return $dictionary;
		}

		my $dictionary = get_dictionary ($query_env,$levels);
		my $lines = {};
		my $level = 0;
		my $number = 1;
# get_lines is recursive function for building strings for report;
# 1 iteration - 1 string
#
		sub get_line {
			my ( $hash, $level, $lines, $number, $dictionary, $levels ) = @_;
			if ( !( ref ($hash) eq 'HASH') ){
				$level --;
				return $lines;
			}
			$level++;
			my @children = @{$hash->{'order'}};
			for my $child ( @children ){
				my $line={};
# line is hash for elemen Line, see DTD
#
				$line->{'Number'} = $number;
				$line->{'Level'} = $level;
				my $text;
				
# resolve ID to strung value;
#
				if ( exists ( $dictionary->{$level}->{$child} ) ){
					if ( $levels->{$level} eq 'product.product_id' ){
						$text = $dictionary->{$level}->{$child}->{'prod_id'}.' - '.$dictionary->{$level}->{$child}->{'name'};
					}else{
						$text = $dictionary->{$level}->{$child};
					}
				}else{
					$text = $child;
				}
				$line->{'Text'} = $text;
				$line->{'Count'} = $hash->{$child}->{'count'};
				$number ++;
				push @{$lines->{'line'}}, $line;
				my $current = $hash->{$child};
				get_line ( $current, $level, $lines, $number, $dictionary, $levels );
		}
			$level--;
			return ;
		}

		get_line ( $data, $level, $lines, $number, $dictionary, $levels );
		push @{$rh->{'StatisticQueryDateDataReportResponse'}->{'Body'}}, $lines;

	}
}

#
# Suppliers
#

if(defined $root->{'SuppliersListRequest'}){
 # building suppliers list
my $data;

 if( ref($root->{'SuppliersListRequest'}->[0]) eq 'HASH' ) {
	 my $extra_sql = 1;
   if($root->{'SuppliersListRequest'}->[0]->{'Searchable'}){
	  $extra_sql .= " and category.searchable = 1 ";
	 }
	 if($root->{'SuppliersListRequest'}->[0]->{'UNCATID'}){
	  $extra_sql .= "  and  category.ucatid = ".$root->{'SuppliersListRequest'}->[0]->{'UNCATID'};
	 }
	 if($root->{'SuppliersListRequest'}->[0]->{'Category_ID'}){
	  $extra_sql .= "  and category.catid = ".$root->{'SuppliersListRequest'}->[0]->{'Category_ID'};
	 }
	 # selecting suppliers
   my $ids = do_query("select distinct supplier_id from product, category where category.catid = product.catid and $extra_sql");
	 my $where = ' 0 ';
	 for my $id_row(@$ids){
	  $where .= ' or supplier.supplier_id = '.$id_row->[0];
	 }
	 my $suppliers = do_query("select supplier_id, name, thumb_pic, is_sponsor from supplier where $where");
   for my $supplier(@$suppliers){
		push @$data, $supplier if (defined $supplier);
	 }
 } else {

    $data = do_query("select supplier_id, name, thumb_pic, is_sponsor from supplier");
 }
 for my $row (@$data){
  $rh->{'SuppliersList'}->{'Supplier'}->{$row->[0]}->{'Name'}	= $row->[1];
  if($row->[2] ne ''){ $rh->{'SuppliersList'}->{'Supplier'}->{$row->[0]}->{'LogoPic'} = $row->[2]; }
  if($row->[3] eq 'Y'){ $rh->{'SuppliersList'}->{'Supplier'}->{$row->[0]}->{'Sponsor'} = 1; }
 }

}

#
# Distributors
#

if (defined $root->{'DistributorListRequest'}) {
	# building suppliers list
	my $data = do_query("select distributor_id, name, code from distributor");

	for my $row (@$data) {
		$rh->{'DistributorList'}->{'Distributor'}->{$row->[0]} = {
			'Name' => $row->[1],
			'Code' => $row->[2]
		};
	}
}

#
# Category feature
#

if(defined $root->{'CategoryFeaturesListRequest'}){
 my $req = $root->{'CategoryFeaturesListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $v = '0 ';
 my $ms = '0 ';
 for my $langid(@lang){
  $v .= ' or v.langid = '.str_sqlize($langid);
  $ms .= ' or ms.langid = '.str_sqlize($langid);
 }

 my ($catid, $ucatid, $low_pic);  # getting correct category id
 my $code = 1; # this request code

 if($req->{'UNCATID'}){
  my $refer = do_query("select catid, ucatid, low_pic from category where ucatid = ".str_sqlize($req->{'UNCATID'}));
  ($catid, $ucatid, $low_pic) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
  if(!$catid){
	 $code = 10; # uncatid is wrong
	}
 }
 
 if(defined $req->{'Category_ID'} ){
	 my $refer = do_query("select catid, ucatid, low_pic from category where catid = ".str_sqlize($req->{'Category_ID'}));
   ($catid, $ucatid, $low_pic) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
	if(!$catid){
	 $code = 11; # catid is wrong
	}
 }
 
 my $catidd;
 
 if($catid){
  $catidd = [[$catid, $ucatid]];
 } else {
  my $d = do_query("select catid, ucatid from category");
	$catidd = [];
	for my $row(@$d){
	 push @$catidd, $row;
	}
 }
 

 for my $crow (@$catidd){
    ($catid, $ucatid) = @$crow;
    my $extra_sql = '1 ';

    if($req->{'Searchable'}){
		  $extra_sql .= ' and category_feature.searchable = 1 ';
		}
    if($req->{'Key'}){
		  $extra_sql .= ' and feature.class = 0 ';
		}

		my $cat_data = do_query("select v.value, v.record_id, v.langid, c.catid from category c, vocabulary v where v.sid = c.sid and ($v) and c.catid = $catid");

# building feature group hashes 
 	my $feat_group_data = do_query("select fg.feature_group_id, v.value, v.langid, v.record_id from feature_group fg, vocabulary v where v.sid = fg.sid and ($v)");
	my $feat_group = {};
	for my $row(@$feat_group_data){
	 $feat_group->{$row->[0]}->{'ID'} = $row->[0];
	 push @{$feat_group->{$row->[0]}->{'Name'}}, 
	   {
		  "ID" => $row->[3],
			"Value" => $row->[1],
			"langid" => $row->[2]
		 }

	}
	
	# processing category features group
  my $cat_feat_group_data = do_query("select category_feature_group_id, feature_group_id, no from category_feature_group where catid = ".$catid);
  my $group_content = [];
  for my $row(@$cat_feat_group_data){
	 push @$group_content, 
			{
			 "ID" => $row->[0],
			 "No"	=> $row->[2],
			 "FeatureGroup" => $feat_group->{$row->[1]}
			}
	}

    my ($cat_name);
		
		  for my $cat_row(@$cat_data){
			 push @$cat_name, { 'langid' 	=> 	$cat_row->[2],
													'Value'		=> 	$cat_row->[0],
													'ID'			=>	$cat_row->[1]
												};
			}
			if (defined $cat_name) {
			    $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Name'}			= $cat_name;
			}
	 

 
 
	 # building category features list
	 my $data = do_query("select category_feature_id, f.feature_id, v.langid, v.value, ms.value, v.record_id, f.limit_direction, (cf.searchable * 10000000 + (1 - f.class) * 100000 + cf.no), cf.searchable, f.class, f.measure_id, cf.category_feature_group_id, restricted_search_values, restricted_values, ms.measure_sign_id, cf.mandatory, cf.use_dropdown_input

from category_feature cf
inner join feature f on f.feature_id = cf.feature_id
left  join vocabulary v on v.sid = f.sid and ($v)
left  join measure_sign ms on ms.measure_id = f.measure_id and ($ms) and v.langid=ms.langid

where cf.catid = $catid and $extra_sql");

	 for my $row(@$data){
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'CategoryFeature_ID'} = $row->[0];
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Name'}->{$row->[5]} = { 'langid' => $row->[2] ,  'Value' => $row->[3]} if ($row->[5]);
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Measure'}->{$row->[10]} = {'Sign' => $row->[4] } if ($row->[2] == 1);
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Measure'}->{$row->[10]}->{'Signs'}->{'Sign'}->{$row->[14]} = { 'content' => $row->[4], 'langid' => $row->[2] } if ($row->[14]);
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'LimitDirection'} = $row->[6];
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'No'} = $row->[7];
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Searchable'} = $row->[8];
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Class'} = $row->[9];
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'CategoryFeatureGroup_ID'} = int( $row->[11] );
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Mandatory'} = ($row->[15])?'1':'0';
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Use_Dropdown_Input'} = ($row->[16])?$row->[16]:'N';
		 log_printf("category_feature_id = ".$row->[0]);
		 my @tmp = split("\n", $row->[12] || $row->[13]);
		 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'RestrictedValue'} = \@tmp;
	 }
	 
	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'CategoryFeatureGroup'} = $group_content;
 	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'UNCATID'} = $ucatid;
 	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'LowPic'} = $low_pic;	 
	}
 $rh->{'CategoryFeaturesList'}->{'Code'} 		= $code;  
}
#log_printf(Dumper($rh));

#
# product lookup
#


if(defined $root->{'ProductsListLookupRequest'}){
 my $req = $root->{'ProductsListLookupRequest'}->[0];

 my ($catid, $ucatid);  # getting correct category id
 my $code = 1; # this request code
 if($req->{'UNCATID'}){
  my $refer = do_query("select catid, ucatid from category where searchable = 1 and ucatid = ".str_sqlize($req->{'UNCATID'}));
	($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
  if(!$catid){
	 $code = 10; # uncatid is wrong
	}
 }
 

# MinQuality
 
 my $minquality; 

 if($req->{'Category_ID'} ){
	 my $refer = do_query("select catid, ucatid from category where catid = ".str_sqlize($req->{'Category_ID'}));
   ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
	if(!$catid){
	 $code = 11; # catid is wrong
	}
 }
 if($req->{'ProductFamily'}->[0]->{'ID'} eq 'ID'){ undef  $req->{'ProductFamily'}->[0]->{'ID'};}
 if($req->{'ProductFamily'}->[0]->{'ID'}){
	 my $refer = do_query("select product_family.catid, ucatid from category, product_family where product_family.family_id =".str_sqlize($req->{'ProductFamily'}->[0]->{'ID'})." and product_family.catid = category.catid");
	 ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]);	 
	 if(!$catid){
		$code = 15; #catid undefined
	 }
 }
 if($code == 1){
 # category is ok
 
 my @lang = split(/,/, $req->{'langid'});
 my $f = '';
 my $ff = '';
 my $lang_table = $$."tmp_lang";
 my $query = "create temporary table $lang_table (langid int(13) not null,  key langid( langid ) )";
 do_statement($query);

 for my $langid(@lang){
  $f .= ' vocabulary.langid = '.str_sqlize($langid).' or';
  $ff.= ' langid = '.str_sqlize($langid).' or';
	do_statement("insert into ".$$."tmp_lang (langid) values ( $langid )");
 }
 chop($f);chop($f);chop($f);
 chop($ff);chop($ff);chop($ff);
 
 # getting product set for each feature limitation
 # also should check if the used features correctness
 
 for my $item('LookupText'){
 
 	 if(ref($req->{$item}) eq 'ARRAY'){ 
 		$req->{$item}  = $req->{$item}->[0];
	 }	

	 if(ref($req->{$item}) eq 'HASH'){ 	
  	 $req->{$item} = $req->{'content'};	 
	 }
 }

# getting supplier info from xml structure
 
 if(ref($req->{'Supplier'}) eq 'ARRAY'){
	$req->{'Supplier'} = $req->{'Supplier'}->[0];
  if(ref($req->{'Supplier'})){
 		$req->{'Supplier'}->{'Name'} = $req->{'Supplier'}->{'content'};
	} else {
	 	$req->{'Supplier'} = { 'Name' => $req->{'Supplier'}};
	}
 } else {
  # single element
  $req->{'Supplier'}->{'Name'} = $req->{'Supplier'};
 }

 my $extra_sql = '';
 if($freeurls) { $extra_sql = ' and product.supplier_id '.in_selected_sponsors; }

 if($req->{'MinQuality'}){
     $minquality = 'ICECAT';
     $extra_sql .= " and user_id <> 1 ";
 }
					

# now  verifying input
 if($req->{'Supplier'}->{'Name'}||$req->{'Supplier'}->{'ID'}){
  my $where = '1 ';
	if($req->{'Supplier'}->{'Name'}){
	 $where .= 'and supplier.name = '.str_sqlize($req->{'Supplier'}->{'Name'});
	}
	if($req->{'Supplier'}->{'ID'}){
	 $where .= 'and supplier.supplier_id = '.str_sqlize($req->{'Supplier'}->{'ID'});
	}

  my $supp_data = do_query("select supplier_id, name from supplier where $where");
  if($supp_data->[0] && $supp_data->[0][1]){
	 # ok
	 $extra_sql = ' and product.supplier_id = '.$supp_data->[0][0];
	} else {
	 # ignoring supplier requirmets
	}
 }

 if($req->{'ProductFamily'}->[0]->{'ID'}){
	my $fam_data = do_query("select product_id from product where family_id =".str_sqlize($req->{'ProductFamily'}->[0]->{'ID'}));
	if($fam_data->[0][0]){
	 $extra_sql = " and family_id =".$req->{'ProductFamily'}->[0]->{'ID'};
	}else{
	 #ignore
	}
 } 
 
 
 if($req->{'LookupText'}){
#	my $pattern = str_sqlize('%'.$req->{'LookupText'}.'%');
	my $pattern = str_sqlize($req->{'LookupText'});
	my $pattern2 = str_sqlize('%'.$req->{'LookupText'}.'%');


# creating tempoprary table for lookup text 
	do_statement("create temporary table ".$$."tmp_txt_tmp (product_id int(13) not null, key product_id ( product_id ) )");
	do_statement("create temporary table ".$$."tmp_txt (product_id int(13) not null, key product_id( product_id ) )");

#	insert into temporary table

	# search by name

	do_statement("insert into ".$$."tmp_txt_tmp select product.product_id from product where ( match (product.name) against($pattern)) $extra_sql");
	
	# search by short and long descriptions 
	do_statement("insert into ".$$."tmp_txt_tmp select product.product_id from product, product_description where product.product_id = product_description.product_id and ($ff) and ( match (product_description.short_desc) against($pattern)) and product.catid = $catid $extra_sql");
	# searche by prod_ud
	do_statement("insert into ".$$."tmp_txt_tmp select product.product_id from product, product_description where product.product_id = product_description.product_id and ($ff) and  product.prod_id like $pattern2  and product.catid = $catid $extra_sql");
	do_statement ( "insert into ".$$."tmp_txt select distinct product_id from ".$$."tmp_txt_tmp" );
	do_statement ("drop temporary table if exists ".$$."tmp_txt_tmp");

 }


# getting all of products
	my $market_country_id; 
	if($req->{'OnMarket'}){
		# identify country
		my $data = do_query("select country_id from country where code = ".str_sqlize($req->{'OnMarket'}));
		if($data->[0] && $data->[0][0]){
			$market_country_id = $data->[0][0];
		}
	}

# creating tempoprary table for all products
		do_statement("create temporary table ".$$."tmp_sup (product_id int(13) primary key not null)");
	
	if($market_country_id){
	
		do_statement("create temporary table all_products (product_id int(13) not null, index (product_id))");
		do_statement("insert into all_products select product.product_id from product where product.catid = $catid $extra_sql");
		do_statement("insert into ".$$."tmp_sup select all_products.product_id from all_products join country_product on all_products.product_id = country_product.product_id and active = 1 and country_id = $market_country_id");
		do_statement("drop temporary table if exists all_products");	
	} else {

#	insert into temporary table
		do_statement("insert into ".$$."tmp_sup select product.product_id from product where product.catid = $catid $extra_sql");
	}
 my $feature_cnt = 0;
 for my $feature(@{$req->{'Features'}->[0]->{'Feature'}}){
  if(!$feature || !$feature->{'ID'}){ next ; }
  my $feat_data = do_query("select feature_id, limit_direction from feature where feature_id = ".str_sqlize($feature->{'ID'}))->[0];
  if(defined $feat_data && defined $feat_data->[0]){

		my $limit 			= $feature->{'LimitValue'};
		my $feature_id 	=  $feat_data->[0];
		my $dir = $feat_data->[1];

		if($dir == 1){
		 $dir = ' <= ';
		 $limit =~s/[^\d\.]//g;		 
		} elsif($dir == 2){
		 $dir = ' >= ';
		 $limit =~s/[^\d\.]//g;
		} elsif($dir == 3){
		 $dir 	= ' = ';		# exact match
		 $limit = str_sqlize($limit);
		}

		$feature_cnt++;

# creating tempoprary table for features intersection 
		do_statement("create temporary table ".$$."tmp".$feature_cnt." (product_id int(13) primary key not null)");

#	insert into temporary table
		do_statement("insert into ".$$."tmp".$feature_cnt." select product_feature.product_id from product_feature, category_feature, feature where product_feature.value".$dir.$limit." and product_feature.category_feature_id = category_feature.category_feature_id and category_feature.feature_id = feature.feature_id and feature.feature_id = $feature_id and category_feature.catid = $catid");
	}
 }

#	intersection between temporary tables
  my $tmp_intersection_table = $$."tmp_intersection";
	do_statement("create temporary table ".$tmp_intersection_table."(product_id int(13) primary key not null)");

	my $from_part;
	my $where_part = "1";
	
	#for features
	for(my $i = 1; $i <= $feature_cnt; $i++){
	 $from_part .= " ".$$."tmp".$i.",";
	 $where_part .= " and ".$$."tmp_sup.product_id = ".$$."tmp".$i.".product_id";
	}
	
	#for lookup text
	if($req->{'LookupText'}){
	 $where_part .= " and ".$$."tmp_sup.product_id = ".$$."tmp_txt.product_id";
	 $from_part .= " ".$$."tmp_txt,";
	}	

	#for all products
	$where_part .= " and ".$$."tmp_sup.product_id = ".$$."tmp_sup.product_id";
  $from_part .= " ".$$."tmp_sup";
	
	do_statement("insert into ".$tmp_intersection_table." select ".$$."tmp_sup.product_id from ".$from_part." where ".$where_part);

# delete temporary tables
	for(my $i = 1; $i <= $feature_cnt; $i++){
		do_statement("drop temporary table if exists ".$$."tmp".$i);
	}
	if($req->{'LookupText'}){
	 do_statement("drop temporary table if exists ".$$."tmp_txt");
	}
	do_statement("drop temporary table if exists ".$$."tmp_sup");
	
 # now got all requests performed
 # filetring result set 

	my $prod_xml = load_complex_template('xml/products_list_lookup.xml');
	my $all_cat_data = get_categories( $tmp_intersection_table, $lang_table, $prod_xml, $catid );
#	log_printf("lang table = $lang_table");
	my $products = get_products_xml( $tmp_intersection_table, $all_cat_data, $prod_xml, undef, $minquality, \@lang, $lang_table);
	do_statement ( "drop temporary table if exists $lang_table");
#		return xml
	$prod_xml->{'body'} =~s/%%products%%/$products/g;
	$products = $prod_xml->{'body'};

	$prod_xml->{'body'} =~s/%%Code%%/$code/g;
	$products = $prod_xml->{'body'};

	if ( defined ( $rh->{'__plain_xml'} ) ) {
		$rh->{'__plain_xml'} = concat_scalar_refs ( $rh->{'__plain_xml'}, \ $products );
	}else{
		$rh->{'__plain_xml'} = \ $products;
	}
	do_statement("drop temporary table if exists $tmp_intersection_table");
 }
}

#
# Fulltxt search
# 

if ( defined $root->{'FulltextProductsSearchRequest'} ){
	my $start = time;
	my $start1;
	
	my $req = $root->{'FulltextProductsSearchRequest'}->[0];
	my $search_text = $req->{'Text'};
	my ($catid, $ucatid, $code );
	$code = 1;
	my $extra_sql='';
	my $query;
	my $minquality;
	my $prod_xml = load_complex_template('xml/fulltext_products_search.xml');
	if($req->{'Category_ID'} ){
		my $refer = do_query("select catid, ucatid from category where catid = ".str_sqlize($req->{'Category_ID'}));
		($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]);
		$extra_sql .= " and product.catid = $catid"; 
		if(!$catid){
			$code = 11; # catid is wrong
		}
	}
	
# MinQuality

       if ($req->{'MinQuality'} eq 'ICECAT'){
    		$minquality = 'ICECAT';
       }
       
# getting supplier info from xml structure
 
	if(ref($req->{'Supplier'}) eq 'ARRAY'){
		$req->{'Supplier'} = $req->{'Supplier'}->[0];
		if(ref($req->{'Supplier'})){
			$req->{'Supplier'}->{'Name'} = $req->{'Supplier'}->{'content'};
		} else {
			$req->{'Supplier'} = { 'Name' => $req->{'Supplier'}};
		}
	} else {
	# single element
		$req->{'Supplier'}->{'Name'} = $req->{'Supplier'};
	}

	if($req->{'Supplier'}->{'Name'}||$req->{'Supplier'}->{'ID'}){
		my $where = '1 ';
		if($req->{'Supplier'}->{'Name'}){
			$where .= 'and supplier.name = '.str_sqlize($req->{'Supplier'}->{'Name'});
		}
		if($req->{'Supplier'}->{'ID'}){
			$where .= 'and supplier.supplier_id = '.str_sqlize($req->{'Supplier'}->{'ID'});
		}

		my $supp_data = do_query("select supplier_id, name from supplier where $where");
		if($supp_data->[0] && $supp_data->[0][1]){
			# ok
			$extra_sql .= ' and product.supplier_id = '.$supp_data->[0][0];
		} else {
			# ignoring supplier requirmets
		}
	}

	if($code == 1){
		# category is ok
	 	my @lang = split(/,/, $req->{'langid'});
		my $f = '';
		my $ff = '';
		my $lang_table = $$."tmp_lang";
		$query = "create temporary table $lang_table (langid int(13) not null,  key langid( langid ) )";
		do_statement($query);
		for my $langid(@lang){
			$f .= ' vocabulary.langid = '.str_sqlize($langid).' or';
			do_statement("insert into ".$$."tmp_lang (langid) values ( $langid )");
			$ff.= ' langid = '.str_sqlize($langid).' or';
		}
		chop($f);chop($f);chop($f);
		chop($ff);chop($ff);chop($ff);

		$search_text =~ s/^\s*//;
		$search_text =~ s/\s*$//;

		my $total_cat_score=do_query('select sum(score) from category_statistic')->[0][0];
		my $pattern = str_sqlize($search_text);
		$query = "create temporary table ".$$."tmp_union_tmp (product_id int(13) not null, relevance double, cat_score int(11), key product_id ( product_id ) )";
		do_statement($query);
#search by product name
		$query = "insert into ".$$."tmp_union_tmp select product.product_id, match (product.name) against($pattern), score from product left join category_statistic on product.catid=category_statistic.catid where (match (product.name) against($pattern)) $extra_sql";
		do_statement( $query );
		
# search by product descriptions		
# Denied at the moment
#    do_statement("CREATE temporary TABLE ".$$."tmp_union_tmp_pd_match
#		              (
#									   product_id int(11),
#										 relevance  double,
#										 KEY product_id(product_id)
#									)");
#		do_statement("
#		              INSERT INTO ".$$."tmp_union_tmp_pd_match
#		              SELECT pd.product_id, match (pd.short_desc) against($pattern)
#									FROM product_description pd
#									WHERE 1 AND ($ff) AND (match (pd.short_desc) against($pattern))
#								 ");
#								 
#   do_statement("INSERT INTO ".$$."tmp_union_tmp
#		              SELECT tpm.product_id, tpm.relevance, cs.score
#									FROM ".$$."tmp_union_tmp_pd_match tpm, product p LEFT JOIN category_statistic cs ON p.catid=cs.catid
#		              WHERE  tpm.product_id = p.product_id
#								 ");
#		do_statement("DROP temporary TABLE if exists ".$$."tmp_union_tmp_pd_match");


#search by category keywords
		$query = "insert into ".$$."tmp_union_tmp select product.product_id,(match (ck.keywords) against($pattern))*100,score from product left join category_statistic on product.catid=category_statistic.catid, category_keywords as ck where  ($ff) and (match (ck.keywords) against($pattern)) and product.catid = ck.category_id";
		do_statement( $query );
#search by supplier name
		$query = "insert into ".$$."tmp_union_tmp select product.product_id,(match (s.name) against($pattern))*10,score from product left join category_statistic on product.catid=category_statistic.catid, supplier as s where  (match (s.name) against($pattern)) and product.supplier_id = s.supplier_id";
		do_statement( $query );
# Only for prod_id
		if ( is_prod_id ( $search_text ) ){
			my $pattern1 = str_sqlize($search_text.'%');
			my $pattern2 = str_sqlize('%'.$search_text);

			log_printf ("Search in prod_id");
			$query = "insert into ".$$."tmp_union_tmp select product.product_id, 10,score from product left join category_statistic on product.catid=category_statistic.catid, product_description where product.product_id = product_description.product_id and ($ff) and product.prod_id like $pattern1 $extra_sql";
			#log_printf ( $query );
			do_statement($query);
			$query = "insert into ".$$."tmp_union_tmp select product.product_id, 10,score from product left join category_statistic on product.catid=category_statistic.catid where product.prod_id like $pattern1 $extra_sql";
			do_statement($query);

			
		} 
		$query = "create temorary table ".$$."tmp_union1 (product_id int(13) not null, relevance double, key product_id ( product_id ) )";
		do_statement($query);
		$query = "insert into ".$$."tmp_union1 select product_id, SUM(relevance)*(((cat_score*5)/$total_cat_score)+0.1) from ".$$."tmp_union_tmp group by product_id";
		do_statement ( $query );
		$query = "create temporary table ".$$."tmp_union (product_id int(13) not null, relevance double, key product_id ( product_id ) )";
		do_statement ( $query );
		$query = "insert into ".$$."tmp_union select ".$$."tmp_union1.product_id, relevance from ".$$."tmp_union1, product where product.product_id=".$$."tmp_union1.product_id $extra_sql order by relevance DESC";
		do_statement ( $query );
		my $tmp_product_table_name = $$."tmp_union";
		my $all_cat_data = get_categories( $tmp_product_table_name, $lang_table, $prod_xml );
		

		do_statement ("drop temporary table if exists ".$$."tmp_union_tmp");
		do_statement ("drop temporary table if exists ".$$."tmp_union1");
		
		my $tmp_union_table = $$."tmp_union";
		my $add_atribute = {};
		$add_atribute->{'relevance'} = 1;
		my $products = get_products_xml( $tmp_product_table_name, $all_cat_data, $prod_xml, $add_atribute, $minquality, \@lang, $lang_table);

		do_statement ( "drop temporary table if exists $lang_table");
		
#		return xml

		$prod_xml->{'body'} =~s/%%products%%/$products/g;
		$products = $prod_xml->{'body'};

		if ( defined ( $rh->{'__plain_xml'} ) ) {
			$rh->{'__plain_xml'} = concat_scalar_refs ( $rh->{'__plain_xml'}, \ $products );
		}else{
			$rh->{'__plain_xml'} = \ $products;
		}
	}
	do_statement ("drop temporary table if exists ".$$."tmp_union");
}

sub is_prod_id (){
	my ( $text ) = @_;
	my $is_prod_id = 1;

# 1. Searching graps in text
	if ( $text =~ m/\s+/ ){
		$is_prod_id = 0;
		return $is_prod_id;
	}
# 2. Searching digits
	if ( $text =~ m/[0-9]/){
		$is_prod_id = 1;
		return $is_prod_id;
	}else{
		$is_prod_id = 0;
		return $is_prod_id;
	}
}

sub get_categories (){
# this is used only as a combination with get_products_xml, and utf encoding is performed there
	my ( $tmp_product_table_name, $lang_table, $prod_xml, $single_catid ) = @_;
	my $cat_start = time;
	my $all_cat_data = {};
	my $query;
	$query = "create temporary table ".$$."tmp_categories (catid int(13) not null, key catid ( catid ) )";
	do_statement ( $query );
	if(!$single_catid){
		$query = "insert into ".$$."tmp_categories select distinct product.catid from product, $tmp_product_table_name where product.product_id=".$tmp_product_table_name.".product_id";
		do_statement ( $query );
	} else {
		$query = "insert into ".$$."tmp_categories values ($single_catid)";
		do_statement ( $query );
	}
	$query = "select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.searchable, category.ucatid, ".$$."tmp_categories.catid from category,vocabulary, ".$$."tmp_categories, $lang_table where vocabulary.sid = category.sid and $lang_table.langid=vocabulary.langid  and ".$$."tmp_categories.catid=category.catid";
	my $cat_data = do_query($query);
	for my $cat_row(@$cat_data){
		my $cat_content_cache = {};
		if ( !defined ( $all_cat_data->{$cat_row->[5]} ) ){
			my $cat_name_xml = repl_ph($prod_xml->{'category_name'},
														{ 'Name_id' => $cat_row->[1],
															'langid' => $cat_row->[2],
															'Value'=> str_xmlize($cat_row->[0])
														});
			$cat_content_cache->{'UNCATID'} = $cat_row->[4];
			$cat_content_cache->{'Searchable'}= $cat_row->[3];
			$cat_content_cache->{'Name'} = $cat_name_xml;
			$all_cat_data->{$cat_row->[5]} =  $cat_content_cache;
		}else{
			my $cat_name_xml = repl_ph($prod_xml->{'category_name'},
														{ 'Name_id' => $cat_row->[1],
															'langid' => $cat_row->[2],
															'Value'=> str_xmlize($cat_row->[0])
														});
			$all_cat_data->{$cat_row->[5]}->{'Name'} .= $cat_name_xml;
		}
	}
	do_statement ( "drop temporary table if exists ".$$."tmp_categories" );
	return $all_cat_data;
}

sub get_products_xml{
	my ( $tmp_product_table, $all_cat_data, $prod_xml, $add_atributes, $exclude_noeditor, $lang_arr, $lang_table ) = @_;
	my @lang = @$lang_arr;
	my $products;
	my $query;
	my $datas;
	my $ShortDesc;
	
	my $datas_descriptions;
	my $datas_products;

	my $extra_where = '';
	
  if($exclude_noeditor){
     $extra_where = ' and u.user_group!=\'nogroup\'';
  }
	
	# Step 1. Creating temporary tables
	do_statement("CREATE temporary TABLE $tmp_product_table\_product 
	              (
								 product_id int(11) PRIMARY KEY,
								 prod_id varchar(70),
								 supplier_id int(11), 
								 catid int(11),
								 name varchar(255),
								 low_pic varchar(255),
								 high_pic varchar(255),
								 thumb_pic varchar(255),
								 relevance double,
								 score double,
								 supplier_name varchar(70),
								 user_group varchar(70)
								)");
								
	do_statement("CREATE temporary TABLE $tmp_product_table\_product_description
	              (
								  product_id int(11),
									short_desc varchar(255),
									langid int(5),
									product_description_id int(11),
									PRIMARY KEY (product_id, langid)
								)"	
								);
								
								
	# Step 2. First JOIN to $tmp_product_table_product and JOIN to $tmp_product_table_product_description

	if ($add_atributes->{'relevance'}){
	
	    # QUICK SEARCH
			
			$datas_products		 	= do_query("
			              SELECT p.product_id, p.prod_id, p.supplier_id, s.name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic , u.user_group, ".$tmp_product_table.".relevance
										FROM product p , $tmp_product_table, supplier s, users u
										WHERE p.product_id = ".$tmp_product_table.".product_id AND s.supplier_id = p.supplier_id
										      AND p.user_id = u.user_id $extra_where
										LIMIT 500");
										
      $datas_descriptions = do_query("
									 SELECT HIGH_PRIORITY pd.product_id, pd.short_desc, pd.langid, pd.product_description_id
									 FROM product_description pd join $lang_table on pd.langid = $lang_table.langid, $tmp_product_table
									 WHERE ".$tmp_product_table.".product_id = pd.product_id 
									");
			
	    $query = "SELECT  p.product_id, p.prod_id, p.supplier_id, p.supplier_name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic, p.relevance,
			                  pd.short_desc, pd.langid, pd.product_description_id, p.user_group
                FROM    $tmp_product_table\_product p LEFT JOIN $tmp_product_table\_product_description pd ON pd.product_id = p.product_id ";
   		$datas = do_query($query);

	}elsif( $add_atributes->{'Score'}){
      
			# top10's output 

			$datas_products		 	= do_query("
			              SELECT p.product_id, p.prod_id, p.supplier_id, s.name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic , u.user_group, ".$tmp_product_table.".score 
										FROM product p , $tmp_product_table, supplier s, users u
										WHERE p.product_id = ".$tmp_product_table.".product_id AND s.supplier_id = p.supplier_id
										      AND p.user_id = u.user_id $extra_where
      						 ");
									 
      $datas_descriptions = do_query("
			              SELECT HIGH_PRIORITY pd.product_id, pd.short_desc, pd.langid, pd.product_description_id
									 	FROM product_description pd join $lang_table on pd.langid = $lang_table.langid, $tmp_product_table
									 	WHERE ".$tmp_product_table.".product_id = pd.product_id 
									 ");

      $query = "SELECT p.product_id, p.prod_id, p.supplier_id, p.supplier_name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic, 
			                 p.score,pd.short_desc, pd.langid,pd.product_description_id,p.user_group
                FROM   $tmp_product_table\_product p LEFT JOIN $tmp_product_table\_product_description pd ON pd.product_id = p.product_id";
   		#$datas = do_query($query);	
	
	}else{
      $datas_products		 	= do_query("
									 SELECT HIGH_PRIORITY p.product_id, p.prod_id, p.supplier_id, s.name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic, u.user_group
									 FROM product p , $tmp_product_table, supplier s, users u
									 WHERE p.product_id = ".$tmp_product_table.".product_id AND s.supplier_id = p.supplier_id
									 AND p.user_id = u.user_id $extra_where
									");
      $datas_descriptions = do_query("
									 SELECT HIGH_PRIORITY pd.product_id, pd.short_desc, pd.langid, pd.product_description_id
									 FROM product_description pd join $lang_table on pd.langid = $lang_table.langid, $tmp_product_table
									 WHERE ".$tmp_product_table.".product_id = pd.product_id 
									");
	    $query = "SELECT p.product_id, p.prod_id, p.supplier_id, p.supplier_name, p.catid, p.name, p.low_pic, p.high_pic, p.thumb_pic,
			                 pd.short_desc, pd.langid,pd.product_description_id, p.user_group
	               FROM   $tmp_product_table\_product p LEFT JOIN $tmp_product_table\_product_description pd ON pd.product_id = p.product_id"; 

  		#$datas = do_query($query);
	}

	do_statement("DROP temporary TABLE if exists $tmp_product_table\_product_description");
	do_statement("DROP temporary TABLE if exists $tmp_product_table\_product");
	
	my $sd = {};
	my $langid;
	my $short_desc;
	my $pd_id;
	my $count = 0;
	my $quality;
	my $quality_name;
	
	if($add_atributes->{'relevance'} || $add_atributes->{'Score'}){
		 $short_desc=1;
		 $langid=2;
		 $pd_id=3;
		 $quality=9;
	}else{
		 $short_desc=1;
		 $langid=2;
		 $pd_id=3;
		 $quality=9;
	}
	
	my $datum;
	for (@$datas_descriptions) {
#   if (!$sd->{$_->[0]}){
#	       $datum->[$count] = $_;
#	       $count++;
#	  }
	  $sd->{$_->[0]}->{'id'}->{$_->[$langid]} = $_->[$pd_id];
	  $sd->{$_->[0]}->{$_->[$langid]} = $_->[$short_desc];
	}


#	$datas = $datum;
	@lang=(1,2,3) if !$lang[0];

	my $add_atributes_relevance = $add_atributes->{'relevance'};
	my $add_atributes_score 		= $add_atributes->{'Score'};
	my $add_atributes_flag			= 0;
	if($add_atributes_relevance || $add_atributes_score){
		$add_atributes_flag = 1;
	}
	
	for my $data(@$datas_products) {
		 my $row = $data;
		 my $product_id = $data->[0];
		 my $category_id = $data->[4];
		 my $hash = {};

     # building product_body entries
		 
		 $quality_name = get_quality_measure($row->[$quality]);
		
		my $product_description;
		
		
		for(@lang){
                #log_printf($sd->{$product_id}->{$_});
		            $product_description.=s_repl_ph($prod_xml->{'product_description'},
		    		      {
				             'id' => $sd->{$product_id}->{'id'}->{$_},
				             'short_desc' => str_xmlize($sd->{$product_id}->{$_}),
				             'langid' => $_
				          }) if $sd->{$product_id}->{'id'}->{$_};
		
		}
		
		$hash = {
							'product_description'	 => $product_description,
							'category_names' => $all_cat_data->{$category_id}->{'Name'},
							'Product_id' => $product_id,
							'Prod_id' => str_xmlize( $row->[1]),
							'ThumbPic' => str_xmlize( $row->[8]),
							'HighPic' => str_xmlize( $row->[7]),
							'Product_name' => str_xmlize( $row->[5]),
							'LowPic' => str_xmlize( $row->[6]),
							'Quality' => $quality_name,
							'Cat_id' => $row->[4],
							'UNCATID' => $all_cat_data->{$category_id}->{'UNCATID'},
							'Searchable' => $all_cat_data->{$category_id}->{'Searchable'},
							'Sup_ID' => $row->[2],
							'Sup_Name' => str_xmlize($row->[3])
						};
		 if($add_atributes_flag){ 
			 if($add_atributes_relevance ){
				  $hash->{'Relevance'} = str_xmlize( $row->[10] );
			 }
			 if( $add_atributes_score ){
				  $hash->{'Score'} = str_xmlize( $row->[10] );
			 }
		 }
		$products .= s_repl_ph($prod_xml->{'product_body'}, $hash);
		#undef $hash;
		#undef $data;
		#undef $row;
	}
	return $products;
}

###################################################################################################

#
# product statistic
#

if (defined $root->{'ProductsStatistic'}) {
	my $req = $root->{'ProductsStatistic'}->[0];
	if (ref($req) eq 'HASH') {
 
		my @lang = split(/,/, $req->{'langid'});
		my $f = '0';
		my $lang_table = $$."tmp_lang";
		my $query = "create temporary table ".$lang_table." (langid int(13) not null,  key langid( langid ) )";
		do_statement($query);
		push @lang, 1; # by default
		push @lang, 2; # by default
		push @lang, 3; # by default
		for my $langid (@lang) {
			do_statement("insert into ".$lang_table." (langid) values ( $langid )");
			$f .= ' or vocabulary.langid = '.str_sqlize($langid);
		}

		my ($catid, $ucatid);
		
		# getting catid
		if ($req->{'UNCATID'}) {
			my $refer = do_query("select catid, ucatid from category where ucatid = ".str_sqlize($req->{'UNCATID'}));
			($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
		}


		# MinQuality
		
		my $minquality;
		
		if ($req->{'MinQuality'}) {
			$minquality = 'ICECAT';
		}
 
		if (defined $req->{'Category_ID'} ) {
			my $refer = do_query("select catid, ucatid from category where catid = ".str_sqlize($req->{'Category_ID'}));
			($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
		}
 
		if ($req->{'Type'} eq 'TOP10' && $catid) {
			
			my $extra_sql = '';
			if ($freeurls) { $extra_sql = ' and product.supplier_id '.in_selected_sponsors; }
			my $data = do_query("select product.product_id, score from product_statistic, product where product.product_id = product_statistic.product_id and product.catid = ".str_sqlize($catid).$extra_sql." order by score desc limit 20");
			
# creating tempoprary table for features intersection 
			my $tmp_table = $$."tmp_top10";
			do_statement("create temporary table ".$tmp_table." (product_id int(13) primary key not null, score int(13) not null default 0)");
			
#	insert into temporary table
			do_statement("insert into ".$tmp_table." select product.product_id, score from product_statistic, product where product.product_id = product_statistic.product_id and product.catid = ".str_sqlize($catid).$extra_sql." order by score desc limit 20");
			
			my $prod_xml = load_complex_template('xml/products_statistic.xml');
			my $all_cat_data = get_categories( $tmp_table, $lang_table, $prod_xml );
			my $add_atributes = {};
			$add_atributes->{'Score'} = 1;
			my $products = get_products_xml( $tmp_table, $all_cat_data, $prod_xml, $add_atributes,$minquality, [1,2,3], $lang_table);
			do_statement("drop temporary table if exists ".$lang_table);
#		return xml
			$prod_xml->{'body'} =~s/%%products%%/$products/g;
			$products = $prod_xml->{'body'};
			
			if ( defined ( $rh->{'__plain_xml'} ) ) {
				$rh->{'__plain_xml'} = concat_scalar_refs ( $rh->{'__plain_xml'}, \ $products );
			}else{
				$rh->{'__plain_xml'} = \ $products;
			}
			do_statement("drop temporary table if exists ".$tmp_table);
		}
	}
}

#
# requires(clients requires to describe specific products)
#

if(defined $root->{'DescribeProductsRequest'}){
#my $rh = {};
my $resp;
my $cnt = 0;
my ($p_id, $pr_id, $s_id, $s_code, $cl_email, $todate, $cl_msg, $where);
    for my $cl_req(@{$root->{'DescribeProductsRequest'}->[0]->{'DescribeProductRequest'}}){
	if($cl_req->{'Product_id'}){ $p_id = $cl_req->{'Product_id'};}
	if($cl_req->{'Prod_id'}){ $pr_id = $cl_req->{'Prod_id'};}
	if($cl_req->{'Supplier_id'}){ $s_id = $cl_req->{'Supplier_id'};}
	if($cl_req->{'Supplier_Code'}){ $s_code = $cl_req->{'Supplier_Code'};}
	if($cl_req->{'Email'}){ 
	    $cl_email = $cl_req->{'Email'}; 
	}
	else{
	    $cl_email = "";
	}
	if($cl_req->{'toDate'}){ 
	    $todate = $cl_req->{'toDate'};
	}
	else{
	    $todate = "";
	}
	if($cl_req->{'Message'}){ 
	    $cl_msg = $cl_req->{'Message'};
	}
	else{
	    $cl_msg = "";
	}
	if($s_code && !$s_id){
	    my $resp = do_query("select supplier_id from supplier where name=".str_sqlize($s_code));
	    if($resp->[0][0]){
		$s_id = $resp->[0][0];
	    }
	}
	$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'ID'} = $cnt;		
	if($p_id){$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Product_id'} = $p_id;}
	if($pr_id){$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Prod_id'} = $pr_id;}
	if($s_id){$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Supplier_id'} = $s_id;}
	if($s_code){$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Supplier_Code'} = $s_code;}
	if(!$p_id){
#	log_printf("\npid=$p_id\nprid=$pr_id\nsid=$s_id\nemail=$cl_email\ntodate$todate\nmsg=$cl_msg\n");
	    if($pr_id && !$s_id){
		my $resp = do_query("select product_id, count(product_id) from product where prod_id=".str_sqlize($pr_id)." group by prod_id");
		if($resp->[0][1] && ($resp->[0][1] > 1)){
		    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Error'} = "Multiple products are matching your request";		    
		    $p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $todate = ""; $cl_msg= "";
		    $cnt++;
		    next;
		}
		if($resp->[0][1] && ($resp->[0][1] == 0)){
		    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Error'} = "No product was found on request";		    
		    $p_id = ""; $pr_id = ""; $s_id = ""; $cl_email = ""; $todate = ""; $cl_msg= "";
		    $cnt++;
		    next;
		}
		if($resp->[0][0]){
		    $p_id = $resp->[0][0];
		}
	    }
	    if($pr_id && $s_id){
		my $resp = do_query("select product_id from product where prod_id=".str_sqlize($pr_id)." and supplier_id=".str_sqlize($s_id));
		if($resp->[0][0]){
		    $p_id = $resp->[0][0];
		}
		else{
		    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Error'} = "No product was found on request";
		    $p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $todate = ""; $cl_msg= "";
		    $cnt++;		    
#		    return ({'Response' => [$rh]}, $gzipped);
		    next;
		}
	    }
	    if(!$p_id){
		$rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Error'} = "No product was found on request";
		$p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $todate = ""; $cl_msg= "";		
		$cnt++;		    
#		return ({'Response' => [$rh]}, $gzipped);
		next;
	    }
	}

	if(!$pr_id or !$s_id){
	    my $resp = do_query("select prod_id, supplier_id from product where product_id=".str_sqlize($p_id));
	    $pr_id = $resp->[0][0];
	    $s_id = $resp->[0][1];
	}
#mapped prod_id
    my $p = {"supplier_id" => $s_id, "prod_id" => $pr_id};
#    $pr_id = get_mapped_prod_id($p);
#check status    
    my $stat = 0;
    my $ans1 = do_query("select user_id from product where product_id=".str_sqlize($p_id));
    my $ans2 = do_query("select user_group from users where user_id=".str_sqlize($ans1->[0][0]));
    my $qual_rat = get_quality_measure($ans2->[0][0]);
    my $qual = get_quality_index($qual_rat);
    if($qual > 0){$stat = 0;}
    else{$stat = 1;}

# register require in requires journal
	insert_rows('describe_product_request', {  
					    'product_id' => str_sqlize($p_id),
                        		    'prod_id' => str_sqlize($pr_id),
	                                    'supplier_id' => str_sqlize($s_id),
					    'email' => str_sqlize($cl_email),
					    'user_id' => str_sqlize($user_id),
					    'message' => str_sqlize($cl_msg),
					    'todate' => str_sqlize($todate),
					    'date' => str_sqlize(`date +%Y%m%d%H%M%S`),
					    'status' => str_sqlize($stat)
 	                                  }
	            );
#make up response
    my $dp_id = sql_last_insert_id();
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'ID'} = $cnt;		
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Product_id'} = $p_id;
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Prod_id'} = $pr_id;
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Supplier_id'} = $s_id;
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Status'} = $stat;
    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Confirmation'} = "The request is accepted";    
#    delete($rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'Error'});   
    $p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $todate = ""; $cl_msg= "";    
#    $rh->{'DescribeProductsResponse'}->{'DescribeProductResponse'}->[$cnt]->{'DescribeProductRequest_ID'} = $dp_id;
    $cnt++;
#   my $response = {'DescribeProductsResponse' => [$rh]};
#   $response = xml_out($response);
#   log_printf("response = $$response\n");
    }
   
}


#
# Complaints request(products description Complaints)
#

if(defined $root->{'ProductsComplaintRequest'}){
##my $rh = {};
my $resp;
my $cnt = 0;
my ($p_id, $pr_id, $s_id, $s_code, $cl_email, $date, $cl_msg, $cl_name, $editor, $cl_subj, $cl_company);
for my $cl_req(@{$root->{'ProductsComplaintRequest'}->[0]->{'ProductComplaintRequest'}}){
		if($cl_req->{'Product_id'}){ $p_id = $cl_req->{'Product_id'};}
		if($cl_req->{'Prod_id'}){ $pr_id = $cl_req->{'Prod_id'};}
		if($cl_req->{'Supplier_id'}){ $s_id = $cl_req->{'Supplier_id'};}
 		if($cl_req->{'Supplier_Code'}){ $s_code = $cl_req->{'Supplier_Code'};}	
		if($cl_req->{'Email'}){ 
		 $cl_email = $cl_req->{'Email'}; 
		}
		else{
	    $cl_email = "";
		}
		if($cl_req->{'Date'}){ 
	   $date = $cl_req->{'Date'};
		}
		else{
	    $date = "";
		}
		if($cl_req->{'Message'}){ 
	    $cl_msg = $cl_req->{'Message'};
      $cl_msg =~s/\\n/<BR>/gi;
      $cl_msg =~s/\n/<BR>/gi;
		 	$cl_msg =~s/\s/&nbsp;/gi;
		}
		else{
	    $cl_msg = "";
		}
		if($cl_req->{'Name'}){ 
	    $cl_name = $cl_req->{'Name'};
		}
		else{
	    $cl_name = "";
		}
		if($cl_req->{'Subject'}){
	    $cl_subj = $cl_req->{'Subject'};
		}
		else{
	    $cl_subj = "";
		}
    if($cl_req->{'Company'}){
      $cl_company = $cl_req->{'Company'};
    }
    else{
      $cl_company = "no company";
    }
		if($s_code && !$s_id){
	    my $resp = do_query("select supplier_id from supplier where name=".str_sqlize($s_code));
	    if($resp->[0][0]){
				$s_id = $resp->[0][0];
	    }
		}
#		$rh->{'ComplaintProductsResponse'}->{'ComplaintProductResponse'}->[$cnt]->{'ID'} = $cnt;		
		if($p_id){$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Product_id'} = $p_id;}
		if($pr_id){$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Prod_id'} = $pr_id;}
		if($s_id){$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Supplier_id'} = $s_id;}
		if($s_code){$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Supplier_Code'} = $s_code;}
		if(!$p_id){
#log_printf("\npid=$p_id\nprid=$pr_id\nsid=$s_id\nemail=$cl_email\ntodate$todate\nmsg=$cl_msg\n");
	    if($pr_id && !$s_id){
				my $resp = do_query("select product_id, count(product_id) from product where prod_id=".str_sqlize($pr_id)." group by prod_id");
				if($resp->[0][1] && ($resp->[0][1] > 1)){
		   		$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Error'} = "Multiple products are matching your complaint";		    
		   		$p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $date = ""; $cl_msg= ""; $cl_name = ""; $cl_company = "";
		   		$cnt++;
		   		next;
				}
				if($resp->[0][1] && ($resp->[0][1] == 0)){
		   		$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Error'} = "No product was found on complaint";		    
		   		$p_id = ""; $pr_id = ""; $s_id = ""; $cl_email = ""; $date = ""; $cl_msg= ""; $cl_name= ""; $cl_company = "";
		   		$cnt++;
		   		next;
				}
				if($resp->[0][0]){
		  	 $p_id = $resp->[0][0];
				}
	  	}
	  	if($pr_id && $s_id){
			 my $resp = do_query("select product_id from product where prod_id=".str_sqlize($pr_id)." and supplier_id=".str_sqlize($s_id));
			 if($resp->[0][0]){
		  	 $p_id = $resp->[0][0];
			 }
			 else{
		    $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Error'} = "No product was found on complaint";
		    $p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $date = ""; $cl_msg= ""; $cl_name= ""; $cl_company = "";
		    $cnt++;		    
#		    return ({'Response' => [$rh]}, $gzipped);
	    next;
			}
	 	 }
	 	 if(!$p_id){
			$rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Error'} = "No product was found on complaint";
			$p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $date = ""; $cl_msg= "";	$cl_name= "";	$cl_company = "";
			$cnt++;		    
#		return ({'Response' => [$rh]}, $gzipped);
		 next;
	  }
	}
	if(!$pr_id or !$s_id){
	    my $resp = do_query("select prod_id, supplier_id from product where product_id=".str_sqlize($p_id));
	    $pr_id = $resp->[0][0];
	    $s_id = $resp->[0][1];
	}
#check editor
  my $get_editor = do_query("select product.user_id, user_group from product,users where product_id=".str_sqlize($p_id)."and product.user_id = users.user_id");
	if(!$get_editor || ($get_editor->[0][0] == 1) || ($get_editor->[0][0] == 15) || ($get_editor->[0][1] eq 'exeditor') || ($get_editor->[0][1] eq 'supplier') || ($get_editor->[0][0] == 19)){
	   my $get_def_sed = do_query("select value from sys_preference where name='default_superuser_id'");
	   $editor = $get_def_sed->[0][0];
	}
	else{
		 $editor = $get_editor->[0][0];
	}
#mapped prod_id
  my $p = {"supplier_id" => $s_id, "prod_id" => $pr_id};
#    $pr_id = get_mapped_prod_id($p);
#check status    
   my $stat = 1;
#check name
  if($cl_name eq ''){
		my $get_name = do_query("select login from users where user_id=".str_sqlize($user_id));
		$cl_name = $get_name->[0][0];
	}
#check email
	if($cl_email eq ""){
		my $req1 = do_query("select pers_cid from users where user_id=".str_sqlize($user_id));
		my $req2 = do_query("select email from contact where contact_id=".str_sqlize($req1->[0][0]));
		$cl_email = $req2->[0][0];
	}
# register complaint in complaints journal
insert_rows('product_complaint', {  
				    'product_id' => str_sqlize($p_id),
            'prod_id' => str_sqlize($pr_id),
            'supplier_id' => str_sqlize($s_id),
		        'email' => str_sqlize($cl_email),
			      'fuser_id' => str_sqlize($user_id),
			      'message' => str_sqlize($cl_msg),
			      'subject' => str_sqlize($cl_subj),
			      'date' => str_sqlize(`date "+%Y-%m-%d %H:%M:%S"`),
			      'complaint_status_id' => str_sqlize($stat),
					  'name' => str_sqlize($cl_name),
					  'user_id' => str_sqlize($editor),
						'company' => str_sqlize($cl_company),
						'internal' => '2'
                             }
          );
 my $c_id = sql_last_insert_id();

#add history
 insert_rows("product_complaint_history",{
							"complaint_id" => $c_id,
							"complaint_status_id" => 1,
							"user_id" => $editor,
							"message" => str_sqlize("New complaint received"),
							'date' => str_sqlize(`date "+%Y-%m-%d %H:%M:%S"`)
							});

#email to responsible editor
 my $mail_to_editor;
 load_email_template("email_complaint");
 if(! defined $hin{'langid'}){ $hin{'langid'} = 1;}
 $hin{'complaint_id'} = $c_id;
 my $html_body = get_complaint_email_body($atoms, $hin{'complaint_id'}, $hin{'langid'});
		
 $mail_to_editor->{'html_body'} = $html_body;
 $mail_to_editor->{'text_body'} = repl_ph($atoms->{'default'}->{'email_complaint'}->{'post_text_body'}, {'id' => $hin{'complaint_id'}});		 
 $mail_to_editor->{'subject'} = repl_ph($atoms->{'default'}->{'email_complaint'}->{'post_subject'}, {'id' => $hin{'complaint_id'}});		 
 my $get_email_login_to = do_query("select person, email from contact, users where users.user_id = $editor and users.pers_cid = contact.contact_id");

 $mail_to_editor->{'to'} = $get_email_login_to->[0][1];
 $mail_to_editor->{'from'} = $atomcfg{'complain_from'};
 complex_sendmail($mail_to_editor);

#make up response
#   $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'ComplaintNumber'} = $cnt;		
    $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Product_id'} = $p_id;
#    $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Prod_id'} = $pr_id;
#   $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Supplier_id'} = $s_id;
    $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'ComplaintStatus_ID'} = $stat;
   $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'Confirmation'} = "The complaint is accepted";    
   $rh->{'ProductsComplaintResponse'}->{'ProductComplaintResponse'}->[$cnt]->{'ProductComplaintRequest_ID'} = $c_id;    
    $p_id = ""; $pr_id = ""; $s_id = ""; $s_code = ""; $cl_email = ""; $date = ""; $cl_msg= ""; $cl_name = "";   
    $cnt++;
  }
}


#
# products
#
if(defined $root->{'ProductsListRequest'}){

	my $resp = '';
	my @lang = split(/,/, $root->{'ProductsListRequest'}->[0]->{'langid'});
	my $f = '';
	for my $langid(@lang){
		$f .= ' vocabulary.langid = '.str_sqlize($langid).' or';
	}
	chop($f);chop($f);chop($f);


# building feature group hashes 
	my $feat_group_data = do_query("select feature_group.feature_group_id, vocabulary.value, vocabulary.langid, vocabulary.record_id from feature_group, vocabulary where vocabulary.sid = feature_group.sid and ($f)");
	my $feat_group = {};
	for my $row(@$feat_group_data){
		$feat_group->{$row->[0]}->{'ID'} = $row->[0];
		push @{$feat_group->{$row->[0]}->{'Name'}}, 
	   {
		  "ID" => $row->[3],
			"Value" => $row->[1],
			"langid" => $row->[2]
		 }
	}

	my $fns = do_query("select vocabulary.value, vocabulary.langid, record_id, feature_id from vocabulary, feature where feature.sid = vocabulary.sid and ($f)");
	my $fn_hash = {};
	
	for my $row(@$fns){
		push @{$fn_hash->{$row->[3]}}, $row;
	}

	my $extra_sql = '';
	if($freeurls) { $extra_sql = ' and product.supplier_id '.in_selected_sponsors; }
		
	for my $pr_req(@{$root->{'ProductsListRequest'}->[0]->{'Product'}}){
	
		my $data;
		my $where 		= '';
		my $req_type 	= 0;
		my $e_supp_id 		= 0;
		my $e_supp_name 	= 0;
		my $e_product_id	= 0;
		my $e_not_found		= 0;
		my $vfied_supplier_name = '';
		my $vfied_supplier_id = '';
		if($pr_req->{'ID'}){
			$where = " product.product_id = ".str_sqlize($pr_req->{'ID'});
			$req_type = 1;
		}elsif(ref($pr_req->{'Supplier'}->[0]) eq 'HASH' && $pr_req->{'Supplier'}->[0]->{'ID'} && $pr_req->{'Prod_id'}->[0] ){
			$where = " supplier.supplier_id = ".str_sqlize($pr_req->{'Supplier'}->[0]->{'ID'})." and prod_id = ".str_sqlize($pr_req->{'Prod_id'}->[0]);
			$req_type = 2;

	 # validating input
			my $supp = do_query("select supplier_id, name from supplier where supplier_id = ".str_sqlize($pr_req->{'Supplier'}->[0]->{'ID'}));
	    unless($supp && $supp->[0]){
	 
	 # supplier_id is wrong
		$e_supp_id = 1;
	    } 
	    else {
	 	 $vfied_supplier_id = $supp->[0][0];
  		 $vfied_supplier_name = $supp->[0][1];
	    }
	}
	 elsif(ref($pr_req->{'Supplier'}->[0]) ne 'HASH' && $pr_req->{'Supplier'}->[0] && $pr_req->{'Prod_id'}->[0] ) {
	    $where = " supplier.name = ".str_sqlize($pr_req->{'Supplier'}->[0])." and prod_id = ".str_sqlize($pr_req->{'Prod_id'}->[0]);

	 # validating input

	    my $supp = do_query("select supplier_id from supplier where name = ".str_sqlize($pr_req->{'Supplier'}->[0]));
	    unless($supp && $supp->[0]){
	    
	# supplier_id is wrong
	
	    $e_supp_name = 1;
	    $vfied_supplier_name = $pr_req->{'Supplier'}->[0];		
	    } 
	    else {
		$vfied_supplier_id = $supp->[0][0];
		$vfied_supplier_name = $pr_req->{'Supplier'}->[0];
	    }
	    $req_type = 3;
	}
	
	 $data = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id and ".$where.$extra_sql);
	 unless($data && $data->[0]){

		#
		# Not found. Maybe to map current prod_id? 
		#
		
		if($pr_req->{'Prod_id'}->[0] && $vfied_supplier_id){
		    #
		    # Mapping by prodid and supplier 
		    #
		    
		    my $prodid;
		       $prodid->{'prod_id'} = $pr_req->{'Prod_id'}->[0];
		       $prodid->{'supplier_id'} = $vfied_supplier_id;
		
		    $prodid = get_mapped_prod_id($prodid);
		    #log_printf($prodid.'----USING SUPPLIER----->'.$pr_req->{'Prod_id'}->[0]);			    
		    
		    $data = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id and product.prod_id=".str_sqlize($prodid)." and supplier.supplier_id=$vfied_supplier_id".$extra_sql);
		    
		    if($data->[0][0]){
			$pr_req->{'ID'} = $data->[0][0];
			$pr_req->{'Prod_id'}->[0] = $data->[0][1];
			$e_not_found = undef; 
		    }else{ 
			$e_not_found = 1;
		    }
		    
		    
		}elsif($pr_req->{'Prod_id'}->[0]){
		    #
		    # Mapping only by prodid
		    #
		       
		    #
		    # Try to guess supplier :)
		    #
		    
		    my $mapped_supp_id;
		    
		    if($vfied_supplier_name){
		       $mapped_supp_id = do_query('select supplier_id from data_source_supplier_map where symbol='.str_sqlize($vfied_supplier_name))->[0][0];
		    }
		    
		    if($mapped_supp_id){

			#
			# Yeah, we've got it!
			#
			
			$vfied_supplier_id = $mapped_supp_id;
			my $prodid;
		    	    $prodid->{'prod_id'} = $pr_req->{'Prod_id'}->[0];
			    $prodid->{'supplier_id'} = $mapped_supp_id;
		    
		        $prodid = get_mapped_prod_id($prodid);
		        $data = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id and product.prod_id=".str_sqlize($prodid)." and supplier.supplier_id=$mapped_supp_id".$extra_sql);

			if(!$data->[0][0]){
			    $data = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id and product.prod_id=".str_sqlize($pr_req->{'Prod_id'}->[0])." and supplier.supplier_id=$mapped_supp_id".$extra_sql);
			}

			if($data->[0][0]){
			    $pr_req->{'ID'} = $data->[0][0];
			    $pr_req->{'Prod_id'}->[0] = $data->[0][1];
			    $vfied_supplier_name = $data->[0][3];
			    $e_not_found = undef; 
			    $req_type = 1;
			}else{ 
			    $e_not_found = 1;
			}
		    }else{
			$e_not_found = 1;
		    }	
		}else{ 
		    if($req_type == 1){
			$e_product_id = 1;
		    }
		    $e_not_found = 1;
		}

				
	 } else {
	  $pr_req->{'ID'} = $data->[0][0];
	 }
	 
	 my $code = 0;
	 if(!$e_not_found){
	 		$code = 1; # product found, input correct
	 } 
	 else {
	    if($req_type == 1){
		$code = 3; # product not found, supplied wrong product_id
	    } 
	    elsif($req_type == 2){
		if($e_supp_id){
		    $code = 4; # product not found, supplied wrong supplier_id
		} else {
		$code = 2; # product not found, all input is correct
		}
	    } 
	    elsif($req_type == 3){
		if($e_supp_name){
		    $code = 5; # product not found, supplied wrong supplier name
		} else {
		    $code = 2; # product not found, all input is correct
		}
	    }
	 
	}
	 
# stating request
    state_product_request($rh->{'ID'}, $pr_req->{'ID'}, $pr_req->{'Prod_id'}->[0], $vfied_supplier_id, $vfied_supplier_name, $code, $e_not_found^1);	 
	 
#    print "code=$code\n";
    if($code != 1){
	if($req_type == 1){
	    $rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'ID'}).'?'}->{'Code'} = $code;
	    $resp .= "\t\t<Product Code=\"$code\" ID=\"?$pr_req->{'ID'}?\"/>\n"; 
	} 
	else {
	    $rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'Prod_id'}->[0] ).'?'}->{'Code'} = $code;
	    $resp .= "\t\t<Product Code=\"$code\" ID=\"?".str_xmlize($pr_req->{'Prod_id'}->[0])."?\"/>\n";
	}
        next;
    }
	 
    my $row = $data->[0];
    $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Code'} = $code;
    my $p_id;
    if($req_type == 1){ 
	$p_id = $pr_req->{'ID'};
#	print "1.".$p_id."\n";    
    }
    if($req_type == 2){ 
	my $q = "select product_id from product where supplier_id=".str_sqlize($pr_req->{'Supplier'}->[0]->{'ID'})." and prod_id=".str_sqlize($pr_req->{'Prod_id'}->[0]);
	my $r = do_query($q);	
	$p_id = $r->[0][0];
#	print "2.".$p_id."\n";
    }
    if($req_type == 3){ 
	my $q = "select p.product_id from product as p, supplier as s where p.prod_id = ".str_sqlize($pr_req->{'Prod_id'}->[0])." and p.supplier_id=s.supplier_id and s.name=".str_sqlize($pr_req->{'Supplier'}->[0]);
	my $r = do_query($q);	
	$p_id = $r->[0][0];
#	print "3.".$p_id."\n";    
    }
		log_printf("getting response for product_id = $p_id");
    my $ans;

		$ans = get_product_xml_fromrepo($p_id);
		if (!$$ans) {
			$code = 2; # product not found, all input is correct
			$$ans = "\t\t<Product Code=\"$code\" ID=\"?$p_id?\"/>\n"; 
		}
		$resp .= $$ans."\n";
}

$rh->{'ProductsList'}->{'__plain_xml'} = \$resp;
delete($rh->{'ProductsList'}->{'Product'});
}

#
# products dump
#

if(defined $root->{'ProductsDumpRequest'}){

 my @lang = split(/,/, $root->{'ProductsDumpRequest'}->[0]->{'langid'});
 my $f = '0 ';
 for my $langid(@lang){
  $f .= ' or vocabulary.langid = '.str_sqlize($langid);
 }
 
 my $products = '';
 
 my $quality = get_quality_index($root->{'ProductsDumpRequest'}->[0]->{'MinQuality'});
 
 
 my $updated_from = $root->{'ProductsDumpRequest'}->[0]->{'UpdatedFrom'};
    if($updated_from){
   		 $updated_from = do_query("select unix_timestamp(".str_sqlize($updated_from).")")->[0][0]; 
		} else {
		   $updated_from = '';
		}
 
 if($quality < get_quality_index('ICECAT')){
  $quality = get_quality_index('NOEDITOR')
 } 

 my $supplier = $root->{'ProductsDumpRequest'}->[0]->{'Supplier_ID'};
 my @suppliers = split(',', $supplier);
 my %allowed = map { $_ => 1 } @suppliers;

# cat_mem_stat(__LINE__.'-'.__FILE__); 
 log_printf('loading raw products');
 my $request = [];
 { 
	 my $raw_products = do_query("select product_id, user_id, supplier_id from product");
	 log_printf('loaded raw products');
#	 cat_mem_stat(__LINE__.'-'.__FILE__);
	 my $users = do_query("select user_id, user_group from users");
	 my %users = map { $_->[0] => $_->[1] } @$users;

	 my $i = 0;
 
	 for my $row(@$raw_products){
 		my $ug = $users{$row->[1]};
		my $q_rate = get_quality_measure($ug);
#		if($i > 50){ next }
	  my $row_quality = get_quality_index($q_rate);
#		log_printf("product $row->[0] is $ug($row->[1] comparing to  $quality ");		
		if($row_quality >= $quality &&
		 ( ( $allowed{$row->[2]} && $supplier ) || !$supplier) ){
				 if( $updated_from ){
				 		 my $updated = get_product_date_cached($row->[0]);
						 if( $updated_from <= $updated) {
								$i++;
								push @$request, $row->[0];
						 }
				 } else {
								$i++;
								push @$request, $row->[0];				 
				 }
		}
	
	}

	 log_printf("Request matched $i products");	
	 undef $raw_products;
	 clear_product_date_cache();
	}
 

 
	 my $prod_xml = load_complex_template('xml/products_dump.xml');

#	 cat_mem_stat(__LINE__.'-'.__FILE__); 

 my $i = 0;
  
 for my $product_id(@$request){
  $i++;


	my $hash = {};
	my $data;
	my $where 		= '';

#	cat_mem_stat(__LINE__.'-'.__FILE__);  
  
	$where 		= '';

	my $req_type 	= 0;
	
	my $e_supp_id 		= 0;
	my $e_supp_name 	= 0;
	my $e_product_id	= 0;
	my $e_not_found		= 0;
	
	my $vfied_supplier_name = '';
	my $vfied_supplier_id = '';

  $where = " product.product_id = ".$product_id;
  $req_type = 1;
	
	 $data = do_query("select product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group, product.family_id from product, category, supplier, users where product.user_id = users.user_id	  and category.catid = product.catid and product.supplier_id = supplier.supplier_id  and ".$where);
	 unless($data && $data->[0]){
		if($req_type == 1){
		 $e_product_id = 1;
		}
		 $e_not_found = 1;
	 } else {
	  $product_id = $data->[0][0];
	 }
	 
	 my $code = 0;
	 if(!$e_not_found){
	 		$code = 1; # product found, input correct
	 } else {
	  if($req_type == 1){
			$code = 3; # product not found, supplied wrong product_id
		} 
	 }
	 
	 my $row = $data->[0];
	 
	 $hash->{'Code'} = $code;

# building product_description entries
   my $des_data = do_query("select short_desc, long_desc, warranty_info, official_url, product_description_id, langid, pdf_url from product_description as vocabulary where product_id = $row->[0] and ($f)");	 

   $hash->{'ProductDescriptions'} = '';
	 for my $des_row(@$des_data){
		$hash->{'ProductDescriptions'} .= repl_ph($prod_xml->{'product_description_row'}, 
												{  "ShortDesc" 		=> str_xmlize($des_row->[0]),
													 "LongDesc"			=> str_xmlize($des_row->[1]),
													 "WarrantyInfo"	=> str_xmlize($des_row->[2]),
													 "URL"					=> str_xmlize($des_row->[3]),
													 "ID"						=> $des_row->[4],
													  "PDFURL"                               => $des_row->[6],
													 "langid"				=> $des_row->[5]
												});		
	}
	
	undef $des_data;
	 
# building features list
   my $feat_data_query = "select pf.product_feature_id, cf.feature_id, pf.value, f.measure_id, 1, (cf.searchable * 10000000 + (1 - f.class) * 100000 + cf.no), cf.category_feature_group_id

from measure m
inner join feature f on m.measure_id = f.measure_id
inner join category_feature cf on f.feature_id = cf.feature_id
inner join product_feature pf on cf.category_feature_id = pf.category_feature_id

where cf.catid = $row->[4] and pf.product_id = ".str_sqlize($row->[0]);

  my $feat_data = do_query($feat_data_query);

	 $hash->{'ProductFeature'} = '';
	 for my $feat_row(@$feat_data){
	  $hash->{'ProductFeature'} .= repl_ph($prod_xml->{'product_feature_row'},
											  { "ID" 						=> $feat_row->[0],
													"No"						=> $feat_row->[5],
													"Feature_ID"		=> $feat_row->[1],
													"CategoryFeatureGroup_ID" => int($feat_row->[6]),
													"Value"					=> str_xmlize($feat_row->[2]),
													"Measure_ID"		=> $feat_row->[3]
												 });
	 }
	undef $feat_data;
	
# building related
	my $rel_data = do_query("select product_related_id, rel_product_id, product.prod_id, product.supplier_id, supplier.name from product_related, product, supplier where product_related.product_id = $row->[0] and product_related.rel_product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 

	$hash->{'ProductsRelated'} = '';
	for my $rel_row(@$rel_data){
	 $hash->{'ProductsRelated'} .= repl_ph($prod_xml->{'product_related_row'},
	 										 { 'ID' 				=> $rel_row->[0], 
												 'Product_ID' => $rel_row->[1],
												 'prod_id'		=> str_xmlize($rel_row->[2]),
												 'supplier_id'=> $rel_row->[3]
											 });
	}
	
	undef $rel_data;
	

# building bundled 
    my $bndl_data = do_query("select product_bundled.id, bndl_product_id from product_bundled where  product_bundled.product_id = $row->[0]  ");
	
    $hash->{'ProductBundled'} = '';
    for my $rel_row(@$bndl_data){
        $hash->{'ProductBundled'} .= repl_ph($prod_xml->{'product_bundled_row'},
                                                                 { 'ID' => $rel_row->[0],
	                                                           'Product_ID' => $rel_row->[1]
                                                            });
			           }
    undef $bndl_data;

   $hash->{'Prod_id'} = str_xmlize($row->[1]);
   $hash->{'Supplier_ID'} = $row->[2];
   $hash->{'Category_ID'} = $row->[4];
   $hash->{'ProductFamily_ID'} = $row->[10];
   $hash->{'Quality'} = get_quality_measure($row->[9]);
   $hash->{'Name'} =  str_xmlize($row->[5]);
   $hash->{'LowPic'} =  str_xmlize($row->[6]);
   $hash->{'HighPic'} = str_xmlize($row->[7]);
   $hash->{'ThumbPic'} = $row->[8];	 
	 $hash->{'ID'}			 = $row->[0];
	 my $tmp;
   $products .= $tmp = repl_ph($prod_xml->{'product_body'}, $hash);

	 undef $hash;
	 undef $data;
	 undef $row;
#	 log_printf("the xml chunk is ".length($tmp)." bytes on $i product");
#	 cat_mem_stat(__LINE__.'-'.__FILE__); 	 
 }
 log_printf("len of xml = ".length($products));
 
 $prod_xml->{'body'} =~s/%%products%%/$products/g;
 
 $products = $prod_xml->{'body'};
 delete $prod_xml->{'body'};
 

 $rh->{'__plain_xml'} = \$products;
}


#
# supplier families
#

if (defined $root->{'SupplierProductFamiliesListRequest'}) {
	# building supplier families list
	my $req = $root->{'SupplierProductFamiliesListRequest'}->[0];
	my @lang = split(/,/, $req->{'langid'});
	my $f = '0 ';
	for my $langid (@lang) {
		$f .= ' or langid = '.str_sqlize($langid);
	}
	my $supplier_id = $req->{'Supplier_ID'};
	my $supplier_parent_family_id = $req->{'SupplierParentProductFamily_ID'};
	my $catid = $req->{'Category_ID'};
	
	if (0) {
		$rh->{'SupplierProductFamiliesList'}->{'Error'} = "Not enough data to get suppliers families list";
	}
	else {
		my $query = "select family_id, parent_family_id, low_pic, thumb_pic, supplier_id, catid from product_family where family_id>1 !where!"; # family_id = 1 is the virtual family root
		my $where = '';
		if ($supplier_id) {
			$where = "and product_family.supplier_id = $supplier_id";
		}
		if ($catid) {
			$where .= " and product_family.catid = $catid";
		}
		if ($supplier_parent_family_id) {
			if (!$supplier_id && !$catid) {
				$where = "and product_family.parent_family_id = $supplier_parent_family_id";
			}
			else {
				$where .= " and product_family.parent_family_id = $supplier_parent_family_id";
			}
		}
		if (!$supplier_id && !$supplier_parent_family_id && !$catid) {
			$where .= "";
		}
		$query =~ s/!where!/$where/;
		my $data = do_query($query);

		if (!$data->[0][0]) {
			$rh->{'SupplierProductFamiliesList'}->{'Error'} = "No matching families found";
		}
		else {
			my $fam_name = {};
			my $fam_name_descr = {};
			my $pfam_name = {};
			my $series_name = {};

			# building families	names
			for my $row (@$data) {
				my $fam_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, family_id, parent_family_id from product_family, vocabulary where vocabulary.sid = product_family.sid and ($f) and product_family.family_id = $row->[0]");
				for my $fam_row (@$fam_data) {
					push @{$fam_name->{$fam_row->[3]}}, {
						'langid' 	=> $fam_row->[2],
						'Value'	  => $fam_row->[0],
						'ID'			=> $fam_row->[1]
					};
#		  push @{$pfam_name->{$fam_row->[3]}}, { 
#																						'langid' 	=> 	$fam_row->[2],
#																						'content'	=> 	$fam_row->[0],
#																						'ID'			=>	$fam_row->[4]
#																					};
				}																					
				my $series_data = do_query(
					"select v.value, v.record_id, v.langid, ps.series_id from product_series ps join product_family pf using (family_id, supplier_id, catid) join vocabulary v on v.sid=ps.sid where ($f) and ps.family_id = $row->[0]"
				);
				for my $series_row (@$series_data) {
					$rh->{'SupplierProductFamiliesList'}
						->{'ProductFamily'}->[ $row->[0] ]->{'Series'}
						->[ $series_row->[3] ]->{'ID'} = $series_row->[3];
					push @{ $rh->{'SupplierProductFamiliesList'}
							->{'ProductFamily'}->[ $row->[0] ]
							->{'Series'}->[ $series_row->[3] ]
							->{'Name'} },
						{ 'langid' => $series_row->[2],
						  'Value'  => $series_row->[0],
						  'ID'     => $series_row->[1]
						};
				}
				my $fam_data_descr = do_query("select tex.value, tex.tex_id, tex.langid, family_id  from product_family,tex where tex.tid = product_family.tid and ($f) and product_family.family_id = $row->[0]");
				for my $fam_row (@$fam_data_descr) {
					push @{$fam_name_descr->{$fam_row->[3]}}, {
						'langid' 	=> $fam_row->[2],
						'Value'	  => $fam_row->[0],
						'ID'			=> $fam_row->[1]
					};
				}

#		 for my $pcat_row(@{$pcat_name->{$row->[4]}}){
#			my $hash = {};
#			%$hash = %{$pfam_row};
#			push @{$rh->{'SupplierFamiliesList'}->{'ProductFamily'}->{$row->[0]}->{'ParentProductFamily'}->{'Names'}->{'Name'}},
#						 $hash;	
#			}

				# select supplier data
				my $supp_data = do_query("select supplier_id, name from supplier where supplier_id = $row->[4]");

				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'ID'}	= $row->[0];
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'Name'} = $fam_name->{$row->[0]}; 
				if ((ref($fam_name_descr->{$row->[0]}) eq 'ARRAY')||
						(ref($fam_name_descr->{$row->[0]}) eq 'HASH')) {
					$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'Description'} = $fam_name_descr->{$row->[0]};
				}
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'LowPic'} = $row->[2] if ($row->[2]);
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'ThumbPic'} = $row->[3] if ($row->[3]);
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'Category_ID'} = $row->[5] if ($row->[5]);
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'ParentProductFamily'} = {'ID' => $row->[1]};	
				$rh->{'SupplierProductFamiliesList'}->{'ProductFamily'}->[$row->[0]]->{'Supplier'} = {'ID' => $supp_data->[0][0], 'Name' => $supp_data->[0][1]};	
			}
		}
	}
}

log_printf('done processing content');

}

return ({'Response' => [$rh],
#	'__plain_xml' => $plain_xml, 
    }, $gzipped);

}

sub icecat_server_main
{

push_dmesg(4, 'starting up ReadParse');

atom_html::ReadParse;

push_dmesg(4, 'done');

my $message = $hin{'REQUEST_BODY'};
my ($response, $gzipped) = respond_message($message);
#log_printf ("response = ".Dumper($response));

    $response = build_message($response, "response");

if($gzipped){
 print "Content-type: application/x-gzip\n\n";
 $response = gzip_data_by_ref($response);
} else {
 print "Content-type: text/xml; charset=utf-8\n\n";
# Encode::_utf8_on($response);
 binmode(STDOUT,":utf8");
# log_printf($response);
}

print STDOUT $$response;

}

sub icecat_server_main_local {
	my ($in) = @_;
	
	my ($response, $gzipped) = respond_message($$in,'skip_validation'); # skipped - cause called locally

	$response = build_message($response, "response");

	if ($gzipped) {
		$response = gzip_data_by_ref($response);
	}
	else {
		Encode::_utf8_on($response);
	}
	
	return $response;
} # sub icecat_server_main_local

sub icecat_server_main_cgi {

atom_html::ReadParse;

print "Content-type: text/plain\n\n";

my $hash = {};
if($hin{'MeasuresList'}){
 $hash->{'MeasuresList'} = $hin{'MeasuresList'};
}

if($hin{'FeaturesList'}){
 $hash->{'FeaturesList'} = $hin{'FeaturesList'};
}

if($hin{'CategoriesList'}){
 $hash->{'CategoriesList'} = $hin{'CategoriesList'};
}

if($hin{'ID'}&&$hin{'langid'}){
 $hash->{'ProductsList'}->{'langid'} = $hin{'langid'};
 push @{$hash->{'ProductsList'}->{'Products'}}, {'ID' => $hin{'ID'}};
}

if($hin{'Prod_id'} && $hin{'Supplier_ID'} && $hin{'langid'}){
 $hash->{'ProductsList'}->{'langid'} = $hin{'langid'};
 push @{$hash->{'ProductsList'}->{'Products'}}, 
				 {	'Supplier_ID' => $hin{'Supplier_ID'},
						'Prod_id'			=> $hin{'Prod_id'}
				 };
}

if($hin{'Prod_id'} && $hin{'Supplier'} && $hin{'langid'}){
 $hash->{'ProductsList'}->{'langid'} = $hin{'langid'};
 push @{$hash->{'ProductsList'}->{'Products'}}, 
				 {	'Supplier' => $hin{'Supplier'},
						'Prod_id'			=> $hin{'Prod_id'}
				 };
}


my $message = build_message(build_request($hash,$hin{'shop'},$hin{'pass'},$hin{'Request_ID'}||''));

my $response = build_message(respond_message($$message));

print $$response;

}

sub icecat_server_main_cgi2html
{

 html_start();
 
 $hin{'tmpl'} = 'product_details_pub.html';

 my $login = $hin{'shop'};
 my $pass	= $hin{'pass'};
 
 if($hin{'langid'}){
  $hl{'langid'} = $hin{'langid'};	
 }
 
 my $status = 1;
 my $user_id = '';

 my $usr_data = do_query("select user_id, user_group, access_restriction, access_restriction_ip  from users where login =".atomsql::str_sqlize($login)." and password = ".atomsql::str_sqlize($pass));
 
	atom_engine::init_atom_engine();


 $status = -1;
 my $vfied_supplier_id 		= '';
 my $vfied_supplier_name 	= '';
 my $e_not_found = 0;
 my $e_supp_id = 0;
 my $e_supp_name = 0;
 
 my $code = 0;
 my $req_type;
 
 
	
 if($usr_data && $usr_data->[0] && $usr_data->[0][1] eq 'shop'&&
   verify_address($usr_data->[0][2], $usr_data->[0][3], $ENV{'REMOTE_ADDR'} )){
  $status = 1;
	$hl{'user_id'} = $user_id = $usr_data->[0][0];
	
	# the user is verified

	if($hin{'ID'}){
	 
	 $hin{'product_id'} = $hin{'ID'};

	 my $r = do_query("select product_id from product where product_id = ".str_sqlize($hin{'ID'}));
	 if($r && $r->[0]){
	  $hin{'product_id'} = $r->[0][0];
	 } else {
	  $e_not_found = 1;
	 }

	 $req_type = 1;

	} elsif($hin{'Supplier_ID'} && $hin{'Prod_id'} ) {
	 
	 my $r = do_query("select product_id from product where supplier_id = ".str_sqlize(int($hin{'Supplier_ID'}))." and prod_id = ".str_sqlize($hin{'Prod_id'}));

	 if($r && $r->[0]){
	  $hin{'product_id'} = $r->[0][0];
	 } else {
	  $e_not_found = 1;
	 }
	 
	 $req_type = 2;

	 # validating input

	 my $supp = do_query("select supplier_id, name from supplier where supplier_id = ".str_sqlize(int($hin{'Supplier_ID'})));
	 unless($supp && $supp->[0]){
	  # supplier_id is wrong
		$e_supp_id = 1;
	 } else {
	 	 $vfied_supplier_id 		= $supp->[0][0];
   	 $vfied_supplier_name		= $supp->[0][1];
	 }
	 

	 

#	} elsif($hin{'Supplier'}&& $hin{'Prod_id'} ) {
	} else {
# then we have to assume the Prod_id and Supplier present
	 # validating input
	 my $supp = do_query("select supplier_id from supplier where name = ".str_sqlize($hin{'Supplier'}));
	 unless($supp && $supp->[0]){
	  # supplier_id is wrong
		$e_supp_name = 1;
    $vfied_supplier_name	= $hin{'Supplier'};		
	 } else {
	  $vfied_supplier_id 		= $supp->[0][0];
    $vfied_supplier_name	= $hin{'Supplier'};
	 }


	 my $r = do_query("select product_id from product where supplier_id = ".str_sqlize($vfied_supplier_id)." and prod_id = ".str_sqlize($hin{'Prod_id'}));

	 if($r && $r->[0]){
	  $hin{'product_id'} = $r->[0][0];
	 } else {
	  $e_not_found = 1;
	 }

	 $req_type = 3;
	}


	 if(!$e_not_found){
	 		$code = 1; # product found, input correct
	 } else {
	 
	  if($req_type == 1){
			$code = 3; # product not found, supplied wrong product_id
		} elsif($req_type == 2){
		 if($e_supp_id){
		  $code = 4; # product not found, supplied wrong supplier_id
		 } else {
			$code = 2; # product not found, all input is correct
		 }
		} elsif($req_type == 3){
		 if($e_supp_name){
		  $code = 5; # product not found, supplied wrong supplier name
		 } else {
			$code = 2; # product not found, all input is correct
		 }
		}
	 
	 }
	 
  if($code != 1){
#	 push_user_error("Please, check your request(code $code).");
	 print_html("<font size=+3>Sorry, no information available about this product.<BR>Please, check your request(code $code).</font>");
	}	else {
		atom_engine::launch_atom_engine();
	}
	atom_engine::done_atom_engine();


 } else {
	$status = -1;
 }
 
	atom_engine::html_finish(); 
	
	my $nowtime;
	

insert_rows('request', 
			 { 
				 'user_id'				=> str_sqlize($user_id),
				 'status'					=> $status,
				 'date'						=> str_sqlize($nowtime = time),
				 'login'					=> str_sqlize($login),
				 'ip'							=> str_sqlize($ENV{'REMOTE_ADDR'})
			 });


my $req_id = sql_last_insert_id();

   insert_rows('request_product', { 'request_id'			=> $req_id,
																		 'rproduct_id'		=> str_sqlize($hin{'product_id'}),
																		 'rprod_id'				=> str_sqlize($hin{'Prod_id'}),
																		 'rsupplier_id'		=> str_sqlize($vfied_supplier_id),
																		 'rsupplier_name'	=> str_sqlize($vfied_supplier_name),
																		 'code'						=> $code,
																		 'product_found'	=> str_sqlize($e_not_found^1)
																	 });	 


	
}

sub log_xml_request
{
my ($request_id, $user_id, $status, $nowtime, $login) = @_;

insert_rows('request', 
			 { 
				 'ext_request_id' => str_sqlize($request_id),
				 'user_id'				=> str_sqlize($user_id),
				 'status'					=> $status,
				 'date'						=> str_sqlize($nowtime = time),
				 'login'					=> str_sqlize($login),
				 'ip'							=> str_sqlize($ENV{'REMOTE_ADDR'})
			 });

return sql_last_insert_id;
}

sub state_product_request
{
my ($request_id, $rproduct_id, $rprod_id, $rsupplier_id, $rsupplier_name, $code, $product_found) = @_;
   insert_rows('request_product', { 'request_id'			=> $request_id,
			 'rproduct_id'		=> str_sqlize($rproduct_id),
			 'rprod_id'				=> str_sqlize($rprod_id),
					 'rsupplier_id'		=> str_sqlize($rsupplier_id),
					 'rsupplier_name'	=> str_sqlize($rsupplier_name),
				 'code'						=> $code,
		 'product_found'	=> str_sqlize($product_found),
		 'date' => 'unix_timestamp()'
			 });	 
return sql_last_insert_id;
}

sub describe_products_xml
{

my ($tmp_intersection_table, $destination, $catid, $f) = @_;

 # now describing each of result arr element 
	my $where 		= ' 0 ';
	my $datas;	
	
	my $use_tree = 1;
	
 $datas = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic from product, supplier,".$tmp_intersection_table." where product.supplier_id = supplier.supplier_id and product.catid = ".str_sqlize($catid)." and product.product_id =".$tmp_intersection_table.".product_id");

	my $des_data = do_query("select short_desc, product_description_id, langid, vocabulary.product_id from product_description as vocabulary,".$tmp_intersection_table." where ($f) and vocabulary.product_id = ".$tmp_intersection_table.".product_id");	 
  my $des_data_hash = {};
  for my $row(@$des_data){
		 push @{$des_data_hash->{$row->[3]} }, $row; 
	}

	my $cat_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = ".str_sqlize($catid));

	for my $data(@$datas){
	  my $product_id = $data->[0];
	  next if(!defined $data || !defined $data->[0]);
		my $pcode = 1;

# stating request
#	  state_product_request($rh->{'ID'}, $product_id, $data->[1], $data->[2], $data->[3], $pcode, 1);
	 
		my $row = $data;
	 
		$destination->{$row->[0]}->{'Code'} = $pcode;

# building cats	for product

		my $cat_content = [];
		for my $cat_row(@$cat_data){
	 		push @$cat_content, { 					'ID'				=> $cat_row->[1],
																		  'Value'			=> $cat_row->[0],
																			'langid'		=> $cat_row->[2] } ;
		}

# building product_description entries
		my $des_content = [];
		for my $des_row(@{$des_data_hash->{'product_id'}}){
			push @$des_content, {  "ShortDesc" 		=> $des_row->[0],
													 "ID"						=> $des_row->[1],
													 "langid"				=> $des_row->[2]};		
		}
	 
		$destination->{$row->[0]}->{'Prod_id'} = $row->[1];
		$destination->{$row->[0]}->{'Supplier'} = {'ID' => $row->[2], 'Name' => $row->[3] };
		$destination->{$row->[0]}->{'Category'} = { 'ID' => $row->[4], 'Name' => $cat_content };
		$destination->{$row->[0]}->{'Name'} = $row->[5];
		$destination->{$row->[0]}->{'LowPic'} 	= $row->[6];
		$destination->{$row->[0]}->{'HighPic'} 	= $row->[7];
		$destination->{$row->[0]}->{'ThumbPic'} = $row->[8];
		$destination->{$row->[0]}->{'ProductDescription'} = $des_content;
	}
#delete	temporary table
	do_statement("drop temporary table if exists ".$tmp_intersection_table);
}

sub get_product_xml_data_OLD {
    my $rh = {};
    my $p_id = shift;
    my $nowtime = time();
    my $pr_req = {};
    $rh->{'Date'} = localtime($nowtime);
#    my $prod_xml = load_complex_template('xml/product_file.xml');


# building feature group hashes 
    my $feat_group_data = do_query("select feature_group.feature_group_id, vocabulary.value, vocabulary.langid, vocabulary.record_id from feature_group, vocabulary where vocabulary.sid = feature_group.sid");
    my $feat_group = {};
    for my $row(@$feat_group_data){
        $feat_group->{$row->[0]}->{'ID'} = $row->[0];
        push @{$feat_group->{$row->[0]}->{'Name'}}, 
        {
	    "ID" => $row->[3],
	    "Value" => $row->[1],
	    "langid" => $row->[2]
	}
    }

    my $fns = do_query("select vocabulary.value, vocabulary.langid, record_id, feature_id from vocabulary, feature where feature.sid = vocabulary.sid");
    my $fn_hash = {};
 
    for my $row(@$fns){
			push @{$fn_hash->{$row->[3]}}, $row;
    }

    my $mss = do_query("select measure_sign.value, measure_sign.langid, measure_sign_id, measure_id from measure_sign");
    my $ms_hash = {};
 
    for my $row(@$mss){
			push @{$ms_hash->{$row->[3]}}, $row;
    }

    $pr_req->{'ID'} = $p_id;

    my  $data = do_query("select product.product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group, product.family_id, low_pic_size, high_pic_size, thumb_pic_size from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id and product.product_id = $p_id");
    				   
    my $code = 1;	 
    my $row = $data->[0];
												       	 
# stating request
#    $rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'ID'}).'?'}->{'Code'} = $code;

# building cats	for product
    my $cat_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid from category, vocabulary where vocabulary.sid = category.sid and category.catid = ".str_sqlize($row->[4]));
    my $cat_content = [];
    for my $cat_row(@$cat_data){
	push @$cat_content, { 'ID'      => $cat_row->[1],
			      'Value'	=> $cat_row->[0],
			      'langid'	=> $cat_row->[2] } ;
    }
		
# building families	for product
    my $fam_data = do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid from product_family, vocabulary where vocabulary.sid = product_family.sid and product_family.family_id = ".str_sqlize($row->[10]));
    my $fam_content = [];
    for my $fam_row(@$fam_data){
	push @$fam_content, { 'ID'      => $fam_row->[1],
			      'Value'	=> $fam_row->[0],
			      'langid'	=> $fam_row->[2] } ;
    }
		
# building product_description entries
    my $des_data = do_query("select short_desc, long_desc, warranty_info, official_url, product_description_id, langid, pdf_url, pdf_size from product_description as vocabulary where product_id = $row->[0]");	 
    my $des_content = [];
#    $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductsDescription'} = '';
    for my $des_row(@$des_data){
        push @$des_content, {  	"ShortDesc"              	=> $des_row->[0],
	                     					"LongDesc"               	=> $des_row->[1],
	                      				"WarrantyInfo"     				=> $des_row->[2],
	                       				"URL"                     => $des_row->[3],
	                    					"PDFURL"                  => $des_row->[6],
	                    					"PDFSize"                  => $des_row->[7],
	                     					"ID"                      => $des_row->[4],
	             									"langid"                  => $des_row->[5]};
	}
	
# processing category features group
    my $cat_feat_group_data = do_query("select category_feature_group_id, feature_group_id, no from category_feature_group where catid=".$row->[4]);
    my $group_content = [];
    for my $row(@$cat_feat_group_data){
	push @$group_content, 
			{
			 "ID" => $row->[0],
			 "No"	=> $row->[2],
			 "FeatureGroup" => $feat_group->{$row->[1]}
			}
    }

# building features list

    my $feat_data_query = "select pf.product_feature_id, cf.feature_id, pf.value, f.measure_id, 1, (cf.searchable * 10000000 + (1 - f.class) * 100000 + cf.no), cf.category_feature_group_id, cf.category_feature_id

from measure m
inner join feature f on ms.measure_id = f.measure_id
inner join category_feature cf on f.feature_id = cf.feature_id
inner join product_feature pf on cf.category_feature_id = pf.category_feature_id

where cf.catid = $row->[4] and pf.product_id = ".str_sqlize($row->[0]);

    my $feat_data = do_query($feat_data_query);
 
    my $feat_content = [];
    for my $feat_row(@$feat_data){
				if($feat_row->[2] eq ''){
		 			next;
				}
				my $feat_names = [];
        my $fn = $fn_hash->{$feat_row->[1]};
				for my $fn_row(@$fn){
	    		push @$feat_names, { 	'ID'=> $fn_row->[2], 
			     											'langid'		=> $fn_row->[1],
	    		     									'Value'	=> $fn_row->[0] 
			   										 };
				}
				my $meas_names = [];
        my $ms = $ms_hash->{$feat_row->[3]};
				for my $ms_row(@$ms){
	    		push @$meas_names, { 	'ID'=> $ms_row->[2], 
			     											'langid'		=> $ms_row->[1],
	    		     									'Value'	=> $ms_row->[0] 
			   										 };
				}
			push @$feat_content, 
			{ 	"ID"	=> $feat_row->[0],
			   	"No"	=> $feat_row->[5],
					"CategoryFeature_ID"			=> int($feat_row->[7]),
			   	"CategoryFeatureGroup_ID" => int($feat_row->[6]),
			   	"Feature" => {
					    						"ID" => $feat_row->[1],
					    						"Name"=> $feat_names,
				    	    				"Measure"	=> {
					    		    										'ID' => $feat_row->[3],
							    												'Sign' => $meas_names
							  						},																						
											},
			   	"Value" =>  $feat_row->[2],
		   };
    }

# building bundled products
    my $bndl_data = do_query("select product_bundled.id, bndl_product_id, product.prod_id, product.supplier_id, supplier.name, product.name, product.thumb_pic from product_bundled, product, supplier where  product_bundled.product_id = $row->[0] and product_bundled.bndl_product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 
    my $bndl_content = [];
	
    for my $rel_row(@$bndl_data){
					push @$bndl_content, 
					{ 
						'ID' 				=> $rel_row->[0], 
						'Product' 	=> { 	'ID'				=> $rel_row->[1],
				    									'Supplier'	=> { 	'ID'				=> $rel_row->[3],
															     							'Name'			=> $rel_row->[4]
													 									 },
												     	'Prod_id'		=> $rel_row->[2],
												     	'Name'			=> $rel_row->[5],
				    								 	'ThumbPic' 	=> $rel_row->[6]
													 }
			    }	
    }

	 
# building related
	my $rel_data1 = do_query("select product_related_id, rel_product_id, product.prod_id,
		product.supplier_id, supplier.name, product.name, product.thumb_pic,
		product.catid from product, supplier,product_related  where
		product_related.product_id = $row->[0] and 
		product_related.rel_product_id = product.product_id and 
		product.supplier_id = supplier.supplier_id");	 
	my $rel_data2 = do_query("select product_related_id, product.product_id, product.prod_id, product.supplier_id,
	        supplier.name, product.name, product.thumb_pic, product.catid
		from product_related, product, supplier where  product_related.rel_product_id = $row->[0] and
		product_related.product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 
	my $rel_data 	= [];
	
	push @$rel_data, @$rel_data1;
	push @$rel_data, @$rel_data2;
	my ($i, $reversed) = (0,0);
	
	my $rel_content = [];
	
	for my $rel_row(@$rel_data){
	 if($i >= $#$rel_data1){
	 		$reversed = 1;
	 }
	 $i++;
	 
	 push @$rel_content, 
	 					{ 
							'ID' 				=> $rel_row->[0], 
							'Category_ID'   =>$rel_row->[7],
							'Reversed'	=> $reversed,
							'Product' 	=> 
									{ 
											'ID'				=> $rel_row->[1],
				    					'Supplier'	=> 
																			{ 
																				'ID' 	=> $rel_row->[3],
																		    'Name'	=> $rel_row->[4]
						    											},
									    'Prod_id'		=> $rel_row->[2],
				  					  'Name'			=> $rel_row->[5],
				    					'ThumbPic' 	=> $rel_row->[6]
						}
			    };	
	}
    
	#build gallery
	my $gallery_data = do_query("select id, link, thumb_link, height, width, size from product_gallery where product_id = ".$row->[0]);
	my $gallery_content = []; my $gallery_local_content = [];
	for my $gallery_row(@$gallery_data){
		push @$gallery_local_content,{'ProductPicture_ID' => $gallery_row->[0],
														'Pic' => $gallery_row->[1],
														'ThumbPic' => $gallery_row->[2],
														'PicHeight' => $gallery_row->[3],
														'PicWidth' => $gallery_row->[4],
														'Size' => $gallery_row->[5]
													}
	}
	if($gallery_data->[0][0]){
	 push @$gallery_content, {'ProductPicture' => $gallery_local_content};
	}

        # building EAN codes list
	my $eans = do_query("select ean_code from product_ean_codes where product_id = ".$row->[0]);
	my $ean_content = [];

	for my $r (@$eans) {
		push @$ean_content, { 'EAN' => $r->[0] };
	}
	
	#build multimedia objects
	my $obj_data = do_query("select id, link, short_descr, size, updated, langid, content_type, keep_as_url, type, width, height from product_multimedia_object where product_id = ".$row->[0]);
	my $obj_content = []; my $obj_local_content = [];
	for my $obj_row(@$obj_data){
		if(!$obj_row->[0]){ last;}
		push @$obj_local_content,{'MultimediaObject_ID' => $obj_row->[0],
															'URL' => $obj_row->[1],
															'Description' => $obj_row->[2],
															'Size' => $obj_row->[3],
															'Date' => $obj_row->[4],
															'langid' => $obj_row->[5],
															'ContentType' => $obj_row->[6],
															'KeepAsURL' => $obj_row->[7],
															'Type' => $obj_row->[8],
															'Height' => $obj_row->[9],
															'Width' => $obj_row->[10]
														 }
	}
	if($obj_data->[0][0]){
	 push @$obj_content, {'MultimediaObject' => $obj_local_content};
	}
	
   $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ID'} = $p_id;
   $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Code'} = $code;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Prod_id'} = $row->[1];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Quality'} = get_quality_measure($row->[9]);
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Name'} = $row->[5];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPic'} = $row->[6];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPicSize'} = $row->[11];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPic'} = $row->[7];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPicSize'} = $row->[12];
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ThumbPic'} = $row->[8];	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ThumbPicSize'} = $row->[13];	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'EAN'} = $ean_content;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Supplier'} = {'ID' => $row->[2], 'Name' => $row->[3] };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Category'} = { 'ID' => $row->[4], 'Name' => $cat_content };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductFamily'} = { 'ID' => $row->[10], 'Name' => $fam_content } if ($row->[10] != 0);
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductDescription'} = $des_content;
   $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductFeature'} = $feat_content;	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductRelated'} = $rel_content;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductBundled'} = $bndl_content;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'CategoryFeatureGroup'} = $group_content;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductGallery'} = $gallery_content;
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductMultimediaObject'} = $obj_content;
	 

		my $response = {'Response' => [$rh]}; 
		$response = xml_out($response, 
												 {
													 key_attr => {
														 'Measure'       => 'ID',
														 'Name'          => 'ID',
														 'Sign'          => 'ID',
														 'Description'   => 'ID',
														 'Feature'       => 'ID',
														 'Category'      => 'ID',
														 'Supplier'      => 'ID',
														 'Product'       => 'ID',
														 #      		'CategoryFeatureGroup'=> 'ID'
														 'ProductFamily' => 'ID',
														 'FeatureValuesVocabulary' => 'Key_Value'
													 }
												 }
			);
			 
	$$response =~ s/<>//;
  $$response =~ s/<Response.+>//;
  $$response =~ s/<ProductsList>//;
	$$response =~ s/<\/ProductsList>//;
	$$response =~ s/<\/Response>//;
#	$$response =~ s/<.+\"\?\d+\?\"\/>//;
	$$response =~ s/<\/>//;
	$$response =~ s/^\s*\n//g;
	$$response =~ s/\n\s*\n/\n/g;
			
	return $$response;
}

sub put_product_xml2_file{
    my ($p_id, $data, $supplier_repository_path) = @_;
		if(!$data){
			return undef;
		}
#    print $data;
    my $data2file = xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{'host'}."dtd/ICECAT-interface_response.dtd\">\n\t".source_message()."\n\t<ICECAT-interface>\n$data\n</ICECAT-interface>";
		my $file_path = $atomcfg{xml_dir_path}.$p_id.".xml";

    open(XML_FILE, ">$file_path") or die "Can't open '$file_path'";
		binmode(XML_FILE,":utf8");
    print XML_FILE $data2file;
	
    close(XML_FILE);

    my $updated = get_product_date($p_id);
#    print "from 2file: $updated\n";
    utime((stat($file_path))[8], $updated, $file_path) or die "Can't modify mtime in $file_path.Exit.";

		return ($data,'');
}

sub put_product_xml2_repo {
	my ($p_id, $langid, $file_path, $data, $product_date, $skip_update_modification_time) = @_; 

	my $backup = $atomcfg{'backup_enable'};
	my $diff_mode = $atomcfg{'xml_repository_diff_backup_mode'};
	my $backup_path = $atomcfg{'xml_repository_diff_backup_path'};

	my ($cmd, $rcmd, $rpath);

	# will wait string or arrayref. if string - push them to void arrayref
	unless (ref($file_path)) {
		$file_path = [ $file_path ];
	}
	unless ($product_date) {
		$product_date = get_product_date($p_id);
	}
	if ($langid == -1) {
		return undef;
	}
	else {
		if (!$$data) {
			$data =	get_product_partsxml_fromdb($p_id, $langid);
		}
	}

	my $data2file = xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{'host'}."dtd/ICECAT-interface_response.dtd\">\n\t".source_message()."\n\t<ICECAT-interface " .xsd_header('ICECAT-interface_response') .">\n".$$data."\n</ICECAT-interface>";

	my $product_id_path = get_smart_path($p_id);
	#log_printf($product_id_path);
	my $file;
	
	for (@$file_path) {
		$file = $_.$product_id_path.$p_id.'.xml';
		next unless $_;
		unless (-d $_.$product_id_path) {
			# mkdir tree
			$cmd = '/bin/mkdir -p '.$_.$product_id_path;
			`$cmd`;
		}

		## trying to backup_diff - part 1
		if ($diff_mode) {
			# check the former xml
			
			# if present - extract it near as old
			
		}

		# load content to file
		Encode::_utf8_on($data2file);
		unless (open(XML_FILE, ">".$file.".gz")) {
			log_printf("Can't open '".$file.".gz' ".$!);
			return undef;
		}
		XML_FILE->autoflush(0);
		binmode XML_FILE, ":raw";
		print XML_FILE compress_data_by_ref(\$data2file,$file);
		close XML_FILE;
		`/bin/rm -f $file`;
		utime((stat($file.".gz"))[8], $product_date, $file.".gz") or die "Can't modify mtime in ".$file.". Exit.";

		## trying to backup_diff - part 2
		if ($diff_mode) {
			# extract the new xml

			# make a diff and move it to the its place with the cool path

			# remove old and new extracted xmls
			
		}

		# upload new xml.gz file to backup server
		if ($backup) {
			# make remote dir
			$rpath = $_;
			$rpath =~ s/^.*(level4\/.*)$/$1/;
			$rcmd = '/usr/bin/ssh -q '.$atomcfg{'backup_host'}." '/bin/mkdir -p ".$atomcfg{'backup_path'}.$rpath.$product_id_path."'";
			log_printf($rcmd);
			`$rcmd`;

			# add xml
			$rcmd = '/usr/bin/scp -qrB '.$file.'.gz '.$atomcfg{'backup_host'}.':'.$atomcfg{'backup_path'}.$rpath.$product_id_path;
			log_printf($rcmd);
			`$rcmd`;
		}
	}

	# update product_modification_time
	unless ($skip_update_modification_time) {
		my $modtime = do_query("select product_id, modification_time from product_modification_time where product_id=".$p_id)->[0];
		if ($modtime->[0]) {
			do_statement("update product_modification_time set modification_time=".$product_date." where product_id=".$p_id);
			return $modtime->[1] == $product_date ? 'old' : 'new';
		}
		else {
			do_statement("insert into product_modification_time(product_id,modification_time) values('".$p_id."','".$product_date."')");
			return 'new';
		}
	}

	return 'old';
}

sub put_product_xml2_db_OLD {
    my $p_id = shift;
    my $data2db = get_product_xml_data($p_id);
#	    my $nowtime = `date +%Y%m%d%H%M%S`;
    my $ret_data = $data2db;
    $data2db = str_sqlize($data2db);
    my $updated = data_management::get_product_date($p_id);    
#    print "ToDB:\n".$data2db;
    print "from 2db: $updated\n";
		my $xml_hash = {'product_id' => $p_id,
										'xml_products_list_request_chunk' => $data2db,
										'updated' => $updated
									 };
		my $exists = do_query("select product_id from product_xml_cache where product_id = ".$p_id);										 
	  if($exists->[0][0]){
			update_rows("product_xml_cache", "product_id = ".$p_id, $xml_hash);	
		}else{
			insert_rows("product_xml_cache", $xml_hash);
		}
		
		return ('', $ret_data);
}

sub get_product_xml_fromrepo {
	my ($p_id) = @_;
	my $path = $atomcfg{'xml_export_path'}."/level4/INT/".$p_id.".xml";
	my $content = "";
	open(XML,"<".$path) or return \$content;
	binmode(XML,":utf8");
	$content = join("",<XML>);
	close XML;
	$content =~ /<ICECAT-interface>(.*)<\/ICECAT-interface>/is;
	$content = $1;
	chomp($content);
	return \$content;
}

sub req_validation {
	my $str = shift;

	my $doctyperr = 0;
	$str =~ /(<\!DOCTYPE ICECAT-interface SYSTEM \"http:\/\/.*?\/dtd\/ICECAT-interface_request.dtd\">)/s;

	if (!$1) {
		my $resp = "DOCTYPE error. Check SYSTEM ID";
		$str =~ s/<\?xml version=\'1.0\'\?>\s+(<\!DOCTYPE.+>\s+)?\s+<ICECAT-interface>\s+/<\?xml version=\'1.0\'\?>\n<\!DOCTYPE ICECAT-interface SYSTEM \"$atomcfg{'host'}dtd\/ICECAT-interface_request.dtd\">\n<ICECAT-interface>\n/g;
		$doctyperr = 1;	
		#       return \$resp;
	}

	my $dtd = XML::LibXML::Dtd->new("",$atomcfg{'base_dir'}."/www/dtd/ICECAT-interface_request.dtd");
	my $doc = XML::LibXML->new->parse_string($str);
	eval { $doc->validate($dtd) };
	if ($@) {
		return $@;
	}
	if ($doctyperr) {
		return "DOCTYPE ERROR";
	}
}
				
sub get_text_tag {
	my $test_parser = XML::LibXML->new();
	my $test_doc = $test_parser->parse_chunk( "<a>a</a>", 1 );
	my $test_elem = $test_doc->getDocumentElement;
	my @test_child_nodes = $test_elem->childNodes;
	return undef if ($#test_child_nodes == -1);
	return $test_child_nodes[0]->nodeName;
} # get_text_tag

#sub resp_validation{
#    my $str = @_[0];
#    my $dtd = XML::LibXML::Dtd->new("","icecat_response.dtd");
#    my $doc = XML::LibXML->new->parse_string($str);
#    eval{ $doc->validate($dtd)};
#    if($@){
#	$@ =~ s/\n$//;
#	my $time = localtime(time());
#	my $resp = "?xml version='1.0'?>\n<!DOCTYPE ICECAT-interface SYSTEM \"icecat-response.dtd\">\n\t".&source_message()."\n\t<ICECAT-interface>
#	\t<Response Data=\"$time\" Error='$@'></Response>\n\t</ICECAT-interface>";
#	return \$resp;	
#    }
#}

1;

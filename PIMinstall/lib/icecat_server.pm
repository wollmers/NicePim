package icecat_server;

#$Id: icecat_server.pm 492 2006-12-15 09:26:02Z dima $

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

use data_management;

use LWP::UserAgent;
use XML::Simple;
use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
								 &icecat_server_main
								 &icecat_server_main_cgi
								 &icecat_server_main_cgi2html
							);

 $SIG{ALRM} = sub { 
     my $message_text = $hin{'REQUEST_BODY'};
		 
		 if(!( $message_text=~m/xml/ )){
			 # &log_printf('Trying to ungzip!');
			 $message_text = &ungzip_data($message_text);
		 }

     &sendmail(" the xml request is timed out!. The body:\n".$message_text,
							 $atomcfg{'bugreport_email'}, 'icecat', 'timeout'); 
	   
	 };
 alarm 550;
}

sub respond_message
{
my ($message_text) = @_;
my $response = {};

my $gzipped = 0;

if(!( $message_text=~m/xml/ )){
# &log_printf('Trying to ungzip!');
 $message_text = &ungzip_data($message_text);
 $gzipped = 1;
}

my $rh = {};

my $xs = new XML::Simple();

my $message = $xs->XMLin($message_text, forcearray => 1 );

#  print Dumper($message);
my $root = $message->{'Request'}->[0];

# verifying login info

my $login = $root->{'Login'};
my $pass	= $root->{'Password'};
my $status = 1;
my $user_id = '';

my $usr_data = &do_query("select user_id, user_group, access_restriction, access_restriction_ip  from users where login =".&str_sqlize($login)." and password = ".&str_sqlize($pass));

if($usr_data && $usr_data->[0] && $usr_data->[0][1] eq 'shop'&&
  &verify_address($usr_data->[0][2], $usr_data->[0][3], $ENV{'REMOTE_ADDR'} )){
	
 $status = 1;
 $user_id = $usr_data->[0][0];
 
} else {
 $status = -1;
}

$rh->{'Status'} = $status;

my $nowtime = time();

 $rh->{'ID'} = &log_xml_request($root->{'Request_ID'}, $user_id, $status, $nowtime, $login);


 $rh->{'Request_ID'}	= $root->{'Request_ID'}||'';
 $rh->{'Date'}	= localtime($nowtime);

if($status == 1){

#
# MEASURES
#

if(defined $root->{'MeasuresListRequest'}){
 # building measures list
 my $req = $root->{'MeasuresListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }
 my $measures = &do_query("select measure_id, sign, vocabulary.record_id, vocabulary.langid, tex.tex_id, vocabulary.value, tex.value from measure, tex, vocabulary where measure.sid = vocabulary.sid and tex.tid = measure.tid and ($f) and vocabulary.langid = tex.langid");
 foreach my $measure(@$measures){
   
	 $rh->{'MeasuresList'}->{'Measure'}->{$measure->[0]}->{"Sign"} = { 'content' => $measure->[1] };
 
	 $rh->{'MeasuresList'}->{'Measure'}->{$measure->[0]}->{"Names"}->{"Name"}->{$measure->[2]} =
	 												{
														"content"	=> $measure->[5],
														'langid'	=> $measure->[3]
													};
	 $rh->{'MeasuresList'}->{'Measure'}->{$measure->[0]}->{"Descriptions"}->{"Description"}->{$measure->[4]} =
	 												{
														"content"	=> $measure->[6],
														'langid'	=> $measure->[3]
													};

 }
}
#
# features
#

if(defined $root->{'FeaturesListRequest'}){
 # building measures list
 my $req = $root->{'FeaturesListRequest'}->[0];

 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }
 
 my $features = &do_query("select feature_id, measure.sign, vocabulary.record_id, vocabulary.langid, tex.tex_id, vocabulary.value, tex.value, measure.measure_id from feature, measure, tex, vocabulary where measure.measure_id = feature.measure_id and feature.sid = vocabulary.sid and tex.tid = feature.tid and ($f) and vocabulary.langid = tex.langid");
 foreach my $feature(@$features){
   
	 $rh->{'FeaturesList'}->{'Feature'}->{$feature->[0]}->{'Measure'} = {
	   "Sign" 	=> { 'content' => $feature->[1] },
		 "ID"	=> $feature->[7]
		 
		 };
 
	 $rh->{'FeaturesList'}->{'Feature'}->{$feature->[0]}->{"Names"}->{"Name"}->{$feature->[2]} =
	 												{
														"content"	=> $feature->[5],
														'langid'	=> $feature->[3]
													};
	 $rh->{'FeaturesList'}->{'Feature'}->{$feature->[0]}->{"Descriptions"}->{"Description"}->{$feature->[4]} =
	 												{
														"content"	=> $feature->[6],
														'langid'	=> $feature->[3]
													};

 }
}

#
# categories
#

if(defined $root->{'CategoriesListRequest'}){
 # building measures list
 my $req = $root->{'CategoriesListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }
 my $extra_sql = '';
  
 if(defined $req->{'Searchable'}){
  $extra_sql = ' and category.searchable = '.&str_sqlize($req->{'Searchable'});
 }
 if(defined $req->{'Category_ID'}){
  $extra_sql = ' and category.catid = '.&str_sqlize($req->{'Category_ID'});
 }
# &log_printf(Dumper($req));
 if(defined $req->{'UNCATID'}){
  $extra_sql = ' and category.ucatid = '.&str_sqlize($req->{'UNCATID'});
 }

 my $data = &do_query("select catid, ucatid, sid, tid, pcatid, searchable, category.low_pic from category where 1 $extra_sql");
 my $cat_name = {};
 my $pcat_name = {};


# building cats	names
 my $cat_data = &do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid from category, vocabulary where vocabulary.sid = category.sid and ($f) $extra_sql");
 foreach my $cat_row(@$cat_data){
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

 foreach my $row(@$data){


  $rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'UNCATID'} 	= { 'content' => $row->[1] };
  foreach my $pcat_row(@{$pcat_name->{$row->[4]}}){
	  my $hash = {};
		   %$hash = %{$pcat_row};
		push @{$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'Names'}->{'Name'}},
				 $hash;	
	}
	$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'ParentCategory'}->{'ID'}	= $row->[4];
	$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'LowPic'}									= $row->[6];
	$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Names'}->{'Name'}			= $cat_name->{$row->[0]};
	$rh->{'CategoriesList'}->{'Category'}->{$row->[0]}->{'Searchable'} = $row->[5];
 }

}

#
# supplier categories
#

if(defined $root->{'SupplierCategoriesListRequest'}){
 # response code
 
 my $code = 1;
 
 my $req = $root->{'SupplierCategoriesListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
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
	 $where .= 'and supplier.name = '.&str_sqlize($req->{'Supplier'}->{'Name'});
	}
	if($req->{'Supplier'}->{'ID'}){
	 $where .= 'and supplier.supplier_id = '.&str_sqlize($req->{'Supplier'}->{'ID'});
	}

  my $supp_data = &do_query("select supplier_id, name from supplier where $where");
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

	 my $data = &do_query("select product.catid, ucatid, sid, tid, pcatid, searchable from category, product where product.catid = category.catid $extra_sql group by product.catid");
	 my $cat_name = {};
	 my $pcat_name = {};


# building cats	names
	 foreach my $row(@$data){

		my $cat_data = &do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = $row->[0]");

		  foreach my $cat_row(@$cat_data){
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
		  foreach my $pcat_row(@{$pcat_name->{$row->[4]}}){
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
# Suppliers
#

if(defined $root->{'SuppliersListRequest'}){
 # building suppliers list
my $data;

 if(%{$root->{'SuppliersListRequest'}->[0]}){
   my $extra_sql = '1';
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
   my $ids = &do_query("select distinct supplier_id from product, category where category.catid = product.catid and $extra_sql"); 
	 my $where = ' 0 ';
	 foreach my $id_row(@$ids){
	  $where .= ' or supplier.supplier_id = '.$id_row->[0];
	 }
	 my $suppliers = &do_query("select supplier_id, name from supplier where $where");

   foreach my $supplier(@$suppliers){
		push @$data, $supplier if (defined $supplier);
	 }
 } else {

    $data = &do_query("select supplier_id, name from supplier");
 }
 foreach my $row(@$data){
  $rh->{'SuppliersList'}->{'Supplier'}->{$row->[0]}->{"Names"}->{'Name'} 	= { 'content' => $row->[1] };
 }

}

#
# Category feature
#

if(defined $root->{'CategoryFeaturesListRequest'}){
 my $req = $root->{'CategoryFeaturesListRequest'}->[0];
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }

 my ($catid, $ucatid, $low_pic);  # getting correct category id
 my $code = 1; # this request code

 if($req->{'UNCATID'}){
  my $refer = &do_query("select catid, ucatid, category.low_pic from category where ucatid = ".&str_sqlize($req->{'UNCATID'}));
  ($catid, $ucatid, $low_pic) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
  if(!$catid){
	 $code = 10; # uncatid is wrong
	}
 }
 
 if(defined $req->{'Category_ID'} ){
	 my $refer = &do_query("select catid, ucatid, category.low_pic from category where catid = ".&str_sqlize($req->{'Category_ID'}));
   ($catid, $ucatid, $low_pic) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
	if(!$catid){
	 $code = 11; # catid is wrong
	}
 }

 if($catid){
    my $extra_sql = '1 ';

    if($req->{'Searchable'}){
		  $extra_sql .= ' and category_feature.searchable = 1 ';
		}
    if($req->{'Key'}){
		  $extra_sql .= ' and feature.class = 0 ';
		}

		my $cat_data = &do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid, category.catid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = $catid");

# building feature group hashes 
 	my $feat_group_data = &do_query("select feature_group.feature_group_id, vocabulary.value, vocabulary.langid, vocabulary.record_id from feature_group, vocabulary where vocabulary.sid = feature_group.sid and ($f)");
	my $feat_group = {};
	foreach my $row(@$feat_group_data){
	 $feat_group->{$row->[0]}->{'ID'} = $row->[0];
	 push @{$feat_group->{$row->[0]}->{'Names'}->{'Name'}}, 
	   {
		  "ID" => $row->[3],
			"content" => $row->[1],
			"langid" => $row->[2]
		 }

	}
	
	# processing category features group
  my $cat_feat_group_data = &do_query("select category_feature_group_id, feature_group_id, no from category_feature_group where catid = ".$catid);
  my $group_content = [];
  foreach my $row(@$cat_feat_group_data){
	 push @$group_content, 
			{
			 "ID" => $row->[0],
			 "No"	=> $row->[2],
			 "FeatureGroup" => $feat_group->{$row->[1]}
			}
	}

    my ($cat_name);
		
		  foreach my $cat_row(@$cat_data){
			 push @$cat_name, { 'langid' 	=> 	$cat_row->[2],
													'content'	=> 	$cat_row->[0],
													'ID'			=>	$cat_row->[1]
												};
			}

			$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Names'}->{'Name'}			= $cat_name;
	 

 
 
	 # building category features list
	 my $data = &do_query("select category_feature_id, feature.feature_id, vocabulary.langid, vocabulary.value, measure.sign, vocabulary.record_id, feature.limit_direction, (category_feature.searchable * 10000000 + (1 - feature.class) * 100000 + category_feature.no), category_feature.searchable, feature.class, feature.measure_id, category_feature.category_feature_group_id, restricted_search_values, restricted_values from measure, category_feature, feature, vocabulary where feature.feature_id = category_feature.feature_id and category_feature.catid = $catid and vocabulary.sid = feature.sid and ($f) and measure.measure_id = feature.measure_id and $extra_sql");
	 

	 foreach my $row(@$data){
	  $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Names'}->{'Name'}->{$row->[5]} = { 'langid' => $row->[2] ,  'content' => $row->[3]};
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Measure'}->{$row->[10]}->{'Sign'} = $row->[4];
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'LimitDirection'} = $row->[6];
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'No'} = $row->[7];
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Searchable'} = $row->[8];
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'Class'} = $row->[9];
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'CategoryFeatureGroup'} = 
														{  "ID" => int( $row->[11] ) };		
		my @tmp = split("\n", $row->[12] || $row->[13])														;
		$rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'Feature'}->{$row->[1]}->{'RestrictedValues'}->{'RestrictedValue'} = \@tmp;
	 }
	 
	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'CategoryFeatureGroups'} = { 'CategoryFeatureGroup' => $group_content,
																																									'Category_ID' => $catid  };	 
 	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'UNCATID'} = $ucatid;
 	 $rh->{'CategoryFeaturesList'}->{'Category'}->{$catid}->{'LowPic'} = $low_pic;	 
	}
 $rh->{'CategoryFeaturesList'}->{'Code'} 		= $code;  
}
#
# product lookup
#
if(defined $root->{'ProductsListLookupRequest'}){
 my $req = $root->{'ProductsListLookupRequest'}->[0];

 my ($catid, $ucatid);  # getting correct category id
 my $code = 1; # this request code
 if($req->{'UNCATID'}){
  my $refer = &do_query("select catid, ucatid from category where searchable = 1 and ucatid = ".&str_sqlize($req->{'UNCATID'}));
  ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
  if(!$catid){
	 $code = 10; # uncatid is wrong
	}
 }
 
 if(defined $req->{'Category_ID'} ){
	 my $refer = &do_query("select catid, ucatid from category where catid = ".&str_sqlize($req->{'Category_ID'}));
   ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
	if(!$catid){
	 $code = 11; # catid is wrong
	}
 }
 
 if($code == 1){
 # category is ok
 
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 my $ff = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
  $ff.= ' or langid = '.&str_sqlize($langid);
 }
 # getting product set for each feature limitation
 # also should check if the used features correctness
 
 my $cnt = 0;
 my $result_set = {};
 
 foreach my $item('LookupText'){
 
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

# now  verifying input
 if($req->{'Supplier'}->{'Name'}||$req->{'Supplier'}->{'ID'}){
  my $where = '1 ';
	if($req->{'Supplier'}->{'Name'}){
	 $where .= 'and supplier.name = '.&str_sqlize($req->{'Supplier'}->{'Name'});
	}
	if($req->{'Supplier'}->{'ID'}){
	 $where .= 'and supplier.supplier_id = '.&str_sqlize($req->{'Supplier'}->{'ID'});
	}

  my $supp_data = &do_query("select supplier_id, name from supplier where $where");
  if($supp_data->[0] && $supp_data->[0][1]){
	 # ok
	 $extra_sql = ' and product.supplier_id = '.$supp_data->[0][0];
	} else {
	 # ignoring supplier requirmets
	}
 }
 
 
 
 
 if($req->{'LookupText'}){
  $cnt++;
	my $pattern = &str_sqlize('%'.$req->{'LookupText'}.'%');
	my $product_data = &do_query("select product.product_id from product, product_description where product.product_id = product_description.product_id and ($ff) and (product.name like $pattern or product_description.short_desc like $pattern or product.prod_id like $pattern) and product.catid = $catid $extra_sql");

	  foreach my $row(@$product_data){
		 if($result_set->{$row->[0]} && $row->[0]){
		 		 $result_set->{$row->[0]}++;
		 } else {
		 		 $result_set->{$row->[0]} = 1;
		 }
		}

 }
  # getting all of products
	my $product_data = &do_query("select product.product_id from product where product.catid = $catid $extra_sql");
	$cnt++;
  foreach my $row(@$product_data){
	 if($result_set->{$row->[0]}){
	 		 $result_set->{$row->[0]}++;
	 } else {
	 		 $result_set->{$row->[0]} = 1;
	 }
	}

 foreach my $feature(@{$req->{'Features'}->[0]->{'Feature'}}){
  if(!$feature->{'ID'}){ next ; }
  my $feat_data = &do_query("select feature_id, limit_direction from feature where feature_id = ".&str_sqlize($feature->{'ID'}))->[0];
  if(defined $feat_data && defined $feat_data->[0]){
	  $cnt++;

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
		 $limit = &str_sqlize($limit);
		}
    
		# performing request
		
		my $product_data = &do_query("select product.product_id from product, product_feature, category_feature, feature where product_feature.value".$dir.$limit." and product.product_id = product_feature.product_id and product_feature.category_feature_id = category_feature.category_feature_id and category_feature.feature_id = feature.feature_id and feature.feature_id = $feature_id and product.catid = $catid $extra_sql");
	  foreach my $row(@$product_data){
		 if($result_set->{$row->[0]}){
		 		 $result_set->{$row->[0]}++;
		 } else {
		 		 $result_set->{$row->[0]} = 1;
		 }
		}	
		
	}
 }
 # now got all requests performed
 # filetring result set
 
 my $result_arr = [];
 my $result_hash = {};
 
 foreach my $product_id(keys %$result_set){
  if($result_set->{$product_id} == $cnt && $product_id){
#	 push @$result_arr, $product_id;
	 $result_hash->{$product_id} = 1;
	}
 } 
   $rh->{'ProductsListLookup'}->{'Product'} = {};
   &describe_products_xml($result_hash, $rh->{'ProductsListLookup'}->{'Product'}, $catid, $f); 
  
 }
 
 $rh->{'ProductsListLookup'}->{'Code'} 		= $code;  
 
} 

#
# product statistic
#
if(defined $root->{'ProductsStatistic'}){
 my $req = $root->{'ProductsStatistic'}->[0];
 if(ref($req) eq 'HASH'){
 
 my @lang = split(/,/, $req->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }

 
 my ($catid, $ucatid);

 # getting catid
  if($req->{'UNCATID'}){
  my $refer = &do_query("select catid, ucatid from category where ucatid = ".&str_sqlize($req->{'UNCATID'}));
  ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
 }
 
 if(defined $req->{'Category_ID'} ){
	 my $refer = &do_query("select catid, ucatid from category where catid = ".&str_sqlize($req->{'Category_ID'}));
   ($catid, $ucatid) = @{$refer->[0]} if (defined $refer && defined $refer->[0]); 
 }
 
  if($req->{'Type'} eq 'TOP10' && $catid){
	 
 	  my $data = &do_query("select rproduct_id, count(*) as cnt from request, request_product, product where product.product_id = rproduct_id and catid = ".&str_sqlize($catid)." and ( unix_timestamp() - request.date) < 24*60*60*7 and request.request_id = request_product.request_id group by rproduct_id order by cnt");
		my $prod_hash = {};
		
		foreach my $row(@$data){
#		 push @$prod_arr, $row->[0];
		 $prod_hash->{$row->[0]} = 1;
		}
		

  	$rh->{'ProductsStatistic'}->{'Product'} = {};
  	&describe_products_xml($prod_hash, $rh->{'ProductsStatistic'}->{'Product'}, $catid, $f); 

		foreach my $row(@$data){
			$rh->{'ProductsStatistic'}->{'Product'}->{$row->[0]}->{'Score'} = $row->[1];
		}
	 
	}
 }
}

#
# products
#
if(defined $root->{'ProductsListRequest'}){

 my @lang = split(/,/, $root->{'ProductsListRequest'}->[0]->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }

# building feature group hashes 
 	my $feat_group_data = &do_query("select feature_group.feature_group_id, vocabulary.value, vocabulary.langid, vocabulary.record_id from feature_group, vocabulary where vocabulary.sid = feature_group.sid and ($f)");
	my $feat_group = {};
	foreach my $row(@$feat_group_data){
	 $feat_group->{$row->[0]}->{'ID'} = $row->[0];
	 push @{$feat_group->{$row->[0]}->{'Names'}->{'Name'}}, 
	   {
		  "ID" => $row->[3],
			"content" => $row->[1],
			"langid" => $row->[2]
		 }

	}

 
 foreach my $pr_req(@{$root->{'ProductsListRequest'}->[0]->{'Product'}}){
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

   $where = " product_id = ".&str_sqlize($pr_req->{'ID'});
	 $req_type = 1;

	} elsif(ref($pr_req->{'Supplier'}->[0]) eq 'HASH' && $pr_req->{'Supplier'}->[0]->{'ID'} &&
					$pr_req->{'Prod_id'}->[0] ) {
	 $where = " supplier.supplier_id = ".&str_sqlize($pr_req->{'Supplier'}->[0]->{'ID'})." and prod_id = ".&str_sqlize($pr_req->{'Prod_id'}->[0]);
	 $req_type = 2;

	 # validating input

	 my $supp = &do_query("select supplier_id, name from supplier where supplier_id = ".&str_sqlize($pr_req->{'Supplier'}->[0]->{'ID'}));
	 unless($supp && $supp->[0]){
	  # supplier_id is wrong
		$e_supp_id = 1;
	 } else {
	 	 $vfied_supplier_id 		= $supp->[0][0];
   	 $vfied_supplier_name		= $supp->[0][1];
	 }

	} elsif(ref($pr_req->{'Supplier'}->[0]) ne 'HASH' && $pr_req->{'Supplier'}->[0] &&
					$pr_req->{'Prod_id'}->[0] ) {
	 $where = " supplier.name = ".&str_sqlize($pr_req->{'Supplier'}->[0])." and prod_id = ".&str_sqlize($pr_req->{'Prod_id'}->[0]);

	 # validating input
	 my $supp = &do_query("select supplier_id from supplier where name = ".&str_sqlize($pr_req->{'Supplier'}->[0]));
	 unless($supp && $supp->[0]){
	  # supplier_id is wrong
		$e_supp_name = 1;
    $vfied_supplier_name	= $pr_req->{'Supplier'}->[0];		
	 } else {
	  $vfied_supplier_id 		= $supp->[0][0];
    $vfied_supplier_name	= $pr_req->{'Supplier'}->[0];
	 }

	 $req_type = 3;
	}
	
	 $data = &do_query("select product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id  and ".$where);
	 unless($data && $data->[0]){
		if($req_type == 1){
		 $e_product_id = 1;
		}
		 $e_not_found = 1;
	 } else {
	  $pr_req->{'ID'} = $data->[0][0];
	 }
	 
	 my $code = 0;
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
	 
# stating request
    &state_product_request($rh->{'ID'}, $pr_req->{'ID'}, $pr_req->{'Prod_id'}->[0], $vfied_supplier_id, $vfied_supplier_name, $code, $e_not_found^1);	 
	 
	 if($code != 1){
	  if($req_type == 1){
			$rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'ID'}).'?'}->{'Code'} = $code;
		} else {
			$rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'Prod_id'}->[0] ).'?'}->{'Code'} = $code;
		}
	  next;
	 }
	 
	 my $row = $data->[0];
	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Code'} = $code;

# building cats	for product
	 my $cat_data = &do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = ".&str_sqlize($row->[4]));
	 my $cat_content = [];
	 foreach my $cat_row(@$cat_data){
	  push @$cat_content, { 'ID'			=> $cat_row->[1],
																		  'content'	=> $cat_row->[0],
																			'langid'	=> $cat_row->[2] } ;
	 }
# building product_description entries
   my $des_data = &do_query("select short_desc, long_desc, warranty_info, official_url, product_description_id, langid, pdf_url from product_description as vocabulary where product_id = $row->[0] and ($f)");	 
	 my $des_content = [];
	 foreach my $des_row(@$des_data){
		push @$des_content, {  "ShortDesc" 		=> { 'content' => $des_row->[0]},
													 "LongDesc"			=> { 'content' => $des_row->[1]},
													 "WarrantyInfo"	=> { 'content' => $des_row->[2]},
													 "URL"					=> { 'content' => $des_row->[3]},
													 "PDFURL"				=> { 'content' => $des_row->[6]},
													 "ID"						=> $des_row->[4],
													 "langid"				=> $des_row->[5]};		
	 }

# processing category features group
  my $cat_feat_group_data = &do_query("select category_feature_group_id, feature_group_id, no from category_feature_group where catid=".$row->[4]);
  my $group_content = [];
  foreach my $row(@$cat_feat_group_data){
	 push @$group_content, 
			{
			 "ID" => $row->[0],
			 "No"	=> $row->[2],
			 "FeatureGroup" => $feat_group->{$row->[1]}
			}
	}

	 
# building features list
   my $feat_data = &do_query("select product_feature_id, category_feature.feature_id, product_feature.value, feature.measure_id, measure.sign, (category_feature.searchable * 10000000 + (1 - feature.class) * 100000 + category_feature.no), category_feature.category_feature_group_id from measure, product_feature, category_feature, feature where category_feature.catid = $row->[4] and measure.measure_id = feature.measure_id and category_feature.category_feature_id = product_feature.category_feature_id and feature.feature_id = category_feature.feature_id and product_feature.product_id = ".&str_sqlize($row->[0]));
   my $feat_content = [];
	 foreach my $feat_row(@$feat_data){
	  my $feat_names = [];
		my $fn = &do_query("select vocabulary.value, vocabulary.langid, record_id from vocabulary, feature where feature.sid = vocabulary.sid and ($f) and feature.feature_id = $feat_row->[1]");
    foreach my $fn_row(@$fn){
			 push @$feat_names, { 'ID'				=> $fn_row->[2], 
												 'langid'		=> $fn_row->[1],
												 'content'	=> $fn_row->[0] 
												};
		}
	  push @$feat_content, { "ID" 			=> $feat_row->[0],
													"No"				=> $feat_row->[5],
													"CategoryFeatureGroup" => { "ID" => int($feat_row->[6])},
													"Feature"		=> 	{
																						"ID"		=> $feat_row->[1],
																						"Names"	=> { 'Name' => $feat_names }
																					},
														"Value"		=>  { 'content' => $feat_row->[2] },
														"Measure"	=> {
																					 'ID'		=> $feat_row->[3],
																					 'Sign'			=> { 'content' => $feat_row->[4] }	
																				 }
												 };
	 }
	 
# building related
	my $rel_data1 = &do_query("select product_related_id, rel_product_id, product.prod_id, product.supplier_id, supplier.name, product.name, product.thumb_pic from product_related, product, supplier where  product_related.product_id = $row->[0] and product_related.rel_product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 
	my $rel_data2 = &do_query("select product_related_id, product.product_id, product.prod_id, product.supplier_id, supplier.name, product.name, product.thumb_pic from product_related, product, supplier where  product_related.rel_product_id = $row->[0] and product_related.product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 
	my $rel_data 	= [];
	
	push @$rel_data, @$rel_data1;
	push @$rel_data, @$rel_data2;
	
	my $rel_content = [];
	
	foreach my $rel_row(@$rel_data){
	 push @$rel_content, { 'ID' 			=> $rel_row->[0], 
												 'Product' 	=> { 'ID'		=> $rel_row->[1],
																				 'Supplier'	=> {
																												'ID' 	=> $rel_row->[3],
																												'content'	=> $rel_row->[4]
																											 },
																				 'Prod_id'	=> { 'content' => $rel_row->[2] },
																				 'Name'			=> $rel_row->[5],
																				 'ThumbPic' => $rel_row->[6]
																			 }
											 }	
	}
 	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Prod_id'} = { 'content' => $row->[1]};
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Supplier'} = {'ID' => $row->[2], 'content' => $row->[3] };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Category'} = { 'ID' => $row->[4], 'Names' =>  { 'Name' => $cat_content }};
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Quality'} = &get_quality_measure($row->[9]);
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Name'} = { 'content' => $row->[5]};
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPic'} = { 'content' => $row->[6] };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPic'} = { 'content' => $row->[7] };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ThumbPic'} = { 'content' => $row->[8] };	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductDescriptions'} = { 'ProductDescription' => $des_content };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductFeatures'} = { 'ProductFeature' => $feat_content };	 
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductsRelated'} = { 'ProductRelated' => $rel_content };
	 $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'CategoryFeatureGroups'} = { 'CategoryFeatureGroup' => $group_content,
																																									'Category_ID' => $row->[4]  };	 
#	 &log_printf(Dumper($group_content));
 }

}

#
# products dump
#

if(defined $root->{'ProductsDumpRequest'}){

 my @lang = split(/,/, $root->{'ProductsDumpRequest'}->[0]->{'langid'});
 my $f = '0 ';
 foreach my $langid(@lang){
  $f .= ' or vocabulary.langid = '.&str_sqlize($langid);
 }
 
 my $products = '';
 
 my $quality = &get_quality_index($root->{'ProductsDumpRequest'}->[0]->{'MinQuality'});
 
 
 my $updated_from = $root->{'ProductsDumpRequest'}->[0]->{'UpdatedFrom'};
    if($updated_from){
   		 $updated_from = &do_query("select unix_timestamp(".&str_sqlize($updated_from).")")->[0][0]; 
		} else {
		   $updated_from = '';
		}
 
 if($quality < &get_quality_index('ICECAT')){
  $quality = &get_quality_index('ICECAT');
 } 

 my $supplier = $root->{'ProductsDumpRequest'}->[0]->{'Supplier_ID'};
 my @suppliers = split(',', $supplier);
 my %allowed = map { $_ => 1 } @suppliers;
 
 my $raw_products = &do_query("select product_id, user_id, supplier_id from product");
 my $users = &do_query("select user_id, user_group from users");
 my %users = map { $_->[0] => $_->[1] } @$users;

 my $request = [];
 
 my $i = 0;
 
 foreach my $row(@$raw_products){
  my $ug = $users{$row->[1]};
	my $q_rate = &get_quality_measure($ug);
  my $row_quality = &get_quality_index($q_rate);
	
	if($row_quality >= $quality &&
	 ( $allowed{$row->[2]} && $supplier || !$supplier) ){
	 $i++;
#	 if($i > 1000) { next } # !!!!!
	 my $updated = &get_product_date($row->[0]);
	 if( (!$updated_from || $updated_from <= $updated) ){
		 push @$request, { 'ID'	=> $row->[0] };
	 }
	}
	
 }
 
 
 my $feat_data_hash = {}; 

 undef $raw_products;
 
 my $prod_xml = &load_complex_template('xml/products_dump.xml');
 
 foreach my $pr_req(@$request){
  
	my $xml = '';
	my $hash = {};
 
  my $data;
	my $where 		= '';
	my $req_type 	= 0;
	
	my $e_supp_id 		= 0;
	my $e_supp_name 	= 0;
	my $e_product_id	= 0;
	my $e_not_found		= 0;
	
	my $vfied_supplier_name = '';
	my $vfied_supplier_id = '';

  $where = " product_id = ".&str_sqlize($pr_req->{'ID'});
  $req_type = 1;
	
	 $data = &do_query("select product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic, users.user_group from product, category, supplier, users where product.user_id = users.user_id and category.catid = product.catid and product.supplier_id = supplier.supplier_id  and ".$where);
	 unless($data && $data->[0]){
		if($req_type == 1){
		 $e_product_id = 1;
		}
		 $e_not_found = 1;
	 } else {
	  $pr_req->{'ID'} = $data->[0][0];
	 }
	 
	 my $code = 0;
	 if(!$e_not_found){
	 		$code = 1; # product found, input correct
	 } else {
	  if($req_type == 1){
			$code = 3; # product not found, supplied wrong product_id
		} 
	 }
	 
# stating request
	 
	 if($code != 1){
	  if($req_type == 1){
			$rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'ID'}).'?'}->{'Code'} = $code;
		} else {
			$rh->{'ProductsList'}->{'Product'}->{'?'.($pr_req->{'Prod_id'}->[0] ).'?'}->{'Code'} = $code;
		}
	  next;
	 }
	 
	 my $row = $data->[0];
	 
	 $hash->{'Code'} = $code;

# building product_description entries
   my $descriptions = '';
	 
   my $des_data = &do_query("select short_desc, long_desc, warranty_info, official_url, product_description_id, langid from product_description as vocabulary where product_id = $row->[0] and ($f)");	 

   $hash->{'ProductDescriptions'} = '';
	 foreach my $des_row(@$des_data){
		$hash->{'ProductDescriptions'} .= &repl_ph($prod_xml->{'product_description_row'}, 
												{  "ShortDesc" 		=> &str_xmlize($des_row->[0]),
													 "LongDesc"			=> &str_xmlize($des_row->[1]),
													 "WarrantyInfo"	=> &str_xmlize($des_row->[2]),
													 "URL"					=> &str_xmlize($des_row->[3]),
													 "ID"						=> $des_row->[4],
													 "langid"				=> $des_row->[5]
												});		
	}
	 
# building features list
   my $feat_data = &do_query("select product_feature_id, category_feature.feature_id, product_feature.value, feature.measure_id, measure.sign, (category_feature.searchable * 10000000 + (1 - feature.class) * 100000 + category_feature.no) from measure, product_feature, category_feature, feature where category_feature.catid = $row->[4] and measure.measure_id = feature.measure_id and category_feature.category_feature_id = product_feature.category_feature_id and feature.feature_id = category_feature.feature_id and product_feature.product_id = ".&str_sqlize($row->[0]));
   my $feat_content = [];
	 $hash->{'ProductFeature'} = '';
	 foreach my $feat_row(@$feat_data){
	  my $feat_names = [];
		my $fn = [];

	  $hash->{'ProductFeature'} .= &repl_ph($prod_xml->{'product_feature_row'},
											  { "ID" 						=> $feat_row->[0],
													"No"						=> $feat_row->[5],
													"Feature_ID"		=> $feat_row->[1],
													"Value"					=> &str_xmlize($feat_row->[2]),
													"Measure_ID"		=> $feat_row->[3]
												 });
	 }
	 
# building related
	my $rel_data = &do_query("select product_related_id, rel_product_id, product.prod_id, product.supplier_id, supplier.name from product_related, product, supplier where product_related.product_id = $row->[0] and product_related.rel_product_id = product.product_id and product.supplier_id = supplier.supplier_id");	 
	my $rel_content = [];
	$hash->{'ProductsRelated'} = '';
	foreach my $rel_row(@$rel_data){
	 $hash->{'ProductsRelated'} .= &repl_ph($prod_xml->{'product_related_row'},
	 										 { 'ID' 				=> $rel_row->[0], 
												 'Product_ID' => $rel_row->[1]
											 });
	}
 	 
	 $hash->{'Prod_id'} = &str_xmlize($row->[1]);
   $hash->{'Supplier_ID'} = $row->[2];
   $hash->{'Category_ID'} = $row->[4];
   $hash->{'Quality'} = &get_quality_measure($row->[9]);
   $hash->{'Name'} =  &str_xmlize($row->[5]);
   $hash->{'LowPic'} =  &str_xmlize($row->[6]);
   $hash->{'HighPic'} = &str_xmlize($row->[7]);
   $hash->{'ThumbPic'} = $row->[8];	 
	 $hash->{'ID'}			 = $row->[0];
   $products .= &repl_ph($prod_xml->{'product_body'}, $hash);	 
 }
$rh->{'__plain_xml'} .= &repl_ph($prod_xml->{'body'}, { 'products' => $products });
}




}

return ({'Response' => [ $rh
											] 
										 }, $gzipped);



}

sub icecat_server_main
{

&atom_html::ReadParse;


my $message = $hin{'REQUEST_BODY'};
my ($response, $gzipped) = &respond_message($message);

    $response = &build_message($response);

if($gzipped){
 print "Content-type: application/x-gzip\n\n";
 $$response = &gzip_data($$response);
} else {
 print "Content-type: text/xml\n\n";
}


print $$response;

}

sub icecat_server_main_cgi
{

&atom_html::ReadParse;

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


my $message = &build_message(&build_request($hash,$hin{'shop'},$hin{'pass'},$hin{'Request_ID'}||''));

my $response = &build_message(&respond_message($$message));

print $$response;

}

sub icecat_server_main_cgi2html
{

 &html_start();
 
 $hin{'tmpl'} = 'product_details_pub.html';

 my $login = $hin{'shop'};
 my $pass	= $hin{'pass'};
 
 if($hin{'langid'}){
  $hl{'langid'} = $hin{'langid'};	
 }
 
 my $status = 1;
 my $user_id = '';

 my $usr_data = &do_query("select user_id, user_group, access_restriction, access_restriction_ip  from users where login =".&atomsql::str_sqlize($login)." and password = ".&atomsql::str_sqlize($pass));
 
	&atom_engine::init_atom_engine();


 my $status = -1;
 my $vfied_supplier_id 		= '';
 my $vfied_supplier_name 	= '';
 my $e_not_found = 0;
 my $e_supp_id = 0;
 my $e_supp_name = 0;
 
 my $code = 0;
 my $req_type;
 
 
	
 if($usr_data && $usr_data->[0] && $usr_data->[0][1] eq 'shop'&&
   &verify_address($usr_data->[0][2], $usr_data->[0][3], $ENV{'REMOTE_ADDR'} )){
  $status = 1;
	$hl{'user_id'} = $user_id = $usr_data->[0][0];
	
	# the user is verified

	if($hin{'ID'}){
	 
	 $hin{'product_id'} = $hin{'ID'};

	 my $r = &do_query("select product_id from product where product_id = ".&str_sqlize($hin{'ID'}));
	 if($r && $r->[0]){
	  $hin{'product_id'} = $r->[0][0];
	 } else {
	  $e_not_found = 1;
	 }

	 $req_type = 1;

	} elsif($hin{'Supplier_ID'} && $hin{'Prod_id'} ) {
	 
	 my $r = &do_query("select product_id from product where supplier_id = ".&str_sqlize(int($hin{'Supplier_ID'}))." and prod_id = ".&str_sqlize($hin{'Prod_id'}));

	 if($r && $r->[0]){
	  $hin{'product_id'} = $r->[0][0];
	 } else {
	  $e_not_found = 1;
	 }
	 
	 $req_type = 2;

	 # validating input

	 my $supp = &do_query("select supplier_id, name from supplier where supplier_id = ".&str_sqlize(int($hin{'Supplier_ID'})));
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
	 my $supp = &do_query("select supplier_id from supplier where name = ".&str_sqlize($hin{'Supplier'}));
	 unless($supp && $supp->[0]){
	  # supplier_id is wrong
		$e_supp_name = 1;
    $vfied_supplier_name	= $hin{'Supplier'};		
	 } else {
	  $vfied_supplier_id 		= $supp->[0][0];
    $vfied_supplier_name	= $hin{'Supplier'};
	 }


	 my $r = &do_query("select product_id from product where supplier_id = ".&str_sqlize($vfied_supplier_id)." and prod_id = ".&str_sqlize($hin{'Prod_id'}));

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
#	 &push_user_error("Please, check your request(code $code).");
	 &print_html("<font size=+3>Sorry, no information available about this product.<BR>Please, check your request(code $code).</font>");
	}	else {
		&atom_engine::launch_atom_engine();
	}
	&atom_engine::done_atom_engine();


 } else {
	$status = -1;
 }
 
	&atom_engine::html_finish(); 
	
	my $nowtime;
	

&insert_rows('request', 
			 { 
				 'user_id'				=> &str_sqlize($user_id),
				 'status'					=> $status,
				 'date'						=> &str_sqlize($nowtime = time),
				 'login'					=> &str_sqlize($login),
				 'ip'							=> &str_sqlize($ENV{'REMOTE_ADDR'})
			 });


my $req_id = &sql_last_insert_id();

   &insert_rows('request_product', { 'request_id'			=> $req_id,
																		 'rproduct_id'		=> &str_sqlize($hin{'product_id'}),
																		 'rprod_id'				=> &str_sqlize($hin{'Prod_id'}),
																		 'rsupplier_id'		=> &str_sqlize($vfied_supplier_id),
																		 'rsupplier_name'	=> &str_sqlize($vfied_supplier_name),
																		 'code'						=> $code,
																		 'product_found'	=> &str_sqlize($e_not_found^1)
																	 });	 


	
}

sub log_xml_request
{
my ($request_id, $user_id, $status, $nowtime, $login) = @_;

&insert_rows('request', 
			 { 
				 'ext_request_id' => &str_sqlize($request_id),
				 'user_id'				=> &str_sqlize($user_id),
				 'status'					=> $status,
				 'date'						=> &str_sqlize($nowtime = time),
				 'login'					=> &str_sqlize($login),
				 'ip'							=> &str_sqlize($ENV{'REMOTE_ADDR'})
			 });

return &sql_last_insert_id;
}

sub state_product_request
{
my ($request_id, $rproduct_id, $rprod_id, $rsupplier_id, $rsupplier_name, $code, $product_found) = @_;
   &insert_rows('request_product', { 'request_id'			=> $request_id,
																		 'rproduct_id'		=> &str_sqlize($rproduct_id),
																		 'rprod_id'				=> &str_sqlize($rprod_id),
																		 'rsupplier_id'		=> &str_sqlize($rsupplier_id),
																		 'rsupplier_name'	=> &str_sqlize($rsupplier_name),
																		 'code'						=> $code,
																		 'product_found'	=> &str_sqlize($product_found)
																	 });	 
return &sql_last_insert_id;
}

sub describe_products_xml
{

my ($result_hash, $destination, $catid, $f) = @_;

 # now describing each of result arr element 
	my $where 		= ' 0 ';
	my $datas;	
	
#	foreach my $product_id(@$result_arr){
#		$where .= " or product_id = ".&str_sqlize($product_id);
#  }

#	$datas = &do_query("select product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic from product, supplier where product.supplier_id = supplier.supplier_id and (".$where." )");
	$datas = &do_query("select product_id, prod_id, product.supplier_id, supplier.name, product.catid, product.name, product.low_pic, high_pic, product.thumb_pic from product, supplier where product.supplier_id = supplier.supplier_id");
	my $fdatas = [];
	foreach my $row(@{$datas}){
	 if($result_hash->{$row->[0]}){
	  push @$fdatas, $row;
	 }
	}
  $datas = $fdatas;

#	my $des_data = &do_query("select short_desc, product_description_id, langid, product_id from product_description as vocabulary where ($where) and ($f)");	 
	my $des_data = &do_query("select short_desc, product_description_id, langid, product_id from product_description as vocabulary where ($f)");	 
  my $des_data_hash = {};
  foreach my $row(@$des_data){
	 if($result_hash->{$row->[0]}){
		 push @{$des_data_hash->{$row->[3]} }, $row; 
	 }
	}

	my $cat_data = &do_query("select vocabulary.value, vocabulary.record_id, vocabulary.langid from category, vocabulary where vocabulary.sid = category.sid and ($f) and category.catid = ".&str_sqlize($catid));

	foreach my $data(@$datas){
	  my $product_id = $data->[0];
  
	  next if(!defined $data || !defined $data->[0]);
		my $pcode = 1;

# stating request
#	  &state_product_request($rh->{'ID'}, $product_id, $data->[1], $data->[2], $data->[3], $pcode, 1);
	 
		my $row = $data;
	 
		$destination->{$row->[0]}->{'Code'} = $pcode;

# building cats	for product

		my $cat_content = [];
		foreach my $cat_row(@$cat_data){
	 		push @$cat_content, { 'ID'			=> $cat_row->[1],
																		  'content'	=> $cat_row->[0],
																			'langid'	=> $cat_row->[2] } ;
		}

# building product_description entries
		my $des_content = [];
		foreach my $des_row(@{$des_data_hash->{'product_id'}}){
			push @$des_content, {  "ShortDesc" 		=> { 'content' => $des_row->[0]},
													 "ID"						=> $des_row->[1],
													 "langid"				=> $des_row->[2]};		
		}
	 
		$destination->{$row->[0]}->{'Prod_id'} = $row->[1];
		$destination->{$row->[0]}->{'Supplier'} = {'ID' => $row->[2], 'content' => $row->[3] };
		$destination->{$row->[0]}->{'Category'} = { 'ID' => $row->[4], 'Names' =>  { 'Name' => $cat_content }};
		$destination->{$row->[0]}->{'Name'} = { 'content' => $row->[5]};
		$destination->{$row->[0]}->{'LowPic'} = { 'content' => $row->[6] };
		$destination->{$row->[0]}->{'HighPic'} = { 'content' => $row->[7] };
		$destination->{$row->[0]}->{'ThumbPic'} = { 'content' => $row->[8] };
		$destination->{$row->[0]}->{'ProductDescriptions'} = { 'ProductDescription' => $des_content };
	}

}

1;

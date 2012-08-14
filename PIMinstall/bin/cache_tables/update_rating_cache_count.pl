#!/usr/bin/perl

use lib "/home/pim/lib";
use Data::Dumper;
use Time::HiRes;
my $time_start = Time::HiRes::time();
use atomsql;
use atomcfg;
use strict;
use utf8;
use atom_misc;

my $sessid=make_code(48);
while(-e $atomcfg{'session_path'}.'.'.$sessid){
	$sessid=make_code(48);	
}
my $sess_path=$atomcfg{'session_path'}.'.'.$sessid;
open(SESS,'>',$sess_path);
&do_statement('INSERT INTO session SET code='.str_sqlize($sessid).', updated=unix_timestamp()');
print SESS '
search_atom=
product_search_start_row=
s_order_products_products_mode=
search_from_day=1
s_order_product_search_param=
search_to_month=1
mi=products
clipboard_object_type=
products_header_start_row=
products_start_row=
atom_name=
s_order_products_products=prod_id
search_from_month=1
search_from_year=2001
search_to_year=2011
search_to_day=11
s_order_product_search_param_mode=
deep_search=
search_period=1
!auth_product_id=
!permanent_list=mi
!_saved_values=
!langid=1
!hl_permanent_list=user_id
!auth_submit_product_id=
!auth_submit_cproduct_id=
!user_id=10962
!sesscode='.$sessid.'
';
close(SESS);
`chmod 666 $atomcfg{'session_path'}.$sessid`;
`wget --user=alexeylav --password=ghbrjkgfhjkm '$atomcfg{'bo_host'}index.cgi?search_status=&search_prod_id=&search_product_name=&search_ssupplier_id=&search_catid_old=1&search_catid=1&search_catid_name=Any+category&search_catid_selected=0&search_catid_value_selected=&search_country_id=&search_distributor_id=&search_owner_id=&search_onstock=0&search_onmarket=0&new_search=Submit+Query&sessid=$sessid&search_atom=products_raiting&tmpl=products_raiting.html&search_product_name_mode=like&search_prod_id_mode=like&new_search=1' -O /tmp/dummy_ratting_cache`;
`wget --user=alexeylav --password=ghbrjkgfhjkm '$atomcfg{'bo_host'}index.cgi?sessid=$sessid&tmpl=products_raiting.html&mi=products_raiting&reset_search=1' -O /tmp/dummy_ratting_cache.html`;


print "\n---------->".(Time::HiRes::time()-$time_start);

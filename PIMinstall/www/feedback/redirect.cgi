#!/usr/bin/perl

#$Id$

use lib '/home/pim/lib';
#use lib '/home/dima/gcc_svn/lib';

use strict;

use atomcfg;
use atomlog;
use atomsql;
use atom_engine;
use atom_html;
use atom_util;
use atom_misc;

#open new session
&html_start();
$hin{'sessid'} = $sessid;
#$jump_to_location = "http://icecat.demo.iceshop.nl/index.cgi?sessid=$sessid";

#select data for autentification by uniq. key (120 char)
my $kdata = &do_query("select phk.user_id, phk.product_id, phk.html_key, u.login, u.password

from  product_html_key phk
left  join product p            using (product_id)
left  join supplier s           using (supplier_id)
inner join users u              on phk.user_id=u.user_id

where phk.html_key = \"$hin{'key'}\"");

if (!$kdata->[0]) {
	&log_printf("USER autentification failed while redirected");
	&html_finish();
	exit;
}

$jump_to_location = $atomcfg{'bo_host'}."index.cgi?sessid=$sessid";
my ($l, $p) = (&escape($kdata->[0][3]), &escape($kdata->[0][4]));
$jump_to_location =~ s/^(https?:\/\/)(.*)$/$1$l\:$p\@$2/;

#to define user
$hout{'user_id'} = $kdata->[0][0];
$hs{'user_id'} = $hout{'user_id'};
$hl{'hl_permanent_list'} = "user_id";
$hs{'hl_permanent_list'} = "user_id";

#get action by the key
my $action = &do_query("select action from product_html_key where html_key = \"$hin{'key'}\"");

#redirection due the action
&log_printf("\n\n$action->[0][0]");

if ($action->[0][0] eq 'publish_product') {
	&update_rows("product", "product_id =".$kdata->[0][1], {'publish' => &str_sqlize('A')});
	$jump_to_location = '';
	my $content = &load_template("approve.html", 1);
	&print_html($content);
# &html_finish();
	$hout{'product_id'} = $kdata->[0][1];
}

if ($action->[0][0] eq 'edit_product') {
	$hout{'atom_name'} = 'product';
	$hout{'tmpl'} = 'product_details.html';
	$hout{'product_id'} = $kdata->[0][1];
}

if ($action->[0][0] eq 'send_product_complaint') {
	$hout{'atom_name'} = 'product_post_complain';
	$hout{'tmpl'} = 'product_post_complain.html';
	$hout{'product_id'} = $kdata->[0][1];
}
if ($action->[0][0] =~ /^add_brand/) {
	$hout{'atom_name'} = 'supplier';
	$hout{'tmpl'} = 'supplier_edit.html';
	my $extra = $action->[0][0];
	$extra =~ s/^[^;]+//;

	my @params = split /;/, $extra;

	foreach my $param (@params) {
		$param =~ /^(.+?)=(.*)$/;
		$hout{$1} = $2;
	}	

	$hs{'auth_add_supplier_id'} = 0;
	$hs{'auth_supplier_id'} = 0;
	$hs{'auth_submit_supplier_id'} = 'supplier_id';

	&html_finish();
	exit;
}
if ($action->[0][0] =~ /^link_brand_and_user/) {
	$hout{'atom_name'} = 'supplier';
	$hout{'tmpl'} = 'supplier_edit.html';
	my $extra = $action->[0][0];
	$extra =~ s/^[^;]+//;

	my @params = split /;/, $extra;

	foreach my $param (@params) {
		$param =~ /^(.+?)=(.*)$/;
		$hout{$1} = $2;
	}

	$hs{'auth_add_supplier_id'} = $hout{'supplier_id'};
	$hs{'auth_supplier_id'} = $hout{'supplier_id'};
	$hs{'auth_submit_supplier_id'} = 'supplier_id';

	log_printf($jump_to_location);

	&html_finish();
	exit;
}

log_printf($jump_to_location);

$hs{'auth_product_id'} = $hout{'product_id'};
$hs{'auth_product_description_id'} = $hout{'product_description_id'};
$hs{'auth_product_feature_id'} = 'product_feature_id';

$hs{'auth_add_product_id'} = $hout{'product_id'};
$hs{'auth_add_product_description_id'} = $hout{'product_description_id'};
$hs{'auth_add_product_feature_id'} = 'product_feature_id';

$hs{'auth_submit_product_id'} = $hout{'product_id'};
$hs{'auth_submit_product_description_id'} = $hout{'product_description_id'};
$hs{'auth_submit_product_feature_id'} = 'product_feature_id';


#&delete_rows("product_html_key", "html_key = \"$hin{'key'}\"");

&html_finish();

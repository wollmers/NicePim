#!/usr/bin/perl

#$Id: do.cgi 2550 2010-05-11 16:14:46Z dima $

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';

use strict;

use atom_engine;
use atom_html;
use atomcfg;
use atomlog;
use atomsql;
use atom_util;
use atom_misc;

use Crypt::Lite;

&html_start();

my $crypt = Crypt::Lite->new( debug => 0, encoding => 'hex8' );

# make clickthrough for campaign products and go to the landing page
# encrypted value is product_id
$hin{'campaign'} = $hin{'campaign_product'} unless $hin{'campaign'};
if ($hin{'campaign'}) {
	my $phrase = 'ICEcat.biz is a cool catalogue!';
	my $product_id = $crypt->decrypt($hin{'campaign'}, $phrase);

	my $link = &do_query("select c.link from campaign c inner join campaign_kit ck using (campaign_id) where ck.product_id=".$product_id)->[0][0];

	if ($link =~ /(ht|f)tps?:\/\//) {
		$link =~ s/^.*((ht|f)tps?:\/\/)/$1/;
	}

	if ($link) {
		&do_statement("update campaign_kit set clickthrough_count=clickthrough_count+1 where product_id=".$product_id);
		$link = 'http://'.$link if $link !~ /^(ht|f)tps?:\/\//i;
		$jump_to_location = $link;
	}
}

# redirect to users page
# encrypted value is user_id
if ($hin{'login'}) {
	my $phrase = 'WP2s2xvj03wrmonETy0PwFYunsNA144c06AQ';
	my $user_id = $crypt->decrypt($hin{'login'}, $phrase);

	my $user = &do_query("select user_id, login, password from users where user_id=".$user_id." limit 1")->[0];
	if (($user_id) && ($user_id =~ /^\d+$/) && ($user->[0])) {
		my $link = $atomcfg{'bo_host'};
		$link =~ s/^(http:\/\/)(.*)$/$1$user->[1]:$user->[2]\@$2/;
		$jump_to_location = $link.'index.cgi?sessid='.$sessid.';tmpl=user_edit.html;edit_user_id='.$user_id;
		$hs{'user_id'} = $user_id;
		$hs{'auth_edit_user_id'} = $user_id;
		$hs{'auth_submit_edit_user_id'} = $user_id;
		$hs{'sesscode'} = $sessid;
		$hs{'langid'} = 1;
		$hout{'mi'} = 'users';
	}
}

# unsubscribe from mailnews
# encrypted value is user_id

if ($hin{'unsubscribe'}) {
	my $phrase = 'yuiNsAEoj97dKMYrDN3t';
	my $user_id = $crypt->decrypt($hin{'unsubscribe'}, $phrase);

	if (($user_id eq int($user_id)) && (&do_query("select user_id from users where user_id=".$user_id)->[0][0])) {
		my $contact_id = &do_query("select pers_cid from users where user_id=".$user_id)->[0][0];
		if ($contact_id) {
			&do_statement("update contact set email_subscribing='N' where contact_id=".$contact_id);
		}
		my $content = &load_template("mail_dispatch_unsubscribe.html", 1);
		&print_html(&repl_ph($content,{
			'person' => &do_query("select person from contact where contact_id=".$contact_id)->[0][0],
			'icecat_current_year' => &do_query('select year(now())')->[0][0],
			'icecat_company_name' => $atomcfg{'company_name'}
												 }));
	}
}

&html_finish();

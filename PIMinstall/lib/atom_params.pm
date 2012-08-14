package atom_params;

 #$Id: atom_params.pm 3787 2011-02-04 09:29:54Z vadim $

use strict;
use atom_html;
use atomlog;
use atom_util;
use atom_misc;
use atomsql;
use coverage_report;
use atomcfg;
use atom_mail;
use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw( &prepare_params_unifiedly
			  				&proc_prepare_params_dummy
								&proc_prepare_params_product_search
								&proc_prepare_params_category
								&proc_prepare_params_categories
								&proc_prepare_params_features_search
								&proc_prepare_params_category_feature_compare
								&proc_prepare_params_category_features_search
								&proc_prepare_params_categories_search
								&proc_prepare_params_products_raiting
								&proc_prepare_params_suppliers
								&proc_prepare_params_products_complaint
								&proc_prepare_params_products
								&proc_prepare_params_products_header
								&proc_prepare_params_families
								&proc_prepare_params_family
								&proc_prepare_params_products_raiting_search
								&proc_prepare_params_users
								&proc_prepare_params_product_group_actions_list
								&proc_prepare_params_editor_journal_searchs
								&proc_prepare_params_editor_journal_list
								&proc_prepare_params_editor_journal_edit
								&proc_prepare_params_feature_value_search
								&proc_prepare_params_feature_values_vocabulary
								&proc_prepare_params_feature_values
								&proc_prepare_params_measure_power_mapping
								&proc_prepare_params_dashboard
								&proc_prepare_params_quicktest
								&proc_prepare_params_mail_dispatch

&proc_prepare_params_product_supplier_choose_ajax
&proc_prepare_params_product_supplier_family_choose_ajax
&proc_prepare_params_product_category_choose_ajax
&proc_prepare_params_product_category_choose_as_list_ajax
&proc_prepare_params_product_feature_choose_ajax
&proc_prepare_params_stat_query
&proc_prepare_params_price_reports
&proc_prepare_params_users_search
&proc_prepare_params_data_sources
&proc_prepare_params_campaigns

&proc_prepare_params_brand_invalid_partnumbers
&proc_prepare_params_feed_config
&format_as_radio
&proc_prepare_params_feed_pricelist
&proc_prepare_params_feed_coverage

&proc_prepare_params_feature_utilizing_products_categories

&proc_prepare_params_sectors
&proc_prepare_params_sector
&proc_prepare_params_track_list

&proc_prepare_params_virtual_categories

&proc_prepare_params_default_warranty_info
&proc_prepare_params_default_warranty_info_edit

&proc_prepare_params_track_products
&proc_prepare_params_track_list_settings
&proc_prepare_params_track_lists
&proc_prepare_params_track_products_all
&proc_prepare_params_ajax_track_list_editors

proc_prepare_params_product_restrictions_details
proc_prepare_params_product_restrictions
&proc_prepare_params_track_list_graph
&proc_prepare_params_backup_language_config
&proc_prepare_params_product_rating_conf
&proc_prepare_params_products_raiting_search
);
}


sub proc_prepare_params_product_rating_conf{
	my ($atom,$call) = @_;
	my $hash={'superuser'=>1};
 	unless($hash->{$USER->{'user_group'}}){
 			push(@user_errors,'You are not authorized to view this page');
 			hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
 			return '';
 	}
 	&prepare_params_unifiedly($atom,$call);	
}

sub proc_prepare_params_track_list_graph{
	my ($atom,$call) = @_;
	my $hash={'superuser'=>1,'supereditor'=>1};
 	unless($hash->{$USER->{'user_group'}}){
 			push(@user_errors,'You are not authorized to view this page');
 			hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
 			return '';
 	}
 	&prepare_params_unifiedly($atom,$call);	
}

sub proc_prepare_params_backup_language_config{
	my ($atom,$call) = @_;
	my $hash={'superuser'=>1,'supereditor'=>1};
 	unless($hash->{$USER->{'user_group'}}){
 			push(@user_errors,'You are not authorized to view this page');
 			hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
 			return '';
 	}
 	&prepare_params_unifiedly($atom,$call);	
}

sub proc_prepare_params_feed_coverage{
	my ($atom,$call) = @_;
	$hs{'feed_coverage_deleted'}=$hl{'feed_coverage_deleted'}; 
 	$hs{'feed_coverage_dublicates'}=$hl{'feed_coverage_dublicates'};
 	$hs{'coverage_summary'}=$hl{'coverage_summary'};
	&prepare_params_unifiedly($atom,$call);
}

# AJAX

sub proc_prepare_params_product_supplier_family_choose_ajax {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	$call->{'call_params'}->{'additional_condition'} = '';
	
	if (($hin{'catid'}) && ($hin{'catid'} =~ /^\d+$/)) {
		$call->{'call_params'}->{'additional_condition'} = ' and catid='.$hin{'catid'};
	}
} # sub proc_prepare_params_product_supplier_family_choose_ajax

sub proc_prepare_params_product_supplier_choose_ajax {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	$call->{'call_params'}->{'additional_join'} = '';
	
	if (($hin{'catid'}) && ($hin{'catid'} =~ /^\d+$/)) {
		$call->{'call_params'}->{'additional_join'} = 'inner join product p using (supplier_id) where p.catid='.$hin{'catid'};
	}

	if ($hin{'prod_id'} ne '') {
		# choose the 1st supplier
		if ($hin{'supplier_id'} ne '') {
			$call->{'call_params'}->{'supplier_id'} = &do_query("select supplier_id from product where prod_id=".&str_sqlize($hin{'prod_id'})." limit 1")->[0][0];
		}
		$call->{'call_params'}->{'additional_join'} = ' inner join product p using (supplier_id) where p.prod_id='.&str_sqlize($hin{'prod_id'});
	}

#	&log_printf(Dumper($call->{'call_params'}));

} # sub proc_prepare_params_product_supplier_choose_ajax

sub proc_prepare_params_product_category_choose_ajax {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	$call->{'call_params'}->{'additional_join'} = '';
} # sub proc_prepare_params_product_category_choose_ajax

sub proc_prepare_params_product_category_choose_as_list_ajax {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	$call->{'call_params'}->{'additional_join'} = '';
	$call->{'call_params'}->{'additional_condition'} = '';
	
	if (($hin{'supplier_id'}) && ($hin{'supplier_id'} =~ /^\d+$/)) {
		$call->{'call_params'}->{'additional_join'} .= ' inner join product p using (catid)';
		$call->{'call_params'}->{'additional_condition'} .= ' and p.supplier_id='.$hin{'supplier_id'};
		if ($hin{'supplier_family_id'} > 1) {
			$call->{'call_params'}->{'additional_join'} .= ' inner join product_family pf using (catid)';
			my $children_arr = &get_family_children_list($hin{'supplier_family_id'});
			$call->{'call_params'}->{'additional_condition'} .= ' and pf.family_id in ('.(join(',',@$children_arr)).')';
		}
	}
} # sub proc_prepare_params_product_category_choose_as_list_ajax

sub proc_prepare_params_product_feature_choose_ajax {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	$call->{'call_params'}->{'additional_join'} = '';
	
	if (($hin{'catid'}) && ($hin{'catid'} =~ /^\d+$/)) {
		$call->{'call_params'}->{'additional_join'} = ' inner join category_feature cf using (feature_id) where cf.catid='.$hin{'catid'};
	}
} # sub proc_prepare_params_product_feature_choose_ajax

# General

sub proc_prepare_params_feature_utilizing_products_categories {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);
	
	&do_statement("create temporary table `tmp_feature_prod` (
`value`              varchar(20000) NOT NULL default '',
`value60`            varchar(60)    NOT NULL default '',
`user_id`            int(13)        NOT NULL default '1',
`product_id`         int(13)        NOT NULL default '0',
`prod_id`            varchar(60)    NOT NULL default '',
`name`               varchar(255)   NOT NULL default '',
`name60`             varchar(60)    NOT NULL default '',
`catid`              int(13)        NOT NULL default '0',
`vocabulary_value`   varchar(255)   default NULL,
`vocabulary_value60` varchar(60)    default NULL,
`feature_id`         int(13)        NOT NULL default '0',
key (feature_id),
key sorting_index (vocabulary_value60,name60,value60,prod_id))");

	&do_statement("insert into `tmp_feature_prod` select pf.value, pf.value, p.user_id, p.product_id, p.prod_id, s.name, s.name, cf.catid, cat_name.value, cf.feature_id, cf.feature_id
from category c
inner join vocabulary cat_name on cat_name.sid = c.sid and cat_name.langid = ".&str_sqlize($call->{'call_params'}->{'langid'})."
inner join category_feature cf on c.catid = cf.catid
inner join product p on cf.catid = p.catid
inner join supplier s on s.supplier_id = p.supplier_id
inner join product_feature pf on pf.product_id = p.product_id and pf.category_feature_id = cf.category_feature_id
where cf.feature_id = ".&str_sqlize($call->{'call_params'}->{'feature_id'})." and pf.value <> ''");

} # sub proc_prepare_params_feature_utilizing_products_categories

sub proc_prepare_params_brand_invalid_partnumbers {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	return;
#	use icecat_mapping;

	# complete the new table for processing

	my $table_name = "brand_invalid_partnumbers";
	my $file_name = "/tmp/prod_prepare_params_brand_invalid_partnumbers_".&make_code(32);

	&do_statement("drop table if exists tmp_".$table_name."_new");
	&do_statement("create table tmp_".$table_name."_new (product_id int(13) not null default 0)");

	my $checks = &do_query("select p.product_id, p.prod_id, p.supplier_id from product p inner join supplier s using (supplier_id) where trim(prod_id_regexp) != ''");

	open TMP, ">".$file_name;
	binmode TMP, ":utf8";

	foreach (@$checks) {
		unless (&brand_prod_id_checking_by_regexp($_->[1],{'supplier_id' => $_->[2]})) {
			print TMP $_->[0].",";
		}
	}

	close TMP;

	&do_statement("load data local infile '".$file_name."' into table tmp_".$table_name."_new lines terminated by ','");

	`/bin/rm -f $file_name`;

	&do_statement("drop table if exists tmp_".$table_name);
	&do_statement("rename table tmp_".$table_name."_new to tmp_".$table_name);
} # sub proc_prepare_params_brand_invalid_partnumbers

sub prepare_params_unifiedly {
#
# this should fill hash $call->{'call_params'}
#
	
	my ($atom,$call) = @_;
	
	foreach my $key (keys %hin) {
		if ($hin{$key.'_ignore_unifiedly_processing'}) {
			$call->{'call_params'}->{$key} = $hin{$key};
		}
		else {
			$call->{'call_params'}->{$key} = &str_htmlize($hin{$key});
		}
	}

	foreach my $key (keys %hl) {
		$call->{'call_params'}->{$key} = &str_htmlize($hl{$key});
	}  
	
	$call->{'call_params'}->{'user_id'} = &str_htmlize($USER->{'user_id'});
}

sub proc_prepare_params_campaigns {
  my ($atom, $call) = @_;
	
	&prepare_params_unifiedly($atom,$call);

	if ($USER->{'user_group'} eq 'supplier') {
		$call->{'call_params'}->{'user_clause'} = 'user_id = '.$USER->{'user_id'};
	}
	elsif ($USER->{'user_group'} eq 'superuser') {
		$call->{'call_params'}->{'user_clause'} = '1';
	}
	else {
		$call->{'call_params'}->{'user_clause'} = '0';
	}

} # sub proc_prepare_params_campaigns

sub proc_prepare_params_categories_search
{
    my ($atom, $call) = @_;
    $call->{'call_params'}->{'search_name'} = &str_sqlize($hin{'search_name'});
}

sub prepare_date_params
{
 my($d,$m,$y,$wd)=(localtime(time))[3..7];
 $m++; $y+=1900;

 if(!$hin{'search_period'}) {$hin{'search_period'}=1;}
 if(!$hin{'search_from_year'}) {$hin{'search_from_year'}=2001;}
 if(!$hin{'search_from_month'}) {$hin{'search_from_month'}=1;}
 if(!$hin{'search_from_day'}) {$hin{'search_from_day'}=1;}
 if(!$hin{'search_to_year'}) {$hin{'search_to_year'}=$y;}
 if(!$hin{'search_to_month'}) {$hin{'search_to_month'}=$m;}
 if(!$hin{'search_to_day'}) {$hin{'search_to_day'}=$d;}

 if($hin{'search_period'}==5){ ## last day
	$hin{'search_from_year'}=$y;
	$hin{'search_from_month'}=$m;
	$hin{'search_from_day'}=$d;
 }
 if($hin{'search_period'}==2){ ## last week
	$wd=7 if(!$wd); $wd--; ## 0 = monday
	my($fd,$fm,$fy)=(localtime(time-$wd*24*60*60))[3..6];
	$hin{'search_from_year'}=$fy+1900;
	$hin{'search_from_month'}=$fm+1;
	$hin{'search_from_day'}=$fd;
 }
 if($hin{'search_period'}==3){ ## last month
	$hin{'search_from_year'}=$y;$hin{'search_from_month'}=$m;$hin{'search_from_day'}=1;
 }
 if($hin{'search_period'}==4){ ## last quarter
	my $fqm = int(($m-1)/3)*3+1;
	$hin{'search_from_year'}=$y;$hin{'search_from_month'}=$fqm;$hin{'search_from_day'}=1;
 }
}

sub proc_prepare_params_product_search {
	my ($atom,$call) = @_;
	
	&prepare_params_unifiedly($atom,$call);
	$hin{'search_product_name'} = $hin{'search_prod_id'};
	$hout{'search_atom'} = $hin{'search_atom'};

	&prepare_date_params;
	
	foreach my $item ('search_supplier_id','search_catid','search_product_name','search_prod_id','search_edit_user_id','search_adv', 'search_to_year', 'search_to_month', 'search_to_day', 'search_from_year', 'search_from_month', 'search_from_day', 'search_period') {
		
		# trailing spaces
		
		$hin{$item} =~ s/^\s*(.*?)\s*$/$1/gs;
		
		if (!$hin{$item}) {
			$call->{'call_params'}->{$item} = '\'\'';
		}
		else {
			$call->{'call_params'}->{$item} = &str_htmlize(&str_sqlize($hin{$item}));

			# storing for a next session
			$hout{$item} = $hin{$item};
		}
	}

} # sub proc_prepare_params_product_search

sub proc_prepare_params_features_search {
 my ($atom,$call) = @_;
 
&prepare_params_unifiedly($atom,$call);


 foreach my $item('search_name'){

	 # trailing spaces

	 $hin{$item} =~s/^\s+(.*)/$1/g;
	 $hin{$item} =~s/(.*)\s+\Z/$1/g;

  if(!$hin{$item}){
   $call->{'call_params'}->{$item} = '\'\'';
	} else {
	  $call->{'call_params'}->{$item} = &str_sqlize($hin{$item});
	}
 }

}

sub proc_prepare_params_category_features_search
{
 my ($atom,$call) = @_;
 &proc_prepare_params_features_search($atom,$call);
}


sub proc_prepare_params_categories 
{
    my ($atom,$call) = @_;

    if (!$hin{'pcatid'}){ $hin{'pcatid'} = '1'; }
    $hout{'pcatid'} = $hin{'pcatid'};

    if (!$hin{'new_search'}) {
	$call->{'call_params'}->{'pcatid_clause'} = " pcatid = $hin{'pcatid'} ";
    } else {
	$call->{'call_params'}->{'pcatid_clause'} = '1';
    }

    &prepare_params_unifiedly($atom,$call);
}

sub proc_prepare_params_category
{
    my ($atom,$call) = @_;
    $hout{'pcatid'} = $hin{'pcatid'};
    
    &prepare_params_unifiedly($atom,$call);
}

sub proc_prepare_params_category_feature_compare {
	my ($atom,$call) = @_;
	
	&prepare_params_unifiedly($atom,$call); 
	my $order = [];
	
	# building correct category feature order
	my $catid = &str_sqlize($hin{'catid'});
	
	my $header = '';
	
	my $data = &do_query("select category_feature_id, feature_name.value, feature.class from category_feature, feature, vocabulary as feature_name where category_feature.catid = $catid and feature.feature_id = category_feature.feature_id and feature_name.sid = feature.sid and feature_name.langid = $hl{'langid'} order by feature.class, feature_name.value");

	foreach my $row(@$data){
		push @$order, $row->[0];
		$header	.= &repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{'category_feature_entry_format_'.$row->[2]},
												{ "name" => $row->[1] }); 
	}
	
	$call->{'call_params'}->{'category_features_header'} = $header;
	$call->{'call_params'}->{'category_feature_order'} = $order;
}

sub proc_prepare_params_products_raiting {
	my ($atom,$call) = @_;

	$call->{'call_params'}->{'additional_values'} = "";
	$call->{'call_params'}->{'additional_joins'} = '';
	$hin{'search_product_name'} = $hin{'search_prod_id'};

	# distributor_id
	if ($hin{'search_distributor_id'}) {
		&do_statement("create temporary table itmp_distributor_product like distributor_product");
		&do_statement("insert into itmp_distributor_product(product_id,stock,dist_prod_id,distributor_id)
select product_id, max(stock), dist_prod_id, distributor_id from distributor_product where distributor_id=".$hin{'search_distributor_id'}." group by product_id");
		
		$call->{'call_params'}->{'additional_joins'} .= "
left  join itmp_distributor_product dp on pis.product_id=dp.product_id ".($hin{'search_onstock'}?"and dp.stock > 0":"")." ".($hin{'search_onmarket'}?"and dp.active > 0":"")."
left  join distributor d using (distributor_id)";
		$call->{'call_params'}->{'additional_values'} .= ", dp.product_id, dp.distributor_id";
	}
	else {
		$call->{'call_params'}->{'additional_values'} .= ", pis.product_id, 0";
	}

	# country_id
	if ($hin{'search_country_id'}) {
		if ($hin{'search_distributor_id'}) {
			$call->{'call_params'}->{'additional_joins'} .= "
left  join country cnt using (country_id)
inner join vocabulary vcnt on cnt.sid=vcnt.sid and vcnt.langid=1";
			$call->{'call_params'}->{'additional_values'} .= ", cnt.country_id, vcnt.value";
		}
		else {
			$call->{'call_params'}->{'additional_joins'} .= "
left  join country_product cp on pis.product_id=cp.product_id ".($hin{'search_onstock'}?"and cp.stock > 0":"")." ".($hin{'search_onmarket'}?"and cp.active > 0":"")."
left  join country cnt using (country_id)
inner join vocabulary vcnt on cnt.sid=vcnt.sid and vcnt.langid=1";
			$call->{'call_params'}->{'additional_values'} .= ", cnt.country_id, vcnt.value";
		}
	}
	else {
		unless ($hin{'search_distributor_id'}) {
#			&do_statement("create temporary table itmp_country_product like country_product");
#			&do_statement("insert into itmp_country_product(product_id,stock,active)
#select product_id, max(stock), max(active) from country_product group by product_id");

			$call->{'call_params'}->{'additional_joins'} .= "
left  join product_active pa on pis.product_id=pa.product_id ".($hin{'search_onstock'}?"and pa.stock > 0":"")." ".($hin{'search_onmarket'}?"and pa.active > 0":"");
		}
		$call->{'call_params'}->{'additional_values'} .= ", 0, ''";
	}
} # sub proc_prepare_params_products_raiting

sub proc_prepare_params_suppliers {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);
	$hin{'family_id'} = 1;
	$hout{'family_id'} = $hin{'family_id'};
} # sub proc_prepare_params_suppliers

sub proc_prepare_params_products_complaint {
	my ($atom,$call) = @_;
	if(!$hin{'new_search'} && !$hin{'product_id'} && ($USER->{'user_group'} ne "superuser") && ($USER->{'user_group'} ne "supereditor")) {
		$call->{'call_params'}->{'_resource_complaint_def_search'} = " pc.user_id = $USER->{'user_id'} and pc.complaint_status_id = 1";
	}
	if(!$hin{'see'}) {
		$call->{'call_params'}->{'product_id'} = '%';
	} else {
		$call->{'call_params'}->{'product_id'} = $hin{'product_id'};
	}
}

sub proc_prepare_params_stat_query{
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);

	if (($USER->{'user_group'} eq "superuser") || ($USER->{'user_group'} eq "supereditor")) {
		$hin{'stock_reports'} = "Stock reports";
        }else{
		$hin{'stock_reports'} = "";
        }

}

sub proc_prepare_params_data_sources{
	my ($atom,$call) = @_;
        &prepare_params_unifiedly($atom,$call);

        if (($USER->{'user_group'} eq "superuser") || ($USER->{'user_group'} eq "supereditor")) {
                $hin{'price_reports'} = "Price reports";
        }else{
                $hin{'price_reports'} = "";
        }

}

sub proc_prepare_params_price_reports{
        my ($atom,$call) = @_;
        &prepare_params_unifiedly($atom,$call);

        if ($hin{'distri_code'}) {
                $hin{'ex_distri_checked'} = ' checked="checked" ';
        }else{
                $hin{'ex_distri_checked'} = "";
        }

	if($hin{'pl_login'}){
		$hin{'auth_checked'} = ' checked="checked" ';
	}else{
		$hin{'auth_checked'} = '';
	}

}

sub proc_prepare_params_products_header {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	# show / hide submenus
	if (($USER->{'user_group'} eq "supplier") || ($USER->{'user_group'} eq "guest")) {
		$call->{'call_params'}->{'product_maps'} = "";
		$call->{'call_params'}->{'product_relations'} = "";
		$call->{'call_params'}->{'brand_invalid_partnumbers'} = "";
	}
	else {
		$call->{'call_params'}->{'product_maps'} = '<span><a href="%%base_url%%;tmpl=product_maps.html" class="linkmenu3">Product maps</a></span>';
		$call->{'call_params'}->{'product_relations'} = '<span><a href="%%base_url%%;tmpl=relation_groups.html" class="linkmenu3">Product relations</a></span>';
		$call->{'call_params'}->{'brand_invalid_partnumbers'} = '<span><a href="%%base_url%%;tmpl=brand_invalid_partnumbers.html" class="linkmenu3">Invalid partnumbers</a></span>';
	}

	# get the filter info from products prepare params (do not str_htmlize it)
	$call->{'call_params'}->{'filter_flag'} = $hin{'filter_flag'};
	$hin{'filter_flag'} = '';
	
	# quicktest
	if (($USER->{'user_group'} eq "superuser") && ($USER->{'login'} eq 'root')) {
		$call->{'call_params'}->{'admin'} = '<a href="%%base_url%%;tmpl=quicktest.html" style="color: red;">Quicktest</a>';
	}

} # sub proc_prepare_params_products_header

sub proc_prepare_params_products {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	# init some tripped, cross-atom params
	my $xAtomFilterTables = [];

	# coverage filter
	
	if ($hin{'filter'} ne '') {
		$call->{'call_params'}->{'filter_tables'} = &prepare_coverage_filter($hin{'filter'});
		goto no_filter unless $call->{'call_params'}->{'filter_tables'};
		$call->{'call_params'}->{'filter_key'} = ';filter='.$hin{'filter'};
		$call->{'call_params'}->{'filter'} = &str_htmlize($hin{'filter'});
		$hin{'filter_flag'} = '<br /><span style="color: blue;">Filter: '.$hin{'filter_toString'}.'</span>&nbsp;&nbsp;&nbsp;'.
			"<a class=linkmenu2 href=\"/index.cgi?sessid=$hl{sesscode};mi=products;tmpl=products.html\">reset filter</a>";
		
		# push filter table to clipboard for clipboard products completion & processing via JS to products page
		push @$xAtomFilterTables, $call->{'call_params'}->{'filter_tables'};
	}
	else {
	no_filter:
		$call->{'call_params'}->{'filter_tables'} = '';
		$call->{'call_params'}->{'filter_key'} = '';
		$call->{'call_params'}->{'filter'} = '';
		$hin{'filter_flag'} = '';
	}

	# check seep_search
	$hin{'deep_search'} = '' if $hin{'deep_search'} ne '%';

	# restrictions

	my ($restrict);
	$restrict = '1 AND ';

	my $supp_uid = 0;	
	
	$supp_uid = $USER->{'user_id'} if $USER->{'user_group'} eq "supplier";

	if ($supp_uid) {
		my $supplier_ids = &do_query("select group_concat(supplier_id separator ',') from supplier where user_id=".$supp_uid." group by user_id")->[0][0];
		unless ($supplier_ids) {
			$restrict = "0 AND ";
		}
		else {
			$restrict = "p.supplier_id ". ( $supplier_ids =~ /,/ ? "in (".$supplier_ids.")" : "=".$supplier_ids ) . " AND ";
		}
	}
	
	if ($USER->{'user_group'} eq "guest") { # guest account
		$restrict .= 'p.supplier_id in (select supplier_id from supplier where is_sponsor="Y") AND ';
	}

	# prod_id + product name + ean search
	if ($hin{'search_product_name'} ne '') {
		# check the product_memory table
#		my $p_table = ( &do_query("show tables like 'product_memory'")->[0][0] && ( &do_query("select max(product_id) from product")->[0][0] eq &do_query("select max(product_id) from product_memory")->[0][0] ) ) ?
#			'product_memory' : 'product';
		my $p_table = 'product_memory';
		
		&do_statement("drop temporary table if exists itmp_product_search");
		&do_statement("create temporary table `itmp_product_search` (`product_id` int(13) not null primary key) ENGINE = MyISAM");
		if(!$hin{'deep_search'}){
			&do_statement("insert into `itmp_product_search`
	select `product_id` from `" . $p_table . "`
	where prod_id like " . &str_sqlize($hin{'search_product_name'} . "%"));
			&do_statement("insert ignore into `itmp_product_search`
	select `product_id` from `" . $p_table . "`
	where name    like " . &str_sqlize($hin{'search_product_name'} . "%"));
		}else{
			my $reverse_name=reverse($hin{'search_product_name'});
			&do_statement("insert into `itmp_product_search`
						  select `product_id` from product_words
						  where word 	 like ".&str_sqlize($hin{'search_product_name'}.'%')." OR 
						  		word_rev like ".&str_sqlize($reverse_name.'%').'
						  GROUP BY product_id');
			&do_statement("insert IGNORE into `itmp_product_search`
						  select `product_id` from product
						  where updated > (now() - 60*30) and 
						  		(name 	 like ".&str_sqlize('%'.$hin{'search_product_name'}.'%')." OR 
						  		prod_id like ".&str_sqlize('%'.$hin{'search_product_name'}.'%').')');									  
		}							
		if ($hin{'search_product_name'} =~ /^\d+$/) {
			&do_statement("insert ignore into `itmp_product_search` select `product_id` from `product_ean_codes`
where ".&str_sqlize($hin{'search_product_name'})." regexp '^[[:digit:]]+\$'
and trim(leading '0' from ean_code) = trim(leading '0' from ".&str_sqlize($hin{'search_product_name'}).")");
		}
#		&log_printf("--------------->>>>>>>>>>>>>".$call->{'call_params'}->{'inner_join'});
		
		$call->{'call_params'}->{'smart_search_tables'} = " inner join itmp_product_search ips on ips.product_id=p.product_id ";

		# push smart search table to clipboard for clipboard products completion & processing via JS to products page
		push @$xAtomFilterTables, $call->{'call_params'}->{'smart_search_tables'};
	}
	else {
		$call->{'call_params'}->{'smart_search_tables'} = '';
	}
		
	my $order = $hin{'order_products_products'};
	if (!$order) {
		$order = $call->{'call_params'}->{'order_products_products'};
	}
	if (!$order) {
		$order = $call->{'call_params'}->{'s_order_products_products'};
	}
	if (!$order) {
		$order='prod_id';
	}
	
	my ($tbl,$order_fields);
	
	if (($order eq 'prod_id') || ($order eq 'date_added')) {
		$tbl = "product p";
		$order_fields = "'','',''";
	}
	elsif ($order eq 'supp_name') {
		$tbl = "supplier s inner join product p on s.supplier_id=p.supplier_id";
		$order_fields = "s.name,'',''";
	}
	elsif ($order eq 'user_name') {
		$tbl = "users u inner join product p on u.user_id=p.user_id";
		$order_fields = "'',u.login,''";
	}
	elsif ($order eq 'cat_name') {
		$tbl = "vocabulary as cat_name inner join category c on cat_name.sid=c.sid and cat_name.langid=1 inner join product p on c.catid=p.catid";
		$order_fields = "'','',cat_name.value";
	}
	
	$call->{'call_params'}->{'order_tables'} = $tbl.' ';
	$call->{'call_params'}->{'order_fields'} = $order_fields;
	$call->{'call_params'}->{'restrict_clause'} = $restrict;

	$hin{'x-atom filter tables'} = $xAtomFilterTables;
	$hin{'x-atom filter wheres'} = $restrict;
} # sub proc_prepare_params_products

sub proc_prepare_params_families {
 my ($atom,$call) = @_;
 &prepare_params_unifiedly($atom,$call);
 if($hin{'tmpl_if_success_cmd'} eq 'product_families.html'){
	my $pfid = &do_query("select parent_family_id from product_family where family_id = $hin{'family_id'}");
	if($pfid->[0][0]){
   $call->{'call_params'}->{'family_id'} = $pfid->[0][0];
   $hin{'family_id'} = $pfid->[0][0];
	}else{
   $call->{'call_params'}->{'family_id'} = 1;
   $hin{'family_id'} = 1;
	}
 }
}

sub proc_prepare_params_family {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);

	if (!$hin{'family_id'}) {
		$hin{'ffamily_id'} = 0;
		$call->{'call_params'}->{'ffamily_id'} = $hin{'ffamily_id'};
	}
	else {
		$hin{'ffamily_id'} = $hin{'family_id'};
		$call->{'call_params'}->{'ffamily_id'} = $hin{'ffamily_id'};
	}
}

sub proc_prepare_params_feature_values_vocabulary {
	my ($atom,$call) = @_;
	
	&prepare_params_unifiedly($atom,$call);

	&do_statement("create temporary table localized_bits (key_value varchar(255), localized_bits int(13), primary key(key_value))");

	my $vals = &do_query("select key_value, max(feature_values_group_id), min(updated), max(last_published), min(langid) from feature_values_vocabulary group by 1");

	foreach my $val (@$vals) {
		# check the langid = 1 presence and insert lost values
		if ($val->[4] > 1) {
			&do_statement("insert ignore into feature_values_vocabulary(key_value,langid,feature_values_group_id,value,updated,last_published)
values(".&str_sqlize($val->[0]).",1,".$val->[1].",".&str_sqlize($val->[0]).",".&str_sqlize($val->[2]).",".&str_sqlize($val->[3]).")");
		}

		# complete localized_bits info
		my $codes = &do_query("select langid, value from feature_values_vocabulary where key_value = ".&str_sqlize($val->[0])." order by langid desc");
		my $flag=0;
		foreach my $lang (@$codes) {
			if ($lang->[1] ne '') {
				$flag++;
			}
			$flag <<= 1;
		}
		$flag >>= 1;
		&do_statement("insert into localized_bits values (".&str_sqlize($val->[0]).",".$flag.")");
	}
}

sub proc_prepare_params_feature_values {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);
# 	if ($call->{'call_params'}->{'power_mapping_on'}) { # if we click on button `Power mapping` - the $hin{'power_mapping_on'} appears

#	&log_printf(Dumper($hin{'create_mapping'}));

	# Do Power mapping
	use icecat_mapping;
	
	my $h = {
		'feature_id' => $hin{'feature_id'},
		'measure_id' => $hin{'measure_id'},
		'useN' => 'Y'
		};

	if ($hin{'reload'} eq 'Apply') {
		$h->{'apply'} = 'Y';
	}
	&power_mapping_per_feature_and_measure_for_BO($h);

#	}
} # sub proc_prepare_params_feature_values

sub proc_prepare_params_measure_power_mapping {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);

 	if ($hin{'power_mapping_on'}) { # if we click on button `Power mapping` - the $hin{'power_mapping_on'} appears
		# Do Power mapping
		unless ($hin{'power_mapping_apply'}) {
			use icecat_mapping;
			&log_printf("ON, but APPLY");
			&power_mapping_per_measure_for_BO({ 'measure_id' => $hin{'measure_id'}, 'useN' => 'Y', 'max_rows' => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'measure_power_mapping_results_max_rows'} });
		}
	}
} # sub proc_prepare_params_measure_power_mapping

sub proc_prepare_params_feature_value_search
{
 my ($atom,$call) = @_;
 &prepare_params_unifiedly($atom,$call);

 $call->{'call_params'}->{'local_value_search'} = "<tr>";
 my $lang_codes = &do_query("select short_code, code from language where langid!=1 order by langid asc");

 #look for checked descriptions from values saved in session
 foreach my $code(@$lang_codes){
   if(! defined $hin{'new_search'}){
     $hin{$code->[0]."_local_value"} = $hin{$code->[0]."_local_value_saved"};
   }
 }

 my $lang_cnt = 1; #fo format if langs more then 3
 foreach my $code(@$lang_codes){
   my $checked_yes = ""; my $checked_no = "";
   if(defined $hin{$code->[0]."_local_value"} && ($hin{$code->[0]."_local_value"} eq '1')){ $checked_yes = 'checked';}
   if(defined $hin{$code->[0]."_local_value"} && ($hin{$code->[0]."_local_value"} eq '0')){ $checked_no = 'checked';}
   $call->{'call_params'}->{'local_value_search'} .= &repl_ph($atoms->{'default'}->{'feature_value_search'}->{'local_value_search_row'},
   {"lang_code" => $code->[0],
    "lang_name" => $code->[1],
    "checked_yes" => $checked_yes,
    "checked_no" => $checked_no});
    $lang_cnt ++; if($lang_cnt > 3){  $call->{'call_params'}->{'local_value_search'} .= "</tr><tr>";
}
 }
 $call->{'call_params'}->{'local_value_search'} .= "</tr>";

 return 1;
}


sub proc_prepare_params_products_raiting_search {
	my ($atom,$call) = @_;
	my $mapping=$iatoms->{$call->{'name'}}->{'_mapping_params'};
	my @search_params=split(/[\s,]+/,$mapping);
	@search_params=sort @search_params;
	if(!$hin{'reset_search'}){
		foreach my $search_param (@search_params){
			$iatoms->{'search_params_key'}.=$search_param.':'.$hin{$search_param}.',';
		}
	} else{
		$iatoms->{'search_params_key'}='';
	}
	
	&prepare_params_unifiedly($atom,$call);
	
	$call->{'call_params'}->{'description_search'} = "<tr>";
	my $lang_codes = &do_query("select short_code, code from language order by langid asc");
	
	#look for checked descriptions from values saved in session
	foreach my $code(@$lang_codes){
		if(! defined $hin{'new_search'}){
			$hin{$code->[0]."_description"} = $hin{$code->[0]."_description_saved"};
		}
	}
	
	# undef $hin{'search_onstock'} if (defined $hin{'new_search'});
	
	my $lang_cnt = 1; #fo format if langs more then 3
	foreach my $code(@$lang_codes){
		my $checked_yes = ""; my $checked_no = "";
		if(defined $hin{$code->[0]."_description"} && ($hin{$code->[0]."_description"} eq '1')){ $checked_yes = 'checked';}
		if(defined $hin{$code->[0]."_description"} && ($hin{$code->[0]."_description"} eq '0')){ $checked_no = 'checked';}
		$call->{'call_params'}->{'description_search'} .= 
			&repl_ph(
				$atoms->{'default'}->{'products_raiting_search'}->{'description_search_row'},
				{"lang_code" => $code->[0],
					"lang_name" => $code->[1],
					"checked_yes" => $checked_yes,
					"checked_no" => $checked_no
				}
			);
			$lang_cnt ++;
			if($lang_cnt > 3){  $call->{'call_params'}->{'description_search'} .= "</tr><tr>";}
	}
	$call->{'call_params'}->{'description_search'} .= "</tr>";
	
	$call->{'call_params'}->{'search_catid'} = '' unless $hin{'search_catid'};
	
	return 1;
}			

sub proc_prepare_params_users {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);
	&log_printf("\nID:$USER->{'user_id'}; $hin{'user_id'}");
	my $user_group = &do_query("select user_group from users where user_id = ".$USER->{'user_id'})->[0][0];
	if (($user_group ne 'supplier') && ($user_group ne 'guest') && ($user_group ne 'shop')) {
		$hin{'editors_journal_link'} = 'Editors journal';
	}
	else {
		$hin{'editors_journal_link'} = '';
	}

	if (($user_group eq 'superuser') || ($user_group eq 'supereditor') || ($user_group eq 'category_manager')) {
		$hin{'mail_dispatch_link'} = 'Mail dispatch';
	}
	else {
		$hin{'mail_dispatch_link'} = '';
	}

	if (($user_group eq 'superuser')) {
		$hin{'platforms_link'} = 'Platforms';
	}
	else {
		$hin{'platforms_link'} = '';
	}
	
	if (($user_group eq 'superuser')) {
		$hin{'sectors_link'} = 'Sectors';
	}
	else {
		$hin{'sectors_link'} = '';
	}
}

sub proc_prepare_params_mail_dispatch {
	my ($atom,$call) = @_;
	&prepare_params_unifiedly($atom,$call);

	my $query = "SELECT single_email,attachment_name,html_body FROM mail_dispatch WHERE id=".&str_sqlize($hin{'id'});
	my $mail_params = do_query($query);
	$hin{'attachment_name'} = $mail_params->[0][1];
	$hin{'dispatch_message'} = $mail_params->[0][2];
	$hin{'dispatch_message'} =~ s/\%\%/\\%\\%/g;
	if ($mail_params->[0][0]) {
		$hin{'checked'} = 'checked';
		$hin{'single_email'} = $mail_params->[0][0];
	}

}

sub proc_prepare_params_product_group_actions_list {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	my ($value,$call,$field,$res,$hash) = @_;
	my @product_id = split(",", $hin{'product_id_list'});

	if(($USER->{'user_group'} eq 'category_manager')||
		 ($USER->{'user_group'} eq 'supereditor')) {$hin{'chown_disabled'} = "disabled";}
	
	# check, if one supplier products then change family enable
#	my $sup_hash;
#	my $supplier_id;

#	foreach my $product_id (@product_id) {
#		$supplier_id = &do_query("select supplier_id from product where product_id = ".$product_id)->[0][0];
#		$sup_hash->{$supplier_id} = 1;
#		if (keys) {
#		}
#	}

	my $cnt = $hin{'supplier_id_list'};
	$cnt = $#$cnt + 1;

#	my $supplier_id = ;

#	log_printf(Dumper($hin{'supplier_id_list'}));
#	log_printf("COUNT = ".$cnt);

#	foreach my $key (keys %$sup_hash) {
#		$cnt++;
#	}

	if ($cnt != 1) {
		$hin{'disabled'} = "disabled";
		$call->{'call_params'}->{'supplier_id'} = 0;

		return $value;
	}

	$hin{'disabled'} = "";
	$call->{'call_params'}->{'supplier_id'} = $hin{'supplier_id_list'}->[0];
	$hash->{'supplier_id'} = $hin{'supplier_id_list'}->[0];

	return $value;										
}

sub proc_prepare_params_editor_journal_searchs
{
 my ($atom,$call) = @_;
 &prepare_params_unifiedly($atom,$call);
 #restoring search params from session if any 
 if(!$hin{'atom_submit'}){
	 $hin{'search_supplier'}=$hl{'search_supplier'} 	if $hl{'search_supplier'} and !$hin{'search_supplier'};
	 $hin{'from_day'}=$hl{'from_day'} 					if $hl{'from_day'} and !$hin{'from_day'};
	 $hin{'to_day'}=$hl{'to_day'} 						if $hl{'to_day'} and !$hin{'to_day'};
	 $hin{'from_month'}=$hl{'from_month'} 				if $hl{'from_month'} and !$hin{'from_month'};
	 $hin{'to_month'}=$hl{'to_month'} 					if $hl{'to_month'} and !$hin{'to_month'};
	 $hin{'from_year'}=$hl{'from_year'} 				if $hl{'from_year'} and !$hin{'from_year'};
	 $hin{'to_year'}=$hl{'to_year'} 					if $hl{'to_year'} and !$hin{'to_year'};
	 $hin{'search_editor'}=$hl{'search_editor'} 		if $hl{'search_editor'} and !$hin{'search_editor'};
	 $hin{'search_supplier'}=$hl{'search_supplier'} 	if $hl{'search_supplier'} and !$hin{'search_supplier'};
	 $hin{'search_catid'}=$hl{'search_catid'} 			if $hl{'search_catid'} and !$hin{'search_catid'};
	 $hin{'search_prodid'}=$hl{'search_prodid'} 		if $hl{'search_prodid'} and !$hin{'search_prodid'};
	 $hin{'search_distributor'}=$hl{'search_distributor'} if $hl{'search_distributor'} and !$hin{'search_distributor'};
	 $hin{'search_isactive'}=$hl{'search_isactive'} 	if $hl{'search_isactive'} and !$hin{'search_isactive'};
	 $hin{'search_changetype'}=$hl{'search_changetype'} if $hl{'search_changetype'} and !$hin{'search_changetype'};
 }
 
#for date search
 if($hin{'from_day'}){
	 if(length($hin{'from_day'}) == 1){ $hin{'from_day_prepared'} = '0'.$hin{'from_day'};}else{ $hin{'from_day_prepared'} = $hin{'from_day'};}
	 if(length($hin{'to_day'}) == 1){ $hin{'to_day_prepared'} = '0'.$hin{'to_day'};}else{$hin{'to_day_prepared'} = $hin{'to_day'};} 
	 if(length($hin{'from_month'}) == 1){ $hin{'from_month_prepared'} = '0'.$hin{'from_month'};}else{ $hin{'from_month_prepared'} = $hin{'from_month'};}
	 if(length($hin{'to_month'}) == 1){ $hin{'to_month_prepared'} = '0'.$hin{'to_month'};}else{ $hin{'to_month_prepared'} = $hin{'to_month'};} 
	 $hin{'from_year_prepared'} = $hin{'from_year'}; 
	 $hin{'to_year_prepared'} = $hin{'to_year'};
	 my ($sec,$min,$hour) = (localtime(time))[0,1,2];
	 my $unixfromdate = &Time::Local::timelocal(0,0,0,$hin{'from_day_prepared'},$hin{'from_month_prepared'}-1,$hin{'from_year_prepared'});
	 my $unixtodate = &Time::Local::timelocal(59,59,23,$hin{'to_day_prepared'},$hin{'to_month_prepared'}-1,$hin{'to_year_prepared'});
	 $call->{'call_params'}->{'from_date_prepared'} = " date >= ".$unixfromdate;
	 $call->{'call_params'}->{'to_date_prepared'} = " date <= ".$unixtodate;
   $call->{'call_params'}->{'to_year'} = $hin{'to_year'};
   $call->{'call_params'}->{'to_month'} = $hin{'to_month'};
   $call->{'call_params'}->{'to_day'} = $hin{'to_day'};
   $call->{'call_params'}->{'from_year'} = $hin{'from_year'};
   $call->{'call_params'}->{'from_month'} = $hin{'from_month'};
   $call->{'call_params'}->{'from_day'} = $hin{'from_day'};;
 }else{
   my($d,$m,$y) = (localtime)[3,4,5];
   $m += 1; $d += 1;
   if(length($m) == 1){ $m = '0'.$m;}
   if(length($d) == 1){ $d = '0'.$d;}
	 my ($sec,$min,$hour) = (localtime(time))[0,1,2];
	 my $unixfromdate = &Time::Local::timelocal(0,0,0,1,$m-1,1900+$y);
	 my $unixtodate = &Time::Local::timelocal(59,59,23,$d-1,$m-1,1900+$y);
	 $call->{'call_params'}->{'from_date_prepared'} = " date >= ".$unixfromdate;
	 $call->{'call_params'}->{'to_date_prepared'} = " date <= ".$unixtodate;
	 my $cur_date = &do_query("select year(now()),month(now()),dayofmonth(now()), year(now()), month(now()), '1'");
	 $call->{'call_params'}->{'to_year'} = $cur_date->[0][0];
	 $call->{'call_params'}->{'to_month'} = $cur_date->[0][1]; 
	 $call->{'call_params'}->{'to_day'} = $cur_date->[0][2]; 
	 $call->{'call_params'}->{'from_year'} = $cur_date->[0][3]; 
	 $call->{'call_params'}->{'from_month'} = $cur_date->[0][4]; 
	 $call->{'call_params'}->{'from_day'} = $cur_date->[0][5];;
 } 								 
 
#for editor search
	if($hin{'search_editor'}){	 
	 my $current_user=&do_query("SELECT user_group FROM users WHERE user_id=".$hl{'user_id'}." LIMIT 1");
	 if($current_user and  grep(/$current_user->[0][0]/,('editor','exeditor','shop'))){
	 	$hin{'search_editor'}=$hl{'user_id'};
	 }	 
	 $hin{'search_editor_prepared'} = $hin{'search_editor'};
	 $call->{'call_params'}->{'search_editor_prepared'} =  " ej.user_id = ".$hin{'search_editor'};
	 $call->{'call_params'}->{'search_editor'} =  $hin{'search_editor'};
	 $call->{'call_params'}->{'editor_id'} =  $hin{'search_editor'};
	 $hin{'editor_id'} = $hin{'search_editor'};
	}else{
	 $call->{'call_params'}->{'search_editor_prepared'} =  " 1 ";
	 $call->{'call_params'}->{'search_editor'} =  " '' ";
	}
#for supplier search
if($hin{'search_supplier'}){
	 $hin{'search_supplier_prepared'} = $hin{'search_supplier'};
	 $call->{'call_params'}->{'search_supplier_prepared'} = " ej.supplier_id = ".$hin{'search_supplier'};
	}else{
	 $call->{'call_params'}->{'search_supplier_prepared'} = " 1 ";
	 $call->{'call_params'}->{'search_supplier'} = " '' ";
	}
#for catid search
	if($hin{'search_catid'} && ($hin{'search_catid'} != 1)){
	 $hin{'search_catid_prepared'} = $hin{'search_catid'};
	 $call->{'call_params'}->{'search_catid_prepared'} = " ej.catid = ".$hin{'search_catid'};
	}else{
	 $call->{'call_params'}->{'search_catid_prepared'} = " 1 ";
	 $call->{'call_params'}->{'search_catid'} = " '' ";
	}

#for prodid search
	if($hin{'search_prodid'}){
	 $hin{'search_prodid_prepared'} = $hin{'search_prodid'};
	 $call->{'call_params'}->{'search_prodid_prepared'} = " ej.prod_id like '%".$hin{'search_prodid'}."%'";
	}else{
	 $call->{'call_params'}->{'search_prodid_prepared'} = " 1 ";
	 $call->{'call_params'}->{'search_prodid'} = " '' ";
	}	 

#for distributor search
	if($hin{'search_distributor'}){
		$hin{'search_distributor_prepared'} = $hin{'search_distributor'};
		$call->{'call_params'}->{'search_distributor_prepared'} = " dp.distributor_id =".$hin{'search_distributor'};
	}else{
	 	$call->{'call_params'}->{'search_distributor_prepared'} = " 1 ";
	 	$call->{'call_params'}->{'search_distributor'} = " '' ";
	}	 

#for active distributor search
	if($hin{'search_isactive'}){
		$hin{'search_isactive_prepared'} = $hin{'search_isactive'};
		$call->{'call_params'}->{'search_isactive_prepared'} = " dp.active =1";
	}else{
		$call->{'call_params'}->{'search_isactive_prepared'} = " 1 ";
		$call->{'call_params'}->{'search_isactive'} = " '' ";
	}	 

#for chanetype search
 	if($hin{'search_changetype'}){
	 if($hin{'search_changetype'} eq 'product'){$hin{'selected1'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_feature'){$hin{'selected2'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_description'){$hin{'selected3'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_bundled'){$hin{'selected4'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_related'){$hin{'selected5'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_gallery'){$hin{'selected6'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_multimedia_object'){$hin{'selected7'} = 'selected';}
	 if($hin{'search_changetype'} eq 'product_ean_codes'){$hin{'selected8'} = 'selected';}
	 $call->{'call_params'}->{'search_changetype_prepared'} = " product_table = ".&str_sqlize($hin{'search_changetype'});
	}else{
	 $call->{'call_params'}->{'search_changetype_prepared'} = " 1 ";
	}
	 
 return 1;
}

sub proc_prepare_params_editor_journal_list
{
 my ($atom,$call) = @_;
 &prepare_params_unifiedly($atom,$call);
 proc_prepare_params_editor_journal_searchs($atom, $call);
 # adding left join to distrionly if needed
 if ($call->{'call_params'}->{'search_distributor_prepared'}!=1 or $call->{'call_params'}->{'search_isactive_prepared'}!=1){
	$call->{'call_params'}->{'left_join_distri'}=" LEFT JOIN distributor_product dp ON dp.product_id=ej.product_id ";
 }else{
 	$call->{'call_params'}->{'left_join_distri'}='';
 }
 
 return 1;
}

sub proc_prepare_params_editor_journal_edit
{

 #pass params trow to session 
 if($hin{'editor_id'}){ 
	$hs{'editor_id'} = $hin{'editor_id'};
	$hs{'from_day'} = $hin{'from_day'};
	$hs{'from_month'} = $hin{'from_month'};
	$hs{'from_year'} = $hin{'from_year'};
	$hs{'to_day'} = $hin{'to_day'};
	$hs{'to_month'} = $hin{'to_month'};
	$hs{'to_year'} = $hin{'to_year'};
	$hs{'search_editor'} = $hin{'search_editor'};
	$hs{'search_catid'} = $hin{'search_catid'};
	$hs{'search_supplier'} = $hin{'search_supplier'};
	$hs{'search_prodid'} = $hin{'search_prodid'};
	$hs{'search_changetype'} = $hin{'search_changetype'};
	$hs{'search_distributor'} = $hin{'search_distributor'};
	$hs{'search_isactive'} = $hin{'search_isactive'};
 }elsif($hl{'editor_id'}){ 
	$hs{'editor_id'} = $hl{'editor_id'}; $hin{'editor_id'} = $hl{'editor_id'};
	$hs{'editor_id'} = $hin{'editor_id'};
	$hs{'from_day'} = $hl{'from_day'}; 	$hin{'from_day'} = $hl{'from_day'};
	$hs{'from_month'} = $hl{'from_month'};	$hin{'from_month'} = $hl{'from_month'};
	$hs{'from_year'} = $hl{'from_year'};	$hin{'from_year'} = $hl{'from_year'};
	$hs{'to_day'} = $hl{'to_day'};	$hin{'to_day'} = $hl{'to_day'};
	$hs{'to_month'} = $hl{'to_month'};	$hin{'to_month'} = $hl{'to_month'};
	$hs{'to_year'} = $hl{'to_year'};	$hin{'to_year'} = $hl{'to_year'};
	$hs{'search_editor'} = $hl{'search_editor'};	$hin{'search_editor'} = $hl{'search_editor'};
	$hs{'search_catid'} = $hl{'search_catid'};	$hin{'search_catid'} = $hl{'search_catid'};
	$hs{'search_supplier'} = $hl{'search_supplier'};	$hin{'search_supplier'} = $hl{'search_supplier'};
	$hs{'search_prodid'} = $hl{'search_prodid'};	$hin{'search_prodid'} = $hl{'search_prodid'};
	$hs{'search_changetype'} = $hl{'search_changetype'};	$hin{'search_changetype'} = $hl{'search_changetype'};
	$hs{'search_distributor'} = $hl{'search_distributor'};	$hin{'search_distributor'} = $hl{'search_distributor'};
	$hs{'search_isactive'} = $hl{'search_isactive'};	$hin{'search_isactive'} = $hl{'search_isactive'};
 }
 my ($atom,$call) = @_;
 &prepare_params_unifiedly($atom,$call);
 proc_prepare_params_editor_journal_searchs($atom, $call);
 # adding left join to distrionly if needed
 if ($call->{'call_params'}->{'search_distributor_prepared'}!=1 or $call->{'call_params'}->{'search_isactive_prepared'}!=1){
	$call->{'call_params'}->{'left_join_distri'}=" LEFT JOIN distributor_product dp ON dp.product_id=ej.product_id ";
 }else{
 	$call->{'call_params'}->{'left_join_distri'}='';
 }

 return 1;
}

sub proc_prepare_params_quicktest {
	my ($atom,$call) = @_;

	# all other stuff
	&prepare_params_unifiedly($atom,$call);

	use LWP::Simple;

	# get _mulitprf login & pass
	my $lp = &do_query("select login, password from users where login='_multiprf'");
	my $l = $lp->[0][0];
	my $p = $lp->[0][1];
	return 1 unless $l;

	my $level4_host = $atomcfg{'host'};
	$level4_host =~ s/^(http\:\/\/)(.*)$/$1$l\:$p\@$2/;
	
#	$lp = &do_query("select login, password from users where login='vitaly'");
#	$l = $lp->[0][0];
#	$p = $lp->[0][1];
#	$l = 'techdatatest';
#	$p = '8ll2k98';

	my $free_host = $atomcfg{'host'};
	$free_host =~ s/^(http\:\/\/)(.*)$/$1$l\:$p\@$2/;

	#my @head;
	
	## quick tests
	# level4 repos
	
	my $files = [
		'refs.xml',
		'refs.xml.gz',
		'refs/CategoriesList.xml.gz',
		'refs/CategoryFeaturesList.xml.gz',
		'refs/FeaturesList.xml.gz',
		'refs/LanguageList.xml.gz',
		'refs/MeasuresList.xml.gz',
		'refs/SupplierProductFamiliesListRequest.xml.gz',
		'refs/SuppliersList.xml.gz',
		'data_prod_stat.xml',
		'export_urls.xml.gz',
		];
	
	foreach (@$files) {
		&add_item($call,$atomcfg{'xml_path'}.'level4/'.$_,$level4_host.'export/level4/'.$_,1);
	}
	
	# get some 2 products
	my $ps = &do_query("(select product_id from product p inner join users u using (user_id) inner join user_group_measure_map ugmm on u.user_group=ugmm.user_group inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure where cmim.quality_index > 0 and product_id < 1000 order by product_id asc limit 3) UNION (select product_id from product p  inner join users u using (user_id)  inner join user_group_measure_map ugmm on u.user_group=ugmm.user_group  inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure  where cmim.quality_index > 0 and product_id > (select max(product_id) from product)-10000 order by product_id desc limit 3)");
	
	foreach (@$ps) {
		&add_item($call,$atomcfg{'xml_path'}.'level4/INT/'.&get_smart_path($_->[0]).$_->[0].'.xml.gz',$level4_host.'export/level4/INT/'.$_->[0].'.xml',2);
	}

	# level4->csv&prf
	$files = [
		'csv/product.txt',
		'csv/category.txt',
		'csv/category_feature.txt',
		'csv/category_feature_group.txt',
		'csv/feature.txt',
		'csv/feature_group.txt',
		'csv/language.txt',
		'csv/measure.txt',
		'csv/product_bundled.txt',
		'csv/product_description.txt',
		'csv/product_ean_codes.txt',
		'csv/product_feature.txt',
		'csv/product_name.txt',
		'csv/product_related.txt',
		'csv/product_statistic.txt',
		'csv/supplier.txt',
		'csv/tex.txt',
		'csv/vocabulary.txt',

		'prf/product.txt',
		];

	foreach (@$files) {
		&add_item($call,$atomcfg{'xml_path'}.'level4/'.$_,$level4_host.'export/level4/'.$_,3);
		&add_item($call,$atomcfg{'xml_path'}.'level4/'.$_.'.gz',$level4_host.'export/level4/'.$_.'.gz',3);
		&add_item($call,$atomcfg{'xml_path'}.'level4/'.$_.'.utf8',$level4_host.'export/level4/'.$_.'.utf8',3);
		&add_item($call,$atomcfg{'xml_path'}.'level4/'.$_.'.utf8.gz',$level4_host.'export/level4/'.$_.'.utf8.gz',3);
	}

	# level4 misc files
	$files = [ 'categories.xml', 'measures.xml' ];
	
	foreach (@$files) {
		&add_item($call,$atomcfg{'www_path'}.'export'.$_,$level4_host.'export/'.$_,'3,5');
		&add_item($call,$atomcfg{'www_path'}.'export/'.$_.'.gz',$level4_host.'export/'.$_.'.gz','3,5');
	}

	# freexml repos
	$files = [ 'files.index.xml', 'daily.index.xml', 'files.index.csv' ];

	foreach (@$files) {
		&add_item($call,$atomcfg{'xml_path'}.'freexml.int/INT/'.$_,$level4_host.'export/freexml.int/INT/'.$_,4);
		&add_item($call,$atomcfg{'xml_path'}.'freexml.int/INT/'.$_.'.gz',$level4_host.'export/freexml.int/INT/'.$_.'.gz',4);
	}

	$ps = &do_query("select p.product_id from product p inner join users u using (user_id) inner join user_group_measure_map ugmm on u.user_group=ugmm.user_group inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure inner join supplier s using (supplier_id) where cmim.quality_index > 0 and s.is_sponsor='Y' and p.product_id > (select max(product_id) from product)-100000 order by p.product_id desc limit 3");

	foreach (@$ps) {
		&add_item($call,$atomcfg{'xml_path'}.'level4/INT/'.&get_smart_path($_->[0]).$_->[0].'.xml.gz',$level4_host.'export/freexml.int/INT/'.$_->[0].'.xml',4);
	}

	# vendor repos
	my $ss = &do_query("select folder_name, supplier_id, public_login, public_password from supplier where public_login!='' order by supplier_id asc limit 2");
	foreach my $s (@$ss) {
		my $vendor_host = $atomcfg{'host'};
		$vendor_host =~ s/^(http\:\/\/)(.*)$/$1$s->[2]\:$s->[3]\@$2/;

		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/files.index.xml',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/files.index.xml',5);
		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/files.index.xml.gz',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/files.index.xml.gz',5);
		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/daily.index.xml',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/daily.index.xml',5);
		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/daily.index.xml.gz',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/daily.index.xml.gz',5);
		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/files.index.csv',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/files.index.csv',5);
		&add_item($call,$atomcfg{'xml_path'}.'vendor.int/'.$s->[0].'/INT/files.index.csv.gz',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/files.index.csv.gz',5);
		$ps = &do_query("select p.product_id from product p inner join users u using (user_id) inner join user_group_measure_map ugmm on u.user_group=ugmm.user_group inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure where cmim.quality_index > 0 and p.supplier_id=".$s->[1]." and p.product_id > (select max(product_id) from product)-100000 order by p.product_id desc limit 3");
		foreach my $p (@$ps) {
			&add_item($call,$atomcfg{'xml_path'}.'level4/INT/'.&get_smart_path($p->[0]).$p->[0].'.xml.gz',$vendor_host.'export/vendor.int/'.$s->[0].'/INT/'.$p->[0].'.xml',5);
		}	
	}

	# hp_corner
	#  /home/gcc/data_source/HPProvisioner/hp_corner_all -> export/hp_corner/hp_corner_all_new.txt
	&add_item($call,$atomcfg{'www_path'}.'export/hp_corner/hp_corner_all_new.txt',$level4_host.'export/hp_corner/hp_corner_all_new.txt',6);
	#  /home/gcc/data_source/HPProvisioner/hp_corner -> export/hp_corner/hp_corner_new.txt, export/hp_corner/hp_categorization_new.txt
	&add_item($call,$atomcfg{'www_path'}.'export/hp_corner/hp_corner_new.txt',$level4_host.'export/hp_corner/hp_corner_new.txt',6);
	&add_item($call,$atomcfg{'www_path'}.'export/hp_corner/hp_categorization_new.txt',$level4_host.'export/hp_corner/hp_categorization_new.txt',6);
	#  /home/gcc/data_source/HPProvisioner/hpinv_check -> export/hp_corner/hpinv_check.txt, linked to data_source/HPProvisioner/hpinv_check.txt
	&add_item($call,$atomcfg{'www_path'}.'export/hp_corner/hpinv_check.txt',$level4_host.'export/hp_corner/hpinv_check.txt',6);

	# techdata (full and open) - TD, TB, TDES
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TD_mapping.txt',$free_host.'export/techdata/TD_mapping.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TD_mapping_rich.txt',$free_host.'export/techdata/TD_mapping_rich.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TB_mapping.txt',$free_host.'export/techdata/TB_mapping.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TB_mapping_rich.txt',$free_host.'export/techdata/TB_mapping_rich.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TDES_mapping.txt',$free_host.'export/techdata/TDES_mapping.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdata/TDES_mapping_rich.txt',$free_host.'export/techdata/TDES_mapping_rich.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdatafull/TDES_mapping_full.txt',$free_host.'export/techdatafull/TDES_mapping_full.txt',7);
	&add_item($call,$atomcfg{'www_path'}.'export/techdatafull/TDES_mapping_full_rich.txt',$free_host.'export/techdatafull/TDES_mapping_full_rich.txt',7);

	# URLs
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls.cgi',$free_host.'export/export_urls.cgi',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_suppliers.txt',$free_host.'export/export_suppliers.txt',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls.txt',$free_host.'export/export_urls.txt',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls.txt.gz',$free_host.'export/export_urls.txt.gz',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls.xml',$free_host.'export/export_urls.xml',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls.xml.gz',$free_host.'export/export_urls.xml.gz',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls_rich.xml',$free_host.'export/export_urls_rich.xml',8);
	&add_item($call,$atomcfg{'www_path'}.'export/export_urls_rich.xml.gz',$free_host.'export/export_urls_rich.xml.gz',8);

	&add_item($call,$atomcfg{'www_path'}.'export/freeurls/export_suppliers.txt',$free_host.'export/freeurls/export_suppliers.txt',8);
	&add_item($call,$atomcfg{'www_path'}.'export/freeurls/export_urls.txt',$free_host.'export/freeurls/export_urls.txt',8);
	&add_item($call,$atomcfg{'www_path'}.'export/freeurls/export_urls.txt.gz',$free_host.'export/freeurls/export_urls.txt.gz',8);
	&add_item($call,$atomcfg{'www_path'}.'export/freeurls/export_urls_rich.xml',$free_host.'export/freeurls/export_urls_rich.xml',8);
	&add_item($call,$atomcfg{'www_path'}.'export/freeurls/export_urls_rich.xml.gz',$free_host.'export/freeurls/export_urls_rich.xml.gz',8);

	# levelplus->csv->categorization_*.txt
	my $langids = &do_query("select langid from language order by langid asc");
	&add_item($call,$atomcfg{'www_path'}.'export/levelplus/csv/product_categorization.txt',$free_host.'export/levelplus/csv/product_categorization.txt',9);
#	&add_item($call,$atomcfg{'www_path'}.'export/levelplus/products_summary.csv',$free_host.'export/levelplus/products_summary.csv',9); # export_short_desc.pl - disabled!
	foreach (@$langids) {
		&add_item($call,$atomcfg{'www_path'}.'export/levelplus/csv/categorization_'.$_->[0].'.txt',$free_host.'export/levelplus/csv/categorization_'.$_->[0].'.txt',9);
	}

	# prodid_d.txt repo
	&add_item($call,$atomcfg{'base_dir'}.'data_export/prodid_d.txt',undef,10);
	
 	return 1;

	sub add_item {
		my ($call, $lfile, $rfile, $no) = @_;

		my $f = 'present';
		my $nf = '<font style="color: red;">not found</font>';
		my $int = '<font style="color: grey;">internal file</font>';
		my $br = '<br>';
		my @head;
		my $out;
		my $cmd;

		my $outfile;
		if ($rfile) {
			$outfile = $rfile;
			$outfile =~ s/^http:\/\/.*?\/(.*)$/$1/;
			$outfile =~ s/^(.*\/)(.*?)$/$1<a href="$rfile">$2<\/a>/;
		}
		else {
			$outfile = $lfile;
			$outfile =~ s/^$atomcfg{'www_path'}//;
			$outfile =~ s/^$atomcfg{'base_dir'}//;
		}

		$call->{'call_params'}->{'info'.$no} .= $outfile;

		$cmd = ( (($atomcfg{'host_raw'} eq '127.0.0.1') ||
							($atomcfg{'host_raw'} eq 'dev.icecat.biz') ||
							($atomcfg{'host_raw'} eq 'localhost')) ?
						 '' : (" ssh ".$atomcfg{'user'}.'@'.$atomcfg{'host_raw'}) ) .
						 " /usr/bin/file ".$lfile;

		log_printf("CMD = ".$cmd);

		$out = `$cmd`;
		$out =~ s/^.*?\:\s+//;
		if ($out =~ /^cannot\sopen/) {
			$out = '';
		}
		else {
			$out =~ s/,.*$//;
			if ($out =~ /^(broken\s)?symbolic/) {
				$out =~ s/^(.*?symbolic.*)\`.*\/(.*?)\'$/<i>$1<\/i> $2/;
				if ($out =~ /^<i>broken/) {
					$out = "<font style=\"color: red;\">".$out."</font>";
				}
				$out =~ s/symbolic\slink/symlink/g;
			}
		}
		$call->{'call_params'}->{'info'.$no.'_int'} .= ($out) ? $out : $nf;
		if ($rfile) {
			@head = head($rfile);
			$call->{'call_params'}->{'info'.$no.'_ext'} .= $head[0] || $nf;
		}
		else {
			$call->{'call_params'}->{'info'.$no.'_ext'} .= $int;
		}
		
		$call->{'call_params'}->{'info'.$no} .= $br;
		$call->{'call_params'}->{'info'.$no.'_int'} .= $br;
		$call->{'call_params'}->{'info'.$no.'_ext'} .= $br;
	}
} # sub proc_prepare_params_quicktest

sub proc_prepare_params_users_search {
	my ($atom,$call) = @_;

	&prepare_params_unifiedly($atom,$call);

	if (($USER->{'user_group'} eq "superuser") || ($USER->{'user_group'} eq "supereditor")) {
		$hin{'what_user'} = "";
		if ($hin{'send_email'}) {
			$hin{'message_sent'} = '<p align="center">'.&make_send_users().'</p>';
			$hin{'message_sent_ignore_unifiedly_processing'} = 'Yes';
		}
		else {
			$hin{'message_sent'} = '';
		}
	}
	else {
		$hin{'what_user'} = "none";
	}
} # sub proc_prepare_params_users_search

sub make_send_users {
	my (%details,$login,$email,$url,$company,$level,$group,$partner,$country);
	
	$details{'login'} =              $hin{'search_login'};
	$details{'email'} =              $hin{'search_email'};
	$details{'url'} =                $hin{'search_url'};
	$details{'company'} =            $hin{'search_company'};
	$details{'subscription_level'} = $hin{'search_subscription_level'};
	$details{'user_group'} =         $hin{'search_user_group'};
	$details{'partner'} =            $hin{'search_user_partner_id'};
	$details{'country'} =            $hin{'search_user_country_id'};
	$details{'send_email'} =         $hin{'email'};
	
	return '<h4>Error! Please, enter valid e-mail</h4>' if ($details{'send_email'} !~ /^([a-zA-Z0-9_\.\-+])+@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/);
	
	$login = $email = $url = $company = $level = $group = $partner = $country = '';
	$login =    " and u.login like ".&str_sqlize('%'.$details{'login'}.'%') if($details{'login'});
	$email =    " and c.email like ".&str_sqlize('%'.$details{'email'}.'%') if($details{'email'});
	$url =      " and c.url like ".&str_sqlize('%'.$details{'url'}.'%') if($details{'url'});
	$company =  " and c.company like ".&str_sqlize('%'.$details{'company'}.'%') if($details{'company'});
	$level =    " and u.subscription_level=".&str_sqlize($details{'subscription_level'}) if($details{'subscription_level'} ne '');
	$group =    " and u.user_group=".&str_sqlize($details{'user_group'}) if($details{'user_group'});
	$partner  = " and u.user_partner_id=".&str_sqlize($details{'partner'}) if($details{'partner'});
	$country =  " and c.country_id=".&str_sqlize($details{'country'}) if($details{'country'});
	
	&do_statement("drop temporary table if exists itmp_send_users");
	&do_statement("create temporary table itmp_send_users(
                        `user_id` int(13) NOT NULL,
                        `login` char(40) NOT NULL,
                        `company` varchar(255) default '',
                        `country` varchar(255) default '',
                        `user_group` varchar(255) NOT NULL default 'shop',
                        `email` varchar(255) default '',
                        `url` varchar(255) default '',
                        `level` varchar(25) default '',
                        `sector` varchar(255),
                        PRIMARY KEY  (`user_id`),
                        UNIQUE KEY `login` (`login`)) DEFAULT CHARSET = utf8");
	&do_statement("insert into itmp_send_users (user_id,login,company,country,user_group,email,url,level,sector) select 
                        u.user_id, u.login, c.company, v.value, u.user_group, c.email, c.url, sl.value, if(s.name is null,'',s.name)
                        from users u 
                        left join contact c on u.pers_cid=c.contact_id 
                        LEFT JOIN country k on c.country_id = k.country_id 
                        LEFT JOIN vocabulary v on k.sid = v.sid and v.langid=1
                        LEFT JOIN sector_name s on c.sector_id = s.sector_id and s.langid = 1
                        LEFT JOIN subscription_levels sl on u.subscription_level = sl.subscription_level
                        where 1".$login.$email.$url.$company.$level.$group.$partner.$country);
	
	my $file  = 'request_users.xls';
	my $workbook  = Spreadsheet::WriteExcel->new($file) or die("cannot create xls file: $!\n");
	my $format = $workbook->add_format(); # Add a format
	$format->set_bold();
	$format->set_color('red');
	$format->set_align('center');
	my $format1 = $workbook->add_format();
	$format1->set_bold();

	my $worksheet;
	my $ws_num = 0;
	$worksheet->{$ws_num} = $workbook->add_worksheet();
	$worksheet->{$ws_num}->write(0, 0, 'User', $format);
	$worksheet->{$ws_num}->write(0, 1, 'Company', $format);
	$worksheet->{$ws_num}->write(0, 2, 'Country', $format);
	$worksheet->{$ws_num}->write(0, 3, 'Group', $format);
	$worksheet->{$ws_num}->write(0, 4, 'e-mail', $format);
	$worksheet->{$ws_num}->write(0, 5, 'URL', $format);
	$worksheet->{$ws_num}->write(0, 6, 'Level', $format);
	$worksheet->{$ws_num}->write(0, 7, 'Sector', $format);
	
	my $row = 1;
	my $info = &do_query("select login,company,country,user_group,email,url,level,sector from itmp_send_users");
	foreach my $inf (@$info) {
		my $col;
		for ($col=0; $col<8; $col++) {
			$worksheet->{$ws_num}->write($row, $col, $inf->[$col]);
		}
		$row++;
	}
	
	$workbook->close();
	
	my $cmd = '/bin/gzip -9 -f '.$file;
	`$cmd`;
	$file .= '.gz';
	
	my $data;
	my $buffer;
	open XLS, "<".$file;
	binmode XLS, ":bytes";
	while (read(XLS,$buffer,4096)) {
		$data .= $buffer;
	}
	close XLS;
	`/bin/rm -f $file`;
	my $mail = {
		'to' => $details{'send_email'},
		'from' => 'no_reply',
		'subject' => 'users list due to your request',
		'text_body' => 'File with list of users is attached to this mail',
		'attachment_name' => $file,
		'attachment_content_type' => 'application/x-gzip',
		'attachment_body' => $data
	};
	
	&atom_mail::complex_sendmail($mail);
	
	return '<h4>File with users information was sent to '.$details{'send_email'}.'</h4>';
} # sub make_send_users

sub proc_prepare_params_feed_config{
 my ($atom,$call) = @_;
 $hin{'feed_url'}=&trim($hin{'feed_url'});
 $hin{'escape'}=($hin{'escape'} eq '\\')?'\\\\':$hin{'escape'};
 $hin{'delimiter'}=($hin{'delimiter'} eq '\\')?'\\\\':$hin{'delimiter'};
 $hin{'newline'}=($hin{'newline'} eq '\\')?'\\\\':$hin{'newline'};
 $hin{'quote'}=($hin{'quote'} eq '\\')?'\\\\':$hin{'quote'}; 
 &prepare_params_unifiedly($atom,$call);
}

sub proc_prepare_params_feed_pricelist{
 my ($atom,$call) = @_;
 my $hash={'superuser'=>1,'supereditor'=>1};
 unless($hash->{$USER->{'user_group'}}){
 	push(@user_errors,'You are not authorized to view this page');
 	hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
 	return '';
 }
 &prepare_params_unifiedly($atom,$call);
 if(!$hin{'group_code'} and $hin{'feed_url'}){
 	push(@user_errors,'Enter group code before making any changes');
 } 
 $hin{'feed_config_id'}=$hin{'group_code'} if $hin{'group_code'};
 # user does not push any buttons yet so we have to replace temporary files with priviosly saved
 # othervise formats will use temporary files which user probably does not save latter  
 if($hin{'feed_config_id'} and !$hin{'feed_url'} and !$hin{'is_first_header'} and !$hin{'delimiter'} and !$hin{'atom_update'} and !$hin{'atom_submit'}){
 	my $tmp_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/'; 	
	my $ready_dir=$atomcfg{"base_dir"}.'pricelists/'.$hin{'feed_config_id'};
	if(-d $ready_dir){
		`rm -R $tmp_dir`;
		`cp -R $ready_dir $tmp_dir`;
		`chmod 777 -R $tmp_dir`;# just is case
	}else{
		# do nothing
	}
 }
 
 if(!$hin{'distributor_pl_id'}){
 	my $exited_pl_id=&do_query('SELECT GROUP_CONCAT(d.name separator \',\')  FROM distributor_pl dp
 								JOIN distributor d ON dp.code=d.group_code
								WHERE dp.code='.&str_sqlize($hin{'group_code'}).'
								GROUP BY dp.code')->[0][0];
	if($exited_pl_id and scalar(@user_errors)<1){
		push(@user_warnings,'This group code already exists. If you change its catalog settings they 
							 will  also affect on such distibutor\'s catalogs: '.$exited_pl_id.'. 
							 Please use another group code if you are not agree with this. ')
	} 	
	 set_hin_from_sql('SELECT feed_url,is_first_header,delimiter,newline,escape,quote,user_choiced_file,feed_type,feed_login,feed_pwd,active 
	 				   FROM distributor_pl WHERE code='.&str_sqlize($hin{'group_code'}),'replace $hin');
 }else{
	 set_hin_from_sql('SELECT feed_url,is_first_header,delimiter,newline,escape,quote,user_choiced_file,feed_type,feed_login,feed_pwd 
	 				   FROM distributor_pl WHERE code='.&str_sqlize($hin{'group_code'})); 	
 }
 if($hin{'feed_url'} and (-d $atomcfg{"base_dir"}.'pricelists/'.$hin{'feed_config_id'}.'/')){# print one-time the warning if file is obsolete 
 	my $curr_file=get_feed_file($atomcfg{"base_dir"}.'pricelists/'.$hin{'feed_config_id'}.'/');
 	my $filetime=(stat($curr_file))[9];
 	if(time-$filetime>(24*3*3600) and !$hl{'obsolite_pricelist_warn_was_shown_'.$hin{'feed_config_id'}}){
 		$hl{'obsolite_pricelist_warn_was_shown_'.$hin{'feed_config_id'}}=1;
 		$hs{'obsolite_pricelist_warn_was_shown_'.$hin{'feed_config_id'}}=1;
 		push(@user_warnings,'Pricelist is obsolete. Please reupload it. It could be changed')
 	}
 }
  $hl{'obsolite_pricelist_warn_was_shown_'.$hin{'feed_config_id'}}=$hs{'obsolite_pricelist_warn_was_shown_'.$hin{'feed_config_id'}};
}

sub set_hin_from_sql{
	my ($sql,$replace_hin)=@_;
	my $rows=&do_query($sql);
	return '' if ref($rows->[0]) ne 'ARRAY';
	$sql=~/select(.+?)from/is;
	my $fields_str=&trim($1);
	$fields_str=~s/[\n\s]+//gs;
	$fields_str=~s/[^,]+\.//gs;
	
	my $i=0;
	foreach my $field (split(',',$fields_str)){
		$hin{$field}=$rows->[0][$i] if !$hin{$field} or $replace_hin;
		$i++;
	}
	return 1;
}

sub hide_atom_for_all_groups_except {
    my ($atom, $groups) = @_;

    my $is_deny = 1;
    foreach (@$groups) {
	if ($USER->{'user_group'} eq $_ ) {
	    $is_deny = 0;
	    last;
	}
    }

    $atom->{'processed'} = '' if ($is_deny);
    return;
}

sub proc_prepare_params_sectors {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}

sub proc_prepare_params_sector {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}
sub proc_prepare_params_virtual_categories {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    
    # delete records from virtual_category
    do_statement("DELETE FROM virtual_category WHERE category_id IN (SELECT catid FROM category WHERE ucatid RLIKE '00\$') ");
    # delete records from virtual_category_product
    do_statement("DELETE FROM virtual_category_product WHERE virtual_category_id NOT IN (SELECT virtual_category_id FROM virtual_category) ");
    
    return;
}

sub proc_prepare_params_default_warranty_info {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}

sub proc_prepare_params_default_warranty_info_edit {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}

sub proc_prepare_params_virtual_categories {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}

sub proc_prepare_params_track_lists{
	my ($atom,$call) = @_;
	
	if($USER->{'user_group'} eq 'supereditor' and  $USER->{'login'} ne 'superilya'){
		#$hin{'search_atom'}='track_lists'; #unless($hin{'search_atom'});
		#$hin{'search_owner_id'}=$USER->{'user_id'};
		#$hin{'search_owner_id_mode'}='=';
		#$hin{'reset_search'}='';
		$call->{'call_params'}->{'restrict'} = ' tl.user_id ='.$USER->{'user_id'}.' ';
	}elsif($USER->{'user_group'} ne 'superuser' and  $USER->{'login'} ne 'superilya'){
		#$hin{'search_atom'}='track_lists'; #unless($hin{'search_atom'});
		#$hin{'search_editor_id'}=$USER->{'user_id'};
		#$hin{'search_editor_id_mode'}='=';
		#$hin{'reset_search'}='';
		$call->{'call_params'}->{'restrict'} = ' tle.user_id='.$USER->{'user_id'}.' ';		
	}
	if($hin{'search_is_open'} eq '1' or !defined($hin{'search_is_open'})){
		$hin{'search_atom'}='track_lists'; #unless($hin{'search_atom'});
		$hin{'search_is_open'}='1';
		$hin{'search_editor_id_mode'}='digit';
		$hin{'reset_search'}='';
	}
	if(($USER->{'user_group'} eq 'superuser' or  $USER->{'login'} eq 'superilya')  and !defined($hin{'search_user_id'})){
		$hin{'search_atom'}='track_lists'; #unless($hin{'search_atom'});
		$hin{'search_user_id'}=$USER->{'user_id'};
		$hin{'reset_search'}='';
	}	
	#unless(&do_query('show create view track_lists_view')->[0]){
	#	&do_statement("CREATE OR REPLACE VIEW track_lists_view AS 
	#				   (SELECT count(*) FROM track_product tp WHERE tp.track_list_id=tl.track_list_id) as prods_count,
	#				   (SELECT count(*) FROM track_product tp JOIN product p USING(product_id) 
	#				   		WHERE tp.track_list_id=tl.track_list_id and tp.extr_quality='icecat') as prods_described,
	#				   (SELECT count(*) FROM track_product tp WHERE tp.track_list_id=tl.track_list_id and tp.extr_quality='icecat' AND described_date!=0) as prods_editor_described,					   					    
	#				   count(tle.track_list_editor_id) as count_editors,
	#				   tl.track_list_id as track_list_id_raw,created,tle.user_id as editor_id,tl.name tl_name1,tl.name tl_name2
	#				   from track_list tl 
	#				   JOIN users lu ON lu.user_id=tl.user_id
	#				   LEFT JOIN track_list_editor tle ON tl.track_list_id=tle.track_list_id
	#				   GROUP BY tl.track_list_id");
	#}
	&prepare_params_unifiedly($atom,$call);
}

sub proc_prepare_params_ajax_track_list_editors{
	my ($atom,$call) = @_;
	
	if($USER->{'user_group'} ne 'superuser' and $USER->{'user_group'} ne 'supereditor'){
		$hin{'search_atom'}='ajax_track_list_editors'; #unless($hin{'search_atom'});
		$hin{'search_user_id'}=$USER->{'user_id'};
		$hin{'search_user_id_mode'}='=';
		$hin{'reset_search'}='';
	}
	&prepare_params_unifiedly($atom,$call);
}

sub proc_prepare_params_track_list{
 my ($atom,$call) = @_;
 my $hash={'superuser'=>1,'supereditor'=>1};
 if(!$hash->{$USER->{'user_group'}}  and $USER->{'login'} ne 'superilya'){
 	push(@user_errors,'You are not authorized to view this page');
 	hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor','editor' ] );
 	return '';
 }
 $hs{'coverage_summary'}=$hl{'coverage_summary'};
 
 &prepare_params_unifiedly($atom,$call);
 if(!$hin{'feed_config_id'} and $hin{'track_list_id'}){
 	my $dir_name=&do_query('SELECT feed_config_id FROM track_list WHERE track_list_id='.$hin{'track_list_id'})->[0][0];
 	if(!$dir_name){
 		push(@user_errors,'Track list Directory does not exists. Please contact to administartor');
 		return '';
 	}else{
 		$hin{'feed_config_id'}=$dir_name;
 	}
 }elsif(!$hin{'feed_config_id'} and !$hin{'track_list_id'}){
 	use POSIX 'floor';
 	$hin{'feed_config_id'}=time().'_'.&floor(rand(1000));
 }
 # user does not push any buttons yet so we have to replace temporary files with priviosly saved
 # othervise formats will use temporary files which user probably does not save latter  
 if($hin{'feed_config_id'} and !$hin{'feed_type'} and !$hin{'atom_update'} and !$hin{'atom_submit'}){
 	my $tmp_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/';
 	if(!(-d $tmp_dir)){
 		`mkdir $tmp_dir`;
 	} 	
	my $ready_dir=$atomcfg{"base_dir"}.'track_lists/'.$hin{'feed_config_id'}.'/';
	if(-d $ready_dir){
		`rm -R $tmp_dir*`;
		`cp -R $ready_dir* $tmp_dir`;
		`chmod 777 -R $tmp_dir`;# just is case
	}else{
		# do nothing
	}
	 set_hin_from_sql('SELECT feed_url,is_first_header,delimiter,newline,escape,quote,user_choiced_file,feed_type,feed_login,feed_pwd 
	 				   FROM track_list WHERE track_list_id='.$hin{'track_list_id'});
 }
}

sub proc_prepare_params_track_products{
	my ($atom,$call) = @_;
	if($hl{'track_list_id'}){
		$hin{'track_list_id'}=$hl{'track_list_id'};		
	}
	my $allowed_editors=&do_query('SELECT user_id FROM track_list_editor 
								   WHERE track_list_id='.$hin{'track_list_id'}.' AND user_id='.$USER->{'user_id'});
	if(!$allowed_editors->[0][0] and $USER->{'user_group'} ne 'superuser' and $USER->{'user_group'} ne 'supereditor'){
 		push(@user_errors,'You are not authorized to view this page');
 		hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
 		return '';
 	}
 	
	 if($hin{'track_list_id'}){ 
		$hs{'track_list_id'} = $hin{'track_list_id'};
	 }elsif($hl{'track_list_id'}){ 
		$hs{'track_list_id'} = $hl{'track_list_id'}; $hin{'track_list_id'} = $hl{'track_list_id'};
	 }
 	
	$hin{'tmpl'}='track_products.html';# to avoid ajax template
	$call->{'call_params'}->{'filter_key'}.='track_list_id='.$hin{'track_list_id'}.';';
	$call->{'call_params'}->{'joined_keys'}.='track_list_id='.$hin{'track_list_id'}.';';	
	
	if($hin{'ajaxed'} and $hin{'sync_only'}){
		synch_track_products($hin{'track_list_id'});
	}elsif($hin{'ajaxed'}){
			my $start_update=&do_query('SELECT unix_timestamp(start_update) FROM track_list WHERE track_list_id='.$hin{'track_list_id'})->[0][0];
			my $curr_time=&do_query('select unix_timestamp()')->[0][0];		
#			&lp('-------->>>>>>>>>>>>>>>>>>>>>>>>'.$start_update.' '.($curr_time-(3600*2)));	
			if(!$start_update or $start_update>($curr_time-(3600*2))){#list is not processed right now or it have been processing more than 2 hour
				# synchronize with removed products 
				&do_statement("UPDATE track_product tp 
							   LEFT JOIN product p ON p.product_id=tp.product_id
							   SET
								tp.extr_langs      = '',
								tp.extr_pdf_langs  = '',
								tp.extr_man_langs  = '',
								tp.extr_rel_count  = '',
								tp.extr_feat_count = '',
								tp.extr_quality    = '',
								tp.extr_ean        = '',
								tp.map_prod_id     = '',
								tp.rule_prod_id    = IF(tp.rule_status=1,tp.rule_prod_id,''),
								tp.supplier_id     = 0,
								tp.product_id      = 0,
								tp.described_date  = 0,
								tp.track_product_status ='not_described'
							   WHERE tp.product_id!=0 AND p.product_id IS NULL AND tp.track_list_id=".$hin{'track_list_id'});		
			
				&do_statement('UPDATE track_list SET start_update=now() WHERE track_list_id='.$hin{'track_list_id'});
				&do_statement("DROP TEMPORARY TABLE IF EXISTS tmp_track_product_to_mapping");			
				#&do_statement("DROP TABLE tmp_track_product_to_mapping");
				&do_statement("CREATE TEMPORARY TABLE tmp_track_product_to_mapping( 
							   id int(13) not null,
							   prod_id varchar(255) not null default '',
							   vendor varchar(255) not null default '',
							   ean varchar(255) not null default '',
							   product_id int(13) not null default 0,							   
							   supplier_id int(13) not null default 0,
							   primary key(id)
							   )");
				
				&do_statement('ALTER TABLE tmp_track_product_to_mapping disable keys');
				&do_statement('INSERT INTO tmp_track_product_to_mapping (id,prod_id,vendor,ean,product_id,supplier_id)
							   SELECT track_product_id,feed_prod_id,IF(s.supplier_id IS NULL,feed_supplier,s.name),
							   eans_joined,product_id,0
							   FROM track_product tp
							   LEFT JOIN  supplier s ON s.supplier_id=tp.supplier_id 
							   WHERE extr_quality!=\'icecat\' and track_list_id='.$hin{'track_list_id'});											   
				&do_statement('ALTER TABLE tmp_track_product_to_mapping enable keys');
				my $has_ean=&do_query('SELECT ean_cols FROM track_list WHERE track_list_id='.$hin{'track_list_id'})->[0][0];
				my $client_id=&do_query('SELECT client_id FROM track_list WHERE track_list_id='.$hin{'track_list_id'})->[0][0];
				if($has_ean){
					&coverage_by_table('tmp_track_product_to_mapping',{'ean'=>'ean'});		
				}else{
					&coverage_by_table('tmp_track_product_to_mapping',{'ean'=>''});
				}
				if($client_id){
					&do_statement("UPDATE tmp_track_product_to_mapping tp 							    
							   JOIN track_list_supplier_map sm ON sm.client_id=$client_id AND tp.vendor=sm.symbol
							   SET tp.supplier_id=sm.supplier_id
							   WHERE sm.supplier_id!=0 and tp.supplier_id=0");
				}							   
				&do_statement("UPDATE track_product tp JOIN tmp_track_product_to_mapping ttm ON ttm.id=tp.track_product_id
							   SET tp.product_id=ttm.product_id,
							       tp.rule_prod_id=   IF(ttm.by_ean_prod_id='' AND ttm.map_prod_id!=tp.map_prod_id AND tp.feed_prod_id!='' AND tp.rule_status!=1,ttm.map_prod_id,tp.rule_prod_id),
							       tp.remarks=	   	  IF(ttm.by_ean_prod_id='' AND ttm.map_prod_id!=tp.map_prod_id AND tp.feed_prod_id!='',CONCAT('correct code is ',ttm.map_prod_id),tp.remarks),
							       tp.is_reverse_rule=IF(ttm.by_ean_prod_id='' AND ttm.map_prod_id!=tp.map_prod_id AND tp.feed_prod_id!='',0,tp.is_reverse_rule),
							   	   tp.map_prod_id=IF(tp.product_id=ttm.product_id, tp.map_prod_id, ttm.map_prod_id),
							       tp.supplier_id=ttm.supplier_id,							       
							       tp.described_date=IF(ttm.quality='ICECAT' and tp.product_id!=ttm.product_id,now(),tp.described_date)
							  WHERE tp.extr_quality!='icecat'");
			synch_track_products($hin{'track_list_id'});
			&do_statement('UPDATE track_list SET start_update=0 WHERE track_list_id='.$hin{'track_list_id'});
		  }#if(!$start_update){#list is not processed right now
		my $updated_from;
		if($hin{'ajax_delta'}){
			$updated_from=&do_query('select from_unixtime(unix_timestamp() -'.($hin{'ajax_delta'}+1).')')->[0][0];
		}else{
			$updated_from=&do_query('select from_unixtime(unix_timestamp())')->[0][0];
		}
#		&lp('------------------!!!!!!!!!!!!!!!!!!!!!!!!'.$updated_from);
		# this needed to use the same atom track_product.ail but with las updated products
		$hin{'search_atom'}='track_products';						
		$hin{'search_updated'}=$updated_from;
		$hin{'search_updated_mode'}='>';		
				
	}	
	
	&prepare_params_unifiedly($atom,$call);
	
}
sub synch_track_products{
	my ($track_list_id)=@_;		
			&do_statement("UPDATE track_product tp 
		JOIN track_list tl ON tl.track_list_id=tp.track_list_id						  
		JOIN product p ON p.product_id=tp.product_id
		JOIN users u ON p.user_id=u.user_id
		JOIN user_group_measure_map gm ON u.user_group=gm.user_group
		LEFT JOIN product_ean_codes pe ON pe.product_id=p.product_id
		SET
		tp.extr_langs      = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id GROUP BY pd.product_id),
		tp.extr_pdf_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.pdf_url!='' GROUP BY pd.product_id),
		tp.extr_man_langs  = (SELECT group_concat(l.short_code separator ',') FROM product_description pd JOIN language l USING(langid) WHERE p.product_id=pd.product_id and pd.manual_pdf_url!='' GROUP BY pd.product_id),
		tp.extr_rel_count  = (SELECT count(pr.product_related_id) FROM product_related pr WHERE pr.product_id=p.product_id),
		tp.extr_feat_count = (SELECT count(pf.product_feature_id) FROM product_feature pf WHERE pf.product_id=p.product_id),
		tp.described_date  = IF(lcase(gm.measure)='icecat' and lcase(gm.measure)!=tp.extr_quality,now(),tp.described_date),
		tp.extr_quality    = lcase(gm.measure),
		tp.extr_ean        = pe.ean_code,
		tp.map_prod_id     = IF(tp.map_prod_id='',p.prod_id,tp.map_prod_id),
		tp.supplier_id     = IF(tp.supplier_id=0,p.supplier_id,tp.supplier_id),
		track_product_status = (IF(tp.is_parked=1,'parked',IF(gm.measure='ICECAT','described','not_described')))
		WHERE tp.track_list_id=".$track_list_id);
		&do_statement("UPDATE track_product SET track_product_status='parked' where product_id=0 and is_parked=1 and track_list_id=$track_list_id");
		&do_statement("UPDATE track_product SET track_product_status='not_described' where product_id=0 and is_parked=0 and track_list_id=$track_list_id");				
}

sub proc_prepare_params_track_products_all{
	my ($atom,$call) = @_;	
	my $entusted_editor=&do_query('SELECT 1 FROM track_list_entrusted_users WHERE user_id='.$USER->{'user_id'})->[0][0];
	if(!$entusted_editor){	
	 	hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
	}
 	&prepare_params_unifiedly($atom,$call);
 	if($hin{'ajaxed'}){
 		$call->{'call_params'}->{'filter_key'}.='track_product_id='.$hin{'track_product_id'}.';';
		$call->{'call_params'}->{'joined_keys'}.='track_product_id='.$hin{'track_product_id'}.';';
		$call->{'call_params'}->{'restrict'} = ' tp.track_product_id='.$hin{'track_product_id'}.' ';
 	}
 	
}
 	
sub proc_prepare_params_track_list_settings{
	my ($atom,$call) = @_;
	my $hash={'superuser'=>1,'supereditor'=>1};
 	unless($hash->{$USER->{'user_group'}}){
 		push(@user_errors,'You are not authorized to view this page');
 		hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor'] );
 		return '';
 	}
 	&prepare_params_unifiedly($atom,$call);
} 

sub proc_prepare_params_product_restrictions {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}

sub proc_prepare_params_product_restrictions_details {
    my ($atom,$call) = @_;
    &prepare_params_unifiedly($atom,$call);
    hide_atom_for_all_groups_except($atom, [ 'superuser' , 'supereditor' ] );
    return;
}


1;

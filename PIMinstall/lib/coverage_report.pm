package coverage_report;

#$Id: coverage_report.pm 3726 2011-01-14 16:01:38Z alexey $

use strict;

use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_util;
use atom_misc;
use icecat_util;
use atom_mail;
use data_management;
use icecat_mapping;
use pricelist qw(convert_xls_csv get_csv_rows);
use POSIX qw(strftime);

use Data::Dumper;

#use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);
#use stat_lib;
#use Time::HiRes 'time';

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
					&generate_coverage_report
					&prepare_coverage_tmp_tables
					&prepare_coverage_filter
					&report_products
					&coverage_by_table
					&get_feed_file
					&load_coverage_track_list
					&send_coverage_from_file_report
					&get_xls_cov_report
					&get_csv_cov_report
					&get_coverage_sumary_by_table
					&create_cov_cache_table
					&get_cov_report_file_first_row
					);
}

sub generate_coverage_report {
	my ($rep_class) = @_;

	return if($hin{'reload'} ne 'Report');

	if ($rep_class eq 'products') {
		return report_products();
	}
	elsif ($rep_class eq 'features') {
		return report_features();
	}
}

sub format {
	my ($value,$width,$class,$weight,$color,$params)=@_;

	$width = $width? " width=\"$width\"" : '';
	$class = $class? " class=\"$class\"" : '';
	$weight = $weight? ' style="font-weight: bold"':'';
	$color = $color? " style=\"color:$color;font-size:9pt\"":'';

	if ($params) {
		if ($value && !$hin{'analyze_pl'}) {
			$value = "<a $color href=\"/index.cgi?sessid=$hl{sesscode};mi=products;tmpl=products.html;filter=$params\">$value%</a>";
		}
		else {
			$value = "<span $color>$value%</span>";
		}
	}
	else {
		$value = "&nbsp;&nbsp;$value";
	}

	return "<td $width$class$weight>&nbsp;$value</td>\n";
}

sub report_row {
	my($row,$title,$bold,$hash) = @_;

	my ($tr,$p2,$p3,$p4,$p5)=('',0,0,0,0);
	if($row->[1]>0){
		$p2 = sprintf("%.0f",$row->[2]/$row->[1]*100);
		$p3 = sprintf("%.0f",$row->[3]/$row->[1]*100);
		$p4 = sprintf("%.0f",$row->[4]/$row->[1]*100);
		$p5 = sprintf("%.0f",$row->[5]/$row->[1]*100);
	}
	my @params;
	for my $key(keys %$hash){
		push @params,$key.':'.$hash->{$key} if($key && $hash->{$key});
	}
	my $params = join(',',@params);
	$tr = '<tr><td class="main info_bold">&nbsp;'.$title.'</td>'.
		format($row->[1],'8%','main info_bold',$bold).
	  format($row->[2],'6%','main info_bold',$bold).
	  format($p2,'6%','main info_bold',$bold,'green',$params.',col:3').
	  format($row->[3],'6%','main info_bold',$bold).
	  format($p3,'6%','main info_bold',$bold,'red',$params.',col:0').
	  format($row->[4],'6%','main info_bold',$bold).
	  format($p4,'6%','main info_bold',$bold,'blue',$params.',col:2').
	  format($row->[5],'6%','main info_bold',$bold).
	  format($p5,'6%','main info_bold',$bold,'blue',$params.',col:1').
		'</tr>';
	return $tr;
}

sub report_features {
	my $report = '';
	my $totals = ['',0,0,0,0];

	if($hin{'search_catfeat_id'}){
		if(do_query("select 1 from category_feature
			where catid = ".$hin{search_catid}."
			and category_feature_id = ".$hin{search_catfeat_id})->[0][0] != 1) {
			return "<p><font face=Verdana size=2 color=green>Category features were loaded. Press <b>[Report]</b> again.</font></p>";
		}
	}else{
		return "<p><font face=Verdana size=2 color=red>Undefined category feature!</b></font></p>";
	}

  my %rep_params = (
    'type' => 2,
    'supp' => $hin{'search_supplier_id'},
    'dist' => $hin{'search_distri_id'},
    'cat' => $hin{'search_catid'},
    'feat' => $hin{'search_catfeat_id'},
    'stock' => $hin{'on_stock'}
  );

  prepare_coverage_tmp_tables(\%rep_params);

  my $search_cnt = do_query("select sfeatures from itmp_4c_desc_category where catid=".$hin{'search_catid'})->[0][0];

	if($hin{'search_distri_id'} eq '0'){
		
		my $bysup = do_query("select name, count(*) as cnt, sum(if(sfeatures = desc_sfeatures and sfeatures > 0,1,0)), 0, sum(if(desc_feature=1,1,0)), p.supplier_id
			from itmp_4c_product p
inner join supplier using (supplier_id)
inner join itmp_4c_desc_product dsp on p.product_id=dsp.product_id
inner join itmp_4c_distinct dp on p.product_id=dp.product_id
group by p.supplier_id order by cnt desc");

    $report .= '
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
<th class="main info_header" rowspan=2>Suppliers</th>
<th class="main info_header" rowspan=2>Total products</th>
<th class="main info_header" colspan=4>Searchable features (<b>'.$search_cnt.'</b>)</th>
<th class="main info_header" colspan=4>Selected category feature</th></tr>
<tr><th class="main info_header" colspan=2>all described</th><th class="main info_header" colspan=2>undescribed</th>
<th class="main info_header" colspan=2>described</th><th class="main info_header" colspan=2>undescribed</th>
</tr>';

		for my $row (@$bysup){
      my %supp_params = %rep_params;
      $supp_params{'supp'} = $row->[5];
			if($search_cnt>0){ $row->[3]=$row->[1]-$row->[2]; }
			$row->[5]=$row->[1]-$row->[4];
			for my $i (1..5) { $totals->[$i]+=$row->[$i]; }
      $report .= report_row($row,'<b>'.$row->[0].'</b>',0,\%supp_params);
		}
	}
	else {
		my $bydist = do_query("select name, count(*), sum(if(sfeatures=desc_sfeatures and sfeatures>0,1,0)), 0, sum(if(desc_feature=1,1,0)), d.distributor_id, d.last_import_date
from itmp_4c_product p
inner join itmp_4c_desc_product dsp on p.product_id=dsp.product_id
inner join itmp_4c_distributor_product dp on p.product_id=dp.product_id
inner join distributor d using (distributor_id)
group by d.distributor_id order by name");

    my $colname = "any supplier";
    if ($hin{'search_supplier_id'}){
      $colname = '<b>'.do_query("select name from supplier where supplier_id=".$hin{'search_supplier_id'})->[0][0].'</b>';
    }
    $report .= '
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
<th class="main info_header" rowspan=2>Distributors ('.$colname.')</th>
<th class="main info_header" rowspan=2>Total products</th>
<th class="main info_header" colspan=4>Searchable features (<b>'.$search_cnt.'</b>)</th>
<th class="main info_header" colspan=4>Selected category feature</th></tr>
<tr><th class="main info_header" colspan=2>all described</th><th class="main info_header" colspan=2>undescribed</th>
<th class="main info_header" colspan=2>described</th><th class="main info_header" colspan=2>undescribed</th>
</tr>';
		
		for my $row (@$bydist){
      my %dist_params = %rep_params;
      $dist_params{'dist'} = $row->[5];
			if ($search_cnt>0) {
				$row->[3] = $row->[1] - $row->[2];
			}
			$row->[5] = $row->[1] - $row->[4];
			$report .= report_row($row,'<b>'.$row->[0].'</b>',0,\%dist_params);
		}
		$totals = do_query("select count(*),count(*),sum(if(sfeatures=desc_sfeatures and sfeatures>0,1,0)), 0, sum(if(desc_feature=1,1,0))
from itmp_4c_product p
inner join itmp_4c_desc_product dsp on p.product_id=dsp.product_id
inner join itmp_4c_distinct dp on p.product_id=dp.product_id")->[0];
    if ($search_cnt > 0) {
			$totals->[3] = $totals->[1]-$totals->[2];
		}
    $totals->[5] = $totals->[1]-$totals->[4];
	}
	return $report.report_row($totals,'<font color=darkgray><b>summary</b></font>',1,\%rep_params).'</table></td></tr></table></td></tr></table>';
}


sub report_products {
	my ($file, $d_code) = @_;

	my $report = '';
	my $totals = ['',0,0,0,0];
	my $last_import_date;
	
	my %rep_params = (
		'type' => 1,
		'supp' => $hin{'search_supplier_id'},
		'cat' => $hin{'search_catid'},
		'dist' => $hin{'search_distri_id'},
		'scat' => $hin{'show_subtotals'},
		'stock' => $hin{'on_stock'}
		);
	
	prepare_coverage_tmp_tables(\%rep_params,$file);
	`/bin/rm -f $file` if($file);
	
	if($hin{'search_distri_id'} eq '0' || $file){
		my $bysup = do_query("select name, count(*) as cnt, sum(if(quality>0,1,0)), sum(if(quality=0,1,0)), sum(if(quality=2,1,0)), sum(if(quality=1,1,0)), p.supplier_id 
		from itmp_4c_product as p
		inner join supplier using (supplier_id)
		inner join itmp_4c_distinct as dp using (product_id)
		group by p.supplier_id order by cnt desc");
		
		$report .= '
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
			<th class="main info_header">Suppliers</th>
			<th class="main info_header">Total products</th>
			<th class="main info_header" colspan=2>Described</th>
			<th class="main info_header" colspan=2>NOEDITOR</th>
			<th class="main info_header" colspan=2>SUPPLIER</th>
			<th class="main info_header" colspan=2>ICECAT</th></tr>'.
"\n";
		my $cover = $report if($d_code);
		
		for my $row (@$bysup) {
			for my $i (1..5) { $totals->[$i]+=$row->[$i]; }
			my %supp_params = %rep_params;
			$supp_params{'supp'} = $row->[6];
			$report .= report_row($row,'<b>'.$row->[0].'</b>',0,\%supp_params);
			if ($hin{'show_subtotals'}) {
				my $bycat = do_query("select value, count(*) as total_cnt, sum(if(quality>0,1,0)), sum(if(quality=0,1,0)), sum(if(quality=2,1,0)), sum(if(quality=1,1,0)), p.catid
from itmp_4c_product as p
inner join category as c on p.catid=c.catid
inner join vocabulary as v on c.sid=v.sid and v.langid=1
inner join itmp_4c_distinct as dp on p.product_id=dp.product_id
where p.supplier_id=$row->[6] group by p.catid order by total_cnt,value");

				my %scat_params = %supp_params;
				delete $scat_params{'scat'};
				for my $row (@$bycat) {
					$scat_params{'cat'} = $row->[6];
					$report .= report_row($row,'&nbsp;&nbsp;&nbsp;'.$row->[0],0,\%scat_params);
				}
			}
		}
		
		if ($file) {
			$cover = quotemeta($cover.report_row($totals,'<font color=darkgray><b>summary</b></font>',1,\%rep_params).'</table>') if($d_code);
			do_statement("update distributor_pl set updated=now(), coverage='".$cover."' where code='".$d_code."'") if($d_code);
			return $report.report_row($totals,'<font color=darkgray><b>summary</b></font>',1,\%rep_params).'</table>';
		}
	}
	else {
		my $bydist = do_query("select name,count(*),sum(if(quality>0,1,0)),
			sum(if(quality=0,1,0)),sum(if(quality=2,1,0)),sum(if(quality=1,1,0)),dp.distributor_id, d.last_import_date, d.file_creation_date
			from itmp_4c_product as p, itmp_4c_distributor_product as dp, distributor as d
			where p.product_id=dp.product_id and dp.distributor_id=d.distributor_id
			group by dp.distributor_id order by name");
		
		my $colname = "any supplier";
		if ($hin{'search_supplier_id'}) {
			$colname = '<b>'.do_query("select name from supplier where supplier_id=".$hin{'search_supplier_id'})->[0][0].'</b>';
		}
		$report .= '
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
<th class="main info_header">Distributors ('.$colname.')</th>
<th class="main info_header">Total products</th>
<th class="main info_header" colspan=2>Described</th>
<th class="main info_header" colspan=2>NOEDITOR</th>
<th class="main info_header" colspan=2>SUPPLIER</th>
<th class="main info_header" colspan=2>ICECAT</th></tr>';
		
		for my $row (@$bydist) {
			my %dist_params = %rep_params;
			$dist_params{'dist'} = $row->[6];

			# last import date & file creation date -> into the abbr
			$last_import_date = $row->[7] unless $last_import_date;

			$report .= report_row($row,'<b>'.$row->[0].'</b>' . ($row->[8] ? ' ('.strftime("%Y-%m-%d %H:%M:%S", localtime($row->[8])).')' : ''),0,\%dist_params);
			if ($hin{'show_subtotals'}) {
				my $bycat = do_query("select value,count(*),sum(if(quality>0,1,0)),
					sum(if(quality=0,1,0)),sum(if(quality=2,1,0)),sum(if(quality=1,1,0)),p.catid
					from itmp_4c_product as p, itmp_4c_distributor_product as dp, category as c, vocabulary as v
					where p.product_id=dp.product_id and p.catid=c.catid and c.sid=v.sid and v.langid=1
					and dp.distributor_id=$row->[6] group by p.catid order by value");
				my %scat_params = %dist_params;
				delete $scat_params{'scat'};
				for my $row (@$bycat) {
					$scat_params{'cat'} = $row->[6];
					$report .= report_row($row,'&nbsp;&nbsp;&nbsp;'.$row->[0],0,\%scat_params);
				}
			}
		}	
		$totals = do_query("select count(*),count(*),sum(if(quality>0,1,0)),sum(if(quality=0,1,0)),sum(if(quality=2,1,0)),sum(if(quality=1,1,0))
from itmp_4c_product as p, itmp_4c_distinct as dp, itmp_4c_desc_category as c where p.product_id=dp.product_id and p.catid=c.catid limit 1")->[0];
	}
	
	return $report.report_row($totals,'<font color=darkgray><b>summary</b>' . ( $last_import_date ? ' (last import date is '.strftime("%Y-%m-%d %H:%M:%S", localtime($last_import_date)).')' : '' ) . '</font>',1,\%rep_params).'</table></td></tr></table></td></tr></table>';
}

sub prepare_coverage_tmp_tables {
	my ($hash,$file) = @_;

	my $report_type = $hash->{'type'};
	my $supplier = $hash->{'supp'};
	my $catid = $hash->{'cat'};
	my $distri = $hash->{'dist'};
	my $feat = $hash->{'feat'};
	
	my ($supplier_clause,$catid_clause);
	
	if ($supplier) {
		$supplier_clause = " and p.supplier_id = ".$supplier;
	}
	if ($catid>1) {
		if (($report_type==2) || ($hash->{'scat'}!=1)) {
			$catid_clause=" and catid = ".$catid;
		}
		else {
		  my $rows = do_query("select catid, pcatid from category");
		  my $cats_by_owner;
			for my $row (@$rows) {
				my ($catid,$catownerid) = @{$row};
				push @{$cats_by_owner->{$catownerid}},$catid;
			}
		  my @catids;
			sub get_catids {
				my ($id) = @_;
				push @catids,$id;
				for my $subid (@{$cats_by_owner->{$id}}) {
					get_catids($subid);
				}
			}
			
			get_catids($catid);
		  $catid_clause = "and catid in (".join(',',@catids).")";
		}
	}
	
	my $temp = 'temporary';	

	do_statement("drop $temp table if exists itmp_4c_product");
	do_statement("drop $temp table if exists itmp_4c_distributor_product");
	do_statement("drop $temp table if exists itmp_4c_desc_category");
	do_statement("drop $temp table if exists itmp_4c_desc_product");
	do_statement("drop $temp table if exists itmp_4c_distinct");

	do_statement("create $temp table itmp_4c_product (
		product_id  int(13)      unsigned not null default 0,
		supplier_id mediumint(7) unsigned not null default 0,
		catid       mediumint(7) unsigned not null default 0,
		user_id     mediumint(7) unsigned not null default 0,
		quality     tinyint(1)   unsigned not null default 0,
		sfeatures   smallint(5)  unsigned not null default 0,
		primary key (product_id),
		key (catid),
		key (supplier_id, catid),
		key (user_id)) ENGINE = MEMORY");

	do_statement("create $temp table itmp_4c_distributor_product (
		product_id     int(13)      unsigned not null default 0,
		distributor_id mediumint(7) unsigned not null default 0) ENGINE = MyISAM");

	do_statement("create $temp table itmp_4c_desc_category (
		catid     mediumint(7) unsigned primary key,
		sfeatures smallint(5)  unsigned not null default 0) ENGINE = MEMORY");

	do_statement("create $temp table itmp_4c_desc_product (
		product_id     int(13)     unsigned not null default 0,
		desc_sfeatures smallint(5) unsigned not null default 0,
		desc_feature   tinyint(1)  unsigned not null default 0,
		primary key (product_id)) ENGINE = MyISAM");	

	do_statement("create $temp table itmp_4c_distinct (product_id int(13) primary key) ENGINE = MEMORY");

	do_statement("alter table itmp_4c_desc_category disable keys");
	do_statement("insert into itmp_4c_desc_category select catid, sum(searchable) from category_feature where 1 $catid_clause group by catid");
	do_statement("alter table itmp_4c_desc_category enable keys");
	
	do_statement("create $temp table itmp_4c_category_feature (
		category_feature_id int(13)      unsigned not null default 0,
		catid               mediumint(7) unsigned not null default 0,
		searchable          tinyint(1)   unsigned not null default 0,
		primary key (category_feature_id)) ENGINE = MyISAM");

	do_statement("insert into itmp_4c_category_feature select category_feature_id, catid, searchable from category_feature where 1 $catid_clause");
	
	my $c_on_market = "cp.active>0";
	my $d_on_market = "dp.active>0";

	# a LOT of time
	if ($file) {
		$c_on_market = "1";
		$d_on_market = "1";
		do_statement("drop $temp table if exists tmp_pl_products");
		do_statement("create $temp table tmp_pl_products(
			id int(13) primary key auto_increment,
                        prodlevid   varchar(235) not null default '',
                        prod_id     varchar(235) not null default '',
                        supplier    varchar(36)  not null default '',
                        category    varchar(64)  not null default '',
                        subcategory varchar(64)  not null default '',
                        name        varchar(64)  not null default '',
                        description text,
                        euprice     int(13)      not null default 0,
                        euprice_vat int(13)      not null default 0,
                        stock       int(13)      not null default 0,
                        distributor varchar(36)  not null default '',
                        image       varchar(235) not null default '',
                        ean         char(13)     not null default '',

			                  supplier_id int(13)      not null default '0',
			                  product_id  int(13)      not null default '0',

                        key (prod_id,ean),
                  			key (supplier),
                  			key (supplier_id))");
		do_statement("alter table tmp_pl_products disable keys");
		do_statement("load data local infile \"".$file."\" into table tmp_pl_products fields escaped by '".$hin{'esc_c'}."' terminated by '\\t' lines terminated by '\\n'
			(prodlevid,prod_id,supplier,category,subcategory,name,description,euprice,euprice_vat,stock,distributor,image,ean,\@dummy,\@dummy)");
		do_statement("alter table tmp_pl_products enable keys");
		
		# supplier mapping
		do_statement("update tmp_pl_products t inner join supplier s on t.supplier=s.name set t.supplier_id=s.supplier_id");
		do_statement("update tmp_pl_products t inner join data_source_supplier_map s on t.supplier=s.symbol and s.data_source_id=1 set t.supplier_id=s.supplier_id where t.supplier_id=0");
		
		my $query = "select 0, supplier_id, pattern, 0, map_supplier_id from product_map";

		# prod_id mapping
		template_prod_id_mapping_DEPRECATED("tmp_pl_products", undef, $query);
		
		do_statement("update tmp_pl_products tpp inner join product p using(prod_id) set tpp.product_id=p.product_id");
		
		do_statement("alter table itmp_4c_product disable keys");
		do_statement("insert ignore into itmp_4c_product select p.product_id, p.supplier_id, p.catid, p.user_id, 0, 0 
				from product p 
				inner join tmp_pl_products tpp using(prod_id)");
		
		do_statement("insert ignore into itmp_4c_product select p.product_id, p.supplier_id, p.catid, p.user_id, 0, 0 
                                from product p 
				inner join product_ean_codes pec on p.product_id=pec.product_id
				inner join tmp_pl_products tpp on tpp.ean=pec.ean_code");
		do_statement("alter table itmp_4c_product enable keys");
		
	}
	else {
		do_statement("alter table itmp_4c_product disable keys");

		# get product info from product_memory table
		my @arr = get_primary_key_set_of_ranges('p','product_memory',500000,'product_id'); # 1/2 million
		my $b_cond;
		for $b_cond (@arr) {
			do_statement("insert into itmp_4c_product(product_id,supplier_id,catid" . ( $report_type == 1 ? ",user_id" : '' ) .")
select p.product_id, p.supplier_id, p.catid" . ( $report_type == 1 ? ", p.user_id" : '' ) . " 
from product_memory p force key (product_id)
where 1 ".$supplier_clause." ".$catid_clause.' AND '.$b_cond);
		}
		
		do_statement("alter table itmp_4c_product enable keys");
	}
	
	if ($report_type == 1 || $file) { # product
		do_statement("update itmp_4c_product p
inner join users u                        using (user_id)
inner join user_group_measure_map ugmm    using (user_group)
inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure
set   p.quality = cmim.quality_index");
	}
	elsif ($report_type == 2) { # feature
		do_statement("update itmp_4c_product p inner join itmp_4c_desc_category c using (catid) set p.sfeatures=c.sfeatures");
	}
	
	my ($distri_clause,$stock_clause_dp,$stock_clause_cp);
	
	if (($distri>0) && ($distri ne 'all')) {
		$distri_clause = " and distributor_id = ".$distri;
	}
	
	if ($hash->{'stock'}) {
		$stock_clause_cp = " and cp.stock > 0";
		$stock_clause_dp = " and dp.stock > 0";
	}
	
	#log_printf("Q (coverage_report.pm): \n" . do_query_dump("explain select distinct p.product_id, distributor_id
	#from itmp_4c_product p
	#inner join country_product cp on cp.product_id=p.product_id
	#left join distributor_product dp on dp.product_id=p.product_id
	#where ".$c_on_market." and ".$d_on_market." ".$stock_clause_dp." ".$stock_clause_cp." ".$distri_clause));
	
	do_statement("alter table itmp_4c_distributor_product disable keys");

	if ($distri) {
		do_statement("insert into itmp_4c_distributor_product
		select distinct p.product_id, distributor_id
		from       itmp_4c_product p
		inner join country_product cp on cp.product_id=p.product_id
		left join  distributor_product dp on dp.product_id=p.product_id
		where      $c_on_market and $d_on_market $stock_clause_dp $stock_clause_cp $distri_clause");
	}
	else {
		do_statement("insert into itmp_4c_distributor_product
		select distinct p.product_id, 1
		from       itmp_4c_product p
		inner join country_product cp on cp.product_id=p.product_id
		where      $c_on_market $stock_clause_cp");
	}

	do_statement("alter table itmp_4c_distributor_product enable keys");

	do_statement("alter table itmp_4c_distinct disable keys");
	do_statement("insert into itmp_4c_distinct select distinct product_id from itmp_4c_distributor_product");
	do_statement("alter table itmp_4c_distinct enable keys");

	if ($report_type == 2) {
		my $data = do_query("select category_feature_id from itmp_4c_category_feature where searchable=1");
		my @cfids = ($feat);
		
		for (@$data) {
			push @cfids, $_->[0];
		}
		
		my $feat_clause = " and pf.category_feature_id in (".join(',',@cfids).")";
		do_statement("alter table itmp_4c_desc_product disable keys");
		do_statement("insert into itmp_4c_desc_product select pf.product_id, sum(if(if(pf.value!='',1,0)=1 and cf.searchable=1,1,0)), sum(if(pf.category_feature_id = ".$feat." and if(value!='',1,0)=1,1,0))
			from product_feature pf
			inner join category_feature cf using (category_feature_id)
			inner join itmp_4c_product p on p.product_id=pf.product_id 
			where 1 $feat_clause
			group by pf.product_id");
		do_statement("alter table itmp_4c_desc_product enable keys");
	}
}

sub prepare_coverage_filter {
	my ($filter) = @_;

	log_printf("FILTER = ".$filter);
	
	#check if we will use ready set of products into table instead of filter 
	my @arr=split(/,/,$filter);
	my $cache_table_found=0;
	my $cache_table_join='';
	my $cache_table_join_on='';
	for my $pair_str (@arr){
		my @pair_arr=split(/:/,$pair_str);
		if($pair_arr[0] eq 'table' and $pair_arr[1]){
			$cache_table_found=1;
			$cache_table_join.=" INNER JOIN $pair_arr[1] tmp_tbl ON p.product_id=tmp_tbl.product_id ";
		}elsif($pair_arr[0] and $pair_arr[1]){ # all other are conditions to cache table
			$cache_table_join_on.=" AND tmp_tbl.$pair_arr[0]=$pair_arr[1] "
		}
	}
	return $cache_table_join.$cache_table_join_on if $cache_table_found;
	
	my $filter_tbl_name = $filter;
	my @filter_keys = split(/,/,$filter);
	my %filter_hash;

	for (@filter_keys) {
		my @couple = split(/:/,$_);
		if ($#couple == 1) {
			$couple[0] =~ s/[^_a-zA-Z1-9]/0/g;
			$couple[1] =~ s/[^_a-zA-Z1-9]/0/g;
			$filter_hash{$couple[0]} = $couple[1];
		}
	}

	my $isRightFilter = 1;
	my $i = 0;
	my $current_epoch = '0';	 
	my @result_filter_params;

	my $filter_tbl_name_notime;
	$hin{'filter_toString'} = '';

	# only product filters allowed, otherwise cache table won't created 
	if ((defined $filter_hash{'type'}) && (defined $filter_hash{'col'})) {
		log_printf("filter is active!");

		@filter_keys = sort keys %filter_hash;
		for (@filter_keys) {
			$result_filter_params[$i] = $filter_hash{$_};
			$i++;
		};
		$current_epoch = do_query('SELECT UNIX_TIMESTAMP()')->[0][0];

		$filter_tbl_name_notime = 'itmp_f_'.join('_',@result_filter_params)."_end";
		$filter_tbl_name = $filter_tbl_name_notime.'_'.$current_epoch; # creating table name from filter parametrs
	}
	else{
		$isRightFilter = 0;
	}

  if ($isRightFilter) {

		my $filter_tbl_name_notime4MySQL_like = $filter_tbl_name_notime;
		$filter_tbl_name_notime4MySQL_like =~ s/\_/\\_/gs;

    my $tmp_filter_tbl = do_query("show tables like '".$filter_tbl_name_notime4MySQL_like."\\_%'")->[0][0];

		# prepare filter params
		
		my @params = split(',',$filter);
		my %params;
		
		for my $param (@params) {
			my ($key,$value) = split(':',$param);
			$params{$key} = $value;
		}

		if (!$tmp_filter_tbl) {
			log_printf("creating filter cache table: '$filter_tbl_name'");

			prepare_coverage_tmp_tables(\%params);

			my $select = "insert into $filter_tbl_name (product_id) select distinct p.product_id from itmp_4c_product as p, itmp_4c_distributor_product as dp, ";
			
			my ($supp_clause,$distri_clause,$cat_clause,$qual_clause,$desc_clause);
			
			if ($params{'dist'} && ($params{'dist'} ne 'all')) {
				$distri_clause = " and dp.distributor_id = ".$params{dist};
			}
			
			if ($params{'scat'} != 1) {
				if ($params{'cat'} > 1) {
					$cat_clause = " and p.catid = ".$params{cat};
				}
			}
			else {
				$cat_clause = " and p.catid = c.catid ";
			}
			
			if ($params{'supp'}) {
				$supp_clause = " and p.supplier_id = ".$params{supp};
			}
			
			if ($params{'col'} == 3) {
				$qual_clause = " and p.quality > 0";
				$desc_clause = " and sfeatures = desc_sfeatures and sfeatures > 0";
			}
			else {
				$qual_clause = " and p.quality = ".$params{col};
				$hin{'filter_toString'} .= 'described only, ';
				if ($params{'col'} == 0) {
					$desc_clause = " and not (sfeatures = desc_sfeatures and sfeatures > 0)";
				}
				elsif($params{'col'} == 2) {
					$desc_clause = " and desc_feature = 1";
				}
				else {
					$desc_clause = " and desc_feature = 0";
				}
			}
			
			do_statement("drop temporary table if exists $filter_tbl_name");
			do_statement("create temporary table if not exists $filter_tbl_name (product_id int(13), primary key(product_id)) ENGINE = MyISAM");
			
			if ($params{'type'} == 1) {
				do_statement($select." itmp_4c_desc_category as c where p.product_id=dp.product_id ".$supp_clause." ".$distri_clause." ".$cat_clause." ".$qual_clause);
			}
			else {
				do_statement($select." itmp_4c_desc_product as dsp where p.product_id = dsp.product_id and p.product_id = dp.product_id ".$supp_clause." ".$distri_clause." ".$cat_clause." ".$desc_clause);
			}
		} #(!$tmp_filter_exist)

		# prepare filter string
		
		if ($params{'dist'} && ($params{'dist'} ne 'all')) {
			$hin{'filter_toString'} .= ( do_query("select name from distributor where distributor_id=".$params{dist})->[0][0] || '(unknown)' ) . ', ';
		}
		if ($params{'dist'} eq 'all') {
			$hin{'filter_toString'} .= 'all distributors, ';
		}
		if ($params{'scat'} != 1) {
			if ($params{'cat'} > 1) {
				$hin{'filter_toString'} .= ( do_query("select v.value from vocabulary v inner join category c on c.sid=v.sid and v.langid=1 where c.catid=".$params{cat})->[0][0] || '(unknown)' ) . ', ';
			}
		}
		if ($params{'supp'}) {
			$hin{'filter_toString'} .= ( do_query("select name from supplier where supplier_id=".$params{supp})->[0][0] || '(unknown)' ) . ', ';
		}
#		if ($params{'col'} != 3) {
#			$hin{'filter_toString'} .= 'described only products, ';
#		}
		if ($hin{'filter_toString'}) {
			chop($hin{'filter_toString'});
			chop($hin{'filter_toString'});
#			$hin{'filter_toString'} = str_htmlize($hin{'filter_toString'});
		}


		log_printf("DV: ".$hin{'filter_toString'});

		if ($tmp_filter_tbl) {
			return " inner join $tmp_filter_tbl filter_p on p.product_id=filter_p.product_id ";
		}
		else {
			return " inner join $filter_tbl_name filter_p on p.product_id=filter_p.product_id ";
		}
  }
}

sub coverage_by_table {
	my ($product_table,$params)=@_;
	my $debug_tmp="TEMPORARY";
	#my $debug_tmp="";
	return  unless $product_table;
	
	##
	## begin of our damned script
	##
	
	my $has_ean = 0;
	my $has_vendor = 0;
	
	# complete columns
	
	my $h = {
		'vendor' => 1,
		'supplier_id' => 1,
		'id' => 1,
		'product_id' => 1,
		'prod_id' => 1,
		'quality' => 1,
		'editor' => 1,
		'link' => 1,
		'access' => 1
	};
	
	my $cols = do_query("desc ".$product_table);
	
	for (@$cols) {
	#	log_printf($_->[0]."\n");
		delete $h->{$_->[0]};
		if (($_->[0] eq 'ean') && ($params->{'ean'})) {
			$has_ean = 1;
		}
		if ($_->[0] eq 'vendor') {
			unless (do_query("select count(*) from ".$product_table." where vendor is null")->[0][0]) {
				$has_vendor = 1;
			}
		}
	}
	
	for (keys %$h) {
		if ($_ eq 'vendor') {
			do_statement("alter table ".$product_table." add column `vendor` varchar(60) NULL");
			log_printf("Warning!.. Vendor is absent.");
		}
		elsif ($_ eq 'supplier_id') {
			do_statement("alter table ".$product_table." add column `supplier_id` int(13) NOT NULL default '0', add key (`supplier_id`)");
			log_printf("adding supplier_id\n");
		}
		elsif ($_ eq 'id') {
			do_statement("alter table ".$product_table." add column `id` int(13) NOT NULL auto_increment, add primary key (`id`)");
			log_printf("Adding absent primary key.");
		}
		elsif ($_ eq 'product_id') {
			do_statement("alter table ".$product_table." add column `product_id` int(13) NOT NULL default '0', add key (`product_id`)");
			log_printf("adding product_id\n");
		}
		elsif ($_ eq 'prod_id') {
			do_statement("alter table ".$product_table." add column `prod_id` varchar(60) NOT NULL default '', add key (`prod_id`)");
			log_printf("adding product_id\n");
			log_printf("mprod_id is missing.");
			unless ($has_ean) {
				log_printf("exiting!!!!!!!!!");
				return '';
			}
			else {
			}
		}
		elsif ($_ eq 'quality') {
			do_statement("alter table ".$product_table." add column `quality` varchar(60) NOT NULL default ''");
			log_printf("adding quality\n");
		}
		elsif ($_ eq 'editor') {
			do_statement("alter table ".$product_table." add column `editor` varchar(60) NOT NULL default ''");
			log_printf("adding editor\n");
		}
		elsif ($_ eq 'link') {
			do_statement("alter table ".$product_table." add column `link` varchar(255) NOT NULL default ''");
			log_printf("adding link\n");
		}
		elsif ($_ eq 'access') {
			do_statement("alter table ".$product_table." add column `access` char(4) NOT NULL default ''");
			log_printf("adding access\n");
		}
	}
	do_statement("alter table ".$product_table." add column `by_ean_prod_id` varchar(255) NOT NULL default ''");	
	# starting
	
	log_printf("Start (total products = " . do_query("select count(*) from ".$product_table)->[0][0] . "):\n\n");
	
	# remove products w/o prod_ids
	my $product_table_saved=$product_table.'_saved';
	do_statement("DROP $debug_tmp TABLE IF EXISTS $product_table_saved");
	do_statement("CREATE $debug_tmp TABLE $product_table_saved LIKE $product_table");
	do_statement("ALTER TABLE $product_table_saved DISABLE KEYS");
	if ($has_ean) {
		do_statement("INSERT INTO $product_table_saved SELECT * FROM $product_table WHERE prod_id='' and ean=''");
		do_statement("delete from ".$product_table." where prod_id='' and ean=''");
	}
	else {
		do_statement("INSERT INTO $product_table_saved SELECT * FROM $product_table WHERE prod_id=''");
		do_statement("delete from ".$product_table." where prod_id=''");
	}
	log_printf("remove bad products: " . do_query("select row_count()")->[0][0] . "");
	
	if ($has_vendor) {
	# supplier mapping
	
		do_statement("update ".$product_table." t inner join supplier s on t.vendor=s.name set t.supplier_id=s.supplier_id where t.supplier_id=0");
		log_printf("supplier map: #1 = " . do_query("select row_count()")->[0][0] . ", ");
		do_statement("update ".$product_table." t inner join data_source_supplier_map s on t.vendor=s.symbol and s.data_source_id=1 set t.supplier_id=s.supplier_id where t.supplier_id=0");
		log_printf("#2 = " . do_query("select row_count()")->[0][0] . "");
	}
	else {
		log_printf(" haven't vendor...");
	}
	
	# prod_id mapping
	
	log_printf("product map:\n");
	
	prod_id_mapping({'table' => $product_table, 'visual' => '0'});
	#do_statement("update ".$product_table." set supplier_id=map_supplier_id, prod_id=map_prod_id");
	
	# ean_mapping
	do_statement("ALTER TABLE $product_table ADD COLUMN droped_ean varchar(255) not null default '' ");
	if ($has_ean) {
		log_printf("\nproduct_id (ean): ");
		
		#do_statement("update ".$product_table." set ean='' where ean=0");
		#do_statement("UPDATE $product_table SET droped_ean=ean WHERE  length(ean)<12");
		#do_statement("update ".$product_table." set ean='' where length(ean)<12");
		#do_statement("update ".$product_table." set ean=trim(leading '0' from ean)");


		# if we have ean,ean,ean... in $product_table and ean's spliter is defined
		my $ean_spliter="[,\.\t:;]";
		do_statement("drop $debug_tmp table if exists itmp_multiean2ean");
		do_statement("create $debug_tmp table itmp_multiean2ean (
id  int(11) not null default 0,
ean       varchar(15) not null default '',
product_id       int(13) not null default 0,

key multiean_ean (id, ean),
key (ean))");

		do_statement("alter table itmp_multiean2ean disable keys");
			
		my $commaSeparatedEANs = do_query("select ean,id from ".$product_table." where ean rlike ".str_sqlize($ean_spliter));
		do_statement("insert into itmp_multiean2ean(id,ean) select id,LPAD(ean,13,'0') from ".$product_table." where ean!='' and  ean not rlike ".str_sqlize($ean_spliter));
						
		for (@$commaSeparatedEANs) {
			my $commaSeparatedEAN = $_->[0];
			my $id=$_->[1];
			my @listOfEANs = split /$ean_spliter/, $commaSeparatedEAN;
			for (@listOfEANs) {
				next unless $_;
				next unless /^\d+$/;
				do_statement("insert into itmp_multiean2ean(id,ean) values ($id,LPAD(".str_sqlize($_).",13,'0'))");					
			}
		}
		do_statement("alter table itmp_multiean2ean enable keys");
		do_statement("alter ignore table itmp_multiean2ean drop key `multiean_ean`, add unique key (id,ean)");
		#do_statement("delete from itmp_multiean2ean where length(ean)<10");
#		do_statement("update ".$product_table." t inner join product_ean_codes pec on t.ean like concat('%',pec.ean_code,'%') set t.product_id=pec.product_id where t.ean like '%,%' and length(trim(leading '0' from pec.ean_code)) > 11 and t.product_id=0 and pec.product_id>0");
		log_printf("done, ");		
		do_statement("update ".$product_table." t inner join itmp_multiean2ean im on t.id = im.id 
inner join product_ean_codes pec on pec.ean_code = im.ean
inner join product p on pec.product_id = p.product_id
set t.product_id = pec.product_id, im.product_id=pec.product_id,t.by_ean_prod_id = p.prod_id 
where t.product_id = 0 and im.ean != ''");
		
		log_printf(do_query("select row_count()")->[0][0] . ", ");
	
		#remember droped eans
		do_statement("INSERT INTO itmp_multiean2ean (id,ean) 
					   SELECT id,droped_ean FROM $product_table WHERE droped_ean!=''");
		log_printf(do_query("select row_count()")->[0][0]);
	}

	# product_id mapping
	
	log_printf("\nproduct_id. by vendor+prod_id: ");
	
	do_statement("update ".$product_table." t 
				   inner join product p ON p.prod_id=t.map_prod_id and t.supplier_id=p.supplier_id 
				   set t.product_id=p.product_id,t.by_ean_prod_id=''
				   where t.prod_id!='' and t.supplier_id!=0");
	log_printf("" . do_query("select row_count()")->[0][0] . ", by prod_id - the rest: ");
	
	do_statement("update ".$product_table." t inner join product p ON p.prod_id=t.map_prod_id 
				   set t.product_id=p.product_id, t.supplier_id=p.supplier_id, t.by_ean_prod_id='' 
				   where t.product_id=0 and t.prod_id!='' and length(trim(t.prod_id)) > 4 and vendor=''");
	log_printf("" . do_query("select row_count()")->[0][0] . "");
	
	if($has_ean){
		log_printf("correct prod_id by ean: ");
		do_statement("UPDATE ".$product_table." t  
					   SET t.map_prod_id=t.by_ean_prod_id 
					   WHERE t.by_ean_prod_id!=''");
	}	
	# add editor & quality
	
	do_statement("update ".$product_table." t inner join product_memory p using (product_id) inner join users u using (user_id) inner join user_group_measure_map ugmm using (user_group) set t.quality=ugmm.measure where t.product_id!=0");
	log_printf("add quality " . do_query("select row_count()")->[0][0] . "");
	
	do_statement("update ".$product_table." t inner join product_memory p using (product_id) inner join users u using (user_id) set t.editor=u.login where t.product_id!=0");
	log_printf("add editor " . do_query("select row_count()")->[0][0] . "");
	
	# add access & link
	
	# access
	do_statement('DROP temporary TABLE IF EXISTS tmp_cache_supplier');
	do_statement('CREATE temporary TABLE tmp_cache_supplier AS SELECT * FROM supplier');
	do_statement('ALTER TABLE tmp_cache_supplier ADD UNIQUE KEY(supplier_id)');
	do_statement("update ".$product_table." t inner join product_memory p using (product_id) 
					inner join tmp_cache_supplier s on p.supplier_id=s.supplier_id 
					set t.access=if(s.is_sponsor='Y','FREE','FULL') where t.product_id!=0");
	log_printf("add access " . do_query("select row_count()")->[0][0] . "");
	# link
	my $lang_code=lc(($params->{'lang_code'})?$params->{'lang_code'}:'en');
	do_statement("update ".$product_table." t inner join product_memory p using (product_id) inner join tmp_cache_supplier s on p.supplier_id=s.supplier_id
	set t.link=concat('http://icecat.biz/$lang_code/p/',s.name,'/',t.map_prod_id,'/desc.htm') where t.product_id!=0");
	
	log_printf("add link " . do_query("select row_count()")->[0][0] . "");
	if($has_ean){
		do_statement("DROP TABLE IF EXISTS ".$product_table.'_eans');
		do_statement("ALTER TABLE itmp_multiean2ean RENAME TO ".$product_table.'_eans');
	}
}
################ -coverage report from file an track lists
sub get_cov_report_file_first_row{
	my $file_to_load=shift;
	my($delimiter,$newline,$escape);
	my $first_row=[];
	if($hin{'feed_type'} eq 'csv' or $hin{'feed_type'} eq 'xml'){
		($delimiter,$newline,$escape)=($hin{'delimiter'},$hin{'newline'},$hin{'escape'});
		$first_row=get_csv_rows($file_to_load,$delimiter,$newline,$escape,1);
	}elsif($hin{'feed_type'} eq 'xls'){
		($delimiter,$newline,$escape)=(';',"\n",'\\');
		$file_to_load=convert_xls_csv($file_to_load,$delimiter,$newline);
		$first_row=get_csv_rows($file_to_load,$delimiter,$newline,$escape,1);
	}else{
		push(@user_errors,"Type of file is invalid. Choice Excel or CSV");
		return '';
	}
	return [$first_row,$file_to_load,$delimiter,$newline,$escape];	
}
sub create_cov_cache_table{
	my($table,$cache_table)=@_;
	do_statement("CREATE TABLE  $cache_table (
								product_id int(13) not null default 0, 
								is_sponsored int(1) not null default 0,
								is_described int(1) not null default 0,
								is_active    int(1) not null default 0,
								primary key(product_id))");
	do_statement("INSERT IGNORE INTO $cache_table (product_id) SELECT product_id FROM  $table WHERE product_id!=0");
	my $feed_coverage_duplicates=(do_query("SELECT count(*) FROM $table WHERE product_id!=0")->[0][0]-do_query('SELECT count(*) FROM '.$cache_table)->[0][0]);
	
	#remember sponsored products
	do_statement("UPDATE $cache_table t 
					INNER JOIN $table c USING(product_id) 
					INNER JOIN supplier s USING (supplier_id) 
					SET t.is_sponsored=1
					WHERE c.product_id!=0 and s.is_sponsor='Y'");

	#remember described products
	do_statement("UPDATE $cache_table t 
					INNER JOIN $table c USING(product_id) 
					SET t.is_described=1
					WHERE c.quality!='NOEDITOR'");

	#remember active products
	do_statement("UPDATE $cache_table t 
				    INNER JOIN $table c USING(product_id) 
				    INNER JOIN product_active pa USING (product_id) 
					SET t.is_active=1
					WHERE pa.active>0");
	return $feed_coverage_duplicates;
	
}
sub get_coverage_sumary_by_table{
	my ($table,$feed_coverage_duplicates,$count_deleted,$cache_table)=@_;
	my $total_count=do_query("SELECT count(*) FROM $table")->[0][0];
	my $existed=	do_query("SELECT count(*) FROM $table WHERE product_id!=0")->[0][0];
	my $absent=		do_query("SELECT count(*) FROM $table WHERE product_id=0")->[0][0];	
	my $free  =		do_query("SELECT count(*) FROM $table pa 
							  INNER JOIN supplier s USING (supplier_id) 
							  WHERE pa.product_id!=0 and s.is_sponsor='Y'")->[0][0];
	my $described=	do_query("SELECT count(*) FROM $table 
							   WHERE product_id!=0 and quality!='NOEDITOR'")->[0][0];
	my $onstocks=	do_query("SELECT count(*) FROM $table pa 
							   INNER JOIN product_active pa2 USING (product_id) 
							   WHERE pa.product_id!=0 and pa2.active>0")->[0][0];
	process_atom_ilib('feed_coverage_summary');	
	my $my_atoms=process_atom_lib('feed_coverage_summary');
	
	my $my_atom=$my_atoms->{'default'}->{'feed_coverage_summary'};
	my $cover_html=repl_ph($my_atom->{'body'},{
										'total_count'=>$total_count,
										'existed'=>$existed,
										'existed_pers'=>get_percent($existed,$total_count),
										'absent'=>$absent,
										'absent_pers'=>get_percent($absent,$total_count),
										'free'=>$free,
										'free_pers'=>get_percent($free,$total_count),
										'described'=>$described,
										'described_pers'=>get_percent($described,$total_count),
										'onstocks'=>$onstocks,
										'onstocks_pers'=>get_percent($onstocks,$total_count),
										'coverage_cache_table'=>$cache_table,
										'invalid'=>$count_deleted,
										'invalid_pers'=>get_percent($count_deleted,$total_count),
										'duplicates'=>$feed_coverage_duplicates,
										'duplicates_pers'=>get_percent($feed_coverage_duplicates,$total_count),
									}
					 );	
	
	my $summary_html="Total count: $total_count<br/>
			  Total count of existed product: $existed (".get_percent($existed,$total_count).")<br/>
			  Total count of absent products: $absent (".get_percent($absent,$total_count).")<br/>
			  Total count of sponsored products: $free (".get_percent($free,$total_count).")<br/>
			  Total count of described products: $described (".get_percent($described,$total_count).")<br/>
			  Total count of active products: $onstocks (".get_percent($onstocks,$total_count).")<br/>
			  Details of coverage report (see in attachment).";	
	return [$cover_html,$summary_html];
}

sub get_csv_cov_report{
	my ($table,$ext_header,$lang_code)=@_;
	use Text::CSV;
	my $csv_writer=Text::CSV->new({
				quote_char          => '"',
				escape_char         => "\\",
				sep_char            => ",",
				eol                 => "\n",
				always_quote        => 0,
				binary              => 1,
				keep_meta_info      => 0,
				allow_loose_quotes  => 1,
				allow_loose_escapes => 1,
				allow_whitespace    => 0,
				blank_is_undef      => 0,
				verbatim            => 0				
	  });
	my $desc_langid=do_query("SELECT langid FROM language  WHERE short_code='$lang_code'")->[0][0];	  
	my $ext_header_str;
	$ext_header_str=' , '.join(' , ',@$ext_header) if scalar(@$ext_header)>0;		
	$csv_writer->combine(('Product_id','Partcode','Vendor','EAN code','ICEcat partcode','ICEcat vendor','Access','ICEcat editor','Quality','Link',$lang_code.' Text present','On market','Added','Updated',@$ext_header));
	#unmatched
	my $report_body=$csv_writer->string();
	my $rows=do_query("SELECT '', prod_id, vendor, IF(ean!='',ean,droped_ean),'','','','','','','','','','' $ext_header_str 
							FROM $table cr 
							WHERE product_id=0");
	for my $row(@$rows){
		$csv_writer->combine(@$row);
		$report_body.=$csv_writer->string();
	}
	#matched
	$rows=do_query("SELECT cr.product_id,cr.prod_id, vendor, IF(ean!='',ean,droped_ean), map_prod_id, s.name,access,editor,quality,cr.link,pd.long_desc,IF(pa.active=1,'Yes','No'),p.date_added,p.updated  $ext_header_str
						FROM $table cr
						JOIN product p ON p.product_id=cr.product_id  
						JOIN supplier s ON s.supplier_id=cr.map_supplier_id  
						LEFT JOIN content_measure_index_map mip ON cr.quality=mip.content_measure
						LEFT JOIN product_active pa ON cr.product_id=pa.product_id
						LEFT JOIN product_description pd ON pd.product_id=cr.product_id and pd.langid=$desc_langid  
						WHERE cr.product_id!=0 ORDER BY mip.quality_index");
	for my $row(@$rows){		
		$row->[9]="http://icecat.biz/$lang_code/p/".encode_url($row->[5]).'/'.encode_url($row->[4]).'/desc.htm';
		if(trim($row->[10])){
			$row->[10]='Yes';
		}else{
			$row->[10]='No';
		} 		
		$csv_writer->combine(@$row);
		$report_body.=$csv_writer->string();
	}
	return [$report_body,'csv'];
		
}

sub get_xls_cov_report{
		my ($table,$ext_header,$lang_code)=@_;
		use Spreadsheet::WriteExcel::Big;
		open my $fh, '>', \my $xls;
		my $ext_header_str;
		$ext_header_str=' , '.join(' , ',@$ext_header) if scalar(@$ext_header)>0;
		
		my $workbook=Spreadsheet::WriteExcel::Big->new($fh);
		my $header_format = $workbook->add_format(size => 12,bold=>1);
		my $default_format= $workbook->add_format(size => 10,bold=>0);
		my $i=1;
		
		
		my $start_limit=0;
		my $limit=65535;
		my $all_count=do_query("SELECT count(*) FROM $table");
		$all_count=$all_count->[0][0] if $all_count->[0];
		my $desc_langid=do_query("SELECT langid FROM language  WHERE short_code='$lang_code'")->[0][0];
		my $worksheet;
		my $header=['Product_id','Partcode','Vendor','EAN code','ICEcat partcode','ICEcat vendor','Access','ICEcat editor','Quality','Link',$lang_code.' text present','On market','Created','Last updated',@$ext_header];
		# write unmatched products
		$worksheet=$workbook->add_worksheet("Report") if $all_count<=$limit;
		my $unmatched_count=1;
		while(1){
			my $rows=do_query("SELECT '', prod_id, vendor, IF(ean!='',ean,droped_ean),'','','','','','','','','','' $ext_header_str 
								FROM $table cr 
								WHERE product_id=0 LIMIT $start_limit,$limit");
			$unmatched_count+=scalar(@$rows);
			if($rows->[0]){		
				$worksheet=$workbook->add_worksheet("Unmatched products $i") if $all_count>$limit;
				$worksheet->set_row(0, 15, $header_format);
				$worksheet->set_column(0, 5, 20, $default_format);
				$worksheet->write_row('A1',$header);
				#$worksheet->write_col('A2',$rows);
				
				for(my $k=1; $k<scalar(@$rows)+1; $k++){					
					for(my $j=0; $j<scalar(@{$rows->[0]});$j++){
						$worksheet->write_string($k,$j,$rows->[$k-1][$j]);		
					}
				}
				$start_limit=$start_limit+$limit;
				$i++;
				last() if $i==100;# just in case 
			}else{
				last();
			}
		}
		
		# write matched products
		$i=1;
		$start_limit=0;
	
		if($unmatched_count==1 and $all_count<$limit){# unmatched not found and all in one page
				$worksheet->set_row(0, 15, $header_format);
				$worksheet->write_row('A1',$header);			
		}

		while(1){
			my $rows=do_query("SELECT cr.product_id,cr.prod_id, vendor, IF(ean!='',ean,droped_ean), map_prod_id, s.name,access,editor,quality,cr.link,pd.long_desc,IF(pa.active=1,'Yes','No'),p.date_added,p.updated $ext_header_str
								FROM $table cr 
								JOIN product p ON cr.product_id=p.product_id  
								JOIN supplier s ON s.supplier_id=cr.map_supplier_id  
								LEFT JOIN content_measure_index_map mip ON cr.quality=mip.content_measure
								LEFT JOIN product_active pa ON pa.product_id=cr.product_id
								LEFT JOIN product_description pd ON pd.product_id=cr.product_id and pd.langid=$desc_langid   
								WHERE cr.product_id!=0 ORDER BY mip.quality_index LIMIT $start_limit,$limit");
			if($rows->[0]){
				if($all_count>$limit){
					$worksheet=$workbook->add_worksheet("Found products $i") ;
					$worksheet->set_column(0, 5, 20, $default_format);
					$worksheet->set_row(0, 15, $header_format);						
					$worksheet->write_row('A1',$header);
					#$worksheet->write_col('A2',$rows);
					for(my $k=1; $k<scalar(@$rows); $k++){
						my $partcode = $rows->[$k][4];
						$partcode =~ s/\//|/g;
						$rows->[$k][9]="http://icecat.biz/$lang_code/p/".encode_url($rows->[$k][5]).'/'.encode_url($partcode).'/desc.htm';
						if(trim($rows->[$k][10])){
							$rows->[$k][10]='Yes';
						}else{
							$rows->[$k][10]='No';
						} 
						for(my $j=0; $j<scalar(@{$rows->[0]});$j++){
							$worksheet->write_string($k,$j,$rows->[$k][$j]);
						}
					}
				}else{
					$worksheet->set_column(0, 5, 20, $default_format);
					$worksheet->set_row(0, 15, $header_format);			
					#$worksheet->write_col('A'.$unmatched_count,$rows);
					for(my $k=0; $k<scalar(@$rows); $k++){
						my $partcode = $rows->[$k][4];
						$partcode =~ s/\//|/g;
						$rows->[$k][9]="http://icecat.biz/$lang_code/p/".encode_url($rows->[$k][5]).'/'.encode_url($partcode).'/desc.htm';
						if(trim($rows->[$k][10])){
							$rows->[$k][10]='Yes';
						}else{
							$rows->[$k][10]='No';
						} 
						
						for(my $j=0; $j<scalar(@{$rows->[0]});$j++){
							$worksheet->write_string($k+$unmatched_count,$j,$rows->[$k][$j]);
						}
					}					
				}
				$start_limit=$start_limit+$limit;
				$i++;
				last() if $i==100;# just in case 
			}else{
				last();
			}	
		}
		$workbook->close();
		return [$xls,'xls'];
}

sub send_coverage_from_file_report{
	my ($report_body,$cover_txt,$report_type,$file_to_load)=@_;
	my $atach_name="";
	if($hin{'feed_url'}){
		$hin{'feed_url'}=~/([^\/]+)$/;
		$atach_name=$1;
	}else{
		log_printf('---------------------->>>>>>>>>>'.$file_to_load);
		$file_to_load=~/([^\/]+)$/;		
		$atach_name=$1;
	}
	my $current_date=do_query('SELECT now()')->[0][0];	
	$atach_name=~s/[^\.]+$//;
	$atach_name.='_'.$current_date;
	$atach_name=~s/[^\w-:]/_/g;
	$atach_name=~s/:+/-/g;
	
	use IO::Compress::Zip qw(zip $ZipError) ;
	my ($gziped,$ref);	
	$ref=\$report_body;
	my $file_name='coverage_details_'.$atach_name.'.'.$report_type;
	zip $ref=>\$gziped,Name=>$file_name or log_printf("gzip failed: $ZipError\n");
	my $mail = {
		'to' => $hin{'user_email'},
		'from' =>  $atomcfg{'mail_from'},
		'subject' => "Details of coverage report from: $current_date",
		'default_encoding'=>'utf8',
		'html_body' => $cover_txt,
		'attachment_name' => $file_name.'.zip',
		'attachment_content_type' => 'application/zip',
		'attachment_body' => $gziped,
		};
		
	complex_sendmail($mail);	
}


sub load_coverage_track_list{
	my ($first_row,$file_to_load,$delimiter,$newline,$escape,$table)=@_;
	use coverage_report qw(coverage_by_table);
	my %columns=($hin{'brand_prodid_col'}=>'prod_id',
				 $hin{'brand_col'}=>'vendor',
				 #$hin{'ext_col1'}=>'ext_col1',
				 #$hin{'ext_col2'}=>'ext_col2',
				 #$hin{'ext_col3'}=>'ext_col3',				
				 );
	my @max_arr=sort {$b<=>$a} keys(%columns);

	#return '' unless($max_arr[0]);
	my $vars=" ( ";
	my $sets=" SET ";
	my $column_count;
	if(ref($first_row) eq 'ARRAY' and scalar(@{$first_row->[0]})>$max_arr[0]){
		$column_count=scalar(@{$first_row->[0]});
	}else{
		$column_count=$max_arr[0];
	}
	my $extended_cols='';
	my $rep_hash={};
	my @ext_header;

	my %ext_cols=('ext_col1'=>$hin{'ext_col1'},'ext_col2'=>$hin{'ext_col2'},'ext_col3'=>$hin{'ext_col3'});
	my %ext_nums;
	for my $key(keys(%ext_cols)){
		if($ext_cols{$key}){
			push(@{$ext_nums{$ext_cols{$key}}},$key);
		}else{
			$ext_nums{$ext_cols{$key}}=[$key];
		}
	}
	
	use POSIX qw(floor);
	for(my $i=1; $i<=$column_count;$i++){
		$vars.=" \@var$i, ";
		if($ext_nums{$i}){
			for my $ext_name(@{$ext_nums{$i}}){
				$sets.=$ext_name."=TRIM(\@var$i), ";
			}
		}
		if($hin{'name_col'} eq $i){
			$sets.="name=TRIM(\@var$i), ";
		}
		if($columns{$i} and $columns{$i} ne 'ean'){
			$sets.=$columns{$i}."=\@var$i, ";
		}else{
			my $ext_col=trim($first_row->[0][$i-1]);
			
			if($hin{'is_first_header'} and $ext_col){
				$ext_col=~s/[^\w]+/_/gs;
				$ext_col=shortify_str('Info_'.$i.'_'.$ext_col,20,'');
			}else{
				$ext_col="Column_$i";
			}
			if($rep_hash->{$ext_col}){
				$ext_col=$ext_col.'_'.floor(rand(1000));
				$rep_hash->{$ext_col}=1;
			}else{
				$rep_hash->{$ext_col}=1;
			}
			push(@ext_header,$ext_col);
			$extended_cols.=" $ext_col text not null default '',\n";
			$sets.=$ext_col."=\@var$i, "
		}
	}
	my $ean_set;
	if($hin{'ean_cols'}){
		#ean=CONCAT(VAR1,',',VAR2,',',VAR3)
		my @ean_cols=split(',',$hin{'ean_cols'});
		
		$ean_set="ean=CONCAT( ";
		for my $ean_col(@ean_cols){
			$ean_set.='TRIM(@VAR'.$ean_col."),'".(',')."',";
		}
		$ean_set=~s/,[^,]*,$//;
		$ean_set=~s/,[^,]*$//;
		$ean_set.=') ';
	}
	$sets.=$ean_set;
	do_statement("DROP TABLE IF EXISTS $table");
	do_statement("CREATE TABLE  $table (
					prod_id varchar(60)  not null default '',
					vendor  varchar(255) not null default '',
					ean     varchar(255) not null default '',
					ext_col1 text not null default '',
					ext_col2 text not null default '',
					ext_col3 text not null default '',
					name     varchar(255) not null default '',
					$extended_cols				
					key (prod_id, vendor),
					key (vendor),
					key (ean))");
	
	$vars=~s/,[\s]*$//;
	$sets=~s/,[\s]*$//;
	$vars.=" ) ";
	
	my $sql="LOAD DATA LOCAL INFILE '$file_to_load' 
			 INTO TABLE $table 
			 FIELDS TERMINATED BY '".$delimiter."'
				 		ESCAPED BY ".str_sqlize($escape)."
				 		OPTIONALLY ENCLOSED BY '\"'
			 LINES 
				 TERMINATED BY '$newline'\n"				 	 
				 .(($hin{'is_first_header'}*1)?" IGNORE 1 LINES \n":" \n ").$vars."\n".$sets;

	do_statement("alter table $table disable keys");
	do_statement($sql);
	do_statement("alter table $table enable keys");
	do_statement('UPDATE '.$table.' SET ean=\'\' WHERE ean rlike \'^[,]+$\'');
#	log_printf(Dumper(do_query("select * from $table")));	
	my $count_loaded=do_query('SELECT count(*) FROM '.$table)->[0][0];
	coverage_by_table($table,{ 'ean' => $hin{'ean_cols'}});
	my $count_deleted=$count_loaded-do_query('SELECT count(*) FROM '.$table)->[0][0];
	do_statement("UPDATE $table t 
					JOIN product p USING(product_id)
					JOIN supplier s ON p.supplier_id=s.supplier_id  
					SET map_supplier_id=s.supplier_id
					WHERE t.product_id!=0 AND map_supplier_id=0");
	return {'ext_header'=>\@ext_header,'count_deleted'=>$count_deleted};		
}

sub get_feed_file{
	my ($feed_dir) = @_;		
	#check input params
	if(!$hin{'feed_config_id'} or !(-d $feed_dir)){
		push(@user_errors,"Temporary directory with datapack is empty. Please download the pricelist first");
		return '';		
	}
	my $dir_files_txt=`find $feed_dir`;
	$dir_files_txt=~s/$feed_dir//gs;
	$dir_files_txt=~s/^[\n]+//gs;
	my @dir_files=split(/\n/,$dir_files_txt);
	my $file_to_load;
	if(scalar(@dir_files)<1){
		push(@user_errors,"Temporary directory with datapack is empty. Please download the pricelist first");
		return '';
	}elsif(scalar(@dir_files)==1){
		$file_to_load=$feed_dir.$dir_files[0];# if there only one file it's default
		 
	}elsif(scalar(@dir_files>1) and !$hin{'user_choiced_file'}){# too sad
		push(@user_errors,"It seems the file is directory. Please choice one file and reupload the feed");
		return '';
	}elsif(scalar(@dir_files>1) and $hin{'user_choiced_file'} and !(-e $feed_dir.$hin{'user_choiced_file'})){#this should never happens
		push(@user_errors,"It seems the file is directory. Please choice one file and reupload the feed");
		return '';		
	}else{
		$file_to_load=$feed_dir.$hin{'user_choiced_file'};
	}
	return $file_to_load;
}
1;

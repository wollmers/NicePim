#!/usr/bin/perl
# @author <vadim@bintime.com>
use lib "/home/pim/lib";
use strict;
use warnings;
use Benchmark;
use atomsql;
use atom_mail;
use atomcfg;
use atomlog;
use nested_sets;
use Term::ANSIColor qw(:constants);
use constant DISABLE_SQL_STMT			=> 1;		# DANGER!!! set TRUE if you want only report to be generated
use constant NULL_SERIES_ID				=> 1;		# series_id if no series
use constant INTER_LANGID				=> 1;		# international language of title ( default is english )
use constant ROOT_FAMILY_ID				=> 1;
use constant RESTRICTED_BRANDS			=> 'HP,Seagate';
use constant ALLOW_MODEL_IN_SERIES		=> 1;		# for some rare bugs
use constant DROP_SERIES_FROM_SERIES	=> 1;		# set TRUE to drop 'series' from new series (ex. X series => X)
use constant DROP_SERIES_FROM_FAMILY	=> 1;		# set TRUE to drop 'series' from new families (ex. TravelMate series => TravelMate)
use constant MAX_PRODUCTS_PER_FILE		=> 1000;	# for report
use constant EMAIL_TO					=> 'blackchval@gmail.com,alexandr_kr@icecat.biz,alena@icecat.biz,dima@icecat.biz';
#use constant EMAIL_TO					=> 'vadim@chval.icecat.localnet';
use constant EMAIL_FROM					=> 'info@icecat.biz';
use constant EMAIL_SUBJ					=> "Product family in model name";

&sql_backup_tables();
&sql_alter_product_table();
&sql_create_product_series_table();
my $sr_list = &get_restricted_supplier_id_list();
&send_mail( EMAIL_TO, EMAIL_FROM, EMAIL_SUBJ, &form_report( &update_all() ) );
exit;
####################
sub update_all {
	my $families_del_list = {};
	
	# select all families on international language
	my $families = &sql_select_all_inter_families(INTER_LANGID);
	return unless ref $families->[0] eq 'ARRAY';
	my $report_data = {};
	my $fam_cnt     = scalar @$families || 1;
	my $current_fam = 1;
	print BOLD WHITE "::Processing families ... [0] ", RESET;
	my $time_start = new Benchmark;

	# process all families
	foreach my $fam (@$families) {
		my $family_id        = $fam->[0];
		my $family           = $fam->[1];
		my $parent_family_id = &sql_select_parent_family_id($family_id);

		# select all products with this family
		my $products = &sql_select_all_products_with_family($family_id);
		next unless ref $products eq 'ARRAY';

		# we shouldn't split family that has children or it's parent is root
		if ( &sql_has_family_children($family_id)
			 || $parent_family_id == ROOT_FAMILY_ID )
		{
			my $prod_cnt     = scalar @$products || 1;
			my $current_prod = 1;
			my $percent_prev = sprintf( "%2d", $current_prod * 100 / $prod_cnt );

			# update each product with title and NULL series
			foreach my $product (@$products) {
				next unless ( ref $product eq 'ARRAY' );
				my $product_id = $product->[0];
				my $model      = $product->[1];
				my $brand      = $product->[2];
				my $prod_id    = $product->[5];
				my $percent = sprintf( "%2d", $current_prod * 100 / $prod_cnt );
				$current_prod++;

				if ( $percent > $percent_prev ) {
					&animate_product_update();
				}
				$percent_prev = $percent;
			} ## end foreach my $product (@$products)
		} else {
			my $prod_cnt     = scalar @$products || 1;
			my $current_prod = 1;
			my $percent_prev = sprintf( "%2d", $current_prod * 100 / $prod_cnt );

	# if family has non root parent and has no children ( we can split it!!! )
			foreach my $product (@$products) {
				next unless ref $product eq 'ARRAY';
				my $product_id = $product->[0];
				my $model      = $product->[1];
				my $brand      = $product->[2];
				my $brand_id   = $product->[3];
				my $catid      = $product->[4];
				my $prod_id    = $product->[5];
				my $c = &find_common_and_non_common_part( $family, $model );
				my $nc = $c->[1]; # non common family part of family and model
				my $series;

				if (ALLOW_MODEL_IN_SERIES) {
					$series = &get_series($family);
				} else {
					$series = &get_series($nc);
				}

				# if this family has series included
				if ($series) {
					my $new_family_id = $parent_family_id;
					my $new_family    = &sql_select_family($new_family_id);
					my $new_catid     = &sql_get_family_category_id( $new_family_id );
					goto NO_SERIES if $new_catid != $catid;
					$c = &find_common_and_non_common_part( $family,
														   $new_family );
					$series = $c->[1];

					# very rare but happens
					goto NO_SERIES if $series =~ /^\s*series\s*$/i;
					if (DROP_SERIES_FROM_SERIES) {
						$series =~ s/\s+series$//gi;
					}
					if (DROP_SERIES_FROM_FAMILY) {
						if ( $new_family =~ /\s+series$/gi ) {
							$new_family =~ s/\s+series$//gi;
							&sql_update_family($new_family_id, $new_family);
						}
					}
					my $title = &join_brand_family_and_model( $brand, $new_family, $model );
					my $series_id
						= &sql_insert_series( $series, $brand_id, $catid,
											  $new_family_id, INTER_LANGID );
					&sql_update_product( $product_id, $new_family_id, $series_id );
					$families_del_list->{$family_id} = 1;    # we should delete this family
					push @{ $report_data->{$brand} },
						&insert_report_data( $prod_id, $family, $new_family,
											 $series,  $model,  $title );
				} else {
				NO_SERIES:
				} ## end else [ if ($series)
				my $percent
					= sprintf( "%2d", $current_prod * 100 / $prod_cnt );
				$current_prod++;
				if ( $percent > $percent_prev ) {
					&animate_product_update();
				}
				$percent_prev = $percent;
			} ## end foreach my $product (@$products)
		} ## end else [ if ( &sql_has_family_children...
		my $percent = sprintf( "%2d", $current_fam * 100 / $fam_cnt );
		print BOLD GREEN "\b\b\b\b$percent% ", RESET;
		$current_fam++;
	} ## end foreach my $fam (@$families)
	print "\n";
	my $time_stop = new Benchmark;
	my $timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
	print BOLD WHITE "::Deleting @{[scalar keys %$families_del_list]} splitted families ... [0]", RESET;
	$fam_cnt     = scalar keys %$families_del_list || 1;
	$current_fam = 1;
	$time_start  = new Benchmark;

	foreach ( keys %$families_del_list ) {
		&sql_delete_family($_);
		my $percent = sprintf( "%2d", $current_fam * 100 / $fam_cnt );
		print BOLD GREEN "\b\b\b$percent%", RESET;
		$current_fam++;
	} ## end foreach ( keys %$families_del_list)
	print "\n";
	$time_stop = new Benchmark;
	$timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
	return $report_data;
} ## end sub update_all

sub insert_report_data {
	my ( $prod_id, $family_origin, $family, $series, $model, $title ) = @_;
	my $data = [];
	push @$data, $prod_id;
	push @$data, $family_origin;
	push @$data, $family;
	push @$data, $series;
	push @$data, $model;
	push @$data, $title;
	return $data;
} ## end sub insert_report_data

sub form_report {
	my $report_data = shift;
	return unless ref $report_data eq 'HASH';
	my $html_head = sub {
		return "
			<head>
				<meta name='author' content=" . 'vadim@bintime.com' . "/>
				<meta name='generator' content='" . __FILE__ . "' />
				<meta http-equiv='Content-Type' content='text/html;charset=UTF-8' />
				<title>" . shift . "</title>
				<style type='text/css'>
				table {
					border-width: 1px;
					border-spacing: 4px;
					border-style: solid;
					border-color: gray;
					border-collapse: collapse;
				}
				tr {
					color:LightSlateGray;
					font-family:Lucida Sans Mono;
					font-size:11px;
				}
				td {
					border-width: 1px;
					padding: 3px;
					border-style: solid;
					border-color: green;
				}
				</style>
			</head>
			";
	};
	my $html_table_begin = sub {
		return "
				<table width='100%'>
					<tr style='color:CornflowerBlue;font-family:Monospace;font-size:12px;'>
						<td>Part no.</td>
						<td>Family (origin)</td>
						<td>Family (new)</td>
						<td>Series</td>
						<td>Model</td>
						<td>Title</td>
					</tr>
		";
	};
	my $report_begin = sub {
		return "
		<html>" . $html_head->(shift) . "<body>" . $html_table_begin->();
	};
	my $report_end = sub {
		return "
				</table>
			</body>
		</html>
		"
	};
	my $brand_cnt     = scalar keys %$report_data || 1;
	my $current_brand = 1;
	print BOLD WHITE "::Generating report ... [0]", RESET;
	my $files      = {};
	my $time_start = new Benchmark;
	foreach my $brand ( keys %$report_data ) {
		my $prod_cnt = 0;
		my $part     = 1;
		my $fname    = $brand . '.html';
		my $out = $report_begin->( ( uc $brand ) . ' product title report' );
		next unless ref $report_data->{$brand} eq 'ARRAY';
		foreach ( @{ $report_data->{$brand} } ) {
			next unless ref $_ eq 'ARRAY';
			$out .= "
					<tr>
						<td>" . $_->[0] . "</td>
						<td>" . $_->[1] . "</td>
						<td>" . $_->[2] . "</td>
						<td>" . $_->[3] . "</td>
						<td>" . $_->[4] . "</td>
						<td>" . $_->[5] . "</td>
					</tr>
			";

			if ( ++$prod_cnt >= MAX_PRODUCTS_PER_FILE ) {
				$prod_cnt = 0;
				$out .= $report_end->();
				$files->{$fname} = $out;
				$part++;
				$fname = $brand . '_part_' . $part . '.html';
				$out = $report_begin->(
					  ( uc $brand ) . ' product title report part ' . $part );
			} ## end if ( ++$prod_cnt >= MAX_PRODUCTS_PER_FILE)
		} ## end foreach ( @{ $report_data->...
		$out .= $report_end->();
		$files->{$fname} = $out;
		foreach ( keys %$files ) {
			open REPORT, '>:encoding(UTF-8)', $_ || next;
			print REPORT $files->{$_};
			close REPORT || next;
		}
		my $percent = sprintf( "%2d", $current_brand * 100 / $brand_cnt );
		print BOLD GREEN "\b\b\b$percent%", RESET;
		$current_brand++;
	} ## end foreach my $brand ( keys %$report_data)
	print "\n";
	my $time_stop = new Benchmark;
	my $timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
	print BOLD WHITE "::Gzipping report ... ", RESET;
	my $params = "";
	foreach ( keys %$files ) {
		$params .= "'$_' ";
	}
	qx(tar -cf report.tar $params);
	qx(gzip -f report.tar);
	qx(rm $params);
	if ( ( -e 'report.tar.gz' ) && ( -s 'report.tar.gz' != 0 ) ) {
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
	return 'report.tar.gz';
} ## end sub form_report

sub send_mail {
	my ( $to, $from, $subj, $report ) = @_;
	open REPORT, '<', $report;
	binmode REPORT, ':bytes';
	my ( $file, $buffer );
	while ( read( REPORT, $buffer, 4096 ) ) { $file .= $buffer }
	close REPORT;
	qx(rm $report);
	my $mail = { 'to'                     => $to,
				 'from'                   => $from,
				 'subject'                => $subj,
				 'default_encoding'       => 'utf8',
				 'html_body'              => 'See attachcement!',
				 'attachment_name'        => $report,
				 'attachment_cotent_type' => 'application/x-gzip',
				 'attachment_body'        => $file
	};
	&complex_sendmail($mail);
	print BOLD WHITE
		"#-----\nFor detailed information - check your email box at <" . $to
		. ">", RESET, "\n";
} ## end sub send_mail

sub get_series {
	my $str = shift;
	my $series;
	if (   $str =~ /
		(
			(^|\s+)					# beginning or space
			(
				\d{3,}				# at least 3 digits
				|					# or
				[\S\-]+\d+			# word + digit
				|					# or
				\d+[\S\-]+			# digit + word
				|					# or
				[\S\-]+\d+[\S\-]+	# word + digit + word
				|					# or
				\d+[\S\-]+\d+		# digit + word + digit
				|					# or
				[A-Z]+				# LETTER
			)
			\b
		)
		(
			$						# end of line
			|						# or
			(
				\s+.*\s+			# space + text + space
				|					# or
				\s+					# space
			)
			[sS]eries				# series
		)
	/gx
		|| $str =~ /
	(
		\b[\S\-]+[sS]eries\b		# some series
	)
	.*$
	/gx
		)
	{
		$series = $1;
		$series =~ s/^\s+|\s+$//gi;
	} ## end if ( $str =~ / || $str...
	return $series;
} ## end sub get_series

sub find_common_and_non_common_part {
	my ( $str_, $str__ ) = @_;
	my ( $c, $nc_, $nc__ );
	$_ = $str_ . "\n" . $str__;
	if (/\A(.+(?=\s+))(.*)\n\1(\s+|\Z)(.*)\Z/gim) {
		( $c, $nc_, $nc__ ) = ( $1, $2, $4 );
		$nc_ =~ s/^\s+//g;
	} else {
		$nc_  = $str_;
		$nc__ = $str__;
	}
	foreach ( $nc_, $nc__ ) {s/^\s+|\s+$//g}
	return [ $c, $nc_, $nc__ ];
} ## end sub find_common_and_non_common_part

sub join_brand_family_and_model {
	my ( $brand, $family, $model ) = @_;
	my $bfm;
	my $c_ = &find_common_and_non_common_part( $family, $model );
	my $c = $c_->[0];
	if ($c) {
		$bfm = $brand . ' ' . $family . ' ' . $c_->[2];
	} else {
		$bfm = $brand . ' ' . $family . ' ' . $model;
	}
	return $bfm;
} ## end sub join_brand_family_and_model

sub animate_product_update {

	BEGIN {
		my $anim_arr = [ "-", "\\", "|", "/" ];
		my $anim_idx = 0;

		sub animate {
			print "\b", $anim_arr->[ $anim_idx++ ];
			if ( $anim_idx >= $#$anim_arr ) { $anim_idx = 0 }
		}
	} ## end BEGIN
	&animate();
} ## end sub animate_product_update

sub get_restricted_supplier_id_list {
	print BOLD WHITE
		"::Detecting each id from restricted supplier's list ...", RESET, "\n";
	my $suppliers = [ split( /,/, RESTRICTED_BRANDS ) ];
	my $supplier_id_list = "";
	foreach (@$suppliers) {
		s/^\s+|\s+$//g;
		my $supplier_id = &sql_select_supplier_id($_);
		unless ($supplier_id) {
			print BOLD RED, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
		} else {
			print BOLD GREEN, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
			$supplier_id_list .= $supplier_id . ',';
		}
	} ## end foreach (@$suppliers)
	$supplier_id_list =~ s/,$//;
	unless ($supplier_id_list) {
		return '0';
	} else {
		return $supplier_id_list;
	}
} ## end sub get_restricted_supplier_id_list
######################### SQL section ##########################################
sub sql_select_all_inter_families {
	return &do_query(
		"SELECT pf.family_id, v.value FROM product_family pf JOIN vocabulary v USING (sid) WHERE v.langid="
			. shift
			. " AND pf.supplier_id NOT IN ("
			. $sr_list
			. ")" );
} ## end sub sql_select_all_inter_families

sub sql_get_family_category_id {
	return &do_query("SELECT catid FROM product_family WHERE family_id=" . shift)->[0]->[0];	
} ## end sub sql_get_family_category_id

sub sql_has_family_children {
	my $children = &do_query(
				"SELECT family_id FROM product_family WHERE parent_family_id="
					. shift )->[0];
	return 1 if ( ref $children eq 'ARRAY' );
} ## end sub sql_has_family_children

sub sql_select_all_products_with_family {
	return &do_query(
		"SELECT p.product_id, p.name, s.name, s.supplier_id, p.catid, p.prod_id FROM product p JOIN product_family pf USING (family_id, supplier_id, catid) JOIN supplier s USING (supplier_id) WHERE pf.family_id="
			. shift
			. " AND p.supplier_id NOT IN ("
			. $sr_list
			. ")" );
} ## end sub sql_select_all_products_with_family

sub sql_select_all_products_with_null_family {
	return &do_query(
		"SELECT p.product_id, p.name, s.name, p.prod_id FROM product p JOIN supplier s USING (supplier_id) WHERE (p.family_id=1 OR p.family_id=0) AND p.supplier_id NOT IN ("
			. $sr_list
			. ")" );
} ## end sub sql_select_all_products_with_null_family

sub sql_select_parent_family_id {
	return &do_query(
				"SELECT parent_family_id FROM product_family WHERE family_id="
					. shift )->[0]->[0];
} ## end sub sql_select_parent_family_id

sub sql_select_family {
	return &do_query(
		"SELECT v.value FROM product_family pf JOIN vocabulary v USING (sid) WHERE family_id="
			. shift )->[0]->[0];
} ## end sub sql_select_family

sub sql_select_supplier_id {
	return &do_query(
		 "SELECT supplier_id FROM supplier WHERE name=" . &str_sqlize(shift) )
		->[0]->[0];
} ## end sub sql_select_supplier_id

sub sql_insert_series {
	my ( $series, $brand_id, $catid, $family_id, $langid ) = @_;
	return if DISABLE_SQL_STMT;
	my $series_exist_id = &do_query(
		"SELECT series_id FROM product_series ps JOIN vocabulary v USING (sid) WHERE v.langid="
			. $langid
			. " AND v.value="
			. &str_sqlize($series) )->[0]->[0];
	return $series_exist_id if $series_exist_id;
	&do_statement("INSERT INTO sid_index (dummy) values (1)");
	my $sid = &do_query("SELECT LAST_INSERT_ID()")->[0]->[0];
	&do_statement(
		"INSERT INTO product_series (supplier_id, catid, family_id, sid)
		VALUES (" . $brand_id . "," . $catid . "," . $family_id . "," . $sid . ")"
	);
	my $series_id = &do_query("SELECT LAST_INSERT_ID()")->[0]->[0];
	&do_statement(
		"INSERT INTO vocabulary (sid, langid, value)
		VALUES (" . $sid . "," . $langid . "," . &str_sqlize($series) . ")" );
	return $series_id;
} ## end sub sql_insert_series

sub sql_update_product {
	my ( $product_id, $family_id, $series_id ) = @_;
	return if DISABLE_SQL_STMT;
	&do_statement(   "UPDATE product SET family_id="
				   . $family_id
				   . ", series_id="
				   . $series_id
				   . " WHERE product_id="
				   . $product_id );
} ## end sub sql_update_product

sub sql_backup_tables {
	return if DISABLE_SQL_STMT;
	my $time = localtime;
	$time =~ s/\s+/_/g;
	print BOLD WHITE "::Backup product table ... ", RESET;
	my $time_start = new Benchmark;
	my $status = system(
		"mysqldump -u${atomcfg{'dbuser'}} -p${atomcfg{'dbpass'}} -h $atomcfg{'dbhost'} -C -l ${atomcfg{'dbname'}} product > product_backup_$time.sql"
	);
	my $exit_value = $status >> 8;
	if ( $exit_value == 0 ) {
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
	my $time_stop = new Benchmark;
	my $timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
	print BOLD WHITE "::Backup product_family table ... ", RESET;
	$time_start = new Benchmark;
	$status = system(
		"mysqldump -u${atomcfg{'dbuser'}} -p${atomcfg{'dbpass'}} -h $atomcfg{'dbhost'} -C -l ${atomcfg{'dbname'}} product_family > product_family_backup_$time.sql"
	);
	$exit_value = $status >> 8;

	if ( $exit_value == 0 ) {
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
	$time_stop = new Benchmark;
	$timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
	print BOLD WHITE "::Backup vocabulary table ... ", RESET;
	$time_start = new Benchmark;
	$status = system(
		"mysqldump -u${atomcfg{'dbuser'}} -p${atomcfg{'dbpass'}} -h $atomcfg{'dbhost'} -C -l ${atomcfg{'dbname'}} vocabulary > vocabulary_backup_$time.sql"
	);
	$exit_value = $status >> 8;

	if ( $exit_value == 0 ) {
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
	$time_stop = new Benchmark;
	$timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
} ## end sub sql_backup_tables

sub sql_alter_product_table {
	return if DISABLE_SQL_STMT;
	my $query         = &do_query("DESCRIBE product");
	my $series_exists = 0;
	foreach (@$query) {
		if ( $_->[0] eq 'series_id' ) {
			$series_exists = 1;
		}
	} ## end foreach (@$query)
	print BOLD WHITE "::Alter product table ... ", RESET;
	my $time_start = new Benchmark;
	unless ( $series_exists ) {
		&do_statement(
			"ALTER TABLE product 
			ADD COLUMN series_id INT(17) NOT NULL DEFAULT 1"
		);
	} ## end unless ( $title_exists || ...
	if ( &do_query("SELECT COUNT(series_id) FROM product")->[0]
		 ->[0] )
	{
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
	my $time_stop = new Benchmark;
	my $timebenchmark = timediff( $time_start, $time_stop );
	print "\t", WHITE, timestr($timebenchmark), RESET, "\n";
} ## end sub sql_alter_product_table

sub sql_create_product_series_table {
	return if DISABLE_SQL_STMT;
	print BOLD WHITE "::Creating product_series table ... ", RESET;
	unless ( &do_query("SHOW TABLES LIKE 'product_series'")->[0]->[0] ) {
		&do_statement(
			"CREATE TABLE product_series ( series_id INT(17) NOT NULL PRIMARY KEY AUTO_INCREMENT, 
			sid INT(13) NOT NULL, 
			tid INT(13) NOT NULL, 
			supplier_id INT(17) NOT NULL, 
			catid INT(13) NOT NULL, 
			family_id INT(17) NOT NULL, 
			KEY (sid), 
			KEY (supplier_id), 
			KEY (family_id) )"
		);
		&do_statement("INSERT INTO product_series VALUES (1, 0, 0, 0, 0, 0)");
	} ## end unless ( &do_query("SHOW TABLES LIKE 'product_series'"...
	if ( &do_query("SHOW TABLES LIKE 'product_series'")->[0]->[0] ) {
		print BOLD WHITE "[ ", BOLD GREEN, "Success", BOLD WHITE, " ]", RESET, "\n";
	} else {
		print BOLD WHITE "[ ", BOLD RED, "Fail", BOLD WHITE, " ]", RESET, "\n";
		exit;
	}
} ## end sub sql_create_product_series_table

sub sql_delete_family {
	my $family_id = shift;
	return if DISABLE_SQL_STMT;
	&delete_element( 'product_family', 'family_id', 'parent_family_id',
					 $family_id, 'value', 'vocabulary', 'sid' );
	&do_statement(  "DELETE FROM product_family WHERE family_id=" . $family_id );
} ## end sub sql_delete_family

sub sql_update_family {
	my ($family_id, $family_name) = @_;
	return if DISABLE_SQL_STMT;
	&do_statement("UPDATE vocabulary v JOIN product_family pf USING(sid)
		SET v.value=" . &str_sqlize($family_name) .
		" WHERE pf.family_id=" . $family_id . " AND v.langid=" . INTER_LANGID);
}

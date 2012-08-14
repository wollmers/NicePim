package icecat_server2_repository;

#$Id: icecat_server2_repository.pm 3743 2011-01-19 16:39:34Z alexey $

use strict;
use atomcfg;
use atomsql;
use atomlog;
use atom_misc;
use atom_util;
use icecat_util;
use data_management;
#use process_manager;

use Data::Dumper;

use POSIX qw (strftime);
use Encode;

use IO::File;

use vars qw($fn_hash);

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
      
    @EXPORT = qw(
								 &generate_xml_file_OLD
								 &get_files_index_xml
								 &get_product_xml_from_cache
								 &get_product_partsxml_data
								 &get_product_partsxml
								 &get_product_partsxml_fromdb
								 &create_index_files
								 &create_index_files_from_index_cache
								 &create_index_pair
								 &create_specific_index_files_from_index_cache
								 &store_index
								 &store_specific_index
								 &remove_product_from_repository
								 &is_daily
    );
}

sub create_index_pair {
	my ($p) = @_;

	my $pid = $p->{'product_id'};
	
# make XML and CSV data
	
	my $xml_all = '';
	my $csv_all = '';

	# Encode part
	&Encode::_utf8_on($p->{'prod_id'});
	&Encode::_utf8_on($p->{'orig_set'});
	&Encode::_utf8_on($p->{'ean_upc_set'});
	&Encode::_utf8_on($p->{'country_market_set'});
	&Encode::_utf8_on($p->{'name'});

	$p->{'agr_prod_count'} = int($p->{'agr_prod_count'}) eq $p->{'agr_prod_count'} ? $p->{'agr_prod_count'} : '0';

	# go on
	$p->{'name'} =~  s/\t//gs;
	$p->{'name'} =~  s/\r//gs; # found by Alexey Osadchiy, 23.04.2010, fixed by dima; found by BAS 14.12.2010, fixed by dima
	$p->{'name'} =~  s/\n//gs; # found by Alexey Osadchiy, 23.04.2010, fixed by dima; found by BAS 14.12.2010, fixed by dima
	$p->{'name'} =~  s/\\$//s;
	
	# new info about high_pic
	$p->{'high_pic'} = '' if (! $p->{'high_pic'});
	$p->{'high_pic_size'} = 0  if (! $p->{'high_pic_size'});
	$p->{'high_pic_width'} = 0  if (! $p->{'high_pic_width'});
	$p->{'high_pic_height'} = 0  if (! $p->{'high_pic_height'});

	# bug with tabs in prod_ids (found by Artem, 8.09.2009, fixed by dima)
	$p->{'prod_id'} =~ s/\t/\\t/gs;

	# set updated
	my $updated = &format_date($p->{'updated'});
	my $date_added = &format_date($p->{'date_added'});
	
	# undef $ean2file;
	my $ean2file = { 'csv' => '', 'xml' => '' };

	# undef $country2file;
	my $country2file = { 'csv' => '', 'xml' => '' };
	
	if ($p->{'ean_upc_set'}) {
		# if we have the set of EANs
		# collect EAN_UPC-s
		my @ean_upcs = sort {$a cmp $b} split /\t/, $p->{'ean_upc_set'};
		
		if ($#ean_upcs > -1) {
			foreach my $ean_upc (@ean_upcs) {
				$ean_upc =~ s/\D//gs;
				next unless ($ean_upc);
				$ean2file->{'csv'} .= $ean_upc.";";
				$ean2file->{'xml'} .= "\n\t\t\t\t<EAN_UPC Value=\"".&str_xmlize($ean_upc)."\"/>";
			}
			chop($ean2file->{'csv'});
		}
	}

	if ($p->{'country_market_set'}) { 
		# if we have the set of Countries
		# collect Country-s
		my @countries = sort {$a cmp $b} split /\t/, $p->{'country_market_set'};
		
		if ($#countries > -1) {
			foreach my $country (@countries) {
				next unless ($country);
				$country2file->{'csv'} .= $country.";";
				$country2file->{'xml'} .= "\n\t\t\t\t<Country_Market Value=\"".&str_xmlize($country)."\"/>";
			}
			chop($country2file->{'csv'});
		}
	}

### 1.

	my $csv = '';
	my $xml = "\n\t\t<file path=\"%%target_path%%".$pid.".xml\" ".
		"Product_ID=\"".$pid."\" ".
		"Updated=\"".$updated."\" ".
		"Quality=\"".$p->{'content_measure'}."\" ".
		"Supplier_id=\"".$p->{'supplier_id'}."\" ".
		"Prod_ID=\"".&str_xmlize($p->{'prod_id'})."\" ".
		"Catid=\"".$p->{'catid'}."\" ".
		"On_Market=\"".$p->{'on_market'}."\" ".
		"Model_Name=\"".&str_xmlize($p->{'name'})."\" ".
		"Product_View=\"" . &str_xmlize($p->{'agr_prod_count'})."\" ".
		"HighPic=\"" . str_xmlize($p->{'high_pic'}) . "\" ".
		"HighPicSize=\"" . $p->{'high_pic_size'} . "\" ".
		"HighPicWidth=\"" . $p->{'high_pic_width'} . "\" " .
		"HighPicHeight=\"" . $p->{'high_pic_height'} . "\">";
	
	# append
	$xml_all .= $xml;
	
### 2.

	# collect M_Prod_ID-s
	my @m_prod_ids = ();
	if ($p->{'orig_set'}) {
		@m_prod_ids = sort {$a cmp $b} split /\t/, $p->{'orig_set'};
	}

	if ($#m_prod_ids > -1) { # have some m_prod_ids

		my $prod_id_prev = '';

		foreach my $m_prod_id (@m_prod_ids) {
			next unless ($m_prod_id);
			next if ($p->{'prod_id'} eq $m_prod_id);
			next if ($prod_id_prev eq $m_prod_id);
			undef $csv;
			$csv = "%%target_path%%" . $pid . ".xml\t".$pid."\t".$updated."\t".$p->{'content_measure'}."\t".$p->{'supplier_id'}."\t".$p->{'prod_id'}."\t".$p->{'catid'}."\t".$m_prod_id."\t".$ean2file->{'csv'}."\t".$p->{'on_market'}."\t".$country2file->{'csv'}."\t".$p->{'name'}."\t".$p->{'agr_prod_count'} .	"\t" . $p->{'high_pic'} ."\t" . $p->{'high_pic_size'} ."\t" . $p->{'high_pic_width'} ."\t" . $p->{'high_pic_height'} . "\n";

			undef $xml;
			$xml = "\n\t\t\t<M_Prod_ID>".&str_xmlize($m_prod_id)."</M_Prod_ID>";
			
			# append
			$xml_all .= $xml;
			$csv_all .= $csv;
			
			$prod_id_prev = $m_prod_id;
		}
	}
	else { 
		# don't have m_prod_ids
		undef $csv;
		$csv = "%%target_path%%".$pid.".xml\t".$pid."\t".$updated."\t".$p->{'content_measure'}."\t".$p->{'supplier_id'}."\t".$p->{'prod_id'}."\t".$p->{'catid'}."\t\t".$ean2file->{'csv'}."\t".$p->{'on_market'}."\t".$country2file->{'csv'}."\t".$p->{'name'}."\t".$p->{'agr_prod_count'}. "\t" . $p->{'high_pic'} ."\t" . $p->{'high_pic_size'} ."\t" . $p->{'high_pic_width'} ."\t" . $p->{'high_pic_height'} ."\n";
		# append
		$csv_all .= $csv;
	}

### 3.

	# collect eans
	if ($ean2file->{'xml'}) {
		undef $xml;
		$xml = "\n\t\t\t<EAN_UPCS>".$ean2file->{'xml'}."\n\t\t\t</EAN_UPCS>";
		# append
		$xml_all .= $xml;
	}

### 4.

	# collect countries
	if ($country2file->{'xml'}) {
		undef $xml;
		$xml = "\n\t\t\t<Country_Markets>".$country2file->{'xml'}."\n\t\t\t</Country_Markets>";
		# append
		$xml_all .= $xml;
	}
	
### 5.

	# should we include distributors
#	if (0) {
#		undef $xml;
#		
#		$xml = &getDistri_xml_tags($p->{'distri_set'});
#		# append
#		$xml_all .= $xml;
#	}

### FINISH

	undef $xml;
	$xml = "</file>";

	# append
	$xml_all .= $xml;
	
	return {
		'csv' => $csv_all,
		'xml' => $xml_all
	};
} # sub create_index_pair

sub remove_product_from_repository {
	my ($product_id) = @_;
	return unless ($product_id);
	my ($cmd, $smart_path, $prefix_path, $suffix_path);
	my $langs = &do_query("select langid, short_code from language where published='Y'");
	my %lang_dir = map {$_->[0] => $_->[1]} @$langs;
	$lang_dir{0} = 'INT';

	my $rm_cmd = '/bin/rmdir -p --ignore-fail-on-non-empty';


	foreach my $langid (sort {$a <=> $b} keys %lang_dir) {
		$smart_path = &get_smart_path($product_id);
		$suffix_path = 'level4/'.$lang_dir{$langid}.'/';
		$prefix_path = $atomcfg{'xml_path'}.$suffix_path;
		$cmd = '/bin/rm -f '.$prefix_path.$smart_path.$product_id.'.xml';
		&log_printf("remove file: ".$cmd);
		`$cmd`;
		if ($atomcfg{'backup_enable'}) {
			$cmd = '/usr/bin/ssh '.$atomcfg{'backup_host'}." '/bin/rm -f ".$atomcfg{'backup_path'}.$suffix_path.$smart_path.$product_id.".xml'";
			&log_printf("remote remove file: ".$cmd);
			`$cmd`;
		}
		$cmd = '/bin/rm -f '.$prefix_path.$smart_path.$product_id.'.xml.gz';
		&log_printf("remove file: ".$cmd);
		`$cmd`;
		if ($atomcfg{'backup_enable'}) {
			$cmd = '/usr/bin/ssh '.$atomcfg{'backup_host'}." '/bin/rm -f ".$atomcfg{'backup_path'}.$suffix_path.$smart_path.$product_id.".xml.gz'";
			&log_printf("remote remove file: ".$cmd);
			`$cmd`;
		}

		# remove all dirs
		$cmd = 'cd '.$prefix_path.' && '.$rm_cmd.' '.$smart_path;
		&log_printf("remove dir: ".$cmd);
		`$cmd`;
		if ($atomcfg{'backup_enable'}) {
			$cmd = '/usr/bin/ssh '.$atomcfg{'backup_host'}." 'cd ".$atomcfg{'backup_path'}.$suffix_path." && ".$rm_cmd.' '.$smart_path."'";
			&log_printf("remote remove dir: ".$cmd);
			`$cmd`;
		}
	}

}
																																																								
sub format_date {
	my ($time) = @_;
	my $generated = strftime("%Y%m%d%H%M%S", localtime($time));
	return $generated;
}

sub generate_xml_file_OLD {
	my $generated = &format_date(time());
	my $xml_content = &xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/files.index.dtd>\n".&source_message()."\n"."<ICECAT-interface " . &xsd_header("files.index") . ">\n\t<files.index Generated=\"$generated\">";
	my $users = &do_query('select user_id, user_group from users');
	my %user = map { $_->[0] =>  $_->[1] } @$users;
	my $prod_data = &do_query("select product_id, supplier_id, prod_id, user_id from product");
	
	foreach my $row(@$prod_data){
		my $updated = &format_date(&get_product_date($row->[0]));
		my $quality = &get_quality_measure($user{$row->[3]});
		if(!&get_quality_index($quality)){ next; } #not editors product => ignored
		$xml_content .= "\n\t\t<file path=\"$atomcfg{xml_dir_path}".$row->[0].".xml\""." Product_ID=\"$row->[0]\" Updated=\"$updated\" Quality=\"$quality\" Supplier_id=\"$row->[1]\" Prod_ID=\"".&str_xmlize($row->[2])."\"/>";
	}
	$xml_content .= "\n\t</files.index>\n</ICECAT-interface>";    
	return \$xml_content;
} # sub generate_xml_file_OLD

#my $xxx = 0;

sub is_daily {
	my ($data, $today, $yesterday) = @_;

	if (uc($data->{'quality'}) eq 'SUPPLIER') {
    #   return (($data->{'date_added'} < $$today) && ($data->{'date_added'} >= $$yesterday))? 1 : 0;
		return (($data->{'updated'} < $$today) && ($data->{'updated'} >= $$yesterday)) ? 1 : 0;
	}
	elsif (uc($data->{'quality'}) eq 'ICECAT')  {
		return (($data->{'updated'} < $$today) && ($data->{'updated'} >= $$yesterday)) ? 1 : 0;
	}

	return 0;
} # sub is_daily

sub create_index_files {

	my ($only_vendor_too, $cond, $progress, $daily_products) = @_; 
	
	# $only_vendor_too - also collect only_vendor (product.public='Limited') strings;
	# $cond - also collect on_market strings

	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';

	my ($collect, $handles, $handle, $file);
	$handles = {
    'XML' => 'files.index.xml',
    'CSV' => 'files.index.csv',
    'DAILYXML' => 'daily.index.xml',
    'DAILYCSV' => 'daily.index.csv',
    'ONMARKETXML' => 'on_market.index.xml',
    'ONMARKETCSV' => 'on_market.index.csv',
    'NOBODYXML' => 'nobody.index.xml',
    'NOBODYCSV' => 'nobody.index.csv'
  };

	print "\ncreate handles: " if ($progress);

    foreach my $h (keys %$handles) {
		$handle = new IO::File;
		$file = "/tmp/".$$."_".$handles->{$h};
		open($handle, "> ".$file);
		$handle->binmode(":utf8");
		$collect->{$h}->{'handle'} = $handle;
		$collect->{$h}->{'draftfilename'} = $file;
		$collect->{$h}->{'filename'} = $handles->{$h};

		print "." if ($progress);
    }

	print "\b done" if ($progress);

	if ($only_vendor_too) {

		print "\ncreate handles only_vendors: " if ($progress);
		
		foreach my $h (keys %$handles) {
			$handle = new IO::File;
			$file = "/tmp/".$$."_".$handles->{$h}."_only_vendor";
			open($handle, "> ".$file);
			$handle->binmode(":utf8");
			$collect->{$h.'ONLYVENDOR'}->{'handle'} = $handle;
			$collect->{$h.'ONLYVENDOR'}->{'draftfilename'} = $file;
			$collect->{$h.'ONLYVENDOR'}->{'filename'} = $handles->{$h};
			
			print "." if ($progress);
		}
		
		print "\b done" if ($progress);
	}

	# main cycle
	my $today = &format_date(time);
	$today =~ s/.{6}$/000000/;

	my $yesterday = &format_date(time-24*60*60);
	$yesterday =~ s/.{6}$/000000/;

	my ($xml, $csv, $updated, $date_added, $m_prod_ids, $daily, $cmd, @m_prod_ids, $prod_id_prev, @ean_upcs, $ean2file, $current, @countries, $country2file, $only_vendor_suffix);

	my $query = "
	    SELECT
	    tp.product_id, tp.supplier_id, tp.prod_id, tp.catid, tp.user_id, 
        cmim.content_measure, tp.updated, tp.mapped, tp.orig_set, tp.date_added,
        tp.ean_upc_set, tp.on_market, tp.only_vendor, tp.country_market_set, tp.name,
        tp.quality, tp.agr_prod_count, distri_set,
        high_pic, high_pic_size, high_pic_width, high_pic_height, tp.public
        FROM ".$table_name." tp
        INNER JOIN content_measure_index_map cmim ON tp.quality = cmim.quality_index
        ORDER BY tp.product_id asc
    ";

	my ($sth, $p, $i);
	
	# &log_printf("SQL QUERY DIRECTLY: " . $query . ";");
	$sth = $atomsql::dbh->prepare($query);
	$sth->execute();

	$current = $collect; # link current with collect

	print "\nproducts = ".$sth->rows.": " if ($progress);

    while ($p = $sth->fetchrow_arrayref) {
		$i++;

		if ($progress) {
			print $i." " unless ($i % 10000);
		}

		# Encode part
		&Encode::_utf8_on($p->[2]);
		&Encode::_utf8_on($p->[8]);
		&Encode::_utf8_on($p->[10]);
		&Encode::_utf8_on($p->[13]);
		&Encode::_utf8_on($p->[14]);

		$p->[16] = int($p->[16]) eq $p->[16] ? $p->[16] : '0';

		# go on
		$p->[14] =~  s/\t//gs;
		$p->[14] =~  s/\r/\\r/gs; # found by Alexey Osadchiy, 23.04.2010, fixed by dima
		$p->[14] =~  s/\n/\\n/gs; # found by Alexey Osadchiy, 23.04.2010, fixed by dima
		$p->[14] =~  s/\\$//s;
		
		# new info about high_pic
		$p->[18] = '' if (! $p->[18]);
		$p->[19] = 0 if (! $p->[19]);
		$p->[20] = 0 if (! $p->[20]);
		$p->[21] = 0 if (! $p->[21]);

		# bug with tabs in prod_ids (found by Artem, 8.09.2009, fixed by dima)
		$p->[2] =~ s/\t/\\t/gs;

		if ($only_vendor_too) {
			if ($p->[12] eq '1') {
				$only_vendor_suffix = 'ONLYVENDOR';
			}
			else {
				$only_vendor_suffix = '';
			}
		}

		# set updated
		$updated = &format_date($p->[6]);
		$date_added = &format_date($p->[9]);
		$daily = is_daily({ 'updated' => $updated, 'date_added' => $date_added, 'quality' => $p->[5] }, \$today, \$yesterday);
		
		# log_printf($yesterday . " " . $updated . " " . $today);
		
		# save product_id if daily
		if ($daily) {
		    $daily_products->{$p->[0]} = $p->[22];
		}

		undef $ean2file;
		$ean2file = { 'csv' => '', 'xml' => '' };

		undef $country2file;
		$country2file = { 'csv' => '', 'xml' => '' };
		
		if ($p->[10]) { # if we have the set of EANs
			# collect EAN_UPC-s
			@ean_upcs = sort {$a cmp $b} split /\t/, $p->[10];
			
			if ($#ean_upcs > -1) {
				foreach my $ean_upc (@ean_upcs) {
					next unless ($ean_upc);
					$ean2file->{'csv'} .= $ean_upc.";";
					$ean2file->{'xml'} .= "\n\t\t\t\t<EAN_UPC Value=\"".&str_xmlize($ean_upc)."\"/>";
				}
				chop($ean2file->{'csv'});
			}
		}

		if ($p->[13]) { #if we have the set of Countries
			# collect Country-s
			@countries = sort {$a cmp $b} split /\t/, $p->[13];
			
			if ($#countries > -1) {
				foreach my $country (@countries) {
					next unless ($country);
					$country2file->{'csv'} .= $country.";";
					$country2file->{'xml'} .= "\n\t\t\t\t<Country_Market Value=\"".&str_xmlize($country)."\"/>";
				}
				chop($country2file->{'csv'});
			}
		}
		
		undef $xml;
		$xml = "\n\t\t<file path=\"%%target_path%%".$p->[0].".xml\" ".
			"Product_ID=\"$p->[0]\" ".
			"Updated=\"".$updated."\" ".
			"Quality=\"".$p->[5]."\" ".
			"Supplier_id=\"".$p->[1]."\" ".
			"Prod_ID=\"".&str_xmlize($p->[2])."\" ".
			"Catid=\"".$p->[3]."\" ".
			"On_Market=\"".$p->[11]."\" ".
			"Model_Name=\"".&str_xmlize($p->[14])."\" ".
			"Product_View=\"" . &str_xmlize($p->[16])."\" ".
			"HighPic=\"" . str_xmlize($p->[18]) . "\" ".
			"HighPicSize=\"" . $p->[19] . "\" ".
			"HighPicWidth=\"" . $p->[20] . "\" " .
			"HighPicHeight=\"" . $p->[21] . "\">";

		if ($p->[15] != 0) {
			$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ($daily) {
			$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
			$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ($p->[15] == 0) {
			$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}

		# collect M_Prod_ID-s
		@m_prod_ids = sort {$a cmp $b} split /\t/, $p->[8];

		if ($#m_prod_ids > -1) { # have some m_prod_ids

			$prod_id_prev = '';

			foreach my $m_prod_id (@m_prod_ids) {
				next unless ($m_prod_id);
				next if ($p->[2] eq $m_prod_id);
				next if ($prod_id_prev eq $m_prod_id);
				undef $csv;
				$csv = "%%target_path%%".$p->[0].".xml\t".$p->[0]."\t".$updated."\t".$p->[5]."\t".$p->[1]."\t".$p->[2]."\t".$p->[3]."\t".$m_prod_id."\t".$ean2file->{'csv'}."\t".$p->[11]."\t".$country2file->{'csv'}."\t".$p->[14]."\t".$p->[16] .	"\t" . $p->[18] ."\t" . $p->[19] ."\t" . $p->[20] ."\t" . $p->[21] . "\n";

				undef $xml;
				$xml = "\n\t\t\t<M_Prod_ID>".&str_xmlize($m_prod_id)."</M_Prod_ID>";
				
				if ($p->[15] != 0) {
					$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
					print $handle $xml;
					$handle = $collect->{'CSV'.$only_vendor_suffix}->{'handle'};
					print $handle $csv;
				}
				if ($daily) {
					$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
					print $handle $xml;
					$handle = $collect->{'DAILYCSV'.$only_vendor_suffix}->{'handle'};
					print $handle $csv;
				}
				if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
					$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
					print $handle $xml;
					$handle = $collect->{'ONMARKETCSV'.$only_vendor_suffix}->{'handle'};
					print $handle $csv;
				}
				if ($p->[15] == 0) {
					$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
					print $handle $xml;
					$handle = $collect->{'NOBODYCSV'.$only_vendor_suffix}->{'handle'};
					print $handle $csv;
				}

				$prod_id_prev = $m_prod_id;
			}

		}
		else { # don't have m_prod_ids
			undef $csv;
			$csv = "%%target_path%%".$p->[0].".xml\t".$p->[0]."\t".$updated."\t".$p->[5]."\t".$p->[1]."\t".$p->[2]."\t".$p->[3]."\t\t".$ean2file->{'csv'}."\t".$p->[11]."\t".$country2file->{'csv'}."\t".$p->[14]."\t".$p->[16]. "\t" . $p->[18] ."\t" . $p->[19] ."\t" . $p->[20] ."\t" . $p->[21] ."\n";

			if ($p->[15] != 0) {
				$handle = $collect->{'CSV'.$only_vendor_suffix}->{'handle'};
				print $handle $csv;
			}
			if ($daily) {
				$handle = $collect->{'DAILYCSV'.$only_vendor_suffix}->{'handle'};
				print $handle $csv;
			}
			if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
				$handle = $collect->{'ONMARKETCSV'.$only_vendor_suffix}->{'handle'};
				print $handle $csv;
			}
			if ($p->[15] == 0) {
				$handle = $collect->{'NOBODYCSV'.$only_vendor_suffix}->{'handle'};
				print $handle $csv;
			}
		}

		# collect eans
		if ($ean2file->{'xml'}) {
			undef $xml;
			$xml = "\n\t\t\t<EAN_UPCS>".$ean2file->{'xml'}."\n\t\t\t</EAN_UPCS>";
			if ($p->[15] != 0) {
				$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($daily) {
				$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
				$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($p->[15] == 0) {
				$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
		}

		# collect countries
		if ($country2file->{'xml'}) {
			undef $xml;
			$xml = "\n\t\t\t<Country_Markets>".$country2file->{'xml'}."\n\t\t\t</Country_Markets>";
			if ($p->[15] != 0) {
				$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($daily) {
				$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
				$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($p->[15] == 0) {
				$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
		}
		# should we include distributors
		if ($cond->{'do_add_distri'}) {
			undef $xml;
			$xml = &getDistri_xml_tags($p->[17]);
			if ($p->[15] != 0) {
				$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($daily) {
				$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
				$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
			if ($p->[15] == 0) {
				$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
				print $handle $xml;
			}
		}	
		
		undef $xml;
		$xml = "</file>";

		if ($p->[15] != 0) {
			$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ($daily) {
			$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ((defined $cond) && ($cond->{'on_market'} eq $p->[11]) && ($p->[15] != 0)) {
			$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		if ($p->[15] == 0) {
			$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $xml;
		}
		
  } # while
  
	if ($daily) {
		my $today_d = $today;
		my $yesterday_d = $yesterday;
		
		$today_d =~ s/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/$1-$2-$3 $4:$5:$6/;
		$yesterday_d =~ s/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/$1-$2-$3 $4:$5:$6/;
		
		my $deleted_p = &do_query("
		    select product_id, unix_timestamp(del_time), prod_id, catid, name, supplier_id
		    from product_deleted
		    where unix_timestamp(del_time) < unix_timestamp('".$today_d."') and unix_timestamp(del_time) >= unix_timestamp('".$yesterday_d."')
		");
		
		foreach my $p_d (@$deleted_p) {
			$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
			print $handle "\n\t\t<file path=\"%%target_path%%".$p_d->[0].".xml\""." Product_ID=\"$p_d->[0]\" Updated=\"".&format_date($p_d->[1]) . 
			"\" Quality=\"REMOVED\" Supplier_id=\"".$p_d->[5]."\" Prod_ID=\"".&str_xmlize($p_d->[2])."\" Catid=\"".$p_d->[3].
			"\" On_Market=\"0\" Model_Name=\"".&str_xmlize($p_d->[4])."\" Product_View=\"0\" HighPic=\"\" HighPicSize=\"0\" HighPicWidth=\"0\" HighPicHeight=\"0\"></file>";
			
			$handle = $collect->{'DAILYCSV'.$only_vendor_suffix}->{'handle'};
			print $handle "%%target_path%%".$p_d->[0].".xml\t".$p_d->[0]."\t".&format_date($p_d->[1])."\tREMOVED\t".$p_d->[5]."\t".$p_d->[2]."\t".$p_d->[3]."\t\t\t0\t\t0\n";
		}
	}

	print $sth->rows." done" if ($progress);

  foreach my $h (keys %$handles) {
		$handle = $collect->{$h}->{'handle'};
		close $handle;
  }

	if ($only_vendor_too) {
		foreach my $h (keys %$handles) {
			$handle = $collect->{$h.'ONLYVENDOR'}->{'handle'};
			close $handle;
		}
	}

	return $collect;
} # sub create_index_files

sub create_index_files_from_index_cache {
	my ($only_vendor_too, $cond, $progress, $daily_products) = @_; 
	
	# $only_vendor_too - also collect only_vendor (product.public='Limited') strings;
	# $cond - also collect on_market strings

	my $table_name = $cond->{'table_name'} ? $cond->{'table_name'} : 'itmp_product';

	my ($collect, $handles, $handle, $file);

	$handles = {
    'XML' => 'files.index.xml',
    'CSV' => 'files.index.csv',
    'DAILYXML' => 'daily.index.xml',
    'DAILYCSV' => 'daily.index.csv',
    'ONMARKETXML' => 'on_market.index.xml',
    'ONMARKETCSV' => 'on_market.index.csv',
    'NOBODYXML' => 'nobody.index.xml',
    'NOBODYCSV' => 'nobody.index.csv'
  };

	print "\ncreate handles: " if ($progress);
	
	foreach my $h (keys %$handles) {
		$handle = new IO::File;
		$file = "/tmp/".$$."_".$handles->{$h};
		open($handle, "> ".$file);
		$handle->binmode(":utf8");
		$collect->{$h}->{'handle'} = $handle;
		$collect->{$h}->{'draftfilename'} = $file;
		$collect->{$h}->{'filename'} = $handles->{$h};
		
		print "." if ($progress);
	}
	
	print "\b done" if ($progress);

	if ($only_vendor_too) {

		print "\ncreate handles only_vendors: " if ($progress);
		
		foreach my $h (keys %$handles) {
			$handle = new IO::File;
			$file = "/tmp/".$$."_".$handles->{$h}."_only_vendor";
			open($handle, "> ".$file);
			$handle->binmode(":utf8");
			$collect->{$h.'ONLYVENDOR'}->{'handle'} = $handle;
			$collect->{$h.'ONLYVENDOR'}->{'draftfilename'} = $file;
			$collect->{$h.'ONLYVENDOR'}->{'filename'} = $handles->{$h};
			
			print "." if ($progress);
		}
		
		print "\b done" if ($progress);
	}

	# main cycle
	my $today = &format_date(time);
	$today =~ s/.{6}$/000000/;
	my $yesterday = &format_date(time - 24 * 60 * 60);
	$yesterday =~ s/.{6}$/000000/;

#	my ($xml, $csv, $updated, $date_added, $m_prod_ids, $daily, $cmd, @m_prod_ids, $prod_id_prev, @ean_upcs, $ean2file, $current, @countries, $country2file);
	my ($current, $only_vendor_suffix, $daily, $updated, $date_added);

	my $query = "SELECT STRAIGHT_JOIN pic.product_id, pic.xml_info, pic.csv_info, cmim.quality_index, cmim.content_measure, tp.only_vendor, tp.on_market, tp.updated, tp.date_added
FROM       ".$table_name." tp
INNER JOIN product_index_cache pic        USING (product_id)
INNER JOIN users u                        USING (user_id)
INNER JOIN user_group_measure_map ugmm    USING (user_group)
INNER JOIN content_measure_index_map cmim ON ugmm.measure = cmim.content_measure
ORDER BY   tp.product_id ASC";

	my ($sth, $p, $i);

	&lp(&do_query_dump('EXPLAIN '.$query));

	&log_printf("SQL QUERY DIRECTLY: " . $query . ";");
	$sth = $atomsql::dbh->prepare($query);
	$sth->execute();

	$current = $collect; # link current with collect

	print "\nproducts = " . $sth->rows . ": " if ($progress);

	while ($p = $sth->fetchrow_arrayref) {
		for (my $j = 0; $j <= $#$p; $j++) {
			&Encode::_utf8_on($p->[$j]);
		}

		$i++;
		
		if ($progress) {
			print $i." " unless ($i % 10000);
		}
		
		if ($only_vendor_too) {
			if ($p->[5] eq '1') {
				$only_vendor_suffix = 'ONLYVENDOR';
			}
			else {
				$only_vendor_suffix = '';
			}
		}
		
		$updated = &format_date($p->[7]);
		$date_added = &format_date($p->[8]);
		$daily = is_daily({ 'updated' => $updated, 'date_added' => $date_added, 'quality' => $p->[4] }, \$today, \$yesterday);
		
		# save product_id if daily
		if ($daily) {
			$daily_products->{$p->[0]} = $p->[3];
		}
		
		# xml
		if ($p->[3] > 0) {
			$handle = $collect->{'XML'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[1];
		}
		if ($daily) {
			$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[1];
		}
		if ((defined $cond) && ($cond->{'on_market'} eq $p->[6]) && ($p->[3] > 0)) {
			$handle = $collect->{'ONMARKETXML'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[1];
		}
		if ($p->[3] == 0) {
			$handle = $collect->{'NOBODYXML'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[1];
		}
		
		# csv
		if ($p->[3] != 0) {
			$handle = $collect->{'CSV'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[2];
		}
		if ($daily) {
			$handle = $collect->{'DAILYCSV'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[2];
		}
		if ((defined $cond) && ($cond->{'on_market'} eq $p->[6]) && ($p->[3] != 0)) {
			$handle = $collect->{'ONMARKETCSV'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[2];
		}
		if ($p->[3] == 0) {
			$handle = $collect->{'NOBODYCSV'.$only_vendor_suffix}->{'handle'};
			print $handle $p->[2];
		}
		
	} # while
  
	# trying to add deleted (QUALITY = REMOVED) products
	if ($daily) {
		my $today_d = $today;
		my $yesterday_d = $yesterday;
		
		$today_d =~ s/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/$1-$2-$3 $4:$5:$6/;
		$yesterday_d =~ s/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/$1-$2-$3 $4:$5:$6/;
		
		my $deleted_p = &do_query("
		    SELECT product_id, unix_timestamp(del_time), prod_id, catid, name, supplier_id
		    FROM   product_deleted
		    WHERE  unix_timestamp(del_time) < unix_timestamp('".$today_d."') AND unix_timestamp(del_time) >= unix_timestamp('".$yesterday_d."')
		");
		
		foreach my $p_d (@$deleted_p) {
			$handle = $collect->{'DAILYXML'.$only_vendor_suffix}->{'handle'};

			# probably, we need to add it to the additional XML cache... will think about it
			print $handle "\n\t\t<file path=\"%%target_path%%".$p_d->[0].".xml\""." Product_ID=\"".$p_d->[0]."\" Updated=\"".&format_date($p_d->[1]) . 
				"\" Quality=\"REMOVED\" Supplier_id=\"".$p_d->[5]."\" Prod_ID=\"".&str_xmlize($p_d->[2])."\" Catid=\"".$p_d->[3].
				"\" On_Market=\"0\" Model_Name=\"".&str_xmlize($p_d->[4])."\" Product_View=\"0\" />";
			
			$handle = $collect->{'DAILYCSV'.$only_vendor_suffix}->{'handle'};

			# probably, we need to add it to the additional CSV cache... will think about it
			print $handle "%%target_path%%".$p_d->[0].".xml\t".$p_d->[0]."\t".&format_date($p_d->[1])."\tREMOVED\t".$p_d->[5]."\t".$p_d->[2]."\t".$p_d->[3]."\t\t\t0\t\t0\n";
		}
	}

	print $sth->rows." done" if ($progress);

  foreach my $h (keys %$handles) {
		$handle = $collect->{$h}->{'handle'};
		close $handle;
  }

	if ($only_vendor_too) {
		foreach my $h (keys %$handles) {
			$handle = $collect->{$h.'ONLYVENDOR'}->{'handle'};
			close $handle;
		}
	}

	return $collect;
} # sub create_index_files_from_index_cache

sub store_index {
	my $hash_ref = shift;
	
	my $path = $hash_ref->{'path'};
	my $content = $hash_ref->{'content'};
	my $langid = $hash_ref->{'langid'};
	my $supplier_id = $hash_ref->{'supplier_id'};
	my $subscription_level = $hash_ref->{'subscription_level'};
	
	print "store: " if $hash_ref->{'progress'};
	
	my $generated = &format_date(time);
	
	## check if daily.index.xml need to update
	my ($cmd, $mtime, $is_daily_updated_today);
	my $today = &format_date(time);
	$today =~ s/.{6}$/000000/;	
	if (-e $path."/daily.index.xml") {
		(undef,undef,undef,undef,undef,undef,undef,undef,undef,$mtime) = stat($path."/daily.index.xml");
		$mtime = &format_date($mtime);
		$is_daily_updated_today = $mtime < $today ? 1 : 0;
	}
	else {
		$is_daily_updated_today = 1;
	}
	
	# prepare replace target
  my $relpath = $path;
  $relpath =~ s/$atomcfg{'xml_path'}/export\//s;
	$relpath = quotemeta($relpath);
	
	# create header & footer files
	open XMLHEADER, ">".$path."xml_header";
	binmode XMLHEADER, ":utf8";
	print XMLHEADER &xml_utf8_tag .
		"<!DOCTYPE ICECAT-interface SYSTEM \"" . $atomcfg{host} . "dtd/files.index.dtd\">\n" .
		&source_message()."\n<ICECAT-interface " . &xsd_header("files.index") . ">\n\t<files.index Generated=\"" . $generated . "\">";
	close XMLHEADER;
	
	open CSVHEADER, ">".$path."csv_header";
	binmode CSVHEADER, ":utf8";
	print CSVHEADER "path\tproduct_id\tupdated\tquality\tsupplier_id\tprod_id\tcatid\tm_prod_id\tean_upc\ton_market\tcountry_market\tmodel_name\tproduct_view\thigh_pic\thigh_pic_size\thigh_pic_width\thigh_pic_height\n";
	close CSVHEADER;
	
	open XMLFOOTER, ">".$path."xml_footer";
	binmode XMLFOOTER, ":utf8";
	print XMLFOOTER "\n\t</files.index>\n</ICECAT-interface>";
	close XMLFOOTER;
	
	# copying & seding
	foreach my $t ('XML','CSV','DAILYXML','DAILYCSV','ONMARKETXML','ONMARKETCSV','NOBODYXML','NOBODYCSV') {
		print $t.":" if $hash_ref->{'progress'};
 
		if (($t =~ 'DAILY' && !$is_daily_updated_today) || ($t =~ 'ONMARKET' && -z $content->{$t}->{'filename'})) {
			print "- " if $hash_ref->{'progress'};
			next;
		}
		
		# copy draft content to proper place
		$cmd = '/bin/cp '.$content->{$t}->{'draftfilename'}.' '.$path.$content->{$t}->{'filename'}.'.new';
		`$cmd`;
		
		# restrict if needed
		print "R" if $hash_ref->{'progress'};
		$cmd =
			$atomcfg{'base_dir'} . "/bin/filter_supplier_products " .
			$path . $content->{$t}->{'filename'} . '.new ' .    # 1
			$langid . " " .                                     # 2
			$supplier_id . " " .                                # 3
			$subscription_level;                                # 4
		`$cmd`;
		
		# sed everything
		print "S" if $hash_ref->{'progress'};
		#$cmd = "/bin/sed -i -e 's/%%target_path%%/".$relpath."/g' ".$path.$content->{$t}->{'filename'}.'.new';
		$cmd = "/usr/bin/minised -e 's/%%target_path%%/".$relpath."/g' ".$path.$content->{$t}->{'filename'}.'.new > '.$path.$content->{$t}->{'filename'}.'.new.minised';
		`$cmd`;
#		&log_printf($cmd);
		$cmd = "/bin/mv -f ".$path.$content->{$t}->{'filename'}.'.new.minised '.$path.$content->{$t}->{'filename'}.'.new';
		`$cmd`;
#		&log_printf($cmd);

		# append header & footer files
		print "C" if $hash_ref->{'progress'};
		if ($t =~ /XML/) {
			$cmd = '/bin/cat '.$path.'xml_header '.$path.$content->{$t}->{'filename'}.'.new '.$path.'xml_footer > '.$path.$content->{$t}->{'filename'};
			`$cmd`;
			$cmd = '/bin/rm -f '.$path.$content->{$t}->{'filename'}.'.new';
			`$cmd`;
		}
		else {
			$cmd = '/bin/cat '.$path.'csv_header '.$path.$content->{$t}->{'filename'}.'.new > '.$path.$content->{$t}->{'filename'};
			`$cmd`;
			$cmd = '/bin/rm -f '.$path.$content->{$t}->{'filename'}.'.new';
			`$cmd`;
		}
		
		print "Z" if $hash_ref->{'progress'};
		$cmd = "/bin/cat ".$path.$content->{$t}->{'filename'}." | /bin/gzip -9 > ".$path.$content->{$t}->{'filename'}.".gz";
		`$cmd`; #&run_bg_command($cmd." &");
		if(($t eq 'DAILYXML' or $t eq 'DAILYCSV') and (!$supplier_id or $supplier_id eq '0') and $path=~/level4/){
			use Time::Piece;
			my $date_obj=Time::Piece->new(time());
			my $curr_day=$date_obj->mday();
			$date_obj=$date_obj->add_months(-1);
			my $year=$date_obj->year();
			my $month=$date_obj->mon();
			my $last_month=$atomcfg{'base_dir'}."history_files/$year/$month/";
			if(-d $last_month and $month and $year and $curr_day==20){
				`rm -R $last_month`;
				&lp('Remove last month data');
			};			
			copyToDateDir($atomcfg{'base_dir'}.'history_files/',time(),$path.$content->{$t}->{'filename'}.".gz",'lang_'.$langid.'_');
		}
		print " " if $hash_ref->{'progress'};
	}
	
	# cgi
  $cmd = "/bin/ln -s -f ".$atomcfg{'www_path'}."/files.index.cgi ".$path."/files.index.cgi";
	`$cmd`;
	
	# remove headers - footers
	$cmd = "/bin/rm -f ".$path."xml_header";
	`$cmd`;
	$cmd = "/bin/rm -f ".$path."xml_footer";
	`$cmd`;
	$cmd = "/bin/rm -f ".$path."csv_header";
	`$cmd`;
} # sub store_index

sub get_files_index_xml {
	my $xml_file_path = $atomcfg{'xml_export_path'}."/level4/INT/files.index.xml";
	my @xml_file_content;
	if(!open(XML_FILE, $xml_file_path)){
		log_printf("Can't open '$xml_file_path'");
		return;
	}
	flock(XML_FILE, 2);
	@xml_file_content = <XML_FILE>;
	
	close(XML_FILE);
	return \@xml_file_content;
}

sub get_product_partsxml_data {
	my ($p_id) = @_;
	my $rh = {};
	my $nowtime = time();
	my $pr_req = {};

	$rh->{'Date'} = localtime($nowtime);

  $pr_req->{'ID'} = $p_id;
								
  my $data = &do_query(
    "select     p.product_id,   p.prod_id,      p.supplier_id,      s.name,             p.catid,      
                p.name,         p.low_pic,      p.high_pic,         p.thumb_pic,        u.user_group, 
                p.family_id,    p.low_pic_size, p.high_pic_size,    p.thumb_pic_size,   p.date_added,                 
                p.high_pic_width,   p.high_pic_height, 
                p.low_pic_width,    p.low_pic_height                
     from product p inner join supplier s using (supplier_id) inner join users u on p.user_id=u.user_id where p.product_id = " . $p_id
  );

  my $eans = &do_query("select ean_code from product_ean_codes where product_id = ".$p_id);

	# building EAN codes list
  my $ean_content = [];

  foreach my $r (@$eans) {
    push @$ean_content, { 'EAN' => $r->[0] };
  }
														
  my $code = 1;
  my $row = $data->[0];
											
	# building cats for product
  my $cat_content = [];

	# building families for product
  my $fam_content = [];
																			 
	# building product_description entries
  my $des_content = [];

	# processing category features group
  my $group_content = [];

	# building features list
	my $feat_content = [];

	# building related list
	my $rel_content = [];

	# building summary description list
	my $summary_content = [];
																																																																																																																												 																					
	# building bundled products
  my $bndl_data = &do_query("select pb.id, pb.bndl_product_id, p.prod_id, p.supplier_id, s.name, p.name, p.thumb_pic
from product_bundled pb inner join product p on pb.bndl_product_id=p.product_id inner join supplier s using (supplier_id)
where pb.product_id = ".$row->[0]);
  my $bndl_content = [];
									
  foreach my $rel_row (@$bndl_data) {
    push @$bndl_content,
		{
			'ID' => $rel_row->[0],
			'Product' => {
				'ID' => $rel_row->[1],
				'Supplier' => {
					'ID' => $rel_row->[3],
					'Name' => $rel_row->[4]
				},
						'Prod_id'   => $rel_row->[2],
						'Name'      => $rel_row->[5],
						'ThumbPic'  => $rel_row->[6]
					}
		}
	}
	
	# build gallery
  my $gallery_data = &do_query("select id, link, thumb_link, height, width, size, thumb_size from product_gallery where product_id = ".$row->[0]);
  my $gallery_content = []; my $gallery_local_content = [];

  foreach my $gallery_row (@$gallery_data) {
		push @$gallery_local_content, { 'ProductPicture_ID' => $gallery_row->[0],
																		'Pic' => $gallery_row->[1],
																		'ThumbPic' => $gallery_row->[2],
																		'PicHeight' => $gallery_row->[3],
																		'PicWidth' => $gallery_row->[4],
																		'Size' => $gallery_row->[5], 
																		'ThumbSize' => $gallery_row->[6], 
																		};
	}
  if ($gallery_data->[0][0]) {
		push @$gallery_content, { 'ProductPicture' => $gallery_local_content };
	}

  # build multimedia objects
  my $obj_content = [];
	my $obj_local_content = [];

  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ID'} = $p_id;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Code'} = $code;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Prod_id'} = $row->[1];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Quality'} = &get_quality_measure($row->[9]);
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Name'} = 'ProductNameXmlPart';
  $rh->{'ProductsList'}->{'Product'}->{ $row->[0] }->{'Title'} = 'ProductTitleXmlPart';
  
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPic'} = $row->[6];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPicSize'} = $row->[11];  
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPicWidth'} = $row->[17];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'LowPicHeight'} = $row->[18];
      
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPic'} = $row->[7];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPicSize'} = $row->[12];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPicWidth'} = $row->[15];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'HighPicHeight'} = $row->[16];
  
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ThumbPic'} = $row->[8];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ThumbPicSize'} = $row->[13];
  
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ReleaseDate'} = $row->[14];
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'EANCode'} = $ean_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Supplier'} = {'ID' => $row->[2],'Name' => $row->[3] };
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'Category'} = { 'ID' => $row->[4],'CategoryNameXMLPart' => $cat_content };
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductFamily'} = { 'ID' => $row->[10],'FamilyNameXMLPart' => $fam_content } if ($row->[10] != 0);
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductDescriptionXMLPart'} = $des_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductRelatedXMLPart'} = $rel_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductFeatureXMLPart'} = $feat_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductBundled'} = $bndl_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'CategoryFeatureGroupXMLPart'} = $group_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductGallery'} = $gallery_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'ProductMultimediaXMLPart'} = $obj_content;
  $rh->{'ProductsList'}->{'Product'}->{$row->[0]}->{'SummaryDescriptionXMLPart'} = $summary_content;
  
	my $response = { 'Response' => [$rh] };
	
	&atom_util::push_dmesg(3, "before xml_out");
	
	$response = &xml_out($response,
											 {
												 key_attr => {
													 'Measure'      => 'ID',
													 'Name'         => 'ID',
													 'Description'  => 'ID',
													 'Feature'      => 'ID',
													 'Category'     => 'ID',
													 'Supplier'     => 'ID',
													 'Product'      => 'ID',
													 #'CategoryFeatureGroup'=> 'ID',
													 'ProductFamily' => 'ID',
												 }
											 });

	&atom_util::push_dmesg(3, "after xml_out");
  $$response =~ s/<>//;
	$$response =~ s/<Response.*>//;
  $$response =~ s/<ProductsList>//;
	$$response =~ s/<\/ProductsList>//;
	$$response =~ s/<\/Response>//;
# $$response =~ s/<.+\"\?\d+\?\"\/>//;
  $$response =~ s/<\/>//;
  $$response =~ s/^\s*\n//g;
  $$response =~ s/\n\s*\n/\n/g;

	&atom_util::push_dmesg(3, "at end of get_product_partsxml_data");
	
  return $response;
} # sub get_product_partsxml_data


sub get_product_xml_from_cache{
	my ($p_id, $langid) = @_;
	my $suffix;
	if($langid){ $suffix = '_'.&do_query("select lower(short_code) from language where langid=$langid")->[0][0]; }
	my $xml_in_cache = &do_query("select 1 from product_xml_cache$suffix where product_id=$p_id")->[0][0];
	if(!$xml_in_cache){
		my $cmd = $atomcfg{'base_dir'}."/bin/update_product_xml_chunk $p_id";
		`$cmd`;
	}
	return &do_query("select xml_products_list_request_chunk from product_xml_cache$suffix where product_id=$p_id")->[0][0];
}

sub get_product_partsxml_fromdb {
	my ($p_id, $langid) = @_;

	my $lang_clause = '1';
	$lang_clause = " langid = ".$langid if ($langid);
	
	my $xml_chunk = &get_product_partsxml_data($p_id); # initial xml -> to xml_out (with templates)
	
	# change description
	my $xml_desc_chunk = &get_product_partsxml("desc", $langid, $p_id);
	chomp($$xml_desc_chunk);
	if (length($$xml_desc_chunk) == 0) {
		$$xml_desc_chunk = "<ProductDescription/>";
	}
	$$xml_chunk =~ s/<ProductDescriptionXMLPart\/>/$$xml_desc_chunk/gs;
	
	# change product name
	my $local_name = &str_xmlize(&do_query("select name from product_name where product_id = ".$p_id." and langid = ".$langid)->[0][0] ||
															 &do_query("select name from product where product_id = ".$p_id)->[0][0]);
	$$xml_chunk =~ s/ProductNameXmlPart/$local_name/sg;
	
	# change product title
	my $family_id = &do_query("SELECT family_id FROM product WHERE product_id=" . $p_id)->[0]->[0];
	my $fam_langid = $langid;
	# if there's no family in some language than take english
	# english langid=1 so desc order
	my $family_value = &do_query("SELECT v.value FROM product_family pf JOIN vocabulary v USING(sid) WHERE pf.family_id=" . $family_id . " AND v.langid IN (" . $fam_langid . ",1) ORDER BY v.langid DESC")->[0]->[0];
	my $model_name = &do_query("SELECT name FROM product_name WHERE product_id=" . $p_id . " AND langid=" . $langid)->[0]->[0] ||
		&do_query("SELECT name FROM product WHERE product_id=" . $p_id)->[0]->[0];
	my $brand = &do_query("SELECT s.name FROM product p JOIN supplier s USING(supplier_id) WHERE p.product_id=" . $p_id)->[0]->[0];
	foreach ( $brand, $family_value, $model_name ) {s/^\s+|\s+$//g}
	
	# this sub is for smart joining brand + family + model
	my $jbfm = sub {
		my ( $brand, $family, $model ) = @_;
		
		# anon sub find_common_and_non_common_part of family and model
		my $fcncp = sub {
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
		};
		
		my $bfm;
		my $c_ = $fcncp->( $family, $model );
		my $c = $c_->[0];
		if ($c) {
			$bfm = $brand . ' ' . $family . ' ' . $c_->[2];
		} else {
			$bfm = $brand . ' ' . $family . ' ' . $model;
		}
		return $bfm;
	};
	
	my $title = $jbfm->($brand, $family_value, $model_name);
	my $local_title = &str_xmlize($title);
	$$xml_chunk =~ s/ProductTitleXmlPart/$local_title/sg;
	
	# change product_feature values
	my $product_catid = &do_query("select catid from product where product_id = ".$p_id)->[0][0];
	
	my ($product_feat, $product_feat_local, $product_feat_chunks, $product_feat_local_chunks);
	my $fn_hash = {};	my $ms_hash = {};	my $msl_hash = {};
	
	# adding feature 'source' to every product
	my $p_feature_id = 6617; # &do_query("select f.feature_id from feature f inner join vocabulary v using(sid) where v.value='source' and langid=1")->[0][0];

	if ($p_feature_id) {
		my $p_category_feature_group_id = &do_query("select category_feature_group_id from category_feature_group where feature_group_id = 0 and catid = '".$product_catid."'")->[0][0];
		unless ($p_category_feature_group_id) {
			&do_statement("insert ignore into category_feature_group (catid,feature_group_id) values ('".$product_catid."',0)");
			$p_category_feature_group_id = &do_query("SELECT LAST_INSERT_ID()")->[0][0];
		}

		if ($p_category_feature_group_id > 0) {
			my $p_category_feature_id = &do_query("select category_feature_id from category_feature where feature_id = '".$p_feature_id."' and catid = '".$product_catid."'")->[0][0];

			unless ($p_category_feature_id) {
				&do_statement("insert ignore into category_feature (feature_id,catid,category_feature_group_id) values ('".$p_feature_id."','".$product_catid."','".$p_category_feature_group_id."')");
				$p_category_feature_id = &do_query("SELECT LAST_INSERT_ID()")->[0][0];
			}

			unless (&do_query("select product_feature_id from product_feature where product_id=".$p_id." and category_feature_id=".$p_category_feature_id)->[0][0]) {
				if ($p_category_feature_id > 0) {
					&do_statement("insert ignore into product_feature (product_id,category_feature_id,value) values ('".$p_id."','".$p_category_feature_id."','.')");
				}
				else {
					&log_printf("DBD: WRONG category_feature_id = `".$p_category_feature_id."`");
				}
			}
		}
		else {
			&log_printf("DBD: WRONG category_feature_group_id = `".$p_category_feature_group_id."`");
		}
	}
	
	## feature values - reworked

	my ($xml_pf_chunk, $metric_imperial, $presentation_value, $new_unit, $collect_features, $translated);

	my $feats = &get_overall_features_info_per_product($p_id, $langid, {'catid' => $product_catid});

	$collect_features = {};

	foreach (@$feats) {

		# decide about new feature ignoring

		next if ($collect_features->{$_->[17]});
		$collect_features->{$_->[17]} = 1;

		# process the new feature value
		$translated = 0;
		if (($_->[13] ne '') && ($_->[13] ne $_->[2])) { # replace value to vocabulary value
			$_->[2] = $_->[13];
			$translated = 1;
		}

		if ($_->[3] == 6617) { # replace `.` -> `ICEcat.biz` values
			$_->[1] = 'ICEcat.biz';
			$_->[2] = 'ICEcat.biz';
		}

		if ($langid) { # remove all others languages
			$_->[8] =~ s/^(<Name.*?)<Name.*$/$1/is;
			$_->[9] =~ s/^(<Sign.*?)<Sign.*$/$1/is;
		}

		# will form the new view of presentation value (according to the new German laws from 1.01.2010)

		if ($_->[11]) { # has unit
			use icecat_mapping;
			$metric_imperial = &system_of_measurement_transform($_->[2], $_->[3], $_->[4], $langid);
			if (($metric_imperial->{'metric'}) || ($metric_imperial->{'imperial'})) { # well-formed imperial & metric
				if ($langid == 9) { # imperial (*metric*) or *imperial*
					if ($metric_imperial->{'imperial'} ne $_->[2]) {
						$presentation_value = &form_presentation_value($metric_imperial->{'imperial'}, $metric_imperial->{'imperial_unit'}).
							" (".&form_presentation_value($metric_imperial->{'metric'}, $metric_imperial->{'metric_unit'}).")";
					}
					else {
						$presentation_value = &form_presentation_value($metric_imperial->{'imperial'}, $metric_imperial->{'imperial_unit'});
					}
				}
				else { # metric (*imperial*) or *metric*
					if ($metric_imperial->{'metric'} ne $_->[2]) {
						$presentation_value = &form_presentation_value($metric_imperial->{'metric'}, $metric_imperial->{'metric_unit'}).
							" (".&form_presentation_value($metric_imperial->{'imperial'}, $metric_imperial->{'imperial_unit'}).")";
					}
					else {
						$presentation_value = &form_presentation_value($metric_imperial->{'metric'}, $metric_imperial->{'metric_unit'});
					}
				}
			}
			else { # has unit, but hasn't well-formed imperial & metric
				$presentation_value = &form_presentation_value($_->[2], $_->[11]);
			}
		}
		else { # hasn't unit
			$presentation_value = &form_presentation_value($_->[2], $_->[11]);
		}

		$xml_pf_chunk .= "
	<ProductFeature Localized=\"".$_->[12]."\" ID=\"".$_->[0]."\" Local_ID=\"".$_->[18]."\" Value=\"".&str_xmlize($_->[1])."\"".
#	" Local_Value=\"".&str_xmlize($_->[2])."\"". # remove the Local_Value from the ProductFeature tag (2010.02.16, Martijn's wish)
	" CategoryFeature_ID=\"".$_->[5]."\" CategoryFeatureGroup_ID=\"".$_->[6]."\" No=\"".$_->[7]."\" Presentation_Value=\"".&str_xmlize($presentation_value)."\" Translated=\"".$translated."\"  Mandatory=\"".( $_->[20] ? '1' : $_->[19] )."\">
	  <Feature ID=\"".$_->[3]."\">
	    <Measure ID=\"".$_->[4]."\" Sign=\"".&str_xmlize($_->[10])."\">
	      ".($_->[9] ? "<Signs>".$_->[9]."</Signs>" : "<Signs/>" )."
	    </Measure>
	    ".$_->[8]."
	  </Feature>
	</ProductFeature>
";
	}

	$$xml_chunk =~ s/<ProductFeatureXMLPart\/>/$xml_pf_chunk/gms;
	
	# change products multimedia objects
	my $xml_obj_chunk = &get_product_partsxml("multimedia", $langid, $p_id);
	if (length($$xml_obj_chunk) == 0) {
		$$xml_obj_chunk = "<ProductMultimediaObject/>";
	}
	$$xml_chunk =~ s/<ProductMultimediaXMLPart\/>/$$xml_obj_chunk/gms;
	
	# change products family name
	#my $xml_family_chunk = &get_product_partsxml('family', $langid, $p_id);
	#if (length($$xml_family_chunk) == 0) {
		#$$xml_family_chunk = "<Name/>";
	#}
	#$$xml_chunk =~ s/<FamilyNameXMLPart\/>/$$xml_family_chunk/gms;
	
	my $family_data = &do_query( "select v.value, v.record_id, v.langid from product_family pf, vocabulary v, product p where p.product_id=" . $p_id . " and p.family_id=pf.family_id and pf.sid=v.sid and " . $lang_clause );
	my $series_data = &do_query( "select v.value, v.record_id, v.langid, ps.series_id from product_series ps, vocabulary v, product p where p.product_id=" . $p_id . " and p.series_id=ps.series_id and ps.sid=v.sid and " . $lang_clause );
	my $xml_family_chunk;
	if ( scalar @$family_data ) {
		foreach (@$family_data) {
			$xml_family_chunk .= "<Name ID=\"" . $_->[1] . "\" Value=\"" . &str_xmlize($_->[0]) . "\" langid=\"" . $_->[2] . "\"/>";
		}
		my $series_id = &do_query( "select series_id from product where product_id=" . $p_id )->[0]->[0];
		$xml_family_chunk .= "<Series ID=\"" . $series_id . "\">";
		if ( scalar @$series_data ) {
			foreach (@$series_data) {
				$xml_family_chunk .= "<Name ID=\"" . $_->[1] . "\" Value=\"" .&str_xmlize( $_->[0]) . "\" langid=\"" . $_->[2] . "\"/>"
			}
		} else {
			$xml_family_chunk .= "<Name/>";
		}
		$xml_family_chunk .= "</Series>";
	} else {
		$xml_family_chunk = '<Name/>';
	}
	$$xml_chunk =~ s/<FamilyNameXMLPart\/>/$xml_family_chunk/gms;
	
	# change products category name
	my $xml_cat_chunk = &get_product_partsxml('cat', $langid, $p_id);
	if (length($$xml_cat_chunk) == 0) {
		$$xml_cat_chunk = "<Name/>";
	}
	$$xml_chunk =~ s/<CategoryNameXMLPart\/>/$$xml_cat_chunk/gms;
  
	# change products feature group names
	my $xml_feat_grp_chunk = &get_product_partsxml('feat_grp', $langid, $p_id);
	$$xml_chunk =~ s/<CategoryFeatureGroupXMLPart\/>/$$xml_feat_grp_chunk/gms;
	
	# change products related (reworked 03.04.2008 by dima, cause of &xml_out problems, slow working with hashes, that contain above 7000 keys)
	my $xml_related_chunk = &get_product_partsxml('rel', $langid, $p_id);
	if (length($$xml_related_chunk) == 0) {
		$$xml_related_chunk = "<ProductRelated/>";
	}
	$$xml_chunk =~ s/<ProductRelatedXMLPart\/>/$$xml_related_chunk/gms;
	
	# summary description
	my $xml_summary_description_chunk = &get_product_partsxml('summary_description', $langid, $p_id);
	if (length($$xml_summary_description_chunk) == 0) {
		$$xml_summary_description_chunk = "<SummaryDescriptions/>";
	}
	$$xml_chunk =~ s/<SummaryDescriptionXMLPart\/>/$$xml_summary_description_chunk/gms;
	
	return $xml_chunk;
} # sub get_product_partsxml_fromdb

#use vars qw  ($data_features);
sub get_product_partsxml {
	my ($part, $langid, $p_id, $pf_id, $localized) = @_;
	
	my $lang_clause = '1';
	$lang_clause = "langid = $langid" if ($langid);
	$localized = '0' if ($localized ne '1');

	my $l_langid=1; # default langid
	my $row1;
 
    # get xml parts for description 
	if ($part eq 'desc') {
		my $incl_intDesc;
		my $backup_langid = do_query("SELECT backup_langid FROM language WHERE langid = $langid")->[0]->[0];
		
		#if($langid and $langid ne '1')
		
		# add backup language if exists
		$incl_intDesc = " or langid=$backup_langid " if ($backup_langid);
			
	my $des_data = &do_query("
	    select short_desc, long_desc, warranty_info, official_url,
   	    product_description_id, langid, pdf_url, pdf_size, manual_pdf_url, manual_pdf_size from product_description
   	    where product_id = $p_id and ($lang_clause $incl_intDesc)
   	");
   	
		my $des_content = [];
		foreach my $des_row (@$des_data) {
		
		   	# get default warranty info for certain (supplier_id, catid, langid)
          	my $ans = do_query("
           	    SELECT supplier_id, catid
   	            FROM product
           	    WHERE product_id = $p_id
           	");
           	my $supplier_id_tmp = $ans->[0]->[0];
           	my $catid_tmp = $ans->[0]->[1];
   	
           	my $wi = do_query("
           	    SELECT warranty_info
           	    FROM default_warranty_info
           	    WHERE supplier_id = $supplier_id_tmp
   	            AND catid = $catid_tmp
           	    AND $lang_clause
           	")->[0]->[0];
   	
           	# try to replace
   	        my $tmp_wi = $des_row->[2];
           	if (($tmp_wi =~ /^\s*$/) and ($wi)) {
   	            $tmp_wi = $wi;
   	        }
		
			push @$des_content, {
				"ShortDesc" => $des_row->[0],
				"LongDesc" => $des_row->[1],
				"WarrantyInfo" => $tmp_wi,
				"URL" => $des_row->[3],
				"PDFURL" => $des_row->[6],
				"PDFSize" => $des_row->[7],
				"ID" => $des_row->[4],
				"langid" => $des_row->[5],
				"ManualPDFURL" => $des_row->[8],
				"ManualPDFSize" => $des_row->[9]};
		}
		my $response = { 'ProductDescription' => [$des_content] };
		$response = &xml_out($response);
		$$response =~ s/<>//;
		$$response =~ s/<\/>//;
		$$response =~ s/^\s+$//gms;
				
		return $response;
	}

	# get xml parts for features set
	if ($part eq 'feats') { # new fast features xml parts
		# fill tmp table with product_feature_ids
		return [] if ($#$pf_id == -1);

		&do_statement("create temporary table itmp_product_feature (tmp_product_feature_id int(13) not null primary key)");
		&do_statement("insert into itmp_product_feature(tmp_product_feature_id) values(".join('),(',@$pf_id).')');

		my $local_suffix = $localized ne '1' ? '' : '_local';

		my $data = &do_query("select product_feature".$local_suffix."_id, cf.feature_id, pf.value, f.measure_id, mse.value, (cf.searchable * 10000000 + (1 - f.class) * 100000 + cf.no), cf.category_feature_group_id, cf.category_feature_id, cf.restricted_search_values, f.restricted_values, ms.value
from product_feature".$local_suffix." as pf
inner join category_feature as cf on pf.category_feature_id = cf.category_feature_id
inner join feature as f on cf.feature_id = f.feature_id
left join measure_sign as mse on f.measure_id = mse.measure_id and mse.langid=1
left join measure_sign as ms on f.measure_id = ms.measure_id and ms.langid=".$langid."
inner join itmp_product_feature tpf on tpf.tmp_product_feature_id = pf.product_feature".$local_suffix."_id");

		&do_statement("drop temporary table itmp_product_feature");
		
		my $response;

		foreach my $row(@$data) {
			if ($langid) {
				if (($row->[8] ne '') || ($row->[9] ne '')) {
					my $key_val = &str_sqlize($row->[2]);
					my $voc_val = &do_query("select value from feature_values_vocabulary where langid=".$langid." and key_value=".$key_val)->[0][0];
					if ($voc_val ne '') {
						$row->[2] = $voc_val;
					}
				}
			}
			chomp($row->[2]);

			$row->[10] = $row->[4] unless ($row->[10]);
			my $feat_names = [];
			my $feat_content;
			my $p_feature_id = 6617; #&do_query("select f.feature_id from feature f inner join vocabulary v using(sid) where v.value='source' and langid=1")->[0][0];
			$row->[2] = 'ICEcat.biz'  if($row->[1] == $p_feature_id && $row->[2] eq '.'); # checking if it's Copyright feature

			if ($row->[0] && ($row->[2] ne '')) { # for insurance 
				push @$feat_content, {
					"ID" => $row->[0],
					"No" => $row->[5],
					"CategoryFeature_ID" => int($row->[7]),
					"CategoryFeatureGroup_ID" => int($row->[6]),
					"Feature" => {
						"ID" => $row->[1],
						"NameXMLPart"=> $feat_names,
						"Measure" => { 'ID' => $row->[3], 'Sign' => $row->[4], 'SignsXMLPart' => [] },
					},
					"Value" => $row->[2],
					"Presentation_Value" => (($row->[2] =~ /[^0-9]$/)&&($row->[10]))?$row->[2]:$row->[2].(($row->[10])?" ":"").$row->[10], # another one DTD item
					"Localized" => $localized # new DTD item
					};
			}
			my $response_part = { 'ProductFeature' => [$feat_content] };
			$response_part = &xml_out($response_part);
			$$response_part =~ s/<>//;
			$$response_part =~ s/<\/>//;
			$$response_part =~ s/^\s+$//gms;
			push @$response, [ $row->[0], $$response_part ];
		} # foreach big
	
		return $response;
	}

	# get xml parts for multimedia objects 
	if ($part eq 'multimedia') {
		my $obj_data = &do_query("select id, link, short_descr, size, updated, langid, content_type, keep_as_url, type, height, width
from product_multimedia_object where product_id = $p_id and $lang_clause");
		$obj_data = &do_query("select id, link, short_descr, size, updated, langid, content_type, keep_as_url, type, height, width
from product_multimedia_object where product_id = $p_id and langid = 1") unless $obj_data->[0][0];
		my $obj_content = []; my $obj_local_content = [];
		foreach my $obj_row (@$obj_data) {
			last unless ($obj_row->[0]);
			push @$obj_local_content, { 'MultimediaObject_ID' => $obj_row->[0],
																	'URL' => $obj_row->[7] ? $atomcfg{'objects_host'} . 'objects/' . $p_id . '-' . $obj_row->[0] . '.html' : $obj_row->[1],
																	'Description' => $obj_row->[2],
																	'Size' => $obj_row->[3],
																	'Date' => $obj_row->[4],
																	'langid' => $obj_row->[5],
																	'ContentType' => $obj_row->[6],
																	'KeepAsURL' => $obj_row->[7],
																	'Type' => $obj_row->[8],
																	'Height' => $obj_row->[9],
																	'Width' => $obj_row->[10] }
		}
		if ($obj_data->[0][0]) {
			push @$obj_content, { 'MultimediaObject' => $obj_local_content };
		}
		my $response = { 'ProductMultimediaObject' => [$obj_content] };
		$response = &xml_out($response);
		$$response =~ s/<>//;
		$$response =~ s/<\/>//;
		$$response =~ s/^\s+$//gms;
		return $response;
	}
	


	# get xml parts for families 
	if ($part eq 'family') {
		my $fam_data = &do_query("select v.value, v.record_id, v.langid from
product_family as pf, vocabulary as v, product as p where 
p.product_id = $p_id and p.family_id = pf.family_id and 
v.sid = pf.sid and $lang_clause");
		my $fam_content = [];
		foreach my $fam_row (@$fam_data) {
			push @$fam_content, {
				'ID' => $fam_row->[1],
				'Value' => $fam_row->[0],
				'langid' => $fam_row->[2] };
		}
		my $response = { 'Name' => [$fam_content] };
		$response = &xml_out($response);
		$$response =~ s/<>//;
		$$response =~ s/<\/>//;
		$$response =~ s/^\s+$//gms;
		return $response;
	}

	# get xml parts for category
	if ($part eq 'cat') {
		my $cat_data = &do_query("select v.value, v.record_id, v.langid, v.sid
from category c
inner join vocabulary v on v.sid = c.sid and $lang_clause
inner join product p using (catid)
where p.product_id = $p_id");
		my $cat_content = [];
		foreach my $cat_row (@$cat_data) {
			if ((!$cat_row->[0]) && ($lang_clause ne '1')) {
				$row1 = &do_query("select record_id, value from vocabulary where sid=".$cat_row->[3]." and langid=".$l_langid)->[0];
				$cat_row->[0] = $row1->[1];
				$cat_row->[1] = $row1->[0];
				$cat_row->[2] = $l_langid;
			}			
			next unless $cat_row->[0];
			push @$cat_content, {
				'ID'      => $cat_row->[1],
				'Value' => $cat_row->[0],
				'langid'  => $cat_row->[2] };
		}
		
		# add info about virtual categories
		my $vc_content;
        my $vcats = do_query('SELECT name, virtual_category.virtual_category_id FROM virtual_category, virtual_category_product WHERE virtual_category_product.virtual_category_id = virtual_category.virtual_category_id AND product_id = ' . $p_id );
        if (scalar @$vcats > 0) {                
            my ($name, $id);
            foreach (@$vcats) {
                $name = $_->[0];
                $id = $_->[1];                
                push @$vc_content, { 'Name' => $name, 'ID' => $id };                                
            }            
		}
		
		my $response1 = { 'Name' => [$cat_content] };
		$response1 = &xml_out($response1);		
		$$response1 =~ s/<>//;
		$$response1 =~ s/<\/>//;
		
		my $response2 = { 'VirtualCategories' => { 'VirtualCategory' => [ $vc_content ] } };
		$response2 = &xml_out($response2);
		$$response2 =~ s/<>//;
		$$response2 =~ s/<\/>//;
		
		my $response;
		$$response = $$response1 . $$response2;
		
		$$response =~ s/^\s+$//gms;
		return $response;
	}
 
	# get xml parts feature group names 
	if ($part eq 'feat_grp') {
		my $feat_group_data = &do_query("select fg.feature_group_id, v.value, v.langid, v.record_id, v.sid
from feature_group fg
inner join vocabulary v on fg.sid=v.sid and $lang_clause
inner join category_feature_group cfg using (feature_group_id)
inner join product p using (catid)
where p.product_id = $p_id");
		my $feat_group = {};
		foreach my $row (@$feat_group_data) {
			$feat_group->{$row->[0]}->{'ID'} = $row->[0];
			unless ($row->[1]) {
				$row1 = &do_query("select record_id, value from vocabulary where sid=".$row->[4]." and langid=".$l_langid)->[0];
				$row->[1] = $row1->[1];
				$row->[3] = $row1->[0];
				$row->[2] = $l_langid;
			}
			push @{$feat_group->{$row->[0]}->{'Name'}}, {
        "ID" => $row->[3],
        "Value" => $row->[1],
        "langid" => $row->[2] }
		}
		my $cat_feat_group_data = &do_query("select category_feature_group_id, feature_group_id, no 
from category_feature_group as cfg, product as p where p.product_id = $p_id and p.catid = cfg.catid");
		my $group_content = [];
		foreach my $row (@$cat_feat_group_data) {
			push @$group_content, {
				"ID" => $row->[0],
				"No" => $row->[2],
				"FeatureGroup" => $feat_group->{$row->[1]}
			}
		}

		my $response = { 'CategoryFeatureGroup' => [$group_content] };
		$response = &xml_out($response);
		$$response =~ s/<>//;
		$$response =~ s/<\/>//;
		$$response =~ s/^\s+$//gms;
		return $response;
	}

	if ($part eq 'rel') {

		# if itmp_product_related exists - go to
		#if (&do_query("select count(*) + 1 from ")->[0][0]table_exists('itmp_product_related')) {
		if (table_exists('itmp_product_related')){
			goto itmp_product_related_exists;
		}

		# building related
		&do_statement("drop temporary table if exists itmp_product_related");
		&do_statement("create temporary table itmp_product_related (
product_related_id int(13)      NOT NULL default 0,
product_id         int(13)      NOT NULL default 0,
prod_id            varchar(60)  NOT NULL default '',
supplier_id        int(13)      NOT NULL default 0,
s_name             varchar(255) NOT NULL default '',
p_name             varchar(255) NOT NULL default '',
thumb_pic          varchar(255) default NULL,
catid              int(13)      NOT NULL default 0,
preferred_option   tinyint(1)   NOT NULL default 0,
`order`            smallint(5)  unsigned NOT NULL default 65535,
score              int(13)      NOT NULL default 0,

key (product_id),
key (preferred_option, `order`, score))");

		my $queueArray;

		push @$queueArray, "select pr.product_related_id, pr.rel_product_id, p.prod_id, p.supplier_id, s.name, p.name, p.thumb_pic, p.catid, pr.preferred_option, pr.`order`, pis.score
from product p
inner join supplier s on p.supplier_id = s.supplier_id
inner join product_related pr on pr.rel_product_id = p.product_id
inner join users u on p.user_id=u.user_id
inner join user_group_measure_map ugmm using (user_group)
inner join content_measure_index_map cmim on ugmm.measure=cmim.content_measure
left join  product_interest_score pis on pr.rel_product_id = pis.product_id
where pr.product_id = ".$p_id." and cmim.quality_index>0";

		push @$queueArray, "select pr2.product_related_id, p2.product_id, p2.prod_id, p2.supplier_id, s2.name, p2.name, p2.thumb_pic, p2.catid, pr2.preferred_option, pr2.`order`, pis.score
from product p2
inner join supplier s2 on p2.supplier_id = s2.supplier_id
inner join product_related pr2 on pr2.product_id = p2.product_id
inner join users u on p2.user_id = u.user_id
inner join user_group_measure_map ugmm using (user_group)
inner join content_measure_index_map cmim on ugmm.measure = cmim.content_measure
left join  product_interest_score pis on pr2.product_id = pis.product_id
where pr2.rel_product_id = ".$p_id." and cmim.quality_index>0";

		my $xs_count = &do_query("select count(*) from itmp_xpids")->[0][0];
	
		if ($xs_count) {
			&do_statement("drop temporary table if exists itmp_xs_product_related");
			&do_statement("create temporary table itmp_xs_product_related (
	product_related_id int(13)      NOT NULL default 0,
	product_id         int(13)      NOT NULL default 0,
	prod_id            varchar(60)  NOT NULL default '',
	supplier_id        int(13)      NOT NULL default 0,
	s_name             varchar(255) NOT NULL default '',
	p_name             varchar(255) NOT NULL default '',
	thumb_pic          varchar(255) default NULL,
	catid              int(13)      NOT NULL default 0,
	preferred_option   tinyint(1)   NOT NULL default 0,
  score              int(13)      NOT NULL default 0,

	key (product_id))");

			&do_statement("alter table itmp_xs_product_related disable keys");
			my @arr = &get_primary_key_set_of_ranges('p','product_memory',300000,'product_id');
			@arr = ('1') if $xs_count < 10000;
			foreach my $b_cond (@arr) {
				&do_statement("insert into itmp_xs_product_related(product_related_id,product_id,prod_id,supplier_id,s_name,p_name,thumb_pic,catid,preferred_option,score)
select '0', p.product_id, p.prod_id, p.supplier_id, s.name, p.name, p.thumb_pic, p.catid, '0', pis.score
                        from product_memory p
                        inner join supplier_memory s on p.supplier_id = s.supplier_id
                        inner join itmp_xpids tx on tx.product_id = p.product_id
                        inner join users_memory u on p.user_id = u.user_id
                        inner join user_group_measure_map ugmm using (user_group)
                        inner join content_measure_index_map cmim on ugmm.measure = cmim.content_measure
                        left join  product_interest_score pis on p.product_id = pis.product_id
                        where cmim.quality_index > 0 AND " . $b_cond);
			}
			&do_statement("alter table itmp_xs_product_related enable keys");

			push @$queueArray, "select xpr.product_related_id, xpr.product_id, xpr.prod_id, xpr.supplier_id, xpr.s_name, xpr.p_name, xpr.thumb_pic, xpr.catid, xpr.preferred_option, '65535', xpr.score from itmp_xs_product_related xpr";
		}

		&do_statement("alter table itmp_product_related disable keys");
		foreach (@$queueArray) {
			&do_statement("insert IGNORE into itmp_product_related(product_related_id,product_id,prod_id,supplier_id,s_name,p_name,thumb_pic,catid,preferred_option,`order`,score) ".$_);
		}
		&do_statement("alter table itmp_product_related enable keys");
		&do_statement("alter IGNORE table itmp_product_related add unique key (product_id)");

		#
		# Vitaly Kashin requirements:
		#
		# 1024495: implement ordering at the stage of products publishing
		# 1025056: implement ordering at the stage of products publishing. Alternative product have the biggest priority 
		#
		# to change order as: ORDER BY alternative desc,
		#                              [category_id IN(839,788) DESC for HP ,]
		#                              Preferred DESC,
		#                              Order ASC,
		#                              Score DESC
		#

	itmp_product_related_exists:

		my $t_supplier_id = &get_supplier_id4product($p_id);
		my $t_catid = &get_catid4product($p_id);
		my $hp_supplier_id = &get_supplier_id_by_name('HP');
		my ($extra_f, $extra_oc);
		if ( $t_supplier_id == $hp_supplier_id ) {
			$extra_f = ' , if((catid in (839,788)) and (supplier_id = '.$hp_supplier_id.'), 1, 0) as warranty_extensions ';
			$extra_oc = ' warranty_extensions desc, ';
		}
		else {
			$extra_f = '';
			$extra_oc = '';
		}
		
		my $rel_data = &do_query("select product_related_id, pr.product_id, prod_id, supplier_id, s_name, if(pn.name != '', pn.name, p_name), thumb_pic, catid, preferred_option,
`order` 
".$extra_f.",
if(catid = ".$t_catid.", 1, 0) as alternative
from itmp_product_related pr
left  join product_name pn on pr.product_id = pn.product_id and pn.langid = " . $langid . "
order by alternative desc, ".$extra_oc." preferred_option desc, `order` asc, score desc
" . ((($atomcfg{'x_sells_limit'} > 0) && ($atomcfg{'x_sells_limit'} =~ /^\d+$/)) ? 'limit ' . $atomcfg{'x_sells_limit'} : '') );
		
#		&do_statement("drop temporary table if exists itmp_product_related");
		
		my $response;
		$$response = '';

		foreach my $rel_row (@$rel_data) {
			$$response .= "\t  <ProductRelated ID=\"".$rel_row->[0]."\" Category_ID=\"".$rel_row->[7]."\" Reversed=\"0\" Preferred=\"".$rel_row->[8]."\"".($rel_row->[9] < 65535 ? " Order=\"".$rel_row->[9]."\"" : "" ).">\n".
				"\t    <Product ID=\"".$rel_row->[1]."\" Prod_id=\"".&str_xmlize($rel_row->[2])."\" ThumbPic=\"".$rel_row->[6]."\" Name=\"".&str_xmlize($rel_row->[5])."\">\n".
				"\t      <Supplier ID=\"".$rel_row->[3]."\" Name=\"".&str_xmlize($rel_row->[4])."\"/>\n".
				"\t    </Product>\n".
				"\t  </ProductRelated>\n";
		}
		
		return $response;
	}

	if ($part eq 'summary_description') {
		# form new dummary descriprions from database tables
		my $descs = &get_summary_descriptions($p_id, $langid);

		# refresh summary descriptions in database
		if (&do_query("select product_summary_description_id from product_summary_description where product_id=".$p_id." and langid=".$langid)->[0][0]) {
			&do_statement("update product_summary_description set short_summary_description = ".&str_sqlize($descs->{'short'}).", long_summary_description = ".&str_sqlize($descs->{'long'})." where product_id=".$p_id." and langid=".$langid);
		}
		else {
			&do_statement("insert IGNORE into product_summary_description(product_id,langid,short_summary_description,long_summary_description) values(".$p_id.",".$langid.",".&str_sqlize($descs->{'short'}).",".&str_sqlize($descs->{'long'}).")");
		}

		# form new XML structure for product XML
		my $response;
		$$response = "\n\t  <SummaryDescription>\n".
"\t    <ShortSummaryDescription ".(($langid != 0)?'langid="'.$langid.'"':'').">".&str_xmlize($descs->{'short'})."</ShortSummaryDescription>\n".
"\t    <LongSummaryDescription ".(($langid != 0)?'langid="'.$langid.'"':'').">".&str_xmlize($descs->{'long'})."</LongSummaryDescription>\n".
"\t  </SummaryDescription>\n";
		
		return $response;
	}
	

}

sub getDistri_xml_tags {
	my $distri_set = shift;

	my @distris = split /\t/, $distri_set;
	return '' if $#distris == -1;

	my $xml = "\n\t\t\t<Distributors>\n";
	foreach (@distris) {
		my @attrs = split /;/, $_;
		if ($#attrs != -1) {
			$xml .= "\n\t\t\t\t".'<Distributor ID="'.$attrs[0].'" Name="'.&str_xmlize($attrs[1]).'" Country="'.$attrs[2].'" ProdlevId="'.$attrs[3].'"/>'."\n";
		}
	}
	$xml .= "\n\t\t\t</Distributors>\n";

	return $xml;
}

sub create_specific_index_files_from_index_cache {
	my ($langid, $daily_products, $supplier_id, $progress) = @_;
	
	my ($collect, $handles, $handle, $file);

	$handles = {
		'DAILY_XML_EXT' => "daily.index.ext.$langid.xml",
		'DAILY_CSV_EXT' => "daily.index.ext.$langid.csv",
	};

	foreach my $h (keys %$handles) {
		$handle = new IO::File;
		$file = "/tmp/".$$."_".$handles->{$h};
		open($handle, "> ".$file);
		$handle->binmode(":utf8");

		$collect->{$h}->{'handle'} = $handle;
		$collect->{$h}->{'draftfilename'} = $file;
		$collect->{$h}->{'filename'} = $handles->{$h};
	}

	# main cycle
	my $now = time;
	my $now_date = strftime("%Y-%m-%d", localtime($now));
	my $now_stamp = &do_query("select unix_timestamp(".&str_sqlize($now_date).")")->[0][0];
	my $yesterday_date = strftime("%Y-%m-%d", localtime($now_stamp - 1));
	my $yesterday_stamp = &do_query("select unix_timestamp(".&str_sqlize($yesterday_date).")")->[0][0];

#	my $today = &format_date(time);
#	$today =~ s/.{6}$/000000/;
	
#	my $yesterday = &format_date(time-24*60*60);
#	$yesterday =~ s/.{6}$/000000/;

	if ($langid == 0) { # INT repository - use 1st 6 languages
		$langid = '1,2,3,4,5,6';
	}

	# query
	my $query = "
	    SELECT ap.product_id, MAX(UNIX_TIMESTAMP(ap.updated)), c.xml_info, c.csv_info
	    FROM actual_product ap
	    INNER JOIN product_index_cache c ON ap.product_id = c.product_id
" . ( $supplier_id ? "INNER JOIN product_memory pm ON ap.product_id = pm.product_id and pm.supplier_id = " . $supplier_id : '' ) . "
	    WHERE ap.langid in (" . $langid . ") and ap.updated between from_unixtime(".$yesterday_stamp.") and from_unixtime(".$now_stamp.")
      GROUP BY ap.product_id
	";

	my $sth;
	&log_printf("SQL QUERY DIRECTLY: " . $query . ";");
	$sth = $atomsql::dbh->prepare($query);
	$sth->execute();
	my $all = $sth->rows();

	my $i = 0;
	my ($p, $daily, $date, $c);
	$c = 0;
	while ($p = $sth->fetchrow_arrayref) {
		# counter
		$i++;
				
		if (! $daily_products->{$p->[0]} ) {
			$handle = $collect->{'DAILY_XML_EXT'}->{'handle'};
			print $handle $p->[2];
			$handle = $collect->{'DAILY_CSV_EXT'}->{'handle'};
			print $handle $p->[3];
			
			$c++;
		}
	} # while
	
  foreach my $h (keys %$handles) {
    $handle = $collect->{$h}->{'handle'};
    close $handle;
  }
  
  my $size = scalar keys %$daily_products;
  print "(specific: $all, general: $size, added: $c) " if $progress;

  return $collect;
} # sub create_specific_index_files_from_index_cache

sub store_specific_index {
	my $hash_ref = shift;
	
	my $path = $hash_ref->{'path'};
	my $langid = $hash_ref->{'langid'};
	my $supplier_id = $hash_ref->{'supplier_id'};
	my $subscription_level = $hash_ref->{'subscription_level'};
	
	my $original_name = $path . "/daily.index.xml";
	my $specific_name = "/tmp/" . $$ ."_daily.index.ext." . $langid . ".xml";

	my $original_name_csv = $path."/daily.index.csv";
	my $specific_name_csv = "/tmp/" . $$ ."_daily.index.ext." . $langid . ".csv";

	my $cmd;
	
	my $today = &format_date(time);
	$today =~ s/.{6}$/000000/;
	if (-e $original_name) {
		my $mtime;
		(undef,undef,undef,undef,undef,undef,undef,undef,undef,$mtime) = stat($original_name);
		$mtime = &format_date($mtime);
		if ($mtime >= $today) {
			goto skip_daily_completeness;
		}
	}

	if (! -e $original_name) { 
		print "\nDaily index not found\n";
		return;
	}
	
	if (! -e $specific_name) { 
		print "\nSpecific lang index not found\n";
		return;
	}
	
	#
	# daily xml
	#
	
	# restrict for XML
	print "filter XML";
	$cmd = 
		$atomcfg{'base_dir'} . "/bin/filter_supplier_products " .
		$specific_name . " " .          # 1
		$langid . " " .                 # 2
		$supplier_id . " " .            # 3
		$subscription_level;            # 4
	`$cmd`;
	print ",";
	
	my $S_FILE;
	my $O_FILE;

	my $original_content;
	my $specific_content;
	
	open $S_FILE, "<", $specific_name;
	open $O_FILE, "<", $original_name;

	binmode $S_FILE, ":utf8";
	binmode $O_FILE, ":utf8";

	while (<$S_FILE>) { $specific_content .= $_; }	
	while (<$O_FILE>) { $original_content .= $_; }
	
	my $relpath = $path;
	$relpath =~ s/$atomcfg{'xml_path'}/export\//s;
	$specific_content =~ s/%%target_path%%/$relpath/g;
	$original_content =~ s/<\/files\.index>/\n\n${specific_content}<\/files\.index>/;
    
	close $O_FILE;
	close $S_FILE;

	open $O_FILE, ">", $original_name;
	flock $O_FILE, 2;
	binmode $O_FILE, ":utf8";
	print $O_FILE $original_content;
	close $O_FILE;
	
	#
	# daily csv
	#
		
	# restrict for CSV
	print "filter CSV";
	$cmd = 
		$atomcfg{'base_dir'} . "/bin/filter_supplier_products " .
		$specific_name_csv . " " . # 1
		$langid . " " .            # 2
		$supplier_id . " " .       # 3
		$subscription_level;       # 4

	`$cmd`;
	print ",";
	
	open $S_FILE, "<", $specific_name_csv;
	open $O_FILE, ">>", $original_name_csv;
	flock $O_FILE, 2;
	
	binmode $S_FILE, ":utf8";
	binmode $O_FILE, ":utf8";

	# remove ph - need to rework!
	$specific_content = '';
	while (<$S_FILE>) {
		$specific_content .= $_;
	}
	$specific_content =~ s/%%target_path%%/$relpath/g;
	
	print $O_FILE $specific_content;
	
	close $S_FILE;
	close $O_FILE;

 skip_daily_completeness:
	
	#
	# cleanup
	#
	
	qx(/bin/rm -f $specific_name);
	qx(/bin/rm -f $specific_name_csv);
	
	return;
}

1;

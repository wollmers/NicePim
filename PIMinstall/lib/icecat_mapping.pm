package icecat_mapping;

#$Id: icecat_mapping.pm 3716 2011-01-14 11:05:43Z dima $

use strict;

use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_misc;
use data_management;

use Data::Dumper;

use vars qw($power_mapping_measure_id
						
						$G_go_hash

						$G_table_name

						$G_feature_id_present
						$G_pfv_history_present
						$G_pfv_mapped_present
						$G_pfv_pattern_present
						$G_new_value_present
						$G_langid_present

						$G_history_hash);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
							 $G_go_hash
							 $G_table_name

							 &icecat2mysql_mapping
							 &icecat2mysql_regexp
							 &icecat2perl_pattern

							 &power_mapping_per_feature_and_measure
							 &power_mapping_per_feature_and_measure_for_BO
							 &power_mapping_per_measure_for_BO
							 &power_mapping_per_category_feature_id_hash

							 &my_chomp
							 &get_generic_operations_hash
							 &get_pattern_parts

							 &generic_operation_void
							 &generic_operation_as_is
							 &generic_operation_kg2g
							 &generic_operation_remove_spaces
							 &generic_operation_remove_double_units
							 &generic_operation_remove_string
							 &generic_operation_replace_string

							 &prod_id_mapping

							 &brand_prod_id_checking_by_regexp

							 &system_of_measurement_transform
							);
}

sub system_of_measurement_transform {
	my ($value, $feature_id, $measure_id, $langid) = @_;

	my ($m_value, $i_value, $m_unit, $i_unit, $probability, $related_measure_id, $type, $pattern, $collapsed, $pattern_value, $pattern_number, $pattern_value_number, $suddenly_reverse);

	$probability = 100;
	$suddenly_reverse = 0;

	if ($value eq '-') { # undefined value
		$m_value = $value;
		$i_value = $value;
	}
	elsif (value_custom_restrictions_based_on_the_summary_report($value)) {
		$probability = 25;
		$m_value = '';
		$i_value = '';
		log_printf("value_custom_restrictions_based_on_the_summary_report restriction: ".$value);
	}
	elsif ($feature_id) {
		# fix the langid
		$langid = 1 unless $langid;
	
		# get the measure_id
		unless ($measure_id) {
			$measure_id = do_query("select measure_id from feature where feature_id=".$feature_id)->[0][0];
		}
		
		# set multiplexer for g -> kg
		if (($measure_id == 38) && ($value =~ /\bkg\b/i)) {
			$measure_id = 17;
		}

		# set multiplexer for mm -> cm
		if (($measure_id == 24) && ($value =~ /\bcm\b/i)) {
			$measure_id = 34;
		}

		# set multiplexer for " -> mm
		if (($measure_id == 16) && ($value =~ /\bmm\b/i)) {
			$measure_id = 24;
		}

		# set multiplexer for lbs -> oz
		if (($measure_id == 127) && ($value =~ /\boz\b/i)) {
			$measure_id = 147;
		}

		# determine the ability to make the transformation
		my $rel = do_query("select mr.related_measure_id, mr.factor, mr.term, m.system_of_measurement from measure_related mr inner join measure m using (measure_id) where mr.measure_id=".$measure_id." limit 1")->[0];
		$related_measure_id = $rel->[0];

#		print "rel = ".Dumper($rel);

		if ($related_measure_id) {
			# #,# -> #.#
			$value =~ s/(\d+),(\d+)/$1.$2/gs if ($value !~ /\d,\d+,\d/);

			# so, we have the value and factor + term. let's get the feature input type
			my $fit = do_query("select fit.type, fit.pattern, f.feature_id from feature_input_type fit inner join feature f using (type) where f.feature_id=".$feature_id)->[0];
			$type = $fit->[0];
			$pattern = $fit->[1];
			
#			print "fit = ".Dumper($fit);

			# determine the $pattern number of #-es
			$pattern_number = $pattern;
			$pattern_number =~ s/[^#]//gs;
			$pattern_number = length($pattern_number);

			## numbers - to #
			my $digit_perl = icecat2perl_pattern('#',undef,'do not use fractions');

			# set the custom pattern, if pattern is absent
			if (!$pattern_number) {
				# at first, make all numbers in brackets (, ) - as untouchable
				($pattern, $collapsed) = collapse_brackets($value);

#				print "---> test 50: ".$pattern." ".Dumper($collapsed);

				$probability = 50;
#				$pattern = $value;
				
				$pattern =~ s/$digit_perl/\#/gs;

				$pattern = expand_brackets($pattern, $collapsed);

#				print "---> test 50: ".$pattern."\n";
			}
			else { # check the number of digits in value
				($pattern_value, $collapsed) = collapse_brackets($value);

#				$pattern_value = $value;
				$pattern_value =~ s/$digit_perl/\#/gs;
				
				$pattern_value_number = $pattern_value;
				$pattern_value_number =~ s/[^#]//gs;
				$pattern_value_number = length($pattern_value_number);

				if ($pattern_number != $pattern_value_number) { # strange value, when pattern is present
					$probability = 75;
					$pattern = expand_brackets($pattern_value, $collapsed);
				}
				else {
					# pattern is already here

					$probability = 100;
				}
			}
			
#			print "ha-ha: ".Dumper($pattern);

			# CUSTOM PREFIX THE PATTERN
			if ($type eq 'ratio') {
				if ($probability == 100) {
					$pattern =~ s/\#/1/s;

					$rel->[1] = 1 / $rel->[1]; # because, we have a deal with the perfect ratio
					$rel->[2] = 0; # it is 0 by default ever, so - no changes
				}
				else {
					goto to_end;
				}
			}
			
			# patterns forming
			my $new_value = $pattern;
			$new_value =~ s/\#/\x01/gs;
			my $pattern_perl = icecat2perl_pattern($pattern,undef,'do not use fractions');
			
			# additionally, make the spaces as optional
			$pattern_perl =~ s/\\ /\\s\?/gs;
			
#			print "---> test: ".$type." ~ ".$pattern_perl." ~ ".$value."\n";
			
			$value =~ /^$pattern_perl\s*(.*)$/s;

			# add the ending, for any purpose
			$new_value .= " \x01";
			
			my @in = ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
			
			if (defined $in[0]) {
				# get the source & target units
				my $unit1 = do_query("select value from measure_sign where measure_id=".$measure_id." and langid = ".$langid)->[0][0]
					|| do_query("select value from measure_sign where measure_id=".$measure_id." and langid = 1")->[0][0];
				my $qunit1 = quotemeta($unit1);
				my $unit2 = do_query("select value from measure_sign where measure_id=".$related_measure_id." and langid = ".$langid)->[0][0]
					|| do_query("select value from measure_sign where measure_id=".$related_measure_id." and langid = 1")->[0][0];
				# custom - special for lb, lbs, lbm case
				my $qunit2 = $unit2 eq 'lbs' ? 'lb[sm]?' : quotemeta($unit2);
#				log_printf($unit1." ".$qunit1." ".$unit2." ".$qunit2);

				# determine the both-values
				goto to_end if (($value =~ /$qunit1/i) && ($value =~ /$qunit2/i) || ($value =~ /\([^\(]*$qunit2[^\)]*\)/i));

				# determine the suddenly reverse
				if ($unit2) {
#					print "--->test: ".$value."\t".$qunit2."\n";
					$suddenly_reverse = 1 if ($value =~ /$qunit2/i);
				}

				my $cunit = $suddenly_reverse ? $unit2 : $unit1;

				for my $victim (@in) { # 10 values max
					last unless defined $victim;
#					print Dumper($victim);
#					print Dumper($new_value);

					$new_value =~ s/\x01/factor_term($victim,$rel->[1],$rel->[2],$suddenly_reverse)/se;
#					print Dumper($new_value);
				}
				
				# remove other #-es
				$new_value =~ s/\x01//gs;

				if ($suddenly_reverse) {
					## old unit -> new unit
					$new_value =~ s/(\s|\b)$qunit2(\s|$)/$1$unit1$2/gsi;
					
					# CUSTOM: " -> INCH
					if ($unit2 eq "\"") {
						$new_value =~ s/\binch\b/$unit1/gsi;
					}
					elsif (lc($unit2) eq 'lbs') {
						$new_value =~ s/\blbm\b/$unit1/gsi;
						$new_value =~ s/\blb\b/$unit1/gsi;
					}
				}
				else {
					## old unit -> new unit
					$new_value =~ s/(\s|\b)$qunit1(\s|$)/$1$unit2$2/gsi;
#					$new_value =~ s/\b$qunit1\b/$unit2/gsi;
#					log_printf("nw: ".$qunit1." ".$unit2." ".$new_value);
					
					# CUSTOM: " -> INCH
					if ($unit1 eq "\"") {
						$new_value =~ s/\binch\b/$unit2/gsi;
					}
					elsif (lc($unit1) eq 'lbs') {
						$new_value =~ s/\blb\b/$unit2/gsi;
					}
				}

				# remove ending spaces
				$new_value =~ s/\s+$//s;

				# swap $rel->[3] if $suddenly_reverse
				if ($suddenly_reverse) {
					$rel->[3] = $rel->[3] eq 'metric' ? 'imperial' : 'metric';
				}

				# choose the m and i
				if ($rel->[3] eq 'metric') {
					$m_value = $value;
					$i_value = $new_value;
					$m_unit = $unit1;
					$i_unit = $unit2;
				}
				else {
					$m_value = $new_value;
					$i_value = $value;
					$m_unit = $unit2;
					$i_unit = $unit1;
				}
			}
			else {
				$m_value = '';
				$i_value = '';
			}
		}
		else {
			$m_value = '';
			$i_value = '';
		}
	}
	else {
		$m_value = '';
		$i_value = '';
	}

 to_end:
	
	return {
		'probability' => $probability,
		'metric' => $m_value,
		'imperial' => $i_value,
		'metric_unit' => $m_unit,
		'imperial_unit' => $i_unit,
		'related_measure_id' => $related_measure_id
	};
} # sub system_of_measurement_transform

sub factor_term {
	my ($digit, $factor, $term, $reverse) = @_;

	return undef unless ($digit);
	return undef if ($digit eq '.');
#	print "---> test: ".Dumper(\@_);
	return $digit if ($digit =~ /[a-zA-Z]/);

	my $out;
	if ($reverse) {
		$out = ($digit - $term) / $factor;
	}
	else {
		$out = $factor * $digit + $term;
	}

	my $exponent = get_exponent($out);
	my $after_dot = 1;

	if ($exponent > 1) {
		$after_dot = 1;
	}
	elsif ($exponent == 1) {
		$after_dot = 2;
	}
	elsif ($exponent == 0) {
		$after_dot = 0;
	}
	else {
		$after_dot = 2 - $exponent;
	}

	my $result = sprintf("%.".$after_dot."f", $out);
#	$result =~ s/\.?0\d$//s;
	$result =~ s/\.?0+$//s;
#	print $result;

	return $result;
} # sub factor_term

sub collapse_brackets {
	my ($value) = @_;

	my $victim = $value;
	my $collect = [];

#	print "---> test collapse: ".$victim."\n";

	while ($victim =~ /^.*?\((.*?)\)/) {
		push @$collect, $1;
		$victim =~ s/^.*?\(.*?\)//;
#		print "---> test collapse: ".$victim."\n";
	}

	$value =~ s/\((.*?)\)/\(\x02\)/gs;

#	print "---> test collapse: ".$value."\n"."\n";

	return ($value, $collect);
} # sub collapse_brackets

sub expand_brackets {
	my ($value, $collect) = @_;

	for (@$collect) {
		$value =~ s/\x02/$_/s;
	}

	return $value;
} # sub expand_brackets

sub value_custom_restrictions_based_on_the_summary_report {
	my ($value) = @_;
	
	# 3.36 - 3.45 + 14.1" display or 3.54 - 3.62 + 15" display
	return 1 if $value =~ /\+\s\d+(\.\d+)?\"\sdisplay/;

	# 14.1": 3.06; 15.0": 3.29 (may vary, depending configuration and components)
	return 1 if $value =~ /(\s|^)\d+(\.\d+)?\"(\:|\sscherm)/;

	# Tray 1: A4 65 - 90/m², envelopes 70 - 90/m², cards < 200/m², photo paper < 280/m²; Tray 2: 10 x 15 cm photo paper < 280/m² 5400
	return 1 if $value =~ /Tray\s\d+(\:|\,)/;

	# US letter: 16 to 24 lb; A4: 16 to 24 lb; legal: 20 to 24 lb; banner: 16 to 24 lb; envelopes: 20 to 24 lb; cards: up to 110 lb index maximum; photo paper: up to 130 lb index
	# Alle A4-formaat notebooks (zowel met 14 als 15 schermen), B5-formaat notebooks
	# A4: 75 - 90/m², banner paper: 75 - 90/m², envelopes: 75 - 90/m², cards: < 200/m², photo paper: < 280/m² 7000
	return 1 if $value =~ /(\s|^)[AB]\d(\:|\-)/;

	# 40-inch 810 mm 1593 to 1845 mm /60-inch 1220 mm 2413 to 2789 mm /80-inch 1630 mm 3232 to 3733 mm /100-inch 2030 mm 4051 to 4677 mm /120-inch 2440 mm 4870 to 5621 mm /150-inch 3050 mm 6099 to 7037 mm .
	return 1 if $value =~ /\d+\-inch\s\d+\smm/;

	# 4x Hot-Swap SCSI
	return 1 if $value =~ /^[^\d]*\d+\s?x[^\d]*$/;

	# <br>2.4 (2.34) + weight saver<br>2.6 (2.565) + optical drive<br>4.8 (4.77) packed
	return 1 if $value =~ /\d+\.\d+\s\(\d+\.\d+\)\s+\+\sweight\ssaver/;

	# 68 lb Tower: 1 Processor, 1 hard drive cage, 1 Memory Board, 1 Power Supply, 1 Controller card, 3 fans 77 lbs Tower: 1 Processor, 1HDD, 1 Memory Board, 2 Power Supplies, 2 Controller cards, 6 fans
	return 1 if $value =~ /Tower\:\s\d+\sProcessor/;

	# 60 to 120 g/m2
	return 1 if $value =~ /\sg\/m2/;

	# 250-sheet tray: 16 to 43 lb; 10-sheet input tray: 16 to 43
	return 1 if $value =~ /(\s|^)\d+\-sheet/;
	
	return undef;
} # sub value_custom_restrictions_based_on_the_summary_report

sub brand_prod_id_checking_by_regexp {
	my ($prod_id, $h) = @_; # h->regexp, h->supplier_id
	
	if (
		(($h->{'supplier_id'}) && (int($h->{'supplier_id'}) eq $h->{'supplier_id'})) ||
		($h->{'regexp'}) ||
		(($h->{'product_id'}) && (int($h->{'product_id'}) eq $h->{'product_id'}))
		) { # we have the supplier_id, checking
		my $rs = $h->{'regexp'} || ( $h->{'supplier_id'} ? do_query("select prod_id_regexp from supplier where supplier_id=".$h->{'supplier_id'})->[0][0] :
																 ( $h->{'product_id'} ? do_query("select s.prod_id_regexp from supplier s inner join product p using (supplier_id) where p.product_id=".$h->{'product_id'})->[0][0] :
																	 undef) );
		return 1 unless $rs;
		$rs =~ s/^\s*(.*?)\s*$/$1/s;
		return 1 unless $rs;
		my @ars = split /\n/, $rs;
		for (@ars) {
			s/^\s*(.*?)\s*$/$1/s;
			next unless $_;
			return 1 if $prod_id =~ /$_/;
		}
	}

	return undef;
} # sub brand_prod_id_checking_by_regexp

 ######
# main #
 ######

# mysql> show create table dv;
#+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#| Table | Create Table                                                                                                                                                                                                                             |
#+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#| dv    | CREATE TABLE `dv` (
#  `text` varchar(255) NOT NULL default '',
#  `method` enum('like','likerev') default 'like',
#  KEY `method` (`method`),
#  KEY `text_2` (`text`),
#  KEY `text` (`text`,`method`)
#) ENGINE=MyISAM DEFAULT CHARSET=utf8 |
#+-------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#1 row in set (0.00 sec)

#	mysql> show create table dv2;
#+-------+----------------------------------------------------------------------------------------------------------------------------+
#| Table | Create Table                                                                                                               |
#+-------+----------------------------------------------------------------------------------------------------------------------------+
#| dv2   | CREATE TABLE `dv2` (
#  `text` varchar(255) NOT NULL default '',
#  KEY `text` (`text`)
#) ENGINE=MyISAM DEFAULT CHARSET=utf8 |
#+-------+----------------------------------------------------------------------------------------------------------------------------+
#1 row in set (0.00 sec)

#	mysql> explain select * from dv t1 inner join dv2 t2 on (method='like' and t2.text like t1.text) or (method='likerev' and reverse(t2.text) like reverse(t1.text));
#+----+-------------+-------+-------+---------------+------+---------+------+------+--------------------------+
#| id | select_type | table | type  | possible_keys | key  | key_len | ref  | rows | Extra                    |
#+----+-------------+-------+-------+---------------+------+---------+------+------+--------------------------+
#	|  1 | SIMPLE      | t1    | index | method        | text | 769     | NULL |    3 | Using where; Using index |
#	|  1 | SIMPLE      | t2    | index | NULL          | text | 767     | NULL |   24 | Using where; Using index |
#+----+-------------+-------+-------+---------------+------+---------+------+------+--------------------------+
#2 rows in set (0.00 sec)
#

sub prod_id_mapping { # a new, powerful, wrote by Dima (04.09.2009)
	my ($h) = @_; # this is the hash... probably, it will be used as parameters: which table, which conditions, etc...

	return undef unless $h->{'table'};

	# get current timestamp
	my $tstamp = do_query("select unix_timestamp()")->[0][0];

	# decide to use single specified mapping or use all mappings from product_map
	my $ins;
	if ($h->{'pattern'}) {
		push @$ins, [ 1, $h->{'pattern'}, $h->{'supplier_id'}, $h->{'dest_supplier_id'} ];
	}
	else {
		$ins = do_query("select product_map_id,trim(trim(both '\n' from trim(pattern))),supplier_id,map_supplier_id from product_map order by supplier_id asc");
	}

	print "patterns loaded, " if ($h->{'visual'});

	my $t = "\x01";
	my $n = "\x02";
	my ($i, $order, $d, $mode2, $max_order, @pattern);
	my ($ts, $ts_id); # the very-very major variables

	## load everything to CSV files
	$i = 0;

	for my $in (@$ins) {
		@pattern = split /\n/, $in->[1];
		$order = 0;
		for (@pattern) {
			s/\r//gs;
			next unless check_product_map_pattern($_);
			$order++;
			$i++;
			$max_order = $max_order < $order ? $order : $max_order;
			my ($mode, $p, $pnot) = get_product_map_pattern_parts($_);

			$ts->{$in->[0]}->{$order} = {
				'mode' => $mode,
				'product_map_id' => $in->[0] || 0,
				'id' => $i, # unique identifier of each part of pattern
				'pattern' => $_,
				'supplier_id' => $in->[2] || 0,
				'map_supplier_id' => $in->[3] || 0,
				'order' => $order,
				'pattern_mysql' => $p,
				'pattern_mysqlnot' => $pnot
			};

			$ts_id->{$i} = $ts->{$in->[0]}->{$order}; # the another view on the same hash ;)
		}
	}

	print "hashes completed, " if ($h->{'visual'});

	do_statement("ALTER TABLE " . $h->{'table'} . " DISABLE KEYS");

	my $exist_columns = do_query("DESC ".$h->{'table'});
	my $hcols = {};
	my $q = "ALTER TABLE " . $h->{'table'} . " ";
	my $visual_columns = '';

	for (@$exist_columns) {
		$hcols->{$_->[0]} = $_->[3];
	}

	unless (defined $hcols->{'map_prod_id'}) {
		$q .= "ADD COLUMN map_prod_id    varchar(60) NOT NULL DEFAULT '',"; $visual_columns .= 'map_prod_id, ';
	}
	unless (defined $hcols->{'map_prod_idrev'}) {
		$q .= "ADD COLUMN map_prod_idrev varchar(60) NOT NULL DEFAULT '',"; $visual_columns .= 'map_prod_idrev, ';
	}
	unless (defined $hcols->{'map_supplier_id'}) {
		$q .= "ADD COLUMN map_supplier_id int(13) NOT NULL DEFAULT 0,"; $visual_columns .= 'map_supplier_id, ';
	}
	unless (defined $hcols->{'pattern_id'}) {
		$q .= "ADD COLUMN pattern_id int(13) NOT NULL DEFAULT 0,"; $visual_columns .= 'pattern_id, ';
	}
	if (($hcols->{'map_prod_id'} ne 'MUL') || ($hcols->{'map_supplier_id'} ne 'MUL')) {
		$q .= "ADD KEY map_p_s (map_prod_id, pattern_id, map_supplier_id, supplier_id),"; $visual_columns .= 'K map_p_s, ';
	}
	if (($hcols->{'prod_id'} ne 'MUL') || ($hcols->{'supplier_id'} ne 'MUL')) {
		$q .= "ADD KEY p_s (prod_id, supplier_id),"; $visual_columns .= 'K p_s, ';
	}
	if (($hcols->{'map_prod_idrev'} ne 'MUL') || ($hcols->{'map_supplier_id'} ne 'MUL')) {
		$q .= "ADD KEY map_prev_s (map_prod_idrev, pattern_id, map_supplier_id, supplier_id),"; $visual_columns .= 'K map_prev_s, ';
	}

	if ($q =~ /,$/) {
		chop($q); chop($visual_columns); chop($visual_columns);
		do_statement($q);
		print "`" . $h->{'table'} . "` new columns/keys added (".$visual_columns."), " if ($h->{'visual'});
	}

	## copy prod_id -> map_prod_id, supplier_id -> map_supplier_id
	do_statement("UPDATE " . $h->{'table'} . " SET map_prod_id = prod_id, map_prod_idrev = REVERSE(prod_id), map_supplier_id = supplier_id");
	do_statement("ALTER TABLE " . $h->{'table'} . " ENABLE KEYS");

	print "`" . $h->{'table'} . "` keys enabled, " if ($h->{'visual'});

	## 1. rotation using product_map_id + order
	my ($table_suffix, $action, $not_action, $mapped, $map_prod_id, $map_supplier);
	my ($ts2, $ts3, $q_where);

	for (1..3) { # 3 times
		print "cycle " . $_ . " started, " if ($h->{'visual'});

		$mapped = 0;

		for my $map_id (sort {$a <=> $b} keys %$ts) {
			$ts2 = $ts->{$map_id};

			for my $order (sort {$a <=> $b} keys %$ts2) {
				$ts3 = $ts2->{$order};
				$table_suffix = ($ts3->{'mode'} =~ /rev/) ? 'rev' : '';

				if ($ts3->{'mode'} =~ /like/) {
					$action = 'like';
					$not_action = 'not like';
				}
				else {
					$action = '=';
					$not_action = '!='; # this is a joke :)
				}
				
				# the root of the universe!..

				$q_where = " WHERE map_prod_id".$table_suffix." " . $action . " " . str_sqlize($ts3->{'pattern_mysql'}) . " " . ( ($ts3->{'mode'} =~ /not/) ? " and map_prod_id".$table_suffix." " . $not_action . " " . str_sqlize($ts3->{'pattern_mysqlnot'}) . " " : "" ) . "and pattern_id = 0 and " . $ts3->{'supplier_id'} . " in (supplier_id, map_supplier_id, 0)";

				do_statement("update " . $h->{'table'} . " set pattern_id = " . $ts3->{'id'} . " " . $q_where);
				$mapped += do_query("select row_count()")->[0][0];
#				log_printf("DV: update: ".$mapped);
			}
		}

		log_printf("DV: MAPPED: ".$mapped);
		
		print $mapped . " products mapped, " if ($h->{'visual'});

		# if we have changes - do the mapping
		if ($mapped > 0) {
			my $fu = "/tmp/prod_id_mapping_".$tstamp."_".$$."_update";
			open OUTU, ">".$fu;
			binmode OUTU, ":utf8";

			my $mapped_prods = do_query("select pattern_id, map_prod_id, prod_id, supplier_id from " . $h->{'table'} . " where pattern_id > 0");
			my $pat;
			for (@$mapped_prods) {
				# remove [^...] from pattern - for match_single_product_regexp
				$pat = $ts_id->{$_->[0]}->{'pattern'};
				$pat =~ s/\[\^.*?\]//s;
				$map_prod_id = data_management::match_single_product_regexp($pat, $_->[1]);

#				log_printf("DV: ".$_->[1]." ".$pat." ".$_->[2]);
				if (($map_prod_id ne $_->[1]) || ($ts_id->{$_->[0]}->{'map_supplier_id'} != 0)) {
#					log_printf("\tDV: ".$_->[1]." ==> ".$map_prod_id);
					$map_supplier = 0;
					if (($ts_id->{$_->[0]}->{'supplier_id'} != $ts_id->{$_->[0]}->{'map_supplier_id'}) &&
							($ts_id->{$_->[0]}->{'supplier_id'} != 0) &&
							($ts_id->{$_->[0]}->{'map_supplier_id'} != 0)) { # vendor mapping
						$map_supplier = 1;
					}
					
					# csv instead of miltiple updates: prod_id, supplier_id, map_prod_id, map_supplier_id
					print OUTU $_->[2].$t.$_->[3].$t.$map_prod_id . $t .  ( $map_supplier ? $ts_id->{$_->[0]}->{'map_supplier_id'} : $_->[3] ) . $n;
				}
			} # for
			close OUTU;

			# make a table, csv->table, update from table
			do_statement("drop temporary table if exists tmp_do_map");
			do_statement("create temporary table tmp_do_map (
prod_id         varchar(60) not null default '',
supplier_id     int(13)     not null default 0,
map_prod_id     varchar(60) not null default '',
map_supplier_id int(13)     not null default 0,

unique key (prod_id, supplier_id))");

			do_statement("load data local infile '".$fu."' into table tmp_do_map fields terminated by '".$t."' lines terminated by '".$n."'");
			my $cmd2 = "/bin/rm -rf ".$fu;
			log_printf($cmd2);
			`$cmd2`;

			# do update
			do_statement("update " . $h->{'table'} . " p inner join tmp_do_map t using(prod_id,supplier_id) set p.map_prod_id=t.map_prod_id, p.map_prod_idrev=reverse(t.map_prod_id), p.map_supplier_id=t.map_supplier_id, p.pattern_id=0");
			do_statement("drop temporary table if exists tmp_do_map");
			
			print $mapped . " products updated, " if ($h->{'visual'});

		} # if mapped
		else { # all mapped
			last;
		}
	} # 3 times

	print "done " if ($h->{'visual'});
} # prod_id_mapping

sub get_product_map_pattern_parts {
##  1  - eq       (5 - eqrev)
##  2  - like      6 - likerev
##  3? - eqnot    (7 - eqnotrev)
##  4  - likenot   8 - likenotrev
	my $p = shift;
	#$p =~ s/^\s*(.*)\s*$/$1/s;
	return undef unless $p;
	return undef if $p =~ /^\s+$/;
	my ($mode, $pnot);

	## code
	$p =~ s/%%/\x03/gs;
	$p =~ s/%=/\x01/gs;
	$p =~ s/%\*/\x02/gs;

	## split
	if ($p =~ /^(.*?)=/) {
		$p = $1;
	}
	
	## check the mode: 1,2,3?,4,(5),6,(7),8
	# decide, if we have a [^ ... ] or not
	if ($p =~ /\[\^.*\]/) { # yes, we have [^ ... ] = not mode: 3?,4,(7),8
		$pnot = $p;
		$p    =~ s/^(.*)\[\^.*\](.*)$/$1$2/s; # remove [^ ... ] from pattern
		$pnot =~ s/^(.*)\[\^(.*)\](.*)$/$1$2$3/s; # remove [^ and ] from pattern
	} # else we haven't [^ ... ] = "yes"-mode: 1,2,(5),6

	if ($p =~ /\*/) { # like-mode: 4-2, 8-6
		if ($p =~ /^\*/) { # 8-6
			$mode = $pnot ? 'likenotrev' : 'likerev';
		}
		else { # 4-2
			$mode = $pnot ? 'likenot' : 'like';
		}
	}
	else { # eq-mode: 3?-1
		$mode = $pnot ? 'eqnot' : 'eq';
	}

	## TODO: join these to 1 sub and do [^...] checking as separate if () {}

	## reverse $p and $pnot before 
	if ($mode =~ /rev/) {
		$p = scalar reverse $p;
		$pnot = scalar reverse $pnot;
	}

	## * -> %  &  decode
	for ($p, $pnot) {
		if ($mode =~ /like/) {
			s/\*/%/gs; # do the power
			s/_/\\_/gs; # escape the _
			s/\x03/\\%/gs; # escape the %
		}
		else {
			s/\x03/%/gs;
		}
		s/\x01/=/gs;
		s/\x02/*/gs;
	}

	return ($mode, $p, $pnot);
} # sub get_product_map_pattern_parts

sub check_product_map_pattern { # complete this
	my $p = shift;
	$p =~ s/^\s*(.*)\s*$/$1/s;
	return undef unless $p;
} # sub check_product_map_pattern

##
## $h - good hash, with:
##      - 'feature_id';
##      - 'measure_id';
##

sub power_mapping_per_category_feature_id_hash {
	my ($hash) = @_;

	return undef unless ($hash); # return, if hash corrupted

	# create a table: id, product_feature_id, value, new_value, history
	do_statement("drop temporary table if exists tmp_category_feature_id_hash");
	do_statement("create temporary table tmp_category_feature_id_hash (
tmp_category_feature_id_hash_id int(13) NOT NULL PRIMARY KEY auto_increment,
category_feature_id             int(13) NOT NULL default '0',
value                           text    NOT NULL default '',
new_value                       text    NOT NULL default '')");

	# fill with values
	my $insert = 'insert into tmp_category_feature_id_hash(category_feature_id,value) values';
	my $insert2 = '';
	for my $key (keys %$hash) {
		$insert2 .= "('".$key."',".str_sqlize($hash->{$key})."),";
	}
	chop($insert2);
	return undef unless ($insert2); # return, if lack of inserts
	do_statement($insert.$insert2);
	do_statement("update tmp_category_feature_id_hash set new_value=value");
	do_statement("alter table tmp_category_feature_id_hash add key (category_feature_id)");

	# feature_id mapping
	do_statement("alter table tmp_category_feature_id_hash add column feature_id int(13) not null default '0'");
	do_statement("update tmp_category_feature_id_hash tcfih inner join category_feature cf using (category_feature_id) set tcfih.feature_id=cf.feature_id");
	do_statement("alter table tmp_category_feature_id_hash add key (feature_id)");
	do_statement("delete from tmp_category_feature_id_hash where feature_id=0");

	# power mapping
	my $feature_id = do_query("select distinct feature_id from tmp_category_feature_id_hash");
	for (@$feature_id) {
		power_mapping_per_feature_and_measure({'feature_id' => $_->[0]}, 'tmp_category_feature_id_hash');
	}

	# get a result
	my $out = do_query("select category_feature_id, new_value from tmp_category_feature_id_hash");
	for (@$out) {
		$hash->{$_->[0]} = $_->[1];
	}

	do_statement("drop temporary table if exists tmp_category_feature_id_hash");
	$G_table_name = undef;
} # sub power_mapping_per_category_feature_id_hash

sub power_mapping_per_feature_and_measure_for_BO { # do group feature value power mapping (per feature_id (& also measure_id for feature_id))
	my ($h) = @_;
	# general and fantastic procedure

	# return if void
	return undef unless ($h->{'measure_id'} || $h->{'feature_id'});
	
	# create a table: id, product_feature_id, value, new_value, history
	do_statement("drop temporary table if exists tmp_group_mapping");
	do_statement("create temporary table tmp_group_mapping (
tmp_group_mapping_id int(13)      NOT NULL PRIMARY KEY auto_increment,
value                text         NOT NULL default '',
new_value            text         NOT NULL default '',
pfv_history          text         NOT NULL default '')");

	# fill with values
	do_statement("insert into tmp_group_mapping(value,new_value)
select distinct pf.value, pf.value
from product_feature pf
inner join category_feature cf on cf.category_feature_id = pf.category_feature_id
where cf.feature_id = ".$h->{'feature_id'});

	power_mapping_per_feature_and_measure($h, 'tmp_group_mapping');

	# form a hash with results - for format!!!
	my $result = do_query("select value,new_value,pfv_history from tmp_group_mapping");
	my $history;
	for my $res (@$result) {
		$hin{'power_mapping_results'}->{'new_value'}->{$res->[0]} = $res->[1];
		$history = parse_power_mapping_history($res->[2]);
		if ($history) {
			$hin{'power_mapping_results'}->{'history'}->{$res->[0]} = $history;
		}
	}

#	log_printf(Dumper($hin{'power_mapping_results'}));

	do_statement("drop temporary table if exists tmp_group_mapping");
	$G_table_name = undef;
} # sub power_mapping_per_feature_and_measure_for_BO

sub power_mapping_per_measure_for_BO { # do group measure value power mapping (per measure_id)
	my ($h) = @_;
	# general and fantastic procedure

	# return if void
	return undef unless ($h->{'measure_id'});
	
	my $measure_name = do_query("select concat(v.value,' (',ms.value,')') from measure m inner join measure_sign ms on m.measure_id=ms.measure_id and ms.langid=1  inner join vocabulary v on m.sid=v.sid and v.langid=1 where m.measure_id=".$h->{'measure_id'})->[0][0];

	# create a table: id, product_feature_id, value, new_value, history
	do_statement("drop temporary table if exists tmp_group_mapping");
	do_statement("create temporary table tmp_group_mapping (
tmp_group_mapping_id int(13)      NOT NULL PRIMARY KEY auto_increment,
value                text         NOT NULL default '',
new_value            text         NOT NULL default '',
pfv_history          text         NOT NULL default '')");

	# fill with values
	do_statement("insert into tmp_group_mapping(value,new_value)
select distinct pf.value, pf.value
from product_feature pf
inner join category_feature cf on cf.category_feature_id = pf.category_feature_id
inner join feature f on cf.feature_id = f.feature_id
where f.measure_id = ".$h->{'measure_id'});

	if ($h->{'value_regexp_bg_processes_id'}) {
		do_statement("update value_regexp_bg_processes set stage='".$measure_name.": do mapping' where value_regexp_bg_processes_id=".$h->{'value_regexp_bg_processes_id'});
	}

	power_mapping_per_feature_and_measure($h, 'tmp_group_mapping');

	# form a hash with results - for format!!!

	my $result;

	if ($h->{'apply'}) { # apply changes
		$result = do_query("select value, new_value from tmp_group_mapping where value!=new_value");
		if ($h->{'value_regexp_bg_processes_id'}) {
			do_statement("update value_regexp_bg_processes set stage='".$measure_name.": update feature values', max_value=". ($#$result+1) ." where value_regexp_bg_processes_id=".$h->{'value_regexp_bg_processes_id'});
		}
		for my $res (@$result) {
			do_statement("update product_feature pf
inner join category_feature cf using (category_feature_id)
inner join feature f using (feature_id)
set pf.value=".str_sqlize($res->[1])."
where f.measure_id=".$h->{'measure_id'}." and pf.value=".str_sqlize($res->[0]));
			if ($h->{'value_regexp_bg_processes_id'}) {
				do_statement("update value_regexp_bg_processes set current_value=current_value+1 where value_regexp_bg_processes_id=".$h->{'value_regexp_bg_processes_id'});
			}
		}
	}
	else { # preview in BO (first limit values, about 1000)
		$result = do_query("select value,new_value,pfv_history from tmp_group_mapping where pfv_history!=''".($h->{'max_rows'}?" limit ".$h->{'max_rows'}:""));
		my $history;
		for my $res (@$result) {
			$hin{'power_mapping_results'}->{$res->[0]}->{'new_value'} = $res->[1];
			$history = parse_power_mapping_history($res->[2]);
			if ($history) {
				$hin{'power_mapping_results'}->{$res->[0]}->{'history'} = $history;
			}
		}
	}

#	log_printf(Dumper($hin{'power_mapping_results'}));

	do_statement("drop temporary table if exists tmp_group_mapping");
	$G_table_name = undef;
} # sub power_mapping_per_measure_for_BO

 #######################################################################
## power_mapping_per_feature_and_measure - a main power mapping engine ##
##                                                                     ##
## measure_id                                                          ##
## feature_id                                                          ##
##                                                                     ##
## max_rows - set maxrows values mapping (for BO, measure page)        ##
## useN - allow also N patterns during mapping                         ##
## apply - set N -> Y per feature/measure                              ##
 #######################################################################

sub power_mapping_per_feature_and_measure {
	my ($h, $table_name) = @_;

	my $logs = 0;

	# get a measure_id
	if ($h->{'feature_id'}) {
		$h->{'measure_id'} = do_query("SELECT measure_id FROM feature WHERE feature_id = ".$h->{'feature_id'})->[0][0];
	}
	
	return undef unless ($h->{'measure_id'});
	
	# get a measure sign
	my $measure_signs = do_query("SELECT DISTINCT value FROM measure_sign WHERE measure_id = ".$h->{'measure_id'}." AND value != '' ORDER BY langid ASC");
	
	# check if table contents feature_id value! (needs for join)
	# check if pfv_mapped & pfv_pattern exists & add them if absent

	my $table_name_id = $h->{'id'} ? $h->{'id'} : $table_name."_id";
	
	if ($G_table_name ne $table_name) {
		my $is_feature_id_field_arrayref = do_query("desc ".$table_name);

		$G_feature_id_present = 0;
		$G_pfv_history_present = 0;
		$G_pfv_mapped_present = 0;
		$G_pfv_pattern_present = 0;
		$G_new_value_present = 0;
		$G_langid_present = 0;

		for (@$is_feature_id_field_arrayref) {
			if ($_->[0] eq 'feature_id') { $G_feature_id_present = 1; }
			elsif ($_->[0] eq 'pfv_history') { $G_pfv_history_present = 1; }
			elsif ($_->[0] eq 'pfv_mapped') { $G_pfv_mapped_present = 1; }
			elsif ($_->[0] eq 'pfv_pattern') { $G_pfv_pattern_present = 1; }
			elsif ($_->[0] eq 'new_value') { $G_new_value_present = 1; }
			elsif ($_->[0] eq 'langid') { $G_langid_present = 1; }
		}
		
		$G_table_name = $table_name;
		
		unless ($G_pfv_mapped_present) {
			do_statement("ALTER TABLE ".$table_name." ADD COLUMN pfv_mapped int(1) NOT NULL DEFAULT '0', ADD KEY pfv_mapped (pfv_mapped)");
		}
		unless ($G_pfv_pattern_present) {
			do_statement("ALTER TABLE ".$table_name." ADD COLUMN pfv_pattern varchar(255) NOT NULL DEFAULT ''");
		}
		unless ($G_new_value_present) {
			do_statement("ALTER TABLE ".$table_name." ADD COLUMN new_value text");
			do_statement("UPDATE ".$table_name." SET new_value = value");
		}
	}
	
	# do cycle of mappings: measure, feature: generic + power mapping, also collect logs
	# history format = (g|v)id: g - generic operation, v - power value mapping
	my $collect_measure_id_patterns = do_query("select vr.pattern, 'measure', vr.value_regexp_id, vr.parameter1, vr.parameter2 from value_regexp vr
inner join measure_value_regexp mvr using (value_regexp_id)
where mvr.measure_id=".$h->{'measure_id'}.($h->{'useN'}?"":" and mvr.active='Y'")." order by mvr.no asc");
	
	my $collect_feature_id_patterns = [];
	
	if ($h->{'feature_id'}) {
		$collect_feature_id_patterns = do_query("select vr.pattern, 'feature', vr.value_regexp_id, vr.parameter1, vr.parameter2 from value_regexp vr
inner join feature_value_regexp fvr using (value_regexp_id)
where fvr.feature_id=".$h->{'feature_id'}.($h->{'useN'}?"":" and fvr.active='Y'")." order by fvr.no asc");
	}

	unless ($#$collect_measure_id_patterns+1 + $#$collect_feature_id_patterns+1) {
#		do_statement("update ".$table_name." tgm set tgm.new_value=tgm.value ".($G_feature_id_present?" where feature_id=".$h->{'feature_id'}:""));
		return undef;
	}
	
	# generate_operations hash creation
	unless ($G_go_hash) {
		$G_go_hash = get_generic_operations_hash;
	}
	
	my ($l, $r, $old, $mapped, @res, $parts, $parts_mysql, $to_go, $new_go, $mapping_type, $unique_filename, $unique_filename_log, $to_log, $body, $parameter1, $parameter2, $mode, $is_go, $mode_perl, $inline_regexps, $number_of_replaces, $test);

	if ($logs) {
		$unique_filename_log = '/tmp/tgm_log_'.make_code(32);
		open(TGM_LOG,">".$unique_filename_log);
		binmode(TGM_LOG,":utf8");
	}
	
	for my $pattern (@$collect_feature_id_patterns, @$collect_measure_id_patterns) {		
		# if GO - get a body and parameter
		$is_go = 0;
		$body = $pattern->[0];
		$parameter1 = $pattern->[3];
		$parameter2 = $pattern->[4];
		
#		log_printf("'".$body."' -> '".$go_parameter."'");
		
		$mode = undef;
		
		# let's check: GO, GO via patterns or patterns
		if ($G_go_hash->{$body}->{'code'}) { # generic operation
			# check if GO mapped to pattern (increase speed): TRUE - make pattern, FALSE - make GO
			no strict;
			eval { $mode = &{'generic_operation_'.$body} ( { 'mode' => 'test' }, { 'signs' => $measure_signs, 'p1' => $parameter1, 'p2' => $parameter2 }); };
			use strict;
			next if ($@); # next if bad (absent, incorrect) GO sub
			$is_go = 1;
		}
		
		if (($is_go) && ($mode->{'status'} ne 'mysql')) { # GO not via patterns

			# let's create a csv-file
			$unique_filename = '/tmp/tgm_'.make_code(32);
			open TGM, ">".$unique_filename;
			binmode TGM, ":utf8";

			# roll-back all values and filter via GOs
			$to_go = do_query("SELECT ".$table_name_id.", new_value FROM ".$table_name);
			no strict;
			for my $go (@$to_go) {
				eval { $new_go = &{'generic_operation_'.$body}($go->[1], { 'signs' => $measure_signs, 'p1' => $parameter1, 'p2' => $parameter2 }); };
#				log_printf("after go: '".$new_go."' -> '".$go->[1]."' = ". ($new_go ne $go->[1]) .", result = ".Dumper($@));
				if (($new_go ne $go->[1]) && (!$@)) {
					print TGM "\x01".($G_pfv_history_present?("g".$pattern->[2].";"."\x01"):"").$new_go."\x01".$go->[0]."\x02";
					print TGM_LOG "\x01".$go->[1]."\x01".$body."\x01".$new_go."\x01".$pattern->[1]."\x02" if ($logs);
				}
			}
			use strict;
			undef $to_go;
		}
		else { # power mapping
			# clear mapped flag
			do_statement("UPDATE ".$table_name." SET pfv_mapped = 0, pfv_pattern = '' WHERE 1 " .
										($G_feature_id_present ? " AND feature_id = ".$h->{'feature_id'} : "") .
										($G_langid_present ? " AND langid IN (1,9)" : ""));
			
			# prepare mysql parts
			$parts_mysql = undef;
			if ($mode) {
				$mode_perl = $mode->{'perl'};
				for (@$mode_perl) {
					push @$parts_mysql, {
						'left' => $_->{'left'},
						'right' => '1' || $_->{'right'},
						'params' => $_->{'params'}
					};
				}
			}
			else {
				$parts_mysql = get_pattern_parts([$body, $parameter1, $parameter2], 'mysql', 0);
				$parts_mysql = [ $parts_mysql ];
			}
			
			next unless ($parts_mysql);

			# check for able for mapping values (pfv_mapped = 1)
			$inline_regexps = undef;
			my $for_REGEXP = undef;
			for (@$parts_mysql) {
				$for_REGEXP = $_->{'left'};
				$for_REGEXP =~ s/\\/\\\\/gs;
				$inline_regexps .= ($inline_regexps ? ' OR ' : '') . 'new_value REGEXP \'' . ($_->{'params'} eq 'g' ? '' : '^') . $for_REGEXP . ($_->{'params'} eq 'g' ? '' : '\$') . '\'';
			}

			$test = "UPDATE ".$table_name." SET pfv_mapped = 1, pfv_pattern = ".str_sqlize($body)." WHERE (".$inline_regexps.")" .
										($G_feature_id_present ? " AND feature_id = ".$h->{'feature_id'} : "") .
										($G_langid_present ? " AND langid IN (1,9)" : "");
#			log_printf("TEST = ".$test);

			do_statement($test);
			
			log_printf("found = ".do_query("select row_count()")->[0][0]);
			
			# if none found - none replace
			$number_of_replaces = do_query("SELECT count(*) FROM ".$table_name." WHERE pfv_mapped = 1" . ($G_feature_id_present ? " AND feature_id = ".$h->{'feature_id'} : "") . ($G_langid_present ? " AND langid IN (1,9)" : ""))->[0][0];
			log_printf("number of replaces = ".$number_of_replaces);
			next unless ($number_of_replaces);

			# perl converting HUGE script
			if ($mode) {
				$mode_perl = $mode->{'perl'};
				for (@$mode_perl) {
					push @$parts, {
						'left' => $_->{'left'},
						'right' => icecat2perl_regexp_right($_->{'right'}),
						'params' => $_->{'params'}
					};
				}
			}
			else {
				$parts = get_pattern_parts([$body, $parameter1, $parameter2], 'perl', 1);
				$parts = [ $parts ];
			}

			# $parts may be an array
			next unless ($parts);
			
			# let's create a csv-file for GO via patterns and patterns
			$unique_filename = '/tmp/tgm_'.make_code(32);
			open TGM, ">".$unique_filename;
			binmode TGM, ":utf8";

			# DO: $l  ->  $r
			$mapped = do_query("select ".$table_name_id.", new_value, pfv_pattern, value from ".$table_name." where pfv_mapped = 1" .
				($G_langid_present?" and langid in (1,9)":""));
			for my $map (@$mapped) {
				$old = $map->[1];
				for (@$parts) {
					next unless (defined $_->{'left'});

#					log_printf(Dumper($_));

					if ($_->{'params'} eq 'g') {
						$map->[1] =~ s/$_->{'left'}/eval($_->{'right'})/geis; # the root of the universe!!!
					}
					else {
						$map->[1] =~ s/^$_->{'left'}$/eval($_->{'right'})/eis; # the root of the universe!!!
					}
				}
				if ($map->[1] ne $old) {
					print TGM "\x01".($G_pfv_history_present?(($mode?"g":"v").$pattern->[2].";"."\x01"):"").$map->[1]."\x01".$map->[0]."\x02";
					if ($logs) {
						print TGM_LOG "\x01".$map->[3]."\x01".$map->[2]."\x01".$map->[1]."\x01".$pattern->[1]."\x02";
					}
				}
			}
		}
		close TGM;
		
		# load to tmp table
		do_statement("drop temporary table if exists ".$table_name."_new_values");
		do_statement("create temporary table ".$table_name."_new_values (
".$table_name."_new_values_id        int(13)     NOT NULL PRIMARY KEY auto_increment,
".($G_pfv_history_present?"dhistory varchar(60) NOT NULL default '',":"")."
new_value                            text,
".$table_name_id."                   int(13)     NOT NULL default '0',
unique key (".$table_name_id."))");
		
		do_statement("load data local infile '".$unique_filename."' replace into table ".$table_name."_new_values fields terminated by '\x01' lines terminated by '\x02'");
		`/bin/rm -f $unique_filename`;
		
		do_statement("update ".$table_name." tgm
inner join ".$table_name."_new_values tgmnv using (".$table_name_id.")
set tgm.new_value=tgmnv.new_value".($G_pfv_history_present?", tgm.pfv_history=CONCAT(tgm.pfv_history,tgmnv.dhistory)":""));
		do_statement("drop temporary table if exists ".$table_name."_new_values");
	}

	if ($logs) {
		close TGM_LOG;
		do_statement("load data local infile '".$unique_filename_log."'
into table value_regexp_log fields terminated by '\x01' lines terminated by '\x02' set updated=CURRENT_TIMESTAMP");
		`/bin/rm -f $unique_filename_log`;
	}
	
	if ($h->{'apply'} eq 'Y') {
		if ($h->{'feature_id'}) { # set N -> Y on feature_value_regexp for feature_id
			do_statement("update feature_value_regexp set active='Y' where feature_id=".$h->{'feature_id'});
		}
		elsif ($h->{'measure_id'}) {
			do_statement("update measure_value_regexp set active='Y' where measure_id=".$h->{'measure_id'});
		}
	}

} # sub power_mapping_per_feature_and_measure

sub parse_power_mapping_history {	# history format = (g|v)id
	my ($in) = @_;

	my $collect = '';

	my @keys = split /;/, $in;

	for (@keys) {
		chomp;
		next unless $_;

		/^(.)(.*?)$/;

		if ($1 eq 'g') { # generic value
			unless ($G_history_hash->{'g'.$2}) {
				$G_history_hash->{'g'.$2} = do_query("select concat('<b>',vr.pattern,'</b>',if(vr.parameter1!='',concat(' (<font color=\"black\">',parameter1,'</font>',if(vr.parameter2!='',concat(',<font color=\"black\">',parameter2,'</font>'),''),')'),'')) from value_regexp vr inner join generic_operation go where vr.value_regexp_id=".$2)->[0][0];
			}
			$collect .= "<nobr><font color=\"green\">".
				$G_history_hash->{'g'.$2}.
				'</font></nobr>, ';
		}
		elsif ($1 eq 'v') { # regexp
			if ($2 && ($2 eq int($2))) {
				unless ($G_history_hash->{'v'.$2}) {
					$G_history_hash->{'v'.$2} = do_query("select pattern from value_regexp where value_regexp_id=".$2)->[0][0];
				}
				$collect .= "<nobr><font color=\"blue\">".$G_history_hash->{'v'.$2}.'</font></nobr>, ';
			}
		}
	}
	chop($collect);
	chop($collect);

	return $collect;
} # sub parse_power_mapping_history


 ######################
## generic operations ##
 ######################

##
## request:
##   mode: test - check the GO/pattern mapping, are shown in status
##
## response:
##   status: 0 - disabled, perl - do 
##

sub generic_operation_void {
	return undef;
} # sub generic_operation_void

sub generic_operation_as_is {
	my ($in) = @_;

	if (ref($in) eq 'HASH') {
		return {
			'status' => 'mysql',
			'perl' => { 'left' => '', 'right' => '' }
		};
	}
	elsif (ref($in) eq 'SCALAR') {
		return $in;
	}

} # sub generic_operation_as_is

sub generic_operation_kg2g {
	my ($in) = @_;
	if (ref($in) eq 'HASH') {
		return { 'status' => 0 }; # temporary disabled
	}
	elsif (ref($in) eq 'SCALAR') {
		return $in; # TEMPORARY!
		# WILL FILL IT SOON!!!
	}
} # sub generic_operation_kg2g

sub generic_operation_remove_spaces {
	my ($in,$params) = @_;

	if (ref($in) eq 'HASH') {
		return {
			'status' => 'mysql',
			'perl' => [
								 { 'left' => '^[[:space:]]+', 'right' => '', 'params' => 'g' },
								 { 'left' => '[[:space:]]+$', 'right' => '', 'params' => 'g' }
								 ]
								 };
	}
	elsif (ref($in) eq 'SCALAR') {
		return undef unless (defined $in);
		
		$in =~ s/^\s+//is;
		$in =~ s/\s+$//is;
		
		return $in;
	}
} # sub generic_operation_remove_spaces

sub generic_operation_remove_string {
	my ($in,$params) = @_;

	if (ref($in) eq 'HASH') {
		return {
			'status' => 'mysql',
			'perl' => [
								 {
									 'left' => quotemeta($params->{'p1'}),
									 'right' => '',
									 'params' => 'g'
								 }
				]
		};
	}
	elsif (ref($in) eq 'SCALAR') {
		return undef unless (defined $in);
		return $in unless $params->{'p1'};
		
		$params->{'p1'} = quotemeta($params->{'p1'});
		
		$in =~ s/$params->{'p1'}//gis;
		
		return $in;
	}
} # sub generic_operation_remove_string

sub generic_operation_replace_string {
	my ($in,$params) = @_;

	if (ref($in) eq 'HASH') {
		return {
			'status' => 'mysql',
			'perl' => [
								 {
									 'left' => quotemeta($params->{'p1'}),
									 'right' => quotemeta($params->{'p2'}),
									 'params' => 'g'
								 }
				]
		};
	}
	elsif (ref($in) eq 'SCALAR') {
		return undef unless (defined $in);
		return $in unless $params->{'p1'};
		
		$params->{'p1'} = quotemeta($params->{'p1'});
		$params->{'p2'} = quotemeta($params->{'p2'});
		
		$in =~ s/$params->{'p1'}/$params->{'p2'}/gis;
		
		return $in;
	}
} # sub generic_operation_replace_string

sub generic_operation_remove_double_units {
	my ($in, $params) = @_;
	
	my $signs = $params->{'signs'};

#	my $first = '(\-?[[:digit:]]+(\.[[:digit:]]+)?(\/[[:digit:]]+(\.[[:digit:]]+)?)?([[:space:]]*\(.*\))?)[[:space:]]*';
	my $first = '(\-?[[:digit:]]+(\.[[:digit:]]+)?([[:space:]]*\(.*\))?)[[:space:]]*';
	my $second = '($|[^0-9a-zA-Z])';

	my $arr;

	if (ref($in) eq 'HASH') {
		for (@$signs) {
			chomp($_->[0]);
			next unless ($_->[0]);
			push @$arr, { 'left' => $first.quotemeta($_->[0]).$second, 'right' => '$1$6', 'params' => 'g' };
		}

		return {
			'status' => 'mysql',
			'perl' => $arr
			};
	}
	elsif (ref($in) eq 'SCALAR') {
		return $in unless (defined $in);
		return $in unless (ref($signs) eq 'ARRAY');
		
		my $sgn = undef;

		for (@$signs) {
			chomp($_->[0]);
			next unless ($_->[0]);
			$sgn = quotemeta($_->[0]);
			$in =~ s/$first$sgn$second/$1$5/gis;
		}
		
		return $in;
	}
} # sub generic_operation_remove_double_units

 ###########
## mapping ##
 ###########

 #########################################################################
##                                                                       ##
## sub creating new tmp regexp table by request                          ##
##                                                                       ##
## 1 value: request "select table_id, id, pattern, frequency from table" ##
## 2 value: name of already created tmp table:                           ##
##          tmp_table_id                                                 ##
##          table_id                                        <- table_id  ##
##          mapped_id                                       <- id        ##
##          left_mysql_pattern                                           ##
##          left_mysql_match                                             ##
##          pattern                                         <- pattern   ##
##          frequency                                       <- frequency ##
##                                                                       ##
 #########################################################################

sub icecat2mysql_mapping {
	my ($hash, $query, $tmptable) = @_;

	my ($out, $left, $left_old, $whole, $rwhole, $parts, $cmd);

	# give id name
	my $id_name = do_query("desc ".$tmptable)->[2][0];

	my $patterns = do_query($query);
	do_statement("alter table ".$tmptable." add column left_mysql_match varchar(60) not null default ''"); # important thing
	do_statement("alter table ".$tmptable." add key (".$id_name."), add key (left_mysql_pattern), add key (left_mysql_match)");

	for my $item (@$patterns) {
	
		@$parts = split(/\n/,@$item->[2]);

		for my $part (@$parts) {
			$part = my_chomp($part);
			next unless $part;
			$whole = $part;
			# hide ICEcat pattern metatags
			$part =~ s/\%\*/\x01/g; $part =~ s/\%\%/\x02/g; $part =~ s/\%\=/\x03/g;
			if ($part =~ /^(.*)\=/) { $left = $1;	} else { $left = $part; }
			$left_old = $left;
			if ($hash->{'mode'} eq 'like') {
				$left = icecat2mysql_like($left);
			}
			else {
				$left = icecat2mysql_regexp($left,$hash->{'metatags'});
			}
			# show ICEcat pattern metatags
			$left =~ s/\x01/\\\*/sg; $left =~ s/\x02/\%/gs; $left =~ s/\x03/\=/gs;
			$left =~ s/\\\\/\\/sg; # IMPORTANT!.. We do load data, not open request. That's why we don't need to duplicate slashes
			$out .= "\x01".$item->[0]."\x01".$item->[1]."\x01" . ( $hash->{'mode'} eq 'like' ? $left : "^".$left."\$" ) . "\x01".$whole."\x01".$item->[3]."\x01".$item->[4]."\x01".$left_old."\x02";
		}
	}

	# load data into tmp file
	my $filename = POSIX::time()."_".$hash->{'data_source_code'}."_".$tmptable;
	open(TMP,">"."/tmp/".$filename);
	flock(TMP,2);
	binmode(TMP,":utf8");
	print TMP $out;
	close(TMP);

	# load data local infile from tmp file & delete them
	do_statement("load data local infile \""."/tmp/".$filename."\" into table `".$tmptable."` fields terminated by '\x01' escaped by '' lines terminated by '\x02'");
	$cmd = "/bin/rm -f /tmp/".$filename;
	`$cmd`;

	# mark *-ed and non-*-ed patterns: *ed will be matched via regexp, others - via =
	do_statement("alter table ".$tmptable." add column with_metatags tinyint(1) not null default 0");
	do_statement("update ".$tmptable." set with_metatags=1 where locate('.*',left_mysql_pattern)>0");
	do_statement("alter table ".$tmptable." add key (with_metatags)");
}

sub get_pattern_parts {
	my ($part,$type,$is_right) = @_;

	my ($general, $p1, $p2);

	unless ($G_go_hash) {
		$G_go_hash = get_generic_operations_hash;
	}

	if (ref($part) eq 'ARRAY') { # [$body, $parameter1, $parameter2]
		$general = $part->[0];
		$p1 = $part->[1];
		$p2 = $part->[2];
	}
	elsif (ref($part) eq 'SCALAR') {# pattern
		$general = $part;
		$p1 = '';
		$p2 = '';
	}
	else {
		return { 'left' => '', 'right' => '' };
	}

	#$part =~ /^(.*?)\s+(.*)$/;
	
	if ($G_go_hash->{$general}->{'code'}) {
		return { 'left' => $general, '1' => $p1, '2' => $p2 };
	}

	my ($left, $right, $rhash);
	
	$general =~ s/\%\%/\x02/g;
	$general =~ s/\%\*/\x01/g;
	$general =~ s/\%\#/\x04/g;
	$general =~ s/\%\=/\x03/g;

	if ($general =~ /^(.*)\=(.*)$/) {
		$left = $1;
		if ($is_right) {
			$right = $2;
		}
	}
	else {
		$left = $general;
	}
	
	$rhash = {};

	$left = ($type eq 'perl') ? icecat2perl_regexp_left($left,$rhash) :
		(($type eq 'none') ? $left : icecat2mysql_regexp($left));

	$left =~ s/\x01/\\\*/g;
	$left =~ s/\x04/\\\#/g;
	$left =~ s/\x02/\%/g;
	$left =~ s/\x03/\=/g;
	
	if ($right && $is_right) {
		$right = ($type eq 'perl') ? icecat2perl_regexp_right($right,$rhash) :
			(($type eq 'none') ? $right : icecat2mysql_regexp($right));
		
		$right =~ s/\x01/\\\*/g;
		$right =~ s/\x04/\\\#/g;
		$right =~ s/\x02/\%/g;
		$right =~ s/\x03/\=/g;
	}
	
	return { 'left' => $left, 'right' => $right };
} # sub get_pattern_parts

sub icecat2mysql_like {
	my $str = shift;
	
	$str =~ s/\*/\x01/gs; # convert all * to 01

	$str =~ s/%/\\\%/gs; # escape %
	$str =~ s/_/\\\_/gs; # escape _

	$str =~ s/\x01/%/gs; # convert all 01 to %

	return $str;
} # sub icecat2mysql_like

sub icecat2mysql_regexp {
  my ($str, $metatags) = @_;

  $str =~ s/\./\\\./gs;
  $str =~ s/\^/\\\^/gs;
  $str =~ s/\$/\\\$/gs;
  $str =~ s/\+/\\\+/gs;
  $str =~ s/\?/\\\?/gs;
  $str =~ s/\|/\\\|/gs;
  $str =~ s/\(/\\\(/gs;
  $str =~ s/\)/\\\)/gs;
  $str =~ s/\[/\\\[/gs;
  $str =~ s/\]/\\\]/gs;
  $str =~ s/\{/\\\{/gs;
  $str =~ s/\}/\\\}/gs;
	$str =~ s/\//\\\//gs;
  $str =~ s/\-/\\\-/gs;

	if ((!$metatags) || ($metatags =~ /#/)) {
#		$str =~ s,\#,-?[[:digit:]]+(\.[[:digit:]]+)?(\/[[:digit:]]+(\.[[:digit:]]+)?)?,gs; # # -> !digit!*
		$str =~ s,\#,-?[[:digit:]]+(\.[[:digit:]]+)?,gs; # # -> !digit!*
	}

	if ((!$metatags) || ($metatags =~ /^/)) { # a new [^...] construction
#		$str =~ 
	}

  $str =~ s/\*/.*/gs; # * -> .*

  return $str;
} # sub icecat2mysql_regexp

sub icecat2perl_pattern {
	return icecat2perl_regexp_left(@_);
} # sub icecat2perl_pattern

sub icecat2perl_regexp_left { # # & * only yet
	my ($str,$right) = @_;
	
	# quotes ALL

#	log_printf("before = ".$str);
	$str = quotemeta($str);
#	log_printf("after = ".$str);

	# unquote tags
	$str =~ s/\\\#/\#/gs;
	$str =~ s/\\\*/\*/gs;

	# 
	if (ref($right) eq 'HASH') {
		my $str2 = $str;
		my $cnt = 1;
		my $cnt2 = 1;
		while ($str2 =~ /^.*?(\#|\*).*$/) {
			$right->{$cnt} = $cnt2;
#			if ($1 eq '*') {
				$cnt2++;
#			}
#			elsif ($1 eq '#') {
#				$cnt2 += 4;
#			}
			$str2 =~ s/^.*?(\#|\*)//;
			$cnt++;
		}
	}

#	log_printf(Dumper($right));

	# tags -> their values
	$str =~ s/\#/(\-?\\\d+(?:\\\.\\\d+)?)/gs;
	#$str =~ s/\#/(\-?\\\d+(?:\\\.\\\d+)?(?:\\\/\\\d+(?:\\\.\\\d+)?)?)/gs;
	$str =~ s/\*/(.*?)/gs;

	# spaces -> \s
#	$str =~ s/\s/\\s/gs;

	return $str;
} # sub icecat2perl_regexp_left

sub icecat2perl_regexp_right { # using quotemeta, as in data_management
	my ($str,$right) = @_;

	$str = quotemeta($str);

#	log_printf("before = ".$str);

	# temporary values
	$str =~ s,\\\$\\?(\d+),\"\.\$\$$1\.\",gs;

	# right value
	if (ref($right) eq 'HASH') {
		for my $r (keys %$right) {
			$str =~ s/\$\$$r/\$$right->{$r}/gs;
		}
	}

	$str =~ s/\$\$/\$/gs;
	
#	log_printf("after = ".$str);

	return "\"".$str."\"";
} # sub icecat2perl_regexp_right

sub my_chomp {
	my ($str) = @_;
	$str =~ s/^\s*(.*?)\s*$/$1/s;
	return $str;
} # sub my_chomp

sub get_generic_operations_hash {
	my $out;
	my $go = do_query("select generic_operation_id, code, name, parameter from generic_operation");
	for (@$go) {
		no strict;
		eval {
			&{'generic_operation_'.$_->[1]}({'mode' => 'test'});
		};
		$out->{$_->[1]}->{'code'} = $@?0:$_->[0];
		$out->{$_->[1]}->{'name'} = $@?$@:$_->[2];
		$out->{$_->[1]}->{'parameter'} = $@?0:$_->[3];
	}
	return $out;
} # sub get_generic_operations_hash

1;

package feature_values;

#$Id: feature_values.pm 3789 2011-02-04 13:33:32Z alexey $

use strict;
use atomlog;
use atomcfg;
use atom_util;
use atom_html;
use atomsql;
use atom_mail;
use icecat_util;
use Digest::MD5 qw(md5_hex);

use Data::Dumper;


use vars qw ($atomid @errors);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw( &apply_feature_values_mapping
								&create_feature_values_mapping
								&map_feature_value
							 );
}

use vars qw ($loaded_mapping);

sub map_feature_value {
	my ($feature_id, $value, $missing) = @_;
	
	if (!$loaded_mapping) {
		$loaded_mapping = {};
	}
 
	if (!$loaded_mapping->{$feature_id}) {
		my $data = &do_query("select id, ext_value, int_value from feature_value_mapping where feature_id = ".&str_sqlize($feature_id));
		foreach my $row (@$data) {
			$loaded_mapping->{$feature_id}->{'mapping'}->{$row->[1]} = 
			{ 'id' 					=> $row->[0],
				'int_value'		=> $row->[2]};
		}
	
		$data = &do_query("select restricted_values, type from feature where feature_id = ".&str_sqlize($feature_id));
		if ($data->[0] && $data->[0][1] eq 'dropdown') {
			my @list = split("\n", $data->[0][0]);
			foreach my $a (@list) {
				$a =~s/\r//g;
			}
			my %hash = map { $_ => 1} @list;
			$loaded_mapping->{$feature_id}->{'allowed_value'} = \%hash;
		}
		
	}
	# &log_printf(" feature_id = $feature_id value = $value"); 
	if (!$loaded_mapping->{$feature_id} ||
			! ( $loaded_mapping->{$feature_id}->{'allowed_value'} ||
					$loaded_mapping->{$feature_id}->{'mapping'}
					)
			) {
		# &log_printf("	  # no mapping needed");
		return ($value, 0);
	}
	# else checking if the current value is ok 
	if ($loaded_mapping->{$feature_id}->{'allowed_value'}->{$value}) {
		# &log_printf("  # current value is ok ");
		return ($value, 0);
	}
	
	# otherwise trying to map
	my $int_value;
	if ($int_value = $loaded_mapping->{$feature_id}->{'mapping'}->{$value}->{'int_value'}) {
		# &log_printf("  # such mapping exists. ok");
		# &log_printf(" value = $int_value"); 
		return ($int_value, 0);
	}
	else {
		# &log_printf("missing mapping for feature value");
		$missing->{'feature_value_mapping'}->{$feature_id}->{$value} = 1;
		return ($value, 1);
	}
} # sub map_feature_value

sub create_feature_values_mapping {
	my ($feature_id, $mapping, $maintain_mapping, $make_dropdown) = @_;
	
	if ($make_dropdown) {
		$maintain_mapping = 1;
	}
	
	my $data = &do_query("select id, ext_value, int_value from feature_value_mapping where feature_id = ".&str_sqlize($feature_id));
  my $existing_values_string = &do_query("select restricted_values from feature where feature_id = ".&str_sqlize($feature_id))->[0][0];
	
	my %cmapping = map { $_->[1] => { 'int_value' =>  $_->[2], 'id' => $_->[0] } } @$data;
	my $values_string = '';
	my $val_hash = {};
	
	foreach my $row (@$mapping) {
		if ($row->{'ext_value'}) {
			my $tmp = $row->{'int_value'};
			$tmp =~s/\n/\\n/gsm;
			
			$val_hash->{$tmp} = 1;
			
			foreach my $cext_value (keys %cmapping) {
				my $chash = $cmapping{$cext_value};
				if ($chash->{'int_value'} eq $row->{'ext_value'}) {
					if ($maintain_mapping) {
						if (defined $row->{'int_value'}) {
							&update_rows('feature_value_mapping', " id = ".$chash->{'id'},
													 { 'int_value'	=> &str_sqlize($row->{'int_value'})});
						}
					}
				}
			}
			
			if ($cmapping{$row->{'ext_value'}}) {
				# already exists
				if ($maintain_mapping) {
					if (defined $row->{'int_value'}) {
						&update_rows('feature_value_mapping', " id = ".$cmapping{$row->{'ext_value'}}->{'id'},
												 { 'int_value'	=> &str_sqlize($row->{'int_value'})});
					}
				}
			}
			elsif ($row->{'ext_value'} ne $row->{'int_value'}) {
				if ($maintain_mapping) {
					if (defined $row->{'int_value'}) {
		 				&insert_rows('feature_value_mapping', 
												 {
													 'ext_value' 	=> &str_sqlize($row->{'ext_value'}),
													 'int_value'	=> &str_sqlize($row->{'int_value'}),
													 'feature_id'	=> &str_sqlize($feature_id)
													 });
						
						$cmapping{$row->{'ext_value'}} = $row;
						$cmapping{$row->{'ext_value'}}->{'id'} = &sql_last_insert_id();
					}
				}
			}
		}
	}
	
	my @exist_val = split("\n", $existing_values_string);
	
	foreach my $val (@exist_val) {
		delete $val_hash->{$val};
	}
	foreach my $key (keys %$val_hash) {
		push @exist_val, $key;
	}
	
  @exist_val = sort @exist_val;
	
	$values_string = join("\n", @exist_val);
	
	if ($make_dropdown) {
		&update_rows('feature', "feature_id = ".&str_sqlize($feature_id), 
								 { 'restricted_values'	=> &str_sqlize($values_string),
									 'type' 		=> '\'dropdown\''});
	}
} # sub create_feature_values_mapping

sub apply_feature_values_mapping {
	my ($feature_id, $mapping, $maintain_mapping, $make_dropdown) = @_;
	use utf8;
	use Encode;
	my $cat_feats = &do_query("select category_feature_id from category_feature where feature_id = ".&str_sqlize($feature_id));
	&do_statement('CREATE TEMPORARY TABLE tmp_pf_value (product_feature_id int(13) not null default 0,value varchar(255) not null default \'\',KEY(product_feature_id))');		
	foreach my $row (@$mapping) {
		if ($row->{'int_value'} ne $row->{'ext_value'}) {
			&do_statement("INSERT INTO tmp_pf_value (product_feature_id,value)
						  SELECT product_feature_id,value FROM product_feature WHERE product_feature_id=".$row->{'product_feature_id'});
			my $db_value=&do_query("SELECT value FROM tmp_pf_value WHERE product_feature_id=$row->{'product_feature_id'}")->[0][0];
			if(cmp_symbols($row->{'old_post_value'},$db_value)){# check if feature value from web page eq to the same value from db and prod_feature_id 
				foreach my $cat_feat (@$cat_feats) {
							&update_rows("product_feature", " category_feature_id = $cat_feat->[0] and 
													value = (SELECT value FROM tmp_pf_value WHERE product_feature_id=$row->{'product_feature_id'})",
													 {
														 'value' => &str_sqlize($row->{'int_value'})
														 });						
					}
			}else{# value of given product_feature_id was changed. Unxpected case
				&lp('---------->>>>>>>>>>>>>>>>>>>>error');  
				push(@user_errors,'Some features was changed  during update. Please push apply button again');
			}
		}
	}
} # sub apply_feature_values_mapping

1;

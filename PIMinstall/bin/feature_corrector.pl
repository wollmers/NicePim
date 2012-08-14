#!/usr/bin/perl

use lib "/home/pim/lib";

use atomcfg;
use atomsql;
use Data::Dumper;

$test=1;

print "start:\n";

&correcto_feature_values;

print "end\n";



sub correcto_feature_values {
	&replace_feature_values('Yes','Y');
	&replace_feature_values('No','N');
}

sub replace_feature_values {
	my ($value,$value2) = @_;

	open (FILL, "> ".$atomcfg{'base_dir'}.'logs/feature_corrector.pl.log');
	binmode (FILL, ":utf8");
	my $query = "SELECT f.product_feature_id, p.product_id, p.prod_id, p.supplier_id, p.name 
								FROM product_feature f JOIN product p ON f.product_id=p.product_id WHERE TRIM(f.value)=".&str_sqlize($value);
	
	my $res = &do_query($query);
	print FILL "\t\tfeatures with value=".&str_sqlize($value)."\n";
	foreach (@$res) {
		print FILL $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t".$_->[4]."\n";
	}

	$query = "UPDATE product_feature SET value=".&str_sqlize($value2)." WHERE TRIM(value)=".&str_sqlize($value);
	print $query . "\n";
	if (!$test) {
		do_statement($query);
	}

	my $query = "SELECT f.product_feature_local_id, p.product_id, p.prod_id, p.supplier_id, p.name 
								FROM product_feature_local f JOIN product p ON f.product_id=p.product_id WHERE TRIM(f.value)=".&str_sqlize($value);
	
	my $res = &do_query($query);
	print FILL "\t\tlocal features with value=".&str_sqlize($value)."\n";
	foreach (@$res) {
		print FILL $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t".$_->[4]."\n";
	}

	$query = "UPDATE product_feature_local SET value=".&str_sqlize($value2)." WHERE TRIM(value)=".&str_sqlize($value);
	print $query . "\n";
	if (!$test) {
		do_statement($query);
	}


	my $query = "SELECT value, langid FROM feature_values_vocabulary WHERE trim(value) != '' and key_value = ".&str_sqlize($value);
	my $translations  = &do_query($query);


	foreach (@$translations) {
		$query = "SELECT f.product_feature_local_id, p.product_id, p.prod_id, p.supplier_id, p.name 
									FROM product_feature_local f JOIN product p ON f.product_id=p.product_id 
									WHERE f.langid=".&str_sqlize($_->[1])." AND TRIM(f.value)=".&str_sqlize($_->[0]);

		my $res = &do_query($query);
		print FILL "\n\t\tlocal features with value=".&str_sqlize($_->[0])." and langid=".&str_sqlize($_->[1])."\n";
		foreach (@$res) {
			print FILL $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t".$_->[4]."\n";
		}

		$query = "UPDATE product_feature_local SET value=".&str_sqlize($value2)." WHERE langid=".&str_sqlize($_->[1])." AND TRIM(value)=".&str_sqlize($_->[0]);
		print $query . "\n";
		if (!$test) {
			do_statement($query);
		}
	}
	close (FILL);
}


1;

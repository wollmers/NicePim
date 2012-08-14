#!/usr/bin/perl

use lib "/home/pim/lib";
use atomsql;

my $query = "SELECT p.product_id,p.prod_id,p.supplier_id,su.name,pf.value,p.name,m.sign
FROM product p
LEFT JOIN product_feature pf ON p.product_id = pf.product_id
LEFT JOIN supplier su ON p.supplier_id = su.supplier_id
LEFT JOIN category_feature cf ON cf.category_feature_id = pf.category_feature_id
LEFT JOIN feature f ON cf.feature_id = f.feature_id
LEFT JOIN vocabulary v ON v.sid = f.sid
LEFT JOIN measure m ON f.measure_id = m.measure_id
WHERE v.value = 'Weight' AND pf.value > 0
";

my $result = do_query("$query");

open OUT, ">/home/pim/www/weight.csv";
foreach my $str (@$result){
	my $string = {};
	$string->{'0'}->{'product_id'} = $str->[0];
	$string->{'1'}->{'prod_id'} = $str->[1];
	$string->{'2'}->{'supplier_id'} = $str->[2];
	$string->{'3'}->{'supplier'} = $str->[3];
	$string->{'4'}->{'weight'} = $str->[4];
	$string->{'5'}->{'product_name'} = $str->[5];
	$string->{'6'}->{'measure'} = $str->[6];
	if ($string->{'6'}->{'measure'} eq 'Kg' or $string->{'6'}->{'measure'} eq 'kg'){
		$koef = 1000;
	}
	elsif ($string->{'6'}->{'measure'} eq 'g' or $string->{'6'}->{'measure'} eq 'g') {
		$koef = 1;
	}
	else {
		print "Unknown measure:" . $string->{'6'}->{'measure'};
	}
	$string->{'4'}->{'weight'} *= $koef;
	foreach my $key (sort keys %$string){
		next if ($key == 6);
		foreach my $subkey (keys %{$string->{$key}}){
			next if ($key == 4 and $string->{$key}->{$subkey} == 0 or $string->{$key}->{$subkey} eq '');
			print OUT $string->{$key}->{$subkey}."\t";
		}
	}
	print OUT "\n";
}
close OUT;

package files_index;

#$Id: files_index.pm 2318 2010-03-22 17:23:36Z dima $

use atomcfg;
use atomsql;
use atomlog;
use atom;
use atom_html;
use atom_misc;
use atom_util;
use icecat_util;

use Data::Dumper;

use vars qw($spam $ajax_request);

##################################################################################################

BEGIN {
	use Exporter();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
	@EXPORT = qw(&generate_files_index &files_index_cgi);
}

#
# <?xml version="1.0" encoding="UTF-8" ?>
# <!DOCTYPE ICECAT-interface SYSTEM "http://.../dtd/files.index.dtd">
# <!-- source: ICEcat.biz -->
# <ICECAT-interface>
#   <files.index Generated="20070101000000">
#     <file path="export/level4/INT/1.xml" Product_ID="1" Updated="20070101000000" Quality="ICECAT" Supplier_id="1" Prod_ID="A0000A" Catid="1">
#       <M_Prod_ID>MA0000A</M_Prod_ID>
#     </file>
#
#     ...........
#
#   </files.index>
# </ICECAT-interface>
#

sub files_index_cgi {

# vars
	my $max = 10;

# Make some logging here
	log_printf("Started files.index logging");

# Parsing the input of the client
	atom_html::ReadParse;

#	my $ajax_request = $hin{REQUEST_BODY};

	$hin{'files_index_path'} = get_path($ENV{'SCRIPT_NAME'});

	$hin{'files_index_max'} = $max;

	my $icecat_interface = ${generate_files_index(\%hin)};
	if ((!$icecat_interface)||(!$hin{'files_index_path'})) {
		$icecat_interface = "<ICECAT-interface " . xsd_header("files.index") . ">\n  <files.index>\n  </files.index>\n </ICECAT-interface>";
	}
	print STDOUT xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{'host'}."dtd/files.index.dtd\">\n".source_message()."\n".$icecat_interface;

} # sub files_index_cgi

sub generate_files_index {
	my ($h) = @_;
	my ($out, $pids, $pid, $rh);
	chomp($h->{'product_ids'});

	# check if they are numbers
	my $pids2 = get_good_list_from_product_ids($h->{'product_ids'}); # array of product_id conditions
	my $pids3 = get_good_list_from_prod_ids($h); # string of prod_id+supplier_id conditions
	my $openICEcatCondition = openICEcatCondition;
	my $EANCondition = EANCondition($h);

	# condition
	my $condition = " where (".$$pids2." or (0 ".$$pids3.") or (0 ".$$EANCondition."))".((int($h->{'catid'}))?" and p.catid=".$h->{'catid'}:"").$$openICEcatCondition;
	
	do_statement("create temporary table tmp_product (product_id int(13) not null default '0')");
	do_statement("insert into tmp_product(product_id)
select p.product_id from product p
inner join supplier s using (supplier_id)".
								(($$openICEcatCondition)?"
inner join users u on u.user_id=p.user_id
inner join user_group_measure_map ugmm using (user_group)":"").
								(($$EANCondition)?"
left join product_ean_codes pec on p.product_id=pec.product_id":"").
								$condition." limit ".$hin{'files_index_max'}||10);
	
	# prod_id
	my $prods = do_query("select p.product_id, unix_timestamp(p.updated), ugmm.measure, p.supplier_id, p.prod_id, p.catid, dp.original_prod_id
from tmp_product tp
inner join product p on tp.product_id=p.product_id
inner join users using (user_id)
inner join user_group_measure_map ugmm using (user_group)
left  join distributor_product dp on p.product_id=dp.product_id");
	do_statement("drop temporary table tmp_product");
	
	for my $p (@$prods) {
		$rh->{'file'}->{$p->[0]}->{'path'} = $hin{'files_index_path'}.$p->[0].".xml";
		
		$rh->{'file'}->{$p->[0]}->{'Updated'} = atom_util::format_date($p->[1]);
		$rh->{'file'}->{$p->[0]}->{'Quality'} = $p->[2];
		$rh->{'file'}->{$p->[0]}->{'Supplier_id'} = $p->[3];
		$rh->{'file'}->{$p->[0]}->{'Prod_ID'} = str_xmlize($p->[4]);
		$rh->{'file'}->{$p->[0]}->{'Catid'} = $p->[5];
		$rh->{'file'}->{$p->[0]}->{'M_Prod_ID'} = [{'content' => str_xmlize($p->[6])}] if (($p->[6]) && ($p->[6] ne $p->[4]));
	}
	
	$out = xml_out({'files.index' => [$rh]}, {key_attr => { 'file' => 'Product_ID' }, rootname => 'ICECAT-interface'});

	chomp($$out);

	return $out;
} # sub generate_files_index

##################################################################################################

sub get_good_list_from_product_ids {
	my ($bad) = @_;

	my ($pids, $out, $good, $good2, $a, $b);
	@$pids = split(/,/, $bad);
	for (my $i=0;$i<=$#$pids;$i++) {
		if ($pids->[$i] =~ /^(\d+)\-(\d+)$/) {
			if ($1 <= $2) { $a = $1; $b = $2;	}	else { $a = $2; $b = $1; }
			$good2 .= " or ( p.product_id>=".$a." and p.product_id<=".$b." ) ";
		}
		elsif ($pids->[$i] =~ /^(\d+)$/) {
			push @$good, $1;
		}
	}
	$out = " p.product_id in (".join(",",(0,@$good)).") ".$good2;
	return \$out;
} # get_good_list_from_product_ids

sub get_good_list_from_prod_ids {
	my ($h) = @_;

	my ($out, $supplier);
	my $i=1;
	for (;;) {
		if ($h->{'prod_id_'.$i}) {
			if ($h->{'supplier_'.$i}) {
				$supplier = " and s.name = ".str_sqlize($h->{'supplier_'.$i});
			}
			else {
				$supplier = '';
			}
			$out .= " or (p.prod_id = ".str_sqlize($h->{'prod_id_'.$i}).$supplier.")";
		}
		else {
			last;
		}
		$i++;
	}
	return \$out;
} # sub get_good_list_from_prod_ids

sub openICEcatCondition {
	my $condition = '';
	if ($ENV{'SCRIPT_NAME'} =~ /^\/export\/vendor(\.int)?\/(.+?)\//) { # vendor openICEcat
		# convert supplier name to directory name
		$condition = " and ugmm.measure != 'NOEDITOR' and REPLACE(REPLACE(lower(trim(s.name)),' ','_'),'/','-') = ".str_sqlize($2)." ";
	}
	elsif ($ENV{'SCRIPT_NAME'} =~ /^\/export\/freexml(\.int)?\//) { # freexml openICEcat
		$condition = " and ugmm.measure != 'NOEDITOR' ";
	}
	return \$condition;
} # sub openICEcatCondition

sub EANCondition {
	my ($h) = @_;
	my ($out, $eans);

	if ($h->{'eans'}) {
		@$eans = split(/,/, $h->{'eans'});
		for my $ean (@$eans) {
			if ($ean =~ /^\w{13}$/) {
				$out .= " or pec.ean_code=".str_sqlize($ean);
			}
		}
	}

	return \$out;
} # sub EANCondition

sub get_path {
	my $path = $ENV{'SCRIPT_NAME'};
	$path =~ s/\/(.*)\/.*/$1/;
	return ($path =~ /export/)?$path."/":undef;
} # sub get_path

##################################################################################################

1;

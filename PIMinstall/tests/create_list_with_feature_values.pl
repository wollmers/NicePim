#!/usr/bin/perl
# @author <vadim@bintime.com>
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Spreadsheet::WriteExcel;
use lib "/home/pim/lib";
use atomsql;
use atom_mail;

use constant XLS_REPORT		=> '1026845_Create_a_list_with_feature_values.xls';
use constant XLS_MAX_ROWS	=> 65536;
use constant SUPPLIER		=> 'ASUS, Packard Bell, Sony, Apple';
use constant CATEGORY		=> 'notebooks';
use constant FEATURE		=> 'Processor model, Chipset, Graphic adapter, Memory slots, Networking features';
use constant START_DATE		=> '2010-09-01';
use constant END_DATE		=> 'NOW()';
use constant UGMM			=> 'ICECAT';
use constant EMAIL_TO		=> 'alexandr_kr@icecat.biz,blackchval@gmail.com';
use constant EMAIL_FROM		=> 'info@icecat.biz';
use constant EMAIL_SUBJ		=> "1026845: Create a list with feature values";

print BOLD WHITE "::Detecting category id for '" . CATEGORY . "' ...", RESET;
my $catid = &do_query("SELECT catid FROM category c JOIN vocabulary v USING (sid) WHERE v.langid=1 AND v.value=" . &str_sqlize(CATEGORY))->[0]->[0];
unless ( $catid ) {
	print BOLD WHITE "[ ", BOLD RED, "fail", BOLD WHITE, " ]", RESET, "\n";
	exit;
} else {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
}

print BOLD WHITE "::Detecting each id from supplier's list ...", RESET, "\n";
my $suppliers = [ split /,/, SUPPLIER ];
my $supplier_id_list = "";
foreach ( @$suppliers ) {
	s/^\s+|\s+$//g;
	my $supplier_id = &do_query("SELECT supplier_id FROM supplier WHERE name=" . &str_sqlize($_))->[0]->[0];
	unless ( $supplier_id ) {
		print BOLD RED, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
	} else {
		print BOLD GREEN, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
		$supplier_id_list .= $supplier_id . ',';
	}
}
$supplier_id_list =~ s/,$//;
unless ( $supplier_id_list ) {
	print BOLD RED "No one supplier were found\nExit", RESET, "\n";
	exit;
}

print BOLD WHITE "::Detecting each feature id from feature's list ...", RESET, "\n";
my $features = [ split /,/, FEATURE ];
my $feature_id_list = "";
foreach ( @$features ) {
	s/^\s+|\s+$//g;
	my $feature_id = &do_query("SELECT feature_id FROM feature JOIN vocabulary v USING(sid) WHERE v.langid=1 AND v.value=" . &str_sqlize($_))->[0]->[0];
	unless ( $feature_id ) {
		print BOLD RED, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
	} else {
		print BOLD GREEN, ' ' . &str_sqlize($_) . ' ', RESET, "\n";
		$feature_id_list .= $feature_id . ',';
	}
}
$feature_id_list =~ s/,$//;
unless ( $feature_id_list ) {
	print BOLD RED "No one feature were found\nExit", RESET, "\n";
	exit;
}

print BOLD WHITE "::Executing main query ... ", RESET;
my $query_result = &do_query("SELECT u.login, FROM_UNIXTIME(ej.date), s.name, " . &str_sqlize(CATEGORY) . ", v.value, pf.value FROM editor_journal ej JOIN product p USING (product_id) JOIN supplier s ON s.supplier_id=p.supplier_id JOIN users u ON u.user_id=p.user_id JOIN user_group_measure_map ugmm USING (user_group) JOIN product_feature pf ON p.product_id=pf.product_id JOIN category_feature cf USING (category_feature_id) JOIN feature f USING (feature_id) JOIN vocabulary v USING (sid) WHERE v.langid=1 AND p.supplier_id IN (" . $supplier_id_list . ") AND ugmm.measure=" . &str_sqlize(UGMM) . " AND ej.date BETWEEN UNIX_TIMESTAMP(" . &str_sqlize(START_DATE) . ") AND UNIX_TIMESTAMP(" . END_DATE . ") AND f.feature_id IN (" . $feature_id_list . ") AND p.catid=" . $catid . " ORDER BY 2 DESC");
if ( scalar @$query_result ) {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
} else {
	print BOLD WHITE "[ ", BOLD RED, "No results", BOLD WHITE, " ]", RESET, "\n";
	exit;
}
################ Saving result ################################
my $workbook  = eval { Spreadsheet::WriteExcel->new(XLS_REPORT); };
if ( $@ ) {
	print BOLD RED "'" . __FILE__ . "' failed : can't write '" . XLS_REPORT . "'", RESET, "\n";
	exit;
}
$workbook->set_properties(
	title		=> 'Create a list with feature values',
	author		=> 'vadim@bintime.com',
	comments	=> 'Create the list with feature values that filled by our editors from the following features:
					- Processor model
					- Chipset
					- Graphic adapter
					- Memory slots
					- Networking features
					-> Just for notebooks of the following brands: ASUS, PackardBell, Sony, Apple
					-> And just for the last three months',
	subject		=> '1026845: Create a list with feature values',
	utf8		=> 1
);

# set columns format
my $format = $workbook->add_format();
$format->set_align('left');
$format->set_font('Lucida Sans');
$format->set_size('11');

my $columns = [
	{'User'		=> 15},
	{'Date'		=> 30},
	{'Brand'	=> 15},
	{'Category'	=> 15},
	{'Feature'	=> 30},
	{'Value'	=> 70}
];
my $result_cnt = scalar @$query_result;
my $current_result = 0;
my $part = 1;
my $ri = 1; # row index
my $out = &create_my_worksheet( $workbook, 'Journal', $part, $columns );

print BOLD WHITE "::Saving results ... [0]", RESET;

foreach my $row ( @$query_result ) {
	my $ci = 0; # column index
	foreach my $col ( @$row ) {
		$out->write_string( $ri, $ci, $row->[$ci], $format);
		$ci++
	}
	if ( ++$ri >= XLS_MAX_ROWS ) {
		$out = &create_my_worksheet( $workbook, 'Journal', ++$part, $columns );
		$ri = 1;
	}
	my $percent = sprintf( "%2d", ++$current_result * 100 / $result_cnt );
	print BOLD GREEN "\b\b\b$percent%", RESET;
}
print "\n";
$workbook->close();

print BOLD WHITE "::Gzipping results ... ", RESET;
my $xls = XLS_REPORT;
qx(gzip -f $xls);
my $attachment = $xls . '.gz';
if ( -e $attachment ) {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
} else {
	print BOLD WHITE "[ ", BOLD RED, "fail", BOLD WHITE, " ]", RESET, "\n";
	exit;
}

&send_mail( EMAIL_TO, EMAIL_FROM, EMAIL_SUBJ, $attachment);
exit;

################################################################################
sub create_my_worksheet {
	my ( $workbook, $name, $part, $columns ) = @_;
	my $out = $workbook->add_worksheet($name . ($part > 1 ? " part $part " : ""));
	my $format = $workbook->add_format();
	$format->set_align('left');
	$format->set_bold();
	$format->set_color('red');
	$format->set_font('Verdana');
	$format->set_size('12');
	my $col = 0;
	if ( ref $columns eq 'ARRAY' ) {
		foreach my $col_hash ( @$columns ) {
			next unless ref $col_hash eq 'HASH';
			foreach my $col_name ( keys %$col_hash ) {
				$out->write_string(0, $col, $col_name, $format);
				$out->set_column($col++, $col, $col_hash->{$col_name});
			}
		}
	}
	return $out;
}

sub send_mail {
	my ($to, $from, $subj, $att_file_name) = @_;
	open ATTACHMENT, '<', $att_file_name;
	binmode ATTACHMENT, ':bytes';
	my ( $file, $buffer );
	while( read( ATTACHMENT, $buffer, 4096 ) ){ $file .= $buffer }
	close ATTACHMENT;
	my $mail =	{
				'to'					=> $to,
				'from'					=> $from,
				'subject'				=> $subj,
				'default_encoding'		=> 'utf8',
				'html_body'				=> 'See attachcement!',
				'attachment_name'		=> $att_file_name,
				'attachment_cotent_type'=> 'application/x-gzip',
				'attachment_body'		=> $file
				};
	&complex_sendmail($mail);
	print BOLD WHITE "#-----\nFor detailed information - check your email box at <" . $to . ">", RESET, "\n";
}

#!/usr/bin/perl
# @author <vadim@bintime.com>
use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Spreadsheet::WriteExcel;
use lib "/home/pim/lib";
use atomsql;
use atom_mail;

use constant XLS_REPORT		=> 'MSI_ICEcat_products.xls';
use constant XLS_MAX_ROWS	=> 65536;
use constant SUPPLIER		=> 'MSI';
use constant YEAR			=> 2010;
use constant EMAIL_TO		=> 'alexandr_kr@icecat.biz,blackchval@gmail.com';
use constant EMAIL_FROM		=> 'info@icecat.biz';
use constant EMAIL_SUBJ		=> "Create a list of the described products MSI";

my $workbook  = eval { Spreadsheet::WriteExcel->new(XLS_REPORT); };
if ( $@ ) {
	print BOLD RED "'" . __FILE__ . "' failed : can't write '" . XLS_REPORT . "'", RESET, "\n";
	exit;
}
$workbook->set_properties(
	title		=> 'MSI products export',
	author		=> 'vadim@bintime.com',
	comments	=> 'List of the described by ICEcat editors products of vendor - MSI',
	subject		=> 'Create a list of the described products MSI',
	utf8		=> 1
);
# set columns format
my $format = $workbook->add_format();
$format->set_align('left');
$format->set_font('Lucida Sans');
$format->set_size('11');

print BOLD WHITE "::Detecting " . SUPPLIER . " id ... ", RESET;
my $supplier_id = &do_query("SELECT supplier_id FROM supplier WHERE name=" . &str_sqlize(SUPPLIER))->[0]->[0];
if ( $supplier_id ) {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
} else {
	print BOLD WHITE "[ ", BOLD RED, "fail", BOLD WHITE, " ]", RESET, "\n";
	exit;
}

print BOLD WHITE "::Executing main query ... ", RESET;
my $query_result = &do_query("SELECT p.prod_id, p.name, v.value, u.login FROM editor_journal ej JOIN product p USING (product_id) JOIN users u ON u.user_id=p.user_id JOIN user_group_measure_map ugmm USING (user_group) JOIN product_family pf ON pf.family_id=p.family_id AND pf.supplier_id=p.supplier_id JOIN vocabulary v USING (sid) WHERE v.langid=1 AND YEAR(FROM_UNIXTIME(ej.date))=" . YEAR . " AND p.supplier_id=" . $supplier_id . " AND ugmm.measure='ICECAT' GROUP BY 1");
if ( scalar @$query_result ) {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
} else {
	print BOLD WHITE "[ ", BOLD RED, "fail", BOLD WHITE, " ]", RESET, "\n";
	exit;
}

my $columns = [
	{'Part number'	=> 40},
	{'Model name'	=> 40},
	{'Family'		=> 40},
	{'User'			=> 40}
];
my $result_cnt = scalar @$query_result;
my $current_result = 0;
my $part = 1;
my $ri = 1; # row index
my $out = &create_my_worksheet( $workbook, SUPPLIER . ' products', $part, $columns );

print BOLD WHITE "::Saving results ... [0]", RESET;

foreach my $row ( @$query_result ) {
	my $ci = 0; # column index
	foreach my $col ( @$row ) {
		$out->write_string( $ri, $ci, $row->[$ci], $format);
		$ci++
	}
	if ( ++$ri >= XLS_MAX_ROWS ) {
		$out = &create_my_worksheet( $workbook, SUPPLIER . ' products', ++$part, $columns );
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

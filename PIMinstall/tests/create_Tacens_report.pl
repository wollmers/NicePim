#!/usr/bin/perl

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Spreadsheet::WriteExcel;
use lib "/home/pim/lib";
use atomsql;
use atom_mail;
use icecat_util;

use constant XLS_REPORT		=> 'Tacens_ES_products.xls';
use constant XLS_MAX_ROWS	=> 65536;
use constant EMAIL_TO		=> 'blackchval@gmail.com';
use constant EMAIL_FROM		=> 'info@icecat.biz';
use constant EMAIL_SUBJ		=> "1027655: Create report with Tacens products";

print BOLD WHITE "::Executing main query ... ", RESET;
my $query_result = do_query("SELECT p.prod_id, 'stub' FROM product p JOIN supplier s USING(supplier_id) WHERE s.name='Tacens' AND p.user_id <> 1");
if ( scalar @$query_result ) {
	print BOLD WHITE "[ ", BOLD GREEN, "success", BOLD WHITE, " ]", RESET, "\n";
} 
else {
	print BOLD WHITE "[ ", BOLD RED, "No results", BOLD WHITE, " ]", RESET, "\n";
	exit;
}

foreach ( @$query_result ) {
	my $prod_id = $_->[0];
	$prod_id = encode_url($prod_id);
	my $url = 'http://icecat.es/ES/p/Tacens/' . $prod_id . '/desc.htm';
	$_->[1] = $url;
}

################ Saving result ################################
my $workbook  = eval { Spreadsheet::WriteExcel->new(XLS_REPORT); };
if ( $@ ) {
	print BOLD RED "'" . __FILE__ . "' failed : can't write '" . XLS_REPORT . "'", RESET, "\n";
	exit;
}
$workbook->set_properties(
	title		=> 'Create report with Tacens products',
	author		=> 'vadim@bintime.com',
	comments	=> "Please create the list with MPN's of described Tacens products + link to spanish datasheet for each product in FO",
	subject		=> '1027655: Create report with Tacens products',
	utf8		=> 1
);

# set columns format
my $format = $workbook->add_format();
$format->set_align('left');
$format->set_font('Lucida Sans');
$format->set_size('11');

my $columns = [
	{'MPN'		=> 25},
	{'ES link'		=> 90}
];
my $result_cnt = scalar @$query_result;
my $current_result = 0;
my $part = 1;
my $ri = 1; # row index
my $out = &create_my_worksheet( $workbook, 'Tacens products', $part, $columns );

print BOLD WHITE "::Saving results ... [0]", RESET;

for my $row ( @$query_result ) {
	my $ci = 0; # column index
	foreach my $col ( @$row ) {
		$out->write_string( $ri, $ci, $row->[$ci], $format);
		$ci++
	}
	if ( ++$ri >= XLS_MAX_ROWS ) {
		$out = create_my_worksheet( $workbook, 'Tacens products', ++$part, $columns );
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
} 
else {
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
		for my $col_hash ( @$columns ) {
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
	complex_sendmail($mail);
	print BOLD WHITE "#-----\nFor detailed information - check your email box at <" . $to . ">", RESET, "\n";
}

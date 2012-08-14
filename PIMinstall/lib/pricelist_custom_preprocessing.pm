package pricelist_custom_preprocessing;

#$Id: pricelist_custom_preprocessing.pm 2462 2010-04-21 16:27:09Z alexey $

use strict;

use atomcfg;
use atomlog;
use atomsql;

#use Data::Dumper;

use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw(
&custom_preprocessing_TDPL
&custom_preprocessing_MSAN
&custom_preprocessing_Ingram_Micro_MX

&custom_postprocessing_Ingram_Micro_Europe_
);

BEGIN {}

sub custom_preprocessing_Ingram_Micro_MX {
	my ($file,$is_preview) = @_;
	log_printf("Starting custom_preprocessing_Ingram_Micro_MX");
	if(!$is_preview){
		my $cmd = "/usr/bin/funzip ".$file.".ZIP > ".$file.".old";
		log_printf($cmd);
		`$cmd`;
	
		$cmd = "/bin/rm -f ".$file.".ZIP";
		log_printf($cmd);
		`$cmd`;
	open HEADER, ">$file.header";
	binmode HEADER, ":utf8";
	print HEADER '"Action Indicator","Ingram PartNbr","Vendor Nbr","Vendor Name","Description 1","Description 2","Retail Price","Weight","UPC CODE","Length","Width","Height","Price Change Flag","Customer Price","Special Price Flag","Availability Flag","Par Status","CPU CODE","Media Type","Category","Substitute Part","Replacement Cost","Warranty","Item Status","Promo","Instant Rebate Flag","Rebate Start Date","Rebate End Date","Rebate Amount","Special Start Date","Vendor PartNbr"'."\n";
	close HEADER;

	`cat $file.header $file.old > $file`;
	`rm $file.header $file.old`;
	}else{
		open HEADER, ">$file.header";
		binmode HEADER, ":utf8";
		print HEADER '"Action Indicator","Ingram PartNbr","Vendor Nbr","Vendor Name","Description 1","Description 2","Retail Price","Weight","UPC CODE","Length","Width","Height","Price Change Flag","Customer Price","Special Price Flag","Availability Flag","Par Status","CPU CODE","Media Type","Category","Substitute Part","Replacement Cost","Warranty","Item Status","Promo","Instant Rebate Flag","Rebate Start Date","Rebate End Date","Rebate Amount","Special Start Date","Vendor PartNbr"'."\n";
		close HEADER;
		`mv $file $file.tmp`;
		`cat $file.header $file.tmp > $file`;
		`rm $file.header`;
		`rm $file.tmp`;
	}

	log_printf("custom_preprocessing_Ingram_MicroMX ended.");
} # sub custom_preprocessing_Ingram_Micro_MX

sub custom_preprocessing_TDPL {
	my ($file,$is_preview) = @_;
	if(!$is_preview){
		log_printf("Starting custom_preprocessing_TDPL");
	
		my $cmd = "/usr/bin/funzip ".$file.".zip > ".$file;
		log_printf($cmd);
		`$cmd`;
		$cmd = "/bin/rm -f ".$file.".zip";
		log_printf($cmd);
		`$cmd`;
	
		log_printf("custom_preprocessing_TDPL ended.");
	}
} # sub custom_preprocessing_TDPL

sub custom_preprocessing_MSAN {
	my ($file,$is_preview) = @_;
	log_printf("Starting custom_preprocessing_MSAN: ".$file);

	# XLS to CSV

	use Spreadsheet::ParseExcel::Simple;

	my $xls = Spreadsheet::ParseExcel::Simple->read($file);
	my @data;
	my $firstRow = 1;
	my $ValueId = -1;

	open F, ">".$file;
	binmode F, ":utf8";
  for my $sheet ($xls->sheets) {
		while ($sheet->has_data) {  
			# get
			@data = $sheet->next_row;

			# fiter
			$#data = 9; # truncate all other elements
			$data[1] =~ s/^'//s; # filter 1, 5 and 7 elements
			$data[5] =~ s/^'//s;
			$data[7] =~ s/^'//s;

			# deternmine the Value field (first row)
			if ($firstRow) {
				for (0 .. @data) {
					if ($data[$_] eq 'Value') {
						$ValueId = $_;
						last;
					}
				}
			}

			# add new row (if we found the Value column)
			if ($ValueId != -1) {
				if ($firstRow) {
					push @data, 'Value.Stock';
					$data[$ValueId] = 'Value.Price';
				}
				else {
					push @data, $data[$ValueId] eq '0' ? '0' : '1';
					$data[$ValueId] =~ s/,/./gs;
				}
			}

			# print it
			print F join '|', @data;
			print F "\n";

			# disable first row indicator
			$firstRow = 0;
		}
		last;
	}
	close F;

	log_printf("custom_preprocessing_MSAN ended.");
} # sub custom_preprocessing_MSAN

sub custom_postprocessing_Ingram_Micro_Europe_ {
	my ($file,$is_preview) = @_;
	log_printf("Starting custom_postprocessing_Ingram_Micro_Europe");

	my $h_stock = { 'N'=>7, 'A'=>5, 'B'=>3, 'C'=>1, 'H'=>1, 'P'=>1, 'R'=>1, 'S'=>1, 'W'=>1, 'E'=>0, 'F'=>0, 'I'=>0, 'K'=>0, 'Q'=>0, 'V'=>0, 'X'=>0 };

	my $out = $file.".new";

	open F, "<".$file;
	binmode F, ":utf8";

	open F2, ">".$out;
	binmode F2, ":utf8";

	my $is_header = 1;
	my $choose_column = 0;
	my $skip_row;
	my @r;

	while (<F>) {
		$skip_row = 0;
		s/\n$//s;
#		log_printf("row: " . $_);
		@r = split(/~~/);
#		log_printf(Dumper(\@r));
		if ($is_header) {
			for (my $i=0; $i<=$#r; $i++) {
#				log_printf($r[$i]);
				if ($r[$i] eq 'ClassCd') {
					$choose_column = $i;
#					log_printf("chosen column is: ".$choose_column);
					last;
				}
			}
			# now, $choose_column contains the ClassCd column order number
		}
		
		for (my $i=0; $i<=$#r; $i++) {
			if ($i == $choose_column) {
				if ($is_header) {
					$r[$i] = 'ClassCd.Stock';
				}
				else {
#					log_printf("ClassCd is: " . $r[$i]);
					$r[$i] = defined $h_stock->{$r[$i]} ? $h_stock->{$r[$i]} : '';
				}
				if ($r[$i] eq '') {
					$skip_row = 1;
					last;
				}
			}
			else {
				# do nothing
			}
		}

		next if $skip_row;

		print F2 join "~~", @r;
		print F2 "\n";

		$is_header = 0;
	}

	close F2;
	close F;

	`/bin/mv -f $out $file`;

	log_printf("custom_postprocessing_Ingram_Micro_Europe ended.");
} # sub custom_postprocessing_Ingram_Micro_Europe

##########################################################################################

END {}

1;

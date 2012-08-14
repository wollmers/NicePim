package price_request;

use strict;

use atomlog;
use atomsql;
use atomlog;
use atom_util;
use atom_html;
use atom_misc;
use atom_params;
use atom_format;
use atom_store;
use atom_validate;
#use atom_cust;
use atom_commands;
use atomcfg;
use atom_mail;

use coverage_report;
use Spreadsheet::WriteExcel::Big;
use String::Escape qw( printable unprintable );
use Data::Dumper;

BEGIN{
	use Exporter ();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
	@EXPORT = qw( &generate_price_report
		      &generate_price_prew
		      &generate_price_save
		      &make_efile
                    );

}

#################### main sub to generate report ############################################################

sub generate_price_report {
	my $base_data = get_base_data();

#	log_printf('base data: '.Dumper($base_data));
	log_printf('file for parsing: '.$hin{'fn'});

	my $distri = $hin{'d_code'} if($hin{'d_code'});
	$distri = $hin{'distri_code'} if($hin{'distri_code'});
	my $fn = $hin{'fn'};
	my $done = make_efile($fn,$base_data);
#	`/bin/rm -f $fn`;

	return report_products($fn.'_parsed_pricelist.csv', $distri);
}

############################### saving settings for current distri ########################################

sub generate_price_save {
	if ($hin{'distri_code'}) { # choose distributor & d_code using distri_code value - Sergey Karmalita's BIG bug was here - fixed by DV (10.09.2009)
		my $restore_distri_datas = do_query("select code, name from distributor_pl where code = ".str_sqlize($hin{'distri_code'}))->[0];
		$hin{'distributor'} = $restore_distri_datas->[1];
		$hin{'d_code'} = $restore_distri_datas->[0];
	}
	
	return "<h3 color='red'>Error! Please type distributor to appropriate fields!</h3>" unless($hin{'distributor'} && $hin{'d_code'});
	return "<h3 color='red'>Error! At least Part number must be selected!</h2>" unless($hin{'prod_id'} || $hin{'ean'});
	
	my $base_data = get_base_data();

	#log_printf('base data: '.Dumper(\%base_data));
#	$base_data->{'delimeter'} = quotemeta($base_data->{'delimeter'});
#	$base_data->{'row_delimeter'} = quotemeta($base_data->{'row_delimeter'});

	my $settings = "";
	$settings = "delimeter:".$base_data->{'delimeter'}."\n"."row_delimeter:".$base_data->{'row_delimeter'}."\n" if($base_data->{'delimeter'} && $base_data->{'row_delimeter'});
	$settings = "delimeter:".$base_data->{'own_delimeter'}."\n"."row_delimeter:".$base_data->{'row_delimeter'}."\n" if($base_data->{'delimeter'} eq "own" && $base_data->{'row_delimeter'});
	$settings .= "first_row_as_header:".$base_data->{'first_row_as_header'};
	$settings .= "\n"."pl_login:".$base_data->{'pl_login'} if($base_data->{'pl_login'});
	$settings .= "\n"."pl_pass:".$base_data->{'pl_pass'} if($base_data->{'pl_pass'});
	$settings .= "\n"."esc_c:".$base_data->{'esc_c'} if($base_data->{'esc_c'});
	$settings .= "\n"."prodlevid:".$base_data->{'prodlevid'} if($base_data->{'prodlevid'});
	$settings .= "\n"."prod_id:".$base_data->{'prod_id'} if($base_data->{'prod_id'});
	$settings .= "\n"."supplier:".$base_data->{'supplier'} if($base_data->{'supplier'});
	$settings .= "\n"."euprice:".$base_data->{'euprice'} if($base_data->{'euprice'});
	$settings .= "\n"."stock:".$base_data->{'stock'} if($base_data->{'stock'});
	$settings .= "\n"."euprice_incl_vat:".$base_data->{'euprice_incl_vat'} if($base_data->{'euprice_incl_vat'});
	$settings .= "\n"."ean:".$base_data->{'ean'} if($base_data->{'ean'});
	$settings .= "\n"."category:".$base_data->{'category'} if($base_data->{'category'});
	$settings .= "\n"."image:".$base_data->{'image'} if($base_data->{'image'});
	$settings .= "\n"."name:".$base_data->{'name'} if($base_data->{'name'});
	$settings .= "\n"."description:".$base_data->{'description'} if($base_data->{'description'});
	$settings .= "\n"."xml_path:".$base_data->{'xml_path'} if($base_data->{'xml_path'});
	# add more settings - country_postfix
	$settings .= "\n"."country_postfix:".$base_data->{'country_postfix'} if($base_data->{'country_postfix'});

	my $act = ($base_data->{'active'} eq '1') ? 1 : 0;

	do_statement("replace into distributor_pl set code=".str_sqlize($base_data->{'d_code'}).", name=".str_sqlize($base_data->{'distributor'}).", pl_format=".str_sqlize($base_data->{'pl_format'}).", pl_settings=".str_sqlize($settings).", pl_url=".str_sqlize($base_data->{'pl_url'}).", langid=".$base_data->{'langid'}.", active=".$act);

	my $ret = do_query("select name, code, pl_url, pl_format, pl_settings, active from distributor_pl where code=".str_sqlize($base_data->{'d_code'})." limit 1")->[0];
	my $tbl = '<b>Such settings has been saved:</b><br>
			<table class="tbl-block" border="0" cellpadding="3">
			<th class="th-dark">Distributor</th><th class="th-norm">Code</th><th class="th-dark">Pricelist url</th><th class="th-norm">Format</th><th class="th-dark">Pricelist settings</th><th class="th-norm">Is active</th>';

	$ret->[4] =~ s/(\n)|(\r)/<br>/gs;
	$ret->[4] =~ s/\t/\\t/gs;
	$ret->[4] =~ s/:<br><br>/:\\n\\r/;
	$ret->[4] =~ s/:<br>/:\\n/;

	$tbl .= '<tr><td class="td-dark">'.$ret->[0].'</td><td class="td-norm">'.$ret->[1].'</td><td class="td-dark">'.$ret->[2].'</td><td class="td-norm">'.$ret->[3].'</td><td class="td-dark">'.$ret->[4].'</td><td class="td-norm">'.$ret->[5].'</td></tr></table>';

	return $tbl;
}

############################# base data needed for report and saving settings ############################

sub get_base_data {
	my $base_data;
	$base_data->{'langid'} = $hin{'langid'} if($hin{'langid'});
	$base_data->{'d_code'} = $hin{'d_code'} if($hin{'d_code'});
	$base_data->{'distributor'} = $hin{'distributor'} if($hin{'distributor'});
	$base_data->{'pl_format'} = $hin{'pl_format'} if($hin{'pl_format'});
	$base_data->{'first_row_as_header'} = $hin{'first_row_as_header'} if($hin{'first_row_as_header'});
	$base_data->{'row_delimeter'} = $hin{'row_delimeter'} if($hin{'row_delimeter'});
	$base_data->{'delimeter'} = $hin{'delimeter'} if($hin{'delimeter'});
	$base_data->{'prodlevid'} = $hin{'prodlevid'} if($hin{'prodlevid'});
	$base_data->{'prod_id'} = $hin{'prod_id'} if($hin{'prod_id'});
	$base_data->{'supplier'} = $hin{'supplier'} if($hin{'supplier'});
	$base_data->{'euprice'} = $hin{'euprice'} if($hin{'euprice'});
	$base_data->{'stock'} = $hin{'stock'} if($hin{'stock'});
	$base_data->{'euprice_incl_vat'} = $hin{'euprice_incl_vat'} if($hin{'euprice_incl_vat'});
	$base_data->{'ean'} = $hin{'ean'} if($hin{'ean'});
	$base_data->{'category'} = $hin{'category'} if($hin{'category'});
	$base_data->{'image'} = $hin{'picture'} if($hin{'picture'});
	$base_data->{'name'} = $hin{'name'} if($hin{'name'});
	$base_data->{'description'} = $hin{'description'} if($hin{'description'});
	$base_data->{'xml_path'} = $hin{'xml_path'} if($hin{'xml_path'});
	$base_data->{'country_postfix'} = $hin{'country_postfix'} if($hin{'country_postfix'});
	$base_data->{'pl_url'} = $hin{'pl_url'} if($hin{'pl_url'});
	$base_data->{'file'} = $hin{'fn'} if($hin{'fn'});
	$base_data->{'own_delimeter'} = $hin{'own_delimeter'}  if($hin{'own_delimeter'});
	$base_data->{'active'} = $hin{'active'} if($hin{'active'});
	$base_data->{'distri_code'} = $hin{'distri_code'} if($hin{'distri_code'});
	$base_data->{'esc_c'} = $hin{'esc_c'} if($hin{'esc_c'});
	$base_data->{'pl_login'} = $hin{'pl_login'} if($hin{'pl_login'});
	$base_data->{'pl_pass'} = $hin{'pl_pass'} if($hin{'pl_pass'});
	
	return $base_data;
}

########################## generating preview for price ####################################################

sub generate_price_prew {

	use pricelist;
	
	my ($price,$prew,$head,$options,$preview,$fn,$adt);
	
	my $fields = { 'prodlevid' => 'Distributor part no (product code)',
								 'prod_id' => 'Manufacturer part no (product code)<font color="red">*</font>',
								 'supplier' => 'Manufacturer brand name<font color="red">*</font>',
								 'euprice' => 'Price excl. VAT',
								 'euprice_incl_vat' => 'Price incl. VAT<font color="red">*</font>',
								 'stock' => 'Stock quantity (numerical)',
								 'ean' => 'EAN/UPC code (only needed if Brand + Partno are absent)<font id="ean_upc_" color="red">*</font>',
								 'category' => 'Category',
								 'name' => 'Product name',
								 'description' => 'Product description',
								 'picture' => 'Product image',
								 'country_postfix' => 'Country <font color="green">(disrtibutor distinguish postfix)</font>',
	};
	
	$adt = '';

  if (($hin{'pl_url'} && !$hin{'distri_code'}) || $hin{'file_name'}) {
		log_printf("pl_url or file_name");
#		$fn = $hin{'pl_url'};
#		$fn =~ s#.*//([^/]*?)/.*#$1#i unless($fn =~ s#.*//[^\.]*?\.([^/]*?)/.*#$1#i || s/.*/$hin{'pl_url'}/i);
#		$fn =~ s/[\?\:\@]//gs;
#	download_pricelist($hin{'pl_url'}, '../tmp/'.$fn);
		$price = parse_price_list(refine_url4path($hin{'pl_url'}),$hin{'d_code'});

		return "<h4>1 Error! File not found!</h4>" if($price eq "not found!");

		$prew = $price->{'preview'};
		$head = $price->{'header'};
		$options = $price->{'settings'};
		$fn = $price->{'file'};
		$hin{'file'} = $fn;
		$adt = display_xml($options) if($options->{'pl_format'} eq 'xml');
		$adt = display_csv($options) if($options->{'pl_format'} eq 'csv');
		$adt = display_xls($options) if($options->{'pl_format'} eq 'xls');
  }
	elsif ($hin{'distri_code'}) {
		my $d_id = $hin{'distri_code'};
		log_printf("getting pricelist with saved settings code=".$d_id);
		$price = parse_price_list(undef, $d_id);

		return "<h4>2 Error! File not found!</h4>" if($price eq "not found!");

		$prew = $price->{'preview'};
		$head = $price->{'header'};
		$options = $price->{'settings'};
		$hin{'langid'} = $options->{'langid'};
		$hin{'active'} = $options->{'active'};
#	log_printf("options:".Dumper($options));
		$fn = $price->{'file'};
		$hin{'file'} = $fn;
		$adt = display_xml($options) if($options->{'pl_format'} eq 'xml');
		$adt = display_csv($options) if($options->{'pl_format'} eq 'csv');
		$adt = display_xls($options) if($options->{'pl_format'} eq 'xls');
  }
	else {
		log_printf("else");
  	$options = get_default_options();
		$adt = display_csv();
  }
	
#log_printf("options:".Dumper($options));
#log_printf("addition:".$adt);
  my $cnt = 0;
  $preview = $adt."\n".'<table class="tbl-block" cellpadding="3">';
  for my $row (keys %$fields) {

		# Dirty fix by DV (10.02.2009)!..
		$options->{$row} =~ s/^.*?(<.*$)/$1/s;

		$preview .= '<tr style="display: none" id="setting'.$cnt.'">
                        <td style="font-size: 100%; text-align:right;">'.$fields->{$row}.'</td>
                        <td style="font-size: 100%; text-align:left;"><select name="'.$row.'" id="'.$row.'">
                        '.$options->{$row}.'</select>
                        </td>
                </tr>';
		$cnt++;
  }
	$preview .= '</table>';
	
#log_printf("prew:".Dumper($prew));
  if ($prew && !$hin{'is_analyzis'}) {
		my $i=0;
		my @hels = keys %$prew;
#log_printf(Dumper( \@hels ));
		my $tmp_arr = $prew->{$hels[2]};
#log_printf(Dumper($tmp_arr));
		$preview .= '<div style="width:100%;height:150px;overflow:auto;align:center;">
                                    <table class="tbl-block" border="0" celpadding="3"><tr>';
		my $chet = 2;
		my $class;
		for my $hdr (@hels) {
			unless ($chet % 2) {
				$class = 'class="th-dark"';
			}
			else {
				$class = 'class="th-norm"';
			}
			$preview .= '<td align="center" '.$class.'><b>'.$hdr.'</b></td>';
			$chet++;
		}
		$preview .= '</tr>';
		for (@$tmp_arr) {
			$preview .= '<tr>';
			$chet = 2;
			for my $pcol (@hels) {
				unless ($chet % 2) {
					$class = 'class="td-dark"';
				}
				else {
					$class = 'class="td-norm"';
				}
				$preview .= '<td align="center" '.$class.'>'.$prew->{$pcol}->[$i].'</td>';
				$chet++;
			}
			$preview .= '</tr>';
			$i++;	
		}
		$preview .= '</table></div>';
  }
	elsif ($hin{'is_analyzis'}) {
  	$preview .= '<div style="width:100%;height:300px;overflow:auto;align:center;">'.generate_price_report().'</div>';
		if ($hin{'mail_rep'}) {
			do_statement("drop temporary table if exists tmp_mail_rep");
			do_statement("create temporary table tmp_mail_rep(
				product_id int(13) not null default '0',
				prod_id varchar(36) not null default '',
				supplier varchar(255) not null,
				quality varchar(50) not null default 'NOEDITOR',
				user char(40) not null default '',
				name varchar(255) not null default '')");
			
			do_statement("insert into tmp_mail_rep (product_id, prod_id, supplier, quality, user, name) select tp.product_id,tp.prod_id,if(s.name,s.name,tp.supplier),ugmm.measure,u.login,if(p.name,p.name,tp.name) 
				from tmp_pl_products tp
				left join product p using (product_id)
				left join users u on p.user_id = u.user_id
				left join user_group_measure_map ugmm on u.user_group=ugmm.user_group
				left join supplier s on s.supplier_id = p.supplier_id order by tp.product_id desc");
			
			my $mail_rep = do_query("select product_id, prod_id, supplier, quality, user, name from tmp_mail_rep");
			
			my $file  = 'pricelist_products_detailed_report.xls';
			my $workbook  = Spreadsheet::WriteExcel::Big->new("/tmp/".$file) or die("cannot create xls file\n");
			my $format = $workbook->add_format(); # Add a format
			$format->set_bold();
			$format->set_align('center');
			$format->set_text_wrap();
			
			my $worksheet;
			
			$worksheet = $workbook->add_worksheet();
			$worksheet->set_column('A:E', 20);
			$worksheet->set_column('F:F', 50);
			$worksheet->write(0, 0, 'Product id', $format);
			$worksheet->write(0, 1, 'Part number', $format);
			$worksheet->write(0, 2, 'Supplier', $format);
			$worksheet->write(0, 3, 'Quality', $format);
			$worksheet->write(0, 4, 'User', $format);
			$worksheet->write(0, 5, 'Model name', $format);
			my $row = 1;
			for my $data (@$mail_rep) {
				my $col;
				for ($col=0; $col<6;$col++) {
					$worksheet->write($row, $col, $data->[$col]);
				}
				$row++;
			}
			$workbook->close();
			
			my $cmd = "cd /tmp/ && /usr/bin/zip -r ".$file.".zip ".$file;
			`$cmd`;
			log_printf($cmd);
			open(ZIP, "< /tmp/".$file.".zip");
			binmode(ZIP,":bytes");
			my $zip = join('', <ZIP>);
			close ZIP;
			my $cmd = "/bin/rm -f /tmp/".$file.".zip && /bin/rm -f /tmp/".$file;
			`$cmd`;
			log_printf($cmd);
			
			my $email = $hin{'mail_rep'};
			$email =~ s/^\s*|\s*$//gs;
			my $mail = {
				'to' => $email,
				'from' =>  $atomcfg{'mail_from'},
				'subject' => "Detailed report of products in pricelist",
				'text_body' => "Information about every found product (see in attachment).",
				'attachment_name' => "products_detailed_report.zip",
				'attachment_content_type' => 'application/zip',
				'attachment_body' => $zip
			};
			
			complex_sendmail($mail);
		}
  }
	
#			log_printf(Dumper($preview));
	$preview .= '<input type=hidden id="fn" name="fn" value="'.$fn.'">
		</form>
		<script type="text/javascript">sel_distributor(); is_auth(); chose_url_format(); hide_settings();document.getElementById("is_analyzis").value = "";
		</script>';
#	generate_price_report($fn) if($hin{'submit'} eq 'Analize');

	return $preview;
}

sub display_xls {
	my ($settings) = @_;
	log_printf("xls block");
	my $html='';
	open PLT, "<".$atomcfg{'templates_path'}."english/price_reports_format.html" or die "Template was not found: $!";
	while(<PLT>){
		s/%%select_format_csv%%//gs;
		s/%%select_format_xml%%//gs;
		s/%%select_format_xls%%/selected/gs;
		s/%%first_row_csv_checked%%//gs;
		s/%%row_n%%//gs;
		s/%%row_nr%%//gs;
		s/%%xml_path%%//gs;
		s/%%auth_checked%%/checked/gs if($settings->{'pl_login'});
		if($settings->{'first_row_as_header'}){
			s/%%first_row_xls_checked%%/checked/gs;
		}else{
			s/%%first_row_xls_checked%%//gs;
		}
		
		$html .= $_;
	}
	close PLT;
	return $html;
}

sub display_xml {
	my ($settings) = @_;

	log_printf('xml block');
	my $html = '';
	open PLT, "<".$atomcfg{'templates_path'}."english/price_reports_format.html" or die "Template was not found: $!";
	while(<PLT>){
		s/%%select_format_csv%%//gs;
		s/%%select_format_xml%%/selected/gs;
		s/%%select_format_xls%%//gs;
		s/%%first_row_csv_checked%%//gs;
		s/%%row_n%%//gs;
		s/%%row_nr%%//gs;
		s/%%auth_checked%%/checked/gs if($settings->{'pl_login'});
		if($settings->{'xml_path'}){
			s/%%xml_path%%/$settings->{'xml_path'}/gs;
		}else{
			s/%%xml_path%%//gs;
		}
		s/%%first_row_xls_checked%%//gs;
		$html .= $_;
	}
	close PLT;
	return $html;
}

sub display_csv {
	my ($settings) = @_;

#	log_printf(Dumper($settings));

	log_printf('csv block');
	my $html = '';

	open PLT, "<".$atomcfg{'templates_path'}."english/price_reports_format.html" or die "Template was not found: $!";
	while (<PLT>) {
		s/%%select_format_csv%%/selected/gs;
		s/%%select_format_xml%%//gs;
		s/%%select_format_xls%%//gs;
		s/%%auth_checked%%/checked/gs if ($settings->{'pl_login'});
		if ($settings->{'first_row_as_header'}) {
			s/%%first_row_csv_checked%%/checked/gs;
		}
		else {
			s/%%first_row_csv_checked%%//gs;
		}
		if ($settings->{'row_delimeter'} eq "\\n") {
			s/%%row_n%%/selected/gs;
			s/%%row_nr%%//gs;
		}
		elsif ($settings->{'row_delimeter'} eq "\\r\\n") {
			s/%%row_n%%//gs;
			s/%%row_nr%%/selected/gs;
		}
		else {
			s/%%row_n%%//gs;
			s/%%row_nr%%//gs;
		}
		s/%%xml_path%%//gs;
		s/%%first_row_xls_checked%%//gs;
		$html .= $_;
	}

	if ($settings->{'delimeter'}) {
		$html .= "<script type='text/javascript'>
<!--
				if (document.getElementById('".quotemeta($settings->{'delimeter'})."')) {
					document.getElementById('".quotemeta($settings->{'delimeter'})."').checked = true;
				}
        else {
					document.getElementById('own_del').checked = true;
					document.getElementById('own_delimeter').value = '".quotemeta($settings->{'delimeter'})."'; 
				}\n";
		$html .= "document.getElementById('esc_c').value = '".$settings->{'esc_c'}."';" if ($settings->{'esc_c'});
		$html .= "// -->
</script>";
	}

	close PLT;

#	log_printf($html);

	return $html;
}

sub make_efile {
	my ($file,$set) = @_;
	
	my $parsed;	
	
	if ($set->{'pl_format'} eq 'csv') {
		#$parsed = load_csv($set, $file);
		my $tmp=$file.'_parsed_pricelist.csv';
		`cp $file $tmp`;
		return $file;
		
	}
	elsif ($set->{'pl_format'} eq 'xls') {
		$parsed = load_xls($set, $file);
	}
	elsif ($set->{'pl_format'} eq 'xml') {
		$parsed = load_xml($set, $file);
	}

	log_printf(Dumper("Parsed: ".$parsed));
	
	return $parsed;
}

################### if price is in .xml format ###############################################################
sub load_xml {
  my ($options,$path) = @_;
  use icecat_util;
  my $result=xml2csv($path,($path.'_parsed_pricelist.csv'),30);
  if($result){
	`rm -r $path`;
	$path.='.csv';
  }
  return $path;
}

################################# if price is in .xls format #####################################################
sub load_xls {
  my ($options,$path)=@_;

  use Spreadsheet::ParseExcel;

  log_printf("Format is xls, so lets load $path into our file");

  my $oExcel = new Spreadsheet::ParseExcel;
  my $oBook  = $oExcel->Parse($path);
  my ($R, $C, $Sheet,$WC);
  my $csv='';
  my $cols=0;
  my $bool=0;
  my $temp=[];
	
	if (!($options->{'prod_id'} =~/Column/)) {
		my $sh = $oBook->{Worksheet}[0];
		for my $opt (keys %$options) {
			for (my $c = $sh->{MinCol}; defined $sh->{MaxCol} && $c <= $sh->{MaxCol}; $c++) {
				my $shv = $sh->{Cells}[0][$c];
				next if !$shv;
        $shv = $shv->Value;
				my $t = chr(65+$c);
				$options->{$opt} = "Column $t" if $shv eq $options->{$opt};
			}
		}
	}
  my $count = 0;
	my $new_path = $path.'_parsed_pricelist.csv';
	`/bin/rm -f $new_path`;
	open (PRICE, ">".$new_path) or die "cannot open new file!:$!";
  for (my $iSheet = 0; $iSheet < $oBook->{SheetCount}; $iSheet++) {
		my $SheetName = $oBook->{Worksheet}[$iSheet];
		for (my $R = $SheetName->{MinRow}; defined $SheetName->{MaxRow} && $R <= $SheetName->{MaxRow};$R++) {
			my %hash;
			for (my $C = $SheetName->{MinCol}; defined $SheetName->{MaxCol} && $C <= $SheetName->{MaxCol};$C++) {
				$Sheet = $SheetName->{Cells}[$R][$C];
				$Sheet = $Sheet->Value if $Sheet;
				if ($Sheet) {
					
					$hash{'prodlevid'}   = $Sheet if $options->{'prodlevid'}==($C+1) and ($options->{'prodlevid'}*1);
					$hash{'prod_id'}     = $Sheet if $options->{'prod_id'}==($C+1) and ($options->{'prod_id'}*1);
					$hash{'supplier'}    = $Sheet if $options->{'supplier'}==($C+1) and ($options->{'supplier'}*1);
					$hash{'category'}    = $Sheet if $options->{'category'}==($C+1) and ($options->{'category'}*1);
					$hash{'name'}        = $Sheet if $options->{'name'}==($C+1) and ($options->{'name'}*1);
					$hash{'description'} = $Sheet if $options->{'description'}==($C+1) and ($options->{'description'}*1);
					$hash{'euprice'}     = $Sheet if $options->{'euprice'}==($C+1) and ($options->{'euprice'}*1);
			   $hash{'euprice_incl_vat'} = $Sheet if $options->{'euprice_incl_vat'}==($C+1) and ($options->{'euprice_incl_vat'}*1);
					#$hash{'stock'} = ( $options->{'stock'}=~/ $t/ ) ? $Sheet."\t" : "0\t" ;
					$hash{'stock'}       = $Sheet if $options->{'stock'}==($C+1) and ($options->{'stock'}*1);
					$hash{'distributor'} = $options->{'distributor'};
					$hash{'image'}       = $Sheet if $options->{'image'}==($C+1) and ($options->{'image'}*1);
					$hash{'ean'}         = $Sheet if $options->{'ean'}==($C+1) and ($options->{'ean'}*1);
					
				}
			}
			print PRICE ($hash{'prodlevid'} || '')."\t";
			print PRICE ($hash{'prod_id'} || '')."\t";
			print PRICE ($hash{'supplier'} || '')."\t";
			print PRICE ($hash{'category'} || '99999999')."\t";
			print PRICE ($hash{'category'} || '99999999')."\t";
			print PRICE ($hash{'name'} || '')."\t";
			print PRICE ($hash{'description'} || '')."\t";
			print PRICE ($hash{'description'} || '')."\t";
			print PRICE ($hash{'euprice'} || '')."\t";
			#print PRICE (valid_import_price($hash{'euprice_incl_vat'}) || "0")."\t";
			print PRICE ($hash{'stock'} || '0')."\t";
			print PRICE ($hash{'distributor'} || '').(($hash{'country_postfix'})?'_'.$hash{'country_postfix'}:'')."\t";			
			print PRICE ($hash{'image'} || '')."\t";
			print PRICE ($hash{'ean'} || '');
			#print PRICE ($hash{'country_postfix'} || '');
			print PRICE "\n";
			$count++;
#		log_printf("content from xls: ".Dumper(%hash));
		}
  }
#  print PRICE "\nTOTAL COUNT $count\n";
  close PRICE;
  return $count;
}

############################### if price is in .csv format ############################################################
sub load_csv {
  my ($options, $path) = @_;

	return undef unless $path;

  log_printf("Format is csv, so let's load $path into our file");

  my $res = [];
		my $header = '';

	# to be able parse files with \r delimeter only
	my $buffer_file = $path.'_buffer';
	my $pattern = '\\\n';
	`cat $path | sed s/\\\r/$pattern/g  > $buffer_file && mv -f $buffer_file $path`;

	my $file_enc = `file -ib $path`;

	log_printf("FILE ENC: ".$file_enc);

	if ($file_enc !~ /charset=utf-8/) {
		`recode latin1..utf8 $path`;
	}

	# remove_empty_strings($path);
	open(PL, "<".$path) or die "cannot open $path file!:$!";
	my $j = 0;
	do {
		$j++;
		$header = <PL>;
	} until $j == 1 || eof;
	close(PL);

	$header =~ s/\r//gs;
  $header = '0' if $options->{'prod_id'}=~/ column/;
	
  my $line = 0;
  my $map = {};
	
  my $new_path = $path.'_parsed_pricelist.csv';
	`/bin/rm -f $new_path`;
  open (PRICE,">".$new_path) or die "cannot open new file!:$!";
	
  my $prodlevidi = $options->{'prodlevid'};
	$prodlevidi =~ s/(\d+)\s\w+/$1/gs;
	
  my $prod_idi = $options->{'prod_id'};
	$prod_idi =~ s/(\d+)\s\w+/$1/gs;
	
  my $eupricei = $options->{'euprice'};
	$eupricei =~ s/(\d+)\s\w+/$1/gs;
	
  my $euprice_incl_vati = $options->{'euprice_incl_vat'};
	$euprice_incl_vati =~ s/(\d+)\s\w+/$1/gs;
	
  my $stocki = $options->{'stock'};
	$stocki =~ s/(\d+)\s\w+/$1/gs;
	
  my $supplieri = $options->{'supplier'};
	$supplieri =~ s/(\d+)\s\w+/$1/gs;
	
	my $extri = $options->{extra};
	$extri =~ s/(\d+)\s\w+/$1/gs;
	
	my $eani = $options->{'ean'};
	$eani =~ s/(\d+)\s\w+/$1/gs;
	
	my $categoryi = $options->{'category'};
	$categoryi =~ s/(\d+)\s\w+/$1/gs;
	
	my $imagei = $options->{'image'};
	$imagei =~ s/(\d+)\s\w+/$1/gs;
	
	my $namei = $options->{'name'};
	$namei =~ s/(\d+)\s\w+/$1/gs;
	
	my $descriptioni  = $options->{'description'};
	$descriptioni  =~ s/(\d+)\s\w+/$1/gs;

	my $country_postfixi  = $options->{'country_postfix'};
	$country_postfixi  =~ s/(\d+)\s\w+/$1/gs;
	
	$options = validate_map_hash($options);
	
	open(PL, "<".$path) or die "cannot open $path file!:$!";

	my ($formed_distri, $cat_postfix);
	
	$options->{'delimeter'} = unprintable($options->{'delimeter'});
	$options->{'row_delimeter'} = unprintable($options->{'row_delimeter'});
	
	use Text::CSV;

	binmode PL, ":utf8";

	while (<PL>) {
		chomp;
		s/\n$//s;
		s/\r//gs;
		
		next unless $_;

		my @data;
		
		my $csv = Text::CSV->new({
			quote_char          => '"',
			escape_char         => $options->{'esc_c'},
			sep_char            => $options->{'delimeter'},
			eol                 => $options->{'row_delimeter'},
			always_quote        => 0,
			binary              => 1,
			keep_meta_info      => 0,
			allow_loose_quotes  => 1,
			allow_loose_escapes => 1,
			allow_whitespace    => 0,
			blank_is_undef      => 0,
			verbatim            => 0,
														 });
		my $status  = $csv->parse($_);
		my ($cde, $str, $pos) = $csv->error_diag();
#         log_printf('error diag:'.$str.' code:'.$cde.' at :'.$pos);
		@data = $csv->fields;
		#chomp $data[$#data];
		
#         if($options->{'delimeter'} eq '\t'){
#            $options->{'delimeter'} = "\t";
#            @data = split(/$options->{'delimeter'}/);
#	    log_printf("Data: ".Dumper(\@data));
#         }else{
#      @data = split(/\Q$options->{'delimeter'}\E/);
#         }
		
		my $par = qr(\"[\"]+\");

		for (@data) {
			$_=~s/^\"//gs;
			$_=~s/\"$//gs;
			$_=~s/^'//gs;
			$_=~s/'$//gs;
			$_=~s/^\s+//gs;
			$_=~s/\s+$//gs;
		}
		
		if ($line == 0 && $header ne '0') {
			my $j=0;
			for (@data) {
				$map->{$_}=$j;
				$j++;
			} 
			$line++;
			next;
		}
		
		$map = validate_map_hash($map);

#		log_printf("Map: ".Dumper($map));
		log_printf("Data: ".Dumper(\@data));
		
		if($header ne '0'){
#     if($data[$map->{$options->{'euprice_incl_vat'}}] =~ /\./g &&  $data[$map->{$options->{'euprice_incl_vat'}}] =~ /,/g){
#         $data[$map->{$options->{'euprice_incl_vat'}}] =~ s/\.//gs;
#     }
#           if($data[$map->{$options->{'euprice'}}] =~ /\./g &&  $data[$map->{$options->{'euprice'}}] =~ /,/g){
#              $data[$map->{$options->{'euprice'}}] =~ s/\.//gs;
#                 }
#
#                 $data[$map->{$options->{'euprice_incl_vat'}}]=~s/,/\./gs;
#     $data[$map->{$options->{'euprice'}}]=~s/,/\./gs;
			
			if($options->{'prodlevid'}){
        print PRICE $data[$map->{$options->{'prodlevid'}}]."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'prod_id'}){
        print PRICE $data[$map->{$options->{'prod_id'}}]."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'supplier'}){
        print PRICE $data[$map->{$options->{'supplier'}}]."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'category'}){
				print PRICE ($data[$map->{$options->{'category'}}] || '')."\t";
			}else{
				print PRICE "99999999\t";
			}
			
			if($options->{'category'}){
				print PRICE ($data[$map->{$options->{'category'}}] || '')."\t";
			}else{
				print PRICE "99999999\t";
			}
			
			if($options->{'name'}){
				print PRICE ($data[$map->{$options->{'name'}}] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'description'}){
				print PRICE ($data[$map->{$options->{'description'}}] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'euprice'}){
        print PRICE (valid_import_price($data[$map->{$options->{'euprice'}}]) || "0")."\t";
			}else{
				print PRICE "0\t";
			}
			if($options->{'euprice_incl_vat'}){
				print PRICE (valid_import_price($data[$map->{$options->{'euprice_incl_vat'}}]) || "0")."\t";
			}else{
				print PRICE "0\t";
			}
			
			if($options->{'stock'}){
        print PRICE $data[$map->{$options->{'stock'}}]."\t";
			}else{
				print PRICE "0\t";
			}
			
			# need to fix it a little bit (dima, 2009-10-06)
			if ($options->{'distributor'}) {

				$formed_distri = $options->{'distributor'};
				if ($options->{'country_postfix'}) {
					$cat_postfix = $data[$map->{$options->{'country_postfix'}}];
					$cat_postfix = uc($cat_postfix);
					$cat_postfix =~ s/\W//sg; # remove all bad symbols
					if ($options->{'distributor'} =~ /\*/) { # we have a wildcard
						$formed_distri =~ s/\*/($cat_postfix)/s; # replace 1 time
						$formed_distri =~ s/\*//sg; # all others * - replaced by ''
					}
					else {
						$formed_distri .= '_'.$cat_postfix;
					}
				}

				print PRICE $formed_distri."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'image'}){
				print PRICE ($data[$map->{$options->{'image'}}] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($options->{'ean'}){
				print PRICE ($data[$map->{$options->{'ean'}}] || '');
			}else{
				print PRICE "";
			}
			
		}else{
#     if($data[$eupricei-1] =~ /\./g && $data[$eupricei-1] =~ /,/g){
#                    $data[$eupricei-1] =~ s/\.//gs;
#                 }
#                 if($data[$euprice_incl_vati-1] =~ /\./g && $data[$euprice_incl_vati-1] =~ /,/g){
#                    $data[$euprice_incl_vati-1] =~ s/\.//gs;
#                 }
#
#     $data[$eupricei-1]          =~ s/,/\./gs;
#     $data[$euprice_incl_vati-1] =~ s/,/\./gs;
			
			if($prodlevidi){
		    print PRICE $data[$prodlevidi-1]."\t";
			}else{
		    print PRICE "\t";
			}
			
			if($prod_idi){
		    print PRICE $data[$prod_idi-1]."\t";
			}else{
		    print PRICE "\t";
			}
			
			if($supplieri){
		    print PRICE $data[$supplieri-1]."\t";
			}else{
		    print PRICE "\t";
			}
			
			if($categoryi){
				print PRICE ($data[$categoryi-1] || '')."\t";
			}else{
				print PRICE "99999999\t";
			}
			
			if($categoryi){
				print PRICE ($data[$categoryi-1] || '')."\t";
			}else{
				print PRICE "99999999\t";
			}
			
			if($namei){
				print PRICE ($data[$namei-1] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($descriptioni){
				print PRICE ($data[$descriptioni-1] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($eupricei){
        print PRICE (valid_import_price($data[$eupricei-1]) || "0")."\t";
			}else{
				print PRICE "0\t";
			}
			
			if($euprice_incl_vati){
        print PRICE (valid_import_price($data[$euprice_incl_vati-1]) || '0')."\t";
			}else{
				print PRICE "0\t";
			}
			
			if($stocki){
        print PRICE ($data[$stocki-1] || "0")."\t";
			}else{
				print PRICE "0\t";
			}

			# NEED TO ADD THE SIMILAR AS IN WITH-HEADER!..
			
			if ($options->{'distributor'}) {
				print PRICE $options->{'distributor'}."\t";
			}
			else {
				print PRICE "\t";
			}
			
			if($imagei){
				print PRICE ($data[$imagei-1] || '')."\t";
			}else{
				print PRICE "\t";
			}
			
			if($eani){
				print PRICE ($data[$eani-1] || '');
			}else{
				print PRICE "";
			}
		}
		print PRICE "\n";
		$line++;
#   log_printf("content from csv: ".Dumper(@data));
		
	}
	close(PL);
#  print PRICE "\nTOTAL COUNT: $line";
  close(PRICE);
	return $line;
}

sub valid_import_price {
  my $price = shift;

  $price =~ s/\./,/sg;
  $price =~ s/(.*),(\d*)$/$1.$2/sg;
  $price =~ s/,//gs;

  return $price;
}

sub validate_map_hash {

	my ($hash, $res_hash) = @_;
	for my $key (keys %$hash) {
		my $val = $hash->{$key};
		$key =~s/^[\s\t]+//gs;
		$val =~s/^[\s\t]+//gs;
		$key =~s/[\s\t]+$//gs;
		$val =~s/[\s\t]+$//gs;
		$res_hash->{$key} = $val;
	}
	
	return $res_hash;
}

sub read_configs {
	my ($config)=@_;
	my @configs=split("\n",$config);
	my $set={};
	for(@configs){
		my @c=split(':',$_);
		my @conf=split(':',$_);
		$set->{$conf[0]}=$conf[1];
	}
	return $set;
}
  
1;

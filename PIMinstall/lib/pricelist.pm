package pricelist;

#$Id$

use strict;

use File::Copy;
use File::stat;
use Data::Dumper;

use String::Escape qw( printable unprintable );
use LWP::Simple;
use File::Listing qw(parse_dir);

use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_util;
use atom_misc;
use icecat_util;
use pricelist_custom_preprocessing;
use Spreadsheet::XLSX;
use utf8;
use Exporter ();
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw(
&parse_price_list
&load_pricelist_settings
&download_pricelist
&get_default_options
&refine_url4path
&reupload_price_feed
&get_preview_html
&get_feed_config_params
&convert_escaped
&get_sql_columns_assingment
&get_xls_rows
&get_csv_rows
&convert_xls_csv
);

BEGIN {}

sub reupload_price_feed{
	my $hin=shift;
	use POSIX qw(floor);
	my $tmp_filename=floor(rand(1000000000));
	my $errors=[];
	if(!$hin->{'feed_config_id'}){# big evol if it's true
		push(@$errors,'Configuration id does not exists');
		return $errors;		
	}
	my($tmp_path,$tmp_dir,$cmd);
	$tmp_dir=$atomcfg{'session_path'}.$hin->{'feed_config_id'}.'/';
	`rm -R $tmp_dir` if -d $tmp_dir;
	`mkdir $tmp_dir`;
	`chmod 777 $tmp_dir -R`;
	if($hin->{'feed_url'}){
		my $feed_url=$hin->{'feed_url'};
		$feed_url=~/\.([\w]+)$/;
		$tmp_path=$atomcfg{'session_path'}.$tmp_filename.'.'.$1;
		if($hin->{'feed_login'} and $hin->{'feed_pwd'} and $feed_url=~/^ftp/i){
			if($feed_url=~/\[maxmtime\]/){#find out max time under given url
				$feed_url=~s/\[maxmtime\]//;
				$feed_url=get_ftp_newest_file($feed_url,$hin->{'feed_login'},$hin->{'feed_pwd'});
			}
			if(!$feed_url){
				push(@$errors,'Can\'t download the newest file from ftp $feed_url');
				return $errors;	
			}
			$cmd="wget -q --ftp-user=$hin->{'feed_login'}  --ftp-password=$hin->{'feed_pwd'} --no-passive-ftp '$feed_url' -O '$tmp_path'";
		}elsif($hin->{'feed_login'} and $hin->{'feed_pwd'}){
			$cmd="wget -q --http-user=$hin->{'feed_login'}  --http-password=$hin->{'feed_pwd'} '$feed_url' -O '$tmp_path'";		
		}else{
			$cmd="wget -q '$feed_url' -O '$tmp_path'  -a $atomcfg{'logfile'}";
		}
		`$cmd`;
	}elsif(-s $hin->{'feed_file'}){
		$tmp_filename=$hin->{'file_name'};
		$tmp_filename=~s/[^a-zA-Z0-9.]/_/gs;
		lp('---------->>>>>>>>>>>>>>>>'.$tmp_filename);
		$tmp_path=$atomcfg{'session_path'}.$tmp_filename;
		$cmd="cp -f '$hin->{'feed_file'}' '$tmp_path'";
		`$cmd`;
	}else{
		push(@$errors,'Can\'t download the file or file is empty');
		return $errors;		
	}
	
	if(!(-e $tmp_path)){
		log_printf("Error this file $tmp_path does not exists");
		log_printf($cmd);
		push(@$errors,'Can\'t download the file');
		return $errors;
	}
	my $feed_type=get_feed_type($hin->{'feed_type'},$tmp_path);
	#if(ref($feed_type) eq 'ARRAY'){
	#	push(@$errors,$feed_type->[0]);
	#	return $errors;		
	#} 
	my $arh_cmd_dir={
				'tar'=>"tar -xvf  '%%src%%' -C '%%dst%%'",
				'gz'=>"tar -xvzf  '%%src%%' -C '%%dst%%'",				
				'bz2'=>"tar --use-compress-prog=bzip2 -xf '%%src%%' -C '%%dst%%'",								
				'zip'=>"unzip -o '%%src%%' -d '%%dst%%'",
			 };
			 
	my $arh_cmd_file={
				'gz'=>"gzip -d -c '%%src%%' >  '%%dst%%'",
				'tar'=>"tar -x -f '%%src%%' '%%dst%%'",
				'zip'=>"unzip -o '%%src%%' -d '%%dst%%'",
				'bz2'=>"bzip2 -c -d '%%src%%' > '%%dst%%'",				
			 };
	
	my $unpacked_file='';
	if($arh_cmd_dir->{$feed_type}){# we deal with archive
		$cmd=repl_ph($arh_cmd_dir->{$feed_type},{'src'=>$tmp_path,'dst'=>$tmp_dir});
		`$cmd`;# unarahive
		my $tmp_unarh=`find $tmp_dir`;
		$tmp_unarh=~s/$tmp_dir//gs;
		$tmp_unarh=~s/^[\n]+//gs;
		my @unpack_files=split(/\n/,$tmp_unarh);
		if(scalar(@unpack_files)<1){# this could be a single file to diffrent type of unarh used
			$cmd=repl_ph($arh_cmd_file->{$feed_type},{'src'=>$tmp_path,'dst'=>$tmp_dir.$tmp_filename});
			`$cmd`;
			$tmp_unarh=`find $tmp_dir`;
			$tmp_unarh=~s/$tmp_dir//gs;
			$tmp_unarh=~s/\n//gs;	
			if(!$tmp_unarh){#this is something unexpectable
				push(@$errors,'Can\'t unpack the file');
				return $errors;		
			}
			$unpacked_file=$tmp_dir.$tmp_filename;
		}elsif(scalar(@unpack_files)>1 and !$hin->{'user_choiced_file'}){#let's user choice which file to parse
			push(@$errors,'Many files found in the archive. Plese select the one');
			`rm -f $tmp_path`;
			return $errors;
		}elsif(scalar(@unpack_files)>1 and $hin->{'user_choiced_file'}){#user choose something				
			if(-e $tmp_dir.$hin->{'user_choiced_file'}){
				$unpacked_file=$tmp_dir.$hin->{'user_choiced_file'};				
			}else{
				push(@$errors,"This file $hin->{'user_choiced_file'} does not exists in the datapack");
				`rm -f $tmp_path`;
				return $errors;
			}
		}elsif(scalar(@unpack_files)==1){# we have only one file in the package
			$unpacked_file=$tmp_dir.$unpack_files[0];
		}
		`rm -f $tmp_path`;	
		$tmp_path=$unpacked_file; 
		$feed_type=get_feed_type($hin->{'feed_type'},$unpacked_file);
		if(ref($feed_type) eq 'ARRAY'){
			push(@$errors,$feed_type->[0]);
			return $errors;		
		}
	}# if arhive
	#if($feed_type eq 'xls'){
	#	$tmp_path=~/([^\/]+)$/;
	#	$tmp_path=xls2csv($tmp_path,$tmp_dir,$1);
	#}elsif($feed_type eq 'xml'){
	#	$tmp_path=~/([^\/]+)$/;
	#	$tmp_path=xml2csv($tmp_path,$tmp_dir,$1);
	#}els
	if(!$unpacked_file){# this stuff copies file from $tmp to feed's dir if file already been unpacked copying has happened before
		$tmp_path=~/([^\/]+)$/;
		`mv -f '$tmp_path' '$tmp_dir$1'`;
		
		$tmp_path=$tmp_dir.$1;
	}elsif($unpacked_file){
		
	}else{
		log_printf("can't find out the feed's type ");
		push(@$errors,'can\'t find out the feed\'s type');
		`rm -f $tmp_path`;
		`rm -R $tmp_dir`;
		return $errors;		
		#return "";		
	}
	
	if(`file -bi $tmp_path`=~/utf[^utf16]{0,2}16/i){ # this is utf16 !!!!!!!!
		my $tmp_path_converted=convert_utf16($tmp_path);
		if(!$tmp_path_converted){
			push(@$errors,'Can\'t convert UTF16. Please convert file to UTF8 manually');
			return $errors;
		}else{
			$tmp_path=$tmp_path_converted;
		}
	}
	
	if($feed_type eq 'xml'){
		$tmp_path=xml_feed2csv($tmp_path);
	}
	
	if (defined &{'custom_preprocessing_'.$hin->{'code'}}) {# for distributors additional preprocessing is needed
		no strict;
		&{'custom_preprocessing_'.$hin->{'code'}}($tmp_path,'it is preview');
		$hin{'feed_type'}='csv';
		$feed_type=get_feed_type('auto',$tmp_path);
		use strict;
	}
	if (defined &{'custom_postprocessing_'.$hin->{'code'}}) {# for distributors additional postprocessing is needed
		no strict;
		&{'custom_postprocessing_'.$hin->{'code'}}($tmp_path,'it is preview');
		$hin{'feed_type'}='csv';		
		$feed_type=get_feed_type('auto',$tmp_path);
		use strict;
	}
	$hin{'is_first_header'}='1';# default when reupload	
	assign_autodetected($feed_type,$tmp_path);
	return $tmp_path; 
}

sub convert_utf16{
	my $source=$_[0];
	if(-e $source){
		my $dest=$source.'.utf8';
		open UTF16, "<:encoding(utf16)", "$source";
		open UTF8,">:utf8", "$dest";
		print UTF8 <UTF16>;
		close UTF16;
		close UTF8;
		if(!(-s $dest)){
			log_printf("------------>>>>>>>>>>>>>>>>>Erorr convertir utf16 to utf8: file $source");
			return '';
		}else{
			`mv -f '$dest' '$source'`;
			return $source; 
		}
		
	}else{
		return '';
	}
}
sub assign_autodetected{
	my ($type,$csv_file)=@_;
	$hin{'feed_type'}=$type if $type and $type ne 'auto';
	if($type eq 'csv' and ($hin{'delimiter'} eq 'auto' or !$hin{'delimiter'})){
		use Text::CSV::Separator qw(get_separator);
		my $candidate = get_separator( path=>$csv_file,lucky=>1);
		
		my $my_atom=$atoms->{'default'}->{'feed_config'};		
			log_printf('----------------->>>>>>>>>>>>>>>>assign_autodetected '.$candidate);
		if($candidate){
			#for my $atom_key( keys %{$my_atom}){
			#	if($atom_key=~/delimiter_radio_value/ and trim($my_atom->{$atom_key}) eq $candidate ){
					 $hin{'delimiter'}=($candidate eq "\t")?'\t':$candidate;
					 
			#		 last;
			#	}
			#}
		}else{
			$hin{'delimiter'}=',';
		}
	}
} 

sub trim{
	  my $str = shift;
	  $str=~s/^\s*(.*?)\s*$/$1/;
	  return $str;   	
}

sub xml_feed2csv{
	my ($tmp_path)=@_;
	my $result=xml2csv($tmp_path,($tmp_path.'.csv'),30);
	if($result){
		`rm -r $tmp_path`;
		$tmp_path.='.csv';
		$hin{'feed_type'}='xml';		
		$hin{'delimiter'}=',';
		$hin{'newline'}='\n';
		return $tmp_path;		
	}else{
		return '';
	}
}

sub get_feed_type{
	my ($expected_type,$feed_path)=@_;
	return undef if !(-e $feed_path);
	my $mime_type_map={
			'application/vnd.ms-office; charset=binary'=>'xls',
			'application/vnd.ms-excel; charset=binary'=>'xls',
			'application/x-gzip; charset=binary'=>'gz',
			'application/zip; charset=binary'=>'zip',
			'application/x-tar; charset=binary'=>'tar',
			'application/x-bzip2; charset=binary'=>'bz2',
			
			'application/octet-stream'=>'xls',
			'application/x-gzip'=>'gz',
			'application/zip'=>'zip',
			'application/x-tar'=>'tar',
			'application/x-bzip2'=>'bz2'
		};
	my $ext;
	my $file_func=`file -i -b $feed_path`;
	$file_func=~s/\n//gs;
	my $is_xml=`file -bi $feed_path`;
	my $is_xml1=`file -b $feed_path`;
	$is_xml=~s/\n//gs;
	if( ($is_xml=~/xml/i and $is_xml1=~/xml/i) or $feed_path=~/\.xml$/){
		$ext='xml';		
	}elsif($file_func=~/text/i){
		$ext='csv';				
	}else{
		$ext=$mime_type_map->{$file_func};
	}
	#if($ext and $expected_type ne 'auto' and $ext!~/\Q$expected_type\E/gi){
	#	my $errors=["Pricelist file type '$expected_type' conflicts with detected '$ext'"];
	#	return $errors;
	#}els
	if($expected_type eq 'xml' and $ext eq 'csv'){
		return 'xml';
	}elsif($expected_type ne 'auto' and $ext ne $expected_type){
		log_printf("User choiced type not equal determited. assume determited");# this may be an user error
		if($ext eq 'zip' and quick_checkExcel2007($feed_path)){
			return 'xls';
		}else{
			return $ext;
		}
	}elsif($ext eq 'zip'){# check for excel 2007
		if(quick_checkExcel2007($feed_path)){
			return 'xls';
		}else{
			return $ext;
		}
	}elsif($ext){
		return $ext;
	}else{		
		my $errors=["Can't find out type of file or file is empty"];
		return $errors;
	}
}


sub get_preview_html{
	my ($row_limit,$hash)=@_;
	if(!$hin{'feed_config_id'} or scalar(@user_errors)>0){#User does not submit.we should not display anything. 
		return "";
	}
	
	my($feed_url,$is_first_header,$delimiter,$newline,$escape,$user_choiced_file,$feed_type)=
		($hin{'feed_url'},$hin{'is_first_header'},$hin{'delimiter'},$hin{'newline'},$hin{'escape'},$hin{'user_choiced_file'},$hin{'feed_type'});
	my $errors=[];

	my $feed_config_dir=$atomcfg{'session_path'}.$hin{'feed_config_id'}.'/';
	my $tmp_unarh=`find $feed_config_dir`;
	$tmp_unarh=~s/$atomcfg{'session_path'}$hin{'feed_config_id'}\///gs;
	$tmp_unarh=~s/^[\n]+//gs;
	my @unpack_files=split(/\n/,$tmp_unarh);
	my $csv_file='';
	if(scalar(@unpack_files)==1){
		$csv_file=$feed_config_dir.$unpack_files[0];
	}elsif(scalar(@unpack_files)>1){
		$csv_file=$feed_config_dir.$user_choiced_file;
		if(!(-e $csv_file)){
			push(@$errors,"User choised file $user_choiced_file does not exists");
			return $errors;
		}
	}else{
		log_printf("Datapack was not downloaded. Please download it");
		return '';			
	}
	use CSVParser;
	process_atom_ilib('feed_config_preview');	
	$atoms=process_atom_lib('feed_config_preview');
	#print Dumper($atoms);
			log_printf('------>>>>>>>>>>>>>>>>>>>>>>>>>'.get_feed_type('auto',$csv_file));
	if($user_choiced_file and get_feed_type('auto',$csv_file) eq 'xml'){
		$csv_file=xml_feed2csv($csv_file);
		if(!$csv_file){
			push(@$errors,"XML file was not processed. Please check it");
			return @$errors;
		}else{
			($delimiter,$newline,$feed_type)=($hin{'delimiter'},$hin{'newline'},$hin{'feed_type'});
		}
	}
	
	my $i=0;
	my $my_atom=$atoms->{'default'}->{'feed_config_preview'};
	my $csvs;
	if($feed_type eq 'auto' or !$feed_type){
		$feed_type=get_feed_type('auto',$csv_file);
	}
	if($feed_type eq 'csv' or $feed_type eq 'xml'){
		if(!$delimiter and defined($is_first_header)){# if there is pricelist configurator an user does push buttons $is_first_header will be '0' or '1'
			push(@$errors,"Delimiter does not defined"); 
			return $errors;
		}		
		$csvs=get_csv_rows($csv_file,$delimiter,$newline,$escape,$row_limit);
	}elsif($feed_type eq 'xls'){
		$csvs=get_xls_rows($csv_file,$row_limit);
	}else{
		log_printf('ERROR( sub get_preview_html): Can\'t find out type of feed');
		return '';
	}
	
	if(ref($csvs) ne 'ARRAY'){		
		return '';
	} 
	my ($html_rows,$right_cells_cnt);
	for my $csv (@$csvs){
		
		if(ref($csv) eq 'ARRAY' and scalar(@$csv)>1 and !$right_cells_cnt){#first row which looks right is a sample
			$right_cells_cnt=scalar(@$csv);	
		} 
		my ($html_cells);
		my $j=1;
		for my $csv_cell(@$csv){
			my $line_delimiter_warn1='';
			my $line_delimiter_warn2='';
			if($j==1 and $csv_cell=~/^\n/){
				$line_delimiter_warn1='<span class="red"> Warning!!! \\r At the begining of line. please check the Line separator </span>';
			}elsif($j==scalar(@$csv) and $csv_cell=~/[\r]$/){
				$line_delimiter_warn2='<span class="red"> Warning!!! \\r At the end of line please check the Line seprator </span>';				
			}
			$csv_cell=$line_delimiter_warn1.str_htmlize(shortify_str($csv_cell,30,'..')).$line_delimiter_warn2;
			
			$html_cells.=repl_ph($my_atom->{'csv_cell'},{'cell'=>$csv_cell});
			
			$j++;
		}
		if($i==0 and $is_first_header){
			$html_rows.=repl_ph($my_atom->{'csv_header_row'},{'csv_cell'=>$html_cells});
		}elsif(scalar(@$csv)!=$right_cells_cnt){
			$html_rows.=repl_ph($my_atom->{'csv_err_row'},{'csv_cell'=>$html_cells});
		}else{
			$html_rows.=repl_ph($my_atom->{'csv_row'},{'csv_cell'=>$html_cells});			
		}
		$i++;
	}	
	my $html_table=repl_ph($my_atom->{'body'},{'csv_row'=>$html_rows});
	return $html_table;
	
}

sub get_csv_rows{
	my($csv_file,$delimiter,$newline,$escape,$row_limit)=@_;
	my $file_out=`file -b -i $csv_file`;
	$file_out=~/charset=(.+)$/;
	#assign_autodetected('csv',$csv_file);
	#if(!$hin{'delimiter'}){
	#	$delimiter=',';
	#}	
	my $csv_obj=CSVParser->new(
				quote          => '"',
				escape         => ($escape)?$escape:'\\',
				delimiter      => convert_escaped($delimiter), 
				newline        => convert_escaped($newline),
				file		   => $csv_file,
				encoding	   => ($1 and $1 ne 'binary' and $1!~/unknown/)?($1):'ISO-8859-1' # default is ISO-8859-1
			  );
	if(!$csv_obj){
		log_printf("CSV parameters conflicts with each other");
		return "";				
	}
	my @csv_rows;
	my $i=0;
	while(my $csv_row=$csv_obj->get_next_row() and $i<$row_limit){
		push(@csv_rows,$csv_row);
		$i++;
	}
	return \@csv_rows;
}

sub get_xls_rows{
	my($xls_file,$row_limit,$excel)=@_;
	my @xls_rows;
	if(ref($excel) and $excel->can('worksheet_count') and $excel->get_filename eq $xls_file){
		# we already have excel object from given file
	}else{
		if(quick_checkExcel2007($xls_file)){
			$excel=Spreadsheet::XLSX->new($xls_file);
		}else{
			$excel = Spreadsheet::ParseExcel->new()->Parse($xls_file);
		}
	}
	 
	if(!$excel or !$excel->{Worksheet}->[0]){
		log_printf("ERROR(sub get_xls_rows): This file $xls_file does  not exists or we can't parse it");
		return \@xls_rows;
	}
	my $firstSheet=$excel->{Worksheet}[0];
	if(!defined($firstSheet->{MaxCol}) or !defined($firstSheet->{MaxRow})){# sheet looks empty 
		return \@xls_rows;
	}
	for(my $i=0; $i<$row_limit; $i++){
		my @xls_row;
		for(my $j=0; $j<=$firstSheet->{MaxCol}; $j++){
			push(@xls_row,($firstSheet->{Cells}[$i][$j])?$firstSheet->{Cells}[$i][$j]->value:'');	
		}
		push(@xls_rows,\@xls_row);
	}
	return \@xls_rows;
}

sub convert_xls_csv{
	my($xls_file,$delimiter,$newline)=@_;
	my @xls_rows;
	my $excel;
	if(quick_checkExcel2007($xls_file)){ 
		$excel=Spreadsheet::XLSX->new($xls_file);
	}else{
		$excel=Spreadsheet::ParseExcel->new()->Parse($xls_file);
	}
	if(!$excel or !$excel->{Worksheet}[0]){
		log_printf("ERROR(sub get_xls_rows): This file $xls_file does  not exists or we can't parse it");
		return '';
	}
	open CSV,">".$xls_file.'.csv' || return '';
	my $firstSheet=$excel->{Worksheet}[0];
	if(!defined($firstSheet->{MaxCol}) or !defined($firstSheet->{MaxRow})){# sheet looks empty 
		return '';
	}
	my $csv_obj=Text::CSV->new({
				quote_char          => '"',
				escape_char         => "\\",
				sep_char            => $delimiter,
				eol                 => $newline,
				always_quote        => 0,
				binary              => 1,
				keep_meta_info      => 0,
				allow_loose_quotes  => 1,
				allow_loose_escapes => 1,
				allow_whitespace    => 0,
				blank_is_undef      => 0,
				verbatim            => 0				
			  });
	
	for(my $i=0; $i<$firstSheet->{MaxRow}+1; $i++){
		my @xls_row;
		for(my $j=0; $j<=$firstSheet->{MaxCol}; $j++){
			push(@xls_row,($firstSheet->{Cells}[$i][$j])?$firstSheet->{Cells}[$i][$j]->value:'');
		}
		$csv_obj->combine(@xls_row);
		print CSV $csv_obj->string();
	}
	close(CSV);
	return $xls_file.'.csv';
}

sub get_feed_config_params{
	my ($code)=@_;
	my $params=do_query("SELECT feed_url,is_first_header,delimiter,newline,escape,quote,user_choiced_file,feed_type 
						  FROM distributor_pl WHERE code=".str_sqlize($code));
	if(scalar(@$params)<1){
		return [];
	}else{
		return @$params->[0];
	}		
}
  
sub convert_escaped{
	my ($newline_escaped)=@_;
	if($newline_escaped eq '\n'){
		return "\n";
	}elsif($newline_escaped eq '\r\n'){
		return "\r\n";
	}elsif($newline_escaped eq '\r'){
		return "\r";
	}elsif($newline_escaped eq '\t'){
		return "\t";		
	}else{
		return $newline_escaped;
	}
}




sub xls2csv{
	my ($tmp_path,$tmp_dir,$tmp_filename)=@_;
	`mv -f '$tmp_path' '$tmp_dir$tmp_filename.xls'`;
	return $tmp_dir.$tmp_filename.'.xls';
}




sub get_sql_columns_assingment{
	my($csv_sett)=@_;
	my @columns=(
		{'key'=>'ean','num'=>$csv_sett->{'ean'}},
		{'key'=>'supplier','num'=>$csv_sett->{'supplier'}},
		{'key'=>'prod_id','num'=>$csv_sett->{'prod_id'}},
		#{'key'=>'euprice','num'=>$csv_sett->{'euprice'}},
		{'key'=>'euprice_incl_vat','num'=>$csv_sett->{'euprice_incl_vat'}},
		
		{'key'=>'category','num'=>$csv_sett->{'category'}},
		{'key'=>'country_postfix','num'=>$csv_sett->{'country_postfix'}},
		{'key'=>'name','num'=>$csv_sett->{'name'}},
		{'key'=>'stock','num'=>$csv_sett->{'stock'}},
		{'key'=>'description','num'=>$csv_sett->{'description'}},
		{'key'=>'prodlevid','num'=>$csv_sett->{'prodlevid'}},
		{'key'=>'image','num'=>$csv_sett->{'image'}},
	);
	# keys: column names from csv file, values: column names from table pricelist 
	my $table2csvMap={
					  'ean'=>'ean_code',
					  'prod_id'=>'prod_id',
					  'supplier'=>'vendor',
					  'euprice_incl_vat'=>'price',
					  
					  'category'=>'cat',
					  #'country_postfix'=>'country_id',
					  'name'=>'name',
					  'stock'=>'stock',
					  'description'=>'l_desc',
					  'prodlevid'=>'prodlevid',
					  'image'=>'image',
					 };
	
	my $cols_sql="(";
	my $set_sql=" SET ";
	@columns=sort {$a->{'num'}<=>$b->{'num'}} @columns;
	#print Dumper(\@columns);
	my (@arr);
	my $country_found=undef;
	for(my $i=0; $i<$columns[scalar(@columns)-1]->{'num'}; $i++){
		for(my $j=0; $j<scalar(@columns); $j++){
			if($columns[$j]->{'num'}==$i+1 and ($columns[$j]->{'num'}*1)){				
				if($columns[$j]->{'key'} eq 'country_postfix'){
					$country_found=1;
					$set_sql.=" distributor=IF(".'@var'.($i+1)."!='',CONCAT('$csv_sett->{'distributor'}',".'@var'.($i+1)."),'$csv_sett->{'distributor'}'), ";
				}else{
					$set_sql.=$table2csvMap->{$columns[$j]->{'key'}}.'=@var'.($i+1).', ';	
				}
				last;
			}
		}
		$cols_sql.='@var'.($i+1).', ';						
	}
	$cols_sql=~s/,[\s]*$/)/;	
	$set_sql=~s/,[\s]*$//;
	if(!$country_found){
		$set_sql.=", distributor='$csv_sett->{'distributor'}'";
	}
	$set_sql.=", source_info='icecat'";
	return  $cols_sql."\n".$set_sql." ";
}






sub refine_url4path {
	my $file = shift;

	return undef unless $file;
	
	$file =~ s#.*//([^/]*?)/(.*)$#$1 $2#i;
	$file =~ s/[\?\:\@]//gs; # remove auth info
	$file =~ s/\W+/\_/gs; # noncharacters -> to _
	$file .= do_query("select unix_timestamp()")->[0][0]; # add the timestamp
	
	return $file;
} # sub refine_url4path

sub parse_price_list {
	my ($file, $distri_code) = @_;

	my $type;
	my $settings = {};
	my $download = 0;
	$type = $hin{'pl_format'} if($hin{'pl_format'});
	
	log_printf('our file:'.$file." distri_code:".$distri_code);
	$settings->{'first_row_as_header'} = $hin{'first_row_as_header'} if($hin{'first_row_as_header'} && $hin{'pl_format'});
	$settings->{'row_delimeter'} = $hin{'row_delimeter'} if($hin{'row_delimeter'} && $hin{'pl_format'});
	$settings->{'delimeter'} = $hin{'delimeter'} if ($hin{'delimeter'} && $hin{'pl_format'});
	$settings->{'delimeter'} = $hin{'own_delimeter'} if($hin{'delimeter'} eq "own" && $hin{'pl_format'});
	$settings->{'esc_c'} = $hin{'esc_c'} if($hin{'esc_c'});
	$settings->{'xml_path'} = $hin{'xml_path'} if($hin{'xml_path'} && $hin{'pl_format'});
	$settings->{'pl_login'} = $hin{'pl_login'} if($hin{'pl_login'});
	$settings->{'pl_pass'} = $hin{'pl_pass'} if($hin{'pl_pass'});
	
	my $s;

	if ($distri_code) {
		log_printf("Loading pricelist settings");
		$s = load_pricelist_settings($distri_code);
	}

#	log_printf("and our settings: ".Dumper($s));

	if ($s) {
		$type = $s->{'pl_format'};
		unless ($file) {
			log_printf("loading file according settings");
			$hin{'pl_url'} = $s->{'pl_url'};
			$file = refine_url4path($hin{'pl_url'});
			log_printf('and our file is : '.$file);
		}
		$hin{'first_row_as_header'} = $settings->{'first_row_as_header'} = $s->{'first_row_as_header'} if !$hin{'first_row_as_header'};
		$hin{'row_delimeter'} = $settings->{'row_delimeter'} = $s->{'row_delimeter'} if !$hin{'row_delimeter'};
		$hin{'delimeter'} = $settings->{'delimeter'} = $s->{'delimeter'} if !$hin{'delimeter'};
		$hin{'xml_path'} = $settings->{'xml_path'} = $s->{'xml_path'} if !$hin{'xml_path'};
		$hin{'pl_login'} = $settings->{'pl_login'} = $s->{'pl_login'} if !$hin{'pl_login'};
		$hin{'pl_pass'} = $settings->{'pl_pass'} = $s->{'pl_pass'} if !$hin{'pl_pass'};
		$settings->{'pl_format'} = $s->{'pl_format'};
	}

	########## here the directory files to be saved ################

	$file = $atomcfg{'session_path'}.$file;
	$hin{'first_row_as_header'} eq 'on' ? 1 : 0;

	if (!$type) {
		# first time parsing
		# will try to guess by file extention
		$type = $hin{'pl_url'};
		$type =~ s/\s+$//;
		$type =~ s/\t+$//;
		$type =~ s/^.*\.(\w+)$/$1/;
		$type = lc($type);

		if ($type eq 'csv' || $type eq 'txt') {
			# ok
			$type = 'csv';
		}
		elsif ($type eq 'xml' || $type eq 'xls') {
			# ok
		}
		else {
			# not ok, probably here is .pl, .php, .cgi script printing to STDOUT
			# will try to guess or suppose it is csv , just let it be so ;) if not - user will setup it manualy before next parsing
			my $guess = $hin{'pl_url'};
			$guess =~ s/.*?(csv).*/$1/i;
			$guess =~  s/.*?(xml).*/$1/i;
			$guess =~ s/.*?(xls).*/$1/i;
			$guess = '' if($guess eq $hin{'pl_url'});
			$type = $guess || 'csv';
		}
	}

	log_printf("FINAL TYPE ::: ".$type." 1  row as header: ".$hin{'first_row_as_header'});
	$settings->{'pl_format'} = $hin{'pl_format'} = $type;
	$file = $file.".".$type;
	log_printf("Downloading: ".$hin{'pl_url'}." to ".$file);

	$settings->{'distri_code'} = $distri_code;
	download_pricelist($hin{'pl_url'}, $file, $settings); # if(!$hin{'file_name'} && !($hin{'is_analyzis'} && $distri_code));
	
	if ($hin{'file_name'} && !$hin{'is_analyzis'}) {
		$file = $atomcfg{'session_path'}.$hin{'file_name'};
		my $cmd = "/bin/mv ".$hin{'pl_url_filename'}." ".$file;
		`$cmd`;
		if ($file !~ /xls$/i) {
			my $buffer_file = $file.'_buffer';
			my $pattern = '\\\n';
			`cat $file | sed s/\\\r/$pattern/g  > $buffer_file && mv -f $buffer_file $file`;
			remove_empty_strings($file);
		}
		log_printf($cmd);
	}

	return "not found!" unless(-e $file);
	
	my @price;
	my @header;
	my $preview;
	my $skip_header = 1;
	
	############ hey-hey! if you want number of rows in preview to be changed, change number below ####################
	my $preview_cnt = 30;
	
	if (!$hin{'is_analyzis'} || !$s) {
		log_printf('if type eq csv, xls, xml:');
		if ($type eq 'csv') {
			log_printf('- parse_csv_header');
			my $res   = parse_csv_header($file,$settings,$preview_cnt,$s);
#			@header = @{$res->{'header'}};
			@header   = $res->{'header'} ? @{$res->{'header'}} : ();		
			$settings = $res->{'settings'};
			$preview  = $res->{'preview'};
		}
		elsif ($type eq 'xls' || $type eq 'exel') {
			log_printf('- parse_excel_header');
			$settings->{'CSV'}='';
			my $res   = parse_excel_header($file,$hin{'first_row_as_header'},$preview_cnt);
#			@header   = @{$res->{'header'}};
			@header   = $res->{'header'} ? @{$res->{'header'}} : ();		
			$preview  = $res->{'preview'};
		}
		elsif ($type eq 'xml') {
			log_printf('- parse_xml_header');
			my $res   = parse_xml_header($file,$settings,$preview_cnt);
#			log_printf(Dumper($res->{'header'}));
			@header   = $res->{'header'} ? @{$res->{'header'}} : ();
			$preview  = $res->{'preview'};
		}
		log_printf('parsed');
	}
	else {
		$settings = $s;
	}

	# Here we compare the current setting of pricelist with the list of known columns\attributes
	# It will be used to mark the currently setted value properly
	# $col_del = $s->{'delimeter'}; 
	
	$settings->{'delimeter'} = $s->{'delimeter'} if $s->{'delimeter'};

	my @header_nice;

	for (@header) {
		my $prev_line = $preview->{$_};
		my $prev_name = $_;

		$_ =~ s/[\n\r]//gs;
		$_ =~ s/^"//gs;
		$_ =~ s/"$//gs;

		if ($_ ne $prev_name) {
			delete $preview->{$prev_name};
			$preview->{$_} = $prev_line;
		}
		push @header_nice, $_;
		
		$settings->{'prodlevid'}        = $s->{'prodlevid'}        if $_ eq $s->{'prodlevid'};
		$settings->{'prod_id'}          = $s->{'prod_id'}          if $_ eq $s->{'prod_id'};
		$settings->{'supplier'}         = $s->{'supplier'}         if $_ eq $s->{'supplier'};
		$settings->{'euprice'}          = $s->{'euprice'}          if $_ eq $s->{'euprice'};
		$settings->{'stock'}            = $s->{'stock'}            if $_ eq $s->{'stock'};
		$settings->{'euprice_incl_vat'} = $s->{'euprice_incl_vat'} if $_ eq $s->{'euprice_incl_vat'};
		$settings->{'ean'}              = $s->{'ean'}              if $_ eq $s->{'ean'};
		$settings->{'category'}      	  = $s->{'category'}         if $_ eq $s->{'category'};
		$settings->{'picture'}          = $s->{'picture'}          if $_ eq $s->{'picture'};
		$settings->{'name'}             = $s->{'name'}             if $_ eq $s->{'name'};
		$settings->{'description'}      = $s->{'description'}      if $_ eq $s->{'description'};

		$settings->{'country_postfix'}  = $s->{'country_postfix'}  if $_ eq $s->{'country_postfix'};
	}
	
	
	# And here we build the dropdowns itself
	# Really strange approach. Will change that when time permit
	
	for my $val (keys %$settings) {
    if ($val ne 'delimeter1' && $val ne 'delimeter2' && $val ne 'rdelimeter1' && $val ne 'delimeter' && $val ne 'rdelimeter2' && $val ne 'CSV' && $val ne 'rdelimeter' && $val ne 'row_delimeter' && $val ne 'xml_path' && $val ne 'pl_format' && $val ne 'first_row_as_header' && $val ne 'pl_login' && $val ne 'pl_pass' && $val ne 'esc_c') {
      # We do not to include delimeters and other non product stuff here
#      $settings->{$val} = ;
#      $settings->{$val} = '<option value="'.$settings->{$val}.'">'.$settings->{$val};
			my $selected_value = $settings->{$val} || '';
			
      for my $cval (@header) {
#				log_printf("DV: '".$cval."' === '".$selected_value."'");

				# Till this moment we already have one option
				# Lets add all other options, except the one we already have (it was added in the previous step)
				my $selected = '';
				if ($selected_value eq $cval) {
					$selected = ' selected';
				}
				
				$settings->{$val}.='<option value="'.$cval.'"'.$selected.'>'.$cval."</option>\n";
      }
			#$settings->{$val}.='<option value="">[none]';
#			log_printf("DV: --- none ---");
    }
	}
	
	# Here we build general dropdown
	# It is used if no pricelist settings was found in the database
	
	$settings->{'all'}.="<option>\n";
	for (@header) {
		$settings->{'all'}.='<option value="'.$_.'">'.$_;
	}
	
	$settings->{'prodlevid'}        = $settings->{'all'} if !$s->{'prodlevid'};
	$settings->{'prod_id'}          = $settings->{'all'} if !$s->{'prod_id'};
	$settings->{'supplier'}         = $settings->{'all'} if !$s->{'supplier'};
	$settings->{'euprice'}          = $settings->{'all'} if !$s->{'euprice'};
	$settings->{'stock'}            = $settings->{'all'} if !$s->{'stock'};
	$settings->{'euprice_incl_vat'} = $settings->{'all'} if !$s->{'euprice_incl_vat'};
	$settings->{'ean'}              = $settings->{'all'} if !$s->{'ean'};
	$settings->{'category'}      	  = $settings->{'all'} if !$s->{'category'};
	$settings->{'picture'}          = $settings->{'all'} if !$s->{'picture'};
	$settings->{'name'}						  = $settings->{'all'} if !$s->{'name'};
	$settings->{'description'}			= $settings->{'all'} if !$s->{'description'};

	$settings->{'country_postfix'}		= $settings->{'all'} if !$s->{'country_postfix'};
	
	$hout{'header'}                 = $hin{'header'};

  return {'settings' => $settings, 'preview' => $preview , 'header' => \@header_nice, 'file' => $file};
}

sub get_default_options {
	my ($settings,@header);

	@header = (
		'1 column',
		'2 column',
		'3 column',
		'4 column',
		'5 column',
		'6 column',
		'7 column',
		'8 column',
		'9 column',
		'10 column',
		'11 column',
		'12 column',
		'13 column',
		'14 column',
		'15 column'
		);
	
	$settings->{'all'}.="<option>\n";
	for(@header){
		$settings->{'all'}.='<option value="'.$_.'">'.$_;
	}
	
	$settings->{'prodlevid'}        = $settings->{'all'};
	$settings->{'prod_id'}          = $settings->{'all'};
	$settings->{'supplier'}         = $settings->{'all'};
	$settings->{'euprice'}          = $settings->{'all'};
	$settings->{'stock'}            = $settings->{'all'};
	$settings->{'euprice_incl_vat'} = $settings->{'all'};
	$settings->{'ean'}              = $settings->{'all'};
	$settings->{'category'}      	  = $settings->{'all'};
	$settings->{'picture'}          = $settings->{'all'};
	$settings->{'name'}						  = $settings->{'all'};
	$settings->{'description'}			= $settings->{'all'};

	$settings->{'country_postfix'}			= $settings->{'all'};
	
	$hout{'header'}                 = $hin{'header'};
	
	return $settings;
}

sub download_pricelist {
	my ($url, $path, $sett) = @_;

	my ($download, $path_compressed);

	log_printf("download started: url = ".$url);

	# add a possibility to use wildcards in the URL: [max], [maxmtime]
	if ($url =~ /\[max\]/) { # get the maximum filename
		my $url2dir = $url;
		my $nameWoExt;
		my $maxFile = '';
		$url2dir =~ s/\[max\]$//s;

		$url2dir =~ s/^((ht|f)tp:\/\/)(.*)$/$1$sett->{'pl_login'}\:$sett->{'pl_pass'}\@$3/;
		log_printf("get the directory path: ".$url2dir);
		
		for (parse_dir(get($url2dir))) {
			my ($name, $type, $size, $mtime, $mode) = @$_;
			$maxFile = $name gt $maxFile ? $name : $maxFile;
		}

		if ($maxFile) {
			log_printf("the max file is ".$maxFile);
			$url =~ s/\[max\]/$maxFile/s;
		}
	}
	elsif ($url =~ /\[maxmtime\]/) { # get the maximum modification time
		my $url2dir = $url;
		my $nameWoExt;
		my $maxMtime = 0;
		my $maxFile = '';
		$url2dir =~ s/\[maxmtime\]$//s;

		$url2dir =~ s/^((ht|f)tp:\/\/)(.*)$/$1$sett->{'pl_login'}\:$sett->{'pl_pass'}\@$3/;
		log_printf("get the directory path: ".$url2dir);
		
		for (parse_dir(get($url2dir))) {
			my ($name, $type, $size, $mtime, $mode) = @$_;
			if ($mtime > $maxMtime) {
				$maxMtime = $mtime;
				$maxFile = $name;
			}
		}

		if ($maxFile) {
			log_printf("the newest file is ".$maxFile);
			$url =~ s/\[maxmtime\]/$maxFile/s;
		}
	}

	$path_compressed = $path;

	if ($url =~ /\.(gz|zip|bz2)$/i) {
		$path_compressed .= ".".$1;
	}

	log_printf("path, path2: ".$path.", ".$path_compressed);

  if ($url =~ /^http/) {
	  log_printf("Downloading file HTTP: $url");
    $download = download_file_http($url,$path_compressed,$sett);
  }
	elsif ($url =~ /^ftp/) {
	  log_printf("Downloading file FTP: $url");
    $download = download_file_ftp($url,$path_compressed,$sett);
  }
	else {
  	`/usr/bin/cp $url $path_compressed`;
		$download = $url;
  	$download = 1 if(-e $path_compressed);
  }

	# datapack custom preprocessing: change field values & filter products (The pioneer is TechData Poland datapack)
#	log_printf(Dumper($sett));
	if (defined &{'custom_preprocessing_'.$sett->{'distri_code'}}) {
		no strict;
		&{'custom_preprocessing_'.$sett->{'distri_code'}}($path);
		use strict;
	}	

	# check for compressors: gz, bz2
	my ($z, $buffer);
	my $arh_cmd_dir={
				'tar'=>"tar -xvf  '%%src%%' -C '%%dst%%'",
				'gz'=>"tar -xvzf  '%%src%%' -C '%%dst%%'",				
				'bz2'=>"tar --use-compress-prog=bzip2 -xf '%%src%%' -C '%%dst%%'",								
				'zip'=>"unzip -o '%%src%%' -d '%%dst%%'",
			 };
	
	if ($url =~ /\.gz$/) {
		use IO::Uncompress::Gunzip qw($GunzipError);
		$z = new IO::Uncompress::Gunzip $path_compressed or die "gunzip failed: $GunzipError\n";
	}
	elsif ($url =~ /\.bz2$/) {
		use IO::Uncompress::Bunzip2 qw($Bunzip2Error);
		$z = new IO::Uncompress::Bunzip2 $path_compressed or die "bunzip2 failed: $Bunzip2Error\n";
	}elsif($url =~ /\.zip$/ and !$sett->{'user_choiced_file'}){
		my $unarh_dir=$atomcfg{'session_path'}.'tmp_unarh/';
		`mkdir $unarh_dir` if !(-d $unarh_dir);		
		my $cmd=repl_ph($arh_cmd_dir->{'zip'},{'src'=>$path_compressed,'dst'=>$unarh_dir});
		`$cmd`;
		my $extracted_file=`find $unarh_dir*`;
		$extracted_file=~s/[\n\s]+//gs;
		if(!(-s $extracted_file)){# zip archive is empty			
			return '';
		}
		`cp -f $extracted_file $path`;
		`rm -R $unarh_dir`;
		$path_compressed=$path;		
	}
	
	my $feed_type=get_feed_type('auto',$path_compressed);
	
	if($arh_cmd_dir->{$feed_type} and  $sett->{'user_choiced_file'}){
		my $unarh_dir=$atomcfg{'session_path'}.'tmp_unarh/';
		`mkdir $unarh_dir` if !(-d $unarh_dir);		
		my $cmd=repl_ph($arh_cmd_dir->{$feed_type},{'src'=>$path_compressed,'dst'=>$unarh_dir});
		`$cmd`;
		`cp -f $unarh_dir$sett->{'user_choiced_file'} $path`;
		`rm -R $unarh_dir`;
		$path_compressed=$path;
	}
#	log_printf("z = ".Dumper($z));

	if (($z) && ($path_compressed ne $path)) {
		open UNCOMPRESSED, ">".$path;
		binmode UNCOMPRESSED, ":utf8";
		while (read($z, $buffer, 4096)) {
			print UNCOMPRESSED $buffer;
		}
		close UNCOMPRESSED;
		`/bin/rm -f $path_compressed`;
	}

	# datapack custom postprocessing: change field values & filter products (The pioneer is Ingram_Micro_Europe datapack)
	if (defined &{'custom_postprocessing_'.$sett->{'distri_code'}}) {
		no strict;
		&{'custom_postprocessing_'.$sett->{'distri_code'}}($path);
		use strict;
	}

	return $download;
}

sub download_file_http {
	my ($url,$path,$set) = @_;

	use LWP::UserAgent;
	use HTTP::Request;

	my $fn = $path;
	my $ua = new LWP::UserAgent;
	my $req = new HTTP::Request GET => $url;
	my ($un,$pw);

	if ($set->{'pl_login'} && $set->{'pl_pass'}) {
		$un = $set->{'pl_login'};
		$pw = $set->{'pl_pass'};
		$url =~ s#^http://##i;
		$req->authorization_basic($un,$pw);
	}

	my $res = $ua->request($req, $fn);

	# get and update the modification time
	my $mtime = $res->header('last-modified');
	$mtime =~ s/^\w+,\s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s+\w+$/$3."-" . months2numbers($2) . "-".$1." ".$4.":".$5.":".$6/e;

	# prepare MySQL-like distri code
	my $distri_code = $set->{'distri_code'};
	my $country_postfix = do_query("select country_col from distributor_pl where code=".str_sqlize($set->{'distri_code'}))->[0][0];
	$country_postfix=$country_postfix*1;# convert '0' to 0

	if ($country_postfix) {
		$distri_code =~ s/\_/\\\_/gs;
		$distri_code =~ s/\%/\\\%/gs;
	}

	if (($mtime =~ /^\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{1,2}:\d{1,2}$/) && ($set->{'distri_code'} ne '') && ($set->{'distri_code'})) {
		log_printf("Update distributor ".$set->{'distri_code'}." with the new modification time: ".$mtime);
		do_statement("update distributor
set file_creation_date=unix_timestamp(".str_sqlize($mtime).")
where code". ( $country_postfix ? " like ".str_sqlize($distri_code."%") : "=".str_sqlize($set->{'distri_code'}) ). "
and file_creation_date!=unix_timestamp(".str_sqlize($mtime).")");
	}

	if (!$res->is_success) {
		if ($un && $pw) {
			log_printf("AUTH wget -q -O$path '".$url."'");
			`wget -q -O$path --http-user="'.$un.'" --http-password="'.$pw.'" http://"$url"' > /dev/null` || log_printf("Can't download $url!\n") && return "http://$un:$pw\@$url";
		}
		else {
			log_printf("wget -q -O$path '".$url."'");
			`wget -q -O$path "$url" > /dev/null` || log_printf("Can't download $url!\n") && return "$url";
		}
		log_printf("Can't download $url!\n");
		# return undef;
	}

	if ($url =~ /zip$/) {
		system("unzipto",$fn,$fn);
	}

	return 1;
}

sub download_file_ftp {
	my ($ftp,$path,$set)=@_;
# $ftp=~s/[\$\&]/\\$&/gsm;
#	$ftp = "'".$ftp."'";

	my $wget_settings = ' --no-passive-ftp --tries=1 --timeout=20 ';
	my $cmd = "wget -O$path ".$wget_settings." '$ftp'";
	my ($un, $pw);

	if ($set->{'pl_login'} && $set->{'pl_pass'}){
		$un = $set->{'pl_login'};
		$pw = $set->{'pl_pass'};
		$ftp =~ s#^ftp://##i;
		log_printf("uname:".$un." pass:".$pw." host:".$ftp);
	}

	# get and update the modification time
	use Net::FTP;

	$ftp =~ /^(.*?)\/(?:(.*\/)?(.*?))$/;
	my ($ftphost, $ftppath, $ftpfile) = ($1, $2, $3);

	log_printf("host: ".$ftphost.", path: ".$ftppath.", file: ".$ftpfile);
	
	my $oftp = Net::FTP->new($ftphost, Debug => 0)
		or die "Cannot connect to ".$ftphost.": $@";
	
	$oftp->login($un,$pw)
		or die "Cannot login ", $oftp->message;
	
	if ($ftppath) {
		$oftp->cwd($ftppath)
			or die "Cannot change working directory ", $oftp->message;
	}
	
	my $mtime = $oftp->mdtm($ftpfile) || 0; # some ftp servers doen't support mdtm
	
	$oftp->quit;

	# prepare MySQL-like distri code
	my $distri_code = $set->{'distri_code'};
	my $country_postfix = do_query("select country_col from distributor_pl where code=".str_sqlize($set->{'distri_code'}))->[0][0];
	$country_postfix=$country_postfix*1; # convert '0' to 0
	
	if ($country_postfix) {
		$distri_code =~ s/\_/\\\_/gs;
		$distri_code =~ s/\%/\\\%/gs;
	}

	if (($mtime =~ /^\d+$/) && ($set->{'distri_code'} ne '') && ($set->{'distri_code'})) {
		log_printf("Update distributor ".$set->{'distri_code'}." with the new modification time: ".$mtime);
		do_statement("update distributor
set file_creation_date=".str_sqlize($mtime)."
where code". ( $country_postfix ? " like ".str_sqlize($distri_code."%") : "=".str_sqlize($set->{'distri_code'}) ). "
and file_creation_date!=".str_sqlize($mtime));
	}

 once_again:

	$cmd = 'wget -O'.$path.' '.$wget_settings.' --ftp-user="'.$un.'" --ftp-password="'.$pw.'" ftp://"'.$ftp.'"' if($un && $pw && $ftp);

	log_printf("getting file ftp:".$cmd);
	`$cmd`;

	if (($wget_settings =~ /--no-passive-ftp/) && (!-f $path)) { # quick fix with passive ftp - trying in passive mode
		$wget_settings =~ s/--no-passive-ftp//is;
		goto once_again;
	}

	return "$ftp" if (!(-e $path)); 

	if($ftp =~ /zip$/g){
		system("unzipto",$path,$path);
	}

	return 1;
}

sub load_pricelist_settings {
	my ($id) = @_;

	my @settings;
	my (%result, $set);

	my $extra=' where code='.str_sqlize($id); #if !$id || $id eq 'all';
		
	$set = do_query('select name, code, feed_url, feed_type, 
							 is_first_header,feed_login,feed_pwd,delimiter,newline,escape,user_choiced_file,
							 country_col,ean_col,name_col,price_vat_col,price_novat_col,desc_col,stock_col,distri_prodid_col,brand_col,brand_prodid_col,category_col,
							 escape
							 from distributor_pl '.$extra)->[0];
	$result{'distributor'} = $set->[1];
	$result{'pl_url'}    = $set->[2] || '';
	$result{'pl_format'} = $set->[3] || '';
	$result{'first_row_as_header'} = $set->[4];
	$result{'pl_login'} = $set->[5];
	$result{'pl_pass'} = $set->[6];
	$result{'delimeter'} = $set->[7];
	$result{'row_delimeter'} = $set->[8];
	$result{'esc_c'} = $set->[9];
	$result{'user_choiced_file'} = $set->[10];
	$result{'country_postfix'} = $set->[11];
	$result{'ean'} = $set->[12];
	$result{'name'} = $set->[13];
	$result{'euprice_incl_vat'} = $set->[14];
	$result{'euprice'} = $set->[15];
	$result{'description'} = $set->[16];
	$result{'stock'} = $set->[17];
	$result{'prodlevid'} = $set->[18];
	$result{'supplier'} = $set->[19];
	$result{'prod_id'} = $set->[20];
	$result{'category'} = $set->[21];
	$result{'esc_c'}=$set->[22];
#	log_printf("result: ".Dumper(\%result));
#	log_printf("hin: ".Dumper(\%hin));
	return \%result;
}

sub remove_empty_strings {
	my ($file) = @_;
	
	my $cache = $file."_without_empty";
	open(FH1,"<$file") or die "Cannot open file: $!";
	open(FH2,">$cache") or die "Cannot open file: $!";
	while(<FH1>){
		s/(\xEF\xBB\xBF)|(\xFF\xEF)|(\xEF\xFF)//smg;
		my $line = $_;
		if($line && length($line)>3){
			#                log_printf($line);
			print FH2 $line;
		}
	}
	close FH1;
	close FH2;
	`mv $cache $file`;
}


#######################################################################################################
# 
# Parse heaser subs : return { 'header' => \@header, 'settings' => $settings, 'preview' => $preview  }
#
# preview : { 
# 						'header1'=> [value01,value02, ...],
# 						'header2'=> [value11,value12, ...],
# 						....
# 							}
#######################################################################################################
#my $returned = parse_csv_header('/home/vitaly/prf_test/test.csv',$settings,10);
##################################################
sub parse_csv_header {
	use Text::CSV;
	my ($file, $settings, $preview_count, $s) = @_;

	log_printf("parse_csv_header launched");

	my $cursor = 0;
	my @preview_buffer;
	my $preview;
	my @header;
	my @price;
	my $skip_header = 1;
	
	# to be able parse files with \r rdelimeter only
	my $buffer_file = $file.'_buffer';
	my $pattern = '\\\n';

	`cat $file | sed s/\\\r/$pattern/g  > $buffer_file && mv -f $buffer_file $file`;

	# check how many symbols does delimiter has, because Text::CSV uses only 1 char as delimiter
	# http://search.cpan.org/~makamaka/Text-CSV-1.13/lib/Text/CSV.pm#sep_char

	log_printf("the size of delimiter is ".length($s->{'delimeter'}));

	my $replace_with_x01 = undef;
	if (length($s->{'delimeter'}) > 1) {
		$replace_with_x01 = $s->{'delimeter'};
		$s->{'delimeter'} = "\x01";
		$settings->{'delimeter'} = "\x01";
	}

	my $file_enc = `file -ib $file`;

	log_printf("FILE ENC: ".$file_enc);

	if ($file_enc !~ /charset=utf-8/) {
		`recode latin1..utf8 $file`;
	}
	
	open PL, "<$file";
	binmode PL, ":utf8";
	while (<PL>) {
		chomp;
		s/^\s*?//s;
		s/\s*?$//s;
		s/\n$//s;
		next unless $_;
		if (defined $replace_with_x01) {
			s/$replace_with_x01/$s->{'delimeter'}/gs;
		}
		$price[$cursor] = $_;
		$preview_buffer[$cursor] = $_;
		$cursor++;

		if ($cursor > $preview_count) {
			last;
		}
	}
	close PL;

#	log_printf("tmp array: ".Dumper(@price));
	
	$settings->{'rdelimeter1'}='';
	$settings->{'rdelimeter2'}='';

	if ($price[0]=~/\r\n/) {
		$settings->{'rdelimeter1'}='selected';
		$settings->{'rdelimeter'}="\\r\\n";
	}
	if ($price[0]=~/\n/) {
		$settings->{'rdelimeter2'}='selected';
		$settings->{'rdelimeter'}="\\n";
	}
	
	$settings->{'delimeter'} = $s->{'delimeter'} ? $s->{'delimeter'} : $settings->{'delimeter'};

#	log_printf("delimeter ".$settings->{'delimeter'}."\nEscape character:".$settings->{'esc_c'});	
	
	$settings->{'delimeter'} = unprintable($settings->{'delimeter'});
	$settings->{'row_delimeter'} = unprintable($settings->{'row_delimeter'});

	log_printf("delimeter ".$settings->{'delimeter'}."\nEscape character:".$settings->{'esc_c'});
	
	shift @preview_buffer unless $hin{'first_row_as_header'};

	my $iteration = 0;
	my $tmp_hash;
	my $csv = Text::CSV->new({
		quote_char          => '"',
		escape_char         => $settings->{'esc_c'},
		sep_char            => $settings->{'delimeter'},
		eol                 => $settings->{'row_delimeter'},
		always_quote        => 0,
		binary              => 1,
		keep_meta_info      => 0,
		allow_loose_quotes  => 1,
		allow_loose_escapes => 1,
		allow_whitespace    => 0,
		blank_is_undef      => 0,
		verbatim            => 0,	
													 });
 	my $status;	

	$settings->{'delimeter'} = $replace_with_x01; # back previous delimiter (dima)
	$s->{'delimeter'} = $replace_with_x01; # back previous delimiter (dima)

	Encode::_utf8_on($price[0]);
	
#	log_printf("delimeter ".$settings->{'delimeter'}."\nEscape character:".$settings->{'esc_c'}."\n1st string is:".Dumper($price[0]));

	$status  = $csv->parse($price[0]);
	my ($cde, $str, $pos) = $csv->error_diag();
	log_printf('error diag:'.$str.' code:'.$cde.' at :'.$pos);
	@header = $csv->fields;
	for my $i (0 .. $#header) {
		$header[$i] =~ s/^\s*(.*)\s*$/$1/s;
	}
#	log_printf("header: ".Dumper(\@header));
	
	for my $row (@preview_buffer) {
		chomp $row;
		$iteration++;
#		log_printf('row: '.Dumper($row));
		$status  = $csv->parse($row);		
		$csv->error_diag();
		($cde, $str, $pos) = $csv->error_diag();
#		log_printf('error diag:'.$str.' code:'.$cde.' at :'.$pos);
		my @list = $csv->fields;
		my $iter = 0;
		my $t_hash;
#		log_printf('list:'.Dumper(\@list));
		for (@list) {
			$t_hash->{$iter} = $_; # if($_ ne "\n"); must work properly with Text::CSV
			$iter++;
		}
#		log_printf('t_hash:'.Dumper($t_hash));
		my $fl = 0;
		if ($iteration == 1) {
			if ($hin{'first_row_as_header'}) {
				$tmp_hash = $t_hash;
			}
			else {
				$fl = 1;
				my $sub_iteration = 0;
				for my $k (keys %$t_hash) {
					$tmp_hash->{$sub_iteration} = ($sub_iteration+1)." column";
					$sub_iteration++;
				}
			}
		}
		if ($iteration!=1 || $fl) {
			$fl = 0;
			for my $key (keys %$t_hash){
				push @{$preview->{$tmp_hash->{$key}}},$t_hash->{$key};
			}
		}
	}

#	log_printf(Dumper($preview));	
	
  $skip_header = 1;
  $skip_header = 0 if $hin{'first_row_as_header'}; #$hin{'header'};

  unless ($skip_header) {
    for (@header) {
			$settings->{'prodlevid'}              = $s->{'prodlevid'}        if $_ eq $s->{'prodlevid'};
			$settings->{'ean'}                    = $s->{'ean'}              if $_ eq $s->{'ean'};
      $settings->{'prod_id'}                = $s->{'prod_id'}          if $_ eq $s->{'prod_id'};
      $settings->{'supplier'}               = $s->{'supplier'}         if $_ eq $s->{'supplier'};
      $settings->{'euprice'}                = $s->{'euprice'}          if $_ eq $s->{'euprice'};
      $settings->{'stock'}                  = $s->{'stock'}            if $_ eq $s->{'stock'};
      $settings->{'euprice_incl_vat'}       = $s->{'euprice_incl_vat'} if $_ eq $s->{'euprice_incl_vat'};
			$settings->{'category'}						 	 	= $s->{'category'}				 if $_ eq $s->{'category'};
			$settings->{'picture'}                = $s->{'picture'}          if $_ eq $s->{'picture'};
			$settings->{'name'}									 	= $s->{'name'} 						 if $_ eq $s->{'name'};
			$settings->{'description'}						= $s->{'description'} 		 if $_ eq $s->{'description'};

			$settings->{'country_postfix'}					= $s->{'country_postfix'} 	 if $_ eq $s->{'country_postfix'};
  	}
	}
	elsif ($skip_header) {
		my $i=1;
		$settings->{'prodlevid'}              = $i.     " column" if !$settings->{'prodlevid'};
		$settings->{'prod_id'}                = ($i+1). " column" if !$settings->{'prod_id'};
		$settings->{'supplier'}               = ($i+2). " column" if !$settings->{'supplier'};
		$settings->{'euprice'}                = ($i+3). " column" if !$settings->{'euprice'}; 
		$settings->{'stock'}                  = ($i+4). " column" if !$settings->{'stock'};
		$settings->{'euprice_incl_vat'}       = ($i+5). " column" if !$settings->{'euprice_incl_vat'};
		$settings->{'ean'}                    = ($i+6). " column" if !$settings->{'ean'};
		$settings->{'category'}               = ($i+7). " column" if !$settings->{'category'};
		$settings->{'picture'}                = ($i+8). " column" if !$settings->{'picture'};
		$settings->{'name'}                   = ($i+9). " column" if !$settings->{'name'};
		$settings->{'description'}            = ($i+10)." column" if !$settings->{'description'};

		$settings->{'country_postfix'}         = ($i+11)." column" if !$settings->{'country_postfix'};

		for (@header) {
			$_ = "$i column";
			$i++;
		}
	}

#	log_printf(Dumper(\{ 'header' => \@header, 'settings' => $settings, 'preview' => $preview}));
	return { 'header' => \@header, 'settings' => $settings, 'preview' => $preview};
}

##################################################
##################################################

sub parse_xml_header {
	
	my ($filename,$settings,$preview_count) = @_; #input
	log_printf("parse_xml_header launched");
	my @header; #output
	my $preview;
	my $preview_buffer;
	my $local_debug = 0; #debuglevel 1|0
	
	# Require some XML modules
	use XML::Simple;
	
	# Reading file
	open(XML,"<$filename") or die "Can't open XML file for parsing: $!";
	my $file = join('',<XML>);
	close XML;
	
	# Parsing  
	my $parsed;
	unless (eval {$parsed =  XMLin($file, forcearray => 1) }){
		log_printf('USER INTERFACE : parse pricelist :: xml url to parse or invalid xml content');
	}
#	log_printf(Dumper($parsed));
	# Debug info
	if($local_debug){
		#log_printf(Dumper($parsed));
	}
	
	# Lets try to guess the structure of XML
	my $rows = scalar(keys %$parsed);

	if(($rows == 1 || $rows>1) && !($settings->{'xml_path'} || $hin{'xml_path'})){
		# That is great. We have more or less understandable structure
		# The structure of such XML is like:
		#  <?xml version ?>
		#  <ProductsList>
		#  <Product >....</Product>
		#  ........
		#  <Product >....</Product>
		#  </ProductsList>
		#  </xml>
		# Lets take the first entry of the refernce to the array and use that as a header
		#log_printf("Rows: $rows at $filename. That is great. We have more or less understandable XML structure");
		my $header; # store the array reference item here
		my $last_flag = 0;		
		for(keys %$parsed){
			if(ref($parsed->{$_}) ne 'ARRAY' || ref($parsed->{$_}->[0]) ne 'HASH' ){
				next;
			}else{
				$last_flag=1;
			}
			# a bit tricky here :) we have only one key
			$header = $parsed->{$_}->[0]; # catched
			for( my $cursor = 0; $cursor < $preview_count;$cursor++){
				push @{$preview_buffer},$parsed->{$_}->[$cursor];
			} 
			last if $last_flag;
		}
		
#		log_printf("Preview buffer: ".Dumper($preview_buffer));
		# Debug info
		if($local_debug){
			#log_printf(Dumper($header));
		}
		# So let feed @header array using XML attributes of the current element
		# If nested elements are present it may fail
		# So let feed @header array using XML attributes of the current element
		# If nested elements are present it may fail
		for(keys %$header){
			push @header, $_;
			for( my $cursor = 0; $cursor < $preview_count;$cursor++){
				if(ref($preview_buffer->[$cursor]->{$_}) eq 'ARRAY'){
					if(ref($preview_buffer->[$cursor]->{$_}->[0]) eq 'HASH'){ # this type of if is to prevent text 'HASH(0x123213)' instead of values
						push @{$preview->{$_}},'';
					}else{
						push @{$preview->{$_}},$preview_buffer->[$cursor]->{$_}->[0];
					}
				}elsif(ref($preview_buffer->[$cursor]->{$_}) eq 'HASH'){
					push @{$preview->{$_}},'';
				}else{
					if(ref($preview_buffer->[$cursor]->{$_}) eq 'HASH'){
						push @{$preview->{$_}},'';
					}else{
						push @{$preview->{$_}},$preview_buffer->[$cursor]->{$_};
					}
				}
			}
		}
		# Debug info
		if($local_debug){
			#log_printf(Dumper(\@header));
		}
		return { 'header' => \@header, 'preview' => $preview};
		
	}else{
		if($settings->{'xml_path'} || $hin{'xml_path'}){
			my $xml_path = $settings->{'xml_path'};
			$xml_path = $xml_path ? $xml_path : $hin{'xml_path'};
			$xml_path =~ s/^\<\w+\>\<//;
			$xml_path =~ s/\>$//;
			log_printf("xml path: ".$xml_path);
			my @path_arr = split(/\>\</,$xml_path);
			my $parsed2 = $parsed;
			for my $step (@path_arr){
				$parsed2 = $parsed2->{$step}[0] if ref($parsed2) eq 'HASH' && $parsed2->{$step} && ref($parsed2->{$step}) eq 'ARRAY';
			}
#			log_printf("parsed2: ".Dumper($parsed2));
			my $rows = ref($parsed2) eq 'HASH' ? scalar(keys %$parsed2) : 0;
			if($rows == 1){
				my $header;
				for(keys %$parsed2){
					if(scalar($parsed2->{$_})=~/ARRAY/){
						$header = $parsed2->{$_}->[0];
						for( my $cursor = 0; $cursor < $preview_count;$cursor++){
			        push @{$preview_buffer},$parsed2->{$_}->[$cursor];
						}
#			log_printf("Preview_buffer: ".Dumper($preview_buffer));
					}
				}
				for(keys %$header){
					push @header, $_;
      		for( my $cursor = 0; $cursor < $preview_count;$cursor++){
						if(ref($preview_buffer->[$cursor]->{$_}) eq 'ARRAY'){
							push @{$preview->{$_}},$preview_buffer->[$cursor]->{$_}->[0];
						}else{
							push @{$preview->{$_}},$preview_buffer->[$cursor]->{$_};
						}
      		}
				}
				return {'header' => \@header, 'preview' => $preview};
			}else{
				log_printf("Rows: $rows at $filename. Seems that functionality should be developed");
				return {'header' => ['wrong structure of file'], 'preview' => {'wrong structure of file'}};
			}
		}else{
			# That is not good.
			# Seems that functionality should be developed
			log_printf("Rows: $rows at $filename. Seems that functionality should be developed");     
			return {'header' => ['wrong structure of file'], 'preview' => {'wrong structure of file'} };
			# exit(0);
		}
	}
}
##################################################
##################################################
sub parse_excel_header
{
	my ($file,$rah,$preview_count)=@_;
	log_printf("parse_excel_header launched");
	my $oExcel = new Spreadsheet::ParseExcel;
	log_printf("spreadsheet created... file to be book created: ".$file);
	my $oBook  = $oExcel->Parse($file);
	log_printf("book created");
	my ($R, $C, $Sheet,$WC);
	my $csv='';
	my $cols=0;
	my $bool=0;
	for(my $iSheet=0; $iSheet < $oBook->{SheetCount}; $iSheet++){
		my $SheetName = $oBook->{Worksheet}[$iSheet];
		for(my $R=$SheetName->{MinRow}; defined $SheetName->{MaxRow} && $R <= $SheetName->{MaxRow};$R++){
			for(my $C=$SheetName->{MinCol}; defined $SheetName->{MaxCol} && $C <= $SheetName->{MaxCol};$C++){
				$Sheet=$SheetName->{Cells}[$R][$C];
				$Sheet=$Sheet->Value if $Sheet;
				$csv.=$Sheet.";" if $Sheet;
				$bool=1 if $Sheet;
				$cols=$C if $Sheet && $C > $cols;
			}
			$csv.="\n" if $bool==1; 
			$bool=0;
		} 
	}
# log_printf("temporary csv: ".Dumper($csv));
	my @header;
	my $preview;
	my ($cur,$pcar,$ccar)=(0,0,0);
	my $sh;
	if($rah){
		log_printf("... parsing ...");
		my $hrow=$oBook->{Worksheet}[0];
		for(my $c=$hrow->{MinCol};defined $hrow->{MaxCol} && $c <= $hrow->{MaxCol};$c++){
			$sh = $hrow->{Cells}[0][$c];
			$sh = $sh->Value if $sh;
			push @header, $sh if $sh;
			####
			if($sh){
				for(my $cursor = 1;$cursor < $preview_count;$cursor++){
					my $example = $hrow->{Cells}[$cursor][$c];
					$example = $example->Value if $example;
					$example = $example ? $example : '';
					push @{$preview->{$sh}},$example;
				}
			}
			####
		} 
	}else{
		my $hrow=$oBook->{Worksheet}[0];
		while($cur!=$cols && $cur<1000){
			$ccar=chr(65+$cur);
			push @header, "Column $ccar";    
			####
			for(my $cursor = 0;$cursor < $preview_count;$cursor++){
				my $example = $hrow->{Cells}[$cursor][$cur];
				$example = $example->Value if $example;
				$example = $example ? $example : '';
				push @{$preview->{"Column $ccar"}},$example;
			} 
			####
			$cur++;
		}
	}
	return {'header' => \@header, 'preview' => $preview };
}

sub test_tables{
	sub create_aaa_test{
		my $table=shift;
		do_statement("DROP TABLE IF EXISTS aaa_$table");
		do_statement("CREATE TABLE aaa_$table LIKE $table");
		do_statement("INSERT INTO aaa_$table SELECT * FROM $table");
	}
	create_aaa_test('tmp_shops_imported_product_data');
}

##########################################################################################
##########################################################################################
##########################################################################################
END{}

1;

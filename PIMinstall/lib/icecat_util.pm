package icecat_util;

#$Id: icecat_util.pm 3789 2011-02-04 13:33:32Z alexey $

use strict;
use LWP::UserAgent;
use XML::Simple;
use Unicode::String qw (utf8 latin1);
use Unicode::Map8;
use Digest::MD5 qw(md5 md5_base64);
use HTTP::Request;
use LWP::UserAgent;

use atomcfg;
use Data::Dumper;
use atomlog;
use icecat_client;
use atomsql;
use atom_mail;
use atom_misc;
use atom_util;
use process_manager;
use HTTP::Request::Common;
use HTML::Entities;
use vars qw ($CLASS_MYISO);
use utf8;
BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
								&post_message
								&build_message
								&gzip_data
								&ungzip_data
								&utf82latin
								&latin2utf8
								&back_parse

								&compress_data_by_ref
								&get_corrected_product_feature_value
								
								&xml_out
								&str_xmlize
								&str_xmlize8
								&cat_mem_stat
								&gzip_data_by_ref
								&convert_to_jpg
								&get_files

							 &remote_mv
							 &cp2remote
							 &add_image
							 &source_message
							 &get_ftp_newest_file
							 &xml2csv
							 &quick_checkExcel2007
							 &mail_atom_template
							 &translate_from_google
							 &encode_url
							 &remove_tags_except
							 &remove_tags_content_except
							 &copyToDateDir
							 &get_rating_prop
							 &cmp_symbols
							);
 
	$CLASS_MYISO = Unicode::Map8->new('ISO_8859-1') || die;
#	$CLASS_MYISO = Unicode::Map8->new('MYISO_8859-1') || die;

}

sub encode_url{
	my $str=shift;
	$str =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
	return $str
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


sub get_corrected_product_feature_value {
	my ($value, $langid) = @_;
	my $yes = 'yes';
	my $no = 'no';

	if (lc(&trim($value)) eq $yes) {
		return 'Y';
	} elsif (lc(&trim($value)) eq $no) {
		return 'N';
	}

	if ($langid) {

		my $result  = &do_query("select value from feature_values_vocabulary where TRIM(value) != '' AND key_value = 'Yes' and langid=".&str_sqlize($langid));
		if($result->[0] && $result->[0][0] ne ''){
			$yes = $result->[0][0];
		}

		my $result  = &do_query("select value from feature_values_vocabulary where TRIM(value) != '' AND key_value = 'No' and langid=".&str_sqlize($langid));
		if($result->[0] && $result->[0][0] ne ''){
			$no = $result->[0][0];
		}

		if (lc(&trim($value)) eq lc($yes)) {
			return 'Y';
		} elsif (lc(&trim($value)) eq lc($no)) {
			return 'N';
		}

	}
	return $value;
}


my $tmp_path = '/tmp/';
# warning this function delete source of conversion if conversion happens
sub convert_to_jpg{
	my ($src)=@_; 
	my $file_info;
	if(!(-e $src)){
		return 0;
	};
	my $dst=$src;
	$file_info=`/usr/bin/file $src`;
	if($file_info!~/JPEG image data/){
		$dst=~s/\.\w{3,4}$/.jpg/;
		`convert -quality 99 $src jpeg:$dst`;
		`/bin/rm -f $src`;		
	}
	return $dst;
}

sub quick_checkExcel2007{
	my ($candidate)=@_;
	my $tmp_dir=$atomcfg{'session_path'}.'checkExcel2007_'.rand();
	`rm -d $tmp_dir` if -d $tmp_dir;
	`mkdir $tmp_dir`;
	`unzip -o '$candidate' -d '$tmp_dir'`;
	my $workbook_xml=eval{XML::XPath->new($tmp_dir.'/xl/workbook.xml')};
	my $workbook_rels_xml=eval{XML::XPath->new($tmp_dir.'/xl/_rels/workbook.xml.rels')};
	
	`rm -R $tmp_dir` if -d $tmp_dir;		
	if(!$workbook_rels_xml and !$workbook_rels_xml){
		return ''; 
	}else{
		return 1;		
	};
}

sub add_image {
	my ($src_file, $dest_delta, $dest_array, $new_name, $no_rm) = @_;

	my $bg = 0; # set background_mode

	return undef unless ($src_file);

	my ($cmd, $src_path, $old_name, $result, $hash, $out, $out_default);
	
	$dest_array = [ $dest_array ] if (ref($dest_array) ne 'ARRAY');

	# rename if needed
	$src_file =~ /^(.*\/)(.*?)$/;
	$src_path = $1;
	$old_name = $2;
	
	if ($new_name) {
		$cmd = "/bin/cp -f ".$src_path.$old_name." ".$src_path.$new_name;
		&log_printf($cmd);
		`$cmd`;
		$src_file = $src_path.$new_name;
		$old_name = $new_name;
	}
	
	foreach my $dest (@$dest_array) {
		if ($dest->{'toXML'}) { # is to XML path?
			$out = (($dest->{'host'})?$dest->{'host'}:$atomcfg{'host'}).$dest_delta.$old_name;
		}
		$out_default = (($dest->{'host'})?$dest->{'host'}:$atomcfg{'host'}).$dest_delta.$old_name;

		if (($dest->{'host'} =~ /^http:\/\//) && (!($dest->{'local'}))) { # remote cp
			$hash = {
				'host' => $dest->{'host'},
				'path' => $dest->{'path'}.$dest_delta,
				'login' => $dest->{'login'}
			};
			$result = &cp2remote($src_file, $hash, {'bg' => $bg});
			if ($result) {
				&sendmail(Dumper($src_file).Dumper($hash),$atomcfg{'bugreport_email'},$atomcfg{'bugreport_from'},'scp failed');
			}
		}
		else { # simple cp
			$cmd = "/bin/cp -f ".$src_file." ".$dest->{'path'}.$dest_delta;
			&log_printf($cmd);
			if ($bg) {
				&run_bg_command($cmd);
			}
			else {
				`$cmd`;
			}
		}
	}

	if ($no_rm) {
		$cmd = "/bin/rm -f ".$src_file;
		&log_printf($cmd);
		`$cmd`;
	}

	return $out || $out_default;
} # sub add_image

sub cp2remote {
	my ($file, $host, $attr) = @_;
	$host->{'host'} =~ s/^http:\/\///;
	$host->{'host'} =~ s/\/+$//;
	&log_printf("/usr/bin/scp -qrB $file $host->{'login'}\@$host->{'host'}:$host->{'path'}");

	# temp! collect images size statistics
	my @attrs = stat($file);
	open TMP, ">> ".$atomcfg{'base_dir'}."/logs/image_log";
	binmode TMP, ":utf8";
	print TMP &POSIX::time()."\t".$file."\t".$attrs[7]."\n";
	close TMP;
	# temp! end of ...

	if ($attr->{'bg'}) {
		&run_bg_command("/usr/bin/scp -qrB ".$file." ".$host->{'login'}."@".$host->{'host'}.":".$host->{'path'});
		return undef;
	}
	else {
		return system("/usr/bin/scp","-qrB",$file,$host->{'login'}."@".$host->{'host'}.":".$host->{'path'});
	}
} # sub cp2remote

sub remote_mv {
	my ($file, $src, $dest, $host) = @_;
	my $cmd = system("/usr/bin/ssh",$host->{'login'}."@".$host->{'url'},"\"/bin/mv -f ".$src.$file." ".$dest."\"");
#	&log_printf($cmd);
	`$cmd`;
} # sub remote_mv

sub post_message {
	my ($message, $url, $no_unzip) = @_;
	
	my $ua 	= new LWP::UserAgent;
	$ua->timeout(6000);
	my $req 	= new HTTP::Request 'POST', $url;
	$req->content_type('application/x-www-form-urlencoded'); 
#&log_printf($message);
	$message = &gzip_data($message);
	
	$req->content($message);
	
	my $res = $ua->request($req);
	
	my $message_response = $res->content;		
	
	if (!($message_response =~m/^\<\?xml/) && !$no_unzip) {
		$message_response = &ungzip_data($message_response);
	}
	
#&log_printf($message_response);
	
	return $message_response;
}

sub source_message {
	return "<!-- source: " . $atomcfg{'company_name'} . " " . &atomsql::do_query("select year(curdate())")->[0][0] . " -->";
}

sub build_message {
	my ($hash, $param) = @_;
	
	my $xmldecl = &atom_misc::xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-interface_request.dtd\">".
		"\n".&source_message();
	if ($param eq "request") {
    $xmldecl = &atom_misc::xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-interface_request.dtd\">".
			"\n".&source_message();
	}
	if ($param eq "response") {
    $xmldecl = &atom_misc::xml_utf8_tag."<!DOCTYPE ICECAT-interface SYSTEM \"".$atomcfg{host}."dtd/ICECAT-interface_response.dtd\">".
			"\n".&source_message();
	}

	my $message = &xml_out( $hash,
													{
														xmldecl 	=> $xmldecl,
														rootname	=> 'ICECAT-interface',
														key_attr	=> {'Measure' 			=> 'ID',	
																					'Name'					=> 'ID',
																					'Description'	=> 'ID',
																					'Sign'					=> 'ID',
																					'Feature'			=> 'ID',
																					'Category'			=> 'ID',
																					'Supplier'			=> 'ID',
																					'Product'			=> 'ID',
																					'Distributor'			=> 'ID',
#								 'CategoryFeatureGroup'=> 'ID' 
																					'DescribeProductResponse' => 'ID',
#								 'ComplaintProductResponse' => 'ID'
#								 'ProductFamily' => 'ID'
														}
													}
		);

	undef $hash;
	return $message;
}

sub gzip_data {
	my ($data,$filename,$binmode) = @_;

	my ($cmd);

	$binmode = "utf8" unless $binmode;

	my $dirname = $tmp_path; 
	my $gz = $dirname."/tmp-".&make_code(28).".gz";
	
	if ($filename) {
		$cmd = "/bin/mkdir -p ".$dirname."/report_".$$;
		`$cmd`;
		open SRC, ">".$dirname."/report_".$$."/".$filename;
		binmode SRC, ":".$binmode;
		print SRC $data;
		close SRC;
		$cmd = "gzip -c9 ".$dirname."/report_".$$."/".$filename." > ".$gz;
		`$cmd`;
		$cmd = "/bin/rm -rf ".$dirname."/report_".$$;
		`$cmd`;
	}
	else {
		open(GZIP,"|gzip -c9 > ".$gz);
		binmode(GZIP,":".$binmode);
		print GZIP $data;
		close(GZIP);
	}
	undef $data;
	my $compdata = undef;
	my $buffer;
	open(GZIPPED,"<".$gz);
	binmode GZIPPED, ":bytes";
  while(read(GZIPPED,$buffer,4096)){ $data .= $buffer;} 
	close(GZIPPED);
	system("rm",$gz);
 	return $data;
}

sub gzip_data_by_ref {
 my ($data) = @_;
 my $dirname = $tmp_path; 
 my $gz = $dirname."/tmp-".&make_code(28).".gz";
 open(GZIP,"|gzip -c9>$gz") || &log_printf("Can't open gzip: $!"); 
 binmode (GZIP,":utf8");
 print GZIP $$data;
 close(GZIP);
 undef $$data;
 undef $data;
 my $compdata = '';
 $data = \$compdata;
 my $buffer;
 open(GZIPPED,"<$gz"); 
  &cat_mem_stat(__LINE__.'-'.__FILE__);
  while(read(GZIPPED,$buffer,4096)){ $$data .= $buffer;} 
 close(GZIPPED);
 system("rm",$gz);
 return $data;
}

sub compress_data_by_ref {
	my ($dataref, $filename, $binmode, $type) = @_;

	$filename =~ s/^.*\///; # funny bug was found during `1027336: return export/<level>/<lang>/<product_id>.xml.gz as gzipped content`

	$binmode = 'utf8' unless $binmode;
	
	# select proper filter
	
	my $tmp = $tmp_path."/tmp-".&make_code(28);
	my $compress;
	if ($type eq 'zip') { # zip
		use IO::Compress::Zip qw($ZipError);
		$compress = new IO::Compress::Zip $tmp, Name => $filename || &log_printf("Can't open file: $ZipError, $!");
	}
	elsif ($type eq 'bz2') { # bz2
		use IO::Compress::Bzip2 qw($Bzip2Error);
		$compress = new IO::Compress::Bzip2 $tmp, Name => $filename || &log_printf("Can't open file: $Bzip2Error, $!");
	}
	else { # gz by default
		use IO::Compress::Gzip qw($GzipError);
		$compress = new IO::Compress::Gzip $tmp, Name => $filename || &log_printf("Can't open file: $GzipError, $!");
	}

#	&log_printf("data = ".Dumper($dataref));

	binmode($compress,':'.$binmode);
	print $compress $$dataref;
	close $compress;
	undef $$dataref;
	undef $dataref;
	
	my $buffer;
	$$dataref = '';
	open COMPRESSED, "<".$tmp;
	binmode COMPRESSED, ":raw";
#  &cat_mem_stat(__LINE__.'-'.__FILE__);
	while (read(COMPRESSED,$buffer,4096)) {
		$$dataref .= $buffer;
	}
	close COMPRESSED;
	system("rm",$tmp);

#	&log_printf("cdata = ".Dumper($dataref));
	
	return $$dataref;
}

sub cat_mem_stat
{
my ($mark) = @_;
#open(FH, "</proc/$$/status");
#my $dump = join('', grep /VmSize/i, <FH>);
#close(FH);
#&log_printf("$mark status: pid=$$ ".$dump);
}

sub ungzip_data
{
 my ($data) = @_;
 my $dirname = $tmp_path; 
 my $ugz 	= $dirname."/tmpu-".&make_code(28);
 my $gz 	= $ugz.".gz";
 
 open(DATA, ">$gz");
 binmode(DATA,":bytes");
 syswrite(DATA, $data, length($data));
 close(DATA);
 
 system("gzip", "-d", $gz);
 
 my $ugzip = '';
 
 open(UGZIP,"<$ugz");
 binmode(UGZIP,":utf8");
 while(<UGZIP>){
  $ugzip .= $_;
 }
 close(UGZIP);

 
  system("rm",$ugz);
 return $ugzip;
}

sub make_code 
{
	my $n = shift;
	my ($i,$s,$c);
	$s = '';

	for ($i = 0; $i < $n; $i++) {
		$c = int(rand(62));
		if ($c < 26) { $c = chr(ord('a')+$c); }
		elsif ($c < 52) { $c = chr(ord('A')+$c-26); }
		elsif ($c < 62) { $c = chr(ord('0')+$c-52); }
		$s .= $c;
	}
	
	return $s;
}

sub back_parse
{
my ($node, $sub) = @_;


if(ref($node) eq 'ARRAY'){
 for(my $i = 0; $i - 1< $#$node; $i++){ 
 if(!ref($node->[$i])){
   $node->[$i] = &{$sub}($node->[$i]);
	} else {
   &back_parse($node->[$i], $sub); 
	}
 }
}

if(ref($node) eq 'HASH'){
 foreach my $subnode(keys %$node){ 
#   print $subnode."\n";
 if(!ref($node->{$subnode})){
	 if($subnode ne '__plain_xml'){
		 my $utf8_val 	= &{$sub}($node->{$subnode});
		 my $utf8_name 	= &{$sub}($subnode); 
  	 delete $node->{$subnode};
		 $node->{$utf8_name}	= $utf8_val;
#		 $node->{$subnode}  = &{$sub}($node->{$subnode});
	 }
	} else {
   &back_parse($node->{$subnode}, $sub); 
	}
 }
}

}

use Encode;

sub latin2utf8
{
my ($string) = @_;

my $octets = encode("iso-8859-1", $string);
my $l = $CLASS_MYISO->tou($octets);
my $utf8 =  $l->utf8;
return $utf8;
}


sub utf82latin
{
my ($string) = @_;

my $u = utf8($string);

#return '' unless ($CLASS_MYISO);

my $ll  = $CLASS_MYISO->to8($u->ucs2);
return $ll;
}


sub xml_out {
	my ($ref, $options) = @_;

	my $plain_xml = $ref->{'__plain_xml'};
	$ref->{'__plain_xml'} = undef;	
	
	my $xml;
	
	if (!$plain_xml) {
		$xml = &my_xml_out($options->{'rootname'}, $ref, 1, $options);
# &log_printf(Dumper($ref));
	}
	
	if ($options->{'xmldecl'}) {
		$$xml =~s/^/$options->{'xmldecl'}."\n"/e;
	}
	
	if ($plain_xml) {
		
		$$plain_xml ="$options->{'xmldecl'}\n<$options->{'rootname'}>\n".$$plain_xml."</$options->{'rootname'}>\n";
		
		return $$plain_xml;
	}
#my $xml = $plain_xml;
	
	return $xml;
}

sub my_xml_out {
	my ($name, $ref, $cnt, $options, $prev) = @_;
	
#&log_printf("name = $name, ref = ".Dumper($ref));
	
	my $spacer = (' ' x ($cnt));
	
	my ($params, $body, $c_flag);
	my $rbody = '';
	
	$body = \$rbody;
	
	if (ref($ref) eq 'HASH') {
		
###
		
		if ($options->{'key_attr'}->{$name} &&
				ref($ref) eq 'HASH'&&
				!$ref->{'__id_expanded'}&&
				ref($prev) eq 'HASH'&&
				!$ref->{$options->{'key_attr'}->{$name}}){
			# should coerce to array
			my $new_ref = [];
			my $expand = 0;
			
#			foreach my $key (sort keys %{$ref}) {
			foreach my $key (keys %{$ref}) {
				if (ref($ref->{$key}) eq 'HASH') {
					if ($key ne 'content') {
						$ref->{$key}->{$options->{'key_attr'}->{$name}} = $key;
						$expand = 1;
					}
					else {
						
					}
				}
				elsif (ref($ref->{$key}) eq 'ARRAY') {
# do not expand this entry
					$expand = 0; 
				}
				else {
					# scalar
					if ($key ne 'content') {
						$expand = 1;
						$ref->{$key} = {
							'content'	=> $ref->{$key},
							$options->{'key_attr'}->{$name} => $key
						};
					}
				}
				if ($expand) {
					$ref->{$key}->{'__id_expanded'} = 1;
					push @$new_ref,  $ref->{$key};
				}
			}
			if ($expand) {
				$ref = $new_ref;
			}
#print Dumper($ref);
		}
		
###

	}	
	
	if (ref($ref) eq 'HASH') {
		
		my @hash_keys = keys %$ref;
		
#		if ($#hash_keys == -1) {
#		$$body =~s/^/'<'.$name/e;
#		$$body .= "/>\n";
#		}
		
		#
		# add sorting order to generating XML tags list
		#
		# 1024435: Add restricted values subtags to FeaturesList.xml (19.08.2010)
		#

		foreach my $key (sort @hash_keys) {
			
			if (ref($ref->{$key}) eq '') {
				if ($key ne 'content' &&
						$key ne '__id_expanded'&&
						$key ne '__plain_xml') {
					$params .= " ".$key."=\"".&str_xmlize($ref->{$key}).'"';
				}
			}
			else {
				$c_flag = 1;
				
				my $empty = 0;
				my $arr = $ref->{$key};

				if (ref($arr) eq 'HASH') {
					my @arr = keys %$arr;
					$arr = \@arr;
				}

				if (ref($arr) eq 'ARRAY' && $#$arr == -1) {
					$empty = 1;
#		$$body =~s/^/'<'.$key/e;
					$$body .= "$spacer<$key/>\n";
					
				}
				else {
					my $extra_ref = &my_xml_out($key,$ref->{$key}, $cnt+1, $options, $ref);
					$body = &concat_scalar_refs($body, $extra_ref);
				}
				
#	 delete $ref->{$key};
			}
		}
		
		if (ref($ref->{'content'}) eq '' &&
				$ref->{'content'}) {
			if ($$body) {
				$params .= " content=\"".&str_xmlize($ref->{'content'}).'"';
			}
			else {
				my $tmp = &str_xmlize($ref->{'content'});
				$body = \$tmp;
			}
		}
		
		if (ref($ref->{'__plain_xml'}) eq '' &&
				$ref->{'__plain_xml'}){
			$body = $ref->{'__plain_xml'}.$body;
		}
		
		if (ref($ref->{'__plain_xml'}) eq 'SCALAR' &&
				$ref->{'__plain_xml'}) {
			
			my $saved_body = $body;
			$body = $ref->{'__plain_xml'};
			
			$$body =~s/^/$$saved_body/;
			$$body .= $$saved_body;
			
		}
		
	}
	
	
	if (ref($ref) eq 'ARRAY') {
		if (!$name) {
			$name = 'anon';
		}
		
		
		foreach my $elem (@$ref) {
			my $tmp = &my_xml_out($name, $elem, $cnt+1, $options, $ref);
			$body = &concat_scalar_refs($body, $tmp);
		}

		return $body; 
	}
	
	
	if (ref($ref) eq '') {
		if (!$name) {
			$name = 'anon';
		}
		$$body = &str_xmlize($ref);
	}
	
	
	if ($$body) {
		if ($c_flag) {
			
			my $str = $spacer."<".$name.$params.">\n";
#		$$body =~s/^/$spacer."<".$name.$params.">\n"/e;
			$body = &concat_scalar_refs(\$str, $body);
			
			$$body .= $spacer."</".$name.">\n";

			return $body;		
		}
		else {
#    use utf8;
#    $name = &latin2utf8($name);
			my $str = $spacer."<".$name.$params.">";
			$body = &concat_scalar_refs(\$str, $body);		
#		$$body =~s/^/$spacer."<".$name.$params.">"/e;
			$$body .= "</".$name.">\n";

			return $body;
		}
	}
	else {
		if ($params) {
			$params = $spacer."<".$name.$params."/>\n";

			return \$params;
		}
		my $empty = '';

		return \$empty;
	}
	
}

sub str_xmlize {
	my $str = shift;
	return undef unless (defined $str);

	$str =~ s/\&/&amp;/g;
	$str =~ s/\"/&quot;/g;
	
	$str =~ s/</&lt;/g;
	$str =~ s/>/&gt;/g;
	$str =~ s/\n/\\n/g;
#	$str =~ s/\x1/</g;
#	$str =~ s/\x2/>/g;
  $str =~ s/[\x0-\x1D]//gm;
  $str=~s/[\x{E}-\x{1F}]/\s/gs;

	return $str;
}

sub str_xmlize8
{
	my $str = shift;
	
	$str = &str_xmlize($str);
	$str = &latin2utf8($str);
	
	return $str;
}

sub concat_scalar_refs
{
my ($body, $tmp) = @_;
  if(length($$tmp) > length($$body)){
	 my $t = $body;
	 $body = $tmp;
	 $$body =~s/^/$$t/;
	} else {
	 $$body .= $$tmp;
	}
return $body;
}

sub get_files {
	my ($path, $regexp,$isdir) = @_;
	my @files;
	opendir(DIR, $path) or return undef;
	if ($isdir) {	
		@files = grep {!/^\./ && /$regexp/ && -d $path."/".$_ } readdir(DIR);
#		@files = grep {!/^\./ && -d $path."/".$_ } readdir(DIR);
	}
	else {
		@files = grep {!/^\./ && /$regexp/ && -f $path."/".$_ } readdir(DIR);
#		@files = grep {!/^\./ && -f $path."/".$_ } readdir(DIR);
	}
	close DIR;
	print " regexp = ".$regexp."\n";
#	if ($regexp) {
#		my @nfiles;
#		print "files = ".Dumper(@files);
#		for (my $i=0;$i<$#files;$i++) {
#			
#			if ($files[$i] =~ /$regexp/) {
#				push @nfiles, $files[$i];
#			}
#		}
#		return \@nfiles;
#	}
#	else {
		return \@files;
#	}
}

sub get_ftp_newest_file{	
	my ($ftp_dir,$user,$password)=@_;
	my $listing_file="/tmp/listing.html";
	my $cmd="wget -q --user=$user $ftp_dir --password=$password -O $listing_file";
	`$cmd`;
		
	open(LISTING_FILE,$listing_file);
	my @listing_arr=<LISTING_FILE>;
	my $listing_cont=join("\n",@listing_arr);
	close(LISTING_FILE);
	$listing_cont=~/<pre>(.+)<\/pre>/s;
	my @file_strs=split(/\n/,$1);
	my @all_files;
	my @curr_month_files;
	use HTML::Entities;
	use Time::Piece;
	my $curr_time=localtime;
	""=~/(.*)/;#it empties $1 varable
	foreach my $file_str (@file_strs){
		$file_str=~s/^\s*(.*?)\s*$/$1/;
		next() unless $file_str;
		""=~/(.*)/;#it empties $1 varable
		$file_str=~/<a.+>(.+)<\/.+>/;
		my $file_name=HTML::Entities::decode_entities($1)."\n";
		$file_name=~s/^\s*(.*?)\s*$/$1/;
		""=~/(.*)/;#it empties $1 varable
		$file_str=~/^(.+)<a/;
		my $date_file=$1;
		$date_file=~s/^[\s]+//gs;
		$date_file=~s/[\s]+$//gs;
		my @date_pieces=split(/[\s]+/,$date_file);
		my $file_time=eval("Time::Piece->strptime('".$date_pieces[0]."-".
													$date_pieces[1]."-".
													$date_pieces[2]." ".
													$date_pieces[3]."','%Y-%b-%d %H:%M')");
		next unless($file_time);
		
		my $m_name=uc($curr_time->month);
		if($date_pieces[4] eq 'File' and uc($file_name)=~/$m_name/){			
			push(@curr_month_files,{'time'=>$file_time->epoch(),'name'=>$file_name});
		}elsif($date_pieces[4] eq 'File'){
			push(@all_files,{'time'=>$file_time->epoch(),'name'=>$file_name});
		}
		 
	}
	if(scalar(@curr_month_files)>0){
		@curr_month_files=sort {$a->{'time'} < $b->{'time'}} @curr_month_files;
		return $ftp_dir.$curr_month_files[0]->{'name'};
	}elsif(scalar(@all_files)>0){
		@all_files=sort {$a->{'time'} < $b->{'time'}} @all_files;
		return $ftp_dir.$all_files[0]->{'name'};
	}
}

sub xml2csv{
	my ($xml_file,$csv_file,$preview_length)=@_;
	use SAXs::StructureCollector;
	use XML::XPath;
	use XML::XPath::XMLParser;
	use XML::SAX::ParserFactory;
	my $handler=SAXs::StructureCollector->new;
	my $parser = XML::SAX::ParserFactory->parser(Handler => $handler);
	my $stat=eval{$parser->parse_uri($xml_file)};
	return '' unless $stat;
	my $xp = XML::XPath->new(filename => $xml_file);
	
	#print Dumper($handler->{repeatTags});
	open(CSV,">$csv_file");
	my %paths=%{$handler->{repeatTags}};
	my $csv_header=$handler->{csvHeader};
	my $csv_obj=Text::CSV->new({
					quote_char          => '"',
					escape_char         => "\\",
					sep_char            => ",",
					eol                 => "\n",
					always_quote        => 0,
					binary              => 1,
					keep_meta_info      => 0,
					allow_loose_quotes  => 1,
					allow_loose_escapes => 1,
					allow_whitespace    => 0,
					blank_is_undef      => 0,
					verbatim            => 0				
				  });
				  
	my @header_row;
		foreach my $header_path(keys(%{$csv_header})){
			my $header_path_short=$header_path;
			$header_path_short=~/([^\/]+\/[^\/]+$)/;
			$header_path_short=$1 if $1;
			$header_row[$csv_header->{$header_path}->{'order'}]=$header_path_short;
			foreach my $attr(keys %{$csv_header->{$header_path}->{'attrs'}}){
				$header_row[$csv_header->{$header_path}->{'attrs'}->{$attr}->{'order'}]=$header_path_short.$attr;
			};
		}
	my $preview_str;
	my $csv_str;
	$csv_obj->combine(@header_row);
	$preview_str=$csv_obj->string();
	
	my %csv_paths=%{$handler->{csv_paths}};
	
	my $preview_csv;
	use POSIX;
	if(scalar(keys(%csv_paths))>0){
		$preview_csv=&floor($preview_length/scalar(keys(%csv_paths)));
	}else{
		$preview_csv=$preview_length;
	}
	if(!$preview_csv){
		$preview_csv=scalar(keys(%csv_paths));
	}
	
	my @root_childs."\n";
	 
	foreach my $root_child_path(keys %{$handler->{root_childs}}){
		my $child_el=$xp->find($root_child_path);
		if(scalar(@{$child_el})==1){
			push(@root_childs,{'el'=>$child_el->[0],'path'=>$root_child_path});
		}
	};	
	foreach my $csv_path(sort {$a cmp $b} keys(%csv_paths)){
		if(!$paths{$csv_path}){# this is  a tag from that we start to write csv row
			&log_printf("---->>>>>>>>>>CSV tag: ".$csv_path);
			my @csv_childs=();
			my $rep_parens_childs={};
			my $branch_childs={};
			my $top_rep_parent="";	  
			foreach my $tag_path(keys(%paths)){
				if($tag_path=~/^\Q$csv_path\E/ and $tag_path ne $csv_path){# this is child of current csv path
					my $curr_child_path=$tag_path;
					$curr_child_path=~s/^\Q$csv_path\E//;
					push(@csv_childs,$curr_child_path);
				}elsif($csv_path=~/^\Q$tag_path\E/ and $tag_path ne $csv_path and $paths{$tag_path} eq 'REP_PARENT'){
					$rep_parens_childs->{$tag_path}=[];
				};
			}
			foreach my $rep_parent_path(keys(%{$rep_parens_childs})){
					#print $rep_parent_path."\n";
					foreach my $tag_path(keys(%paths)){
						if($tag_path=~/^\Q$rep_parent_path\E/ and $csv_path!~/^\Q$tag_path\E/ and $paths{$tag_path} and $paths{$tag_path} ne 'REP_PARENT'){#this is child path of repeatable parent tag of current csv path
							my $curr_child_path=$tag_path;
							$curr_child_path=~s/^\Q$rep_parent_path\E//;
							push(@{$rep_parens_childs->{$rep_parent_path}},$curr_child_path);
							#print $curr_child_path."\n";
						}
					}
			}
			
			my $csv_tags=$xp->find($csv_path);
			my $rows_count=0;
			foreach my $start_tag(@$csv_tags){			
				my $curr_csv_row=[];
				$curr_csv_row->[scalar(@header_row)]=undef;
				my @curr_csv;
				my @parent_branch=@{$start_tag->find('ancestor-or-self::*')};
				my @parent_branch_rev=reverse(@{$start_tag->find('ancestor-or-self::*')});
				my $parent_branch_size=scalar(@parent_branch_rev);
				for(my $i=0;$i<$parent_branch_size;$i++){	
					my $curr_path=SAXs::StructureCollector->get_stack_path(\@parent_branch);
					my $curr_branch=shift(@parent_branch_rev);
					pop(@parent_branch);				
					#print "PARENT branch: ".$curr_branch->getName().'  '.$curr_path."\n";
					$curr_csv_row=&addTo_csv_row($curr_csv_row,$csv_header,$curr_path,$curr_branch);
					if(ref($rep_parens_childs->{$curr_path}) eq 'ARRAY'){
						foreach my $rep_parent_child (@{$rep_parens_childs->{$curr_path}}){
							my $path_proccesed=$rep_parent_child;
							$path_proccesed=~s/^\///;						
							my $parent_child=$curr_branch->find($path_proccesed);
							if(scalar(@{$parent_child})==1){
								#print 'REPEATABLE parent child: '.$parent_child->[0]->getName().'  '.$rep_parent_child."\n";
								$curr_csv_row=&addTo_csv_row($curr_csv_row,$csv_header,$curr_path.$rep_parent_child,$parent_child->[0]);
							}
						}
					}
				}
				if(scalar(@csv_childs)>0){
					foreach my $csv_child_path (@csv_childs){
						my $path_proccesed=$csv_child_path;
						$path_proccesed=~s/^\///;
						my $csv_child_el=$start_tag->find($path_proccesed);
						if(scalar(@{$csv_child_el})==1){
							#print 'Csv tag CHILD: '.$csv_child_el->[0]->getName().'  '.$csv_child_path."\n";
							$curr_csv_row=&addTo_csv_row($curr_csv_row,$csv_header,$csv_path.$csv_child_path,$csv_child_el->[0]);
						}
					}
				}else{
					#print 'Csv tag CHILD: '.$start_tag->getName().'  '.$start_tag->string_value()."\n";
				}
				foreach my $root_child(@root_childs){
					$curr_csv_row=&addTo_csv_row($curr_csv_row,$csv_header,$root_child->{'path'},$root_child->{'el'});
				}
				$csv_obj->combine(@$curr_csv_row);
				if($rows_count<$preview_length){
					$preview_str.=$csv_obj->string();	
				}else{
					$csv_str.=$csv_obj->string();
				}
				$rows_count++;
			}
		}
	}
	
	print CSV $preview_str.$csv_str;
	close(CSV);
	return 1;
}

sub addTo_csv_row{
	my ($curr_row,$csv_header,$el_path,$el)=@_;
	
		foreach my $attr (@{$el->getAttributes()}){
			$curr_row->[$csv_header->{$el_path}->{'attrs'}->{'{}'.$attr->getName()}->{'order'}]=$attr->getData();
			my $bb1=1;
		}
		if(scalar(@{$el->getChildNodes()})==1 and ref($el->getChildNodes()->[0]) eq 'XML::XPath::Node::Text'){
			my @tmp=@{$el->getChildNodes()};
			my $str=$el->string_value();
			$str=~s/(\t)|(\n)|(\r)//gs;
			$curr_row->[$csv_header->{$el_path}->{'order'}]=$str;			
		}else{
			my @tmp=@{$el->getChildNodes()};
			$curr_row->[$csv_header->{$el_path}->{'order'}]='';
			
		}
	return $curr_row;
}

sub mail_atom_template{
	my ($tmpl,$email,$subject,$params)=@_;
	
	if(!$params or !$email or ref($params) ne 'HASH'){
		&log_printf('------>>>>>>>>>wrong params for mail_atom_template');
		return '';
	};
	atom_util::process_atom_ilib($tmpl);
 	my $atoms=atom_util::process_atom_lib($tmpl);
	my $my_atom=$atoms->{'default'}->{$tmpl};
	return '' unless($my_atom);
	my $html=atom_misc::repl_ph($my_atom->{'body'},$params);
	my $mail = {'to' => $email,
				'from' =>  $atomcfg{'mail_from'},
				'subject' => $subject,
				'html_body' => $html,
				};
	&complex_sendmail($mail);	
}

# WARNING : this sub translates only statement never use it to translate single word
sub translate_from_google{
	my($strings,$from_langid,$to_langid)=@_;
	my $debug_tmp="TEMPORARY";
	#my $debug_tmp="";
	my $delimiter=' .!!!!!!!!!!! ';# the best delimiter.  
	my %res_hash=(); 
	if(ref($strings) ne 'ARRAY'){
		&log_printf('----->>>>>>>>>translate_from_google ERROR: provide array of strings to translate');
		return undef;
	}	
	my $langs=atomsql::do_query('SELECT lcase(short_code), langid FROM language');
	my %lang_map= map {lc($_->[1])=>$_->[0]} @$langs;
	if(!$lang_map{$from_langid} or !$lang_map{$to_langid}){
		&log_printf('----->>>>>>>>>translate_from_google ERROR: One of this lang ids does not valid $from_langid $to_langid');
		return undef;	
	}
	&atomsql::do_statement("DROP $debug_tmp TABLE IF EXISTS tmp_str_trans");
	&atomsql::do_statement("CREATE $debug_tmp TABLE tmp_str_trans(
											id int(11) NOT NULL auto_increment,
	                                        source_text mediumtext default '',
											source_langid int(11) default 0,
											source_text_md5 varchar(100) default 0,
											PRIMARY KEY (id),
											KEY `source_md5` (`source_text_md5`,`source_langid`))");
	if(scalar(@$strings)<100){
		my $tmp_sql='';
		foreach my $str(@$strings){
			$tmp_sql.="(".&atom_util::trim(&atomsql::str_sqlize($str)).",".$from_langid.",".&atomsql::str_sqlize(md5_base64(encode_utf8($str)))."),";
		}
		$tmp_sql=~s/,$//;
		&atomsql::do_statement('INSERT INTO tmp_str_trans (source_text,source_langid,source_text_md5) VALUES '.$tmp_sql) if $tmp_sql;
	}else{
		## TODO: use load data instead bellow
		my $tmp_sql='';
		foreach my $str(@$strings){
			$tmp_sql.="(".&atom_util::trim(&atomsql::str_sqlize($str)).",".$from_langid.",".&atomsql::str_sqlize(md5_base64(encode_utf8($str)))."),";
		}
		$tmp_sql=~s/,$//;
		&atomsql::do_statement('INSERT INTO tmp_str_trans (source_text,source_langid,source_text_md5) VALUES '.$tmp_sql);		 
	}
	
	my $matches=&atomsql::do_query("SELECT t.source_text,gt.trans_text FROM google_translations gt 
			   JOIN tmp_str_trans t ON t.source_text_md5=gt.source_text_md5 
			   WHERE gt.source_langid=$from_langid AND gt.trans_langid=$to_langid");
	my $unmatches=&atomsql::do_query("SELECT t.source_text FROM tmp_str_trans t  
			   LEFT JOIN google_translations gt ON t.source_text_md5=gt.source_text_md5  
			   									   AND gt.source_langid=$from_langid AND gt.trans_langid=$to_langid
			   WHERE gt.google_translations_id IS NULL");
	%res_hash=map {$_->[0]=>$_->[1]} @$matches;
	if(scalar(@$matches)==scalar(@$strings)){# all found in the table
		return \%res_hash;
	}
	&log_printf('----->>>>>>>>>translate_from_google: going to translate;  '.scalar(@$unmatches)." of strings ");
	my $toTranslate='';
	foreach my $unmatch(@$unmatches){
		$toTranslate.=$unmatch->[0].$delimiter;
	}
	$toTranslate=substr($toTranslate,0,(length($toTranslate)-length($delimiter)));
	my $ua = new LWP::UserAgent;
	$ua->agent('Mozilla/5.0');	
	#http://www.google.com/translate_a/t?client=t&sl=EN&tl=FR&text=yes
	my $url='http://www.google.com/translate_a/t';
	#$ua->default_header('Accept-Charset' => 'utf-8');
	my $res = $ua->request(&POST($url,['client'=>'t','text'=>&encode_entities($toTranslate),'sl'=>$lang_map{$from_langid},'tl'=>$lang_map{$to_langid}]));
	#$res->decoded_content(charset => 'utf8');
	#my $cont=Encode::decode_utf8($res->content());
	my $cont=$res->content();
	$cont=~s/@/\\@/gs;
	$cont=~s/\$/\\\$/gs;	
	$cont=~s/%/\\%/gs;
	my @pieces=eval($cont);
	if(ref($pieces[0][0][0]) eq 'ARRAY' and $pieces[0][0][0][0]){
		$cont=join('',map {&decode_entities($_->[0])} @{$pieces[0][0]});
	}else{
		&log_printf('----->>>>>>>>>translate_from_google: Unxpected result from google '.Dumper($unmatches));
		return '';
	}
	my $delim_part=	substr($delimiter,-2); # one of the delimiter lettres 
	my $delim_only=$delimiter;
	$delim_only=~s/\s\./\s/g;
	$cont=~s/(\.[\s]*)$delim_only/$delim_only/gis;
	$delimiter=~s/\.//;
	$cont=~s/$delim_part[\s]+$delim_part/$delim_part$delim_part$delim_part/gs;# remove backspaces inside the delimiter
	$cont=~s/[$delim_part]{2,}/$delimiter/gs; # google some times make delimiter shoter
	$delimiter=&atom_util::trim($delimiter);
	
	my @translated_strs=split(/$delimiter/i,$cont);
	if(scalar(@translated_strs)!=scalar(@$unmatches)){
		&log_printf('----->>>>>>>>>translate_from_google ERROR: Google fail or it have changed the html');
		&log_printf("\n-------------Size source: ".scalar(@$unmatches)."\n".$toTranslate."\n");
		&log_printf("\n------TRANSLATED---Size trans: ".scalar(@translated_strs)."----\n".$cont);
		return undef;
	}
	my $insert_sql="INSERT IGNORE INTO google_translations (source_text,source_text_md5,source_langid,trans_text,trans_text_md5,trans_langid) VALUES ";
	my($tmpSrc,$tmpTrans,$unmatchStr,$matchStr);
	for(my $i=0; $i<scalar(@$unmatches); $i++){
		$unmatchStr=$unmatches->[$i][0];
		$matchStr=$translated_strs[$i];
		if(substr($unmatchStr,-1)==lc(substr($unmatchStr,-1))){# first letter is lowercased. google replace it as uppercased
			$matchStr=lc(substr($matchStr,0,1)).substr($matchStr,1);
		}
		$matchStr=~s/[$delim_part]+[\s]*$//;
		$matchStr=~s/\.[\s]*$//g;		
		#$matchStr=~s/^[\s]*[$delim_part]+//;
		$res_hash{$unmatchStr}=$matchStr;
		#(source_text,source_text_md5,source_langid,trans_text,trans_text_md5,trans_langid)
		$tmpSrc=&atom_util::trim($unmatchStr);
		$tmpTrans=&atom_util::trim($matchStr);
		$insert_sql.='('.&atomsql::str_sqlize($tmpSrc).','.&atomsql::str_sqlize(md5_base64(encode_utf8($tmpSrc))).','.$from_langid.','.
						 &atomsql::str_sqlize($tmpTrans).','.&atomsql::str_sqlize(md5_base64(encode_utf8($tmpTrans))).','.$to_langid.
					 '),';
	}
	$insert_sql=~s/,$//;
	&atomsql::do_statement($insert_sql);
	
	return \%res_hash;
}


sub get_rating_prop{
	my ($what,$config)=@_;
	my @matches=$config=~/($what:[\s]*[^\n]+)[\n]*/gis;
	return \@matches;
}
sub remove_tags_except{
	my ($html,$tags)=@_;
	foreach my $tag(@$tags){
		$html=~s/<$tag>/%%%$tag%%%/gsi;
		$html=~s/<\/$tag>/%%%\/$tag%%%/gsi;
		$html=~s/<$tag\/>/%%%$tag\/%%%/gsi;
	}
	$html=~s/<[^<>]+?>//gs;
	foreach my $tag(@$tags){
		$html=~s/%%%$tag%%%/<$tag>/gsi;
		$html=~s/%%%\/$tag%%%/<\/$tag>/gsi;
		$html=~s/%%%$tag\/%%%/<$tag\/>/gsi;
	}
	return $html;
}

sub remove_tags_content_except{
	my ($html,$tags)=@_;
	foreach my $tag(@$tags){
		$html=~s/<$tag>/%%%$tag%%%/gsi;
		$html=~s/<\/$tag>/%%%\/$tag%%%/gsi;
		$html=~s/<$tag\/>/%%%$tag\/%%%/gsi;		
	}
	#print $html;
	$html=~s/<.+>//gs;
		
	foreach my $tag(@$tags){
		$html=~s/%%%$tag%%%/<$tag>/gsi;
		$html=~s/%%%\/$tag%%%/<\/$tag>/gsi;
		$html=~s/%%%$tag\/%%%/<$tag\/>/gsi;		
	}
	return $html;
}

sub copyToDateDir{
	my ($dir_root,$unix_time,$file,$prefix)=@_;
	use Time::Piece;
	my $date_obj=Time::Piece->new($unix_time);
	if(!$date_obj or !(-s $file)){
		errmail('alexey@bintime.com','copyToDateDir failed on '.$file);
		return '';
	}
	my ($year,$month,$day);
	$year=$date_obj->year();
	$month=$date_obj->mon();
	$day=$date_obj->mday();
	if(!(-d $dir_root.'/'.$year.'/')){
		`mkdir $dir_root/$year/`;
	}
	if(!(-d $dir_root.'/'.$year.'/'.$month.'/')){
		`mkdir $dir_root/$year/$month/`;
	}
	if(!(-d $dir_root.'/'.$year.'/'.$month.'/'.$day.'/')){
		`mkdir $dir_root/$year/$month/$day`;
	}
	my $file_name;
	if($file=~/([^\/]+)$/){
		$file_name=$1;
	}else{
		errmail('alexey@bintime.com','copyToDateDir failed on '.$file);
		return '';		
	}
	
	my $dst_file=$dir_root.'/'.$year.'/'.$month.'/'.$day.'/'.$prefix.$file_name;
	if(-e $dst_file){
		`rm $dst_file`;
	}
	`cp $file $dst_file`;
	return 1;
}

sub cmp_symbols{
	my($str1,$str2)=@_;
	$str1=~s/[^\d\w]//gs;
	$str2=~s/[^\d\w]//gs;
	return ($str1 eq $str2)				
}

1;

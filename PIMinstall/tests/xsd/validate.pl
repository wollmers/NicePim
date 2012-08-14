#!/usr/bin/perl

	#cpan XML::Filter::ExceptionLocator
	#cpan XML::SAX::ExpatXS 

use XML::SAX::ParserFactory;
use XML::Validator::Schema;
use XML::SAX::ExpatXS ;

use atomcfg;
use lib '/home/alexey/icecat/bo/trunk/lib';
use Time::HiRes;

$time_start=Time::HiRes::time();  
$base=$atomcfg{'base_dir'};
#&do_validate($base.'www/xsd/files.index.xsd',$base.'xml/level4/EN/files.index.xml');
#&do_validate($base.'www/xsd/ICECAT-product_mapping.xsd', $base.'xml/level4/EN/product_mapping.xml');
#&do_validate($base.'www/xsd/ICECAT-supplier_mapping.xsd', $base.'xml/level4/EN/supplier_mapping.xml');
#&do_validate($base.'www/xsd/ICECAT-relations.xsd', $base.'xml/level4/refs/RelationsList.xml');
#&do_validate($base.'www/xsd/ICECAT-urls.xsd', $base.'www/export/export_urls.xml');
#&do_validate($base.'www/xsd/ICECAT-campaigns.xsd', $base.'xml/refs/CampaignsList.xml');

$gz=$base.'xml/level4/INT/39/59/57/3959571.xml.gz';
$xml=$base.'xml/level4/INT/39/59/57/3959571.xml';
`gzip -d -c $gz > $xml` if -e $gz;
&do_validate($base.'www/xsd/ICECAT-interface_response.xsd', $base.'xml/level4/INT/39/59/57/3959571.xml');

$gz=$base.'xml/level4/INT/21/48/78/2148783.xml.gz';
$xml=$base.'xml/level4/INT/21/48/78/2148783.xml';
`gzip -d -c $gz > $xml` if -e $gz;
&do_validate($base.'www/xsd/ICECAT-interface_response.xsd', $base.'xml/level4/INT/21/48/78/2148783.xml');

&do_validate($base.'www/xsd/ICECAT-interface_response.xsd', $base.'xml/level4/refs.xml');


print "takes ================>>>>>>>> ".(Time::HiRes::time()-$time_start);

sub do_validate{
	my ($xsd,$xml)=@_;
	$validator = XML::Validator::Schema->new(file => $xsd);
	$parser = XML::SAX::ExpatXS->new(Handler => $validator);
	eval { $parser->parse_uri($xml)};
	die "File failed validation: $@" if $@;	
} 

1;

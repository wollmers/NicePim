package PIMConfiguration;
use vars qw($Bin $Script);
BEGIN { ($Bin, $Script) = split /([^\/\\]+)$/, $0 }
use lib $Bin . '../../lib';

sub new {
	my $class = shift;
	my $self  = {

		#name of user for download of xml files
		xml_username => "openICEcat-xml",

		#password of user for download of xml files
		xml_password => "freeaccess",

		#URL for references XML files
		refs_url => "http://data.icecat.biz/export/freexml/refs/",

		#XML refs files
		suppliers_xml => "SuppliersList.xml.gz",
		languages_xml => "LanguageList.xml.gz",
		measures_xml => "MeasuresList.xml.gz",
		features_xml => "FeaturesList.xml.gz",
		categories_xml => "CategoriesList.xml.gz",
		category_features_xml => "CategoryFeaturesList.xml.gz",
		product_families_xml => "SupplierProductFamiliesListRequest.xml.gz",
		feature_values_vocabulary_xml => "FeatureValuesVocabularyList.xml.gz",

		#URL for product XML files
		product_url => "http://data.icecat.biz/export/freexml.int/INT/",
		
		#Path for download of XML files
		files_path =>
		  "/home/pim//data_source/IcecatToPIMImport/files/",

		#Import mode (0 - only insert, 1 - insert and update)
		import_mode => 1,

		#Product list file
		product_list_file => "daily.index.csv.gz",

		#Count of threads for product import
		thread_count => 15,

		#PIM mail options
		mail_to      => '',
		mail_from    => "localhost",
		mail_subject => "PIM"
	};
	bless( $self, $class );
	return $self;
}

1;

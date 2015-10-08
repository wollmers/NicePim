package PIMImportConfiguration;
use lib "/home/gcc/lib";

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
		product_url => "http://data.icecat.biz/export/freexml.int/",
				
		#languages for products
		languages => ['INT','NL','FR'],
		
		#Path for download of XML files
		files_path =>
		  "/home/gcc/data_source/IcecatToPIMImport/files/",

		#Import mode (0 - only insert, 1 - insert and update)
		import_mode => 1,

		#Product list file
		product_list_file => "daily.index.csv.gz",

		#import process may modify products with this such users
		product_users_for_import => ['icecat','nobody'], 

		#Count of threads for product import
		thread_count => 15,

		#PIM mail options
		mail_to      => "email_to\@domain",
		mail_from    => "email_from\@domain",
		mail_subject => "Icecat to PIM import"
	};
	bless( $self, $class );
	return $self;
}

1;


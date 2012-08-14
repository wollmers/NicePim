package PIMImporter;
use PIMImportConfiguration;
use atomsql;
use atomlog;
use PIMReport;
use PIMFileWorker;
use XML::SAX::ParserFactory;
use CategoriesListHandler;
use CategoriesParentHandler;
use CategoryFeaturesListHandler;
use FeaturesListHandler;
use FeatureValuesVocabularyListHandler;
use LanguageListHandler;
use LanguageNameListHandler;
use MeasuresListHandler;
use ProductFamiliesListHandler;
use ProductFamiliesParentHandler;
use SuppliersListHandler;
use ProductHandler;

sub new {
	my $class = shift;
	my $self  = {};

	#initialize PIM configuration
	$self->{pim_cfg} = PIMImportConfiguration->new();

	#initialize PIM file worker
	$self->{file_worker} = PIMFileWorker->new();

	bless( $self, $class );
	return $self;
}

#Import xml files to PIM database
sub do_import {
	my ($self) = @_;
	die "instance method called on class" unless ref $self;
	&log_printf("*****Before Icecat to PIM import*****");

	#get and save current time
	my $start_time = time;

	#import XML files
	unless ( -d $self->{pim_cfg}->{files_path} ) {
		mkdir( $self->{pim_cfg}->{files_path} );
	}

	$self->import_references();
	
	foreach my $language (@{$self->{pim_cfg}->{languages}}) {
		$self->import_products($language);
	}

	#send and print report
	PIMReport->print_report();
	PIMReport->send_report(
		$self->{pim_cfg}->{mail_to},
		$self->{pim_cfg}->{mail_from},
		$self->{pim_cfg}->{mail_subject}
	);

	#get current time and calculate time of import
	my $res_time = time - $start_time;

	&log_printf("*****After Icecat to PIM import. Time of import = $res_time s*****");
}

# Import references from XML to PIM
sub import_references {
	my ($self) = @_;
	die "instance method called on class" unless ref $self;
	my ( $import_res, $file_name, $handler );

	#connect to database for import references
	&init_connection();

	$file_name = $self->{pim_cfg}->{suppliers_xml};
	$handler   = SuppliersListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );

	$file_name = $self->{pim_cfg}->{languages_xml};
	$handler   = LanguageListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );
	$handler = LanguageNameListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 1 );

	$file_name = $self->{pim_cfg}->{measures_xml};
	$handler   = MeasuresListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );

	$file_name = $self->{pim_cfg}->{features_xml};
	$handler   = FeaturesListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );

	$file_name = $self->{pim_cfg}->{categories_xml};
	$handler   = CategoriesListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );
	$handler    = CategoriesParentHandler->new();
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 1 );

	$file_name = $self->{pim_cfg}->{category_features_xml};
	$handler   = CategoryFeaturesListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );

	$file_name = $self->{pim_cfg}->{product_families_xml};
	$handler   = ProductFamiliesListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );
	$handler    = ProductFamiliesParentHandler->new();
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 1 );

	$file_name = $self->{pim_cfg}->{feature_values_vocabulary_xml};
	$handler   = FeatureValuesVocabularyListHandler->new();
	$handler->set_import_mode( $self->{pim_cfg}->{import_mode} );
	$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{refs_url},
		$file_name, $handler, 0 );

	#close connection to database after import references
	&close_connection();
}

#import products from XML to PIM
sub import_products {
	my ( $self, $language ) = @_;
	die "instance method called on class" unless ref $self;
	my ( $handler, $sql, $file_name, $file_res, $pid, $products, $query_res, $langid);
	my ( $product_owners, $product_owners_ids);

	#download archive with list of product files
	$file_res = $self->{file_worker}->download_file(
		$self->{pim_cfg}->{product_url}.$language."\/",
		$self->{pim_cfg}->{product_list_file},
		$self->{pim_cfg}->{files_path},
		$self->{pim_cfg}->{xml_username},
		$self->{pim_cfg}->{xml_password}
	);
	if ( $file_res == 0 ) {
		$file_name =
		    $self->{pim_cfg}->{files_path}
		  . $self->{pim_cfg}->{product_list_file};

		#unpuck archive with list of products
		$file_res = $self->{file_worker}->unpack_file($file_name);
		$file_name =~ s/.gz$//;
		if ( $file_res == 0 ) {

			#connect to database for parent process
			&init_connection();

			#get language id from database
			$sql = "SELECT langid FROM language WHERE short_code = \'$language\'";
			$query_res = &do_query($sql);
			$langid = $query_res->[0][0];
			if (! defined $langid){
				
				#international products
				$langid = 0; 
			}

			#clear table with product files
			$sql = "DELETE FROM product_csv";
			&do_statement($sql);

			#load list of files to table
			$sql = "LOAD DATA LOCAL INFILE \'$file_name\' 
					INTO TABLE product_csv IGNORE 1 LINES (\@dummy, product_id, updated, quality,supplier_id,prod_id)";
			&do_statement($sql);
			
			#search product users in database
			foreach (@{$self->{pim_cfg}->{product_users_for_import}}){
				$product_owners .= "\'".uc($_)."\'".",";
			}
			chop($product_owners);
			$sql = "SELECT user_id FROM users WHERE UPPER(login) IN ($product_owners)";
			$query_res = &do_query($sql);
			foreach (@$query_res){
				foreach (@$_) {
					$product_owners_ids .= $_.',';
				}
			}
			chop($product_owners_ids); 

			#get array of products for import
			$sql = "SELECT csv.product_id,csv.quality FROM product_csv AS csv 
					LEFT JOIN product AS p ON csv.prod_id = p.prod_id 
					LEFT JOIN product_pim AS pim ON csv.product_id = pim.product_id AND pim.langid = $langid 
					INNER JOIN supplier AS s ON s.icecat_id = csv.supplier_id  
					WHERE (csv.quality = 'SUPPLIER' OR csv.quality = 'ICECAT') 
					AND (pim.product_id IS NULL OR pim.updated<csv.updated OR pim.status=1) 
					AND (p.user_id IS NULL OR p.user_id IN ($product_owners_ids)) 
					AND (p.supplier_id IS NULL OR p.supplier_id = s.supplier_id) ";
			$products = &do_query($sql);
			
			&log_printf("import_products: start of parallel product import");

			#create table for PIM statistic in database
			$sql = "DROP table IF exists pim_statistic ";
			&do_statement($sql);
			$sql = "CREATE TABLE pim_statistic (cnt_imported INT)";
			&do_statement($sql);
			$sql = "INSERT INTO pim_statistic VALUES (0)";
			&do_statement($sql);

			#close connection for parent process
			&close_connection();

			if ( $#$products >= 0 ) {

				#create child processes
				for ( my $i = 0 ; $i < $self->{pim_cfg}->{thread_count} ; $i++ )
				{

					if ( !defined( $pid = fork() ) ) {
						die("ERROR! import_products: can not fork: $!\n");
					}

					#child process
					elsif ( $pid == 0 ) {

						#start index in product array for child process
						my $start = int(
							($#$products) / $self->{pim_cfg}->{thread_count} ) *
						  $i;
						my $end;

						#end index in product array for no last child
						if ( $i < $self->{pim_cfg}->{thread_count} - 1 ) {
							$end =
							  int( ($#$products) /
								  $self->{pim_cfg}->{thread_count} ) *
							  ( $i + 1 ) - 1;
						}

						#end index in product array for last child
						else {
							$end = $#$products;
						}

						#run child process of product import
						if ( $start <= $#$products && $start <= $end ) {
							&log_printf(
								"import_products: interval of indexes for process $i = $start..$end"
							);
							my @product_interval = @$products[ $start .. $end ];
							my $cnt_imported =
							  $self->import_products_from_array(
								\@product_interval, $i, $language, $langid );
						}
						exit;
					}

					#parent process
					elsif ( $pid > 0 ) {
						push( @pids, $pid );
					}
				}

				#wait for all child processess
				for ( my $i = 0 ; $i <= $#pids ; $i++ ) {
					waitpid( $pids[$i], 0 );
				}
				&log_printf("import_products: end of parallel product import ");
			}
			my $cnt_imported = $#$products + 1;
			PIMReport->append(
				"\nTotal products for language $language in list for import=$cnt_imported \n" );
			&log_printf(
				"=====Total products for language $language in list for import = $cnt_imported =====");

			#get statistic from database
			&init_connection();
			$sql          = "SELECT cnt_imported FROM pim_statistic";
			$query_res    = &do_query($sql);
			$cnt_imported = $query_res->[0][0];
			if (!defined $cnt_imported){
				$cnt_imported = 0;
			}
			PIMReport->append( "\nTotal imported products for $language language = $cnt_imported \n" );
			&log_printf("=====Total imported products for $language language = $cnt_imported =====");
			&close_connection();
		}
	}
}

#Import products for array of IDs
#	Parameters:
#	products - array of product IDs for import
sub import_products_from_array {
	my ( $self, $products, $n, $language, $langid ) = @_;
	die "instance method called on class" unless ref $self;
	my ( $file_name, $import_res, $sql, $query_res, $user_id );
	my $cnt_imported = 0;

	#init connection for child process
	&init_connection();

	#initialization of SAX parser for product xml files
	my $handler = ProductHandler->new();
	$handler->set_import_mode(1);
	$handler->set_langid($langid);
	my $parser = XML::SAX::ParserFactory->parser( Handler => $handler );

	#import products from array
	for ( my $i = 0 ; $i <= $#$products ; $i++ ) {
		&log_printf(
			"import_products_from_array: process $n: import product $products->[$i][0] "
		);
		$file_name = $products->[$i][0] . ".xml";
		
		#get user id for product 
		$sql = "SELECT user_id FROM users WHERE UPPER(login) = UPPER(\'$products->[$i][1]\')";
		$query_res = &do_query($sql);
		$user_id = $query_res->[0][0];
		if (! defined $user_id){
			$user_id = 1;
		}
		$handler->set_user_id($user_id);
		
		#import product 	
		$import_res = $self->import_xml_to_PIM( $self->{pim_cfg}->{product_url}.$language."\/",
			$file_name, undef, 0, $parser );
		$sql = "INSERT INTO product_pim (product_id,langid,status,updated) 
					VALUES ($products->[$i][0],$langid,$import_res,NOW()) 
					ON DUPLICATE KEY UPDATE status = $import_res, updated = NOW()";
		&do_statement($sql);
		if ( $import_res == 0 ) {
			$cnt_imported++;
		}
	}

	$sql =
	  "UPDATE pim_statistic SET cnt_imported = cnt_imported + $cnt_imported";
	&do_statement($sql);

	#close connection for child process
	&close_connection();
	return $cnt_imported;
}

# Import xml file to database
# 	Parameters:
# 	url - URL for download of xml file (without file name)
# 	file_name - name of xml file or archive with xml
#	download_path - path for download of xml file
# 	handler - handler instance for SAX parser
#	is_offline - if 0 then online mode, if 1 then offline mode
#	parser - SAX parser (for product xml)
sub import_xml_to_PIM {
	my ( $self, $url, $file_name, $handler, $is_offline, $parser ) = @_;
	die "instance method called on class" unless ref $self;
	my ( $file_res, $destination );
	$destination = $self->{pim_cfg}->{files_path} . $file_name;

	#use current xml file
	if ( $is_offline == 1 ) {
		$destination =~ s/.gz$//;
		if ( -e $destination && ( ( -s $destination ) > 0 ) ) {
			$file_res = 0;
		}
		else {
			$file_res = 1;    #error
		}
	}

	#download xml file
	else {
		$file_res = $self->{file_worker}->download_file(
			$url, $file_name,
			$self->{pim_cfg}->{files_path},
			$self->{pim_cfg}->{xml_username},
			$self->{pim_cfg}->{xml_password}
		);
		if ( $file_res == 0 ) {
			if ( $destination =~ /.gz$/ ) {

				#extract xml file from gzip archive
				$file_res = $self->{file_worker}->unpack_file($destination);
				$destination =~ s/.gz$//;
			}
		}
	}

	#if file was successfully downloaded or was existed
	if ( $file_res == 0 ) {

		if ( !defined $parser ) {

			#initialization of SAX parser
			$parser = XML::SAX::ParserFactory->parser( Handler => $handler );
		}

		#parse xml file
		$parser->parse_uri($destination);
	}
	return $file_res;
}

1;


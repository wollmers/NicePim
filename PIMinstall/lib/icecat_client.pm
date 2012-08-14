package icecat_client;

#$Id: icecat_client.pm 2625 2010-05-27 00:04:38Z dima $

use strict;
use icecat_util;
use LWP::UserAgent;
use XML::Simple;
use atomlog;
use Data::Dumper;
BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
								&build_request
							);

}

sub build_request {
	my ($hash,$login,$pass,$req_id) =	@_;
	my $rh = {};
	
	if ($hash->{'LanguageList'}) {
		$rh->{'LanguageListRequest'} = {};
	}

	if ($hash->{'DistributorList'}) {
		$rh->{'DistributorListRequest'} = {};
	}
	
	if ($hash->{'MeasuresList'}) {
		$rh->{'MeasuresListRequest'} = { 'langid' => $hash->{'MeasuresList'}, 'content' => ''};
	}
	
	if ($hash->{'FeaturesList'}) {
		$rh->{'FeaturesListRequest'} = { 'langid' => $hash->{'FeaturesList'}, 'content' => ''};
	}

	if ($hash->{'FeatureValuesVocabularyList'}) {
		$rh->{'FeatureValuesVocabularyListRequest'} = { 'langid' => $hash->{'FeatureValuesVocabularyList'}, 'content' => '' };
	}
	
	if ($hash->{'CategoriesList'}) {
		$rh->{'CategoriesListRequest'} = { 'langid' => $hash->{'CategoriesList'}->{'langid'}, 'content' => ''};
		$rh->{'CategoriesListRequest'}->{'Searchable'} = $hash->{'CategoriesList'}->{'Searchable'} if (defined $hash->{'CategoriesList'}->{'Searchable'});
		$rh->{'CategoriesListRequest'}->{'UNCATID'} = $hash->{'CategoriesList'}->{'UNCATID'} if (defined $hash->{'CategoriesList'}->{'UNCATID'});
		$rh->{'CategoriesListRequest'}->{'Category_ID'} = $hash->{'CategoriesList'}->{'Category_ID'} if (defined $hash->{'CategoriesList'}->{'Category_ID'});
	}
	
	if ($hash->{'SupplierCategoriesList'}) {
		$rh->{'SupplierCategoriesListRequest'} = { 'langid' => $hash->{'SupplierCategoriesList'}->{'langid'}, 
		};
		$rh->{'SupplierCategoriesListRequest'}->{'Supplier'}->{'content'} 	= $hash->{'SupplierCategoriesList'}->{'Supplier'} if ($hash->{'SupplierCategoriesList'}->{'Supplier'}); 
		$rh->{'SupplierCategoriesListRequest'}->{'Supplier'}->{'ID'} 		= $hash->{'SupplierCategoriesList'}->{'Supplier_ID'} if ($hash->{'SupplierCategoriesList'}->{'Supplier_ID'});  
		$rh->{'SupplierCategoriesListRequest'}->{'Searchable'} = $hash->{'SupplierCategoriesList'}->{'Searchable'} if ($hash->{'SupplierCategoriesList'}->{'Searchable'});
	}
	
	
	if (defined $hash->{'SuppliersList'}) {
		my $content = '';
		if($hash->{'SuppliersList'}->{'Searchable'} ||
			 $hash->{'SuppliersList'}->{'UNCATID'} ||
			 $hash->{'SuppliersList'}->{'Category_ID'}){
			if($hash->{'SuppliersList'}->{'Searchable'}){
				$rh->{'SuppliersListRequest'}->{'Searchable'} = '1';
			}
			
			if($hash->{'SuppliersList'}->{'UNCATID'}){
				$rh->{'SuppliersListRequest'}->{'UNCATID'} = $hash->{'SuppliersList'}->{'UNCATID'};
			}
			
			if($hash->{'SuppliersList'}->{'Category_ID'}){
				$rh->{'SuppliersListRequest'}->{'Category_ID'} = $hash->{'SuppliersList'}->{'Category_ID'};
			}
			
#	log_printf('hello dudy-dude!');
		} else {
#  log_printf('hello dude!');
			$rh->{'SuppliersListRequest'} = {};
		}
		
	}
	
	
	if (defined $hash->{'CategoryFeaturesList'}) {
		if ($hash->{'CategoryFeaturesList'}->{'UNCATID'}) {
			$rh->{'CategoryFeaturesListRequest'}->{'UNCATID'} = $hash->{'CategoryFeaturesList'}->{'UNCATID'};	
		}
		if ($hash->{'CategoryFeaturesList'}->{'Category_ID'}) {
			$rh->{'CategoryFeaturesListRequest'}->{'Category_ID'} = $hash->{'CategoryFeaturesList'}->{'Category_ID'};	
		}
		
		if ($hash->{'CategoryFeaturesList'}->{'Searchable'}) {
			$rh->{'CategoryFeaturesListRequest'}->{'Searchable'} = $hash->{'CategoryFeaturesList'}->{'Searchable'};	
		}
		
		if ($hash->{'CategoryFeaturesList'}->{'Key'}) {
			$rh->{'CategoryFeaturesListRequest'}->{'Key'} = $hash->{'CategoryFeaturesList'}->{'Key'};	
		}
		
		$rh->{'CategoryFeaturesListRequest'}->{'langid'} = $hash->{'CategoryFeaturesList'}->{'langid'};	
		
	}
	
	if (defined $hash->{'ProductsDump'}) {
		$rh->{'ProductsDumpRequest'} = { "MinQuality" => $hash->{'ProductsDump'}->{'MinQuality'},
																		 "langid" 		 => $hash->{'ProductsDump'}->{'langid'},
																		 "Supplier_ID"=> $hash->{'ProductsDump'}->{'Supplier_ID'},
																		 "UpdatedFrom"=> $hash->{'ProductsDump'}->{'UpdatedFrom'}};
	}
	
	if (defined $hash->{'ProductsListLookup'}) {
		
		my $t = {};
		
		for my $feature (@{$hash->{'ProductsListLookup'}->{'LookupFeatures'}}) {
			$t->{$feature->[0]}->{'LimitValue'} = $feature->[1];
		}
		
		$rh->{'ProductsListLookupRequest'}->{'LookupText'} = $hash->{'ProductsListLookup'}->{'LookupText'} if ($hash->{'ProductsListLookup'}->{'LookupText'}); 
		
		$rh->{'ProductsListLookupRequest'}->{'Supplier'}->{'content'} 	= $hash->{'ProductsListLookup'}->{'Supplier'} if ($hash->{'ProductsListLookup'}->{'Supplier'}); 
		$rh->{'ProductsListLookupRequest'}->{'Supplier'}->{'ID'} 		= $hash->{'ProductsListLookup'}->{'Supplier_ID'} if ($hash->{'ProductsListLookup'}->{'Supplier_ID'});  
		
		$rh->{'ProductsListLookupRequest'}->{'Features'}->{'Feature'} = $t;
		$rh->{'ProductsListLookupRequest'}->{'langid'} = $hash->{'ProductsListLookup'}->{'langid'};
		$rh->{'ProductsListLookupRequest'}->{'UNCATID'} = $hash->{'ProductsListLookup'}->{'UNCATID'}; 
		$rh->{'ProductsListLookupRequest'}->{'Category_ID'} = $hash->{'ProductsListLookup'}->{'Category_ID'}; 
		$rh->{'ProductsListLookupRequest'}->{'ProductFamily'}->{'ID'} = $hash->{'ProductsListLookup'}->{'ProductFamily_ID'};  
	}
	
	if (defined $hash->{'FulltextProductsSearch'}) {
		$rh->{'FulltextProductsSearchRequest'}->{'Text'} = $hash->{'FulltextProductsSearch'}->{'Text'}; 
		$rh->{'FulltextProductsSearchRequest'}->{'Category_ID'} = $hash->{'FulltextProductsSearch'}->{'Category_ID'} if ( $hash->{'FulltextProductsSearch'}->{'Category_ID'} );
		$rh->{'FulltextProductsSearchRequest'}->{'langid'} = $hash->{'FulltextProductsSearch'}->{'langid'} if ( $hash->{'FulltextProductsSearch'}->{'langid'} );
		
		if ($hash->{'FulltextProductsSearch'}->{'Supplier'}) {
#		print Dumper ( $hash->{'FulltextProductsSearch'}->{'Supplier'} );
			$rh->{'FulltextProductsSearchRequest'}->{'Supplier'}=[];
			for my $supplier ( @{$hash->{'FulltextProductsSearch'}->{'Supplier'}} ) {
				my $current_supp;
				$current_supp->{'content'} = $supplier->{'Supplier'};
				$current_supp->{'ID'} = $supplier->{'Supplier_ID'};
				push @{$rh->{'FulltextProductsSearchRequest'}->{'Supplier'}},$current_supp;
			}
		}	
	}
	
	
	if (defined $hash->{'ProductsList'}) {
		my $content = {'langid' => $hash->{'ProductsList'}->{'langid'}};
		
		for my $product (@{$hash->{'ProductsList'}->{'Products'}}) {
			if (defined $product->{'ID'}) {
				push @{$content->{'Product'}}, { 'ID' => $product->{'ID'}, 'content'	=>	'' };
			}
			elsif (defined $product->{'Supplier_ID'} && defined $product->{'Prod_id'}) {
				push @{$content->{'Product'}}, { 
					'Supplier' => {
						'ID' 	=> $product->{'Supplier_ID'},
						'content'=> ''
					},
							'Prod_id'	=> [ $product->{'Prod_id'} ]
							
				};
			}
			elsif (defined $product->{'Supplier'} && defined $product->{'Prod_id'}) {
				push @{$content->{'Product'}}, { 
					'Supplier' => [ $product->{'Supplier'}],
					'Prod_id'	=> [ $product->{'Prod_id'} ]
						
				};
			}
		}
		
		$rh->{'ProductsListRequest'} = $content;
	}
	
	if ($hash->{'ProductsStatistic'}) {
		if (!$hash->{'ProductsStatistic'}->{'Type'} || $hash->{'ProductsStatistic'}->{'Type'} ne 'TOP10') {
			$hash->{'ProductsStatistic'}->{'Type'}  = 'TOP10';
		}
		$rh->{'ProductsStatistic'}->{'Type'} 			= $hash->{'ProductsStatistic'}->{'Type'};
		
		for my $item ('Category_ID', 'UNCATID') {
			if ($hash->{'ProductsStatistic'}->{$item}) {
				$rh->{'ProductsStatistic'}->{$item} = $hash->{'ProductsStatistic'}->{$item};
			}
		}
	}
	
	if ($hash->{'DescribeProductsRequest'}) {
		my $content = {'langid' => $hash->{'DescribeProductsRequest'}->{'langid'}};
		for my $require (@{$hash->{'DescribeProductsRequest'}->{'DescribeProductRequest'}}) {
			push @{$content->{'DescribeProductRequest'}},{
				'Product_id' => $require->{'Product_id'},
				'Prod_id' => $require->{'Prod_id'},
				'Supplier_id' => $require->{'Supplier_id'},
				'Email' => $require->{'Email'},
				'toDate' => $require->{'toDate'},
				'Message' => $require->{'Message'},
				'Supplier_Code' => $require->{'Supplier_Code'}
			};
		}
		$rh->{'DescribeProductsRequest'} = $content;
	}
	
#
# building request for StatisticQueryList 
#
	
	if ($hash->{'StatisticQueryList'}) {
		my $content = {};
		$rh->{'StatisticQueryListRequest'} = $content;
	}
	
#
# building request for StatisticQueryDatesList
#
	
	if ($hash->{'StatisticQueryDatesList'}) {
		my $content = {};
		if (defined $hash->{'StatisticQueryDatesList'}->{'DateStart'}) {
			$content->{'DateStart'} = $hash->{'StatisticQueryDatesList'}->{'DateStart'};
		}
		
		if (defined $hash->{'StatisticQueryDatesList'}->{'DateEnd'}) {
			$content->{'DateEnd'} = $hash->{'StatisticQueryDatesList'}->{'DateEnd'};
		}
		if (defined $hash->{'StatisticQueryDatesList'}->{'StatisticQueries'}) {
			for my $StatisticQuery ( @{$hash->{'StatisticQueryDatesList'}->{'StatisticQueries'} } ){
				push @{ $content->{'StatisticQuery'} }, { 'ID' => $StatisticQuery->{'ID'} };
			} 
		}
		
		$rh->{'StatisticQueryDatesListRequest'} = $content;	
		
	}
	if ($hash->{'ProductsComplaintRequest'}) {
# my $content = {'langid' => $hash->{'ComplaintProductsRequest'}->{'langid'}};
		my $content = {};
		for my $require (@{$hash->{'ProductsComplaintRequest'}->{'ProductComplaintRequest'}}) {
			push @{$content->{'ProductComplaintRequest'}},{
				'Product_id' => $require->{'Product_id'},
				'Prod_id' => $require->{'Prod_id'},
				'Supplier_id' => $require->{'Supplier_id'},
				'Email' => $require->{'Email'},
				'Date' => $require->{'Date'},
				'Message' => $require->{'Message'},
				'Supplier_Code' => $require->{'Supplier_Code'},
				'Subject' => $require->{'Subject'},
				'Name' => $require->{'Name'},
				'Company' => $require->{'Company'}
			};
		}
    $rh->{'ProductsComplaintRequest'} = $content;
	}
	
	if ($hash->{'SupplierProductFamiliesListRequest'}) {
		$rh->{'SupplierProductFamiliesListRequest'} = { 'langid' => $hash->{'SupplierProductFamiliesListRequest'}->{'langid'}};
		$rh->{'SupplierProductFamiliesListRequest'}->{'Supplier_ID'} = $hash->{'SupplierProductFamiliesListRequest'}->{'Supplier_ID'} if ($hash->{'SupplierProductFamiliesListRequest'}->{'Supplier_ID'});  
		$rh->{'SupplierProductFamiliesListRequest'}->{'Category_ID'} = $hash->{'SupplierProductFamiliesListRequest'}->{'Category_ID'} if ($hash->{'SupplierProductFamiliesListRequest'}->{'Category_ID'});
		$rh->{'SupplierProductFamiliesListRequest'}->{'SupplierParentProductFamily_ID'} = $hash->{'SupplierProductFamiliesListRequest'}->{'SupplierParentProductFamily_ID'} if ($hash->{'SupplierProductFamiliesListRequest'}->{'SupplierParentProductFamily_ID'});
	}
	
#
# building request for StatisticQueryDateDataReport 
#
	
	if ($hash->{'StatisticQueryDateDataReport'} ) {
		my $content = {};
		push @{ $content->{ 'StatisticQueryDate'}}, { 'ID' => $hash->{'StatisticQueryDateDataReport'}->{'StatisticQueryDate'}->[0]->{'ID'}};
		$rh->{'StatisticQueryDateDataReportRequest'} = $content;
	}
	
	$rh->{'Login'}			= $login;
	$rh->{'Password'}		= $pass;
	$rh->{'Request_ID'}	= $req_id;
	
#log_printf ( Dumper ( $rh ) );
	return { 'Request' => [ $rh ] };
}

1;

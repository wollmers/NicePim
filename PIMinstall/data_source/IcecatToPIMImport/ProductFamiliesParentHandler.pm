package ProductFamiliesParentHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====ProductFamiliesParentHandler: start of parsing=====");
	$self->{product_family}            = {};
	$self->{cnt_update_product_family} = 0;
	$self->{cnt_xml_product_family}    = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );
	if ( $data->{Name} eq 'ProductFamily' ) {
		$self->{product_family}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{cnt_xml_product_family}++;
	}
	elsif ( $data->{Name} eq 'ParentProductFamily' ) {

		#check parent product_family
		$sql = "SELECT parent_family_id FROM product_family 
				WHERE icecat_id = $self->{product_family}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{product_family}->{parent_family_id} = $query_res->[0][0];

		#search parent product_family
		if ( $self->{product_family}->{parent_family_id} == 1 ) {
			$self->{product_family}->{parent_family_id_icecat} =
			  $data->{Attributes}->{"{}ID"}->{Value};
			$sql = "SELECT family_id FROM product_family 
					WHERE icecat_id = $self->{product_family}->{parent_family_id_icecat}";
			$query_res = &do_query($sql);
			$self->{product_family}->{parent_family_id} = $query_res->[0][0];

			#update parent product_family
			if ( defined $self->{product_family}->{parent_family_id} ) {
				$sql = "UPDATE product_family SET 
						parent_family_id = $self->{product_family}->{parent_family_id} 
						WHERE icecat_id = $self->{product_family}->{icecat_id}";
				&do_statement($sql);
				$self->{cnt_update_product_family}++;
			}
		}
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append(
		"Count of updated parent fileds in product families = $self->{cnt_update_product_family}\n"
	);

	#add statistics to log
	&log_printf(
		"Tatal product families in xml = $self->{cnt_xml_product_family}");
	&log_printf(
		"Count of updated product families = $self->{cnt_update_product_family}"
	);
	&log_printf("=====CategoriesParentHandler: end of parsing=====");
}
1;


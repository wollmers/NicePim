package CategoriesParentHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====CategoriesParentHandler: start of parsing=====");
	$self->{category}            = {};
	$self->{cnt_update_category} = 0;
	$self->{cnt_xml_category}    = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );
	if ( $data->{Name} eq 'Category' ) {
		$self->{category}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};
		$self->{cnt_xml_category}++;
	}
	elsif ( $data->{Name} eq 'ParentCategory' ) {

		#check parent category
		$sql = "SELECT pcatid FROM category
				WHERE icecat_id = $self->{category}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category}->{pcatid} = $query_res->[0][0];

		#search parent category
		if ( $self->{category}->{pcatid} == 1 ) {
			$self->{category}->{pcatid_icecat} =
			  $data->{Attributes}->{"{}ID"}->{Value};
			$sql = "SELECT catid FROM category 
					WHERE icecat_id = $self->{category}->{pcatid_icecat}";
			$query_res = &do_query($sql);
			$self->{category}->{pcatid} = $query_res->[0][0];

			#update parent category
			if ( defined $self->{category}->{pcatid} ) {
				$sql = "UPDATE category SET 
						pcatid = $self->{category}->{pcatid} 
						WHERE icecat_id = $self->{category}->{icecat_id}";
				&do_statement($sql);
				$self->{cnt_update_category}++;
			}
		}
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append(
		"Count of updated parent filed in categories = $self->{cnt_update_category}\n"
	);

	#add statistics to log
	&log_printf("Tatal of updated parent field in categories in xml = $self->{cnt_xml_category}");
	&log_printf(
		"Count of updated parent field in categories = $self->{cnt_update_category}"
	);
	&log_printf("=====CategoriesParentHandler: end of parsing=====");
}
1;


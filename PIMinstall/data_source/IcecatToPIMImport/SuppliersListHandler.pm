package SuppliersListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====SuppliersListHandler: start of parsing=====");
	$self->{supplier}            = {};
	$self->{cnt_insert_supplier} = 0;
	$self->{cnt_update_supplier} = 0;
	$self->{cnt_xml_supplier}    = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "supplier"
	if ( $data->{Name} eq 'Supplier' ) {
		$self->{supplier}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search supplier in database
		$sql = "SELECT supplier_id FROM supplier 
				WHERE icecat_id=$self->{supplier}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{supplier}->{supplier_id} = $query_res->[0][0];

		#if supplier does not exist or update mode is turned on
		if ( !defined $self->{supplier}->{supplier_id} || $self->{import_mode} == 1 ) {

			#get fields for supplier from xml
			$self->{supplier}->{name} =
			  &str_sqlize( $data->{Attributes}->{"{}Name"}->{Value} );
			if ( defined $data->{Attributes}->{"{}LogoPic"}->{Value} ) {
				$self->{supplier}->{low_pic} =
				  &str_sqlize( $data->{Attributes}->{"{}LogoPic"}->{Value} );
			}
			else {
				$self->{supplier}->{low_pic} = "NULL";
			}
			if ( defined $data->{Attributes}->{"{}Sponsor"}->{Value} ) {
				$self->{supplier}->{is_sponsor} =
				  $data->{Attributes}->{"{}Sponsor"}->{Value};
			}
			else {
				$self->{supplier}->{is_sponsor} = "0";
			}

			#insert supplier
			if ( !defined $self->{supplier}->{supplier_id} ) {
				$self->insert_supplier();
			}

			#update supplier
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_supplier();
			}
		}
		$self->{cnt_xml_supplier}++;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statisics to report
	PIMReport->append("\n=====SuppliersList.xml=====\n");
	PIMReport->append("Total suppliers in xml = $self->{cnt_xml_supplier}\n");
	PIMReport->append(
		"Inserted suppliers to database = $self->{cnt_insert_supplier}\n");
	PIMReport->append(
		"Updated suppliers in database = $self->{cnt_update_supplier}\n");

	#add statiscics to log
	&log_printf("Total suppliers in xml = $self->{cnt_xml_supplier}");
	&log_printf(
		"Inserted suppliers to database = $self->{cnt_insert_supplier}");
	&log_printf("Updated suppliers in database = $self->{cnt_update_supplier}");
	&log_printf("=====SuppliersListHandler: end of parsing=====");
}

#insert new supplier
sub insert_supplier() {
	my ( $self ) = @_;
	$sql = "INSERT INTO supplier 
			(name,low_pic,is_sponsor,icecat_id) 
			VALUES(
			$self->{supplier}->{name}, $self->{supplier}->{low_pic}, 
			$self->{supplier}->{is_sponsor},$self->{supplier}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_supplier}++;
}

#update supplier
sub update_supplier() {
	my ( $self ) = @_;
	$sql = "UPDATE supplier SET 
			name=$self->{supplier}->{name}, 
			low_pic=$self->{supplier}->{low_pic}, 
			is_sponsor=$self->{supplier}->{is_sponsor} 
			WHERE icecat_id = $self->{supplier}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_supplier}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;


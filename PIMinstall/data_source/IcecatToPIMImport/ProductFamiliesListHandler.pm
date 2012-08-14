package ProductFamiliesListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf(
		"=====SupplierProductFamiliesListHandler: start of parsing=====");
	$self->{product_family}             = {};
	$self->{product_family_name}        = {};
	$self->{product_family_description} = {};
	$self->{languages}                  = {};
	$self->{categories}                 = {};
	$self->{cnt_insert_product_family}  = 0;
	$self->{cnt_update_product_family}  = 0;
	$self->{cnt_xml_product_family}     = 0;
	$self->{cnt_insert_name}            = 0;
	$self->{cnt_update_name}            = 0;
	$self->{cnt_xml_name}               = 0;
	$self->{cnt_insert_description}     = 0;
	$self->{cnt_update_description}     = 0;
	$self->{cnt_xml_description}        = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "product_family"
	if ( $data->{Name} eq 'ProductFamily' ) {
		$self->{cnt_xml_product_family}++;
		$self->{product_family}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		#search product family in database
		$sql = "SELECT family_id,sid,tid FROM product_family 
				WHERE icecat_id = $self->{product_family}->{icecat_id}";
		$query_res                           = &do_query($sql);
		$self->{product_family}->{family_id} = $query_res->[0][0];
		$self->{product_family}->{sid}       = $query_res->[0][1];
		$self->{product_family}->{tid}       = $query_res->[0][2];
		#insert or update product family
		if (  !defined $self->{product_family}->{family_id}
			|| $self->{import_mode} == 1 )
		{
			$self->{product_family}->{catid_icecat} =
			  $data->{Attributes}->{"{}Category_ID"}->{Value};
			if ( !defined $self->{product_family}->{catid_icecat} ) {
				$self->{product_family}->{catid} = "0";
			}
			else {

				#get category from hash
				$self->{product_family}->{catid} =
				  $self->{categories}
				  ->{ $self->{product_family}->{catid_icecat} };
				if ( !defined $self->{product_family}->{catid} ) {

					#search category in database
					$sql = "SELECT catid FROM category 
							WHERE icecat_id = $self->{product_family}->{catid_icecat}";
					$query_res = &do_query($sql);
					$self->{product_family}->{catid} = $query_res->[0][0];
					if ( defined $self->{product_family}->{catid} ) {

						#put category to hash
						$self->{categories}
						  ->{ $self->{product_family}->{catid_icecat} } =
						  $self->{product_family}->{catid};
					}
				}
			}
			if ( defined $self->{product_family}->{catid} ) {
				$self->{product_family}->{low_pic} =
				  &str_sqlize( $data->{Attributes}->{"{}LowPic"}->{Value} );
				$self->{product_family}->{thumb_pic} =
				  &str_sqlize( $data->{Attributes}->{"{}ThumbPic"}->{Value} );

				#insert or update product family
				if ( !defined $self->{product_family}->{family_id} ) {
					$self->insert_product_family();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_product_family();
				}
			}
		}
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {
		$self->{cnt_xml_name}++;
		#$self->{product_family_name}->{icecat_id} =
		#  $data->{Attributes}->{"{}ID"}->{Value};

		$self->{product_family_name}->{langid_icecat} =
			$data->{Attributes}->{"{}langid"}->{Value};

		#get language from hash
		$self->{product_family_name}->{langid} =
			$self->{languages}->{ $self->{product_family_name}->{langid_icecat} };
		if ( !defined $self->{product_family_name}->{langid} ) {

			#search language in database
			$sql = "SELECT langid FROM language 
				WHERE icecat_id = $self->{product_family_name}->{langid_icecat}";
			$query_res = &do_query($sql);
			$self->{product_family_name}->{langid} = $query_res->[0][0];

			#put language to hash
			if ( defined $self->{product_family_name}->{langid} ) {
				$self->{languages}->{ $self->{product_family_name}->{langid_icecat} } =
					$self->{product_family_name}->{langid};
			}
		}
		if ( defined $self->{product_family_name}->{langid} ) {
				
			#search name in database
			$sql = "SELECT record_id FROM vocabulary 
				WHERE sid = $self->{product_family}->{sid} 
                       		AND langid = $self->{product_family_name}->{langid}";
			$query_res = &do_query($sql);
			$self->{product_family_name}->{record_id} = $query_res->[0][0];

			$self->{product_family_name}->{value} =
			  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
				
			#if name does not exist or update mode is turned on
			if ( !defined $self->{product_family_name}->{record_id} ) {
				$self->insert_product_family_name();
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_family_name();
			}
		}
	}

	#data for table "tex"
	elsif ( $data->{Name} eq 'Description' ) {
		$self->{cnt_xml_description}++;
		$self->{product_family_description}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		#search name in database
		$sql = "SELECT tex_id FROM tex 
				WHERE icecat_id = $self->{product_family_description}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{product_family_description}->{tex_id} = $query_res->[0][0];

		#if name does not exist or update mode is turned on
		if (  !defined $self->{product_family_description}->{tex_id}
			|| $self->{import_mode} == 1 )
		{
			$self->{product_family_description}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};

			#get language from hash
			$self->{product_family_description}->{langid} =
			  $self->{languages}
			  ->{ $self->{product_family_description}->{langid_icecat} };
			if ( !defined $self->{product_family_description}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{product_family_description}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{product_family_description}->{langid} =
				  $query_res->[0][0];

				#put language to hash
				if ( defined $self->{product_family_description}->{langid} ) {
					$self->{languages}
					  ->{ $self->{product_family_description}->{langid_icecat} }
					  = $self->{product_family_description}->{langid};
				}
			}
			if ( defined $self->{product_family_description}->{langid} ) {
				$self->{product_family_description}->{value} =
				  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
				if ( !defined $self->{product_family_description}->{tex_id} ) {
					$self->insert_product_family_description();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_product_family_description();
				}
			}
		}
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statisctics to report
	PIMReport->append("\n=====ProductFamiliesList.xml=====\n");
	PIMReport->append(
		"Total product families in xml = $self->{cnt_xml_product_family}\n");
	PIMReport->append(
		"Inserted product families to database = $self->{cnt_insert_product_family}\n"
	);
	PIMReport->append(
		"Updated product families in database = $self->{cnt_update_product_family}\n"
	);
	PIMReport->append("Total names in xml = $self->{cnt_xml_name}\n");
	PIMReport->append(
		"Inserted names to database = $self->{cnt_insert_name}\n");
	PIMReport->append("Updated names in database = $self->{cnt_update_name}\n");
	PIMReport->append(
		"Total descriptions in xml = $self->{cnt_xml_description}\n");
	PIMReport->append(
		"Inserted descriptions to database = $self->{cnt_insert_description}\n"
	);
	PIMReport->append(
		"Updated descriptions in database = $self->{cnt_update_description}\n");

	#add statistics to log
	&log_printf(
		"Total product families in xml = $self->{cnt_xml_product_family}");
	&log_printf(
		"Inserted product families to database = $self->{cnt_insert_product_family}"
	);
	&log_printf(
		"Updated product families in database = $self->{cnt_update_product_family}"
	);
	&log_printf("Total names in xml = $self->{cnt_xml_name}");
	&log_printf("Inserted names to database = $self->{cnt_insert_name}");
	&log_printf("Updated names in database = $self->{cnt_update_name}");
	&log_printf("Total descriptions in xml = $self->{cnt_xml_description}");
	&log_printf(
		"Inserted descriptions to database = $self->{cnt_insert_description}");
	&log_printf(
		"Updated descriptions in database = $self->{cnt_update_description}");
	&log_printf("=====SupplierProductFamiliesListHandler: end of parsing=====");
}

#insert product family
sub insert_product_family {
	my ($self) = @_;

	#get sid for new product family
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{product_family}->{sid} = $query_res->[0][0];

	#get tid for new product family
	$sql = "INSERT INTO tid_index VALUES()";
	&do_statement($sql);
	$sql                           = "SELECT LAST_INSERT_ID()";
	$query_res                     = &do_query($sql);
	$self->{product_family}->{tid} = $query_res->[0][0];

	#insert product family
	$sql = "INSERT INTO product_family 
			(sid,tid,low_pic,thumb_pic,catid,icecat_id) 
			VALUES(
			$self->{product_family}->{sid}, 
			$self->{product_family}->{tid},
			$self->{product_family}->{low_pic},
			$self->{product_family}->{thumb_pic},
			$self->{product_family}->{catid},
			$self->{product_family}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_product_family}++;
}

#update product family
sub update_product_family {
	my ($self) = @_;
	my $sql = "UPDATE product_family SET 
			low_pic = $self->{product_family}->{low_pic}, 
			catid = $self->{product_family}->{catid} 
			WHERE icecat_id = $self->{product_family}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_product_family}++;
}

#insert product_family name
sub insert_product_family_name {
	my ($self) = @_;
	#print Dumper($self->{product_family})."\n";
	my $sql = "INSERT INTO vocabulary 
			(sid, langid, value,icecat_id) 
			VALUES( 
			$self->{product_family}->{sid},
			$self->{product_family_name}->{langid}, 
			$self->{product_family_name}->{value},
			$self->{product_family_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_name}++;
}

#update product_family name
sub update_product_family_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			value = $self->{product_family_name}->{value} 
			WHERE record_id = $self->{product_family_name}->{record_id}";
	&do_statement($sql);
	$self->{cnt_update_name}++;
}

#insert product_family description
sub insert_product_family_description {
	my ($self) = @_;
	my $sql = "INSERT INTO tex 
			(tid, langid, value,icecat_id) 
			VALUES( 
			$self->{product_family}->{tid},
			$self->{product_family_description}->{langid}, 
			$self->{product_family_description}->{value},
			$self->{product_family_description}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_description}++;
}

#update product_family name
sub update_product_family_description {
	my ($self) = @_;
	my $sql = "UPDATE tex SET 
			tid = $self->{product_family}->{tid}, 
			langid=$self->{product_family_description}->{langid},
			value = $self->{product_family_description}->{value} 
			WHERE tex_id = $self->{product_family_description}->{tex_id}";
	&do_statement($sql);
	$self->{cnt_update_description}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

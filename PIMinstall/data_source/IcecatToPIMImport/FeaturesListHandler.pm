package FeaturesListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("======FeaturesListHandler: start of parsing=====");
	$self->{feature}                = {};
	$self->{feature_name}           = {};
	$self->{feature_description}    = {};
	$self->{languages}              = {};
	$self->{is_feature_inserted}    = 0;
	$self->{cnt_insert_feature}     = 0;
	$self->{cnt_update_feature}     = 0;
	$self->{cnt_xml_feature}        = 0;
	$self->{cnt_insert_name}        = 0;
	$self->{cnt_update_name}        = 0;
	$self->{cnt_xml_name}           = 0;
	$self->{cnt_insert_description} = 0;
	$self->{cnt_update_description} = 0;
	$self->{cnt_xml_description}    = 0;
	$self->{is_in_name}             = 0;
	$self->{is_in_description}      = 0;
	$self->{is_in_restricted_value} = 0;

}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "feature"
	if ( $data->{Name} eq 'Feature' ) {
		$self->{feature}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search feature in database
		$sql = "SELECT feature_id,sid,tid FROM feature 
				WHERE icecat_id = $self->{feature}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{feature}->{feature_id} = $query_res->[0][0];
		if ( defined $self->{feature}->{feature_id} ) {
			$self->{feature}->{sid}      = $query_res->[0][1];
			$self->{feature}->{tid}      = $query_res->[0][2];
			$self->{is_feature_inserted} = 0;
		}

		#if feature does not exist or update mode is turned on
		if ( !defined $self->{feature}->{feature_id} || $self->{import_mode} == 1 ) {
			$self->{feature}->{type} =
			  &str_sqlize( $data->{Attributes}->{"{}Type"}->{Value} );
			$self->{feature}->{class} =
			  $data->{Attributes}->{"{}Class"}->{Value};

			#initialize restricted values for current feature
			$self->{feature}->{restricted_values} = "";
			if ( !defined $self->{feature}->{feature_id} ) {
				$self->insert_feature();
			}
		}
		$self->{cnt_xml_feature}++;
	}

	#field "measure_id" of table "feature"
	elsif ( $data->{Name} eq 'Measure' ) {
		if ( $self->{is_feature_inserted} == 1 || $self->{import_mode} == 1 ) {
			$self->{feature}->{measure_id_icecat} =
			  $data->{Attributes}->{"{}ID"}->{Value};

			#search measure in database
			$sql = "SELECT measure_id FROM measure 
					WHERE icecat_id = $self->{feature}->{measure_id_icecat}";
			$query_res = &do_query($sql);
			$self->{feature}->{measure_id} = $query_res->[0][0];
			if ( !defined $self->{feature}->{measure_id} ) {
				$self->{feature}->{measure_id} = "0";
			}
		}
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {
		$self->{is_in_name}++;
		$self->{feature_name}->{langid_icecat} =
		  $data->{Attributes}->{"{}langid"}->{Value};
		$self->{feature_name}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{cnt_xml_name}++;
	}

	#data for table tex
	elsif ( $data->{Name} eq 'Description' ) {
		$self->{is_in_description}++;
		$self->{feature_description}->{langid_icecat} =
		  $data->{Attributes}->{"{}langid"}->{Value};
		$self->{feature_description}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{cnt_xml_description}++;
	}

	#field "restricted_values" of table "feature"
	elsif ( $data->{Name} eq 'RestrictedValue' ) {
		$self->{is_in_restricted_value}++;
	}
}

#characters in xml file
sub characters {
	my ( $self, $data ) = @_;
	if ( $self->{is_in_name} == 1 ) {
		$self->{feature_name}->{value} = &str_sqlize( $data->{Data} );
	}
	elsif ( $self->{is_in_description} == 1 ) {
		$self->{feature_description}->{value} = &str_sqlize( $data->{Data} );
	}
	if ( $self->{is_in_restricted_value} == 1 ) {
		$self->{feature}->{restricted_values} .= "$data->{Data}\n";
	}
}

#end element in xml file
sub end_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "feature"
	if ( $data->{Name} eq 'Feature' ) {
		if ( $self->{is_feature_inserted} == 1 || $self->{import_mode} == 1 ) {
			$self->{feature}->{restricted_values} =
			  &str_sqlize( $self->{feature}->{restricted_values} );
			$self->update_feature();
		}
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {

		#search feature name in database
		$sql = "SELECT record_id FROM vocabulary 
				WHERE icecat_id=$self->{feature_name}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{feature_name}->{record_id} = $query_res->[0][0];

		#if feature name does not exist or update mode is turned on
		if ( !defined $self->{feature_name}->{record_id} || $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{feature_name}->{langid} =
			  $self->{languages}->{ $self->{feature_name}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{feature_name}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{feature_name}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{feature_name}->{langid} = $query_res->[0][0];
				if ( defined $self->{feature_name}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{feature_name}->{langid_icecat} } =
					  $self->{feature_name}->{langid};
				}
			}

			#insert or update feature name
			if ( defined $self->{feature_name}->{langid} ) {
				if ( !defined $self->{feature_name}->{value} ) {
					$self->{feature_name}->{value} = "NULL";
				}
				if ( !defined $self->{feature_name}->{record_id} ) {
					$self->insert_feature_name();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_feature_name();
				}
			}
		}
		$self->{is_in_name}--;
	}

	#data for table "tex"
	elsif ( $data->{Name} eq 'Description' ) {

		#search feature description in database
		$sql = "SELECT tex_id FROM tex 
				WHERE icecat_id=$self->{feature_description}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{feature_description}->{tex_id} = $query_res->[0][0];

		#if feature description does no exist or update mode is turned on
		if (  !defined $self->{feature_description}->{tex_id}
			|| $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{feature_description}->{langid} =
			  $self->{languages}
			  ->{ $self->{feature_description}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{feature_description}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{feature_description}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{feature_description}->{langid} = $query_res->[0][0];
				if ( defined $self->{feature_description}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{feature_description}->{langid_icecat} } =
					  $self->{feature_description}->{langid};
				}
			}

			#insert or update feature description
			if ( defined $self->{feature_description}->{langid} ) {
				if ( !defined $self->{feature_description}->{value} ) {
					$self->{feature_description}->{value} = "NULL";
				}
				if ( !defined $self->{feature_description}->{tex_id} ) {
					$self->insert_feature_description();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_feature_description();
				}
			}
		}
		$self->{is_in_description}--;
	}

	#field "restricted_values" of table "feature"
	elsif ( $data->{Name} eq 'RestrictedValue' ) {
		$self->{is_in_restricted_value}--;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append("\n=====FeaturesList.xml=====\n");
	PIMReport->append(
		"Total features in xml = $self->{cnt_xml_feature}\n");
	PIMReport->append(
		"Inserted features to database = $self->{cnt_insert_feature}\n");
	PIMReport->append(
		"Updated features in database = $self->{cnt_update_feature}\n");
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
	&log_printf("Total features in xml = $self->{cnt_xml_feature}");
	&log_printf("Inserted features to database = $self->{cnt_insert_feature}");
	&log_printf("Updated features in database = $self->{cnt_update_feature}");
	&log_printf("Total names in xml = $self->{cnt_xml_name}");
	&log_printf("Inserted names to database = $self->{cnt_insert_name}");
	&log_printf("Updated names in database = $self->{cnt_update_name}");
	&log_printf("Total descriptions in xml = $self->{cnt_xml_description}");
	&log_printf(
		"Inserted descriptions to database = $self->{cnt_insert_description}");
	&log_printf(
		"Updated descriptions in database = $self->{cnt_update_description}");
	&log_printf("=====FeaturesListHandler: end of parsing=====");
}

#insert feature
sub insert_feature {
	my ($self) = @_;

	#get "sid" for new feature
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{feature}->{sid} = $query_res->[0][0];

	#get "tid" for new feature
	$sql = "INSERT INTO tid_index VALUES()";
	&do_statement($sql);
	$sql                    = "SELECT LAST_INSERT_ID()";
	$query_res              = &do_query($sql);
	$self->{feature}->{tid} = $query_res->[0][0];

	#insert new feature
	$sql = "INSERT INTO feature 
			(sid,tid,type,class,icecat_id ) 
			VALUES( 
			$self->{feature}->{sid}, 
			$self->{feature}->{tid}, 
			$self->{feature}->{type}, 
			$self->{feature}->{class}, 
			$self->{feature}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_feature}++;
	$self->{is_feature_inserted} = 1;
}

#update feature
sub update_feature {
	my ($self) = @_;
	my $sql = "UPDATE feature SET 
			measure_id=$self->{feature}->{measure_id}, 
			type=$self->{feature}->{type}, 
			class=$self->{feature}->{class}, 
			restricted_values = $self->{feature}->{restricted_values} 
			WHERE icecat_id=$self->{feature}->{icecat_id} ";
	&do_statement($sql);
	$self->{cnt_update_feature}++;
}

#insert feature name
sub insert_feature_name {
	my ($self) = @_;
	my $sql = "INSERT INTO vocabulary 
			(sid, langid, value,icecat_id) 
			VALUES( 
			$self->{feature}->{sid},
			$self->{feature_name}->{langid}, 
			$self->{feature_name}->{value},
			$self->{feature_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_name}++;
}

#update feature name
sub update_feature_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			sid = $self->{feature}->{sid}, 
			langid=$self->{feature_name}->{langid},
			value = $self->{feature_name}->{value} 
			WHERE icecat_id = $self->{feature_name}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_name}++;
}

#insert feature description
sub insert_feature_description {
	my ($self) = @_;
	my $sql = "INSERT INTO tex 
			(tid, langid, value,icecat_id)  
			VALUES( 
			$self->{feature}->{tid},
			$self->{feature_description}->{langid}, 
			$self->{feature_description}->{value},
			$self->{feature_description}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_description}++;
}

#update feature name
sub update_feature_description {
	my ($self) = @_;
	my $sql = "UPDATE tex SET 
			tid = $self->{feature}->{tid}, 
			langid=$self->{feature_description}->{langid},
			value = $self->{feature_description}->{value} 
			WHERE icecat_id = $self->{feature_description}->{icecat_id}";
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

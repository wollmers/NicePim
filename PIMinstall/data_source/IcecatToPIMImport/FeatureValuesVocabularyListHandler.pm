package FeatureValuesVocabularyListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf(
		"=====FeatureValuesVocabularyListHandler: start of parsing=====");
	$self->{feature_values_vocabulary} = {};
	$self->{feature_values_group}      = {};
	$self->{feature_values_groups}     = {};
	$self->{languages}                 = {};
	$self->{cnt_insert_group}          = 0;
	$self->{cnt_xml_group}             = 0;
	$self->{cnt_insert_vocabulary}     = 0;
	$self->{cnt_update_vocabulary}     = 0;
	$self->{cnt_xml_vocabulary}        = 0;
	$self->{is_in_feature_value}       = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "feature_values_group"
	if ( $data->{Name} eq 'FeatureValuesVocabulary' ) {
		$self->{feature_values_group}->{icecat_id} =
		  $data->{Attributes}->{"{}Group_ID"}->{Value};

		#get feature values group from hash
		$self->{feature_values_group}->{feature_values_group_id} =
		  $self->{feature_values_groups}
		  ->{ $self->{feature_values_group}->{icecat_id} };
		if ( !defined $self->{feature_values_group}->{feature_values_group_id} ) {

			#search feature values group in database
			$sql = "SELECT feature_values_group_id FROM feature_values_group 
					WHERE icecat_id = $self->{feature_values_group}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{feature_values_group}->{feature_values_group_id} =
			  $query_res->[0][0];

			#insert new feature values group
			if ( !defined $self->{feature_values_group}->{feature_values_group_id} ) {
				$self->{feature_values_group}->{name} = &str_sqlize("");
				$self->insert_feature_values_group();
			}

			#push feature values group to hash
			$self->{feature_values_groups}
			  ->{ $self->{feature_values_group}->{icecat_id} } =
			  $self->{feature_values_group}->{feature_values_group_id};
			$self->{cnt_xml_group}++;
		}
		$self->{feature_values_vocabulary}->{key_value} =
		  &str_sqlize( $data->{Attributes}->{"{}Key_Value"}->{Value} );
	}

	#data for table "feature_values_vacabulary"
	elsif ( $data->{Name} eq 'FeatureValue' ) {
		$self->{is_in_feature_value}++;
		$self->{cnt_xml_vocabulary}++;
		$self->{feature_values_vocabulary}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		#search feature values vocabulary in database
		$sql = "SELECT record_id FROM feature_values_vocabulary 
				WHERE icecat_id = $self->{feature_values_vocabulary}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{feature_values_vocabulary}->{record_id} = $query_res->[0][0];

		#if feature values vocabulary does not exist or update mode is turned on
		if (  !defined $self->{feature_values_vocabulary}->{record_id}
			|| $self->{import_mode} == 1 )
		{
			$self->{feature_values_vocabulary}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};

			#get language from hash
			$self->{feature_values_vocabulary}->{langid} =
			  $self->{languages}
			  ->{ $self->{feature_values_vocabulary}->{langid_icecat} };
			if ( !defined $self->{feature_values_vocabulary}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{feature_values_vocabulary}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{feature_values_vocabulary}->{langid} =
				  $query_res->[0][0];
				if ( defined $self->{feature_values_vocabulary}->{langid} ) {

					#push language to hash
					$self->{languages}
					  ->{ $self->{feature_values_vocabulary}->{langid_icecat} }
					  = $self->{feature_values_vocabulary}->{langid};
				}
			}
		}
	}
}

#characters in xml file
sub characters {
	my ( $self, $data ) = @_;
	if ( $self->{is_in_feature_value} == 1 ) {
		$self->{feature_values_vocabulary}->{value} =
		  &str_sqlize( $data->{Data} );
	}
}

#end element in xml file
sub end_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );
	if ( $data->{Name} eq 'FeatureValue' ) {

		#if feature values vocabulary does not exist or update mode is turned on
		if (  !defined $self->{feature_values_vocabulary}->{record_id}
			|| $self->{import_mode} == 1 )
		{

			#insert or update feature values vocabulary
			if ( defined $self->{feature_values_vocabulary}->{langid} ) {
				if ( !defined $self->{feature_values_vocabulary}->{record_id} ) {
					$self->insert_feature_values_vocabulary();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_feature_values_vocabulary();
				}
			}
		}
		$self->{is_in_feature_value}--;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to xml
	PIMReport->append("\n=====FeatureValuesVocabularyList.xml=====\n");
	PIMReport->append(
		"Tatal feature values groups in xml = $self->{cnt_xml_group}\n");
	PIMReport->append(
		"Inserted feature values groups = $self->{cnt_insert_group}\n");
	PIMReport->append(
		"Tatal feature values vacabulary in xml = $self->{cnt_xml_vocabulary}\n"
	);
	PIMReport->append(
		"Inserted to feature values vacabulary = $self->{cnt_insert_vocabulary}\n"
	);
	PIMReport->append(
		"Updated in feature values vacabulary = $self->{cnt_update_vocabulary}\n"
	);

	#add statistics to log
	&log_printf("Tatal feature values groups in xml = $self->{cnt_xml_group}");
	&log_printf("Inserted feature values groups = $self->{cnt_insert_group}");
	&log_printf(
		"Tatal feature values vacabulary in xml = $self->{cnt_xml_vocabulary}"
	);
	&log_printf(
		"Inserted to feature values vacabulary = $self->{cnt_insert_vocabulary}"
	);
	&log_printf(
		"Updated in feature values vacabulary = $self->{cnt_update_vocabulary}"
	);
	&log_printf("====FeatureValuesVocabularyListHandler: end of parsing=====");
}



#insert feature values group to database
sub insert_feature_values_group {
	my ($self) = @_;

	#insert feature values group to database
	my $sql = "INSERT INTO feature_values_group 
			(name,icecat_id) 
			VALUES(
			$self->{feature_values_group}->{name},
			$self->{feature_values_group}->{icecat_id})";
	&do_statement($sql);

	#get id of inserted feature values group
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{feature_values_group}->{feature_values_group_id} =
	  $query_res->[0][0];
	$self->{cnt_insert_group}++;
}

#insert feature values vocabulary to database
sub insert_feature_values_vocabulary {
	my ($self) = @_;
	my $sql = "INSERT INTO feature_values_vocabulary 
			(key_value,langid,feature_values_group_id,
			value,icecat_id) 
			VALUES(
			$self->{feature_values_vocabulary}->{key_value},
			$self->{feature_values_vocabulary}->{langid},
			$self->{feature_values_group}->{feature_values_group_id},
			$self->{feature_values_vocabulary}->{value},
			$self->{feature_values_vocabulary}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_vocabulary}++;
}

#update feature values vocabulary in database
sub update_feature_values_vocabulary {
	my ($self) = @_;
	my $sql = "UPDATE feature_values_vocabulary SET 
			key_value = $self->{feature_values_vocabulary}->{key_value},
			langid = $self->{feature_values_vocabulary}->{langid},
			feature_values_group_id = $self->{feature_values_group}->{feature_values_group_id},
			value = $self->{feature_values_vocabulary}->{value} 
			WHERE icecat_id= $self->{feature_values_vocabulary}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_vocabulary}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

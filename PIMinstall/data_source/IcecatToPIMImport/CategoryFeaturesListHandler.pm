package CategoryFeaturesListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====CategoryFeatureListHandler: start of parsing=====");
	$self->{category}                          = {};
	$self->{category_feature_group}            = {};
	$self->{category_feature_groups}           = {};    #hash category_feature_groups
	$self->{feature_group}                     = {};
	$self->{feature_group_name}                = {};
	$self->{category_feature}                  = {};
	$self->{feature}                           = {};
	$self->{feature_groups}                    = {};    #hash feature_groups
	$self->{feature_group_sids}                = {};
	$self->{languages}                         = {};    #hash for languages
	$self->{features}                          = {};
	$self->{cnt_insert_category_feature_group} = 0;
	$self->{cnt_update_category_feature_group} = 0;
	$self->{cnt_xml_category_feature_group}    = 0;
	$self->{cnt_xml_name}                      = 0;
	$self->{cnt_update_name}                   = 0;
	$self->{cnt_insert_name}                   = 0;
	$self->{cnt_xml_feature}                   = 0;
	$self->{cnt_update_feature}                = 0;
	$self->{cnt_xml_category_feature}          = 0;
	$self->{cnt_insert_category_feature}       = 0;
	$self->{cnt_update_category_feature}       = 0;
	$self->{cnt_xml_feature_group}             = 0;
	$self->{cnt_insert_feature_group}          = 0;
	$self->{is_feature_group_edited}           = 0;
	$self->{is_in_feature_group}               = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "category"
	if ( $data->{Name} eq 'Category' ) {
		$self->{category}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search category in database
		$sql = "SELECT catid FROM category 
				WHERE icecat_id = $self->{category}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category}->{catid} = $query_res->[0][0];
	}

	#data for table "category_feature_group"
	elsif ( $data->{Name} eq 'CategoryFeatureGroup' ) {
		$self->{cnt_xml_category_feature_group}++;
		$self->{category_feature_group}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{category_feature_group}->{no} =
		  $data->{Attributes}->{"{}No"}->{Value};
	}

	#data for table "feature_group"
	elsif ( $data->{Name} eq 'FeatureGroup' ) {
		$self->{is_in_feature_group}++;
		$self->{feature_group}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{feature_group}->{feature_group_id} =
		  $self->{feature_groups}->{ $self->{feature_group}->{icecat_id} };
		$self->{feature_group}->{sid} =
		  $self->{feature_group_sids}->{ $self->{feature_group}->{icecat_id} };

		#check repetition of feature group
		if ( !defined $self->{feature_group}->{feature_group_id} ) {
			$self->{cnt_xml_feature_group}++;

			#search feature group in database
			$sql = "SELECT feature_group_id,sid FROM feature_group 
					WHERE icecat_id = $self->{feature_group}->{icecat_id}";
			$query_res                                 = &do_query($sql);
			$self->{feature_group}->{feature_group_id} = $query_res->[0][0];
			$self->{feature_group}->{sid}              = $query_res->[0][1];

			#insert feature group
			if ( !defined $self->{feature_group}->{feature_group_id} ) {
				$self->insert_feature_group();
			}

			#save feature group and sid to hashes
			$self->{feature_groups}->{ $self->{feature_group}->{icecat_id} } =
			  $self->{feature_group}->{feature_group_id};
			$self->{feature_group_sids}
			  ->{ $self->{feature_group}->{icecat_id} } =
			  $self->{feature_group}->{sid};
			$self->{is_feature_group_edited} = 1;
		}
		else {
			$self->{is_feature_group_edited} = 0;
		}

		#search category feature group in database
		$sql = "SELECT category_feature_group_id FROM category_feature_group 
				WHERE icecat_id = $self->{category_feature_group}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category_feature_group}->{category_feature_group_id} =
		  $query_res->[0][0];

		#insert or update category feature group
		if (  !defined $self->{category_feature_group}->{category_feature_group_id}
			|| $self->{import_mode} == 1 )
		{
			if ( defined $self->{feature_group}->{feature_group_id} ) {
				if ( !defined $self->{category_feature_group}
					->{category_feature_group_id} )
				{
					$self->insert_category_feature_group();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_category_feature_group();
				}
			}
		}
	}

	#data for table "category_feature" and "feature"
	elsif ( $data->{Name} eq 'Feature' ) {
		$self->{feature}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search feature in hash
		$self->{feature}->{feature_id} =
		  $self->{features}->{ $self->{feature}->{icecat_id} };
		if ( !defined $self->{feature}->{feature_id} ) {
			$self->{cnt_xml_feature}++;

			#search feature in database
			$sql = "SELECT feature_id FROM feature 
					WHERE icecat_id = $self->{feature}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{feature}->{feature_id} = $query_res->[0][0];
			if ( defined $self->{feature}->{feature_id} ) {
				$self->{feature}->{class} =
				  $data->{Attributes}->{"{}Class"}->{Value};
				$self->{feature}->{limit_direction} =
				  $data->{Attributes}->{"{}LimitDirection"}->{Value};

				#update feature in database
				$sql = "UPDATE feature SET 
						class = $self->{feature}->{class},
						limit_direction = $self->{feature}->{limit_direction}";
				&do_statement($sql);
				$self->{cnt_update_feature}++;

				#push feature to hash
				$self->{features}->{ $self->{feature}->{icecat_id} } =
				  $self->{feature}->{feature_id};

			}
		}
		
		$self->{category_feature_group}->{icecat_id} = $data->{Attributes}->{"{}CategoryFeatureGroup_ID"}->{Value};

		#search category feature group in hash
		$self->{category_feature_group}->{category_feature_group_id} =
		  $self->{category_feature_groups}->{ $self->{category_feature_group}->{icecat_id} };
		if ( !defined $self->{category_feature_group}->{category_feature_group_id} ) {
			
			#search category feature group in database
			$sql = "SELECT category_feature_group_id FROM category_feature_group  
					WHERE icecat_id = $self->{category_feature_group}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{category_feature_group}->{category_feature_group_id} = $query_res->[0][0];
			if ( defined $self->{category_feature_group}->{category_feature_group_id} ) {

				#push category feature group to hash
				$self->{category_feature_groups}->{ $self->{category_feature_group}->{icecat_id} } =
				  $self->{category_feature_group}->{category_feature_group_id};
			}
		}
		
		$self->{cnt_xml_category_feature}++;
		if ( defined $self->{feature}->{feature_id} && defined $self->{category_feature_group}->{category_feature_group_id} ) {
			$self->{category_feature}->{icecat_id} =
			  $data->{Attributes}->{"{}CategoryFeature_ID"}->{Value};

			#search category feature in database
			$sql = "SELECT category_feature_id FROM category_feature 
				WHERE icecat_id = $self->{category_feature}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{category_feature}->{category_feature_id} =
			  $query_res->[0][0];

			#category feature does not exist or update mode is turned on
			if (  !defined $self->{category_feature}->{category_feature_id}
				|| $self->{import_mode} == 1 )
			{
				$self->{category_feature}->{mandatory} =
				  $data->{Attributes}->{"{}Mandatory"}->{Value};
				$self->{category_feature}->{no} =
				  $data->{Attributes}->{"{}No"}->{Value};
				$self->{category_feature}->{searchable} =
				  $data->{Attributes}->{"{}Searchable"}->{Value};
				$self->{category_feature}->{use_dropdown_input} =
				  &str_sqlize(
					$data->{Attributes}->{"{}Use_Dropdown_Input"}->{Value} );
			}

			#insert or update category feature
			if ( !defined $self->{category_feature}->{category_feature_id} ) {
				$self->insert_category_feature();
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_category_feature();
			}
		}
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {

		#check repetition of feature group
		if (   $self->{is_feature_group_edited} == 1
			&& $self->{is_in_feature_group} == 1 )
		{
			$self->{cnt_xml_name}++;
			$self->{feature_group_name}->{icecat_id} =
			  $data->{Attributes}->{"{}ID"}->{Value};

			#search feature group name in database
			$sql = "SELECT record_id FROM vocabulary 
					WHERE icecat_id = $self->{feature_group_name}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{feature_group_name}->{record_id} = $query_res->[0][0];
			if (  !defined $self->{feature_group_name}->{record_id}
				|| $self->{import_mode} == 1 )
			{

				#get language from hash
				$self->{feature_group_name}->{langid_icecat} =
				  $data->{Attributes}->{"{}langid"}->{Value};
				$self->{feature_group_name}->{langid} =
				  $self->{languages}
				  ->{ $self->{feature_group_name}->{langid_icecat} };

				#language does not exist in hash
				if ( !defined $self->{feature_group_name}->{langid} ) {

					#search language in database
					$sql = "SELECT langid FROM language 
							WHERE icecat_id = $self->{feature_group_name}->{langid_icecat}";
					$query_res = &do_query($sql);
					$self->{feature_group_name}->{langid} = $query_res->[0][0];
					if ( defined $self->{feature_group_name}->{langid} ) {

						#put language to hash
						$self->{languages}
						  ->{ $self->{feature_group_name}->{langid_icecat} } =
						  $self->{feature_group_name}->{langid};
					}
				}

				#insert or update feature group name
				if ( defined $self->{feature_group_name}->{langid} ) {
					$self->{feature_group_name}->{value} =
					  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
					if ( !defined $self->{feature_group_name}->{record_id} ) {
						$self->insert_feature_group_name();
					}
					elsif ( $self->{import_mode} == 1 ) {
						$self->update_feature_group_name();
					}
				}
			}
		}
	}
}

#end of element in xml file
sub end_element {
	my ( $self, $data ) = @_;
	if ( $data->{Name} eq 'FeatureGroup' ) {
		$self->{is_in_feature_group}--;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append("\n=====CategoryFeaturesListHandler.xml=====\n");
	PIMReport->append(
		"Total category feature group = $self->{cnt_xml_category_feature_group}\n"
	);
	PIMReport->append(
		"Inserted category feature group = $self->{cnt_insert_category_feature_group}\n"
	);
	PIMReport->append(
		"Updated category feature group = $self->{cnt_update_category_feature_group}\n"
	);
	PIMReport->append("Total feature group = $self->{cnt_xml_feature_group}\n");
	PIMReport->append(
		"Inserted feature group = $self->{cnt_insert_feature_group}\n");
	PIMReport->append("Total feature group name = $self->{cnt_xml_name}\n");
	PIMReport->append(
		"Inserted feature group name = $self->{cnt_insert_name}\n");
	PIMReport->append(
		"Updated feature group name = $self->{cnt_update_name}\n");
	PIMReport->append("Total feature = $self->{cnt_xml_feature}\n");
	PIMReport->append("Updated feature = $self->{cnt_update_feature}\n");
	PIMReport->append(
		"Total category feature = $self->{cnt_xml_category_feature}\n");
	PIMReport->append(
		"Inserted category feature = $self->{cnt_insert_category_feature}\n");
	PIMReport->append(
		"Updated category feature = $self->{cnt_update_category_feature}\n");

	#add statistics to log
	&log_printf(
		"Total category feature group = $self->{cnt_xml_category_feature_group}"
	);
	&log_printf(
		"Inserted category feature group = $self->{cnt_insert_category_feature_group}"
	);
	&log_printf(
		"Updated category feature group = $self->{cnt_update_category_feature_group}"
	);
	&log_printf("Total feature group = $self->{cnt_xml_feature_group}");
	&log_printf("Inserted feature group = $self->{cnt_insert_feature_group}");
	&log_printf("Total feature group name = $self->{cnt_xml_name}");
	&log_printf("Inserted feature group name = $self->{cnt_insert_name}");
	&log_printf("Updated feature group name = $self->{cnt_update_name}");
	&log_printf("Total feature = $self->{cnt_xml_feature}");
	&log_printf("Updated feature = $self->{cnt_update_feature}");
	&log_printf("Total category feature = $self->{cnt_xml_category_feature}");
	&log_printf(
		"Inserted category feature = $self->{cnt_insert_category_feature}");
	&log_printf(
		"Updated category feature = $self->{cnt_update_category_feature}");
	&log_printf("=====CategoryFeatureListHandler: end of parsing=====");
}

#insert category feature group
sub insert_category_feature_group {
	my ($self) = @_;
	my $sql = "INSERT INTO category_feature_group 
			(catid, no, feature_group_id, icecat_id) 
			VALUES(
			$self->{category}->{catid}, 
			$self->{category_feature_group}->{no}, 
			$self->{feature_group}->{feature_group_id}, 
			$self->{category_feature_group}->{icecat_id})";
	&do_statement($sql);

	#get id on new category feature group
	#$sql = "SELECT LAST_INSERT_ID()";
	#my $query_res = &do_query($sql);
	#$self->{category_feature_group}->{category_feature_group_id} =
	#  $query_res->[0][0];
	$self->{cnt_insert_category_feature_group}++;
}

#update category feature group
sub update_category_feature_group {
	my ($self) = @_;
	my $sql = "UPDATE category_feature_group SET 
			catid = $self->{category}->{catid}, 
			no = $self->{category_feature_group}->{no}, 
			feature_group_id = $self->{feature_group}->{feature_group_id} 
			WHERE icecat_id = $self->{category_feature_group}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_category_feature_group}++;
}

#insert new feature group
sub insert_feature_group {
	my ($self) = @_;

	#get sid for new feature group
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{feature_group}->{sid} = $query_res->[0][0];

	#insert new feature group
	$sql = "INSERT INTO feature_group 
			(sid,icecat_id) 
			VALUES(
			$self->{feature_group}->{sid}, 
			$self->{feature_group}->{icecat_id})";
	&do_statement($sql);

	#get id of new feature group
	$sql                                       = "SELECT LAST_INSERT_ID()";
	$query_res                                 = &do_query($sql);
	$self->{feature_group}->{feature_group_id} = $query_res->[0][0];
	$self->{cnt_insert_feature_group}++;
}

#insert new feature group name
sub insert_feature_group_name {
	my ($self) = @_;
	my $sql = "INSERT INTO vocabulary (sid,langid,value,icecat_id) 
			VALUES(
			$self->{feature_group}->{sid},
			$self->{feature_group_name}->{langid},
			$self->{feature_group_name}->{value},
			$self->{feature_group_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_name}++;
}

#update feature group name
sub update_feature_group_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			sid = $self->{feature_group}->{sid},
			langid = $self->{feature_group_name}->{langid},
			value = $self->{feature_group_name}->{value} 
			WHERE icecat_id = $self->{feature_group_name}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_name}++;
}

#insert category feature
sub insert_category_feature {
	my ($self) = @_;
	my $sql = "INSERT INTO category_feature 
			(feature_id, catid, no, searchable, 
			category_feature_group_id, use_dropdown_input, 
			mandatory,icecat_id) 
			VALUES(
			$self->{feature}->{feature_id},
			$self->{category}->{catid},$self->{category_feature}->{no},
			$self->{category_feature}->{searchable},
			$self->{category_feature_group}->{category_feature_group_id},
			$self->{category_feature}->{use_dropdown_input},
			$self->{category_feature}->{mandatory},
			$self->{category_feature}->{icecat_id}) ";
	&do_statement($sql);
	$self->{cnt_insert_category_feature}++;
}

#update category feature
sub update_category_feature {
	my ($self) = @_;
	my $sql = "UPDATE category_feature SET 
			feature_id = $self->{feature}->{feature_id},
			catid = $self->{category}->{catid},
			no = $self->{category_feature}->{no},
			searchable = $self->{category_feature}->{searchable},
			category_feature_group_id = $self->{category_feature_group}->{category_feature_group_id},
			use_dropdown_input = 
			$self->{category_feature}->{use_dropdown_input} 
			WHERE icecat_id = $self->{category_feature}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_category_feature}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

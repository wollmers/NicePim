package MeasuresListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====MeasuresListHandler: start of parsing=====");
	$self->{languages}               = {};
	$self->{measure}                 = {};
	$self->{measure_name}            = {};
	$self->{measure_description}     = {};
	$self->{measure_sign}            = {};
	$self->{is_measure_inserted}     = 0;
	$self->{is_in_name}              = 0;
	$self->{is_in_description}       = 0;
	$self->{in_sign}                 = 0;
	$self->{cnt_insert_measure}      = 0;
	$self->{cnt_update_measure}      = 0;
	$self->{cnt_xml_measure}         = 0;
	$self->{cnt_insert_description}  = 0;
	$self->{cnt_update_description}  = 0;
	$self->{cnt_xml_description}     = 0;
	$self->{cnt_insert_name}         = 0;
	$self->{cnt_update_name}         = 0;
	$self->{cnt_xml_name}            = 0;
	$self->{cnt_insert_measure_sign} = 0;
	$self->{cnt_update_measure_sign} = 0;
	$self->{cnt_xml_measure_sign}    = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "measure"
	if ( $data->{Name} eq 'Measure' ) {
		$self->{measure}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search measure in database
		$sql = "SELECT measure_id,sid,tid FROM measure 
				WHERE icecat_id = $self->{measure}->{icecat_id}";
		$query_res = &do_query($sql);

		#if measure does not exist in database
		if ( !defined $query_res->[0][0] ) {
			$self->insert_measure();
		}

		#get measure_id, sid and tid for current measure
		else {
			$self->{measure}->{measure_id} = $query_res->[0][0];
			$self->{measure}->{sid}        = $query_res->[0][1];
			$self->{measure}->{tid}        = $query_res->[0][2];
			$self->{is_measure_inserted}   = 0;
		}
		$self->{cnt_xml_measure}++;
	}

	#data for table "measure_sign" or field "sign" of table "measure"
	elsif ( $data->{Name} eq 'Sign' ) {

		#data for table "measure_sign"
		if ( defined $data->{Attributes}->{"{}ID"} ) {
			$self->{measure_sign}->{icecat_id} =
			  $data->{Attributes}->{"{}ID"}->{Value};
			$self->{measure_sign}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};
			$self->{measure_sign}->{value} = undef;
			$self->{cnt_xml_measure_sign}++;
			$self->{in_sign} = 2;
		}
		else {
			$self->{in_sign} = 1;
		}
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {
		$self->{is_in_name}++;
		$self->{measure_name}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{measure_name}->{langid_icecat} =
		  $data->{Attributes}->{"{}langid"}->{Value};
		$self->{measure_name}->{value} = undef;
		$self->{cnt_xml_name}++;
	}

	#data for table "tex"
	elsif ( $data->{Name} eq 'Description' ) {
		$self->{is_in_description}++;
		$self->{measure_description}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$self->{measure_description}->{langid_icecat} =
		  $data->{Attributes}->{"{}langid"}->{Value};
		$self->{measure_description}->{value} = undef;
		$self->{cnt_xml_description}++;
	}
}

#characters inside of element
sub characters {
	my ( $self, $data ) = @_;

	#field "sign" of table "measure"
	if ( $self->{in_sign} == 1 ) {
		$self->{measure}->{sign} = &str_sqlize( $data->{Data} );
	}

	#filed "value" for table "measure_sign"
	elsif ( $self->{in_sign} == 2 ) {
		$self->{measure_sign}->{value} = &str_sqlize( $data->{Data} );
	}

	#filed "value" in table "vocabulary"
	elsif ( $self->{is_in_name} == 1 ) {
		$self->{measure_name}->{value} = &str_sqlize( $data->{Data} );
	}

	#filed "value" in table "tex"
	elsif ( $self->{is_in_description} == 1 ) {
		$self->{measure_description}->{value} = &str_sqlize( $data->{Data} );
	}
}

#end element in xml file
sub end_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "measure_sign" or field "sign" of table "measure"
	if ( $data->{Name} eq 'Sign' ) {

		#data for table "measure_sign"
		if ( $self->{in_sign} == 2 ) {

			#search measure sing in database
			$sql = "SELECT measure_sign_id FROM measure_sign 
					WHERE icecat_id = $self->{measure_sign}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{measure_sign}->{measure_sign_id} = $query_res->[0][0];
			if (  !defined $self->{measure_sign}->{measure_sign_id}
				|| $self->{import_mode} == 1 )
			{

				#get language from hash
				$self->{measure_sign}->{langid} =
				  $self->{languages}
				  ->{ $self->{measure_sign}->{langid_icecat} };

				#language does not exist in hash
				if ( !defined $self->{measure_sign}->{langid} ) {

					#search language in database
					$sql = "SELECT langid FROM language 
							WHERE icecat_id = $self->{measure_sign}->{langid_icecat}";
					$query_res = &do_query($sql);
					$self->{measure_sign}->{langid} = $query_res->[0][0];
					if ( defined $self->{measure_sign}->{langid} ) {

						#put language to hash
						$self->{languages}
						  ->{ $self->{measure_sign}->{langid_icecat} } =
						  $self->{measure_sign}->{langid};
					}
				}

				# if language exists
				if ( defined $self->{measure_sign}->{langid} ) {
					if ( !defined $self->{measure_sign}->{value} ) {
						$self->{measure_sign}->{value} = &str_sqlize("");
					}
					if ( !defined $self->{measure_sign}->{measure_sign_id} ) {

						#insert new measure sign
						$self->insert_measure_sign();
					}
					elsif ( $self->{import_mode} == 1 ) {

						#update measure sign
						$self->update_measure_sign();
					}
				}
			}
		}

		#field "sign" of table "measure"
		elsif ( ( $self->{in_sign} == 1 )
			&& (   $self->{is_measure_inserted} == 1
				|| $self->{import_mode} == 1 ) )
		{
			$sql = "UPDATE measure SET 
					sign = $self->{measure}->{sign} 
					WHERE icecat_id = $self->{measure}->{icecat_id}";
			&do_statement($sql);
			if ( $self->{import_mode} == 1 ) {
				$self->{cnt_update_measure}++;
			}
		}
		$self->{in_sign} = 0;
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {

		#search measure name in database
		$sql = "SELECT record_id FROM vocabulary 
				WHERE icecat_id = $self->{measure_name}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{measure_name}->{record_id} = $query_res->[0][0];
		if ( !defined $self->{measure_name}->{record_id} || $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{measure_name}->{langid} =
			  $self->{languages}->{ $self->{measure_name}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{measure_name}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{measure_name}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{measure_name}->{langid} = $query_res->[0][0];
				if ( defined $self->{measure_name}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{measure_name}->{langid_icecat} } =
					  $self->{measure_name}->{langid};
				}
			}

			# insert or update measure name
			if ( defined $self->{measure_name}->{langid} ) {
				if ( !defined $self->{measure_name}->{value} ) {
					$self->{measure_name}->{value} = "NULL";
				}
				if ( !defined $self->{measure_name}->{record_id} ) {
					$self->insert_measure_name();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_measure_name();
				}
			}
		}
		$self->{is_in_name}--;
	}

	#data for table "tex"
	elsif ( $data->{Name} eq 'Description' ) {

		#search measure description in database
		$sql = "SELECT tex_id FROM tex 
				WHERE icecat_id = $self->{measure_description}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{measure_description}->{tex_id} = $query_res->[0][0];
		if (  !defined $self->{measure_description}->{tex_id}
			|| $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{measure_description}->{langid} =
			  $self->{languages}
			  ->{ $self->{measure_description}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{measure_description}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{measure_description}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{measure_description}->{langid} = $query_res->[0][0];
				if ( defined $self->{measure_description}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{measure_description}->{langid_icecat} } =
					  $self->{measure_description}->{langid};
				}
			}

			# insert or update measure description
			if ( defined $self->{measure_description}->{langid} ) {
				if ( !defined $self->{measure_description}->{value} ) {
					$self->{measure_description}->{value} = "NULL";
				}
				if ( !defined $self->{measure_description}->{tex_id} ) {
					$self->insert_measure_description();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_measure_description();
				}
			}
		}
		$self->{is_in_description}--;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistic to report
	PIMReport->append("\n=====MeasuresList.xml=====\n");
	PIMReport->append("Total measures in xml = $self->{cnt_xml_measure}\n");
	PIMReport->append(
		"Inserted measures to database = $self->{cnt_insert_measure}\n");
	PIMReport->append(
		"Updated measures in database = $self->{cnt_update_measure}\n");
	PIMReport->append(
		"Total measure signs in xml = $self->{cnt_xml_measure_sign}\n");
	PIMReport->append(
		"Inserted measure signs to database = $self->{cnt_insert_measure_sign}\n"
	);
	PIMReport->append(
		"Updated measure signs in database = $self->{cnt_update_measure_sign}\n"
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

	#add statistic to log
	&log_printf("Total measures in xml = $self->{cnt_xml_measure}");
	&log_printf("Inserted measures to database = $self->{cnt_insert_measure}");
	&log_printf("Updated measures in database = $self->{cnt_update_measure}");
	&log_printf( "Total measure signs in xml = $self->{cnt_xml_measure_sign}" );
	&log_printf(
		"Inserted measure signs to database = $self->{cnt_insert_measure_sign}"
	);
	&log_printf(
		"Updated measure signs in database = $self->{cnt_update_measure_sign}"
	);
	&log_printf("Total names in xml = $self->{cnt_xml_name}");
	&log_printf("Inserted names to database = $self->{cnt_insert_name}");
	&log_printf("Updated names in database = $self->{cnt_update_name}");
	&log_printf("Total descriptions in xml = $self->{cnt_xml_description}");
	&log_printf(
		"Inserted descriptions to database = $self->{cnt_insert_description}");
	&log_printf(
		"Updated descriptions in database = $self->{cnt_update_description}");
	&log_printf("=====MeasuresListHandler: end of parsing=====");
}

#insert measure
sub insert_measure {
	my ($self) = @_;

	#get sid for new measure
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{measure}->{sid} = $query_res->[0][0];

	#get tid for new measure
	$sql = "INSERT INTO tid_index VALUES()";
	&do_statement($sql);
	$sql                    = "SELECT LAST_INSERT_ID()";
	$query_res              = &do_query($sql);
	$self->{measure}->{tid} = $query_res->[0][0];

	#insert measure to database
	$sql = "INSERT INTO measure (sid,tid,icecat_id) 
			VALUES(
			$self->{measure}->{sid}, 
			$self->{measure}->{tid}, 
			$self->{measure}->{icecat_id});";
	&do_statement($sql);

	#get id of new measure
	$query_res                     = &do_query("SELECT LAST_INSERT_ID()");
	$self->{measure}->{measure_id} = $query_res->[0][0];
	$self->{is_measure_inserted}   = 1;
	$self->{cnt_insert_measure}++;
}

#insert measure description
sub insert_measure_description {
	my ($self) = @_;
	my $sql = "INSERT INTO tex 
			(tid,langid,value,icecat_id) 
			VALUES( 
			$self->{measure}->{tid},$self->{measure_description}->{langid}, 
			$self->{measure_description}->{value}, 
			$self->{measure_description}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_description}++;
}

#update measure description
sub update_measure_description {
	my ($self) = @_;
	my $sql = "UPDATE tex SET 
			tid=$self->{measure}->{tid},
			langid=$self->{measure_description}->{langid}, 
			value=$self->{measure_description}->{value} 
			WHERE icecat_id=$self->{measure_description}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_description}++;
}

#insert measure name
sub insert_measure_name {
	my ($self) = @_;
	my $sql = "INSERT INTO vocabulary 
			(sid,langid,value,icecat_id) 
			VALUES(
			$self->{measure}->{sid}, 
			$self->{measure_name}->{langid}, 
			$self->{measure_name}->{value}, 
			$self->{measure_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_name}++;
}

#update measure name
sub update_measure_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			sid = $self->{measure}->{sid},
			langid=$self->{measure_name}->{langid},
			value=$self->{measure_name}->{value} 
			WHERE icecat_id=$self->{measure_name}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_name}++;
}

#insert measure sign
sub insert_measure_sign {
	my ($self) = @_;
	my $sql = "INSERT INTO measure_sign 
			(measure_id, langid, value, icecat_id) 
			VALUES(
			$self->{measure}->{measure_id}, 
			$self->{measure_sign}->{langid}, 
			$self->{measure_sign}->{value}, 
			$self->{measure_sign}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_measure_sign}++;
}

#update measure sign
sub update_measure_sign {
	my ($self) = @_;
	my $sql = "UPDATE measure_sign SET 
			measure_id = $self->{measure}->{measure_id},
			langid=$self->{measure_sign}->{langid},
			value=$self->{measure_sign}->{value} 
			WHERE icecat_id = $self->{measure_sign}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_measure_sign}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

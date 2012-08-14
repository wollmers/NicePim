package CategoriesListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====CategoriesListHandler: start of parsing=====");
	$self->{category}               = {};
	$self->{category_name}          = {};
	$self->{category_description}   = {};
	$self->{languages}              = {};
	$self->{category_keywords}      = {};
	$self->{is_category_inserted}   = 0;
	$self->{cnt_insert_category}    = 0;
	$self->{cnt_update_category}    = 0;
	$self->{cnt_xml_name}           = 0;
	$self->{cnt_insert_name}        = 0;
	$self->{cnt_update_name}        = 0;
	$self->{cnt_insert_description} = 0;
	$self->{cnt_update_description} = 0;
	$self->{cnt_xml_description}    = 0;
	$self->{cnt_insert_keywords}    = 0;
	$self->{cnt_update_keywords}    = 0;
	$self->{cnt_xml_keywords}       = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "category"
	if ( $data->{Name} eq 'Category' ) {
		$self->{category}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search category in database
		$sql = "SELECT catid,sid,tid FROM category 
				WHERE icecat_id = $self->{category}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category}->{catid} = $query_res->[0][0];
		if ( defined $self->{category}->{catid} ) {
			$self->{category}->{sid}      = $query_res->[0][1];
			$self->{category}->{tid}      = $query_res->[0][2];
			$self->{is_category_inserted} = 0;
		}

		#if category does not exist or update mode is turned on
		if ( !defined $self->{category}->{catid} || $self->{import_mode} == 1 )
		{
			$self->{category}->{low_pic} =
			  &str_sqlize( $data->{Attributes}->{"{}LowPic"}->{Value} );
			$self->{category}->{score} =
			  $data->{Attributes}->{"{}Score"}->{Value};
			$self->{category}->{searchable} =
			  $data->{Attributes}->{"{}Searchable"}->{Value};
			$self->{category}->{thumb_pic} =
			  &str_sqlize( $data->{Attributes}->{"{}ThumbPic"}->{Value} );
			$self->{category}->{ucatid} =
			  $data->{Attributes}->{"{}UNCATID"}->{Value};
			$self->{category}->{visible} =
			  &str_sqlize( $data->{Attributes}->{"{}Visible"}->{Value} );
			if ( !defined $self->{category}->{catid} ) {
				$self->insert_category();
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_category();
			}
		}
		$cnt_xml_category++;
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {

		#check name inside <ParentCategory>
		if ( defined $data->{Attributes}->{"{}Value"}->{Value} ) {
			$self->{category_name}->{icecat_id} =
			  $data->{Attributes}->{"{}ID"}->{Value};

			#search category name in database
			$sql = "SELECT record_id FROM vocabulary 
					WHERE icecat_id=$self->{category_name}->{icecat_id}";
			$query_res = &do_query($sql);
			$self->{category_name}->{record_id} = $query_res->[0][0];

			#if category name does not exist or update mode is turned on
			if ( !defined $self->{category_name}->{record_id}
				|| $self->{import_mode} == 1 )
			{

				#get language from hash
				$self->{category_name}->{langid_icecat} =
				  $data->{Attributes}->{"{}langid"}->{Value};
				$self->{category_name}->{langid} =
				  $self->{languages}
				  ->{ $self->{category_name}->{langid_icecat} };

				#language does not exist in hash
				if ( !defined $self->{category_name}->{langid} ) {

					#search language in database
					$sql = "SELECT langid FROM language 
							WHERE icecat_id = $self->{category_name}->{langid_icecat}";
					$query_res = &do_query($sql);
					$self->{category_name}->{langid} = $query_res->[0][0];
					if ( defined $self->{category_name}->{langid} ) {

						#put language to hash
						$self->{languages}
						  ->{ $self->{category_name}->{langid_icecat} } =
						  $self->{category_name}->{langid};
					}
				}

				#insert or update category name
				if ( defined $self->{category_name}->{langid} ) {
					$self->{category_name}->{value} =
					  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
					if ( !defined $self->{category_name}->{record_id} ) {
						$self->insert_category_name();
					}
					elsif ( $self->{import_mode} == 1 ) {
						$self->update_category_name();
					}
				}
			}
			$self->{cnt_xml_name}++;
		}
	}

	#data for table "tex"
	elsif ( $data->{Name} eq 'Description' ) {
		$self->{category_description}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		#search category description in database
		$sql = "SELECT tex_id FROM tex 
				WHERE icecat_id=$self->{category_description}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category_description}->{tex_id} = $query_res->[0][0];

		#if category description does not exist or update mode is turned on
		if ( !defined $self->{category_description}->{tex_id}
			|| $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{category_description}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};
			$self->{category_description}->{langid} =
			  $self->{languages}
			  ->{ $self->{category_description}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{category_description}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{category_description}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{category_description}->{langid} = $query_res->[0][0];
				if ( defined $self->{category_description}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{category_description}->{langid_icecat} } =
					  $self->{category_description}->{langid};
				}
			}

			#insert or update category description
			if ( defined $self->{category_description}->{langid} ) {
				$self->{category_description}->{value} =
				  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
				if ( !defined $self->{category_description}->{tex_id} ) {
					$self->insert_category_description();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_category_description();
				}
			}
		}
		$self->{cnt_xml_description}++;
	}

	#data for table "category_keywords"
	elsif ( $data->{Name} eq 'Keywords' ) {
		$self->{category_keywords}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		#search category keyword in database
		$sql = "SELECT id FROM category_keywords 
				WHERE icecat_id=$self->{category_keywords}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{category_keywords}->{id} = $query_res->[0][0];

		#if category keyword does not exist or update mode is turned on
		if ( !defined $self->{category_keywords}->{id}
			|| $self->{import_mode} == 1 )
		{

			#get language from hash
			$self->{category_keywords}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};
			$self->{category_keywords}->{langid} =
			  $self->{languages}
			  ->{ $self->{category_keywords}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{category_keywords}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{category_keywords}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{category_keywords}->{langid} = $query_res->[0][0];
				if ( defined $self->{category_keywords}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{category_keywords}->{langid_icecat} } =
					  $self->{category_keywords}->{langid};
				}
			}

			#insert or update category keyword
			if ( defined $self->{category_keywords}->{langid} ) {
				$self->{category_keywords}->{keywords} =
				  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
				if ( !defined $self->{category_keywords}->{id} ) {
					$self->insert_category_keywords();
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_category_keywords();
				}
			}
		}
		$self->{cnt_xml_keywords}++;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append("\n=====CategoriesList.xml=====\n");
	PIMReport->append("Total category in xml = $cnt_xml_category\n");
	PIMReport->append(
		"Inserted categories to database = $self->{cnt_insert_category}\n");
	PIMReport->append(
		"Updated categories in database = $self->{cnt_update_category}\n");
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
	PIMReport->append("Total keywords in xml = $self->{cnt_xml_keywords}\n");
	PIMReport->append(
		"Inserted keywords to database = $self->{cnt_insert_keywords}\n");
	PIMReport->append(
		"Updated keywords in database = $self->{cnt_update_keywords}\n");

	#add statistics to log
	&log_printf("Total category in xml = $cnt_xml_category");
	&log_printf(
		"Inserted categories to database = $self->{cnt_insert_category}");
	&log_printf(
		"Updated categories in database = $self->{cnt_update_category}");
	&log_printf("Total names in xml = $self->{cnt_xml_name}");
	&log_printf("Inserted names to database = $self->{cnt_insert_name}");
	&log_printf("Updated names in database = $self->{cnt_update_name}");
	&log_printf("Total descriptions in xml = $self->{cnt_xml_description}");
	&log_printf(
		"Inserted descriptions to database = $self->{cnt_insert_description}");
	&log_printf(
		"Updated descriptions in database = $self->{cnt_update_description}");
	&log_printf("Total keywords in xml = $self->{cnt_xml_keywords}");
	&log_printf("Inserted keywords to database = $self->{cnt_insert_keywords}");
	&log_printf("Updated keywords in database = $self->{cnt_update_keywords}");
	&log_printf("=====CategoriesListHandler: end of parsing=====");
}

#insert category
sub insert_category {
	my ($self) = @_;

	#get "sid" for new category
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	$sql = "SELECT LAST_INSERT_ID()";
	my $query_res = &do_query($sql);
	$self->{category}->{sid} = $query_res->[0][0];

	#get "tid" for new category
	$sql = "INSERT INTO tid_index VALUES()";
	&do_statement($sql);
	$sql                     = "SELECT LAST_INSERT_ID()";
	$query_res               = &do_query($sql);
	$self->{category}->{tid} = $query_res->[0][0];

	#insert new category
	$sql = "INSERT INTO category 
			(ucatid, sid, tid, searchable, 
			low_pic, thumb_pic, visible, icecat_id ) 
			VALUES( 
			$self->{category}->{ucatid}, 
			$self->{category}->{sid}, 
			$self->{category}->{tid}, 
			$self->{category}->{searchable}, 
			$self->{category}->{low_pic}, 
			$self->{category}->{thumb_pic}, 
			$self->{category}->{visible}, 
			$self->{category}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_category}++;
	$self->{is_category_inserted} = 1;

	#get catid of new category
	$sql                       = "SELECT LAST_INSERT_ID()";
	$query_res                 = &do_query($sql);
	$self->{category}->{catid} = $query_res->[0][0];

	#insert into category statistic
	$sql = "INSERT INTO category_statistic 
			(catid, score,icecat_id) 
			VALUES(
			$self->{category}->{catid},
			$self->{category}->{score},
			$self->{category}->{icecat_id})";
	&do_statement($sql);
}

#update category
sub update_category {
	my ($self) = @_;
	my $sql = "UPDATE category SET 
			ucatid=$self->{category}->{ucatid}, 
			searchable=$self->{category}->{searchable}, 
			thumb_pic=$self->{category}->{thumb_pic}, 
			visible=$self->{category}->{visible} 
			WHERE catid=$self->{category}->{catid} ";
	&do_statement($sql);
	$self->{cnt_update_category}++;

	#check category statistic
	$sql = "SELECT catid FROM category_statistic 
			WHERE icecat_id = $self->{category}->{icecat_id}";
	my $query_res = &do_query($sql);

	#insert new category statistic
	if ( !defined $query_res->[0][0] ) {
		$sql = "INSERT INTO category_statistic 
				(catid, score,icecat_id) 
				VALUES(
				$self->{category}->{catid},
				$self->{category}->{score},
				$self->{category}->{icecat_id})";
	}

	#udpate category statistic
	else {
		$sql = "UPDATE category_statistic SET
				score=$self->{category}->{score},
				catid=$self->{category}->{catid} 
				WHERE icecat_id=$self->{category}->{icecat_id}";
	}
	&do_statement($sql);
}

#insert category name
sub insert_category_name {
	my ($self) = @_;
	my $sql = "INSERT INTO vocabulary 
			(sid, langid, value,icecat_id) 
			VALUES( 
			$self->{category}->{sid},
			$self->{category_name}->{langid}, 
			$self->{category_name}->{value},
			$self->{category_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_name}++;
}

#update category name
sub update_category_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			sid = $self->{category}->{sid}, 
			langid=$self->{category_name}->{langid},
			value = $self->{category_name}->{value} 
			WHERE icecat_id = $self->{category_name}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_name}++;
}

#insert category description
sub insert_category_description {
	my ($self) = @_;
	my $sql = "INSERT INTO tex 
			(tid, langid, value,icecat_id) 
			VALUES( 
			$self->{category}->{tid},
			$self->{category_description}->{langid}, 
			$self->{category_description}->{value},
			$self->{category_description}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_description}++;
}

#update category name
sub update_category_description {
	my ($self) = @_;
	my $sql = "UPDATE tex SET 
			tid = $self->{category}->{tid}, 
			langid=$self->{category_description}->{langid},
			value = $self->{category_description}->{value} 
			WHERE icecat_id = $self->{category_description}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_description}++;
}

#insert category keywords
sub insert_category_keywords {
	my ($self) = @_;
	my $sql = "INSERT INTO category_keywords 
			(category_id, langid, keywords,icecat_id)  
			VALUES( 
			$self->{category}->{catid},
			$self->{category_keywords}->{langid}, 
			$self->{category_keywords}->{keywords},
			$self->{category_keywords}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_keywords}++;
}

#update category keywords
sub update_category_keywords {
	my ($self) = @_;
	my $sql = "UPDATE category_keywords SET 
			category_id = $self->{category}->{catid}, 
			langid=$self->{category_keywords}->{langid},
			keywords = $self->{category_keywords}->{keywords} 
			WHERE icecat_id = $self->{category_keywords}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_keywords}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

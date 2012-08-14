package LanguageNameListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====LanguageNameListHandler: start of parsing=====");
	$self->{language_name}            = {};
	$self->{language}                 = {};
	$self->{languages}                = {};
	$self->{cnt_insert_language_name} = 0;
	$self->{cnt_xml_language_name}    = 0;
	$self->{cnt_update_language_name} = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "language"
	if ( $data->{Name} eq 'Language' ) {
		$self->{language}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search language in database
		$sql = "SELECT sid FROM language 
				WHERE icecat_id = $self->{language}->{icecat_id}";
		$query_res = &do_query($sql);

		#get sid for current language
		$self->{language}->{sid} = $query_res->[0][0];
	}

	#data for table "vocabulary"
	elsif ( $data->{Name} eq 'Name' ) {
		$self->{language_name}->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};

		{

			#get language from hash
			$self->{language_name}->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};
			$self->{language_name}->{langid} =
			  $self->{languages}->{ $self->{language_name}->{langid_icecat} };

			#language does not exist in hash
			if ( !defined $self->{language_name}->{langid} ) {

				#search language in database
				$sql = "SELECT langid FROM language 
						WHERE icecat_id = $self->{language_name}->{langid_icecat}";
				$query_res = &do_query($sql);
				$self->{language_name}->{langid} = $query_res->[0][0];
				if ( defined $self->{language_name}->{langid} ) {

					#put language to hash
					$self->{languages}
					  ->{ $self->{language_name}->{langid_icecat} } =
					  $self->{language_name}->{langid};
				}
			}

			# if language exists
			if ( defined $self->{language_name}->{langid} ) {

				#search languge name in database
				$sql = "SELECT record_id FROM vocabulary 
						WHERE langid = $self->{language_name}->{langid} 
						AND sid = $self->{language}->{sid}";
				$query_res = &do_query($sql);
				$self->{language_name}->{record_id} = $query_res->[0][0];

				if ( !defined $self->{language_name}->{record_id}
					|| $self->{import_mode} == 1 )
				{

					#get another fileds for language name
					$self->{language_name}->{value} =
					  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );

					#insert new language name
					if ( !defined $self->{language_name}->{record_id} ) {
						$self->insert_language_name();
					}

					#update language name
					elsif ( $self->{import_mode} == 1 ) {
						$self->update_language_name();
					}
				}
			}

			$self->{cnt_xml_language_name}++;
		}
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append(
		"Total language names in xml = $self->{cnt_xml_language_name}\n");
	PIMReport->append(
		"Inserted language names to database = $self->{cnt_insert_language_name}\n"
	);
	PIMReport->append(
		"Updated language names in database = $self->{cnt_update_language_name}\n"
	);

	#add statistics to log
	&log_printf("Total names in xml = $self->{cnt_xml_language_name}");
	&log_printf(
		"Inserted names to database = $self->{cnt_insert_language_name}");
	&log_printf(
		"Updated names in database = $self->{cnt_update_language_name}");
	&log_printf("=====LanguageNameListHandler: end of parsing=====");
}

#insert language name
sub insert_language_name {
	my ($self) = @_;
	my $sql = "INSERT INTO vocabulary 
			(sid,langid,value,icecat_id) 
			VALUES (
			$self->{language}->{sid}, 
			$self->{language_name}->{langid}, 
			$self->{language_name}->{value}, 
			$self->{language_name}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_language_name}++;
}

#update language name
sub update_language_name {
	my ($self) = @_;
	my $sql = "UPDATE vocabulary SET 
			icecat_id = $self->{language_name}->{icecat_id}, 
			value = $self->{language_name}->{value} 
			WHERE record_id = $self->{language_name}->{record_id}";
	&do_statement($sql);
	$self->{cnt_update_language_name}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

package LanguageListHandler;
use base qw(XML::SAX::Base);
use atomsql;
use atomlog;
use PIMReport;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;
	&log_printf("=====LanguageListHandler: start of parsing=====");
	$self->{language}            = {};
	$self->{cnt_insert_language} = 0;
	$self->{cnt_update_language} = 0;
	$self->{cnt_xml_language}    = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table "language"
	if ( $data->{Name} eq 'Language' ) {
		$self->{language}->{icecat_id} = $data->{Attributes}->{"{}ID"}->{Value};

		#search language in database
		$sql = "SELECT langid FROM language 
				WHERE icecat_id = $self->{language}->{icecat_id}";
		$query_res = &do_query($sql);
		$self->{language}->{langid} = $query_res->[0][0];



		#if language does not exist or update mode is turned on
		if ( !defined $self->{language}->{langid} || $self->{import_mode} == 1 ) {

			#get fields for new language from xml
			$self->{language}->{code} =
			  &str_sqlize( $data->{Attributes}->{"{}Code"}->{Value} );
			$self->{language}->{short_code} =
			  &str_sqlize( $data->{Attributes}->{"{}ShortCode"}->{Value} );

			#insert language
			if ( !defined $self->{language}->{langid} ) {
				$self->insert_language();
			}

			#update language
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_language();
			}

		}
		$self->{cnt_xml_language}++;
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;

	#add statistics to report
	PIMReport->append("\n=====LanguageList.xml=====\n");
	PIMReport->append("Total languages in xml = $self->{cnt_xml_language}\n");
	PIMReport->append(
		"Inserted languages to database = $self->{cnt_insert_language}\n");
	PIMReport->append(
		"Updated languages in database = $self->{cnt_update_language}\n");

	#add statistics to log
	&log_printf("Total languages in xml = $self->{cnt_xml_language}");
	&log_printf(
		"Inserted languages to database = $self->{cnt_insert_language}"
	);
	&log_printf("Updated languages in database = $self->{cnt_update_language}");
	&log_printf("=====LanguageListHandler: end of parsing=====");
}

#insert language to database
sub insert_language {
	my ($self) = @_;

	#get sid for new language
	my $sql = "INSERT INTO sid_index VALUES()";
	&do_statement($sql);
	my $query_res = &do_query("SELECT LAST_INSERT_ID()");
	$self->{language}->{sid} = $query_res->[0][0];

	#insert language
	$sql = "INSERT INTO language 
			(langid,code,short_code,sid,icecat_id) 
			VALUES(
			$self->{language}->{icecat_id},
			$self->{language}->{code}, 
			$self->{language}->{short_code}, 
			$self->{language}->{sid}, 
			$self->{language}->{icecat_id})";
	&do_statement($sql);
	$self->{cnt_insert_language}++;
}

#update language in database
sub update_language {
	my ($self) = @_;
	my $sql = "UPDATE language SET 
			code=$self->{language}->{code}, 
			short_code=$self->{language}->{short_code} 
			WHERE icecat_id=$self->{language}->{icecat_id}";
	&do_statement($sql);
	$self->{cnt_update_language}++;
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

1;

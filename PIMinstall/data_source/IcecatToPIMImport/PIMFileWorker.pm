package PIMFileWorker;
use atomlog;
use LWP::UserAgent;

sub new {
	my $class = shift;
	my $self  = {};
	bless( $self, $class );
	return $self;
}

# Download file via http using LWP::UserAgent
# 	Parameters:
#	url - url for download without file name (for example "http://data.icecat.biz/export/freexml/refs/")
#	filename - name of file (for example "SuppliersList.xml.gz")
#	download_path - destination directory for download (for example "/tmp")
#	username - name of user (for example "openICEcat-xml") or undefined value
#	password - password (for exapmle "freeaccess") or undefined value
#
sub download_file {
	my ( $self, $url, $filename, $download_path, $username, $password ) = @_;
	die "instance method called on class" unless ref $self;
	$download_path .= $filename;
	$url           .= $filename;

	#complete URL
	if ( defined $username && defined $password ) {
		$url =~ s/http:\/\//http:\/\/$username:$password\@/;
	}

	#remove destination file if exists
	if ( -e $download_path ) {
		unlink($download_path);
	}

	#initialization of user agent
	my $ua = new LWP::UserAgent;
	$ua->agent('Mozilla/5.0');

	#get file size from server
	my $ua_head        = $ua->head($url);
	my $remote_headers = $ua_head->headers;
	$total_size = $remote_headers->content_length;

	#create request for download
	my $request = new HTTP::Request( GET => $url );

	#try download in cycle
	my $result = 1;
	my $cnt_try = 5;
	for ( my $i = 0 ; $i < $cnt_try ; $i++ ) {
		if ($i > 0){
			sleep(1);
			&log_printf("Repeat download file $url");
		}
		$response = $ua->request( $request, $download_path );
		
		#download was successfull
		if ( $response->is_success() ) {

			#check file after download
			if ( -e $download_path && ( ( -s $download_path ) == $total_size ) )
			{
				$result = 0;
				last;
			}
			else {
				if ($i == $cnt_try - 1 ){
					unless (-e $download_path){
						&log_printf(
						"ERROR! download_file: destination file was not saved!"
						);					
					}
					unless (( -s $download_path ) == $total_size){
						&log_printf(
						"ERROR! download_file: different size of source and destination files!"
						);	
					}
				}
			}
		}
		
		#error during download
		else {
			if ( !($response->status_line() =~ /500/) || $i == $cnt_try - 1 ) {
				log_printf( "ERROR! download_file: can not download file $url: "
					  . $response->status_line() );
				last;
			}
		}
	}
	return $result;
}

# Extract file from gzip archive
# 	Parameters:
#	path - full path of archive
sub unpack_file {
	my ( $self, $path ) = @_;
	die "instance method called on class" unless ref $self;
	$path =~ s/.gz$//;

	#remove destination file if exists
	if ( -e $path ) {
		unlink($path);
	}

	#extract file from gzip archive
	`gunzip $path`;

	#check file
	if ( -e $path && ( ( -s $path ) > 0 ) ) {

		#&log_printf("unpack_file: successfull extraction $path");
		return 0;
	}
	else {
		&log_printf("ERROR! unpack_file: can not extract file $path");
		return 1;
	}
}

# Download file via http using wget
# 	Parameters:
#	url - url for download without file name (for example "http://data.icecat.biz/export/freexml/refs/")
#	filename - name of file (for example "SuppliersList.xml.gz")
#	download_path - destination directory for download (for example "/tmp")
#	username - name of user (for example "openICEcat-xml") or undefined value
#	password - password (for exapmle "freeaccess") or undefined value
#
sub download_file_wget {
	my ( $self, $url, $filename, $download_path, $username, $password ) = @_;
	die "instance method called on class" unless ref $self;
	$download_path .= $filename;
	$url           .= $filename;

	#complete URL
	if ( $username && $password ) {
		$url =~ s/http:\/\//http:\/\/$username:$password\@/;
	}

	#&log_printf("download_file: Start download $url");

	#remove destination file if exists
	if ( -e $download_path ) {
		unlink($download_path);
	}

	#download file
	`wget $url -q -O $download_path`;

	#check file
	if ( -e $download_path && ( ( -s $download_path ) > 0 ) ) {

		#&log_printf("download_file: Successfull download $url");
		return 0;
	}
	else {
		&log_printf("ERROR! download_file: can not download file $url");
		return 1;
	}
}

1;

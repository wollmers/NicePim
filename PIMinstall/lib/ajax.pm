package ajax;

use strict;

use atomcfg;
use atomsql;
use atomlog;
use atom;
use atom_html;
use atom_misc;
use icecat_util;

use XML::Simple;
use Data::Dumper;
use Time::HiRes qw(gettimeofday);

##################################################################################################

BEGIN {
	use Exporter();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	use vars qw(
	    $spam
	    $ajax_request
	);
	$VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
	@EXPORT = qw(
	    &ajax
	    $spam
	    $ajax_request
	);
}

sub ajax {

	my $functions_hash = {
		'get_local_feature' => 1,
		'get_supplier_edit' => 1,
		'get_supplier_family_edit' => 1,
		'get_category_edit' => 1,
		'get_feature_edit' => 1,
		'get_supplier_related_edit' => 1,
		'get_allowed_feature_value_report' => 1,
		'get_current_mapping_processes' => 1,
		'get_current_generate_report_processes' => 1,
		'get_amount' => 1,
		'get_product_related' => 1,
		'get_products_by_feature_value' => 1,
		'get_categories_list_by_like_name' => 1,
		'get_vcategories' => 1,
		'park_track_product' => 1,
		'get_track_list_editors' => 1,
		'get_track_products' => 1,
		'get_product_families' => 1,
		'get_product_series' => 1,
		'get_warranty_info' => 1,
		'sync_all_distri' => 1,
		'set_map_pair'=>1,
		'set_map_pair_check'=>1,
		'get_map_pair_err'=>1,
		'map_track_product'=>1,
		'set_track_poduct_rule'=>1,
		'delete_track_poduct_rule'=>1,
		'default'=>1,
		'get_google_translations'=>1
	};

	# Make some logging here
	log_printf("Started AJAX logging");

	# Parsing the input of the client
	html_start;
	
	log_printf("request = ".Dumper($hin{'request'}));
	lp('Connection ID: '.do_query('select connection_id()')->[0][0]);
	# log_printf("request_body = ".Dumper($hin{REQUEST_BODY}));

	$ajax_request = $hin{'REQUEST_BODY'};

	my $response;
	$response = [];

	if ((!$ajax_request) || (!$hin{'request'})) {
		return error("No request, so no response :)");
	}

	$ajax_request = XMLin($hin{'request'});

	my $key = '';
	my $value = '';
	my $params = undef;
	my $parameter = undef;
	$params = $ajax_request->{Request}->{Parameter};

#	my $tmp = Dumper($params);
#	$tmp =~ s/[\n\t\r]/ /gs;

#	log_printf("ajax_request = ".$tmp);

	# fullfill %hin with key -> value from request
	for $parameter (@$params) {
#		my ($key,$value) = split(/=/,$parameter->{content});
#		log_printf("param = ".Dumper($parameter));
		$parameter->{content} =~ /^(.*?)\=(.*)$/s;
		($key,$value) = ($1,$2);
		next unless $key;
		$key =~ s/^http\:\/\/.*?\/index\.cgi\?(.*)$/$1/s;
		$hin{$key} = $value;
		log_printf("key|value = '".$key."' | '".$value."'");
	}

	$ajax_request = $ajax_request->{Request};

	#  0. Prevent non authorized usage
	#  1. Delete all requests that were done more that minute ago
	#  2. Check whether current IP has too many requests during last minute
	#  3. Insert the request into the database

	if ($ajax_request->{Function}) {

		do_statement('DELETE FROM ajax_usage WHERE updated < from_unixtime(unix_timestamp() - 60)');
		# Lets check that we have not too much requests
		my $max_requests_per_minute = 600;
		my $counted = do_query("SELECT count(*) FROM ajax_usage WHERE ip = ".str_sqlize($ENV{REMOTE_ADDR})." AND func = ". str_sqlize($ajax_request->{Function}))->[0][0];

		if ($counted > $max_requests_per_minute) {
			# Aha, we caught you :)
			$spam = 1;
		}

		insert_rows('ajax_usage', {
			'ip'      => str_sqlize($ENV{REMOTE_ADDR}), 
			'func'    => str_sqlize($ajax_request->{Function}),
			'updated' => 'now()'
								 });
	}

	# Choosing apropriate function here

	my $output;
	$output = 'No response';

#	log_printf($ajax_request->{Function});

	if ($functions_hash->{$ajax_request->{Function}}) {
	    # log_printf(Dumper(\%hin));
		$output = atom_main_ajaxed();
	}

	$hin{'additional'} = $hin{'tag_id'};

	return output_txt(pack_response($output));
}

##################################################################################################

sub pack_response {
	my $output = shift;

	my ($result, $parameters);

	push @$parameters, $ajax_request->{ID};       # 1. request id
	push @$parameters, $ajax_request->{Function}; # 2. function name
	push @$parameters, $hin{'additional'};        # 3. additional parameter (only for several requests)
	push @$parameters, $output;                   # 4. formed, separated output
	push @$result, { 'parameters' => $parameters };

	return $result;
}

##################################################################################################

sub output {
	my $hash      = shift;
	my $response  = xml_utf8_tag;
	$response .= "<AjaxResponse>\n";
	my $i = 0;
	
	for my $function(@$hash){
		my $j = 0;$i++;
		$response .= "<Response ID=\"$i\">\n";
		for my $parameter(@{$function->{parameters}}){
			$j++;
			$response .= "<Parameter ID=\"$j\">" . $parameter . "</Parameter>\n";
		}
		$response .= "</Response>\n";
	}
	$response .= "</AjaxResponse>\n";
#  	log_printf('>>>>>>>>>>>>>>> res = '.$response);
	return $response;
#	exit;
}

##################################################################################################

sub output_txt {
	my $arr = shift;

	my $response;
	$response = '';
	my $function;
	$function = undef;
	my $parameter;
	$parameter = undef;
	my $delim;
	$delim = 0;

	for $function (@$arr) {
		$delim = 0;
		for $parameter (@{$function->{parameters}}) {
			if ($delim) {
				$response .= "<ICEcat-AJAX-delimiter>";
			}
			else {
				$delim = 1;
			}
			$response .= $parameter;
		}
	}

	# old print for CGI (not mod_perl) case
	# print $response;
	
	return gzip_data($response);
}

##################################################################################################

sub error {
	my $error = shift;
	my $text  = '';
	log_printf("Error: " . $error);
	$text .= xml_utf8_tag;
	$text .= "<AjaxResponse>\n";
	$text .= "<Error>" . $error . "</Error>\n";
	$text .= "</AjaxResponse>\n";

	return $text;
}

##################################################################################################

1;

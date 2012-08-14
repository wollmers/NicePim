package atom_engine;

use strict;

use atomcfg;
use atomlog;
use atomsql;
use atom_util;
use atom_html;
use atom_misc;
use atom_params;
use atom_format;
use atom_store;
use atom_validate;
use atom_cust;
use atom_commands;

use Data::Dumper;

#
# atoms: 
# $iatoms->{'atom_name'} - inner atom data ialib
# $atoms->{'atom_name'} - atom data, taken form alib
# $atoms->{'class_name'}->{'atom_name'}->{'fieldname'} = $fieldvalue - from atom defs. 
# $atoms->{'class_name'}->{'atom_name'}->{'proc'} - atom procedure. By default - process_atom_default
# $atoms->{'class_name'}->{'atom_name'}->{'call_params'} - a hash for atom params. 
#    Produced by &{$iatoms->{'atom_name'}->{'create_params'}}
#
use Digest::MD5 qw(md5_hex);

use vars qw ($glob_unauthorized);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw( 
    &init_atom_engine
	&done_atom_engine
	&launch_atom_engine
  );
  $glob_unauthorized	= 0;
}


sub init_atom_engine {

#log_printf("HIN = ".Dumper(%hin));

	$atoms = undef;
	$iatoms = undef;

	# set initial params

 	# set current year
	open YEAR, 'date +%Y |';
	binmode YEAR, ":utf8";
	$hin{'icecat_current_year'} = join '', <YEAR>;
	close YEAR;
	chop($hin{'icecat_current_year'});

	# set company name
	$hin{'icecat_company_name'} = $atomcfg{'company_name'};

	# set default hostname
	$hin{'icecat_hostname'} = $atomcfg{'host'};
	# set default raw hostname
	$hin{'icecat_hostname_raw'} = $atomcfg{'host_raw'};

	# set default bo hostname
	$hin{'icecat_bo_hostname'} = $atomcfg{'bo_host'};
	# set default bo raw hostname
	$hin{'icecat_bo_hostname_raw'} = $atomcfg{'bo_host_raw'};

	load_atomer_params();

 # refreshing permanent params list
 if($hl{'permanent_list'}){
  my @list = split(/,/, $hl{'permanent_list'});
	$hl{'permanent_list'} = {};
	foreach my $item(@list){
	 $hl{'permanent_list'}->{$item} = 1; 
	}
 } else {
  $hl{'permanent_list'} = { 'mi' => 1 };
 }

 # refreshing hl permanent params list
 if($hl{'hl_permanent_list'}){
  my @list = split(/,/, $hl{'hl_permanent_list'});
	$hl{'hl_permanent_list'} = {};
	foreach my $item(@list){
	 $hl{'hl_permanent_list'}->{$item} = 1; 
	}
 } else {
  $hl{'hl_permanent_list'} = {};
 }
 push_dmesg(3, "LOADING USER DATA");
 $USER = get_rows('users',"user_id = $hl{'user_id'}")->[0];
 push_dmesg(3, "LOADING USER DATA DONE USER_ID : $USER->{'user_id'}");
 if(!verify_address($USER->{'access_restriction'}, $USER->{'access_restriction_ip'}, $ENV{'REMOTE_ADDR'})){
   log_printf(" IP VALIDATION FAILED for user_id $USER->{'user_id'} and ip $ENV{'REMOTE_ADDR'}");
	 $hl{'ip_validation_failed'} = 1;
   undef $USER;
   html_start();
   $hout{'error'} = "Access denied, please check your access permissions and the IP address you use (http://www.whatismyip.com/). And contact your account manager to fix the issue if persistent.";
   $jump_to_location = $atomcfg{bo_host}."index.cgi?sessid=$sessid";
	 html_finish;
	 exit;
 }
}

sub launch_atom_engine {

	my $replaces = {};

	my $command_executed = 0;
	my $result;

	unless ($hin{'tmpl'}) {
		# no template to process given
		$hin{'tmpl'} = "index.html";
	}

	if ($hin{'precommand'}) {
#		 log_printf("executing");	   
		$result = execute_command("pre");
		$command_executed = 1;
	}
	
	if($hin{'atom_name'}!~/,/){
		($result,$command_executed) = atom_submit($hin{'atom_name'},$hin{'atom_class'});			
	}else{
		my @submit_atoms=split(',',$hin{'atom_name'});
		my @submit_clases=split(',',$hin{'atom_class'});
		my $curr_result=1;
		my $curr_command_executed=1;
		$result=1;
		$command_executed=1;
		for(my $i=0;$i<scalar(@submit_atoms);$i++){			
			($curr_result,$curr_command_executed)=atom_submit($submit_atoms[$i],$submit_clases[$i]);
			$result=0 if !($curr_result+0);
			$command_executed=0 if !($curr_command_executed+0);			
		};
	}
		
#	 log_printf($result);
#	 log_printf("\nafter submit id = $hin{'product_description_id'}");
	if ($result && $hin{'command'}) {
#		 log_printf("executing");
		$result = execute_command("");
		$command_executed = 1;
	}

	my $tmpl = $hin{'tmpl'};	 
	if ($result && $hin{'tmpl_if_success_cmd'} && !$hin{'reload'} && $command_executed) {
		$tmpl 				= $hin{'tmpl_if_success_cmd'};
		$hin{'tmpl'}	= $hin{'tmpl_if_success_cmd'};
	}
	$tmpl =~ s/\.\.\///gs;
	$tmpl =~ s/[\<\>\|\\]//gs;
	
	$tmpl =~ s/\///gs;

	my $tmp = load_template($tmpl,$hl{'langid'});
	$tmp =~ s/\n/\x1/gms;
	my $atom_calls = get_atom_calls($tmp);
	my $ikey;

	foreach my $call (@$atom_calls) {
		#log_printf('---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'.$call->{'name'});
		my $result = process_atom($atoms->{$call->{'class'}}->{$call->{'name'}},$call);
	  $tmp =~ s/\{$call->{'origin'}\}/$result/s;
	}
	
	my $errors_text = get_errors_text();
	unless ($tmp =~ s/<body([^>]*)>/<body$1>$errors_text/s) {
	  $tmp .= $errors_text;
	}
	
	$tmp =~ s/\x1/\n/gs;
	$tmp =~ s/\;{2,}/\;/gs;
	$tmp =~ s/\\([\{\}\;])/$1/gs;
	
	fill_repl_hash($replaces);
	$tmp = repl_ph($tmp, $replaces);
	
	my $iterations = 10_000;

	while ($tmp =~ /(%%[^\n\r]+?%%)/s) {
	  my $name = $1;
	  $tmp =~ s/$1//gs;
	  push_dmesg(3,"Unparsed $name is removed");

		$iterations--;
		last if $iterations < 0;
	}

	# restoring percents
	$tmp =~ s/\\%/%/gs;

	print_html($tmp);
}

sub done_atom_engine {
	pass_params();
}

sub fill_repl_hash {
	my ($replaces) = @_;

	%$replaces = %hin;

	# McAfee report bug fixed (11.03.2010)
	foreach (keys %$replaces) {
		$replaces->{$_} = str_htmlize($replaces->{$_}) unless ($hin{$_.'_ignore_unifiedly_processing'});
	}
	
	$replaces->{'base_url'} 				= get_base_URL."?sessid=".encode_sessid($sessid);

	$replaces->{'secure_action_url'} 	= $atomcfg{'secure_action_url'};
	$replaces->{'action_url'} 					= $atomcfg{'action_url'};
	
	$replaces->{'langid'}			= $hl{'langid'};
	$replaces->{'sessid'}			= encode_sessid($sessid);
	
	return $replaces;
}

sub pass_params {
my $cookie;

foreach $cookie('pattern'){
  $hout{$cookie} = $hin{$cookie} if (defined $hin{$cookie});
 } 


foreach $cookie(keys %{$hl{'permanent_list'}}){
  $hout{$cookie} = $hin{$cookie} if (defined $hin{$cookie});
 } 

foreach $cookie(keys %{$hl{'hl_permanent_list'}}){
  $hs{$cookie} = $hl{$cookie} if (defined $hl{$cookie});
 } 

$hl{'permanent_list'} = join(",", keys %{$hl{'permanent_list'}});
$hl{'hl_permanent_list'} = join(",", keys %{$hl{'hl_permanent_list'}});

foreach $cookie('hl_permanent_list','permanent_list','langid'){
	  $hs{$cookie}	= $hl{$cookie} if (defined $hl{$cookie});
	}

foreach my $auth(keys %$AUTH){
 my %ttt = map { $_ => 1 } split(/,/, $AUTH->{$auth}->{'list'});
 $hs{'auth_'.$auth} = join(',', keys %ttt );
}

foreach my $auth(keys %$AUTH_SUBMIT){
 my %ttt = map { $_ => 1 } split(/,/, $AUTH_SUBMIT->{$auth}->{'list'});
 $hs{'auth_submit_'.$auth} = join(',', keys %ttt );
}

}

sub get_atom_calls
{
 my ($al) = @_;
 my $atoms_text = get_atoms_text($al);
 my $atom_calls = [];
 
 foreach my $text(@$atoms_text){
  my $new_atom = get_atom_structure($text);

  unless(defined $new_atom->{'class'}){
	 $new_atom->{'class'} = 'default';
	}
	process_atom_libs($new_atom); # loading libs if needed
	
	unless(defined $atoms->{$new_atom->{'class'}}){
	  push_error('Don\'t known the class named \''.$new_atom->{'class'}.'\'');
	} 
	
	unless(defined $atoms->{$new_atom->{'class'}}->{$new_atom->{'name'}}){
	  push_error('Undefined atom named \''.$new_atom->{'name'}.'\' class \''.$new_atom->{'class'}.'\'');
	} else {
			$new_atom->{'origin'}	= $text;
   		push @$atom_calls,$new_atom;
		}
 }
 @$atom_calls = sort { $iatoms->{$b->{'name'}}->{'priority'} <=> $iatoms->{$a->{'name'}}->{'priority'} } @$atom_calls;
return $atom_calls;
}

sub process_atom
{
 my ($atom,$call) = @_;
 my $unauthorized = 0;
 my $unauthorized_submit = 0;
 my $authorized_add = 0;
 
			push_dmesg(1,"ATOM '$atom->{'name'}'");        
											
 if($iatoms->{$call->{'name'}}->{'custom_processing'} eq 'yes'){

	return &{\&{'proc_custom_processing_'.$call->{'name'}}}($atom,$call);
 } else {

# verifying hin data 

		$authorized_add 			= verify_authorized_add($call);		
		$unauthorized_submit 	= verify_unauthorized_submit($call);
		$unauthorized					= verify_unauthorized($call,$authorized_add);
		$call->{'call_params'}->{'authorized_all'} = $authorized_add;
		$call->{'call_params'}->{'unauthorized_submit'} = $unauthorized_submit;
		$call->{'call_params'}->{'unauthorized'} = $unauthorized;
		
		if(!$unauthorized and $iatoms->{$call->{'name'}}->{'authorize_by_field_only'}){
			$hs{'authorize_by_field_only'}=$iatoms->{$call->{'name'}}->{'authorize_by_field_only'};
		}
		log_printf("ATOM PROCESS: UNAUTH_SUB AUTH_ADD UNAUTH are $unauthorized_submit, $authorized_add, $unauthorized");

		if (defined $call->{'body'}) {
			$atom->{'processed'} = $call->{'body'};
		}
		else {
			$atom->{'processed'} = $atom->{'body'};
		}
		
# Filling $call->{'call_params'} hash

      prepare_atom_params($atom,$call);
			
			if(!$iatoms->{$call->{'name'}}->{'_resource_list'}){
			 $iatoms->{$call->{'name'}}->{'_resource_list'} = [];
			}
			if(!$iatoms->{$call->{'name'}}->{'_selector_list'}){
			 $iatoms->{$call->{'name'}}->{'_selector_list'} = [];
			}
#			if(!$iatoms->{$call->{'name'}}->{'_tmpresource_list'}){
#			 $iatoms->{$call->{'name'}}->{'_tmpresource_list'} = [];
#			}

			my @res_list = @{$iatoms->{$call->{'name'}}->{'_resource_list'}};
			my @sel_list = @{$iatoms->{$call->{'name'}}->{'_selector_list'}};
			my @tmpres_list = @{$iatoms->{$call->{'name'}}->{'_tmpresource_list'}};
		  @tmpres_list = sort @tmpres_list;
			my %auth;
			my %auth_submit;
			
      build_auth_hashes(\%auth, \%auth_submit, $call);

# Now executing and mapping resource results

# first selectors
			foreach my $key(@sel_list){
			  process_atom_selector($atom,$call,$key);
			}
# now parsing		
			$atom->{'processed'} = repl_ph($atom->{'processed'}, $call->{'selectors'});
     			
# assuming all keys are present 
      my $all_keys_present = 0;
			
# processing useful tmp tables (26.11.2006)
#		foreach my $key(@tmpres_list) {
#			push_dmesg(1,"processing tmp resource '$key'");
#			
#			if ($iatoms->{$call->{'name'}}->{'_tmpresource_'.$key}) {
#				$call->{'call_params'}->{'deep_search'} = $hin{'deep_search'} if ($hin{'deep_search'});
#				$iatoms->{$call->{'name'}}->{'_tmpresource_'.$key} = repl_ph($iatoms->{$call->{'name'}}->{'_tmpresource_'.$key},$call->{'call_params'});
#				if ((!$call->{'call_params'}->{'search_product_name'}) && ($call->{'name'} eq 'products')) {
#					## other
#					my $res_key = $key;
#					$res_key =~ s/(.*)_\d+/$1/;
#					$iatoms->{$call->{'name'}}->{'_resource_'.$res_key} =~ s/itmp_product_search tps,//;
#					$iatoms->{$call->{'name'}}->{'_resource_'.$res_key} =~ s/product\.product_id=tps\.product_id and //;
#				}
#				else {
#					do_statement($iatoms->{$call->{'name'}}->{'_tmpresource_'.$key.'_create'}) if ($iatoms->{$call->{'name'}}->{'_tmpresource_'.$key.'_create'});
#					do_statement($iatoms->{$call->{'name'}}->{'_tmpresource_'.$key});
#				}
#			}
#		}
		## hout deep_search
		$hout{'deep_search'} = $call->{'call_params'}->{'deep_search'};

		## indicate begin_scripts
		my $begin_script;
		#ALEXEY: if we deal with clipboard paginations we have to set %%atom_name%%_start_row before start_row will be processed
		# this code was brought from proc_custom_processing_clipboard as it's proceeed after main atom    
		if($hin{'clipboard_object_type'}){
			foreach my $item ('first', 'prev', 'next', 'last') {
				if ($hin{$item}) {
					$hin{$hin{'atom_name'}.'_start_row'} = str_htmlize($hin{'start_row_'.$item}); # DV CHANGES...
				}
			}
		}
		$hin{'rows_number'}=$atom->{'rows_number'} if !$hin{'rows_number'};		
# then resources	
			foreach my $key(@res_list) {
      
			# debugcheck
			push_dmesg(1,"processing resource '$key'");        

			  my $this_keys_present = execute_atom_resource($atom,$call,$key);
#				if(!$this_keys_present){ $all_keys_present = 0 }
				if($this_keys_present){ $all_keys_present = 1 }
				
# mapping
			   my @mapping = split(/,/,$iatoms->{$call->{'name'}}->{'_mapping_'.$key});
 				 if($#mapping == -1){
				  push_error("Mapping item for resource $key is invalid");
				 }
			   if(defined $call->{'_result_resource_'.$key}->[0] && defined $call->{'_result_resource_'.$key}->[0][0] ) {
 					push_dmesg(2,"resource '$key' had not empty result");
					
				  my $rows 		= $#{$call->{'_result_resource_'.$key}};
	   		  my $columns	= $#{$call->{'_result_resource_'.$key}->[0]};
					if ($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_type'} eq 'multi') {

					unless($atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_row'}){
						 log_printf("\$atoms->{$call->{'class'}}->{$call->{'name'}}->{$key".'_row} is empty');
					}

					my $row;
					my $i;
					my ($rows_text, $rows_header);
					my $start_row = $call->{'call_params'}->{'start_row'};
					
					if ($hin{'new_search'}) { # starting new search
						$start_row = 0; # resetting
					}
          $call->{'_resource_'.$key.'_count'}	=	$call->{'_resource_'.$key};

					#if($call->{'_resource_'.$key.'_count'} =~s/\s*select.*?from(.*?)/\ select count\(\*\) from $1/ismg) {
					#
					if ($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_disable_sql_calc_found_rows'} eq '1') {
						$call->{'_resource_'.$key.'_count'} =~s/\s*select.*?from(.*?)/\ select count\(\*\) from $1/ism;
					}
					else {
						$call->{'_resource_'.$key.'_count'} = "SELECT FOUND_ROWS()";
					}

					if (1) { # In connection with the script updating, the given condition has been cleaned

						#$call->{'_resource_'.$key.'_count'} = "SELECT FOUND_ROWS()";

						if (repl_ph($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_nav_bar'}, $call->{'call_params'})) {
							$call->{'_resource_'.$key.'_count'} = repl_ph($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_nav_bar'}, $call->{'call_params'});
						}
						$call->{'_resource_'.$key.'_count'}	=~s/order by.*\Z//gsi;
   					    if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_disable_sql_calc_found_rows'} eq '1' and exists($iatoms->{$call->{'name'}}->{'resource_'.$key.'_disable_sql_calc_found_rows_cache'})){
							my $search_md5;
							if($hin{'search_atom'}){# check if it is a search. if it is so, get parametrs md5
								if($iatoms->{'search_params_key'}){
									$search_md5=md5_hex($iatoms->{'search_params_key'});
								}else{
									lp('=========ERROR!!! please populate $iatoms->{search_params_key} in prepare params of search atom ');									
								}							
							} 
							$search_md5.='_'.$call->{'name'}.'_'.$key;
						  	my $cache_time=$iatoms->{$call->{'name'}}->{'resource_'.$key.'_disable_sql_calc_found_rows_cache'};
						  	if($cache_time=~/[\d\s\.]+/){
						  		$cache_time=~s/[\s\t]+//g;
						  		my $cached_count=do_query('SELECT select_count FROM cache_atom_resource_count 
						  									WHERE search_param_md5 = '.str_sqlize($search_md5)." and 			 
						  									unix_timestamp(updated)>(unix_timestamp()-($cache_time*60*60))")->[0][0];
								if(!$cached_count){
									$call->{'call_params'}->{'found'} = do_query($call->{'_resource_'.$key.'_count'})->[0][0];
									
									do_statement('DELETE FROM cache_atom_resource_count 
												WHERE search_param_md5 = '.str_sqlize($search_md5));
									do_statement('INSERT INTO cache_atom_resource_count (search_param_md5,select_count) 
												VALUES('.str_sqlize($search_md5).','.$call->{'call_params'}->{'found'}.')');
								}else{
									$call->{'call_params'}->{'found'}=$cached_count;
								}
						  	}else{
						  		push (@user_errors,"Atom $call->{'name'} has wrong value in cache_sql_calc_found_rows parametr");
						  	}
					    }else{
					  	 	$call->{'call_params'}->{'found'} = do_query($call->{'_resource_'.$key.'_count'})->[0][0];	
					    }

						my $pages = int($call->{'call_params'}->{'found'}/$atom->{'rows_number'});
						$call->{'call_params'}->{'pages'} 	= $pages;
						$call->{'call_params'}->{'next'}		= $start_row + $atom->{'rows_number'};
						$call->{'call_params'}->{'prev'}		= $start_row - $atom->{'rows_number'};
						$call->{'call_params'}->{'last_row'}= $rows + $start_row + 1;
						$hin{'last_row'}=$call->{'call_params'}->{'last_row'};
												
						if ($call->{'call_params'}->{'next'}>$call->{'call_params'}->{'found'} - $atom->{'rows_number'}) {
							$call->{'call_params'}->{'next'} = int($call->{'call_params'}->{'found'} / $atom->{'rows_number'}) * $atom->{'rows_number'};
						}
						 $call->{'call_params'}->{'last'} 	= $call->{'call_params'}->{'found'} - $atom->{'rows_number'};
						 $call->{'call_params'}->{'first'} = 0;
						 
						 my $nbr_pages = int($call->{'call_params'}->{'found'} / $atom->{'rows_number'}) + 1;
						 
						 my $i = int($start_row / $atom->{'rows_number'});

						 my $number_of_cases = 10;
						 my $next_case = 0;

						 while ($i < $nbr_pages) {

							 $next_case++;
							 
							 my $fmt;
							 
							 if ($start_row == ($i * $atom->{'rows_number'})) {
	 			 			 	 $fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'nav_link_current'};
							 }
							 else {
			 				 	 $fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'nav_link'}
							 }

							 my $step = int(
								 exp( log(10)*
											int(
												log(abs(int($start_row/10)*10 / $atom->{'rows_number'} - ($i-1)) + 1)
												/
												log(10)
											)
								 )
								 );

							 if (($next_case < $number_of_cases) || ($i+$step > $nbr_pages)) { # give 1st 10 cases & the last one
								  
								 $call->{'call_params'}->{'page_links'} .=  repl_ph(
									 $fmt,
									 {
										 'start_row' => $atom->{'rows_number'} * $i,
										 'start_page' => $i+1
									 });
							 }


							 $i += $step; 

						 }

						 $i = int($start_row / $atom->{'rows_number'});

						 $next_case = 0;

						 while ($i >= 1) {
							 
							 $next_case++;

							 my $step = int(
								 exp( log(10)*
											int(
												log(abs($start_row / $atom->{'rows_number'} - ($i-1)) + 1)
												/
												log(10)
											)
								 )
								 );

							 $i -= $step;
							 
							 if ($i < 0) {
								 $i = 0;
							 }
							 
							 my $fmt;
							 
							 $fmt = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'nav_link'};

							 if (($next_case < $number_of_cases) || ($i-$step <= 0)) { # give 1st 10 cases & the first one

								 $call->{'call_params'}->{'page_links'} =  repl_ph(
									 $fmt,
									 {
										 'start_row' => $atom->{'rows_number'} * $i,
										 'start_page' => $i+1
									 }).$call->{'call_params'}->{'page_links'} ;
								 
							 }
						 }

						$atom->{'processed'} = repl_ph($atom->{'processed'},
																						{
																							'page_links' => $call->{'call_params'}->{'page_links'}
																						});
						
						if ($call->{'call_params'}->{'prev'} < 0) {
							$call->{'call_params'}->{'prev'} = 0;
						}
						if ($call->{'call_params'}->{'next'} < 0) {
							$call->{'call_params'}->{'next'} = 0;
						}
						if ($call->{'call_params'}->{'last'} < 0) {
							$call->{'call_params'}->{'last'} = 0;
						}
					}
					
					$i = 0; my $rotate_arr; my $non_rotate_arr;
					
					while ($mapping[$i]) {
						if ($mapping[$i] =~ /_rotate_/) {
							push @$rotate_arr, $i;
						} else {
							push @$non_rotate_arr, $i;
						}
						$i++;
					}

					my $atom_name = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'name'};

					# new-rotate
					$hin{'new_rotate'} = 1;

	     		for($row = 0; $row < $rows + 1; $row++) {

						my $call_row = $call->{'_result_resource_'.$key}->[$row];
						
						my %tmp_hash; my $pf = 0;
						
						%tmp_hash = map { $mapping[$_] => $call_row->[$_] } @$non_rotate_arr;
						my $tmp_hash = \%tmp_hash;
						
						foreach my $i(@$rotate_arr){
							$tmp_hash->{$mapping[$i]."_".$call_row->[0]} = $call_row->[$i];
						}
						
						if($#user_errors > -1) {
							$pf = ($atom->{'name'} eq 'product_features')&&($key eq 'product_features')?1:0;
							foreach my $key2(keys %hin) {
								# simplify product_features format in product_details ($tmp_hash will be more simple, so repl_ph works more quickly)
								unless ($pf&&($key2 =~ /^_rotate_/)&&($key2 !~ /$call_row->[0]$/)) {
									$tmp_hash->{$key2} = $hin{$key2};
								}
							}
						}
						
						$tmp_hash = format_hash($tmp_hash,$call,$key,$call_row);
						
						$tmp_hash->{'no'} =	$row + $start_row + 1 ;
						$tmp_hash->{'found'} = $call->{'call_params'}->{'found'};
						
						# refreshing the flag
						$authorized_add = verify_authorized_add($call, $tmp_hash);
						
						# authorizing values
						
						authorize_values(\%auth, \%auth_submit, $tmp_hash);
						
						# now we are trying to guess which action is relevant
						# first, either we are authorized to do any update
						
						my $skeys_present = 1;
#						log_printf(" \$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_skey'} = ".$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_skey'});
						
						if(!$tmp_hash->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_skey'}} &&
						   !$hin{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_skey'}}){
							$skeys_present = 0; 
						}	 
						push_dmesg(3, "Secondary key $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_skey'} is present <===> $skeys_present ");

				    if (!$unauthorized_submit) {
							if ($skeys_present) {
								# got all keys - assuming update & delete actions are relevant
								if ($atom->{'update_action'}) { 
									$tmp_hash->{'update_action'} = $atom->{'update_action'};
									push_dmesg(3,'Enabling update');
								}
								if ($atom->{'delete_action'}) { 
									$tmp_hash->{'delete_action'} = $atom->{'delete_action'};
									push_dmesg(3,'Enabling delete');
								}
								$tmp_hash->{'insert_action'} = '';			
							}
							if (!$skeys_present) {
								# we assuming that adding is relevant
								if ($atom->{'insert_action'} && $authorized_add ) { 
									$tmp_hash->{'insert_action'} = $atom->{'insert_action'};
									push_dmesg(3,'Enabling insert');
								}
								push_dmesg(3,'Clearing enabled update & delete');
								$tmp_hash->{'delete_action'} = '';
								$tmp_hash->{'update_action'} = '';
							}
						}
						else {
							$tmp_hash->{'delete_action'} = '';
							$tmp_hash->{'update_action'} = '';
						}
						
						my $new_row = '';
						my $new_row_header = '';
						my $new_row_pattern = '';
						
						if (defined($atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_row_even'}) &&
								(int((1+$row)/2) == (1+$row)/2)) {
							$new_row_pattern = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_row_even'};
						} else {
							$new_row_pattern = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_row'};
						}
						
						if ($atom_name eq 'product_features') { # pre-customization
							if ($call_row->[1] eq 'textarea') {
								$new_row_pattern = $atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_row_textarea'};
							}
							if ($call_row->[14] ne $atoms->{$call->{'class'}}->{$call->{'name'}}->{'group_shower'}) {
								$tmp_hash->{'product_features_row_group'} = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'product_features_row_group'};
								$atoms->{$call->{'class'}}->{$call->{'name'}}->{'group_shower'} = $call_row->[14];
							}
							else {
								$tmp_hash->{'product_features_row_group'} = '';
							}
						}

						if ($atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_header'}) { # create header for multi
							$new_row_header = repl_ph(repl_ph($atoms->{$call->{'class'}}->{$call->{'name'}}->{$key.'_header'},$tmp_hash),$tmp_hash);
							$rows_header .= format_row($new_row_header,$call,$call_row,$key,$row);
						}
						
						$new_row = repl_ph(repl_ph($new_row_pattern,$tmp_hash),$tmp_hash);
						$rows_text .= format_row($new_row,$call,$call_row,$key,$row);
						
						# add some additional code to output
						if ( # product_features customization
								 ($atom_name eq 'product_features') &&
								 ($row > (($rows-2)/2)) && (!$atoms->{$call->{'class'}}->{$call->{'name'}}->{'splitter'})
								 ) {
							$atoms->{$call->{'class'}}->{$call->{'name'}}->{'group_shower'} = '';
							$rows_text .= $atoms->{$call->{'class'}}->{$call->{'name'}}->{'split_columns'};
							$atoms->{$call->{'class'}}->{$call->{'name'}}->{'splitter'} = '1';
							
						} # end of
						
					}
					push_dmesg(4,"resource '$key' result:\n $rows_text");

					# rows_header process customizaton - via external pattern!!!
					if ($rows_header) {
						process_atom_ilib('rows_header');
						process_atom_lib('rows_header');
						
						$call->{'call_params'}->{$key.'_rows'} = ($begin_script->{'headers'}?"":$atoms->{'default'}->{'rows_header'}->{'begin_script'}).
							repl_ph($atoms->{'default'}->{'rows_header'}->{'body'},
											 { 'header' => $rows_header,
												 'rows' => $rows_text,
												 'expand' => repl_ph($atoms->{'default'}->{'rows_header'}->{'expand'},{ 'suffix' => $key })});
						$begin_script->{'headers'} = 1;
					}
					else {
						$call->{'call_params'}->{$key.'_rows'} = $rows_text;
					}
					
			  } else {
				# single data
				   my $i;
					 my $tmp_hash = {};
				   for($i = 0; $i < $columns + 1; $i++){
							$tmp_hash->{$mapping[$i]} = $call->{'_result_resource_'.$key}->[0][$i];
							push_dmesg(4," \$tmp_hash->{$mapping[$i]} = $call->{'_result_resource_'.$key}->[0][$i];" );
					 }

					 # now formatting 
					 
					 # implication from %hin

						if($#user_errors > -1 || $hin{'reload'} ||
						   $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_imply_fields'}){
						 for($i = 0; $i < $columns + 1; $i++){
							  if(defined $hin{$mapping[$i]}){
		 							$tmp_hash->{$mapping[$i]} = $hin{$mapping[$i]};
								}
							 }
						} else {					 
						 # no errors
							 for($i = 0; $i < $columns + 1; $i++){
							  if(defined $hin{$mapping[$i]}){
		 							$hin{$mapping[$i]} = $tmp_hash->{$mapping[$i]};
								}
							 }
						}

					 $tmp_hash  = format_hash($tmp_hash,$call,$key,$call->{'_result_resource_'.$key}->[0]);


# authorizing values

						authorize_values(\%auth, \%auth_submit, $tmp_hash);
						$authorized_add 			= verify_authorized_add($call, $tmp_hash);		

					 
					 foreach my $item (keys %$tmp_hash){
						 $call->{'call_params'}->{$item} = $tmp_hash->{$item};
					 }

					   if($atom->{'unified_fields'} eq 'yes'){ 
							 $call->{'call_params'}->{$key.'_fields'} = unified_processing($atom,$call,$key);
						 }
				 }
			 } else {
# if empty query it
# should have defined replacement 
#log_printf()
								if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_type'} eq 'multi'){
									$call->{'call_params'}->{'found'} = '0';
									$call->{'call_params'}->{$key.'_rows'} = $atom->{'no_'.$key.'_rows'};
								} else {
									foreach my $param(@mapping){
										$call->{'call_params'}->{$param} = $hin{$param}||$atoms->{$call->{'class'}}->{$call->{'name'}}->{'default_'.$param};
										if(!$call->{'call_params'}->{$param} && $call->{'call_params'}->{$param} ne '0'){
										 $call->{'call_params'}->{$param} = '';
										}
									}
									if($atom->{'unified_fields'} eq 'yes'){ 
										$call->{'call_params'}->{$key.'_fields'} = unified_processing($atom,$call,$key);
									}
								my $hash = {};
								foreach my $field(@mapping){
								 $hash->{$field} = $call->{'call_params'}->{$field};
								}	
								$hash = format_hash($hash,$call,$key);
								foreach my $field(@mapping){
								 $call->{'call_params'}->{$field} = $hash->{$field};
								}	

								}
			 } 
		 # passing auth. values to globals
						foreach my $auth(keys %auth){
						  $AUTH->{$auth}->{'list'} .= $auth{$auth}->{'list'};
						}
						foreach my $auth(keys %auth_submit){
						  $AUTH_SUBMIT->{$auth}->{'list'} .= $auth_submit{$auth}->{'list'};
						}

		 
		 }
		 
		 # now we are trying to guess which action is relevant
		 
		 # first, either we are authorized to do any update
	 
	  my $ignore_keys = 0;
		if($iatoms->{$call->{'name'}}->{'_insert_ignore_keys'} eq 'yes'){ $ignore_keys = 1; }

		push_dmesg(3,"All keys present <==> ".$all_keys_present);
		log_printf($unauthorized_submit);

   if(!$unauthorized_submit){
		 if($all_keys_present || $ignore_keys){
		   # got all keys - assuming update & delete actions are relevant
       if($atom->{'update_action'}){ 
			   $call->{'call_params'}->{'update_action'} = $atom->{'update_action'};
			 }
       if($atom->{'delete_action'}){ 
			   $call->{'call_params'}->{'delete_action'} = $atom->{'delete_action'};
				 if(($USER->{'user_group'} ne 'supereditor')&&($USER->{'user_group'} ne 'superuser')&&($iatoms->{$call->{'name'}}->{'deny_editor_delete'} eq 'yes')){
			  	$call->{'call_params'}->{'delete_action'} = '';
				 }
			 }

		 }
		 if(!$all_keys_present || $ignore_keys) {
		  # we assuming that adding is relevant
       if($atom->{'insert_action'} && $authorized_add ){ 
			   $call->{'call_params'}->{'insert_action'} = $atom->{'insert_action'};
			 }

		 }
	}
     $call->{'call_params'}->{'atom_name'} = $call->{'name'};

		 $atom->{'processed'} = repl_ph($atom->{'processed'}, $call->{'call_params'});

#		log_printf(Dumper($atom->{'processed'}));
#		log_printf(Dumper($call->{'call_params'}));

		# unauthorized submit issue by DV: 1) replace all edits with texts, replace all buttons & submits with empty (3.12.2009)

#		log_printf($unauthorized_submit);
#		log_printf("Guest account cleaning for ".$atom->{'name'});

	# we need to remove all edits
	# if (($unauthorized_submit) && (lc($USER->{'user_group'}) eq 'guest') && ($atom->{'name'} !~ /_search/)) { 
	if ((lc($USER->{'user_group'}) eq 'guest') && ($atom->{'name'} !~ /_search/)) { 

		# log_printf("##### Replacement for guest in action ... #####");
		# log_printf("unauthorized_submit = " . $unauthorized_submit);
		# log_printf("user_group          = " . lc($USER->{'user_group'}) );
		# log_printf("atom name           = " . $atom->{'name'} );

		# text value within input can include ">" so we use IMPROVED regex for detection
		my ($input, $input_type, $input_value);
		while ($atom->{'processed'} =~ /(<input('[^']*'|"[^"]*"|[^'">])*>)/gi) {
		
		    # input tag 
		    $input = $1;
		    
		    # get type
		    $input =~ /\b type \s* = \s*
			(?:
			    "([^"]*)"
			    |
			    '([^']*)'
			    |
			    ([^'">\s]+)
			)
		    /xi;
		    $input_type = $+;
		
		    # get value
		    $input_value = '';
		    $input =~ /\b value \s* = \s*
			(?:
			    "([^"]*)"
			    |
			    '([^']*)'
			    |
			    ([^'">\s]+)
			)
		    /xmi;
		    $input_value = $+;
		
		    if ($input_type =~ /^(text|input)$/i ) {
			# replace $input content with content of value attribute
			# we use $input value not like regex, but like casual text
			$atom->{'processed'} =~ s/\Q$input\E/$input_value/i;
			
			    # something wrong
			    log_printf("<<< " . $input);
			    log_printf(">>> " . $input_value);
		    }
		    
		    # remove (without any replace) submit controls
		    if ($input_type =~ /^(submit)$/i ) {
			$atom->{'processed'} =~ s/\Q$input\E//i;
		    }
		    
		    # remove (without any replace) file controls
		    if ($input_type =~ /^(file)$/i ) {
			$atom->{'processed'} =~ s/\Q$input\E//i;
		    }
		
		} # while

		# similar processing for textarea tag
		# allow to match "." with EOL
		my ($textarea, $text, $container);
		while ($atom->{'processed'} =~ /(<textarea[^>]*>(.*?)<\/textarea>)/sgi ) {
		    $textarea = $1;
		    $text = $2;
		    
		    # append new style for former textarea
		    $container = "<div class='default_style_for_former_textarea'>" . $text . "</div>";
		
		    # same style substitution with \Q \E
		    $atom->{'processed'} =~ s/\Q$textarea\E/$container/i;
		}
		
		# similar processing for select tag
		# allow to match "." with EOL
		my ($select, $value);
		while ($atom->{'processed'} =~ /(<select[^>]*>(.*?)<\/select>)/sgi ) {
		    $select = $1;
		    
		    # structure for select was defined in atom_utils.pl, so we can use it in regex
		    $select =~ /<option selected value="(.*)">(.*?)\n/;
		    $value = $2;
		
		    # same style substitution with \Q \E
		    $atom->{'processed'} =~ s/\Q$select\E/$value/i;
		}
	} else {
	    # log_printf("##### No guest restrictions #####");
	    # log_printf("unauthorized_submit = " . $unauthorized_submit);
	    # log_printf("user_group          = " . lc($USER->{'user_group'}) );
	    # log_printf("atom name           = " . $atom->{'name'} );
	}

# if no security violations
		if (!$unauthorized) {
			return $atom->{'processed'};
		}
		else {
		  return '';
		}
 }
}

sub prepare_atom_params {
# this prepares $call->{'call_params'}
	my ($atom,$call) = @_;
	if (defined &{'proc_prepare_params_'.$call->{'name'}}) {
		no strict;
		&{'proc_prepare_params_'.$call->{'name'}}($atom,$call);
		use strict;
	}
	else {
		prepare_params_unifiedly($atom,$call);
	}
	
	unless($atom->{'rows_number'}) {
		$atom->{'rows_number'} = $iatoms->{$atom->{'name'} }->{'default_rows_number'} || 20;
	}
	
	$call->{'call_params'}->{'rows_number'} = $atom->{'rows_number'};
	$call->{'call_params'}->{'start_row'} = $hin{$atom->{'name'}.'_start_row'} || '0';
	
	# this params will be used in 'nav_bar2_memorize'
	# 'start_row' variable with tmpl name for navigation bar
	#my $start_row_variable = $atom->{'name'} . '_start_row';
	#$call->{'call_params'}->{'tmpl_start_row_variable'} = $start_row_variable;
	
	# get tail for navigation bar
	# get REQUEST_BODY and remove 3 name/value pairs
	# 1. sessid
	# 2. tmpl
	# 3. $atom->{'name'} . '_start_row'
	# 4. parameter with 'order_' word
	# 5. 'search_' block
	
	#my $req = $call->{'call_params'}->{'REQUEST_BODY'};
	#$req =~ s/sessid=[^;]*?;//;
	#$req =~ s/tmpl=[^;]*?;//;
	#$req =~ s/${start_row_variable}=[^;]*?;//;
	#$req =~ s/order_[^=]*?=[^;]*?(;|$)//;
	#$req =~ s/search_.*$//;

	#$call->{'call_params'}->{'navigation_tail'} = $req;
	
	if ($hin{'new_search'} ) {
		$call->{'call_params'}->{'start_row'} = 0;
		$hin{$atom->{'name'}.'_start_row'} = 0;
	}
	
	$hout{$atom->{'name'}.'_start_row'} = $hin{$atom->{'name'} . '_start_row' };
}

sub process_atom_selector
{
 my ($atom,$call,$key) = @_;

 		$call->{'_selector_'.$key} = repl_ph($iatoms->{$call->{'name'}}->{'_selector_'.$key},$call->{'call_params'});
				
		if(defined $iatoms->{$call->{'name'}}->{'_selector_'.$key.'_key'}){
	  # we have a key
			if(defined $call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_selector_'.$key.'_key'}}){
			# do query if we have the key
					 $call->{'_result_selector_'.$key} = do_query($call->{'_selector_'.$key});
			}
		} else {
			 # do it unconditionally
			 #  log_printf("uncond");
			 $call->{'_result_selector_'.$key} = do_query($call->{'_selector_'.$key});
		}
	
	if(defined $call->{'_result_selector_'.$key}->[0] &&
	   defined $call->{'_result_selector_'.$key}->[0][0]&&
		 $call->{'_result_selector_'.$key}->[0][0]){
#		 log_printf("defined");
     $call->{'selectors'}->{'selector_'.$key} = $atom->{'selector_'.$key.'_def'};
	} else {
#		 log_printf("undefined");
     $call->{'selectors'}->{'selector_'.$key} = $atom->{'selector_'.$key.'_undef'};
	} 
}

sub execute_atom_resource
{
 my ($atom,$call,$key) = @_;
 my $key_present = 0; # means keys is not defined or empty

 unless($iatoms->{$call->{'name'}}->{'_resource_'.$key}){
  log_printf("\$iatoms->{$call->{'name'}}->{'_resource_$key'} is empty!");
 }
 push_dmesg(2,"executing resource $key for $call->{'name'} started");        


 # building restriction
 my $restrict = '1';

 if( $iatoms->{$call->{'name'}}->{$key.'_restrict_'.$USER->{'user_group'}} ){
	$restrict = $iatoms->{$call->{'name'}}->{$key.'_restrict_'.$USER->{'user_group'}};
 }
 #$call->{'call_params'}->{'restrict'} = repl_ph($restrict, $call->{'call_params'})
 # if restrict was set before don't change it. needed for custom filter in track_lists.ail 02.11.2010 @Alexey  
 $call->{'call_params'}->{'restrict'} = repl_ph($restrict, $call->{'call_params'}) unless($call->{'call_params'}->{'restrict'});

 #preparing custom processing order fields and tables if specified
 if($call->{'call_params'}->{'order_fields'}){
  $iatoms->{$call->{'name'}}->{'_resource_'.$key} = repl_ph(
		$iatoms->{$call->{'name'}}->{'_resource_'.$key},{'order_fields'=>$call->{'call_params'}->{'order_fields'}});
 }
 if($call->{'call_params'}->{'order_tables'}){
  $iatoms->{$call->{'name'}}->{'_resource_'.$key} = repl_ph(
    $iatoms->{$call->{'name'}}->{'_resource_'.$key},{'order_tables'=>$call->{'call_params'}->{'order_tables'}});
 }

 # custom processing new fields and joins
 if($call->{'call_params'}->{'additional_values'}){
  $iatoms->{$call->{'name'}}->{'_resource_'.$key} = repl_ph(
		$iatoms->{$call->{'name'}}->{'_resource_'.$key},{'additional_values'=>$call->{'call_params'}->{'additional_values'}});
 }
 if($call->{'call_params'}->{'additional_joins'}){
  $iatoms->{$call->{'name'}}->{'_resource_'.$key} = repl_ph(
    $iatoms->{$call->{'name'}}->{'_resource_'.$key},{'additional_joins'=>$call->{'call_params'}->{'additional_joins'}});
 } 

 # building order by clause
 $call->{'call_params'}->{'order_clause'} = build_order_clause($atom,$call,$key);
 
 # building search clause
 my $search_clause = build_search_clause($atom,$call,$key); 

 $call->{'call_params'}->{'search_clause'} = $search_clause;

 # building supplier search filter
 $call->{'call_params'}->{'supplier_restrict_clause'} = build_supplier_restrict_clause();

 $call->{'_resource_'.$key} = repl_ph($iatoms->{$call->{'name'}}->{'_resource_'.$key},$call->{'call_params'});


 #build straight join tables order
 build_straight_join_order_clause($atom,$call,$key);

 $call->{'_resource_'.$key} = repl_ph($call->{'_resource_'.$key},$call->{'call_params'});
 

#####################################################################################################################

  if ($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_disable_sql_calc_found_rows'} ne '1') {
  	$call->{'_resource_'.$key} =~ s/^\s*(select)\s+(.+)$/$1 SQL_CALC_FOUND_ROWS $2/is; 
  }

    # removing %%.*%% left 
#		$call->{'_resource_'.$key} =~s/%%.*?%%/\'\'/g;
		if(defined $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}){
	  # we have a key
			if(defined $call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}}&&
				 $call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}} ne ''){
			# do query if we have the key
					 $key_present = 1; # really, it present

					 # adding this key to global keys list
#					 log_printf($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}.'='.$call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}}.';');
					 $call->{'call_params'}->{'joined_keys'} .= $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}.'='.$call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}}.';';
					 $call->{'call_params'}->{'hidden_joined_keys'} .= "<input type=hidden name=\"".$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}."\" value=\"".$call->{'call_params'}->{$iatoms->{$call->{'name'}}->{'_resource_'.$key.'_key'}}.'">';					 

           if(!$call->{'no_resource_exec'}){

						 $call->{'_result_resource_'.$key} = do_query($call->{'_resource_'.$key});
							 if(!defined $call->{'_result_resource_'.$key}->[0]){
						  				if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_iq'}){
					 							 $call->{'_resource_'.$key} = repl_ph($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_iq'},$call->{'call_params'});			
												 $call->{'_result_resource_'.$key} = do_query($call->{'_resource_'.$key});
											}
							}
					}
				} else {
			# probably we have an insert query appointed
 				if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_iq'}){
				  $call->{'_resource_'.$key} = repl_ph($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_iq'},$call->{'call_params'});			
					$call->{'_result_resource_'.$key} = do_query($call->{'_resource_'.$key});
				}
			}
		} else {
			 # do it unconditionally
			 #  log_printf("uncond");
           if(!$call->{'no_resource_exec'}){
						 $call->{'_result_resource_'.$key} = do_query($call->{'_resource_'.$key});
					 }
		}
	if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_rearrange_as'} eq 'tree'){
   # finding tree key and parent 
	 my @mapping = split(/,/,$iatoms->{$call->{'name'}}->{'_mapping_'.$key});
	 my ($key_i,$parent_i); # indexes
	 my $i = 0;

	 while( $i < $#mapping ) {
	  if($mapping[$i] eq $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_tree_key'}){
		  $key_i = $i;
		}
	  if($mapping[$i] eq $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_parent_key'}){
		  $parent_i = $i;
		}

	  $i++;
	 }
		
	 # now got indexes found
	 my $tmp = {};
	 my $result = [];
	 foreach my $row(@{$call->{'_result_resource_'.$key}}){
	 		push @{$tmp->{$row->[$parent_i]}->{'children'}}, $row->[$key_i];
			$tmp->{$row->[$key_i]}->{'data'} =  $row;
	 }
	 
	 my $root = '1';
	 
	 foreach my $id(keys %$tmp){
	  if(!defined $tmp->{$id}->{'data'}&&$id ne $root){
#		 log_printf($id);
		 
		 foreach my $child(@{$tmp->{$id}->{'children'}}){
#		 log_printf($child);
		  push @{$tmp->{$root}->{'children'}}, $child;
		 }
		 
		 delete $tmp->{$id};
		}
	 }
   my $multi = $atoms->{$call->{'class'}}->{$call->{'name'}}->{'tree_multi'};
	 $result = rearrange_as_tree($root,0,$tmp,1,$multi);

	 $call->{'_result_resource_'.$key} = $result;
	 $iatoms->{$call->{'name'}}->{'_mapping_'.$key} .= ',tree_multi,tree_level';	 
	 
				  my $rows 		= $#{$call->{'_result_resource_'.$key}};
	   		  my $columns	= $#{$call->{'_result_resource_'.$key}->[0]};

	 
	} 
	$iatoms->{$call->{'name'}}->{'executed_resource_sql_'.$key}=$call->{'_resource_'.$key}; # save the procesed sql. very useful for clipboard
push_dmesg(3, "resource $key and key flag is $key_present");
push_dmesg(2,"executing resource $key for $call->{'name'} done");        
return $key_present;
}



sub format_hash
{
my ($hash,$call,$res, $data_row) = @_;

my $iatom = $iatoms->{$call->{'name'}};
			foreach my $item(keys %$iatom){
				if($item=~m/format_as_(.+)/){
							my $format = $1;
							if(defined &{'format_as_'.$format}){
				 				my @field_list = split(/,/,$iatom->{$item});
								 foreach my $field(@field_list){
									 no strict;
									  push_dmesg(3,"$field as $format");
									 if(defined $hash->{eval_view_name($field,$data_row)} or $iatoms->{$call->{'name'}}->{'format_undef_values'}){
					 					$hash->{eval_view_name($field,$data_row)} = &{'format_as_'.$format}($hash->{eval_view_name($field,$data_row)},$call,eval_view_name($field,$data_row),$res,$hash);
									 } else {
									   push_dmesg(3,"format_hash: field ".eval_view_name($field,$data_row)." to format $format is undef");
									 }
								 
								 }
							} else {
							 push_dmesg(3,'Format routine for '.$format.' is undef!');
							}
						}

			}

return $hash;
}				 

sub format_row
{
  my ($row_text,$call,$row_data,$key,$row) = @_;
  
	my $iatom = $iatoms->{$call->{'name'}};
  
	foreach my $item(keys %$iatom){
		my $pat = '_format_'.$key.'_row_as';

		if($item=~m/$pat/){
		 my $format = $iatom->{$pat};
		 my $name = 'format_row_as_'.$format;
		 if(defined &$name){
		   no strict;
			 $row_text = &$name($row_text,$call,$row_data,$key,$row);
		 }
		}
	}
 return $row_text;  
}
sub execute_command
{
 my ($pre) = @_;
my $result = 1;
my $commands 			= $hin{$pre.'command'};
# log_printf($command);
my @commands = split(/,/, $commands);
foreach my $command(@commands){
 if($command&&$result){
     no strict;
     if(defined &{'command_proc_'.$command}){
				$result = &{'command_proc_'.$command}();
				push_dmesg(3, "launching ".$pre."command $command");
		 } else {
					push_error('Invalid '.$pre.'command name: '.$command);
		 }
 }
}
 				delete $hin{$pre.'command'}; # to avoid (pre)command double executing
return $result;
}

sub atom_submit {
	my ($atom_name,$atom_class)=@_;
	my $result = 1;
	my $command_executed = 0;

	if (($hin{'atom_submit'} ||
			 $hin{'atom_update'} ||
			 $hin{'atom_delete'}) && $hin{'atom_name'}) {
		
		$command_executed = 1;
		
		$atom_class = $hin{'atom_class'} || 'default';
		my $call = { 'name' => $atom_name, 'class' => $atom_class };
		
		my $unauthorized_submit 	= verify_unauthorized_submit($call);
		my $authorized_add 				= verify_authorized_add($call);		
		my $unauthorized					= verify_unauthorized($call,$authorized_add);
		
		push_dmesg(2,"ATOM SUBMIT: UNAUTH_SUB AUTH_ADD UNAUTH are $unauthorized_submit, $authorized_add, $unauthorized");
		
		if (!$authorized_add && $unauthorized_submit) {
			return 0;
		}
		
		process_atom_libs($call);
		
		# perform validation
		push_dmesg(2,"modifying input");
		# perform modifying
		modify_atom_submit($call);
		# perform validation
		push_dmesg(2,"validating input");
		validate_atom_submit($call,$atom_name,$atom_class);
		
		# formatting input to output
		push_dmesg(2,"formatting output");
		format_atom_input($call);
		
		if ($#user_errors < 0) {
			#getting sequence list
			push_dmesg(2,"processing sequence list");
			my @i_sequence = split(/,/,$iatoms->{$atom_name}->{'_insert_sequence'});
			foreach my $seq(@i_sequence) {
				# foreach insert do:
				push_dmesg(2,"Processing insert seq. $seq");
				
				my $r_arr = []; # rotate array
				my $r_res = '';	# rotating by ...
				my $r_flag = 0; # rotate flag
				
				
				last if $result == 0;
		 		my $key;
		 		my $u_key;	# for rotation purposes
				
				if ($r_res = $iatoms->{$atom_name}->{'_rotate_insert_'.$seq}) {
					#  ^^^^^ is the resource name.
					# performing query
					push_dmesg(3,"rotating by $r_res");						 
					$r_flag = 1;
					
					#standard call
					my $call = { 'name' => $atom_name, 'class' => $atom_class };
					
					# preparing params
					prepare_atom_params($atoms->{$call->{'class'}}->{$call->{'name'}},$call);
					
					# executing rotate resource
					execute_atom_resource($atoms->{$call->{'class'}}->{$call->{'name'}},$call,$r_res);
					
					$r_arr = $call->{'_result_resource_'.$r_res};
				}
				else {
					$r_arr = [[1]]; # nothing to rotate
				}
				my @r_names = split(/,/,$iatoms->{$atom_name}->{'_mapping_'.$r_res});						 

				foreach my $r_row(@$r_arr) {

					my $i_flag = 0;
					# if($i_flag == 1){ do insert}
					# if($i_flag == 2){ do update}
					# if($i_flag == 3){ do delete}
					
					my $unique = 1; # if($unique) then data in %hin are unique comparing to db
					
					# insert fields (names in db)
					my @i_fields = split(/,/,$iatoms->{$atom_name}->{'_insert_fields_'.$seq});
					# insert values (names in %hin)
					my @i_values = split(/,/,$iatoms->{$atom_name}->{'_insert_values_'.$seq});

					if ($r_flag) { # if rotating
						$key 	= eval_view_name('_rotate_'.$iatoms->{$atom_name}->{'_insert_key_'.$seq},$r_row);
						$u_key = eval_view_name('_rotate_'.$iatoms->{$atom_name}->{'_update_key_'.$seq},$r_row);
					}
					else {
						$key 	= eval_view_name($iatoms->{$atom_name}->{'_insert_key_'.$seq},$r_row);
						$u_key = eval_view_name($iatoms->{$atom_name}->{'_update_key_'.$seq},$r_row);
					}
					push_dmesg(3, "the key for $key seq. $seq is \'$hin{$key}\'");
					
					if ($hin{$key}) {
						
						if ($iatoms->{$atom_name}->{'_update_sequence_'.$seq} &&
							 ($hin{'atom_update'} || $hin{'atom_submit'})
							 && !$unauthorized_submit) {
							
							$i_flag = 2;
							
						}
						elsif ($iatoms->{$atom_name}->{'_delete_sequence_'.$seq} &&
										$hin{'atom_delete'} && !$unauthorized_submit) { 
							# deleting right here
							
							delete_rows($iatoms->{$atom_name}->{'_insert_table_'.$seq},
													 eval_name($iatoms->{$atom_name}->{'_insert_key_'.$seq.'_name'} || $iatoms->{$atom_name}->{'_insert_key_'.$seq})." = ".$hin{$key});
							
							$i_flag = 0;
							if ($iatoms->{$atom_name}->{'_insert_sequence_'.$seq.'_clear_keys'} eq 'yes') {
								delete $hin{$key};
							}					 
						}
						
					} elsif (($hin{'atom_submit'} || $hin{'atom_update'}) && $authorized_add) {
						push_dmesg(3, "DON'T have the key for $key seq. $seq");					
						$i_flag = 1;
					}
					if ($iatoms->{$atom_name}->{'_update_sequence_'.$seq} &&
						 $hin{'atom_update'} &&
						 $hin{$u_key} &&
						 !$unauthorized_submit) {
						# in case of update key defined	 
						$i_flag = 2;
					}
					
					push_dmesg(3,"insert flag for seq. $seq is $i_flag");
					
					if ($i_flag) {
						# performing insert (without the $key)
			 			
						my $i_hash; # insert hash
						
						my %r_map = map { $r_names[$_] => $r_row->[$_] } (0..$#$r_row);
						
						my $r_map = \%r_map;  
						
						if ($#i_fields != $#i_values ) {
							log_printf("atom_submit: fields and values are mismatch at atom $atom_name, sequence $seq");
							log_printf(" $#i_fields != $#i_values 	");
						}
						else {
							
							# forming insert hash
							for (my $i = 0; $i<= $#i_fields; $i++) {
								my $item 	= $i_values[$i];
								my $val 	= eval_value($item,$r_map,$r_row,$atom_name,$atom_class);
#HERE
								
								$i_hash->{$i_fields[$i]} = str_sqlize($val); 
								push_dmesg(2,"\$i_hash->{$i_fields[$i]} = $i_hash->{$i_fields[$i]} ");
							}
							
#									log_printf($iatoms->{$atom_name}->{'_insert_'.$seq.'_keep_unique'});
							
							if ($iatoms->{$atom_name}->{'_insert_'.$seq.'_keep_unique'}) {
								# checking if unique data
								push_dmesg(2," checking unique for $seq");
								
								my $where = ' 1 ';
								my $check_hash;
								if ($iatoms->{$atom_name}->{'_insert_'.$seq.'_unique_set'}) {
									my @set = split(/,/, $iatoms->{$atom_name}->{'_insert_'.$seq.'_unique_set'});
									foreach my $item(@set){
										$check_hash->{$item} = $i_hash->{$item};
									}
								}
								else {
									%$check_hash = %$i_hash;
								}
								
								while (my ($a,$b) = each %$check_hash) {
									$where .= ' and '.$a.' = '.$b;
								}
#										log_printf($where);
								
								my $dummy = do_query("select ".($iatoms->{$atom_name}->{'_insert_key_'.$seq.'_name'} || eval_name($key)).
																			" from ".$iatoms->{$atom_name}->{'_insert_table_'.$seq}." where ".$where);
								my $i = 0; 
								if (defined $dummy->[0]) {
									# we have such record
									push_dmesg(2,"have dummy defined");

									if ($hin{$key}) {
										if ($dummy->[0][0] == $hin{$key}) {
											# record are match & keys are match
											# ==> record itself
											$unique = 1;
										}
										else {
											# records are match but keys are different
											# another record
											$unique = 0;
										}
									}
									else {
										$unique = 0; # don't have the key, but the record i slaready there
										# key implication
										
#											 log_printf("don't have key: \$hin{$key} = $dummy->[0][0]");
										if ($iatoms->{$atom_name}->{'_insert_'.$seq.'_pass_key'} eq 'permanent') {
											# passing permanently
											$hin{$key} = $dummy->[0][0];
											$hl{'permanent_list'}->{$key} = 1;
										}
									}
								}
								else {
									# we don't have such record
									$unique = 1;
									# so, should insert
									# if($i_flag == 2){ $i_flag = 1; }
								}
								push_dmesg(2,"unique flag is $unique");						 				
							}
							
							#inserting 
							# check on unique
							if ($iatoms->{$atom_name}->{'_insert_'.$seq.'_keep_unique'} && !$unique) {

								my @set = split(/,/, $iatoms->{$atom_name}->{'_insert_'.$seq.'_unique_set'});
								foreach my $uni(@set) {
#										  log_printf($uni.'!'.$atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{eval_name($uni)});
									push_user_error(repl_ph(
																						$atoms->{'default'}->{'errors'}->{'unique'},
																						{
																							"name" => $atoms->{$call->{'class'}}->{$call->{'name'}}->{'var_names'}->{eval_name($uni)}
																						}));
								}
								$result = 0;
							}
							else {
								if ($i_flag == 1) {
									# check for `void values` (1001743: Create "Ignore void values inserting" mechanism to ICEcat engine)
									unless (($iatoms->{$atom_name}->{'_insert_'.$seq.'_ignore_void_values'}) &&
											(($i_hash->{$iatoms->{$atom_name}->{'_insert_'.$seq.'_ignore_void_values'}} eq str_sqlize('')))) {
										if (!insert_rows($iatoms->{$atom_name}->{'_insert_table_'.$seq}, $i_hash)) {
											$result = 0;
										}
										else {
											# refreshing the key
											if (!$iatoms->{$atom_name}->{'_insert_'.$seq.'_no_refresh'}) {
												$hin{$key} = sql_last_insert_id();
												
												push_dmesg(2,"refreshing: the key $key became $hin{$key}");
												if ($iatoms->{$atom_name}->{'_insert_'.$seq.'_pass_key'} eq 'permanent') {
													# passing permanently
													$hl{'permanent_list'}->{$key} = 1;
												}
											}
											else {
												$hs{'is_'.$key} = sql_last_insert_id();
											}
										}
										if ($iatoms->{$atom_name}->{'_insert_sequence_'.$seq.'_clear_keys'} eq 'yes') {
											delete $hin{$key};
										}					 
									}
									else {
									}
								}
								elsif ($i_flag == 2) {
#									log_printf("\nafter4 $key => $hin{$key}");
									# update
									if (!update_rows($iatoms->{$atom_name}->{'_insert_table_'.$seq},
																		eval_name($iatoms->{$atom_name}->{'_insert_key_'.$seq.'_name'} || $iatoms->{$atom_name}->{'_insert_key_'.$seq}).
																		" = ".$hin{$key} ,$i_hash)) {
										$result = 0;
									}
								}
								if ($iatoms->{$atom_name}->{'_insert_sequence_'.$seq.'_clear_keys'} eq 'yes') {
									delete $hin{$key};
								}
							}
						}
					}
				}
			}
			# now authorizing from hin what could been changed
      my $auth = {};
			my $auth_submit = {};
			build_auth_hashes($auth, $auth_submit, $call);
			authorize_values($auth, $auth_submit, \%hin);
			
			# passing auth. values to globals
			foreach my $item(keys %$auth) {
				$hl{'auth_'.$item} .= $auth->{$item}->{'list'};
			}
			foreach my $item(keys %$auth_submit) {
				$hl{'auth_submit_'.$item} .= $auth_submit->{$item}->{'list'};
			}
			
		}
		else {
			return 0;
		}
	}
	if ($result && $hin{'atom_submit'} && $hin{'tmpl_if_success_cmd'} && $hin{'tmpl_if_create_and_success_cmd'}) {
		$hin{'tmpl_if_success_cmd'} = $hin{'tmpl_if_create_and_success_cmd'};
	}
	return ($result, $command_executed);
} # sub atom_submit

sub eval_value
{
	  my ($item,$r_map,$r_row,$atom_name,$atom_class) = @_;
		my $val;
 		
		# $self->... substitutions
		if($item =~m/\$self\-\>(.+)/){
		   $val = $atoms->{$atom_class}->{$atom_name}->{$1};
		} elsif($item =~m/\$\$(.+)\$\$/){
			 $val = eval $1;										 
		} elsif($item =~m/_rotate_(.+)/){
		   
		   $val = $hin{"_rotate_$1_".$r_row->[0]};
		}	else {
			 $val = $hin{$item};
		}
 return $val;
}

sub modify_atom_submit {
	my ($call) = @_;

	my $atom = $atoms->{$call->{'class'}}->{$call->{'name'}};
	my $iatom = $iatoms->{$call->{'name'}};
	
	my $r_arr;
	my $rotate_ref = {};

	my $atom_name 	= $hin{'atom_name'};
	my $atom_class = $hin{'atom_class'} || 'default';

	my @i_sequence = split(/,/,$iatoms->{$atom_name}->{'_insert_sequence'});
	my $r_flag;

	foreach my $seq(@i_sequence){

		if(my $r_res = $iatoms->{$atom_name}->{'_rotate_insert_'.$seq}){
# ^^^^^ is the resource name.
# performing query
			push_dmesg(3,"rotating by $r_res");						 
			$r_flag = 1;


#standard call
			my $call = {'name' => $atom_name, 'class' => $atom_class };

# preparing params
			prepare_atom_params($atoms->{$call->{'class'}}->{$call->{'name'}},$call);

# executing rotate resource
			execute_atom_resource($atoms->{$call->{'class'}}->{$call->{'name'}},$call,$r_res);

			$r_arr = $call->{'_result_resource_'.$r_res};
		} else {
			$r_arr = [[1]]; # nothing to rotate
		}
		my @r_names = split(/,/,$iatoms->{$atom_name}->{'_insert_values_'.$seq});
		foreach my $name(@r_names){
			if($name =~m/^_rotate_/){
				$rotate_ref->{$name} = $r_arr;
			}
		}
	}

 process_atom_libs({"name" => "errors" });

	foreach my $item(keys %$iatom){
		if($item =~m/modify_as_(.+)/){
			my $type = $1;

			if(defined &{'modify_as_'.$type}){
				my @fields = split(/,/,$iatom->{'modify_as_'.$type});

				foreach my $field(@fields){
					no strict;
					my $error = &{'modify_as_'.$type}($call,$field, $rotate_ref->{$field});
					if($error){
						push_user_error($error);
					}
				}

			} else {
				log_printf("Modification routine from $type is not defined! ");
			}
		}  
	}

}

sub validate_atom_submit
{
 my ($call,$atom_name,$atom_class_) = @_;
 
 my $atom = $atoms->{$call->{'class'}}->{$call->{'name'}};
 my $iatom = $iatoms->{$call->{'name'}};

 my $r_arr;
 my $rotate_ref = {};

 my $atom_class = $atom_class_ || 'default';

 my @i_sequence = split(/,/,$iatoms->{$atom_name}->{'_insert_sequence'});
 my $r_flag;
 
 foreach my $seq(@i_sequence){

		if(my $r_res = $iatoms->{$atom_name}->{'_rotate_insert_'.$seq}){
						 # ^^^^^ is the resource name.
						 # performing query
						 push_dmesg(3,"rotating by $r_res");						 
						 $r_flag = 1;
						 

						 #standard call
						 my $call = {'name' => $atom_name, 'class' => $atom_class };
						 
						 # preparing params
						 prepare_atom_params($atoms->{$call->{'class'}}->{$call->{'name'}},$call);
						 
						 # executing rotate resource
						 execute_atom_resource($atoms->{$call->{'class'}}->{$call->{'name'}},$call,$r_res);
						 
						 $r_arr = $call->{'_result_resource_'.$r_res};
		} else {
						 $r_arr = [[1]]; # nothing to rotate
		}
	 		 my @r_names = split(/,/,$iatoms->{$atom_name}->{'_insert_values_'.$seq});
       foreach my $name(@r_names){
			  if($name =~m/^_rotate_/){
				 $rotate_ref->{$name} = $r_arr;
				}
			 }
	}



 process_atom_libs({"name" => "errors" });

 foreach my $item(keys %$iatom){
  if($item =~m/validate_as_(.+)/){
	 my $type = $1;
	 
	  if(defined &{'validate_as_'.$type}){
		 my @fields = split(/,/,$iatom->{'validate_as_'.$type});
		 
		 foreach my $field(@fields){
		  no strict;
			my $error = &{'validate_as_'.$type}($call,$field, $rotate_ref->{$field});
			if($error){
			 push_user_error($error);
			}
		 }
		
		} else {
		 log_printf("Validation routine from $type is not defined! ");
		}
	}  
 }
 
}

sub format_atom_input
{
 my ($call) = @_;
 
 my $atom = $atoms->{$call->{'class'}}->{$call->{'name'}};
 my $iatom = $iatoms->{$call->{'name'}};

 foreach my $item(keys %$iatom){
  if($item =~m/store_as_(.+)/){
	 my $type = $1;
	 
	  if(defined &{'store_as_'.$type}){
		 my @fields = split(/,/,$iatom->{'store_as_'.$type});
		 
		 foreach my $field(@fields){
		  no strict;
			$hin{$field} = &{'store_as_'.$type}($call,$field,$hin{$field});
		 }
		
		} else {
		 log_printf("Store routine for $type is undef!");
		}
	}  
 }
 
}

sub unified_processing
{
my ($atom,$call,$key) = @_;;
my @mapping = split(/,/,$iatoms->{$call->{'name'}}->{'_mapping_'.$key});

# if for the resource turned on unified fields
my $fields 			= '';
my %processed;
my $field_fmt 	= $atom->{$key.'_field'};


my @field_order = split(/,/,$atom->{$key.'fields_order'});

						 foreach my $field(@field_order){
						  $fields .= repl_ph($field_fmt,{ "value" => $call->{'call_params'}->{$field},
																							"name"	=> $field,
																							"prompt"=> $atom->{$key.'.'.$field}  
																						 });
							$processed{$field} = 1;
						 }
						 
						 foreach my $field(@mapping){
						  unless($processed{$field}){
							 		  $fields .= repl_ph($field_fmt,{ "value" => $call->{'call_params'}->{$field},
																							"name"	=> $field,
																							"prompt"=> $atom->{$key.'_'.$field}  
																						 });
							}
						 }

return $fields;
}

sub process_atom_libs
{
 my ($atom) = @_;
 unless(defined $iatoms->{$atom->{'name'}}->{'_resource_list'}){ 
   # if ilib is not loaded trying to load
   process_atom_ilib($atom->{'name'});
 }

 unless(defined $atoms->{$atom->{'class'}}->{$atom->{'name'}}){
   # if lib is not loaded trying to load
   process_atom_lib($atom->{'name'})
 } 
}

sub eval_name
{
 my ($name) = @_;
 
 if($name=~m/_rotate_(.*)/){
  $name=$1; 
 }
 
 return $name;
}

sub eval_view_name
{
 my ($name,$row) = @_;
 
 if($name=~m/_rotate_/){
  $name .='_'.$row->[0]; 
 }
 
 return $name;
}

sub authorize_values
{
my ($auth, $auth_submit, $tmp_hash) = @_;

						# checking if auth. fields present
						foreach my $auth_item(keys %$auth){
						push_dmesg(3, "checking auth item $auth_item");
						 if(defined $tmp_hash->{$auth_item}){
						  if(!defined $auth->{$auth_item}->{'conds'}){
						 		 $auth->{$auth_item}->{'list'} .= ','.$tmp_hash->{$auth_item};
						     push_dmesg(3, "authed $auth_item $tmp_hash->{$auth_item}");
							} else {
								foreach my $cond(@{$auth->{$auth_item}->{'conds'}}){
									   if( $USER->{$cond->{'user'}} eq
									 	    $tmp_hash->{$cond->{'tmp'}}
									 		){
						 			 				$auth->{$auth_item}->{'list'} .= ','.$tmp_hash->{$auth_item};
						  		   			push_dmesg(3, "authed $auth_item $tmp_hash->{$auth_item}");
									 	}
								}							
							}
						 }
						}
# now checking the same for submit authorization
						foreach my $auth_item(keys %$auth_submit){
						 if(defined $tmp_hash->{$auth_item}){
						  push_dmesg(3, "checking submit auth $auth_item");
						  if(!defined $auth_submit->{$auth_item}->{'conds'}){
						 		 $auth_submit->{$auth_item}->{'list'} .= ','.$tmp_hash->{$auth_item};
						     push_dmesg(3, "authed submit $auth_item $tmp_hash->{$auth_item}");
							} else {
								foreach my $cond(@{$auth_submit->{$auth_item}->{'conds'}}){
								  my $lkey = $cond->{'user'};
									my $rkey = $cond->{'tmp'};
								
								  my $rvalue = '';
									my $lvalue = '';
								
									if($lkey =~m/^\'(.*)\'\Z/){ # in '..'
  									 $lvalue = $1;
									} else {
										 $lvalue = $USER->{$lkey};
									}
									if($rkey =~m/^\'(.*)\'\Z/){ # in '..'
 		 								 $rvalue = $1;
									} else {
										 $rvalue = $tmp_hash->{$rkey};
									}
								
								  if( $lvalue eq $rvalue ){
							 					$auth_submit->{$auth_item}->{'list'} .= ','.$tmp_hash->{$auth_item};
						 		  			push_dmesg(3, "authed submit $auth_item $tmp_hash->{$auth_item}");
									}
								}
							}
						 }
						}

}

sub verify_unauthorized_submit {
	my ($call) = @_;
	
	my $unauthorized_submit = 0;
	
	my @vrfy_submit = split(/,/ , $iatoms->{$call->{'name'}}->{'verify_submit'}); 
	
	foreach my $item (@vrfy_submit) {
		my %v_hash = map { $_ => 1 } split(/,/, $hl{'auth_submit_'.$item});
		log_printf("\$hl{auth_submit_$item} = ".$hl{'auth_submit_'.$item});
		#log_printf(Dumper(\%v_hash));
		if ($hin{$item} && !(defined $v_hash{$hin{$item}} || ($hl{'authorize_by_field_only'} && $hl{'authorize_by_field_only'} eq $item))) {
			$unauthorized_submit = 1;
			push_dmesg(2, " uauth submit value! item $item == $hin{$item}");
		}
	}
	
	return $unauthorized_submit;
}

sub verify_authorized_add
{
my ($call, $tmp_hash) = @_;
my $authorized_add = 0;
		if($iatoms->{$call->{'name'}}->{'verify_add'}){

   	 my @vrfy_add = split(/,/ , $iatoms->{$call->{'name'}}->{'verify_add_'.$USER->{'user_group'}}); 
		 foreach my $item (@vrfy_add){
#log_printf("checking item $item");
       $item =~s/\s//g;
			 my ($field,$cond) = split(/#/, $item);
			 my ($cond_user,$cond_tmp) = split('==', $cond);
						  if(!defined $cond_user){
								 $authorized_add = 1;
#log_printf('no conditions - authed to add');
							} else {
#log_printf('condition');
							  if( $USER->{$cond_user} eq
								    $tmp_hash->{$cond_tmp}
									){
#log_printf('ok');
											$authorized_add = 1;
									} else {
#log_printf('failed');									
									}
							}
		 }
		} else {
				$authorized_add = 1;		
		}
return  $authorized_add
}

sub verify_unauthorized
{
my ($call,$authorized_add) = @_;
my $unauthorized = 0;

#log_printf(Dumper(\%hin));
#log_printf(Dumper($call));
#log_printf(Dumper($iatoms->{$call->{'name'}}));

if (($USER->{'user_group'} eq 'guest') && ($iatoms->{$call->{'name'}}->{'verify_deny_guest'})) {
	$glob_unauthorized = 1;
	return 1;
}

if(defined $USER){
    my @vrfy = split(/,/ , $iatoms->{$call->{'name'}}->{'verify'}); 
		foreach my $item (@vrfy){
		 my %v_hash = map { $_ => 1 } split(/,/, $hl{'auth_'.$item});
		if( $hin{$item} && !( defined $v_hash{$hin{$item}} || 
							  	($hl{'authorize_by_field_only'} && $hl{'authorize_by_field_only'} eq $item))	
			){
	#if($hin{$item} && !defined $v_hash{$hin{$item}}){
		    $hin{$item} = '-1';  
			  push_user_error($atoms->{'default'}->{'errors'}->{'unauthorized'}) if (!$glob_unauthorized);
				$unauthorized = 1;
				$glob_unauthorized = 1;
			 }
		}
	}
	else {
		push_user_error($atoms->{'default'}->{'errors'}->{'unauthorized'}) if (!$glob_unauthorized);
		$unauthorized = 1;
		$glob_unauthorized = 1;
	}
	return $unauthorized;
}

sub build_auth_hashes {
	my ($auth, $auth_submit, $call) = @_;
	
	# building the hash of fields which should be authorized
	push_dmesg(3, "Building auth hashes");
	foreach my $item (split(/,/, $iatoms->{$call->{'name'}}->{'authorize_'.$USER->{'user_group'}}) ) {
		$item =~s/\s//g;
		my ($field,$cond) = split(/#/, $item);
		my ($cond_user,$cond_tmp) = split('==', $cond);
		$auth->{$field}->{'list'} = ''; # this is where we will store auth. records
		
		if($cond_user && $cond_tmp){
			push @{$auth->{$field}->{'conds'}}, { 'user' => $cond_user, 'tmp' => $cond_tmp };
		}
		push_dmesg(3, "auth item added to hash: $field");
	}
	# building submit fields authorization 
	
	foreach my $item (split(/,/, $iatoms->{$call->{'name'}}->{'authorize_submit_'.$USER->{'user_group'}}) ) {
		$item =~ s/\s//g;
		my ($field,$cond) = split(/#/, $item);
		my ($cond_user,$cond_tmp) = split('==', $cond);
		$auth_submit->{$field}->{'list'} = ''; # this is where we will store auth. records
		if ($cond_user && $cond_tmp) {
			push @{$auth_submit->{$field}->{'conds'}}, { 'user' => $cond_user, 'tmp' => $cond_tmp };
		}
		push_dmesg(3, "auth submit item added to hash: $field # $cond_user = $cond_tmp");
	}
}

sub build_straight_join_order_clause {
	my ($atom,$call,$key) = @_;
	
	my $order_key = $hin{'order_'.$call->{'name'}.'_'.$key};
	if(!$order_key){ $order_key = $hin{'s_order_'.$call->{'name'}.'_'.$key};}
# log_printf("\norder_key: $order_key\n");
# if(!$order_key){ return;}
	my $straight_join_approve = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_straight_join_approve'};
# log_printf("\napprove: $straight_join_approve\n");
	if($straight_join_approve != 1){ return;}
	my $tables_order = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_order_by_tables_order_'.$order_key};
	if(!$tables_order){
		$tables_order = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_order_by_tables_order_default'};
	}
	my $inner_join = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_inner_join_table'};
# log_printf("\ntables order: $tables_order\n");
	if(!$tables_order && $straight_join_approve){
		atom_util::push_error("Straight join approved but tables order isn't specified. ailib file is incorrect");
		return $call->{'_resource_'.$key};
	}
	my $resource_query = $iatoms->{$call->{'name'}}->{'_resource_'.$key};
	$resource_query =~ s/select(.*?)from(.*?)\b$tables_order\b(.*?)where(.*?)/select straight_join $1 from $2 $tables_order $call->{'call_params'}->{'inner_join'} $3 where $4/s;
#  log_printf("\nquery: $resource_query\n");
	$call->{'_resource_'.$key} = $resource_query;

	return;
}

sub build_order_clause {
	my ($atom,$call,$key) = @_;

	my $clause = '';
	
	my $dir = $hin{'order_'.$call->{'name'}.'_'.$key};
	my $mode = $hin{'s_order_'.$call->{'name'}.'_'.$key.'_mode'};
	if (!$mode) { $mode = 'A' }
	
	my $s_dir = $hin{'s_order_'.$call->{'name'}.'_'.$key};
	
	if (!$dir) {
		$dir = $s_dir; 
		if (!$dir) {
			# using default 
			$dir = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_def_order'};
			$mode = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_def_order_mode'};
		}
	}
	elsif ($dir eq $s_dir) {
		if ($mode eq 'A') { $mode = 'D' }
		elsif ($mode eq 'D') { $mode = 'A' }
	}
	
	$hout{'s_order_'.$call->{'name'}.'_'.$key.'_mode'} = $mode;
	$hout{'s_order_'.$call->{'name'}.'_'.$key} = $dir;
#!!!
	
	my @dirs 	= split(/,/, $dir);
	my @modes	= split(/,/, $mode);
	
	my $i = 0;
	
	while ($i <= $#dirs) {
		$dir 	= $dirs[$i];
		$mode = $modes[$i];
		$i++;
		my $field = $dir;
		
		if ($mode eq 'D') { $mode = 'desc'} else { $mode = 'asc' }
		
		if ($field) {
			my @mapping = split(/,/,$iatoms->{$call->{'name'}}->{'_mapping_'.$key}); 
			$iatoms->{$call->{'name'}}->{'_resource_'.$key} =~ /select(.*?)from/s;
			my $func = $1;
			$func=~ s/(\([^\(\)]*?\))//gs; #mercilessly remove everything inside brackeds
			$func=~ s/(\([^\(\)]*?\))//gs;
			$func=~ s/(\([^\(\)]*?\))//gs;

			my @func = split(/,/, $func);
			my %m = map { $mapping[$_] => $func[$_]} (0..$#mapping);
#			log_printf(Dumper(\%m));
#log_printf($field);
			$field = $m{$field};
#log_printf($field);
			$field =~s/.*\ as\ (.*)/$1/i; # processing alias constructions
			$clause .= $field.' '.$mode.',' if ($field);
		}
	}
	chop $clause;
	$clause = ' order by '.$clause; 
# log_printf("order clause: $clause");
	
	return $clause;
}

sub build_search_clause {
	my ($atom,$call,$key) = @_;

	my $clause = ' 1 ';
	my $product_name_clause = '';
	
	if($call->{'name'} ne $hin{'search_atom'} ||  $hin{'reset_search'}){
		
		#default search clause
		if($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_def_search'}){
			$clause = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_def_search'};
		}
		if($call->{'call_params'}->{'_resource_'.$key.'_def_search'}){ 
			$clause = $call->{'call_params'}->{'_resource_'.$key.'_def_search'};
		}
		
		return $clause;
	}
	
	$hout{'search_atom'} = $hin{'search_atom'}; 
	
	my $opened = 0; # brackets opened flag for custom
	my $bitwise_search = 0; #to run bitwise search once
	
	my @mapping = split(/,/,$iatoms->{$call->{'name'}}->{'_mapping_'.$key});
	$iatoms->{$call->{'name'}}->{'_resource_'.$key} =~m/\bselect\b(.*)\bfrom\b/is;
	my $func = $1;
	$func =~s/[\s\t]+/\ /g;
	$func=~ s/(\([^\(\)]*?\))//gs; #mercilessly remove everything inside brackeds
	$func=~ s/(\([^\(\)]*?\))//gs;
	$func=~ s/(\([^\(\)]*?\))//gs;
	my @func = split(/,/, $func);

	# additional parameters for searching (9.01.2008, dima, 1001326: Coverage VS Rating tool (different results))
	# (as in products_raiting: on_stock aren't contents in `select` query, so, it can be add separately into @func)

	if ($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_additional_search'}) {
		my $addfunc = $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_additional_search'};
#		undef $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_additional_search'};
		my @addfunc = split(/,/, $addfunc);
		push @func, @addfunc;
		push @mapping, @addfunc;
	}

	
	for(my $i = 0; $i <= $#func; $i++){
#	    log_printf("### = ".$func[$i]);
		my $prod_id_product_name = 0;
	if($func[$i]=~/^[\s]*as/i){
		$func[$i]=~s/^[\s]*as//i;
	}elsif($func[$i]=~/^[^\s]*[\s]*as/i){
		$func[$i]=~s/as.*$//i;
	}	
	$func[$i]=trim($func[$i]);	
    if($mapping[$i] eq 'catid'){
			if( $hin{'search_'.$mapping[$i]} ne '1' && $hin{'search_'.$mapping[$i]} ne '' ){

				# McAfee report bug (11.03.2010)
				if ($hin{'search_'.$mapping[$i]} !~ /^\d+$/s) {
					$clause .= ' and 0 ';
					next;
				}

				# saving for future sessions
				$hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
				my $rows = do_query("select catid, pcatid from category");
				my $cats_by_owner;
				
				foreach my $row(@$rows){
					my ($catid,$catownerid) = @{$row};
					push @{$cats_by_owner->{$catownerid}},$catid;
				}
				
				$clause .= ' and (0 '.traverse_only($hin{'search_'.$mapping[$i]},$func[$i],$cats_by_owner).' ) ';
				
			}
		} elsif($mapping[$i] eq 'date_added' && $hin{'search_adv'}){
# advanced search by date added
			$clause .=' and '.$func[$i].'>='.str_sqlize($hin{'search_from_year'}.'-'.$hin{'search_from_month'}.'-'.$hin{'search_from_day'});
			$clause .= ' and '.$func[$i].'<='.str_sqlize($hin{'search_to_year'}.'-'.$hin{'search_to_month'}.'-'.$hin{'search_to_day'});
			$clause .= 'and checked_by_supereditor=' . ($hin{'checked_by_supereditor'} ? '1' : '0');
			
		} 
# product_name and prod_id
		elsif (($mapping[$i] eq 'prod_id') || ($mapping[$i] eq 'product_name')) {
			if ($call->{'name'} ne 'products') {
				$product_name_clause .= ($hin{'search_'.$mapping[$i]} ? " or ".$func[$i]." like ".str_sqlize("%".$hin{'search_'.$mapping[$i]}."%") : ""); # restriction for products atom. it has custom prod_id + name searching mechanism
				$hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
			}
		}
		elsif ( ($mapping[$i] eq 'ucatid' || $mapping[$i] eq 'name') && $hin{'search_cat_search'} eq '1' ){
			if ($mapping[$i] eq 'ucatid') {
				$hin{'search_'.$mapping[$i]} = $hin{'search_name'};
			};
			# this commented line fix issue with browsing categories after searching (1020666)
			# $hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
			if($opened){
				$clause .= ' or '.$func[$i].' like '.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%').' ) ';
				
	    } else {
	      $clause .= ' and ( '.$func[$i].' like '.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%');
				$opened = 1;
			}
		}
		
		elsif(($iatoms->{$call->{'name'}}->{'_resource_'.$key.'_bitwise_search'} eq 'yes') && !$bitwise_search){
#bitwise search
			my $search_string = form_bit_strings($key, $iatoms->{$call->{'name'}}->{'_resource_'.$key.'_bitwise_field'});
			$clause .= ' and '.$search_string;
			$bitwise_search = 1; #to run once
		}
		elsif($mapping[$i] eq 'subject' || $mapping[$i] eq 'message'){
#complaints subject and message		
      if($mapping[$i] eq 'message'){$hin{'search_'.$mapping[$i]} = $hin{'search_subject'};}		
		  $hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
#			log_printf("\n\tclause=$clause 'search_'.$mapping[$i]=$hin{'search_'.$mapping[$i]}");
      if($opened){
				$clause .= ' or '.$func[$i].' like '.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%').' ) ';
			} else {
				$clause .= ' and ( '.$func[$i].' like '.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%');
				$opened = 1;
			}
#			log_printf("\n\tclause=$clause");
		}
		elsif (($mapping[$i] eq 'onstock') || ($mapping[$i] eq 'onmarket')) {
		  $hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
		}
		elsif ($hin{'search_'.$mapping[$i]}){
			# all standard fields
			
			# McAfee report bug (11.03.2010)
			if (($mapping[$i] =~ /\id$/s) && ($hin{'search_'.$mapping[$i]} !~ /^\d+$/s)) {
				$clause .= ' and 0 ';
				next;
			}

			# saving for future sessions
			$hout{'search_'.$mapping[$i]} = $hin{'search_'.$mapping[$i]};
			$hout{'search_'.$mapping[$i].'_mode'} = $hin{'search_'.$mapping[$i].'_mode'};
			 
			if($hin{'search_'.$mapping[$i].'_mode'} eq 'case_insensitive_like'){ 
				$clause .= ' and upper('.$func[$i].') like upper('.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%').')';
			}elsif($hin{'search_'.$mapping[$i].'_mode'} eq 'digit'){# this is a digit in this case value zero considered as 0 
				$clause .= ' and ('.$mapping[$i].' = '.(($hin{'search_'.$mapping[$i]} eq 'zero')?'0  )':$hin{'search_'.$mapping[$i]}.')').' ';	
			}elsif($hin{'search_'.$mapping[$i].'_mode'}=~/^[<>=]+$/i){
				 $clause .= ' and '.$func[$i].' '.$hin{'search_'.$mapping[$i].'_mode'}.' 
				 	'.(($hin{'search_'.$mapping[$i]}=~/^[\d\.]$/)?$hin{'search_'.$mapping[$i]}:str_sqlize($hin{'search_'.$mapping[$i]}));
			}else{
				if($hin{'search_'.$mapping[$i].'_mode'} ne 'like'){ 
				  $clause .= ' and '.$func[$i].' = '.str_sqlize($hin{'search_'.$mapping[$i]});
			  } else {
				  $clause .= ' and '.$func[$i].' like '.str_sqlize('%'.$hin{'search_'.$mapping[$i]}.'%');
				}
			}
		}
	}
	
# virtual categories
    
    # search with or without virtual categories tags
    my $is_vcats_search = $call->{'call_params'}->{'vcat_enable_all'};

    # get vcats from 'vcat_enable_list'
    my @vcats_set = ();
    my $vcount = 0;
    while ($call->{'call_params'}->{'vcat_enable_list'} =~ /_(\d+)_/g) {
        push @vcats_set, $1;
        $vcount++;
    }
    
    # update search clause
    if ($is_vcats_search) {
        my $vc_id;
        for ( my $i = 1 ; $i <= $vcount ; $i++ ) {
            $vc_id = $vcats_set[$i - 1];
            $clause .= ' AND product_id IN (SELECT product_id FROM virtual_category_product WHERE virtual_category_id = ' . $vc_id . ') ';
        }
    }

	$clause .= ($product_name_clause?" and (0 ".$product_name_clause.")":"");

#  log_printf("\n\tsearch clause = $clause\n");
#  log_printf("\n\thin = ".Dumper(\%hin)."\n");
#  log_printf("\n\thout = ".Dumper(\%hout)."\n");

	return $clause;
}

sub traverse_only {
	my ($catid,$fieldname,$cats_by_owner) = @_;
	my $tmp = " or $fieldname = $catid ";
	foreach my $subcatid (@{$cats_by_owner->{$catid}}) {
		$tmp .= traverse_only($subcatid,$fieldname);
	}
	return $tmp;
} # sub traverse_only (see above)

sub build_supplier_restrict_clause {  # for ratings only. need to be improved
   my $clause = " 1 ";

   if ($USER->{'user_group'} eq 'supplier') {
		 $clause = " s.supplier_id = ".do_query("SELECT supplier_id FROM supplier WHERE user_id = $USER->{'user_id'} LIMIT 1")->[0][0]." ";
   }
	 elsif (($USER->{'user_group'} eq 'guest')) { # it works, but rating page is closed for guest
		 $clause = " s.is_sponsor='Y'";
	 }

   return $clause;
}

1;

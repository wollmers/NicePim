package stat_report;

#$Id: stat_report.pm 3604 2010-12-21 01:11:39Z dima $

##
## TODO: generate_report_bg_processes - ignore by slave
##

use strict;

use atom_html;
use atomcfg;
use atomlog;
use atom_util;
use atom_misc;
use atomsql;
use icecat_util;
use atom_mail;
use Data::Dumper;
#use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);

use POSIX;

use vars qw($G_product_id);

#use stat_lib;
#use Time::HiRes 'time';
our $main_slave;
BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  
  @EXPORT = qw($main_slave
							 &generate_stat_report
							 &statistic_in_base
							 &statistic_from_base
							 &get_data
							 &get_query_env
							 &get_delta_time_stamp
							 &start_aggregate
							 &YYYYMM_range
							 &get_aggregated_request_stat_table_name
               &remove_ancient_request_repository_statistics

							 &csv2xls
							 &send_preformatted_reports_via_mail
							 &preparing_bg_table
							 &generate_graph_report
							 &returnRightDay
							 &create_gisto
							 &normalizeDataInterval
							 );
}

sub remove_ancient_request_repository_statistics {
	my ($last_date) = @_;

	return undef unless $last_date;

	my $ts = do_query("select unix_timestamp(".str_sqlize($last_date).")")->[0][0];
	my $cts = do_query("select unix_timestamp()")->[0][0];

	return undef unless $ts;

	if ($ts < $cts) {
		do_statement("delete from request_repository where date < ( ".$ts." - 60*60*24*30 )"); # a month safer
	}
}

sub get_aggregated_request_stat_table_name {
	return do_query("show tables like 'aggregated_request_stat\\_______'")->[0][0] || 'aggregated_request_stat';
} # sub get_aggregated_request_stat_table_name

sub preparing_bg_table {
	my $table_name = "generate_report_bg_processes";

	my $existed; # existed cols
	my $out;

	my $mandatory_set = { 'reload' => 1, 'mail_class_format' => 1, 'period' => 1, 'email' => 1, 'email_attachment_compression' => 1, 'code' => 1 };

	# fill existed
	my $cols = do_query("desc ".$table_name,$main_slave);
	for (@$cols) {
		next if ($_->[0] eq $table_name."_id"); # ignore id column
		next if ($_->[0] =~ /^bg\_/); # ignore static columns
		$existed->{$_->[0]} = 1;
	}

	# collect current ones
	for (sort {$a cmp $b} keys %hin) {
		if (($mandatory_set->{$_}) ||
				($_ =~ /^subtotal\_/) ||
				($_ =~ /^from\_/) ||
				($_ =~ /^to\_/) ||
				($_ =~ /^search\_/) ||
				($_ =~ /^request\_/) ||
				($_ =~ /^include\_/)) {
			$out->{$_} = 1;
			next if ($existed->{$_}); # next if column already exists
			do_statement("alter table ".$table_name." add column ".$_." varchar(255) NULL",$main_slave);
		}
	}

	$out->{'name'} = 1;
	unless ($existed->{'name'}) {
		do_statement("alter table ".$table_name." add column name varchar(60) NULL",$main_slave);
	}
	$out->{'class'} = 1;
	unless ($existed->{'class'}) {
		do_statement("alter table ".$table_name." add column class varchar(60) NULL",$main_slave);
	}
	return $out;
} # sub preparing_bg_table

sub generate_graph_report{
	my ($atom, $call) = @_;
	my $report;
	my $graph_path;
	log_printf("generate_graph_report");
	my $unshown_limit=32;
	my $graph_top_limit=50;
	my $graph_top_html_limit=100;
	$hin{'subtotal_2'}=''; $hin{'subtotal_3'}=''; # we dont pay an  attetion to 2st and 3rd level of grouping
	my $shops_count=do_query("SELECT COUNT(*) FROM users WHERE user_group='shop'")->[0][0];
	if ($hin{'reload'}) {
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating monthly graph)', bg_max_value=7, bg_current_value=0 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		my $from=eval('Time::Piece->strptime(\''.$hin{'from_year'}.'-'.$hin{'from_month'}.'-'.$hin{'from_day'}.'\',\'%Y-%m-%d\')');
		my $to=eval('Time::Piece->strptime(\''.$hin{'to_year'}.'-'.$hin{'to_month'}.'-'.$hin{'to_day'}.'\',\'%Y-%m-%d\')');
	    if(!$from or !$to){
	    	use Time::Piece;
	    	$hin{'period'}=3 if (!$hin{'period'} or $hin{'period'} eq '1');
	    	$to=return_currentTimePiece();
	    	$from=$to->add_months(-1);
	    };
		my $by_period=get_interval_by_period($hin{'period'});
		if($by_period){
			($hin{'from_year'},$hin{'from_month'},$hin{'from_day'})=@{$by_period->{'from'}};	
			($hin{'to_year'},$hin{'to_month'},$hin{'to_day'})=@{$by_period->{'to'}};
			$from=eval('Time::Piece->strptime(\''.$hin{'from_year'}.'-'.$hin{'from_month'}.'-'.$hin{'from_day'}.'\',\'%Y-%m-%d\')');
			$to=eval('Time::Piece->strptime(\''.$hin{'to_year'}.'-'.$hin{'to_month'}.'-'.$hin{'to_day'}.'\',\'%Y-%m-%d\')');	     			
		}
		my ($query_env,$data,$avgs_html,$graphs_html,@tops_html,$attachments);
		$attachments=[];
		my $xls_attachments=[];		
		#print Dumper(\%hin)
		my $interval_txt=$from->ymd()." - ".$to->ymd();
		
		if($hin{'include_top_supplier'}){
			$hin{'subtotal_1'}='1';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			log_printf("--------------->>>>>>>>>Top 20 Suppliers",1);
			get_data ($query_env);
			my $html_data=get_tops_html_data($query_env,$graph_top_html_limit,'Y','');
			#if(scalar(@$html_data)<$graph_top_html_limit){
				push(@tops_html,create_top_html($html_data,"Top $graph_top_html_limit brands",['Name','Data-sheet Downloads'],'brand'));
			#}else{
			#	push(@tops_html,create_top_html([],"List is too big to be displayed. Please see in attachement",['top_suppliers.xls']));
			#	$html_data=get_tops_html_data($query_env,'','Y','Y','avoid html');
			#	my $xls=write_to_xls($html_data,'Supplier',['Supplier','Is sponsor','Download count']);
			#	push(@$xls_attachments,{'mime'=>$xls,'name'=>'top_suppliers.xls'});
			#}
			
			my $gisto_data=get_tops_gisto_data($query_env,$graph_top_limit,'order by cnt','1','add summary bar');
			$graph_path=create_gisto($gisto_data->{'axis'},'Brand',10,"Top $graph_top_limit Brands",$gisto_data->{'x_axis_style'},1);			
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Top $graph_top_limit Brands",$graph_path,$shops_count);				
			$graphs_html.='<div style="font-size: 8pt">
									<div>The following drivers determine the positioning of a brand:</div>
									<ul style="list-style-type: square">
									 <li>Stock in the channel (distribution model)</li>
									 <li>The popularity of individual products</li>
									 <li>Presence in free Open ICEcat</li>
									 <li>Automated cross-sell and up-sell relations via Open ICEcat</li>
									 <li>Promotion and online visibility</li>
									 <li>International presence</li>
									 <li>Activation of brand-specific channel partners</li>
									</ul>
									</div>';		
			clean_temporary_tables();
		}
		
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating weekly graph)', bg_max_value=7, bg_current_value=1 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		
		if($hin{'include_top_product'}){
			$hin{'subtotal_1'}='5';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			log_printf("--------------->>>>>>>>>Top 20 products");
			get_data ($query_env);
			my $html_data=get_tops_html_data($query_env,'','Y','Y');
			
			if(scalar(@$html_data)<$graph_top_html_limit){
				push(@tops_html,create_top_html($html_data,"Top $graph_top_html_limit Products",['Part code','Name','Supplier','Data-sheet Downloads'],'product'));
			}else{
				my @tmp_arr=@$html_data[0..$graph_top_html_limit];
				push(@tops_html,create_top_html(\@tmp_arr,"Only top $graph_top_html_limit are shown.<br/>See the attachment top_products.xls",['Part code','Name','Supplier','Data-sheet Downloads'],'product'));
				$html_data=get_tops_html_data($query_env,'','Y','Y','avoid html');
				my $xls=write_to_xls($html_data,'Products',['Partcode','Name','Supplier','Is sposor','Download count']);
				push(@$xls_attachments,{'mime'=>$xls,'name'=>'top_product.xls'});
			}
			
			my $gisto_data=get_tops_gisto_data($query_env,$graph_top_limit,'order by cnt','1','');
			$graph_path=create_gisto($gisto_data->{'axis'},'Product',10,"Top $graph_top_limit products",$gisto_data->{'x_axis_style'},1);			
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Top $graph_top_limit products",$graph_path,$shops_count);				
			
			clean_temporary_tables();
		}
		
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating weekly graph)', bg_max_value=7, bg_current_value=2 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		
		if($hin{'include_top_cats'}){
			$hin{'subtotal_1'}='2';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			log_printf("--------------->>>>>>>>>Top 20 Categories");
			get_data ($query_env);
			my $html_data=get_tops_html_data($query_env,$graph_top_html_limit,'Y','');
			 
			#if(scalar(@$html_data)<$graph_top_html_limit){			
				push(@tops_html,create_top_html($html_data,"Top $graph_top_html_limit categories",['Name','Data-sheet Downloads'],'category'));
			#}else{
			#	push(@tops_html,create_top_html([],"List is too big to be displayed. Please see in attachement",['top_categories.xls']));
			#	$html_data=get_tops_html_data($query_env,'','Y','','');
			#	my $xls=write_to_xls($html_data,'Categories',['Category','Download count']);
			#	push(@$xls_attachments,{'mime'=>$xls,'name'=>'top_categories.xls'});
			#}
			
			my $gisto_data=get_tops_gisto_data($query_env,$graph_top_limit,'order by cnt','','add summary bar');
			$graph_path=create_gisto($gisto_data->{'axis'},'Category',10,"Top $graph_top_limit categories",'',1);			
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Top $graph_top_limit categories",$graph_path,$shops_count);				
			
					
			clean_temporary_tables();
		}
		
		if($hin{'include_top_owner'}){
			$hin{'subtotal_1'}='3';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			log_printf("--------------->>>>>>>>>Top 20 Product's editors");
			get_data ($query_env);
			my $html_data=get_tops_html_data($query_env,'','Y','');
			if(scalar(@$html_data)<$graph_top_html_limit){
				push(@tops_html,create_top_html($html_data,"Top $graph_top_html_limit Product\'s owners",['Name','Data-sheet Downloads']));
			}else{
				push(@tops_html,create_top_html([],"Top editors list is too big to be displayed. Please see the attachement",['top_editors.xls']));
				$html_data=get_tops_html_data($query_env,'','Y','','');
				my $xls=write_to_xls($html_data,'Editors',['Editors','Download count']);
				push(@$xls_attachments,{'mime'=>$xls,'name'=>'top_editors.xls'});
			}
			
			my $gisto_data=get_tops_gisto_data($query_env,$graph_top_limit,'order by cnt','','add summary bar');
			$graph_path=create_gisto($gisto_data->{'axis'},'Product\'s owner',10,"Top $graph_top_limit Product\'s owners",$gisto_data->{'x_axis_style'},1);			
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Top $graph_top_limit Product\'s owners",$graph_path,$shops_count);				
					
			clean_temporary_tables();
		}
		
		if($hin{'include_top_request_country'}){
			$hin{'subtotal_1'}='10';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			log_printf("--------------->>>>>>>>>Top 20 Request owner countries");
			get_data ($query_env);
			my $html_data=get_tops_html_data($query_env,$graph_top_html_limit,'Y','');
			#if(scalar(@$html_data)<$graph_top_html_limit){
				push(@tops_html,create_top_html($html_data,"Top $graph_top_html_limit Download countries",['Country','Data-sheet Downloads']));
			#}else{
			#	push(@tops_html,create_top_html([],"List is too big to be displayed. Please see in attachement",['top_editors.xls']));
			#	$html_data=get_tops_html_data($query_env,'','Y','','');
			#	my $xls=write_to_xls($html_data,'Countries',['Editors','Download count']);
			#	push(@$xls_attachments,{'mime'=>$xls,'name'=>'top_countries.xls'});
			#}
			
			my $gisto_data=get_tops_gisto_data($query_env,$graph_top_limit,'order by cnt','','add summary bar');
			$graph_path=create_gisto($gisto_data->{'axis'},'Download country',10,"Top $graph_top_limit Download countries",$gisto_data->{'x_axis_style'},1);			
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Top $graph_top_limit  Download countries",$graph_path,$shops_count);				
					
			clean_temporary_tables();
		}
				
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating top products)', bg_max_value=7, bg_current_value=3 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		
		#month		
		if((($to-$from)/(31*24*3600))<=1){
			
		}elsif((($to-$from)/(30*24*3600))<=$unshown_limit){
			$hin{'subtotal_1'}='7';			
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			get_data ($query_env);
			$data=get_gisto_data($query_env,55,$unshown_limit,'','%m');
			$avgs_html.=get_average_html('month','Monthly Data-sheet Downloads ');
			$data=normalizeDataInterval($hin{'from_year'},$hin{'from_month'},$hin{'from_day'},$hin{'to_year'},$hin{'to_month'},$hin{'to_day'},$data,'%m','month');
			$graph_path=create_gisto($data,'month',10,'','');
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Monthly Data-sheet Downloads ".$interval_txt,$graph_path,$shops_count);				
			log_printf("--------------->>>>>>>>>Month graph ".$graph_path);
			clean_temporary_tables();
		}else{
			log_printf("Monthly graph will not be displayed: to much bars");
			$graph_path=create_gisto([[0],[0]],'month',10,'','');
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Monthly Data-sheet Downloads graph. Gistogram is too big. Please, reduce the range. ".$interval_txt,$graph_path,$shops_count);						
		}
		
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating top categories)', bg_max_value=7, bg_current_value=4 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}				
		
		# weeks
		if((($to-$from)/(7*24*3600))<=1){
			
		}elsif((($to-$from)/(7*24*3600))<=$unshown_limit){
			$hin{'subtotal_1'}='6';
			$query_env = get_query_env('omit changing into table generate_report_bg_processes');
			get_data ($query_env,);			
			$data=get_gisto_data($query_env,55,$unshown_limit,'','%U');
			$avgs_html.=get_average_html('week','Average Number of Data-sheet Downloads per Week');
			$data=normalizeDataInterval($hin{'from_year'},$hin{'from_month'},$hin{'from_day'},$hin{'to_year'},$hin{'to_month'},$hin{'to_day'},$data,'%U','week');
			$graph_path=create_gisto($data,'week',10,'','');
			push(@$attachments,$graph_path);		
			$graphs_html.=get_gisto_html_image("Weekly Data-sheet Downloads graph ".$interval_txt,$graph_path,$shops_count);				
			log_printf("--------------->>>>>>>>>week graph ".$graph_path);
			clean_temporary_tables();		
		}else{
			log_printf("Weekly graph will not be displayed: to much bars");
			$graph_path=create_gisto([[0],[0]],'week',10,'','');
			push(@$attachments,$graph_path); 		
			$graphs_html.=get_gisto_html_image("Weekly Data-sheet Downloads graph. Gistogram is too big. Please, reduce the range. ".$interval_txt,$graph_path,$shops_count);			
		}
		
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating top brands)', bg_max_value=7, bg_current_value=5 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}				
		
		#days		
		#if((($to-$from)/(24*3600))<=$unshown_limit){	
		#	$hin{'subtotal_1'}='111';
		#	$query_env = get_query_env('omit changing into table generate_report_bg_processes');
		#	get_data ($query_env);
		#	$data=get_gisto_data($query_env,55,$unshown_limit,'','%d');
		#	$avgs_html.=get_average_html('day','Data-sheet Downloads by day ');
		#	$data=normalizeDataInterval($hin{'from_year'},$hin{'from_month'},$hin{'from_day'},$hin{'to_year'},$hin{'to_month'},$hin{'to_day'},$data,'%d','day');
		#	$graph_path=create_gisto($data,'day',10,'','');
		#	push(@$attachments,$graph_path);		
		#	$graphs_html.=get_gisto_html_image("Daily Data-sheet Downloads graph ".$interval_txt,$graph_path,$shops_count);				
		#	log_printf("--------------->>>>>>>>>Daily graph ".$graph_path);
		#	clean_temporary_tables();		
		#}else{
			#log_printf("Daily graph will not be displayed: to much bars");
			#$graph_path=create_gisto([[0],[0]],'day',10,'','');
			#push(@$attachments,$graph_path);		
			#$graphs_html.=get_gisto_html_image("Daily Data-sheet Downloads graph. Gistogram is too big. Please, reduce the range. ".$interval_txt,$graph_path,$shops_count);			
		#}
		
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating top editors)', bg_max_value=7, bg_current_value=6 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}					


		my $report_text=get_full_report($avgs_html,$graphs_html,\@tops_html,"Report on ".$hin{'code'});
		open(TMP,'>/tmp/test.html');
		print TMP $report_text;
		close(TMP);
		
		log_printf('get_report end');
		push(@$attachments,$atomcfg{'www_path'}.'img/'.'trans_logo.gif');
		my $hash;
		$hash->{'images'}=$attachments;
		$hash->{'xls'}=$xls_attachments;
		return [$report_text,"Report on ".$hin{'code'}.' from '.$from->ymd().' to '.$to->ymd(),$hash];
	} 
	
	log_printf("generate_graph_report end");
	return 1;
}
 
sub generate_stat_report {
	my ($atom, $call,$doIncludeGraph) = @_;
	my $tmp = '';
	my $report;
	my $start = time;
	my $graph_path;
	log_printf("generate_stat_report");
	if ($hin{'reload'}) {
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (preparing temporary tables)', bg_max_value=5, bg_current_value=0 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		my $query_env = get_query_env();
		log_printf('get_data');
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (generating the report)', bg_max_value=5, bg_current_value=4 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		get_data ($query_env);
		log_printf('get_report');
		$report = get_report($query_env, $atom);
		log_printf('get_report end');		
		$tmp = $report->[0];		
	}
	clean_temporary_tables();
	log_printf("generate_stat_report end");
	return [ $tmp, $report->[1], $graph_path];
} # sub generate_stat_report

sub clean_temporary_tables {
	do_statement("drop temporary table if exists itmp_aggregated_request_stat_select");
	do_statement("drop temporary table if exists itmp_aggr_products");
	do_statement("drop temporary table if exists itmp_aggr_temp");
	do_statement("drop temporary table if exists itmp_users_selection");
	do_statement("drop temporary table if exists itmp_aggregated_request_stat");

}

sub get_query_env {
	my ($dont_change_bg)=@_;
	log_printf("get_query_env");

#	log_printf(Dumper(\@_));

	my $env = {};
	my $subtotal;
	my @array_of_subtotal;

	# NEW!!! PIV report added! (Martijn's wish)
	if ($hin{'mail_class_format'} eq 'PIV' || $hin{'mail_class_format'} eq 'PSV') { # custom Philips-style XML report format forming
		$hin{'subtotal_1'} = '5'; # product code
		$hin{'subtotal_2'} = '9'; # year
		$hin{'subtotal_3'} = '7'; # month
		$hin{'subtotal_4'} = '10'; # request owner country
		$hin{'subtotal_5'} = '11'; # URL_XML
	}

	for my $step (1..5) {
		if ($hin{'subtotal_'.$step}) {
			push @array_of_subtotal, $hin{'subtotal_'.$step};
		}
	} 
	
	my $number_of_subtotal = 1;
	for my $subtotal_value (@array_of_subtotal) {
		$subtotal->{$number_of_subtotal} = $subtotal_value;
		$number_of_subtotal ++;
	}

	for my $step (1..5) {
		if (exists($subtotal->{$step}) && defined($subtotal->{$step})) {
			$hin{'subtotal_'.$step} = $subtotal->{$step};
		}
		else {
			$hin{'subtotal_'.$step} = 0;
		}
	}

	if (!$subtotal->{'1'} && !$subtotal->{'2'} && !$subtotal->{'3'} && !$subtotal->{'4'} && !$subtotal->{'5'}) {
		$subtotal->{'1'} = '5';
		$hin{'subtotal_1'} = 5;
	}

	# log_printf ('Sub'.Dumper ( $subtotal ) );
	my $from;
	my $to;
	my $clause = '';

	# processing time restrictions

	# to date
	if ($hin{'to_year'}) {
		$to = $hin{'to_year'}.'-';
		if (!$hin{'to_month'}) {
			$hin{'to_month'} = '12';
		}
		if (!$hin{'to_day'}) {
			$hin{'to_day'} = '31';
		}
		$to .= $hin{'to_month'}.'-'.$hin{'to_day'};
	}

	# from date
	if ($hin{'from_year'}) {
		$from = $hin{'from_year'}.'-';
		if (!$hin{'from_month'}) {
			$hin{'from_month'} = '01';
		}
		if (!$hin{'from_day'}) {
			$hin{'from_day'} = '01';
		}
		$from .= $hin{'from_month'}.'-'.$hin{'from_day'};
	}
 
	$env->{'period'} = 'Custom date';

	# choose the correct start dates, if the period is chosen
	if ($hin{'period'} > 1) {
		# the period is given
		use POSIX qw (strftime);
		if ($hin{'period'} == 2 ) {
			# last week from appointed
			my $t = do_query('SELECT unix_timestamp()')->[0][0];			
			$t -= 7*24*60*60;
			my $week_scope=get_week_scope($t);
			$from = strftime("%Y-%m-%d", localtime($week_scope->{'from'}));
			$to = strftime("%Y-%m-%d", localtime($week_scope->{'to'}));
			$env->{'period'} = 'Last week';
		}
		if ($hin{'period'} == 3 ) {
			# last month from appointed
			my $t = do_query("select date_sub(".str_sqlize($to).", interval 1 month)")->[0][0];
			$from = $t;
			$env->{'period'} = 'Last month';
		}
		if ($hin{'period'} == 4 ) {
			# last quarter from appointed
			my $t = do_query("select date_sub(".str_sqlize($to).", interval 4 month)")->[0][0];
			$from = $t;
			$env->{'period'} = 'Last quarter';
		}
		if ($hin{'period'} == 5) {
			# last day appointed
			my $t = do_query("select unix_timestamp(".str_sqlize($to).")")->[0][0];
			$t -= 24*60*60; 
			$to = strftime("%Y-%m-%d", localtime($t));		
			$from = strftime("%Y-%m-%d", localtime($t));		
			$env->{'period'} = 'Last day';
		}
	}


	# make clause

  my $product_clause = '';
  my $product_join_clause = '';
	my $single_product_only = 0;
	my $single_product_only_where = ' and 1';
	my $extra_product_select = '';
  my $select_clause_from = '';
  my $select_clause_from_YYYY = 0;
  my $select_clause_from_MM = 0;
  my $select_clause_to = '';
  my $select_clause_to_YYYY = 0;
  my $select_clause_to_MM = 0;
	
	if ($hin{'search_supplier_id'}) {
		$product_clause .= " and p.supplier_id = ".str_sqlize($hin{'search_supplier_id'});
	}
	if ($hin{'search_catid'}&&$hin{'search_catid'} != 1) {
		$product_clause .= " and p.catid = ".str_sqlize($hin{'search_catid'});
	}
	if ($hin{'search_edit_user_id'}) {
		$product_clause .= " and p.user_id = ".str_sqlize($hin{'search_edit_user_id'});
	}
	if ($hin{'search_prod_id'}) {
		$single_product_only = 1;
		$product_clause .= " and p.prod_id = ".str_sqlize($hin{'search_prod_id'});
		my $desired_product_id = do_query("select product_id from product where prod_id=".str_sqlize($hin{'search_prod_id'}))->[0][0] || 0;
		$single_product_only_where = ' and ' . ( $desired_product_id ? "ag.product_id = " . $desired_product_id : '0' );
	}
	if ($hin{'request_user_id'}) {
		$clause .= " and arss.user_id = ".$hin{'request_user_id'};
	}
	if ($to) {
		my $delta_time_stamp = get_delta_time_stamp($to);
		my $unix_to = do_query("select unix_timestamp(".str_sqlize($to).") + $delta_time_stamp - 1")->[0][0];
		$select_clause_to = " and ag.date < ".$unix_to;
		$select_clause_to_YYYY = strftime ("%Y", localtime($unix_to));
		$select_clause_to_MM = strftime ("%m", localtime($unix_to));
	}

	if ($from) {
		my $unix_from = do_query("select unix_timestamp(".str_sqlize($from).")")->[0][0];
		$select_clause_from = " and ag.date >= ".$unix_from;
		$select_clause_from_YYYY = strftime ("%Y", localtime($unix_from));
		$select_clause_from_MM = strftime ("%m", localtime($unix_from));
	}

	# correct from_YYYY with to_YYYY (17.07.2010)
	if (($select_clause_to_YYYY - $select_clause_from_YYYY) > 2) {
		$select_clause_from_YYYY = $select_clause_to_YYYY - 2;
	}

	# 8. additional tables for request_partner_id
	if ($hin{'request_partner_id'} || $subtotal->{'1'} == 8 || $subtotal->{'2'} == 8 || $subtotal->{'3'} == 8 || $subtotal->{'4'} == 8 || $subtotal->{'5'} == 8) {
		$extra_product_select	.= " inner join itmp_users_selection on itmp_users_selection.user_id = ag.user_id ";
		
		my $my_request_partner_id;
		if ($hin{'request_partner_id'}) {
			$my_request_partner_id = " user_partner_id = ".str_sqlize($hin{'request_partner_id'});
		}
		else {
			$my_request_partner_id = " user_group = 'shop' ";
		}
		do_statement("create temporary table itmp_users_selection (user_id int(13) not null primary key, user_partner_id int(13) not null, key (user_partner_id, user_id))");
		do_statement("insert into itmp_users_selection(user_id,user_partner_id) select user_id, user_partner_id from users where ".$my_request_partner_id);
	}

	# 10. additional tables for request_country_id
	if ($hin{'request_country_id'} || $subtotal->{'1'} == 10 || $subtotal->{'2'} == 10 || $subtotal->{'3'} == 10 || $subtotal->{'4'} == 10 || $subtotal->{'5'} == 10) {
		$extra_product_select	.= " inner join itmp_users_country_selection on itmp_users_country_selection.user_id = ag.user_id ";
#		$extra_product_select	.= " left join itmp_users_country_selection on itmp_users_country_selection.user_id = ag.user_id ";
		
		my $my_request_country_id;
		if ($hin{'request_country_id'}) {
			$my_request_country_id = " user_group = 'shop' and country_id = ".str_sqlize($hin{'request_country_id'});
		}
		else {
			$my_request_country_id = " user_group = 'shop' ";
		}
		do_statement("drop temporary table if exists itmp_users_country_selection");
		do_statement("create temporary table itmp_users_country_selection (user_id int(13) not null primary key, user_country_id int(13) not null, key (user_country_id, user_id))");
		do_statement("insert into itmp_users_country_selection(user_id,user_country_id) select user_id, country_id from users u inner join contact c on u.pers_cid=c.contact_id where ".$my_request_country_id);
	}

	# 11. additional tables for url_xml
	if ($subtotal->{'1'} == 11 || $subtotal->{'2'} == 11 || $subtotal->{'3'} == 11 || $subtotal->{'4'} == 11 || $subtotal->{'5'} == 11) {
		$extra_product_select	.= " inner join itmp_users_url_xml on itmp_users_url_xml.user_id = ag.user_id ";
#		$extra_product_select	.= " left join itmp_users_url_xml on itmp_users_url_xml.user_id = ag.user_id ";
		
		do_statement("drop temporary table if exists itmp_users_url_xml");
		do_statement("create temporary table itmp_users_url_xml (user_id int(13) not null primary key, url_xml char(3) not null, key (user_id, url_xml), key (url_xml))");
		do_statement("insert into itmp_users_url_xml(user_id,url_xml) select user_id, if(subscription_level in (1,2,6),'url','xml') from users where subscription_level in (1,2,4) and user_group = 'shop'");
		do_statement("update itmp_users_url_xml set url_xml='url' where user_id=(select user_id from users where login='_multiprf')");
	}

	# additional tables for product_country_id
	my $IJ_product_country = 0;
	if ($hin{'search_product_country_id'}) {
		$IJ_product_country = 1;
		$extra_product_select	.= " inner join itmp_country_selection on itmp_country_selection.product_id = ag.product_id";
		
		do_statement("drop temporary table if exists itmp_country_selection");
		do_statement("create temporary table itmp_country_selection(product_id int(13) not null default 0, p_country_id int(13) not null default 0, key (product_id, p_country_id), key (p_country_id))");
		do_statement("alter table itmp_country_selection disable keys");
		do_statement("insert into itmp_country_selection(product_id, p_country_id) select product_id, country_id from country_product where 1 " . ( $hin{'search_product_country_id'} ? "and country_id = ".$hin{'search_product_country_id'} : "" ) );
		do_statement("alter table itmp_country_selection enable keys");
	}

	# additional tables for product_distributor_id
	if ($hin{'search_product_distributor_id'}) {
		$extra_product_select	.= " inner join itmp_distributor_selection on itmp_distributor_selection.product_id = ag.product_id"
			. ( $IJ_product_country ? " and itmp_distributor_selection.p2_country_id=itmp_country_selection.p_country_id" : '');
		
		do_statement("drop temporary table if exists itmp_distributor_selection");
		do_statement("create temporary table itmp_distributor_selection(
product_id int(13) not null default 0,
p2_country_id int(13) not null default 0,
p_distributor_id int(13) not null default 0,
key (product_id, p_distributor_id),
key (p_distributor_id),
key (p2_country_id, p_distributor_id))");
		do_statement("alter table itmp_distributor_selection disable keys");
		do_statement("insert into itmp_distributor_selection(product_id, p2_country_id, p_distributor_id)
select dp.product_id, d.country_id, distributor_id
from distributor_product dp
inner join distributor d using (distributor_id)
where 1 " . ( $hin{'search_product_distributor_id'} ? "and dp.distributor_id = ".$hin{'search_product_distributor_id'} . ( $hin{'search_product_country_id'} ? " and d.country_id = ".$hin{'search_product_country_id'} : "" ) : "" ) );
		do_statement("alter table itmp_distributor_selection enable keys");
	}	

	# additional tables for product_onstock
	if ($hin{'search_product_onstock'}) {
		$extra_product_select	.= " inner join itmp_onstock_selection on itmp_onstock_selection.product_id=ag.product_id";
		
		do_statement("drop temporary table if exists itmp_onstock_selection");
		do_statement("create temporary table itmp_onstock_selection(product_id int(13) not null default 0, key (product_id))");
		do_statement("alter table itmp_onstock_selection disable keys");
		do_statement("insert into itmp_onstock_selection(product_id) select distinct product_id from product_active where active = 1 and stock > 0");
		do_statement("alter table itmp_onstock_selection enable keys");
	}

	# additional tables for product_onstock
	if ($hin{'search_supplier_type'}) {
		if (($hin{'search_supplier_type'} eq 'Y') || ($hin{'search_supplier_type'} eq 'N')) {
			$product_join_clause .= " inner join supplier s2 on p.supplier_id=s2.supplier_id and s2.is_sponsor='".$hin{'search_supplier_type'}."' ";
		}
	}
	
	my $base_map = {
		'1' => 'supplier_id',
		'2' => 'catid',
		'3' => 'product_user_id',
		'4' => 'request_user_id',
		'5' => 'product_id',
		'6' => 'week',
		'7' => 'month',
		'8' => 'request_partner_id',
		'9' => 'year',
		'10' => 'request_country_id',
		'11' => 'url_xml',
		'111' => 'day',

		'999' => 'request_product_id'
	};

	my $fields = {};
	my $levels = {};
	my $dictionary = {};
	my $extra_fs = '';
	my $extra_fs_select = '';

	for my $sbtl ('1','2','3','4','5') {
		if ($subtotal->{$sbtl} == 1) {
			#	Subtotal = supplier
			$fields->{'arss.p_supplier_id'} = 'supplier_id';
			$levels->{$sbtl} = 'arss.p_supplier_id';
			$dictionary->{$sbtl}->{'field'} = ',s.name';
			$dictionary->{$sbtl}->{'join'} = 'inner join supplier s using (supplier_id)';
		}
		elsif ($subtotal->{$sbtl} == 2) {
			#	Subtotal = category
			$fields->{'arss.p_catid'} = 'catid';
			$levels->{$sbtl} = 'arss.p_catid';
			$dictionary->{$sbtl}->{'field'} = ",v.value";

			$dictionary->{$sbtl}->{'join'} = "inner join category c using (catid) inner join vocabulary v on c.sid = v.sid and v.langid = ".$hl{'langid'};
		}
		elsif ($subtotal->{$sbtl} == 3) {
			#	Subtotal = product owner
			$fields->{'arss.p_user_id'} = 'product_user_id';
			$levels->{$sbtl} = 'arss.p_user_id';
			$dictionary->{$sbtl}->{'field'} = ',u.login';
			$dictionary->{$sbtl}->{'join'} = 'inner join users u on product_user_id=u.user_id';
		}
		elsif ($subtotal->{$sbtl} == 4) {
			#	Subtotal = request owner
			$fields->{'arss.user_id'} = 'request_user_id';
			$levels->{$sbtl} = 'arss.user_id';
			$dictionary->{$sbtl}->{'field'} = ',u.login';
			$dictionary->{$sbtl}->{'join'} = 'inner join users u on request_user_id=u.user_id';
		}
		elsif ($subtotal->{$sbtl} == 8) {
			# Subtotal = request owner's partner
			$fields->{'arss.user_partner_id'} = 'request_partner_id';
			$levels->{$sbtl} = 'arss.user_partner_id';
			$extra_fs .= ', user_partner_id int(10) not null ';
			$extra_fs_select .= ', user_partner_id ';
			$dictionary->{$sbtl}->{'field'} = ',u.login';
			$dictionary->{$sbtl}->{'join'} = 'inner join users u on request_partner_id=u.user_id';
		}
		elsif ($subtotal->{$sbtl} == 10) {
			# Subtotal = request owner's country
			$fields->{'arss.user_country_id'} = 'request_country_id';
			$levels->{$sbtl} = 'arss.user_country_id';
			$extra_fs .= ', user_country_id int(13) not null ';
			$extra_fs_select .= ', user_country_id ';
			$dictionary->{$sbtl}->{'field'} = ',v.value';
			$dictionary->{$sbtl}->{'join'} = 'inner join country c on request_country_id = c.country_id inner join vocabulary v on c.sid = v.sid and v.langid = '.$hl{'langid'};
		}
		elsif ($subtotal->{$sbtl} == 11) {
			# Subtotal = url_xml
			$fields->{'arss.url_xml'} = 'url_xml';
			$levels->{$sbtl} = 'arss.url_xml';
			$extra_fs .= ', url_xml char(3) not null ';
			$extra_fs_select .= ', url_xml ';
		}
		elsif ($subtotal->{$sbtl} == 5) {
			#	Subtotal = product code
			$fields->{'arss.product_id'} = 'product_id';
			$levels->{$sbtl} = 'arss.product_id';
			$dictionary->{$sbtl}->{'field'} = ',p.prod_id,p.name'; 
			$dictionary->{$sbtl}->{'join'} = 'inner join itmp_aggr_temp p using(product_id)'; 
		}
		elsif ($subtotal->{$sbtl} == 6) {
			#	Subtotal = week
			$fields->{'arss.datew'} = 'week';
			$levels->{$sbtl} = 'arss.datew';
		}
		elsif ($subtotal->{$sbtl} == 7) {
			#	Subtotal = month
			$fields->{'arss.datem'} = 'month';
			$levels->{$sbtl} = 'arss.datem';
		}
		elsif ($subtotal->{$sbtl} == 9) {
			#	Subtotal = year
			$fields->{'arss.datey'} = 'year';
			$levels->{$sbtl} = 'arss.datey';
		}
		elsif ($subtotal->{$sbtl} == 111) {
			#	Subtotal = day
			$fields->{'arss.date_d'} = 'day';
			$levels->{$sbtl} = 'arss.date_d';
		}
	}
	
	my $fields_str = join(',', keys %$fields);
	my @fields_arr = split (',', $fields_str);
	my %field_number = map { $fields_arr[$_] => $_ } (0..$#fields_arr);

	# create and fill statistics selection
	do_statement("create temporary table itmp_aggregated_request_stat_select (
product_id int(13) not null,
datew      int(19) not null,
datem      int(19) not null,
datey      int(19) not null,
date_d     int(19) not null,
count      int(7) not null,
user_id    int(13) not null

".$extra_fs.",

p_catid       int(13) not null,
p_supplier_id int(13) not null,
p_user_id     int(13) not null,
p_prod_id     varchar(235) not null,
p_name varchar(255),

key (product_id),
key (p_supplier_id),
key (p_catid),
key (user_id))");
	
	if ($hin{'ajax_bg_process'} and !$dont_change_bg) { # AJAX
		do_statement("update generate_report_bg_processes
set bg_current_value=1
where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}

	# itmp_product
	do_statement("drop temporary table if exists itmp_product");

	do_statement("create temporary table itmp_product (
`product_id`  int(13)      NOT NULL primary key,
`supplier_id` int(13)      NOT NULL default '0',
`prod_id`     varchar(235) NOT NULL default '',
`catid`       int(13)      NOT NULL default '0',
`user_id`     int(13)      NOT NULL default '0',
`name`        varchar(255) NOT NULL default '',

key (supplier_id),
key (catid,supplier_id),
key (user_id,catid,supplier_id),
key (prod_id))");

	# collect all products
	do_statement("alter table itmp_product disable keys");
  my @arr = get_primary_key_set_of_ranges('p','product',100000,'product_id');
	@arr = ('1') if $product_clause;
	my $collect_request_products;
	for my $b_cond (@arr) {
		$collect_request_products = "select p.product_id,p.supplier_id,p.prod_id,p.catid,p.user_id,p.name
from product p ".$product_join_clause." where 1 ".$product_clause." and ".$b_cond;
		log_printf(do_query_dump("explain ".$collect_request_products));

		do_statement("insert into itmp_product(product_id,supplier_id,prod_id,catid,user_id,name) ".$collect_request_products);
	}
	do_statement("alter table itmp_product enable keys");

	# fullfill statistics selection
	#my $aggregation_table_name = 'aggregated_request_stat';
#	if (($select_clause_from) || ($select_clause_to)) {

	do_statement("drop temporary table if exists itmp_aggregated_request_stat_timeslice");
	do_statement("create temporary table itmp_aggregated_request_stat_timeslice like " . get_aggregated_request_stat_table_name);
	do_statement("alter table itmp_aggregated_request_stat_timeslice modify column id int(13) not null default 0, drop primary key");

	do_statement("alter table itmp_aggregated_request_stat_timeslice disable keys");
	
	my $range = YYYYMM_range($select_clause_from_YYYY, $select_clause_from_MM, $select_clause_to_YYYY, $select_clause_to_MM);
	my ($collect_force_index, $collect_join, $collect_request);
	for my $yyyymm (@$range) {
		if (do_query("show tables like 'aggregated\\_request\\_stat\\_".$yyyymm->[0].$yyyymm->[1]."'")->[0][0]) {

			# complete join
			$collect_join = (!$single_product_only && ($product_clause || $product_join_clause)) ? ' inner join itmp_product p using (product_id) ' : '';

			# complete force index
			$collect_force_index = $collect_join ? '' : "force index(" . ( ( $single_product_only ) ? 'product_id_' : '' ) . "date)";

			# complete request
			$collect_request = "select ag.* from aggregated_request_stat_" . $yyyymm->[0] . $yyyymm->[1] . " ag " . $collect_force_index . $collect_join . $extra_product_select . "
where 1 " . ( $yyyymm->[4] ? $select_clause_from : '' ) . " " . ( $yyyymm->[5] ? $select_clause_to : '' ) . " " . $single_product_only_where;

#			log_printf("explain ".$collect_request);
			log_printf(do_query_dump("explain ".$collect_request));
			do_statement("insert into itmp_aggregated_request_stat_timeslice ".$collect_request);
		}
	}		

	do_statement("alter table itmp_aggregated_request_stat_timeslice enable keys");
	
	my $aggregation_table_name = 'itmp_aggregated_request_stat_timeslice';
#	}
#	else {
#		# a nonsense!.. we can block it in BO & logics. from & to would be always!!! even if they are empty. please, check it, unless we will loose the statistics
#		log_printf("Doing statistics without time frames... it is dangerous!..");
#	}

#	do_statement("alter table itmp_aggregated_request_stat_select disable keys");
	do_statement("insert into itmp_aggregated_request_stat_select
select ag.product_id, ag.date, ag.date, ag.date,ag.date, ag.count, ag.user_id ".$extra_fs_select.", p.catid, p.supplier_id, p.user_id, p.prod_id, p.name
from ".$aggregation_table_name." ag ".$extra_product_select."
inner join itmp_product p on p.product_id = ag.product_id");
#	do_statement("alter table itmp_aggregated_request_stat_select enable keys");
	do_statement("drop temporary table if exists itmp_aggregated_request_stat_timeslice");
	do_statement("drop temporary table if exists itmp_product");

	if ($hin{'ajax_bg_process'} and !$dont_change_bg) { # AJAX
		do_statement("update generate_report_bg_processes set bg_current_value=2 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}

	do_statement("create temporary table itmp_aggr_products (product_id int(13) primary key)");
	do_statement("insert into itmp_aggr_products(product_id) select distinct product_id from itmp_aggregated_request_stat_select");

	do_statement("create temporary table itmp_aggr_temp (
product_id  int(13),
catid       int(13),
supplier_id int(13),
user_id     int(13),
prod_id     varchar(235),
name        varchar(255),
primary key (product_id),
key (supplier_id),
key (catid))");

	do_statement("alter table itmp_aggr_temp disable keys");

	do_statement("insert into itmp_aggr_temp(product_id,catid,supplier_id,user_id,prod_id,name)
select p.product_id, p.catid, p.supplier_id, p.user_id, p.prod_id, p.name
from itmp_aggr_products ap inner join product p using (product_id) ".$product_join_clause."
where 1 ".$product_clause);

	do_statement("alter table itmp_aggr_temp enable keys");

	if ($hin{'ajax_bg_process'} and !$dont_change_bg) { # AJAX
		do_statement("update generate_report_bg_processes
set bg_current_value=3
where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}
	
	my $query = "select arss.count as count, ".$fields_str.",".$levels->{'1'}." from itmp_aggregated_request_stat_select arss where 1 ".$clause;
	
	$env->{'subtotal'} = $subtotal;
#	$env->{'fields'} = $fields; # MAYBE IT'S UNNECESSARY THING
	$env->{'fields_arr'} = [@fields_arr];
	$env->{'field_number'} = {%field_number};	
	$env->{'base_map'} = $base_map;
	$env->{'query'} = $query;
	$env->{'levels'} = $levels;
	$env->{'dictionary'} = $dictionary;

	$env->{'date_from'} = $from;
	$env->{'date_to'} = $to;
#	log_printf ( 'Env-demo'.Dumper ( $env ) );
	
	return $env;
} 

sub get_data {
	my ($query_env) = @_;
	my ($levels, $subtotal, $base_map, @fields_arr, %field_number, $table_rows, $table_rows_plain, $table_rows_hash, $table_rows_keys, @insert_rows, $group_rows, $field, $quoted_levels);

	## create table names
	$levels  = $query_env->{'levels'};
	$subtotal = $query_env->{'subtotal'};
	$base_map = $query_env->{'base_map'};
	@fields_arr = @{$query_env->{'fields_arr'}};
	%field_number = %{ $query_env->{'field_number'}};

	for (sort keys %$levels) { # sorted as in report
		$field = $levels->{$_};
		$table_rows .= $base_map->{$subtotal->{$_}}.(($subtotal->{$_}==6||$subtotal->{$_}==7||$subtotal->{$_}==9||$subtotal->{$_}==111||$subtotal->{$_}==11)?" varchar(255)":" int(13)")." null,\n";
		$table_rows_keys .= "key (".$base_map->{$subtotal->{$_}}."),\n";
		$table_rows_plain .= $base_map->{$subtotal->{$_}}.",";
		$table_rows_hash->{$_} = $base_map->{$subtotal->{$_}};
		$insert_rows[$field_number{$levels->{$_}}] = $base_map->{$subtotal->{$_}};

		$quoted_levels = quotemeta($levels->{$_});
		if ($subtotal->{$_}==6) {
			$query_env->{'query'} =~ s/($quoted_levels)/concat('WEEK ',date_format(from_unixtime($1),'%Y-%U')) as new_week/s;
			$field = "new_week";
		}
		elsif ($subtotal->{$_}==7) {
			$query_env->{'query'} =~ s/($quoted_levels)/concat('MONTH ',date_format(from_unixtime($1),'%Y-%m')) as new_month/s;
			$field = "new_month";
		}
		elsif ($subtotal->{$_}==111) {
			$query_env->{'query'} =~ s/($quoted_levels)/concat('DAY ',date_format(from_unixtime($1),'%Y-%m-%d')) as new_day/s;
			$field = "new_day";
		}
		elsif ($subtotal->{$_}==9) {
			$query_env->{'query'} =~ s/($quoted_levels)/concat('YEAR ',date_format(from_unixtime($1),'%Y')) as new_year/s;
			$field = "new_year";
		}
		$group_rows .= $field.",";
	}
	chop($group_rows);
	chop($table_rows_plain);
	chop($table_rows_keys);
	chop($table_rows_keys);

	## create tmp table
	do_statement("create temporary table itmp_aggregated_request_stat (".$table_rows."tmp_count int(13) not null default '0',raw_value bigint(25) not null default 0,\n".$table_rows_keys.")");

	##inserting (aggregate)
	$query_env->{'query'} =~ s/^select\s([a-zA-Z_\.]+?)\s(.*)$/select sum($1) $2/s;
	push(@insert_rows,'raw_value');
	my $with_rollup;
	do_statement("insert into itmp_aggregated_request_stat(tmp_count,".join(",",@insert_rows).")".$query_env->{'query'}." group by ".$group_rows." with rollup");
	#log_printf("insert into itmp_aggregated_request_stat(tmp_count,".join(",",@insert_rows).")".$query_env->{'query'}." group by ".$group_rows." with rollup");
	$query_env->{'group_rows'} = $group_rows;
	$query_env->{'table_rows'} = $table_rows;
	$query_env->{'table_rows_keys'} = $table_rows_keys;
	$query_env->{'table_rows_plain'} = $table_rows_plain;
	$query_env->{'table_rows_hash'} = $table_rows_hash;
} # sub get_data

sub recurse_report {
	my ($out,$level,$clauses,$values,$query_env,$atom) = @_;
	my ($current, $next, $and, $where, $not_null, $query, $rows, $sth, $out_ref, $tmpl, $tmpl2, $dictionary_field, $dictionary_join, $value, $order_by, $G_product_id_info, $i);

	## get next column
	$current = $query_env->{'table_rows_hash'}->{$level};
	$next = $query_env->{'table_rows_hash'}->{($level+1)};
	$dictionary_field = $query_env->{'dictionary'}->{$level}->{'field'};
	$dictionary_join = $query_env->{'dictionary'}->{$level}->{'join'};

	## get response of tmp table
	$next = $next?"t.".$next." is null":"";
	$and = ($next)&&($#$clauses>-1)?" and ":"";
	$where = ($next)||($#$clauses>-1)?" where ":"";
	$order_by = ($current eq "month")||($current eq "week")||($current eq "year")?$current." asc":"tmp_count desc";
	$query = "select t.".$current.",t.tmp_count".$dictionary_field." from itmp_aggregated_request_stat t ".$dictionary_join.$where.$next.$and.join(" and ",@$clauses)." order by t.".$order_by;
	
#	log_printf(("\t" x $level) . "level = " . $level);
	log_printf("SQL QUERY DIRECTLY: ".$query.";");
	$sth = $atomsql::dbh->prepare($query);
	$sth->execute;
	
	if (($level eq 1) && ($hin{'ajax_bg_process'})) {
		do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (forming statistics)', bg_max_value=".$sth->rows.", bg_current_value=0 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}	
	$i=0;

	while ($rows = $sth->fetchrow_arrayref) {
#		log_printf(("\t" x $level) . "value = " . $rows->[0]);
		if (($level eq 1) && ($hin{'ajax_bg_process'}) && !($i % 100)) {
			$i++;
			do_statement("update LOW_PRIORITY generate_report_bg_processes set bg_current_value=".$i." where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		if ($rows->[0]) {
			if ($hin{'mail_class_format'} eq 'PIV' || $hin{'mail_class_format'} eq 'PSV') { # new Philips XLS format
				if ($current eq 'product_id') { # get all info about request user
					unless ($G_product_id->{$rows->[0]}) {
						$G_product_id_info = do_query("select middle_price from product_prf_prices where product_id=".$rows->[0])->[0][0] || '-';

#"select
#if(v.value!=''    and v.value   IS NOT NULL, v.value,'-'),
#if(c.company !='' and c.company IS NOT NULL, c.company,if(u.login != '' and u.login IS NOT NULL,concat('(',u.login,')'),'-')),
#if(s.name!=''     and s.name   IS NOT NULL,  s.name,'-')
#
#from users u
#left join contact c on u.pers_cid=c.contact_id
#left join country cn using (country_id)
#left join vocabulary v on cn.sid=v.sid and v.langid=1
#left join sector_name s on s.sector_id=c.sector_id and s.langid=1

#where u.user_id=".$rows->[0]);
#						log_printf("G = ".$G_product_id_info);
						$G_product_id->{$rows->[0]} = ($dictionary_field ? $rows->[2] : $rows->[0]) . "\t".$G_product_id_info;
					}
#					log_printf("G2 = ".$G_product_id->{$rows->[0]});
					$value = $G_product_id->{$rows->[0]};
				}
				elsif ($current eq 'year') {
					$value = $rows->[0];
					$value =~ s/^YEAR\s+//si;
				}
				elsif ($current eq 'month') {
					$value = $rows->[0];
					$value =~ s/^.*\-(\d+)$/$1/si;
					$value--;
					$value = POSIX::strftime("%B",0,0,0,1,$value,1);
				}
				else {
					$value = $dictionary_field?$rows->[2]:$rows->[0];
				}

				unless ($next) {
					$tmpl = $atom->{'report_row'};
					$tmpl2 = $atom->{'subtotal_format'};
					$tmpl =~ s/%%report_line%%/&format_out(join("\t", @$values) . "\t" . $value . "\t", 0, $atom, 67)/se;
					$tmpl2 =~ s/%%value%%/$rows->[1]/s;
					$tmpl =~ s/%%subtotals%%/$tmpl2/s;
					$$out .= $tmpl;
				}
			}
			else { # old format
				$value = $dictionary_field?$rows->[2]:$rows->[0];
				$tmpl = $atom->{'report_row'};
				$tmpl2 = $atom->{'subtotal_format'};
				$tmpl =~ s/%%report_line%%/&format_out($value,$level,$atom,67)/se;
				$tmpl2 =~ s/%%value%%/$rows->[1]/s;
				$tmpl =~ s/%%subtotals%%/$tmpl2/s;
				$$out .= $tmpl;
			}
			if ($next) {
				push @$clauses, "t.".$current."='".$rows->[0]."'";
				push @$values, $value;
				recurse_report($out,$level+1,$clauses,$values,$query_env,$atom);
				pop @$values;
				pop @$clauses;
			}
		}
	}
} # sub recurse_report

sub format_out {
	my ($text,$i,$atom,$line) = @_;
	$text = $atom->{'report_ident'} x ($i-1).$text;
	if ($atom->{'class'} eq 'mail_report_dsv') {
		if (length($text) >= $line) {
			$text = substr($text,0,$line);
		}
		else {
			$text .= '.' x ($line - length($text));
		}
	}
	if ($atom->{'class'} eq 'mail_report_csv') {
		unless ($hin{'mail_class_format'} eq 'PIV' || $hin{'mail_class_format'} eq 'PSV') {
			$text .= "\t" x (4 - $i);
		}
	}
	return $text;
}

sub get_report {
	log_printf("get_report");
	my ( $query_env, $atom ) = @_;

	my ($report, $query, $cols, $row, $wrow, $count, $olds, $new, $out, $example, $clauses, $subject);

	## how many columns?
	$cols = $#{$query_env->{'fields_arr'}};

	do_statement("delete from itmp_aggregated_request_stat where ".$query_env->{'table_rows_hash'}->{1}." is null");

	$G_product_id = undef;

	recurse_report(\$out,1,[],[],$query_env,$atom);
	
	$report = repl_ph($atom->{'body'}, {
		'report_rows' => $out,
		'code'        => $hin{'code'},
		'date'        => 'from '.$query_env->{'date_from'}.' to '.$query_env->{'date_to'},
		'period_text' => ' '.$query_env->{'period'}
										 });

	$subject = repl_ph($atom->{'subject'}, {
		'code' => $hin{'code'},
		'date' => 'from '.$query_env->{'date_from'}.' to '.$query_env->{'date_to'}
											} ) || "report";

	return [ $report, $subject ];
} # sub get_report

######################         Aggregate           ###########################################

sub start_aggregate () {
#	use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);
	use POSIX qw (strftime);

#	$Date - is string in format %Y-%m-%d
	my ($Date) = @_;
	my $TimeStamp = do_query("select unix_timestamp(".str_sqlize($Date).")")->[0][0]; 
	my $From =  $TimeStamp;
	my $delta_time_stamp = get_delta_time_stamp( $Date );
	my $To =  $TimeStamp + $delta_time_stamp - 1;
	my $C_year = strftime ("%Y", localtime($TimeStamp));
	my $C_month = strftime ("%m", localtime($TimeStamp));

#	log_printf (  "From: $From - ".strftime("%Y-%m-%d", localtime($From) ) );
#	log_printf ( "To: $To - ".strftime("%Y-%m-%d", localtime($To) ) );

	# create the source for aggregated_request_stat
	do_statement("create temporary table `tmp_aggregate` (
`user_id`    int(13) not null default '0',
`product_id` int(13) not null default '0',
`count`      int(13) not null default '0',

PRIMARY KEY (`user_id`,`product_id`))");

	my $Query = "insert into tmp_aggregate(user_id,product_id,`count`)
select user_id, product_id, count(*)
from request_repository
where date >= ".$From." and date <= ".$To."
group by user_id, product_id
order by product_id, user_id";
	do_statement($Query);

	# prepare the aggregated_request_stat & aggregated_request_stat_YYYYMM
#	do_statement("delete from aggregated_request_stat where date='".$TimeStamp."'");

	# complete the aggregated_request_stat with the new datas
#	do_statement("insert into aggregated_request_stat(user_id,product_id,date,count) select user_id,product_id,'".$TimeStamp."' as date,count from tmp_aggregate");
#	my $result_old = do_query("select ROW_COUNT()")->[0][0];

	# complete the aggregated_request_stat_YYYYMM with the new datas
	if (do_query("show tables like 'aggregated\\_request\\_stat\\_".$C_year.$C_month."'")->[0][0]) { # if the next table not exists
		do_statement("delete from aggregated_request_stat_".$C_year.$C_month." where date='".$TimeStamp."'");
	}
	else {
		do_statement("create table aggregated_request_stat_".$C_year.$C_month." like " . get_aggregated_request_stat_table_name);
		log_printf("The new aggregated_requests_stat_".$C_year.$C_month." table...");
	}
	do_statement("insert into aggregated_request_stat_".$C_year.$C_month."(user_id,product_id,date,count)
select user_id, product_id, '".$TimeStamp."' as date, count from tmp_aggregate");
	my $result = do_query("select ROW_COUNT()")->[0][0];

	# prepare the new product count data
	do_statement("drop temporary table if exists tmp_count");
	do_statement("create temporary table `tmp_count`(
`product_id` int(13) not null default '0',
`count`      int(13) not null default '0',
PRIMARY KEY (`product_id`))");
	do_statement("insert into tmp_count select product_id,sum(count) from tmp_aggregate group by product_id");
	do_statement("update tmp_count tc left join aggregated_product_count apc on tc.product_id=apc.product_id SET tc.count=tc.count+if(apc.count is null,0,apc.count)");

	# replace the new product count data

	# TODO: Replace `replace` command with update + insert. We can replace eixted the same values

	do_statement("replace into aggregated_product_count (product_id,count) select product_id,count from tmp_count");
	do_statement("drop temporary table tmp_count");
	do_statement("drop temporary table tmp_aggregate");

	return $result;
}

########################## Delta Time stamp #################################################

sub get_delta_time_stamp {
	my ($date) = @_;
	my $current_time_stamp = do_query("select unix_timestamp(".str_sqlize($date).")")->[0][0];
	my $next_date = strftime ("%Y-%m-%d", localtime ($current_time_stamp + 90001 ) ); 
	my $next_time_stamp = do_query("select unix_timestamp(".str_sqlize($next_date).")")->[0][0];
	my $delta = $next_time_stamp - $current_time_stamp;
	return $delta;
}


##############################################################################################

sub statistic_in_base {
	my ( $ShopId, $QueryId, $Statistic, $date, $period ) = @_;
	my $Query = "SELECT statistic_id FROM statistic_cache WHERE shop_id=".str_sqlize($ShopId)." and stat_query_id=".str_sqlize($QueryId)." and date=".str_sqlize($date); 
	my $StatisticId = do_query ( $Query )->[0][0];
	my $sr  = freeze $Statistic;
	if ($StatisticId) {
		$Query = "UPDATE statistic_cache SET statistic=".str_sqlize($sr)."WHERE statistic_id=".str_sqlize($StatisticId);
		do_statement($Query);
	}else{
		$Query = "INSERT INTO statistic_cache (stat_query_id, shop_id, statistic, date, period ) VALUES (".str_sqlize($QueryId).",".str_sqlize($ShopId).",".str_sqlize($sr).",".str_sqlize($date).",".str_sqlize($period).")";
		do_statement($Query);
	}
	return length($sr);
}

sub statistic_from_base {
	my $StartTime = time;
	my ( $StatisticId ) = @_;
	my $Query = "SELECT statistic FROM statistic_cache WHERE statistic_id=".str_sqlize( $StatisticId );
	my $Result = do_query ( $Query );
	$Result = $Result->[0]->[0];
	my $dsr = thaw($Result);
	my $Ret={};
	my $DeltaTime = time - $StartTime;
	$Ret->{data}=$dsr;
	$Ret->{delta_time} = $DeltaTime;
	return $Ret ; 
}

sub csv2html {
	my ($text) = @_;

	$text =~ /^(.*?)(Items.*?Requests)(.*)\s/s;
	my $head = $1;
	my $title = $2;
	my $tail = $3;

	$title =~ s/(Items).*?(Requests)/<table><tr><th>$1<\/th><th>$2<\/th><\/tr>/;

	$tail =~ s/^\s+(.*)\s*$/$1/s;

	my @lines = split /\n/, $tail;

	$tail = '';

	for (@lines) {
		/^(.*)\t(.*?)$/;
		$tail .= '<tr><td>'.$1.'</td><td>'.$2.'</td></tr>';
	}

	$tail .= '</table>';

	return $head.$title.$tail;
	
} # sub csv2html

sub csv2xls {
  my ($text, $is_PIV) = @_;
  use Spreadsheet::WriteExcel;
  #use Spreadsheet::WriteExcel::WorkbookBig;
  use Spreadsheet::WriteExcel::Big;

  my @lines = split(/\n/,$text);

	#log_printf("text = ".Dumper($$text));

  shift @lines while (@lines && ($lines[0] !~ /\s*Items\s+Requests/));
  shift @lines;
  shift @lines while (@lines && ($lines[0] eq ''));

	if ($is_PIV) {
		unshift @lines, "Part code (CTN)/MPN\tAverage price\tYear\tMonth\tCountry\tRequest type\tRequests (#)";
	}

  my @data;
  my @maxwidth = (0,0,0,0);
  my $lastcol;

	if ($is_PIV) {
		$lastcol = 6;
	}

  while ($lines[0] ne '') {
   my @cells = split(/\t/,$lines[0]);
   $lastcol = $lastcol?$lastcol:$#cells;

   for my $i (0..$lastcol) {
     $cells[$i] =~ s/^\s+//;
     my $len = (length($cells[$i])>>1)+5;
     if ($maxwidth[$i] < $len) { $maxwidth[$i] = $len; }
     if ($maxwidth[$i] > 100) { $maxwidth[$i] = 100; }
     if ($maxwidth[$i] < 8) { $maxwidth[$i] = 8; }
   }
   push @data, \@cells;
   shift @lines;
  }

	if (($hin{'ajax_bg_process'})) {
		do_statement("update generate_report_bg_processes set bg_max_value=".($#data+1)." where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}

  open my $fh, '>', \my $xls; ## streams file directly to scalar (perl 5.8 hack)
  my $workbook = Spreadsheet::WriteExcel::Big->new($fh);
	my $shcount;
#	if ($is_PIV) {
#		$shcount = 1;
#	}
#	else {
	$shcount = int($#data/10000) + 1;
#	}

  my @sheets;

  for (my $i=0; $i<$shcount; $i++) {
    my $pagenum=$i+1;
    push @sheets, $workbook->addworksheet($shcount==1?"Requests":"Requests ".$pagenum);
    for my $col (0..$lastcol) { $sheets[$i]->set_column($col, $col, $maxwidth[$col]); }
  }

  my $rowcount = 0;
  my $sht = 0;
  my $row = 0;
  $sheets[0]->activate();

	my $i = 0;

  for my $cells (@data) {
		$i++;
		# for ajax_bg_process
		if (($hin{'ajax_bg_process'}) && !($i % 100)) {
			do_statement("update LOW_PRIORITY generate_report_bg_processes set bg_current_value=".$i." where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}

    if ($sht < int($rowcount/10000)) {
      $sht = int($rowcount/10000);
      $sheets[$sht]->activate();
      $row=0;
    }
    my $col=0;
    for my $field (@$cells) {
      if ($field eq '') { $sheets[$sht]->write_string($row,$col,''); }
      else {
        my $fld = $field;
        $field =~ /^\d+$/ ? $sheets[$sht]->write_number($row,$col,$fld) :
					$sheets[$sht]->write_string($row,$col,$fld);
      }
      $col++;
    }
    $row++;
    $rowcount++;
  }

  $sheets[0]->activate();
  $workbook->close();

  return \$xls;
} # sub csv2xls

sub send_preformatted_reports_via_mail {
	my ($report, $lreport,$isHtml) = @_;

	# $report - report fields from db
	# @$lreport: 0 - body, 1 - subject

	my $attachment_mime = {
		'' => '',
		'gz' => 'application/x-gzip',
		'bz2' => 'application/x-bzip',
		'zip' => 'application/zip'	
	};

	# (30.03.2009) new! Use various cases of compessors
	# ungzip files with open-source application
	my $type = $report->{'email_attachment_compression'};
	$type = 'gz' if (($report->{'mail_class_format'} ne 'DSV') && (!$type));
	my $open_source_uncompressor = do_query("select email_postscriptum from compression_types where type=".str_sqlize($type))->[0][0];

	if ($hin{'ajax_bg_process'}) {
		do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (converting to ".$report->{'mail_class_format'}." format)', bg_max_value=1, bg_current_value=0 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}

	# forming mail hash
	my $report_filename = string2fat_name($lreport->[1]);
	if (length($report_filename) > 40) {
		$report_filename = substr($report_filename,0,40);
	}
	my $report_filename_xls = $report_filename.'.xls';
	my $report_filename_txt = $report_filename.'.txt';
	my $mail_type;
	if($isHtml){
		$mail_type="html_body";
	}else{
		$mail_type="text_body";
	}
	my $mail = {
		'from' =>  $atomcfg{'mail_from'},
		'subject' => $lreport->[1],
		$mail_type => $lreport->[1]." in attachment\n\n".$open_source_uncompressor,
		'attachment_content_type' => $attachment_mime->{$type}
		};
	
	if ($report->{'mail_class_format'} eq 'XLS') {
		$type = 'gz' unless $type;
		$mail->{'attachment_body'} = compress_data_by_ref(csv2xls($lreport->[0]),$report_filename_xls,"bytes",$type);
		$mail->{'attachment_name'} = $report_filename_xls.'.'.$type,
	}
	elsif ($report->{'mail_class_format'} eq 'PIV') {
		$type = 'gz' unless $type;
		$mail->{'attachment_body'} = compress_data_by_ref(csv2xls($lreport->[0],1),$report_filename_xls,"bytes",$type); # NEW!!! Philips pivot XLS format
		$mail->{'attachment_name'} = $report_filename_xls.'.'.$type,
	}
	elsif ($report->{'mail_class_format'} eq 'PSV') {
                $type = 'gz' unless $type;
                $mail->{'attachment_body'} = compress_data_by_ref(PSV_format($lreport->[0]),$report_filename_txt,"",$type); # NEW!!! Philips pivot CSV format
                $mail->{'attachment_name'} = $report_filename_txt.'.'.$type,
        }
	else {
		if ($report->{'mail_class_format'} eq 'CSV') {
			$mail->{'attachment_body'} = compress_data_by_ref(\$lreport->[0],$report_filename_txt,'',$type);
			$mail->{'attachment_name'} = $report_filename_txt.'.'.$type,
		}
		else {
#			$mail->{'text_body'} = undef;
			$mail = {
				'from' =>  $atomcfg{'mail_from'},
				'subject' => $lreport->[1],
				$mail_type => $lreport->[0],
				'attachment_content_type' => ''
			};
		}
	}
		
	if($report->{'mail_class_format'} eq 'GDR' and ref($lreport->[2]) eq 'HASH'){# it seems we have graphical report
	 my $indx=2;
	 if(ref($lreport->[2]->{'images'}) eq 'ARRAY'){
		 for my $gisto_img (@{$lreport->[2]->{'images'}}){
			unless(open(IMG, "<$gisto_img")){ 
	  			  log_printf("can't open gistogram image $gisto_img while sending email");
		 	}  		
	  		binmode IMG;
	  		$/ = \1024;
			while(<IMG>){
				$mail->{'attachment'.$indx.'_body'}.=$_;
			};
			$gisto_img=~/([^\/]+)$/;
			my $gisto_atach_name;
			if($1){
				$gisto_atach_name=$1;
			}else{
				$gisto_atach_name=$indx;
			}
			$mail->{'attachment'.$indx.'_name'} = $1;
			$mail->{'attachment'.$indx.'_content_type'}="image/gif";
	  		close IMG;
	  		$indx++;
	  		`rm $gisto_img` if $gisto_img=~/gisto/;
		 }
		}
		
	if(ref($lreport->[2]->{'xls'}) eq 'ARRAY'){
		for my $xls (@{$lreport->[2]->{'xls'}}){
			use IO::Compress::Gzip qw(gzip $GzipError) ;
			my $gziped;
			my $ref=\$xls->{'mime'};
			gzip $ref=>\$gziped or log_printf("gzip failed: $GzipError\n");
			$mail->{'attachment'.$indx.'_name'} = $xls->{'name'}.'.gz';
			$mail->{'attachment'.$indx.'_body'} = $gziped;
			$mail->{'attachment'.$indx.'_content_type'}="application/x-gzip";
	  		close IMG;
	  		$indx++;
		 }
	}
		
	}
	
	# sending to emails
	$report->{'email'} =~ s/[\r\n\t]/ /gs;
	$report->{'email'} =~ s/\s+/ /gs;

	my @emails = split(/[^\w\d-\.@]/, $report->{'email'});

	my $i=0;
	
	if ($hin{'ajax_bg_process'}) {
		do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (sending...)', bg_max_value=" . ($#emails+1) . ", bg_current_value=0 where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
	}

	for my $email (@emails) {
		$i++;
		if ($hin{'ajax_bg_process'}) {
			do_statement("update generate_report_bg_processes set bg_stage='".$hin{'code'}." (sending to ".$email.")', bg_current_value=".$i." where generate_report_bg_processes_id=".$hin{'ajax_bg_process_id'},$main_slave);
		}
		$mail->{'to'} = $email;
		complex_sendmail($mail);
	}
} # sub send_preformatted_reports_via_mail

##############################################################################################

sub PSV_format {
	my ($text) = @_;
	
	my @lines = split(/\n/,$text);
	
	shift @lines while (@lines && ($lines[0] !~ /\s*Items\s+Requests/));
	shift @lines;
	shift @lines while (@lines && ($lines[0] eq ''));
	unshift @lines, "Part code (CTN)/MPN\tAverage price\tYear\tMonth\tCountry\tRequest type\tRequests (#)";
	
	my $out_txt = join("\n",@lines);
	
	return \$out_txt;
} # sub PSV_format

sub YYYYMM_range {
	my ($y1, $m1, $y2, $m2) = @_;

#	log_printf("DV: ".Dumper(\@_));

	my ($range, $nextmonth, $nextyear);

	# get the lowest YYYYMM value, if $y1 & $m1 are empty
	if ($y1.$m1 lt '200207') { # 200207 is the lowest value in the ICEcat database - hardcoded
		$y1 = '2002';
		$m1 = '07';
	}

	# max
	if (!$y2 || !$m2) {
		my $ltime = do_query("select unix_timestamp()")->[0][0];
		$y2 = strftime ("%Y", localtime($ltime));
		$m2 = strftime ("%m", localtime($ltime));
	}

	for my $cyear ($y1 .. $y2) {
		for my $cmonth (1 .. 12) {
			next if (($y1 == $cyear) && ($cmonth < $m1)); # if year is current and month is less than initial - next, please ;)

			# get next month & year
			$nextmonth = $cmonth + 1;
			$nextmonth = '0'.$nextmonth if (length($nextmonth) == 1);
			$cmonth = '0'.$cmonth if (length($cmonth) == 1);
			$nextyear = $cyear;
			if ($nextmonth >= 13) {
				$nextmonth = '01';
				$nextyear = $cyear + 1;
			}
			
			# push it: current year, current month, next year, next month, is 1st table, is last table
			push @$range, [$cyear, $cmonth, $nextyear, $nextmonth, (($cyear == $y1) && ($cmonth == $m1)) ? 1 : 0, (($cyear == $y2) && ($cmonth == $m2)) ? 1 : 0 ];

			# reach the end
			last if (($cmonth == $m2) && ($cyear >= $y2)); # finish if we reach the end
		}
		last if ($cyear >= $y2); # just in case
	}
	
#	log_printf("DV: ".Dumper($range));
	
	return $range;
} # sub YYYYMM_range

sub get_gisto_data{
	my ($query_env,$limit,$allowed_limit,$is_order_by_cnt,$stamp)=@_;
	my $where_is_null='';
	my $order_by='';
	my $limit_clause;
	my $group_by;
	if($is_order_by_cnt){
		$order_by=" ORDER BY tmp_count ";
	}else{
		$order_by=" ORDER BY raw_value ";
	}
	if($limit){
		$limit_clause=" LIMIT $limit"
	}
	my $main_field;
	if($stamp){
		$main_field="date_format(from_unixtime(tmp.raw_value),'$stamp') as ".$query_env->{'table_rows_hash'}->{'1'};
	}else{
		$main_field='tmp.'.$query_env->{'table_rows_hash'}->{'1'};
	}
	$where_is_null=" tmp.$query_env->{'table_rows_hash'}->{'2'} is null and " if $query_env->{'table_rows_hash'}->{'2'}; 
	my $sql="  SELECT $main_field $query_env->{'dictionary'}->{'1'}->{'field'},tmp.tmp_count,tmp.$query_env->{'table_rows_hash'}->{'1'} as to_group
	           FROM itmp_aggregated_request_stat tmp
	           $query_env->{'dictionary'}->{'1'}->{'join'} 
			   WHERE $where_is_null tmp.$query_env->{'table_rows_hash'}->{'1'} IS NOT null           
	           GROUP BY to_group
	           $order_by
	           $limit_clause";
   	my $sth = $atomsql::dbh->prepare($sql);
	$sth->execute;
	my (@x_axis,@y_axis,$x_name);
    if($query_env->{'dictionary'}->{'1'}->{'field'}=~/,/){# this's vocabulary's field	
		$x_name=$query_env->{'dictionary'}->{'1'}->{'field'}." ";
		$x_name=~/(^\,[^\.]+\.)([\w]+)(.+)/;
    	$x_name=$2;
    }else{ # this field is from  itmp_aggregated_request_stat table
    	$x_name=$query_env->{'table_rows_hash'}->{'1'};
    }
    my $rows_cnt=0;
    
	while (my $rows = $sth->fetchrow_hashref()) {
		if($rows->{$x_name}){
			push(@x_axis,shortfy_x_name($rows->{$x_name}));
			push(@y_axis,$rows->{"tmp_count"});
			$rows_cnt++;
		}
		if($rows_cnt>$allowed_limit and $allowed_limit){
			return '';
		};# don't create gisto if count of bars more than $allowed_limit  
		
	}
  	return [[@x_axis],[@y_axis]];
}

sub get_tops_gisto_data {
	my ($query_env,$limit,$is_order_by_cnt,$indicate_sponsor,$add_summary_bar)=@_;
	my $sth=get_tops_data($query_env,$limit,$is_order_by_cnt,$indicate_sponsor);
	
	my (@data);	
	my $sql_fileds=$query_env->{'dictionary'}->{'1'}->{'field'};
	my @info_fields=split(/,[\w]+\./,$sql_fileds);
	shift @info_fields;#first element will be empty couse fields start with , 
	
	my (@x_axis,@y_axis,$x_name,@x_styles);
    
    if($query_env->{'dictionary'}->{'1'}->{'field'}=~/,/){# this's vocabulary's field
    	if($info_fields[1]){
    		$x_name=$info_fields[1];
    	}else{
    		$x_name=$info_fields[0];
    	}
    }else{ # this field is from  itmp_aggregated_request_stat table
    	$x_name=$query_env->{'table_rows_hash'}->{'1'};
    }
    my $rows_cnt=0;
    my ($total_count,$limit_count);
	while (my $rows = $sth->fetchrow_hashref()) {
		if($rows->{$x_name}){
			push(@x_axis,shortify_str($rows->{$x_name},15,'..'));
			push(@y_axis,$rows->{"tmp_count"});
			$rows_cnt++;
		}
		($total_count,$limit_count)=($rows->{'total_count'},$rows->{'limit_count'}) unless($total_count);
		if($indicate_sponsor){
			use GD::Graph::bars3d::Style;
			if($rows->{'is_sponsor'} eq 'Y'){
				push(@x_styles,GD::Graph::bars3d::Style->new(rgb=>[0,255,0],legend_name=>'Sponsored'));
			}else{
				push(@x_styles,GD::Graph::bars3d::Style->new(rgb=>[250,0,0],legend_name=>'Not Sponsored'));
			}
		}
	}
	if($total_count != $limit_count and $add_summary_bar){ # add summary bar
		push(@x_axis,'others');
		push(@y_axis,$total_count-$limit_count);
	}
  	return {'axis'=>[[@x_axis],[@y_axis]],'x_axis_style'=>\@x_styles};
}

sub create_gisto{
  my ($data,$bar_name,$bar_width,$title,$x_styles,$x_lables_vertical)=@_;
  return '' unless($data);
  my $x_font_height=4;
  my $x_label="   ";
  my $y_label="Downloads per $bar_name";    
  use GD::Graph::bars3d::bars3dCustomStyle;
  #use GD::Graph::bars;
  use GD::Graph::colour;
  my $width;
  my $bar_spacing=7;
  my $bar_depth=5;
  $bar_width=$bar_width;
  $width=scalar(@{$data->[0]})*$bar_width + $bar_spacing*scalar(@{$data->[0]})+150;# 100- texts and other things at left side   
  
  $bar_width=100 unless($bar_width);
  if (scalar(@{$data->[0]})<=3){
  	$width=320;
  }
  if (scalar(@{$data->[0]})<1 or scalar(@{$data->[1]})<1){ # no data was fetched from db  	
  	$width=500;
  	$x_label='Request gave no results';
    $y_label='Request gave no results';
    $title='Request gave no results';
  	
  	$data=[[0],[0]];  	
  }
	my $max_x_length=5;
	if(ref($data->[0]) eq 'ARRAY'){
		for my $x_value( @$data->[0]->[0]){
			$max_x_length=length($x_value) if $max_x_length<length($x_value);
		}	
	}
  
  my $graph=GD::Graph::bars3d::bars3dCustomStyle->new($width,350+($max_x_length*$x_font_height));
  
  $graph->x_axis_styles($x_styles);
  GD::Graph::colour::add_colour(lines_clr=>[48,122,199]);
  GD::Graph::colour::add_colour(axis_label=>[31,31,31]);
  GD::Graph::colour::add_colour(gisto_clr1=>[1,1,228]);
  GD::Graph::colour::add_colour(gisto_clr2=>[221,254,228]);
  GD::Graph::colour::add_colour(gisto_clr3=>[252,254,228]);
  
  GD::Graph::colour::add_colour(gisto_border_clr=>[204,206,204]);
  GD::Graph::colour::add_colour(gisto_value_clr=>[204,10,10]);

my $font_path=$atomcfg{'font_path'}.'FreeMonoBold.ttf';
$graph->set_y_axis_font($font_path, 7);
$graph->set_x_axis_font($font_path, 8);
$graph->set_x_label_font($font_path, 10);
$graph->set_y_label_font($font_path, 10);
$graph->set_values_font($font_path, 7);
$graph->set_title_font($font_path, 11);
$graph->set_legend_font($font_path, 8);
if($bar_name and !$x_styles){
	$graph->set_legend($bar_name);
}

$graph->set(
	  #'width'           => scalar(@x_axis)*100,
	  'interlaced'      => 1,   
      'x_label'         => $x_label,
      'y_label'         => $y_label,
      'title'           => $title,
      'fgclr'       	=> 'lines_clr',
      'transparent'     => 0,
      'axislabelclr'    => 'axis_label',
      'labelclr'        => 'axis_label',
      'textclr'         => 'axis_label',
      'dclrs'           => ['gisto_clr1','gisto_clr2'],
      'borderclrs'      => ['gisto_border_clr'],
      'cycle_clrs'      => 0,
      'long_ticks'      => 1,
      'tick_length'     => 5,
      'x_ticks'         => 0, 
      'y_label_skip'    => 1,
      'y_tick_number'   => 10,      
      'y_number_format' => sub{return "".shift()},
      'x_label_skip'    => 0,
      'x_label_position'=> 1,
      'y_label_position'=> 1,
      'y_plot_values'   => 1,
      'x_plot_values'   => 1,
      'x_labels_vertical' => $x_lables_vertical,
      'box_axis'        => 0,
      'zero_axis'       => 1,
      'zero_axis_only'  => 1,
      'axis_space'      => 1,
      'text_space'      => 1,
      'cumulate'       => 0,
      'overwrite'      => 0,
      'show_values'     => 1,
      'values_vertical' => 1,
      'values_format'   =>sub{my $value=shift(); return ($value)?$value:''},
      'bar_spacing'     =>$bar_spacing,
      'bar_width'       =>$bar_width,
      #'bargroup_spacing'=>20,
      'bar_depth'=>$bar_depth,      
	  'legend_placement'=>'BL',
	  #'b_margin'=>($max_x_length*$x_font_height),
  ) or log_printf($graph->error);
  my $gd = $graph->plot($data);
  return 0 unless($gd);
  use POSIX qw(floor);
  #my $img_path='/home/alex/tmp/'.floor(rand(200)).'_gisto.gif';
  my $img_path=$atomcfg{'session_path'}.floor(rand(200000)).'_gisto.gif';
  unless(open(IMG, ">$img_path")){ 
  	log_printf('can\'t open gistogram image');
  	return undef;
  }
  
  binmode IMG;
  print IMG $gd->gif;
  close IMG;
  return $img_path;  	
};

sub shortfy_x_name{
	my $name=shift;
	my $min_lenght=8; 
	if ($hin{'subtotal_1'} eq '6' or $hin{'subtotal_1'} eq '7' or $hin{'subtotal_1'} eq '111'){#time intervals
		$name=~s/[A-Za-z]+//g;
		$name=~s/\-/\n/g;
	}
	my @words=split(/\s+/,$name);
	my $words=\@words;
	for(my $i=0;$i<scalar(@$words);$i++){
		if(length($words->[$i])>8){
			$words->[$i]=substr($words->[$i],0,$min_lenght).'..';
		}
	}
	return join("\n",@$words);
}

sub returnRightDay{
	my($year,$month,$day)=@_;
	my $max_day;
	use Time::Piece;
	my $t;
	$t=eval('Time::Piece->strptime(\''.$year.'-'.$month.'-01\',\'%Y-%m-%d\')');
	return '' unless($t);
	$max_day=$t->month_last_day();
	if($max_day<$day){
		return $max_day;
	}else{
		return $day;
	}
}

sub normalizeDataInterval{
	my ($from_year,$from_month,$from_day,$to_year,$to_month,$to_day,$data,$x_axis_stamp,$interval)=@_;
	my $x_axis=$data->[0];
	my $y_axis=$data->[1];
	use POSIX qw(floor);
	my ($from,$to);
	$from=eval('Time::Piece->strptime(\''.$from_year.'-'.$from_month.'-'.$from_day.'\',\'%Y-%m-%d\')');
	return '' unless($from);	
	
	$to=eval('Time::Piece->strptime(\''.$to_year.'-'.$to_month.'-'.$to_day.'\',\'%Y-%m-%d\')');
	return '' unless($to);
	my $curr_date=$from;
	my ($curr_week,$curr_month,$prev_week,$prev_month);
	my $i=0;
	while($curr_date->epoch()<=($to->epoch()+1)){
		$x_axis->[$i]=~s/[\n\t\r\s]+//gs;
		if($interval eq 'day'){
			if($x_axis->[$i] ne $curr_date->strftime($x_axis_stamp)){
				splice(@$x_axis, $i, 0, $curr_date->strftime($x_axis_stamp));
				splice(@$y_axis, $i, 0, 0);
			}							
			$i++;
		}elsif($interval eq 'week'){
			my $curr_week=$curr_date->strftime($x_axis_stamp);
			if($curr_week ne $prev_week){
				if($x_axis->[$i] ne $curr_week){
					splice(@$x_axis, $i, 0, $curr_week);
					splice(@$y_axis, $i, 0, 0);
				}				
				$i++;
				$prev_week=$curr_week;
			}			
		}elsif($interval eq 'month'){
			my $curr_month=$curr_date->strftime($x_axis_stamp);
			if($curr_month ne $prev_month){
				if($x_axis->[$i] ne $curr_month){
					splice(@$x_axis, $i, 0, $curr_month);
					splice(@$y_axis, $i, 0, 0);
				}
				$i++;
				$prev_month=$curr_month;
			}						
		}		
		$curr_date=$curr_date+24*3600;
		return $data if $i==182500; #just in case 		
	};
	pop(@$x_axis) if $interval ne 'day'; #alogorithm stops  when current day < right limit day +1 sek. this is not a problem with daily interval but with others will produce 1 redundant item   ;
	return $data;

}

sub get_tops_data {
	my ($query_env,$limit,$is_order_by_cnt,$indicate_sponsor)=@_;

	my ($where_is_null,$order_by,$limit_clause,$sponsor_joins,$sponsor_field);

	if ($is_order_by_cnt) {
		$order_by=" ORDER BY tmp_count ";
	}

	if ($limit) {
		$limit_clause=" LIMIT $limit"
	}

	if ($indicate_sponsor and $query_env->{'table_rows_hash'}->{'1'} ne 'supplier_id') {
		$sponsor_joins=" JOIN product prod ON tmp.product_id=prod.product_id
					  JOIN supplier s ON prod.supplier_id=s.supplier_id ";
		$sponsor_field=" ,s.is_sponsor,s.name as supl_name";
	}elsif($indicate_sponsor and $query_env->{'table_rows_hash'}->{'1'} eq 'supplier_id') {
		$sponsor_joins='';
		$sponsor_field=" ,s.is_sponsor ";
	}else{
		$sponsor_field=",''";
	}
	
	$where_is_null=" WHERE tmp.$query_env->{'table_rows_hash'}->{'2'} is null " if $query_env->{'table_rows_hash'}->{'2'}; 
	my $sql="  SELECT tmp.$query_env->{'table_rows_hash'}->{'1'} $query_env->{'dictionary'}->{'1'}->{'field'},tmp.tmp_count $sponsor_field,'%%total_count%%' as total_count, '%%limit_count%%' as limit_count
	           FROM itmp_aggregated_request_stat tmp
	           $query_env->{'dictionary'}->{'1'}->{'join'}
	           $sponsor_joins 
			   $where_is_null	           
	           GROUP BY tmp.$query_env->{'table_rows_hash'}->{'1'}
	           $order_by DESC
	           $limit_clause";
	#print $sql;
	my $sql_limit_count=do_query("SELECT SUM(tmp_count) FROM ($sql) as subq")->[0][0];
	my $sql_total_count=do_query("SELECT tmp_count FROM itmp_aggregated_request_stat 
	           					   WHERE $query_env->{'table_rows_hash'}->{'1'} IS NULL ")->[0][0];
	$sql=repl_ph($sql,{'total_count'=>$sql_total_count,'limit_count'=>$sql_limit_count});
	#test_tables();
	my $sth = $atomsql::dbh->prepare($sql);
	$sth->execute;
	return $sth;
}

sub get_tops_html_data {
	my ($query_env,$limit,$is_order_by_cnt,$indicate_sponsor,$for_xls)=@_;
	my $sth=get_tops_data($query_env,$limit,$is_order_by_cnt,$indicate_sponsor);
	
	my (@data);	
	my $sql_fileds=$query_env->{'dictionary'}->{'1'}->{'field'};
	my @info_fields=split(/,[\w]+\./,$sql_fileds);
	shift @info_fields;#first element will be empty couse fields start with ,
	if($query_env->{'group_rows'} =~ /product_id$/){
		push(@info_fields,'supl_name');
	}   
	while (my $rows = $sth->fetchrow_hashref()) {
		my @to_push;
		for my $info_field(@info_fields){
				push(@to_push,$rows->{$info_field});
		};		
		if($indicate_sponsor and $for_xls){			
			$to_push[0]=$to_push[0]."$rows->{'is_sponsor'}";
			push(@to_push,(($rows->{'is_sponsor'} eq 'Y')?'sponsored':'not sponsored'));
			
		}elsif($indicate_sponsor and !$for_xls){
			$rows->{'is_sponsor'}=($rows->{'is_sponsor'} eq 'Y')?'&nbsp;(<span style="color:green">sponsored</span>)':'';
			$to_push[0]=$to_push[0]."$rows->{'is_sponsor'}";
		}
		push(@to_push,$rows->{'tmp_count'});
		push(@data,\@to_push);
				
	}
  	return \@data;		
}


sub create_top_html{
	my($data,$caption,$headers,$type)=@_;	
	use HTML::Entities;
	process_atom_ilib('graphical_query_report_top');
	my $atoms = process_atom_lib('graphical_query_report_top');
	my ($headers_html,$rows_html);
	for my $header(@$headers){
		unless($type eq 'product' and $header eq 'Supplier'){
			$headers_html.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'header_row'},{'header'=>$header})
		}
	}
	my $row_size=scalar(@$headers);
	my ($info_link,$tmp_prod_id);	
	for my $row(@$data){
		my $info_cell='';
		for(my $i=0;$i<$row_size;$i++){
			if($i==1 and $type eq 'product'){
				$tmp_prod_id=$row->[0];
				$tmp_prod_id=~s/&nbsp;.+$//;	
				$info_link=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'product_link'},
									 {'cell'=>decode_entities($row->[$i]),'supplier'=>decode_entities($row->[2]),'prod_id'=>decode_entities($tmp_prod_id)});
				$info_cell.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'first_info_cell'},
									 {'cell'=>$info_link});
			}elsif($i==0 and $type and $type ne 'product'){
				$info_link=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'lookup_link'},
										 {'cell'=>decode_entities($row->[$i]),'type'=>$type,'key'=>str_htmlize(decode_entities($row->[0]))});
				$info_cell.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'first_info_cell'},
									 {'cell'=>$info_link});										 																		 				
			}elsif($i==0){
				$info_cell.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'first_info_cell'},
									 {'cell'=>decode_entities($row->[$i]),30})
			}else{
				#log_printf(encode_entities($row->[$i]));
				unless($type eq 'product' and $headers->[$i] eq 'Supplier'){
					utf8::decode($row->[$i]);
					$info_cell.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'info_cell'},
										 {'cell'=>decode_entities(shortify_name($row->[$i],30))})
				}
			}
		}
		$rows_html.=repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'info_row'},{'info_cell'=>$info_cell})
	}
	
	return repl_ph($atoms->{'default'}->{'graphical_query_report_top'}->{'body'},
					{'header_row'=>$headers_html,'info_row'=>$rows_html,'caption'=>$caption}
					);
}

sub create_see_attach_html{
	my($title,$atach_name)=@_;
		
}

sub get_average_html{
	my($field_name,$caption)=@_;
	my $count=do_query("SELECT count(*) FROM itmp_aggregated_request_stat WHERE $field_name IS not null")->[0][0];
	my $total_count=do_query("SELECT tmp_count FROM itmp_aggregated_request_stat 
							   WHERE $field_name IS null AND tmp_count IS not NULL ")->[0][0];
	my $avg;
	if($count){
		use POSIX qw(floor);		
		$avg=floor($total_count/$count);
	}else{
		$avg='0'; 
	} 
	process_atom_ilib('graphical_query_report_avg');
	my $atoms = process_atom_lib('graphical_query_report_avg');
	return repl_ph($atoms->{'default'}->{'graphical_query_report_avg'}->{'body'},
					{'caption'=>$caption,'cell'=>$avg});
	
}

sub get_gisto_html_image{
	my($caption,$img_file,$shops_count)=@_;
	process_atom_ilib('graphical_query_report_graph');
	my $atoms = process_atom_lib('graphical_query_report_graph');
	$img_file=~/([^\/]+)$/gs;
	my $qqq=$1;
	return repl_ph($atoms->{'default'}->{'graphical_query_report_graph'}->{'body'},
					{'caption'=>$caption,'image_file'=>$1,'shops_count'=>$shops_count});	
}

sub get_full_report{
	my($avgs,$graphs,$tops,$name)=@_;
	my $tops_html;
	process_atom_ilib('graphical_query_report');
	my $atoms = process_atom_lib('graphical_query_report');
	open(CSS,$atomcfg{'www_path'}.'graphic_report.css');
	my $css=join("\n",<CSS>);
	close CSS;
	my ($top_td);
	for(my $i=1;$i<scalar(@$tops)+1;$i++){
		$top_td.=repl_ph($atoms->{'default'}->{'graphical_query_report'}->{'top_td'},{'top'=>$tops->[$i-1]});
		if($i % 2==0){
			$tops_html.=repl_ph($atoms->{'default'}->{'graphical_query_report'}->{'top_row'},
								 {'top_td'=>$top_td});		
			$top_td='';
		}
	}
	if($top_td){
		$tops_html.=repl_ph($atoms->{'default'}->{'graphical_query_report'}->{'top_row'},{'top_td'=>$top_td});
	}		
		
	return repl_ph($atoms->{'default'}->{'graphical_query_report'}->{'body'},
					{'avg'=>$avgs,'graphs'=>$graphs,'top_row'=>$tops_html,'css'=>$css,'report_name'=>$name});
}

sub shortify_name{
	my ($str,$limit)=@_;
	$limit=length($str)-$limit;
	if($limit>0){
		$str=~s/.{0,$limit}$/\.\.\./;
		return $str;
	}else{
		return $str;
	}	
}

#sub test_tables{
#	sub create_aaa_test{
#		my $table=shift;
#		do_statement("DROP TABLE IF EXISTS aaa_$table");
#		do_statement("CREATE TABLE aaa_$table LIKE $table");
#		do_statement("INSERT INTO aaa_$table SELECT * FROM $table");
#	}
#	create_aaa_test('itmp_aggregated_request_stat');
	#create_aaa_test('itmp_aggr_temp');	
#}

sub get_interval_by_period{
		use Time::Piece;
		use POSIX qw(strftime);	
		my $period=shift;
		return '' if(!$period or $period eq '1');
		my $from;
		my $to=return_currentTimePiece();
		if($period == 5){#last day
			$from=$to-24*3600;			
		}elsif($period == 2){# last week
			my $week_scope=get_week_scope($to->epoch()-7*24*3600);
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($week_scope->{'from'});
			$year+=1900;
			$mon+=1;
			$from=eval('Time::Piece->strptime(\''.$year.'-'.$mon.'-'.$mday.'\',\'%Y-%m-%d\')');
			($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($week_scope->{'to'});
			$year+=1900;
			$mon+=1;
			$to=eval('Time::Piece->strptime(\''.$year.'-'.$mon.'-'.$mday.'\',\'%Y-%m-%d\')');
		}elsif($period == 3){# last month
			$from=$to->add_months(-1);
		}elsif($period == 4){# last quarter
			$from=$to->add_months(-4);
		}else{
			return undef;
		}
		
		return {'from'=>[$from->year(),$from->mon(),$from->mday()],'to'=>[$to->year(),$to->mon(),$to->mday()]}	
}

sub get_week_scope{
	my ($epoch_wday)=@_;
	use Time::Piece;
	use POSIX qw(strftime);	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($epoch_wday);
	$year+=1900;
	$mon+=1;
	my $curr_day_obj=eval('Time::Piece->strptime(\''.$year.'-'.$mon.'-'.$mday.'\',\'%Y-%m-%d\')');
	while($curr_day_obj->day_of_week()){
		$curr_day_obj+=24*3600;
	}
	my $week_end=$curr_day_obj;
	$week_end-=24*3600;
	do{
		$curr_day_obj-=24*3600;
	}while($curr_day_obj->day_of_week());
	my $week_start=$curr_day_obj;
	return {'from'=>$week_start->epoch,'to'=>$week_end->epoch}
}

sub return_currentTimePiece{
	use Time::Piece; 
	my $to_unixtime=do_query("SELECT unix_timestamp()")->[0][0];
	my($sec_,$min_,$hour_,$mday_,$mon_,$year_)=localtime($to_unixtime);
	$year_+=1900;$mon_++;
	my $to=eval('Time::Piece->strptime(\''.$year_.'-'.$mon_.'-'.$mday_.'\',\'%Y-%m-%d\')');
	return $to; 
}

sub write_to_xls{ 
	my ($rows,$title,$header)=@_;
	use Spreadsheet::WriteExcel::Big;	
	my $workbook=Spreadsheet::WriteExcel::Big->new('text.xls');
	open my $fh, '>', \my $xls;	
	my $workbook=Spreadsheet::WriteExcel::Big->new($fh);	
	
	my $header_format= $workbook->add_format(size => 10,bold=>1);
	my $i=2;
	my $limit=65535;
	my $sheet_count=1;
	my $worksheet=$workbook->add_worksheet("$title$sheet_count");
	
	$worksheet->set_row(0, 15, $header_format);
	$worksheet->write_row('A1',$header);
	for my $row(@$rows){
			if($i==$limit){
				$sheet_count++;
				$worksheet=$workbook->add_worksheet("$title$sheet_count");
				$i=1;
			}
			
			if(ref($row) eq 'ARRAY'){
				my $j=0;
				for my $cell(@$row){
					$worksheet->write_string($i,$j,$row->[$i,$j]);
					$j++;		
				}
			}
			
			$i++;
	}
	$workbook->close();
	return $xls;
}

1;

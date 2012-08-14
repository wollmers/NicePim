package atom_cust;

use strict;

use atomcfg;
use atom_html;
use atomlog;
use atomsql;
use atom_util;
use atom_misc;

use Data::Dumper;


BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw( &proc_custom_processing_errors
								&proc_custom_processing_menu
								&proc_custom_processing_menu2
								&proc_custom_processing_stat_report
								&proc_custom_processing_category_features_batch
								&proc_custom_processing_clipboard
								&proc_custom_processing_coverage_report
								&proc_custom_processing_ajax_product_features_local
								&proc_custom_processing_price_prew
								&proc_custom_processing_price_save
								&proc_custom_processing_send_users
								&proc_custom_processing_warnings
								);
}

sub proc_custom_processing_send_users {
	my ($atom,$call) = @_;
	use atom_commands;
	return make_send_users($atom->{'class'});
}

sub proc_custom_processing_price_save {
	my ($atom,$call) = @_;
	use price_request;
	return generate_price_save($atom->{'class'});
}

sub proc_custom_processing_price_prew {
	my ($atom,$call) = @_;
	use price_request;
	return generate_price_prew($atom->{'class'});
}

sub proc_custom_processing_coverage_report {
	my ($atom,$call) = @_;
	use coverage_report;
	return generate_coverage_report($atom->{'class'});
}

sub proc_custom_processing_stat_report {
	my ($atom,$call) = @_;
	return '' if $hin{'atom_update'} or $hin{'atom_delete'} or $hin{'atom_submit'};
	 
	my ($str, $cols, $names, $values, $value, $id);	
	use stat_report;

	if (($hin{'reload'}) && (lc($hin{'reload'}) ne 'report')) {

		if ($hin{'mail_class_format'} eq 'DSV') {
			$call->{'class'} = 'mail_report_dsv';
		}
		else {
			$call->{'class'} = 'mail_report_csv';
		}

		log_printf("via mail");
		
		# backgrounding
		if (0) {
			$str = generate_stat_report($atoms->{$call->{'class'}}->{$call->{'name'}}, $call);
			my $report = \%hin;
			&stat_report::send_preformatted_reports_via_mail($report, $str);
#			log_printf(Dumper($call));
			return "<center>Report already sent!</center>";
		}
		else {
			use process_manager;
			$cols = preparing_bg_table; # make additional columns if needed			
			# prepare request
			for (keys %$cols) {
				$names .= $_.",";
				if (($_ ne 'name') && ($_ ne 'class')) {
					$value = $hin{$_};
					$value = returnRightDay($hin{'to_year'},$hin{'to_month'},$value) 	  if $_ eq 'to_day';
					$value = returnRightDay($hin{'from_year'},$hin{'from_month'},$value) if $_ eq 'from_day';
				}
				else {
					$value = $call->{$_};
				}
				$values .= str_sqlize($value).",";
			}
			chop($names);
			chop($values);
			do_statement("insert into generate_report_bg_processes(".$names.",bg_user_id,bg_start_date,bg_stage) ".
						  "values(".$values.",".$USER->{'user_id'}.",unix_timestamp(),'".$hin{'code'}."(initialization)')");
			$id = do_query("select last_insert_id()")->[0][0];
		  $hin{'generate_report_bg_processes_id'} = $id; # for AJAX
			log_printf("run in BG: ".$atomcfg{'base_dir'}."bin/do_generate_stat_report_and_mail_it ".$id.' &');
			run_bg_command($atomcfg{'base_dir'}.'bin/do_generate_stat_report_and_mail_it '.$id.' &');
			#return "<center>Report is processing in the background. You can monitor it.</center>";
			return "<center></center>";
		}

		# end
	}
	else {
		log_printf("via html");
		$hin{'to_day'} 	 = returnRightDay($hin{'to_year'},$hin{'to_month'},$hin{'to_day'}) 	  if $hin{'to_day'};
		$hin{'from_day'} = returnRightDay($hin{'from_year'},$hin{'from_month'},$hin{'from_day'}) if $hin{'from_day'};
		$main_slave='slave1';
		register_slave('slave1',$atomcfg{'dbslavehost'},$atomcfg{'dbslaveuser'},$atomcfg{'dbslavepass'});
		make_slave_host('slave1');
		register_slave($main_slave,$atomcfg{'dbhost'},$atomcfg{'dbuser'},$atomcfg{'dbpass'});
		$str = generate_stat_report($atoms->{$call->{'class'}}->{$call->{'name'}}, $call);

		return $str->[0];
	}
}

sub proc_custom_processing_category_features_batch {
	my ($atom,$call) = @_;
	my $langid = 1;
	
	if (($USER->{'user_group'} eq 'superuser') || ($USER->{'user_group'} eq 'supereditor')) {
		
		if ($hin{'process_batch'} && $hin{'batch'}) {
			my $report_rows = '';	  
			my $cat_feat_ref = do_query("select category_feature_id, feature_id, catid from category_feature");
			my $category_feature;
			for my $cat_feat (@$cat_feat_ref) {
				$category_feature->{$cat_feat->[2]}->{$cat_feat->[1]} = $cat_feat->[0];
			}

			my $data = do_query("select catid, vocabulary.value, pcatid, ucatid from category, vocabulary where category.sid = vocabulary.sid and vocabulary.langid = ".str_sqlize($langid)." and category.catid <> 1 ");
			my $category;
			
			for my $row (@$data) {
				$category->{$row->[0]} = {
					'name' 		=>	$row->[1],
					'pcatid'	=> 	$row->[2],
					'uncatid'	=>	$row->[3]
				};
			}
			
			$data = do_query("select feature_id, v.value, ms.value, measure_name.value, f.measure_id from feature f
inner join vocabulary v on f.sid = v.sid and v.langid = ".str_sqlize($langid)."
left  join measure_sign ms on f.measure_id = ms.measure_id and ms.langid = ".str_sqlize($langid)."
inner join measure m on f.measure_id = m.measure_id
inner join vocabulary measure_name on m.sid = measure_name.sid and measure_name.langid = v.langid");

			my $feature;
			my $feature_map;

			for my $row (@$data) {
				$feature->{$row->[0]} = {
					'name' 		=>	$row->[1],
					'sign'		=> 	$row->[2],
					'measure_name' => $row->[3],
					'measure_id' => $row->[4]
				};
				$feature_map->{$row->[1].'('.$row->[3].')'} = $row->[0];
			}
			
			$data = do_query("select category_feature_group_id, catid from category_feature_group where feature_group_id = 0");
			my $category_feature_group_map = {};
			for my $row (@$data) {
				$category_feature_group_map->{$row->[1]} = $row->[0];
			}
			
			$hin{'batch'} =~s/\r//gms;
			my @lines = split("\n", $hin{'batch'});
			
			for my $line (@lines) {
				$line =~s/^\s+//;
				next unless($line);
				my ($cat_name, $feat_name) = split('\) - ', $line);
				my $status;				 
				
				$cat_name.= ')'; # appending cutted bracket
				
				$cat_name =~m/\((\d+?)\)$/;
				my $catid = $1;

				unless ($category->{$catid}) {
					$catid = undef;
				}
				
				$feat_name =~s/\s+\Z//g;
				
				my $feature_id = $feature_map->{$feat_name};
				
				if ($feature_id && $catid) {
					# create link
					if ($category_feature->{$catid}->{$feature_id}) {
						# such link exists
						$status = 2;
					}
					else {
						if (!$category_feature_group_map->{$catid}) {
							# we need to insert category feature group here
							insert_rows("category_feature_group", 
													 {
														 "catid" => $catid,
														 "feature_group_id"	=> 0
													 });
							$category_feature_group_map->{$catid} = sql_last_insert_id();
						}
   					my $hash = {
							'catid' 											=> $catid,
							'feature_id'									=> $feature_id,
							'category_feature_group_id'	=> $category_feature_group_map->{$catid}
						};
						
						insert_rows('category_feature', $hash);			 
						$category_feature->{$catid}->{$feature_id}	= sql_last_insert_id();
						$status = 0;
					}
				}
				else {
					if ($feature_id && !$catid) {
						$status = 3;
					}
					elsif (!$feature_id && $catid) {
						$status = 4;
					}
					else {
						$status = 5;
					}
				}
				
				$report_rows .= repl_ph($atom->{'report_row'}, { 'value' => $line,
																													'status' => 
																														$atom->{'row_status_'.$status}});
				
			}
			$atom->{'body'} = repl_ph($atom->{'body'}, 
																 {
																	 'report'	=> repl_ph($atom->{'report_body'}, { 'report_rows' => $report_rows})
																 });
		}
		else {
			return $atom->{'body'};
		}
	}
	else {
		return '';
	}
} # sub proc_custom_processing_category_features_batch

sub proc_custom_processing_errors {
	my ($atom,$call) = @_;

	my $tmp =	'';

	if ($#user_errors > -1) {
		for my $error (@user_errors) {
			$tmp .= repl_ph($atom->{'error_row'}, {'error_text' => str_unhtmlize($error) });
		}
		return repl_ph($atom->{'body'}, {'error_rows' => $tmp });
	}

	return '<span style="color: red;">'.$hin{'error'}.'</span>' if($hin{'error'});

	return undef;
}

sub proc_custom_processing_ajax_product_features_local {
	my ($atom,$call) = @_;

	$hin{'hidden_tab_id'} =~ /feat_tab_id_(\d+)/;
	my $tab_id = $1;

	if ($tab_id) {
		return repl_ph($atom->{'body'}, { 'tab_id' => $tab_id, 'product_id' => $hin{product_id} });
	}
	else {
		return undef;
	}
} # sub proc_custom_processing_ajax_product_features_local

sub proc_custom_processing_menu2 {
	my ($atom,$call) = @_;	
	return proc_custom_processing_menu($atom,$call);
}

sub proc_custom_processing_menu{
	my ($atom,$call) = @_;
	use XML::XPath;
	my $menu_conf =	$atom->{'menu_config'};
	my $menu_xml=XML::XPath->new($menu_conf);
	my $root=$menu_xml->find('/*')->[0];
	my $menu_html=' ';
	my $mi = $hin{$atom->{'general_indicator'}};
	submenu_tree($root,-1,$atom,$mi,\$menu_html,'');
	$menu_html=~s/<\/table><\/div><\/td>$//;
	return repl_ph($atom->{'general_body'},{ 'items' => $menu_html });;  	
}

sub submenu_tree{
	my ($root_node,$level,$atom,$mi,$menu_html,$is_left)=@_;
	#print join('',map {'-'} (1..$level));
	$root_node->getAttribute('name')."\n";
	my $sub_menus=$root_node->find('menu');
	if($level>-1){
		my $curr_menu='';
		if($level==0 and $root_node->getAttribute('id') eq $mi){
			$curr_menu=$atom->{'general_item_sel'};		
			$is_left=$root_node->getAttribute('is_left');	
		}elsif($level==0 and $root_node->getAttribute('id') ne $mi){
			$curr_menu=$atom->{'general_item'};
			$is_left=$root_node->getAttribute('is_left');
		}elsif(scalar(@$sub_menus)>0){
			$curr_menu=$atom->{'menu_container'};
		}else{
			$curr_menu=$atom->{'menu_item'};
		}
		$$menu_html.=repl_ph($curr_menu,{'name'=>$root_node->getAttribute('name'),
										 'width'=>$root_node->getAttribute('width'),
										 'url'=>$root_node->getAttribute('url'),
										 'is_left'=>(($is_left)?'true':'false'),
										 'right_indicator'=>(($is_left)?'':$atom->{'right_indicator'}),
										 'left_indicator'=>(($is_left)?$atom->{'left_indicator'}:''),
										  })."\n";
	}
	$level++;
	for my $submenu (@$sub_menus){
		my $validate_sub=$submenu->getAttribute('restrict');
		if($validate_sub and !eval($validate_sub)){
			next;
		}
		$level=submenu_tree($submenu,$level,$atom,$mi,$menu_html,$is_left);
			
	}
	if(scalar(@$sub_menus)>0 or $level==1){
		$$menu_html.="\n</table></div></td>";
	}
	$level--;
	return $level;
}

sub hide_from_groups{
	my ($groups)=@_;
	if(ref($groups) ne 'ARRAY'){
		return 1;
	}
	if(grep(/^$USER->{'user_group'}$/,@{$groups})){
		return '';
	}else{
		return 1;
	}
}

sub hide_from_all_groups_except{
	my ($groups)=@_;
	if(ref($groups) ne 'ARRAY'){
		return 1;
	}
	if(grep(/^$USER->{'user_group'}$/,@{$groups})){
		return 1;
	}else{
		return '';
	}
}

sub proc_custom_processing_menu_ldkjvaslfjlsdkfjslkdjflkdl {
	my ($atom,$call) = @_;
	
	my $pref = 'general_';
	
	my $rstr = 'restrict_';

	my $add_supplier = 'add_supplier_';
	
	my $mi = $hin{$atom->{$pref.'indicator'}};
	my @mis = split(/,/,$atom->{$pref.'mis'});
	my @names = split(/,/,$atom->{$pref.'names'}); 
	my @tmpls = split(/,/,$atom->{$pref.'tmpls'}); 
	my @sup_rst = split(/,/,$atom->{$rstr.'supplier'});

	my @add_sup_names = split(/,/,$atom->{$add_supplier.'names'});
	my @add_sup_mis = split(/,/,$atom->{$add_supplier.'mis'});
	my @add_sup_tmpls = split(/,/,$atom->{$add_supplier.'tmpls'});
	# Filtering out menu buttons for supplier in correspondence with restriction in atom file
	if ($USER->{'user_group'} eq 'supplier') {
		for my $sup (@sup_rst) {
			for (my $i = 0; $i < @mis; $i++) {
				if ($mis[$i] eq $sup) {
					splice (@mis,$i,1);
					splice (@names,$i,1);
					splice (@tmpls,$i,1);
				}
			}
		}
	}

	# new! add specific menu items to supplier
	if ($USER->{'user_group'} eq 'supplier') {
		for (my $i=0; $i < @add_sup_mis; $i++) {
			push @mis, $add_sup_mis[$i];
			push @names, $add_sup_names[$i];
			push @tmpls, $add_sup_tmpls[$i];
		}
	}	
	
	my $cnt = $#mis;
	my $entries = '';

	#log_printf('selected'.$mi); 
	for (my $i=0; $i <= $cnt; $i++) {
		my $entry;

		my $prefix = $i == 0 ? "first" : ( $i == $cnt ? "last" : "" );
		
		if ($mis[$i] eq $mi) {
			$entry = repl_ph($atom->{$pref.'item_sel'}, 
												{
													"name" => $names[$i],
													"tmpl" => $tmpls[$i],
													"item" => $mis[$i],
													"indicator" => $atom->{$pref.'indicator'},
													"prefix" => $prefix
												});
			
#			if ($i != 0) {
#				$entry = $atom->{$pref.'sel_left_div'}.$entry;
#			}
#			if ($i != $cnt) {
#				$entry .= $atom->{$pref.'sel_right_div'};
#			}
		}
		else {
			$entry = repl_ph($atom->{$pref.'item'},
												{
													"name" => $names[$i],
													"tmpl" => $tmpls[$i],
													"item" => $mis[$i],
													"indicator" => $atom->{$pref.'indicator'},
													"prefix" => $prefix
												});
			
#			if ($mis[$i+1] ne $mi && $cnt != $i) {
#				$entry .= $atom->{$pref.'div'};	
#			}
		}
		$entries .= $entry;
	}
	
	$entries = repl_ph($atom->{$pref.'body'},{ 'items' => $entries });
	
	return $entries; 
}

sub proc_custom_processing_clipboard {
	my ($atom, $call) = @_;
#	log_printf("CLIPBOARD\nhin = ".Dumper(\%hin));
#	log_printf("atom = ".Dumper($atom));
#	log_printf("call = ".Dumper($call));
	my $text = '';
	my $extra_JS = '';

	# changing the start_row

#	log_printf("FILTER = ".$filter);
	my $saved_line = $hl{$hin{'clipboard_object_type'}.'_saved_values'};
	# log_printf($saved_line);
	my @saved = split(',',$saved_line);
	my $hash = undef;
	%$hash = map { $_ => 1 } @saved;

	$hash = {} unless $hash;

	# log_printf($i.' '.$last_saved);
	$hin{$hin{'atom_name'}.'_start_row'} = int($hin{$hin{'atom_name'}.'_start_row'});
	my $first_saved;
	if(int($hin{'start_row_memory'})){
		$first_saved=int($hin{'start_row_memory'});
	}else{# by some kind of unknown reason %%%%atom_name%%_start_row%% does not procesed correctly in nav_bar2_memorize.al. this is a fix for it
		$first_saved=int($hin{'start_row_memory_custom'});
	} 
		
	#my $rowsOnPage = int($hin{'last_row'}) - int($hin{$hin{'atom_name'}.'_start_row'});
	my $rowsOnPage = int($hin{'rows_number'});
	
	my $last_saved = $first_saved + ($rowsOnPage*2);
	my $i = $first_saved;
	while ($i <= $last_saved) {
		if ($hin{'row_'.$i}) {
			# log_printf("saving $i row");
			$hash->{$hin{'row_'.$i.'_item'}} = 1;
		}
		else {
			delete $hash->{$hin{'row_'.$i.'_item'}};
		}
		$i++;
	}	
	my @actions = split(',',$hin{'listed_actions'});

	$clipboard_objects->{$hin{'clipboard_object_type'}} = $hash;	
	for my $action (@actions) {
		if ($hin{'action_'.$action.'_'.$hin{'clipboard_object_type'}}) {

			if ($action eq 'clear') {
				$hash = {};				
				$clipboard_objects->{$hin{'clipboard_object_type'}} = $hash;
				$hin{$hin{'atom_name'}.'_start_row'}='0';
			}
			elsif ($action eq 'selectall' and $hin{'clipboard_object_type'} eq 'product') {

				# may be we need to remove it!..
				if ($hin{'search_clause'} =~ /prod_id like ''/s) {
					$hin{'search_clause'} =~ s/prod_id like ''/prod_id like '%%'/s;
				}
				if ($hin{'search_clause'} =~ /name like ''/s) {
					$hin{'search_clause'} =~ s/name like ''/name like '%%'/s;
				}

				# the improved clauses
				log_printf("InTeReStInG ReQuEsT:");

				my $xAtomFilterTables = $hin{'x-atom filter tables'};

				my $allproduct_ids = do_query("select p.product_id from product p " . ( join ' , ', @$xAtomFilterTables ) . " where " . $hin{'x-atom filter wheres'} . " " . $hin{'search_clause'});

				my %hash1 = map {$_->[0] => 1} @$allproduct_ids;

				$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;

				# no strict;
				# $text = &{'cli_'.$hin{'clipboard_object_type'}.'_group'}($atom, $call);
				# $hin{'action_code'} = 'action_group'.$hin{'clipboard_object_type'};
			}
			elsif ($action eq 'batchselect' and $hin{'clipboard_object_type'} eq 'product') {

				#
				# IMPORTANT: This type of selection removes all previous selections and ignore filters & searches
				#

				use data_management;

				my $list_of_products = get_product_id_list_from_raw_batch($hin{'batch_products4selection'})->[0];
				my %hash1 = map {$_ => 1} @$list_of_products;

				$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;

			}
			elsif ($action eq 'selectall' and $hin{'clipboard_object_type'} eq 'complaint') {
				# if($hin{'search_clause'} =~ /name like ''/){ $hin{'search_clause'} =~ s/name like ''/name like '%%'/;}	 
				my $allcomplaint_ids = do_query("SELECT pc.id 
	 								FROM supplier as s,  users as u, users as u1,vocabulary as v,  product_complaint_status as pcs, product_complaint as pc
	 								LEFT JOIN   product as p ON (p.product_id=pc.product_id) 
	 								WHERE pc.supplier_id = s.supplier_id and 
								 	  pc.user_id = u.user_id and 
								 	  pc.complaint_status_id = pcs.code and 
								 	  pcs.sid = v.sid and  
								 	  v.langid = 1 and  
								 	  pc.fuser_id = u1.user_id".
																				 (($hin{'search_status_id'})?" AND pc.complaint_status_id=$hin{'search_status_id'}":'').
																				 (($hin{'search_subject'})?" AND (pc.message LIKE '%$hin{'search_subject'}%' OR pc.subject LIKE '%$hin{'search_subject'}%') ":'').
																				 (($hin{'search_userid'})?" AND pc.user_id=$hin{'search_userid'}":'').
																				 (($hin{'search_fuserid'})?" AND pc.fuser_id=$hin{'search_fuserid'}":'').
																				 (($hin{'search_internal_search'})?" AND pc.internal=$hin{'search_internal_search'}":'').
																				 (($hin{'search_complaint_id'})?" AND pc.id=$hin{'search_complaint_id'}":''));
				my %hash1 = map{$_->[0] => 1} @$allcomplaint_ids;
				$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;				
			}elsif ($action eq 'selectall' and $hin{'clipboard_object_type'} eq 'track_product_all') {				
				my $sql=$iatoms->{'track_products_all'}->{'executed_resource_sql_track_products_all'};
				$sql=~s/limit.+$//gis;				
				my $ids=do_query($sql);
				my %hash1 = map{$_->[1] => 1} @$ids;
				$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;		
				#my $allcomplaint_ids = do_query("SELECT tp.track_product_id FROM  track_product tp 
				#			WHERE  
				#	      		tp.rule_prod_id!='' 					      		
				#	      	".(($hin{'search_rule_user_id'})?" AND tp.rule_user_id=$hin{'search_rule_user_id'}":''));
				#my %hash1 = map{$_->[0] => 1} @$allcomplaint_ids;
				
				#$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;		
			}elsif ($action eq 'selectall' and $hin{'clipboard_object_type'} eq 'track_product') {				
				my $sql=$iatoms->{'track_products'}->{'executed_resource_sql_track_products'};
				$sql=~s/limit.+$//gis;				
				my $ids=do_query($sql);
				my %hash1 = map{$_->[0] => 1} @$ids;
				$clipboard_objects->{$hin{'clipboard_object_type'}} = \%hash1;		
			}
			else {
				no strict;
				$text = &{'cli_'.$hin{'clipboard_object_type'}.'_'.$action}($atom, $call);
				$hin{'action_code'} = 'action_'.$action.'_'.$hin{'clipboard_object_type'};
			}
		}
	}
	my @arr = keys %{$clipboard_objects->{$hin{'clipboard_object_type'}}};
	$saved_line = '';

	for my $row (@arr) {
		$saved_line .= $row.',';
	}

# passing params
	$hs{$hin{'clipboard_object_type'}.'_saved_values'} = $saved_line;
	$hout{'clipboard_object_type'} = $hin{'clipboard_object_type'};
	$hout{'atom_name'} = $hin{'atom_name'};
	
# log_printf(Dumper(\%hin));	
#	for my $item ('first', 'prev', 'next', 'last') {
#		if ($hin{$item}) {
#			$hin{$hin{'atom_name'}.'_start_row'} = str_htmlize($hin{'start_row_'.$item}); # DV CHANGES...
#		}
#	}
	if ($text) {
		$text = repl_ph($atom->{'wrap_body'}, { 'instance_body' => $text });
	}

	# set checkboxes for products	
	#if ($hin{'clipboard_object_type'} eq 'product') {
		my $product_id_saved_list = $hin{'clipboard_saved_list'};
		for my $p_id (@$product_id_saved_list) {
			if ($clipboard_objects->{$hin{'clipboard_object_type'}}->{$p_id}) {
				$extra_JS .= "if (document.getElementById('row_".$p_id."')) { document.getElementById('row_".$p_id."').checked = true; }\n";
			}
		}		
		my $objs = $clipboard_objects->{$hin{'clipboard_object_type'}};
		if (ref($objs) eq 'HASH' and scalar(keys(%{$objs}))>0) {
			$extra_JS = "<script type='text/javascript'>
<!--
window.onload=function(){
".$extra_JS."

document.getElementById('clipboard_info').innerHTML = '&nbsp;&nbsp;&nbsp;Total " . ( keys %$objs ) . " products selected';
}
// -->
</script>
";
		}
	#}

	return $text."\n".$extra_JS;
}

sub cli_category_feature_group {
my ($atom, $call) = @_;
 my $obj = 'category_feature';

 
if($hin{'group_selection'}&&$hin{'catid'}){
 if($hin{'feature_group_id'}){
# checking category_feature_group

  my $category_feature_group_id = maintain_category_feature_group($hin{'feature_group_id'}, $hin{'catid'});
	
	 for my $key(keys %{$clipboard_objects->{$obj}}){
  	 update_rows('category_feature', " category_feature_id = ".$key , 
	  	 {
		 		"category_feature_group_id" => $category_feature_group_id
			 });
	 }  
 
 $clipboard_objects->{$obj} = {};

 } else {
  # error
	log_printf('no group_feature_id ');
 }
 return '';
} else {

 
 my $instance_body = $atom->{$obj.'_body'};
 my $cat_feat_row = $atom->{$obj.'list_row'};
 
 my $category_feature_id_clause = ' 0 ';
 
 for my $key(keys %{$clipboard_objects->{$obj}}){
   $category_feature_id_clause .= ' or category_feature.category_feature_id = '.$key;
 }
 
 my $data = do_query("select concat(vocabulary.value,'(',measure_name.value,')') from feature, vocabulary, vocabulary as measure_name, measure, category_feature where category_feature.feature_id = feature.feature_id and ( $category_feature_id_clause ) and feature.measure_id = measure.measure_id and measure_name.sid = measure.sid and measure_name.langid = $hl{'langid'} and vocabulary.sid = feature.sid and vocabulary.langid = $hl{'langid'}  order by vocabulary.value");
 
 my $cat_feat_rows = '';
 for my $row(@$data){
  $cat_feat_rows .= repl_ph($atom->{$obj.'_list_row'}, { 'value' => $row->[0] } );
 }
 
   my $group_data = do_query("select feature_group.feature_group_id, vocabulary.value from feature_group, vocabulary where vocabulary.sid = feature_group.sid and vocabulary.langid = $hl{'langid'}  order by vocabulary.value");
   unshift @$group_data, ['',''];
	 
 $instance_body = repl_ph($instance_body, 
	 { 'category_feature_list_rows' => $cat_feat_rows,
	    # 'group_list' => make_select($group_data, 'feature_group_id')
	    'group_list' => make_select( {
		'rows' => $group_data,
		'name' => 'feature_group_id'
	    } )
	 } );
 
 return $instance_body;
}

}

sub cli_product_group {
	my ($atom, $call) = @_;
	my $obj = 'product';
	
	my $instance_body = $atom->{$obj.'_body'};
	my $product_row = $atom->{$obj.'list_row'};
	my $product_id_clause = ' 0 ';
	my $product_id_list = '';
	
	do_statement("drop temporary table if exists itmp_product");
	do_statement("create temporary table itmp_product (
product_id  int(13)      not null primary key,
supplier_id int(13)      not null default '0',
prod_id     varchar(235) not null default '',
name        varchar(255) not null default '',
key (supplier_id),
key (product_id, prod_id, supplier_id))");

	do_statement("drop temporary table if exists itmp_product_list");
	do_statement("create temporary table itmp_product_list (product_id  int(13) not null)");

	for my $key (keys %{$clipboard_objects->{$obj}}) {
#		do_statement("insert into itmp_product select product_id,supplier_id,prod_id,name from product where product_id=".$key);
		$product_id_list .= $key.",";
	}

	chop($product_id_list);
	my $product_id_list2SQL = $product_id_list;

	$product_id_list2SQL =~ s/,/\),\(/gs;

	do_statement("insert into itmp_product_list values (".$product_id_list2SQL.")");
	do_statement("alter ignore table itmp_product_list add unique key (product_id)");

	do_statement("alter table itmp_product disable keys");
	do_statement("insert into itmp_product select p.product_id,p.supplier_id,p.prod_id,p.name from product p inner join itmp_product_list ipl using (product_id)");
	do_statement("alter table itmp_product enable keys");

	$hin{'product_id_list'} = $product_id_list;
	$hin{'supplier_id_list'} = undef;

	my $supplier_ids = do_query("select supplier_id from itmp_product group by supplier_id");
	my @ids = ();

	for (@$supplier_ids) {
		push @ids, $_->[0];
	}

	$hin{'supplier_id_list'} = \@ids;
	
	my $data = do_query("select tp.product_id, tp.prod_id, tp.name, s.name from itmp_product tp inner join supplier s on tp.supplier_id=s.supplier_id");
	do_statement("drop temporary table itmp_product");
	
	my $product_rows = '';
	for my $row (@$data) {
		$product_rows .= repl_ph($atom->{$obj.'_list_row'}, { 'value' => $row->[0], 'text' => $row->[3]." ".$row->[1]." ".$row->[2]} );
	}
	
	$instance_body = repl_ph($instance_body, 
														{ 'product_list_rows' => $product_rows,
															'product_id_list' => $product_id_list
														});
	
	return $instance_body;
}

sub cli_complaint_group
{
	my ($atom, $call) = @_;
	my $obj = 'complaint';
	
	my $instance_body = $atom->{$obj.'_body'};
	my $complaint_row = $atom->{$obj.'list_row'};
	my $complaint_id_clause = ' 0 '; 
	my $complaint_id_list = ''; 
	do_statement("CREATE TEMPORARY TABLE tmp_complaint LIKE product_complaint");
	for my $key(keys %{$clipboard_objects->{$obj}}){
		do_statement("INSERT INTO tmp_complaint SELECT * FROM product_complaint WHERE id=".$key);
		$complaint_id_list .= $key.",";
	}
	$complaint_id_list =~ s/(.+),/$1/;
	$hin{'complaint_id_list'} = $complaint_id_list;
	
	my $data = do_query("SELECT id, subject,prod_id FROM tmp_complaint");
	do_statement("drop temporary table tmp_complaint");
	
	my $complaint_rows = '';
	for my $row(@$data){
	   $complaint_rows .= repl_ph($atom->{$obj.'_list_row'}, { 'value' => $row->[0], 'text' =>$row->[1]."nbsp;($row->[2])"} );
	}
	 
	$instance_body = &repl_ph($instance_body, 
	{ 'complaint_list_rows' => $complaint_rows,
		 'complaint_id_list' => $complaint_id_list
	});
	
	return $instance_body;

}

sub cli_track_product_all_group{
	my ($atom, $call) = @_;
	my $obj = 'track_product_all';
	
	my $instance_body = $atom->{$obj.'_body'};
	my $track_product_all_row = $atom->{$obj.'list_row'};
	my $track_product_all_id_clause = ' 0 '; 
	my $track_product_all_id_list = ''; 
	do_statement("CREATE TEMPORARY TABLE tmp_track_product_all LIKE track_product");
	for my $key(keys %{$clipboard_objects->{$obj}}){
		do_statement("INSERT INTO tmp_track_product_all SELECT * FROM track_product WHERE track_product_id=".$key);
		$track_product_all_id_list .= $key.",";
	}
	$track_product_all_id_list =~ s/(.+),/$1/;
	$hin{'track_product_all_id_list'} = $track_product_all_id_list;
	
	my $data = do_query("SELECT track_product_id, map_prod_id,rule_prod_id FROM tmp_track_product_all");
	do_statement("drop temporary table tmp_track_product_all");
	
	my $track_product_all_rows = '';
	for my $row(@$data){
	   $track_product_all_rows .= repl_ph($atom->{$obj.'_list_row'}, { 'value' => $row->[0], 'text' =>$row->[1]."&nbsp;($row->[2])"} );
	}
	 
	$instance_body = repl_ph($instance_body, 
	{ 'track_product_all_list_rows' => $track_product_all_rows,
	  'track_product_all_id_list' => $track_product_all_id_list
	});
	
	return $instance_body;
}

sub cli_track_product_group{
	my ($atom, $call) = @_;
	my $obj = 'track_product';
	my $instance_body = $atom->{$obj.'_body'};
	my $track_product_row = $atom->{$obj.'list_row'};
	my $track_product_id_clause = ' 0 '; 
	my $track_product_id_list = ''; 
	do_statement("CREATE TEMPORARY TABLE tmp_track_product_actions LIKE track_product");
	for my $key(keys %{$clipboard_objects->{$obj}}){
		do_statement("INSERT INTO tmp_track_product_actions SELECT * FROM track_product WHERE track_product_id=".$key);
		$track_product_id_list .= $key.",";
	}
	$track_product_id_list =~ s/(.+),/$1/;
	$hin{'track_product_id_list'} = $track_product_id_list;
	
	my $data = do_query("SELECT track_product_id, feed_prod_id, feed_supplier,name,eans_joined FROM tmp_track_product_actions");
	do_statement("drop temporary table tmp_track_product_actions");
	
	my $track_product_rows = '';
	for my $row(@$data){
	   $track_product_rows .= repl_ph($atom->{$obj.'_list_row'}, { 'value' => $row->[0], 'text' =>$row->[1]."($row->[2]) (".$row->[4].') '.$row->[3]} );
	}
	 
	$instance_body = repl_ph($instance_body, 
	{ 'track_product_list_rows' => $track_product_rows,
	  'track_product_id_list' => $track_product_id_list
	});
	return $instance_body;
}

sub proc_custom_processing_warnings{
	my ($atom, $call) = @_;
	#my @user_warnings_=split(/,/,$hl{'user_warnings'});
	if(scalar(@user_warnings)>0){
		my $str;
		for my $warn (@user_warnings){
			
			$str.=repl_ph($atom->{'warnings_row'},{'warning_text' => $warn });
		}
		
		delete $hs{'user_warnings'};		
		return repl_ph($atom->{'body'},{'warnings_row' => $str });
	}else{
		return '';
	};
}

1;

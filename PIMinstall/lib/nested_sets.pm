package nested_sets;

#$Id: nested_sets.pm 2595 2010-05-19 11:51:30Z lexx $

use strict;

use atomcfg;
use atomsql;
use atomlog;
use Data::Dumper;
use Time::HiRes;
use utf8;
BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
$postfix
$nested_set_debug

&add_element
&delete_element
&move_element
&merge_elements

&get_subtree
&get_parentree
&get_branch

&check_tree
);

}

my $postfix = '_nestedset';
my $nested_set_debug = 1;

sub TEST {log_printf(shift) if $nested_set_debug;} # sub TEST

sub init_nestedset { # the result is - from scratch to filled table  
	my ($table, $id_name, $p_id_name, $force,$transl_field,$tree_lang,$transl_table,$transl_id) = @_; # id_name - primary key, $p_id_name - parent_id_name
	
	TEST("sub init_nestedset(" . (join ',', @_) . ")");
	return 0 unless($transl_field);
	
	return unless $table;
	return unless $id_name;
	return unless $p_id_name;
	return unless do_query("select ".$id_name.", ".$p_id_name." from ".$table." limit 1")->[0][0];
	#return if (!$force); # do not do anything
	
	my $is_maintable_exists=do_query("show tables like '".$table.$postfix."'")->[0][0];
			# get the id parameters
			my $format = do_query("show create table ".$table)->[0][1];
			$format =~ s/^.*?\`$id_name\`\s+(.*?)\,.*$/$1/is;
			$format =~ s/\sauto_increment//is;
		
			TEST("\t" . "PK format is: ".$format);
		
			# create a new nestedset table
			$postfix .= '_tmp';
			do_statement("drop table if exists ".$table.$postfix);
			do_statement("create table ".$table.$postfix." (
		".$id_name." ".$format.",
		nestedset_id int(13) unsigned not null auto_increment,
		level tinyint(1) unsigned not null default 0,
		left_key  int(13) unsigned not null default 0,
		right_key int(13) unsigned not null default 0,
		langid int(11)    unsigned not null default 0,
		primary key (nestedset_id),
		key id_name ($id_name),
		unique key ".$id_name." (".$id_name.",langid),
		key ll (left_key),
		key rr (right_key)
		)");
		
	# fill it
	my $elements = do_query("select ".$id_name.", ".$p_id_name." from ".$table." order by ".$p_id_name.", ".$id_name);
	for (@$elements) {
		add_element($table, $id_name, $p_id_name, $_->[1], $_->[0], 'skip_checking',$transl_field,$tree_lang,$transl_table,$transl_id);
	}
	
	# rotate it
	$postfix =~ s/_tmp$//s;
	if($is_maintable_exists){
		do_statement("DELETE FROM ".$table.$postfix." WHERE langid=$tree_lang");
		do_statement("INSERT IGNORE INTO ".$table.$postfix." ($id_name,level,left_key,right_key,langid)
					   SELECT $id_name,level,left_key,right_key,langid FROM ".$table.$postfix."_tmp");
	}else{
		do_statement("drop table if exists ".$table.$postfix);	
		do_statement("rename table ".$table.$postfix."_tmp to ".$table.$postfix);		
		
	}
	do_statement("drop table if exists ".$table.$postfix."_tmp");

	# post-checking
	
	check_tree($table, $id_name, $p_id_name,'',$transl_field,$tree_lang,$transl_table,$transl_id);
} # sub init_nestedset

sub check_tree { # also init and so on: the result is - properly formed nestedset table
	my ($table, $id_name, $p_id_name, $force,$transl_field,$tree_lang,$transl_table,$transl_id) = @_;	
	
	return 0 unless($transl_field);
	TEST("sub check_tree(" . (join ',', @_) . ")");
	my $avialble_langs;
	if ($tree_lang){		
		$avialble_langs=[[$tree_lang]];
	}else{
		$avialble_langs=do_query("SELECT v.langid FROM $table c JOIN $transl_table v USING($transl_id) group by v.langid");
	}

	my $errors;
	my $ns_table=$table.$postfix;	
	for(@{$avialble_langs}){
		if(!do_query("SHOW TABLES LIKE '$ns_table'")->[0][0]){
			$errors="Table $ns_table does not exits";
			last();	
		}
		
		my $err_rows=do_query(" SELECT $id_name FROM $ns_table WHERE langid=$_->[0] AND left_key >= right_key");
		$errors.="Error. Here is WHERE langid=$_->[0] AND left key more than right key".Dumper($err_rows)." lang $_->[0] \n" if $err_rows->[0];
		my $total=do_query(" SELECT COUNT($id_name)FROM $ns_table WHERE langid=$_->[0]")->[0][0];
		my $root=do_query(" SELECT left_key,right_key FROM $ns_table WHERE langid=$_->[0] and $id_name=1")->[0];
		if ($root->[0]!=1 or $root->[1]<$total*2){
			$errors.="Error. Min left key more than 1 or Max right key less than ".($total*2)." lang $_->[0] \n";
		}
		$err_rows=do_query("SELECT $id_name FROM $ns_table WHERE langid=$_->[0] AND MOD((right_key - left_key), 2)=0");
	
		$errors.="Error. There is even difference beetween left an right key here: ".Dumper($err_rows)." lang $_->[0] \n" if $err_rows->[0];
			
		$err_rows=do_query("SELECT $id_name FROM $ns_table WHERE langid=$_->[0] AND MOD((left_key - level + 2),2)=1");
		
		$errors.="Error. Left key should be odd cause level is odd. keys: ".Dumper($err_rows)." lang $_->[0] \n" if $err_rows->[0];
		
		if($total!=do_query("SELECT count($id_name) FROM (SELECT * FROM $ns_table WHERE langid=$_->[0] GROUP BY left_key) AS t1")->[0][0]){
			$errors.="Error. Not unique left key found lang $_->[0] \n";
		}
		if($total!=do_query("SELECT count($id_name) FROM (SELECT * FROM $ns_table WHERE langid=$_->[0] GROUP BY right_key) AS t1")->[0][0]){
			$errors.="Error. Not unique right key found lang $_->[0] \n";
		}
		
	}
	TEST($errors);
	if ($force or $errors) {
		init_nestedset($table, $id_name, $p_id_name, $force,$transl_field,$tree_lang,$transl_table,$transl_id);
	}
	
} # sub init_nested_tree

sub add_element {
	my ($table, $id_name, $p_id_name,  $p_id, $new_id, $skip_checking,$transl_field,$tree_lang,$transl_table,$transl_id) = @_; # also we need to get the parent node there

	my $recurse = 0;
	
	TEST("sub add_element(" . (join ',', @_) . ")");
	
	my $lang_conv;
	$lang_conv=" AND langid=$tree_lang " if $tree_lang; # will be used in all quaries
	
	if (($p_id == $new_id) && ($p_id == 1)) {$p_id = 0} # for category table

	## check for the already added element
	return if do_query("select ".$id_name." from ".$table.$postfix." where ".$id_name." = ".$new_id.$lang_conv)->[0][0];

	## 1. check it
	check_tree($table, $id_name, $p_id_name,$transl_field,$tree_lang,$transl_table,$transl_id) unless $skip_checking; # we need to check it before inserting

	## 2. add it
	# get the parent right key and level
 recurse:
	if ($recurse) {
		add_element($table, $id_name, $p_id_name,  do_query("select ".$p_id_name." from ".$table." where ".$id_name."=".$p_id)->[0][0], $p_id, 'skip_checking',$transl_field,$tree_lang,$transl_table,$transl_id);
		$recurse = 0;
	}
	my $p = do_query("select right_key, level from ".$table.$postfix." where ".$id_name." = ".$p_id.$lang_conv)->[0];
	my $new_right = defined $p->[0] ? $p->[0] : 1;
	my $new_level = defined $p->[1] ? $p->[1] : 0;

	if (($p_id > 1) && ($new_level == 0)) {
		$recurse = 1;
		goto recurse;
	}

	# insert it and correct lefts & rights
#	do_statement("lock tables ".$table.$postfix." write");
	add_sort($table,$postfix,$id_name,$p_id,$new_id,$transl_field,$tree_lang,$transl_table,$transl_id);
#	do_statement("unlock tables");
} # sub add_element



sub add_sort{
	my ($main_table,$postfix,$pk,$parent_id,$new_id,$transl_field,$tree_lang,$transl_table,$transl_id)=@_;
	my $ns_table=$main_table.$postfix;
	my $parent_level=0;
	my $parent_left_key=2;
	my $parent_right_key=1;
	
	my $avialble_langs;
	if($tree_lang){
		$avialble_langs=[[$tree_lang]];
	}else{
		$avialble_langs=do_query("SELECT v.langid FROM $main_table c JOIN $transl_table v USING($transl_id) group by v.langid");
	}
	
	if($new_id==1){# root element		
		for my $lang(@{$avialble_langs}){			
			do_statement("update ".$ns_table." set right_key = right_key + 2, left_key = if(left_key > ".$parent_right_key.", left_key + 2, left_key) where right_key >= ".$parent_right_key." AND langid=".$lang->[0]);
			do_statement("insert into ".$ns_table." set ".$pk." = ".$new_id.", left_key = ".$parent_right_key.", right_key = ".$parent_right_key." + 1, level = ".$parent_level." + 1,langid=".$lang->[0]);
		}
		return 1;
	}
	
	my $time_start=Time::HiRes::time();
	my $query_time=0;
	my $cnt=0;
	for(@$avialble_langs){
		my $lang=$_->[0];
		my $parent_info=do_query("SELECT level,left_key,right_key FROM $ns_table WHERE $pk=$parent_id and langid=".$lang)->[0];
		next() unless($parent_info);
		($parent_level,$parent_left_key,$parent_right_key)=(@$parent_info);
		

		my $query=" SELECT c.$pk,IF(v.value IS NULL OR v.value='',v_en.value,v.value),
					ns.level,ns.left_key,ns.right_key FROM $ns_table ns
					JOIN $main_table c ON c.$pk=ns.$pk
					LEFT JOIN $transl_table v ON v.$transl_id=c.$transl_id AND v.langid=$lang
					JOIN $transl_table v_en ON v_en.$transl_id=c.$transl_id 
					WHERE (left_key>$parent_left_key and right_key<$parent_right_key and level=$parent_level+1)
						 AND ns.langid=$lang AND v_en.langid=1
					ORDER BY v.value";
		
		my $query_time1=Time::HiRes::time();
		my $siblings=do_query($query);
		$query_time+=Time::HiRes::time()-$query_time1;
		my $inserted=do_query("
					SELECT c.$pk,IF(v.value IS NULL OR v.value='',v_en.value,v.value)
					FROM $main_table c
					LEFT JOIN $transl_table v ON v.$transl_id=c.$transl_id AND v.langid=$lang
					JOIN $transl_table v_en ON v_en.$transl_id=c.$transl_id
					WHERE c.$pk=$new_id AND v_en.langid=1")->[0];			
		my $i=0;	
		my $insert_before;
		for my $sibling (@$siblings){
			if(lc($inserted->[1]) lt lc($sibling->[1])){
				$insert_before=$sibling;
				last();
			}
			$i++;
		}
		$cnt=(scalar @$siblings);		
		if((scalar @$siblings)==0 or !$insert_before){# no sibling at all so insert only
			#print "this is the one ".$new_id.' '.$lang."\n";
			do_statement("update ".$ns_table." set right_key = right_key + 2, left_key = if(left_key > ".$parent_right_key.", left_key + 2, left_key) where right_key >= ".$parent_right_key." AND langid=".$lang);
			do_statement("insert into ".$ns_table." set ".$pk." = ".$new_id.", left_key = ".$parent_right_key.", right_key = ".$parent_right_key." + 1, level = ".$parent_level." + 1, langid=".$lang);
			
		}else{# new element are first among siblings. insert it first 
			my($before_level,$before_left_key,$before_right_key)=($insert_before->[2],$insert_before->[3],$insert_before->[4]);
			do_statement("UPDATE $ns_table SET right_key = right_key + 2  
							WHERE right_key > $before_right_key AND left_key < $before_right_key AND langid=".$lang);	
			do_statement("UPDATE $ns_table SET left_key = left_key + 2, right_key = right_key + 2	 
						   WHERE left_key >= $before_left_key AND langid=".$lang);	
			do_statement("INSERT INTO $ns_table SET left_key = $before_left_key, 
							right_key = $before_left_key+1, 
							level = $before_level, $pk=$new_id, langid=".$lang);			
		}		
		#my $total=do_query(" SELECT COUNT($pk)FROM $ns_table WHERE langid=$lang")->[0][0];
		#if($total!=do_query("SELECT count($pk) FROM (SELECT * FROM $ns_table WHERE langid=$lang GROUP BY left_key) AS t1")->[0][0]){
		#	print  "Error. Not unique left key found lang $lang \n";
		#}
	}
	TEST("$pk ----->>>>$new_id  $parent_left_key $parent_right_key \n
	Total siblings >>>>>>>".$cnt.">\n
	SELECT SIBLING takes --> ".$query_time."\n
	FOREACH takes --> ".(Time::HiRes::time()-$time_start));	
}

sub delete_element {
	my ($table, $id_name, $p_id_name, $removed_id,$transl_field,$transl_table,$transl_id) = @_; # also we need the parent node there

	TEST("sub delete_element(" . (join ',', @_) . ")");

	## 1. check it
	check_tree($table, $id_name, $p_id_name); # we need to check it before inserting
	my $avialble_langs=do_query("SELECT v.langid FROM $table c JOIN $transl_table v USING($transl_id) group by v.langid");
	for(@{$avialble_langs}){
		my $lang=$_->[0];	
		## 2. remove it
		# get the left & right keys
		my $p = do_query("select left_key, right_key from ".$table.$postfix." where ".$id_name." = ".$removed_id." AND langid=".$lang)->[0];
		my $old_left = $p->[0];
		my $old_right = $p->[1];
		next() unless $p->[0] || $p->[1];
	
		# remove it
#	do_statement("lock tables ".$table.$postfix." write");
		do_statement("delete from ".$table.$postfix." where left_key >= ".$old_left." and right_key <= ".$old_right." AND langid=".$lang);
		do_statement("update ".$table.$postfix." set left_key = if(left_key > ".$old_left.", left_key - (".$old_right." - ".$old_left." + 1), left_key), right_key = right_key - (".$old_right." - ".$old_left." + 1) where right_key > ".$old_right." AND langid=".$lang);
#	do_statement("unlock tables");
	}
} # sub delete_element

sub move_element {
	my ($table, $id_name, $p_id_name,  $new_p_id, $moved_id,$transl_field,$transl_table,$transl_id) = @_; # check the parameters

	TEST("sub move_element(" . (join ',', @_) . ")");

	## 1. check it
	check_tree($table, $id_name, $p_id_name); # we need to check it before inserting

	## 2. is this available at all???

	my $avialble_langs=do_query("SELECT v.langid FROM $table c JOIN $transl_table v USING($transl_id) group by v.langid");
	for(@{$avialble_langs}){
		my $lang=$_->[0];
		## 3. move it
		# get all necessary variables
		my $p = do_query("select left_key, right_key, level from ".$table.$postfix." where ".$id_name." = ".$moved_id.' AND langid='.$lang)->[0];
		my $old_left = $p->[0];
		my $old_right = $p->[1];
		my $old_level = $p->[2];		
		return undef unless $p->[0] || $p->[1] || defined $p->[2];
	
		# get the level of new_parent, get the new right key near
		$p = do_query("select level, left_key, right_key from ".$table.$postfix." where ".$id_name." = ".$new_p_id.' AND langid='.$lang)->[0];
		my ($parent_level,$parent_left_key,$parent_right_key)=(@$p);
		# figure out parent new_right_near by using sorting

		my $query=" SELECT c.$id_name,IF(v.value IS NULL OR v.value='',v_en.value,v.value),
					ns.level,ns.left_key,ns.right_key FROM ".$table.$postfix." ns
					JOIN $table c ON c.$id_name=ns.$id_name
					LEFT JOIN $transl_table v ON v.$transl_id=c.$transl_id AND v.langid=$lang
					JOIN $transl_table v_en ON v_en.$transl_id=c.$transl_id AND v_en.langid=1
					WHERE (left_key>$parent_left_key and right_key<$parent_right_key and level=$parent_level+1)
						 AND ns.langid=$lang
					ORDER BY v.value";
		
		my $siblings=do_query($query);
		my $inserted=do_query("
					SELECT c.$id_name,IF(v.value IS NULL OR v.value='',v_en.value,v.value)
					FROM $table c
					LEFT JOIN $transl_table v ON v.$transl_id=c.$transl_id AND v.langid=$lang
					JOIN $transl_table v_en ON v_en.$transl_id=c.$transl_id AND v_en.langid=1
					WHERE c.$id_name=$moved_id")->[0];			
		my $insert_after;
		my $i=0;
		for my $sibling (@$siblings){
			if(lc($inserted->[1]) lt lc($sibling->[1])){
				last();
			}
			$i++;
			$insert_after=$siblings->[$i-1];
		}
		
		my $new_right_near;
		if($insert_after){ 
			$new_right_near=$insert_after->[4];
		}else{
		 	$new_right_near=$parent_left_key;			
		}
		# get the skews
		my $skew_level = $parent_level - $old_level + 1;
		my $skew_tree = $old_right - $old_left + 1;
		# compare the right and new_right_near
		my $skew_edit;
		if ($old_right < $new_right_near) { # to the smallest knots
			$skew_edit = $new_right_near - $old_left + 1 - $skew_tree;
			do_statement("update ".$table.$postfix."
	set left_key = if(right_key <= ".$old_right.", left_key + ".$skew_edit.", if(left_key > ".$old_right.", left_key - ".$skew_tree.", left_key)),
	level = if(right_key <= ".$old_right.", level + ".$skew_level.", level),
	right_key = if(right_key <= ".$old_right.", right_key + ".$skew_edit.", if(right_key <= ".$new_right_near.", right_key - ".$skew_tree.", right_key))
	where right_key > ".$old_left." and left_key <= ".$new_right_near.' AND langid='.$lang);
		}
		elsif ($old_right > $new_right_near) { # to the biggest knots
			$skew_edit = $new_right_near - $old_left + 1;
			do_statement("update ".$table.$postfix."
	set right_key = if(left_key >= ".$old_left.", right_key + ".$skew_edit.", if(right_key < ".$old_left.", right_key + ".$skew_tree.", right_key)),
	level = if(left_key >= ".$old_left.", level + ".$skew_level.", level),
	left_key = if(left_key >= ".$old_left.", left_key + ".$skew_edit.", if(left_key > ".$new_right_near.", left_key + ".$skew_tree.", left_key))
	where right_key > ".$new_right_near." and left_key < ".$old_right.' AND langid='.$lang);
		}
		else {
			log_printf("FATAL! Something strange there!!! right $old_right equals new_right_near $new_right_near");
		}
	}#for lang
} # sub move_element

sub merge_elements{
	my ($table, $id_name, $p_id_name, $merged_id,$new_p_id,$transl_field,$transl_table,$transl_id) = @_; # check the parameters
	my $ns_table=$table.$postfix;
	my $merged_params=do_query("SELECT level,left_key,right_key,langid FROM $ns_table 
					   			 WHERE $id_name=$merged_id AND langid=1")->[0];
	return '' unless($merged_params);
	my ($merged_level,$merged_left_key,$merged_right_key,$merged_langid)=(@$merged_params);
	my $merged_childs=do_query("SELECT $id_name,left_key,right_key,level,langid FROM $ns_table
								 WHERE left_key>$merged_left_key AND right_key<$merged_right_key AND langid=1");
	if($merged_childs){
		for my $merged_child (@$merged_childs){
			move_element($table, $id_name, $p_id_name, $new_p_id, $merged_child->[0],$transl_field,$transl_table,$transl_id);			
		};
	}
	delete_element($table, $id_name, $p_id_name, $merged_id,$transl_field,$transl_table,$transl_id);	
}
1;

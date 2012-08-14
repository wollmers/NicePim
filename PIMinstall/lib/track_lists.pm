package track_lists;

use strict;

use atomcfg;
use atomsql;
use atomcfg;
use atomlog;

use Data::Dumper;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
  				&add_track_product_rule
  				&delete_track_product_rule
			  );
}
								
sub add_track_product_rule{
	my ($track_product_id)=@_;
	my $params=&do_query('SELECT tp.rule_prod_id,tp.feed_prod_id,tp.is_reverse_rule,tp.track_list_id,tl.name,tp.supplier_id,s.name 
						  FROM track_product tp JOIN track_list tl USING(track_list_id)
						  JOIN supplier s USING(supplier_id) 
						  WHERE track_product_id='.$track_product_id);
	my $track_list_rules;						  
	if($params->[0][0]){
		$track_list_rules=&do_query('SELECT product_map_id, code, pattern FROM product_map 
									 WHERE track_list_id='.$params->[0][3].' AND supplier_id='.$params->[0][5])->[0];		
	}else{
		&lp('Err in add_track_product_rule: track_product does not exists');
		return '';
	}
	if(!$params->[0][5]){# no suplier_id. ignore the rule
		return 0;
	};
	my $rule;
	my $all_rules=$track_list_rules->[2];
	if($params->[0][0] eq $params->[0][1] or !$params->[0][1] or !$params->[0][0]){# rule is invalid or no sense to add the rule. it's  mapped to itself 
		return '';
	}
	if($params->[0][2]){# this is a reverse rule 
		$rule=$params->[0][0].'='.$params->[0][1];
	}else{
		$rule=$params->[0][1].'='.$params->[0][0];
	}
	my $tmp_str=$rule."\n";
	
	if(ref($track_list_rules) eq 'ARRAY' and !$track_list_rules->[0]){
		&do_statement("INSERT INTO product_map SET
						 code= ".&str_sqlize('Track list: '.$params->[0][4].','.$params->[0][6]).",
						 pattern= ".&str_sqlize($rule."\n").",
						 supplier_id=$params->[0][5],
						 track_list_id= $params->[0][3]");
	}elsif($all_rules!~/\Q$tmp_str\E/i){
		$all_rules.=$rule."\n";
		&lp('----------------------->>>>>>>>>>>>>>'.$params->[0][5]);
		&do_statement("UPDATE product_map SET						 
						 pattern= ".&str_sqlize($all_rules)."
						 WHERE track_list_id= $params->[0][3] and supplier_id=".$params->[0][5]);
	}
	if($params->[0][2]){# this is reverse rule. change the partcode from  corresponding product 
		my $source_product_id=&do_query('SELECT product_id FROM product 
										 WHERE supplier_id='.$params->[0][5].' AND prod_id='.&str_sqlize($params->[0][0]))->[0][0];
		if($source_product_id and $params->[0][1]){
			&do_statement('UPDATE product SET prod_id='.&str_sqlize($params->[0][1]).' WHERE product_id='.$source_product_id);			
		}else{
			&lp('Err in add_track_product_rule: cant change the product with partcode '.$params->[0][0]);
		}		
	}
	&do_statement('UPDATE track_product SET rule_status=2 WHERE track_product_id='.$track_product_id);
	return 1;		
}

sub delete_track_product_rule{
	my ($track_product_id)=@_;
	my $params=&do_query('SELECT tp.rule_prod_id,tp.feed_prod_id,tp.is_reverse_rule,tp.track_list_id,tl.name,tp.supplier_id,tp.rule_status 
						  FROM track_product tp JOIN track_list tl USING(track_list_id) 
						  WHERE track_product_id='.$track_product_id);
	my $track_list_rules;						  
	if($params->[0][0]){
		$track_list_rules=&do_query('SELECT product_map_id, code, pattern FROM product_map WHERE track_list_id='.$params->[0][3])->[0];		
	}else{
		&lp('Err in delete_track_product_rule: track_product does not exists');
		return '';
	}
	my $rule;
	my $all_rules=$track_list_rules->[2];
	if($params->[0][2]){# this is a reverse rule 
		$rule=$params->[0][0].'='.$params->[0][1];
	}else{
		$rule=$params->[0][1].'='.$params->[0][0];
	}
	my $tmp_str=$rule."\n";
	if($all_rules=~/\Q$tmp_str\E/i){
		$all_rules=~s/\Q$tmp_str\E//i;# remove the rule
		&do_statement("UPDATE product_map SET						 
						 pattern= ".&str_sqlize($all_rules)."
						 WHERE track_list_id= $params->[0][3] and supplier_id=$params->[0][5]");
		&do_statement("UPDATE track_product SET remarks='',product_id=0,rule_status=1,map_prod_id=feed_prod_id,extr_quality='' 
				   WHERE track_product_id = $track_product_id");
		&lp('----------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
		#if(!$params->[0][2]){# if this is not reverse rule try to roolback to previous 
		#	&do_statement("UPDATE track_product SET rule_prod_id='', product_id=0 WHERE rule_prod_id=".&str_sqlize($params->[0][0]))
		#}								 
	}else{	
		&do_statement("UPDATE track_product SET remarks='',rule_prod_id='',rule_user_id=0,is_reverse_rule=0  
				   WHERE track_product_id = $track_product_id");
	}  
	return 1; 
}

1;
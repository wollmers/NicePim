#
# This package enhances DBI interface to make it extremly useful in the
# environment.
#

package atomsql;
use DBI;

#$Id: atomsql.pm 3743 2011-01-19 16:39:34Z alexey $

use vars qw ($dbh %describen_tables $debug $requests $speedy_mode %slaves_dbh);
use vars qw ($debug_db_on $current_ts $current_day);

# These register globals
use atomcfg;
use atomlog;
use atom_util;
use strict;
use Encode;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(
							 &describe_table
							 &get_rows
							 &get_row
							 &update_rows
							 &insert_rows
							 &do_query
							 &do_query_sequenced
							 &delete_rows
							 &str_sqlize
							 &str_unsqlize
							 &to_like_operand
							 &sql_date
							 &insert_rows_ifne
							 &sql_last_insert_id
							 &do_statement
							 &do_query_dump
							 &get_primary_key_set_of_ranges
							 &primary_key_from_table
							 &register_slave
							 &unregister_slave
							 &unregister_main
							 &init_connection
							 &close_connection
							 &make_slave_host
							 &table_exists
							 );
	
}

init_connection();

END {
	close_connection();
}

sub table_exists{
	my ($table,$slave_name) = @_;
	my ($sth,@nw,@row,$rv,$debug);
	my $select='DESC '.$table;
	$debug = $storesql::debug;
	if (substr($select,0,1) eq '*') { $debug = 1; $select = substr($select,1); }
	sql_log($select);	
	
	if($slave_name and ref($slaves_dbh{$slave_name}) ne ref($dbh)){
		log_printf("Slave ' $slave_name ' was not registered pls use atomsql::register_slave(slave_name,host,user,pass) to register it");
		error_prepare($select); return [];
	}elsif($slave_name and ref($slaves_dbh{$slave_name}) eq ref($dbh)){
		$sth=$slaves_dbh{$slave_name}->prepare($select)		
	}else{
		$sth = $dbh->prepare($select);
	}
	
	$rv = $sth->execute;
	if (!$rv) {
		return '';
	}else{
		return 1;
	}
}

sub push_a_nmtable {
	my ($nmt,$dbt,$value) = @_;	my (%nh,$i);
#	log_printf("push_a_nmtable(nmt = %s, dbt = %s, value = %s)",
#		join('|',@{$nmt}), join('|',@{$dbt}), join('|',@{$value}) );
	for ($i = 0; $i <= $#{$dbt}; $i ++) {	$nh{$dbt->[$i]} = $value->[$i]; }
	push (@{$nmt}, \%nh);
}


sub sql_last_insert_id
{
	return do_query("SELECT LAST_INSERT_ID()")->[0][0];
}

sub sql_date
{
	my @a = localtime($_[0]);
	return sprintf("%04d%02d%02d%02d%02d%02d",$a[5]<1900?$a[5]+1900:$a[5],$a[4]+1,
	               $a[3], $a[2], $a[1], $a[0]);
}

sub str_unsqlize
{
	my $str = $_[0];

	if ($str =~ /^\'(.*)\'$/g) { # only if quoted
		$str = $1;
		$str =~ s/\\\'/\'/g;
		$str =~ s/\\\\/\\/g;
	}
	
	return $str;
}

sub str_sqlize {
	my $str = $_[0];

	$str =~ s/\\/\\\\/g;
	$str =~ s/\'/\\\'/g;
	$str = "\'".$str."\'";

	return $str;
}

sub to_like_operand {
	my $str = $_[0];

	return $str if $str !~ /[\w\.]/;

	return "replace(replace(replace(".$str.",'_','\\_'),'%','\\%'),'*','%')";
}

sub describe_table {
	my ($tablename) = @_;
	my ($sth,$rv,@row,$h,$i);
	
	if ($describen_tables{$tablename}) {
		return $describen_tables{$tablename};
	}
	
	$sth = $dbh->prepare("show columns from $tablename");
	if (!$sth) {
		error_prepare("show columns from $tablename");
		return [];
	}
	$rv = $sth->execute;
	if (!$rv) {
		error_execute("show columns from $tablename");
		return [];
	}
	$requests++;
	
	$h = []; $i = 0;
	while (@row = $sth->fetchrow_array) {
		$h->[$i] = $row[0]; $i++;
	}
	$describen_tables{$tablename} = $h;
	$rv=$sth->finish;
	
	if ($storesql::debug) {
		log_printf('storesql: describing '.$tablename.' '.join('|',@$h));
	}
	
	return $h;
}

sub get_rows {
	my ($tablename,$where,$orderby,$limit,$ofs) = @_;
	my ($select,$debug,$dbt,$sth,$nrw,$rv,@row);

	$debug = $storesql::debug;
	
	
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	$dbt = describe_table($tablename);
	
	$nrw = [];

	if ($limit && $limit <= 0) {
		error_printf('get_rows $limit == %d <= 0 Table: %s', $limit, $tablename);
		return $nrw;
	}
	
	if ($ofs && $ofs <= 0) {
		error_printf('get_rows $ofs == %d <= 0 Table: %s', $ofs, $tablename);
		return $nrw;
	}
	
# check if $dbt is empty => do nothing.
	$select = 'SELECT * FROM '.$tablename;
#	if ($where && $where ne '') { $select .= ' WHERE '.$where; }
#	if ($orderby && $orderby ne '') { $select .= ' ORDER BY '.$orderby; }

	if ($where) { $select .= ' WHERE '.$where; }
	if ($orderby) { $select .= ' ORDER BY '.$orderby; }

	if ($ofs) { $select .= " LIMIT $ofs,$limit"; }
	elsif ($limit) { $select .= " LIMIT $limit"; }

	$sth = $dbh->prepare($select);
	if (!$sth) {
		error_prepare($select);
		return $nrw;
	}
	$rv = $sth->execute;
	if (!$rv) {
		error_execute($select);
		return $nrw;
	}
	$requests++;

#	if ($debug) { log_printf('get_rows statement '.$select); }
	
#	while (@row = $sth->fetchrow_array) {	push_a_nmtable($nrw,$dbt,\@row); }

my $row;	
 while ($row = $sth->fetchrow_arrayref) {
	 for (my $i = 0; $i <= $#{$dbt}; $i ++) {
		 Encode::_utf8_on($row->[$i]);
	 }
	 push_a_nmtable($nrw,$dbt,$row);
 }

	$rv=$sth->finish;
	return $nrw;
}

sub get_row {
	my ($tablename,$where,$orderby,$ofs) = @_;
	my ($select,$debug,$dbt,$sth,$nh,$rv,@row,$i);
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }

	if ($ofs && $ofs <= 0) {
		error_printf('get_rows $ofs == %d <= 0 Table: %s', $ofs, $tablename);
		return {};
	}
	
	$dbt = describe_table($tablename);
	
# check if $dbt is empty => do nothing.
	$select = 'SELECT * FROM '.$tablename;
	if ($where && $where ne '') { $select .= ' WHERE '.$where; }
	if ($orderby && $orderby ne '') { $select .= ' ORDER BY '.$orderby; }
	if ($ofs) { $select .= " LIMIT $ofs,1"; }
	else { $select .= " LIMIT 1"; }
	
	$sth = $dbh->prepare($select);
	if (!$sth) {
		error_prepare($select);
		return {};
	}
	$rv = $sth->execute;
	if (!$rv) {
		error_execute($select);
		return {};
	}
	$requests++;
	
	if ($debug) { log_printf('get_rows statement %s',$select); }
	
	$nh = {};
	if (@row = $sth->fetchrow_array) {
		for ($i = 0; $i <= $#{$dbt}; $i ++) {
			Encode::_utf8_on($row[$i]);
			$nh->{$dbt->[$i]} = $row[$i];
		}
	}
	
	$rv=$sth->finish;
	
	return $nh;
}

sub update_rows {
	my ($tablename,$where,$fields) = @_;
	my ($stmt,$i,$isgood,$debug,$rv);
	
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	if (!$where) {
		log_printf("Warning: update_rows called without where clause.... NO WAY! Table: $tablename");
		return 0;
	}
	
	$stmt = "UPDATE $tablename SET";
	$isgood = 0;
	if ($fields) {
		for $i (keys %$fields) {
			if ($isgood) { $stmt .= ","; }
			#Encode::_utf8_on($fields->{$i});
			$stmt .= " ".$i." = ".$fields->{$i};
			$isgood = 1;
		}
	}
	
	if (!$isgood) {
		log_printf("Warning: update_rows called without fields specified.... Table: $tablename");
		return 0;
	}
	
	$stmt .= " WHERE ".$where;
	
	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("update_rows stmt $stmt");	}
	sql_log($stmt);
	
	return $rv;
}

## hash with autoinserted fields/values for specified tables
## used in 'insert_rows_ifne' and 'insert_rows'
my $AUTO_FIELDS = { 'product' => {'date_added'=>'now()'} };

sub insert_rows_ifne {
	my ($tablename,$fields) = @_;
	my ($stmt,$i,$debug,$rv);
	my @fld_list;
	my @val_list;
	
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	if ($fields) {
		for $i (keys %$fields) {
			if(!defined $AUTO_FIELDS->{$tablename}->{$i}) {
				push @fld_list, $i;
				push @val_list, $fields->{$i};
			}
		}
	}

	if (!defined $fld_list[0]) {
		log_printf("Warning: insert_rows called without fields specified.... Table: $tablename");
		return 0;
	}

	if (defined $AUTO_FIELDS->{$tablename}) { ## $tablename was found in AUTO_FIELDS
		for $i (keys %{$AUTO_FIELDS->{$tablename}}) {
			push @fld_list, $i;
			push @val_list, $AUTO_FIELDS->{$tablename}->{$i};
		}
	}

	$stmt = "INSERT INTO $tablename (".join(',',@fld_list).") VALUES (".join(',',@val_list).")";
	
	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		return 0;
	}
	
	if ($debug) {	log_printf("insert_rows stmt $stmt");	}
	sql_log($stmt);
	
	return $rv;
}

sub insert_rows {
	my ($tablename,$fields) = @_;
	my ($stmt,$i,$debug,$rv);
	my @fld_list;
	my @val_list;
	
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }

	if ($fields) {
		for $i (keys %$fields) {
			if(!defined $AUTO_FIELDS->{$tablename}->{$i}) {
				push @fld_list, $i;
				push @val_list, $fields->{$i};
			}
		}
	}

	if (!defined $fld_list[0]) {
		log_printf("Warning: insert_rows called without fields specified.... Table: $tablename");
		return 0;
	}

	if (defined $AUTO_FIELDS->{$tablename}) { ## $tablename was found in AUTO_FIELDS
		for $i (keys %{$AUTO_FIELDS->{$tablename}}) {
			push @fld_list, $i;
			push @val_list, $AUTO_FIELDS->{$tablename}->{$i};
		}
	}
	
	$stmt = "INSERT INTO $tablename (".join(',',@fld_list).") VALUES (".join(',',@val_list).")";

	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("insert_rows stmt $stmt");	}
	sql_log($stmt);
	
	return $rv;
}

sub do_query {
	my ($select,$slave_name) = @_;
	my ($sth,@nw,@row,$rv,$debug);

	$debug = $storesql::debug;
	if (substr($select,0,1) eq '*') { $debug = 1; $select = substr($select,1); }
	sql_log($select);	
	
	if($slave_name and ref($slaves_dbh{$slave_name}) ne ref($dbh)){
		log_printf("Slave ' $slave_name ' was not registered pls use atomsql::register_slave(slave_name,host,user,pass) to register it");
		error_prepare($select); return [];
	}elsif($slave_name and ref($slaves_dbh{$slave_name}) eq ref($dbh)){
		$sth=$slaves_dbh{$slave_name}->prepare($select)		
	}else{
		$sth = $dbh->prepare($select);
	}
	
	if (!$sth) { error_prepare($select); return []; }
	$rv = $sth->execute;
	$requests++ if !$slave_name;
	if (!$rv) {				
				error_execute($select,$slave_name); return []; }

	while (@row = $sth->fetchrow_array) {
		for (my $i=0;$i<=$#row;$i++) {
			Encode::_utf8_on($row[$i]);
		}
		push(@nw,[@row]);
	}

	$rv=$sth->finish;
	if ($debug) { log_printf("do_query stmt $select"); }
	
	return [@nw];
} # sub do_query

sub do_query_sequenced {
	my ($select, $params) = @_;

	my @nw = ();

	# decide what we have - query or statement
	my $whatWeHave = '';
	if ($select =~ /^\s*(?:select|show|explain)/is) {
		$whatWeHave = 'query';
	}
	else {
		$whatWeHave = 'statement';
	}

	# skip the multi-dimensional requests
	my @splitter = ();
	@splitter = split /select/si, $select;

	if (($#splitter != 1) && ($whatWeHave eq 'query')) {
		log_printf("It is the multi-dimensional request, doing the do_".$whatWeHave." instead");
		if ($whatWeHave eq 'query') {
			goto default_way;
		}
		else {
			goto default_way_statement;
		}
	}

	# add insert INTO

	if ($select =~ /^(?:(?:insert|replace)\s+.*)?\s*(?:select|delete|update|insert)/i) { # do this
		# get the table name (or alias)
		my $nameOrAlias = $select;
		$nameOrAlias =~ s/^(?:(?:insert|replace)\s+.*)?\s*(?:select|delete|update|insert)\s+.+?\s+from\s+((?:[a-zA-Z0-9_]+)(?:\s+(?:as\s+)?(?:[a-zA-Z0-9_]+))?)\s*?(?:where|[(?:inner|left)\s+]?join|(?:group|order)\s+by|limit)?.*?$/$1/is; # we get all we want
#		print $nameOrAlias . "\n";

		if ($nameOrAlias =~ /^([a-zA-Z0-9_]+)(?:\s+(?:as\s+)?([a-zA-Z0-9_]+))?$/s) {
			# get their name and alias
			my ($name, $alias) = ($1, $2);

			# get the ranges
			my @ranges = get_primary_key_set_of_ranges($alias, $name, $params->{'delimiter'} || undef);

			# determine the place, where the condition will be pasted - and mark it as |||
			my $pselect = '';

			print $select . "\n";

			if ($select =~ /where/is) { # put it after where
				$select =~ s/(where\s+)(.+)(\s+group|\s+order|\s+limit|$)/$1||| and $2$3/si;
			}
			else {
				$select =~ s/((?:\s+group|\s+order|\s+limit|$))/ where |||$1/si;
			}

			log_printf("Do the sequenced do_".$whatWeHave."-s ". ( $#ranges + 1 ) ." times");

			my $nwpart;

			# do this!
			for (@ranges) {
				$pselect = $select;
				$pselect =~ s/\|\|\|/$_/s;

				if ($whatWeHave eq 'query') {
					$nwpart = do_query($pselect);
					for (@$nwpart) {
						push @nw, $_;
					}
				}
				else {
					do_statement($pselect);
				}
			}

			if ($whatWeHave eq 'query') {
				return [@nw];
			}
			else {
				return;
			}
		}
		else { # bad SQL syntax, do the default do_query sub instead
			log_printf("Bad SQL syntax for sequences");
			if ($whatWeHave eq 'query') {
				goto default_way;
			}
			else {
				goto default_way_statement;
			}
		}
	}
	else {
	default_way:
		return do_query($select);
	}

	default_way_statement:
	do_statement($select);
} # sub do_query_sequenced

sub do_query_dump {
	my ($select) = @_;
	my $res = do_query($select);
	return undef unless $res;
	my $out;
	for (@$res) {
		$out .= join ("\t", @$_);
		$out .= "\n";
	}
	return $out;
} # sub do_query_dump

sub do_statement {
	my ($select,$slave_name) = @_;
	my ($sth,@nw,@row,$rv);
	
	if($slave_name and ref($slaves_dbh{$slave_name}) ne ref($dbh)){
		log_printf("Slave ' $slave_name ' was not registered pls use atomsql::register_slave(slave_name,host,user,pass) to register it");
		error_prepare($select); return [];
	}elsif($slave_name and ref($slaves_dbh{$slave_name}) eq ref($dbh)){
		$sth=$slaves_dbh{$slave_name}->prepare($select);	
	}else{
		$sth = $dbh->prepare($select);
	}
	
	if (!$sth) {; 
		error_prepare($select); return []; }
	$rv = $sth->execute;
	$requests++ if !$slave_name;
	if (!$rv) {	
		error_execute($select,$slave_name); return []; }
	
	$rv=$sth->finish;

	sql_log($select);
	
}

sub delete_rows {
	my ($tablename,$where) = @_;
	my ($stmt,$i,$isgood,$debug,$rv);
	
	$debug = 0;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	if (!$where) {
		log_printf("Warning: delete_rows called without where clause.... NO WAY! Table: $tablename");
		return 0;
	}
	
	$stmt = "delete from $tablename where ".$where;

	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("delete_rows stmt $stmt");	}
	sql_log($stmt);
	
	return $rv;
}

# getting primary key from a table
sub primary_key_from_table {
	my ($table) = @_;

	chomp($table);

	return undef unless $table;

	my $indexes = do_query("show index from ".$table);

	for (@$indexes) {
		if ($_->[2] eq 'PRIMARY') {
			return $_->[4];
		}
	}

	return undef;
} # sub primary_key_from_table

sub get_primary_key_set_of_ranges {
	my ($pk_alias,$table,$delim,$pk) = @_;

	$pk = primary_key_from_table($table) unless $pk;
	my $max_pk = do_query("select max($pk) from $table")->[0][0];
	my $betweens = undef;
	my $init = 1;
	$delim = 100000 if ((!$delim) || ($delim !~ /^\d+$/s));

	if (($pk) && ($max_pk > $delim)) {
		$pk_alias = $pk_alias || $table;
		while ($init <= $max_pk) {
			push @$betweens, $pk_alias.".".$pk.' between '.$init.' and '. ( $init + $delim - 1 );
			$init += $delim;
		}
	}
	else {
		push @$betweens, '1';
	}

	return @$betweens;
} # sub get_primary_key_set_of_ranges

# Logging SQL queries
sub sql_log {
	my $query = join(";\n",@_).";\n";

	atom_util::push_dmesg(3,"SQL QUERY:$query");

	# USE FILTERING 
	if (!($query=~/^\s*select/si) && 0) {
    open(LOG,">>$atomcfg{'sql_log_path'}/$atomcfg{'sql_log_file'}");
		flock(LOF,2);
		binmode(LOG,":utf8");
		print LOG $query;
		close(LOG);
		flock(LOG,4); 
		
	}
}

sub register_slave {
	my($slave_name,$host,$user,$pass)=@_;
	my $db = $atomcfg{dbname};
	my $str = "DBI:mysql:$db:$host;mysql_local_infile=1";
	my $triesToConnect=1;
	my $triesToConnectMax=10;

	if (ref($slaves_dbh{$slave_name}) eq ref($dbh) and $slaves_dbh{$slave_name}->ping()) { # we already have this slave
		return 1;
	}
	
 try:
	my $dbh = DBI->connect($str,$user,$pass,{PrintError=>1,AutoCommit=>1});
	if (!$dbh) {
		$triesToConnect++;
		if ($triesToConnect > $triesToConnectMax) {
			error_dbopen($str.":$user,$pass");
		}
		else {
			sleep(1);
			goto try;
		}
	}
	log_printf("atomsql.pm: database connected on slave: " .
							"$slave_name, host: $host, " . $triesToConnect . " try");
  	$dbh->{mysql_auto_reconnect} = 1;
	my $rv = $dbh->do("set names utf8");
	$slaves_dbh{$slave_name}=$dbh;
}

sub make_slave_host{
	my ($slave_name)=@_;
	unregister_main();
	if($slaves_dbh{$slave_name} and ref($slaves_dbh{$slave_name}) eq 'DBI::db'){
		$dbh=$slaves_dbh{$slave_name};
		return 1;
	}else{
#		lp('!!!!!!!!!!!!!!!!!!!!!!make_slave_main failed: no connection to db');
		return '';
	}
}

sub unregister_slave{
	my($slave_name)=@_;	
	if($slave_name and ref($slaves_dbh{$slave_name}) eq ref($dbh)){
		$slaves_dbh{$slave_name}->disconnect();
	}
	delete $slaves_dbh{$slave_name};
}

sub unregister_main {
	if (ref($dbh) eq 'DBI::db') {
		$dbh->disconnect();
	}
	$dbh->disconnect();
}

sub init_connection {
	my ($str,$user,$pass,$rv,$db,$triesToConnect,$triesToConnectMax);

	$requests = 0;
	%slaves_dbh = (); # a hash that stores info about connections to slaves_dbh
	$storesql::debug = 0;
	$triesToConnectMax = 10;
	$triesToConnect = 1;
	$db = $atomcfg{dbname};
	if ($debug_lib::debug_on && $atomcfg{debug_db}) {
		$db = $atomcfg{debug_db};
		$str = "DBI:mysql:$db:$atomcfg{dbhost};mysql_local_infile=1";
	} elsif ($debug_lib1::debug_on && $atomcfg{debug_db_1}) {
		$db = $atomcfg{debug_db_1};
		$str = "DBI:mysql:$db:$atomcfg{dbhost};mysql_local_infile=1";
	}	else {
	  $str = "DBI:mysql:$db:$atomcfg{dbhost};mysql_local_infile=1";
	}
	$user = $atomcfg{dbuser};
	$pass = $atomcfg{dbpass};
	$speedy_mode = 0;

 try:
	$dbh = DBI->connect($str, $user, $pass, {PrintError => 1, AutoCommit => 1});
	if (!$dbh) {
		$triesToConnect++;
		if ($triesToConnect > $triesToConnectMax) {
			error_dbopen($str.":$user,$pass");
		}
		else {
			sleep(1);
			goto try;
		}
	}
	log_printf("atomsql.pm: database `" . $db . ':' . $atomcfg{dbhost} . "` connected, ".$triesToConnect." try");

  $dbh->{mysql_auto_reconnect} = 1;
	$rv = $dbh->do("set names utf8");

	my $sth = $dbh->prepare("select unix_timestamp()");
	my $rv = $sth->execute;
	my @row = $sth->fetchrow_array;
	$current_ts = $row[0];

	$sth = $dbh->prepare("select now()");
	$rv = $sth->execute;
	@row = $sth->fetchrow_array;
	$current_day = $row[0];
	$current_day =~ s/\s+.+$//s;

#	log_printf("timestamp = `".$current_ts."`");
#	log_printf("day = `".$current_day."`");
	
}
sub close_connection{
	log_printf("atomsql.pm: did $requests requests");
	if(!$speedy_mode){
		for my $key( keys %slaves_dbh){
			$slaves_dbh{$key}->disconnect if(ref($slaves_dbh{$key}) eq ref($dbh));
		}
	}
	
	if(!$speedy_mode){
		$dbh->disconnect;
	}
}
1;

=head1 NAME

storesql - a package that should be used for regular SQL access.

=head1 SYNOPSIS

  use storesql;
	
  # connection is made automatically to database, specified in config file

  $descr = describe_table("tablename");
  # now $descr is reference to array, that contains names of each column,
  # that is hold inside of the table `tablename'

  $nm = get_rows("tablename", "where clause", "order by", limit, ofs)
  # retrieves an nmtable object, that is got, by using of statement
  # SELECT * FROM tablename WHERE where clause ORDER BY order by LIMIT ofs,limit
  # get_rows can also be called in these ways:
  $nm = get_rows("tablename", "where clause", "order by", limit);
  $nm = get_rows("tablename", "where clause", "order by");
  $nm = get_rows("tablename", "where clause");
  $nm = get_rows("tablename");
  # please consider, that doing last query can result in enormously big table,
  # and perl will drop a core dump.

  $rows_updated = update_rows("tablename", "where clause",
                   { 'field_1' => str_sqlize('alpha'), 'field_2' => '1' } );
  # this will generate UPDATE statement for supplied parameters.
  # if 0 rows are updated '0E0' is returned.

	$rows_updated = insert_rows("tablename",
                   { 'field_1' => str_sqlize('alpha'), 'field_2' => '1' } );
  # this will generate UPDATE statement for supplied parameters.

	$rows_updated = delete_rows("tablename", "where clause");
  # this will generate UPDATE statement for supplied parameters.

  # all these functions returns number of rows affected.

=head1 DESCRIPTION

=over 100

=item General behaviour.

Module automatically connects to DB, as specified in config file, if
it unable to connect - it'll write to logs and bail out. If local
$storesql::debug is equal to 1, then all database usage will be logged
into a log files.

=item $nm = get_rows($tablename, $where, $orderby, $lim, $ofs)

Returns an $nm table with named columns by using select statement.
$nm has structure:
  $nm is a reference to array of rows.
  $nm->[i] is a reference to a hash, which corresponds to i-th row.
  $nm->[i]->{'colname'} is a data in i-th row, in column named colname.

Statement is composed by this algorythm:

SELECT * FROM $tablename [WHERE $where] [ORDER BY $orderby] [LIMIT [$ofs,]$lim]

If $orderby or $where is equal to '' the function considers as they're absent.

=item $fields = get_row($tablename, $where, $orderby, $lim, $ofs)

Returns a $fields reference to a hash by using select statement. This function
returns exactly ONE row.

Statement is composed by this algorythm:

SELECT * FROM $tablename [WHERE $where] [ORDER BY $orderby] LIMIT [$ofs,] 1

If $orderby or $where is equal to '' the function considers as they're absent,
so you can specify $ofs without where and orderby clauses.

=item $rows_affected = update_rows($tablename,$where,$fields)

Launches UPDATE statement on table $tablename, by using $where clause, while
setting data to specified by $fields (reference to a hash). Please, consider,
that absent $tablename, $where and/or $fields are errors. Returns how many rows
affected. '0E0' is returned if zero affected.

=item $rows_affected = delete_rows($tablename,$where)

Launches DELETE statement on table $tablename, by using $where clause.
Please, consider, that absent $tablename and/or $where are errors. Returns
how many rows affected.

=item $rows_affected = insert_rows($tablename,$fields)

Launches INSERT statement on table $tablename, by inserting a row specified
by $fields (reference to a hash). Please, consider, that absent $tablename
and/or $fields are errors. Returns how many rows affected.

=item $rows_affected = insert_rows_ifne($tablename,$fields)

The same as insert_rows, but doesn't print into logs error, if item already existed
in destination table.

=item $table = do_query($query)

Should be used to launch queries. Generally, $query will contain SELECT
statement. The return value is a reference to array of references to
array of values. Use make_nmtable to make output like in get_rows.
Here is example:

$table = do_query("SELECT a.column_a,b.column_b from a,b where a.column_c = b.column_c");
make_nmtable($table,['column_a','column_b']);

After make_nmtable call the $table will be a reference to array of references
to a hash, where actual values are stored.

=item $sqlstr = str_sqlize($str)

Converts $str to into SQL string format. If $str eq 'Somebody's test', then
$sqlstr eq "\'Somebody\'s test\'".

=item $str = str_unsqlize($str)

Action is a reversed str_sqlize.

=item $str = sql_date($time)

Returns datetime in form YYYYMMDDHHMMSS from $time seconds. Current datetime is
sql_date(time). But use of now() builtin of SQL is encouraged. Consider, that
time on hosts which runs CGI-scripts and MySQL server could be different.

=back

=cut


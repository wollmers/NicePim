#
# This package enhances DBI interface to make it extremly useful in the
# environment.
#

package atomsql;
use DBI;

#$Id: atomsql_speedy.pm 2 2005-08-29 12:03:18Z serzh $

use vars qw($dbh %describen_tables $debug $requests);
use vars qw ( $debug_db_on) ;

# These register globals
use atomcfg;
use atomlog;
use atom_util;
use strict;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&describe_table &get_rows &get_row &update_rows &insert_rows
	             &do_query &delete_rows &str_sqlize &str_unsqlize &sql_date
	             &insert_rows_ifne &sql_last_insert_id
							 &do_statement);
	
	my ($str,$user,$pass);
	$storesql::debug = 0;
	$requests = 0;
	if($debug_lib::debug_on && $atomcfg{debug_db}){
		$str = "DBI:mysql:$atomcfg{debug_db}:$atomcfg{dbhost}";
	} elsif($debug_lib1::debug_on && $atomcfg{debug_db_1}){
		$str = "DBI:mysql:$atomcfg{debug_db_1}:$atomcfg{dbhost}";
	}	else {
	  $str = "DBI:mysql:$atomcfg{dbname}:$atomcfg{dbhost}";
	}
	$user = $atomcfg{dbuser};
	$pass = $atomcfg{dbpass};
	if(undef $dbh){
		$dbh = DBI->connect($str,$user,$pass,{PrintError=>1,AutoCommit=>1});
	}
	if (!$dbh) {
		&error_dbopen($str.":$user,$pass");
	}
}

END {
	&log_printf("storesql.pm: did $requests requests.");
	$dbh->disconnect;
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
	return &do_query("SELECT LAST_INSERT_ID()")->[0][0];
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

sub str_sqlize
{
	my $str = $_[0];

	$str =~ s/\\/\\\\/g;
	$str =~ s/\'/\\\'/g;
	$str = "\'".$str."\'";

	return $str;
}

sub describe_table {
	my ($tablename) = @_;
	my ($sth,$rv,@row,$h,$i);
	
	if ($describen_tables{$tablename}) {
		return $describen_tables{$tablename};
	}
	
	$sth = $dbh->prepare("show columns from $tablename");
	if (!$sth) {
		&error_prepare("show columns from $tablename");
		return [];
	}
	$rv = $sth->execute;
	if (!$rv) {
		&error_execute("show columns from $tablename");
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
		&error_printf('get_rows $limit == %d <= 0 Table: %s', $limit, $tablename);
		return $nrw;
	}
	
	if ($ofs && $ofs <= 0) {
		&error_printf('get_rows $ofs == %d <= 0 Table: %s', $ofs, $tablename);
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
		&error_prepare($select);
		return $nrw;
	}
	$rv = $sth->execute;
	if (!$rv) {
		&error_execute($select);
		return $nrw;
	}
	$requests++;

#	if ($debug) { log_printf('get_rows statement '.$select); }
	
#	while (@row = $sth->fetchrow_array) {	&push_a_nmtable($nrw,$dbt,\@row); }

my $row;	
 while ($row = $sth->fetchrow_arrayref) {	&push_a_nmtable($nrw,$dbt,$row); }

	$rv=$sth->finish;
	return $nrw;
}

sub get_row {
	my ($tablename,$where,$orderby,$ofs) = @_;
	my ($select,$debug,$dbt,$sth,$nh,$rv,@row,$i);
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }

	if ($ofs && $ofs <= 0) {
		&error_printf('get_rows $ofs == %d <= 0 Table: %s', $ofs, $tablename);
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
		&error_prepare($select);
		return {};
	}
	$rv = $sth->execute;
	if (!$rv) {
		&error_execute($select);
		return {};
	}
	$requests++;
	
	if ($debug) { log_printf('get_rows statement %s',$select); }
	
	$nh = {};
	if (@row = $sth->fetchrow_array) {
		for ($i = 0; $i <= $#{$dbt}; $i ++) {
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
		foreach $i (keys %$fields) {
			if ($isgood) { $stmt .= ","; }
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
		&error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("update_rows stmt $stmt");	}
	&sql_log($stmt);
	
	return $rv;
}

sub insert_rows_ifne {
	my ($tablename,$fields) = @_;
	my ($stmt,$i,$isgood,$debug,$rv,$vals);
	
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	$stmt = "INSERT INTO $tablename (";
	$vals = "(";
	$isgood = 0;

	if ($fields) {
		foreach $i (keys %$fields) {
			if ($isgood) { $stmt .= ","; $vals .= ","; }
			$stmt .= $i;
			$vals .= "$fields->{$i}";
			$isgood = 1;
		}
	}

	$stmt .= ") VALUES ".$vals.")";
	
	if (!$isgood) {
		log_printf("Warning: insert_rows called without fields specified.... Table: $tablename");
		return 0;
	}
	
	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		return 0;
	}
	
	if ($debug) {	log_printf("insert_rows stmt $stmt");	}
	&sql_log($stmt);
	
	return $rv;
}

sub insert_rows {
	my ($tablename,$fields) = @_;
	my ($stmt,$i,$isgood,$debug,$rv,$vals);
	
	$debug = $storesql::debug;
	if (substr($tablename,0,1) eq '*') { $debug = 1; $tablename =~ s/\*//g; }
		
	$stmt = "INSERT INTO $tablename (";
	$vals = "(";
	$isgood = 0;

	if ($fields) {
		foreach $i (keys %$fields) {
			if ($isgood) { $stmt .= ","; $vals .= ","; }
			$stmt .= $i;
			$vals .= "$fields->{$i}";
			$isgood = 1;
		}
	}

	$stmt .= ") VALUES ".$vals.")";
	
	if (!$isgood) {
		log_printf("Warning: insert_rows called without fields specified.... Table: $tablename");
		return 0;
	}
	
	$rv = $dbh->do($stmt);
	$requests++;
	
	if (!$rv) {
		&error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("insert_rows stmt $stmt");	}
	&sql_log($stmt);
	
	return $rv;
}

sub do_query {
	my ($select) = @_;
	my ($sth,@nw,@row,$rv,$debug);

	$debug = $storesql::debug;
	if (substr($select,0,1) eq '*') { $debug = 1; $select = substr($select,1); }
	&sql_log($select);	

	$sth = $dbh->prepare($select);
	if (!$sth) { &error_prepare($select); return []; }
	
	$rv = $sth->execute;
	$requests++;
	if (!$rv) {	&error_execute($select); return []; }

	while (@row = $sth->fetchrow_array) {	push(@nw,[@row]); }

	$rv=$sth->finish;
	if ($debug) { log_printf("do_query stmt $select"); }
	
	return [@nw];
}

sub do_statement {
	my ($select) = @_;
	my ($sth,@nw,@row,$rv);

	$sth = $dbh->prepare($select);
	if (!$sth) { &error_prepare($select); return []; }
	$rv = $sth->execute;
	$requests++;
	if (!$rv) {	&error_execute($select); return []; }
	
	$rv=$sth->finish;

	&sql_log($select);
	
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
		&error_execute($stmt);
		return 0;
	}
	
	if ($debug) {	log_printf("delete_rows stmt $stmt");	}
	&sql_log($stmt);
	
	return $rv;
}

# Logging SQL queries

sub sql_log
{
 my $query = join(";\n",@_).";\n";
		&atom_util::push_dmesg(3,"SQL QUERY:$query");
 # USE FILTERING 
if (!($query=~/^\s*[Ss][Ee][Ll][Ee][Cc][Tt]/)) 
  {
    open(LOG,">>$atomcfg{'sql_log_path'}/$atomcfg{'sql_log_file'}");
		flock(LOF,2);
		print LOG $query;
		close(LOG);
		flock(LOG,4); 
		
	}

}
1;

=head1 NAME

storesql - a package that should be used for regular SQL access.

=head1 SYNOPSIS

  use storesql;
	
  # connection is made automatically to database, specified in config file

  $descr = &describe_table("tablename");
  # now $descr is reference to array, that contains names of each column,
  # that is hold inside of the table `tablename'

  $nm = &get_rows("tablename", "where clause", "order by", limit, ofs)
  # retrieves an nmtable object, that is got, by using of statement
  # SELECT * FROM tablename WHERE where clause ORDER BY order by LIMIT ofs,limit
  # get_rows can also be called in these ways:
  $nm = &get_rows("tablename", "where clause", "order by", limit);
  $nm = &get_rows("tablename", "where clause", "order by");
  $nm = &get_rows("tablename", "where clause");
  $nm = &get_rows("tablename");
  # please consider, that doing last query can result in enormously big table,
  # and perl will drop a core dump.

  $rows_updated = &update_rows("tablename", "where clause",
                   { 'field_1' => &str_sqlize('alpha'), 'field_2' => '1' } );
  # this will generate UPDATE statement for supplied parameters.
  # if 0 rows are updated '0E0' is returned.

	$rows_updated = &insert_rows("tablename",
                   { 'field_1' => &str_sqlize('alpha'), 'field_2' => '1' } );
  # this will generate UPDATE statement for supplied parameters.

	$rows_updated = &delete_rows("tablename", "where clause");
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

$table = &do_query("SELECT a.column_a,b.column_b from a,b where a.column_c = b.column_c");
&make_nmtable($table,['column_a','column_b']);

After make_nmtable call the $table will be a reference to array of references
to a hash, where actual values are stored.

=item $sqlstr = str_sqlize($str)

Converts $str to into SQL string format. If $str eq 'Somebody's test', then
$sqlstr eq "\'Somebody\'s test\'".

=item $str = str_unsqlize($str)

Action is a reversed str_sqlize.

=item $str = &sql_date($time)

Returns datetime in form YYYYMMDDHHMMSS from $time seconds. Current datetime is
&sql_date(time). But use of now() builtin of SQL is encouraged. Consider, that
time on hosts which runs CGI-scripts and MySQL server could be different.

=back

=cut


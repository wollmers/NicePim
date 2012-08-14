#!/usr/bin/perl

#$Id: aggregate.pl 3604 2010-12-21 01:11:39Z dima $

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';

use strict;
use POSIX;
use atomsql;
use stat_report;

open(PRC, "ps axu |");
my @prc = <PRC>;
my @proc = grep {/perl.*aggregate/} @prc;
close(PRC);
if ($#proc > 0) {
    print "already running. exit.";
    exit();
}

my $now = time;
my $now_date = strftime("%Y-%m-%d", localtime($now));
my $yesterday_stamp = &do_query("select unix_timestamp(".&str_sqlize($now_date).")")->[0][0] - 1;
my $yesterday_date = strftime("%Y-%m-%d", localtime($yesterday_stamp));
my $yesterday_stamp = &do_query("select unix_timestamp(".&str_sqlize($yesterday_date).")")->[0][0];
my $aggregated_flag = 0;

#print $now_date."\n";
#print $yesterday_date."\n";

my $latest_stamp = &do_query("select max(time_stamp) from aggregate_log")->[0][0]; 
if ($latest_stamp) {
	my $latest_date = strftime("%Y-%m-%d", localtime($latest_stamp));
	my $delta = &get_delta_time_stamp($latest_date);
	my $stamp_for_aggregate = $latest_stamp + $delta;
	&remove_ancient_request_repository_statistics($latest_date);
	while ($stamp_for_aggregate <= $yesterday_stamp) {
		my $date_for_aggregate = strftime("%Y-%m-%d", localtime($stamp_for_aggregate));
		print "Aggregate request's for $date_for_aggregate: ";
		my $count = &start_aggregate($date_for_aggregate);
		my $query = 'insert into aggregate_log (time_stamp, time_str) values ('.&str_sqlize($stamp_for_aggregate).','.&str_sqlize($date_for_aggregate).')';
		&do_statement($query);
		$delta = &get_delta_time_stamp($date_for_aggregate);
		$stamp_for_aggregate += $delta;
		print "aggregated $count request's.\n";
		$aggregated_flag = 1;
	
	}
}
else {
	my $query = 'insert into aggregate_log (time_stamp, time_str) values ('.&str_sqlize($yesterday_stamp).','.&str_sqlize($yesterday_date).')';
	print "Aggregate request's for $yesterday_date: ";
	my $count = &start_aggregate($yesterday_date);
	print "aggregated $count request's.\n";
	&do_statement($query);
	$aggregated_flag = 1;
}

if (!$aggregated_flag) {
	print "No data for aggregation.\n";
}

#my $TimeStamp = &do_query("select unix_timestamp(".&str_sqlize($TimeStr).")")->[0][0];
#if ($TimeStamp == &start_aggregate(strftime( "%Y-%m-%d", localtime($TimeStamp)))) {
#	my $Query = 'select timestamp from aggregate_log where timestamp='.$TimeStamp;
#	if (!&do_query($Query)->[0][0]) {
#		print 'OK';
#		$Query = 'insert into aggregate_log (timestamp, timestr)values ('.&str_sqlize($TimeStamp).','.&str_sqlize($TimeStr).')';
#	&do_statement($Query);		
#	}

#	print 'ok';
#}

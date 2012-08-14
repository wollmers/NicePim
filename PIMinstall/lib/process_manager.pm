package process_manager;

# $Id: process_manager.pm 3684 2011-01-11 14:45:53Z alexey $

use strict;

use atomcfg;
use atomlog;
use atomsql;

use Data::Dumper;

my %cfg = (
	'process_manager_sleep_timeout' => 600,
	'process_manager_sleep_time' => 1,
	'process_finished_wo_status_update_time' => 20 * 60,
	'process_max_iterations' => 10000,
	'process_queue_table' => 'process_queue'
	);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS %cfg);

  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();

  @EXPORT = qw( &run_bg_command
								&get_running_perl_processes_number
								&get_number_process_running
								&queue_process
								&queue_processes
								&update_process_status
								&run_multiple_processes_managed
                &cleanup_process_queue
                &get_pid
							);
}

sub cleanup_process_queue {
	my $avg_wait=atomsql::do_query('SELECT AVG(finished_date-queued_date) FROM process_queue WHERE process_status_id = 30')->[0][0];
	my $avg_speed=atomsql::do_query('SELECT AVG(finished_date-started_date) FROM process_queue WHERE process_status_id = 30')->[0][0];
	my $pers_data_path=$atomcfg{'www_path'}.'../bin/testing/xml_generation_checker.data';
	my $hash={};
	my $data_open=open(PERS_DATA,'<',$pers_data_path);# persistent data
	if($data_open){# load stored data
		my $persDataStr=join("",<PERS_DATA>);
		$persDataStr=~s/\$VAR1[\s]*=//;
		$hash=eval($persDataStr);
	}
	close(PERS_DATA);
	my $from=atomsql::do_query('SELECT from_unixtime(min(started_date)) FROM process_queue WHERE process_status_id=30')->[0][0];
	my $to=atomsql::do_query('SELECT now()')->[0][0];
	if(ref($hash->{'avg_queue_wait'}) eq 'ARRAY'){# bin/testing/queue_report will report this data and empties the array
		if(scalar(@{$hash->{'avg_queue_wait'}})>1000){# just in case
			$hash->{'avg_queue_wait'}=[];
		}
		push (@{$hash->{'avg_queue_wait'}},{'from'=>$from,'to'=>$to,'avg'=>$avg_wait});
	}else{
		$hash->{'avg_queue_wait'}=[];
	}
	if(ref($hash->{'avg_queue_speed'}) eq 'ARRAY'){# bin/testing/queue_report will report this data and empties the array
		if(scalar(@{$hash->{'avg_queue_speed'}})>1000){# just in case
			$hash->{'avg_queue_speed'}=[];
		}
		push (@{$hash->{'avg_queue_speed'}},{'from'=>$from,'to'=>$to,'avg'=>$avg_speed});
	}else{
		$hash->{'avg_queue_speed'}=[];
	}
		
	open(PERS_DATA,'>',$pers_data_path);
	print PERS_DATA Dumper($hash);
	close(PERS_DATA);
	
	atomsql::delete_rows($cfg{'process_queue_table'},'process_status_id = 30');
} # sub cleanup_process_queue

sub run_bg_command {
	my ($cmd) = @_;
	
	use POSIX 'setsid';
	
	defined(my $pid = fork) or die "Can't fork: $!";
	return '' if $pid;
	
	chdir '/'                 or die "Can't chdir to /: $!";
	open STDIN, '/dev/null'   or die "Can't read /dev/null: $!";
	open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
	setsid                    or die "Can't start a new session: $!";
	open STDERR, '>&STDOUT'   or die "Can't dup stdout: $!";

	# i'm the kiddy
	exec($cmd);
} # sub run_bg_command


sub run_multiple_processes_managed {
	my $get_queued_processes = 'select id, command, process_class_id, prio, langid_list from '.$cfg{'process_queue_table'}.' where process_status_id=1 order by prio desc, /* product_id desc, */ id asc limit 50';
	my $commands = atomsql::do_query($get_queued_processes);

	my $iteration = 0;

	while ($commands->[0]) {
		for my $command_data (@$commands) {
			my $c_id    	= $command_data->[0];
			my $prc_class	=	$command_data->[2];
			my $command 	= $command_data->[1]." $c_id";
			$command .= " ".$command_data->[4] if $command_data->[4]; # add langid_list as 3rd parameter, if necessary
			my $max_prc = atomsql::do_query("select max_processes from process_class where id = ".atomsql::str_sqlize($command_data->[2]))->[0][0];
			
			my $sleep_time = 0;
			my $get_number_of_perl_process;
#			my $get_number_of_process = get_number_process_running($prc_class);
			my $get_number_of_process = get_running_perl_processes_number('update_product_xml_chunk');
			
			print "\tget_number_of_processes running on ".localtime()." is ".$get_number_of_process."\n";
			
			while ($get_number_of_process >= $max_prc) {
				if ($sleep_time >= $cfg{'process_manager_sleep_timeout'}) {
					my $procs = atomsql::do_query("select id from ".$cfg{'process_queue_table'}." where process_status_id in (10,20) and process_class_id = ".atomsql::str_sqlize($prc_class));
					my $is_fail=0;
					for my $proc (@$procs) {
						$get_number_of_perl_process = get_running_perl_processes_number($proc->[0]);
						unless ($get_number_of_perl_process) {
							atomsql::do_statement("update ".$cfg{'process_queue_table'}." set process_status_id=1 where id=".$proc->[0]);
							$is_fail=1;
						}
					}
					if ($is_fail) {
						next;
					}
					else {
						print "SLEEP TIMEOUT! CAN'T GET LESS PROCESS RUNNING! QUITING!\n";
						goto cleanup;
					}
				}

				print " --> running more than $max_prc processes of class $prc_class. Sleeping for a $cfg{process_manager_sleep_time} secs (total $sleep_time secs)\n";
				sleep($cfg{'process_manager_sleep_time'});
				$sleep_time += $cfg{'process_manager_sleep_time'};

				$get_number_of_process = get_number_process_running($prc_class);
			}

			update_process_status($c_id,
														 {
															 'process_status_id' => 10, # launching
															 'started_date'  => "unix_timestamp()"
														 });
			
			$iteration++;
			print "running '$command' [prio ".$command_data->[3].", id $c_id, iteration ".$iteration."]\n";
			run_bg_command($command);

			# decide to exit(2) if iterations more than max

			if ($iteration > $cfg{'process_max_iterations'}) {
				print "Processed maximum of iterations (".$cfg{'process_max_iterations'}.")! QUITING!\n";
				goto cleanup;
			}

		}
		$commands = atomsql::do_query($get_queued_processes);
	}

#
# cleanup
#

 cleanup:
	# 10 -> 1
  sleep($cfg{'process_manager_sleep_time'}); # give some time to process for a start
  atomsql::update_rows($cfg{'process_queue_table'}, " process_status_id = 10 and (unix_timestamp() - started_date) > 10 ", { 'process_status_id' => 1 });
	
  # absent: 20 -> 30 OR present: kill, 20 -> 1. (checking running long processes, 20 * 60 seconds)
  my $running_processes = atomsql::do_query("select id, command, pid from ".$cfg{'process_queue_table'}." where process_status_id = 20 and (unix_timestamp() - started_date) > $cfg{process_finished_wo_status_update_time}");

  for my $process_data (@$running_processes) {
    # check if we really have such process
    my $cnt = get_running_perl_processes_number($process_data->[1]);
    if (!$cnt) {
      print "seems like we have queue $process_data->[0] finished, but status isn\'t updated\n";
      update_process_status($process_data->[0], { 'process_status_id'  => 30, 'exit_code' => 2 });
      print "done\n";
    }
		else {
      print "queue $process_data->[0] still running, seems like freezed. need to kill it - [".$process_data->[2]."]\n";
			`/bin/kill $process_data->[2]`;
    }
  }

  print "done\n";
}

sub queue_process {
	my ($command, $data) = @_;

	my $p = process_queued_active($command);
	
	if (!$p->{'id'}) {
	  my $hash = {
			'command'     => atomsql::str_sqlize($command),
			'queued_date' => 'unix_timestamp()'
		};
  	for my $key (keys %$data) {
  	  $hash->{$key} = atomsql::str_sqlize($data->{$key})
  	}
		if ($hash->{'langid_list'}) { # add specific list of languages, if necessary
			# check if ths product is added as global updating
			return undef if atomsql::do_query("select id from process_queue where product_id=".$hash->{'product_id'}." and process_class_id=".$hash->{'process_class_id'}." and process_status_id < 30 and langid_list = ''")->[0][0];
		}
		if ($hash->{'process_class_id'} && $hash->{'product_id'}) {
			atomsql::do_statement("delete from ".$cfg{'process_queue_table'}." where process_class_id = ".$hash->{'process_class_id'}." and product_id = ".$hash->{'product_id'});
		}
  	atomsql::insert_rows($cfg{'process_queue_table'}, $hash);
	}
	else {
		if (($data->{'prio'}) && ($p->{'prio'} < $data->{'prio'})) {
			atomsql::do_statement("update ".$cfg{'process_queue_table'}." set prio=".$data->{'prio'}." where id=".$p->{'id'});
		}
	}
} # queue_process

sub queue_processes {
	my ($table, $prio, $update_products) = @_; # get a table with product_ids

	my $ps = atomsql::do_query("select product_id from ".$table);
  my $cmd = $atomcfg{'base_dir'}.'bin/update_product_xml_chunk';

  for (@$ps) {
    log_printf("queue(".$cmd." ".$_->[0].")");
#		atomsql::update_rows('product', "product_id=".$_->[0], { 'updated' => 'NOW()' }) if ($update_products);
    queue_process($cmd." ".$_->[0], { 'product_id' => $_->[0], 'process_class_id' => 1, 'prio' => $prio });
  }

	return $#$ps + 1;
} # sub queue_processes

sub process_queued_active {
	my ($command) = @_;
	
	my $status_ref = atomsql::do_query("select id, prio from ".$cfg{'process_queue_table'}." where process_status_id <> 30 and command = ".atomsql::str_sqlize($command));
	
	if (($status_ref->[0]) && ($status_ref->[0][0])) {
		return { 'id' => $status_ref->[0][0], 'prio' => $status_ref->[0][1] };
	}

	return undef;
}

sub update_process_status {
	my ($process_queue_id, $hash) = @_;
	
  if ($process_queue_id) {
    atomsql::update_rows($cfg{'process_queue_table'}, " id = ".atomsql::str_sqlize($process_queue_id), $hash);
  }
#	else {
#   print "update_process_status: no process_queue_id given\n";
#  }
} # sub update_process_status

sub get_number_process_running {
	my ($process_class_id) = @_;

#
# todo - think of this sql query, it may become very slow
#

	return atomsql::do_query("select count(id) from ".$cfg{'process_queue_table'}." where process_status_id in (10,20) and process_class_id = ".atomsql::str_sqlize($process_class_id))->[0][0];
}


sub get_running_perl_processes_number {
	my ($process, $remote) = @_; # remote needs to determine an ssh remote execution

	open(PRC, $remote." ps axu|");
	my @prc = <PRC>;
	$process=~s/[\s]+$//;
	$process = quotemeta($process);
	my @proc = grep {/perl.*?$process\s/ && !/cron/ && !/\/bin\/sh\s\-c/} @prc;
	close(PRC);

	log_printf("get_running_perl_processes_number: number of '".$process."' is " . ($#proc + 1));

	if ($#prc == -1) {
		return 999; # couldn't connect to server - no processes at all
	}
	elsif ($#proc > -1 ) {
		return $#proc+1;
	}
	return 0;
}

#command name should be unique
sub get_pid{
	my ($command)=@_;
	my $result=`ps wwaxo pid,command | grep $command`;
	if($result=~/^[\s\t]*([\d]+)/){
		return $1	
	}else{
		return '';
	}
}

1;

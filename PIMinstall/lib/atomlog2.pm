package atomlog;

#$Id: atomlog2.pm 2 2005-08-29 12:03:18Z serzh $

use strict;
use atomcfg;

local *log_fh;
use vars qw($log_message $error_happened);


sub log_printf {
no strict;

require 'sys/syscall.ph';
my $TIMEVAL_T = "LL";


my $start = pack($TIMEVAL_T, ());
#use vars qw (SYS_gettimeofday);
syscall( &SYS_gettimeofday, $start, 0);
my @start = unpack($TIMEVAL_T, $start);

$start[1] /= 1_000_000;

	my $logs = localtime($start[0]).' '.sprintf("%.4f", $start[1]).' ['.$$.']'.($#_ > 0?sprintf(@_):$_[0])."\n";
	print atomlog::log_fh $logs;
	if ($atomcfg{'bugreport_email'}){
		$log_message .= $logs;
	}
}

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&log_printf &error_printf &error_execute &error_prepare 
								$error_happened
	             &error_dbopen);
	
	if ($atomcfg{'logfile'}) {
		if(!open(log_fh,">>/home/gcc/logs/mylog")){
		 open log_fh,">&STDOUT";
		 &log_printf("Warning: can't open log file");
		};
	} else {
		open log_fh,">&STDOUT";
		&log_printf("Warning: no log file specified in configs...");
	}
	select(log_fh);
	$| = 1;
	select(STDOUT);
	open STDERR, ">&log_fh";
	&log_printf("Started logging");
	$error_happened = 0;
}

sub error_printf {
	&log_printf(@_);
#	if ($_[0] ne 'fo_main was called without shop identifier') { # Don't want to see this message in logs
#		if ($atomcfg{'bugreport_email'} ne '') {
#			use storemail;
#			&sendmail($log_message,$atomcfg{'bugreport_email'},$atomcfg{'bugreport_from'},$atomcfg{'bugreport_subj'});
#		}
#	}
	$error_happened = 1;
#	print "Location: /\n\n";
	exit 0;
}

# SQL ERRORS

sub error_dbopen {
	&error_printf("can't open database $_[0]");
}

sub error_prepare {
	&log_printf("can't prepare SQL statement $_[0]");
}

sub error_execute {
	&log_printf("can't execute SQL statement $_[0]");
}

1;

=head1 NAME

aromlog - log-file manipulations.

=head1 SYNOPSIS

  use atomlog; - use

  log_printf("%s %d", "prints regular log message", 5);

  # You can use here any of atomlog routines.

=head1 DESCRIPTION

log_printf - prints regular message to the log-file.

error_printf - prints error message to the log-file, halts the program, and
  returns to STDOUT HTML-ized error message, that is ended by </body></html>

error_execute($statement), error_prepare($statement) - used to report errors,
that happened during DBI execute and prepare calls.

error_dbopen($dbi_statement) - used to report errors, which happen during
connection to database.

=head2 NOTE

It is not guaranteed, that functions other than error_printf will exit fatally.

=cut

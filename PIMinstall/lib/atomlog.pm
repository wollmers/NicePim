package atomlog;

#$Id: atomlog.pm 3638 2010-12-27 22:28:19Z dima $

use strict;
use atomcfg;
use Time::HiRes qw(gettimeofday);
use Time::Piece;
use Carp 'cluck';

#local *log_fh;
use vars qw($log_message $error_happened *log_fh);

sub log_printf_c {
	my ($txt) = @_;
	open(TMP,">>".$atomcfg{'base_dir'}."/logs/customlog");
	print TMP $txt."\n";
	close TMP;
}

sub log_printf {
	no strict;

	my ($sec, $msec) = gettimeofday();
	$msec = ( '0' x (6 - length($msec)) ) . $msec;
	my (undef, $file, $line) = caller(1);
	$file =~ s,^(.*?)([^/]+/[^/]+)$,$2,;

	my $file_2;
	my $line_2;
	if ($file =~ /atomsql/) {
		(undef, $file_2, $line_2) = caller(2);
		$file_2 =~ s,^(.*?)([^/]+/[^/]+)$,$2,;
	}

	my $file_3;
	my $line_3;
	if ($file_2 =~ /atomsql/) {
		(undef, $file_3, $line_3) = caller(3);
		$file_3 =~ s,^(.*?)([^/]+/[^/]+)$,$2,;
	}

	my $logs = ( $line ? $file . ':' . $line : '' ) . ( $file_2 ? ', ' . $file_2 . ':' . $line_2 . ( $file_3 ? ', ' . $file_3 . ':' . $line_3 : '' ) : '' ) . "\n" .
		localtime($sec)->cdate . ' ' . $msec . ' [' . $$ . ']' . ($#_ > 0 ? sprintf(@_) : $_[0]) . "\n";
	print atomlog::log_fh $logs;

	if ($atomcfg{'bugreport_email'}) {
		$log_message .= $logs;
	}
}

sub lp{
	return &log_printf(@_);
}

sub direct_log_printf
{

require 'sys/syscall.ph';
my $TIMEVAL_T = "LL";


my $start = pack($TIMEVAL_T, ());
#use vars qw (SYS_gettimeofday);
syscall( &SYS_gettimeofday, $start, 0);
my @start = unpack($TIMEVAL_T, $start);

$start[1] /= 1_000_000;
	open(log_fh,">>/home/gcc/logs/mylog");
	log_fh->autoflush(1);
	my $logs = localtime($start[0]).' '.sprintf("%.4f", $start[1]).' ['.$$.']'.($#_ > 0?sprintf(@_):$_[0])."\n";
	print log_fh " $logs \n";

}

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&log_printf &log_printf_c &error_printf &error_execute &error_prepare 
								$error_happened
								&lp
								&direct_log_printf
	             &error_dbopen);
	
	if ($atomcfg{'logfile'}) {
		if(!open(log_fh,">>".$atomcfg{'logfile'})){
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
	binmode(log_fh,":utf8");
	binmode(STDOUT,":utf8");
	binmode(STDERR,":utf8");
	&log_printf("Started logging ".$0.", warn: ".$^W);
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
	&log_printf("<stack_trace>\n");
	cluck '';
	&log_printf("can't prepare SQL statement <sql>$_[0]</sql>\n<err_text>$DBI::errstr</err_text>\n</stack_trace>");
}

sub error_execute {
	&log_printf("<stack_trace>\n");
	cluck '';
	&log_printf("can't execute SQL statement <sql>$_[0]</sql>\n<err_text>$DBI::errstr</err_text>\n</stack_trace>");
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

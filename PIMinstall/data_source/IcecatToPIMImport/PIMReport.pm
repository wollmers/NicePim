package PIMReport;
use PIMImportConfiguration;
use atom_mail;

#message for report
my $report = "";

#append text to report
sub append {
	my ( $class, $message ) = @_;
	die "class method called on object" if ref $class;
	$report .= $message;
}

#print report
sub print_report {
	my $class = shift;
	die "class method called on object" if ref $class;
	print $report;
}

#send report on email
sub send_report {
	my ( $class, $to, $from, $subject ) = @_;
	die "class method called on object" if ref $class;
	&sendmail( $report, $to, $from, $subject );
}

1;

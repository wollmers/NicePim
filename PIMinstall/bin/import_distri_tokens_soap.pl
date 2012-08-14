#!/usr/bin/perl

# @author <vadim@bintime.com>

use strict;
use lib '/home/pim/lib';

use atomcfg;
use atomsql;
use atomlog;
use SOAP::Lite;
use Term::ANSIColor qw(:constants);

# dictionary group id for Ice import distributor
my $DGID = 2;

print BOLD WHITE "::Starting import_distri_tokens_soap.pl:", RESET, "\n";

my $soap = SOAP::Lite->service('http://icetools.iceshop.nl/icetools.wsdl');

print BOLD WHITE "::SOAP connection finished", RESET, "\n";

# get list of distributor codes
my @codes = split(/,/, $soap->getActiveDistriCodes(''));
# code => distributor_id
my %codes = ();

foreach my $code (@codes) {
	s/^\s+|\s+$//gi;
	my $distri_id = do_query("SELECT distributor_id from distributor WHERE code = '$code'")->[0]->[0];
	$codes{$code} = $distri_id if ($distri_id);
}

print BOLD WHITE "::Tokens addition in process:", RESET, "\n";

while ( (my $code, my $distri_id) = each %codes ) {
	print CYAN $code, RESET, ": ";
	my $res = $soap->getDistriImportNecessaryFields($code);
	if ($res) {
		my @tokens = split /,/, $res;
		foreach my $token (@tokens) {
			$token =~ s/^\s+|\s+$//gi; # delete all spaces at the beginning and at the end of token
			print YELLOW $token, RESET;
			$token = str_sqlize($token);
			unless (&do_query("SELECT code FROM dictionary WHERE code=". $token)->[0][0]) {
				do_statement("INSERT INTO dictionary (code, name, dictionary_group_id) VALUES ($token, $token, $DGID)");
			}
			# get dictionary_id of last token
			my $dictionary_id = &do_query("SELECT dictionary_id FROM dictionary WHERE code=$token")->[0]->[0];
			unless (&do_query("SELECT html FROM dictionary_text WHERE langid=1 AND dictionary_id=" . $dictionary_id . " AND distributor_id=" . $distri_id)->[0]->[0]) {
				# insert english translation of token
				do_statement("INSERT INTO dictionary_text (dictionary_id, html, langid, distributor_id) VALUES
					($dictionary_id, $token, 1, $distri_id)");
			}
			unless (&do_query("select distributor_token_id from distributor_tokens where distributor_id=" . $distri_id . " and token=" . $token)->[0][0]) {
				do_statement("INSERT INTO distributor_tokens (distributor_id, token) VALUES ($distri_id, $token)");
				print BOLD GREEN "+", RESET;
			}
			print BOLD WHITE " | ", RESET;
		}
	}
	else {
		print "\033[31mnone found\033[37m";
	}
	print "\n";
}

print BOLD WHITE "::Finished import_distri_tokens_soap.pl", RESET, "\n\n";

#!/usr/bin/perl

# @author vadim

use strict;
#use warnings;

use lib '/home/pim/lib';
use atomsql;
use atomcfg;
use atomlog;

use constant CSV_FILENAME => 'distributor_tokens.csv';
use constant CSVD => "\t";
use constant CSVN => "\n";

my $query = "SELECT d.code, dict.name, l.short_code, dt.html FROM distributor_tokens dtk
	JOIN distributor d USING (distributor_id)
	JOIN dictionary dict ON dtk.token=dict.code
	JOIN dictionary_text dt ON dt.dictionary_id=dict.dictionary_id AND dt.distributor_id=dtk.distributor_id
	JOIN language l ON dt.langid=l.langid WHERE dt.html <> '' AND dt.distributor_id > 0";

my $translations = do_query($query);
if (! scalar @$translations) {
	print "Sorry: No data to export. Exit\n";
	return;
}

my $export; # export data

print "Starting export distributor tokens ...\n";
$export .= "Distributor\tToken\tLanguage\tTranslation\n";
foreach (@$translations) {
	$_->[3] =~ s/\t+/\\t/g;
	$_->[3] =~ s/^<p>(.*)<\/p>$/$1/g; # delete <p> tags
	next if ($_->[3] =~ /^\s*$/); # next row if translation is empty without tags
	$export .= $_->[0] . CSVD . $_->[1] . CSVD . $_->[2] . CSVD . $_->[3] . CSVN;
}

my $path = $atomcfg{'xml_path'} . 'level4/prf/';
if (! -d $path) {
	qx(mkdir $path);
}

my $file_path =  $path . CSV_FILENAME;
open(my $CSV_FILE,"> ".$file_path) || die "$!: $file_path\n";
binmode($CSV_FILE,":utf8");
print $CSV_FILE $export;
close $CSV_FILE || die "$!: $file_path\n";

my $file_path_gz = $file_path.'.gz';
qx(cat $file_path | gzip > $file_path_gz);

print "Export finished! Check at '$file_path'\n";

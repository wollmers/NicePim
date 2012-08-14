#!/usr/bin/perl
use strict;
use warnings;
use PIMImporter;

my $importer = PIMImporter->new();
$importer->do_import();


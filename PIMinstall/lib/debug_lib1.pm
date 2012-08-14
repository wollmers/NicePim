package debug_lib1;

#$Id: debug_lib1.pm 2 2005-08-29 12:03:18Z serzh $

use strict;
use vars qw( $debug_on);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  
	$debug_on = 2;
	
  @EXPORT = qw($debug_on);
}


1;
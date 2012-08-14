package atom;

#$Id: atom.pm 998 2008-05-22 15:58:50Z dima $

use strict;
use atomcfg;
use atom_util;
use atom_engine;
use atomlog;
use atom_html;

use vars qw ($atomid @errors);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&atom_main &atom_main_ajaxed);
}

sub atom_main
{
 &html_start();
 &init_atom_engine();
 &launch_atom_engine();
 &done_atom_engine();
 &html_finish(); 
}

sub atom_main_ajaxed {
 &init_atom_engine();
 &launch_atom_engine();
 &done_atom_engine();
 return &html_finish('ajaxed');
}

1;

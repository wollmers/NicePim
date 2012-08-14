package atom_html;

#$Id: atom_html.pm 3434 2010-11-12 11:30:45Z dima $

use vars qw(%hin %hout %hl %hs %cookies $html_output $bufsize $maxbound $maxdata $sessid $pageid $ssl);
use vars qw(%incfn %inct %insfn $writefiles $html_traffic $jump_to_location);
use vars qw($validation_active $downloaded_files);


use strict;
use atomlog;
use atomcfg;
use atomsql;
use atom_util;
use atom_misc;
use Data::Dumper;

sub get_user_agent {
	my $agent;
	my $ua = $ENV{'HTTP_USER_AGENT'};

	if ($ua =~ /MSIE 4/) {
		$agent = 'IE4';
	} elsif ($ua =~ /MSIE 5/) {
		$agent = 'IE5';
	} elsif ($ua =~ /Mozilla.4/) {
		$agent = 'NN4';
	} else {
		$agent = '';
	}

	return $agent;
}

sub encode_sessid {
# return sprintf('%08X%08X', $_[0] ^ 0x273D5E86, 1 ^ 0x413E295F);
return $_[0];
}

sub decode_sessid {
	if ($_[0] eq '') { return (); }
#	my ($si,$pi) = ( hex(substr($_[0],0,8)),hex(substr($_[0],8,8)) );
#	$si ^= 0x273D5E86;
#	$pi ^= 0x413E295F;
#	return $si;
return $_[0];
}

sub str_htmlize {
	my $str = shift;

	# Preserve inline tags (only if they're balanced!)
#	my @itags = ('[Ii]','[Aa]','[BB]','[Uu]','[Ss][Uu][Pp]','[Ss][Uu][Bb]','[Ee][Mm]','[Ii][Mm][Gg]','[Pp]','[Ff][Oo][Nn][Tt]','[Uu][Ll]','[Ll][Ii]');
#
#	for my $itag (@itags) {
#		$str =~ s/<(\s*$itag(?:\s[^>]+)?)>(.*?)<(\s*\/$itag\s*)>/\x1$1\x2$2\x1$3\x2/gs;
#	}

#	if ($str =~ /\x1/o) {
#		$str =~ s/^([^\x2\x1]*)\"([^\x2\x1]*\x1)/$1&quot;$2/g;
#		$str =~ s/(\x2[^\x2\x1]*)\"([^\x2\x1]*\x1)/$1&quot;$2/g;
#		$str =~ s/(\x2[^\x2\x1]*)\"([^\x2\x1]*)$/$1&quot;$2/g;
#	} else {
#		$str =~ s/\"/&quot;/g;
#	}

	$str =~ s/\&/&amp;/g;
	$str =~ s/\"/&quot;/g;
	$str =~ s/</&lt;/g;
	$str =~ s/>/&gt;/g;

	return $str;
}

sub str_unhtmlize {
	my $str = shift;
	$str =~ s/\&amp;/&/g;
	$str =~ s/\&quot;/"/g;
	$str =~ s/\&lt;/</g;
	$str =~ s/\&gt;/>/g;
	$str =~ s/\&nbsp;/ /g;

	return $str;
}

sub clean_session {
	my ($sess) = @_;
	if (!defined $sess) {
		delete_rows('session',"sessid=".str_sqlize($sess));
	}
}

sub clean_expired_sessions {
 delete_rows("session", "unix_timestamp() - updated > ".$atomcfg{'session_timeout'});
}

sub validate_sessid {
#  log_printf("validating sessid $sessid  , ". ($sessid));

	my $sessrow;

  $sessrow = atomsql::do_query("SELECT sessid,unix_timestamp() - updated FROM session WHERE code = ".atomsql::str_sqlize($sessid))->[0];
#	read    code     for $sessid


	if (!defined $sessrow) { # bad session
	  log_printf("session validation failed");
		return 0;
	}

	if($sessrow->[1] < $atomcfg{'session_timeout'}){
#  log_printf("session successfully validated");
	 return 1;
	}

#  log_printf("timeout $atomcfg{'session_timeout'} vs $sessrow->[1]");
	return 0;
}

sub new_session {
  my $code;
	my $sess_hash = {};
 	 do {
		$code = make_code(48);
		$sess_hash = { 'code' => atomsql::str_sqlize($code),
									 'updated'=> time()
								 };
	 } while(!atomsql::insert_rows('session',$sess_hash));
  $sessid = atomsql::sql_last_insert_id();

	$sessid = $code;
	$hs{'sesscode'} = $code;
  return $sessid;
}

sub load_session {
	my $override;

#	log_printf(" sessid from hin ".$hin{'sessid'});

	$sessid = decode_sessid($hin{'sessid'});

#	log_printf(" decoded into ".$sessid);

	my $fname;

	if(validate_sessid()){

		$fname = encode_sessid($sessid);
 	  open(SESS, $atomcfg{'session_path'}.".$fname") || log_printf("Can't open $atomcfg{'session_path'}\.$fname: $!");
		binmode(SESS,":utf8");

		{
			while (<SESS>) {
				chomp;
				my ($key,$value) = split(/=/);
				if (index($key,'!') == 0) {
					$override = 1; $key = substr($key,1);
				} else { $override = 0; }

				#Encode::_utf8_on($value);
				$key = unescape($key); $value = unescape($value);
#				log_printf($key.' -> '.$value.' - '.$hin{$key}.' <-- '.$override);
				if ($key eq '') { next; }

				if ($override) {
				 $hl{$key} = $value;
				 next;
				} elsif(!defined $hin{$key}){
				 $hin{$key} = $value;
			  }
		 }
		close SESS;
	 }
 	} 
 	else {
	 atom_util::push_error("The session has expired. Please, re-login.") if ($sessid);
   $hin{'tmpl'}='';
	}

	# after reading the session file issuing the new sessid

# $sessid = encode_sessid(new_session());
 $sessid = new_session();
 delete $hin{'sessid'}; # clearing old sessid from hin
}

sub save_session {
	my $key;

	open SESS, '>'.$atomcfg{'session_path'}.'.'.encode_sessid($sessid);
	binmode(SESS,":utf8");
	for $key (keys %hout) {	print SESS escape($key),'=',escape($hout{$key}),"\n"; }
	for $key (keys %hs)   { print SESS '!'.escape($key),'=',escape($hs{$key}),"\n"; }
#	for $key (keys %hout) {	print SESS $key,'=',$hout{$key},"\n"; }
#	for $key (keys %hs)   { print SESS '!'.$key,'=',$hs{$key},"\n"; }
	close SESS;
}

sub split_multiple {
  my ($param) = @_;
  my (@params) = split ("\0", $param);
  return (wantarray ? @params : $params[0]);
}

sub is_request_method_GET {
	return (defined $ENV{'REQUEST_METHOD'} && $ENV{'REQUEST_METHOD'} eq "GET");
}

sub is_request_method_POST {
  return (defined $ENV{'REQUEST_METHOD'} && $ENV{'REQUEST_METHOD'} eq "POST");
}

sub get_base_URL_wo_script {
	return (($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'}) ? 'https://' : 'http://') . $ENV{'SERVER_NAME'} .
		((($ENV{'SERVER_PORT'} != 80 && !$ENV{'SSL_SESSION_ID'} && !$ENV{'SSL_PROTOCOL_VERSION'}) 
			|| ($ENV{'SERVER_PORT'} != 443 && ($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'})))
		 ? ":$ENV{'SERVER_PORT'}" : '');
}

sub get_secure_base_URL_wo_script {
	return (($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'})?'https://':'https://') . $ENV{'SERVER_NAME'} .

  ((($ENV{'SERVER_PORT'} != 80 && !$ENV{'SSL_SESSION_ID'} && !$ENV{'SSL_PROTOCOL_VERSION'})
	|| ($ENV{'SERVER_PORT'} !=443 && ($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'})))
	 ? ":$ENV{'SERVER_PORT'}" : '');
}

sub get_base_URL {
	return get_base_URL_wo_script().
    ($ENV{'SCRIPT_NAME'} eq ''?$atomcfg{'default_url_path'}:$ENV{'SCRIPT_NAME'});
}

sub get_secure_base_URL_wo_script {
	return 'https://' . $ENV{'SERVER_NAME'}.
	(($ENV{'SERVER_PORT'} !=443 && ($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'}))
	? ":$ENV{'SERVER_PORT'}" : '');
}

sub get_secure_base_URL {
# no ssl
#	return get_secure_base_URL_wo_script().($ENV{'SCRIPT_NAME'} eq ''?$atomcfg{'default_url_path'}:$ENV{'SCRIPT_NAME'});
  return get_base_URL;
}

sub get_full_URL {
	return get_base_URL().$ENV{'PATH_INFO'} .
	       (length ($ENV{'QUERY_STRING'}) ? "?$ENV{'QUERY_STRING'}" : '');
}

sub print_html { $html_output .= join('',@_); }
sub printf_html { $html_output .= sprintf(@_); }

sub get_cookies {
	my ($key, $value);

	if (!defined $ENV{HTTP_COOKIE}) {
    log_printf("cookies error");
	  return;
	}
	%cookies = ();
	for my $i (split(/; /, $ENV{'HTTP_COOKIE'})) {
		($key, $value) = split(/=/,$i,2);
		$key   = unescape($key);
		$value = unescape($value);
#		log_printf(" cookie found: $key = $value");
		if (defined($cookies{$key})) {
			$cookies{$key}->[0] .= "\0" . $value;
		} else {
			$cookies{$key} = [$value];
		}
	}
}

sub set_cookies {
	my (@days) = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	my (@months) = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');

	my ($key,$expires,$domain,$path);
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$tmp);

	for $key (keys %cookies) {
# all altered cookies will have expires value
		if (defined $cookies{$key}->[1]) {
			($sec,$min,$hour,$mday,$mon,$year,$wday) = gmtime($cookies{$key}->[1]);

			my $value = escape($cookies{$key}->[0]);

			$expires = sprintf("%s, %d-%s-%d %02d:%02d:%02d GMT",
			  $days[$wday], $mday, $months[$mon], $year+1900,
		    $hour, $min, $sec);

			$tmp = "Set-Cookie: $key=$value; expires=$expires;";
			if ($cookies{$key}->[2]) { $tmp .= " domain=".$cookies{$key}->[2].";"; }
			else { $tmp .= " domain=".$ENV{'SERVER_NAME'}.";"; }
			if ($cookies{$key}->[3]) { $tmp .= " path=".$cookies{$key}->[3].";"; }
			else { $tmp .= " path=/;"; }
			$html_traffic += length($tmp)+1;
			print $tmp,"\n";
		}
	}
}

sub get_cookie {
	my ($key) = @_;
	if (!defined($cookies{$key})) { return undef; }
	return $cookies{$key}->[0];
}

sub set_cookie {
	my ($key,$value,$expires,$domain,$path) = @_;

	if (!$expires) {
		log_printf("Warning: set_cookie($key) called without expiration time - ignored.");
		return;
	}

	if ($domain && $path) {
		$cookies{$key} = [$value, $expires, $domain, $path];
	} 
	elsif ($domain) {
		$cookies{$key} = [$value, $expires, $domain];
	} 
	else {
		$cookies{$key} = [$value, $expires];
	}
}

sub delete_cookie {
	my ($i);
	for $i (@_) { $cookies{$i} = ['',0]; }
}


# Perl Routines to Manipulate CGI input
# S.E.Brenner@bioc.cam.ac.uk
# $Id: atom_html.pm 3434 2010-11-12 11:30:45Z dima $
#
# Copyright (c) 1996 Steven E. Brenner
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# Thanks are due to many people for reporting bugs and suggestions
# especially Meng Weng Wong, Maki Watanabe, Bo Frese Rasmussen,
# Andrew Dalke, Mark-Jason Dominus, Dave Dittrich, Jason Mathews

# For more information, see:
#     http://www.bio.cam.ac.uk/cgi-lib/

# Parameters affecting cgi-lib behavior
# User-configurable parameters affecting file upload.


# Do not change the following parameters unless you have special reasons

# ReadParse
# Reads in GET or POST data, converts it to unescaped text, and puts
# key/value pairs in %in, using "\0" to separate multiple selections

# Returns >0 if there was input, 0 if there was no input
# undef indicates some failure.

# Now that cgi scripts can be put in the normal file space, it is useful
# to combine both the form and the script in one place.  If no parameters
# are given (i.e., ReadParse returns FALSE), then a form could be output.

# If a reference to a hash is given, then the data will be stored in that
# hash, but the data from $in and @in will become inaccessable.
# If a variable-glob (e.g., *cgi_input) is the first parameter to ReadParse,
# information is stored there, rather than in $in, @in, and %in.
# Second, third, and fourth parameters fill associative arrays analagous to
# %in with data relevant to file uploads.

# If no method is given, the script will process both command-line arguments
# of the form: name=value and any text that is in $ENV{'QUERY_STRING'}
# This is intended to aid debugging and may be changed in future releases

sub ReadParseOld {
  my ($len, $type, $meth, $errflag, $cmdflag, $perlwarn, @in, $in);

  # Disable warnings as this code deliberately uses local and environment
  # variables which are preset to undef (i.e., not explicitly initialized)
  $perlwarn = $^W;
  $^W = 0;

  # Get several useful env variables
  $type = $ENV{'CONTENT_TYPE'};
  $len  = $ENV{'CONTENT_LENGTH'};
  $meth = $ENV{'REQUEST_METHOD'};

  if ($len > $maxdata) {
		error_printf("storehtml: Request to receive too much data: $len bytes (max $maxdata)");
  }

  if (!defined $meth || $meth eq '' || $meth eq 'GET' || $meth eq 'HEAD' ||
      $type eq 'application/x-www-form-urlencoded') {
    my ($key, $val, $i);

    # Read in text
    if (!defined $meth || $meth eq '') {
      $in = $ENV{'QUERY_STRING'};
      $cmdflag = 1;  # also use command-line options
    } elsif($meth eq 'GET' || $meth eq 'HEAD') {
      $in = $ENV{'QUERY_STRING'};
    } elsif ($meth eq 'POST') {
        $errflag = (read(STDIN, $in, $len) != $len);
    } else {
			return 1; # FIX AUTOMATIC LOOKUPS OF SEARCH ROBOTS
			error_printf("storehtml: Unknown request method: $meth");
    }

		# saving original request body
		$hin{'REQUEST_BODY'} = $in;

    @in = split(/[&;]/,$in);
    push(@in, @ARGV) if $cmdflag; # add command-line parameters

    for $i (0 .. $#in) {
      # Split into key and value.
      ($key, $val) = split(/=/,$in[$i],2); # splits on the first =.

      # Unescape them
			$key = unescape($key);
			$val = unescape($val);

      # Associate key and value
			# Mulitples disabled.
			#$h{$key} .= "\0" if (defined($h{$key})); # \0 is the multiple separator
			if (defined($hin{$key})) {
				log_printf("Warning: multiple $key found: $hin{$key}  and $val");
			}
      $hin{$key} = $val;
    }
  } elsif ($ENV{'CONTENT_TYPE'} =~ m#^multipart/form-data#) {
    # for efficiency, compile multipart code only if needed
#$errflag = !(eval <<'END_MULTIPART');

		my ($buf, $boundary, $head, @heads, $cd, $ct, $fname, $ctype, $blen);
		my ($bpos, $lpos, $left, $amt, $fn, $ser);
		my ($name);
		my ($bufsize, $maxbound, $writefiles) = ($bufsize, $maxbound, $writefiles);


		# The following lines exist solely to eliminate spurious warning messages
		$buf = '';

		($boundary) = $type =~ /boundary="([^"]+)"/; #";   # find boundary
		($boundary) = $type =~ /boundary=(\S+)/ unless $boundary;
		error_printf("storehtml: Boundary not provided") unless $boundary;
		$boundary =  "--" . $boundary;
		$blen = length ($boundary);

		if ($ENV{'REQUEST_METHOD'} ne 'POST') {
			error_printf("storehtml: Invalid request method for  multipart/form-data: $meth\n");
		}

		stat ($writefiles);
		if (!(-d _ && -r _ && -w _)) {
			error_printf("storehtml: Bad download directory \'$writefiles\'");
		}

    # read in the data and split into parts:
    # put headers in @in and data in %in
    # General algorithm:
    #   There are two dividers: the border and the '\r\n\r\n' between
    # header and body.  Iterate between searching for these
    #   Retain a buffer of size(bufsize+maxbound); the latter part is
    # to ensure that dividers don't get lost by wrapping between two bufs
    #   Look for a divider in the current batch.  If not found, then
    # save all of bufsize, move the maxbound extra buffer to the front of
    # the buffer, and read in a new bufsize bytes.  If a divider is found,
    # save everything up to the divider.  Then empty the buffer of everything
    # up to the end of the divider.  Refill buffer to bufsize+maxbound
    #   Note slightly odd organization.  Code before BODY: really goes with
    # code following HEAD:, but is put first to 'pre-fill' buffers.  BODY:
    # is placed before HEAD: because we first need to discard any 'preface,'
    # which would be analagous to a body without a preceeding head.

		$left = $len;
		PART: # find each part of the multi-part while reading data
		while (1) {
			last PART if $errflag;

			$amt = ($left > $bufsize+$maxbound-length($buf) ?  $bufsize+$maxbound-length($buf): $left);
			$errflag = (read(STDIN, $buf, $amt, length($buf)) != $amt);
			$left -= $amt;

			if (defined $hin{$name}) {
				log_printf("Warning: multiple $name found: $hin{$name} and '$fn'");
			}

			$hin{$name} .= $fn if $fn;
#log_printf(" $hin{$name}! ");
      $name=~/([-\w]+)/;  # This allows $insfn{$name} to be untainted
      if (defined $1) {
				$insfn{$1} .= "\0" if defined $insfn{$1};
				$insfn{$1} .= $fn if $fn;
			}

			BODY:
			while (($bpos = index($buf, $boundary)) == -1) {
				if ($name) {  # if no $name, then it's the prologue -- discard
					if ($fn) { print FILE substr($buf, 0, $bufsize); }
					else     { $hin{$name} .= substr($buf, 0, $bufsize); }
				}
				$buf = substr($buf, $bufsize);
				$amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
				$errflag = (read(STDIN, $buf, $amt, $maxbound) != $amt);
				$left -= $amt;
			}
			if (defined $name) {  # if no $name, then it's the prologue -- discard
				if ($fn) { print FILE substr($buf, 0, $bpos-2); }
				else     { $hin{$name} .= substr($buf, 0, $bpos-2); } # kill last \r\n
			}
			close (FILE);
			last PART if substr($buf, $bpos + $blen, 4) eq "--\r\n";
			substr($buf, 0, $bpos+$blen+2) = '';
			$amt = ($left > $bufsize+$maxbound-length($buf) ? $bufsize+$maxbound-length($buf) : $left);
			$errflag = (read(STDIN, $buf, $amt, length($buf)) != $amt);
			$left -= $amt;
			undef $head;  undef $fn;
			HEAD:
      while (($lpos = index($buf, "\r\n\r\n")) == -1) {
        $head .= substr($buf, 0, $bufsize);
        $buf = substr($buf, $bufsize);
        $amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
        $errflag = (read(STDIN, $buf, $amt, $maxbound) != $amt);
        $left -= $amt;
      }
      $head .= substr($buf, 0, $lpos+2);
      push (@in, $head);
      @heads = split("\r\n", $head);
      ($cd) = grep (/^\s*Content-Disposition:/i, @heads);
      ($ct) = grep (/^\s*Content-Type:/i, @heads);

      ($name) = $cd =~ /\bname="([^"]+)"/i; #";
      ($name) = $cd =~ /\bname=([^\s:;]+)/i unless defined $name;

      ($fname) = $cd =~ /\bfilename="([^"]*)"/i; #"; # filename can be null-str
      ($fname) = $cd =~ /\bfilename=([^\s:;]+)/i unless defined $fname;
      $incfn{$name} .= (defined $incfn{$name} ? "\0" : "") . $fname;

      ($ctype) = $ct =~ /^\s*Content-type:\s*"([^"]+)"/i;  #";
      ($ctype) = $ct =~ /^\s*Content-Type:\s*([^\s:;]+)/i unless defined $ctype;
      $inct{$name} .= (defined $inct{$name} ? "\0" : "") . $ctype;

      if ($writefiles && defined $fname) {
        $ser++;
				my $ending = '';
				if ($fname =~ /\.(.{3,4})$/) {
				 $ending = '.'.$1;
				}
				$fn = $writefiles . ".$$.$ser".$ending;

				push @$downloaded_files, $fn;

				open (FILE, ">$fn") || error_printf("storehtml: Unable to open $fn\n");
      }
      substr($buf, 0, $lpos+4) = '';
      undef $fname;
      undef $ctype;
    }
#
#1;
#END_MULTIPART

#  error_printf($@) if $errflag;
  } else {
    error_printf("storehtml: Unknown Content-type: $ENV{'CONTENT_TYPE'}\n");
  }

  $^W = $perlwarn;

  return ($errflag ? undef :  scalar(@in));
}

# ReadParse new
# Reads in GET or POST data, converts it to unescaped text, and puts
# key/value pairs in %in, using "\0" to separate multiple selections

# Returns >0 if there was input, 0 if there was no input
# undef indicates some failure.

# Now that cgi scripts can be put in the normal file space, it is useful
# to combine both the form and the script in one place.  If no parameters
# are given (i.e., ReadParse returns FALSE), then a form could be output.

# If a reference to a hash is given, then the data will be stored in that
# hash, but the data from $in and @in will become inaccessable.
# If a variable-glob (e.g., *cgi_input) is the first parameter to ReadParse,
# information is stored there, rather than in $in, @in, and %in.
# Second, third, and fourth parameters fill associative arrays analagous to
# %in with data relevant to file uploads.

# If no method is given, the script will process both command-line arguments
# of the form: name=value and any text that is in $ENV{'QUERY_STRING'}
# This is intended to aid debugging and may be changed in future releases

sub CgiDie {
    my ($errmsg) = @_;
    log_printf("HTTP PARSING ERROR\n".$errmsg);
    die;
}

sub ReadParse {

  my ($len, $type, $meth, $errflag, $cmdflag, $perlwarn, @in, $in);

  # Disable warnings as this code deliberately uses local and environment
  # variables which are preset to undef (i.e., not explicitly initialized)

  $perlwarn = $^W;
  $^W = 0;

#  local (*in) = shift if @_;    # CGI input
  local (*incfn,                # Client's filename (may not be provided)
	 *inct,                 # Client's content-type (may not be provided)
	 *insfn) = @_;          # Server's filename (for spooled files)

  binmode(STDIN);   # we need these for DOS-based systems
  binmode(STDOUT);  # and they shouldn't hurt anything else
  binmode(STDERR);

  # Get several useful env variables
  $type = $ENV{'CONTENT_TYPE'};
  $len  = $ENV{'CONTENT_LENGTH'};
  $meth = $ENV{'REQUEST_METHOD'};

  if ($len > $maxdata) { #'
      CgiDie("cgi-lib.pl: Request to receive too much data: $len bytes\n");
  }

  if (!defined $meth || $meth eq '' || $meth eq 'GET' ||
      $meth eq 'HEAD' ||
      $type eq 'application/x-www-form-urlencoded'
			|| $type eq 'text/xml'
			) {
    my ($key, $val, $i, $got);

    # Read in text
    if (!defined $meth || $meth eq '') {
      $in = $ENV{'QUERY_STRING'};
      $cmdflag = 1;  # also use command-line options
    } elsif($meth eq 'GET' || $meth eq 'HEAD') {
      $in = $ENV{'QUERY_STRING'};
    } elsif ($meth eq 'POST') {
        if (($got = read(STDIN, $in, $len) != $len))
	  {$errflag="Short Read: wanted $len, got $got\n";};
    } else {
      CgiDie("cgi-lib.pl: Unknown request method: $meth\n");
    }

		# saving original request body
		$hin{'REQUEST_BODY'} = $in;

    @in = split(/[&;]/,$in);
    push(@in, @ARGV) if $cmdflag; # add command-line parameters

    for $i (0 .. $#in) {
      # Convert plus to space
      $in[$i] =~ s/\+/ /g;

      # Split into key and value.
      ($key, $val) = split(/=/,$in[$i],2); # splits on the first =.

      # Convert %XX from hex numbers to alphanumeric
      $key =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
      $val =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;

			# decode character combinations to utf8-chars
			utf8::decode($val);

#		 log_printf("POST: ".$key." = ".$val."\n");
      # Associate key and value
#			if(!$hin{$key}){
     		 $hin{$key} = $val;
#			} else {
			  # multiples hin entries found. ignoring
#			}
    }

  } 
  elsif ($ENV{'CONTENT_TYPE'} =~ m#^multipart/form-data# ) {
    # for efficiency, compile multipart code only if needed
$errflag = !(eval <<'END_MULTIPART');

    my ($buf, $boundary, $head, @heads, $cd, $ct, $fname, $ctype, $blen);
    my ($bpos, $lpos, $left, $amt, $fn, $ser, $got, $name, $value);


    # The following lines exist solely to eliminate spurious warning messages
    $buf = '';

    ($boundary) = $type =~ /boundary="([^"]+)"/; #";   # find boundary
    ($boundary) = $type =~ /boundary=(\S+)/ unless $boundary;
    CgiDie ("Boundary not provided: probably a bug in your server")
      unless $boundary;
    $boundary =  "--" . $boundary;
    $blen = length ($boundary);

    if ($ENV{'REQUEST_METHOD'} ne 'POST') {
      CgiDie("Invalid request method for  multipart/form-data: $meth\n");
    }

    if ($writefiles) {
      my ($me);
      stat ($writefiles);
			if (!(-d _ && -r _ && -w _)) {
				error_printf("storehtml: Bad download directory \'$writefiles\'");
			}
    }

    # read in the data and split into parts:
    # put headers in @in and data in %in
    # General algorithm:
    #   There are two dividers: the border and the '\r\n\r\n' between
    # header and body.  Iterate between searching for these
    #   Retain a buffer of size(bufsize+maxbound); the latter part is
    # to ensure that dividers don't get lost by wrapping between two bufs
    #   Look for a divider in the current batch.  If not found, then
    # save all of bufsize, move the maxbound extra buffer to the front of
    # the buffer, and read in a new bufsize bytes.  If a divider is found,
    # save everything up to the divider.  Then empty the buffer of everything
    # up to the end of the divider.  Refill buffer to bufsize+maxbound
    #   Note slightly odd organization.  Code before BODY: really goes with
    # code following HEAD:, but is put first to 'pre-fill' buffers.  BODY:
    # is placed before HEAD: because we first need to discard any 'preface,'
    # which would be analagous to a body without a preceeding head.

    $left = $len;
   PART: # find each part of the multi-part while reading data
    while (1) {
      die $@ if $errflag;

      $amt = ($left > $bufsize+$maxbound-length($buf)
	      ?  $bufsize+$maxbound-length($buf): $left);
      $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
      die "Short Read: wanted $amt, got $got\n" if $errflag;
      $left -= $amt;

      $hin{$name} .= "\0" if defined $hin{$name};
      $hin{$name} .= $fn if $fn;

      $name=~/([-\w]+)/;  # This allows $insfn{$name} to be untainted
      if (defined $1) {
        $insfn{$1} .= "\0" if defined $insfn{$1};
        $insfn{$1} .= $fn if $fn;
      }

     BODY:
      while (($bpos = index($buf, $boundary)) == -1) {
        if ($left == 0 && $buf eq '') {
	  for $value (values %insfn) {
            unlink(split("\0",$value));
	  }
	  CgiDie("cgi-lib.pl: reached end of input while seeking boundary " .
		  "of multipart. Format of CGI input is wrong.\n");
        }
        die $@ if $errflag;
        if ($name) {  # if no $name, then it's the prologue -- discard
          if ($fn) { print FILE substr($buf, 0, $bufsize); }
          else     {
						$hin{$name} .= substr($buf, 0, $bufsize);
						Encode::_utf8_on($hin {$name});
					}
        }
        $buf = substr($buf, $bufsize);
        $amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
        $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
	die "Short Read: wanted $amt, got $got\n" if $errflag;
        $left -= $amt;
      }
      if (defined $name) {  # if no $name, then it's the prologue -- discard
        if ($fn) { print FILE substr($buf, 0, $bpos-2); }
        else     {
					$hin {$name} .= substr($buf, 0, $bpos-2);
					Encode::_utf8_on($hin {$name});
				} # kill last \r\n
      }
      close (FILE);
      last PART if substr($buf, $bpos + $blen, 2) eq "--";
      substr($buf, 0, $bpos+$blen+2) = '';
      $amt = ($left > $bufsize+$maxbound-length($buf)
	      ? $bufsize+$maxbound-length($buf) : $left);
      $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
      die "Short Read: wanted $amt, got $got\n" if $errflag;
      $left -= $amt;


      undef $head;  undef $fn;
     HEAD:
      while (($lpos = index($buf, "\r\n\r\n")) == -1) {
        if ($left == 0  && $buf eq '') {
	  for $value (values %insfn) {
            unlink(split("\0",$value));
	  }
	  CgiDie("cgi-lib: reached end of input while seeking end of " .
		  "headers. Format of CGI input is wrong.\n$buf");
        }
        die $@ if $errflag;
        $head .= substr($buf, 0, $bufsize);
        $buf = substr($buf, $bufsize);
        $amt = ($left > $bufsize ? $bufsize : $left); #$maxbound==length($buf);
        $errflag = (($got = read(STDIN, $buf, $amt, length($buf))) != $amt);
        die "Short Read: wanted $amt, got $got\n" if $errflag;
        $left -= $amt;
      }
      $head .= substr($buf, 0, $lpos+2);
      push (@in, $head);
      @heads = split("\r\n", $head);
      ($cd) = grep (/^\s*Content-Disposition:/i, @heads);
      ($ct) = grep (/^\s*Content-Type:/i, @heads);

      ($name) = $cd =~ /\bname="([^"]+)"/i; #";
      ($name) = $cd =~ /\bname=([^\s:;]+)/i unless defined $name;

      ($fname) = $cd =~ /\bfilename="([^"]*)"/i; #"; # filename can be null-str
      ($fname) = $cd =~ /\bfilename=([^\s:;]+)/i unless defined $fname;
      $incfn{$name} .= (defined $hin{$name} ? "\0" : "") .
        (defined $fname ? $fname : "");

      ($ctype) = $ct =~ /^\s*Content-type:\s*"([^"]+)"/i;  #";
      ($ctype) = $ct =~ /^\s*Content-Type:\s*([^\s:;]+)/i unless defined $ctype;
      $inct{$name} .= (defined $hin{$name} ? "\0" : "") . $ctype;

      if ($writefiles && defined $fname) {
        $ser++;
				my $ending = '';
				if($fname =~ /\.(.{3,4})$/){
				 $ending = '.'.$1;
				}
				$fn = $writefiles . ".$$.$ser".$ending;

				log_printf('FILE = '.$fn);

				push @$downloaded_files, $fn;

				open (FILE, ">$fn") || CgiDie("Couldn't open $fn\n");
        binmode (FILE);  # write files accurately
				$hin{'file_content_type'} = $ctype;
				$hin{'file_name'} = $fname;
      }
      substr($buf, 0, $lpos+4) = '';
      undef $fname;
      undef $ctype;
    }

1;
END_MULTIPART
    if ($errflag) {
      my ($errmsg, $value);
      $errmsg = $@ || $errflag;
      for $value (values %insfn) {
        unlink(split("\0",$value));
      }
			log_printf($errmsg);
      CgiDie($errmsg);
    } else {
      # everything's ok.
			#log_printf("HIN = ".Dumper(%hin));
    }
  } else {
    CgiDie("cgi-lib.pl: Unknown Content-type: $ENV{'CONTENT_TYPE'}\n");
  }

  # no-ops to avoid warnings

  $^W = $perlwarn;

  return ($errflag ? undef :  scalar(@in));
}



# parses environment
BEGIN {
	use Exporter ();
	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	$VERSION = 1.00; @ISA = qw(Exporter);	%EXPORT_TAGS = (); @EXPORT_OK = ();
	@EXPORT = qw(&print_html &printf_html &get_full_URL &get_base_URL &is_request_method_GET
	             &is_request_method_POST &split_multiple &get_cookie &set_cookie &delete_cookie
	             %hin %hout %hl %hs &make_html_hash $sessid %incfn %inct %insfn &str_htmlize &str_unhtmlize %hrout
	             $html_traffic &html_start &html_finish &get_base_URL_wo_script &get_user_agent
	             &html_start_no_sessions &html_finish_no_sessions $jump_to_location
							 &get_secure_base_URL &encode_sessid &decode_sessid &new_session
							 &get_secure_base_URL_wo_script
							 get_non_secure_base_URL_wo_script
							 $ssl
							 );
	$bufsize  = $atomcfg{'cgi_bufsize'};  # default buffer size when reading multipart
	$maxbound = $atomcfg{'cgi_maxbound'}; # maximum boundary length to be encounterd
	$maxdata  = $atomcfg{'cgi_maxdata'};
	$writefiles = $atomcfg{'download_path'};
}

END {
	#cleaing up uploaded files
	for my $file (@$downloaded_files) {
		system("rm", "-f", $file);
	}
}

sub html_start {
	$html_traffic = 0;
	%hin = (); %hout = (); %hl = (); %hs = (); # for modperl
	detect_ssl;
	get_cookies;
	ReadParse;
	load_session;
	$html_output = '';
	$jump_to_location = '';
}

sub detect_ssl {
	$ssl = ( $ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'} ) ? 1 : 0;
}

sub preserve_globals {
 # this should save and pass global parameters

}

sub html_finish {
	my $ajaxed = shift;

	if (!$storelog::error_happened) {
	  preserve_globals;
		save_session;
		set_cookies;
		if ($jump_to_location ne '') {
			#my $loginPassEncoded = '';

			if ($ENV{'HTTP_USER_AGENT'} =~ /microsoft|msie/i) { # only for IE & location+authorization
				if ($jump_to_location =~ /^(https?:\/\/)([^\/]+:[^\/]+)\@(.+)$/i) {
					#use MIME::Base64;
					log_printf("IE + location + authorization");
					$jump_to_location = $1.$3;
					#$loginPassEncoded = encode_base64($2);
				}
			}

			print "Location: $jump_to_location\n";
#			print "Authorization: Basic $loginPassEncoded\n" if $loginPassEncoded; # disabled
		}
		if ($ajaxed eq 'ajaxed') {
			return $html_output;
		}
		else {
			html_finish_content;
		}
	}
}

sub html_start_no_sessions {
	$html_traffic = 0;
	get_cookies;
	ReadParse;
	$html_output = '';
}

use FileHandle;
use IPC::Open2;

sub html_finish_content {
	if (index($ENV{'HTTP_ACCEPT_ENCODING'},'gzip') >= 0) {
#		undef local $/;
#		my $pid = open2(*gzRDR,*gzWTR,'gzip');
#		gzWTR->autoflush();
#		print gzWTR $html_output;
#		close gzWTR;
		$html_output = gzip_data($html_output);
#		close gzRDR;
#		log_printf("Content-Type: text/html; charset=utf-8\n");
#		log_printf("Content-Encoding: gzip\n\n");
		print "Content-Type: text/html; charset=utf-8\n";
		print "Content-Encoding: gzip\n\n";
		$html_traffic += length("Content-Type: text/html; charset=utf-8\nContent-Encoding: gzip\n\n") + length($html_output);
	} else {
#		log_printf("Content-Type: text/html; charset=utf-8\n\n");
		print "Content-Type: text/html; charset=utf-8\n\n";
		$html_traffic += length("Content-Type: text/html; charset=utf-8\n\n") + length($html_output);
		binmode(STDOUT,":utf8");
	}
	print $html_output;
#	log_printf($html_output);
	STDOUT->flush();
}

sub gzip_data {
 my ($data) = @_;
 my $dirname = $atomcfg{'session_path'};
 my $gz = $dirname."tmp-".time().make_code(20).".gz";


 open(GZIP,"|gzip -c9>$gz");
 binmode(GZIP,":utf8");
 print GZIP $data;
 close(GZIP);

 my $compdata = undef;
 my $buffer;

 open(GZIPPED,"<$gz");
  while(read(GZIPPED,$buffer,4096)){ $compdata .= $buffer;}
 close(GZIPPED);

 system("rm",$gz);
 return $compdata;
}



sub get_base_URL_wo_script {
	return (($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'})?'https://':'http://') . $ENV{'SERVER_NAME'} .

  ((($ENV{'SERVER_PORT'} != 80 && !$ENV{'SSL_SESSION_ID'} && !$ENV{'SSL_PROTOCOL_VERSION'})
	|| ($ENV{'SERVER_PORT'} !=443 && ($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'})))
	 ? ":$ENV{'SERVER_PORT'}" : '');
}

sub get_non_secure_base_URL_wo_script {
	return 'http://'. $ENV{'SERVER_NAME'};
}

sub get_base_URL {
	return get_base_URL_wo_script().
    ($ENV{'SCRIPT_NAME'} eq ''?$atomcfg{'default_url_path'}:$ENV{'SCRIPT_NAME'});
}

sub get_non_secure_base_URL {
	return get_non_secure_base_URL_wo_script().
    ($ENV{'SCRIPT_NAME'} eq ''?$atomcfg{'default_url_path'}:$ENV{'SCRIPT_NAME'});
}


sub get_secure_base_URL_wo_script {
	return 'https://' . $ENV{'SERVER_NAME'}.
	(($ENV{'SERVER_PORT'} !=443 && ($ENV{'SSL_SESSION_ID'} || $ENV{'SSL_PROTOCOL_VERSION'}))
	? ":$ENV{'SERVER_PORT'}" : '');
}

sub get_secure_base_URL {
# no ssl
#	return get_secure_base_URL_wo_script().($ENV{'SCRIPT_NAME'} eq ''?$atomcfg{'default_url_path'}:$ENV{'SCRIPT_NAME'});
  return get_base_URL;
}

sub get_full_URL {
	return get_base_URL().$ENV{'PATH_INFO'} .
	       (length ($ENV{'QUERY_STRING'}) ? "?$ENV{'QUERY_STRING'}" : '');
}


1;

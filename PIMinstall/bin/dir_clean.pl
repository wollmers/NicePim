#!/usr/bin/perl

#$Id: dir_clean.pl 2432 2010-04-19 21:22:25Z dima $

use strict;

#use lib '/home/dima/gcc_svn/lib';
use lib '/home/pim/lib';

use thumbnail;
use atomcfg;
use atomsql;
use atomlog;

use File::Basename;
use File::Copy;
use File::Listing;
use Time::ParseDate;
use Data::Dumper;

$| = 1;

my $twoweeksago = &parsedate("2 weeks ago");

my $backup_path = $atomcfg{'base_dir'}.'backup/icecat_archive/';
my $backuplog_path = $backup_path;
my $images_path = $atomcfg{'base_dir'}.'images_cache/';
my $tmp_path = $atomcfg{'base_dir'}.'tmp/';
my $pdf_path = $atomcfg{'base_dir'}.'www/pdf/';
my $thumbs_path = $atomcfg{'base_dir'}.'www/thumbs/';
my $low_pic_path = $atomcfg{'base_dir'}.'www/img/low_pic/';
my $high_pic_path = $atomcfg{'base_dir'}.'www/img/high_pic/';
my $norm_low_path = $atomcfg{'base_dir'}.'www/img/norm/low/';
my $norm_high_path = $atomcfg{'base_dir'}.'www/img/norm/high/';
my $gallery_path = $atomcfg{'base_dir'}.'www/img/gallery/';
my $gallery_thumbs_path = $atomcfg{'base_dir'}.'www/img/gallery_thumbs/';
my $families_path = $atomcfg{'base_dir'}.'www/img/families/';
my $supplier_path = $atomcfg{'base_dir'}.'www/img/supplier/';
my $objects_path = $atomcfg{'base_dir'}.'www/objects/';
my $campaign_path = $atomcfg{'base_dir'}."www/campaign/";
my $campaign_thumbs_path = $atomcfg{'base_dir'}."www/campaign_thumbs/";

# remote paths
my $images_server_path = "www\@images%%number%%.icecat.biz"; # global
my $backup_path_remote = $atomcfg{'images_www_path'}."backup/";
my $thumbs_path_remote = $atomcfg{'images_www_path'}."thumbs/";
my $low_path_remote = $atomcfg{'images_path'}."low_pic/";
my $high_path_remote = $atomcfg{'images_path'}."high_pic/";
my $norm_low_path_remote = $atomcfg{'images_path'}."norm/low/";
my $norm_high_path_remote = $atomcfg{'images_path'}."norm/high/";
my $gallery_path_remote = $atomcfg{'images_path'}."gallery/";
my $gallery_thumbs_path_remote = $atomcfg{'images_path'}."gallery_thumbs/";
my $families_path_remote = $atomcfg{'images_path'}."families/";
my $supplier_path_remote = $atomcfg{'images_path'}."supplier/";
my $campaign_path_remote = $atomcfg{'images_path'}."campaign/";
my $campaign_thumbs_path_remote = $atomcfg{'images_path'}."campaign_thumbs/";

print "Started\n";
if (!opendir(BACKUP, $backup_path)) {
  mkdir($backup_path) or die ("can't mkdir $backup_path: $!");
} else {
  closedir(BACKUP);
}
print "Backup path tested\n";
print "BEFORE: backup_files\n";

sub backup_files {
  my ($backup_path, $dir_path, $base, $remote_host) = @_;

	# checking for live server
	if (&do_query("desc product")->[0][0] ne 'product_id') {
		print "MySQL is down. Exiting...\n\n";
		die;
	}

	my ($cmd, $ls, $ts, $move);

	print "\xB7";

	$move = 0;

	# correct path, if remote
	my $dir_path_local = '';
	my $remote_host = '';
	if ($dir_path =~ /\:\//) {
		$dir_path =~ /^(.*?)\:(.*)$/s;
		$remote_host = "/usr/bin/ssh ".$1;
		$dir_path_local = $2;
	}
	else {
		$dir_path_local = $dir_path;
	}

	$cmd = $remote_host." /bin/ls -l --time-style=long-iso ".$dir_path_local.$base;
	open LS, $cmd." |";
	binmode LS, ":utf8";
	$ls = join "", <LS>;
	close LS;
	$ls =~ s/^.{10}\s\d+\s\w+\s\w+\s\d+\s(\d+\-\d+\-\d+\s\d+\:\d+)\s.*$/$1/;
	if ($ls) {
		$ts = &parsedate($ls);
		if ($ts < $twoweeksago) {
			$move = 1;
		}
		else {
			$move = -1;
		}
	}
	else {
		$move = 1;
	}

	if ($move > 0) {
		$cmd = $remote_host." /bin/mkdir -p ".$backup_path.$dir_path_local;
		print "\t\t".$cmd."\n";
		`$cmd`;
		$cmd = $remote_host." /bin/mv -f ".$dir_path_local.$base." ".$backup_path.$dir_path_local.$base;
		print "\t\t".$cmd."\n";
		`$cmd`;
	}
	elsif ($move == -1) {
		print "\t\t".$dir_path_local.$base." newer than 2 weeks. leave it as is\n";
	}

	print BACKUPLOG $dir_path.$base."\n";
}

print "AFTER: backup_files\n";
open(BACKUPLOG, ">>".$backuplog_path."backuplog") or print "Can't open backuplogs: $!"; # opening BACKUPLOG filehandler
binmode(BACKUPLOG, ":utf8");

# Remote processing directories www/thumbs/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$thumbs_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$thumbs_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($thumbs_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		my $qstr = $file.$ext;
		my ($query_thumbs_category, $res_thumbs, $query_thumbs_product, $query_thumbs_supplier, $query_thumbs_product_family);
		$query_thumbs_category = "SELECT thumb_pic FROM category_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_thumbs_product = "SELECT thumb_pic FROM product_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_thumbs_product_family = "SELECT thumb_pic FROM product_family_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_thumbs_supplier = "SELECT thumb_pic FROM supplier_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_thumbs = &do_query($query_thumbs_category)->[0] ||
			&do_query($query_thumbs_product)->[0] ||
			&do_query($query_thumbs_supplier)->[0] ||
			&do_query($query_thumbs_product_family)->[0];
		if ($res_thumbs eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$thumbs_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/norm/low/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$norm_low_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$norm_low_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($norm_low_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_low_pic_category, $res_low_pic, $query_low_pic_product, $query_low_pic_product_family, $query_low_pic_supplier);
		$query_low_pic_category = "SELECT low_pic FROM category_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_product = "SELECT low_pic FROM product_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_product_family = "SELECT low_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_supplier = "SELECT low_pic FROM supplier WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_low_pic = &do_query($query_low_pic_category)->[0] ||
			&do_query($query_low_pic_product)->[0] ||
			&do_query($query_low_pic_product_family)->[0] ||
			&do_query($query_low_pic_supplier)->[0];
		if ($res_low_pic eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$norm_low_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/low_pic/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$low_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$low_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($low_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_low_pic_category, $res_low_pic, $query_low_pic_product, $query_low_pic_product_family, $query_low_pic_supplier);
		$query_low_pic_category = "SELECT low_pic FROM category_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_product = "SELECT low_pic FROM product_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_product_family = "SELECT low_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$query_low_pic_supplier = "SELECT low_pic FROM supplier WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_low_pic = &do_query($query_low_pic_category)->[0] ||
			&do_query($query_low_pic_product)->[0] ||
			&do_query($query_low_pic_product_family)->[0] ||
			&do_query($query_low_pic_supplier)->[0];
		if ($res_low_pic eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$low_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/norm/high/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$norm_high_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$norm_high_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($norm_high_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_norm_high_product, $res_norm_high_product);
		$query_norm_high_product = "SELECT high_pic FROM product_reverse WHERE high_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_norm_high_product = &do_query($query_norm_high_product);
		if ($res_norm_high_product->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$norm_high_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/high_pic/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$high_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$high_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($high_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_norm_high_product, $res_norm_high_product);
		$query_norm_high_product = "SELECT high_pic FROM product_reverse WHERE high_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_norm_high_product = &do_query($query_norm_high_product);
		if ($res_norm_high_product->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$high_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/gallery/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$gallery_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$gallery_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($gallery_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_product_gallery, $res_product_gallery);
		$query_product_gallery = "SELECT link FROM product_gallery_reverse WHERE link LIKE REVERSE('%".$qstr."') limit 1";
		$res_product_gallery = &do_query($query_product_gallery);
		if ($res_product_gallery->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$gallery_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/gallery_thumbs/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$gallery_thumbs_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$gallery_thumbs_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($gallery_thumbs_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_product_gallery, $res_product_gallery);
		$query_product_gallery = "SELECT thumb_link FROM product_gallery_reverse WHERE thumb_link LIKE REVERSE('%".$qstr."') limit 1";
		$res_product_gallery = &do_query($query_product_gallery);
		if ($res_product_gallery->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$gallery_thumbs_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/campaign/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$campaign_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$campaign_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($campaign_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_campaign_gallery, $res_campaign);
		$query_campaign_gallery = "SELECT logo_pic FROM campaign_gallery_reverse WHERE logo_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_campaign = &do_query($query_campaign_gallery);
		if ($res_campaign->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$campaign_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/campaign_thumbs/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$campaign_thumbs_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$campaign_thumbs_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($campaign_thumbs_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_campaign_gallery, $res_campaign);
		$query_campaign_gallery = "SELECT thumb_pic FROM campaign_gallery_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_campaign = &do_query($query_campaign_gallery);
		if ($res_campaign->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$campaign_thumbs_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/families/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$families_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$families_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($families_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_product_family, $res_product_family);
		$query_product_family = "SELECT low_pic, thumb_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') OR thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_product_family = &do_query($query_product_family);
		if ($res_product_family->[0] eq '') {
			&backup_files($backup_path_remote, $images_server_path_current.':'.$families_path_remote, $base);
		}
	}
}

# Remote processing directories www/img/supplier/
foreach ('') {
	my $images_server_path_current = $images_server_path;
	$images_server_path_current =~ s/%%number%%/$_/s;
	print "Remote processing files in ".$images_server_path_current.$supplier_path_remote.":\n\n";
	my $base;
	my $cmd = "/usr/bin/ssh ".$images_server_path_current." ls -l ".$supplier_path_remote;
	print $cmd."\n";
	for (parse_dir(`$cmd`)) {
		print "file: ".@$_[0]."\n";
		$base = @$_[0];
		next if &doNext($base);
		my $path = basename($supplier_path_remote.'/'.$base);
		my ($file, $dir, $ext) = fileparse($path, '\..*');
		#print "$base\n";
		my $qstr = $file.$ext;
		my ($query_supplier, $res_supplier);
		$query_supplier = "SELECT low_pic, thumb_pic FROM supplier_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') OR thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
		$res_supplier = &do_query($query_supplier);
		if ($res_supplier->[0] eq '')	{
			&backup_files($backup_path_remote, $images_server_path_current.':'.$supplier_path_remote, $base);
		}
	}
}

# Processing directory www/img/low_pic/
print "Processing files in $low_pic_path:\n\n";
opendir(LOWPIC, $low_pic_path) or die "Can't open $low_pic_path: $!";
while (defined(my $base = readdir LOWPIC)) {
	next if &doNext($base);
  my $path = basename($low_pic_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_low_pic_category, $res_low_pic, $query_low_pic_product, $query_low_pic_product_family, $query_low_pic_supplier);
  $query_low_pic_category = "SELECT low_pic FROM category_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_low_pic_product = "SELECT low_pic FROM product_reverse WHERE low_pic LIKE REVERSE('%".$qstr."%') limit 1";
  $query_low_pic_product_family = "SELECT low_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."%') limit 1";
  $query_low_pic_supplier = "SELECT low_pic FROM supplier WHERE low_pic LIKE REVERSE('%".$qstr."%') limit 1";
  $res_low_pic = &do_query($query_low_pic_category)->[0] ||
		&do_query($query_low_pic_product)->[0] ||
		&do_query($query_low_pic_product_family)->[0] ||
		&do_query($query_low_pic_supplier)->[0];
  if ($res_low_pic eq '') {
		&backup_files($backup_path, $low_pic_path, $base);
  }
}
closedir(LOWPIC);

# Processing directory tmp/
# Removing old session in db at
&delete_rows('session','updated < (unix_timestamp() - 24*3600)');

print "Processing files in $tmp_path:\n\n";
opendir(SESS, $tmp_path) or die "Can't open $tmp_path: $!";
while (defined(my $base = readdir SESS)) {
	next if &doNext($base);
  my $path = basename($tmp_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  if (length($ext) > '6') { # check for extensions that includes session_code > 6 symbols
    my $timediff = (-M $tmp_path.'/'.$base);
    if ($timediff > 1) {
      &backup_files($backup_path, $tmp_path, $base);
      next;
    }
    my $qstr = $ext;
    $qstr =~ s/^.//;
    my ($query_session, $res_session);
    $query_session = "SELECT code FROM session WHERE code = '".$qstr."' limit 1";
    $res_session = &do_query($query_session);
    if ($res_session->[0] eq '') {
      &backup_files($backup_path, $tmp_path, $base);
    }
  }
	else { # backups all other files
		&backup_files($backup_path, $tmp_path, $base);
	}
}
closedir(SESS);

# Processing directory www/pdf/
print "Processing files in $pdf_path:\n\n";
opendir(PDF, $pdf_path) or die "Can't open $pdf_path: $!";
while (defined(my $base = readdir PDF)) {
	next if &doNext($base);
	next if (-d $pdf_path.'/'.$base);
  my $path = basename($pdf_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_pdf, $query_manual_pdf, $res_pdf);
  $query_pdf = "SELECT pdf_url FROM product_description_reverse WHERE pdf_url LIKE REVERSE('%icecat%".$qstr."') limit 1";
  $query_manual_pdf = "SELECT manual_pdf_url FROM product_description_reverse WHERE manual_pdf_url LIKE REVERSE('%icecat%".$qstr."') limit 1";
  $res_pdf = &do_query($query_pdf)->[0] || &do_query($query_manual_pdf)->[0];
  if ($res_pdf eq '') {
    &backup_files($backup_path, $pdf_path, $base);
  }
}
closedir(PDF);

# Processing directory www/thumbs/
print "Processing files in $thumbs_path:\n\n";
opendir(THUMBS, $thumbs_path) or die "Can't open $thumbs_path: $!";
while (defined(my $base = readdir THUMBS)) {
	next if &doNext($base);
  my $path = basename($thumbs_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_thumbs_category, $res_thumbs, $query_thumbs_product, $query_thumbs_supplier, $query_thumbs_product_family);
  $query_thumbs_category = "SELECT thumb_pic FROM category_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_thumbs_product = "SELECT thumb_pic FROM product_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_thumbs_product_family = "SELECT thumb_pic FROM product_family_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_thumbs_supplier = "SELECT thumb_pic FROM supplier_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_thumbs = &do_query($query_thumbs_category)->[0] ||
		&do_query($query_thumbs_product)->[0] ||
		&do_query($query_thumbs_supplier)->[0] ||
		&do_query($query_thumbs_product_family)->[0];
  if ($res_thumbs eq '') {
		&backup_files($backup_path, $thumbs_path, $base);
  }
}
closedir(THUMBS);

# Processing directory www/img/high_pic/
print "Processing files in $high_pic_path:\n\n";
opendir(HIGHPIC, $high_pic_path) or die "Can't open $high_pic_path: $!";
while (defined(my $base = readdir HIGHPIC)) {
	next if &doNext($base);
  my $path = basename($high_pic_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_high_pic_product, $res_high_pic_product);
  $query_high_pic_product = "SELECT high_pic FROM product_reverse WHERE high_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_high_pic_product = &do_query($query_high_pic_product);
  if ($res_high_pic_product->[0] eq '') {
    &backup_files($backup_path, $high_pic_path, $base);
  }
}
closedir(HIGHPIC);

# Processing directory www/img/norm/low/
print "Processing files in $norm_low_path:\n\n";
opendir(NORMLOW, $norm_low_path) or die "Can't open $norm_low_path: $!";
while (defined(my $base = readdir NORMLOW)) {
	next if &doNext($base);
  my $path = basename($norm_low_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_norm_low_category, $res_norm_low, $query_norm_low_product, $res_norm_low_product, 
      $query_norm_low_product_family, $res_norm_low_product_family, $query_norm_low_supplier, $res_norm_low_supplier);
  $query_norm_low_category = "SELECT low_pic FROM category_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_norm_low_product = "SELECT low_pic FROM product_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_norm_low_product_family = "SELECT low_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
  $query_norm_low_supplier = "SELECT low_pic FROM supplier_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_norm_low = &do_query($query_norm_low_category)->[0] ||
		&do_query($query_norm_low_product)->[0] ||
		&do_query($query_norm_low_product_family)->[0] ||
		&do_query($query_norm_low_supplier)->[0];
  if ($res_norm_low) {
		&backup_files($backup_path, $norm_low_path, $base);
  }
}
closedir(NORMLOW);

# Processing directory www/img/norm/high/
print "Processing files in $norm_high_path:\n\n";
opendir(NORMHIGH, $norm_high_path) or die "Can't open $norm_high_path: $!";
while (defined(my $base = readdir NORMHIGH)) {
	next if &doNext($base);
  my $path = basename($norm_high_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_norm_high_product, $res_norm_high_product);
  $query_norm_high_product = "SELECT high_pic FROM product_reverse WHERE high_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_norm_high_product = &do_query($query_norm_high_product);
  if ($res_norm_high_product->[0] eq '') {
    &backup_files($backup_path, $norm_high_path, $base);
  }
}
closedir(NORMHIGH);

# Processing directory www/img/gallery/
print "Processing files in $gallery_path:\n\n";
opendir(GALLERY, $gallery_path) or die "Can't open $gallery_path: $!";
while (defined(my $base = readdir GALLERY)) {
	next if &doNext($base);
  my $path = basename($gallery_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_product_gallery, $res_product_gallery);
  $query_product_gallery = "SELECT link FROM product_gallery_reverse WHERE link LIKE REVERSE('%".$qstr."') limit 1";
  $res_product_gallery = &do_query($query_product_gallery);
  if ($res_product_gallery->[0] eq '') {
    &backup_files($backup_path, $gallery_path, $base);
  }
}
closedir(GALLERY);


# Processing directory www/img/gallery_thumbs/
print "Processing files in $gallery_thumbs_path:\n\n";
opendir(GALTHUMB, $gallery_thumbs_path) or die "Can't open $gallery_thumbs_path: $!";
while (defined(my $base = readdir GALTHUMB)) {
	next if &doNext($base);
  my $path = basename($gallery_thumbs_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_product_gallery_thumbs, $res_product_gallery_thumbs);
  $query_product_gallery_thumbs = "SELECT thumb_link FROM product_gallery_reverse WHERE thumb_link LIKE REVERSE('%".$qstr."') limit 1";
  $res_product_gallery_thumbs = &do_query($query_product_gallery_thumbs);
  if ($res_product_gallery_thumbs->[0] eq '') {
    &backup_files($backup_path, $gallery_thumbs_path, $base);
  }
}
closedir(GALTHUMB);


# Processing directory www/img/campaign/
print "Processing files in $campaign_path:\n\n";
opendir(CAMPAIGN, $campaign_path) or die "Can't open $campaign_path: $!";
while (defined(my $base = readdir CAMPAIGN)) {
	next if &doNext($base);
  my $path = basename($campaign_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_campaign_gallery, $res_campaign);
  $query_campaign_gallery = "SELECT logo_pic FROM campaign_gallery_reverse WHERE logo_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_campaign = &do_query($query_campaign_gallery);
  if ($res_campaign->[0] eq '') {
    &backup_files($backup_path, $campaign_path, $base);
  }
}
closedir(CAMPAIGN);


# Processing directory www/img/campaign_thumbs/
print "Processing files in $campaign_thumbs_path:\n\n";
opendir(CAMPAIGNTHUMBS, $campaign_thumbs_path) or die "Can't open $campaign_thumbs_path: $!";
while (defined(my $base = readdir CAMPAIGNTHUMBS)) {
	next if &doNext($base);
  my $path = basename($campaign_thumbs_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_campaign_gallery_thumbs, $res_campaign_thumbs);
  $query_campaign_gallery_thumbs = "SELECT thumb_pic FROM campaign_gallery_reverse WHERE thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_campaign_thumbs = &do_query($query_campaign_gallery_thumbs);
  if ($res_campaign_thumbs->[0] eq '') {
    &backup_files($backup_path, $campaign_thumbs_path, $base);
  }
}
closedir(CAMPAIGNTHUMBS);


# Processing directory www/img/families/
print "Processing files in $families_path:\n\n";
opendir(FAMILIES, $families_path) or die "Can't open $families_path: $!";
while (defined(my $base = readdir FAMILIES)) {
	next if &doNext($base);
  my $path = basename($families_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_product_family, $res_product_family);
  $query_product_family = "SELECT low_pic, thumb_pic FROM product_family_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') OR thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_product_family = &do_query($query_product_family);
  if ($res_product_family->[0] eq '') {
    &backup_files($backup_path, $families_path, $base);
  }
}
closedir(FAMILIES);


# Processing directory www/img/supplier/
print "Processing files in $supplier_path:\n\n";
opendir(SUPPLIER, $supplier_path) or die "Can't open $supplier_path: $!";
while (defined(my $base = readdir SUPPLIER)) {
	next if &doNext($base);
  my $path = basename($supplier_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_supplier, $res_supplier);
  $query_supplier = "SELECT low_pic, thumb_pic FROM supplier_reverse WHERE low_pic LIKE REVERSE('%".$qstr."') OR thumb_pic LIKE REVERSE('%".$qstr."') limit 1";
  $res_supplier = &do_query($query_supplier);
  if ($res_supplier->[0] eq '')	{
    &backup_files($backup_path, $supplier_path, $base);
  }
}
closedir(SUPPLIER);

# Processing directory www/objects/
print "Processing files in $objects_path:\n\n";
opendir(OBJECTS, $objects_path) or die "Can't open $objects_path: $!";
while (defined(my $base = readdir OBJECTS)) {
	next if &doNext($base);
  my $path = basename($objects_path.'/'.$base);
  my ($file, $dir, $ext) = fileparse($path, '\..*');
  #print "$base\n";
  my $qstr = $file.$ext;
  my ($query_product_multimedia_object, $res_product_multimedia_object);
  $query_product_multimedia_object = "SELECT link FROM product_multimedia_object WHERE link LIKE '%".$qstr."%' limit 1";
  $res_product_multimedia_object = &do_query($query_product_multimedia_object);
  if ($res_product_multimedia_object->[0] eq '') {
    &backup_files($backup_path, $objects_path, $base);
  }
}
closedir(OBJECTS);

# closing BACKUPLOG filehandler
close(BACKUPLOG);

exit(0);

# subs

sub doNext {
	my ($base) = @_;
	return 1 if (($base =~ /^\.\.?$/) || ($base =~ /^CVS/) || ($base =~ /^\.svn/) || ($base =~ /empty/) || ($base =~ /^\.htaccess/));
	return 0;
} # sub doNext

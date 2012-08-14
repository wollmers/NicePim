package thumbnail;

#$Id: thumbnail.pm 3772 2011-02-01 12:47:33Z dima $

use strict;

use atomcfg;
use atomsql;
use atomcfg;
use atomlog;
use icecat_util;
use atom_misc;

use Data::Dumper;
use MIME::Types;
use LWP::Simple;
use LWP::Simple qw($ua); $ua->timeout($atomcfg{'http_request_timeout'});
use GD;

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
  @EXPORT = qw(&thumbnailize_product
							 &thumbnailize_category
							 &normalize_product_pics
							 &thumbnailize_supplier
							 &thumbnailize_family
							 &normalize_suppl_pics
							 &thumbnailize_product_gallery
							 &thumbnailize_campaign_gallery
							 &create_logo
							 &get_ext_by_file_content
							 &getJpeg
							 &getPng
							 &create_thumbnail
							 );
}								

my $supported = {
	'.jpeg' => 1,
	'.jpg'  => 1,
	'.png'  => 1,
	'.bmp'  => 1,
	'.gif'  => 1,
	'.tif'  => 1,
	'.tiff' => 1
	};

my $convert = '/usr/bin/convert -quality 99 -flatten -background \#FFFFFF ';
my $images_cache = $atomcfg{'base_dir'}.'images_cache/';
my $thumbs_path = 'thumbs/';
my $gallery_thumbs_path = 'img/gallery_thumbs/';
my $campaign_path = 'img/campaign/';
my $campaign_thumbs_path = 'img/campaign_thumbs/';

sub thumbnailize_product {
	my ($product) = @_;

	my $row;
	
#	$row->[0] = $product->{'product_id'};
#	$row->[1] = $product->{'low_pic'};
#	$row->[2] = $product->{'high_pic'};

	return undef unless ($product->{'product_id'});
	
	my $thumb_exist = &atomsql::do_query("select thumb_pic, low_pic from product where product_id = $product->{'product_id'}");
	# I can see a bug here - this will work only when there is NO low pic and IS thumb  & high pic
	# but if you fix this, make sure that you add also forced updated - in product update and data imports
	# so thumbs are renewed
	
	if (!$product->{'low_pic'} && $thumb_exist->[0][1] && $product->{'high_pic'} && $thumb_exist->[0][0]) { # thumb already made from low_pic
		return $thumb_exist;
	}

	if ($product->{'no_changes'}) { # high & low images were the same, skipping
		log_printf("DV: Thumbnailizing skipped.");
		return $thumb_exist->[0][0];
	}
	
  GD::Image->trueColor(1);
  my ($img_url, $thumb);
	my $read_mime = 0;

	if ($img_url = $product->{'low_pic'} || $product->{'high_pic'}) {

		my $filename = $img_url;
		
		$filename =~ m/\.(.{3,4})\Z/;	
		my $ext = $1 || 'jpg';
		$filename =~ s/[^A-Za-z0-9]/_/g;
		if ($ext&&$supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else { 
	    $read_mime = 1; 
		}

		&log_printf("$img_url => $filename ...");
		
		mirror($img_url, $images_cache.$filename);
		
		my $f = 0;
		if (-e $images_cache.$filename) {
			if ($read_mime || 1) {
				system("mv", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", "-quality", "99", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename = $filename.'.jpg';
			}
		
			$thumb = &create_thumbnail($images_cache.$filename, $thumbs_path, $product->{'product_id'}, 75);
			
			if ($thumb->{'link'}) {
				&log_printf("returned thumb link = ".$thumb->{'link'});
				&atomsql::update_rows('product', " product_id = $product->{'product_id'} ", { 'thumb_pic' => &atomsql::str_sqlize($thumb->{'link'}) } );
				
				# update thumbnail size 
				my $hash_tmp = {
					'link' => $thumb->{'link'},
					'dest' => 'thumbs/',
					'dbtable' => 'product', 
					'dbfield' => 'thumb_pic',
					'id' => 'product_id',
					'id_value' => $product->{'product_id'},
				};
				&atom_misc::get_obj_size($hash_tmp, 'thumb_pic_size');
				
				return $thumb->{'link'};
			}
			else {
				&log_printf("bad image failed");
				return undef;
			}
		}
		else {
			&log_printf("mirror failed");
			return undef;
		}
	}
}

sub thumbnailize_category {
	my ($product) = @_;
	
  GD::Image->trueColor(1);
	
	my $row;
	
	$row->[0] = 'CAT'.$product->{'catid'};
	$row->[1] = $product->{'low_pic'};
	
  my ($img_url, $thumb);
	my $read_mime = 0;
	if ($img_url = $row->[1]) {

		my $filename = $img_url;
		
		$filename =~ m/\.(.{3,4})\Z/;	
		my $ext = $1 || 'jpg';
		$filename =~ s/[^A-Za-z0-9]/_/g;
		if ($ext&&$supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else { 
	    $read_mime = 1; 
		}
	
	    
		&log_printf("$img_url => $filename ...");		
		if($img_url=~/^http/){
			mirror($img_url, $images_cache.$filename);
		}else{
			`cp $img_url $images_cache$filename`;
		}
		my $f = 0;
		if (-e $images_cache.$filename) {
			if ($read_mime || 1) {
				system("mv", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", "-quality", "99", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename = $filename.'.jpg';
			}

			$thumb = &create_thumbnail($images_cache.$filename, $thumbs_path, $row->[0], 75);
			
			if ($thumb->{'link'}) {
				$row->[0] =~ s/CAT//;
				&update_rows('category', " catid = $row->[0] ", { 'thumb_pic' => &atomsql::str_sqlize($thumb->{'link'}) } );
				return $thumb->{'link'};
			}
			else {
				&log_printf("failed");
				print "create thumbnail failed\n";
				return undef;
			}
		}
		else {
			&log_printf("cache image not exists\n");
			return undef;
		}
	}
} # sub thumbnailize_category

sub thumbnailize_supplier {
	my ($supplier) = @_;
	
  GD::Image->trueColor(1);
	
	my $row;
	
	$row->[0] = 'SUP'.$supplier->{'supplier_id'};
	$row->[1] = $supplier->{'low_pic'};
	
  my ($img_url, $thumb);
	my $read_mime = 0;
	
	if ($img_url = $row->[1]) {

		my $filename = $img_url;
		
		$filename =~ m/\.(.{3,4})\Z/;	
		my $ext = $1 || 'jpg';
		$filename =~ s/[^A-Za-z0-9]/_/g;
		if ($ext&&$supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else { 
	    $read_mime = 1; 
		}
	
		&log_printf("$img_url => $filename ...");

		if ($img_url =~ /^(f|ht)tps?:\/\//) {
			mirror($img_url, $images_cache.$filename);
		}
		else {
			`/bin/cp -f $img_url $images_cache$filename`;
		}

		my $f = 0;
		if (-e $images_cache.$filename) {
			if ($read_mime || 1) {
				system("mv", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", "-quality", "99", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename = $filename.'.jpg';
			}
			
			$thumb = &create_thumbnail($images_cache.$filename, $thumbs_path, $row->[0], 75);
			
			if ($thumb->{'link'}) {
				$row->[0] =~ s/SUP//;
				&update_rows('supplier', "supplier_id = $row->[0] ", { 'thumb_pic' => &atomsql::str_sqlize($thumb->{'link'}) } );
				return $thumb>{'link'};
			}
			else {
				&log_printf("failed");
				return undef;
			}
		}
		else {
			return undef;
		}
	}
} # sub thumbnailize_supplier

sub create_thumbnail {
	my ($src_name, $dst_name, $unique_id, $max_size, $is_params) = @_;

	my $cmd;

	&log_printf("loading $src_name");
	
	my $src = GD::Image->new($src_name);
	
	if (!$src) {
		# ok, let's try again
		&log_printf('load failed, trying to convert');
		`$convert $src_name jpeg:$src_name`;

		$src = GD::Image->new($src_name);
	}
	
	if (!$src) {
		&log_printf("Can't create object from $src_name: $!");
		return undef;
	}
	
	&log_printf('loaded ok, doing output to '.$dst_name);
	
	my $square = ($dst_name =~ /thumbs/)?1:0;

	my $thumb = &create_thumbnail_object($src, $max_size, $square);
	
	open (OUT, '>/tmp/'.$unique_id.'.jpg') or &log_printf('cannot open /tmp/'.$unique_id.'.jpg'." for output: $!\n");
	binmode (OUT,":bytes");
	print OUT $thumb->jpeg(99);
	close(OUT);

	my $params = $is_params?&atom_misc::get_gallery_pic_params('/tmp/'.$unique_id.'.jpg'):undef;

	return { 'link' =>  &add_image('/tmp/'.$unique_id.'.jpg',$dst_name,$atomcfg::targets), 'params' => $params };
} # sub create_thumbnail

sub create_thumbnail_object { 
	my ($orig,$n,$square) = @_;
	
	my ($ox,$oy) = $orig->getBounds();
	
	my $r = $ox>$oy ? $ox / $n : $oy / $n;
	if($r < 1){ $r = 1 }
	
	my $thumb = new GD::Image($ox/$r,$oy/$r,1);
	
	$thumb->copyResampled($orig,0,0,0,0,$ox/$r,$oy/$r,$ox,$oy);
	
	#make thumb square	
	if ($square) {
		my ($sx,$sy) = $thumb->getBounds();
		my ($dx, $dy);
		if (($sx>$sy)||($sx==$sy))
		{
			$dx=$sx;
			$dy=$sx;
		}
		if ($sx<$sy) {
			$dx=$sy;
			$dy=$sy;
		}
		my $dest = GD::Image->new($dx,$dy);
		my $white = $dest->colorAllocate(255,255,255);
		$dest->filledRectangle(0,0,$dx,$dy,$white);
		$dest->copy ($thumb, 0, $dy/2-$sy/2, 0, 0, $sx, $sy);
		return $dest;
	}
	else {
		return $thumb;
	}
}

sub normalize_product_pics {
	my ($hash, $suffix) = @_;
	
	my $row;
	if ($hash->{'product_id'}) {
		$row->[0] = $hash->{'product_id'};
  }
	elsif ($hash->{'supplier_id'}) {
		$row->[0] = $hash->{'supplier_id'};
  }

	$row->[1] = $hash->{'low_pic'};
	$row->[2] = $hash->{'high_pic'};
	
	my ($src, $dst, $src_exist, $ext);
	my ($high_pic, $low_pic) = ($row->[2], $row->[1]);

	# check the sameless
	my $old_value = &atomsql::do_query("select high_pic, low_pic from product where product_id=".$hash->{'product_id'})->[0];

	if (
		($hash->{'low_pic'} eq $old_value->[1]) &&
		($hash->{'high_pic'} eq $old_value->[0])
		) {
		log_printf("DV: Low & high pics are the same. Skipping.");
		$hash->{'no_changes'} = 1;
		return $hash;
	}

	my $rand_index = $suffix ? $suffix : int(rand(10000));
	
	my $src_mirrored;
	if ($src_mirrored = &mirror_image($row->[2])) {
		&log_printf("high pic is ok");
		$src = $src_mirrored;
	}
	elsif ($src_mirrored = &mirror_image($row->[1])) {
		&log_printf("low pic is ok");
		$src = $src_mirrored;
	}
	else {
		$src = ""; # no pics are available! Sorry, I give up.
		&log_printf("we haven't high & low pics");
		delete $hash->{'low_pic'};
		delete $hash->{'high_pic'};
		return $hash;
	}

	$src = &mirror_image($src);

	if ($src =~ /\.jpg$/i) {
		&PNG($src);
	}
	else {
		my $res = getJpeg($src);
		$src = $res->[0].$res->[1];
	}

	$src =~ /\.(.{3,4})$/;	
	$ext = lc($1) || 'jpg';
	
	$high_pic = &add_image($src, 'img/norm/high/', $atomcfg::targets, $row->[0].'-'.$rand_index.'.'.$ext);
	
	if (-e $src) {
		GD::Image->trueColor(1);
		my $high_file = GD::Image->new($src);
		$low_pic = &create_thumbnail($src, 'img/norm/low/', $row->[0].'-'.$rand_index, 200, 'Y');
		if ($low_pic->{'link'}) {
			
			if ($high_file) {
				my ($low_x, $low_y) = ($low_pic->{'params'}->{'width'}, $low_pic->{'params'}->{'height'});
				my ($high_x, $high_y) = $high_file->getBounds();
				if ($low_x <= $high_x) {
					&atomsql::update_rows("product", "product_id = $row->[0]", { "low_pic" => &atomsql::str_sqlize($low_pic->{'link'}), "high_pic" => &atomsql::str_sqlize($high_pic) });
				}
				else {
					&atomsql::update_rows("product", "product_id = $row->[0]", { "low_pic" => &atomsql::str_sqlize($low_pic->{'link'}) });
				}
			}
			else {
				&atomsql::update_rows("product", "product_id = $row->[0]", { "low_pic" => &atomsql::str_sqlize($low_pic->{'link'}) });
			}

			# sizes, widths and heights
			my $shash;
			
			# for high pic
			$shash = { 'dbtable' => 'product', 'dbfield' => 'high_pic', 'id' => 'product_id', 'id_value' => $hash->{'product_id'} };
			&atom_misc::get_obj_size($shash, 'high_pic_size');
			&atom_misc::get_obj_width_and_height($shash, 'high_pic_width', 'high_pic_height');
			
			# for low pic
			$shash = { 'dbtable' => 'product', 'dbfield' => 'low_pic', 'id' => 'product_id', 'id_value' => $hash->{'product_id'} };
			&atom_misc::get_obj_size($shash, 'low_pic_size');
			&atom_misc::get_obj_width_and_height($shash, 'low_pic_width', 'low_pic_height');

			# returned hash
			my $phash;
			$phash->{'product_id'} = $hash->{'product_id'};
			$phash->{'low_pic'} = $low_pic->{'link'};
			$phash->{'high_pic'} = $high_pic;
			return $phash;
		}
	}
} # sub normalize_product_pics

sub mirror_image {
	my ($src) = @_;

	my ($cmd, $filename, $ext, @head);

	$filename = $src;
	$filename =~ s/[^A-Za-z0-9]/_/g;	 
	
	if ($src =~ /\/$/) {
		$ext = '';
	}
	else {
		$src =~ /\.(.{3,4})$/;	
		$ext = '.'.lc($1);
	}
	
	&log_printf("Starting: ".$src.' => '.$images_cache.$filename.$ext);

#	$src =~ s/http:\/\///;

	if ($src =~ /^https?\:\/\//) {
		$ua->agent('Mozilla/5.0');
		my $rc = $ua->head($src);
		if ($rc->is_success) {
			log_printf("mirror");
			mirror($src, $images_cache.$filename.$ext);
		}
		else {
			log_printf("LWP head request failed, reason: ".$rc->status_line);
			return undef;
		}
	}
	else {
		# trying to determine the ext once again
		$ext = get_ext_by_file_content($src);
#		$ext =~ s/^\.//s;

		log_printf("get_ext_by_file_content!!!!!!!!!!!");

		$cmd = "/bin/cp -f ".$src." ".$images_cache.$filename.$ext;
#		log_printf(`ls -la $src`);
		log_printf("DV: ".$cmd);
		`$cmd`;
	}

	if (!$supported->{lc($ext)}) {
		&log_printf("not supported, extension: ".$ext);
		if ($ext) {
			$cmd = $convert." ".$images_cache.$filename.$ext." jpeg:".$images_cache.$filename.".jpg";
			`$cmd`;
			&log_printf($cmd);
			$ext = '.jpg';
			unless (-e $images_cache.$filename.$ext) {
				if (-e $images_cache.$filename.$ext.".0") {
					$cmd = "/bin/mv -f ".$images_cache.$filename.$ext.".0 ".$images_cache.$filename.$ext;
					`$cmd`;
					&log_printf($cmd);
				}
			}
		}
	}

	if (-e $images_cache.$filename.$ext) {
		return $images_cache.$filename.$ext;
	}
	else {
		&log_printf("mirror is failed");
	  return undef;
	}
}

sub normalize_suppl_pics {
	my ($hash) = @_;
	
	GD::Image->trueColor(1);
	
	my $row;
	$row->[0] = $hash->{'supplier_id'};
	$row->[1] = $hash->{'low_pic'};
	
	my ($src, $dst, $src_exist, $ext);
	my $low_pic = $row->[1];
	
	my $src_mirrored;
	if ($src_mirrored = &mirror_image($row->[1])) {
		&PNG($src_mirrored);
		&log_printf("the low is ok $src_mirrored");			 
		$src = $src_mirrored;
	}
	else {
		$src = ""; # no pic is available.
		&log_printf("the low is not ok");			 
		delete $hash->{'low_pic'};
		return $hash;
	}
	
	$src =~ m/\.(.{3,4})$/;	
	$ext = $1 || 'jpg';
	
	my $low_pic;
	if (-e $src) {
		$low_pic = &create_thumbnail($src, 'img/norm/low/', $row->[0], 200);
		if ($low_pic->{'link'}) {
			
			&update_rows("supplier", "supplier_id = $row->[0]",
									 {
										 "low_pic" => &atomsql::str_sqlize($low_pic->{'link'}),
									 });
			return
			{
				"low_pic" => $low_pic->{'link'},
				"supplier_id" => $hash->{'supplier_id'}	
			}
		}
	}
	else {
	  &log_printf(" src is not available ");
	}
} # sub normalize_suppl_pics

sub thumbnailize_family {
	my ($family) = @_;
	
	&log_printf("\n in thumbnailize_family: $family->{'family_id'}, $family->{'low_pic'}");
	
  GD::Image->trueColor(1);
	
	my $row;
	
	$row->[0] = 'FAM'.$family->{'family_id'};
  $row->[1] = $family->{'low_pic'};
	
	my ($img_url, $thumb);
	my $read_mime = 0;
	if ($img_url = $row->[1]) {
		
		my $filename = $img_url;
		
		$filename =~ m/\.(.{3,4})\Z/;
		my $ext = $1;
		$filename =~ s/[^A-Za-z0-9]/_/g;
		if ($ext&&$supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else {
			$read_mime = 1;
		}
		
 		&log_printf("$img_url => $filename ...");
	  mirror($img_url, $images_cache.$filename);
		my $f = 0;
		if (-e $images_cache.$filename) {
		  if ($read_mime || 1) {
				system("mv", "-f", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename = $filename.'.jpg';
			}

			$thumb = &create_thumbnail($images_cache.$filename, $thumbs_path, $row->[0], 75);
			
			if ($thumb->{'link'}) {
				$row->[0] =~ s/FAM//;
				&update_rows('product_family', "family_id = $row->[0] ", { 'thumb_pic' => &atomsql::str_sqlize($thumb->{'link'}) } );
				return $thumb->{'link'};
			}
			else {
				&log_printf("failed");
				return undef;
			}
		}
		else {
			return undef;
		}
	}
} # sub thumbnailize_family

sub thumbnailize_product_gallery {
	my ($product) = @_;
	
	GD::Image->trueColor(1);

	my $row;
	$row->[0] = $product->{'product_id'};
	$row->[1] = $product->{'gallery_pic'};
	$row->[2] = $product->{'gallery_id'};
	
	my ($img_url, $thumb);
	my $read_mime = 0;

	if ($img_url = $row->[1]) {
		
		my $filename = $img_url;
		
		$filename =~ m/\.(.{3,4})\Z/;
		my $ext = $1;
		$filename =~ s/[^A-Za-z0-9]/_/g;
		if ($ext && $supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else { 
	    $read_mime = 1; 
		}
	
		&log_printf("$img_url => $images_cache$filename ...");
		log_printf("mirror returned = ".mirror($img_url, $images_cache.$filename));
		my $f = 0;

		if (-e $images_cache.$filename) {
			if ($read_mime || 1) {
				system("mv", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", "-quality", "99", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename .= '.jpg';
				log_printf('convert done');
			}
			
			my $rand_index = int(rand(10000)); 
			while (-e $gallery_thumbs_path.$row->[0].'_'.$rand_index.'.'.$ext) {
				$rand_index = int(rand(10000));
			}
			
			$thumb = &create_thumbnail($images_cache.$filename, $gallery_thumbs_path, $row->[0].'_'.$rand_index, 75);
			
			if ($thumb->{'link'}) {
				unless ($product->{'dont_touch_base'}) {
					&atomsql::update_rows('product_gallery', "id = $row->[2] ", { 'thumb_link' => &atomsql::str_sqlize($thumb->{'link'}) } );
					
					# add info about thumb size as well 					    
					my $hash_tmp = {
						'link' => $thumb->{'link'},
						'dest' => 'img/gallery/gallery_thumbs/',
						'dbtable' => 'product_gallery', 
						'dbfield' => 'thumb_link',
						'id' => 'id',
						'id_value' => $row->[2],
					};
					&atom_misc::get_obj_size($hash_tmp, 'thumb_size');    
				}
				return $thumb->{'link'};
			}
			else {
				&log_printf("failed");
				return undef;
			}
		}
		else {
			&log_printf("image cache image file failed");
			return undef;
		}
	}
} # sub thumbnailize_product_gallery

sub thumbnailize_campaign_gallery {
	my ($p) = @_;
	
	GD::Image->trueColor(1);

	my ($img_url, $thumb, $logo);

	my $read_mime = 0;

	if ($img_url = $p->{'logo_pic'}) {
		
		my $filename = $img_url;
		
		$filename =~ /\.(.{3,4})$/;
		my $ext = $1;
		$filename =~ s/[^A-Za-z0-9]/_/sg;
		if ($ext && $supported->{$ext}) {
			$filename .= '.'.$ext;
		}
		else { 
	    $read_mime = 1;
		}
	
		&log_printf("Campaign gallery thumbnail: $img_url => $filename ...");
		
		mirror($img_url, $images_cache.$filename);

		my $f = 0;

		if (-e $images_cache.$filename) {
			if ($read_mime) {
				system("mv", $images_cache.$filename, $images_cache.$filename.'.gif');
#				$f = system("convert", "-quality", "99", $images_cache.$filename.'.gif', "jpeg:".$images_cache.$filename.'.jpg');
				`$convert $images_cache$filename.gif jpeg:$images_cache$filename.jpg`;
				$filename = $filename.'.jpg';
			}
			
			srand;
			my $rand_index = int(rand(10000)); 
			
			$thumb = &create_thumbnail($images_cache.$filename, $campaign_thumbs_path, $p->{'campaign_gallery_id'}.'-'.$rand_index, 75, "Y");
			$logo = &create_thumbnail($images_cache.$filename, $campaign_path, $p->{'campaign_gallery_id'}.'-'.$rand_index, 200);
			
			if ($thumb->{'link'}) {
				&atomsql::update_rows('campaign_gallery', "campaign_gallery_id = ".$p->{'campaign_gallery_id'}, { 'thumb_pic' => &atomsql::str_sqlize($thumb->{'link'}), 'logo_pic' => &atomsql::str_sqlize($logo->{'link'}) } );
				return $thumb->{'link'};
			}
			else {
				&log_printf("failed");
				return undef;
			}
		}
		else {
			return undef;
		}
	}
} # sub thumbnailize_campaign

sub PNG {
	my ($src) = @_;

	log_printf("PNG started");

	return if ((!$src) || ($src =~ /^https?:\/\//) || ($src =~ /\.png$/i));

	&log_printf("??? -> png: ".$src);
	# trying to fix possibly corrupted pic
	my $cmd = $convert.' '.$src.' png:'.$src.'.png';
	log_printf($cmd);
	`$cmd`;

	&log_printf("png -> ???: ".$src);
	$cmd = $convert.' '.$src.'.png jpeg:'.$src;
	log_printf($cmd);
	`$cmd`;

	$cmd = '/bin/rm -f '.$src.'.png';
	log_printf($cmd);
	`$cmd`;
} # sub PNG

sub create_logo {
	my ($pic_path, $logo_path) = @_;
	
	if ($pic_path =~ /^https?:\/\//) {
		$pic_path =~ s/^https?:\/\/.*?/$atomcfg{'base_dir'}www/;
	}
	
  GD::Image->trueColor(1);
	my $pic_file = GD::Image->new($pic_path);

#	# Add `I` to the right bottom corner of the image (disabled)
#	my ($pic_x, $pic_y )= $pic_file->getBounds();	
#	my $icecat_color = $pic_file->colorAllocateAlpha(75,130,200,100);
#	$pic_file->string(gdSmallFont,$pic_x-20,$pic_y-20,"I",$icecat_color);
	
	open (OUT, ">".$pic_path);
	binmode OUT;
	print OUT $pic_file->jpeg(99);
	close(OUT);				
}
																																						 
sub get_ext_by_file_content {
	my ($path) = @_;

	my $mimetypes = MIME::Types->new;

	# several often used
  my $mime2ext = {
    'application/pdf' => '.pdf',
    'image/jpeg' => '.jpg',
    'image/pjpeg' => '.jpg',
    'image/png' => '.png',
    'image/gif' => '.gif',
    'image/tiff' => '.tiff',
    'image/x-ms-bmp' => '.bmp',
    'text/html' => '.html',
		'application/zip' => '.zip',
		'image/vnd.adobe.photoshop' => '.psd',
		'text/plain' => '.txt'
  };
#	$mime2ext = {}; # temporary

	my $fileext = '';

	my $freq = "/usr/bin/file --mime-type -b ".$path;
	log_printf($freq);
	my $file_result = `$freq`;
  chomp($file_result);
  log_printf('FR = '.$file_result);

	$mimetypes->type($file_result);
	my @exts = $mimetypes->extensions;
	$fileext = $mime2ext->{$file_result} || $exts[0] || '';

	log_printf("FILEEXT: ".$fileext);

  if ($fileext eq '') {
		use atom_mail;

    log_printf("WARNING! Unknown mime-type: ".$file_result);
    &sendmail("Unknown mime-type: ".$file_result, $atomcfg{'bugreport_email'}, $atomcfg{'bugreport_from'}, 'unknown mimetype '.$file_result);
  }

	return $fileext;
}

sub getJpeg {
	my ($path) = @_;

	return undef unless $path;

	if ($path =~ /^(.+)(\.\w+?)$/) {
		my ($name, $fileext) = ($1, $2);
		
		if (($fileext eq ".tiff") || ($fileext eq ".tif") || ($fileext eq ".gif") || ($fileext eq ".png") || ($fileext eq ".bmp")) {
			my $cmd = $convert.''.$name.$fileext.' jpeg:'.$name.'.jpg';
			`$cmd`;
			
			&log_printf("$cmd");
			$fileext = '.jpg';
			
			unless (-e $name.'.jpg') { # multigif to jpgs
				if (-e $name.'.jpg.0') {
					$cmd = '/bin/mv -f '.$name.'.jpg.0 '.$name.'.jpg';
					&log_printf("multigif to jpgs: ".$cmd);
					`$cmd`;
				}
			}
		}

		return [ $name, $fileext ];
	}
	else {
		return [ $path, '' ];
	}
} # sub getJpeg

sub getPng {
	my ($path) = @_;

	return undef unless $path;

	if ($path =~ /^(.+)(\.\w+?)$/) {
		my ($name, $fileext) = ($1, $2);
		
		if (($fileext eq ".tiff") || ($fileext eq ".tif") || ($fileext eq ".gif") || ($fileext eq ".jpg") || ($fileext eq ".jpeg") || ($fileext eq ".bmp")) {
			my $cmd = $convert.''.$name.$fileext.' png:'.$name.'.png';
			$cmd =~ s/-background\s+\\\#\w{6}//; # remove bg parameter
			`$cmd`;
			
			&log_printf("$cmd");
			$fileext = '.png';
		}

		return [ $name, $fileext ];
	}
	else {
		return [ $path, '' ];
	}
} # sub getPng

1;

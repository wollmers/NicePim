package publisher;

use lib '/home/pim/lib';
use atomcfg;
use atomlog;
use atomsql;
use atom_html;
use atom_util;
use atom_misc;

use Exporter ();

@ISA = qw(Exporter);
@EXPORT = qw(&generate_site_refferal
             &icemailer_export);

BEGIN{
  $products_per_page = 1000;
  $html_path         = '/home/icecat_index/www';
  
  $db_table = 'product';
  $db_name =  'icemailer';
  $db_host =  'www.icemailer.nl';
  $db_user =  'icecat';
  $db_pass =  '435kay';
  $db_str  =  "DBI:mysql:$db_name:$db_host";
}

sub icemailer_export
{
 use DBI;
 my $prod_list=do_query('select product_id,prod_id,supplier_id from product');
 my $dbh= DBI->connect($db_str,$db_user,$db_pass);
 $dbh->do("set names utf8");
 my $lang=2;
 for my $prod(@$prod_list){
   my $product;
   my %prod_hash = get_product($prod->[0]);
     $product->{'ProdId'}  = str_sqlize($prod_hash{'prod_id'});
      $product->{'Name'}    = str_sqlize($prod_hash{'name'});
      $prod_hash{'short_desc'.$lang} = do_query('select short_desc from product_description 
                                            where langid=1 and product_id='.$prod->[0])->[0][0] if !$prod_hash{'short_desc'.$lang};
      $prod_hash{'long_desc'.$lang}  = do_query('select long_desc from product_description 
                                            where langid=1 and product_id='.$prod->[0])->[0][0] if !$prod_hash{'long_desc'.$lang};
      $product->{'ShortDescription'}  = str_sqlize($prod_hash{'short_desc'.$lang});
      $product->{'LongDescription'}   = str_sqlize($prod_hash{'long_desc'.$lang});
      $product->{'SmallImageURL'}     = str_sqlize($prod_hash{'thumb_pic'});
      $product->{'MediumImageURL'}    = str_sqlize($prod_hash{'low_pic'});
      $product->{'LargeImageURL'}     = str_sqlize($prod_hash{'high_pic'});
      $product->{'PrintImageURL'}     = str_sqlize($prod_hash{'high_pic'});
      $product->{'ICEcatURL'}         = str_sqlize('http://prf.icecat.biz/index.cgi?shopname=icemailer;smi=product;product_id='.$prod->[0]);
   %prod_hash = get_product_addin_info($prod->[0],$prod->[2]);
      $product->{'Vendor'}   = str_sqlize($prod_hash{'Vendor'});
      $product->{'CatId'}    = str_sqlize($prod_hash{'CatId'});
      $product->{'Category'} = str_sqlize($prod_hash{'Category'});
   my $specs  = get_product_specs($prod->[0]);
      $product->{'Specs'}    = str_sqlize($specs);
   my ($select) = @_;
   my ($sth,@nw,@row,$rv);
   $sth = $dbh->prepare("select count(*) from $db_table where ProdId='$prod->[1]' and Vendor=$product->{'Vendor'}");
   $rv = $sth->execute;
   while (@row = $sth->fetchrow_array){
		 Encode::_utf8_on(@row[0]);
		 push(@nw,[@row]);
	 }
   $rv=$sth->finish;
   if($nw[0][0]==0){
      my $stmt = "INSERT INTO $db_table (";
      my $vals = "(";
      my $isgood = 0;
      for my $i (keys %$product) {
        if($isgood){ $stmt .= ","; $vals .= ","; }
	  $stmt .= $i;
	  $vals .= "$product->{$i}";
	  $isgood = 1;
      }
      $stmt .= ") VALUES ".$vals.")";
      $rv = $dbh->do($stmt);
   }else{
      my $stmt   = "UPDATE $db_table SET";
      my $where  = " WHERE ProdId='$prod->[1]' and Vendor=$product->{'Vendor'}";
      my $isgood = 0;	
      for my $i(keys %$product) {
 	 if ($isgood) { $stmt .= ","; }
	 $stmt .= " ".$i." = ".$product->{$i};
	 $isgood = 1;
      }
      $stmt.=$where;
      $rv = $dbh->do($stmt);
  }
 }
 $dbh->disconnect;
 return undef;
}

sub get_product_specs
{
 my $specs='';
 my $feat_val = do_query("select v.value, pf.value, ms.value

from product_feature pf
inner join category_feature cf on pf.category_feature_id=cf.category_feature_id
inner join feature f on f.feature_id=cf.feature_id
inner join vocabulary v on v.sid=f.sid and v.langid=2
left  join measure_sign ms on f.measure_id=ms.measure_id and ms.langid=1

where pf.product_id=$_[0] and pf.value<>''");

 for(@$feat_val){
   $specs.="$_->[0] : $_->[1] $_->[2]";
   $specs.="\n";
 }
 return $specs;
}

sub get_product_addin_info
{
  my %hash;
  my $cat = do_query('select category.ucatid,category.sid 
                       from product, category 
		       where product.catid=category.catid 
		       and product_id='.$_[0]);
  my $cat_name =do_query('select value from vocabulary 
                       where langid=2 and sid='.$cat->[0][1]);
  my $vendor = do_query('select name from supplier where 
                       supplier_id='.$_[1]);
  $hash{'CatId'}    = $cat->[0][0];
  $hash{'Category'} = $cat_name->[0][0];
  $hash{'Vendor'}   = $vendor->[0][0];
  return %hash;
}

sub products_list
{
  my $prod_list=do_query('select product_id from product');
  my $result;
  my $current;
  for (@$prod_list){
   my %hash;
   $current = do_query('select name from product where product_id='.$_->[0]);
   $hash{'prod_id'}=$current->[0][0];
   $hash{'product_id'}=$_->[0];
   push @$result,\%hash;
  }
  return $result;
}

sub get_product
{
  my %res;
   
  my $product=do_query('select supplier_id, prod_id, catid, name,
                              low_pic, high_pic, thumb_pic, dname 
                         from product where product_id='.$_[0]);

  
  $res{'product_id'} = $_[0];
  $res{'supplier_id'}= $product->[0][0];
  $res{'prod_id'}    = $product->[0][1];
  $res{'catid'}      = $product->[0][2];
  $res{'name'}       = $product->[0][3];
  $res{'low_pic'}    = $product->[0][4];
  $res{'high_pic'}   = $product->[0][5];
  $res{'thumb_pic'}  = $product->[0][6];
  $res{'dname'}      = $product->[0][7];


  for my $langid((1,2,3)){
    my $description=do_query('select short_desc, long_desc,
                              specs_url, support_url, official_url, warranty_info 
                              from product_description where product_id='.$_[0].' and langid='.$langid);
  
    $res{'short_desc'.$langid}    = $description->[0][0];
    $res{'long_desc'.$langid}     = $description->[0][1];
    $res{'specs_url'.$langid}     = $description->[0][2];
    $res{'support_url'.$langid}   = $description->[0][3];
    $res{'official_url'.$langid}  = $description->[0][4];
    $res{'warranty_info'.$langid} = $description->[0][5];
  }
  
  for my $langid((1,2,3)){
    my $cat = do_query('select category.ucatid, vocabulary.value 
                       from category,vocabulary where 
                       category.sid=vocabulary.sid and
                       category.catid='.$res{'catid'}.' and vocabulary.langid='.$langid); 
    $res{'uncatid'.$langid}  = $cat->[0][0];
    $res{'cat_name'.$langid} = $cat->[0][1];
  }
  my $langid=2;
  my $sup = do_query('select name from supplier where supplier_id='.$res{'supplier_id'});
  $res{'supp_name'}= $sup->[0][0];

 return %res;
}

sub generate_product_page
{
 my %prod = get_product($_[0]);
 my $lang;
    $lang->{'1'} = 'en';
    $lang->{'2'} = 'nl';
    $lang->{'3'} = 'fr';
 my $tmpl = $_[1];
 
 my $path=encode($prod{'supp_name'});
    $path.='_';
    $path.=encode($prod{'prod_id'});
 
 for (keys %$lang){
   my $keys = $prod{'supp_name'}.' '.$prod{'prod_id'}.' '.$prod{'short_desc'.$_}.' '.$prod{'name'};
     $keys=~s/"//gsm;
   my $desc=$prod{'supp_name'}.' '.$prod{'prod_id'}.' '.$prod{'short_desc'.$_}.' '.$prod{'long_desc'.$_}.' '.$prod{'name'};
     $desc=~s/"//gsm;
   my $page = repl_ph($tmpl->{'product_header'},
                      {'meta-keywords'   =>$keys,
                       'meta-description'=>$desc
                      }); 
   my $img='';
     $img  = repl_ph($tmpl->{'product_image'},{'image' => $prod{'low_pic'}})  if $prod{'low_pic'};
   my $body = repl_ph($tmpl->{'product_body'},
                      {'img'=> $img,
                       'prod_id'   =>$prod{'prod_id'},
											 'link_prod_id'=>escape($prod{'prod_id'}),
                       'product_id'=>$prod{'product_id'},
                       'name'      =>$prod{'name'},
                       'supp_name' =>$prod{'supp_name'},
                       'cat_name'  =>$prod{'cat_name'.$_},
                       'warranty'  =>$prod{'warranty_info'.$_},
                       'short_desc'=>$prod{'short_desc'.$_},
                       'long_desc' =>$prod{'long_desc'.$_}
                     });
  
   $page=$page.$body.$tmpl->{'footer'};
   open(PROD, ">$html_path/$lang->{$_}/$path.html");
	 binmode(PROD,":utf8");
   print PROD $page;
   close(PROD); 
 }
 return $path;
}


sub generate_site_refferal
{
 my $data = products_list();
 `cd $html_path; mkdir nl; mkdir en; mkdir fr;`;
 my $html='';
 my $tmpl=load_complex_template('site_refferal.tmpl');
 my $header='';
 my $i    = 0;
 my $page = 0;
 my $row_count=0;
 my $page_no;
 my $footer=$tmpl->{'footer'};
 for my $product(@$data){
  if($i/$products_per_page==int($i/$products_per_page) && $i>0){
    $page_no=$page || '';
    open(HTML,">$html_path/index$page_no.html");
		binmode(HTML,":utf8");
    print HTML $html;
    close(HTML);
    $header.=repl_ph($tmpl->{'header_link'},{'page'=>$page, 'page_no'=>$page_no});
    $page++;
    $html='';
  }
  $product->{'prod_id'}=substr($product->{'prod_id'},0,48);
  $product->{'path'}=generate_product_page($product->{'product_id'},$tmpl);
  if($row_count!=3){
    $html.='<td width=245>'.(repl_ph($tmpl->{'link'},$product)).'</td>';
  }else{
    $html.='</tr><tr><td></td><td width=245>'.(repl_ph($tmpl->{'link'},$product)).'</td>';    
    $row_count=0;
  }
  $row_count++;
  $i++;
 }
 $page_no=$page || '';
 open(HTML,">$html_path/index$page_no.html");
 binmode(HTML,":utf8");
 print HTML $html;
 close(HTML);
 $header=repl_ph($tmpl->{'header'},{'navigator'=>$header});
 my @pages = `cd $html_path; ls *.html`;
 my $body;
 for my $file(@pages){
  chop $file;
  open(OHTML,"< $html_path/$file");
	binmode(OHTML,":utf8");
  $body = join('',<OHTML>);
  close OHTML;
  open(HTML,"> $html_path/$file");
	binmode(HTML,":utf8");
  $body = $header.$body.$footer;
  print HTML $body;
  close HTML;
 }
}

sub encode{
 my $toencode = shift;
 return undef unless defined($toencode);
 $toencode=~s/([^a-zA-Z0-9_.\-])/uc sprintf("%%%02x",ord($1))/eg;
 $toencode=~s/%20//g;
 $toencode=~s/ //g;
 $toencode=~s/%//g;
 $toencode=~s/\.//g;
 return $toencode;
}

1;

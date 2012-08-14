package atomcfg;

#$Id: atomcfg.pm 3138 2010-09-24 13:18:49Z vadim $

use strict;
use vars qw( %atomcfg $debug_level $targets $pdf_targets $object_targets $email_about_custom);

BEGIN {
  use Exporter ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  $VERSION = 1.00; @ISA = qw(Exporter); %EXPORT_TAGS = (); @EXPORT_OK = ();
	
  @EXPORT = qw(%atomcfg $debug_level $targets $pdf_targets $object_targets $email_about_custom);
}

$debug_level = 3;

my $test = 0;

my $soap_url = 'http://icetools.iceshop.nl/icetools.wsdl';

# basic server: bo, editors
my $base_path = '/home/pim/';
my $pure_base_hosted = 'localhost';
my $base_hosted = 'http://'.$pure_base_hosted.'/';

# xmls server: ALL export/
my $xmls_path = $base_path;
my $pure_xmls_hosted = $base_hosted;
my $xmls_hosted = 'http://'.$pure_xmls_hosted.'/';

# database server
my $db_path = undef;
my $db_hosted = 'localhost';

# images: 
my $images_path = $base_path;
my $images_hosted = $base_hosted;

# pdfs:
my $pdfs_path = $base_path;
my $pdfs_hosted = $base_hosted;

# objects:
my $objects_path = $base_path;
my $objects_hosted = $base_hosted;


goto skip_test unless $test;

$base_path = '/home/dima/gcc_svn/';
$pure_base_hosted = 'dev.icecat.biz';
$base_hosted = 'http://'.$pure_base_hosted.'/';

$xmls_path = $base_path;
$pure_xmls_hosted = $pure_base_hosted;
$xmls_hosted = $base_hosted;

$db_path = '';
$db_hosted = 'localhost';

$images_path = '/home/dimages/';
$images_hosted = $base_hosted;

$pdfs_path = $base_path;
$pdfs_hosted = $base_hosted;

$objects_path = $base_path;
$objects_hosted = $base_hosted;

skip_test:

  %atomcfg = 
		(
		 soap_url			  => $soap_url,
		 host                 => $xmls_hosted,
		 host_raw             => $pure_xmls_hosted,
		 bo_host              => $base_hosted,
		 mirror_path          => $base_path.'mirror/',
		 download_path        => $base_path.'download/',		 
		 atom_inner_lib_path  => $base_path.'ailib/',
		 atom_lib_path        => $base_path.'alib/',
		 www_path             => $base_path.'www/',
		 xml_path             => $base_path.'xml/',
		 pub_path             => $base_path.'www/pub/',
		 base_dir             => $base_path,
		 templates_path       => $base_path.'templates/',
		 httpd_path4          => '/home/httpd/conf/export4.cnf', 
		 httpd_path           => '/home/httpd/conf/export.cnf',		 



		 backup_host          => 'root@172.16.0.133',
		 backup_path          => '~/icecat_repository/',
		 backup_enable        => 0,
		 xml_repository_diff_backup_mode => 0,
		 xml_repository_diff_backup_path => $base_path.'diff_backup/',

		 user => '<set_your_current_web_linux_username>',

		 db_host => $db_hosted,
		 db_user => '<set_your_current_db_linux_username>',

		 dbname => 'pimdb',
		 dbhost => $db_hosted,
		 dbuser => 'root',
		 dbpass => 'q',

		 dbslaveuser => 'root',
		 dbslavepass => '',

		 prfhost   => '<frontoffice_ip>',
		 datahost  => '<ip_for_storing_xmls>',
		 datahost2 => '<ip_for_storing_xmls2>',

		 xsd_active => 1,

		 icetoolshost => '',

		 images_host     => $images_hosted,
		 pdfs_host       => $pdfs_hosted,
		 objects_host    => $objects_hosted,
		 images_user     => '<set_your_current_web_images_linux_username>',
		 images_www_path => $images_path.'www/',
		 images_path     => $images_path.'www/img/',
		 images_user     => '<set_your_current_web_images_linux_username>',

		 logfile      => $base_path.'logs/log',
		 sql_log_path => $base_path.'logs/',
		 sql_log_file	=> 'sql_logs',

     xml_dir_path    => $base_path.'/www/export/level4/repository/',
     xml_export_path => $base_path.'www/export/',
     xml_file_path   => $base_path.'/www/export/level4/repository/files.index.xml',
		 
		 session_path => $base_path.'tmp/',
		 bugreport_email => '<set_your_bugreport_email>', 
		 bugreport_from => '<set_your_bugreport_from>',
		 bugreport_subj => '<set_your_bugreport_subject>',
     complain_from => '<set_your_complaint_mail_from>',

		 company_name => '<type_your_company_name_here>',

		 http_request_timeout => 10, # after 10 secs http request is aborted if no activity on the connection
		 session_timeout => 72000, # 2 hours can pass, before session will be discarded
		 page_timeout => 900,     # 15 minutes can pass before unused pages will be discarded
		 cart_timeout => 86400,   # 24 hours

		 secure_port		=> 443,
		 port						=> 80,
		 
		 cgi_bufsize => 8192,     # default buffer size when reading multipart
		 cgi_maxbound => 100,     # maximum boundary length to be encounterd
		 cgi_maxdata => 33_554_432,   # maximum data allowed to read
		 default_url_path => '/index.cgi',
		 default_url_dir	=> '/',
		 default_langid => 1,
		 
		 MTA_cmdline => '/usr/sbin/sendmail -t',
		 mail_from => "<set_your_mail_from>",
		 mail_dispatch_from => "<set_your_mail_dispatch_from>",
		 
		 debug_db 	=> 'gccdbd',
		 debug_db_1 => 'gccdbdd'
		 
		);

goto skip_test_2 unless $test;

$atomcfg{'dbname'} = 'gccdb_install';
$atomcfg{'dbhost'} = 'localhost';
$atomcfg{'prfhost'} = '127.0.0.1';
$atomcfg{'datahost'} = '127.0.0.1';
$atomcfg{'datahost2'} = '127.0.0.1';
$atomcfg{'icetoolshost'} = '127.0.0.1';
$atomcfg{'imageuser'} = 'alex';
$atomcfg{'dbuser'} = 'root';
$atomcfg{'dbpass'} = 'qwerty';

skip_test_2:

# store images array (toXML = 1 - use this path for XML)

$targets = [
						{
							'host' => $atomcfg{'images_host'},
							'path' => $atomcfg{'images_www_path'},
							'login' => $atomcfg{'images_user'},
							'toXML' => 1
						},
						{
							'path' => $atomcfg{'www_path'}
						}
						];

$pdf_targets = [
								{
									'path' => $atomcfg{'www_path'},
									'toXML' => 1
									}
								];

$object_targets = [
								{
									'path' => $atomcfg{'www_path'},
									'toXML' => 1
									}
								];

$email_about_custom = {
    'from' => 'info@dev.icecat.biz',
    'to' => 'ilya@icecat.biz',
    'title' => 'Custom value has been used'
};

1;

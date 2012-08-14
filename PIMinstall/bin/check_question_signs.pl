#!/usr/bin/perl

use lib "/home/pim/lib";

use atomcfg;
use atomsql;
use atom_mail;
use Data::Dumper;

&check_question_sign('feature_values_vocabulary','value');

sub check_question_sign{
	my ($table,$field)=@_;
	my $has_sign=&do_query("SELECT count(*) FROM $table WHERE $field like '%???%'")->[0][0];
	if($has_sign){
		print "??? found in $table\n";
		my $mail = {
			'to' => 'alexey@bintime.com, dima@icecat.biz',
			'from' =>  $atomcfg{'mail_from'},
			'subject' => "!!!! Weird question signs have been found on table '$table' in field '$table'",
			'default_encoding'=>'utf8',
			'text_body' => "Weird question signs have been found on table '$table' in field '$table'",
			};
		&simple_sendmail($mail);		
	}else{
		print "NO ??? found in $table\n";
	}
}

1;
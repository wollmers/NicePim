package CSVParser;

#use atomcfg;
use atomlog;
use Data::Dumper;
use utf8;

@ISA=qw(Exporter);
@EXPORT_OK = qw(delimiter newline escape quote is_first_header new encoding);

sub new{
	my $package=shift;
	my %params=@_;
	if(!$params{'delimiter'} or !$params{'file'}){
		log_printf(__PACKAGE__."::new -> delimiter and file are mandatory ");
		return undef;
	}
	# the defaults
	$params{'escape'}=($params{'escape'})?$params{'escape'}:'\\';
	$params{'newline'}=($params{'newline'})?$params{'newline'}:"\n";
	$params{'quote'}=($params{'quote'})?$params{'quote'}:'"';
	$params{'encoding'}=($params{'encoding'})?$params{'encoding'}:'utf8';
	
	my $self={
			  delimiter=>$params{'delimiter'},
			  newline=>$params{'newline'},
			  escape=>$params{'escape'},
			  quote=>$params{'quote'},
			  #is_first_header=>$params{'is_first_header'},
			  file=>$params{'file'},
			  encoding=>$params{'encoding'},
			  };
	bless($self,$package);
	if($self->{file}){
		my $file_h;
		if(!(open $file_h, "<:encoding($self->{encoding})",$self->{file})){
			log_printf(__PACKAGE__."::new -> cant open file $self->{file}");
			return undef;
		}
		$self->{file_h}=$file_h;
	}
	
	return $self->check_params($self);
}

sub DESTROY {
    my $self = shift;
    close($self->{file_h}) if ref($self->{file_h}) eq 'GLOB';
}


sub get_next_row{
	my $self=shift;
	my ($str,$buf);
	my($quote_open,@result);
	my $cnt=0;
	my $read_bytes;	
	do{
		$str.=$buf;
		if($buf eq '<'){
			my $a=1;
		}
		if(substr($str,-1*length($self->{delimiter})) eq $self->{delimiter} and !$quote_open){
			for(my $i=0; $i<length($self->{delimiter});$i++){ chop($str);} #remove delimiter. this way faster than regex
			if(substr($str,-2) ne ($self->{escape}.$self->{quote}) and substr($str,-1) eq $self->{quote}){
				chop($str);
			}
			if(substr($str,0,2) ne ($self->{escape}.$self->{quote}) and substr($str,0,1) eq $self->{quote}){
				$str=substr($str,1,length($str));
			}
			$str=~s/\Q$self->{escape}$self->{quote}\E/$self->{quote}/gi;
			push(@result,$str);
			$quote_open=undef;
			$str=undef;
		}elsif(substr($str,-1*length($self->{newline})) eq $self->{newline} and !$quote_open){
			for(my $i=0; $i<length($self->{newline});$i++){ chop($str);} #this way faster than regex
			#if($self->{newline} eq "\n" and substr($str,-1) eq "\r"){# a case when \r\n is delimiter but user inputs \n. we have to fix this here
				#chop($str);# remove \r
			#}
			if(substr($str,-2) ne ($self->{escape}.$self->{quote}) and substr($str,-1) eq $self->{quote}){
				chop($str);
			}
			if(substr($str,0,2) ne ($self->{escape}.$self->{quote}) and substr($str,0,1) eq $self->{quote}){
				$str=substr($str,1,length($str));
			}
			$str=~s/\Q$self->{escape}$self->{quote}\E/$self->{quote}/gi;# !!! should be replaced with something more faster		
			push(@result,$str);
			return \@result;
		}
		
		if($self->{quote} and substr($str,-2) eq ($self->{escape}.$self->{quote}) and $quote_open ){
			#chop($str);#remove qoute				
			#chop($str);#remove escape
			#$str.=$self->{quote};#add quote
		}elsif($self->{quote} and substr($str,-1) eq $self->{quote} and length($str)==1){
			$quote_open=1;
		}elsif($self->{quote} and substr($str,-1) eq $self->{quote}){
			$quote_open=undef;
		}
		$cnt++;
		if($cnt==30000){
			log_printf(__PACKAGE__." Too big line");
			my $tmp=["ERROR!!!. TOO BIG LINE. PLEASE CHECK line delimiter"];
			return $tmp;	
		}
		NEXT: 
	}while((my $read_bytes=read $self->{file_h}, $buf, 1) != 0);

	# this is end of file
	if($str){
		push(@result,$str);
		return \@result;  
	}else{
		return '';
	} 		
}


sub delimiter{
	my $self=shift;
	if($_[0]){
		$self->{'delimiter'}=$_[0];
		return $self->check_params();
	}else{
		return $self->{'delimiter'};
	}
}

sub newline{
	my $self=shift;	
	
	if($_[0]){
		$self->{'newline'}=$_[0];return $self->check_params();
	}else{
		return $self->{'newline'};
	}
}

sub escape{
	my $self=shift;	
	
	if($_[0]){
		$self->{'escape'}=$_[0];return $self->check_params();
	}else{
		return $self->{'escape'};
	}
}

sub quote{
	my $self=shift;	
	
	if($_[0]){
		$self->{'quote'}=$_[0];return $self->check_params();
	}else{
		return $self->{'quote'};
	}
}

sub file{
	my $self=shift;	
	if($_[0]){
		$self->{'file'}=$_[0];
		close($self->{file_h});
		if(!(open my $file_h, "<:encoding($self->{encoding})",$_[0])){
			log_printf("CSVParser::file: file does not exists");
			return undef
		};
		#binmode $file_h;
		$self->{file_h}=$file_h;
		return $self->check_params();
	}else{
		return $self->{'file'};
	}
}

sub file_h{
	my $self=shift;	
	
	if($_[0]){
		$self->{'file_h'}=$_[0];
		return $self->check_params();
	}else{
		return $self->{'file_h'};
	}
}

sub check_params{
	my $self=shift;
	my $to_check={};
	$to_check->{$self->{delimiter}}=1;
	$to_check->{$self->{newline}}=1;
	$to_check->{$self->{quote}}=1;
	#$to_check->{$self->{escape}}=1;
	if(scalar(keys %$to_check)!=3){
		log_printf(__PACKAGE__.": Some of delimiter,newline,quote,escape are equal each other");
		return undef;
	}elsif(!$self->{quote}){
		log_printf(__PACKAGE__.": Quote is undef");
		return '';
	}elsif(!$self->{delimiter}){
		log_printf(__PACKAGE__.": delimiter is undef");
		return '';
	}elsif(!$self->{newline}){
		log_printf(__PACKAGE__.": newline is undef");
		return '';
	}elsif(!$self->{escape}){
		log_printf(__PACKAGE__.": escape is undef");
		return '';
	}else{
		return $self;
	}
}

sub encoding{
	my $self=shift;	
	
	if($_[0]){
		$self->{'encoding'}=$_[0];return $self->check_params();
	}else{
		return $self->{'encoding'};
	}
}

1;

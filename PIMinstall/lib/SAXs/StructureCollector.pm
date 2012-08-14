package SAXs::StructureCollector;

use Data::Dumper;
use XML::SAX::Base;
use Text::CSV;
use utf8;
@ISA=qw(XML::SAX::Base);
@EXPORT = qw(); 
no warnings;

sub new{
	my $package=shift;
	my %params=@_;
	my $self=$package->SUPER::new(@_);
	return $self;	
}
  
sub start_document {
    my ($self, $doc) = @_;
    $self->{tagStack}=[];
	$self->{repeatTags}={};
	$self->{csvHeader}={};
	$self->{rep_parents}={};
	$self->{csv_paths}={};
	$self->{root_childs}={};
}
  
sub start_element {
    my ($self, $el) = @_;
    $el->{'_ID'}=rand();
    if(scalar(@{$self->{tagStack}}) <= 0){# this is root. process it separately for the sake of simplisity
    	push(@{$self->{tagStack}},$el);
    	my $path_str=$self->get_stack_path($self->{tagStack});
    	$self->{repeatTags}->{$path_str}=rand().' '.rand();# root never will be repeatable
   	    my @attrs=keys(%{$el->{Attributes}});
	    foreach my $attr(@attrs){
	    	$self->{csvHeader}->{$path_str}->{'attrs'}->{$attr}={};
	    }	 
	    $self->{csvHeader}->{$path_str}->{'order'}=scalar(keys(%{$self->{csvHeader}}))+1 if !$self->{csvHeader}->{$path_str}->{'order'};    		    	
    	return;
    }
    my $top_tag=$self->{tagStack}->[scalar(@{$self->{tagStack}})-1];	
    $el->{'_P_ID'}=$top_tag->{'_ID'};
    push(@{$self->{tagStack}},$el);
    my $path_str='';	
    $path_str=$self->get_stack_path($self->{tagStack});    
    if(!exists($self->{repeatTags}->{$path_str})){
    	$self->{repeatTags}->{$path_str}=$el->{'_P_ID'};# This path encounters first. canditate to be repeatable tag
    	$self->{csvHeader}->{$path_str}->{'attrs'}={};    	
    }elsif($self->{repeatTags}->{$path_str} ne $el->{'_P_ID'} and $self->{repeatTags}->{$path_str}){
    	# This is not repeatable tag yet. But maybe will be. remember its parent. Dont do this if path already marked as repeatable
    	$self->{repeatTags}->{$path_str}=$el->{'_P_ID'};  
    }else{#$self->{repeatTags}->{$path_str} == $el->{'_P_ID'}. 
    	$self->{repeatTags}->{$path_str}=undef;#this is repeatble tag mark it
    }
    my @attrs=keys(%{$el->{Attributes}});
    foreach my $attr(@attrs){
    	$self->{csvHeader}->{$path_str}->{'attrs'}->{$attr}={};
    }	 
    $self->{csvHeader}->{$path_str}->{'order'}=scalar(keys(%{$self->{csvHeader}}))+1 if !$self->{csvHeader}->{$path_str}->{'order'};
}

sub end_element {
    my ($self, $el) = @_;
	pop(@{$self->{tagStack}});
}
sub get_stack_path{
	my ($self,$stack)=@_;
	my $path_str;
	foreach my $tag(@$stack){
		if(ref($tag) ne 'HASH' and $tag->can('getName')){
			$path_str.='/'.$tag->getName();
		}else{
			$path_str.='/'.$tag->{Name};
		}
	}
	return $path_str;	
}

sub end_document {
	my $self=shift;
	foreach my $rep (keys(%{$self->{repeatTags}})){
		if(!$self->{repeatTags}->{$rep}){
			foreach my $rep1(keys %{$self->{repeatTags}}){
				if($rep1=~/^\Q$rep\E/ and $rep ne $rep1 and !$self->{repeatTags}->{$rep1}){
					$self->{repeatTags}->{$rep}='REP_PARENT';
					$self->{rep_parents}->{$rep}=1;
				}elsif(!$self->{repeatTags}->{$rep}){
					$self->{csv_paths}->{$rep}=1;
				}
			}
		}
	};
	foreach my $tag_path(keys(%{$self->{repeatTags}})){
		my $is_rep_parent=undef;
		my $is_csv_tag=undef;
		foreach my $rep_parent (keys %{$self->{rep_parents}}){ 
			if($tag_path=~/^\Q$rep_parent\E/){
				$is_rep_parent=1;
			};
		}
		next if $is_rep_parent;
		foreach my $csv_path (keys %{$self->{csv_paths}}){ 
			if($tag_path=~/^\Q$csv_path\E/){
				$is_csv_tag=1;
			};
		}
		next if $is_csv_tag;
		$self->{root_childs}->{$tag_path}=1;	 
	}
	
	my @header_arr;
	foreach my $header (keys(%{$self->{csvHeader}})){
		$self->{csvHeader}->{$header}->{'path'}=$header;		
		push(@header_arr,$self->{csvHeader}->{$header});		
	}	
	
	@header_arr=sort{$a->{'path'} cmp $b->{'path'}} @header_arr;
	$cnt=0;
	foreach my $header(@header_arr){
		foreach my $attr(keys(%{$header->{'attrs'}})){
			$header->{'attrs'}->{$attr}->{'order'}=$cnt;
			$cnt++;
		};
		$header->{'order'}=$cnt;
		$cnt++;
	}
	
	my $aa=1;
}
1;

package SAXs::TagBrowser;

use Data::Dumper;
use XML::SAX::Base;
use Text::CSV;
use utf8;
@ISA=qw(XML::SAX::Base);
@EXPORT = qw(); 
no warnings;
#USAGE
#        use SAXs::TagBrowser;
#        my $handler=SAXs::TagBrowser->new();
#        my $parser = XML::SAX::ParserFactory->parser(Handler => $handler);
#        my $stat=eval{$parser->parse_uri('some.xml')};
#        print Dumper($handler->{tags});
#        print Dumper($handler->{tagsSorted});

sub new{
	my $package=shift;
	my %params=@_;
	my $self=$package->SUPER::new(@_);
	return $self;	
}
  
sub start_document {
    my ($self, $doc) = @_;
    $self->{tagStack}=[];
	$self->{tags}={};
}
  
sub start_element {
    my ($self, $el) = @_;
   	push(@{$self->{tagStack}},$el);
 	my $path_str=$self->get_stack_path($self->{tagStack});
    if(ref($self->{tags}->{$path_str}) ne 'HASH'){
    	$self->{tags}->{$path_str}={};
    }
    foreach my $attr (keys %{$el->{Attributes}}){
		 $self->{tags}->{$path_str}->{$el->{Attributes}->{$attr}->{Name}}=$el->{Attributes}->{$attr}->{Value};
    }
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
sub end_document{
	my ($self)=@_;
	my @tags=sort {$b cmp $a} keys %{$self->{tags}};
	$self->{tagsSorted}=\@tags;
}
1;

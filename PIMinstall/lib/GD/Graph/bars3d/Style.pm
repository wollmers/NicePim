#==========================================================================
# Module: GD::Graph::bars3d::GD::Graph::bars3d::Style
#
# Copyright (C) 1999,2010 Alexey Lavrentiev. All Rights Reserved.
#

package GD::Graph::bars3d::Style;

sub new {
	my $package=shift;
	my %params=@_;
	my $self = {
		_rgb=>$params{'rgb'},
		_font=>$params{'font'},
		_legend_name=>$params{'legend_name'},
	};
	
	bless($self,$package);
	return $self;
}

sub rgb {
	my($self,$color)=@_;
	if (defined($color)){
		$self->{_rgb} = $color;
		return $self;
	}
	else{
		return $self->{_rgb};
	}
}

sub font {
	my($self,$font)=@_;
	if (defined($font)) {
		$self->{_font} = $font;
		return $self;
	}
	else{
		return $self->{_font};
	}
}

sub legend_name{
	my($self,$name)=@_;
	if (defined($name)) {
		$self->{_legend_name} = $name;
		return $self;
	}
	else {
		return $self->{_legend_name};
	}
}


1;

#==========================================================================
# Module: GD::Graph::bars3d::bars3dCustomStyle
#
# Copyright (C) 1999,2010 Alexey Lavrentiev. All Rights Reserved.
#
# Based on GD::Graph::bars3d.pm,v 1.16 2000/03/18 10:58:39 mgjv

package GD::Graph::bars3d::bars3dCustomStyle;

use strict;

use GD::Graph::axestype3d;
use GD::Graph::bars;
use GD::Graph::bars3d;
use GD::Graph::utils qw(:all);
use GD::Graph::colour qw(:colours);

@GD::Graph::bars3d::bars3dCustomStyle::ISA = qw(GD::Graph::bars3d);
$GD::Graph::bars3d::bars3dCustomStyle::VERSION = '0.01';

use constant PI => 4 * atan2(1,1);

sub x_axis_styles{
	my ($self,$styles)=@_;
	if(defined($styles)){
		$self->{_x_styles}=$styles;
		return $self;
	}else{
		return $self->{_x_styles};
	}
}

# CONTRIB Jeremy Wadsack
# This is a complete overhaul of the original GD::Graph::bars
# design, because all versions (overwrite = 0, 1, 2) 
# require that the bars be drawn in a loop of point over sets
sub draw_data
{
	my $self = shift;
	my $g = $self->{graph};

	my $bar_s = _round($self->{bar_spacing}/2);

	my $zero = $self->{zeropoint};

  my $i;	
   my @iterate =  (0 .. $self->{_data}->num_points());
   for $i ($self->{rotate_chart} ? reverse(@iterate) : @iterate) {
		my ($xp, $t);
		my $overwrite = 0;
		$overwrite = $self->{overwrite} if defined $self->{overwrite};
		
		my $j;
      my @iterate = (1 .. $self->{_data}->num_sets());
      for $j (($self->{rotate_chart} && $self->{cumulate} == 0) ? reverse(@iterate) : @iterate) {
			my $value = $self->{_data}->get_y( $j, $i );
			next unless defined $value;

			my $bottom = $self->_get_bottom($j, $i);
         $value = $self->{_data}->get_y_cumulative($j, $i)
				if ($self->{cumulate});

			# Pick a data colour, calc shading colors too, if requested
			# cycle_clrs option sets the color based on the point, not the dataset.
			my @rgb;
			if( $self->{cycle_clrs} ) {
				@rgb = $self->pick_data_clr( $i + 1 );
			} else {
				@rgb = $self->pick_data_clr( $j );
				if(ref($self->x_axis_styles()) eq 'ARRAY' and ref($self->x_axis_styles()->[$i]) and ref($self->x_axis_styles()->[$i]->rgb()) eq 'ARRAY' and scalar(@{$self->x_axis_styles()->[$i]->rgb()})==3){
					@rgb = @{$self->x_axis_styles()->[$i]->rgb};# apply styles if any
				}
			} # end if
			my $dsci = $self->set_clr( @rgb );
			if( $self->{'3d_shading'} ) {
				$self->{'3d_highlights'}[$dsci] = $self->set_clr( $self->_brighten( @rgb ) );
				$self->{'3d_shadows'}[$dsci]    = $self->set_clr( $self->_darken( @rgb ) );
			} # end if
			
			# contrib "Bremford, Mike" <mike.bremford@gs.com>
			my $brci;
			if( $self->{cycle_clrs} > 1 ) {
				$brci = $self->set_clr($self->pick_data_clr($i + 1));
			} else {
				$brci = $self->set_clr($self->pick_border_clr($j));
			} # end if


			# get coordinates of top and center of bar
			($xp, $t) = $self->val_to_pixel($i + 1, $value, $j);

			# calculate offsets of this bar
			my $x_offset = 0;
			my $y_offset = 0;
			if( $overwrite == 1 ) {
				$x_offset = $self->{bar_depth} * ($self->{_data}->num_sets() - $j);
				$y_offset = $self->{bar_depth} * ($self->{_data}->num_sets() - $j);
			}
			$t -= $y_offset;


			# calculate left and right of bar
			my ($l, $r);
         if ($self->{rotate_chart}) {
            $l = $bottom;
            ($r) = $self->val_to_pixel($i + 1, $value, $j);
         }

			if( (ref $self eq 'GD::Graph::mixed') || ($overwrite >= 1) )
			{
            if ($self->{rotate_chart}) {
               $bottom = $t + $self->{x_step}/2 - $bar_s + $x_offset;
               $t = $t - $self->{x_step}/2 + $bar_s + $x_offset;
            }
            else 
				{
				   $l = $xp - $self->{x_step}/2 + $bar_s + $x_offset;
				   $r = $xp + $self->{x_step}/2 - $bar_s + $x_offset;
				}
			}
			else
			{
            if ($self->{rotate_chart}) {
					warn "base is $t";
					$bottom = $t - $self->{x_step}/2 
					        + ($j) * $self->{x_step}/$self->{_data}->num_sets() 
					        + $bar_s + $x_offset;
					$t = $t - $self->{x_step}/2 
					   + ($j-1) * $self->{x_step}/$self->{_data}->num_sets() 
					   - $bar_s + $x_offset;
					warn "top bottom is ($t, $bottom)";
            }
            else 
				{
					$l = $xp 
						- $self->{x_step}/2
						+ ($j - 1) * $self->{x_step}/$self->{_data}->num_sets()
						+ $bar_s + $x_offset;
					$r = $xp 
						- $self->{x_step}/2
						+ $j * $self->{x_step}/$self->{_data}->num_sets()
						- $bar_s + $x_offset;
				}
			}

			if ($value >= 0) {
				# draw the positive bar
				$self->draw_bar( $g, $l, $t, $r, $bottom-$y_offset, $dsci, $brci, 0 )
			} else {
				# draw the negative bar
				$self->draw_bar( $g, $l, $bottom-$y_offset, $r, $t, $dsci, $brci, -1 )
			} # end if

		} # end for
	} # end for


	# redraw the 'zero' axis, front and right
	if( $self->{zero_axis} ) {
		$g->line( 
			$self->{left}, $self->{zeropoint}, 
			$self->{right}, $self->{zeropoint}, 
			$self->{fgci} );
		$g->line( 
			$self->{right}, $self->{zeropoint}, 
			$self->{right}+$self->{depth_3d}, $self->{zeropoint}-$self->{depth_3d}, 
			$self->{fgci} );
	} # end if

	# redraw the box face
	if ( $self->{box_axis} ) {
		# Axes box
		$g->rectangle($self->{left}, $self->{top}, $self->{right}, $self->{bottom}, $self->{fgci});
		$g->line($self->{right}, $self->{top}, $self->{right} + $self->{depth_3d}, $self->{top} - $self->{depth_3d}, $self->{fgci});
		$g->line($self->{right}, $self->{bottom}, $self->{right} + $self->{depth_3d}, $self->{bottom} - $self->{depth_3d}, $self->{fgci});
	} # end if

	return $self;
	
} # end draw_data




sub plot
{
	
	
	my $self = shift;
    my $data = shift;

    $self->check_data($data)            or return;
    $self->init_graph()                 or return;
    $self->setup_text()                 or return;
    my %legend_styles;
    if($self->{_x_styles}){
		foreach my $style(@{$self->{_x_styles}}){
			$legend_styles{$style->legend_name()}=$style if UNIVERSAL::can($style,'isa') and $style->can('legend_name') and ref($style->rgb()) eq 'ARRAY';	
		}
	}
	my @legend_names=keys(%legend_styles);
	
	my $saved_legend=$self->{legend};
	if(ref($self->{legend}) eq 'ARRAY'){
		push(@{$self->{legend}},@legend_names);
	}else{
		$self->{legend}=\@legend_names;
	}
	#setup_legend check for length of data array when calculate sizes of text spacing etc.
	#we need to trick it to take into account our styled legend in calculations     
	for(my $i=0;$i<@legend_names;$i++){
		push(@{$self->{_data}},'dummy');
	}

    $self->setup_legend();
    # now remove our dummy data sets 
	for(my $i=0;$i<@legend_names;$i++){
		pop(@{$self->{_data}});
	}
    
    $self->setup_coords()               or return;
    $self->draw_text();
    unless (defined $self->{no_axes})
    {
        $self->draw_axes();
        $self->draw_ticks()             or return;
    }
    $self->draw_data()                  or return;
    $self->draw_values()                or return;
    $self->{legend}=$saved_legend;
    $self->draw_legend();
    $self->draw_legend_from_style();

    return $self->{graph}
	
	
}



sub draw_legend_from_style{
	my $self=shift;
	
    return if !defined($self->{_x_styles}) or ref($self->{_x_styles}) ne 'ARRAY';
    my $xl = $self->{lg_xs}+ $self->{legend_spacing};
    my $y  = $self->{gdta_legend}->{y}+ (($self->{gdta_legend}->{y})?0:$self->{lg_ys}) + $self->{legend_spacing} - 1;
    
    my $i = 1;
    my $row = 1;
    my $x = $xl;    # start position of current element
	
	my %legend_styles;
	
	foreach my $style(@{$self->{_x_styles}}){
		$legend_styles{join('-',@{$style->rgb()})}=$style if UNIVERSAL::can($style,'isa') and $style->can('rgb') and ref($style->rgb()) eq 'ARRAY';	
	}
	my $saved_colors=$self->{dclrs};
	$self->{dclrs}=[];
	#$self->{lg_cols}=+scalar(keys(%legend_styles));
    foreach my $legend (keys(%legend_styles)){
        my $xe = $x;    # position within an element

        next unless defined($legend_styles{$legend}->rgb) && $legend_styles{$legend}->legend_name ne "";
        push(@{$self->{dclrs}},$i);
        my $current_clr='dummy_styled_legend_color_'.rand(1000000).'_';
		GD::Graph::colour::add_colour($current_clr=>$legend_styles{$legend}->rgb);
		
        $self->draw_legend_marker_rgb($current_clr, $xe, $y);

        $xe += $self->{legend_marker_width} + $self->{legend_spacing};
        my $ys = int($y + $self->{lg_el_height}/2 - $self->{lgfh}/2);

        $self->{gdta_legend}->set_text($legend_styles{$legend}->legend_name);
        $self->{gdta_legend}->draw($xe, $ys);

        $x += $self->{lg_el_width};

        if (++$row > $self->{lg_cols})
        {
            $row = 1;
            $y += $self->{lg_el_height};
            $x = $xl;
        }
    }
    $i++;
    $self->{dclrs}=$saved_colors;;	
}

sub draw_legend_marker_rgb # data_set_number, x, y and use RGB array 
{
    my $self = shift;
    my $colour = shift;
    my $x = shift;
    my $y = shift;
	
    my $g = $self->{graph};
	my $ci=$self->set_clr(_rgb($colour));
    return unless defined $ci;
	
    $y += int($self->{lg_el_height}/2 - $self->{legend_marker_height}/2);

    $g->filledRectangle(
        $x, $y, 
        $x + $self->{legend_marker_width}, $y + $self->{legend_marker_height},
        $ci
    );

    $g->rectangle(
        $x, $y, 
        $x + $self->{legend_marker_width}, $y + $self->{legend_marker_height},
        $self->{acci}
    );
}
1;

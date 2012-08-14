package ProductHandler;
use base qw(XML::SAX::Base);
use atomsql;

#use atomlog;

#start of xml file
sub start_document {
	my ( $self, $data ) = @_;

	#&log_printf("=====ProductHandler: start of parsing=====");
	$self->{product}                         = {};
	$self->{product_features}                = [];   #product features
	$self->{product_feature_locals}          = [];   #product feature locals
	$self->{product_ean_codes}               = [];   #product ean codes
	$self->{product_descriptions}            = [];   #product descriptions
	$self->{product_multimedia_objects}      = [];   #product multimedia objects
	$self->{product_summary_description}     = {};
	$self->{product_galleries}               = [];   #product galleries
	$self->{product_relateds}                = [];   #product relateds
	$self->{is_in_product_related}           = 0;
	$self->{is_in_short_summary_description} = 0;
	$self->{is_in_long_summary_description}  = 0;
}

#start of element in xml file
sub start_element {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	#data for table product
	if ( $data->{Name} eq 'Product' ) {
		if ( $self->{is_in_product_related} == 0 ) {
			$self->{product}->{icecat_id} =
			  $data->{Attributes}->{"{}ID"}->{Value};
			$self->{product}->{high_pic} =
			  &str_sqlize( $data->{Attributes}->{"{}HighPic"}->{Value} );
			$self->{product}->{high_pic_height} =
			  $data->{Attributes}->{"{}HighPicHeight"}->{Value};
			if (!defined $self->{product}->{high_pic_height}){
				$self->{product}->{high_pic_height} = 0;
			}
			$self->{product}->{high_pic_size} =
			  $data->{Attributes}->{"{}HighPicSize"}->{Value};
			if (!defined $self->{product}->{high_pic_size}){
				$self->{product}->{high_pic_size} = 0;
			}
			$self->{product}->{high_pic_width} =
			  $data->{Attributes}->{"{}HighPicWidth"}->{Value};
			if (!defined  $self->{product}->{high_pic_width}){
				 $self->{product}->{high_pic_width} = 0;
			}
			$self->{product}->{low_pic} =
			  &str_sqlize( $data->{Attributes}->{"{}LowPic"}->{Value} );
			$self->{product}->{low_pic_height} =
			  $data->{Attributes}->{"{}LowPicHeight"}->{Value};
			if (!defined $self->{product}->{low_pic_height}){
				$self->{product}->{low_pic_height} = 0;
			}
			$self->{product}->{low_pic_size} =
			  $data->{Attributes}->{"{}LowPicSize"}->{Value};
			if (!defined $self->{product}->{low_pic_size}){
				$self->{product}->{low_pic_size} = 0;
			}
			$self->{product}->{low_pic_width} =
			  $data->{Attributes}->{"{}LowPicWidth"}->{Value};
			if (!defined $self->{product}->{low_pic_width}){
				$self->{product}->{low_pic_width} = 0;
			}
			$self->{product}->{name} =
			  &str_sqlize( $data->{Attributes}->{"{}Name"}->{Value} );
			$self->{product}->{prod_id} =
			  &str_sqlize( $data->{Attributes}->{"{}Prod_id"}->{Value} );
			$self->{product}->{date_added} =
			  &str_sqlize( $data->{Attributes}->{"{}ReleaseDate"}->{Value} );
			$self->{product}->{thumb_pic} =
			  &str_sqlize( $data->{Attributes}->{"{}ThumbPicSize"}->{Value} );
			$self->{product}->{thumb_pic_size} =
			  $data->{Attributes}->{"{}ThumbPicSize"}->{Value};
			if (!defined $self->{product}->{thumb_pic_size}){
				$self->{product}->{thumb_pic_size} = 0;
			}
			$self->{product}->{high_pic_origin} = &str_sqlize("");
			$self->{product}->{topseller}       = &str_sqlize("");
			$self->{product}->{dname}           = &str_sqlize("");
		}
		elsif ( $self->{is_in_product_related} == 1 ) {
			my $product_related = {};
			$product_related->{product_id_icecat} =
			  $data->{Attributes}->{"{}ID"}->{Value};
			$sql = "SELECT product_id FROM product 
			 		WHERE icecat_id = $product_related->{product_id_icecat}";
			$query_res = &do_query($sql);
			$product_related->{product_id} = $query_res->[0][0];
			if ( defined $product_related->{product_id} ) {
				push( @{ $self->{product_relateds} }, $product_related );
			}
		}
	}

	#data for table category
	elsif ( $data->{Name} eq 'Category' ) {
		$self->{product}->{catid_icecat} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$sql = "SELECT catid FROM category 
				WHERE icecat_id = $self->{product}->{catid_icecat}";
		$query_res = &do_query($sql);
		$self->{product}->{catid} = $query_res->[0][0];
		if ( !defined $self->{product}->{catid} ) {
			$self->{product}->{catid} = "0";
		}
	}

	elsif ( $data->{Name} eq 'EANCode' ) {
		my $product_ean_code = {};
		$product_ean_code->{ean_code} = $data->{Attributes}->{"{}EAN"}->{Value};
		if ( defined $product_ean_code->{ean_code} ) {
			$sql = "SELECT ean_id FROM product_ean_codes 
				WHERE ean_code = $product_ean_code->{ean_code}";
			$query_res = &do_query($sql);
			if ( !defined $query_res->[0][0] ) {
				push( @{ $self->{product_ean_codes} }, $product_ean_code );
			}
		}
	}
	elsif ( $data->{Name} eq 'ProductDescription' ) {

		my $product_description = {};
		$product_description->{icecat_id} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		if ( defined $product_description->{icecat_id} ) {
			$product_description->{long_desc} =
			  &str_sqlize( $data->{Attributes}->{"{}LongDesc"}->{Value} );
			$product_description->{manual_pdf_size} =
			  $data->{Attributes}->{"{}ManualPDFSize"}->{Value};
			$product_description->{manual_pdf_url} =
			  &str_sqlize( $data->{Attributes}->{"{}ManualPDFURL"}->{Value} );
			$product_description->{pdf_size} =
			  $data->{Attributes}->{"{}PDFSize"}->{Value};
			$product_description->{pdf_url} =
			  &str_sqlize( $data->{Attributes}->{"{}PDFURL"}->{Value} );
			$product_description->{short_desc} =
			  &str_sqlize( $data->{Attributes}->{"{}ShortDesc"}->{Value} );
			$product_description->{specs_url} =
			  &str_sqlize( $data->{Attributes}->{"{}URL"}->{Value} );
			$product_description->{warranty_info} =
			  &str_sqlize( $data->{Attributes}->{"{}WarrantyInfo"}->{Value} );
			$product_description->{langid_icecat} =
			  $data->{Attributes}->{"{}langid"}->{Value};

			#search language in database
			$sql = "SELECT langid FROM language 
					WHERE icecat_id = $product_description->{langid_icecat}";
			$query_res = &do_query($sql);
			$product_description->{langid} = $query_res->[0][0];
			if ( defined $product_description->{langid} ) {
				push( @{ $self->{product_descriptions} },
					$product_description );
			}
		}
	}
	elsif ( $data->{Name} eq 'MultimediaObject' ) {

		my $product_multimedia_object = {};
		$product_multimedia_object->{icecat_id} =
		  $data->{Attributes}->{"{}MultimediaObject_ID"}->{Value};
		if ( defined $product_multimedia_object->{icecat_id} ) {
			$sql = "SELECT id FROM product_multimedia_object 
				WHERE icecat_id = $product_multimedia_object->{icecat_id}";
			$query_res = &do_query($sql);
			$product_multimedia_object->{id} = $query_res->[0][0];
			if ( !defined $product_multimedia_object->{id}
				|| $self->{import_mode} == 1 )
			{
				$product_multimedia_object->{content_type} =
				  &str_sqlize(
					$data->{Attributes}->{"{}ContentType"}->{Value} );
				$product_multimedia_object->{updated} =
				  &str_sqlize( $data->{Attributes}->{"{}Date"}->{Value} );
				$product_multimedia_object->{short_descr} =
				  &str_sqlize(
					$data->{Attributes}->{"{}Description"}->{Value} );
				$product_multimedia_object->{height} =
				  $data->{Attributes}->{"{}Height"}->{Value};
				$product_multimedia_object->{keep_as_url} =
				  $data->{Attributes}->{"{}KeepAsURL"}->{Value};
				$product_multimedia_object->{size} =
				  $data->{Attributes}->{"{}Size"}->{Value};
				$product_multimedia_object->{type} =
				  &str_sqlize( $data->{Attributes}->{"{}Type"}->{Value} );
				$product_multimedia_object->{link} =
				  &str_sqlize( $data->{Attributes}->{"{}URL"}->{Value} );
				$product_multimedia_object->{width} =
				  $data->{Attributes}->{"{}Width"}->{Value};
				$product_multimedia_object->{langid_icecat} =
				  $data->{Attributes}->{"{}langid"}->{Value};

				#search language in database
				$sql = "SELECT langid FROM language 
					WHERE icecat_id = $product_multimedia_object->{langid_icecat}";
				$query_res = &do_query($sql);
				$product_multimedia_object->{langid} = $query_res->[0][0];
				if ( defined $product_multimedia_object->{langid} ) {
					push(
						@{ $self->{product_multimedia_objects} },
						$product_multimedia_object
					);
				}
			}
		}
	}
	elsif ( $data->{Name} eq 'ProductFamily' ) {
		$self->{product}->{family_id_icecat} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		if ( defined $self->{product}->{family_id_icecat} ) {
			$sql = "SELECT family_id FROM product_family 
				WHERE icecat_id = $self->{product}->{family_id_icecat}";
			$query_res = &do_query($sql);
			$self->{product}->{family_id} = $query_res->[0][0];
		}
		if ( !defined $self->{product}->{family_id} ) {
			$self->{product}->{family_id} = "0";
		}
	}
	elsif ( $data->{Name} eq 'ProductFeature' ) {
		my $localized = $data->{Attributes}->{"{}Localized"}->{Value};

		#international product feature
		if ( $localized == 0 ) {
			my $product_feature = {};

			#search category feature in database
			$product_feature->{category_feature_id_icecat} =
			  $data->{Attributes}->{"{}CategoryFeature_ID"}->{Value};
			$sql = "SELECT category_feature_id FROM category_feature 
					WHERE icecat_id = $product_feature->{category_feature_id_icecat}";
			$query_res = &do_query($sql);
			$product_feature->{category_feature_id} = $query_res->[0][0];
			if ( defined $product_feature->{category_feature_id} ) {
				$product_feature->{icecat_id} =
				  $data->{Attributes}->{"{}ID"}->{Value};
				$product_feature->{value} =
				  &str_sqlize( $data->{Attributes}->{"{}Value"}->{Value} );
				push( @{ $self->{product_features} }, $product_feature );
			}
		}

		#localized product feature
		elsif ( $localized == 1 ) {
			my $product_feature_local = {};

			#search category feature in database
			$product_feature_local->{category_feature_id_icecat} =
			  $data->{Attributes}->{"{}CategoryFeature_ID"}->{Value};
			$sql = "SELECT category_feature_id FROM category_feature 
					WHERE icecat_id = $product_feature_local->{category_feature_id_icecat}";
			$query_res = &do_query($sql);
			$product_feature_local->{category_feature_id} = $query_res->[0][0];

			if ( defined $product_feature_local->{category_feature_id} ) {
				$product_feature_local->{icecat_id} =
				  $data->{Attributes}->{"{}Local_ID"}->{Value};
				$product_feature_local->{value} =
				  &str_sqlize(
					$data->{Attributes}->{"{}Presentation_Value"}->{Value} );
				push(
					@{ $self->{product_feature_locals} },
					$product_feature_local
				);
			}
		}
	}
	elsif ( $data->{Name} eq 'ProductPicture' ) {
		my $product_gallery = {};
		$product_gallery->{icecat_id} =
		  $data->{Attributes}->{"{}ProductPicture_ID"}->{Value};
		$product_gallery->{link} =
		  &str_sqlize( $data->{Attributes}->{"{}Pic"}->{Value} );
		$product_gallery->{link_origin} = &str_sqlize("");
		$product_gallery->{height} =
		  $data->{Attributes}->{"{}PicHeight"}->{Value};
		$product_gallery->{width} =
		  $data->{Attributes}->{"{}PicWidth"}->{Value};
		$product_gallery->{size} = $data->{Attributes}->{"{}Size"}->{Value};
		$product_gallery->{thumb_link} =
		  &str_sqlize( $data->{Attributes}->{"{}ThumbPic"}->{Value} );
		$product_gallery->{thumb_size} =
		  $data->{Attributes}->{"{}ThumbSize"}->{Value};
		push( @{ $self->{product_galleries} }, $product_gallery );
	}
	elsif ( $data->{Name} eq 'ProductRelated' ) {
		$self->{is_in_product_related} = 1;
	}
	elsif ( $data->{Name} =~ /ShortSummaryDescription.*/ ) {
		$self->{is_in_short_summary_description}++;
	}
	elsif ( $data->{Name} =~ /LongSummaryDescription.*/ ) {
		$self->{is_in_long_summary_description}++;
	}
	elsif ( $data->{Name} eq 'Supplier' ) {
		$self->{product}->{supplier_id_icecat} =
		  $data->{Attributes}->{"{}ID"}->{Value};
		$sql = "SELECT supplier_id FROM supplier 
				WHERE icecat_id = $self->{product}->{supplier_id_icecat}";
		$query_res = &do_query($sql);
		$self->{product}->{supplier_id} = $query_res->[0][0];
		if ( !defined $self->{product}->{supplier_id} ) {
			$self->{product}->{supplier_id} = "0";
		}
	}
}

#characters in xml file
sub characters {
	my ( $self, $data ) = @_;
	if ( $self->{is_in_short_summary_description} == 1 ) {
		$self->{product_summary_description}->{short_summary_description} =
		  &str_sqlize( $data->{Data} );
	}
	elsif ( $self->{is_in_long_summary_description} == 1 ) {
		$self->{product_summary_description}->{long_summary_description} =
		  &str_sqlize( $data->{Data} );
	}
}

#end element in xml file
sub end_element {
	my ( $self, $data ) = @_;
	if ( $data->{Name} eq 'ProductRelated' ) {
		$self->{is_in_product_related} = 0;
	}
	elsif ( $data->{Name} =~ /ShortSummaryDescription.*/ ) {
		$self->{is_in_short_summary_description}--;

	}
	elsif ( $data->{Name} =~ /LongSummaryDescription.*/ ) {
		$self->{is_in_long_summary_description}--;
	}
	elsif ( $data->{Name} eq 'SummaryDescription' ) {
		$self->{product_summary_description}->{langid} = "0";
	}
}

#end of xml file
sub end_document {
	my ( $self, $data ) = @_;
	my ( $sql, $query_res );

	$sql = "SELECT product_id FROM product 
					WHERE prod_id=$self->{product}->{prod_id} AND supplier_id = $self->{product}->{supplier_id} ";
	$query_res = &do_query($sql);
	$self->{product}->{product_id} = $query_res->[0][0];

	#insert related data for edited product
	if ( !defined $self->{product}->{product_id} || $self->{import_mode} == 1 )
	{

		#insert product
		if ( !defined $self->{product}->{product_id} ) {
			if ( $self->{langid} == 0 ) {
				$self->insert_product();
			}
			else {
				$self->insert_localized_product();
			}
		}

		#update product
		elsif ( $self->{import_mode} == 1 ) {
			if ( $self->{langid} == 0 ) {
				$self->update_product();
			}
			else {
				$self->update_localized_product();
			}
		}

		#insert or update product features
		foreach my $product_feature ( @{ $self->{product_features} } ) {

			#search product feature in database
			$sql = "SELECT product_feature_id FROM product_feature 
						WHERE category_feature_id = $product_feature->{category_feature_id} 
						AND product_id = $self->{product}->{product_id}";
			$query_res = &do_query($sql);
			$product_feature->{product_feature_id} = $query_res->[0][0];
			if ( !defined $product_feature->{product_feature_id} ) {
				$self->insert_product_feature($product_feature);
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_feature($product_feature);
			}
		}

		#insert or update product feature locals
		foreach
		  my $product_feature_local ( @{ $self->{product_feature_locals} } )
		{

			#search product feature local in database
			$sql = "SELECT product_feature_local_id FROM product_feature_local 
					WHERE category_feature_id = $product_feature_local->{category_feature_id} 
					AND product_id = $self->{product}->{product_id} 
					AND langid = $self->{langid}";
			$query_res = &do_query($sql);
			$product_feature_local->{product_feature_local_id} =
			  $query_res->[0][0];
			if ( !defined $product_feature_local->{product_feature_local_id} ) {
				$self->insert_product_feature_local($product_feature_local);
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_feature_local($product_feature_local);
			}
		}

		#insert or update ean codes
		foreach my $product_ean_code ( @{ $self->{product_ean_codes} } ) {
			if ( !defined $product_ean_code->{product_ean_code_id} ) {
				$self->insert_product_ean_code($product_ean_code);
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_ean_code($product_ean_code);
			}
		}

		#insert or update product gelleries
		foreach my $product_gallery ( @{ $self->{product_galleries} } ) {
			$sql = "SELECT id FROM product_gallery 
				WHERE product_id = $self->{product}->{product_id}
				AND link = $product_gallery->{link}";
			$query_res = &do_query($sql);
			$product_gallery->{id} = $query_res->[0][0];
			if ( !defined $product_gallery->{id} ) {
				$self->insert_product_gallery($product_gallery);
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_gallery($product_gallery);
			}
		}

		#insert or update descriptions
		foreach my $product_description ( @{ $self->{product_descriptions} } ) {
			$sql = "SELECT product_description_id FROM product_description 
				WHERE product_id = $self->{product}->{product_id} AND langid = $product_description->{langid} ";
			$query_res = &do_query($sql);
			$product_description->{product_description_id} = $query_res->[0][0];
			if ( !defined $product_description->{product_description_id}
				|| $self->{import_mode} == 1 )
			{
				if ( !defined $product_description->{product_description_id} ) {
					$self->insert_product_description($product_description);
				}
				elsif ( $self->{import_mode} == 1 ) {
					$self->update_product_description($product_description);
				}
			}
		}

		#insert or update product multimedia objects
		foreach my $product_multimedia_object (
			@{ $self->{product_multimedia_objects} } )
		{
			if ( !defined $product_multimedia_object->{id} ) {
				$self->insert_product_multimedia_object(
					$product_multimedia_object);
			}
			elsif ( $self->{import_mode} == 1 ) {
				$self->update_product_multimedia_object(
					$product_multimedia_object);
			}
		}

		#insert or update summary description
		$sql = "SELECT product_summary_description_id 
				FROM product_summary_description 
				WHERE langid = 0 AND product_id = $self->{product}->{product_id}";
		$query_res = &do_query($sql);
		$self->{product_summary_description}->{product_summary_description_id} =
		  $query_res->[0][0];
		if ( !defined $self->{product_summary_description}
			{product_summary_description_id} )
		{
			$self->insert_product_summary_description();
		}
		elsif ( $self->{import_mode} == 1 ) {
			$self->update_product_summary_description();
		}

		#insert related products
		foreach my $product_related ( @{ $self->{product_relateds} } ) {
			$self->insert_product_related($product_related);
		}
	}

	#&log_printf("=====ProductHandler: end of parsing=====");
}

#insert product
sub insert_product {
	my ($self) = @_;
	my $sql = "INSERT INTO product ( 
			user_id, catid,supplier_id,
			high_pic, high_pic_height,high_pic_size, 
			high_pic_width, low_pic, low_pic_height, 
			low_pic_size, low_pic_width, name, 
			prod_id, date_added, thumb_pic,thumb_pic_size, 
			high_pic_origin, topseller, dname,icecat_id) 
			VALUES(
			$self->{user_id}, 
			$self->{product}->{catid},
			$self->{product}->{supplier_id},
			$self->{product}->{high_pic}, 
			$self->{product}->{high_pic_height},
			$self->{product}->{high_pic_size}, 
			$self->{product}->{high_pic_width}, 
			$self->{product}->{low_pic}, 
			$self->{product}->{low_pic_height}, 
			$self->{product}->{low_pic_size}, 
			$self->{product}->{low_pic_width}, 
			$self->{product}->{name}, 
			$self->{product}->{prod_id}, 
			NOW(), 
			$self->{product}->{thumb_pic},
			$self->{product}->{thumb_pic_size}, 
			$self->{product}->{high_pic_origin}, 
			$self->{product}->{topseller}, 
			$self->{product}->{dname},
			$self->{product}->{icecat_id}) ";
	&do_statement($sql);
	$sql                           = "SELECT LAST_INSERT_ID()";
	$query_res                     = &do_query($sql);
	$self->{product}->{product_id} = $query_res->[0][0];
}

#update product
sub update_product {
	my ($self) = @_;
	my $sql = "UPDATE product SET 
		user_id = $self->{user_id}, 
		catid = $self->{product}->{catid},
		high_pic = $self->{product}->{high_pic}, 
		high_pic_height=$self->{product}->{high_pic_height},
		high_pic_size=$self->{product}->{high_pic_size}, 
	  	high_pic_width=$self->{product}->{high_pic_width}, 
	  	low_pic=$self->{product}->{low_pic}, 
	  	low_pic_height=$self->{product}->{low_pic_height}, 
		low_pic_size=$self->{product}->{low_pic_size}, 
		low_pic_width=$self->{product}->{low_pic_width}, 
		name=$self->{product}->{name},
		thumb_pic=$self->{product}->{thumb_pic},
		thumb_pic_size=$self->{product}->{thumb_pic_size}, 
		high_pic_origin=$self->{product}->{high_pic_origin}, 
		topseller=$self->{product}->{topseller}, 
		dname=$self->{product}->{dname}, 
		icecat_id = $self->{product}->{icecat_id} 
		WHERE product_id=$self->{product}->{product_id} ";
	&do_statement($sql);
}

#insert localized product
sub insert_localized_product {
	my ($self) = @_;
	my $sql = "INSERT INTO product ( 
			user_id, catid,supplier_id,
			high_pic, high_pic_height,high_pic_size, 
			high_pic_width, low_pic, low_pic_height, 
			low_pic_size, low_pic_width, 
			prod_id, date_added, thumb_pic,thumb_pic_size, 
			high_pic_origin, topseller, dname,icecat_id) 
			VALUES(
			$self->{user_id}, 
			$self->{product}->{catid},
			$self->{product}->{supplier_id},
			$self->{product}->{high_pic}, 
			$self->{product}->{high_pic_height},
			$self->{product}->{high_pic_size}, 
			$self->{product}->{high_pic_width}, 
			$self->{product}->{low_pic}, 
			$self->{product}->{low_pic_height}, 
			$self->{product}->{low_pic_size}, 
			$self->{product}->{low_pic_width}, 
			$self->{product}->{prod_id}, 
			NOW(), 
			$self->{product}->{thumb_pic},
			$self->{product}->{thumb_pic_size}, 
			$self->{product}->{high_pic_origin}, 
			$self->{product}->{topseller}, 
			$self->{product}->{dname},
			$self->{product}->{icecat_id}) ";
	&do_statement($sql);
	$sql                           = "SELECT LAST_INSERT_ID()";
	$query_res                     = &do_query($sql);
	$self->{product}->{product_id} = $query_res->[0][0];

	#insert product name
	$sql = "INSERT INTO product_name (product_id,name,langid) 
			VALUES ($self->{product}->{product_id},
			$self->{product}->{name},$self->{langid})";
	&do_statement($sql);
}

#update localized product
sub update_localized_product {
	my ($self) = @_;
	my $sql = "UPDATE product SET 
		user_id = $self->{user_id}, 
		catid = $self->{product}->{catid},
		high_pic = $self->{product}->{high_pic}, 
		high_pic_height=$self->{product}->{high_pic_height},
		high_pic_size=$self->{product}->{high_pic_size}, 
	  	high_pic_width=$self->{product}->{high_pic_width}, 
	  	low_pic=$self->{product}->{low_pic}, 
	  	low_pic_height=$self->{product}->{low_pic_height}, 
		low_pic_size=$self->{product}->{low_pic_size}, 
		low_pic_width=$self->{product}->{low_pic_width}, 
		thumb_pic=$self->{product}->{thumb_pic},
		thumb_pic_size=$self->{product}->{thumb_pic_size}, 
		high_pic_origin=$self->{product}->{high_pic_origin}, 
		topseller=$self->{product}->{topseller}, 
		dname=$self->{product}->{dname}, 
		icecat_id = $self->{product}->{icecat_id} 
		WHERE product_id=$self->{product}->{product_id} ";
	&do_statement($sql);

	#insert or update product name
	$sql = "INSERT INTO product_name (product_id,name,langid) 
			VALUES ($self->{product}->{product_id},
			$self->{product}->{name},$self->{langid}) 
			ON DUPLICATE KEY UPDATE 
			name = $self->{product}->{name}";
	&do_statement($sql);
}

#insert product feature
sub insert_product_feature {
	my ( $self, $product_feature ) = @_;
	my $sql = "INSERT INTO product_feature 
			(product_id, category_feature_id, value, icecat_id) 
			VALUES(
			$self->{product}->{product_id},
			$product_feature->{category_feature_id},
			$product_feature->{value},
			$product_feature->{icecat_id})";
	&do_statement($sql);
}

#update product feature
sub update_product_feature {
	my ( $self, $product_feature ) = @_;
	my $sql = "UPDATE product_feature SET 
			value = $product_feature->{value},
			icecat_id = $product_feature->{icecat_id} 
			WHERE product_feature_id = $product_feature->{product_feature_id}";
	&do_statement($sql);
}

#insert product feature local
sub insert_product_feature_local {
	my ( $self, $product_feature_local ) = @_;
	my $sql = "INSERT INTO product_feature_local 
			(product_id, category_feature_id, value, langid, icecat_id) 
			VALUES(
			$self->{product}->{product_id},
			$product_feature_local->{category_feature_id},
			$product_feature_local->{value},
			$self->{langid},
			$product_feature_local->{icecat_id})";
	&do_statement($sql);
}

#update product feature local
sub update_product_feature_local {
	my ( $self, $product_feature_local ) = @_;
	my $sql = "UPDATE product_feature_local SET 
			value = $product_feature_local->{value}, 
			icecat_id = $product_feature_local->{icecat_id} 
			WHERE product_feature_local_id = $product_feature_local->{product_feature_local_id}";
	&do_statement($sql);
}

#insert product EAN code
sub insert_product_ean_code {
	my ( $self, $product_ean_code ) = @_;
	my $sql = "INSERT INTO product_ean_codes 
			(product_id,ean_code) 
			VALUES(
			$self->{product}->{product_id},
			$product_ean_code->{ean_code})";
	&do_statement($sql);
}

#insert product description
sub insert_product_description {
	my ( $self, $product_description ) = @_;
	my $sql = "INSERT INTO product_description 
			(product_id, langid, long_desc, manual_pdf_size, manual_pdf_url,
			pdf_size,pdf_url,short_desc, specs_url,
			warranty_info, icecat_id) 
			VALUES(
			$self->{product}->{product_id},
			$product_description->{langid},
			$product_description->{long_desc},
			$product_description->{manual_pdf_size},
			$product_description->{manual_pdf_url},
			$product_description->{pdf_size},
			$product_description->{pdf_url},
			$product_description->{short_desc},
			$product_description->{specs_url},
			$product_description->{warranty_info},
			$product_description->{icecat_id})";
	&do_statement($sql);
}

#update product description
sub update_product_description {
	my ( $self, $product_description ) = @_;
	my $sql = "UPDATE product_description SET 
			long_desc = $product_description->{long_desc},
			manual_pdf_size = $product_description->{manual_pdf_size},
			manual_pdf_url = $product_description->{manual_pdf_url},
			pdf_size = $product_description->{pdf_size},
			pdf_url = $product_description->{pdf_url},
			short_desc = $product_description->{short_desc},
			specs_url = $product_description->{specs_url},
			warranty_info = $product_description->{warranty_info}, 
			icecat_id = $product_description->{icecat_id} 
			WHERE product_description_id = $product_description->{product_description_id} ";
	&do_statement($sql);
}

#insert product summary description
sub insert_product_summary_description {
	my ($self) = @_;
	my $sql = "INSERT INTO product_summary_description 
			(product_id, langid, long_summary_description, short_summary_description) 
			VALUES(
			$self->{product}->{product_id},
			$self->{product_summary_description}->{langid},
			$self->{product_summary_description}->{long_summary_description},
			$self->{product_summary_description}->{short_summary_description})";
	&do_statement($sql);
}

#update product summary description
sub update_product_summary_description {
	my ($self) = @_;
	my $sql = "UPDATE product_summary_description SET 
			long_summary_description = $self->{product_summary_description}->{long_summary_description},
			short_summary_description = $self->{product_summary_description}->{short_summary_description} 
			WHERE product_summary_description_id = $self->{product_summary_description}->{product_summary_description_id}";
	&do_statement($sql);
}

#insert product gallery
sub insert_product_gallery {
	my ( $self, $product_gallery ) = @_;
	my $sql = "INSERT INTO product_gallery 
			(product_id, link, link_origin, height, width,
			size,thumb_link,thumb_size,icecat_id) 
			VALUES(
			$self->{product}->{product_id},
			$product_gallery->{link},
			$product_gallery->{link_origin},
			$product_gallery->{height},
			$product_gallery->{width},
			$product_gallery->{size},
			$product_gallery->{thumb_link},
			$product_gallery->{thumb_size},
			$product_gallery->{icecat_id})";
	&do_statement($sql);
}

#update product gallery
sub update_product_gallery {
	my ( $self, $product_gallery ) = @_;
	my $sql = "UPDATE product_gallery SET  
			link_origin = $product_gallery->{link_origin},
			height = $product_gallery->{height},
			width = $product_gallery->{width},
			size = $product_gallery->{size},
			thumb_link = $product_gallery->{thumb_link},
			thumb_size = $product_gallery->{thumb_size} 
			WHERE id = $product_gallery->{id}";
	&do_statement($sql);
}

#insert product related
sub insert_product_related {
	my ( $self, $product_related ) = @_;
	my $sql = "SELECT product_related_id FROM product_related 
			WHERE product_id = $product_related->{product_id} 
			AND rel_product_id = $self->{product}->{product_id}";
	my $query_res = &do_query($sql);
	if ( !defined $query_res->[0][0] ) {
		$sql = "INSERT INTO product_related 
			(product_id, rel_product_id) 
			VALUES(
			$product_related->{product_id},
			$self->{product}->{product_id})";
		&do_statement($sql);
	}
}

#insert multimedia object
sub insert_product_multimedia_object {
	my ( $self, $product_multimedia_object ) = @_;
	my $sql = "INSERT INTO product_multimedia_object 
			(product_id, content_type, updated, short_descr, height, keep_as_url, 
			size, type, link, width, langid, icecat_id) 
			VALUES(
			$self->{product}->{product_id},
			$product_multimedia_object->{content_type},
			$product_multimedia_object->{updated},
			$product_multimedia_object->{short_descr},
			$product_multimedia_object->{height},
			$product_multimedia_object->{keep_as_url},
			$product_multimedia_object->{size},
			$product_multimedia_object->{type},
			$product_multimedia_object->{link},
			$product_multimedia_object->{width},
			$product_multimedia_object->{langid},
			$product_multimedia_object->{icecat_id})";
	&do_statement($sql);
}

#update multimedia object
sub update_product_multimedia_object {
	my ( $self, $product_multimedia_object ) = @_;
	my $sql = "UPDATE product_multimedia_object SET  
			product_id = $self->{product}->{product_id},
			content_type = $product_multimedia_object->{content_type}, 
			updated = $product_multimedia_object->{updated}, 
			short_descr = $product_multimedia_object->{short_descr}, 
			height = $product_multimedia_object->{height}, 
			size = $product_multimedia_object->{size}, 
			keep_as_url = $product_multimedia_object->{keep_as_url}, 
			size = $product_multimedia_object->{size}, 
			type = $product_multimedia_object->{type}, 
			link = $product_multimedia_object->{link}, 
			width = $product_multimedia_object->{width}, 
			langid = $product_multimedia_object->{langid}  
			WHERE icecat_id = $product_multimedia_object->{icecat_id}";
	&do_statement($sql);
}

#set import mode
sub set_import_mode {
	my ( $self, $import_mode ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{import_mode} = $import_mode;
}

#set user id
sub set_user_id {
	my ( $self, $user_id ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{user_id} = $user_id;
}

#set langid
sub set_langid {
	my ( $self, $langid ) = @_;
	die "instance method called on class" unless ref $self;
	$self->{langid} = $langid;
}

1;

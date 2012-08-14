{
 name:errors;
 
 error_row: <li style="color: red;">%%error_text%%<br>
 body: <ul style="color: red;">Error(s)\:
			   %%error_rows%%
			 </ul>
 
 email: %%name%% is niet valide
 mandatory: %%name%% missing (mandatory)
 url: %%name%% is niet valide
 unique: %%name%% is not unique
 numeric: %%name%% is not numeric 

 date: %%name%% is not valid date. Date should be in DD-MM-YYYY format.
 login_expiration_date: %%name%% is not valid date. Date should be in YYYY-MM-DD hh:mm:ss format.
 low_pic: %%name%% can't be uploaded.
 high_pic: %%name%% can't be uploaded.
 pdf_url: %%name%% can't be uploaded.
 family_id: Current product family doesn't belong to suppluier
 
 unauthorized: You're not authorized to view this page
 integrity_validation_fails: Can't delete feature. This feature is used in following data sources\: %%sources%%
 assigned_rows_exists: Can't delete this object. Following objects has references to this one\: %%value%%
 prod_id_should_be_mapped: Warning: Product <b>%%prod_id%%</b> may be mapped by rule to <b>%%m_prod_id%%</b>%%map_supplier_name%%. Press action button again to ignore.
 stat_period: Report period should be relative
 missing_feature_value: Missing feature value for feature "%%feature_name%%"
 missing_feature_name: Missing feature name for language "%%language%%"
 missing_category_name: Missing category name for language "%%language%%"
 missing_mandatory_feature_value: Missing feature value for mandatory feature "%%feature_name%%"
 nonenglish_feature_value: Non International feature value "<i>%%feature_value%%</i>" for mandatory feature "%%feature_name%%"
 missing_mandatory_feature_value_tab: Missing feature value for mandatory feature "%%feature_name%%" in %%tab%% tab
 catid_mismatch: products category and products family category mismatch
 sup_family_id_mismatch: products brand and products family mismatch
 sup_cat_family: For this brand/category combination a product family is required
 category_not_allowed: Selected main category is not allowed to contain products. Please, select a category at the most detailed level.
 dispatch_groups: Pick up at least one email address;
 group_actions: Uncompatibe actions;
 group_actions_empty: Pick up at least one group action;
 gallery_thumbnail: Error occupied while thumbail created. Try again please.
 gallery_upload: Picture uploading error. Try again please.
 gallery_convert: Error occupied while picture converting. Try again please.
 related_incorrect: Related product code is incorrect
 related_duplicate: Relation to this product already present
 empty_category: Pick up at least one category;
 default_manager: Default manager already exist;
 thumb_bad: Thubmnail can't be created. May be picture of bad quality.
 dest_part_number_not_unique: Destination part number from destination brand already exists.
 invalid_ean_code: Invalid EAN code <b>%%code%%</b>, checksum failed
 already_present_ean_code: EAN code <b>%%code%%</b> already belongs to another product (part number is <b>%%prod_id%%</b>)
 pattern_invalid: There are %%num%% localizations total found. Please check patterns.
 merge_products: There are same part codes in both brand products. Please confirm merging products.
 merge_products_error: You have no rights to merge products. Please delete merged products from your list.
 supplier_name_void: You entered void new brand name.
 feature_name_void: You entered void new feature name.
 measure_id_void: Please select proper measure for new feature.
 multiple_measure_map: Another mapping process already started <b>%%secs%%</b> seconds ago for current measure by <b>%%login%%</b>. Please, wait, until it have finished.
 incorrect_file_type: Incorrect file type!
 relation_are_too_global: You wanted to create too general relation rule! Please, set another rule.
 check_dates: Please, check dates. Start date must be less than end date
 check_date: Please, check the delivery date
 complete_email_params: Please, complete email parameters
 adding_shop_isnot_allowed: You can't add (save) user having group of shop in the backoffice interface
 html_validation: %%name%% - invalid HTML code
 report_type_and_interval: html type of report format is not allowed for <b>%%report_type%%</b> interval
 check_prod_id_strictness: Please, check the product part code. It can't match the templates: %%regexps%%
}

{
 name:errors;
 
 class: pub;
 
 error_row: %%error_text%%<br>
 body: 
			<font size=8>%%error_rows%%</font>
			 
 
 email: %%name%% is niet valide
 mandatory: %%name%% is verplicht
 url: %%name%% is niet valide
 unique: %%name%% is not unique
 date: %%name%% is not valid date. Date should be in DD-MM-YYYY format.
 unauthorized: You're not authorized to view this page
}

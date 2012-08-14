<script type="text/javascript">
<!--

// reset form to default state

function defaultPart (session_id) \{
	document.getElementById('supplier').value = '';
	document.getElementById('supplierfamily').value = 1;
	document.getElementById('category').value = '';
	document.getElementById('feature').value = '';
	document.getElementById('featurevalue').value = '';
	document.getElementById('prodid').value = '';
	document.getElementById('prodid').style.height = 100;
	document.getElementById('start_date').value = '0000-00-00';
	document.getElementById('end_date').value = '0000-00-00';

	document.getElementById('featurevalue').disabled = true;
	document.getElementById('exact_value').value = 0;
	document.getElementById('supplier').disabled = true;
	document.getElementById('supplierfamily').disabled = true;
	document.getElementById('category').disabled = true;
	document.getElementById('feature').disabled = true;
	document.getElementById('exact_value').disabled = true;

	get_supplier_edit_call(session_id);

	if (document.getElementById('left_right').value == 0) \{ // destination
		get_category_edit_call(session_id);
		get_feature_edit_call(session_id);
	\}

	calculateAmount(session_id);
\}

// prepare form for new rule adding

function enableSetAdding (session_id, type) \{
	document.getElementById('include_exclude').value = 1; // include

	if (type == 'destination') \{ // destination
		document.getElementById('include_exclude').disabled = false;
		document.getElementById('left_right').value = 0; // right
	\}
	else \{ // source
		document.getElementById('include_exclude').disabled = true;
		document.getElementById('left_right').value = 1; // left
	\}

	document.getElementById('prodid').style.height = 100;

	document.getElementById('action').value = 'add';

	leftRightOnChange();

	if (type == 'destination') \{
		document.getElementById('relation_rule_add_destination_button').style.display = 'none';
		document.getElementById('relation_rule_add_source_button').style.display = 'inline';
	\}
	else \{
		document.getElementById('relation_rule_add_source_button').style.display = 'none';
		document.getElementById('relation_rule_add_destination_button').style.display = 'inline';
	\}

	document.getElementById('relation_rule_manage_div').style.display = 'block';

	defaultPart(session_id);
	
	document.getElementById('edit_relation_span').style.display = 'none';
	document.getElementById('add_relation_span').style.display = 'block';
\}

// prepare form for rule editing

function enableSetEditing(rsid, rrid, session_id) \{
	document.getElementById('relation_rule_add_source_button').style.display = 'inline';
	document.getElementById('relation_rule_add_destination_button').style.display = 'inline';

	document.getElementById('add_relation_span').style.display = 'none';
	document.getElementById('edit_relation_span').style.display = 'block';

	document.getElementById('relation_rule_manage_div').style.display = 'block';

	document.getElementById('relation_rule_id').value = rrid;
	document.getElementById('relation_set_id').value = rsid;
	document.getElementById('action').value = 'edit';
	document.getElementById('exact_value').value = 0;

	document.getElementById('include_exclude').value = document.getElementById(rsid+'_'+rrid+'_include_exclude').value;
	document.getElementById('include_exclude').disabled = true;

	document.getElementById('left_right').value = document.getElementById(rsid+'_'+rrid+'_left_right').value;

	document.getElementById('prodid').style.height = 21;

	leftRightOnChange();

	var edit_supplier_id = document.getElementById(rsid+'_'+rrid+'_supplier_id').value;
	var edit_supplier_family_id = document.getElementById(rsid+'_'+rrid+'_supplier_family_id').value;
	var edit_catid = document.getElementById(rsid+'_'+rrid+'_catid').value;
	var edit_feature_id = document.getElementById(rsid+'_'+rrid+'_feature_id').value;
	var edit_feature_value = document.getElementById(rsid+'_'+rrid+'_feature_value').value;
	var edit_exact_value = document.getElementById(rsid+'_'+rrid+'_exact_value').value;
	var edit_prod_id = document.getElementById(rsid+'_'+rrid+'_prod_id').value;
	var edit_start_date = document.getElementById(rsid+'_'+rrid+'_start_date').value;
	var edit_end_date = document.getElementById(rsid+'_'+rrid+'_end_date').value;

	document.getElementById('supplier').disabled = true;
	get_supplier_set_call(session_id, edit_supplier_id);

	document.getElementById('supplierfamily').disabled = true;
	get_supplier_family_set_call(session_id, edit_supplier_id, edit_catid, edit_supplier_family_id);
		
	document.getElementById('category').disabled = true;
	get_category_set_call(session_id, edit_catid);
		
	document.getElementById('feature').disabled = true;
	if (edit_catid > 0) \{
		document.getElementById('featurevalue').disabled = false;
		document.getElementById('featurevalue').value = edit_feature_value;
		document.getElementById('exact_value').value = edit_exact_value;
		document.getElementById('exact_value').disabled = false;
		get_feature_set_call(session_id, edit_feature_id);
	\}
	else \{
		document.getElementById(rsid+'_'+rrid+'_feature_id').value = 0;
		edit_feature_id = 0;
		document.getElementById('featurevalue').disabled = true;
		document.getElementById('exact_value').disabled = true;
	\}

	document.getElementById('prodid').value = edit_prod_id;
	document.getElementById('start_date').value = edit_start_date;
	document.getElementById('end_date').value = edit_end_date;

// if prod_id != '' - all other values are useless

	document.getElementById('amount').innerHTML = document.getElementById(rsid+'_'+rrid+'_products_amount').value;
\}


function enableSetDeleting(rsid, rrid) \{
	document.getElementById('relation_set_id').value = rsid;
	document.getElementById('relation_rule_id').value = rrid;
	document.getElementById('action').value = 'del';

	document.getElementById('include_exclude').value = document.getElementById(rsid+'_'+rrid+'_include_exclude').value;
	document.getElementById('include_exclude').disabled = false;

	document.getElementById('left_right').value = document.getElementById(rsid+'_'+rrid+'_left_right').value;

	document.getElementById('relation_rule_manage_form').submit();
\}


// onChange/onKeyUp/other events

function categoryOnChange (session_id) \{
	document.getElementById('supplier').disabled = true;
	get_supplier_edit_call(session_id);
	document.getElementById('supplierfamily').disabled = true;
	get_supplier_family_edit_call(session_id);
	document.getElementById('feature').disabled = true;
	get_feature_edit_call(session_id);
	calculateAmount(session_id);
\}

function supplierOnChange (session_id) \{
	document.getElementById('category').disabled = true;
	get_category_edit_call(session_id);
	document.getElementById('supplierfamily').disabled = true;
	get_supplier_family_edit_call(session_id);
	calculateAmount(session_id);
\}

function supplierFamilyOnChange (session_id) \{
	document.getElementById('category').disabled = true;
	get_category_edit_call(session_id);
	calculateAmount(session_id);
\}

function featureOnChange (session_id) \{
	if (document.getElementById('feature').value > 0) \{
		document.getElementById('featurevalue').disabled = false;
		document.getElementById('exact_value').disabled = false;
	\}
	else \{
		document.getElementById('featurevalue').disabled = true;
		document.getElementById('exact_value').disabled = true;
	\}
	calculateAmount(session_id);
\}

function featureValueOnChange (session_id) \{
	calculateAmount(session_id);
\}

function exactMatchOnChange (session_id) \{
	calculateAmount(session_id);
\}

function leftRightOnChange () \{
	if (document.getElementById('left_right').value == 1) \{ // source
		document.getElementById('source_span').style.display = 'inline';
		document.getElementById('destination_span').style.display = 'none';

		// document.getElementById('supplier_edit').style.display = 'none';
		document.getElementById('supplier_family_edit').style.display = 'none';
		document.getElementById('category_edit').style.display = 'none';
		document.getElementById('feature_edit').style.display = 'none';
		document.getElementById('feature_value_edit').style.display = 'none';
		document.getElementById('exact_value_edit').style.display = 'none';

		document.getElementById('start_date_edit').style.display = 'none';
		document.getElementById('end_date_edit').style.display = 'none';
	\}
	else \{ // destination
		document.getElementById('source_span').style.display = 'none';
		document.getElementById('destination_span').style.display = 'inline';

		// document.getElementById('supplier_edit').style.display = 'inline';
		document.getElementById('supplier_family_edit').style.display = 'inline';
		document.getElementById('category_edit').style.display = 'inline';
		document.getElementById('feature_edit').style.display = 'inline';
		document.getElementById('feature_value_edit').style.display = 'inline';
		document.getElementById('exact_value_edit').style.display = 'inline';

		document.getElementById('start_date_edit').style.display = 'inline';
		document.getElementById('end_date_edit').style.display = 'inline';
	\}
\}

function prodIdOnChange(session_id) \{
	document.getElementById('supplier').value = 0;
	document.getElementById('supplier').disabled = true;
	get_supplier_edit_call(session_id);
	calculateAmount(session_id);
\}

function dateOnKeyUp(session_id) \{
	calculateAmount(session_id);
\}





// AJAX calls

function get_supplier_edit_call (session_id) \{
	call('get_supplier_edit',
			 'tag_id=supplier_edit' +
			 ';catid=' + document.getElementById('category').value +
			 ';supplier_id=' + document.getElementById('supplier').value +
			 ';prod_id=' + encodeURIComponent(document.getElementById('prodid').value) +
			 ';new_id=supplier' +
			 ';JSEvents=onChange=javascript\:supplierOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_supplier_choose_ajax.html');
\}

function get_supplier_set_call (session_id, new_id) \{
	call('get_supplier_edit',
			 'tag_id=supplier_edit' +
			 ';supplier_id=' + new_id +
			 ';new_id=supplier' +
			 ';JSEvents=onChange=javascript\:supplierOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_supplier_choose_ajax.html');
\}

function get_supplier_family_edit_call (session_id) \{
	call('get_supplier_family_edit',
			 'tag_id=supplier_family_edit' +
			 ';supplier_id=' + document.getElementById('supplier').value +
			 ';catid=' + document.getElementById('category').value +
			 ';new_id=supplierfamily' +
			 ';JSEvents=onChange=javascript\:supplierFamilyOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_supplier_family_choose_ajax.html');
\}

function get_supplier_family_set_call (session_id, supplier_id, catid, supplier_family_id) \{
	call('get_supplier_family_edit',
			 'tag_id=supplier_family_edit' +
			 ';supplier_id=' + supplier_id +
			 ';catid=' + catid +
			 ';supplier_family_id=' + supplier_family_id +
			 ';new_id=supplierfamily' +
			 ';JSEvents=onChange=javascript\:supplierFamilyOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_supplier_family_choose_ajax.html');
\}

function get_category_edit_call (session_id) \{
	call('get_category_edit',
			 'tag_id=category_edit' +
			 ';supplier_id=' + document.getElementById('supplier').value +
			 ';supplier_family_id=' + document.getElementById('supplierfamily').value +
			 ';catid=' + document.getElementById('category').value +
			 ';new_id=category' +
			 ';JSEvents=onChange=javascript\:categoryOnChange("' + session_id + '")',
			 'sessid=' + session_id + ';tmpl=product_category_choose_as_list_ajax.html');
\}

function get_category_set_call (session_id, new_id) \{
	call('get_category_edit',
			 'tag_id=category_edit' +
			 ';catid=' + new_id +
			 ';new_id=category' +
			 ';JSEvents=onChange=javascript\:categoryOnChange("' + session_id + '")',
			 'sessid=' + session_id + ';tmpl=product_category_choose_as_list_ajax.html');
\}

function get_feature_edit_call (session_id) \{
	call('get_feature_edit',
			 'tag_id=feature_edit' +
			 ';catid=' + document.getElementById('category').value +
			 ';feature_id=' + document.getElementById('feature').value +
			 ';new_id=feature' +
			 ';JSEvents=onChange=javascript\:featureOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_feature_choose_ajax.html');
\}

function get_feature_set_call (session_id, new_id) \{
	call('get_feature_edit',
			 'tag_id=feature_edit' +
			 ';feature_id=' + new_id +
			 ';new_id=feature' +
			 ';JSEvents=onChange=javascript\:featureOnChange("' + session_id + '")',
			 'sessid=' + session_id + '\;tmpl=product_feature_choose_ajax.html');
\}

function setWait (id) \{
	document.getElementById(id).innerHTML = '<span style="color: #AAAAAA;">loading...</span>';
\}

function calculateAmount (session_id) \{
	setWait('amount');
	call('get_amount',
			 'tag_id=amount' +
			 ';supplier_id=' + document.getElementById('supplier').value +
			 ';supplier_family_id=' + document.getElementById('supplierfamily').value +
			 ';catid=' + document.getElementById('category').value +
			 ';feature_id=' + document.getElementById('feature').value +
			 ';feature_value=' + encodeURIComponent(document.getElementById('featurevalue').value) +
			 ';exact_value=' + document.getElementById('exact_value').value +
			 ';prod_id=' + encodeURIComponent(document.getElementById('prodid').value)+
			 ';start_date=' + encodeURIComponent(document.getElementById('start_date').value)+
			 ';end_date=' + encodeURIComponent(document.getElementById('end_date').value),
			 'sessid=' + session_id + ';tmpl=calculate_amount_ajax.html');
\}


// obsolete

function enableAdding (session_id) \{ // obsolete
	document.getElementById('relation_id').value = 0;
	document.getElementById('action').value = 'add';

	document.getElementById('relation_rule_add_button').style.display = 'none';
	document.getElementById('relation_rule_manage_div').style.display = 'block';

	defaultPart(session_id);
	
	document.getElementById('edit_relation_span').style.display = 'none';
	document.getElementById('add_relation_span').style.display = 'block';
\}


function enableEditing(rid, session_id) \{ // obsolete
	document.getElementById('relation_rule_add_button').style.display = 'block';

	document.getElementById('add_relation_span').style.display = 'none';
	document.getElementById('edit_relation_span').style.display = 'block';

	document.getElementById('relation_rule_manage_div').style.display = 'block';

	document.getElementById('relation_id').value = rid;
	document.getElementById('action').value = 'edit';
	document.getElementById('exact_value').value = 0;

	var edit_supplier_id = document.getElementById(rid+'_supplier_id').value;
	var edit_supplier_family_id = document.getElementById(rid+'_supplier_family_id').value;
	var edit_catid = document.getElementById(rid+'_catid').value;
	var edit_feature_id = document.getElementById(rid+'_feature_id').value;
	var edit_feature_value = document.getElementById(rid+'_feature_value').value;
	var edit_exact_value = document.getElementById(rid+'_exact_value').value;
	var edit_prod_id = document.getElementById(rid+'_prod_id').value;

	document.getElementById('supplier').disabled = true;
	get_supplier_set_call(session_id, edit_supplier_id);

	document.getElementById('supplierfamily').disabled = true;
	get_supplier_family_set_call(session_id, edit_supplier_id, edit_catid, edit_supplier_family_id);
		
	document.getElementById('category').disabled = true;
	get_category_set_call(session_id, edit_catid);
		
	document.getElementById('exact_value').value = document.getElementById(rid+'_exact_value');

	document.getElementById('feature').disabled = true;
	if (edit_catid > 0) \{
		document.getElementById('featurevalue').disabled = false;
		document.getElementById('featurevalue').value = edit_feature_value;
		get_feature_set_call(session_id, edit_feature_id);
	\}
	else \{
		document.getElementById(rid+'_feature_id').value = 0;
		edit_feature_id = 0;
		document.getElementById('featurevalue').disabled = true;
		document.getElementById('exact_value').disabled = true;
	\}

	document.getElementById('prodid').value = edit_prod_id;

// if prod_id != '' - all other values are useless

	document.getElementById('amount').innerHTML = document.getElementById(rid+'_products_amount').value;
\}


function enableDeleting(rid) \{ // obsolete
	document.getElementById('relation_id').value = rid;
	document.getElementById('action').value = 'del';
	document.getElementById('relation_rule_manage_form').submit();
\}


// -->
</script>

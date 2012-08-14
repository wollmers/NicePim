
function get_series_do_next_request(family_id) {

	try {
		var supplier_id = document.getElementsByName('supplier_id')[0].value;
	} catch (e) {
		return;
	}

	try {
		var category_id = document.getElementById('catid').value;
	} catch (e) {
		return;
	}

	if (category_id == 0) return;

	session_id = document.getElementsByName('sessid')[0].value;

	// create AJAX request
	var tmp1_local = 'tag_id=series_id;supplier_id=' + supplier_id + ';foo=bar;field_name=series_id;category_id=' + category_id + ';family_id=' + family_id;
	var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_get_product_series.html';

	call('get_product_series', tmp1_local, tmp2_local);

}

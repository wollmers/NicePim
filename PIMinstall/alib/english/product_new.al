{
name: product_new;

publish_Y: Yes;
publish_N: No;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

supplier_ajax_link: 
	<div id="supplier_edit" style="display: inline; width: 200px;">
		<a class="divajax" onClick="call('get_supplier_edit','tag_id=supplier_edit;foo=bar','sessid=%%sessid%%;tmpl=product_supplier_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;supplier_id=%%supplier_id%%');">%%supplier_name%%</a>
		<input type="hidden" name="supplier_id" value="%%supplier_id%%">
	</div>

category_ajax_link:
	<div id="category_edit" style="display: inline; width: 200px;">
		<a class="divajax" onClick="call('get_category_edit','tag_id=category_edit;foo=bar','sessid=%%sessid%%;tmpl=product_category_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;catid=%%catid%%');">%%category_name%%</a>
		<input type="hidden" name="catid" value="%%catid%%">
	</div>

$$INCLUDE actions2.al$$

body:

 <form method="post" enctype="multipart/form-data">

	<input type="hidden" name="atom_name" value="product">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_new.html">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="track_product_id" value="%%track_product_id%%">
	
	<input type="hidden" name="command" value="insert_tab_name,chown_nobody_products,product_delete_daemon,change_product_category,get_obj_url,update_xml_due_product_update,update_score,add2editors_journal,product2vendor_notification_queue,update_virtual_categories_for_product,update_track_product">
	
$$INCLUDE product_general.al$$

}

{
name: product_related_ajax;
r_supplier_id_new_related_dropdown_empty: Any brand;

reversed_related_row:
<tr>
	<td class="main info_bold">%%rel_prod_id%%</td>
	<td class="main info_bold">%%r_supplier_name%%</td>
	<td class="main info_bold">%%r_name%%</td>
	<td class="main info_bold" align="right">
		<form method="post" style="display: inline;">
			<input type="hidden" name="atom_name" value="product_related">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
			<input type="hidden" name="tmpl" value="product_details.html">
			<input type="hidden" name="product_related_id" value="%%product_related_id%%">
			<input type="hidden" name="product_id" value="%%product_id%%">
			<input type="hidden" name="rel_product_id" value="%%r_product_id%%">
			<input type="hidden" name="command" value="product2vendor_notification_queue,update_xmls_due_product_related_update,add2editors_journal">
			<input type="submit" name="atom_delete" value="Delete">
		</form> 
	</td>
</tr>

related_row:
<tr>
	<td class="main info_bold">%%rel_prod_id%%</td>
	<td class="main info_bold">%%r_supplier_name%%</td>
	<td class="main info_bold">%%r_name%%</td>
	<td class="main info_bold" align="right">
		<form method="post" style="display: inline;">
			<input type="hidden" name="atom_name" value="product_related">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
			<input type="hidden" name="tmpl" value="product_details.html">
			<input type="hidden" name="product_related_id" value="%%product_related_id%%">
			<input type="hidden" name="product_id" value="%%product_id%%">
			<input type="hidden" name="rel_product_id" value="%%r_product_id%%">
			<input type="hidden" name="command" value="product2vendor_notification_queue,update_xmls_due_product_related_update,add2editors_journal">
			<input type="submit" name="atom_delete" value="Delete">
		</form> 
	</td>
</tr>

body:
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="10%">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_product_related_related=rel_prod_id;%%joined_keys%%">Part number</a></th>
								<th class="main info_header" width="10%">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_product_related_related=rel_prod_id;%%joined_keys%%">Brand</a></th>
								<th class="main info_header" width="35%">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_product_related_related=r_name;%%joined_keys%%">Product name</a></th>
								<th class="main info_header" width="10%">Action</th>
							</tr>
							%%related_rows%%
							<tr><td colspan="4"></td></tr>
							%%reversed_related_rows%%
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>
}

{
name: product_group_actions_list;

cat_div: ---;
any_cat: None;

category_list: Change category;
supplier_list: Change brand;
owner_list: Change owner;
family_list: Change family;
publish: Publish;
delete: Delete;

apply_merge_body:
<input type="checkbox" name="apply_merge" value="1">&nbsp;save red products & drop black products<br /><br />

body:
<form name=form2 method=post>

	%%apply_merge_body%%
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">

				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr><th class="main info_header" align=left colspan=3>&nbsp;&nbsp;&nbsp;<b>Group actions</b></th></tr>
								<tr>
									<td class="main info_bold" width=20% align=right>
									<input type='checkbox' name='category_list' value=1 class=smallform></td>
	 								<td class="main info_bold">Change category</td>
	 								<td class="main info_bold">
	 								    %%search_category_list%%
	 								    <div id='vcats_container_tmp_group_action'>
	 								    </div>
	 								</td>
								</tr>
								
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' name='supplier_list' value=1 class=smallform %%supplier_list_checked%%></td>
									<td class="main info_bold">Change brand</td><td class="main info_bold">%%search_supplier_list%%</td>
								</tr>
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' name='owner_list' value=1 class=smallform %%chown_disabled%%></td>
									<td class="main info_bold">Change owner</td><td class="main info_bold">%%search_owner_list%%</td>
								</tr>
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' name='family_list' value=1 class=smallform %%disabled%%></td>
									<td class="main info_bold">Change family</td><td class="main info_bold">%%search_family_list%%</td>
								</tr>
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' name='publish' value=1 class=smallform></td>
									<td class="main info_bold">Publish</td>
									<td class="main info_bold">
										<select name="search_publish">
												<option value="Y">Yes</option>
												<option value="N">No</option>
										</select>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' name='public' value=1 class=smallform></td>
									<td class="main info_bold" >Public</td>
									<td class="main info_bold">
										<select name="search_public">
												<option value="Y">Yes</option>
												<option value="L">Limited</option>
										</select>
									</td>									
								</tr>								
								<tr>
									<td class="main info_bold" width=20% align=right><input type='checkbox' id='_delete' name='delete' value=1></td><td class="main info_bold" colspan=3>Delete</td>
								</tr>
  							<tr>
									<td class="main info_bold" align=right colspan=3><input type=submit name=atom_submit value="Complete action" 
																																					class=smallform onClick="javascript:\{
																																																	 document.form2.product_id_list.value = document.form.product_id_list.value;
																																																	 delete_validation();
																																																	 document.form2.action_group_product.value = 1;
																																																	 \}"></td>
								</tr>
							</table>

						</td>
					</tr>
				</table>

			</td>
		</tr>
	</table>

	<input type=hidden name=atom_name value="product_group_actions_list">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="products.html">
	<input type=hidden name=tmpl value="product_group_actions_edit.html">
	<input type=hidden name=command value=product_group_action>
	<input type=hidden name=product_id_list value=>
	<input type=hidden name=supplier_id value=%%supplier_id%%>
	<input type=hidden name=clipboard_object_type value="product">
	<input type=hidden name=action_group_product value=>
	<input type=hidden name=filter value="%%filter%%">
	<input type=hidden name=list_merges value="%%list_merges%%">
	<input type=hidden name=dst_list_merges value="%%dst_list_merges%%">
	<input type=hidden name=merges value="%%merges%%">
	
	$$INCLUDE cli_actions.al$$
	
</form>

<script type="text/javascript">
    function allow_any_vcat() \{
        ref = document.getElementById('hide_vcats');
        if (ref.style.display == 'none') \{
            ref.style.display = 'block';
        \} 
        else \{
            ref.style.display = 'none';
        \}
        return;
    \}
</script>

}

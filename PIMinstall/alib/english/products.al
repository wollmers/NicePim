{
name: products;

$$INCLUDE clipboard_nav_link.al$$

cutted_format: %%value%%...

group_action_buttons:
<table align="right">
	<tr>
		<td>
			<div align="right">
				<span class="linksubmit"
							onClick="javascript:
											 if(document.getElementById('batch_products4selection').style.display == 'none') \{
											 document.getElementById('batch_products4selection').style.display = '';
											 this.innerHTML = 'hide batch input';
											 \}
											 else \{
											 document.getElementById('batch_products4selection').style.display = 'none';
											 this.innerHTML = 'show batch input';
											 \}">show batch input</span>
				<input style="display: inline; color:grey;" type="submit" name="action_batchselect_product" id="action_batchselect_product" value="Batch select" class="linksubmit" onClick="javascript:\{document.form.tmpl.value = 'products.html';\}" disabled="disabled">&nbsp;&nbsp;&nbsp;
				<input style="display: inline;" type="submit" name="action_selectall_product" value="Select all" class="linksubmit" onClick="javascript:\{document.form.tmpl.value = 'products.html';\}">
				<input style="display: inline;" type="submit" name="action_group_product" value="Do group actions" class="linksubmit" onClick="javascript:\{document.form.tmpl.value = 'product_group_actions_edit.html';\}">
				<input style="display: inline;" type="submit" name="action_clear_product" value="Clear selection" class="linksubmit" onClick="javascript:\{document.form.tmpl.value = 'products.html';\}">
			</div>
		</td>
	</tr>
	<tr>
		<td>
			<div align="left">
				<textarea name="batch_products4selection" id="batch_products4selection" style="display: none; width: 300px; height: 150px;"
									onKeyUp="javascript:
													 if (this.value == '') \{
													 document.getElementById('action_batchselect_product').style.color = 'grey';
													 document.getElementById('action_batchselect_product').disabled = true;											
													 \}
													 else \{
													 document.getElementById('action_batchselect_product').style.color = '';
													 document.getElementById('action_batchselect_product').disabled = false;
													 \}
													 "></textarea>
			</div>
		</td>
	</tr>
</table>

products_row:

<tr>
  <td class="main info_bold" align="center">%%no%%/%%found%%<input type=hidden name="row_%%no%%_item" value="%%product_id%%"></td>
  <td class="main info_bold" width="1%"><input type=%%button_type%% id="row_%%product_id%%" name="row_%%no%%" value="%%product_item_marked%%" %%product_item_marked%%></td>
  <td class="main info_bold" nowrap><a href="%%base_url%%;product_id=%%product_id%%;cproduct_id=%%product_id%%;tmpl=product_details.html">%%prod_id%%</a></td>
  <td class="main info_bold"><div  style="height\: 75%; overflow\: hidden;">%%product_name%%</div></td>
  <td class="main info_bold">&nbsp;%%supp_name%%</td>
  <td class="main info_bold">&nbsp;%%cat_name%%</td>
  <td class="main info_bold" align="center" nowrap>%%date_added%%</td>
  <td class="main info_bold">&nbsp;%%user_name%%</td>
</tr>

body:
<!-- continuing -->

		<td class="search" align="right" style="width:100%;padding-left:10px"><nobr><a href="%%base_url%%;tmpl=product_new.html" class="new-win">New product</a></td>
	</tr>
</table>

<script type="text/javascript">
<!--
	function submitform() \{
		document.form.next.value = 'Next';
		document.form.submit();
	\}
// -->
</script>

</div>
<div class="page_content_wide"> <!-- 100% -->

<form method=post name='form'>

$$INCLUDE nav_bar2_memorize.al$$

<input type=hidden name=tmpl value="products.html">
<input type=hidden name=atom_name value="products">
<input type=hidden name=sessid value="%%sessid%%">
<input type=hidden name=clipboard_object_type value="product">
<input type=hidden name=last_row value="%%last_row%%">
<input type=hidden name=search_clause value="%%search_clause%%">
<input type=hidden name=filter value="%%filter%%">
<input type="hidden" name="%%atom_name%%_start_row" id="clipboard_nav_link_start_row" class="linksubmit" value=""/>
%%hidden_joined_keys%%

<div id="clipboard_info" style="color: green;"></div>
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="5%">#/##</th>
								<th class="main info_header" width="16%" colspan="2"><a href="%%base_url%%;tmpl=%%tmpl%%;order_products_products=prod_id%%filter_key%%">Part code</a></th>
								<th class="main info_header" width="35%">Name</th>
								<th class="main info_header" width="12%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_products_products=supp_name%%filter_key%%">Brand</a></th>
								<th class="main info_header" width="18%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_products_products=cat_name%%filter_key%%">Category</a></th>
								<th class="main info_header" width="7%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_products_products=date_added%%filter_key%%">Date added</a></th>
								<th class="main info_header" width="7%" class="last"><a href="%%base_url%%;tmpl=%%tmpl%%;order_products_products=user_name%%filter_key%%">Owner</a></th>
							</tr>
							
							%%products_rows%%
							
						</table>

					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2_memorize.al$$

$$INCLUDE cli_actions.al$$

%%group_action_buttons%%

</form>

</div>

<div class="page_content">
}

{
name: products;
class: hidden;

products_row: &nbsp;

body:

&nbsp;
}


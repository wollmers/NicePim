{
name: product_map;


delete_action: <input type="submit" name="atom_delete" value="Delete" onClick="if(!confirm('Are you sure?')) return false;">

update_action: <input type="submit" name="atom_update" value="Apply rule and drop black products">
insert_action: <input type="submit" name="atom_submit" value="Apply rule and drop black products">

supplier_id_dropdown_empty: Any brand;
dest_supplier_id_dropdown_empty: Do not change;

statistics:
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="info_header" colspan="6" align="center">%%action%%</th>
							</tr>
							<tr>
								<th class="info_header">Brand name</th>
								<th class="info_header">Modified brand name</th>
								<th class="info_header">Original product code</th>
								<th class="info_header">Modified product code</th>
								<th class="info_header">User</th>
								<th class="info_header">User group</th>
							</tr>
							%%statistics%%
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

stat_row:
<tr>
	<td class="main info_bold" style="padding: 0px;" align="center">%%supplier_name%%</td>
	<td class="main info_bold" style="padding: 0px;" align="center">%%m_supplier_name%%</td>
	<td class="main info_bold" style="padding: 0px;" align="center">%%old_prod_id%%</td>
	<td class="main info_bold" style="padding: 0px;" align="center">%%m_prod_id%%</td>
	<td class="main info_bold" style="padding: 0px;" align="center">%%login%%</td>
	<td class="main info_bold" style="padding: 0px;" align="center">%%user_group%%</td>
</tr>

preview_row:
<tr>
  <td class="main info_bold" style="padding: 0px;">%%supplier_name%%</td>
  <td class="main info_bold" style="padding: 0px;">%%m_supplier_name%%</td>
	<td class="main info_bold" style="padding: 0px;">%%old_prod_id%%</td>
	<td class="main info_bold" style="padding: 0px;">%%m_prod_id%%</td>
	<td class="main info_bold" style="padding: 0px;">%%login%%</td>
	<td class="main info_bold" style="padding: 0px;">%%user_group%%</td>
</tr>

preview_row_best:
<tr>
  <td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%supplier_name%%</span></td>
  <td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%m_supplier_name%%</span></td>
  <td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%old_prod_id%%</span></td>
	<td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%m_prod_id%%</span></td>
	<td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%login%%</span></td>
	<td class="main info_bold" style="padding: 0px;"><span style="color: red;">%%user_group%%</span></td>	
</tr>

preview_body: 
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" colspan="6">Mapping rule preview</th>
							</tr>
							<tr>
								<th class="main info_header">Original Brand</th>
								<th class="main info_header">Modified brand</th>
								<th class="main info_header">Original product code</th>
								<th class="main info_header">Modified product code</th>
								<th class="main info_header">User</th>
								<th class="main info_header">User group</th>
							</tr>

							%%preview_rows%%

							<tr>
								<td colspan="6" align="center">
									<table><tr><td>%%update_action%%<td>%%insert_action%%</table>
								</td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

preview_separator: <tr><td colspan="6" style="padding: 0px; height: 2px;"></td></tr>

body:
<form method="post">	
	<input type="hidden" name="atom_name" value="product_map">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_maps.html">
	<input type="hidden" name="tmpl" value="product_map.html">
	<input type="hidden" name="product_map_id" value="%%product_map_id%%">
	<input type="hidden" name="command" value="preview_apply_pattern">

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center" style="display: %%visible%%">
								<tr>
									<th class="main info_header" colspan="2">Mapping rule</th>
								</tr>
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Rule name~</td>
									<td class="main info_bold">
										<input type="text" name="code" value="%%code%%">
									</td>
								</tr>	
								<tr>
									<td class="main info_bold" valign="top"><span style="color: red;">*</span>~Patterns~</td>
									<td class="main info_bold" valign="top">
										<textarea name="pattern" style="width: 650px; height: 250px;">%%pattern%%</textarea><br /><input type="submit" name="reload" value="Preview">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">~Original brand~</td>
									<td class="main info_bold">%%supplier_id%%
									</td>
								</tr>
								<tr>
	 								<td class="main info_bold">~Destination brand~</td>
									<td class="main info_bold">%%dest_supplier_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" colspan="2" align="center">
										%%delete_action%%
									</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>

	<br />
	
	%%preview_body%%

</form>

}

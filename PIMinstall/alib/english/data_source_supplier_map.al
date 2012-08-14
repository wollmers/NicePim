{
name: data_source_supplier_map;

distributor_id_dropdown_empty: Any distributor;

$$INCLUDE actions2.al$$

cat_div: ---;
any_cat: None;

$$INCLUDE foreign_distributors.al$$

body:

<script type="text/javascript">
<!--
	function show_add_new_supplier() \{
	var supplier_id = document.getElementById("supplier_id");
	var is_new_supplier = document.getElementById("is_new_supplier");
	var new_supplier_name = document.getElementById("new_supplier_name");
		if (supplier_id.value == "") \{
			is_new_supplier.disabled = 0;
			new_supplier_name.disabled = 0;
		\}
	else \{
			is_new_supplier.disabled = 1;
			new_supplier_name.disabled = 1;
	\}
	\}
//-->
</script>

<form method="post">
	
	<input type="hidden" name="atom_name" value="data_source_supplier_map">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="data_source_supplier_maps.html">
	<input type="hidden" name="tmpl" value="data_source_supplier_map.html">
	<input type="hidden" name="data_source_supplier_map_id" value="%%data_source_supplier_map_id%%">
	<input type="hidden" name="precommand" value="add_new_supplier">
	<input type="hidden" name="command" value="merge_symbol">
	<!-- ~Data source~ --> <input type="hidden" name="data_source_id" value="%%data_source_id%%">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Foreign symbol~</td>
									<td class="main info_bold" colspan="2">
										<input type="text" size="80" name="symbol" value="%%symbol%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">~Distributor~</td>
									<td class="main info_bold" colspan="2">
										%%distributor_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Native brand~</td>
									<td class="main info_bold" width="1%"><table><tr><td>%%supplier_id%%<td><input type="submit" name="reload" value="Reload"></table>
									</td>
									<td class="main info_bold" align="left">
										<table><tr><td><input id="is_new_supplier" type="checkbox" name="is_new_supplier" value="1"><td>~new brand~<td>
										<input id="new_supplier_name" type="text" size="25" name="new_supplier_name" value=""></table>
									</td>
								</tr>
								
								%%matched_symbols%%
								
								<tr>
									<td class="main info_bold" colspan="3" align="center">
										<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
									</td>
								</tr>
								
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>
}

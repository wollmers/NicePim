{
name: data_source_category_map;

distributor_id_dropdown_empty: Any distributor;

preview_row:
<tr>
	<td>%%value%%</td>	
</tr>

preview_body: 
<h2>Mapping category rule preview</h2>
<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td width="7%" bgcolor="#99CCFF">
			<font face="Verdana" size="2" color="#FFFFFF">Matched symbols</font>
		</td>
	</tr>
	%%preview_rows%%
</table>

$$INCLUDE actions2.al$$

cat_div: ---;
any_cat: None;

$$INCLUDE foreign_distributors.al$$

body:

<form method="post">
	
	<input type="hidden" name="atom_name" value="data_source_category_map">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="data_source_category_maps.html">
	<input type="hidden" name="tmpl" value="data_source_category_map.html">
	<input type="hidden" name="command" value="merge_symbol">
	<input type="hidden" name="data_source_category_map_id" value="%%data_source_category_map_id%%">
	<!-- ~Data source~ --> <input type="hidden" name="data_source_id" value="%%data_source_id%%">
	
  <table width="100%">
		
		<tr>
			<td class="main info_bold"><span style="color: red;">*</span>~Foreign symbol~</td>
			<td class="main info_bold">
				<input type="text" size="80" name="symbol" value="%%symbol%%">
			</td>
		</tr>
		<tr>
			<td class="main info_bold">~Distributor~</td>
			<td class="main info_bold">%%distributor_id%%
	 </td>
		</tr>
		<tr>
			<td class="main info_bold"><span style="color: red;">*</span>~Native category~</td>
			<td class="main info_bold">%%catid%%&nbsp;
			</td>
		</tr>
		
		%%matched_symbols%%
		
		<tr>
			<td class="main info_bold" colspan="2" align="center">
				<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
			</td>
		</tr>
		
	</table>
	
</form>
}

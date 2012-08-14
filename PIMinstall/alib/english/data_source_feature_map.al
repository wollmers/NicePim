{
name: data_source_feature_map;

$$INCLUDE actions2.al$$

cat_div: ---;
any_cat: Any category;

feature_info_row:<tr>
					<td class="main info_bold">~Values example<br/>language: %%lang_code%%~</td>
						<td class="main info_bold">
							<textarea cols="30" rows="5" readonly="readonly" value="" style="" wrap="off">%%example_values%%</textarea>
							Measure sign: <textarea cols="10" rows="5" name="measure_sign_%%data_source_feature_map_info_id%%" value="">%%measure_signs%%</textarea>  
						</td>
									
					</tr>

body:

<script type="text/javascript">
<!--
	function switch_features() \{
		if (document.getElementById('is_new_feature').checked) \{
			document.getElementById('new_feature_area').style.display='block';
			document.getElementById('feature_id').disabled = true;
		\}
		else \{
			document.getElementById('new_feature_area').style.display='none';
			document.getElementById('feature_id').disabled = false;
		\}
	\}
//-->
</script>

<form method="post">

	<input type="hidden" name="atom_name" value="data_source_feature_map">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="data_source_feature_maps.html">
	<input type="hidden" name="tmpl" value="data_source_feature_map.html">
	<input type="hidden" name="data_source_feature_map_id" value="%%data_source_feature_map_id%%">
	<input type="hidden" name="precommand" value="add_new_feature,update_ds_measure_sign">
	<!-- ~Data source~ --> <input type="hidden" name="data_source_id" value="%%data_source_id%%">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Foreign symbol~</td>
									<td class="main info_bold">
										<input type="text" size="80" name="symbol" value="%%symbol%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Native feature~</td>
									<td class="main info_bold">%%feature_id%%&nbsp;<input type="checkbox" name="is_new_feature" id="is_new_feature" onClick="javascript:switch_features();" value="1">&nbsp;new feature<br>
										
										<div style="display: none;" id="new_feature_area">
											<table class="invisible">
												<tr>
													<td>
														<span style="color: red;">*</span>~Feature name~</td>
													<td><input type="text" name="feature_name" value="%%strip_feature_name%%" size="60"></td></tr>
												<tr><td><span style="color: red;">*</span>~Measure~</td>
													<td>%%measure_id%%</td></tr>
												<tr><td>~updating from~</td>
													<td>%%data_source_id_select%%</td></tr>
											</table>
										</div>
										
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Category~</td>
									<td class="main info_bold"><table><tr><td>%%catid%%<td></table>
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Correction coefficient~</td>
									<td class="main info_bold"><input type="text" name="coef" value="%%coef%%">
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Number of digits after '.'~</td>
									<td class="main info_bold"><input type="text" name="format" value="%%format%%">
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Override feature value to~</td>
									<td class="main info_bold"><input type="text" name="override_value_to" value="%%override_value_to%%" size="80">
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Give only 'product' values (for HP Provisioner)~</td>
									<td class="main info_bold">%%only_product_values%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Used </td>
									<td class="main info_bold"><b>%%used_in%%</b> times
									</td>
								</tr>
															
								<td class="main info_bold" colspan="2" align="center">
									<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
								</td>
								%%feature_info_rows%%
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

{
name: feature_value_mapping;

$$INCLUDE actions2.al$$

cat_div: ---;
any_cat: Any category;


body:

<form method="post">
	
	<input type="hidden" name="atom_name" value="feature_value_mapping">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="feature_id" value="%%feature_id%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="feature_value_mappings.html">
	<input type="hidden" name="tmpl" value="feature_value_mapping.html">
	<input type="hidden" name="feature_value_mapping_id" value="%%feature_value_mapping_id%%">
	
	<table align="center" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Feature~</td>
									<td class="main info_bold">%%feat_name%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Foreign value~</td>
									<td class="main info_bold">
										<textarea name="ext_value" cols="40" rows="5">%%ext_value%%</textarea>
									</td>
								</tr>

								<tr>
									<td class="main info_bold">~Native value~</td>
									<td class="main info_bold">%%int_value%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan="2" align="center">
										%%update_action%% %%delete_action%%	%%insert_action%%
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

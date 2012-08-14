{
name: product_feature;

$$INCLUDE actions2.al$$
$$INCLUDE feature_def.al$$

body:

<form method="post">
	
	<input type="hidden" name="atom_name" value="product_feature">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_feature.html">
	<input type="hidden" name="product_feature_id" value="%%product_feature_id%%">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="command" value="update_xml_due_product_update">
	<input type="hidden" name="command" value="update_score,add2editors_journal">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Feature~</td>
									<td class="main info_bold">%%category_feature_id%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Value~</td>
									<td class="main info_bold">
										%%value%%
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan="2" align="center">
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

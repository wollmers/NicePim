{
name: feature_input_type;

$$INCLUDE actions2.al$$

body:
<br />
<br />

<form method="post">
	
  <input type="hidden" name="atom_name" value="feature_input_type">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl_if_success_cmd" value="feature_input_types.html">
  <input type="hidden" name="tmpl" value="feature_input_type.html">
  <input type="hidden" name="feature_input_type_id" value="%%feature_input_type_id%%">
	
	<table align="center" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tbody>
									<tr>
										<td class="main info_bold"><span style="color: red;">*</span>Name</td><td class="main info_bold"><input type="text" name="name" value="%%name%%"></td>
									</tr>
									<tr>
										<td class="main info_bold"><span style="color: red;">*</span>Type</td><td class="main info_bold"><input type="text" name="type" value="%%type%%"></td>
									</tr>
									<tr>
										<td class="main info_bold">Pattern</td><td class="main info_bold"><input type="text" name="pattern" value="%%pattern%%"></td>
									</tr>
									<tr>
										<td class="main info_bold" colspan="2" align="center">
											<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
										</td>
									</tr>
								</tbody>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>

<br />
}

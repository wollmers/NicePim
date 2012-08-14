{
name: feature_values_group;

$$INCLUDE actions2.al$$

body:

<form method="post">
	<input type="hidden" name="atom_name" value="feature_values_group">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="feature_values_groups.html">
	<input type="hidden" name="tmpl" value="feature_values_group.html">
	<input type="hidden" name="feature_values_group_id" value="%%feature_values_group_id%%">
	<input type="hidden" name="command" value="feature_values_group_delete_daemon">
	
	<table align="center" width="60%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" width="30%" align="right">Name</td>
									<td class="main info_bold"><input type="text" size="40" name="name" value="%%name%%"></td>
									<td class="main info_bold" colspan="2" align="center"><table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
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

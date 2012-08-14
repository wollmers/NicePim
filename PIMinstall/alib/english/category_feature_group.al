{
name: category_feature_group;

$$INCLUDE actions2.al$$


body:

<form method=post>
	
	<input type=hidden name=atom_name value="category_feature_group">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="cat_feature_groups.html">
	<input type=hidden name=tmpl value="cat_feature_group.html">
	<input type=hidden name=category_feature_group_id value="%%category_feature_group_id%%">
	<!-- ~Category~ -->	<input type=hidden name=catid value="%%catid%%">
	
	<table align="center" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">~Group~</td>
									<td class="main info_bold">%%group_name%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Order number~</td>
									<td class="main info_bold"><input type=text size=3 name=nom value="%%nom%%"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan=2 align=center>
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

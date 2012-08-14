{
name: category_feature;

$$INCLUDE actions2.al$$

searchable_0: No
searchable_1: Yes

mandatory_0: No
mandatory_1: Yes

option_N: No
option_Y: Yes

body:

<form method=post>
	
	<input type=hidden name=atom_name value="category_feature">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="cat_features.html">
	<input type=hidden name=tmpl value="cat_feature.html">
	<input type=hidden name=category_feature_id value="%%category_feature_id%%">
	<!-- ~Category~ -->	<input type=hidden name=catid value="%%catid%%">
	
	<table align="center" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" align=right>~Feature~</td>
									<td class="main info_bold">%%feature_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Searchable~</td>
									<td class="main info_bold">%%searchable%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Mandatory~</td>
									<td class="main info_bold">%%mandatory%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span style="color: red;">*</span>~Group~</td>
									<td class="main info_bold">%%feature_group_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Order number~</td>
									<td class="main info_bold"><input type=text size=3 name=no value="%%no%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Search list as input dropdown~</td>
									<td class="main info_bold">%%use_dropdown_input%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Search list restriction~</td>
									<td class="main info_bold"><textarea name=restricted_search_values rows=7 cols=60>%%restricted_search_values%%</textarea></td>
								</tr>
								<tr>
									<td class="main info_bold">&nbsp;</td>
									<td class="main info_bold">%%autoinsert%% auto-insert search list values into feature values vocabulary</td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan=2 align=center>
										%%update_action%% %%delete_action%% %%insert_action%%
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

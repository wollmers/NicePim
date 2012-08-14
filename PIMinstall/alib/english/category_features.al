{
name: category_features;

$$INCLUDE nav_inc.al$$

features_row: 
<tr>
	
	<input type=hidden name="row_%%no%%_item" value="%%category_feature_id%%">
	
	<td class="main info_bold">%%no%%/%%found%%</td>
	<td class="main info_bold" width="2%"><input type="checkbox" name="row_%%no%%" value="1" %%category_feature_item_marked%%></td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=cat_feature.html;category_feature_id=%%category_feature_id%%;catid=%%catid%%">%%name%%</a></td>
  <td class="main info_bold">%%group_name%%</td>
  <td class="main info_bold" align=center>&nbsp;%%sign%%</td>
	<td class="main info_bold">&nbsp;%%nom%%</td>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=interval_search.html;catid=%%catid%%;category_feature_id=%%category_feature_id%%">%%search_link%%</a></td>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=feature.html;feature_id=%%feature_id%%;mi=features;tmpl_if_success_cmd=cat_features.html;catid=%%catid%%">Origin</a></td>
</tr>

body:

<form method=post>      

	$$INCLUDE nav_bar2_memorize.al$$

	<input type=hidden name=tmpl value="cat_features.html">
	<input type=hidden name=atom_name value="%%atom_name%%">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=clipboard_object_type value="category_feature">
	<input type=hidden name=last_row value="%%last_row%%">
	
	%%hidden_joined_keys%%
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th width="5%" class="main info_header">#/##</th>
									<th width="40%" class="main info_header" colspan=2>
										<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_features_features=name;%%joined_keys%%">Feature</a></th>
									<th width="25%" class="main info_header">
										<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_features_features=group_name;%%joined_keys%%">Group</a></th>
									<th width="10%" class="main info_header">
										<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_features_features=sign;%%joined_keys%%">Unit</a></th>
									<th width="10%" class="main info_header">
										<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_features_features=nom;%%joined_keys%%">Order&nbsp;number</a></th>
									<th width="5%" class="main info_header">Search intervals</th>
									<th width="5%" class="main info_header">Action</th>
								</tr>
								
								%%features_rows%%
								
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>

	$$INCLUDE nav_bar2_memorize.al$$

	$$INCLUDE cli_actions.al$$

	<br />

	<table width="100%"><tr><td align="right"><input type=submit name="action_group_category_feature" value="Group selected items">
	<input type=submit name="action_clear_category_feature" value="Clear selection"></table>

</form>
}

{
name: category_features;
class: hidden;

features_row:   

body:

}

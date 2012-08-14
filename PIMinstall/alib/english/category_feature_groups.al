{
name: category_feature_groups;

$$INCLUDE nav_inc.al$$

groups_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold">
		<a href="%%base_url%%;tmpl=cat_feature_group.html;category_feature_group_id=%%category_feature_group_id%%;catid=%%catid%%">%%group_name%%</a></td>
	<td class="main info_bold" align=center>%%nom%%</td>
</tr>


body:

$$INCLUDE nav_bar2.al$$

<input type=hidden name=tmpl value="cat_feature_groups.html">
<input type=hidden name=atom_name value="%%atom_name%%">
<input type=hidden name=sessid value="%%sessid%%">

<table align="center" width="75%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th width="10%" class="main info_header">#/##</th>
								<th width="80%" class="main info_header">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_feature_groups_groups=group_name;%%joined_keys%%">Feature group</a></th>
								<th width="10%" class="main info_header">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_category_feature_groups_groups=nom;%%joined_keys%%">Order&nbsp;number</a></th>
							</tr>
							
							%%groups_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

{
name: category_feature_groups;
class: hidden;

groups_row:   

body:


}


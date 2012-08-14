{
name: feature_groups;

$$INCLUDE nav_inc.al$$

groups_row: 
<tr>
	<td class="main info_bold" width="15%">&nbsp;%%no%%/%%found%%</td>
  <td class="main info_bold" width="85%">&nbsp;<a href="%%base_url%%;tmpl=feature_group.html;feature_group_id=%%feature_group_id%%">%%name%%</a></td>
</tr>
body:
			
$$INCLUDE nav_bar2.al$$
      
<table align="center" width="60%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header"># / ##</th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_feature_groups_groups=name">Feature group</a></th>
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

{
name: feature_value_mappings;

$$INCLUDE nav_inc.al$$

feature_value_mappings_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=feature_value_mapping.html;feature_value_mapping_id=%%feature_value_mapping_id%%;feature_id=%%feature_id%%">%%ext_value%%</a></td>
	<td class="main info_bold">%%int_value%%</td>
</tr>


body:

$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header"><a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_feature_value_mappings_feature_value_mappings=ext_value">Foreign symbol</a></th>
								<th class="main info_header"><a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_feature_value_mappings_feature_value_mappings=int_value">Native symbol</a></th>
							</tr>
							
							%%feature_value_mappings_rows%%
							
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
name: feature_value_mappings;

class: hidden;

feature_value_mappings_row: 

body:

}

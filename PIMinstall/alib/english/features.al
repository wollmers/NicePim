{
name: features;


values: <a href="%%base_url%%;tmpl=feature_values.html;feature_id=%%feature_id%%;">Values</a>;
values_mappings: <a href="%%base_url%%;tmpl=feature_value_mappings.html;feature_id=%%feature_id%%;">Values mappings</a>;
products_categories: <a href="%%base_url%%;tmpl=feature_utilizing_products_categories.html;feature_id=%%feature_id%%;">Products/Categories</a>;

$$INCLUDE nav_inc.al$$

features_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=feature.html;feature_id=%%feature_id%%;tmpl_if_success_cmd=features.html">%%name%%</a></td>
  <td class="main info_bold">%%sign%%&nbsp;</td>
	<td class="main info_bold" align="center">%%values%%&nbsp;%%products_categories%%&nbsp;%%values_mappings%%</td>
</tr>

features_row_even: 
<tr bgcolor="#EEEEEE">
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=feature.html;feature_id=%%feature_id%%;tmpl_if_success_cmd=features.html">%%name%%</a></td>
  <td class="main info_bold">%%sign%%&nbsp;</td>
	<td class="main info_bold" align="center">%%values%%&nbsp;%%products_categories%%&nbsp;%%values_mappings%%</td>
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
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_features_features=name">Feature</a></th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_features_features=sign">Unit</a></th>
								<th class="main info_header">Action</th>
							</tr>
							
							%%features_rows%%
							
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
name: features;
class: hidden;

features_row: 


body:

}

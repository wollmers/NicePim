{
name: data_sources;

$$INCLUDE nav_inc.al$$

data_sources_row: 
<tr>
	<td class="main info_bold">&nbsp;%%no%%/%%found%%</td>
	<td class="main info_bold">&nbsp;<a href="%%base_url%%;tmpl=data_source.html;data_source_id=%%data_source_id%%">%%code%%</a></td>
	<td class="main info_bold" align=center>%%updated%%</td>
	<td class="main info_bold" align=center><a href="%%base_url%%;tmpl=data_source_supplier_maps.html;data_source_id=%%data_source_id%%">Map brands</a></td>
	<td class="main info_bold" align=center><a href="%%base_url%%;tmpl=data_source_category_maps.html;data_source_id=%%data_source_id%%">Map categories</a></td>
	<td class="main info_bold" align=center><a href="%%base_url%%;tmpl=data_source_feature_maps.html;data_source_id=%%data_source_id%%">Map features</a></td>
</tr>

body:

$$INCLUDE nav_bar2.al$$

<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_data_sources_data_sources=code">Name</a></th>
								<th class="main info_header">Updated</th>
								<th colspan="3" class="main info_header">Maps</th>
								
								%%data_sources_rows%%
								
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

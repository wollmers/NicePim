{
name: data_source_supplier_maps;

$$INCLUDE nav_inc.al$$

data_source_supplier_maps_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold">&nbsp;<a href="%%base_url%%;tmpl=data_source_supplier_map.html;data_source_supplier_map_id=%%data_source_supplier_map_id%%;data_source_id=%%data_source_id%%">%%symbol%%</a></td>
	<td class="main info_bold">&nbsp;%%dist_name%%</td>
	<td class="main info_bold">&nbsp;%%supp_name%%</td>
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
								<th class="main info_header" width="10%">#/##</th>
								<th class="main info_header" width="45%">
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_supplier_maps_data_source_supplier_maps=symbol">Foreign symbol</a></th>
								<th class="main info_header" width="20%">
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_supplier_maps_data_source_supplier_maps=dist_name">Distributor</a></th>
								<th class="main info_header" width="25%">
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_supplier_maps_data_source_supplier_maps=supp_name">Native brand</a></th>
							</tr>
							
							%%data_source_supplier_maps_rows%%
							
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
name: data_source_supplier_maps;

class: hidden;

data_source_supplier_maps_row: 

body:

}

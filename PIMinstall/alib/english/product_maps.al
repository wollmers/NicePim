{
name: product_maps;
$$INCLUDE nav_inc.al$$

product_maps_row: 
<tr>
  <td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold" align="center"><a href="%%base_url%%;tmpl=product_map.html;product_map_id=%%product_map_id%%">%%code%%</a></td>
  <td class="main info_bold">%%pattern%%</td>
  <td class="main info_bold" align="center">&nbsp;%%supplier_name%%</td>
  <td class="main info_bold" align="center">&nbsp;%%map_supplier_name%%</td>
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
								
								<th class="main info_header" width="5%">#/##</th>
								<th class="main info_header" width="20%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_product_maps_product_maps=code">Rule code</a></th>
								<th class="main info_header" width="51%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_product_maps_product_maps=pattern">Pattern</a></th>
								<th class="main info_header" width="12%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_product_maps_product_maps=supplier_name">Brand</a></th>
								<th class="main info_header" width="12%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_product_maps_product_maps=map_supplier_name">Map supplier</a></th>
							</tr>
							
							%%product_maps_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

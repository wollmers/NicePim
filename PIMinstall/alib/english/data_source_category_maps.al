{
name: data_source_category_maps;

$$INCLUDE nav_inc.al$$

data_source_category_maps_row: 
<tr>
	<td class="main info_bold" align="center">%%no%%/%%found%%</td>
  <td class="main info_bold">&nbsp;<a href="%%base_url%%;tmpl=data_source_category_map.html;data_source_category_map_id=%%data_source_category_map_id%%;data_source_id=%%data_source_id%%">%%symbol%%</a></td>
	<td class="main info_bold">&nbsp;<script type="text/javascript">
<!--
time_end = %%unused%%+0 == 1 ? '' : 's';
product_end = %%frequency%%+0 == 1 ? '' : 's';

if ((%%frequency%% + 0 == 0) && (%%unused%%+0 > 100)) \{ // set 100 as how many times we won't show this warning
	 document.write('<span style="color: red;">useless<br />(%%unused%% time'+time_end+')</span>');
\}
else if (%%frequency%% + 0 > 0) \{
	 document.write('%%frequency%% product'+product_end);
\}
// -->
</script></td>
	<td class="main info_bold">&nbsp;%%dist_name%%</td>
	<td class="main info_bold">&nbsp;%%cat_name%%</td>
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
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_category_maps_data_source_category_maps=symbol">Foreign symbol</a></th>
								<th class="main info_header" width="10%">Notes</th>
								<th class="main info_header" width="15%">
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_category_maps_data_source_category_maps=dist_name">Distributor</a></th>
								<th class="main info_header" width="20%">
									<a href="%%base_url%%;%%joined_keys%%;tmpl=%%tmpl%%;order_data_source_category_maps_data_source_category_maps=cat_name">Native category</a></th>
							</tr>
							
							%%data_source_category_maps_rows%%
							
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
name: data_source_category_maps;

class: hidden;

data_source_category_maps_row: 

body:

}

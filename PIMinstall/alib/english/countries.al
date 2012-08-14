{
name: countries;

$$INCLUDE nav_inc.al$$

countries_row: 
<tr>
	<td class="main info_bold">&nbsp;&nbsp;%%no%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=country_edit.html;country_id=%%country_id%%">%%name%%</a></td>
  <td class="main info_bold">%%country_code%%</td>
	<td class="main info_bold">%%ean_prefix%%</td>
	<td class="main info_bold">%%system_of_measurement%%</td>
</tr>

body:
			
$$INCLUDE nav_bar2.al$$
      
<table align="center" width="70%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="7%">#</th>
								<th class="main info_header" width="48%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_countries_countries=name">Country</th>
								<th class="main info_header" width="15%">Short code</th>
								<th class="main info_header" width="15%">EAN prefix</th>
								<th class="main info_header" width="15%">System of measurement</th>
							</tr>
							
							%%countries_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

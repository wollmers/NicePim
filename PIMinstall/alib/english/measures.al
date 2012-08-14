{
name: measures;

$$INCLUDE nav_inc.al$$

measures_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=measure_edit.html;measure_id=%%measure_id%%">%%name%%</a></td>
  <td class="main info_bold">%%sign%%</td>
  <td class="main info_bold">%%system_of_measurement%%</td>
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
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_measures_measures=name">Measure</a></th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_measures_measures=sign">Unit</a></th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_measures_measures=system_of_measurement">System of measurement</a></th>
								
							</tr>
							
							%%measures_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$


}

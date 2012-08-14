{
name: stat_reports;
$$INCLUDE nav_inc.al$$
period_value_2: Weekly
period_value_3: Monthly
period_value_4: Quarterly
period_value_5: Daily


stat_query_row:
<tr>
	<td class="main info_bold" align="center">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;stat_query_id=%%stat_query_id%%;tmpl=requests.html">%%code%%</a></td>
	<td class="main info_bold">%%period%%</td>
	<td class="main info_bold">%%email%%</td>
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
								<th class="main info_header" width="7%">#/##</th>
								<th class="main info_header" width="20%">Code</th>
								<th class="main info_header" width="20%">Schedule</th>
								<th class="main info_header" width="20%">Email</th>
							</tr> 
							%%stat_query_rows%%
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

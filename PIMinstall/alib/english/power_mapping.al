{
name: power_mapping;

$$INCLUDE actions2.al$$

feature_value_regexp_row:
<a href="%%base_url%%;tmpl=feature_values.html;feature_id=%%feature_id%%">%%feature_name%%</a>&nbsp;

measure_value_regexp_row:
<a href="%%base_url%%;tmpl=measure_edit.html;measure_id=%%measure_id%%">%%measure_name%%</a>&nbsp;

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tbody>
								<tr><td class="main info_bold" width="1%">Pattern\:</td><td class="main info_bold"><span style="font-weight: 900;">%%pattern%%</span></td></tr>
								<tr><td class="main info_bold" width="1%">Features\:</td><td class="main info_bold">%%feature_value_regexp_rows%%</td></tr>
								<tr><td class="main info_bold" width="1%">Measures\:</td><td class="main info_bold">%%measure_value_regexp_rows%%</td></tr>
							</tbody>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

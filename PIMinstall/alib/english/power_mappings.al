{
name: power_mappings;

power_mapping_row:
<tr align="center">
	<td class="main info_bold">%%no%%/%%found%%</td>
	<td class="main info_bold" align="left"><nobr><a style="text-decoration: none;" href="%%base_url%%;tmpl=power_mapping.html;value_regexp_id=%%value_regexp_id%%">%%pattern%% %%parameters%%</a></nobr></td>
	<td class="main info_bold">%%num_features%%</td>
	<td class="main info_bold">%%num_measures%%</td>
</tr>

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<thead>
								<tr>
									<th class="main info_header">#/##</th>
									<th class="main info_header">pattern</th>
									<th class="main info_header"># of features</th>
									<th class="main info_header"># of measures</th>
								</tr>
							</thead>
							<tbody>
								%%power_mapping_rows%%
							</tbody>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />
}

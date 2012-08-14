{
name: feature_input_types;

feature_input_row:
<tr align="center">
	<td class="main info_bold">%%no%%/%%found%%</td>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=feature_input_type.html;feature_input_type_id=%%feature_input_type_id%%">%%name%%</a></td>
	<td class="main info_bold">%%pattern%%</td>
</tr>

body:
<br />

<table width="100%"><tr><td align="right"><a class="new-win" href="%%base_url%%;tmpl=feature_input_type.html">New input type</a></table>

<br />

<table align="center" width="75%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<thead>
								<tr>
									<th class="main info_header">#/##</th>
									<th class="main info_header">name</th>
									<th class="main info_header">pattern</th>
								</tr>
							</thead>
							<tbody>
								%%feature_input_rows%%
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

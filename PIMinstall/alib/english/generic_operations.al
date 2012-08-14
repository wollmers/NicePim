{
name: generic_operations;

generic_operation_row:
<tr align="center">
	<td class="main info_bold">%%no%%/%%found%%</td>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=generic_operation.html;generic_operation_id=%%generic_operation_id%%">%%name%%</a></td>
	<td class="main info_bold">%%parameter%%</td>
	<td class="main info_bold">%%exist%%</td>
</tr>

body:
<br />

<table width="75%" align="center"><tr><td align="right"><a class="new-win" href="%%base_url%%;tmpl=generic_operation.html">New generic operation</a></table>

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
									<th class="main info_header">parameter</th>
									<th class="main info_header">exists?</th>
								</tr>
							</thead>
							<tbody>
								%%generic_operation_rows%%
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

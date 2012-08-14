{
name: stock_reports;


stock_reports_row:
<tr>
  <td class="main info_bold" align="center"><a href="%%base_url%%;tmpl=stock_report.html;stock_report_id=%%stock_report_id%%">%%supplier_name%%</a></td>
  <td class="main info_bold">%%mail_to%%</td>
  <td class="main info_bold">%%mail_cc%%</td>
  <td class="main info_bold" align="center">%%time%%</td>
  <td class="main info_bold" align="center">%%active%%</td>
</tr>

body:

<table width="100%"><tr><td align="right"><a class="new-win" href="%%base_url%%;tmpl=stock_report.html">New stock report</a></table>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">Brand</th>
								<th class="main info_header">Mail to</th>
								<th class="main info_header">Mail cc</th>
								<th class="main info_header">Generation time</th>
								<th class="main info_header">Active</th>
							</tr>
							
							%%stock_reports_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />
}

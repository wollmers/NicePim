{
name: stock_report;

$$INCLUDE actions2.al$$

body:

<form method=post>
	
  <input type=hidden name=atom_name value="stock_report">
  <input type=hidden name=sessid value="%%sessid%%">
  <input type=hidden name=tmpl_if_success_cmd value="stock_reports.html">
  <input type=hidden name=tmpl value="stock_report.html">
  <input type=hidden name=stock_report_id value="%%stock_report_id%%">
	
	<table align="center" width="75%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="2">Stock report</th>
								</tr>
								<tr>
									<td class="main info_bold" align="right">Brand</td><td class="main info_bold">%%supplier_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">Mail to</td><td class="main info_bold"><textarea name="mail_to" rows="5" cols="50">%%mail_to%%</textarea></td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">Mail cc</td><td class="main info_bold"><textarea name="mail_cc" rows="5" cols="50">%%mail_cc%%</textarea></td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">Active</td><td class="main info_bold">%%active%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">Generation time</td><td class="main info_bold">%%time%%</td>
								</tr>
								<tr>
									<td class="main info_bold" colspan="2" align="center">%%insert_action%%%%update_action%%%%delete_action%%</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>

}

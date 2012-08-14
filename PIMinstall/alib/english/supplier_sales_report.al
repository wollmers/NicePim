{
name: supplier_sales_report;

sales_report_row:
<tr>
	<td class="main info_bold"><a href=%%base_url%%;tmpl=supplier_sales_report_edit.html;sales_report_id=%%sales_report_id%%;supplier_id=%%supplier_id%%><b>%%report_type%%</b></a></td>
	<td class="main info_bold">%%active%%</td>
	<td class="main info_bold">&nbsp;<a href="mailto:%%mailto%%">%%mailto%%</a></td>
	<td class="main info_bold">&nbsp;<a href="mailto:%%mailcc%%">%%mailcc%%</td>
	<td class="main info_bold">&nbsp;<a href="mailto:%%mailbcc%%">%%mailbcc%%</td>
</tr>

body:

<br />

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="50%" align=left><b>Reports</b></th>
								<th class="main info_header" style="text-align: right;"><a href="%%base_url%%;tmpl=supplier_sales_report_edit.html;supplier_id=%%supplier_id%%" class="new-win">New report</a></th>
							</tr>
						</table>

          </td>
        </tr>
      </table>
			
    </td>
  </tr>
</table>


<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top: 0px;">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">

							<tr>
								<th class="main info_header" width="15%">Report&nbsp;type</th>
								<th class="main info_header" width="5%">Active</th>
								<th class="main info_header" width="30%">To</th>
								<th class="main info_header" width="25%">Cc</th>
								<th class="main info_header" width="25%">Bcc</th>
							</tr>
							
							%%sales_report_rows%%
							
						</table>

          </td>
        </tr>
      </table>
			
    </td>
  </tr>
</table>
}

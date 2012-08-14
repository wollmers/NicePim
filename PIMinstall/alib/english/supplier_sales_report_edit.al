{
name: supplier_sales_report_edit;

$$INCLUDE actions2.al$$

report_type_id_dropdown_empty: UNDEF;

body:
<form method=post>

	<input type=hidden name=atom_name value="supplier_sales_report_edit">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="supplier_edit.html">
	<input type=hidden name=tmpl_if_create_and_success_cmd value="supplier_sales_report_edit.html">
	<input type=hidden name=tmpl value="supplier_sales_report_edit.html">
	<input type=hidden name=sales_report_id value="%%sales_report_id%%">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	
	<br />
	
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
		
							<tr>
								<th class="main info_header" colspan="2">Brand report details</th>
							</tr>

							<tr>
								<td class="main info_bold" align=right width=20%>~Report type~</td>
								<td class="main info_bold">%%report_type_id%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~Active~</td>
								<td class="main info_bold">%%active%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~To~</td>
								<td class="main info_bold"><textarea cols=60 rows=3 name=mailto>%%mailto%%</textarea></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~Cc~</td>
								<td class="main info_bold"><textarea cols=60 rows=3 name=mailcc>%%mailcc%%</textarea></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~Bcc~</td>
								<td class="main info_bold"><textarea cols=60 rows=3 name=mailbcc>%%mailbcc%%</textarea></td>
							</tr>
							<tr>
								<td class="main info_bold" colspan=2 align=center>
									<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
								</td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
    </td>
  </tr>
</table>

<br />
			
</form>

}

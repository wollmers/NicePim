{
name: cov_distri_query;

supplier_id_multiselect_empty_key: 0;
supplier_id_multiselect_empty: Any vendor;

distri_id_dropdown_empty: Any distributor;

body:

<form method=post enctype="multipart/form-data" name=cov>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="cov_distri_reports.html">
	<input type=hidden name=atom_name value="cov_distri_query">
	<input type=hidden name=tmpl_if_success_cmd value="cov_distri_reports.html">
	<input type=hidden name=command value="distri_data_export"></div>	

	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="3">Distributor coverage report</th>
								</tr>
								<tr>
									<td class="main info_bold" align=right width="25%">Vendor</td>
									<td class="main info_bold">%%supplier_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Distributor</td>
									<td class="main info_bold">%%distri_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Product on stock</td>
									<td class="main info_bold">%%on_stock%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Undescribed products</td>
									<td class="main info_bold">%%undescribed%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Email</td>
									<td class="main info_bold"><input type="text" id="mail_control" name="mail" width="100%" value="" />&nbsp;&nbsp;<input type="submit" value="Export" onClick="return checkEmail()"/></td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>

<script type="text/JavaScript">

function checkEmail() \{
    val = document.getElementById('mail_control').value;
    if (! val.match(/\w+\@\w+/)) \{
        alert('Wrong email');
        return false;   
    \} 
    else \{
        return true;
    \}
\}

</script>

}

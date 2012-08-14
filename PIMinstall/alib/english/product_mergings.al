{
name: product_mergings;

mergings_row:
<tr>
  <td class="main info_bold"><span style="color: black;">&nbsp;&nbsp;&nbsp;%%supplier_name%%</span></td>
  <td class="main info_bold"><span style="color: black;">%%m_prod_id%%</span></td>
	<td class="main info_bold"><span style="color: black;">%%old_prod_id%%</span></td>
	<td class="main info_bold"><span style="color: black;">%%login%%</span></td>
	<td class="main info_bold"><span style="color: black;">%%user_group%%</span></td>	
</tr>

mergings_row_best:
<tr>
  <td class="main info_bold"><span style="color: red;">&nbsp;&nbsp;&nbsp;%%supplier_name%%</span></td>
  <td class="main info_bold"><span style="color: red;">%%m_prod_id%%</span></td>
	<td class="main info_bold"><span style="color: red;">%%old_prod_id%%</span></td>
	<td class="main info_bold"><span style="color: red;">%%login%%</span></td>
	<td class="main info_bold"><span style="color: red;">%%user_group%%</span></td>	
</tr>
 
mergings_separator: <tr><td class="main info_bold" colspan=5 height=1>&nbsp;</td></tr>

mergings_body:
<form method=post name=form3>
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="5">&nbsp;&nbsp;&nbsp;<b>Products merging preview</b></th>
								</tr>
								<tr>
									<th class="main info_header">&nbsp;&nbsp;&nbsp;Brand</th>
									<th class="main info_header">Modified product code</th>
									<th class="main info_header">Original product code</th>
									<th class="main info_header">User</th>
									<th class="main info_header">User group</th>
								</tr>

								%%mergings_rows%%

							</table>
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
</form>

mergings_report_body:
<br />

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="green">
		<tr>
			<td style="padding :1px;">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">

								<tr>
									<th class="main info_header">&nbsp;&nbsp;&nbsp;Brand</th>
									<th class="main info_header">Modified product code</th>
									<th class="main info_header">Original product code</th>
									<th class="main info_header">User</th>
									<th class="main info_header">User group</th>
								</tr>

								<tr style="padding-top: 5px;">
									<th class="main info_header" style="background-color: #cccccc;" colspan="5">&nbsp;&nbsp;&nbsp;<b>Removed products</b></th>
								</tr>

								%%mergings_removed_rows%%

								<tr style="padding-top: 5px;">
									<th class="main info_header" style="background-color: #cccccc;" colspan="5">&nbsp;&nbsp;&nbsp;<b>Saved products</b></th>
								</tr>

								%%mergings_saved_rows%%

							</table>
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>

body:
%%mergings_body%%
}

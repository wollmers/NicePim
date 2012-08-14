{
name: supplier_contact;

contact_row:
<tr>
	<td class="main info_bold"><a href=%%base_url%%;tmpl=supplier_contact_edit.html;contact_id=%%contact_id%%;supplier_id=%%supplier_id%%>%%person%%</a></td>
	<td class="main info_bold"><a href="mailto:%%email%%">%%email%%</a></td>
	<td class="main info_bold">%%report_format%%</td>
	<td class="main info_bold">%%language%%</td>
	<td class="main info_bold">%%country%%</td>
	<td class="main info_bold">

<form method="post" id="%%contact_id%%_submit">
	
  <input type="hidden" name="atom_name" value="supplier_contact">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl" value="supplier_edit.html">
  <input type="hidden" name="user_id_cur" value="%%user_id_cur%%">
  <input type="hidden" name="supplier_id" value="%%supplier_id%%">
  <input type="hidden" name="command" value="brand_users_manage">
  <input type="hidden" name="action" value="del">

	<input class="hover_button" type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete.gif) no-repeat;" name="atom_delete" value="." onClick="var agree=confirm('Are you sure you wish to continue?'); if (agree) \{ return true; \} else \{ return false; \}">

</form>

	</td>
</tr>

supplier_country_empty: International;
user_id_new_dropdown_empty: Choose the user;

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
								<th class="main info_header" align="left"><b>Brand contacts / product updates reports</b></th>
								<th class="main info_header" align="right">
									<a href="%%base_url%%;tmpl=user_edit.html;mi=users;link_supplier_id=%%supplier_id%%;user_group=supplier" class="new-win" target="blank">New brand user for %%brand_name%%</a> (new page)<br/>

                  <form name="brand_user_new" id="brand_user_new" method="post">
                    <input type="hidden" name=atom_name value="supplier_contact">
                    <input type="hidden" name=sessid value="%%sessid%%">
                    <input type="hidden" name=tmpl_if_success_cmd value="supplier_edit.html">
                    <input type="hidden" name=tmpl value="supplier_edit.html">
                    <input type="hidden" name=command value="brand_users_manage">
                    <input type="hidden" name=supplier_id value="%%supplier_id%%">
                    <input type="hidden" name=action value="add">

                    %%user_id_new%%

                    <a href="#" onClick="document.getElementById('brand_user_new').submit(); return false;" class="new-win" align="right">Add new user to %%brand_name%%</a>

                  </form>
									<!--<a href="%%base_url%%;tmpl=supplier_contact_edit.html;supplier_id=%%supplier_id%%" class="new-win"></a>-->
									</th>
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
								<th class="main info_header" width="20%">Person</th>
								<th class="main info_header" width="20%">Email</th>
								<th class="main info_header" width="20%">Report format</th>
								<th class="main info_header" width="14%">Report language</th>
								<th class="main info_header" width="13%">Country</th>
								<th class="main info_header" width="13%">Action</th>
							</tr>

							%%contact_rows%%

						</table>

					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>
}

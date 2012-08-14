{
name: supplier_assigned_users;


new_brand_assigned_users_id_dropdown_empty: Choose the reseller;

assigned_users_row:

<tr>
	<td class="main info_bold">%%person%% (%%login%%)</td>
	<td class="main info_bold">%%company%%</td>
	<td class="main info_bold">%%country%%</td>
	<td class="main info_bold" align="center">

<form method="post" id="%%brand_assigned_users_id%%_submit">
	
  <input type="hidden" name="atom_name" value="supplier_assigned_users">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl" value="supplier_edit.html">
  <input type="hidden" name="brand_assigned_users_id" value="%%brand_assigned_users_id%%">
  <input type="hidden" name="supplier_id" value="%%supplier_id%%">

	<input class="hover_button" type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete.gif) no-repeat;" name="atom_delete" value="." onClick="var agree=confirm('Are you sure you wish to continue?'); if (agree) \{ return true; \} else \{ return false; \}">

</form>

</td>

</tr>


body:

<br />

<form id="new_brand_assigned_users_id_submit" method="post">
	
  <input type="hidden" name="atom_name" value="supplier_assigned_users">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="user_id" value="" id="new_brand_assigned_users_id_paste">
  <input type="hidden" name="supplier_id" value="%%supplier_id%%">
  <input type="hidden" name="tmpl" value="supplier_edit.html">
  <input type="hidden" name="atom_submit" value="atom_submit">

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" align="left" width="25%"><abbr title="Mentioned users will have the brand's repository access"><b>Assigned resellers</b></abbr></th>
								<th class="main info_header" align="right">%%new_brand_assigned_users_id%%&nbsp;<a class="new-win" href="" onClick="javascript:
document.getElementById('new_brand_assigned_users_id_paste').value = document.getElementById('new_brand_assigned_users_id').value;
document.getElementById('new_brand_assigned_users_id_submit').submit();">Add the reseller</a></th>
								
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

</form>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top: 0px;">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="25%">Person</th>
								<th class="main info_header" width="25%">Company</th>
								<th class="main info_header" width="25%">Country</th>
								<th class="main info_header" width="25%">Action</th>
							</tr>

							%%assigned_users_rows%%

						</table>

					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

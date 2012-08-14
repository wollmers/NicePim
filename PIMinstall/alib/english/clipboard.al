{
name:clipboard;

category_feature_list_row:%%value%%

category_feature_body:
<input type=hidden name=catid value="%%catid%%">
<h3>Group category features</h3>    

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<td class="main info_bold" valign=top>Selected items:</td>
								<td class="main info_bold">
									<textarea rows=8 cols=80>%%category_feature_list_rows%%</textarea>
								</td>
							</tr>
							<tr>
								<td class="main info_bold">
									<span style="color: red;">*</span>Assign to </td>
								<td class="main info_bold">%%group_list%%</td>
							</tr>
							<tr>
								<td class="main info_bold">
									<input type=submit name="group_selection" value="Group items"></td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

product_list_row:<option value=%%value%%>%%text%%</option>

complaint_list_row:<option value=%%value%%>%%text%%</option>

track_product_all_list_row:<option value=%%value%%>%%text%%</option>

track_product_list_row:<option value=%%value%%>%%text%%</option>

product_body:

$$INCLUDE product_group_actions_edit.al$$

<input type=hidden name=product_id_list value="%%product_id_list%%"><br>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr><th class="main info_header" align=left>&nbsp;&nbsp;&nbsp;<b>Product selection</b></th></tr>
							<tr bgcolor=white>
								<td class="main info_bold" align=center><select style="width: 90%;" size=10 name=select_products class=smallform>%%product_list_rows%%</select></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right bgcolor=white><input type=button onclick="javascript:delete_()" class=smallform value="Skip product">
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br>

complaint_body:

$$INCLUDE product_complaint_group_actions_edit.al$$

<input type=hidden name=complaint_id_list value="%%complaint_id_list%%"><br>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr><th class="main info_header" align=left>&nbsp;&nbsp;&nbsp;<b>Complaint selection</b></th></tr>
							<tr bgcolor=white>
								<td class="main info_bold" align=center><select size=5 name=select_complaint class=smallform>%%complaint_list_rows%%</select></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right bgcolor=white><input type=button onclick="javascript:delete_()" class=smallform value="Skip complaint">
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br>

track_product_all_body:
<input type=hidden name=complaint_id_list value="%%complaint_id_list%%"><br>
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr><th class="main info_header" align=left>&nbsp;&nbsp;&nbsp;<b>Rules selection</b></th></tr>
							<tr bgcolor=white>
								<td class="main info_bold" align=center><select size=5 name=select_track_product id="select_track_product_id" class=smallform>%%track_product_all_list_rows%%</select></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right bgcolor=white><input type=button onclick="delete_(document.getElementById('select_track_product_id'))" class=smallform value="Skip rule">
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br>

track_product_body:
<input type=hidden name=complaint_id_list value="%%complaint_id_list%%"><br>
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr><th class="main info_header" align=left>&nbsp;&nbsp;&nbsp;<b>Rules selection</b></th></tr>
							<tr bgcolor=white>
								<td class="main info_bold" align=center><select size=5 name=select_track_product id="select_track_product_id" class=smallform>%%track_product_list_rows%%</select></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right bgcolor=white><input type=button onclick="delete_(document.getElementById('select_track_product_id'))" class=smallform value="Skip rule">
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>
	
wrap_body:
<form method=post name=form>
	<input type="hidden" name=sessid value="%%sessid%%">
  <input type=hidden name=tmpl value="%%tmpl%%">

	$$INCLUDE cli_actions.al$$

  <input type=hidden name="%%action_code%%" value="1">	 

	%%instance_body%%
	
</form>

}

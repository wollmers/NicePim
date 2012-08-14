{
name: mail_dispatch;

dispatch_groups_names: Editors, All shops, Brands, Partners, All subscribers;
country_id_set_dropdown_empty: All Countries;
country_id_set_dropdown_empty_key: -1;

body:
<br />

<form method="post" enctype="multipart/form-data"> 
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="#99CCFF">
			<th class="main info_header" width="50%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Send To</th>
			<th class="main info_header" width="50%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Preferences</th>
		</tr>
		<tr bgcolor="white">
			<td valign="top">
				<table width="100%" bgcolor="white" nowrap cellpadding="0" cellspacing="0" class="maintxt" border="0">
					%%mail_dispatch_groups%%
					<tr>
						<td><input type="checkbox" name="dispatch_one_address_check" %%checked%% value="1" class="smallform">Address <input type="text" name="dispatch_one_address" value="%%single_email%%" class="smallform" size="40"></td>
					</tr>
				</table>
			</td>
			<td valign="top">
				<table width="100%" bgcolor="white" nowrap="nowrap" cellpadding="0" cellspacing="5" class="maintxt" valign="top">
					<tr valign="top">
						<td>~Attachment name~</td>
						<td><input type="text" name="dispatch_attachment" value="%%attachment_name%%" class="smallform"><br /><input type="file" name="dispatch_attachment_filename" class="smallform"></td>
					</tr>
					<tr>
						<td>~Country~</td>
						<td>%%country_id_set%%</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br />
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="#99CCFF">
			<th class="main info_header" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Message</th>
		</tr>
		<tr bgcolor="white">
			<td align="right" width="10%"><b>~Subject~</b></td>
			<td colspan="2" align="left"><input type="text" value="%%dispatch_subject%%" class="smallform" name="dispatch_subject" style="width: 600px;"></td>
		</tr>
		<tr bgcolor="white">
			<td valign="top" align="right" width="10%"><b>~Body~</b></td>
			<td colspan="2" align="left"><textarea class="ckeditor" name="dispatch_html_message" id="editor1" style="width: 600px; height: 150px;">%%dispatch_message%%</textarea></td>
		</tr>

	</table>
	<table width="100%">
		<tr bgcolor="white" valign="top">
			<td valign="top" align="right" width="10%"></td>
			<td align="left"><b>\%\%person\%\%:</b>will be replaced with person name (if available in database)</td>
		</tr>
		<tr bgcolor="white" valign="top">
			<td valign="top" align="right" width="10%"></td>
			<td align="left" ><b>\%\%unsubscribe\%\%:</b>will be replaced with unsubscribe URL (if person available in database) you should use it in link editor</td>
		</tr>
		<tr>
			<td colspan="10%" align="right">
				<input type="hidden" name="atom_name" value="mail_dispatch">
				<input type="submit" name="atom_submit" value="Send" class="smallform">
			</td>				
		</tr>
	</table>
	<input type="hidden" name="origin_id" value="%%id%%">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl" value="mail_dispatch_edit.html">
	<input type="hidden" name="command" value="mail_dispatch_prepare">
	<input type="hidden" name="tmpl_if_success_cmd" value="mail_dispatch_log.html">
	<input type="hidden" name="dispatch_message_type" value="html text">
</form>

}

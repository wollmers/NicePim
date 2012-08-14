{
name: supplier;

acknowledge_Y: Yes;
acknowledge_N: No;

$$INCLUDE actions2.al$$

body:

<br />

<form method=post enctype="multipart/form-data">
	
	<input type=hidden name=atom_name value="supplier">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="suppliers.html">
	<input type=hidden name=tmpl_if_create_and_success_cmd value="supplier_edit.html">
	<input type=hidden name=tmpl value="supplier_edit.html">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	<input type=hidden name=command value="get_obj_url,add_new_default_user_and_contact">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main" bgcolor="#e6f0ff" colspan="2" style="font-size: 1.2em;">Brand details</th>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Name~</td>
									<td class="main info_bold">
										<input type=text size=20 name=name value="%%name%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><abbr title="Choose the main user from brand users list">~Assigned (main) user~</abbr></td>
									<td class="main info_bold">%%edit_user_id%%<span style="color: red;"> *</span><span style="color: green;">required if it is sponsor</span></td>
								</tr>
								<tr>
									<td class="main info_bold" valign=top align=right>~Logo picture URL~</td>
									<td class="main info_bold" valign=top><input type="text" name="low_pic" value="%%low_pic%%" size=80 style="display: inline;">
										or
										<input type="file" name="supplier_pic_filename">
									</td>
								</tr>
								<tr>
									<td class="main info_bold" valign=top align=right>~Thumbnail picture URL~</td>
									<td class="main info_bold" valign=top><a href="%%thumb_pic%%" target="_blank">%%thumb_pic%%</a>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Acknowledge~</td>
									<td class="main info_bold">%%acknowledge%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Is sponsor~</td>
									<td class="main info_bold">%%is_sponsor%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Public login~</td>
									<td class="main info_bold"><input type=text size=20 name=public_login value="%%public_login%%" style="display: inline;">
										<span style="color: red;"> *</span><span style="color: green;">required if it is sponsor</span></td>
								</tr>
								<tr>
									<td class="main info_bold" nowrap align=right>~Public password~</td>
									<td class="main info_bold"><input type=text size=20 name=public_password value="%%public_password%%" style="display: inline;">
										<span style="color: red;"> *</span><span style="color: green;">required if it is sponsor</span></td>
								</tr>
								<tr>
									<td class="main info_bold" nowrap align=right>~FTP home dir~</td>
									<td class="main info_bold"><input type=text size=20 name=ftp_homedir value="%%ftp_homedir%%" style="display: inline;">
										<span style="color: red;"> *</span><span style="color: green;">user is locked in his home directory</span></td>
								</tr>
								<tr>
									<td class="main info_bold" nowrap align=right>~XML repository path~</td>
									<td class="main info_bold"><span style="color: black;">%%icecat_hostname%%export/vendor/%%folder_name%%</span></td>
								</tr>
								<tr>
									<td class="main info_bold" colspan=2 style="color: green; text-align: center;">
										Creating the brand sponsored XML repository and including sponsored URLs in the Open-ICEcat data<br>is performed during the night batch<br>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>
										Product localization templates&nbsp;(<a href="%%base_url%%;tmpl=product_update_localizations_howto.html" target="_blank"><span style="color: red;">how-to</span></a>)
									</td>
									<td class="main info_bold">
										<textarea name="template" style="width: 400px; height: 100px;">%%template%%</textarea><br>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>
										Product part codes regular expression&nbsp;(<a href="%%base_url%%;tmpl=product_update_localizations_howto.html" target="_blank"><span style="color: red;">how-to</span></a>)
									</td>
									<td class="main info_bold">
										<textarea name="prod_id_regexp" style="width: 400px; height: 100px;">%%prod_id_regexp%%</textarea><br>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Suppress offers~</td>
									<td class="main info_bold">%%suppress_offers%%&nbsp;<span style="color: green;">If 'Yes' selected, brand's products aren't shown in ICEcat.biz site</span></td>
								</tr>
								<tr>
									<td class="main info_bold" colspan=2 align="center">
										<table class="invisible"><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
									</td>
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

{
name: supplier;
class: brief;
low_pic_format: <img src="%%thumb_value%%" border=0 hspace=0 vspace=0  style="cursor: pointer" onclick="PopupPic('%%sessid%%','%%value%%')"/>

body:
<div align=right>%%low_pic_formatted%%</div>

}

{
name: mail_dispatch_in;

html_message:
<tr bgcolor="white">
	<td colspan="2" align="left" style="padding-left: 100px;">%%dispatch_salutation%% <span style="color: green;">Person</span>,<br /><br />%%message%%<br /><br />%%dispatch_footer%% <span style="color: green;">unsubscribe link</span></td>
</tr>

plain_message:
<tr bgcolor="white">
	<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Plain text</b></td>
</tr>
<tr bgcolor="white">
	<td colspan="2" align="left" style="padding-left: 100px;">
		%%dispatch_salutation%% <span style="color: green;">Person</span>,<br />
		<textarea cols="80" rows="7" name="dispatch_plain_message">%%message%%</textarea><br />
		%%dispatch_footer%% <span style="color: green;">unsubscribe link</span>
	</td>
</tr>

date_format: %Y-%m-%d %H:%M:%S;

dispatch_attach_yes: YES;
dispatch_attach_no: NO;

body:
<br><br>
<form method = post>
<table width = 100% class=maintxt cellpadding=3 cellspacing=1 bgcolor='#EBEBEB'>
<tr bgcolor="#99CCFF">
<input type="hidden" name="sessid" value="%%sessid%%">
<input type="hidden" name="tmpl" value="mail_dispatch_edit.html">
<input type="hidden" name="id" value="%%id%%">
<input type=hidden name=atom_name value="mail_dispatch_in"> 

<td width=50%><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Send To</b></td>
<td width=50%><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Preferences</b></td>
</tr>
<tr bgcolor = "white">
<td valign=top>
<table width = 100% bgcolor=white nowrap cellpadding=0 cellspacing=0 class=maintxt border=0>
<tr><td>%%dispatch_groups%%<br><br></td></tr>
<tr><td align=center><textarea cols=45 rows=5 readonly>%%dispatch_emails%%</textarea></td></tr>
</table></td>
<td valign=top><table width = 100% bgcolor=white nowrap cellpadding=0 cellspacing=0 class=maintxt>
<tr><td width=30%>Date queued</td><td><i>%%date_queued%%</i></td></tr>
<tr><td width=30%>Date delivered</td><td><i>%%date_delivered%%</i></td></tr>
<tr><td width=30%>Attachment</td><td><i>%%dispatch_attachment_name%%</i></td></tr>
<tr><td colspan=2 align="left"><input type="submit" name="atom_submit" value="Edit letter" class="smallform"></td></tr>
</table></td>
</tr></table><br>
<table width = 100% class=maintxt cellpadding=3 cellspacing=1 bgcolor='#EBEBEB'>
	<tr bgcolor="#99CCFF">
		<td colspan=2><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Message</b></td>
	</tr>
	<tr bgcolor=white><td colspan=2 align=left>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Subject</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%%dispatch_subject%%</td></tr>
	%%html_body%% %%plain_body%%
</table>
</form>
}

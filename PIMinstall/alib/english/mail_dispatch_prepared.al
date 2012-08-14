{
name: mail_dispatch_prepared;

html_message:
<tr bgcolor="white">
	<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Html text</b></td>
</tr>
<tr bgcolor="white">
	<td colspan="2" align="left" style="padding-left: 100px;">%%dispatch_salutation%% <span style="color :green;">Person</span>,<br /><br />%%message%%<br /><br />%%dispatch_footer%% <span style="color :green;">unsubscribe link</span></td>
</tr>

plain_message:
<tr bgcolor="white">
	<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Plain text</b></td>
</tr>
<tr bgcolor="white">
	<td colspan="2" align="left" style="padding-left: 100px;">
		%%dispatch_salutation%% <span style="color :green;">Person</span>,<br />
		<textarea cols="80" rows="7" name="dispatch_plain_message">%%message%%</textarea><br />
		%%dispatch_footer%% <span style="color :green;">unsubscribe link</span>
	</td>
</tr>

body:
<script type="text/javascript">
<!--
function delete_() \{
 if(document.form.dispatch_persons.options.selectedIndex != -1) \{
	 document.form.dispatch_persons.options[document.form.dispatch_persons.options.selectedIndex] = null;
	 document.form.dispatch_emails.value = "";
	 for (i=0;i<document.form.dispatch_persons.options.length;i++) \{
		document.form.dispatch_emails.value = document.form.dispatch_emails.value +	document.form.dispatch_persons.options[i].value + ",";
	 \}
	 document.form.dispatch_emails.value = document.form.dispatch_emails.value.substring(0,document.form.dispatch_emails.value.length - 1);
 \}
 else \{alert('Please, pick the address first'); return(''); \}
\}

function add_(name, text) \{
	if (name == 'write an email address here') \{
		name = '';
		text == '';
	\}
	if (name != '') \{
		document.form.dispatch_persons.options.add(new Option(name, text));
		document.form.dispatch_emails.value = document.form.dispatch_emails.value +	"," + text;
	\}
\}
// -->
</script>
																																	
<br /><br />
<form method="post" name="form">
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="#99CCFF">
			<th class="main info_header" width="50%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Send To</th>
			<th class="main info_header" width="50%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Preferences</th>
		</tr>
		<tr bgcolor="white">
			<td valign="top">
				<table width="100%" bgcolor="white" nowrap="nowrap" cellpadding="0" cellspacing="0" class="maintxt" border="0">
					<tr>
						<td>%%dispatch_send_to%%<br /><br /></td>
					</tr>
					<tr>
						<td align="center">
							<select name="dispatch_persons" size="5">%%dispatch_persons%%</select></td>
					</tr>
					<tr align="center">
						<td><input type="button" onclick="javascript:delete_()" class="smallform" value="Delete recipient">
							<input type="button" onclick="javascript:\{
myWin = window.open('','AddRecipientWindow','width=335,height=30,left=0,top=0,toolbar=No,location=No,scrollbars=No,status=No,resizable=No,fullscreen=No,menubar=No,status=No');
myWin.document.open();
myWin.document.write('<html><head><title>Add Recipient</title></head>');
myWin.document.write('<LINK href=\'main.css\' rel=\'stylesheet\' type=\'text/css\'><body>');
myWin.document.write('<form name=\'aform\'><table class=\'maintxt\'><tr><td>Enter email</td></tr>');
myWin.document.write('<tr><td><input type=\'text\' value=\'write an email address here\' name=\'email\' class=\'smallform\' size=\'50\' style=\'color\: grey\;\'');
myWin.document.write('onBlur=\'javascript\:email_blur()\;\' ');
myWin.document.write('onFocus=\'javascript\:email_focus()\;\'></td></tr>');
myWin.document.write('<tr align=\'right\'><td><input type=\'button\' name=\'add\' class=\'smallform\' value=\'Add recipient\'');
myWin.document.write('onClick=\'javascript: \{window.opener.add_(document.aform.email.value, document.aform.email.value); window.close();\}\'></td></tr>\n');
myWin.document.write('<script type=\'text/javascript\'>\n');
myWin.document.write('<!--\n');
myWin.document.write('function email_blur()  \{ if (document.aform.email.value == \'\') \{ document.aform.email.value=\'write an email address here\'\; document.aform.email.style.color=\'grey\'; \} \}\n');
myWin.document.write('function email_focus() \{ if (document.aform.email.value == \'write an email address here\') \{ document.aform.email.value=\'\'\; document.aform.email.style.color=\'black\'; \} \}\n');
myWin.document.write('// -->\n');
myWin.document.write('</script>\n');
myWin.document.write('</table></form></body></html>');
myWin.document.close();\}" class="smallform" value="Add recipient"></td>
					</tr>
			</table></td>
			<td valign="top">
				<table width="100%" bgcolor="white" nowrap="nowrap" cellpadding="0" cellspacing="0" class="maintxt">
					<tr>
						<td width="30%">Date</td>
						<td><i>%%dispatch_date%%</i></td>
					</tr>
					<tr>
						<td width="30%">Message type</td>
						<td><i>%%dispatch_message_type%%</i></td>
					</tr>
					<tr>
						<td width="30%">Attachment</td>
						<td><i>%%dispatch_attachment%%</i></td>
					</tr>
					<tr>
						<td></td>
						<td><i>%%dispatch_attachment_size%%</i></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<br />
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="#99CCFF">
			<th class="main info_header" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Message</th>
		</tr>
		<tr bgcolor="white">
			<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Subject</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;%%dispatch_subject%%</td>
		</tr>
		%%dispatch_html_text%% %%dispatch_plain_text%%
	</table>
	<table width="100%">
		<tr>
			<td align="right">
				<input type="submit" name="atom_submit" value="Send" class="smallform"></td>
		</tr>
	</table>

	<input type="hidden" name="command" value="mail_dispatch_prepare">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl" value="mail_dispatch_edit.html">
	<input type="hidden" name="tmpl_if_success_cmd" value="mail_dispatch_log.html">
	<input type="hidden" name="dispatch_emails" value="%%dispatch_emails%%">
	<input type="hidden" name="dispatch_send_to_values" value="%%dispatch_send_to_values%%">
	<input type="hidden" name="dispatch_date" value="%%dispatch_date%%">
	<input type="hidden" name="dispatch_message_type" value="%%dispatch_message_type%%">
	<input type="hidden" name="dispatch_subject" value="%%dispatch_subject%%">
	<input type="hidden" name="dispatch_salutation" value="%%dispatch_salutation%%">
	<input type="hidden" name="dispatch_footer" value="%%dispatch_footer%%">
	<input type="hidden" name="dispatch_attachment" value="%%dispatch_attachment%%">
	<input type="hidden" name="dispatch_attachment_filename" value="%%dispatch_attachment_filename%%">
	<input type="hidden" name="file_content_type" value="%%file_content_type%%">
	<input type="hidden" name="dispatch_html_message" value="%%dispatch_html_simple_text%%">
	
</form>
}

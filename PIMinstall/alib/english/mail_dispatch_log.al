{
name: mail_dispatch_log;

dispatch_queued: <font color=brown>queued</font>
dispatch_delivered: <font color=green>delivered</font>
dispatch_in_progress: <font color=blue>in progress</font>

dispatch_attach_yes: YES;
dispatch_attach_no: NO;

date_format: %d-%m-%Y %H:%M:%S;

$$INCLUDE nav_inc.al$$

dispatch_log_row:
<tr bgcolor="white">
  <td>%%no%%/%%found%%</td>
	<td><a href="%%base_url%%;tmpl=mail_dispatch_in.html;id=%%dispatch_id%%">%%dispatch_subject%%</a></td>
	<td>%%dispatch_to_groups%%</td>
	<td align="center">%%dispatch_status%%</td>
	<td align="center">%%dispatch_date_queued%%</td>
	<td align="center">%%dispatch_date_delivered%%</td>
	<td align="center">%%dispatch_sent_emails%%</td>
	<td align="center">%%dispatch_attach%%</td>
</tr>

body:

$$INCLUDE nav_bar2.al$$

<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
	<tr bgcolor="#99CCFF" align="center">
		<td>No</td>
		<td><a href="%%base_url%%;tmpl=%%tmpl%%;order_mail_dispatch_log_dispatch_log=dispatch_subject">Subject</a></td>
		<td>To groups</td>
		<td><a href="%%base_url%%;tmpl=%%tmpl%%;order_mail_dispatch_log_dispatch_log=dispatch_status">Status</a></td>
		<td><a href="%%base_url%%;tmpl=%%tmpl%%;order_mail_dispatch_log_dispatch_log=dispatch_date_queued">Date queued</a></td>
		<td><a href="%%base_url%%;tmpl=%%tmpl%%;order_mail_dispatch_log_dispatch_log=dispatch_date_delivered">Date delivered</a></td>
		<td># emails</td>
		<td>Attach</td>
	</tr>
	%%dispatch_log_rows%%
</table>

$$INCLUDE nav_bar2.al$$
}

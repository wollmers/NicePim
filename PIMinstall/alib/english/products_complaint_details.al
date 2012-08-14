{
name: products_complaint_details;
rows_number: 40;

history_row:
<tr>
  <td  bgcolor="#D8D8D8"  rowspan=2 width=200 valign=top>
		<table class="maintxt" cellpadding=1 cellspacing=1 border=0 width=100%>
			<tr><td><b>Author</b></td><td>%%huname%%&nbsp;(%%huemail%%)</td></tr>
      <tr><td><b>Status</b></td><td>%%hstatus_name%%</td></tr>
      <tr><td><b>Date</b></td><td><i> %%hdate%%</i></td></tr>
		</table>
  </td>
  <td bgcolor="#EBEBEB" valign=top>
    <b>Subject</b> <i>%%hsubject%%</i>
  </td>
</tr>
<tr>
	<td bgcolor="#EBEBEB" valign=top>
		<div align='justify'>%%hmessage%%</div>
	</td>
</tr>

 
body:
<form method=post>
	<table border=0 width="740" align=center>
		<tr>
			<td align=left><b>Complaint details</b></td>
			<td align=right><a href="%%base_url%%;tmpl=product_details.html;product_id=%%product_id%%;cproduct_id=%%product_id%%">Edit product</a></td>
		</tr>
	</table>

	<table class="maintxt" cellpadding=1 cellspacing=1 border=0 width="740" align=center bgcolor="#999999">
		<tr>
			<td bgcolor="#D8D8D8" rowspan=2 width=200 valign=top>
				<table class="maintxt" cellpadding=1 cellspacing=1 border=0>
					<tr><td><b>Editor</b></td><td>%%uname%%&nbsp;</td></tr>
					<tr><td><b>From</b></td><td>%%funame%%(%%uemail%%)&nbsp;</td></tr>
					<tr><td><b>Company</b></td><td>%%company%%&nbsp;</td></tr>
					<tr><td><b>Product</b></td><td> %%prodid%%(%%supplier_name%%)</td></tr>
					<tr><td><b>Status</b></td><td> %%status_name%%</td></tr>
					<tr><td><b>Date</b></td><td><i>%%date%%</i></td></tr>		 
				</table>
			</td>
			<td bgcolor="#EBEBEB" valign=top>
				<b>Subject:</b> %%subject%%
			</td>
		</tr>
		<tr>
			<td bgcolor="#EBEBEB" valign=top>
				<div align='justify'>%%message%%</div>
			</td>
		</tr>
	</table>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="products_complaint_details.html">
	<input type=hidden name=complaint_id value=%%complaint_id%%>
	<input type=hidden name=prodid value="%%prodid%%">
	<input type=hidden name=command value="update_complain">
	<input type=hidden name=subject value='%%subject%%'>
	<input type=hidden name=message value="%%message%%">
	<div align=right style="margin-right:127px; margin-top:5px">%%update_button%%</div>
</form>

<br />

<table align="center" width="740"><tr><td align="left"><b>&nbsp;History log</b></table>

<table class="maintxt" cellpadding=0 cellspacing=0 border=0 width="740" align=center bgcolor="#999999">
	<tr>
		<td>
			<table class="maintxt" cellpadding=1 cellspacing=1 border=0 width="740" align=center>
				%%history_rows%%
			</table>
		</td>
	</tr>
</table>

<form method=post>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="%%tmpl_name%%">
	<input type=hidden name=last_complaint_id value=%%last_complaint_id%%>
	<input type=hidden name=complaint_id value=%%complaint_id%%>
	<div align=right style="margin-right:127px; margin-top:5px"><input type=submit name=respond value="Add response" class="elem"></div>
</form>

<br>

}

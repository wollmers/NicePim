{
name: products_complaint_last_history;

body:
<form method=post>

	<table class="maintxt" cellpadding=1 cellspacing=1 border=0 width="540" align=center  bgcolor="#999999">
		<tr>
			<td width="200" rowspan=2 valign=top bgcolor="#D8D8D8">
				<b>Author</b>&nbsp;%%uname%%(%%uemail%%)&nbsp;<br>
				<b>Status</b>&nbsp;&nbsp;&nbsp;&nbsp; %%status_id%%<br>
				<i>Date %%date%%</i>
			</td>
			<td  bgcolor="#EBEBEB">
				<b>Subject</b> %%subject%%
			</td>
		</tr>
		<tr>
			<td  bgcolor="#EBEBEB" valign=top>
				<div align='justify'>%%message%%</div>
			</td>
		</tr>
	</table>

	<input type=hidden name=atom_name value='products_complaint_last_history'>
	<input type=hidden name=complaint_id value=%%complaint_id%%>
	<input type=hidden name=userid value=%%userid%%>
	<input type=hidden name=subject value="%%subject%%">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="products_complaint_details.html">
	<input type=hidden name=command value="add_complaint_history">
	
	<br />

	<table align="center">
		<tr>
			<td>
				<div align=left class="maintxt">~<b>Response area:</b>~</div>
				<textarea class="" cols=64 rows=7 wrap="soft" name=new_msg align="center"></textarea>
				<div align=center><input type=submit name=atom_submit value="Add to history" class="elem"></div>
	</table>
		
</form>
}


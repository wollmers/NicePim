{
 name: products_complaint_history;

 body:
 <form method=post>
 <table class="maintxt" cellpadding=1 cellspacing=1 border=0 width="540" align=center  bgcolor="#999999">
   <tr>
		<td width="200" rowspan=2 valign=top bgcolor="#D8D8D8">
			<b>Editor</b>&nbsp;%%uname%%&nbsp;<br>
			<b>From</b>&nbsp;%%funame%%&nbsp;<br>
      <b>Status</b> %%status_id%%<br>
	    <i>Date %%date%%</i>
		</td>
		<td bgcolor="#EBEBEB">
		 <b>Subject</b> %%subject%%
		</td>
	 </tr>
	 <tr>
		<td bgcolor="#EBEBEB" valign=top>
		  <div align='justify'>%%message%%</div>
		</td>
	 </tr>
 </table>
 
 <input type=hidden name=complaint_id value=%%complaint_id%%>
 <input type=hidden name=userid value=%%userid%%>
 </table>
 <input type=hidden name=sessid value="%%sessid%%">
 <input type=hidden name=tmpl value="products_complaint_details.html">
 <input type=hidden name=command value="add_complaint_history">
 <div align=left class="maintxt" style="margin-left:120px">~<b>Response area:</b>~</div>
 <textarea class="" cols=64 rows=7 wrap="soft" name=new_msg>
 </textarea>
 <div align=right style="margin-right:127px"><input type=submit name=respond value="Add to history" class="elem"></div>
 </form>
}


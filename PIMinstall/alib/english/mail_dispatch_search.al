{
name: mail_dispatch_search;

body:

<form method=post>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				<nobr>MAIL SEARCH</nobr>
			</td>
      <td class="search">
				<input type=text class="smallform" name=search_dispatch_subject size=30 value="%%search_dispatch_subject%%">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value="mail_dispatch_log">
				<input type=hidden name=tmpl value="mail_dispatch_log.html">
				<input type=hidden name="new_search" value="1">
			</td>
      <td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
      <td class="search" style="width: 100%; padding-left: 10px;" align="right">
      </td>
		</tr>
	</table>

</form>

}

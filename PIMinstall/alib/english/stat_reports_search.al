{
name: stat_reports_search;

body:

<form method=post name='form_reports_search' id='form_reports_search'>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=stat_reports>
				<input type=hidden name=tmpl value="stat_queries.html">
				<input type=hidden name="new_search" value="1">
				
				<input type=hidden name=search_code_mode value=case_insensitive_like>
				<input type=hidden name=search_email_mode value=case_insensitive_like>
				code
			</td>
      <td class="search">
				<input type=text name=search_code id=search_code value="%%search_code%%" size="30" class="smallform">
			</td>
      <td class="search">
				email
			</td>
      <td class="search">
				<input type=text name=search_email id=search_email value="%%search_email%%" size="30" class="smallform">
			</td>
      <td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
      <td class="search" style="width: 100%; padding-left: 10px;" align="right"></td>
		</tr>
	</table>
			
</form>
}

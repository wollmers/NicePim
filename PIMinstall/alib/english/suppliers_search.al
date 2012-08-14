{
name: suppliers_search;

body:

<br />

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH BRANDS </td>

		<td class="search">
			<form method=post>
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=suppliers>
				<input type=hidden name=tmpl value="suppliers.html">
				<table cellspacing="0">
					<tr>
						<td>
							<input class="text" type=text name=search_name value="%%search_name%%" size=20>
							<input type=hidden name=search_name_mode value=like>
						</td>
						<td>
							<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
						</td>
					</tr>
				</table>
			</form>
		</td>

<!-- to be continued -->
}

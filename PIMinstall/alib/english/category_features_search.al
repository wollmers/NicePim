{
name: category_features_search;

body:
<br />

<form method=post>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				<nobr>FEATURE SEARCH</nobr>
			</td>
      <td class="search">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value="category_features">
				<input type=hidden name=tmpl value="cat_features.html">
				<input type=text name=search_name value="%%search_name%%" size=20>
			</td>
      <td class="search">
				<input type=hidden name=catid value="%%catid%%">
				<input type=hidden name=search_name_mode value=like>
			</td>
      <td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
			</td>
</form>

<td class="search" style="width: 100%; padding-left: 10px;" align="right">
	<a class="new-win" href="%%base_url%%;catid=%%catid%%;tmpl=cat_feature.html">New feature</a>
</td>

		</tr>
	</table>
	


}

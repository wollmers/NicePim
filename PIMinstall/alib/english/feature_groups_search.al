{
name: feature_groups_search;

body:

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
	<tr>
		<form method=post>
		
			<input type=hidden name=sessid value="%%sessid%%">
			<input type=hidden name=search_atom value=feature_groups>
			<input type=hidden name=tmpl value="feature_groups.html">
			<input type=hidden name=search_name_mode value=like>
			<input type=hidden name="new_search" value="1">
			
			<td class="search">
				<nobr>SEARCH GROUPS</nobr>
			</td>
			<td class="search">
				<input type=text name=search_name value="%%search_name%%" size=20>
			</td>
			<td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
			<td class="search" style="width: 100%; padding-left: 10px;" align="right">
				<a class="new-win" href="%%base_url%%;tmpl=feature_group.html">New feature group</a>
			</td>
		</form>
}

{
name: campaigns_search;

body:
<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
	<tr>
		<td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH CAMPAIGNS </nobr></td>
			<form method="post">

			<input type=hidden name=sessid value="%%sessid%%">
			<input type=hidden name=search_atom value="campaigns">
			<input type=hidden name=tmpl value="campaigns.html">
			<input type=hidden name="search_name_mode" value="like">
			<input type=hidden name="new_search" value="Search">

			<td class="search" align="right">Name<td><td><input type="text" name="search_name" class="text" value="%%search_name%%" /></td>
			<td class="search" align="left"><input class="hover_button" type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;"></td>
			</form>

<!-- to be continued -->
}

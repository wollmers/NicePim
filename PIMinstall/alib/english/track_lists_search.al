{
name: track_lists_search;

search_is_open_custom_select_value_0: 0;
search_is_open_custom_select_text_0:  Any;

search_is_open_custom_select_value_1: 1;
search_is_open_custom_select_text_1:  Open;

search_is_open_custom_select_value_2: zero;
search_is_open_custom_select_text_2:  Closed;


body:

<br/>

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH BY LIST </td>

		<td class="search">
			<form method="get">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=track_lists>
				<input type=hidden name=tmpl value="track_lists.html">
				<table cellspacing="0">
					<tr>
						<td>				
							Status\: %%search_is_open%%
							<input name="search_is_open_mode" value="digit" type="hidden">							
						</td>
						<td>
							Customer\: %%search_user_id%%
						</td>
						<td>
							Title\: <input type="text" name="search_name" value="%%search_name%%"/>
							<input name="search_name_mode" value="like" type="hidden">
						</td>
						
						<td>
							<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
						</td>
					</tr>
				</table>
			</form>
		</td>

}
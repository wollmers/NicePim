{
name: dictionaries_search;

search_active_custom_select_value_0: 0;
search_active_custom_select_text_0:  any state;
search_active_custom_select_value_1: 1;
search_active_custom_select_text_1:  enabled;
search_active_custom_select_value_2: zero;
search_active_custom_select_text_2:  disabled;


body:

<br />

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH DISTRIBUTORS </td>

		<td class="search">
			<form method=post>
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=dictionaries>
				<input type=hidden name=tmpl value="dictionaries.html">
				<table cellspacing="0">
					<tr>
						<td>
							<nobr>Name
							<input class="text" type=text name=search_name value="%%search_name%%" size=20>
							<input type=hidden name=search_name_mode value=like>
							</nobr>
						</td>
						<td>
							<nobr>Group
							%%search_dictionary_group_id%%							
							</nobr>
						</td>						
						
						<td>
							<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
						</td>
												
					</tr>
				</table>
			</form>
		</td>
    <td class="search" align="right" style="width:100%;padding-left:10px"><nobr>
    	<a href="%%base_url%%;tmpl=distributor_new.html" class="new-win">New Distributor</a></nobr>
    </td>
  </tr>
</table>
}
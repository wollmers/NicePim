{
name: distributors_search;

search_active_custom_select_value_0: 0;
search_active_custom_select_text_0:  any state;
search_active_custom_select_value_1: 1;
search_active_custom_select_text_1:  enabled;
search_active_custom_select_value_2: zero;
search_active_custom_select_text_2:  disabled;

search_direct_custom_select_value_0: 0;
search_direct_custom_select_text_0:  Any;
search_direct_custom_select_value_1: 1;
search_direct_custom_select_text_1:  Yes;
search_direct_custom_select_value_2: zero;
search_direct_custom_select_text_2:  No;

search_visible_custom_select_value_0: 0;
search_visible_custom_select_text_0:  Any;
search_visible_custom_select_value_1: 1;
search_visible_custom_select_text_1:  Yes;
search_visible_custom_select_value_2: zero;
search_visible_custom_select_text_2:  No;


body:

<br />

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH DISTRIBUTORS </td>

		<td class="search">
			<form method=post>
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=distributors>
				<input type=hidden name=tmpl value="distributors.html">
				<table cellspacing="0">
					<tr>
						<td>
							<nobr>Name
							<input class="text" type=text name=search_name value="%%search_name%%" size=20>
							<input type=hidden name=search_name_mode value=like>
							</nobr>
						</td>
						<td>
							<nobr>Code of group
							<input class="text" type=text name=search_group_code value="%%search_group_code%%" size=20>
							<input type=hidden name=search_group_code_mode value=like>
							</nobr>
						</td>
						<td/>
					</tr>
					<tr>						
						<td>
							<nobr>Catalog import
							%%search_active%%
							<input type=hidden name=search_active_mode value="digit"/>
							</nobr>
						</td>						
						<td>
							<nobr>Export allowed
							%%search_direct%%
							<input type=hidden name=search_direct_mode value="digit"/>
							Is visible %%search_visible%%
							<input type=hidden name=search_visible_mode value="digit"/>
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
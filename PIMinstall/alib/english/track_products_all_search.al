{
name: track_products_all_search;

search_rule_status_custom_select_value_0: 0;
search_rule_status_custom_select_text_0:  Any;
search_rule_status_custom_select_value_1: zero;
search_rule_status_custom_select_text_1:  New;
search_rule_status_custom_select_value_2: 2;
search_rule_status_custom_select_text_2:  Added;
search_rule_status_custom_select_value_3: 1;
search_rule_status_custom_select_text_3:  Canceled;

body:
<br/>
<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH BY RULES </td>

		<td class="search">
			<form method="get">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=track_products_all>
				<input type=hidden name=tmpl value="track_products_all.html">
				<input type=hidden name="track_list_id" value="%%track_list_id%%">
				<table cellspacing="0">
					<tr>
						<td>							
							Rule user\: %%search_rule_user_id%%
						</td>
						<td>							
							Mapped supplier\: %%search_supplier_id%%
						</td>
						<td>							
							List\: %%search_track_list_id%%
						</td>						
						<td>							
							Status\: %%search_rule_status%%
						</td>
						<td>							
							File's partnumber\: <input type="text" size="10" name="search_feed_prod_id" value="%%search_feed_prod_id%%"/>
							<input type="hidden" name="search_feed_prod_id_mode" value="like"/>
						</td>																		
																								
						<td>
							<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
						</td>
					</tr>
				</table>
			</form>
		</td>
</tr>
</table>
}
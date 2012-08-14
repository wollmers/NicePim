{
name: track_product_search;

search_track_product_status_custom_select_value_0: ;
search_track_product_status_custom_select_text_0:  Any;

search_track_product_status_custom_select_value_1: Described;
search_track_product_status_custom_select_text_1:  described;

search_track_product_status_custom_select_value_2: not_described;
search_track_product_status_custom_select_text_2:  Not described;

search_track_product_status_custom_select_value_3: Parked;
search_track_product_status_custom_select_text_3:  parked;

body:

<br/>

<table width="70%" align="center" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH BY LIST </td>

		<td class="search">
			<form method="get">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=track_products>
				<input type=hidden name=tmpl value="track_products.html">
				<input type=hidden name="track_list_id" value="%%track_list_id%%">
				<table cellspacing="0">
					<tr>
						<td>							
							Supplier\: %%search_supplier_id%%
						</td>
						<td>							
							Status\: %%search_track_product_status%%
						</td>
						<td>							
							Part Number\: <input type="text" size="10" name="search_map_partcode_tofind" value="%%search_map_partcode_tofind%%"/>
							<input type="hidden" name="search_map_partcode_tofind_mode" value="case_insensitive_like">
							
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

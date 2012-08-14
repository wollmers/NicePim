{
name: data_source_category_maps_search;

search_distributor_id_dropdown_empty: Any distributor;

body:
<form method="post">

	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				
				<input type="hidden" name="data_source_id" value="%%data_source_id%%">
				<input type="hidden" name="sessid" value="%%sessid%%">
				<input type="hidden" name="search_atom" value="data_source_category_maps">
				<input type="hidden" name="tmpl" value="data_source_category_maps.html">
				FOREIGN SYMBOL
			</td>
      <td class="search">
				<input type="text" name="search_symbol" value="%%search_symbol%%" size="20">
			</td>
      <td class="search">
				NATIVE SYMBOL
			</td>
      <td class="search">
				<input type="text" name="search_cat_name" value="%%search_cat_name%%" size="20">
				<input type="hidden" name="search_symbol_mode" value="case_insensitive_like">
				<input type="hidden" name="search_cat_name_mode" value="case_insensitive_like">
			</td>
      <td class="search">
				%%search_distributor_id%%
			</td>
      <td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
			
			<td class="search" style="width: 100%; padding-left: 10px;" align="right">
				<a class="new-win" href="%%base_url%%;tmpl=data_source_category_map.html;data_source_id=%%data_source_id%%">New map entry</a>
			</td>
	</table>

</form>
}

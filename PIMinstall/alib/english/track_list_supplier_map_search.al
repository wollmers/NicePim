{
name: track_list_supplier_map_search;


body:

<br/>

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"> SEARCH </td>

		<td class="search">
			<form method="post">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=track_list_supplier_map>
				<input type=hidden name=tmpl value="track_list_supplier_map.html">
				<table cellspacing="0">
					<tr>
						<td>
							Original brand\: <input type="text" name="search_symbol" value="%%search_symbol%%"/>
							<input name="search_symbol_mode" value="like" type="hidden">
						</td>
						<td>
							Client \: %%search_client_id%%
							<!--<input name="search_symbol_mode" value="like" type="hidden">-->
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
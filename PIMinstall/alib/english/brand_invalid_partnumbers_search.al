{
name:  brand_invalid_partnumbers_search;

search_supplier_id_dropdown_empty: Any brand;
search_user_id_dropdown_empty: Any owner;

body:

<form method=post name='form_brand_invalid_partnumbers_search' id='form_brand_invalid_partnumbers_search'>
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search" nowrap>
				<input type=hidden name="sessid" value="%%sessid%%">
				<input type=hidden name="search_atom" value="brand_invalid_partnumbers">
				<input type=hidden name="tmpl" value="brand_invalid_partnumbers.html">
				<input type=hidden name="new_search" value="1">
				<nobr>PRODUCT CODE</nobr>
			</td
      <td class="search">
				<input type=text name=search_prod_id id=search_prod_id value="%%search_prod_id%%" size="30" class="smallform">
			</td>
      <td class="search">
				%%search_supplier_id%%
			</td>
      <td class="search">
				%%search_user_id%%
			</td>
      <td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
      <td class="search" style="width: 100%; padding-left: 10px;" align="right"></td>
		</tr>
	</table>
			
</form>
}

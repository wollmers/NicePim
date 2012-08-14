{
name: product_maps_search;

search_supplier_id_dropdown_empty: Any brand;

body:
<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
	<form method="post">
		<tr>
      <td class="search">
				<nobr>MAPPING CODE</nobr>
			</td>
      <td class="search">
				<input type="text" class="smallform" name="search_code" size="30" value="%%search_code%%">
			</td>
      <td class="search">
				%%search_supplier_id%%
			</td>
      <td class="search">
				<input type="hidden" name="sessid" value="%%sessid%%">
				<input type="hidden" name="search_code_mode" value="like">
				<input type="hidden" name="search_atom" value="product_maps">
				<input type="hidden" name="tmpl" value="product_maps.html">
				<input type="hidden" name="new_search" value="1">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>

</form>

}

{
name: features_search;

search_measure_id_dropdown_empty: Any measure;

body:
<form method="post">

	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				
				<input type="hidden" name="sessid" value="%%sessid%%">
				<input type="hidden" name="search_atom" value="features">
				<input type="hidden" name="tmpl" value="features.html">
				
				%%search_measure_id%%
			</td>
      <td class="search">
				<input type="text" name="search_name" value="%%search_name%%" size="20">
			</td>
      <td class="search">
				<input type="hidden" name="search_name_mode" value="like">
			</td>
      <td class="search">	
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>

</form>
}

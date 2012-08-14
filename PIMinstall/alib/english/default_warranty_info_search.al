{
name: default_warranty_info_search;

body:

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
	<tr>
		<form method=post>
		
			<input type=hidden name="sessid" value="%%sessid%%">
			<input type=hidden name="search_atom" value="default_warranty_info">
			<input type=hidden name="tmpl" value="default_warranty_info.html">
			<input type=hidden name="new_search" value="1">
			
			<td class="search">
				<nobr>SEARCH WARRANTY INFO</nobr>
			</td>
			<td class="search">
			    Category
			    %%search_catid%%
			</td>
			<br>
			<td class="search">
			    Supplier<br>
				%%search_supplier_id%%
			</td>
			
			<td class="search">
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
			</td>
		</form>
}

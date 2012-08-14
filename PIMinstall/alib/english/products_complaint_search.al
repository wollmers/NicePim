{
name: products_complaint_search;

search_userid_dropdown_empty: Any editor;
search_status_id_dropdown_empty: Any status;
search_fuserid_dropdown_empty: Any sender;

body:
<form method=post name='search_form' id="search_form">
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td class="search">
				%%search_userid%%
			</td>
			<td class="search">
				%%search_fuserid%%
			</td>
			<td class="search">
				<input type=text class="smallform" name=search_subject size=20 value="%%search_subject%%">
			</td>
			<td class="search">
				%%search_status_id%%
			</td>
			<td class="search">
				<table><tr><td>ID<td><input type=text class="smallform" name=search_complaint_id size=6 value="%%search_complaint_id%%"></table>
			</td>
			<td class="search">
				%%search_internal_search%% 
			</td>
			<td class="search">
				
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">

				<input type=hidden name="new_search" value="1">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=search_atom value=products_complaint>
				<input type=hidden name=tmpl value="products_complaint.html">
				<input type=hidden name=command value="exec_clipboard_processing">
				<input type=hidden name=search_adv value="%%search_adv%%">				
			</td>
		</tr>
	</table>
	
</form> 	

}			

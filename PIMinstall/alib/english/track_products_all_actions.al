{
name: track_products_all_actions;

add_mapping: Add mapping;
delete: Delete;

apply_merge_body:
  <input type="checkbox" name="apply_merge" value="1">&nbsp;save red track_product_alls & drop black products<br><br>

body:
<form name=form2 method=post>
%%apply_merge_body%%
   <table cellspacing=1 border=0 cellpadding=1 bgcolor='#EBEBEB' width=100% class=maintxt>
    <tr bgcolor="#99CCFF"><td align=left colspan=3>&nbsp;&nbsp;&nbsp;<b>Group actions</b></td></tr>
		<tr bgcolor=white>
		 <!--<td width=20% align=right><input type='checkbox' name='add_mapping' value=1 class=smallform %%chown_disabled%%></td><td colspan=2>Add mappings</td>
		--></tr>
		<tr bgcolor=white>
		 <td width=20% align=right><input type='checkbox' id='_delete' name='delete' value=1></td><td colspan=2>Unset rule</td>		 
		</tr>
		<tr>
			<td width=20% align=right><input type='checkbox' id='_add_mapping' name='add_mapping' value=1></td><td colspan=2>Add rule</td>
		</tr>
  	<tr bgcolor=white>
		 <td align=right colspan=2><input type=submit name=atom_submit value="Complete action" 
		 class=smallform onClick="javascript:\{
			//document.form2.track_product_id_list.value = document.form.track_product_all_id_list.value;
			document.form2.action_group_track_poduct_all.value = 1;
			set_ids(document.getElementById('select_track_product_id'),document.form2.track_product_id_list);
			return delete_validation(document.form2,'rules','track_products_all_actions.html','track_products_all.html');
		\}"></td>
		</tr>
		</table>		
		<input type=hidden name=atom_name value="track_products_all_actions">
	  <input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=tmpl_if_success_cmd value="track_products_all.html">
		<input type=hidden name=tmpl value="track_products_all_actions.html">
		<!--<input type=hidden name=command value=product_track_product_all_group_action>-->
		<input type=hidden name=track_product_id_list value=>
		<input type=hidden name=clipboard_object_type value="track_product_all">
		<input type=hidden name=action_group_track_poduct_all value=>
		<input type=hidden name="command" value="track_product_all_group_action">				
		$$INCLUDE cli_actions.al$$
		
</form>

}
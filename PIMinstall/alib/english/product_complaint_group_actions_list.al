{
name: product_complaint_group_actions_list;

cat_div: ---;
any_cat: None;

status_list: Change status;
delete: Delete;

apply_merge_body:
  <input type="checkbox" name="apply_merge" value="1">&nbsp;save red complaints & drop black products<br><br>

body:
<form name=form2 method=post>
%%apply_merge_body%%
   <table cellspacing=1 border=0 cellpadding=1 bgcolor='#EBEBEB' width=100% class=maintxt>
    <tr bgcolor="#99CCFF"><td align=left colspan=3>&nbsp;&nbsp;&nbsp;<b>Group actions</b></td></tr>
		<tr bgcolor=white>
		 <td width=20% align=right><input type='checkbox' name='status_list' value=1 class=smallform %%chown_disabled%%></td>
		 <td>Change status</td><td>%%search_status_list%%</td>
		</tr>
		<tr bgcolor=white>
		 <td width=20% align=right><input type='checkbox' id='_delete' name='delete' value=1></td><td colspan=3>Delete</td>
		</tr>
  	<tr bgcolor=white>
		 <td align=right colspan=3><input type=submit name=atom_submit value="Complete action" 
		 class=smallform onClick="javascript:\{
			document.form2.complaint_id_list.value = document.form.complaint_id_list.value;
			delete_validation();
			document.form2.action_group_product_complaint.value = 1;
		\}"></td>
		</tr>
		</table>
		<input type=hidden name=atom_name value="product_complaint_group_actions_list">
	  <input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=tmpl_if_success_cmd value="products_complaint.html">
		<input type=hidden name=tmpl value="products_complaint_group_action_edit.html">
		<input type=hidden name=command value=product_complaint_group_action>
		<input type=hidden name=complaint_id_list value=>
		<input type=hidden name=clipboard_object_type value="complaint">
		<input type=hidden name=action_group_product_complaint value=>		
		$$INCLUDE cli_actions.al$$
		
</form>

}

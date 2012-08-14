{
name: track_products_actions;

unpark: Unpark;
park: Park;

park_cause_radio_text_1: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />Incorrect code
						 <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >Incorrect code.</span></td>;
park_cause_radio_value_1: prod_id;

park_cause_radio_text_2: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />No info available
					    <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >No info available.</span></td>;
park_cause_radio_value_2: noinfo;

park_cause_radio_text_3: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />Other
						 <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >Other.</span></td>;
park_cause_radio_value_3: other;

apply_merge_body:
  <input type="checkbox" name="apply_merge" value="1">&nbsp;save red track_products & drop black products<br><br>

body:
<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a href="%%base_url%%;mi=requests;tmpl=track_lists.html">User lists</a>
<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a href="%%base_url%%;mi=requests;tmpl=track_products.html;track_list_id=%%track_list_id%%">List</a>

<form name=form2 method=post>
%%apply_merge_body%%
   <table cellspacing=1 border=0 cellpadding=1 bgcolor='#EBEBEB' width=100% class=maintxt>   
    <tr bgcolor="#99CCFF"><td align=left colspan=3>&nbsp;&nbsp;&nbsp;<b>Group actions</b></td></tr>
		<tr bgcolor=white>
		 <!--<td width=20% align=right><input type='checkbox' name='add_mapping' value=1 class=smallform %%chown_disabled%%></td><td colspan=2>Add mappings</td>
		--></tr>
		<tr bgcolor=white>
		 <td width=20% align=right><input type='checkbox' id='_park' name='park' value=1></td><td colspan=2>
		 	<table cellpadding="0">
		 	<tr>
		 	<td>Park</td> 
			  <td>%%park_cause%%</td>
			 <td><textarea  cols="20" rows="5" id="is_parked_remarks" name="remarks">%%remarks%%</textarea></td>
			 </tr>
			</table>
		 </td>		 		 
		</tr>
		<tr>
			<td width=20% align=right><input type='checkbox' id='_unpark' name='unpark' value=1></td><td colspan=2>Unpark</td>
		</tr>		
  	<tr bgcolor=white>
		 <td align=right colspan=2><input type=submit name=atom_submit value="Complete action" 
		 class=smallform onClick="javascript:\{
			//document.form2.track_product_id_list.value = document.form.track_product_id_list.value;
			document.form2.action_group_track_poduct.value = 1;
			set_ids(document.getElementById('select_track_product_id'),document.form2.track_product_id_list);
			return delete_validation(document.form2,'rules','track_products_actions.html','track_products.html');
		\}"></td>
		</tr>
		</table>
		<input type=hidden name=atom_name value="track_products_actions">
	  <input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=tmpl_if_success_cmd value="track_products.html">
		<input type=hidden name=tmpl value="track_products_actions.html">
		<input type=hidden name=track_list_id value="%%track_list_id%%">
		<!--<input type=hidden name=command value=product_track_product_group_action>-->
		<input type=hidden name=track_product_id_list value=>
		<input type=hidden name=clipboard_object_type value="track_product">
		<input type=hidden name=action_group_track_poduct value=>
		<input type=hidden name="command" value="track_product_group_action">				
		$$INCLUDE cli_actions.al$$
		
</form>

}
{
name: user_authority;

cat_div: --;
any_cat: Any


$$INCLUDE actions2.al$$

body:

 <form method=post>

	<input type=hidden name=atom_name value="user_authority">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="user_auths.html">
	<input type=hidden name=tmpl value="user_auth.html">
	<input type=hidden name=edit_user_id value="%%edit_user_id%%">
	<input type=hidden name=user_authority_id value="%%user_authority_id%%">

  <table>
	 <tr>
	 <td><font color=red>*</font>~Brand~</td>
	 <td>%%supplier_id%%</td>
	 </tr>
	 <tr>
	 <td><font color=red>*</font>~Category~</td>
	 <td>%%catid%%</td>
	 </tr>

	 <tr>
	 <td><font color=red>*</font>~Rights~</td>
	 <td>%%right%%</td>
	 </tr>
	 <tr>
	 <td colspan=2 align=center>
	 %%update_action%% %%delete_action%%
	 %%insert_action%%
	 </td>
	 </tr>
	 

	</table>

</form>
}
{
name: contact;

$$INCLUDE actions2.al$$

body:
 <form method=post>

	<input type=hidden name=atom_name value="contact">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="auth.html">
	<input type=hidden name=tmpl value="user_contact.html">
	<input type=hidden name=edit_user_id value="%%edit_user_id%%">
	<input type=hidden name=contact_id value="%%contact_id%%">	
	<input type=hidden name=item value="%%item%%">	
	<input type=hidden name=command value="refresh_user_cid">


  <table>
	 <tr>
	 <td><font color=red>*</font>~Person~</td>
	 <td><input type=text name=person value="%%person%%" size=24></td>
	 </tr>

	 <td><font color=red>*</font>~Email~</td>
	 <td><input type=text name=email value="%%email%%" size=16></td>
	 </tr>

	 <td><font color=red></font>~Phone~</td>
	 <td><input type=text name=phone value="%%phone%%" size=16></td>
	 </tr>

	 <tr>
	 <td>~Country~</td>
	 <td>%%country_id%%</td>
	 </tr>

	 <td><font color=red></font>~City~</td>
	 <td><input type=text name=city value="%%city%%" size=16></td>
	 </tr>

	 <td><font color=red></font>~Street~</td>
	 <td><input type=text name=street value="%%street%%" size=24></td>
	 </tr>

	 <td><font color=red></font>~House number~</td>
	 <td><input type=text name=nbr value="%%nbr%%" size=6></td>
	 </tr>

	 <td><font color=red></font>~ZIP~</td>
	 <td><input type=text name=zip value="%%zip%%" size=26></td>
	 </tr>

	 <td><font color=red></font>~URL~</td>
	 <td><input type=text name=url value="%%url%%" size=16></td>
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
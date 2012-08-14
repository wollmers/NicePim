{
name:  supplier_url_edit;

$$INCLUDE actions2.al$$

country_dropdown_empty: International;

body:
<form method=post>
	
	<input type=hidden name=atom_name value="supplier_url_edit">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="supplier_edit.html">
	<input type=hidden name=tmpl value="supplier_url_edit.html">
	<input type=hidden name=id value="%%id%%">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	
	<br>
	
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
		
							<tr>
								<th class="main info_header" colspan="2">Brand URL details</th>
							</tr>
							
							<tr>
								<td class="main info_bold" align=right width=15%><span style="color: red;">*</span>~Url~</td>
								<td class="main info_bold"><input type=text size=50 name=url value="%%url%%" class=></td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~Country~</td>
								<td class="main info_bold">%%country%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align=right><span style="color: red;">*</span>~Language~</td>
								<td class="main info_bold">%%language%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align=right>~Description~</td>
								<td class="main info_bold"><textarea rows="7" cols="70" name=description value="%%description%%">%%description%%</textarea></td>
							</tr>
							<tr>
								<td class="main info_bold" colspan=2 align=center>
									%%update_action%% %%delete_action%%	%%insert_action%%
								</td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
    </td>
  </tr>
</table>

<br />

</form>
}

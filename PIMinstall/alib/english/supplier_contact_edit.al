{
name:  supplier_contact_edit;

$$INCLUDE actions2.al$$

country_id_dropdown_empty: International;
report_lang_dropdown_empty: Choose language;

option_Y: Yes;
option_N: No;

cat_div: ---;
any_cat: None;

body:

<form method=post>
	
	<input type=hidden name=atom_name value="supplier_contact_edit">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="supplier_edit.html">
	<input type=hidden name=tmpl_if_create_and_success_cmd value="supplier_contact_edit.html">
	<input type=hidden name=tmpl value="supplier_contact_edit.html">
	<input type=hidden name=id value="%%id%%">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	<input type=hidden name=contact_id value="%%contact_id%%">
	<input type=hidden name=supplier_contact_report_id value="%%supplier_contact_report_id%%">
	
	<br />
	
  <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td style="padding-top:10px">
				
        <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
          <tr>
            <td>
							
              <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								
								<tr>
									<th class="main info_header" colspan="2">Brand contact details</th>
								</tr>
								<tr>
									<td class="main info_bold" align=right width=20%>~Country~</td>
									<td class="main info_bold">%%country_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Position~</td>
									<td class="main info_bold"><input type=text size=50 name=position value="%%position%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span style="color: red;">*</span>~Person~</td>
									<td class="main info_bold"><input type=text size=50 name=person value="%%person%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Company~</td>
									<td class="main info_bold"><input type=text size=50 name=company value="%%company%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Zip code~</td>
									<td class="main info_bold"><input type=text size=50 name=zip value="%%zip%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~City~</td>
									<td class="main info_bold"><input type=text size=50 name=city value="%%city%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Street~</td>
									<td class="main info_bold"><input type=text size=50 name=street value="%%street%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Nbr~</td>
									<td class="main info_bold"><input type=text size=15 name=nbr value="%%nbr%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span style="color: red;">*</span>~Email~</td>
									<td class="main info_bold"><input type=text size=50 name=email value="%%email%%" ></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Telephone~</td>
									<td class="main info_bold"><input type=text size=50 name=telephone value="%%telephone%%" ></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Fax~</td>
									<td class="main info_bold"><input type=text size=50 name=fax value="%%fax%%" ></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Default manager~</td>
									<td class="main info_bold">%%default%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Send products acknowledges~</td>
									<td class="main info_bold">%%interval_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span style="color: red;">*</span>~Report language~</td>
									<td class="main info_bold">%%report_lang%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Report format~</td>
									<td class="main info_bold">%%report_format%%</td>
								</tr>
								<tr>
									<td class="main info_bold" colspan=2 align=center>
										<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
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

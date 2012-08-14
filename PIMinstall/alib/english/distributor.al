{
name: distributor;
$$INCLUDE actions2.al$$
country_id_dropdown_empty: UNDEF;
langid_dropdown_empty: UNDEF;

body:
<form method="post">
	<input type="hidden" name="atom_name" value="distributor">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="distributor_edit.html">
	<input type="hidden" name="tmpl" value="distributor_edit.html">
	<input type="hidden" name="distributor_id" value="%%distributor_id%%">
	<input type="hidden" name="command" value="update_remote_distributor">
	<input type="hidden" name="precommand" value="remove_distri_pricelist">
	
	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Name~</td>
									<td class="main info_bold">
										<input type="text" size="40" name="name" value="%%name%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Code~</td>
									<td class="main info_bold">
										%%code%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Group code~</td>
									<td class="main info_bold">
										%%group_code%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Trust level (%)</td>
									<td class="main info_bold">
										<input type="text" size="40" name="trust_level" value="%%trust_level%%">
									</td>
								</tr>

								<tr>
									<td class="main info_bold">Language</td>
									<td class="main info_bold">
										%%langid%%
									</td>
								</tr>
								
								<input type="hidden" id="source_name" value="%%source%%">
								<tr>
									<td class="main info_bold">Source</td>
									<td class="main info_bold">
										%%source%%
									</td>
								</tr>
								
								<input type="hidden" id="dist_sync" value="%%dist_sync%%">
								<tr id="ext_info_for_iceimport1">
									<td class="main info_bold">Synchronization</td>
									<td class="main info_bold">
										%%sync%%
									</td>
								</tr>
								
								<tr id="ext_info_for_iceimport2">
									<td class="main info_bold">Visibility</td>
									<td class="main info_bold">
										%%visible%%
									</td>
								</tr>
                                <input type="hidden" id="direct_value" value="%%direct_val%%">
								<tr>
									<td class="main info_bold">Export allowed<br/>
										(<span style="font-size: 7pt" >if enabled, the distributor will appear<br/> in the XML server 3 metaxml list</span>)
									</td>
									<td class="main info_bold">
										%%direct%%
									</td>
								</tr>

								<tr>
									<td class="main info_bold">Country</td>
									<td class="main info_bold">
										%%country_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Last import date</td>
									<td class="main info_bold">%%last_import_date%%</td>
								</tr>
								<tr>
									<td class="main info_bold">Import file creation date</td>
									<td class="main info_bold">%%file_creation_date%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan="2" align="center" id="test">
										<table>
											<tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%
										</table>
									</td>
								</tr>
								
								<tr>
									<td colspan="2">
									    <span style="color: red;"><br>%%soap_error%%<br></span>
	                                </td>
                                </tr>
                                
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>

<script language="JavaScript">
    var s = document.getElementById('source_name').value;
    var d = document.getElementById('direct_value').value;
    var sy = document.getElementById('dist_sync').value;
    
    if ( (s != 'iceimport') || ((s == 'iceimport') && (d != 1)) || (sy == "")) \{
        document.getElementById('ext_info_for_iceimport1').style.display = "none";
        document.getElementById('ext_info_for_iceimport2').style.display = "none";
    \}

</script>

}

{
name: distributor;
class: menu_edit;

body: <img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;distributor_id=%%distributor_id%%;tmpl=distributor_edit.html;">%%name%%</a>

}

{
name: distributor;
class: new;

name: distributor;
$$INCLUDE actions2.al$$
country_id_dropdown_empty: UNDEF;
langid_dropdown_empty: UNDEF;

body:
<form method="get">
	<input type="hidden" name="atom_name" id="distributor_atom_name" value="distributor">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="distributor_new.html">
	<input type="hidden" name="tmpl" value="distributor_new.html">
	<input type="hidden" name="distributor_id" value="%%distributor_id%%">
	<input type="hidden" name="distributor_pl_id" value="%%distributo_pl_id%%">
	<input type="hidden" name="precommand" value="set_distri_groupcode"/>
	
	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Name~</td>
									<td class="main info_bold">
										<input type="text" size="40" name="name" value="%%name%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Code~</td>
									<td class="main info_bold">
										%%code%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Group code~</td>
									<td class="main info_bold">
										%%group_code%%
									</td>
								</tr>								
								<tr>
									<td class="main info_bold">Trust level</td>
									<td class="main info_bold">
										<input type="text" size="40" name="trust_level" value="%%trust_level%%">
									</td>
								</tr>

								<tr>
									<td class="main info_bold">Language</td>
									<td class="main info_bold">
										%%langid%%
									</td>
								</tr>

								<tr>
									<td class="main info_bold">Is direct distributor?<br/>
										(<span style="font-size: 7pt" >if enabled, the distributor will appear<br/> in the XML server 3 metaxml list</span>)
									</td>
									<td class="main info_bold">
										%%direct%%
									</td>
								</tr>

								<tr>
									<td class="main info_bold">Country</td>
									<td class="main info_bold">
										%%country_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Last import date</td>
									<td class="main info_bold">%%last_import_date%%</td>
								</tr>
								<tr>
									<td class="main info_bold">Import file creation date</td>
									<td class="main info_bold">%%file_creation_date%%</td>
								</tr>
								<tr>
									<td colspan="2" style="text-align: center">%%update_action%% %%insert_action%%</td>									
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
</form>	
}

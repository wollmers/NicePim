{
name: relation_sets;

relation_include_set_row:
	$$INCLUDE relation_sets_row_source.al$$

relation_exclude_set_row:
<!--	$$INCLUDE relation_sets_row.al$$ -->

relation_include_set_2_row:
	$$INCLUDE relation_sets_row.al$$

relation_exclude_set_2_row:
	$$INCLUDE relation_sets_row.al$$


body:

$$INCLUDE relation_rules_js.al$$

<div id="page_content">

<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td align="left">
			$$INCLUDE products_link.html$$
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;tmpl=relation_groups.html">Relation groups</a>
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;tmpl=relation_rules.html;relation_group_id=%%relation_group_id%%">%%relation_group_name%%</a>
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;tmpl=relation_sets.html;relation_group_id=%%relation_group_id%%;relation_id=%%relation_id%%">%%relation_name%%</a>
		</td>
	</tr>
</table>

<br />

<span style="font-family: Verdana; font-size: 0.8em; color: #00AA00;">%%products2process_queue%%</span>

<div class="linksubmit" id="relation_rule_add_source_button" onClick="javascript\:enableSetAdding('%%sessid%%','source')" style="display: inline;">Add source rule</div>&nbsp;
<div class="linksubmit" id="relation_rule_add_destination_button" onClick="javascript\:enableSetAdding('%%sessid%%','destination')" style="display: inline;">Add destination rule</div>

<!-- abstract form for relation rules -->

$$INCLUDE relation_rule_abstract.al$$

<!-- lists -->

<h3>Source rule</h3>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" colspan="7">Included rules</th>
							</tr>
							
							$$INCLUDE relation_sets_header_source.al$$
							%%relation_include_set_rows%%
							
							<tr>
								<td colspan="10" align="left">&nbsp;</td>
							</tr>
							<!--        <tr>
													<td class="main info_bold" colspan="?" align="left"><b>Excluded rules</b></td>
							</tr>
							
							$$INCLUDE relation_sets_header.al$$
							-->
							%%relation_exclude_set_rows%%
							
							<tr>
								<td colspan="6" align="left">&nbsp;</td>
							</tr>
							
							<tr>
								<td colspan="5" align="right">Total # of source part products:</td><td align="center" style="color:red;"><b>%%set_amount%%</b></td><td></td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<h3>Destination rule</h3>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" colspan="12">Included rules</th>
							</tr>
							
							$$INCLUDE relation_sets_header.al$$
							%%relation_include_set_2_rows%%
							
							<tr>
								<td colspan="12" align="left">&nbsp;</td>
							</tr>
							<tr>
								<th class="main info_header" colspan="12">Excluded rules</th>
							</tr>
							
							$$INCLUDE relation_sets_header.al$$
							%%relation_exclude_set_2_rows%%
							
							<tr>
								<td colspan="12" align="left">&nbsp;</td>
							</tr>
							
							<tr>
								<td colspan="10" align="right">Total # of destination part products:</td><td align="center" style="color:red;"><b>%%set_amount_2%%</b></td><td></td>
							</tr>
							
							<tr>
								<td colspan="10" align="right">Total # of relations:</td><td align="center" style="color:red;"><b><script type="text/javascript">
											<!--
												 var a = %%set_amount%% -0;
												 var b = %%set_amount_2%% -0;
												 document.write(a*b);
												 // -->
								</script></b></td><td></td>
							</tr>
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

}

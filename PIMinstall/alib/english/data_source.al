{
name: data_source;

$$INCLUDE actions2.al$$

update_style_assorted_list_values: U, N;

update_style_value_U: Update all products
update_style_value_N: Add new products only

send_report_assorted_list_values: 1, 0;

send_report_value_1: Yes
send_report_value_0: No

body:

<form method="post">
	
	<input type="hidden" name="atom_name" value="data_source">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="data_sources.html">
	<input type="hidden" name="tmpl" value="data_source.html">
	<input type="hidden" name="data_source_id" value="%%data_source_id%%">
	
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
										<input type="text" size="20" name="code" value="%%code%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Send report to~</td>
									<td class="main info_bold">
										<input type="text" size="20" name="email" value="%%email%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">~Send report~</td>
									<td class="main info_bold">%%send_report%%
									</td>
								<tr>
									<td class="main info_bold">~Assigned user~</td>
									<td class="main info_bold">%%edit_user_id%%
									</td>
								<tr>
									<td class="main info_bold">~Update style~</td>
									<td class="main info_bold">%%update_style%%
									</td>
								<tr>
									<td class="main info_bold">~Configuration~</td>
									<td class="main info_bold"><textarea name="configuration" value="%%configuration%%" rows="6" cols="50">%%configuration%%</textarea>
									</td>
								</tr>
								<td class="main info_bold" colspan="2" align="center">
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
	
</form>
}

{
name: data_source;
class: menu_cat;

body: <img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;data_source_id=%%data_source_id%%;tmpl=data_source_category_maps.html;">%%code%%</a>

}

{
name: data_source;
class: menu_feat;

body: <img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;data_source_id=%%data_source_id%%;tmpl=data_source_feature_maps.html;">%%code%%</a>

}

{
name: data_source;
class: menu_edit;

body: <img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;data_source_id=%%data_source_id%%;tmpl=data_source.html;">%%code%%</a>

}

{
name: data_source;
class: menu_supp;

body: <img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu3" href="%%base_url%%;data_source_id=%%data_source_id%%;tmpl=data_source_supplier_maps.html;">%%code%%</a>

}

{
name: feature_values_vocabulary;

$$INCLUDE nav_inc.al$$

vocabulary_row: 
<tr>
	<td class="main info_bold" width="10%">&nbsp;%%no%%/%%found%%</td>
  <td class="main info_bold" width="30%">&nbsp;%%group_name%%</td>
  <td class="main info_bold" width="40%">&nbsp;<a href="%%base_url%%;tmpl=feature_value_edit.html;record_id=%%record_id%%">%%eng_value%%</a></td>
	<td class="main info_bold" width="20%">&nbsp;%%localized%%</td>
</tr>

body:
			
$$INCLUDE nav_bar2.al$$

<form method="post" name="form">
	<input type="hidden" name="search_clause" value="%%search_clause%%">
</form>

<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_feature_values_vocabulary_vocabulary=group_name,eng_value">Feature values group</a></th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_feature_values_vocabulary_vocabulary=eng_value,group_name">Feature value</a></th>
								<th class="main info_header">Localized</th>
							</tr>
							
							%%vocabulary_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

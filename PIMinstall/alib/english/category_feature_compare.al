{
name: category_feature_compare;

value_entry_format: <td class="main info_bold" style="vertical-align: top;">%%value%%&nbsp;</td>

category_feature_entry_format_0: <th class="main info_header"><span style="color: black;">%%name%%</span></th>
category_feature_entry_format_1: <th class="main info_header"><span style="color: gray;">%%name%%</span></th>

products_row: <tr bgcolor=white><td class="main info_bold"><a href="%%base_url%%;product_id=%%product_id%%;tmpl=product_details.html">%%prod_id%%</a></td>%%values%%</tr>

body:

<h3>%%category_name%% (%%ucatid%%) product feature comaprison table</h3>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">Part number/Features</th>
								
								%%category_features_header%%
								
							</tr>
							
							%%products_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

{
name: feature_utilizing_products_categories;

feature_prod_row: 
<tr>
  <td class="main info_bold">%%cat_name%%</td>
  <td class="main info_bold">%%supplier%%</td>
	<td class="main info_bold"><a href="%%base_url%%;product_id=%%product_id%%;tmpl=product_details.html;mi=products;">%%prod_id%%</a></td>
  <td class="main info_bold">%%value%%</td>
</tr>

feature_cat_row: 
<tr>
  <td><a class="linkmenu2" href="%%base_url%%;catid=%%catid%%;tmpl=cat_features.html;mi=cats">%%trace%%</a></td>
</tr>

cat_format: %%name%% >

body:

<h2>%%name%% (%%measure_name%%)</h2>

<h3>Feature utilizing products & categories</h3>

<table border="0" cellpadding="0" cellspacing="2" width="100%">
	%%feature_cat_rows%%
</table>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">Category</th>
								<th class="main info_header">Brand</th>
								<th class="main info_header">Part number</th>
								<th class="main info_header">Value</th>
							</tr>
							
							%%feature_prod_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

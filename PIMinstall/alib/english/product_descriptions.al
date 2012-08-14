{
name: product_descriptions;

$$INCLUDE nav_inc.al$$

products_row:
	
<tr>
	<td class="main info_bold">
		<a href="%%base_url%%;product_id=%%product_id%%;product_description_id=%%product_description_id%%;edit_langid=%%edit_langid%%;tmpl=product_description.html;supplier_id=%%desc_supplier_id%%;catid=%%desc_catid%%">%%short_desc%%</a>&nbsp;
	</td>
  <td class="main info_bold" align="center">
		<a href="%%base_url%%;product_id=%%product_id%%;product_description_id=%%product_description_id%%;edit_langid=%%edit_langid%%;tmpl=product_description.html">%%lang_name%%</a>
	</td>
	<td class="main info_bold" align="center">%%pd_updated%%
	</td>
</tr>

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th width="67%" class="main info_header">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_product_descriptions_products=short_desc;%%joined_keys%%">Short description</a>
								</th>
								<th width="15%" class="main info_header">
									<a href="%%base_url%%;tmpl=%%tmpl%%;order_product_descriptions_products=lang_name;%%joined_keys%%">Language</a>
								</th>
								<th width="28%" class="main info_header">Last update
								</th>
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


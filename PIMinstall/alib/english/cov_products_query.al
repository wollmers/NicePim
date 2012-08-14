{
name: cov_products_query;

search_supplier_id_dropdown_empty: any brand;
any_cat: any category;
cat_div: ---;
search_catid_recurse_default: Y;


body:

<form method=post name=cov>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="cov_products_reports.html">
	<input type=hidden name=atom_name value="cov_products_query">
	<input type=hidden name=tmpl_if_success_cmd value="cov_products_reports.html">	

	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="3">Product coverage report</th>
								</tr>

								<tr>
									<td class="main info_bold" align=right width="25%">Category</td><td class="main info_bold">%%search_catid%%</td>
									<td class="main info_bold" width="40%">%%show_subtotals%% include subcategories</td>
								</tr>

								<tr>
									<td class="main info_bold" align=right>Supplier</td><td class="main info_bold" colspan="2">%%search_supplier_id%%</td>
								</tr>

								<tr>
									<td class="main info_bold" align=right>On market</td><td class="main info_bold">%%search_distri_id%%&nbsp;&nbsp;%%on_stock%% on stock</td>
									<td class="main info_bold"><input type=submit name=reload value="Report"></td>
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

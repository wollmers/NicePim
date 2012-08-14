{
name: cov_features_query;

search_supplier_id_dropdown_empty: any brand;
search_catid_dropdown_empty: UNDEF;
search_catfeat_id_dropdown_empty: UNDEF;


body:
<form method=post name=cov>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="cov_features_reports.html">
	<input type=hidden name=atom_name value="cov_features_query">
	<input type=hidden name=tmpl_if_success_cmd value="cov_features_reports.html">	
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" align=right width="25%">Category</td>
									<td class="main info_bold">%%search_catid%%&nbsp;&nbsp;
										<input type=submit name=reload value="load category features" class=smallform>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Category feature</td><td class="main info_bold">%%search_catfeat_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Brand</td><td class="main info_bold">%%search_supplier_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>On market</td>
									<td class="main info_bold">%%search_distri_id%%&nbsp;&nbsp; %%on_stock%% on stock &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										
									</td>
								</tr>
								<tr>
									<td class="main info_bold">&nbsp;</td>								
									<td class="main info_bold">
										<input type=submit name=reload value="Report">
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

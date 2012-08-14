{
 name: categories;
 rows_number: 999999999;
	 
 tree_format: 
	 
	%%value%%

 tree_format_even: 
	%%value%%

 tree_multi_1: 10;
 
 tree_multi: 15;

 color_shift: #F5F5F5;
 color_no_shift: #FFFFFF;

 categories_row:
<tr bgcolor="#FFFFFF">
  <td class="main info_bold" width="500">
		<div style=" margin-left: %%tree_multi%%px;"><a class="link" href="%%base_url%%;tmpl=%%new_tmpl%%;%%cat_func%%=%%new_catid%%;">%%name%%</a></div>
	</td>
	<td class="main info_bold" align="center">
		&nbsp;&nbsp;<a class="link" href="%%base_url%%;tmpl=virtual_categories.html;catid=%%catid%%;">%%virtuals%%</a>
	</td>
  <td class="main info_bold" nowrap> 
        %%ucatid%%
  </td>
	<td class="main info_bold" align="center">
		<a class="link" href="%%base_url%%;tmpl=cat_features.html;catid=%%catid%%;">%%fcnt%%</a>
	</td>
	<td class="main info_bold" align="center">
		&nbsp;&nbsp;<a class="link" href="%%base_url%%;tmpl=cat_feature_groups.html;catid=%%catid%%;">Groups</a>
	</td>
	<td class="main info_bold" align="center">
		&nbsp;&nbsp;<a class="link" href="%%base_url%%;tmpl=cat_edit.html;catid=%%catid%%;">Details</a>
	</td>
	
</tr>

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="0" cellspacing="1" width="100%" align="center">
							<tr bgcolor="#FFFFFF"> 
								<td align="right" colspan="6">
									<a class="link" href="%%base_url%%;tmpl=cats.html;pcatid=%%top_catid%%;">To top</a>&nbsp;&nbsp;
								</td>
							</tr>
							
							<tr bgcolor="#FFFFFF">
								<th class="main info_header" width="500">Category</th>
								<th class="main info_header">Virtual<br>categories</th>
								<th class="main info_header">UNSPSC</th>
								<th class="main info_header">Features</th>
								<th class="main info_header">Groups</th>
								<th class="main info_header">Details</th>
								
							</tr>
							
							%%categories_rows%%

						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

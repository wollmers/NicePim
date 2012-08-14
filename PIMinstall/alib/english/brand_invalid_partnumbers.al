{
name: brand_invalid_partnumbers;

$$INCLUDE nav_inc.al$$

brand_invalid_partnumbers_row:
<tr align="center">
	<td class="main info_bold" nowrap>%%no%%/%%found%%</td>
  <td class="main info_bold" nowrap><a href="%%base_url%%;tmpl=product_details.html;product_id=%%product_id%%;cproduct_id=%%product_id%%">%%prod_id%%</a></td>
	<td class="main info_bold" nowrap><abbr title="%%prod_id_regexp%%">%%brand%%</abbr></td>
	<td class="main info_bold" style="text-align: left;"><div style="height: 16px; overflow: hidden;">%%name%%</div></td>
	<td class="main info_bold" nowrap>%%login%%</td>
	<td class="main info_bold" nowrap>%%product_id4distri%%</td>
</tr>

body:

$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th width="5%" class="main info_header" nowrap># / ##</th>
								<th width="10%" class="main info_header" nowrap><a href="%%base_url%%;tmpl=%%tmpl%%;order_brand_invalid_partnumbers_brand_invalid_partnumbers=prod_id">Part code</a></th>
								<th width="10%" class="main info_header" nowrap><a href="%%base_url%%;tmpl=%%tmpl%%;order_brand_invalid_partnumbers_brand_invalid_partnumbers=brand">Brand</a></th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_brand_invalid_partnumbers_brand_invalid_partnumbers=name">Name</a></th>
								<th width="10%" class="main info_header" nowrap><a href="%%base_url%%;tmpl=%%tmpl%%;order_brand_invalid_partnumbers_brand_invalid_partnumbers=login">Owner</a></th>
								<th width="15%" class="main info_header" nowrap>Distributor</th>
							</tr>
							
							%%brand_invalid_partnumbers_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

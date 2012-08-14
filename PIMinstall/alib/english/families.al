{
name: families;

families_row:	
<tr>
	<td class="main info_bold">
		%%no%%
	</td>
	<td class="main info_bold">
		%%family_name%%
	</td>
	<td class="main info_bold">
		%%category_name%%
	</td>
	<td class="main info_bold" align=center>
		<a href="%%base_url%%;tmpl=family_edit.html;family_id=%%family_id%%;supplier_id=%%supplier_id%%">Details</a></td>
	<td class="main info_bold" align=center>
		<a href="%%base_url%%;tmpl=series.html;supplier_id=%%supplier_id%%;family_id=%%family_id%%;catid=%%catid%%">Edit series(<b>%%series_count%%</b>)</a>
	</td>
</tr>

body:

<input type=hidden name=tmpl value="product_families.html">
<input type=hidden name=atom_name value="%%atom_name%%">
<input type=hidden name=sessid value="%%sessid%%">
<input type=hidden name=family_id value="%%family_id%%">

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">

			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>

						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="7%" bgcolor="#99CCFF">#/##</th>
								<th class="main info_header">
									<a href="%%base_url%%;tmpl=%%tmpl%%;family_id=%%family_id%%;order_families_families=family_name;%%joined_keys%%">Family name</a>
								</th>
								<th class="main info_header"></th>
								<th class="main info_header"></th>
								<th class="main info_header"></th>
							</tr>

							%%families_rows%%

						</table>

					</td>
				</tr>
			</table>

		</td>
	</tr>
</table>

}	

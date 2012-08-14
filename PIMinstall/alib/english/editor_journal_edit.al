{
name: editor_journal_edit;

$$INCLUDE nav_inc.al$$

editor_journal_edit_row:
<tr>
	<td class="main info_bold" width="" bgcolor="#FFFFFF" align="left">%%no%%</td>
	<td class="main info_bold" width="" bgcolor="#FFFFFF" align=>
		<a href="%%base_url%%;tmpl=product_details.html;product_id=%%product_id%%;cproduct_id=%%product_id%%">%%prodid%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%product%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%ean_codes%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%descriptions%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%features%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%related%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%bundled%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%objects%%</td>
	<td class="main info_bold" bgcolor="#FFFFFF" align="center">%%gallery%%</td>
</tr>

body:

<br />

<table width=100% border=0 class=maintxt cellpadding="0" cellspacing="0">
	<tr>
		<td><b>Overall:</b></td>
		<td>descriptions=%%summary_descriptions%% (%%summary_description_details%%)</td>
		<td>related=%%summary_related%%</td>
		<td>features=%%summary_features%%</td>
	</tr>
	<tr>
		<td>number of products=%%summary_product%%</td>
		<td>EAN codes=%%summary_ean_codes%%</td>
		<td>objects=%%summary_objects%%</td>
		<td>gallery=%%summary_gallery%%</td>
	</tr>
</table>

<br />

$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th width="1%" class="main info_header" align="center">#</th>
								<th class="main info_header" align="center">ProdID</th>
								<th class="main info_header" align="center">Product</th>
								<th class="main info_header" align="center">EAN codes</th>
								<th class="main info_header" align="center">Descriptions</th>
								<th class="main info_header" align="center">Features</th>
								<th class="main info_header" align="center">Related</th>
								<th class="main info_header" align="center">Bundled</th>
								<th width="7%" class="main info_header" align="center">Multimedia</th>
								<th class="main info_header" align="center">Gallery</th>
							</tr>

							%%editor_journal_edit_rows%%

						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$
}

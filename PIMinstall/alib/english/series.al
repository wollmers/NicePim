{
name: series;

series_row:
<tr>
	<td class="main info_bold">
		%%no%%
	</td>
	<td class="main info_bold" align=left>
		<a href="%%base_url%%;tmpl=series_edit.html;family_id=%%family_id%%;supplier_id=%%supplier_id%%;series_id=%%series_id%%;catid=%%catid%%">%%series_name%%</a></td>
</tr>

body:

<input type=hidden name=tmpl value="series_edit.html">
<input type=hidden name=atom_name value="%%atom_name%%">
<input type=hidden name=sessid value="%%sessid%%">
<input type=hidden name=family_id value="%%series_id%%">

<table align="center" width="50%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">

			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>

						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="7%" bgcolor="#99CCFF">#/##</th>
								<th class="main info_header">Series</th>
							</tr>

							%%series_rows%%

						</table>

					</td>
				</tr>
			</table>

		</td>
	</tr>
</table>

}

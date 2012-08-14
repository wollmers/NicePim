{
name: product_ean_codes;

$$INCLUDE actions2.al$$

ean_codes_row:
<tr>
	<form method="post">
		<td class="main info_bold">%%ean_code%%</td>
		<td class="main info_bold">%%ean_country%%&nbsp;</td>
		<td class="main info_bold">%%nickname%%</td>
		<td class="main info_bold">
			<input type="hidden" name="atom_name" value="product_ean_codes">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
			<input type="hidden" name="tmpl" value="product_details.html">
			<input type="hidden" name="product_id" value="%%product_id%%">
			<input type="hidden" name="ean_id" value="%%ean_id%%">
			<input type="hidden" name="ean_code" value="%%ean_code%%">
			<input type="hidden" name="command" value="add2editors_journal">
			%%delete_action%%
		</td>
	</form>
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
								<th class="main info_header" width="35%">EAN code</th>
								<th class="main info_header" width="45%">Country (EAN prefix)</th>
								<th class="main info_header" width="35%">Added by</th>
								<th class="main info_header" width="20%">Action</th>
							</tr>
							<tr>
								<form method="post">
									<td class="main info_bold"><input type="text" name="edit_ean_code" value="%%edit_ean_code%%"></td>
									<td class="main info_bold">&nbsp;</td>
									<td class="main info_bold">&nbsp;</td>
									<td class="main info_bold">
										<input type="hidden" name="atom_name" value="product_ean_codes">
										<input type="hidden" name="sessid" value="%%sessid%%">
										<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
										<input type="hidden" name="tmpl" value="product_details.html">
										<input type="hidden" name="product_id" value="%%product_id%%">
										<input type="hidden" name="command" value="add2editors_journal">
										%%insert_action%%
									</td>
								</form>
							</tr>
							%%ean_codes_rows%%
						</table>

					</td>
				</tr>
			</table>

		</td>
	</tr>
</table>
}

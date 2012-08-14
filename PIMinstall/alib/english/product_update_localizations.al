{
name: product_update_localizations;

localization_row:
<tr>
	<td class="main info_bold" align="center">%%no%%/%%nos%%<input type="hidden" name="row_%%no%%_item" value="%%product_id%%"><input type="hidden" name="row_%%no%%_item2" value="%%prod_id%%"></td>
	<td class="main info_bold" align="left"><nobr><input type="checkbox" name="row_%%no%%" id="%%no%%" value="1">&nbsp;%%prod_id%%</nobr></td>
	<td class="main info_bold" align="center">%%name%%</td>
</tr>

localization_disable_row:
<tr>
	<td class="main info_bold" align="center">&nbsp;</td>
	<td class="main info_bold" align="left"><nobr><input type="checkbox" disabled>&nbsp;%%prod_id%%</nobr></td>
	<td class="main info_bold" align="center">%%name%%</td>
</tr>

apply_submit:
<tr>
	<td class="main info_bold" colspan="3" align="center">
		<input type="hidden" name="atom_name" value="product_update_localizations">
		<input type="hidden" name="product_id" value="%%product_id%%">
		<input type="hidden" name="sessid" value="%%sessid%%">
		<input type="hidden" name="tmpl" value="product_details.html">
		<input type="hidden" name="command" value="preview_apply_localizations">
		<input type="hidden" name="last_row" value="%%nos%%">
		<input type="checkbox" name="change_owner" value="1" checked>&nbsp;change product's owner to yours
	</td>
</tr>
<tr>
	<td class="main info_bold" colspan="3" align="right">
		<input type="button" name="selectall" value="Select all" class="linksubmit" onClick="javascript:\{ for (i=1;i<=document.form.last_row.value;i++) \{ document.getElementById(i).checked=true; \} \};">
		<input type="submit" name="apply" value="Apply changes" class="linksubmit">
		<input type="button" name="unselectall" value="Clear selection" class="linksubmit" onClick="javascript:\{ for (i=1;i<=document.form.last_row.value;i++) \{ document.getElementById(i).checked=false; \} \};">
	</td>
</tr>

apply_void:
<tr>
	<td class="main info_bold" colspan="3" align="center"><font color="red">No matches!</font></td>
</tr>

localization_body:
%%localization_rows%%

apply_body:
%%apply_submit%%
%%apply_void%%

body:
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header">Part code</th>
								<th class="main info_header">Name</th>
							</tr>
							<form method="post" name="form">
								%%localization_body%%
								%%apply_body%%
							</form>
						</table>
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>
}

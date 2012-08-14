{
name: product_copy;

update_action: <input type=submit name=atom_update value="Copy">

body:

<h3>Copying product %%old_prod_id%%</h3>
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">

			<form method=post>
				
				<input type="hidden" name="atom_name" value="product_copy">
				<input type="hidden" name="sessid" value="%%sessid%%">
				<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
				<input type="hidden" name="tmpl" value="product_copy.html">
				<!--~Source product~-->	<input type="hidden" name="source_product_id" value="%%source_product_id%%">
				
				<!--~Brand~-->	<input type="hidden" name="supplier_id" value="%%supplier_id%%">
				<input type="hidden" name="catid" value="%%catid%%">
				<input type="hidden" name="launch_date" value="%%launch_date%%">
				<input type="hidden" name="obsolence_date" value="%%obsolence_date%%">
				<input type="hidden" name="name" value="%%name%%">
				<input type="hidden" name="edit_user_id" value="%%user_id%%">
				<input type="hidden" name="low_pic" value="%%low_pic%%">
				<input type="hidden" name="high_pic" value="%%high_pic%%">
				<input type="hidden" name="thumb_pic" value="%%thumb_pic%%">
				<input type="hidden" name="dname" value="%%dname%%">
				<input type="hidden" name="family_id" value="%%family_id%%">
				<input type="hidden" name="topseller" value="%%topseller%%">
				<input type="hidden" name="command" value="product_copy">
				
				<tr>
					<td class="main info_bold">~Destination part number~</td>
					<td class="main info_bold"><input type="text" size="30" name="prod_id" value="%%prod_id%%"></td>
				</tr>
				<tr>
					<td class="main info_bold">~Destination brand~</td>
					<td class="main info_bold">%%new_supplier_id%%</td>
				</tr>
				<tr>
					<td class="main info_bold" align="center">%%update_action%%</td>
					<td class="main info_bold">
						<table>
							<tr>
								<td width="30" valign="middle">
									<input type="checkbox" name="need_update" value="1" unchecked>
								</td>
								<td>update destination product from source<br />
									<span style="color: green;" class="linkmenu2">if destination product exists, its ownership won't change</span>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</form>
		</table>
		
    </td>
  </tr>
  </table>
	
  </td>
</tr>
</table>
}

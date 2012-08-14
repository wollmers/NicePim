{
name: user_brands;

supplier_id_new_dropdown_empty: Choose brand;

user_brands_row:
<tr>
  <td class="main info_bold" align="center">%%name%%</td>
  <td class="main info_bold" align="center">
		<form name="user_brand_new_%%supplier_id%%" id="user_brand_new_%%supplier_id%%" method="post">
			<input type="hidden" name=atom_name value="user_brands">
			<input type="hidden" name=sessid value="%%sessid%%">
			<input type="hidden" name=tmpl_if_success_cmd value="user_brands.html">
			<input type="hidden" name=tmpl value="user_brands.html">
			<input type="hidden" name=command value="user_brands_manage">
			<input type="hidden" name=edit_user_id value="%%edit_user_id%%">
			<input type="hidden" name=action value="del">
			<input type="hidden" name=supplier_id value="%%supplier_id%%">
			
			<a href="#" onClick="document.getElementById('user_brand_new_%%supplier_id%%').submit(); return false;">delete</a>
		</form>
	</td>
</tr>

body:

<table align="center" width="75%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>

            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
              <tr>
                <th class="main info_header" width="15%" colspan="2">
									"%%user_login%%" user account
								</th>
							</tr>
              <tr>
                <th class="main info_header" width="15%">
									Brand name
								</th>
                <th class="main info_header" width="15%">
									<form name="user_brand_new" id="user_brand_new" method="post">
										<input type="hidden" name=atom_name value="user_brands">
										<input type="hidden" name=sessid value="%%sessid%%">
										<input type="hidden" name=tmpl_if_success_cmd value="user_brands.html">
										<input type="hidden" name=tmpl value="user_brands.html">
										<input type="hidden" name=command value="user_brands_manage">
										<input type="hidden" name=edit_user_id value="%%edit_user_id%%">
										<input type="hidden" name=action value="add">

										%%supplier_id_new%%

										<a href="#" onClick="document.getElementById('user_brand_new').submit(); return false;" class="new-win" align="right">Add new brand</a>

									</form>
								</th>
              </tr>

              %%user_brands_rows%%

            </table>

          </td>
        </tr>
      </table>

    </td>
  </tr>
</table>

}

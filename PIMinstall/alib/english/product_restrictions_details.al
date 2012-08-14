{
name: product_restrictions_details;

$$INCLUDE actions2.al$$

rest_details_row:

<tr>
    <form type="post">
    <td class="main info_bold" align="center">
        %%product_id%%
    </td>
    <td class="main info_bold" align="center">
        %%prod_id%%
    </td>
    <td class="main info_bold" align="center">
        <input type="hidden" name="restriction_id" id="restriction_id" value="%%restriction_id%%">
        <input type="hidden" name="r_id" id="r_id" value="%%id%%">
        
        <input type="hidden" name="atom_name" value="product_restrictions_details">
        <input type="hidden" name="sessid" value="%%sessid%%">
        <input type="hidden" name="tmpl_if_success_cmd" value="product_restrictions_details.html">
        <input type="hidden" name="tmpl" value="product_restrictions_details.html">
        <input type="hidden" name="command" value="delete_certain_product_restriction">
        
        <input type="submit" name="delete_button" value="Delete">
    </td>
    </form>
</tr>

body:



<form method="post">
		<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr bgcolor="#FFFFFF">
    								<th class="main info_header" colspan="3">Insert new restricted products</th>
								</tr>
								<tr>
								    <td class="main info_bold" align="center">
								        <textarea style="width: 650px;" name="text_new" id="text_new" rows="7" ></textarea>
                                    </td>
                                    <td class="main info_bold" align="center">
                                        <input type="hidden" name="restriction_id" id="rest_id" value="%%restriction_id%%">
                                    
                                    	<input type="hidden" name="atom_name" value="product_restrictions_details">
                                    	<input type="hidden" name="sessid" value="%%sessid%%">
                                    	<input type="hidden" name="tmpl_if_success_cmd" value="product_restrictions_details.html">
                                    	<input type="hidden" name="tmpl" value="product_restrictions_details.html">
                                    	<input type="hidden" name="command" value="update_certain_product_restriction">
                                    	
                                        <input type="submit" name="add_button" onClick="return validate_new()" value="Add products">
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

    <br>
    Total restrictions %%rest_counter%%
    <br>

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr bgcolor="#FFFFFF">
    								<th class="main info_header" width="10%">Product ID</th>
								    <th class="main info_header" width="80%">Part number</th>
								    <th class="main info_header" width="10%">Delete Action</th>
								</tr>
								%%rest_details_rows%%
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

}


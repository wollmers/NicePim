{
name: product_restrictions;

$$INCLUDE actions2.al$$

restrictions_row:

<tr>
    <form type="post">
    <td class="main info_bold" align="center">
        %%n_supplier_id%%
    </td>
    <td class="main info_bold" align="center">
        %%n_langid%%
    </td>
    <td class="main info_bold" align="center">
        %%n_subscription_level%%
    </td>
    <td class="main info_bold" align="center">
        <a href="%%base_url%%;mi=suppliers;tmpl=product_restrictions_details.html;restriction_id=%%i_id%%">%%n_count%%</a>
    </td>
    <td class="main info_bold" align="center">
        <input type="hidden" name="rest_id" id="rest_id" value="%%i_id%%">
        
        <input type="hidden" name="atom_name" value="product_restrictions">
        <input type="hidden" name="sessid" value="%%sessid%%">
        <input type="hidden" name="tmpl_if_success_cmd" value="product_restrictions.html">
        <input type="hidden" name="tmpl" value="product_restrictions.html">
        <input type="hidden" name="command" value="delete_existed_product_restrictions">
        
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
    								<th class="main info_header" colspan="3">Insert new restriction rule</th>
								</tr>
								<tr>
								    <td class="main info_bold" align="left">
								        Brand<br>
								        %%new_supplier_id%%
								        <br>
								        Language<br>
								        %%new_langid%%
								        <br>
								        Subscription level<br>
								        %%new_subscription_level%%
								    </td>
								    <td class="main info_bold" align="center">
								        <textarea style="width: 650px;" name="text_new" id="text_new" rows="7" ></textarea>
                                    </td>
                                    <td class="main info_bold" align="center">
                                    
                                    	<input type="hidden" name="atom_name" value="product_restrictions">
                                    	<input type="hidden" name="sessid" value="%%sessid%%">
                                    	<input type="hidden" name="tmpl_if_success_cmd" value="product_restrictions.html">
                                    	<input type="hidden" name="tmpl" value="product_restrictions.html">
                                    	<input type="hidden" name="command" value="add_new_product_restrictions">
                                    	
                                        <input type="submit" name="add_button" onClick="return validate_new()" value="Add new">
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


	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr bgcolor="#FFFFFF">
    								<th class="main info_header" width="20%">Brand</th>
								    <th class="main info_header" width="20%">Language</th>
								    <th class="main info_header" width="20%">Access level</th>
								    <th class="main info_header" width="20%">Products</th>
								    <th class="main info_header" width="20%">Delete action</th>
								</tr>
								%%restrictions_rows%%
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
<script language="JavaScript">
    function validate_new() \{
    
        // alert("Access level should be specified");
        
        supplier = document.getElementById('new_supplier_id').value;
        langid = document.getElementById('new_langid').value;
        level = document.getElementById('new_subscription_level').value;
        
        // alert("(" + supplier + ")(" + langid + ")(" + level + ")" );
        
        if (supplier == '') \{
            alert("Brand should be specified");
            return false;
        \}
        if (level == '') \{
            alert("Access level should be specified");
            return false;
        \}
        if (langid == '') \{
            alert("Language should be specified");
            return false;
        \}
        
        return true;
    \}
    
    // set default value for access level
    aa = document.getElementById('new_subscription_level');
    aa.value = 1;
    
</script>

}


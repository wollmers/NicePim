{
name: default_warranty_info;

$$INCLUDE actions2.al$$

default_warranty_info_row:

<tr>

<form method="post">

    <td class="main info_bold" align="center">
        %%supplier_id%%
    </td>
    <td class="main info_bold" align="center">
        %%catid%%
    </td>
    <td class="main info_bold" align="center">
        %%w_text%%
    </td>
    <td class="main info_bold" align="center">
    
            <!-- edit button -->
    
            <input type="hidden" name="atom_name" value="default_warranty_info">
        	<input type="hidden" name="sessid" value="%%sessid%%">
        	<input type="hidden" name="tmpl" value="default_warranty_info_edit.html">
        	<input type="hidden" name="tmpl_if_success_cmd" value="default_warranty_info_edit.html">
        	<input type="hidden" name="supplier_id" value="%%supplier_id_num%%">
        	<input type="hidden" name="catid" value="%%catid_num%%">
        	
            <input type="submit" name="edit_button_%%id%%" value="Edit" style="width: 70px;">
</form>
            <br>
<form method="post">

            <!-- delete button -->
            
            <input type="hidden" name="atom_name" value="default_warranty_info">
            <input type="hidden" name="sessid" value="%%sessid%%">
            <input type="hidden" name="tmpl" value="default_warranty_info.html">
            <input type="hidden" name="tmpl_if_success_cmd" value="default_warranty_info.html">
            <input type="hidden" name="command" value="delete_default_warranty_info">
            <input type="hidden" name="supplier_id" value="%%supplier_id_num%%">
        	<input type="hidden" name="catid" value="%%catid_num%%">
        	
        	<input type="submit" name="delete_button_%%id%%" value="Delete" style="width: 70px;">
</form>
    </td>
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
    								<th class="main info_header" colspan="3">Insert new default warranty info</th>
								</tr>
								<tr>
								    <td class="main info_bold" align="left">
								        Brand<br>
								        %%add_supplier_id%%
								        <br>
								        Category
								        %%add_catid%%
								    </td>
								    <td class="main info_bold" align="center">
								        <input type="edit" style="width: 650px;" name="w_text_new" id="w_text_new">
                                    </td>
                                    <td class="main info_bold" align="center">
                                    
                                    	<input type="hidden" name="atom_name" value="default_warranty_info">
                                    	<input type="hidden" name="sessid" value="%%sessid%%">
                                    	<input type="hidden" name="tmpl_if_success_cmd" value="default_warranty_info.html">
                                    	<input type="hidden" name="tmpl" value="default_warranty_info.html">
                                    	<input type="hidden" name="command" value="insert_default_warranty_info">
                                    	
                                        <input type="submit" name="add_button" onClick="return validate_new()" value="Add">
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
	<!-- main list -->
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr bgcolor="#FFFFFF">
    								<th class="main info_header">Supplier</th>
								    <th class="main info_header">Category</th>
								    <th class="main info_header">English warranty info</th>
								    <th class="main info_header">Make new default</th>
								</tr>
								%%default_warranty_info_rows%%
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
<script language="JavaScript">
    function validate_new() \{
        
        sid = document.getElementById('add_supplier_id').value;
        cid = document.getElementById('add_catid').value;
        
        if (sid == 0) \{
            alert('You should specify brand for new default warrnty info');
            return false;
        \}
        if (cid == 0) \{
            alert('You should specify category for new default warrnty info');
            return false;
        \}
        
        txt = document.getElementById('w_text_new').value;
        
        if (txt.match("^\\s*$")) \{
            alert('You should specify non empty string for default warrnty info');
            return false;
        \}
        
        txt = txt.replace("^\\s+", '');
        txt = txt.replace("\\s+$", '');
        
        document.getElementById('w_text_new').value = txt;
        
        return true;
    \}
</script>
	
}



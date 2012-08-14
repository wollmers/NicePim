{
name: default_warranty_info_edit;

$$INCLUDE actions2.al$$

default_warranty_info_edit_row:

<tr>
    <td class="main info_bold" align="center">
        %%lang%%
    </td>
    
    <td class="main info_bold" align="center">
        <input type="edit" style="width: 650px;" name="w_text_%%langid%%" id="w_text_%%langid%%" value="%%text%%" >
    </td>
</tr>

body:

<form method="post">
	<input type="hidden" name="atom_name" value="default_warranty_info_edit">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="default_warranty_info_edit.html">
	<input type="hidden" name="tmpl" value="default_warranty_info_edit.html">
	<input type="hidden" name="command" value="update_default_warranty_info">
	
	<input type="hidden" name="catid" value="%%catid%%">
	<input type="hidden" name="supplier_id" value="%%supplier_id%%">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr bgcolor="#FFFFFF">
    								<th class="main info_header">Language</th>
								    <th class="main info_header">Text</th>
								</tr>
								%%default_warranty_info_edit_rows%%
								
								<tr>
								    <td colspan="2" class="main info_bold" align="center" >
    									<input class="hover_button" type="submit"
                                        style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_save.gif)
                                        no-repeat;' name="atom_update" value="." onClick="return check_english()" />
                                    <td>
								</tr>
								
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>

<script language="JavaScript">

    function check_english() \{
    
        txt = document.getElementById('w_text_1').value;
        
        if (txt.match("^\\s*$")) \{
            alert('English value should not be empty');
            return false;
        \}
        
        return true;
    \}

</script>

}


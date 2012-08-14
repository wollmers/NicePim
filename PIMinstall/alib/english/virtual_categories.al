{
name: virtual_categories;

$$INCLUDE actions2.al$$

virtual_categories_row:

<tr>
    <td class="main info_bold">%%name%%</td>  
    <td class="main info_bold" style="text-align: right;">
    <form method="post">
        <input type="hidden" name="atom_name" value="virtual_categories">
        <input type="hidden" name="sessid" value="%%sessid%%">
        <input type="hidden" name="virtual_category_id" value="%%virtual_category_id%%">
        <input type="hidden" name="tmpl" value="virtual_categories.html">
        <input type="hidden" name="catid" value="%%category_id%%">
        <input type="hidden" name="command" value="delete_from_virtual_category_table">
        <input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete.gif) no-repeat;' name="atom_delete" value="." onClick="var agree=confirm('Are you sure you wish to continue?'); if (agree) \{ return true; \} else \{ return false; \}"> 
    </form>                                                                                                                                              
    </td>
</tr>

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
    
    	<form method="post" onSubmit="vc_name_preprocessing()">
    	
                <input type="hidden" name="atom_name" value="virtual_categories">
                <input type="hidden" name="sessid" value="%%sessid%%">
                <input type="hidden" name="catid" value="%%catid%%">
                <input type="hidden" name="tmpl" value="virtual_categories.html">
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
			<tr>
			    <td nowrap="nowrap">New virtual category</td>
			    <td>
				<input type="text" name="new_name" id="new_name" value="">
			    </td>
			    <td>
			    	%%insert_action%%
			    </td>
			    <td width="100%">
			</tr>
		    </table>
		</form>

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
		    <tr>
		        <th class="main info_header" width="80%">Virtual category English name</th>
		        <th class="main info_header" width="20%"></th>
		    </tr>
			
			%%virtual_categories_rows%%
				
		    </table>		    
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<script type="text/JavaScript">
function vc_name_preprocessing() \{
    val = document.getElementById('new_name').value;
    val = val.replace(/^\s+/, '');
    val = val.replace(/\s+$/, '');
    if (val == '') \{
        alert('Empty virtual category name');
        return false;
    \}
    document.getElementById('new_name').value = val;
    return true;
\}
</script>

}

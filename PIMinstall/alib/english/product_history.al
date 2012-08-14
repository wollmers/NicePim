{
name: product_history;

product_history_row:

<tr>
	<td class="main info_bold" align="right">
	    <span style="%%h_row_format%%">
	        %%h_clever_date%%
	    </span>
	</td>
	
	<td class="main info_bold" align="right">
	    <span style="%%h_row_format%%">
	        %%h_date_abs%%
	    </span>
	</td>
	
	<td class="main info_bold" align="right">
    	<span style="%%h_row_format%%">
    	    %%h_user_name%%
    	</span>
	</td>
	
	<td class="main info_bold" align="right">
	    <span style="%%h_row_format%%">
    	    %%h_product_table%%
    	</span>
	</td>
	
	<td class="main info_bold" align="right">
	    <span style="%%h_row_format%%">
    	    %%h_action_type%%
    	</span>
	</td>
	
	<td class="main info_bold" align="right">
	    <span style="%%h_row_format%%">
    	    %%h_content_id%%
    	</span>
	</td>
</tr>

<!-- details -->
<tr>
    <td colspan="6">
        <span id="diff_span_%%h_id%%" style="display: none;">
        <div id="diff_container_%%h_id%%">
            %%h_changes%%
        </div>
        </span>
    </td>
</tr>

body:

<form method="post">

<!--
    There is no submit from this page

	<input type="hidden" name="atom_name" value="sector">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="sector_edit.html">
	<input type="hidden" name="tmpl" value="sector_edit.html">
	<input type="hidden" name="sector_id" value="%%sector_id%%">
	<input type="hidden" name="command" value="update_sector_name_table">
--> 
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
                            <tr bgcolor="#FFFFFF" >
                            <th class="main info_header">Time since previous update</th>
                            <th class="main info_header">Time stamp of update</th>
                            <th class="main info_header">User name</th>
                            <th class="main info_header">Type of changes</th>
                            <th class="main info_header">Action</th>
  					        <th class="main info_header">Changes</th>
							</tr>
							
							%%product_history_rows%%
							
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>


<script language="JavaScript">
    function showDiff(x) \{
    
        var id = x.id.replace(/^ej_/, "");
        div = document.getElementById('diff_container_' + id);
        
        if (document.getElementById('diff_span_' + id).style.display != 'block') \{
            document.getElementById('diff_span_' + id).style.display = "block";
        \}
        else \{
                document.getElementById('diff_span_' + id).style.display = "none";
        \}
        
        
        // alert(id);
    \}
</script>

}

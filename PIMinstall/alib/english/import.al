{
name: import;

languages_row:
     <tr>
        <td align="right" width="45%">
                <input type="checkbox" name="%%langid_id%%" value="true">
        </td>
        <td align="left" width="55%">
                %%langid_name%%
        </td>
     </tr>
;

body:

 <br />

<table width="100%">
<tr><td width="10%" valign="top" >
   <table width="150px" align="center" class="tabs">
     <td id="_export_btn" width="50%" style="background: #EBEBEB;" align="center" onClick="location.href='index.cgi?sessid=%%sessid%%;mi=groups;tmpl=feature_groups_exp_imp.html';">
	<font color='#1553A4'>Export</font>
     </td>
     <td id="_import_btn" width="50%" style="background: #AADDFF;" align="center" onClick="show('import');">
        <font color='#1553A4'>Import</font>
     </td>
   </table>	

</td></tr>
<tr><td width="100%" valign="top">

 <div id="_import">
   <form method="POST" enctype="multipart/form-data">
    	<table width="100%">
	  <tr>
	    <td width="100%" align="center">
	<!--	Import file: //-->
	    </td>	
	  </tr>
	  <tr>
	    <td>
			%%import%%
	    </td>
	  </tr>	
   	</table> 
 	<div style="display:%%button%%;" align="center"> <hr><input type="submit" value="Import" />
	<input type="button" name="null" value="Cancel" onClick="location.href='index.cgi?sessid=%%sessid%%;mi=groups;tmpl=feature_groups_exp_imp.html';"></p>
 	<input type="hidden" name=atom_name value="import">
 	<input type="hidden" name=sessid value="%%sessid%%">
 	<input type="hidden" name=tmpl_if_success_cmd value="import.html">
 	<input type="hidden" name=tmpl value="import.html">
    	<input type="hidden" name="temp" value="%%temp%%">	
	<input type="hidden" name=command value="get_obj_url,lang_import"></div>
   </form>
 </div>
</td></tr>
</table>
</div>
;

}


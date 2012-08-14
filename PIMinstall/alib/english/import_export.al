{
name: import_export;

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

<script type="text/javascript">
<!--

  function checked(type)
  \{
        document.getElementById("1").checked=type;
        document.getElementById("category_descript_flag").checked=type;
       	document.getElementById("2").checked=type;
        document.getElementById("feature_flag").checked=type;
        document.getElementById("feature_descript_flag").checked=type;
       	document.getElementById("3").checked=type;
       	document.getElementById("4").checked=type;
       	document.getElementById("5").checked=type;
       	document.getElementById("6").checked=type;
       	document.getElementById("7").checked=type;
        if (type) \{
            document.getElementById('feature_flag_container').style.display = 'block';
        \} else \{
            document.getElementById('feature_flag_container').style.display = 'none';
        \}

  \}

  function show(type)
  \{
	if (type == 'export')
	\{
		document.getElementById('_export').style.display='';
		document.getElementById('_import').style.display='none';
		document.getElementById('_export_btn').style.background='#AADDFF';
		document.getElementById('_import_btn').style.background='#EBEBEB';
	\}	
	if (type == 'import')
	\{
		document.getElementById('_export').style.display='none';
                document.getElementById('_import').style.display='';
                document.getElementById('_export_btn').style.background='#EBEBEB';
                document.getElementById('_import_btn').style.background='#AADDFF';
	\}
  \}

  checked(false);
//-->
</script>
 <br />

<table width="100%">
<tr><td width="10%" valign="top" >
   <table width="150px" align="center" class="tabs">
     <td id="_export_btn" width="50%" style="background: #AADDFF;" align="center" onClick="show('export');">
	<font color='#1553A4'>Export</font>
     </td>
     <td id="_import_btn" width="50%" style="background: #EBEBEB;" align="center" onClick="show('import');">
        <font color='#1553A4'>Import</font>
     </td>
   </table>	

</td></tr>
<tr><td width="100%" valign="top">

 <div id="_export">
 <form method="POST">
 <table width="100%" border="0">
  <tr>
  <td width="50" valign="top">
  
   <table width="100%" align="center" border="0">
   <tr>
  	<td colspan="2" align="center">
		<u>Choose exported tables:</u>
        </td>
   </tr>
   
   <tr>
        <td align="right" width="45%">
            <input id="1" type="checkbox" name="category" value="true">
        </td>
        <td align="left" width="55%">
            category
        </td>
   </tr>
   
   <tr>
        <td align="right" width="45%" >
            <input id="category_descript_flag" type="checkbox" name="category_descript_flag" value="true">
        </td>
        <td align="left" width="55%">
            category&nbsp;description
        </td>
    </tr> 
  
   <tr>
        <td align="right" width="45%">
            <input id="2" type="checkbox" name="feature" value="true" onClick="addElement(this)">               
        </td>
        <td align="left" width="55%">
            feature
        </td>
   </tr>        
   
    <!-- a flag for an improved export procedure -->        
    
    <tr>
        <td align="right" width="45%" >            
        </td>
        <td align="left" width="55%">
            <span id="feature_flag_container" style="display: none;">
                <input id="feature_flag" type="checkbox" name="feature_flag" value="true">
                    feature&nbsp;cat/f.group&nbsp;relations
            </span>
        </td>
    </tr>
      
    <tr>
        <td align="right" width="45%">
            <input id="feature_descript_flag" type="checkbox" name="feature_descript_flag" value="true">               
        </td>
        <td align="left" width="55%">
            feature&nbsp;description
        </td>
    </tr> 
     
      <tr>
        <td align="right" width="45%">
                <input id="3" type="checkbox" name="feature_group" value="true">
        </td>
        <td align="left" width="55%">
                feature_group
        </td>
      </tr>
      
      <tr>
        <td align="right" width="45%">
                <input id="4" type="checkbox" name="measure" value="true">
        </td>
        <td align="left" width="55%">
                measure
        </td>
      </tr>
      
      <tr>
        <td align="right" width="45%">
                <input id="5" type="checkbox" name="feature_values_vocabulary" value="true">
        </td>
        <td align="left" width="55%">
                feature_values_vocabulary
        </td>
      </tr>
      
      <tr>
        <td align="right" width="45%">
                <input id="6" type="checkbox" name="measure_sign" value="true">
        </td>
        <td align="left" width="55%">
                measure_sign
        </td>
      </tr>
      
      <tr>
        <td align="right" width="45%">
                <input id="7" type="checkbox" name="sector" value="true">
        </td>
        <td align="left" width="55%">
                sector
        </td>
      </tr>
      
      <tr height="45px">
         <td align="right" width="45%">
                
        </td>
        <td align="left" width="55%">
                <a href="javascript://" onClick="checked(true);"><small>Select all</small></a>    <a href="javascript://" onClick="checked(false);"><small>Clear selected</small></a>
        </td>	
      </tr>
      
    </table>
    
  <br />
   <table width="100%" align="center" border="0">
      <tr>
        <td align="center" width="100%">
               <u>Enter E-mail:</u>
        </td>
      </tr>
      <tr>
        <td align="center" width="50%">
               <input type="text" id="mail_control" name="mail" width="100%" value="" />
        </td>
      </tr>
   </table>

  </td> 
  <td width="50%">
   <table width="100%" align="left" border="0">
     <tr>
        <td colspan="2" align="center">
                <u>Choose languages:</u>
        </td>
     </tr>
     %%languages_rows%%
   </table>
  </td></tr>
  </table>

   <div align="center"><hr><input type="submit" value="Export" onClick="return checkEmail()"/></p>	
 <input type=hidden name=atom_name value="import_export">
 <input type=hidden name=sessid value="%%sessid%%">
 <input type=hidden name=tmpl_if_success_cmd value="feature_groups_exp_imp_ok.html">
 <input type=hidden name=tmpl value="feature_groups_exp_imp.html">
 <input type=hidden name=command value="lang_export">
 </div>
 </form> 
 </div>
 <div id="_import" style="display: none;">
   <form method="POST" enctype="multipart/form-data">
    	<table width="100%">
	  <tr>
	    <td width="100%" align="center">
		Import file:
	    </td>	
	  </tr>
	  <tr>
	    <td width="100%" align="center">
		<input type="file" name="import_file" />
 	    </td>
	  </td>
   	</table> 
 	<div style="%%button%%" align="center"> <hr><input type="submit" value="Import preview" /></p>
 	<input type="hidden" name=atom_name value="import_export">
 	<input type="hidden" name=sessid value="%%sessid%%">
 	<input type="hidden" name=tmpl_if_success_cmd value="import.html">
 	<input type="hidden" name=tmpl value="feature_groups_exp_imp.html">
	<input type="hidden" name=command value="get_obj_url,imp_prev"></div>
   </form>
 </div>
</td></tr>
</table>
</div>
;

<script type="text/JavaScript">
function addElement(x) \{
    if (x.checked) \{
        document.getElementById('feature_flag_container').style.display = 'block';
    \}
    else \{
        document.getElementById('feature_flag_container').style.display = 'none';
    \}
\}

/*
function addElement(x) \{
    switch (x.id) \{
        case "1":
            if (x.checked) \{
                document.getElementById('category_descript_flag_container').style.display = 'block';
            \} else if ( ! document.getElementById('category_descript_flag').checked) \{
                document.getElementById('category_descript_flag_container').style.display = 'none';
            \}
            break;
        case "2":
            if (x.checked) \{
                document.getElementById('feature_flag_container').style.display = 'block';
                document.getElementById('feature_descript_flag_container').style.display = 'block';
            \} else if ( ! document.getElementById('feature_descript_flag').checked) \{
                document.getElementById("feature_flag").checked=false;
                document.getElementById('feature_flag_container').style.display = 'none';
                document.getElementById('feature_descript_flag_container').style.display = 'none';
            \} else if (document.getElementById("feature_flag").checked)\{
                document.getElementById("feature_flag").checked=false;
            \}
            break;
        case "feature_flag":
            if ( x.checked) \{
                document.getElementById("2").checked=true;
            \}
    \}
\}
*/

function checkEmail() \{
    val = document.getElementById('mail_control').value;
    // alert(val);
    
    if (! val.match(/\w+\@\w+/)) \{
        alert('Wrong email');
        return false;   
    \} 
    else \{
        return true;
    \}
\}

</script>

}

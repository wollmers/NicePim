{
name: supplier_contact_product;

cat_div: ---;
any_cat: Any;

javascript_function: onchange="javascript:category_select(this)";
empty_family: Any;
empty_category: Any;

category_family:
<form name="form%%cat_fam_id%%" method="post">
	<tr>
		
		<td class="main info_bold" width="60%">&nbsp;&nbsp;%%category%%&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td class="main info_bold" width="30%">&nbsp;&nbsp;%%family%%&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td class="main info_bold" align="center">
			
			<input type=hidden name=atom_name value="supplier_contact_product">
			<input type=hidden name=sessid value="%%sessid%%">
			<input type=hidden name=tmpl_if_success_cmd value="supplier_contact_edit.html">
			<input type=hidden name=tmpl value="supplier_contact_edit.html">
			<input type=hidden name=supplier_id value="%%supplier_id%%">
			<input type=hidden name=id value="%%id%%">
			<input type=hidden name=cat_fam_id value=%%cat_fam_id%%>
			<input type=hidden name=command value="delete_category_family">
			
			<input type=submit name=del_cat_fam value=Delete class=smallform>
			
		</td>
	</tr>
</form>

body:

<script type="text/javascript">
<!--
function category_select(f) \{
	 var displayed = document.getElementById('displayed');
	 var subfamily = document.getElementById('subfam');
	 if (displayed.value != '') \{ 
 		var displayed_family = document.getElementById(displayed.value);
		displayed_family.style.display = 'none';
		subfamily.style.display = 'none';
	 \}
	 var family = document.getElementById(f.options[f.selectedIndex].value);
	 if (family) \{
		 family.style.display = 'block';
		 subfamily.style.display = 'block';
		 displayed.value = f.options[f.selectedIndex].value;
	\}
\}
// -->
</script>

<form name=form>
	<input type=hidden id=displayed value=''>
	<input type=hidden name=atom_name value="supplier_contact_product">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="supplier_contact_edit.html">
	<input type=hidden name=tmpl value="supplier_contact_edit.html">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	<input type=hidden name=id value="%%id%%">
	<input type=hidden name=command value="add_new_category_family">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td style="padding-top:10px">
				
        <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
          <tr>
            <td>
							
              <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								
								<tr>
									<th class="main info_header" colspan="3">Responsible products</th>
								</tr>

								<tr>
									<td class="main info_bold">%%catid%%</td>
									<td class="main info_bold" align=left>%%cat2family%%</td>
									<td class="main info_bold" align=right>&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit name=add_cat_fam value=Add></td>
								</tr>

								<tr>
									<td class="main info_bold" colspan=2><input type=checkbox name=inc_subcat checked style="display: inline;">&nbsp;Include sub categories&nbsp;&nbsp;&nbsp;</td>
									<td class="main info_bold"><span id=subfam style="display:none;"><input type=checkbox name=inc_subfam checked style="display: inline;">&nbsp;Include sub families</span></td>
								</tr>
							</table>

            </td>
          </tr>
        </table>

      </td>
    </tr>
  </table>
							
</form>

<br />

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							
							<tr>
								<th class="main info_header" width=60% align=center>Category</th>
								<th class="main info_header" width=30% align=center>Family</th>
								<th class="main info_header">Action</th>
							</tr>
							
							%%categories_families%%
							
						</table>
						
          </td>
        </tr>
      </table>
			
    </td>
  </tr>
</table>

<br />

}

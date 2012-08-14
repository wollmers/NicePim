{
name: suppliers;

$$INCLUDE nav_inc.al$$

suppliers_row: 
<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=supplier_edit.html;supplier_id=%%supplier_id%%">%%name%%</a></td>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=product_families.html;supplier_id=%%supplier_id%%;">~brands families~ (<b>%%family_count%%</b>)</a></td>
</tr>


body:
<!-- continuing -->

    <td class="search" align="right" style="width:100%;padding-left:10px"><nobr><a href="%%base_url%%;tmpl=supplier_edit.html" class="new-win">New brand</a></nobr></td>
  </tr>
</table>
			
$$INCLUDE nav_bar2.al$$
  
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
			
      <th class="main info_header" width="10%"># / ##</th>
			<th class="main info_header" width="60%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_suppliers_suppliers=name">Brand</a></th>
			<th class="main info_header" width="40%">Brands families</th>
		</tr>
		
		%%suppliers_rows%%
		
		</table>
		
    </td>
  </tr>
  </table>
	
  </td>
</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

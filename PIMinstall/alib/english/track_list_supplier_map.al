{
name: track_list_supplier_map;

track_list_supplier_map_row: 
<tr class="info_bold %%tr_color%%">
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%no%%/%%found%%</div></td>		
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%symbol%%</div></td>
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%login%%</div></td>
	<td class="main" style="height: 30px;" ><div style="height: 75%; overflow: hidden;">%%map_supplier_id%%</div></td>	
</tr>
rows_number:30;
supplier_ajax_link: 
	<div id="supplier_edit_%%track_list_supplier_map_id%%" style="display: inline; width: 200px;">
		<a class="divajax" style="text-decoration: underline" onClick="call('get_supplier_edit','tag_id=supplier_edit_%%track_list_supplier_map_id%%;track_list_supplier_map_id=%%track_list_supplier_map_id%%;foo=bar','sessid=%%sessid%%;tmpl=ajax_track_list_supplier_map.html;supplier_id=%%map_supplier_id%%');">%%supplier_name%%</a>
	</div>;
	
$$INCLUDE nav_inc.al$$
body:
<form method="post" name='form'> 
$$INCLUDE nav_bar2.al$$
	<input type="hidden" name="tmpl" value="track_products_all_mapping.html"/>
	<input type="hidden" name="atom_name" value="track_products_all_mapping"/>
	<input type="hidden" name="sessid" value="%%sessid%%"/>	
<table id="main_table" align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>
    <table id="main_table_info" border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
	
	<tr>
	<th class="main info_header">#/##</th>	
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_list_supplier_map_track_list_supplier_map=symbol">Original brand</a>
	</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_list_supplier_map_track_list_supplier_map=login">Client</a>
	</th>		
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_list_supplier_map_track_list_supplier_map=brand">ICEcat brand</a>
	</th>
	</tr>
				
	%%track_list_supplier_map_rows%%
		
	</table>
		
    </td>
  </tr>
  </table>
  </td>
</tr>
</table>
	$$INCLUDE nav_bar2.al$$
</form> 



}

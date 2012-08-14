{
name: track_lists;

link_to_import: <a href="%%base_url%%;tmpl=track_list.html;track_list_id=%%track_list_id%%">Import<br/></a>;
link_to_settings: <a href="%%base_url%%;tmpl=track_list_settings.html;track_list_id=%%track_list_id%%">Settings<br/></a>;
report_link: <a href="%%bo_host%%get_track_list_report.cgi?sessid=%%sessid%%;track_list_id=%%track_list_id%%" >Get report</a><br/>;
link_to_graphic: <a target="blank" href="%%base_url%%;tmpl=track_list_graph.html;track_list_id=%%track_list_id%%">Show stat</a><br/>;
link_to_entrusted: <a target="blank" href="%%base_url%%;tmpl=track_list_entrusted_editors.html;">Entrusted editors</a>;
link_to_add:  <a href="%%base_url%%;mi=track_lists;tmpl=track_list.html;track_list_id=">Add new list</a>;
link_to_rules: <a href="%%base_url%%;mi=track_lists;tmpl=track_products_all.html">Browse Part code rules</a><br/>; 
link_to_brand_map: <a target="blank" href="%%base_url%%;tmpl=track_list_supplier_map.html;">Brands mapping</a>;

$$INCLUDE nav_inc.al$$
rows_number:100;
track_lists_row: 
<tr>
  <td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=track_products.html;track_list_id=%%track_list_id%%">%%name%%</a></td>
  <td class="main info_bold">%%prods_count%%/%%prods_described%%</td>
  <td class="main info_bold"><span style="%%prods_desc_pers_color%%">%%prods_desc_pers%%%</span></td>
  <td class="main info_bold">%%processed_prods%%</td>
  <td class="main info_bold">%%goal_coverage%%%</td>  
  <td class="main info_bold"><a href="javascript:void(0)" onclick="get_track_list_editors(event,'%%sessid%%',%%track_list_id%%,'ajax_overlay_result_id',self,true)">%%count_editors%%</a></td>  
  <td class="main info_bold">%%deadline_date%%</td>
  <td class="main info_bold">%%eta%%</td>
  <td class="main info_bold">%%is_open%%</td>
  <td class="main info_bold">%%priority%%</td>
  <td class="main info_bold">%%login%%</td>
  <td class="main info_bold">%%link_to_settings%%%%link_to_import%%%%report_link%%%%link_to_graphic%%</td>
  	
</tr>


body:
<!-- continuing -->
<table>
<tr>
	<td>%%link_to_rules%%</td>
	<td>&nbsp;&nbsp;&nbsp;&nbsp;%%link_to_add%%</td>
	<td>&nbsp;&nbsp;&nbsp;&nbsp;%%link_to_entrusted%%</td>
	<td>&nbsp;&nbsp;&nbsp;&nbsp;%%link_to_brand_map%%</td>
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
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=name">Name</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=prods_count">All/Described</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=prods_desc_pers">Desc Perc</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=editors_descs_cnt">Processed</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=goal_coverage">Target coverage</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=count_editors">Editors</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=deadline_date">Deadline</a></th>
			<th class="main info_header">ETA</th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=is_open">Open</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=priority">Priority</a></th>
			<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_track_lists_track_lists=login">Requester</a></th>			
			
			<th class="main info_header"></th>
		</tr>
				
		%%track_lists_rows%%
		
		</table>
		
    </td>
  </tr>
  </table>
	
  </td>
</tr>
</table>

$$INCLUDE nav_bar2.al$$

}
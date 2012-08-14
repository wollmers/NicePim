{
name: ajax_track_list_supplier_map;

supplier_id_dropdown_empty: Any brand;
map_supplier_id_dropdown_JavaScript: onchange="track_list_set_brand_map(this,'%%sessid%%',%%track_list_supplier_map_id%%)";

body:
%%map_supplier_id%%
}
{
name: ajax_track_list_supplier_map;
class: return;
body:
	<div id="supplier_edit_%%track_list_supplier_map_id%%" style="display: inline; width: 200px;">
		<a class="divajax" style="color: blue" onClick="call('get_supplier_edit','tag_id=supplier_edit_%%track_list_supplier_map_id%%;track_list_supplier_map_id=%%track_list_supplier_map_id%%;foo=bar','sessid=%%sessid%%;tmpl=ajax_track_list_supplier_map.html;supplier_id=%%supplier_id_raw%%');">%%supplier_name%%</a>
	</div>;
}

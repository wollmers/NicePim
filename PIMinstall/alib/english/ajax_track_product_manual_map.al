{
name: ajax_track_product_manual_map;
body:
<div style="background-color: #D4EAF1; height: 100%">
	<div style="height: 100%">
		<div>Correct supplier:%%manual_supplier_id%%</div>
		<div>Correct partcode:<input type="text" id="manual_map_prod_id" size="30" value="%%manual_map_prod_id%%"/></div> 
		<div><input type="button" value="OK" id="set_map_pair_button_id" onclick="set_map_pair(event,'%%sessid%%',%%track_product_id%%,true)" /></div>
	</div>
	
</div>
}

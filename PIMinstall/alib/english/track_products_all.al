{
name: track_products_all;
rows_number:100;
$$INCLUDE clipboard_nav_link.al$$
rule_status_ok:  <img src="/img/track_lists/check.png"/>;
rule_status_new:  <a href="javascript:void(0)" onclick="add_rule('%%sessid%%',%%track_product_id%%,'rule_status_%%track_product_id%%',self)"><img src="img/track_lists/add.png" alt="Add"/></a>;
rule_status_canceled: <img src="img/button_cancel.png" alt="Canceled"/>;
rule_status_remove: <a href="javascript:void(0)" onclick="delete_rule('%%sessid%%',%%track_product_id%%,'rule_status_%%track_product_id%%',self)"><img src="img/track_lists/edit_remove.png" alt="Remove it"/></a>;
rule_status_icons: %%left_icon%%&nbsp;&nbsp;%%right_icon%%;
rule_change_right:  <span id="is_rule_confirmed_%%track_product_id%%">
						<a href="javascript:void(0)" onclick="get_rule_prod_id(event,'%%sessid%%','%%track_product_id%%','ajax_overlay_result_id',this,true,'track_products_all.html')" ><img src="/img/track_lists/arrow_right.png"/></a>
					</span>;
rule_change_left:  <span id="is_rule_confirmed_%%track_product_id%%">
						<a href="javascript:void(0)" onclick="get_rule_prod_id(event,'%%sessid%%','%%track_product_id%%','ajax_overlay_result_id',this,true,'track_products_all.html')" ><img src="/img/track_lists/arrow_left.png"/></a>
					</span>;
 
group_action_buttons:
<div align=right>
	<input style="display: inline;" type=submit name="action_selectall_track_product_all" value="Select all" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products_all.html';\}">
	<input style="display: inline;" type=submit name="action_group_track_product_all" value="Do group actions" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products_all_actions.html';\}">
	<input style="display: inline;" type=submit name="action_clear_track_product_all" value="Clear selection" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products_all.html';\}">
</div>	

track_products_all_row: 
<tr id="%%track_product_id%%_%%ajaxed%%" class="info_bold">
	<td class="main">
	 	<input name="row_%%no%%_item" type="hidden" value="%%track_product_id%%"/>
	 	<input type="%%button_type%%" onmouseover="selectCheckBox(event,this)" name="row_%%no%%" id="row_%%track_product_id%%" value="1" %%track_product_all_item_marked%%/>
	</td>	
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%no%%/%%found%%</div></td>
	<td class="main" style="height: 20px;" id="rule_status_%%track_product_id%%" >%%pattern%%</td>	
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%rule_supplier%%</div></td>	
	<td class="main" style="height: 20px;" ><div title="%%feed_prod_id%%" style="height: 75%; overflow: hidden;">%%feed_prod_id%%</div></td>
	<td class="main" style="height: 20px;" ><div title="%%current_user%%" style="height: 75%; overflow: hidden;">%%current_user%%</div></td>	
	<td class="main" style="height: 20px;" >%%rule_icon%%</td>	
	<td class="main" style="height: 20px;" ><div title="%%feature_user%%" style="height: 75%; overflow: hidden;">%%feature_user%%</div></td>
	<td class="main" style="height: 20px;" ><div title="%%rule_prod_id%%" style="height: 75%; overflow: hidden;">%%rule_prod_id%%</div></td>
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%rule_user%%</div></td>
	<td class="main" style="height: 20px;" ><div title="%%name%%" style="height: 75%; overflow: hidden;">%%name%%</div></td>	
	<td class="main" style="height: 20px;" ><div title="%%orig_name%%" style="height: 75%; overflow: hidden;">%%orig_name%%</div></td>
</tr>
body:

<input type="hidden" id="real_sessid" value="%%sessid%%"/>
<div id="clipboard_info" style="color: green;"></div>		
<form method="post" name='form'> 
$$INCLUDE nav_bar2_memorize.al$$
	<input type="hidden" name="tmpl" value="track_products_all.html"/>
	<input type="hidden" name="atom_name" value="track_products_all"/>
	<input type="hidden" name="sessid" value="%%sessid%%"/>
	<input type="hidden" name="clipboard_object_type" value="track_product_all"/>
	<input type="hidden" name="last_row" value="%%last_row%%"/>
	<input type="hidden" name="%%atom_name%%_start_row" id="clipboard_nav_link_start_row" value=""/>
<table id="main_table" align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>
    <table id="main_table_info" border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
	
	<tr>
	<th class="main info_header"></th>
	<th class="main info_header">#/##</th>
	<th class="main info_header">Status</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=rule_supplier">Mapped supplier</a>
	</th>	
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=feed_prod_id">File's Part Number</a>
	</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=current_user">Current user</a>
	</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=rule_icon">Map</a>
	</th>
	
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=feature_user">Feature user</a>
	</th>	
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=rule_prod_id">Rule Part Number</a>
	</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=rule_user">Rule's user</a>
	</th>	
	
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=name">Tracking list name</a>
	</th>
	<th class="main info_header">
		<a href="%%base_url%%;tmpl=%%tmpl%%;order_track_products_all_track_products_all=orig_name">Original name</a>
	</th>
	
	</tr>
				
	%%track_products_all_rows%%
		
	</table>
		
    </td>
  </tr>
  </table>
  </td>
</tr>
</table>
	$$INCLUDE nav_bar2_memorize.al$$	
	$$INCLUDE cli_actions.al$$
	
	%%group_action_buttons%%
</form> 

<div id="tmp_ajax_result" style="display: none;"></div>
<input type="hidden" id="ajax_call_status"/>
}

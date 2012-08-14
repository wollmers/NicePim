{
name: track_products;

add_product_link: <a target="blank" href="%%icecat_bo_hostname%%index.cgi?sessid=%%sessid%%;tmpl=product_details.html;product_id=;prod_id=%%prod_id%%;supplier_id=%%supplier_id%%;name=%%name%%;track_product_id=%%track_product_id%%"><img src="/img/track_lists/transp_pensil.png"/></a>;
edit_product_link: <a target="blank" href="%%icecat_bo_hostname%%index.cgi?sessid=%%sessid%%;tmpl=product_details.html;track_product_id=%%track_product_id%%;product_id=%%product_id%%"><img src="/img/track_lists/transp_pensil.png"/></a>;

map_prod_id_ok_html: <span id="is_rule_confirmed_%%track_product_id%%">
						<a href="javascript:void(0)" onclick="get_rule_prod_id(event,'%%sessid%%','%%track_product_id%%','ajax_overlay_result_id',this,true,'track_products.html')" >OK</a>
					</span>;
map_prod_id_approve_html: <span id="is_rule_confirmed_%%track_product_id%%">
							<a href="javascript:void(0)" onclick="get_rule_prod_id(event,'%%sessid%%','%%track_product_id%%','ajax_overlay_result_id',this,true,'track_products.html')">NO</a>
						  </span>;
$$INCLUDE clipboard_nav_link.al$$
rows_number:100;						  
track_products_row: 
<tr id="%%track_product_id%%_%%ajaxed%%" class="info_bold %%tr_color%%" >
	<td class="main" style="height: 20px;" ><div style="height: 75%; overflow: hidden;">%%no%%/%%found%%</div></td>
	<td class="main">
	 	<input name="row_%%no%%_item" type="hidden" value="%%track_product_id%%"/>
	 	<input type="%%button_type%%" name="row_%%no%%" id="row_%%track_product_id%%" onmouseover="selectCheckBox(event,this)" value="1" %%track_product_all_item_marked%%/>
	</td>	
	  	
	%%actions%%
  	%%supplier_name%%
  	%%feed_supplier%%
  	%%feed_prod_id%%
  	%%is_rule_confirmed%%
  	%%map_prod_id%%
	%%eans_joined%%	
  	%%name%%
  	%%remarks%%
  	
  	%%ext_col1%%
	%%ext_col2%%
	%%ext_col3%%
	%%extr_ean%%
	%%extr_login%%
	%%extr_langs%%
	%%extr_pdf_langs%%
	%%extr_man_langs%%
	%%extr_rel_count%%
	%%extr_date_added%%	
	%%extr_feat_count%%
	%%extr_quality%%
	%%changer%%
	
	
</tr>

group_action_buttons:
<div align=right>
	<input style="display: inline;" type=submit name="action_selectall_track_product" value="Select all" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products.html';\}">
	<input style="display: inline;" type=submit name="action_group_track_product" value="Do group actions" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products_actions.html';\}">
	<input style="display: inline;" type=submit name="action_clear_track_product" value="Clear selection" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'track_products.html';\}">
</div>	


body:

%%user_column_choice%%
<form method="post" name='form'> 
<input type="hidden" name="clipboard_object_type" value="track_product"/>
<input type="hidden" name="last_row" value="%%last_row%%"/>
<input type="hidden" name="%%atom_name%%_start_row" id="clipboard_nav_link_start_row" value=""/>
<input type="hidden" name="tmpl" value="track_products.html"/>
<input type="hidden" name="atom_name" value="track_products"/>
<input type="hidden" name="sessid" value="%%sessid%%"/>
<input type=hidden name="start_row_memory_custom" value="%%track_products_start_row%%"/>

<input type="hidden" id="real_sessid" value="%%sessid%%"/>		
$$INCLUDE nav_bar2_memorize.al$$

<div>Mandatory languages\: <b>%%manda_langs%%</b></div>
<div>List\: <b>%%tracklist_name%%</b></div>
<div>Additional information\: %%rules%%</div>
<div style="text-align: center;"><input type="button" value="adjust columns" onclick="show_columns_overlay()"/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input id="update_button_id" type="button" onclick="reload_products_page('%%sessid%%',%%track_list_id%%)" value="Update list"/></div>
<div id="clipboard_info" style="color: green;"></div>
<table id="main_table" align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <caption><a href="%%icecat_bo_hostname%%index.cgi?sessid=%%sessid%%;tmpl=track_list.html;track_list_id=%%track_list_id%%;">%%list_name%%</a></caption>
  <tr>
    <td>
    <table id="main_table_info" border="0" cellpadding="1" cellspacing="1" width="100%" align="center">
	
	<tr>
	<th class="main info_header">#/##</th>
	<th class="main info_header"></th>
	%%head_actions%%
  	%%head_supplier_name%%
  	%%head_feed_supplier%%
  	%%head_feed_prod_id%%
  	%%head_is_rule_confirmed%%
  	%%head_map_prod_id%%
	%%head_eans_joined%%	
  	%%head_name%%
  	%%head_remarks%%
  	
  	%%head_ext_col1%%
	%%head_ext_col2%%
	%%head_ext_col3%%
	%%head_extr_ean%%
	%%head_extr_login%%
	%%head_extr_langs%%
	%%head_extr_pdf_langs%%
	%%head_extr_man_langs%%
	%%head_extr_rel_count%%
	%%head_extr_date_added%%	
	%%head_extr_feat_count%%
	%%head_extr_quality%%
	%%head_changer%%
	
	</tr>
				
	%%track_products_rows%%
		
	</table>
		
    </td>
  </tr>
  </table>
<input type="hidden" id="track_list_id" value="%%track_list_id%%" />	
  </td>
</tr>
</table>
<!--form column hide choice  -->
<input type="hidden" id="sessid" value="%%sessid%%"/>
<input type="hidden" id="current_track_product_id" value=""/>
$$INCLUDE nav_bar2_memorize.al$$

$$INCLUDE cli_actions.al$$
%%group_action_buttons%%
</form>

}


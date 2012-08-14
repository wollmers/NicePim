{
name: product;

date_format:%d-%m-%Y;

default_login: None;

cutted_format: %%value%%...

cat_div: ---;
any_cat: None;

publish_A: Approved;
publish_Y: Yes;
publish_N: No;

public_L: Limited;
public_Y: Yes;

no_market_info: <b>No info</b>
market_color_green: <span style="color: green;">%%country_code%%</span>&nbsp;&nbsp;
market_color_black: <span style="color: black;">%%country_code%%</span>&nbsp;&nbsp;
market_color_gray: <span style="color: gray;">%%country_code%%</span>&nbsp;&nbsp;

$$INCLUDE actions2.al$$

gallery_pic_format: <img src="%%value%%" border="0" hspace="0" vspace="0">;

supplier_country_format: 
<tr bgcolor="#99CCFF">
 <td id="%%country_code%%">
	<span class="linksubmit" onclick="show_details('contact_%%country_code%%', 'img_%%country_code%%')"><img id="img_%%country_code%%" src="../../img/%%img%%" border="0"></span>
  <span class="linksubmit" onclick="show_details('contact_%%country_code%%', 'img_%%country_code%%')"><b>%%country%% contacts</b></span>
 </td>
</tr>
<tr bgcolor="#99CCFF">
 <td>
	<div id="contact_%%country_code%%" style="display:%%display%%">

table_begin: <table width="100%" class="maintxt" cellspacing="1" cellpadding="0" bgcolor='#EBEBEB'>;
table_end: </table>
div_end: </div></td></tr>

supplier_contact_format: 
<td width="35%" bgcolor="white">
&nbsp;&nbsp;&nbsp;&nbsp;%%position%%<br>
&nbsp;&nbsp;&nbsp;&nbsp;%%person%%
%%email%%
%%telephone%%</td>

supplier_contact_email: <br>&nbsp;&nbsp;&nbsp;&nbsp;<font color="green"><a href="mailto\:%%email%%">%%email%%</a></font>;
supplier_contact_tel: <br>&nbsp;&nbsp;&nbsp;&nbsp;tel\:<font color="brown"><i>%%telephone%%</i></font>

supplier_url_format: 
<td width="50%" bgcolor="white">
&nbsp;&nbsp;&nbsp;&nbsp;<a href='%%url_link%%'>%%url%%</a>(%%language%%)<br>
&nbsp;&nbsp;&nbsp;&nbsp;%%description%%</td>

supplier_country_empty: International;
supplier_contact_empty: <td bgcolor="white" width="35%"></td>;
supplier_url_empty: <td bgcolor="white" width="50%"></td>;
supplier_row_empty: </tr><tr bgcolor="white"><td colspan="3"><div></div></td></tr>;
supplier_contact_header1: <tr bgcolor='#EBEBEB' align="left"><td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<label class="smallform"><b>Contacts</b></label></td></tr>;
supplier_contact_header2: <tr bgcolor='#EBEBEB' align="left"><td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;<label class="smallform"><b>Urls</b></label></td></tr>;

supplier_det_link: <span class="linksubmit" onclick='show_details("supplier_details")'>Brand info</span>;

supplier_ajax_link: 
	<div id="supplier_edit" style="display: inline; width: 200px;">
		<a class="divajax" id="supplier_link" onClick="call('get_supplier_edit','tag_id=supplier_edit;foo=bar','sessid=%%sessid%%;tmpl=product_supplier_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;supplier_id=%%supplier_id%%');">%%supplier_name%%</a>
		<input type="hidden" name="supplier_id" value="%%supplier_id%%">
	</div>

category_ajax_link:
	<div id="category_edit" style="display: inline; width: 200px;">
		<a class="divajax" onClick="call('get_category_edit','tag_id=category_edit;foo=bar','sessid=%%sessid%%;tmpl=product_category_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;catid=%%catid%%');">%%category_name%%</a>
		<input type="hidden" name="catid" value="%%catid%%">
	</div>

product_original_row:
<tr>
  <td class="main info_bold">&nbsp;<span style="color: %%oactiveness%%;">%%odistri%%</span></td>
  <td class="main info_bold">&nbsp;%%oname%%</td>
  <td class="main info_bold">&nbsp;%%oprod_id%%</td>
  <td class="main info_bold">&nbsp;%%ocat%%</td>
  <td class="main info_bold">&nbsp;%%osupplier%%</td>
  <td class="main info_bold">&nbsp;<b>%%omappedorigsupplier%%</b></td>
  <td class="main info_bold">&nbsp;%%odist_prod_id%%</td>
</tr>

lang1_tab: <td nowrap id="tab_id_%%tab_id%%" bgcolor='white' onclick="white_bg('tab_id_%%tab_id%%');" style="cursor: pointer;">&nbsp;&nbsp;%%lang%%&nbsp;&nbsp;</td>;
lang2_tab: <td nowrap id="tab_id_%%tab_id%%" bgcolor='#AADDFF' onclick="white_bg('tab_id_%%tab_id%%');" style="cursor: pointer;">&nbsp;&nbsp;%%lang%%&nbsp;&nbsp;</td>;
lang_1: <font color="#1553A4" id="lang_tab_id_%%tab_id%%">%%lang1%%</font>;
lang_2: <font color="#1553A4" id="lang_tab_id_%%tab_id%%">%%lang2%%</font>;

javascript:
<script type="text/javascript">
<!--
	function getLoading() \{
		return "<img src='./img/ajax-loader.gif' style='padding: 2px;'/>";
	\}

function white_bg(id, prefix) \{
 var tabs_col = %%tabs_col%%;
 var tab_id = 'tab_id_'; var lang_id = 'lang_'; var bgcolor = "#AADDFF"; var color = "#1553A4"; 
 var div_id = 'name_';
 if(prefix)\{ 
	tab_id = prefix + tab_id; id = prefix + id; bgcolor = "#AADDFF"; color = "#1553A4";
	div_id = 'id_';
 \}
 for (var i = 0; i < tabs_col; i++)\{
	var tab = document.getElementById(tab_id + i);
	if (tab) \{
	tab.style.background = "white";
	var lang = document.getElementById(lang_id + tab_id + i);
	lang.style.color = "#1553A4";
	var div = document.getElementById(div_id + tab_id + i);
	div.style.display = 'none';
	\}
 \}
 var  tab = document.getElementById(id);
 tab.style.background = bgcolor;
 var  lang = document.getElementById(lang_id + id);
 lang.style.color = color;
 var div = document.getElementById(div_id + id);
 div.style.display = 'block';
	if ((id != 'feat_tab_id_0')&&(prefix == 'feat_')) \{
	div.innerHTML = "<center>"+getLoading()+"</center>";
	\}
\}
// -->
</script>

product_name:
<div style="display: none;" id="name_tab_id_%%tab_id%%">
	<table cellspacing="0" cellpadding="5" width="100%" bgcolor="#C0DDFF">
		<tr>
			<td width="20%" align="right">
				<span style="color: red;">*</span>Model name
			</td>
			<td>
				<input type="text" name="value_tab_%%tab_id%%" value="%%tab_name%%" size="80">
			</td>
		</tr>
	</table>
</div>

body:

 %%javascript%%
 
 <form method="post" enctype="multipart/form-data">

	<input type="hidden" name="atom_name" value="product">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_details.html">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="old_catid" value="%%old_catid%%">
	<input type="hidden" name="edit_user_group" value="%%edit_user_group%%">
	<input type="hidden" name="track_product_id" value="%%track_product_id%%">	
	<input type="hidden" name="command" value="insert_tab_name,chown_nobody_products,product_delete_daemon,change_product_category,get_obj_url,update_xml_due_product_update,update_score,add2editors_journal,product2vendor_notification_queue,update_virtual_categories_for_product,update_track_product">
	<input type="hidden" name="precommand" value="store_pics_origin,save_values_for_history_product">
	
	<div id="supplier_details" style="display:none">
	<label class="maintxt"><h3>%%supplier_name%% info</h3></label>
	 <table width="100%" class="maintxt" cellspacing="1" cellpadding="0" bgcolor='#EBEBEB'>
	 %%supplier_contacts%%</div>
	 </table>
	</div>

$$INCLUDE product_general.al$$

}

{
name: product;
class: new;

publish_Y: Yes;
publish_N: No;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

supplier_ajax_link: 
	<div id="supplier_edit" style="display: inline; width: 200px;">
		<a class="divajax" onClick="call('get_supplier_edit','tag_id=supplier_edit;foo=bar','sessid=%%sessid%%;tmpl=product_supplier_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;supplier_id=%%supplier_id%%');">%%supplier_name%%</a>
		<input type="hidden" name="supplier_id" value="%%supplier_id%%">
	</div>

category_ajax_link:
	<div id="category_edit" style="display: inline; width: 200px;">
		<a class="divajax" onClick="call('get_category_edit','tag_id=category_edit;foo=bar','sessid=%%sessid%%;tmpl=product_category_choose_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;catid=%%catid%%');">%%category_name%%</a>
		<input type="hidden" name="catid" value="%%catid%%">
	</div>

$$INCLUDE actions2.al$$

body:

 <form method="post" enctype="multipart/form-data">

	<input type="hidden" name="atom_name" value="product">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_new.html">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="track_product_id" value="%%track_product_id%%">
	
	<input type="hidden" name="command" value="insert_tab_name,chown_nobody_products,product_delete_daemon,change_product_category,get_obj_url,update_xml_due_product_update,update_score,add2editors_journal,product2vendor_notification_queue,update_virtual_categories_for_product,update_track_product">
	<input type="hidden" name="precommand" value="store_pics_origin,save_values_for_history_product">
	
$$INCLUDE product_general.al$$

}

{
name: product;
class: brief;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

low_pic_format: <img src="%%value%%" border="0" hspace="0" vspace="0" />


body:
<!-- continuing -->

  </tr>
</table>

<br />

	<table border="0" width="100%" cellpadding="0" cellspacing="0" align="center">
		<tr>
			<td>
				<span style="font-size: 16px; font-weight: bold;">%%prod_id%% product details</span>
			</td> 
			<td>
				%%low_pic_formatted%%<br />
			</td>
		</tr>
	</table>
}
	
{
name: product;
class: brief2;

date_format:%d-%m-%Y;

default_login: None;

cat_div: ---;
any_cat: None;

low_pic_format: <img src="%%value%%" border="0" hspace="0" vspace="0" />


body:

	<table border="0" width="100%" cellpadding="0" cellspacing="0" align="center">
		<tr>
			<td>
				<span style="font-size: 24px;">%%prod_id%% product details</span>
			</td> 
			<td>
				%%low_pic_formatted%%<br />
			</td>
		</tr>
	</table>
}

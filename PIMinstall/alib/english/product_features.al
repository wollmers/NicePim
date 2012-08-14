{
name: product_features;

$$INCLUDE feature_def.al$$
$$INCLUDE nav_inc.al$$
$$INCLUDE actions2.al$$

product_features_row_group:
<tr>
	<td colspan="3" class="main info_header">%%group_name%%</td>
</tr>

product_features_row:
%%product_features_row_group%%

<tr>
	<td width="48%" class="main info_bold" align="right">
		<input type="hidden" name=_rotate_category_feature_id_%%category_feature_id%% value="%%category_feature_id%%">
		<input type="hidden" name=_rotate_searchable_%%category_feature_id%% value="%%searchable%%">
		<input type="hidden" name=_rotate_feature_name_%%category_feature_id%% value="%%feature_name_value%%">
		<input type="hidden" name=_rotate_product_feature_id_%%category_feature_id%% value="%%_rotate_product_feature_id_%%category_feature_id%%%%">
		<input type="hidden" name=_rotate_cat_feat_mandatory_%%category_feature_id%% value="%%cat_feat_mandatory%%">
		<input type="hidden" id="hidden_tab_id" name="hidden_tab_id" value="0">
		%%cat_feat_mandatory_star%%%%feature_name%%</td>
  <td width="42%" class="main info_bold">%%_rotate_value_%%category_feature_id%%%%</td>
	<td width="10%" class="main info_bold">&nbsp;%%sign%%</td>
</tr>

product_features_row_textarea:
%%product_features_row_group%%

<tr>
	<td width="90%" class="main info_bold" align="right" colspan="2">
		<input type="hidden" name=_rotate_category_feature_id_%%category_feature_id%% value="%%category_feature_id%%">
		<input type="hidden" name=_rotate_searchable_%%category_feature_id%% value="%%searchable%%">
		<input type="hidden" name=_rotate_feature_name_%%category_feature_id%% value="%%feature_name_value%%">
		<input type="hidden" name=_rotate_product_feature_id_%%category_feature_id%% value="%%_rotate_product_feature_id_%%category_feature_id%%%%">
		<input type="hidden" name=_rotate_cat_feat_mandatory_%%category_feature_id%% value="%%cat_feat_mandatory%%">
		<input type="hidden" id="hidden_tab_id" name="hidden_tab_id" value="0">
		<table border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="td-darknoborder" align="left">
					%%cat_feat_mandatory_star%%%%feature_name%%<br>%%_rotate_value_%%category_feature_id%%%%
				</td>
			</tr>
		</table>
	</td>
	<td width="10%" class="main info_bold">&nbsp;%%sign%%</td>
</tr>

product_feature_name_00:<span style="color: black;">%%value%%</span>
product_feature_name_10:<span style="color: gray;">%%value%%</span>
product_feature_name_01:<span style="color: green;">%%value%%</span>
product_feature_name_11:<span style="color: green;">%%value%%</span>

mandatory_star:<span style="color: red">*</span>

lang1_tab: <td id=feat_tab_id_%%tab_id%% bgcolor="white" onclick="call('get_local_feature','tag_id=id_feat_tab_id_%%tab_id%%;foo=bar','sessid=%%sessid%%;tmpl=product_features_local_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;langid=%%tab_id%%;lang_tab=%%tab_id%%');white_bg('tab_id_%%tab_id%%', 'feat_');" style="cursor: pointer;">&nbsp;&nbsp;%%lang%%&nbsp;&nbsp;</td>;
lang2_tab: <td id=feat_tab_id_%%tab_id%% bgcolor="#AADDFF" onclick="call('get_local_feature','tag_id=id_feat_tab_id_%%tab_id%%;foo=bar','sessid=%%sessid%%;tmpl=product_features_local_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;langid=%%tab_id%%;lang_tab=%%tab_id%%');white_bg('tab_id_%%tab_id%%', 'feat_');" style="cursor: pointer;">&nbsp;&nbsp;%%lang%%&nbsp;&nbsp;</td>;

lang_1: <font color="#1553A4" id="lang_feat_tab_id_%%tab_id%%">%%lang1%%</font>;
lang_2: <font color="#1553A4" id="lang_feat_tab_id_%%tab_id%%">%%lang2%%</font>;
 
div_format:    
<tr>
	<td colspan=8>
		<div style="display: none;" id="id_feat_tab_id_%%tab_id%%">
		</div>
</td></tr>

split_columns:
	</table>
</td>
<td width="50%">
	<table class="invisible" width="100%">

body: 
<script type="text/javascript">
<!--

var bad = new Array();

// `bad` array management

function set_value(id) \{
	for(i=0;i<bad.length;i++) \{
		if (bad[i] == id) \{
			return;
		\}
		else if (bad[i] == 0) \{
			bad[i] = id;
			return;
		\}
	\}
	bad[bad.length] = id;
\}

function unset_value(id) \{
	for(i=0;i<bad.length;i++) \{
		if (bad[i] == id) \{
			bad[i] = 0;
			break;
		\}
	\}
\}

function change_update_active() \{
	for (i=0;i<bad.length;i++) \{
		if (bad[i] != 0) \{
			document.getElementById('update_feature_section').style.display='none';
			document.getElementById('update_feature_section_2').style.display='inline';
			return;
		\}
	\}
	document.getElementById('update_feature_section_2').style.display='none';
	document.getElementById('update_feature_section').style.display='inline';
\}

// cV

function cV(category_feature,value) \{
	if (value != '') \{
		document.getElementById('_rotate_value_'+category_feature).style.backgroundColor='#CCCCCC';
		call('get_allowed_feature_value_report','value='+escape(value)+';tag_id=_rotate_value_'+category_feature+';foo=bar','sessid=%%sessid%%;tmpl=product_features_values_checking_ajax.html;category_feature_id='+category_feature);
	\}
\}
// -->
</script>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ebebeb" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>%%lang_tabs%%</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<table cellpadding="0" cellspacing="0" width="100%">
<!--  <tr>
    <td width="11%" class="th-dark">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=group_name;%%joined_keys%%">Group</a></td>
    <td width="12%" class="th-norm">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=feature_name;%%joined_keys%%">Feature</a></td>
    <td width="22%" class="th-dark">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=value;%%joined_keys%%">Value</a></td>
    <td width="5%" class="th-norm">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=sign;%%joined_keys%%">Measure</a></td>
    <td width="11%" class="th-dark">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=group_name;%%joined_keys%%">Group</a></td>
    <td width="12%" class="th-norm">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=feature_name;%%joined_keys%%">Feature</a></td>
    <td width="22%" class="th-dark">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=value;%%joined_keys%%">Value</a></td>
    <td width="5%" class="th-norm">
      <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_features_product_features=sign;%%joined_keys%%">Measure</a></td>
  </tr> -->
	<tr>
		<td colspan="8">
			<div style="display: block;" id="id_feat_tab_id_0">
				<form method="post">
					
					<input type="hidden" name="atom_name" value="product_features">
					<input type="hidden" name="sessid" value="%%sessid%%">
					<input type="hidden" name="tmpl" value="product_details.html">
					<input type="hidden" name="product_id" value="%%product_id%%">
 					<input type="hidden" name="command" value="add2editors_journal,update_xml_due_product_update,product2vendor_notification_queue,send_email_about_custom_value_in_select">
 					<input type="hidden" name="precommand" value="save_values_for_history_product_feature">
					
					<table class="invisible" width="100%" valign="top">
						<tr valign="top">
							<td width="50%">
								<table class="invisible" width="100%">
									%%product_features_rows%%
								</table>
							</td>
						</tr>
						<tr>
							<td colspan="2" align="right">
								<div id="update_feature_section" style="display: inline;">
									<table><tr><td>%%insert_action%%<td>%%update_action%%<td>%%delete_action%%</table>
								</div>
								<div id="update_feature_section_2" style="display: none; color: red;">
									Please, correct the red highlighted fields. The input has to be numerical or should match the exact pre-defined pattern.
								</div>
							</td>
						</tr>
					</table>
				</form>
				
			</div>
		</td>
	</tr>

	%%tab_feature_values%%

</table>

<script type="text/javascript">
    function update_combobox(ref) \{
	// if (document.getElementById(id).value == "Custom...") \{
	if (ref.value == "Custom...") \{
	    nm = ref.name;
	    div = document.getElementById(nm + "_container");
	    div.innerText = "<input type='text' style='width: 200px;' name=" + nm + " value='' ><input type='hidden' name='" + nm + "_use_custom' value='1'>";
	    div.innerHTML = "<input type='text' style='width: 200px;' name=" + nm + " value='' ><input type='hidden' name='" + nm + "_use_custom' value='1'>";
	\}
    \}
</script>

%%open_specific_tab%%

}

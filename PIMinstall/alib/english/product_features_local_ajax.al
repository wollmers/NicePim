{
name: product_features_local_ajax;

$$INCLUDE feature_def.al$$
$$INCLUDE nav_inc.al$$
$$INCLUDE actions2.al$$

product_feature_name_00:<span style="color: black;">%%value%%</span>
product_feature_name_10:<span style="color: gray;">%%value%%</span>
product_feature_name_01:<span style="color: green;">%%value%%</span>
product_feature_name_11:<span style="color: green;">%%value%%</span>

mandatory_star:<span style="color: red;">*</span>;

tab_feature_value_group:
<tr>
	<td width="100%" class="main info_header" align="left" colspan="3">%%group_name%%</td>
</tr>

tab_feature_value:
%%tab_feature_value_groups%%

<tr>
	<td width="48%" class="main info_bold" align="right">
		<input type="hidden" name=%%mandatory_name%% value=%%mandatory_value%%>
		<input type="hidden" name=%%name%% value=%%name_value%%>
		%%cat_feat_mandatory_star%% %%feature_name%%</td>
  <td width="42%" class="main info_bold" align="right">%%feature_value%%</td>
	<td width="10%" class="main info_bold">&nbsp;%%sign%%</td>
</tr>

tab_feature_value_textarea:
%%tab_feature_value_groups%%

<tr>
	<td width="90%" class="main info_bold" align="right" colspan="2">
		<input type="hidden" name=%%mandatory_name%% value=%%mandatory_value%%>
		<input type="hidden" name=%%name%% value=%%name_value%%>
		<table border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="td-darknoborder" align="left">
					%%cat_feat_mandatory_star%% %%feature_name%%<br>%%feature_value%%
				</td>
			</tr>
		</table>
	</td>
	<td width="10%" class="main info_bold">&nbsp;%%sign%%</td>
</tr>

split_columns:
	</table>
</td>
<td width="50%">
	<table class="invisible" width="100%">
		
body: 
<form method="post">
  <input type="hidden" id="hidden_tab_id" name="hidden_tab_id" value=feat_tab_id_%%lang_tab%%>
	<input type="hidden" name="atom_name" value="product_features_local_ajax">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl" value="product_details.html">
	<input type="hidden" name="product_id" value="%%product_id%%">
 	<input type="hidden" name="command" value="insert_tab_feature_value,update_xml_due_product_update,product2vendor_notification_queue,send_email_about_custom_value_in_select,add2editors_journal">
	<input type="hidden" name="precommand" value="save_values_for_history_product_feature_local"> 
	<table class="invisible" width="100%">
		<tr valign="top">
			<td width="50%">
				<table class="invisible" width="100%">
					%%div_format%%
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="8" align="right">
				<table><tr><td>%%insert_action%%<td>%%update_action%%<td>%%delete_action%%</table>
			</td>
		</tr>
	</table>
</form>
}

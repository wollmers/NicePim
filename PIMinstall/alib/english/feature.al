{
name: feature;

_rotate_data_source_id_dropdown_empty_key: 0;
_rotate_data_source_id_dropdown_empty: ;

$$INCLUDE actions2.al$$
$$INCLUDE feature_def.al$$

label_row:
<tr>
	<td class="main info_bold">~%%language%% name~</td>
	<td class="main info_bold" >
 	  <input type="text" name="_rotate_label_%%v_langid%%" id="_rotate_label_%%v_langid%%" value="%%_rotate_label_%%v_langid%%%%" size="60">
		<input type="hidden" name="_rotate_v_langid_%%v_langid%%" value="%%v_langid%%">
		<input type="hidden" name="_rotate_record_id_%%v_langid%%" value="%%_rotate_record_id_%%v_langid%%%%">
	</td>
	<td class="main info_bold">
		<input type="button" value="&lt;&lt;" style="padding: 0; margin: 0" onclick="copy_translation('_rotate_label_%%v_langid%%_google','_rotate_label_%%v_langid%%')"/>
		<input type="text" style="width: 210px" id="_rotate_label_%%v_langid%%_google" value="" READONLY="READONLY"/>
	</td>
	<td class="main info_bold">
		<table><tr><td><input type="hidden" name="_rotate_feature_autonaming_id_%%v_langid%%" value="%%_rotate_feature_autonaming_id_%%v_langid%%%%">
		<input type="checkbox" name="_enabled_autonaming_%%v_langid%%" id="_enabled_autonaming_%%v_langid%%" onClick="javascript:autoupdate_trigger('%%v_langid%%')"><td>updating from<td>%%_rotate_data_source_id_%%v_langid%%%%</table>
	</td>
</tr>

text_row: 
<tr>
	<td class="main info_bold" valign="top">~%%language%% description~</td>
	<td class="main info_bold" valign="top" colspan="3">
		<textarea name="_rotate_text_%%t_langid%%" cols="80" rows="7">%%_rotate_text_%%t_langid%%%%</textarea>
		<input type="hidden" name="_rotate_t_langid_%%t_langid%%" value="%%t_langid%%">
		<input type="hidden" name="_rotate_tex_id_%%t_langid%%" value="%%_rotate_tex_id_%%t_langid%%%%">		
	</td>
</tr>

body:

<script type="text/javascript">
<!--
window.onload=function()\{
	collectToTranslate('_rotate_label_',%%js_langid_array%%,'1','%%sessid%%');
\}

var data_sources = new Array();

function initialize_triggers() \{
	var id="1";
	while (document.getElementById("_rotate_data_source_id_"+id) != undefined) \{
		if (document.getElementById("_rotate_data_source_id_"+id).value == 0) \{
			document.getElementById("_enabled_autonaming_"+id).checked = false;
			autoupdate_trigger(id);
		\}
		else \{
			document.getElementById("_enabled_autonaming_"+id).checked = true;
			autoupdate_trigger(id);
		\}
		id++;
	\}
\}

function autoupdate_trigger_switch() \{
	//alert("autoupdate_trigger_switch() "+document.getElementById("_enabled_autonaming").checked);
	if (document.getElementById("_enabled_autonaming").checked == true) \{
		for (i="1";i<data_sources.length;i++) \{
			document.getElementById("_rotate_data_source_id_"+i).value = data_sources[i];
		\}
		initialize_triggers();
	\}
	else \{
		var id="1";
		while (document.getElementById("_rotate_data_source_id_"+id)!=undefined) \{
			document.getElementById("_enabled_autonaming_"+id).checked = false;
			document.getElementById("_rotate_data_source_id_"+id).value = 0;
			document.getElementById("_rotate_data_source_id_"+id).disabled = true;
			id++;
		\}
	\}
\}

function autoupdate_trigger(id) \{
	if (document.getElementById("_enabled_autonaming_"+id).checked) \{
		if (data_sources[id]) \{
			document.getElementById("_rotate_data_source_id_"+id).value = data_sources[id];
		\}
		data_sources[id] = document.getElementById("_rotate_data_source_id_"+id).value;
		document.getElementById("_rotate_data_source_id_"+id).disabled = false;
	\}
	else \{
		data_sources[id] = document.getElementById("_rotate_data_source_id_"+id).value;
		document.getElementById("_rotate_data_source_id_"+id).value = 0;
		document.getElementById("_rotate_data_source_id_"+id).disabled = true;
	\}
\}
//-->
</script>

<form method="post">
	
	<input type="hidden" name="atom_name" value="feature">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="%%tmpl_if_success_cmd%%">
	<input type="hidden" name="tmpl" value="feature.html">
	<input type="hidden" name="feature_id" value="%%feature_id%%">
	<input type="hidden" name="catid" value="%%catid%%">
	<input type="hidden" name="sid" value="%%sid%%">
	<input type="hidden" name="tid" value="%%tid%%">
	<input type="hidden" name="command" value="update_feature_chunk">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="1" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"/>
									<td class="main info_bold"/>
									<td class="main info_bold"  align="center">
										<input onclick="copy_all_translation(%%js_langid_array%%,'_rotate_label_')" type="button" value="Accept all"> Google suggestions
									</td>
									
									<td class="main info_bold">
										<table><tr><td><input type="checkbox" name="_enabled_autonaming" id="_enabled_autonaming" onClick="javascript:autoupdate_trigger_switch()" checked><td>uncheck all data source updatings</table>
									</td>
								</tr>
								
								%%label_rows%%
								
								<script type="text/javascript">
									<!--
										 initialize_triggers();
										 //-->
								</script>

								<tr>
									<td class="main info_bold"><font color="red">*</font>~Measure~</td>
									<td class="main info_bold" colspan="3">%%measure_id%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Input type~</td>
									<td class="main info_bold" colspan="3">%%type%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Feature class~</td>
									<td class="main info_bold" colspan="3">%%class%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Limit direction~</td>
									<td class="main info_bold" colspan="3">%%limit_direction%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Restricted values~</td>
									<td class="main info_bold" colspan="3"><textarea name="restricted_values" cols="40" rows="5">%%restricted_values%%</textarea></td>
								</tr>
								
								<tr>
									<td class="main info_bold">&nbsp;</td>
									<td class="main info_bold" colspan="3"><table><tr><td>%%autoinsert%%<td>auto-insert search list values into feature values vocabulary</table></td>
								</tr>
								
								%%text_rows%%	 
								
								<td class="main info_bold" colspan="4" align="center">
									<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
								</td>
					</tr>
					
					</table>
					
			</td>
		</tr>
		</table>
		
</td>
</tr>
</table>

</form>
}

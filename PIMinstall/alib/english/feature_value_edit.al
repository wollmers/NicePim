{
name: feature_value_edit;

feature_values_group_id_dropdown_empty: UNDEF;

$$INCLUDE actions2.al$$

label_row:
<tr>
	<td class="main info_bold" align="left">%%language%% value</td>
	<td class="main info_bold">
 	  <input type="text" name="_rotate_label_%%v_langid%%" id="_rotate_label_%%v_langid%%" value="%%_rotate_label_%%v_langid%%%%">
		<input type="hidden" name="_rotate_v_langid_%%v_langid%%" value="%%v_langid%%">
		<input type="hidden" name="_rotate_record_id_%%v_langid%%" value="%%_rotate_record_id_%%v_langid%%%%">		
	</td>
		<td class="main info_bold" align="center">
			<input type="button" value="&lt;&lt;"  onclick="copy_translation('_rotate_label_%%v_langid%%_google','_rotate_label_%%v_langid%%')"/>
		</td>
		<td class="main info_bold" align="center">
			<input type="text" id="_rotate_label_%%v_langid%%_google" size="29" value="" READONLY="READONLY"/>
		</td>
	
</tr>

body:
<script type="text/javascript">
window.onload=function()\{
	collectToTranslate('_rotate_label_',%%js_langid_array%%,'1','%%sessid%%');
\}
</script>

<form method="post">
	<input type="hidden" name="atom_name" value="feature_value_edit">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="feature_values_vocabulary.html">
	<input type="hidden" name="tmpl" value="feature_value_edit.html">
	<input type="hidden" name="key_value" value="%%key_value%%">
	<input type="hidden" name="_command_" value="feature_group_delete_daemon">

	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"></td>
									<td class="main info_bold"/>
									<td class="main info_bold"/>
									<td class="main info_bold" align="center" >
										<input onclick="copy_all_translation(%%js_langid_array%%,'_rotate_label_')" type="button" value="Accept all"> Google suggestions
									</td>
									
								</tr>
								
								%%label_rows%%
								
								<tr>
									<td class="main info_bold" align="right">Group</td>
									<td class="main info_bold" colspan="3">%%feature_values_group_id%%</td>
								</tr>
								<tr>
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

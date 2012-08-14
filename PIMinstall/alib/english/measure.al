{
name: measure;

$$INCLUDE actions2.al$$

label_header: <div style="margin: 0 2px 1px 0; padding: 2px; float: left; cursor: pointer;" id="label_%%v_langid%%_tab" onClick="javascript:white_bg('label',%%v_langid%%);white_bg('sign',%%v_langid%%);white_bg('text',%%v_langid%%);"><nobr>%%language%%</nobr></div>

label_row:
<div id="label_%%v_langid%%" style="display\: none;">
	<table class="invisible"><tr>
			<td width="150">
				%%language%%
			</td><td>
 				<input type=text name=_rotate_label_%%v_langid%% value="%%_rotate_label_%%v_langid%%%%" size=60>
				<input type=hidden name=_rotate_v_langid_%%v_langid%% value="%%v_langid%%">
				<input type=hidden name=_rotate_record_id_%%v_langid%% value="%%_rotate_record_id_%%v_langid%%%%">
			</td>
		</tr>
	</table>
</div>

sign_header: <div style="margin: 0 2px 1px 0; padding: 2px; float: left; cursor: pointer;" id="sign_%%s_langid%%_tab" onClick="javascript:white_bg('sign',%%s_langid%%);"><nobr>%%language%%</nobr></div>

sign_row: <div id="sign_%%s_langid%%" style="display\: none;">
	<table class="invisible"><tr>
			<td width="150">
				%%language%%
			</td>
			<td>
 				<input type=text name=_rotate_sign_%%s_langid%% value="%%_rotate_sign_%%s_langid%%%%" size=60>
				<input type=hidden name=_rotate_s_langid_%%s_langid%% value="%%s_langid%%">
				<input type=hidden name=_rotate_measure_sign_id_%%s_langid%% value="%%_rotate_measure_sign_id_%%s_langid%%%%">
			</td>
		</tr>
	</table>
</div>

text_header: <div style="margin: 0 2px 1px 0; padding: 2px; float: left; cursor: pointer;" id="text_%%t_langid%%_tab" onClick="javascript:white_bg('text',%%t_langid%%);"><nobr>%%language%%</nobr></div>

text_row: 
<div id="text_%%t_langid%%" style="display\: none;">
	<table class="invisible"><tr>
			<td width="150">
				%%language%%
			</td>
			<td>
				<textarea name=_rotate_text_%%t_langid%% cols=80 rows=7>%%_rotate_text_%%t_langid%%%%</textarea>
				<input type=hidden name=_rotate_t_langid_%%t_langid%% value="%%t_langid%%">
				<input type=hidden name=_rotate_tex_id_%%t_langid%% value="%%_rotate_tex_id_%%t_langid%%%%">
			</td>
		</tr>
	</table>
</div>

measure_power_map_row:%%pattern%%

body:

 <form method=post>

	<input type=hidden name=atom_name value="measure">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="measures.html">
	<input type=hidden name=tmpl value="measure_edit.html">
	<input type=hidden name=measure_id value="%%measure_id%%">
	<input type=hidden name=sid value="%%sid%%">
	<input type=hidden name=tid value="%%tid%%">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">~System of measurement~&nbsp;%%system_of_measurement%%</td>
								</tr>

								<tr>
									<th class="main info_header" colspan="2">~Names~</th>
								</tr>
								
								%%label_rows%%
								
								<tr>
									<th class="main info_header" colspan="2">~Units~</th>
								</tr>
								
								%%sign_rows%%
								
								<tr>
									<th class="main info_header" colspan="2">~Descriptions~</th>
								</tr>
								
								%%text_rows%%
								
								<script type="text/javascript">
									<!--
										 white_bg('label',1);white_bg('sign',1);white_bg('text',1);
										 //-->
								</script>
								
								<tr>
									<td class="main info_bold" colspan="2" align="center">
										%%update_action%% %%delete_action%%	%%insert_action%%
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

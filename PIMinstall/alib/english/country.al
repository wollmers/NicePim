{
name: country;

$$INCLUDE actions2.al$$

label_row:
<tr>
	<td class="main info_bold" align="left">%%language%% name</td>
	<td class="main info_bold">
 	  <input type="text" name="_rotate_label_%%v_langid%%" id="_rotate_label_%%v_langid%%" value="%%_rotate_label_%%v_langid%%%%">
		<input type="hidden" name="_rotate_v_langid_%%v_langid%%" value="%%v_langid%%">
		<input type="hidden" name="_rotate_record_id_%%v_langid%%" value="%%_rotate_record_id_%%v_langid%%%%">
	</td>
	<td class="main info_bold" align="center">		
		<input type="button" value="&lt;&lt;" onclick="copy_translation('_rotate_label_%%v_langid%%_google','_rotate_label_%%v_langid%%')"/>
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
	
	<input type="hidden" name="atom_name" value="country">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="countries.html">
	<input type="hidden" name="tmpl" value="country_edit.html">
	<input type="hidden" name="country_id" value="%%country_id%%">
	<input type="hidden" name="sid" value="%%sid%%">
	
	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold"></td>
									<td class="main info_bold"></td>
									<td class="main info_bold"></td>
									<td class="main info_bold" align="center">
										<input onclick="copy_all_translation(%%js_langid_array%%,'_rotate_label_')" type="button" value="Accept all"> Google suggestions
									</td>
								</tr>
								%%label_rows%%

								<tr>
									<td class="main info_bold" align="right">Short code</td>
									<td class="main info_bold" colspan="3"><input type="input" name="code" value="%%code%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">EAN prefix</td>
									<td class="main info_bold" colspan="3"><input type="input" name="ean_prefix" value="%%ean_prefix%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align="right">System of measurement</td>
									<td class="main info_bold" colspan="3">%%system_of_measurement%%</td>
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

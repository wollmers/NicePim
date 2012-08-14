{
name: sector;

$$INCLUDE actions2.al$$

sector_row:
<tr>
	<!-- Country label-->
	<td class="main info_bold" align="left">%%code%% name</td>
	
	<!-- Edit field -->
	<td class="main info_bold">
 	<input type="text" name="value_%%langid%%" id="value_%%langid%%" value="%%name%%">
	</td>
 	<td class="main info_bold" align="center">
	 	<input type="button" value="&lt;&lt;" onclick="copy_translation('_rotate_label_%%v_langid%%_google','value_%%langid%%')"/>
 	</td>
 	<td class="main info_bold" align="center">
		<input type="text" id="value_%%langid%%_google" value="" size="29" READONLY="READONLY"/>
	</td>
</tr>

body:
<script type="text/javascript">
window.onload=function()\{
	collectToTranslate('value_',%%js_langid_array%%,'1','%%sessid%%');
\}
</script>

<form method="post">
	<input type="hidden" name="atom_name" value="sector">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="sector_edit.html">
	<input type="hidden" name="tmpl" value="sector_edit.html">
	<input type="hidden" name="sector_id" value="%%sector_id%%">
	<input type="hidden" name="command" value="update_sector_name_table">
	
	<table align="center" width="70%" border="0" cellspacing="0" cellpadding="0">
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
										<input onclick="copy_all_translation(%%js_langid_array%%,'value_')" type="button" value="Accept all"> Google suggestions
									</td>
								</tr>							
								%%sector_rows%%
								<!-- Submit button -->
								<tr>
									<td class="main info_bold" colspan="4" align="center">
										<table>
										<tr><td>
										<input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_save.gif) no-repeat;' name="atom_update" value="." />
										</td></tr>
										</table>
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



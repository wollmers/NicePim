{
name: track_list_entrusted_editors;

body:

<br />

<form method=post>
	<input type=hidden name=atom_name value="track_list_entrusted_editors">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="track_lists.html">
	<input type=hidden name=tmpl value="track_list_entrusted_editors.html">
	<input type=hidden name=command value="set_entrusted_editor">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" colspan=2 align="center">
										<table>
										<tr>
											<td>
										 		%%available_user_id%%<br/>
										 	</td>
										 	<td>
											 <input style="margin-left: 5px; margin-right: 5px;" type="button" value=">>>" onclick="move_options('available_user_id','occupied_user_id')"/><br>										
											 <input style="margin-left: 5px; margin-right: 5px;" type="button" value="&lt;&lt;&lt;" onclick="move_options('occupied_user_id','available_user_id')"/>
										 	</td>
										 	<td>										 
										 %%occupied_user_id%%
										 	</td>
										 </tr>
										 </table>
									</td>
								</tr>							
								<tr>
									<td class="main info_bold" colspan=2 align="center">
										<input type="submit" value="save" onclick="select_all_users()"/>
									</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	<div>
	</div>
</form>
<script type="text/javascript">
function select_all_users()\{ 
	var options=document.getElementById('occupied_user_id').options;
	for(i=0;i<options.length;i++)\{
		options[i].selected=true;
	\}
\}
</script>

}

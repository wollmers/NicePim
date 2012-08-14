{
name: track_list_graph;

body:

<br />

<form method=post>
	<input type=hidden name=atom_name value="track_list_graph">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="track_list_graph.html">
	<input type=hidden name=tmpl value="track_list_graph.html">
	<input type=hidden name=track_list_id value="%%track_list_id%%">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<caption>List: <b>%%name%%</b>, created at: %%created%%</caption>
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
										 		%%avilable_user_id%%<br/>
										 	</td>
										 	<td>
											 <input style="margin-left: 5px; margin-right: 5px;" type="button" value=">>>" onclick="move_options('avilable_user_id','occupied_user_id')"/><br>										
											 <input style="margin-left: 5px; margin-right: 5px;" type="button" value="&lt;&lt;&lt;" onclick="move_options('occupied_user_id','avilable_user_id')"/>
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
										<input type="submit" value="show graphic" onclick="select_all_users()"/>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" colspan=2 align="center">
										<div id="chartdiv" style="height:400px;width:850px; "></div>
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
graph=null;
renew_graphic_data('chartdiv',%%axis%%,%%editors%%);

function select_all_users()\{ 
	var options=document.getElementById('occupied_user_id').options;
	for(i=0;i<options.length;i++)\{
		options[i].selected=true;
	\}
\}
</script>

}

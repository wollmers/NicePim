{
name: track_list_settings;

$$INCLUDE actions2.al$$
occupied_user_id_dropdown_empty: UNDEF;
avilable_user_id_dropdown_empty: UNDEF;
occupied_langid_dropdown_empty: UNDEF;
avilable_langid_dropdown_empty: UNDEF;


priority_custom_select_value_0: 3;
priority_custom_select_text_0:  Low;

priority_custom_select_value_1: 2;
priority_custom_select_text_1:  Normal;

priority_custom_select_value_2: 1;
priority_custom_select_text_2:  High;

body:

<br />

<form method=post>
	<input type=hidden name=atom_name value="track_list_settings">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="track_lists.html">
	<input type=hidden name=tmpl value="track_list_settings.html">
	<input type=hidden name=track_list_id value="%%track_list_id%%">
	<input type=hidden name=command value="save_track_list_settings">
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main"  bgcolor="#e6f0ff" colspan="2">Settings</th>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Name~<span style="color: red">*</span></td>
									<td class="main info_bold">
										<input type=text size=40 name=name value="%%name%%">
									</td>
								</tr>	
								<tr>
									<td class="main info_bold" align=right>~Is it open or closed~</td>
									<td class="main info_bold">
										%%is_open%%
									</td>
								</tr>																																
								<tr>
									<td class="main info_bold" align=right>~Deadline date~<span style="color: red">*</span></td>
									<td class="main info_bold">
										%%deadline_date%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Client of list~<span style="color: red">*</span></td>
									<td class="main info_bold">
										%%client_id%%
									</td>
								</tr>								
								
								<tr>
									<td class="main info_bold" align=right>~Target coverage~</td>
									<td class="main info_bold">
										<input type="text" size="3" value="%%goal_coverage%%" name="goal_coverage"/>%
									</td>
								</tr>								
								<tr>
									<td class="main info_bold" align=right>~Priority~</td>
									<td class="main info_bold">
										%%priority%%
									</td>
								</tr>																	
								<tr>
									<td class="main info_bold" align=right>~Reminder period~</td>
									<td class="main info_bold">
										<input type=text size=4 name="reminder_period" value="%%reminder_period%%"/> days (digits only)
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Rules~</td>
									<td class="main info_bold">
										<textarea id="rules_id" type=text cols="70" rows="2" name="rules">%%rules%%</textarea>
									</td>
								</tr>																								
								<tr>
									<td colspan="2">
										<div style="text-align: center;width: 100%">Columns settings</div>
										%%restricted_col%%</td>
									</td>
								<tr>
									<td class="main info_bold" align=right>User assigment</td>
									<td class="main info_bold">
										<table cellpadding="0" cellspacing="0" style="text-align: center">
										<tr>
											<td>
												%%avilable_user_id%%
											</td>
											<td>
												<input style="margin-left: 5px; margin-right: 5px;" type="button" value=">>>" onclick="move_options('avilable_user_id','occupied_user_id')"/>
												<br/><br/>
												<input style="margin-left: 5px; margin-right: 5px;" type="button" value="&lt;&lt;&lt;" onclick="move_options('occupied_user_id','avilable_user_id')"/>
											</td>
											<td>
												%%occupied_user_id%%
											</td>
										</tr>
										</table>
										<div align="left">* - indicator of work load (Depends on the quantity of lists assigned to the editor)</div>
										<div align="left">+ - Indicator of productivity (Depends on the quantity of updated products by editor in the past 3 months)</div>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>Mandatory languages</td>
									<td class="main info_bold">
										<table cellpadding="0" cellspacing="0" style="text-align: center">
										<tr>
											<td>
												%%avilable_langid%%
											</td>
											<td>
												<input style="margin-left: 5px; margin-right: 5px;" type="button" value=">>>" onclick="move_options('avilable_langid','occupied_langid')"/>
												<br/><br/>
												<input style="margin-left: 5px; margin-right: 5px;" type="button" value="&lt;&lt;&lt;" onclick="move_options('occupied_langid','avilable_langid')"/>
											</td>
											<td>
												%%occupied_langid%%
											</td>
										</tr>
										</table>						
									</td>
								</tr>																										
								<tr>
									<td class="main info_bold" colspan=2 align="center">
										<table class="invisible"><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
			<script type="text/javascript">
			var savers=document.getElementsByName('atom_submit');
			if(savers[0])\{
				savers[0].onclick=function () \{
					savers[0].onclick=function () \{
						var options=document.getElementById('occupied_user_id').options;
						for(i=0;i<options.length;i++)\{
							options[i].selected=true;
						\}
						options=document.getElementById('occupied_langid').options;
						for(i=0;i<options.length;i++)\{
							options[i].selected=true;
						\}							
					\};					
				\};
			\}else\{
				var updaters=document.getElementsByName('atom_update');
				updaters[0].onclick=function () \{
					var options=document.getElementById('occupied_user_id').options;
					for(i=0;i<options.length;i++)\{
						options[i].selected=true;
					\}
					options=document.getElementById('occupied_langid').options;
					for(i=0;i<options.length;i++)\{
						options[i].selected=true;
					\}						
				\};
			\}
			</script>
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
  tinyMCE.init(\{
    mode\: 'exact',
    elements\: 'rules_id',
    language\: 'en',
    relative_urls\: '',
    height\: '300',
    plugins\: '',
    forced_root_block\: false,
	force_br_newlines\: true,
	force_p_newlines\: false,    
    file_browser_callback\: 'sfMediaLibrary.fileBrowserCallBack',
    width\: '500',
    toolbar_align\: 'left',
    theme\: 'advanced',
    theme_advanced_blockformats\: 'h3,h4,h5',
    theme_advanced_layout_manager\: 'SimpleLayout',
    theme_advanced_buttons1\: 'forecolor,backcolor,outdent,indent,separator,bullist,numlist,separator,undo,redo,separator,hr,removeformat,visualaid,separator,sub,sup,separator,charmap,separator,link',
    theme_advanced_buttons2\: 'bold,italic,underline,fontsizeselect,separator,justifyleft,justifycenter,justifyright,justifyfull,separator, blockformats, code',
    theme_advanced_buttons3\: ''
  \});
</script>

}

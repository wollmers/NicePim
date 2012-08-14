{
name: dictionary;
lang_table: <table width="100%" cellpadding="0" cellspacing="0">%%lang_links%%</table>
lang_link: <td>
				<input style="font-size: 7pt;" class="dictionary_choice_button" type="button" id="dictionary_choice_%%langid%%" onclick="show_dictionary('dictionary_tr_%%langid%%',this)" value="%%lang_code%%"/>
			</td>

dictionary_text_row: <tr style="display: %%curr_style%%" id="dictionary_tr_%%langid%%" class="dictionary_tr">
						<td class="main info_bold">~%%lang_name%%~</td>
						<td class="main info_bold" >
							<div id="dictionary_html">
								<textarea rows="6" name="_rotate_html_%%langid%%" cols="50">%%_rotate_html_%%langid%%%%</textarea>
								<input type="hidden" name="_rotate_langid_%%langid%%" value="%%langid%%"/>
								<input type="hidden" name="_rotate_dictionary_text_id_%%langid%%" value="%%_rotate_dictionary_text_id_%%langid%%%%"/>								
							</div>
						</td>
					</tr>


$$INCLUDE actions2.al$$

body:
<!--  
	<input type="button" onclick="hide_dictionary('dictionary_html1','none')" value="hide_html"/>
	<input type="button" onclick="hide_dictionary('dictionary_html1','block')" value="show_html"/>
-->
<form method="get">
	<input type="hidden" name="atom_name" value="dictionary">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="dictionaries.html">
	<input type="hidden" name="tmpl" value="dictionary.html">
	<input type="hidden" name="dictionary_id" value="%%dictionary_id%%">
	<input type="hidden" name="precommand" value="dictionary_cleanup_html">
	<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~Name~</td>
									<td class="main info_bold">
										<input type="text" size="20" name="name" value="%%name%%">
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Languages</td>
									<td class="main info_bold">
										%%lang_links%%
									</td>
								</tr>																
								<tr>
									<td class="main info_bold">Code</td>
									<td class="main info_bold">
										%%code%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Group</td>
									<td class="main info_bold">
										%%dictionary_group_id%%
									</td>
								</tr>																
								%%dictionary_text_rows%%								
							</table>
							</td>
							</tr>
							<tr>							
								<td class="main info_bold" colspan="2" align="center">
									<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
								</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table> 
	
</form>
<script type="text/javascript">
	document.getElementById('dictionary_choice_1').savedBorder=document.getElementById('dictionary_choice_1').style.border;
	document.getElementById('dictionary_choice_1').style.border='none';
  tinyMCE.init(\{
    mode\: 'exact',
    elements\: '%%textarea_ids%%',
    language\: 'en',
    relative_urls\: '',
    height\: '500',
    plugins \: "style,layer,table,preview,contextmenu",
    width\: '700',
    toolbar_align\: 'left',
    theme\: 'advanced',
    theme_advanced_blockformats\: 'h3,h4,h5',
    theme_advanced_layout_manager\: 'SimpleLayout',
    theme_advanced_buttons1\: 'forecolor,backcolor,outdent,indent,separator,bullist,numlist,separator,undo,redo,separator,hr,removeformat,visualaid,separator,sub,sup,separator,charmap,separator,link',
    theme_advanced_buttons2\: 'bold,italic,underline,fontselect,fontsizeselect,separator,justifyleft,justifycenter,justifyright,justifyfull,separator, blockformats,separator,styleprops,table,separatorm,separator, code, preview',
    theme_advanced_buttons3\: ''
  \});
</script>
}


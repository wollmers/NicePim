{
name: category;

$$INCLUDE actions2.al$$

cat_div: ---;
any_cat: ROOT;

low_pic_format: <img src="%%thumb_value%%" border=0 hspace=0 vspace=0  style="cursor: pointer" onclick="PopupPic('%%sessid%%','%%value%%')"/> 

searchable_0: No
searchable_1: Yes

visible_0: No
visible_1: Yes

delimit_assigned_table: , 

assigned_table_product: Product;
assigned_table_category: Category;
assigned_table_data_source_category_map: Data source category map


keywords_row: 
<tr>
  <td class="main info_bold" valign=top>~%%language%% keywords~</td>
  <td class="main info_bold" valign=top colspan="3">
		<textarea name=_rotate_keywords_%%k_langid%% cols=80 rows=7>%%_rotate_keywords_%%k_langid%%%%</textarea>
		<input type=hidden name=_rotate_k_langid_%%k_langid%% value="%%k_langid%%">
		<input type=hidden name=_rotate_id_%%k_langid%% value="%%_rotate_id_%%k_langid%%%%">
 	</td>
</tr>


label_row: 
<tr>
	<td class="main info_bold"><span style="color: red;">*</span>~%%language%% name~</td>
	<td class="main info_bold">
 	  	<input type=text name=_rotate_label_%%v_langid%% id="_rotate_label_%%v_langid%%" value="%%_rotate_label_%%v_langid%%%%"  size=60>
		<input type=hidden name=_rotate_v_langid_%%v_langid%% value="%%v_langid%%">
		<input type=hidden name=_rotate_record_id_%%v_langid%% value="%%_rotate_record_id_%%v_langid%%%%">
	</td>
	<td class="main info_bold">
		<input type="button" value="&lt;&lt;" onclick="copy_translation('_rotate_label_%%v_langid%%_google','_rotate_label_%%v_langid%%')"/>
	</td>
	<td class="main info_bold">
		<input type="text" id="_rotate_label_%%v_langid%%_google" style="width: 260px" value="" READONLY="READONLY"/>
	</td>
</tr>

text_row: 
<tr>
	<td class="main info_bold" valign=top>
    ~%%language%% description~
	</td>
	<td class="main info_bold" valign=top colspan="3">
		<textarea name=_rotate_text_%%t_langid%% cols=80 rows=7>%%_rotate_text_%%t_langid%%%%</textarea>
		<input type=hidden name=_rotate_t_langid_%%t_langid%% value="%%t_langid%%">
		<input type=hidden name=_rotate_tex_id_%%t_langid%% value="%%_rotate_tex_id_%%t_langid%%%%">
	</td>
</tr>



body:
<script type="text/javascript">
window.onload=function()\{
	collectToTranslate('_rotate_label_',%%js_langid_array%%,'1','%%sessid%%');
\}

</script>
<form method=post  enctype="multipart/form-data">
	
	<input type=hidden name=atom_name value="category">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="cats.html">
	<input type=hidden name=tmpl value="cat_edit.html">
	<input type=hidden name=catid value="%%catid%%">
	<input type=hidden name=sid value="%%sid%%">
	<input type=hidden name=tid value="%%tid%%">
  <input type=hidden name=command value="get_obj_url,change_nestedset">

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td colspan=4 align=right>%%low_pic_formatted%%</td>
								</tr>
								<tr>
									<td class="main info_bold">
										<span style="color: red;">*</span>~UNSPSC~</td><td class="main info_bold" colspan="3"><b><input type=text size=8 name="ucatid" value="%%ucatid%%" style="width: 75px;"></b>
									</td>
								</tr>
								<tr>
									<td class="main info_bold">Subcategory of</td>
									<td class="main info_bold" colspan="3">%%pcatid%%</td>
								</tr>

								<tr>
									<td class="main info_bold"><abbr title="Searchable features will be available on the category page">Searchable</abbr></td>
									<td class="main info_bold" colspan="3">%%searchable%% <span style="color\: green\; font-size\: 0.8em\;">(Searchable features will be available on the category page)</span></td>
								</tr>

								<tr>
									<td class="main info_bold"><abbr title="Category will be available on the main page">Visible</abbr></td>
									<td class="main info_bold" colspan="3">%%visible%% <span style="color\: green\; font-size\: 0.8em\;">(Category will be available on the main page)</span></td>
								</tr>
								<tr>
									<td class="main info_bold" colspan="3"></td>
									<td class="main info_bold" align="center"><input onclick="copy_all_translation(%%js_langid_array%%,'_rotate_label_')" type="button" value="Accept all"> Google suggestions</td>
								</tr>
								%%label_rows%%

								<tr>
									<td class="main info_bold" valign=top>~Category picture URL~</td>
									<td class="main info_bold" valign=top colspan="3"><input type=text name="low_pic" value="%%low_pic%%" size=80>
										or <br />
										<input type="file" name="low_pic_filename">
									</td>
								</tr>
								
								%%text_rows%%
								
								<tr>
									<td class="main info_bold" colspan="4">
										<hr />
									</td>
								</tr>

								%%keywords_rows%%  	 

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

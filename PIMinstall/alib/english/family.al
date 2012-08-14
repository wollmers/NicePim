{
name: family;

cat_div: ---;
any_cat: None;
any_parent_family_id: ROOT;
default_login: None;
low_pic_format: <img src="%%value%%" border=0 hspace=0 vspace=0>

$$INCLUDE actions2.al$$


label_row:
<tr>
	<td class="main info_bold">%%language%% name</td>
	<td class="main info_bold">
 	  <input type=text name=_rotate_label_%%v_langid%% value="%%_rotate_label_%%v_langid%%%%" size=60>
		<input type=hidden name=_rotate_v_langid_%%v_langid%% value="%%v_langid%%">
		<input type=hidden name=_rotate_record_id_%%v_langid%% value="%%_rotate_record_id_%%v_langid%%%%">
	</td>
</tr>


text_row: 
<tr>
	<td class="main info_bold" valign=top>
    ~%%language%% description~
	</td>
	<td class="main info_bold" valign=top>
		<textarea name=_rotate_text_%%t_langid%% cols=80 rows=7>%%_rotate_text_%%t_langid%%%%</textarea>
		<input type=hidden name=_rotate_t_langid_%%t_langid%% value="%%t_langid%%">
		<input type=hidden name=_rotate_tex_id_%%t_langid%% value="%%_rotate_tex_id_%%t_langid%%%%">
	</td>
</tr>


body:

<form method=post enctype="multipart/form-data"> 
	<input type=hidden name=atom_name value="family">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="product_families.html">
	<input type=hidden name=tmpl value="family_edit.html">
	<input type=hidden name=family_id value="%%family_id%%">
	<input type=hidden name=supplier_id value="%%supplier_id%%">
	<input type=hidden name=sid value="%%sid%%">
	<input type=hidden name=tid value="%%tid%%">
	<input type=hidden name=command value="get_obj_url,change_family_ns,family"> 
	
	<div align=right>%%low_pic_formatted%%</div>
	
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">

				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr style="display: none;" id="exchange_section_family">
									<td class="main info_bold"><b>Family to be exchaged when deleted</b></td>
									<td class="main info_bold">%%exchange_family%%</td>
								</tr>

								%%label_rows%%

								<tr>
									<td class="main info_bold">~Brand~</td><td class="main info_bold">%%supplier_name%%</td>
								</tr>
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Parent family~</td><td class="main info_bold">%%parent_family_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold"><span style="color: red;">*</span>~Category~</td><td class="main info_bold">%%catid%%</td>
								</tr>
								<tr>
									<td class="main info_bold" valign=top>~Family picture URL~</td>
									<td class="main info_bold" valign=top><input type=text name="low_pic" value="%%low_pic%%" size=80>
										or
										<input type="file" name="family_pic_filename">
									</td>
								</tr>
								
								%%text_rows%%

								<tr>
									<td class="main info_bold" colspan=2 align=center>
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

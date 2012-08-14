{
name: distri_transl_cfg_attrs;

languages_row: 
<tr>
	<td class="main info_bold">
		<span id=span_%%v_langid%%></span>%%language%% name
	</td>
	<td class="main info_bold">
		<input type=text name=label_%%v_langid%% id=label_%%v_langid%% value="%%trans%%" size=60>
	</td>
</tr>

body:

<form method=post  enctype="multipart/form-data">
	
	<input type=hidden name=atom_name value="distri_transl_cfg_attrs">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=token value="%%token%%">
	<input type=hidden name=dictid value="%%dictid%%">
	<input type=hidden name=tmpl_if_success_cmd value="distributor_edit.html">
	<input type=hidden name=tmpl value="distri_edit_attrs.html">
	<input type=hidden name=distributor_id value="%%distributor_id%%">
	<input type=hidden name=command value="distri_save_attrs">

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="2">
									Set translation for token
									<span style="color: Seagreen;">%%token%%</span>
									of distributor
									<span style="color: Lightcoral;">%%distri%%</span></th>
								</tr>
								%%languages_rows%%
								<tr>
									<td class="main info_bold" colspan="2" align="center">
										<table>
										<tr>
											<td class="main info_bold"><input type="submit" value="Save" onClick="return validateMandatory()"/></td>
										</tr>
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

<script type="text/javascript">
	var english_span = document.getElementById('span_1');
	english_span.innerHTML = "* ";
	english_span.style.color = 'red';
	
	function validateMandatory() \{
	    english_token = document.getElementById('label_1').value;
	    if ( english_token == '' ) \{
	        alert('English name is mandatory!');
	        return false;   
	    \} 
	    else \{
	        return true;
	    \}
	\}
	
</script>

}

{
name: distri_tokens;

tokens_row :
<tr>
	<td class="main info_bold">
		<a href="%%base_url%%;distributor_id=%%distributor_id%%;token=%%token%%;dictid=%%dictid%%;tmpl=distri_edit_attrs.html;">%%token%%</a>
	</td>
</tr>

body:

<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0" id="tokens_table">
	<tr>
		<td style="padding-top:10px">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						<table border="0" cellpadding="2" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" colspan="2">Distributor tokens</th>
							</tr>
							%%tokens_rows%%
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<script language="JavaScript" type="text/javascript">
	var s = document.getElementById('source_name').value;
    var d = document.getElementById('direct_value').value;
    var sy = document.getElementById('dist_sync').value;
    
    if ((sy != "1") || (s != 'iceimport') || ( (s == 'iceimport') && (d != 1) && (sy == "1"))) \{
        document.getElementById('tokens_table').style.display = "none";
    \}
</script>

}

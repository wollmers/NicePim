{
name: category_features_merge;

insert_action: <input type=submit name=atom_submit value="Merge">

body:

<table align="center" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							
							<form method=post>
								
								<input type=hidden name=atom_name value="category_features_merge">
								<input type=hidden name=sessid value="%%sessid%%">
								<input type=hidden name=tmpl_if_success_cmd value="cat_features.html">
								<input type=hidden name=catid value=%%catid%%>
								<input type=hidden name=tmpl value="category_features_merge.html">
								
								<input type=hidden name=command value="merge_features_in_category">
								
								<tr>
									<th class="main info_header" colspan="2">Merging category features</th>
								</tr>

								<tr>
									<td class="main info_bold">~Category~</td>
									<td class="main info_bold"><b>%%category_name%%</b></td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Source feature~</td>
									<td class="main info_bold">%%src_feature_id%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold">~Destination feature~</td>
									<td class="main info_bold">%%dst_feature_id%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" colspan=2 align=center>
										%%insert_action%%
									</td>
								</tr>
							</form>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

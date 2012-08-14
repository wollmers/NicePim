{
name: features_merge;

insert_action: <input type="submit" name="atom_submit" value="Merge">

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							
							<form method="post">
								
								<input type="hidden" name="atom_name" value="features_merge">
								<input type="hidden" name="sessid" value="%%sessid%%">
								<input type="hidden" name="tmpl_if_success_cmd" value="features.html">
								<input type="hidden" name="tmpl" value="features_merge.html">
								
								<input type="hidden" name="command" value="merge_features">
								
								<tr>
									<th class="main info_header" colspan="2">Merging features</th>
								</tr>
								<tr>
									<td class="main info_bold">~Source feature~<font color="red"> (this one will be removed)</font></td>
									<td class="main info_bold">%%src_feature_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold"><b>~Destination feature~</b></td>
									<td class="main info_bold">%%dst_feature_id%%</td>
								</tr>
								<tr>
									<td class="main info_bold" colspan="2" align="center">
										%%insert_action%%
									<td>
								</tr>
							</form>
							
					</td>
				</tr>
				</table>
				
		</td>
	</tr>
	</table>
	
</table>
}

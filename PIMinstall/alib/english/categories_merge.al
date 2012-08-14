{
name: categories_merge;

insert_action: <input type="submit" name="atom_submit" value="Merge">

cat_div: ---;
any_cat: None;


body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							
							<form method="post">
								
								<input type="hidden" name="atom_name" value="categories_merge">
								<input type="hidden" name="sessid" value="%%sessid%%">
								<input type="hidden" name="tmpl_if_success_cmd" value="cats.html">
								<input type="hidden" name="tmpl" value="categories_merge.html">
								
								<input type="hidden" name="command" value="merge_categories">
								
								<tr>
									<th colspan="2" class="main info_header">Merging categories</th>
								</tr>

								<tr>
									<td class="main info_bold">~Source category~ <span style="color: red;">(this one will be removed)</span></td>
									<td class="main info_bold"><table><tr><td>%%src_catid%%<td></table></td>
								</tr>
								
								<tr>
									<td class="main info_bold"><b>~Destination category~</b></td>
									<td class="main info_bold"><table><tr><td>%%dst_catid%%<td></table></td>
								</tr>

								<tr>
									<td class="main info_bold" colspan="2" align="center">
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

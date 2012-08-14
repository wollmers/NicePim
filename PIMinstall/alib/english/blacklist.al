{
name: blacklist;

$$INCLUDE nav_inc.al$$

black_list_row:
<tr>
	<!--<td class="main info_bold" width="20%" align="center">
     			
     			</td>-->
	<td class="main info_bold" width="100%" align="center" >
		<p>%%language_name%%<br />
     	<textarea name="%%language_id%%" cols=100 rows=4>%%black_words%%</textarea></p>
  </td>
</tr>

body:
<form name="blacklist" method="post">

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header">The list with specific words for different languages</th>
								</tr>
								<tr>
									<td class="main info_bold" width="100%" align="center" >
										<p><i>%%confirm_msg%%</i></p><p>&nbsp;</p>
									</td>
								</tr>
								
								%%black_list_rows%%
								
								<tr>
									<td class="main info_bold" width="100%" align="center" > <!-- colspan="2" -->
										<table><tr><td><input type="submit" value="Update"><td><input type="reset" value="Reset"></table>
									</td>
								</tr>
								
								<input type="hidden" name=atom_name value="blacklist">
								<input type="hidden" name=sessid value="%%sessid%%">
								<input type="hidden" name=tmpl_if_success_cmd value="blacklist.html">
								<input type="hidden" name=tmpl value="blacklist.html">
								<input type="hidden" name=command value="blacklist_update">
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>

}




{
name: product_post_complain;

body:
<form method=post>

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">

				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" width="50"><b>Date</b></td><td class="main info_bold">%%date%%</td>
								</tr>
								<tr>
									<td class="main info_bold" width="50"><b>From</b></td><td class="main info_bold"> %%uname%% (%%uemail%%)</td>
								</tr>
								%%to_nobody%%
								<tr>
									<td class="main info_bold" width="50"><b>Subject</b></td><td class="main info_bold" align=left><input type=text name=subject size="85"></td>
								</tr>
								<tr>
									<td class="main info_bold" valign=top><b>Message </b></td>
									<td class="main info_bold"><textarea cols=64 rows=11 wrap="soft" name=message></textarea></td>
								</tr>
								<tr>
									<td class="main info_bold" colspan="2">
										<input type=hidden name=sessid value="%%sessid%%">
										<input type=hidden name=tmpl value="products_complaint.html">
										<input type=hidden name=product_id value=%%product_id%%>
										<input type=hidden name=command value=post_complain>
										<input type=hidden name=uname value="%%uname%%">
										<input type=hidden name=uemail value="%%uemail%%">
										<div align=right style="margin-right:127px"><input type=submit name=respond value="Add complaint" class="elem"></div>
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

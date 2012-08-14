{
name: category_features_batch;

report_body:

<table witdh="100%">
	<tr>
		<td class="main info_bold" colspan="2">Report</td>
	</tr>
	%%report_rows%%
</table>

report_row: <tr><td class="main info_bold">%%value%%</td><td class="main info_bold">%%status%%</td></tr>

row_status_0: OK
row_status_2: Already exists
row_status_3: Category is invalid
row_status_4: Feature is invalid
row_status_5: Category and feature are invalid

body:
 %%report%%
 
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">Batch</th>
							</tr>

							<form method="post">
								<input type="hidden" name="sessid" value="%%sessid%%">
								<input type="hidden" name="tmpl" value="cat_feat_batch.html">
								<tr>
									<td class="main info_bold" align="center">
										<textarea name="batch" cols="80" rows="20">%%batch%%</textarea>
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align="center">
										<input name="process_batch" type="submit" value="Process batch">
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

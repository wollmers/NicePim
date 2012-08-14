{
name: product_multimedia_object_details;

delete_object_value:Delete object;
update_object_value:Update object;

body:
<form name="object_details_form" method="post" enctype="multipart/form-data">
	<br>

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">

				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" width="20%">Object</td>
									<td class="main info_bold">%%object%%</td>
								</tr>
							</table>

						</td>
					</tr>
				</table>

			</td>
		</tr>
	</table>

	<br />

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">

				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<td class="main info_bold" width="20%">Language</td>
									<td class="main info_bold">%%object_langid%%</td>
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">Short description</td>
									<td class="main info_bold">
										<input type="text" name="object_descr" value="%%object_descr%%" class="smallform" size="80">
									</td>
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">Size</td>
									<td class="main info_bold">%%object_size%% Kb</td>
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">Content type</td>
									<td class="main info_bold">%%object_type%%</td>
									<input type="hidden" name="object_type" value="%%object_type%%">
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">~Object URL~</td>
									<td class="main info_bold">
										<input type="text" size="80" name="object_url" value="%%object_url%%" class="smallform">
										or <br><input type="file" name="object_url_filename" class="smallform">
									</td>
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">~Keep as url?~</td>
									<td class="main info_bold">%%keep_as_url%%</td>
									<!--	 <input type="hidden" name='keep_as_url' value="%%keep_as_url%%">-->
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">~Type~</td>
									<td class="main info_bold">%%type%%</td>
									<!--	 <input type="hidden" name='type' value="%%type%%">-->
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">~Height~</td>
									<td class="main info_bold">%%height%%</td>
									<input type="hidden" name="height" value="%%height%%">
								</tr>
								<tr bgcolor="white">
									<td class="main info_bold">~Width~</td>
									<td class="main info_bold">%%width%%</td>
									<input type="hidden" name="width" value="%%width%%">
								</tr>
								<tr bgcolor="white" align="right">
									<td class="main info_bold" colspan="2">
										<input type="hidden" name="atom_name" value="product_multimedia_object_details">
										<input type="hidden" name="sessid" value="%%sessid%%">
										<input type="hidden" name="tmpl" value="product_multimedia.html">
										<input type="hidden" name="tmpl_if_success_cmd" value="product_multimedia.html">
										<input type="hidden" name="product_id" value="%%product_id%%">
										<input type="hidden" name="object_id" value="%%object_id%%">
										<input type="hidden" name="command" value="get_object_url,store_pics_origin_mmo_update,add2editors_journal">
										
										<!--
										    first precommand -- for history,
										    second precommand -- to store picture origin
										-->
										
										<input type="hidden" name="precommand" value="save_values_for_history_product_multimedia_object,store_pics_origin_mmo">
										
										
										<input type="submit" name="atom_submit" value="Update object" class="smallform">
										<input type="submit" name="atom_submit" value="Delete object" class="smallform">
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

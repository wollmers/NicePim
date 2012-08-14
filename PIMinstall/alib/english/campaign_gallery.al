{
name: campaign_gallery;

$$INCLUDE actions2.al$$

campaign_gallery_row:
												<td class="main info_bold" align="center" colspan="2">
													<input type="hidden" id="logo_pic_%%campaign_gallery_id%%" value="%%logo_pic%%">
													<img height="75" width="75" src="%%thumb_pic%%" title="%%thumb_pic%%" onClick="javascript: edit_campaign_gallery_image(%%campaign_gallery_id%%);"/>
													<br />
													<span class="linksubmit" onClick="javascript: delete_campaign_gallery_image(%%campaign_gallery_id%%); document.getElementById('gallery_form').submit();">delete</span>
												</td>

body:
								<tr>
									<th class="main info_header" colspan="2">Campaign images</th>
								</tr>

								<tr>
									<td class="main info_bold" colspan="2">

<script type="text/javascript">
<!--

		function delete_campaign_gallery_image(id) \{
				document.getElementById('campaign_gallery_id').value = id;
				document.getElementById('set_atom_delete').name = 'atom_delete';
		\}

		function edit_campaign_gallery_image(id) \{ // also add
				if (id != 0) \{
						var text = 'Edit campaign image';
						document.getElementById('logo_pic').value = document.getElementById('logo_pic_'+id).value;
						document.getElementById('logo_pic_img_tag').src = document.getElementById('logo_pic_'+id).value;
						document.getElementById('campaign_gallery_add_span').style.display = '';
						document.getElementById('logo_pic_img_tag').style.display = '';
						document.getElementById('gallery_insert_submit').style.display = 'none';
						document.getElementById('gallery_update_submit').style.display = '';
				\}
				else \{
						var text = 'Add new campaign image';
						document.getElementById('logo_pic').value = '';
						document.getElementById('logo_pic_img_tag').src = '';
						document.getElementById('campaign_gallery_add_span').style.display = 'none';
						document.getElementById('logo_pic_img_tag').style.display = 'none';
						document.getElementById('gallery_update_submit').style.display = 'none';
						document.getElementById('gallery_insert_submit').style.display = '';
				\}
				document.getElementById('campaign_gallery_text').innerText = text;
				document.getElementById('campaign_gallery_text').innerHTML = text;
				document.getElementById('campaign_gallery_id').value = id;
		\}

// -->
</script>

										<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
											<tr>
												<td class="main info_bold" align="center" colspan="2">
													<input type="hidden" id="logo_pic_0" value="">
													<span class="linksubmit" height="75" width="75" onClick="javascript: edit_campaign_gallery_image(0);" style="display: none;" id="campaign_gallery_add_span"/>add image</span>
												</td>
												%%campaign_gallery_rows%%
											</tr>
										</table>
									</td>
								</tr>

								<tr>
									<td class="main info_bold" align="center" colspan="2">
										<div style="height: 200px;">
											<img id="logo_pic_img_tag" src="" style="display: none;">
										</div>
<!--									</td>
									<td class="main info_bold">-->
<form method="post" enctype="multipart/form-data" id="gallery_form">

  <input type="hidden" name="atom_name" value="campaign_gallery">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl" value="campaign_kit.html">
  <input type="hidden" name="campaign_id" id="campaign_id" value="%%campaign_id%%">
  <input type="hidden" name="command" value="get_obj_url">

  <input type="hidden" name="user_id" id="user_id" value="%%user_id%%">
  <input type="hidden" name="campaign_gallery_id" id="campaign_gallery_id" value="">
  <input type="hidden" name="campaign_tab" id="campaign_tab" value="2">

										<table border="0" cellpadding="3" cellspacing="1" align="center">
											<tr>
												<td colspan="2">
													<span id="campaign_gallery_text">Add new campaign image</span>
												</td>
											</tr>
											<tr>
												<td colspan="2">
													<input class="text" name="logo_pic" id="logo_pic" value="" type="text" style="width: 400px;">
												</td>
											</tr>
											<tr>
												<td>
													<input name="logo_pic_filename" style="width: 250px;" type="file">
												</td>
												<td>
													<input type="hidden" name="" id="set_atom_delete" value="." />
													<div id="gallery_insert_submit">
														<input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_add.gif) no-repeat;' name="atom_submit" value="." />
													</div>
													<div id="gallery_update_submit" style="display: none;">
														<input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_save.gif) no-repeat;' name="atom_update" value="." />
													</div>
												</td>
											</tr>
										</table>
</form>
									</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>

<!--<br />-->

}


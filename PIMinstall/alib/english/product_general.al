<script type="text/javascript">
<!--
function show_details(id1, id2) \{
  var description = document.getElementById(id1);
	if(id2)\{
 	 var image = document.getElementById(id2);
	\}
  if (description.style.display != 'block') \{
		 description.style.display = 'block';
		 if(id2)\{image.src = '../../img/minus.gif'\};
	\} else \{
		 description.style.display = 'none';
		 if(id2)\{image.src = '../../img/plus.gif'\};
	\}
	 	 return false;
	\}
function update_title() \{
	var tid = document.getElementById('product_title_container');
	var brand = '';
	try \{
		var bid = document.getElementById('supplier_id');
		brand = bid.options[bid.selectedIndex].text;
		if (brand == 'Any brand') \{
			brand = '';
		\}
	\} catch (e) \{
		var bid = document.getElementById('supplier_link');
		brand = bid.text;
	\}
	var family = '';
	try \{
		var fid = document.getElementById('family_id');
		family = fid.options[fid.selectedIndex].text;
		if (family == 'None') \{
			family = '';
		\}
	\} catch (e) \{
	\}
	var model = '';
	try \{
		model = document.getElementsByName('name')[0].value;
	\} catch (e) \{
	\}
	tid.innerHTML = brand + ' ' + family.replace(/^\s*\-+/i, '') + ' ' + model;
\}
// -->
</script>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								
								<td class="main info_bold" width="20%" align="right">~Product ID~</td>
								<td class="main info_bold" width="80%">
									<div style="color: #000000; font-weight: bold;">%%product_id%%</div>
								</td>
								
								<!-- gallery pics started -->
								<td rowspan="20" valign="top">%%gallery_pics%%</td>
								<!-- gellery pics ended -->
								
							</tr>
	 						<tr>
								<td class="main info_bold" align="right">~Date added~</td>
								<td class="main info_bold">
									<font color="black">&nbsp;%%date_added%%</font>
								</td>
							</tr>
	 						<tr>
								<td class="main info_bold" align="right">~Last update~</td>
								<td class="main info_bold">
									<div style="color: black; display: inline;">&nbsp;%%updated%%</div>&nbsp;&nbsp;&nbsp;
									<div style="display: inline;">%%product_xml_indicator%%</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">
									<span style="color: red;">*</span>~Part number~
								</td>
								<td class="main info_bold">
									<input type="text" size="20" name="prod_id" value="%%prod_id%%">&nbsp;<span style="color: red;">%%prod_id4valid%%</span>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">
									<span style="color: red;">*</span>~Brand~
								</td>
								<td class="main info_bold">
									<table><tr><td>%%supplier_id%%<td>%%supplier_det_link%%</table>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" id="odata" align="right">
									<span style="color: red;">*</span>~Category~
								</td>
								<td class="main info_bold"><table><tr><td>%%catid%%<td><span class="linksubmit" onClick="show_details('odiv');">Original data</span></table></td>
							</tr>
							<tr>
							<!-- virtual categories -->
								<td class="main info_bold" id="odata" align="right">
									~Virtual category~
								</td>
								<td class="main info_bold">
								    <div id="vcats_container_tmp">
								        %%vcats%%
								    </div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">
									<span style="color: red;">*</span>~Product families~
								</td>
								<td class="main info_bold">
								<div id="family_select_container">
									%%family_id%%
								</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">
									<span style="color: red;">*</span>~Product series~
								</td>
								<td class="main info_bold">
								<div id="series_select_container">
									%%series_id%%
								</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" colspan="2" bgcolor="white">
	 								<table cellspacing="1" cellpadding="2" class="tabs" id="tabs">
	 									<tr>%%lang_tabs%%</tr>
									</table>
									<div style="display:block" id="name_tab_id_0">
										<table cellspacing="0" cellpadding="5" width="100%" bgcolor="#E3EEF8">
											<tr>
												<td width="20%" align="right">
													<span style="color: red;">*</span>~Model name~
												</td>
												<td>
													<input type="text" name="name" value="%%name%%" size="80" onchange="update_title()">
												</td>
											</tr>
										</table>
									</div>
									%%tab_names%%
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">
									Product title
								</td>
								<td class="main info_bold">
									<div id="product_title_container" style='color:SeaGreen;font-family:Lucida Sans Mono;font-size:12px;'>
										%%title%%
									</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" colspan="2">
									<div id="odiv" style="display: none;">
                                        <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                        <td style="padding-top:10px">
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
                                        <tr>
                                        <td>
                                        <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
											<tr>
												<th class="main info_header">Distributor</th>
												<th class="main info_header">Name from distributor</th>
												<th class="main info_header">ProdId</th>
												<th class="main info_header">Category</th>
												<th class="main info_header">Vendor</th>
												<th class="main info_header">Original brand</th>
												<th class="main info_header">ProdLevId</th>
											</tr>
											%%product_original_rows%%
                                        </table>
                                        </table>
                                        </table>
									</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">~Owner~</td>
								<td class="main info_bold">%%edit_user_id%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">~Publish~</td>
								<td class="main info_bold">%%publish%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right">~TopSeller~</td>
								<td class="main info_bold">%%topseller%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right" title="Public attribute for product\: Yes - be able to publish into repository, Limited - shouldn't published there">~Public~</td>
								<td class="main info_bold">%%public%%</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right"><nobr class="main info_bold">Checked by supereditor</nobr></td>
								<td class="main info_bold">
									<div id="checked_by_supereditor_container">
										%%checked_by_supereditor%%
									</div>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" valign="top" align="right">~Thumbnail URL~</td>
								<td class="main info_bold" valign="top">
									<a href="%%thumb_pic%%" target="_blank">%%thumb_pic%%</a>
<script>
<!--
if (%%thumb_pic_size%% + 0 != 0) \{ document.write('&nbsp;(%%thumb_pic_size%% bytes) '); \}
// -->
</script>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" valign="top" align="right">~Low res picture URL~</td>
								<td class="main info_bold" valign="top">
									<a href="%%low_pic%%" target="_blank">%%low_pic%%</a>
<script>
<!--
if (%%low_pic_size%% + 0 != 0) \{ document.write('&nbsp;(%%low_pic_size%% bytes) '); \}
// -->
</script>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" valign="top" align="right">~High res picture URL~</td>
								<td class="main info_bold" valign="top">
									<input type="text" name="high_pic" value="%%high_pic%%" size="80">
	 								or
									<input type="file" name="high_pic_filename">
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right" valign="top">~Markets~:
								</td>
								<td class="main info_bold">
									<font color="black">%%market_state%%</font>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" align="right" valign="top">~Score~:
								</td>
								<td class="main info_bold">
									<font color="black">%%product_score%%</font>
								</td>
							</tr>
							<tr>
								<td class="main info_bold" colspan="2" align="center">
									<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
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


{
name: campaign_kit;
class: history;

body:

<table cellpadding="0" cellspacing="0" width="100%">
  <tr>
		<td class="main" height="20" bgcolor="#ffffff">
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a href="%%base_url%%;tmpl=campaigns.html">Campaigns</a>
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a href="%%base_url%%;tmpl=campaign_kit.html;campaign_id=%%campaign_id%%">%%name%%</a>
		</td>
	</tr>
</table>

<br />
}

{
name: campaign_kit;
class: add;

body:

%%warnings%%

<script type="text/javascript">
<!--

function to_products_list() \{
  document.getElementById('products_list').style.display = '';
  document.getElementById('campaign_kit_search_table').style.display = '';
  document.getElementById('add_products').style.display = 'none';
\}

// -->
</script>
							
<form method="post">
	
	<input type=hidden name=atom_name value="campaign_kit">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="campaign_kit.html">
	<input type=hidden name=campaign_id value="%%campaign_id%%">
	<input type=hidden name=command value="manage_campaign_kit">

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr align="center">
									<td align="center" bgcolor="#FFFFFF">
										<div id="add_products" style="display: none;">
											<span style="display: inline;"><b>Type some part codes to add them</b></span>
											<br />
											<textarea name="prod_id_set" id="prod_id_set" style="width: 343px; height: 200px;"></textarea>
											<br />
											<input type="submit" name="add_submit" value="Add products to campaign" style="width: 345px;">
											<br />
											<a href="#" onClick="javascript: to_products_list();">back to the products list</a>
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

}

{
name: campaign_kit;
class: list;

$$INCLUDE nav_inc.al$$

campaign_kit_row:
<tr>
	<td class="main info_bold" align="center">
		<input type="hidden" name="product_%%no%%" value="%%product_id%%">
		<input type="hidden" name="product_found" value="%%found%%">%%no%%&nbsp;/&nbsp;%%found%%</td>
	<td class="main info_bold" align="center" style="background-color: #ffffff;"><img src="%%thumb_pic%%" title="%%prod_id%%"></td>
	<td class="main info_bold" align="left"><nobr>
		<input type="checkbox" name="product_%%no%%_checkbox" id="product_%%no%%_checked" style="display: inline;" onChange="javascript:document.getElementById('del_selected_products_button').style.display='';">
		<a class="linksubmit" href="%%base_url%%;tmpl=product_details.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;mi=products">%%prod_id%%</a>
	</nobr></td>
	<td class="main info_bold" align="center">%%s_name%%</td>
	<td class="main info_bold" align="center"><div style="height\: 16px; overflow\: hidden;">%%name%%</div></td>
	<td class="main info_bold" align="center">%%clickthrough_count%%</td>
	<td class="main info_bold" align="center">%%product_view%%</td>
</tr>

body:

<!-- a list of products -->

<div id="products_list">

$$INCLUDE nav_bar2.al$$

<form method="post" id="form_for_kit">
	
	<input type=hidden name=atom_name value="campaign_kit">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="campaign_kit.html">
	<input type=hidden name=campaign_id value="%%campaign_id%%">
	<input type=hidden name=command value="manage_campaign_kit">
								
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" width="1%"><nobr># / ##</nobr></th>
									<th class="main info_header" width="75">Thumbnail</th>
									<th class="main info_header" width="15%">Part code</th>
									<th class="main info_header" width="10%">Brand</th>
									<th class="main info_header">Name</th>
									<th class="main info_header" width="9%">Clickthroughs</th>
									<th class="main info_header" width="9%">Product views</th>
								</tr>
								
								%%campaign_kit_rows%%
								
								<tr>
									<td colspan="2" class="main info_bold">&nbsp;</td>
									<td align="left" class="main info_bold">
										<input type="submit" class="hover_button" style="width:124px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete_selected.gif) no-repeat; display: none;" name="del_submit" value="." onClick="if(!confirm('Are you sure?')) return false;" id="del_selected_products_button">
										<input type="submit" class="hover_button" style="width:107px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete_all.gif) no-repeat;" name="del_all_submit" value="." onClick="if(!confirm('Are you sure?')) return false;" id="del_all_products_button">
									</td>
									<td colspan="4" class="main info_bold">&nbsp;</td>
								</tr>
								
							</table>

						</form>

$$INCLUDE nav_bar2.al$$

</div>

<script type="text/javascript">
<!--
	if ((%%campaign_id%% + 0 == 0) || (%%campaign_tab%% + 0 == 2)) \{
		changeTab(2,2);
	\}
// -->
</script>

}

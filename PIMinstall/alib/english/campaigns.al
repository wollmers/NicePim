{
name: campaigns;

$$INCLUDE nav_inc.al$$

default_date: &nbsp;;
date_format: %Y-%m-%d;

campaigns_row:
	<tr>
		<td class="main info_bold" align="center">%%no%%&nbsp;/&nbsp;%%found%%</td>
		<td class="main info_bold" align="center"><a href="%%base_url%%;tmpl=campaign_kit.html;campaign_id=%%campaign_id%%">%%name%%</a><br />%%short_description%%</td>
		<td class="main info_bold" align="center">%%start_date%% - %%end_date%%</td>
		<td class="main info_bold" align="center">%%number_of_products%%</td>
		<td class="main info_bold" align="center">
		<a href="%%base_url%%;tmpl=campaign_kit.html;campaign_id=%%campaign_id%%;campaign_tab=2"><div style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_edit.gif) no-repeat;' class="hover_button"></div></a>
		</td>
	</tr>

body:
<!-- continuing -->

		<td class="search" align="right" style="width:100%;padding-left:10px"><nobr><a style="font-size: 10px;" href="%%base_url%%;tmpl=campaign_kit.html" class="new-win">Create New Campaign</a></nobr></td>
	</tr>
</table>

<br />

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td class="external">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
$$INCLUDE nav_bar2.al$$

 						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header"># / ##</th>
								<th class="main info_header">Name</th>
								<th class="main info_header">Date</th>
								<th class="main info_header">Number of products</th>
								<th class="main info_header">Action</th>
							</tr>
							
							%%campaigns_rows%%
							
						</table>
						
$$INCLUDE nav_bar2.al$$

					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

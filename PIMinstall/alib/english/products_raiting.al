{
name: products_raiting;

$$INCLUDE nav_inc.al$$
rows_number: 40;

rating_row:
<tr bgcolor="#FFFFFF" nowrap>
	<td class="main info_bold" width="500">
		<a class="link" href="%%base_url%%;tmpl=products_raiting_details.html;product_id=%%product_id%%">%%product_name%%</a>
	</td>    
	<td class="main info_bold"> %%prod_id%% </td>
	<td class="main info_bold"> %%owner%% </td>
	<td class="main info_bold"> %%supplier_name%% </td>
	<td class="main info_bold" align=center> %%score%% </td>
	<td class="main info_bold" align=center> %%language_flag%% </td>
	<td class="main info_bold" align=center> %%status_mode%% </td>
	<td class="main info_bold" align=center> %%product_id_distributor%% </td>	
	<td class="main info_bold" align=center>
		<a href="%%base_url%%;tmpl=product_post_complain.html;product_id=%%product_id%%;user_id=%%user_id%%"><b>C</b></a>
		<input type=hidden name=cat_name value=%%cat_name%%>
 </td>
</tr>
			 
market_color_green: <font color=green>%%country_code%%</font>&nbsp;
market_color_gray: <font color=gray>%%country_code%%</font>&nbsp;			 

body:

$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" align=center>
									<a class="link" href="%%base_url%%;tmpl=products_raiting.html;search_status=%%search_status%%;search_name=%%search_name%%;search_prod_id_formated=%%search_prod_id_formated%%;order_products_raiting_rating=product_name">Product</a>
								</th>
								<th class="main info_header" align=center>Prod ID</th>
								<th class="main info_header" align=center>
									<a class="link" href="%%base_url%%;tmpl=products_raiting.html;order_products_raiting_rating=owner">Owner</a>
								</th>
								<th class="main info_header" align=center>
									<a class="link" href="%%base_url%%;tmpl=products_raiting.html;search_status=%%search_status%%;search_name=%%search_name%%;search_prod_id_formated=%%search_prod_id_formated%%;order_products_raiting_rating=supplier_name">Brand</a>
								</th>
								<th class="main info_header" align=center>
									<a class="link" href="%%base_url%%;tmpl=products_raiting.html;search_status=%%search_status%%;search_name=%%search_name%%;search_prod_id_formated=%%search_prod_id_formated%%;order_products_raiting_rating=score">Score</a>
								</th>
								<th class="main info_header" align=center>Descriptions</th>
								<th class="main info_header" align=center>Status</th>
								<th class="main info_header" align=center>Distributor</th>
								<th class="main info_header" align=center>C</th>
							</tr>
							
							%%rating_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

$$INCLUDE nav_bar2.al$$
}

{
name: products_raiting_details;
rows_number: 999999999;

tree_format:
%%value%%
tree_format_even:
%%value%%
tree_multi_1: 10;
tree_multi: 15;

color_shift:#F5F5F5;
color_no_shift:#FFFFFF;

requires_row:
<tr bgcolor="#FFFFFF" nowrap class="maintxt" align="center">
  <td class="main info_bold">%%login%%</td>
  <td class="main info_bold">%%email%%</td>
  <td class="main info_bold">%%message%%</td>
	<td class="main info_bold">%%todate%%</td>
	<td class="main info_bold">%%date%%</td>
</tr>

body:
<div style="margin-left: %%tree_multi%%px;" align=center><b>Product ID %%product_id%% details</b></div>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">Name</th><th class="main info_header">Prod_ID</th><th class="main info_header">Brand</th><th class="main info_header">Owner</th><th class="main info_header">Score</th><th class="main info_header">Stock</th><th class="main info_header">Requests</th><th class="main info_header">Updated</th><th class="main info_header">Status</th><th class="main info_header">Price</th>
							<tr>
							<tr align=center class='maintxt'>
								<td class="main info_bold">%%name%%</td><td class="main info_bold">%%prod_id%%</td><td class="main info_bold">%%supplier_name%%</td><td class="main info_bold">%%owner%%</td><td class="main info_bold">%%score%%</td><td class="main info_bold">%%stock%%</td><td class="main info_bold">%%product_requested%%</td><td class="main info_bold">%%updated%%</td><td class="main info_bold">%%status_mode%%</td><td class="main info_bold">%%price%%</td>
							</tr>
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

<div style=" margin-left: %%tree_multi%%px;" align='center'><b>Clients requests</b></div>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" align=center width=100>Login</th>
								<th class="main info_header" align=center width=150>Email</th>
								<th class="main info_header" align=center width=240>Message</th>
								<th class="main info_header" align=center>To date</th>
								<th class="main info_header" align=center>Date</th>
							</tr>
							
							%%requires_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

<div style=" margin-left: %%tree_multi%%px;" align=center>
	<a href="%%base_url%%;tmpl=product_details.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;">
	  <b>Describe this product</b>
	</a>
</div>

}								 

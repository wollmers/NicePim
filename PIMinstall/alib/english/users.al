{		
name: users;

$$INCLUDE nav_inc.al$$

users_row: 
<tr>
	<td class="main info_bold"><a href="%%base_url%%;tmpl=user_edit.html;edit_user_id=%%edit_user_id%%">%%login%%</a></td>
	<td class="main info_bold">%%user_group%%</td>
	<td class="main info_bold">%%cnt%%</td>
	<td class="main info_bold">%%country%%</td>
	<td class="main info_bold">%%company%%</td>
	<td class="main info_bold">%%sector%%</td>
	<td class="main info_bold">%%email_subscribing%%</td>
</tr>

body:

<!-- continuing -->

    <td class="search" align="right" style="width:100%;padding-left:10px"><nobr><a href="%%base_url%%;tmpl=user_edit.html" class="new-win">New user</a></td>
  </tr>
</table>

$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="15%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_users_users=login;">User</a></th>
								<th class="main info_header" width="10%"><a href="%%base_url%%;tmpl=%%tmpl%%;order_users_users=user_group;">User type</a></th>
								<th class="main info_header" width="10%">No of products</th>
								<th class="main info_header" width="20%">Country</th>
								<th class="main info_header" width="20%">Company</th>
								<th class="main info_header" width="15%">Sector</th>
								<th class="main info_header" width="10%">Subscribed</th>
							</tr>
							
							%%users_rows%%
							
						</table>

					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

{
name: users_search;

search_user_partner_id_dropdown_empty: Any partner;
search_user_country_id_dropdown_empty: Any country;
search_subscription_level_dropdown_empty: Any level;
search_user_group_dropdown_empty: Any group;

body:

<script type="text/javascript">
<!--
	function submit_users(sel) \{
		if(sel != 2) \{
			document.getElementById("send_email").value = "";
			document.getElementById("f_u_s").submit();
      document.getElementById("send_email").value = "Send file with users";
		\}
		else \{
			document.getElementById("search_users").value = "";
			document.getElementById("f_u_s").submit();
			document.getElementById("search_users").value = "Search";
		\}
	\}
// -->
</script>

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
		<form method=post id="f_u_s">
			<input type=hidden name=sessid value="%%sessid%%">
			<input type=hidden name=search_atom value=users>
			<input type=hidden name=tmpl id="tmpl" value="auth.html">

			<td class="search">
				<table align="center" cellspacing="0">
					<tr>
						<td>
							<table><tr><td>login<td><input class="text" type=text name=search_login value="%%search_login%%" size=20 class="smallform"></table>
						</td>
						<td>
							<table><tr><td>email<td><input class="text" type=text name=search_email value="%%search_email%%" size=20 class="smallform"></table>
						</td>
						<td>
							<table><tr><td>%%search_subscription_level%%<td>%%search_user_group%%</table>
						</td>
						<td>
							<input type="submit" name="search_users" id="search_users" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" value="." class="hover_button" onclick="submit_users(1);">
						</td>
					</tr>
					<tr>
						<td>
							<table><tr><td>URL<td><input class="text" type=text name=search_url value="%%search_url%%" size=20 class="smallform"></table>
						</td>
						<td>
							<table><tr><td>company<td><input class="text" type=text name=search_company value="%%search_company%%" size=20 class="smallform"></table>
						</td>
						<td>
							<table><tr><td>%%search_user_partner_id%%<td>%%search_user_country_id%%</table>
						</td>
						<td align="center">
							<a style="cursor: pointer; text-decoration: underline;" onClick="javascript:document.getElementById('search_by_email').style.display = '';">by email</a>
						</td>
					</tr>
				</table>
<table class="search" align="right" style="display: none;" id="search_by_email">
	<tr>
		<td>
			<input type="text" name="email" id="email" value="email" />
		</td>
		<td>
			<input type="submit" name="send_email" id="send_email" style="width:142px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_by_mail.gif) no-repeat;" value="." class="hover_button" onclick="submit_users(2);">
		</td>
	</tr>
</table>

			</td>

			<input type=hidden name=search_login_mode   value=like>
			<input type=hidden name=search_company_mode value=like>
			<input type=hidden name=search_url_mode     value=like>
			<input type=hidden name=search_email_mode   value="case_insensitive_like">
			<input type=hidden name=order_users_users   value="%%order_users_users%%">
			<input type=hidden name="new_search" value="1">
			
			%%message_sent%%
			
		</form>

		<!-- to be continued -->
}
						    

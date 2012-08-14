{
name: user;

$$INCLUDE actions2.al$$

access_restriction_0: Off
access_restriction_1: On

default_access_restriction: 0;

repository_check: <input style="display\: inline;" type=checkbox name=repository_ >

email_subscribing_tag_attributes: style="display\: inline;"
email_subscribing_checked_by_default: Y;

platform_dropdown_name_empty: Undefined;
sector_id_dropdown_empty: IT;

logo_pic_html: <span id="implementation_partner_cont_logo" style="display:%%style_show%%"><input type="file" name="logo_pic_file" size="50"/><br><input type="text" name="logo_pic" size="50" value="%%logo_pic%%"/><br/><img src="%%logo_pic_view%%" alt="image not available"/></span>

body:
<script type="text/javascript">
	<!-- 
		function hide_checks() \{
			var level = document.getElementById("subscription_level");
			var reps = document.getElementById("access_reps");
			if (level.value != 4) \{ 
				reps.style.display = 'none';
			\}
			else \{
				reps.style.display = '';
			\}
		\}
	// -->
</script>

<form method="post" enctype="multipart/form-data">

	<input type="hidden" name="atom_name" value="user">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="auth.html">
	<input type="hidden" name="tmpl" value="user_edit.html">
	<input type="hidden" name="edit_user_id" value="%%edit_user_id%%">
	<input type="hidden" name="link_supplier_id" value="%%link_supplier_id%%">
	<input type="hidden" name="pers_cid" value="%%pers_cid%%">	
	<input type="hidden" name="command" value="htpass_add_user,update_users_repo_access,add_custom_sector,link_user_with_brand">
   
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

							<span>%%icetoolsurl%%</span>

							<br />
							<br />
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="2">User details</th>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;">*</span>~Login~</td>
									<td class="main info_bold"><input type="text" name="login" value="%%login%%" size="20" style="display: inline;"></td>
								</tr>

								<tr>
									<td class="main info_bold" align="right"><span style="color: red;">*</span>~Password~</td>
									<td class="main info_bold"><input type="text" name="password" value="%%password%%" size="20"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;">*</span>~User group~</td>
									<td class="main info_bold">%%user_group%%&nbsp;&nbsp;&nbsp;<span id="choose_brands" style="display: none;"><a href="%%base_url%%;tmpl=user_brands.html;edit_user_id=%%edit_user_id%%">choose brands</a><span></td>
								</tr>
								
								<tr style="display: %%display_partner%%" id="is_implementation_partner_tr">
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Implementation partner~</td>
									<td class="main info_bold">%%is_implementation_partner%%</td>
								</tr>

								<tr style="display: %%display_partner%%" id="is_implementation_partner_logo_tr">
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Logo~</td>
									<td class="main info_bold">%%logo_pic%%</td>
									<script type="text/javascript">
										<!--
											 hide_user_shop_sett(document.getElementById('user_group'));
											 //-->
									</script>

								</tr>
								
								<tr>
  								<td class="main info_bold" align="right"><span style="color: red;">*</span>~Statistic enabled~</td>
  								<td class="main info_bold">%%statistic_enabled%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~IP address access restrictions~</td>
									<td class="main info_bold">%%access_restriction%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Allowed addresses~</td>
									<td class="main info_bold"><input type="text" name="access_restriction_ip" value="%%access_restriction_ip%%" size="80"></td>
								</tr>
								
								<tr>
  								<td class="main info_bold" align="right">~Allow access via FTP~</td>
  								<td class="main info_bold">%%access_via_ftp%%&nbsp;&nbsp;&nbsp;<a href="ftp\://%%login%%\:%%password%%@%%icecat_hostname_raw%%/">ftp\://%%icecat_hostname_raw%%/</a></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Subscription level~</td>
									<td class="main info_bold">%%subscription_level%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Access respository~</td>
									<td class="main info_bold"><b>%%access_repository%%</b></td>
								</tr>
								
								<tr>
  								<td class="main info_bold" align="right">~Partner for this user~</td>
  								<td class="main info_bold">%%user_partner_id%%&nbsp;&nbsp;&nbsp;<span style="color: green;" face="sans-serif" size="2">[acceptable only for users in group 'shop']</span></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Expiration date~</td>
									<td class="main info_bold"><input type="text" name="login_expiration_date" value="%%login_expiration_date%%" size="30" style="display: inline;">&nbsp;&nbsp;&nbsp;<span style="color: green;" face="sans-serif" size="2">[DATE FORMAT: YYYY-MM-DD hh:mm:ss]</span></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Products entered~</td>
									<td class="main info_bold" style="color:red">%%cnt%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Reference field~</td>
									<td class="main info_bold"><textarea cols="60" rows="4" name="reference">%%reference%%</textarea></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;">*</span>~Name~</td>
									<td class="main info_bold"><input type="text" name="person" value="%%person%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;">*</span>~Email~</td>
									<td class="main info_bold">
										<input type="text" name="email" value="%%email%%" size="26" style="display: inline;">&nbsp;&nbsp;&nbsp;%%email_subscribing%% subscribe to the newsletter
									</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Company~</td>
									<td class="main info_bold"><input type="text" name="company" value="%%company%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Sector~</td>
									<td class="main info_bold">%%sector_id%%</td>
								</tr>

								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Position~</td>
									<td class="main info_bold"><input type="text" name="position" value="%%position%%" size="26"></td>
								</tr>

								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Platform~</td>
									<td class="main info_bold" id="platform_container">%%platform%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Phone~</td>
									<td class="main info_bold"><input type="text" name="phone" value="%%phone%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Mobile phone~</td>
									<td class="main info_bold"><input type="text" name="mphone" value="%%mphone%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Fax~</td>
									<td class="main info_bold"><input type="text" name="fax" value="%%fax%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~ICQ~</td>
									<td class="main info_bold"><input type="text" name="icq" value="%%icq%%" size="10"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right">~Country~</td>
									<td class="main info_bold">%%country_id%%</td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~City~</td>
									<td class="main info_bold"><input type="text" name="city" value="%%city%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~Street~</td>
									<td class="main info_bold"><input type="text" name="street" value="%%street%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~House number~</td>
									<td class="main info_bold"><input type="text" name="nbr" value="%%nbr%%" size="6"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~ZIP~</td>
									<td class="main info_bold"><input type="text" name="zip" value="%%zip%%" size="26"></td>
								</tr>
								
								<tr>
									<td class="main info_bold" align="right"><span style="color: red;"></span>~URL~</td>
									<td class="main info_bold"><input type="text" name="url" value="%%url%%" size="26"></td>
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

<script type="text/javascript">
<!--    
function update_combobox(ref) \{
    if (ref.value == "Custom...") \{
	nm = ref.name;
	div = document.getElementById(nm + "_container");
	div.innerText = "<input type='text' name=" + nm + " value='' size=23><input type='hidden' name='" + nm + "_use_custom' value='1'>";
	div.innerHTML = "<input type='text' name=" + nm + " value='' size=23><input type='hidden' name='" + nm + "_use_custom' value='1'>";
    \}
\}
//-->
</script>

}

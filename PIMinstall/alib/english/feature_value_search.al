{
name: feature_value_search;

search_feature_values_group_id_dropdown_empty: Any group;

local_value_search_row:
<tr>
	<td>
		<table cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<input type="checkbox" name="%%lang_code%%_local_value" value="0"
								 %%checked_no%%
								 onClick='javascript:if(document.search_form.%%lang_code%%_local_value[1].status == 1)\{
								 document.search_form.%%lang_code%%_local_value[1].status = 0\}'>
				</td>
				<td>don't</td>
				<td>
					<input type="checkbox" name="%%lang_code%%_local_value" value="1"
								 %%checked_yes%%
								 onClick='javascript:if(document.search_form.%%lang_code%%_local_value[0].status == 1)\{
								 document.search_form.%%lang_code%%_local_value[0].status = 0\}'>
				</td>
				<td>has&nbsp;%%lang_name%%&nbsp;value</td>
			</tr>
		</table>
	</td>
</tr>

body:

<form method="post" name="search_form">
  <input type="hidden" name="search_eng_value_mode" value="like">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="search_atom" value="feature_values_vocabulary">
	<input type="hidden" name="tmpl" value="feature_values_vocabulary.html">
  <input type="hidden" name="EN_local_value" value="1">

	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
		<tr>
      <td valign="top" class="search">%%search_feature_values_group_id%%</td>
			<td valign="top" class="search">
				<input type="text" name="search_eng_value" value="%%search_eng_value%%" size="30" class="smallform">
			</td>
			<td valign="top" class="search">
				<table align="center" class="smallform" cellpadding="0" cellspacing="0" style="font-size: 10px;">
					%%local_value_search%%
				</table>
			</td>
			<td valign="top" class="search"><input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search"></td>
			<td valign="top" class="search" style="width: 100%; padding-left: 10px;" align="right"><a class="new-win" href="%%base_url%%;tmpl=feature_value_edit.html">New feature value</a></td>
		</tr>
	</table>

</form>

}

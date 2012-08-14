{

name: products_raiting_search;

search_ssupplier_id_dropdown_empty: Any brand;
search_distributor_id_dropdown_empty: Any distributor;
search_country_id_dropdown_empty: Any country;
search_owner_id_dropdown_empty: Any owner;
any_cat: Any category;
cat_div: ---;
search_catid_recurse_default: Y;
description_search_row:
<tr>
	<td>
		<input type=checkbox name="%%lang_code%%_description" value="0"
					 %%checked_no%%
					 onClick='javascript:if(document.myform.%%lang_code%%_description[1].status == 1)\{
					 document.myform.%%lang_code%%_description[1].status = 0\}'>
		<label>don't</label>
		<input type=checkbox name="%%lang_code%%_description" value="1"
					 %%checked_yes%%
					 onClick='javascript:if(document.myform.%%lang_code%%_description[0].status == 1)\{
					 document.myform.%%lang_code%%_description[0].status = 0\}'>
		<label>has %%lang_name%% description</label>
	</td>
</tr>


body:

<script type="text/javascript">
<!--
	function swap() \{
		if (document.getElementById('description_checkbox').checked == true) \{
			document.getElementById('description').style.display = 'block';
		\}
		else \{
			document.getElementById('description').style.display = 'none';
		\}
	\}

	function form_submit() \{
		document.getElementById('search_product_name').value=document.getElementById('search_prod_id').value;
		document.getElementById('myform').submit();
	\}
// -->
</script>

<form method=post name='myform' id='myform'>

	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
      <td class="search">
	<!-- PRODUCT choose -->
  <select name=search_status class=smallform id=search_status>
    <option value=>Any product</option>
    <option value="=0">Undescribed</option>
    <option value=1>Described</option>
  </select>
	<script type="text/javascript">
		<!--
			 document.getElementById('search_status').value='%%search_status%%';
			 // -->
	</script>
			</td>
      <td class="search">
	<!-- TEXT choose -->
  <input type=text name=search_prod_id id=search_prod_id value="%%search_prod_id%%" size=15 class="smallform">
  <input type=hidden name=search_product_name id=search_product_name value="%%search_product_name%%">
			</td>
      <td class="search">
	<!-- BRAND choose -->
	%%search_ssupplier_id%%
			</td>
      <td class="search" colspan="3">
	<!-- CAT choose -->
	%%search_catid%%
			</td>
	</tr>
	<tr>
      <td class="search">
	<!-- COUNTRY/MARKET choose -->
	%%search_country_id%%
			</td>
      <td class="search">
	<!-- DISTRIBUTOR choose -->
	%%search_distributor_id%%
			</td>
      <td class="search">
	<!-- OWNER choose -->
	%%search_owner_id%%
			</td>
      <td class="search">
	<!-- ONSTOCK checkbox -->
	<nobr>%%search_onstock%% on stock</nobr>
			</td>
      <td class="search">
	<!-- ONMARKET checkbox -->
	<nobr>%%search_onmarket%% on market</nobr>
			</td>
      <td class="search" style="text-align: left;">
	<!-- DESCRIPTION search -->
	<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name="new_search">
  <input type=hidden name=sessid value="%%sessid%%">
  <input type=hidden name=search_atom value=products_raiting>
  <input type=hidden name=tmpl value="products_raiting.html">
  <input type=hidden name=search_product_name_mode value=like>
  <input type=hidden name=search_prod_id_mode value=like>
  <input type=hidden name="new_search" value="1">
			</td>
	</tr>
	<tr>
    <td class="search" colspan="2" style="vertical-align: top;">
			<input type="checkbox" id="description_checkbox" onClick="javascript:swap();">show/hide description's conditions
	</td>
    <td class="search" colspan="3">
			<div id="description" style="display: none;">
				<table border=0 class=smallform cellpadding=0 cellspacing=0 style="font-size: 11px;" width=600>
					%%description_search%%
				</table>
			</div>
	</td>
	<td>
		
	</td>		
	</tr>
	</table>
	
</form>
}

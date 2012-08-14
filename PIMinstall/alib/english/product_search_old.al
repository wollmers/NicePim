{
name: product_search_old;

search_edit_user_id_dropdown_empty: Any editor;
search_supplier_id_dropdown_empty: Any brand;
any_cat: Any category;
cat_div: ---;
search_catid_recurse_default: Y;

search_period_assorted_list_values: 1,5,2,3,4;

search_period_value_1: Custom date
search_period_value_2: Last week
search_period_value_3: Last month
search_period_value_4: Last quarter
search_period_value_5: Last day

body:
<script type="text/javascript">
function show_advs() \{
  var advs = document.getElementById('advs');
  if (document.search_form.search_adv.value) \{
    advs.style.display = 'none';
    document.search_form.search_adv.value='';
  \} else \{
    advs.style.display = 'block';
    document.search_form.search_adv.value=1;
  \}
  return false;
\}

function deep_search_change() \{
	var deep_search = document.getElementById('deep_search');
	if (deep_search.value == "") \{
		deep_search.value = "%";
	\} else \{
		deep_search.value = "";
	\}
	return false;
\}

	function is_submit() \{
		if ((document.getElementById('search_prod_id').value.length >= 2)||(document.getElementById('search_prod_id').value.length == 0)) \{
			document.getElementById('search_form').submit();
		\} else \{
			alert("Please use search value length greater than 1 char");
		\}
	\}
</script>

 <form method=post name='search_form' id="search_form">
  <input type=hidden name=search_product_name_mode value=like>
	<input type=hidden name=search_prod_id_mode value=like>
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=search_atom value=products>
	<input type=hidden name=tmpl value="products.html">
	<input type=hidden name=command value="exec_clipboard_processing">
	<input type=hidden name=search_adv value="%%search_adv%%">
	<input type=hidden name=filter value="%%filter%%">
  <input type=hidden name=products_start_row value="">
<table align="center">
<tr>
	<td>%%search_supplier_id%%</td>
	<td>%%search_catid%%</td>
	<td><input type=text id="search_prod_id" name=search_prod_id value="%%search_prod_id%%" size=30 class="smallform"></td>
	<td>%%search_edit_user_id%%</td>
	<td width="10%"><input type=button name=new_search value="Search" class="smallform" onclick="is_submit()"></td>
	<td><a href="#" onclick="show_advs()" style="font:0.8em serif">advanced search</a></td>
</tr>
<tr>
	<td colspan=2></td>
		<input type=hidden id="deep_search" name=deep_search value="%%deep_search%%">
	<td colspan=5 style="font:0.7em serif" width="30%" nowrap>
	<nobr><input type=checkbox name=deep_search_trigger onclick="deep_search_change()" %%deep_search_checked%%>use deep search</nobr>
	</td>
</tr>
<tr>
	<td></td>
	<td colspan=5>
		<div id="advs">
			<table class="invisible"><tr>
				<td style="font:0.8em serif" width="30%" nowrap>Date added from</td>
				<td>%%search_from_day%% %%search_from_month%% %%search_from_year%% %%search_period%%</td>
			</tr><tr>
				<td style="font:0.8em serif" width="30%" nowrap>Date added to</td>
				<td>%%search_to_day%% %%search_to_month%% %%search_to_year%%</td>
			</tr>
			</table>
		</div>
	</td>
</tr>
</table>

<script type="text/javascript">
var advs=document.getElementById('advs');
if(document.search_form.search_adv.value)\{advs.style.display='block';\}else\{advs.style.display='none';\}
</script>
 </form>
}

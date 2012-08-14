{
name: product_search;

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
<!--
  function init_advs() \{
    var advs = document.getElementById('advs');
    var sadv = document.search_form.search_adv;
    var sbox = document.getElementById('search_box');

    if (sadv.value) \{
      advs.style.display = 'block';
      sadv.value = 1;
	    sbox.style.height = "116px";
    \}
    else \{
      advs.style.display = 'none';
      sadv.value = '';
	    sbox.style.height = "68px";
    \}
    return false;
	\}

  function swap_advs() \{
    var advs = document.getElementById('advs');
    var sadv = document.search_form.search_adv;
    var sbox = document.getElementById('search_box');

    if (sadv.value) \{
      advs.style.display = 'none';
      sadv.value = '';
	    sbox.style.height = "68px";
    \}
    else \{
      advs.style.display = 'block';
      sadv.value = 1;
	    sbox.style.height = "116px";
    \}
    return false;
	\}

  function deep_search_change() \{
	  var deep_search = document.getElementById('deep_search');
	  if (deep_search.value == "") \{
		  deep_search.value = "%";
	  \}
	  else \{
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
// -->
</script>

<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0">
  <tr>
    <td class="search" style="padding-left:10px;padding-right:5px;"><nobr> SEARCH PRODUCTS </nobr></td>
		
		<form method=post name='search_form' id="search_form">
			
			<input type=hidden name=search_product_name_mode value=like>
			<input type=hidden name=search_prod_id_mode value=like>
			<input type=hidden name=sessid value="%%sessid%%">
			<input type=hidden name=search_atom value=products>
			<input type=hidden name=tmpl value="products.html">
			<input type=hidden name=command value="exec_clipboard_processing">
			<input type=hidden name=search_adv value="%%search_adv%%">
			<input type=hidden name=filter value="%%filter%%">
			<td class="search" align="left">
				<table cellspacing="1" width="75%" border="0">
					<tr>
						<td>%%search_supplier_id%%</td>
						<td>%%search_catid%%</td>
						<td width="10%"><input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" name="new_search" value="Search" class="hover_button" onclick="is_submit()"></td>
						<td><a href="#" onclick="swap_advs();" style="font: 10px verdana">advanced search</a></td>
					</tr>
					

					
					<tr>
						<td><input class="text" type="text" id="search_prod_id" name=search_prod_id value="%%search_prod_id%%" style="width: 190px"></td>
						<td>%%search_edit_user_id%%</td>
						<td colspan=5 width="30%" nowrap>
							<input type=hidden id="deep_search" name="deep_search" value="%%deep_search%%">
							<nobr><input type="checkbox" name="deep_search_trigger" style="display: inline;" onclick="deep_search_change();" %%deep_search_checked%%><span style="font:10px verdana">use deep search</span></nobr>
						</td>
					</tr>
					
					<tr>
					    <td colspan="2">
					        <!-- external memory cells for vcat searcher -->
					        <input type="hidden" id="vcat_enable_all" name="vcat_enable_all" value="%%vcat_enable_all%%">
					        <input type="hidden" id="vcat_enable_list" name="vcat_enable_list" value="%%vcat_enable_list%%">
					        
    					    <div id="vcats_container_tmp_search">
	    				    %%search_vcats%%
		    			    </div>
					    </td>
					</tr>
					
					<tr>
						<td colspan=6>
							<div id="advs">
								<table class="invisible">
									<tr>
										<td style="font: 10px verdana" width="30%" nowrap>Date added from</td>
										<td>%%search_from_day%% %%search_from_month%% %%search_from_year%% %%search_period%%</td>
									</tr>
									<tr>
										<td style="font: 10px verdana" width="30%" nowrap>Date added to</td>
										<td>%%search_to_day%% %%search_to_month%% %%search_to_year%%</td>
									</tr>
									<tr>
										<td style="font: 10px verdana" width="30%" nowrap>Checked by supereditor</td>
										<td>%%checked_by_supereditor%%</td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
				</table>
			</td>
			
		</form>
		
<!-- to be continued -->

<script type="text/javascript">
<!--
	init_advs();
// -->
</script>

<script type="text/javascript">
	function allow_any_vcat() \{
	
	    ref = document.getElementById('hide_vcats');
	    var value;
	    
	    if (ref.style.display == 'none') \{
	        ref.style.display = 'block';
	        value = 1;
	    \}
	    else \{
	        ref.style.display = 'none';
	        value = 0;
	        
	        // disable all vcategories as well
	        document.getElementById('vcat_enable_list').value = '';
	        // kill all 'checked' labels
	        text = document.getElementById('vcats_container_tmp_search').innerHTML;
	        text = text.replace("checked>", ">");
	        document.getElementById('vcats_container_tmp_search').innerHTML = text;
	    \}
	    
	    hid = document.getElementById('vcat_enable_all');
	    hid.value = value;
	    
	    return;
	\}
	
	function update_vcats_list(c) \{
	    
	    hid = document.getElementById('vcat_enable_list');
	    value = hid.value;
	    cval = c.value;
	    
	    status = c.checked;
	    if (status == true) \{
	        value = value + '_' + cval + '_';
	    \}
	    else \{
	        re = RegExp("_" + cval + "_");
	        value = value.replace(re, '');
	    \}
	    // alert("HID = " + value + " CB = " + cval);
	    hid.value = value;
	    
	\}
</script>

}

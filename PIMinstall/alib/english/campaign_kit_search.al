{
name: campaign_kit_search;


body:

<script type="text/javascript">
<!--

function to_add_products() \{
	document.getElementById('products_list').style.display = 'none';
	document.getElementById('campaign_kit_search_table').style.display = 'none';
	document.getElementById('add_products').style.display = '';
\}

// -->
</script>

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" id="o1">
		<tr>
			<td class="external_wo_top">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>

<form method="post">
			
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=search_atom value="campaign_kit">
	<input type=hidden name=tmpl value="campaign_kit.html">
	<input type=hidden name=campaign_id value="%%campaign_id%%">
	
	<table width="100%" cellspacing="0" cellpadding="0" class="search" border="0" id="campaign_kit_search_table">
		<tr>
			<td class="search" style="padding-left:10px;padding-right:5px;"><nobr>SEARCH PRODUCTS</nobr></td>
			
			
			<td class="search" align="center"><nobr>Part code</nobr></td>
			<td class="search" align="center"><input class="text" type=text name=search_prod_id value="%%search_prod_id%%"><input type=hidden name=search_prod_id_mode value=like></td>
			<td class="search" align="center"><nobr>Name</nobr></td>
			<td class="search" align="center"><input class="text" type=text name=search_name value="%%search_name%%"><input type=hidden name=search_name_mode value=like></td>
			<td class="search" align="left"><input class="hover_button" type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" name="new_search"></td>
			<td class="search" align="left" style="width:100%; padding-left:10px;"><a class="new-win" onClick="javascript: to_add_products();" href="#">Add more products</a></td>
		</tr>
	</table>
</form>

}

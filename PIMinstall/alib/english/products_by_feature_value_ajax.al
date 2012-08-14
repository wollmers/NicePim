 {
 name: products_by_feature_value_ajax;
 product_row:
 	<tr>
 		<td><a target="_blank" href="#" onclick="openProductPage(%%product_id%%,'%%sessid%%')">%%prod_id%%</td>
 		<td>%%supplier_name%%</td>
 	</tr>
 body:
  <table class="maintxt">
  	%%product_rows%%
  </table>  
  <br/>
  <a onclick="makeQuery(event,'%%feature_id%%','%%feature_value_%%','%%sessid%%','ajax_result',this,100000000000,false)" class="divajax">%%show_all%%</a> 
 }

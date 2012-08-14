{
name: product_related_add;

$$INCLUDE actions2.al$$

related_row:
 <form method=post>
        <tr>
					<td>%%rel_prod_id%%</td>
          <td>


	<input type=hidden name=atom_name value="product_related">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="product_details.html">
	<input type=hidden name=tmpl value="product_details.html">
	<input type=hidden name=product_related_id value="%%product_related_id%%">
	<input type=hidden name=product_id value="%%product_id%%">
	<input type=hidden name=rel_product_id value="%%r_product_id%%">
%%delete_action%%
					
					</td>
        </tr>
</form> 
body: 


      <table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>

<form method=post>

	<input type=hidden name=atom_name value="product_related_add">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="product_details.html">
	<input type=hidden name=tmpl value="product_related_add.html">
	<input type=hidden name=product_id value="%%product_id%%">

<td>Brand</td>
	 <td>%%supplier_id%%</td>
</tr>
<tr>
<td>Related product code</td>
	 <td><input type=text size=30 value="%%rel_prod_id%%"></td>
</tr>
<tr>
				 <td>%%insert_action%%</td>
</tr>
</form>
				</tr>
				
				
      </table>



}

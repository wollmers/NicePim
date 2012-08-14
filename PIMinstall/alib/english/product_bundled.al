{
name: product_bundled;

$$INCLUDE actions2.al$$

bundled_row:
 <form method=post>
        <tr>
					<td class="main info_bold">%%bndl_prod_id%%</td>
					<td class="main info_bold">%%bndl_name%%</td>					
          <td class="main info_bold">


	<input type=hidden name=atom_name value="product_bundled">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="product_details.html">
	<input type=hidden name=tmpl value="product_details.html">
	<input type=hidden name=product_bundled_id value="%%product_bundled_id%%">
	<input type=hidden name=product_id value="%%product_id%%">
	<input type=hidden name=bndl_product_id value="%%bndl_product_id%%">
%%delete_action%%
					
					</td>
        </tr>
</form> 
body: 


      <table border="0" cellpadding="3" cellspacing="0" width="100%">
        <tr>
          <td width="20%" class="th-dark">
            <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_bundled_bundled=bndl_prod_id;%%joined_keys%%">Part number</a></td>
          <td width="65%" class="th-norm">
            <a href="%%base_url%%;tmpl=%%tmpl%%;order_product_bundled_bundled=r_name;%%joined_keys%%">Product name</a></td>
          <td width="15%" class="th-dark">Action</td>

        </tr>
				<tr>

<form method=post>

	<input type=hidden name=atom_name value="product_bundled">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="product_details.html">
	<input type=hidden name=tmpl value="product_details.html">
	<input type=hidden name=product_id value="%%product_id%%">
	<input type=hidden name=command value=add2editors_journal>

        <tr>
					<td class="main info_bold"><!--~Part number~--><input type=text name=bndl_prod_id value="%%bndl_prod_id%%"></td>
					<td class="main info_bold">&nbsp;</td>
          <td class="main info_bold">%%insert_action%%</td>
        </tr>
</form> 

				
				</tr>
				
				%%bundled_rows%%
				
      </table>



}
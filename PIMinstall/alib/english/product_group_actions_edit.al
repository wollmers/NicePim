<script>
 function delete_()
  \{
 if(document.form.select_products.options.selectedIndex != -1)\{
	document.form.select_products.options[document.form.select_products.options.selectedIndex] = null;
	document.form.product_id_list.value = "";
	for(i=0;i<document.form.select_products.options.length;i++)\{
	 document.form.product_id_list.value = document.form.product_id_list.value +
	 document.form.select_products.options[i].value + ",";
  \}
  document.form.product_id_list.value = document.form.product_id_list.value.substring(0,document.form.product_id_list.value.length - 1);
 \}
	else\{alert('Please, pick up the product first'); return('');\}
 \};

function delete_validation()
\{
 if(document.form2._delete.checked == 1)\{
	var where_to= confirm("Do you really want to delete product(s)?");
	if (where_to== true)\{
    document.form2.tmpl_if_success_cmd.value= "products.html";
	\}else\{
	  document.form2.tmpl_if_success_cmd.value = "product_group_actions_edit.html";
	  document.form2.tmpl.value = "product_group_actions_edit.html";
		document.form2._delete.checked = 0;
	\}
 \}
\}

</script>
																 

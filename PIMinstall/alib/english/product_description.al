{
name: product_description;

$$INCLUDE actions2.al$$

body:

<form method="post" enctype="multipart/form-data">
	
	<input type="hidden" name="atom_name" value="product_description">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_description.html">
	<input type="hidden" name="product_description_id" value="%%product_description_id%%">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="command" value="get_obj_url,update_xml_due_product_update,update_score,update_language_flag,add2editors_journal,product2vendor_notification_queue">
	<input type="hidden" name="precommand" value="save_values_for_history_product_description">

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
    <tr>
			<td align="right">~Last update~</td>
			<td>
				<span style="color: black;">&nbsp;%%pd_updated%%</span>
			</td>
		</tr>

		$$INCLUDE product_description_general.al$$
}

{
name: product_description;
class: details;

$$INCLUDE actions2.al$$

body:

 <form enctype="multipart/form-data" method="post">
		
	<input type="hidden" name="atom_name" value="product_description">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
	<input type="hidden" name="tmpl" value="product_details.html">
	<input type="hidden" name="product_id" value="%%product_id%%">
	<input type="hidden" name="command" value="get_obj_url,update_xml_due_product_update,update_score,update_language_flag,add2editors_journal,product2vendor_notification_queue">
	<input type="hidden" name="precommand" value="save_values_for_history_product_description">

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td style="padding-top:10px">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
  <tr>
    <td>

    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">

		$$INCLUDE product_description_general.al$$

}


{
name: product_description;
class: menu;

body:
<a href="%%base_url%%?mi=products;tmpl=product_description.html;product_id=%%product_id%%;product_description_id=%%product_description_id%%">DESCRIPTION</a> 
}

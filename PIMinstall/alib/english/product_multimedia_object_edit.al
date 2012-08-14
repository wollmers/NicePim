{
name:product_multimedia_object_edit;

body:

<form name="object_form" method="post" enctype="multipart/form-data">
	<br>

	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="white">
	    <td class="main info_bold">~Language~</td>
	    <td class="main info_bold">%%object_langid%%</td>
		</tr>
		<tr bgcolor="white">
			<td class="main info_bold"><span style="color: red;">*</span>~Short description~</td>
			<td class="main info_bold"><input type="text" size="80" name="object_descr" value="%%object_descr%%" class="smallform"></td>
		</tr>
		<tr bgcolor="white">
   		<td class="main info_bold">~Object URL~</td>
			<td class="main info_bold"><input type="text" size="80" name="object_url" value="" class="smallform">
		    or<br> <input type="file" name="object_url_filename" class="smallform">
			</td>
		</tr>
		<tr bgcolor="white">
   		<td class="main info_bold">~Keep as url?~</td>
			<td class="main info_bold">%%keep_as_url%%&nbsp;<span style="color: red; font-size: 0.8em;">(Set 'Yes' only in cases when object is not downloadable)</span>
			</td>
		</tr>
		<tr bgcolor="white" align="right">
			<td class="main info_bold" colspan="2"><input type="submit" name="atom_submit" value="Add object" class="smallform"></td>
		</tr>
	</table>														

  <input type="hidden" name="atom_name" value="product_multimedia_object_edit">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl" value="product_multimedia.html">
  <input type="hidden" name="tmpl_if_success_cmd" value="product_multimedia.html">
  <input type="hidden" name="product_id" value="%%product_id%%">
  <input type="hidden" name="command" value="get_object_url,store_pics_origin_mmo_update,add2editors_journal">
  <input type="hidden" name="precommand" value="store_pics_origin_mmo">
</form>											
}

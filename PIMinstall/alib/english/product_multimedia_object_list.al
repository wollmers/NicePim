{
name: product_multimedia_object_list;

multimedia_object_row:
<tr>
	<td class="main info_bold" bgcolor="white" colspan="2" align="center"><a href="%%base_url%%;tmpl=product_multimedia_object_details.html;object_id=%%object_id%%;product_id=%%product_id%%">%%object_descr_listed%%</a></td>
	<td class="main info_bold" bgcolor="white" align="center">%%object_lang%%</td>
	<td class="main info_bold" bgcolor="white" align="center">%%object_type%%</td>
	<td class="main info_bold" bgcolor="white" align="center">%%object_updated%%</td>
	<td class="main info_bold" bgcolor="white" align="center">%%object_size%% Kb</td>
	<td class="main info_bold" bgcolor="white" align="center">%%height%%</td>
	<td class="main info_bold" bgcolor="white" align="center">%%width%%</td>
	<td class="main info_bold" bgcolor="white" align="center">%%keep_as_url%%</td>
	<td class="main info_bold" bgcolor="white" colspan="2" align="center">%%type%%</td>
</tr>

body:
<br>

<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
	<tr bgcolor="#99CCFF">
		<th class="main info_header"colspan="11"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Multimedia objects</b></th>
	</tr>
	<tr>
		<td bgcolor="white" colspan="11" height="1"></td>
	</tr>
	<tr bgcolor="#99CCFF" align="center">
		<th class="main info_header" bgcolor="white" width="1"></th>
		<th class="main info_header">Short description</th>
		<th class="main info_header">Language</th>
		<th class="main info_header">Content-type</th>
		<th class="main info_header">Updated</th>
		<th class="main info_header">Size</th>
		<th class="main info_header">Height</th>
		<th class="main info_header">Width</th>
		<th class="main info_header">Keep as url?</th>
		<th class="main info_header">Type</th>
		<th class="main info_header" bgcolor="white" width="1"></th>
	</tr>
	%%multimedia_object_rows%%
</table>
<!--
	<input type="hidden" name="precommand" value="store_pics_origin_mmo">
	<input type="hidden" name="command" value="store_pics_origin_mmo_update">
	-->
}

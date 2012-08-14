{
name: editor_journal_list;

$$INCLUDE nav_inc.al$$
editor_journal_list_row:
<tr>
	<td class="main info_bold">%%no%%</td>
	<td class="main info_bold" id="editor_%%editor_id%%"><a href="%%base_url%%;tmpl=editor_journal_edit.html;editor_id=%%editor_id%%;from_year=%%from_year_prepared%%;from_month=%%from_month_prepared%%;from_day=%%from_day_prepared%%;to_year=%%to_year_prepared%%;to_month=%%to_month_prepared%%;to_day=%%to_day_prepared%%;search_editor=%%editor_id%%;search_catid=%%search_catid%%;search_supplier=%%search_supplier%%;search_prodid=%%search_prodid%%;search_distributor=%%search_distributor%%;search_changetype=%%search_changetype%%;search_isactive=%%search_isactive_prepared%%">%%editor_login%%</a>
		<div>%%editor_distri%%</div>
	</td>
	<td class="main info_bold" align=center>%%editor_products_num%%</td>

<script type="text/javascript">
<!--
if (%%editor_remove_link%% == 1) \{
	document.getElementById('editor_'+%%editor_id%%).innerText = '%%editor_login%%';
	document.getElementById('editor_'+%%editor_id%%).innerHTML = '%%editor_login%%';
\}
// -->
</script>
</tr>

body:

<br />

<table width=100% border=0 class=maintxt cellpadding="0" cellspacing="0">
	<tr>
		<td><b>Overall:</b></td>
		<td>descriptions=%%summary_descriptions%% (%%summary_description_details%%)</td>
		<td>related=%%summary_related%%</td>
		<td>gallery=%%summary_gallery%%</td>
	</tr>
	<tr>
		<td>number of products=%%summary_product%%</td>
		<td>EAN codes=%%summary_ean_codes%%</td>
		<td>features=%%summary_features%%</td>
		<td>objects=%%summary_objects%%</td>
	</tr>
</table>

<br />

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="1%" align="center">#</th>
								<th class="main info_header" width="75%">Editor</th>
								<th class="main info_header" align="center">Number of products</th>
							</tr>
							
							%%editor_journal_list_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

}

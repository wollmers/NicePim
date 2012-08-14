{
name: dictionaries;

$$INCLUDE nav_inc.al$$

dictionaries_row: 
<tr>
	<td class="main info_bold">&nbsp;%%no%%/%%found%%</td>
	<td class="main info_bold">&nbsp;<a href="%%base_url%%;tmpl=dictionary.html;dictionary_id=%%dictionary_id%%">%%name%%</a></td>
	<td class="main info_bold">%%group%%</td>
	<td class="main info_bold" align=center>%%updated%%</td>
</tr>

body:

$$INCLUDE nav_bar2.al$$

<table align="center" width="80%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_dictionaries_dictionaries=name">Name</a></th>								
								<th class="main info_header">Group</th>
								<th class="main info_header">Updated</th>
								
								%%dictionaries_rows%%
								
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}


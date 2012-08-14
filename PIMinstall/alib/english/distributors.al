{
name: distributors;

$$INCLUDE nav_inc.al$$

distris_row: 

<tr>
	<td class="main info_bold">%%no%%/%%found%%</td>
 	<td class="main info_bold">
 		<a href="%%base_url%%;distributor_id=%%distributor_id%%;tmpl=distributor_edit.html;">%%name%%</a>
 	</td>
 	<td class="main info_bold">%%code%%</td>
 	<td class="main info_bold">%%group_code%%</td>
 	<td class="main info_bold">%%last_import_date%%</td>
 	<td class="main info_bold">%%direct%%</td>
 	<td class="main info_bold">%%country_name%%</td> 	
 	<td class="main info_bold">%%link_to_pricelist%%</td>
 	<td class="main info_bold">
 	    <span style="main info_bold" id="sync_ph_%%code%%">
 	        ---
 	    </span>
 	</td>
 	<td class="main info_bold">%%source%%</td>
</tr>

body:
$$INCLUDE nav_bar2.al$$

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header">#/##</th>
								<th class="main info_header"><a href="%%base_url%%;tmpl=%%tmpl%%;order_distributors_distributors=name">Name</a></th>
								<th class="main info_header">Code</th>
								<th class="main info_header"><abbr title="This field groups one distributor in different languages">Group code</abbr></th>
								<th class="main info_header">Last import date</th>
								<th class="main info_header">Export allowed</th>
								<th class="main info_header">Country</th>
								<th class="main info_header">Catalog upload</th>
								<th class="main info_header">Sync</th>
								<th class="main info_header">Import's source</th>
								%%distris_rows%%
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

<script language="JavaScript">
    window.addEvent('domready', function() \{
        var session_id = document.getElementsByName('sessid')[0].value;
        var tmp1_local = 'tag_id=sync_all_distri;foo=bar';
        var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_sync_all_distri.html';
        call('sync_all_distri', tmp1_local, tmp2_local);
    \} );
</script>

}

{
name: products_complaint;

rows_number: 20;

date_format:%d-%m-%Y;
hour: 1 hour ago;
hours: %%hours%% hours ago;
day: 1 day ago;
days: %%days%% days ago;
internal_color: &nbsp;&nbsp;<span style="color: blue;">%%internal%%</span>
external_color: &nbsp;&nbsp;<span style="color: black;">%%internal%%</span>

group_action_buttons:
<div align=right>
	<input style="display: inline;" type=submit name="action_selectall_complaint" value="Select all" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'products_complaint.html';document.form.submit();\}">
	<input style="display: inline;" type=submit name="action_group_complaint" value="Do group actions" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'products_complaint_group_action_edit.html';document.form.submit();\}">
	<input style="display: inline;" type=submit name="action_clear_complaint" value="Clear selection" class=linksubmit onClick="javascript:\{document.form.tmpl.value = 'products_complaint.html';document.form.submit();\}">
</div>	 

$$INCLUDE clipboard_nav_link.al$$
 

complaint_row:
<tr bgcolor="white" nowrap>
	<td class="main info_bold" align="center">
	 	<input name="row_%%no%%_item" type="hidden" value="%%complaint_id%%"/>
	 	<input type="%%button_type%%" name="row_%%no%%" id="row_%%complaint_id%%" value="1" %%complaint_item_marked%%/>
	</td>
	<td class="main info_bold" align="center" width="80">%%date%%</td>
	<td class="main info_bold" align="center">
 		<a class="link" href="%%base_url%%;tmpl=products_complaint_details.html;complaint_id=%%complaint_id%%">%%complaint_id%%</a></td>
	<td class="main info_bold" width="250">
		<a class="link" href="%%base_url%%;tmpl=products_complaint_details.html;complaint_id=%%complaint_id%%">%%pname%%</a>
	</td>
	<td class="main info_bold">%%prodid%%</td>
	<td class="main info_bold" width="150">%%subject%%</td>
	<td class="main info_bold">%%uname%%</td>
	<td class="main info_bold">%%funame%%</td>
	<td class="main info_bold">%%status_name%%</td>
</tr>


body:
<div id="clipboard_info" style="color: green;"></div>
<form method=post name='form'> 
	<input type=hidden name=tmpl value="products_complaint.html">
	<input type=hidden name=atom_name value="products_complaint">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=clipboard_object_type value="complaint">
	<input type=hidden name=last_row value="%%last_row%%">
	<input type="hidden" name="%%atom_name%%_start_row" id="clipboard_nav_link_start_row" class="linksubmit" value=""/>
	<div style="padding-right: 30%">
 		$$INCLUDE nav_bar2_memorize.al$$
	</div>		
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header">
	   								&nbsp; 
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=date">Date</a>
									</th>
									<th class="main info_header">
										ID
									</th>
									<th class="main info_header">	
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=pname">Product</a>
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=prodid">Prod ID</a>
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=subject">Subject</a>
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=uname">Editor</a>
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=funame">Sender</a>
									</th>
									<th class="main info_header">
										<a class="link" href="%%base_url%%;tmpl=products_complaint.html;order_products_complaint_complaint=status_id">Status</a>
									</th>
								</tr>
								
								%%complaint_rows%%
								
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
	<div style="padding-right: 30%">
	 	$$INCLUDE nav_bar2_memorize.al$$
	</div>
	
	$$INCLUDE cli_actions.al$$
	
	%%group_action_buttons%%
	
</form> 

}

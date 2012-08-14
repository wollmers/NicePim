{
name: stat_report;

subtotal_format: <td>%%value%%</td>

report_line: %%value%%
report_line_5: <a href="%%base_url%%;search_prod_id=%%value_escaped%%;new_search=1;tmpl=products.html;mi=products;search_atom=products;">%%value%% - %%product_name%%</a>


report_row: <tr><td>%%report_line%%</td>%%subtotals%%</tr>
report_ident: &nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;;


body:
<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="90%">Item</th>
								<th class="main info_header" width="7%">Requests</th>
							</tr>

							%%report_rows%%

						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>
}

{
name: stat_report;
class: mail_report_dsv;
subtotal_format:%%value%%;



period_value_1: Custom date
period_value_2: Last week
period_value_3: Last month
period_value_4: Last quarter
period_value_5: Last day

report_line:%%value%%;
report_line_5:%%value%% - %%product_name%%;
report_row:%%report_line%% %%subtotals%%

subject: Report on %%code%% - %%date%%;

report_ident:    
body:
Scheduled report on %%code%% - %%date%%
Period -%%period_text%%

 Items                                                              Requests

%%report_rows%%


}

{
name: stat_report;
class: mail_report_csv;
subtotal_format:%%value%%;



period_value_1: Custom date
period_value_2: Last week
period_value_3: Last month
period_value_4: Last quarter
period_value_5: Last day

report_line:%%value%%;
report_line_5:%%value%% - %%product_name%%;
report_row:%%report_line%% %%subtotals%%

subject: Report on %%code%% - %%date%%;

report_ident:	
body:
Scheduled report on %%code%% - %%date%%
Period -%%period_text%%

 Items                                                              Requests

%%report_rows%%


}

{
name: graphical_query_report_top;
product_link: <a href="http://icecat.biz/p/%%supplier%%/%%prod_id%%/desc.htm">%%cell%%</a>
lookup_link: <a href="http://icecat.biz/index.cgi?lookup_text=%%key%%;only=%%type%%">%%cell%%</a>

header_row: <th style="background-color: #e5eff1;padding: 5px;">%%header%%</th>
first_info_cell: <td style="background-color: #e5eff1;padding: 5px;">%%cell%%</td>
info_cell: <td style="border: 1px solid white;padding: 5px;">%%cell%%</td>
info_row: <tr>%%info_cell%%</tr>

body:

<table>
<tr>
  <td width="100%">
	<table  width="100%" style="font-size: 8pt">
		<caption style="background-color: #d5eaff;font-size: 12pt;padding: 5px;font-weight: normal">%%caption%%</caption>
		%%header_row%%
		%%info_row%%
	</table>
  </td>
<td style="background-color: #92d7ff; width: 10px;height: 100%"/>&nbsp;</td>
</tr>
</table>
}

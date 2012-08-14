{
name: supplier_url;

url_row:
<tr>
	<td class="main info_bold"><a href=%%base_url%%;tmpl=supplier_url_edit.html;id=%%id%%;country_id=%%c_id%%;supplier_id=%%supplier_id%%>%%url%%</a></td>
	<td class="main info_bold">%%language%%</td>
	<td class="main info_bold">%%country%%</td>
</tr>

cutted_format: %%value%%...
supplier_country_empty: International;

body:

<br>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="50%" align=left><b>URLs</b></th>
								<th class="main info_header" align=right><a href="%%base_url%%;tmpl=supplier_url_edit.html;supplier_id=%%supplier_id%%" class="new-win">New Url</a></th>
							</tr>
						</table>
						
          </td>
        </tr>
      </table>
			
    </td>
  </tr>
</table>


<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top: 0px;">
			
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
						
            <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header" width="70%">Url</th>
								<th class="main info_header" width="15%">Language</th>
								<th class="main info_header" width="15%">Country</th>
							</tr>
							
							%%url_rows%%
							
						</table>

          </td>
        </tr>
      </table>
			
    </td>
  </tr>
</table>
}

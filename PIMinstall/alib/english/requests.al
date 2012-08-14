{
name: requests;

requests_row:

        <tr>
					<td>%%rprod_id%%</td>
					<td>%%rsupplier_name%%</td>
					<td>%%cnt%%</td>
        </tr>
 
body: 


      <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td width="16%" bgcolor="#99CCFF">
            <p align="left"><font face="Verdana" size="2" color="#FFFFFF">
						<u><a href="%%base_url%%;tmpl=%%tmpl%%;order_requests_requests=rprod_id">Part
 code</a></u></font></td>
						
          <td width="11%" bgcolor="#99CCFF">
            <p align="left"><font face="Verdana" size="2" color="#FFFFFF"><u>
						<a href="%%base_url%%;tmpl=%%tmpl%%;order_requests_requests=rsupplier_name">Brand</a></u></font></td>

          <td width="5%" bgcolor="#99CCFF">
            <p align="left"><font face="Verdana" size="2" color="#FFFFFF"><u>
						<a href="%%base_url%%;tmpl=%%tmpl%%;order_requests_requests=cnt">Qty</a></u></font></td>

        </tr>
				
				%%requests_rows%%
				
      </table>
<br>

}
{
name: user_authorities;

auth_row: 
        <tr>
          <td>%%supplier_id%%</td>
          <td>%%catid%%</td>
          <td>%%right%%</td>
					<td>
					 <a href="%%base_url%%;tmpl=user_auth.html;edit_user_id=%%edit_user_id%%;user_authority_id=%%user_authority_id%%">Edit</a>
					</td>
        </tr>


body:

			
      <p align="center">&lt;&lt; <u>Previous</u>&nbsp; <u>Next</u> &gt;&gt;</p>
      
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td width="11%" bgcolor="#99CCFF">

            <p align="center"><u><font face="Verdana" size="2" color="#FFFFFF">
Brand
            </font></u></td>

          <td width="13%" bgcolor="#99CCFF">
            <p align="center"><font face="Verdana" size="2" color="#FFFFFF">
						<u>
Category
						</u></font></td>
          <td width="29%" bgcolor="#99CCFF">
          <td width="13%" bgcolor="#99CCFF">
            <p align="center"><font face="Verdana" size="2" color="#FFFFFF"><u>
						Rights
						</u></font></td>
          <td width="11%" bgcolor="#99CCFF">

            <p align="center"><u><font face="Verdana" size="2" color="#FFFFFF">
Actie
            </font></u></td>

        </tr>
				

%%auth_rows%%

      </table>
      <p align="center">&lt;&lt; <u>Previous</u>&nbsp; <u>Next</u> &gt;&gt;</p>


}
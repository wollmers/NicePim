{
name: backup_language_config;

$$INCLUDE actions2.al$$

language_row:
<tr>
    <td class="main info_bold">
	%%lang_value%%
    </td>
    <td class="main info_bold">
	 %%short_code%%
    </td>
    <td class="main info_bold">
	%%published%%
    </td>
    <td class="main info_bold">
	%%backup_langid%%
    </td>
</tr>

body:

<table align="center" width="70%" border="0" cellspacing="0" cellpadding="0">
    <tr>
	<td style="padding-top:10px">
		
	    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
		<tr>
		    <td>
			    
			<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
				
				<form method=post enctype="multipart/form-data" name="backup_languages">
				    <input type=hidden name=sessid value="%%sessid%%">
				    <input type=hidden name=tmpl value="backup_language_config.html">
				    <input type=hidden name=atom_name value="backup_language_config">
				    <input type=hidden name=tmpl_if_success_cmd value="backup_language_config.html">
				    <input type=hidden name=command value="save_backup_languages">

				    <tr>
					<td class="main info_header">
					    Language name
					</td>
					<td class="main info_header">
					    Short code
					</td>
					<td class="main info_header">
					    Published
					</td>
					<td class="main info_header">
					    Backup language
					</td>
				    </tr>

				    %%language_rows%%

				    <table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">

				    <tr align="center" width="100%">
					<td class="main info_bold">
					    <input type="submit" value="Save backup languages"/>
					</td>
				    </tr>

				    </table>
				    
				</form>
				
			</table>
			    
		    </td>
		</tr>
	    </table>
		
	</td>
    </tr>
</table>

}

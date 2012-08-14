{
name: feed_config;

user_delimiter_radio_value_0: auto;
user_delimiter_radio_text_0: Auto detect;

user_delimiter_radio_value_1: ;;
user_delimiter_radio_text_1: Semicolon;

user_delimiter_radio_value_2: ,;
user_delimiter_radio_text_2: Comma;

user_delimiter_radio_value_3: .;
user_delimiter_radio_text_3: Dot;

user_delimiter_radio_value_4: \t;
user_delimiter_radio_text_4: Tab;

user_delimiter_radio_value_5: custom;
user_delimiter_radio_text_5: Other delimiter;



feed_type_custom_select_value_0: csv;
feed_type_custom_select_text_0:  CSV;

feed_type_custom_select_value_1: xls;
feed_type_custom_select_text_1:  Excel;

feed_type_custom_select_value_2: xml;
feed_type_custom_select_text_2:  XML;


feed_type_custom_select_value_3: auto;
feed_type_custom_select_text_3:  Auto detect;


newline_custom_select_value_1: \r\n;
newline_custom_select_text_1:  Windows;

newline_custom_select_value_2: \n;
newline_custom_select_text_2:  Unix;

newline_custom_select_value_3: \r;
newline_custom_select_text_3:  Mac OS;

body:

<script type="text/javascript" src="/js/feed_config.js"></script>


	<input type=hidden name=sessid value="%%sessid%%"/>
	<input type=hidden name=tmpl value="%%tmpl%%"/>		
	<input type=hidden name=command id="feed_config_commands" value=""/>
	<input type=hidden name=feed_config_id value="%%feed_config_id%%"/>
		
	<table align="center">
	<tr>
	<td>
	<table class="feed_config_table">
		<tr>
			<td class="main info_bold">Feed url</td>
			<td class="main info_bold">
				<input type="text" name="feed_url" id="feed_config_url" value="%%feed_url%%" size="50"/>
				<input type="submit" value="upload" onclick="return reupload_feed()"/>
			</td>
		</tr>
		<tr id="manualy_download_tr">
			<td class="main info_bold">Upload file</td>
			<td class="main info_bold"><input type="file" id="feed_config_file" name="feed_file" value="" size="50"/>
				<input type="submit" value="reupload" onclick="return reupload_feed()"/><br/>%%feed_file_name%%</td>
		</tr>
		<tr>
			<td class="main info_bold">Feed type</td>
			<td class="main info_bold">%%feed_type%% &nbsp;&nbsp;&nbsp;&nbsp;Is first row a header %%is_first_header%%</td>
		</tr>				
		<tr>
			<td class="main info_bold" colspan="2" align="center">
				Authentication details. Required if access to the url is restricted 
			</td>			
		</tr>						
		<tr id="feed_config_login">	
			<td class="main info_bold">Login</td>
			<td class="main info_bold"><input type="text" name="feed_login" value="%%feed_login%%" size="10"/></td>
		</tr>
		<tr id="feed_config_pwd">
			<td class="main info_bold">Password</td>
			<td class="main info_bold"><input type="text" name="feed_pwd" value="%%feed_pwd%%" size="10"/></td>
		</tr>
	</table>
	</td>
	<td id="feed_config_csv_details" style="display: none;">
		<div class="csv_caption">CSV details</div>
		<table>
		<tr>
		<td>
			 <div class="main info_bold">Delimiter<input type="text" name="delimiter" id="feed_config_delimiter" value="%%delimiter%%" size="5"/></div>
			%%user_delimiter%%
		 </td>
		 <td style="vertical-align: top;"> 
			<table class="feed_config_table"> 			
					<tr>
						<td class="main info_bold">Line separator</td>
						<td class="main info_bold">%%newline%%</td>
					</tr>
					<tr>
						<td class="main info_bold">Escape character (if any)</td>
						<td class="main info_bold"><input type="text" name="escape" value="%%escape%%" size="3"/></td>
					</tr>
			</table>
		</td>
		</tr>
		</table>
	</td> 
	</tr> 
	</table>
	<div style="text-align: center; margin: 5px;">
	%%user_choiced_file%%
	%%preview_button%%
	</div>
	<div style="text-align: center;">
	%%preview%%
	</div>
}

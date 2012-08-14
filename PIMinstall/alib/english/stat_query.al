{
name: stat_query;

insert_action: <input type=submit name=atom_submit value="Schedule query" onclick="return check_mailreport()">
delete_action: <input type=submit name=atom_delete value="Delete" onClick="if(!confirm('Are you sure?')) return false;">
update_action: <input type=submit name=atom_update value="Update">


search_edit_user_id_dropdown_empty: Any editor;
search_supplier_id_dropdown_empty: Any brand;
request_user_id_dropdown_empty: Any owner;
request_partner_id_dropdown_empty: Any partner;
request_country_id_dropdown_empty: Any country;
search_product_country_id_dropdown_empty: Any country;
search_product_distributor_id_dropdown_empty: Any distributor;
any_cat: Any category;
mail_class_format: DSV;
cat_div: ---;
search_catid_recurse_default: Y;

subtotal_list_values: 0,1,2,3,4,5,111,6,7,8,10;
subtotal_value_0: Don't subtotal;
subtotal_value_1: Brand;
subtotal_value_2: Category;
subtotal_value_3: Product owner;
subtotal_value_4: Request owner;
subtotal_value_5: Product code;
subtotal_value_6: Time period - 1 week;
subtotal_value_7: Time period - 1 month;
subtotal_value_8: Request owner partner;
subtotal_value_9: Time period - 1 year;
subtotal_value_10: Request owner country;
subtotal_value_111: Time period - 1 day;

period_assorted_list_values: 1,5,2,3,4;

period_value_1: Custom date
period_value_2: Last week
period_value_3: Last month
period_value_4: Last quarter
period_value_5: Last day


body:
<script type="text/javascript">
<!--
function refreshForm() \{
	if (document.getElementById('mail_class_format').value == 'PIV' || document.getElementById('mail_class_format').value == 'PSV') \{
		document.getElementById('subtotal_1').style.display = 'none';
		document.getElementById('subtotal_2').style.display = 'none';
		document.getElementById('subtotal_3').style.display = 'none';
		document.getElementById('subtotal_1_title').style.display = 'none';
		document.getElementById('subtotal_2_title').style.display = 'none';
		document.getElementById('subtotal_3_title').style.display = 'none';
		document.getElementById('custom_subtotal').style.display = 'block';
		document.getElementById('request_graph_setting').style.display = 'none';
	\}
	else if(document.getElementById('mail_class_format').value == 'GDR')\{
		document.getElementById('subtotal_1').style.display = 'none';
		document.getElementById('subtotal_2').style.display = 'none';
		document.getElementById('subtotal_3').style.display = 'none';
		document.getElementById('subtotal_1_title').style.display = 'none';
		document.getElementById('subtotal_2_title').style.display = 'none';
		document.getElementById('subtotal_3_title').style.display = 'none';
		document.getElementById('search_prod_id').style.display = 'none';
		document.getElementById('product_code_id').style.display = 'none';
		document.getElementById('request_graph_setting').style.display = 'block';		
	\}	
	else \{
		document.getElementById('subtotal_1').style.display = 'block';
		document.getElementById('subtotal_2').style.display = 'block';
		document.getElementById('subtotal_3').style.display = 'block';
		document.getElementById('subtotal_1_title').style.display = 'block';
		document.getElementById('subtotal_2_title').style.display = 'block';
		document.getElementById('subtotal_3_title').style.display = 'block';
		document.getElementById('custom_subtotal').style.display = 'none';
		document.getElementById('search_prod_id').style.display = 'block';
		document.getElementById('product_code_id').style.display = 'block';
		document.getElementById('request_graph_setting').style.display = 'none';
	\}
\}
function check_mailreport()\{
	var err='';	
	if(document.getElementsByName('code')[0].value=='')\{
		err="Statistics query name required. ";
	\}
	var emails_str=document.getElementsByName('email')[0].value;
	emails_str=emails_str.replace(/^\s+/,'');
	emails_str=emails_str.replace(/\s+$/,'');
	emails_str=emails_str.replace(/[^\w\d@\.-]+$/,'');
	emails_str=emails_str.replace(/^[^\w\d@\.-]+/,'');
	var mail_arr=emails_str.split(/[^\w\d@\.-]+/);
	var i;
	//alert(document.getElementsByName('email')[0].value);
	
	var email_err='';
	if(mail_arr=='')\{
		err=err+"Email required. ";
	\}else\{
		for(i=0;i<mail_arr.length;i++)\{
			reg = /^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[\w]\{2,5\}$/i;
			
			if(!reg.test(mail_arr[i]))\{
				
				email_err=email_err+'  '+mail_arr[i];
			\};				
		\}
	\}
	if(email_err)\{
		err=err+'Invalid emails found: '+email_err;
	\}
	if(err!='')\{
		
		alert(err);
	\}
	if(err!='')\{
		document.getElementById('error_div').innerHTML=err;
		return false;
	\}else\{
		document.getElementById('main_request_submit').value='Report via mail';
		document.getElementById('stat_query_form').submit();
		
	\}
	return true;
\}								
function submit_report()\{
	document.getElementById('main_request_submit').value='Report';
	document.forms['stat_query_form'].submit();
\}

function set_dates_intreval(self)\{
	var curr_date= new Date();
	var last_date=new Date();
	if(self.options[self.selectedIndex].value=='5')\{//last day
		last_date.setDate(curr_date.getDate()-1);
	\}else if(self.options[self.selectedIndex].value=='2')\{//last week
		last_date.setDate(curr_date.getDate()-7);
	\}else if(self.options[self.selectedIndex].value=='3')\{//last month
		last_date.setMonth(curr_date.getMonth()-1);
	\}else if(self.options[self.selectedIndex].value=='4')\{//last quarter
		last_date.setMonth(curr_date.getMonth()-4);
	\}else\{
		set_selected_by_value('from_day','');	
		set_selected_by_value('from_month','');
		set_selected_by_value('from_year','');					
		return '';
	\}

	set_selected_by_value('to_day',curr_date.getDate());	
	set_selected_by_value('to_month',curr_date.getMonth()+1);
	set_selected_by_value('to_year',curr_date.getFullYear());

	set_selected_by_value('from_day',last_date.getDate());	
	set_selected_by_value('from_month',last_date.getMonth()+1);
	set_selected_by_value('from_year',last_date.getFullYear());		
\}
function set_selected_by_value(select_id,value)\{
	var select=document.getElementById(select_id);
	for(i=0;i<select.options.length;i++)\{
		if(select.options[i].value==value)\{
			select.selectedIndex=i;
		\}
	\}
\}
// -->
</script>
<div style="color: red;font-size: 14pt; " id="error_div">&nbsp;</div>

<form method=post id="stat_query_form">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl value="requests.html">
	<input type=hidden name=stat_query_id value="%%stat_query_id%%">
	<input type=hidden name=atom_name value="stat_query">
	<input type=hidden name=tmpl_if_success_cmd value="stat_queries.html">	

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="2">Statistics query details</th>
								</tr>
								<tr>
									<td class="main info_bold" align=right>
										From  
									</td>
									<td class="main info_bold">%%from_day%% %%from_month%% %%from_year%% %%period%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>
										Till
									</td>
 									<td class="main info_bold">
										%%to_day%% %%to_month%% %%to_year%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><b>~Statistics query name~</b></td>
									<td class="main info_bold"><input type=text name=code value="%%code%%" size=40 class=smallform></td>
								</tr> 	
								<tr>
									<td class="main info_bold" align=right>~Report mail format~</td>
									<td class="main info_bold">
									<div>%%mail_class_format%%</div>
									<div id="request_graph_setting" class="request_graph">
									<table cellpadding="2px" cellspacing="0"> 
										<tr>
											<td>%%include_top_product%% Include top 50 products</td>
											<td>%%include_top_supplier%% Include top 50 brands</td>
										</tr>
										<tr>
											<td>%%include_top_cats%% Include top 50 categories</td>
											<td>%%include_top_owner%% Include top 50 editors</td>											
										</tr>
										<tr>
											<td>%%include_top_request_country%% Include top 50 download country</td>
										</tr>
									</table>
									</div>
									
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Brand~</td>
									<td class="main info_bold">
										%%search_supplier_id%% 
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Brand sponsoring~</td>
									<td class="main info_bold">
										%%search_supplier_type%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Category~</td>
									<td class="main info_bold">
										%%search_catid%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Product owner~</td>
									<td class="main info_bold">
	 									%%search_edit_user_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Product distributor~</td>
									<td class="main info_bold">
	 									%%search_product_distributor_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Product country~</td>
									<td class="main info_bold">
	 									%%search_product_country_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Product on stock~</td>
									<td class="main info_bold">
	 									%%search_product_onstock%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Request owner~</td>
									<td class="main info_bold">
	 									%%request_user_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Request owner partner~</td>
									<td class="main info_bold">
										%%request_partner_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Request owner country~</td>
									<td class="main info_bold">
										%%request_country_id%%
									</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span id="product_code_id">~Product code~</span></td>
									<td class="main info_bold"><input type=text name="search_prod_id" id="search_prod_id" value="%%search_prod_id%%" size=20 class=smallform></td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span id="subtotal_1_title">~1st subtotal~</span></td>
									<td class="main info_bold">%%subtotal_1%%</td>
								</tr> 
								<tr>
									<td class="main info_bold" align=right><span id="subtotal_2_title">~2nd subtotal~</span></td>
									<td class="main info_bold">%%subtotal_2%%<span id="custom_subtotal" style="display: none; color: red;">Philips custom grouping:<br>by product code (with average price from PRF site), year, month, country and url/xml</span></td>
								</tr> 
								<tr>
									<td class="main info_bold" align=right><span id="subtotal_3_title">~3rd subtotal~</span></td>
									<td class="main info_bold">%%subtotal_3%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right><span id="email_attachment_compression">~Email attachment compression~</span></td>
									<td class="main info_bold">%%email_attachment_compression%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align=right>~Email report to~</td>
									<td class="main info_bold"><textarea name=email cols=60 rows=10>%%email%%</textarea></td>
								</tr> 	
								<tr>
									<td class="main info_bold" colspan=2 align=center>
										<input type="button" value="Report"  onclick="submit_report()">
										<input type="button" value="Report via mail" onclick="return check_mailreport()">
										<input type="hidden" name="reload" id="main_request_submit" value="Report">
										%%insert_action%% %%update_action%% %%delete_action%%
									</td>
								</tr>
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	
</form>
<script type="text/javascript">
	<!--
		 refreshForm();
		 // -->
</script>
<center style="margin-top: 15px;">Reports that are being processed in background:</center>
<div id="current_processes" style="border:1px solid white;display: block;"></div>
<br/>
<div id="current_processes_complited" style="border:1px solid white;display: block;">

</div>
<script type="text/javascript">
	<!--
		 function checkGenerateReportProcesses() \{
		 call('get_current_generate_report_processes','tag_id=current_processes;foo=bar','sessid=%%sessid%%;tmpl=stat_query_processes_ajax.html');	 		 		 
		 //move_complited();
		 setTimeout("checkGenerateReportProcesses()",2000);
		 \}
	 	function remove_stat_report (sessid,generate_report_bg_processes_id)\{
	 		var agree=confirm('Are you sure you wish to continue?'); 
	 		if (agree) \{ 
					call_async('get_current_generate_report_processes','tag_id=current_processes;foo=bar','sessid=%%sessid%%;tmpl=stat_query_processes_ajax.html;command=remove_stat_report;report_bg_processes_id='+generate_report_bg_processes_id);		
		 			return true; 
		 		\} else \{ 
			 		return false; 
			 	\}
		\}
		function move_complited()\{
			if(document.getElementById('bg_process_table')==null)\{
				return '';
			\}
			document.getElementById('bg_process_complited_table').innerHTML='';
			var trs=document.getElementById('bg_process_table').getElementsByTagName('TR');
			var i;
			for(i=0;i<trs.length;i++)\{
				var stage=trs.item(i).attributes.getNamedItem('stage');
				if(stage!=null && stage.nodeValue=='complited')\{
					 document.getElementById('bg_process_complited_table').appendChild(trs.item(i)); 
				\};
			\}
		\}	
		 
		 checkGenerateReportProcesses();
		 // -->
</script>

}

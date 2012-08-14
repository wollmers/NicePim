{
name: price_reports_js;

body:
<script type="text/javascript" language="JavaScript">

	//////////////// selecting existing distributor ////////////
	function sel_distributor()\{
		if(document.getElementById("sel_distri").checked == true)\{
			document.getElementById("ex_d_code").style.display = '';
			document.getElementById("distri_code").disabled=false;
			document.getElementById("n_d_code").style.display = 'none';
			document.getElementById("distributorr").style.display = 'none';
		\}else\{
			document.getElementById("ex_d_code").style.display = 'none';
			document.getElementById("distri_code").disabled=true;
			document.getElementById("n_d_code").style.display = '';
			document.getElementById("distributorr").style.display = '';
		\}
	\}
	/////////////// is authorisation necessary? /////////////////
	function is_auth()\{
		if(document.getElementById("sel_auth").checked == true)\{
                        document.getElementById("show_auth").style.visibility = 'visible';
			document.getElementById("pl_login").disabled=false;
			document.getElementById("pl_pass").disabled=false;
                \}else\{
                        document.getElementById("show_auth").style.visibility = 'hidden';
			document.getElementById("pl_login").disabled=true;
			document.getElementById("pl_pass").disabled=true;
                \}
 
	\}
	//////////////// saving settings for current pricelist//////
	function save_settings()\{
		
		document.getElementById("tmpl").value = "price_save.html";	
		document.getElementById("atom_name").value = "price_save.html";
		document.getElementById("tmpl_if_success_cmd").value = "price_save.html";
//		document.price_report.target = "_blank";
		document.price_report.action = "%%base_url%%;tmpl=price_save.html";
		document.price_report.submit();
		document.getElementById("tmpl").value = "price_reports.html";	
		document.getElementById("atom_name").value = "price_reports.html";
		document.getElementById("tmpl_if_success_cmd").value = "price_reports.html";
		document.price_report.target = "";
		document.price_report.action = "";
	\}
	//////////////// popups rezults of analize ////////////////
	function analize()\{
		var mail = document.getElementById('mail_rep').value;
		var patt = new RegExp("[a-z0-9!#$%&'*+/=?^_`\|-]+(\.[a-z0-9!#$%&'*+/=?^_`\|-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?");
		var match;
		if(mail)\{
			match = patt.test(mail);
		\}
		if(match == false)\{
			alert("Your e-mail is incorrect!\nPlease, enter valid e-mail.");
		\}else\{
			document.getElementById("is_analyzis").value = "1";	
			document.price_report.submit();
	//		document.getElementById('price_report').submit;
		\}
		return match;
	\}

	//////////// show pricelist settings////////////
	function show_settings()\{
		document.getElementById('pl_formats').style.display = '';
		document.getElementById('settings_button').style.display = '';
		document.getElementById('columns_text').style.display = '';
		document.getElementById('hide_set').style.display = '';
		document.getElementById('show_set').style.display = 'none';
		chose_url_format();
		for(i=0; i<11; i++)\{
	                document.getElementById('setting'+i).style.display = '';
	        \}

	\}
	//////////// hide pricelist settings////////////
	function hide_settings()\{
		document.getElementById('pl_formats').style.display = 'none';
		document.getElementById('settings_button').style.display = 'none';
		document.getElementById('columns_text').style.display = 'none';
		document.getElementById('hide_set').style.display = 'none';
		document.getElementById('show_set').style.display = '';
		for(i=1; i<5; i++)\{
                	document.getElementById('csv_block'+i).style.display = 'none';
        	\}
                document.getElementById('xml_block').style.display = 'none';
                document.getElementById('xls_block').style.display = 'none';
		for(i=0; i<11; i++)\{
	                document.getElementById('setting'+i).style.display = 'none';
	        \}

	\}

	///////// chose_url_format /////////////////////
	function chose_url_format()\{

		var new_pl_format = document.getElementById('pl_format_select').value;
//		alert(new_pl_format);
	for(i=1; i<6; i++)\{
		document.getElementById('csv_block'+i).style.display = 'none';
//		alert(i+":"+document.getElementById('csv_block'+i).style.display);
	\}
		document.getElementById('xml_block').style.display = 'none';
		document.getElementById('xls_block').style.display = 'none';
		document.getElementById('first_row_csv').disabled=true;
		document.getElementById('rdelimeter_select').disabled=true;
		document.getElementById('\\t').disabled=true;
		document.getElementById(';').disabled=true;
		document.getElementById(',').disabled=true;
		document.getElementById('|').disabled=true;
		document.getElementById('||').disabled=true;
		document.getElementById('own_del').disabled=true;
		document.getElementById('xml_path').disabled=true;
		document.getElementById('first_row_xls').disabled=true;
		document.getElementById('esc_c').disabled=true;
	
	if(new_pl_format == 'csv')\{
	for(i=1; i<6; i++)\{
		document.getElementById(new_pl_format+'_block'+i).style.display = '';
	\}
		document.getElementById('first_row_csv').disabled=false;
		document.getElementById('rdelimeter_select').disabled=false;
                document.getElementById('\\t').disabled=false;
                document.getElementById(';').disabled=false;
                document.getElementById(',').disabled=false;
                document.getElementById('|').disabled=false;
                document.getElementById('||').disabled=false;
                document.getElementById('own_del').disabled=false;
                document.getElementById('esc_c').disabled=false;
	\}
	if(new_pl_format == 'xml')\{
		document.getElementById(new_pl_format+'_block').style.display = '';
		document.getElementById('xml_path').disabled=false;
	\}
	if(new_pl_format == 'xls')\{
		document.getElementById(new_pl_format+'_block').style.display = '';
		document.getElementById('first_row_xls').disabled=false;
	\}
	
	//	alert(document.getElementById('csv_block').style.display);

	\}
	/////////////////////////////////////////////////
</script>
}

{
name: price_reports;

body:
 <form method=post name="price_report" id="price_report" enctype="multipart/form-data">
        <input type=hidden name="sessid" value="%%sessid%%">
        <input type=hidden id="tmpl" name="tmpl" value="price_reports.html">
        <input type=hidden id="atom_name" name="atom_name" value="price_reports">
        <input type=hidden id="tmpl_if_success_cmd" name="tmpl_if_success_cmd" value="price_reports.html">
	<input type="hidden" name="is_analyzis" id="is_analyzis" value="">
	<table class="tbl-block" cellpadding=3>
        	<tr>
                	<td align="center" colspan="2">
                       	<b>Manage price list</b>
                	</td>
        	</tr>
	        <tr id="distributorr">
        	        <td  style="font-size\: 100%;">Distributor name</td>
                	<td  style="font-size\: 100%;"><input type="text" name="distributor" id="distributor" value="%%distributor%%" style="width\:300px"></td>
	        </tr>
	        <tr id="new_d_code">
        	        <td  style="font-size\: 100%;">Distributor code<br />
<font color="green">(if you set country column for datapack, its value will appear at the end of distributor code in brackets)</font><br />
or select existing distributor:<input type="checkbox" name="sel_distri" id="sel_distri" %%ex_distri_checked%% value="ex_distri" onchange="sel_distributor()" />
			</td>
                	<td style="font-size\: 100%;" id="n_d_code"><input type="text" name="d_code" value="%%d_code%%" style="width\:300px"></td>
			<td style="font-size\: 100%;" id="ex_d_code" style="display\:none;">%%distri_code%%</td>
	        </tr>
	        <tr>
        	        <td  style="font-size\: 100%;">Language</td>
                	<td  style="font-size\: 100%;">%%langid%%</td>
	        </tr>
		<tr>
			<td  style="font-size\: 100%;">Is active for import</td>
			<td  style="font-size\: 100%;">%%active%%</td>
		</tr>
}


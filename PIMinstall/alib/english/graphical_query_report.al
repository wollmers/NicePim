{
name: graphical_query_report;
top_td: <td style="vertical-align: top;">%%top%%</td>
top_row:<tr>%%top_td%%</tr>

body:

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-15">
</head>

<body>
<div style="width: 100%;" align="center">
	<img alt="logo.gif" align="middle" src="cid:trans_logo.gif"/>
</div>	
<div align="center" style="margin: 10px">
	<span style="font-weight: bold;">%%report_name%%</span>
</div>
<div id="report_average"><nobr>
	<table style="font-size: 8pt;">
	<tr>
		%%avg%%
	</tr>
	</table>	
</div>
		
		

<div id="report_graphs">%%graphs%%</div>
<table id="report_tops">
	%%top_row%%
</table>
<DictItem lang="en">graphical_report_bottom</DictItem>
</body>
</html>

}

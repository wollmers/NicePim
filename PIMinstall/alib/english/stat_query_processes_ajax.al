{
name: stat_query_processes_ajax;

stat_query_process_row:
<tr id="curr_report_generate_%%generate_report_bg_processes_id%%" align="center" stage="%%stage%%">
<td class="main info_bold">%%stage%%</td>
<td class="main info_bold">%%seconds%% secs</td>
<td class="main info_bold" align="left" style="padding:0px;">
<div style="width:200px;position:relative;text-align:center;padding:0px">
	<div style="width:%%percent1%%px;height:20px;background-color: #99DD99;float:left"></div>
	<div style="height:20px;text-align:center;position:absolute;left:90px;top:2px">%%percent%%%</div>
</div>
</td>
<td class="main info_bold">
	<a href="javascript:void(0)" onclick="remove_stat_report('%%sessid%%','%%generate_report_bg_processes_id%%')" >Remove</a>
</td>
</tr>

body:
<div style="display\: %%display%%;">
<table class="invisible" align="center" width="100%" id="bg_process_table">
<tr>
<th class="th-norm" width="100%">Current stage</th>
<th class="th-dark">Processed</th>
<th class="th-norm">Completed</th>
</tr>
%%stat_query_process_rows%%
</table>
<br>
</div>
}

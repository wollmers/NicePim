{
name: measure_mapping_processes_ajax;

measure_mapping_process_row:
<tr align="center">
<td class="main info_bold">%%stage%%</td>
<td class="main info_bold">%%seconds%% secs</td>
<td class="main info_bold" align="left" style="padding:0px;">
<div style="width:200px;position:relative;text-align:center;padding:0px">
	<div style="width:%%percent1%%px;height:20px;background-color: #99DD99;float:left"></div>
	<div style="height:20px;text-align:center;position:absolute;left:90px;top:2px">%%percent%%%</div>
</div>
</td>
</tr>

body:
<div style="display\: %%display%%;">
<table class="invisible" align="center" width="100%">
<tr>
<th class="th-norm" width="100%">Current stage</th>
<th class="th-dark">Processed</th>
<th class="th-norm">Completed</th>
</tr>
%%measure_mapping_process_rows%%
</table>
<br>
</div>
}

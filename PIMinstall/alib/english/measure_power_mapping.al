{
name: measure_power_mapping;

power_map_view:
<input type="hidden" name="pattern_order_%%no%%" id="pattern_order_%%no%%" value="%%pattern_id%%">
<input type="hidden" name="pattern_left_%%no%%" id="pattern_left_%%no%%" value="%%pattern_left%%">
<input type="hidden" name="pattern_right_%%no%%" id="pattern_right_%%no%%" value="%%pattern_right%%">
<input type="hidden" name="pattern_right_1_%%no%%" id="pattern_right_1_%%no%%" value="%%pattern_right_1%%">
<input type="hidden" name="pattern_right_2_%%no%%" id="pattern_right_2_%%no%%" value="%%pattern_right_2%%">
<input type="hidden" name="pattern_type_%%no%%" id="pattern_type_%%no%%" value="%%pattern_type%%">
<input type="hidden" name="pattern_max_%%no%%" id="pattern_max_%%no%%" value="%%found%%">

<div id="pattern_%%no%%">%%pattern_show%%</div>


measure_power_map_row:
<tr align="center">
  %%pattern_move%%
  <td class="main info_bold" align="left">%%pattern%%</td>
  <td class="main info_bold">
		<div id="pattern_action_%%no%%">
			%%pattern_edit%%&nbsp;%%pattern_del%%
	  </div>
  </td>
	
	<form id="del_%%no%%" method="post">
		<input type=hidden name=atom_name               value="measure_power_mapping">
		<input type=hidden name=sessid                  value="%%sessid%%">
		<input type=hidden name=measure_id              value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd     value="measure_edit.html">
		<input type=hidden name=tmpl                    value="measure_edit.html">
		<input type=hidden name=command                 value="del_value_regexp">
		<input type=hidden name=id                      value="%%pattern_id%%">
	</form>
</tr>

generic_operation_row:<tr><td class="main info_bold">%%code%%</td><td class="main info_bold">%%name%%</td></tr>

measure_power_mapping_results_max_rows: 250;

measure_power_mapping_results_table_head:
<h3>Measure power mapping preview/apply %%max_rows%%</h3>

<table class="invisible" border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <th class="main info_header">Old value</th>
    <th class="main info_header">New value</th>
    <th class="main info_header">Mapping</th>
  </tr>

measure_power_mapping_results_content:
  <tr>
    <td class="main info_bold">%%old%%</td>
    <td class="main info_bold">%%new%%</td>
    <td class="main info_bold">%%mapping%%</td>
  </tr>

measure_power_mapping_results_table_foot:
</table>

measure_power_mapping_results_do_preview:
<form method="post">
	<input type=hidden name=atom_name               value="measure_power_mapping">
	<input type=hidden name=sessid                  value="%%sessid%%">
	<input type=hidden name=measure_id              value="%%measure_id%%">
	<input type=hidden name=tmpl_if_success_cmd     value="measure_edit.html">
	<input type=hidden name=tmpl                    value="measure_edit.html">

	<input type=hidden name=power_mapping_on        value="1">

	<input type=submit name=preview value="Preview measure power mapping">
</form>

measure_power_mapping_results_do_apply:
<form method="post">
	<input type=hidden name=atom_name               value="measure_power_mapping">
	<input type=hidden name=sessid                  value="%%sessid%%">
	<input type=hidden name=measure_id              value="%%measure_id%%">
	<input type=hidden name=tmpl_if_success_cmd     value="measure_edit.html">
	<input type=hidden name=tmpl                    value="measure_edit.html">
	<input type=hidden name=command                 value="apply_measure_power_mapping">

	<input type=hidden name=power_mapping_apply     value="1">

	<input type=submit name=preview value="Apply changes">
</form>

body:

<h3>Measure power mapping</h3>

$$INCLUDE power_mapping_js.al$$

<div id="current_processes" style="border:1px solid white;display: block;"></div>

<script type="text/javascript">
<!--

	function checkMappingProcesses() \{
	  document.getElementById('current_processes').innerHTML = document.getElementById('current_processes').innerHTML;
		call('get_current_mapping_processes','tag_id=current_processes;foo=bar','sessid=%%sessid%%;tmpl=measure_mapping_processes_ajax.html;measure_id=%%measure_id%%;user_id=%%user_id%%');
		setTimeout("checkMappingProcesses()",3000);
	\}

	checkMappingProcesses();

// -->
</script>

<!-- main table -->

<table class="invisible" border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <th class="main info_header" width="11%" id="pattern_move_0">Move</th>
    <th class="main info_header">Pattern</th>
    <th class="main info_header" width="11%" id="pattern_action_0">Action</th>
  </tr>

	%%measure_power_map_rows%%

</table>

<!-- update movements -->

<div id="moveUpdate" style="display: none;">
	<form method=post id="apply_movement">
		<input type=hidden name=atom_name value="measure_power_mapping">
		<input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=measure_id value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd value="measure_edit.html">
		<input type=hidden name=tmpl value="measure_edit.html">
		<input type=hidden name=command value="movement_value_regexp">
		
		<input type=hidden name=ordered_list id="ordered_list" value="">
	</form>
	
  <table class="invisible" align="right"><tr><td><input type="button" value="Save changes" onClick="javascript:getOrderedList();document.getElementById('apply_movement').submit();"></table>
</div>

<!-- ADD section -->
<div style="display: %%pattern_add%%;">
	<br />
	&nbsp;<a class="linksubmit" id="pattern_p_add_link" onClick="javascript:
																															 document.getElementById('pattern_p_edit').style.display='none';
																															 document.getElementById('pattern_g_edit').style.display='none';
																															 document.getElementById('pattern_p_add').style.display='inline';
																															 document.getElementById('pattern_g_add').style.display='none';
																															 document.getElementById('pattern_p_add_link').style.display='none';
																															 document.getElementById('pattern_g_add_link').style.display='inline';" style="display: inline;">Add pattern</a>
	
	<a class="linksubmit" id="pattern_g_add_link" onClick="javascript:
																												 setGOParameterByGOCode('add',document.getElementById('left_select_add').value);
																												 document.getElementById('pattern_p_edit').style.display='none';
																												 document.getElementById('pattern_g_edit').style.display='none';
																												 document.getElementById('pattern_p_add').style.display='none';
																												 document.getElementById('pattern_g_add').style.display='inline';
																												 document.getElementById('pattern_p_add_link').style.display='inline';
																												 document.getElementById('pattern_g_add_link').style.display='none';" style="display: inline;">Add generic operation</a>
</div>

<div id="pattern_g_add" style="display: none;">
	
  <form method=post>
		<input type=hidden name=atom_name value="measure_power_mapping">
		<input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=measure_id value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd value="measure_edit.html">
		<input type=hidden name=tmpl value="measure_edit.html">
		<input type=hidden name=command value="add_value_regexp">
		<input type=hidden name=id_type_add id=id_type_add value="g">
		<b>Add generic operation</b>
		%%left_select_add%%&nbsp;
		<div id="addGOParameters" style="display:inline;">
			(<div id="addGOParameter1" style="display:inline;">
				<input type="text" name="right_variable_1_add" id="right_variable_1_add" value="">
			</div>
			<div id="addGOParameter2" style="display:inline;">,
				<input type="text" name="right_variable_2_add" id="right_variable_2_add" value="">
			</div>)
		</div>
		<input type="submit" value="Add">
  </form>
	
</div>

<div id="pattern_p_add" style="display: none;">
	
  <form method=post>
		<input type=hidden name=atom_name value="measure_power_mapping">
		<input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=measure_id value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd value="measure_edit.html">
		<input type=hidden name=tmpl value="measure_edit.html">
		<input type=hidden name=command value="add_value_regexp">
		<input type=hidden name=id_type_add id=id_type_add value="p">
		<b>Add pattern</b>
		<input type="text" name="left_part_add" id="left_part_add" value="">
		<font color="red">=</font>
<input type="text" name="right_part_add" id="right_part_add" value="">
<input type="submit" value="Add">
</form>

</div>

<!-- EDIT section -->

<div id="pattern_g_edit" style="display: none;">
	
  <form method=post>
		<input type=hidden name=atom_name value="measure_power_mapping">
		<input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=measure_id value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd value="measure_edit.html">
		<input type=hidden name=tmpl value="measure_edit.html">
		<input type=hidden name=command value="edit_value_regexp">
		<input type=hidden name=g_id id=g_id value="">
		<input type=hidden name=id_type id=id_type value="g">
		<b>Edit generic operation</b>
		%%left_select%%&nbsp;
		<div id="editGOParameters" style="display:inline;">
			(<div id="editGOParameter1" style="display:inline;">
				<input type="text" name="right_variable_1" id="right_variable_1" value="">
			</div>
			<div id="editGOParameter2" style="display:inline;">,
				<input type="text" name="right_variable_2" id="right_variable_2" value="">
			</div>)
		</div>
		<input type="submit" value="Update">
  </form>
	
</div>

<div id="pattern_p_edit" style="display: none;">
	
  <form method=post>
		<input type=hidden name=atom_name value="measure_power_mapping">
		<input type=hidden name=sessid value="%%sessid%%">
		<input type=hidden name=measure_id value="%%measure_id%%">
		<input type=hidden name=tmpl_if_success_cmd value="measure_edit.html">
		<input type=hidden name=tmpl value="measure_edit.html">
		<input type=hidden name=command value="edit_value_regexp">
		<input type=hidden name=p_id id=p_id value="">
		<input type=hidden name=id_type id=id_type value="p">
		<b>Edit pattern</b>
		<input type="text" name="left_part" id="left_part" value=""> <font color="red">=</font>
<input type="text" name="right_part" id="right_part" value="">
<input type="submit" value="Update">
</form>

</div>

<br />
<br />
<br />

<!-- END OF -->

%%measure_power_mapping_results%%

}

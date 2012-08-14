<span id="add_relation_span" style="display\: none;">
	<h3>Add rule</h3>
</span>
<span id="edit_relation_span" style="display\: none;">
	<h3>Edit rule</h3>
</span>

<div id="relation_rule_manage_div" style="display\: none;">
	
  <form method="post" id="relation_rule_manage_form">
		<table border="0" cellpadding="3" cellspacing="0" align="center">
			
			<input type="hidden" name="atom_name" value="%%atom_name4abstract_rule%%">
			<input type="hidden" name="sessid"    value="%%sessid%%">
			<input type="hidden" name="tmpl"      value="%%atom_name4abstract_rule%%.html">
			<input type="hidden" name="command"   value="%%command_name4abstract_rule%%">
			
			<input type="hidden" name="relation_group_id" id="relation_group_id" value="%%relation_group_id%%">
			<input type="hidden" name="relation_set_id"   id="relation_set_id" value="%%relation_set_id%%">
			<input type="hidden" name="relation_rule_id"  id="relation_rule_id" value="%%relation_rule_id%%">
			
			<input type="hidden" name="relation_id"     id="relation_id" value="%%relation_id%%">
			<input type="hidden" name="action"          id="action" value="add">
			
			<tr>
				<td>
					<b><span id="source_span" style="display: inline;">Source</span><span id="destination_span" style="display: none;">Destination</span>&nbsp;rule</b>&nbsp;
					<input type="hidden" name="left_right" id="left_right" value="1"> <!-- 1 - source, 0 - destination -->
					<div id="include_exclude_edit" style="display\: inline;">
						<select name="include_exclude" id="include_exclude" disabled="disabled">
							<option value="1">include</option>
							<option value="0">exclude</option>
						</select>
					</div>&nbsp;<a class="linksubmit" onClick="javascript\:defaultPart('%%sessid%%')">default</a>
				</td>
			</tr>
			
			<tr><td><div id="supplier_edit" style="display\: inline; width: 300px;">%%supplier%%</div></td></tr>
			<tr><td><div id="supplier_family_edit" style="display\: inline; width: 300px;">%%supplierfamily%%</div></td></tr>
			<tr><td><div id="category_edit" style="display\: inline; width: 300px;">%%category%%</div></td></tr>
			<tr><td><div id="feature_edit" style="display\: inline; width: 300px;">%%feature%%</div></td></tr>
			<tr><td><div id="feature_value_edit" style="display\: inline;">feature value<br><input type="text" style="display\: inline; width: 300px;" name="featurevalue" id="featurevalue" value="" disabled="disabled" onChange="javascript\:featureValueOnChange('%%sessid%%');"></div></td></tr>
			<tr><td>
					<div id="exact_value_edit" style="display\: inline;"> <!-- exact matching: 1 - part-of, 2 - exact, 3 - > mode, 4 - < mode, 5 - <> mode  -->
						
						comparison mode&nbsp;<select name="exact_value" id="exact_value" disabled="disabled" onChange="javascript\:exactMatchOnChange('%%sessid%%');">
							<option value="1">like mode</option>
							<option value="2">exact matching</option>
							<option value="3">more than</option>
							<option value="4">less than</option>
							<option value="5">non-equal</option>
						</select>
						
			</div></td></tr>
			
			<!-- prod_id -->
			
			<tr align="left"><td><b>Part code(s)</b>&nbsp;<span id="check_part_code_span" class="linksubmit" style="display: none;" onClick="javascript\:document.getElementById('check_part_code_span').style.display='none';prodIdOnChange('%%sessid%%');">check part code(s)</span><br>
					
					<textarea name="prodid" id="prodid" style="display\: inline; width: 300px; height: 100px;" onKeyUp="javascript:document.getElementById('check_part_code_span').style.display='inline';"></textarea>
					
			</td></tr>
			<tr align="right"><td><div id="start_date_edit" style="display\: inline;"><abbr title="Please, use proper date format YYYY-MM-DD, otherwise date field will be ignored">Start date</abbr>&nbsp;<input type="text" style="display\: inline; width: 200px;" name="start_date" id="start_date" value="" onKeyUp="javascript\:dateOnKeyUp('%%sessid%%');"></div></td></tr>
			<tr align="right"><td><div id="end_date_edit" style="display\: inline;"><abbr title="Please, use proper date format YYYY-MM-DD, otherwise date field will be ignored">End date</abbr>&nbsp;<input type="text" style="display\: inline; width: 200px;" name="end_date" id="end_date" value="" onKeyUp="javascript\:dateOnKeyUp('%%sessid%%');"></div></td></tr>
			<tr><td colspan="2"><div style="color: green; font-size: 0.8em; width: 300px; text-align: justify;">Note! If you set Start date or/and End date, the products will be selected, where<br />Start date < product date added < End date</div></td></tr>
																																																																																													<tr><td># of products\:&nbsp;<div id="amount" style="display\: inline; width: 300px; color: red;">0</div></td></tr>
			<tr><td align="center"><input type="submit" name="add" value="Apply"></td></tr>
		</table>
  </form>
	
</div>

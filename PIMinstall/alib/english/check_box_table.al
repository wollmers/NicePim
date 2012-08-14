{
name: check_box_table;
	td_row: <td><input short_value="%%text%%" type="checkbox" value="%%value%%" %%checked%%/></td><td title="%%value%%">%%text%%</td>
;
	tr_row: </tr><tr>
;
body:
	<div style="vertical-align: middle;">
		<input readonly="readonly" type="text" value="%%values_joined%%" size="21" onclick="show_feature_dropdown(this,%%is_left%%)" class="multifeature_edit" id="%%id%%"/><input id="%%id%%_multifeaturebutton" class="multifeature_button" type="button" onclick="show_feature_dropdown(this,%%is_left%%)" value=" "/>
	</div>
	<table id="%%id%%_multi_value_panel" class="multifeature_checkboxes" style="">
		<caption style="background-color: #3366cc; text-align: right;">&nbsp;
				<span onclick="hide_checkbox_features('%%id%%')" style="color: white; font-size:large; font-weight:bolder; font-family:cursive;  cursor: pointer;">X</span>&nbsp;
		</caption>
		<tr>
		%%tr_row%%	
		</tr>
		<tr>
			<td colspan="4" align="center" style="text-align: center;">
				<input type="button" value="confirm" onclick="collect_checkbox_values('%%id%%',%%short_length%%)"/>
			</td>
		</tr>
	</table>
}


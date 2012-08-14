{
name: track_list_column_choice;
td_row: <td style="text-align: right">%%title%%</td><td><input type="checkbox" name="%%name%%"  value="%%value%%" %%checked%% />&nbsp;&nbsp;&nbsp;</td>
tr_row: %%td_row%%</tr><tr>

body:
<form method="post">
	<input type="hidden" name="atom_name" value="track_products"/>
	<input type="hidden" name="sessid" value="%%sessid%%"/>
	<input type="hidden" name="mi" value="%%mi%%"/>
	<input type="hidden" name="tmpl_if_success_cmd" value="track_products.html"/>
	<input type="hidden" name="tmpl" value="track_products.html"/>
	<input type="hidden" name="track_list_id" value="%%track_list_id%%"/>
	<input type="hidden" name="command" value="save_user_track_list_cols"/>
	
<div id="overlay_content" style=" border: 3px aqua groove; width:600px; height:300px; z-index:10000; background-color: white; display:none; float: left; position: absolute; top:350px;left: 400px; " align="center">
	<table style="margin-top: 20px; width: 100%">
		<tr>
		%%tr_row%%
		</tr>
		<tr>
			<td colspan="8" style="text-align: center;">
				<input type="submit" value="confirm">
			</td>
		</tr>
	</table>
</div>
</form>
}

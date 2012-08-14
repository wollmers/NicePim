<h3>Feature power mapping (expert mode)</h3>

<table border="0" cellpadding="0" cellspacing="2" width="100%">
<tr>
<td width="1%">
<form method=post>
  <input type=hidden name=atom_name value="feature_values">
  <input type=hidden name=sessid value="%%sessid%%">
  <input type=hidden name=feature_id value="%%feature_id%%">
  <input type=hidden name=tmpl_if_success_cmd value="feature_values.html">
  <input type=hidden name=tmpl value="feature_values.html">

<textarea rows=15 cols=75 name="pattern">%%feature_power_map_rows%%</textarea><br>
	<input type="submit" name="atom_update" value="Update">&nbsp;(<span class="linksubmit" onClick="javascript:if (document.getElementById('patterns_howto').style.display == 'block'\
) \{document.getElementById('patterns_howto').style.display = 'none'\} else \{document.getElementById('patterns_howto').style.display = 'block'\};">patterns how-to</span>)
</form>
</td>
<td valign="top" align="left">
<i>Available generic operations\:</i><br>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><th class="th-dark">code</th><th class="th-norm">description</th></tr>
%%generic_operation_rows%%
</table>
</td>
</tr>
</table>

$$INCLUDE power_mapping_patterns_howto.al$$

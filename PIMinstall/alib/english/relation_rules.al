{
name: relation_rules;

relation_rules_row:
<tr align="center">
	
	
	<td class="main info_bold">
		%%no%%/%%found%%
		<input type="hidden" id="%%relation_id%%_name" value="%%name%%">
	</td>
	<td class="main info_bold"><a class="linksubmit" href="%%base_url%%;tmpl=relation_sets.html;relation_group_id=%%relation_group_id%%;relation_id=%%relation_id%%">%%name%%</a></td>
  <td class="main info_bold" style="color: red;">%%amount%%</td>
  <td class="main info_bold" style="color: red;">%%amount_2%%</td>
  <td class="main info_bold">%%relations_set%%</td>
  <td class="main info_bold">%%relations_set_2%%</td>
  <td class="main info_bold" style="color: red;">
		<script type="text/javascript">
			<!--
				 document.write(%%amount%%*%%amount_2%%);
				 // -->
		</script>
	</td>
	<td class="main info_bold"><a class="linksubmit" onClick="javascript\:editRuleOnClick('%%relation_id%%','%%name%%')">edit</a>&nbsp;|&nbsp;
		<a class="linksubmit" onClick="javascript\:deleteRuleOnClick('%%relation_id%%');">del</a>
	</td>
</tr>

body:

<script type="text/javascript">
<!--
function addRuleOnClick() \{
  document.getElementById('relation_rule_add_button').style.display = 'none';
  document.getElementById('relation_id').value = '';
  document.getElementById('relation_rule_name').value = '';
  document.getElementById('relation_rule_manage_span').style.display = 'block';
\}

function deleteRuleOnClick(id) \{
  document.getElementById('relation_rule_name').value = '1'; // otherwise onSubmit fails
		document.getElementById('relation_id').value = id;
  document.getElementById('manage_relation_rule').value='del';
  document.getElementById('relation_rule_manage_form').submit();
\}
	 
function editRuleOnClick(id,name) \{
  document.getElementById('relation_rule_add_button').style.display = 'block';
  document.getElementById('manage_relation_rule').value = 'edit';
  document.getElementById('relation_id').value = id;
  document.getElementById('relation_rule_name').value = name;
  document.getElementById('relation_rule_manage_span').style.display = 'block';
\}
// -->
</script>

<div id="page_content">

<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr>
		<td align="left">
			$$INCLUDE products_link.html$$
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu2" href="%%base_url%%;tmpl=relation_groups.html">Relation groups</a>
			<img src="/img/campaign_def/arrow.gif" width="9" alt=""/>&nbsp;<a class="linkmenu2" href="%%base_url%%;tmpl=relation_rules.html;relation_group_id=%%relation_group_id%%">%%relation_group_name%%</a>
		</td>
	</tr>
</table>

<br />

<div class="linksubmit" id="relation_rule_add_button" onClick="javascript\:addRuleOnClick();">Add relation rule</div>

<!-- edit form -->

<span id="relation_rule_manage_span" style="display\: none;">
	<form method="post" id="relation_rule_manage_form" onSubmit="javascript\:if (document.getElementById('relation_rule_name').value == '') \{return false;\}">
		
		<input type="hidden" name="atom_name" value="relation_rules">
		<input type="hidden" name="sessid" value="%%sessid%%">
		<input type="hidden" name="tmpl" value="relation_rules.html">
		<input type="hidden" name="relation_id" id="relation_id" value="">
		<input type="hidden" name="relation_group_id" id="relation_group_id" value="%%relation_group_id%%">
		<input type="hidden" name="manage_relation_rule" id="manage_relation_rule" value="add">
		<input type="hidden" name="command" value="manage_relation_rule">
		
		<table><tr><td>name<td><input type="text" name="name" id="relation_rule_name" value=""><td>
		
		<input type="submit" name="add" value="Apply"></table>
		<div style="color: red; font-size: 0.8em;">(You may use the product part code as the rule name here)</div>
		
	</form>
</span>

<!-- list -->

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<th class="main info_header"># / ##</th>
								<th class="main info_header">Name</th>
								<th colspan="2" class="main info_header"># products</th>
								<th colspan="2" class="main info_header"># rules</th>
								<th class="main info_header"># relations</th>
								<th class="main info_header">Actions</th>
							</tr>
							
							%%relation_rules_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

<br />

}

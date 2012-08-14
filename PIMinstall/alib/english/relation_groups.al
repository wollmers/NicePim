{
name: relation_groups;

$$INCLUDE nav_inc.al$$

relation_groups_row:
<tr align="center">
	<td class="main info_bold">%%no%%/%%found%%</td>
  <td class="main info_bold"><a href="%%base_url%%;tmpl=relation_rules.html;relation_group_id=%%relation_group_id%%">%%name%%</a></td>
	<td class="main info_bold">%%description%%</td>
	<td class="main info_bold">%%amount%%</td>
	<td class="main info_bold"><a class="linksubmit" onClick="javascript\:editGroupOnClick('%%relation_group_id%%','%%name%%','%%description%%')">edit</a>&nbsp;|&nbsp;
		<a class="linksubmit" onClick="javascript\:if(confirm('Are you sure?')) deleteGroupOnClick('%%relation_group_id%%');">del</a></td>
</tr>

body:

<script type="text/javascript">
<!--
function addGroupOnClick() \{
	document.getElementById('relation_group_add_button').style.display = 'none';
	document.getElementById('relation_group_id').value = '';
	document.getElementById('relation_group_name').value = '';
	document.getElementById('relation_group_description').value = '';
	document.getElementById('relation_group_manage_span').style.display = 'block';
\}

function deleteGroupOnClick(id) \{
	document.getElementById('relation_group_name').value = '1'; // otherwise onSubmit fails
	document.getElementById('relation_group_id').value = id;
	document.getElementById('manage_relation_group').value='del';
	document.getElementById('relation_group_manage_form').submit();
\}

function editGroupOnClick(id,name,description) \{
	document.getElementById('relation_group_add_button').style.display = 'block';
	document.getElementById('manage_relation_group').value = 'edit';
	document.getElementById('relation_group_id').value = id;
	document.getElementById('relation_group_name').value = name;
	document.getElementById('relation_group_description').value = description;
	document.getElementById('relation_group_manage_span').style.display = 'block';
\}
// -->
</script>

<span style="font-family: Verdana; font-size: 0.8em; color: #00AA00;">%%products2process_queue%%</span>

<br />

<span class="linksubmit" id="relation_group_add_button" onClick="javascript\:addGroupOnClick();">Add relation group</span>

<br />

<span id="relation_group_manage_span" style="display\: none;">
	<form method="post" id="relation_group_manage_form" onSubmit="javascript\:if (document.getElementById('relation_group_name').value == '') \{return false;\}">
		<input type="hidden" name="atom_name" value="relation_groups">
		<input type="hidden" name="sessid" value="%%sessid%%">
		<input type="hidden" name="tmpl" value="relation_groups.html">
		<input type="hidden" name="relation_group_id" id="relation_group_id" value="">
		<input type="hidden" name="manage_relation_group" id="manage_relation_group" value="add">
		<input type="hidden" name="command" value="manage_relation_group">
		
		<table><tr><td>name<td><input type="text" name="name" id="relation_group_name" value="" style="width: 200px;">
		<td>description<td><input type="text" name="description" id="relation_group_description" value="" style="width: 400px;a"><td>
		<input type="submit" name="add" value="Apply"></table>
		<div style="color: red; font-size: 0.8em;">(You may use the vendor name as the group name here)</div>
		
	</form>
</span>
		
$$INCLUDE nav_bar2.al$$

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
								<th class="main info_header">Description</th>
								<th class="main info_header"># of rules</th>
								<th class="main info_header">Actions</th>
							</tr>
							
							%%relation_groups_rows%%
							
						</table>
						
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>

$$INCLUDE nav_bar2.al$$

}

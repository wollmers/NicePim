{
name: campaign;

country_id_set_multiselect_empty_key: 0;
country_id_set_multiselect_empty: International;

$$INCLUDE actions2.al$$

body:
<table>
	<tr>
		<td>

<!-- continuing -->

		<td class="search" align="right" style="width:100%;padding-left:10px"></td>
	</tr>
</table>

<script type="text/javascript">
<!--

	function addCampaignOnSubmit() \{
		if ((document.getElementById('name').value == '') || (document.getElementById('short_description').value == '')) \{
			if (document.getElementById('name').value == '') \{ document.getElementById('name').style.backgroundColor = '#ffcccc'; \}
			else \{ document.getElementById('name').style.backgroundColor = 'transparent'; \}
			if (document.getElementById('short_description').value == '') \{ document.getElementById('short_description').style.backgroundColor = '#ffcccc'; \}
			else \{ document.getElementById('short_description').style.backgroundColor = 'transparent'; \}
			alert('Please, complete mandatory fields!');
			return false;
		\}
		return true;
	\}

		function changeTab(tab_id,total) \{
			for(var i=1;i<=total;i++) \{
				if (i!=tab_id) \{
					document.getElementById('t'+i).className = 'tab_inactive';
					document.getElementById('o'+i).style.display = 'none';
				\}
			\}
			document.getElementById('t'+tab_id).className = 'tab_active';
			document.getElementById('o'+tab_id).style.display = '';
		\}

// -->
</script>

<br />

<!-- tabs -->
<table cellspacing="0" cellpadding="0" border="0" width="100%">
	<tr valign="bottom">
		<td class="external_bottom">&nbsp;</td>
		<td valign="bottom" width="20%">
			<div onClick="changeTab(1,2)" class="tab_active" style="cursor: hand;" id="t1">Products management</div>
		</td>
		<td valign="bottom" width="20%">
			<div onClick="changeTab(2,2)" class="tab_inactive" style="cursor: hand;" id="t2">Campaign details</div>
		</td>
		<td width="100%" class="external_bottom">&nbsp;</td>
	</tr>
</table>

	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" id="o2" style="display: none;">
		<tr>
			<td class="external_wo_top">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
<form method="post" enctype="multipart/form-data" onsubmit="return addCampaignOnSubmit();">
	
	<input type="hidden" name="atom_name" value="campaign">
	<input type="hidden" name="sessid" value="%%sessid%%">
	<input type="hidden" name="tmpl" value="campaigns.html">
	<input type="hidden" name="campaign_id" id="campaign_id" value="%%campaign_id%%">
	<input type="hidden" name="command" value="manage_campaigns">

	<input type="hidden" name="user_id" id="user_id" value="%%user_id%%">

							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header" colspan="2">Campaign details</th>
								</tr>
								
								<tr>
									<td class="main info_bold" align="center">Name</td>
									<td class="main info_bold left_padding"><input class="text" type="text" name="name" id="name" value="%%name%%" style="width: 250px;"></td>
								</tr>
								<tr>
									<td class="main info_bold" align="center">Title</td>
									<td class="main info_bold left_padding"><input class="text" type="text" name="short_description" id="short_description" style="width: 450px;" value="%%short_description%%"></td>
								</tr>
								<tr>
									<td class="main info_bold" align="center">Motivation</td>
									<td class="main info_bold left_padding"><textarea name="long_description" id="long_description" style="width: 450px; height: 150px;">%%long_description%%</textarea></td>
								</tr>
								<tr>
									<td class="main info_bold" align="center"><abbr class="main info_bold" title="leave blank if you want to have an endless campaign">Duration</abbr></td>
									<td class="main info_bold left_padding">from %%start_date%% to %%end_date%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align="center" id="link_name">Landing page</td>
									<td class="main info_bold left_padding"><input type="text" name="link" id="link" value="%%link%%" style="width: 450px;"></td>
								</tr>
								<tr> <!-- countries -->
									<td class="main info_bold" align="center" id="link_name">Countries</td>
									<td class="main info_bold left_padding">%%country_id_set%%</td>
								</tr>
								<tr>
									<td class="main info_bold" align="center" colspan="2">
										
										<table border="0"><tr><td>%%insert_action%%</td><td>%%update_action%%</td><td>%%delete_action%%</td></tr></table>
										
									</td>
								</tr>

	</form>
}


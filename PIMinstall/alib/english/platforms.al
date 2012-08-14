{
name: platforms;

$$INCLUDE actions2.al$$

platforms_row:
<tr>
  <td class="main info_bold" align="center">
		<script type="text/javascript">
<!--
	if (document.getElementById('platform_id_max').value < %%platform_id%%) \{ document.getElementById('platform_id_max').value = %%platform_id%%; \}
// -->
	 </script>
		<input type="checkbox" id="platform_%%platform_id%%_checkbox" name="platform_%%platform_id%%_checkbox" value="" onClick="javascript: platform_checkbox_checking(%%platform_id%%);">
	</td>
  <td class="main info_bold" align="center">
		<input type="radio" id="platform_%%platform_id%%_radio" name="platform_radio" value="%%platform_id%%" style="display: none;" onClick="javascript: document.getElementById('platform_id_default').value = document.getElementById('platform_%%platform_id%%_radio').value;">
	</td>
  <td class="main info_bold"><a id="%%platform_id%%_a" onClick="javascript: document.getElementById('%%platform_id%%_a').style.display='none'\; document.getElementById('%%platform_id%%_span').style.display='block'\;" class="linksubmit">%%name%%</a>
		<form method="post">
			<input type="hidden" name="atom_name" value="platforms">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="platform_id" value="%%platform_id%%">
			<input type="hidden" name="tmpl" value="platforms.html">
			<input type="hidden" name="platform_old_name" value="%%name%%">
			<input type="hidden" name="command" value="platform_name_update">
			<span id="%%platform_id%%_span" style="display: none;"><input type="text" name="name" value="%%name%%"><input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_save.gif) no-repeat;' name="atom_update" value="." /></span>
		</form>
	</td>
  <td class="main info_bold" align="center">
		%%count%%
	</td>
	<td class="main info_bold" style="text-align: right;">
		<form method="post">
			<input type="hidden" name="atom_name" value="platforms">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="platform_id" value="%%platform_id%%">
			<input type="hidden" name="tmpl" value="platforms.html">
			<input type="hidden" name="platform_old_name" value="%%name%%">
			<input type="hidden" name="command" value="platform_name_delete">
			<input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete.gif) no-repeat;' name="atom_delete" value="." onClick="var agree=confirm('Are you sure you wish to continue?'); if (agree) \{ return true; \} else \{ return false; \}">
		</form>
	</td>
</tr>

body:

<input type="hidden" id="platform_id_max" value="0">

<script type="text/javascript">
<!--

function platform_checkbox_checking(platform_id) \{
		
		// show / hide the radiobutton
		
		if (document.getElementById('platform_'+platform_id+'_checkbox').checked) \{
				document.getElementById('platform_'+platform_id+'_radio').style.display = '';
		\}
		else \{
				document.getElementById('platform_'+platform_id+'_radio').style.display = 'none';
		\}
		
		// show / hide the 
		var hide = 1;
		for (var i=1; i<=document.getElementById('platform_id_max').value; i++) \{
				if ((document.getElementById('platform_'+i+'_checkbox')) && (document.getElementById('platform_'+i+'_checkbox').checked)) \{
						hide = 0;
				\}
		\}

		if (hide) \{
				document.getElementById('merge_td').style.display='none';
		\}
		else \{
				document.getElementById('merge_td').style.display='';
		\}
\}

// -->
</script>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>

						<form method="post" onSubmit="javsscript: if (document.getElementById('new_name').value.replace(/(^\s+)|(\s+$)/g, '') == '') \{ return false \}\;">

                <input type="hidden" name="atom_name" value="platforms">
                <input type="hidden" name="sessid" value="%%sessid%%">
                <input type="hidden" name="platform_id" value="">
                <input type="hidden" name="tmpl" value="platforms.html">

								<table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
								<tr>
									<td nowrap="nowrap">
										~New platform name~</td><td><input type="text" name="name" id="new_name" value=""></td><td>
										%%insert_action%%</td><td width="100%"></tr>
								</table>
						</form>

						<table border="0" cellpadding="3" cellspacing="1" width="75%" align="center">
							<tr>
								<th width="15%" class="main info_header">Select for merging</th>
								<th width="15%" class="main info_header">Choose the main platform</th>
								<th class="main info_header">Platform name</th>
								<th width="5%" class="main info_header">Count</th>
								<th width="5%" class="main info_header">Action</th>
							</tr>
							
							%%platforms_rows%%

							<!-- form for merging -->

	<script type="text/javascript">
	<!--
	function isPlatformMergeSubmit() \{
			var isSubmit = false;
			
			//document.getElementById('platform_id_default').value = document.getElementById('platform_radio').value;
			
			var hide = 1;
			document.getElementById('platforms_id2merge').value = '';
			for (var j=1; j<=document.getElementById('platform_id_max').value; j++) \{
					if ((document.getElementById('platform_'+j+'_checkbox')) && (document.getElementById('platform_'+j+'_checkbox').checked)) \{
							document.getElementById('platforms_id2merge').value += j + ',';
							if ((document.getElementById('platform_id_default').value != '') && (document.getElementById('platform_id_default').value == j)) \{
									isSubmit = true;
							\}
					\}
			\}

			return isSubmit;
	\}
	// -->
	</script>

							<tr>
								<td class="main info_bold" colspan="4" id="merge_td" style="display: none;" align="center">
									<form method="post">
										<input type="hidden" name="atom_name" value="platforms">
										<input type="hidden" name="sessid" value="%%sessid%%">
										<input type="hidden" name="tmpl" value="platforms.html">

										<input type="hidden" name="command" value="merge_platforms">

										<input type="hidden" name="platforms_id2merge" id="platforms_id2merge" value="">
										<input type="hidden" name="platform_id_default" id="platform_id_default" value="">

										<input type="submit" name="reload" value="Merge platforms" onClick="javascript: if(isPlatformMergeSubmit()) \{ return true; \} else \{ return false; \}">
									</form>

								</td>
							</tr>
							
						</table>		
								
          </td>
        </tr>
      </table>

    </td>
  </tr>
</table>

}

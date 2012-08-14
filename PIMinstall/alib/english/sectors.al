{
name: sectors;

$$INCLUDE actions2.al$$

sectors_row:

<tr>
	<!-- Radio button -->
	<td class="main info_bold">
	    <span style="display: none;" id="span_sector_id_radio_%%sector_id%%" >
	    <input type="radio" name="sector_id_radio" id="sector_id_radio_%%sector_id%%" value="%%sector_id%%">
	    </span>
	</td>
	
	<!-- Checkbox -->
	<!--td class="main info_bold"-->
	<td class="main info_bold">
	    <span style="display: block;">
	    <input type="checkbox" name="checked_sector_%%sector_id%%" id="checked_sector_%%sector_id%%" value="1" onClick="hideRadio()">
	    </span>
	</td>
	
	<!-- English name (from sector_name table) -->
	<td class="main info_bold">
	    (%%sector_id%%)
		<a id="%%sector_id%%" href="%%base_url%%;tmpl=sector_edit.html;sector_id=%%sector_id%%">%%name%%</a>
	</td>
	
	<!-- Delete button -->
	<td class="main info_bold" style="text-align: right;">
		<form method="post">
			<input type="hidden" name="atom_name" value="sectors">
			<input type="hidden" name="sessid" value="%%sessid%%">
			<input type="hidden" name="sector_id" value="%%sector_id%%">
			<input type="hidden" name="tmpl" value="sectors.html">
			<input type="hidden" name="command" value="delete_from_sector_table">
			<input type="hidden" name="new_name" value="1">
			<input class="hover_button" type="submit" style='width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_delete.gif) no-repeat;' name="atom_delete" value="." onClick="var agree=confirm('All users with this sector will receive a default value IT. Are you sure you wish to continue?'); if (agree) \{ return true; \} else \{ return false; \}">
		</form>
	</td>
</tr>

body:

<script type="text/javascript">
function hideRadio() \{

    var i;
    var ref = document.getElementsByName('sector_id_radio');
    var c = 0;
    var id;
    for (i = 0 ; i < ref.length ; i++ ) \{
	// check counter
	id = document.getElementById('checked_sector_' + ref[i].value);
	if (id.checked) \{
	    c++;
	\}
    \}
        
    if (c == 0) \{
	// hide 
	for (i = 0 ; i < ref.length ; i++ ) \{
	    document.getElementById('span_sector_id_radio_' + ref[i].value).style.display = 'none';
	\}
	document.getElementById('span_merge_button').style.display = 'none';
    \} else \{
	// display
	for (i = 0 ; i < ref.length ; i++ ) \{
	    if (! document.getElementById('checked_sector_' + ref[i].value).checked) \{
		document.getElementById('span_sector_id_radio_' + ref[i].value).style.display = 'none';
	    \} else \{
		document.getElementById('span_sector_id_radio_' + ref[i].value).style.display = 'block';
	    \}
	\} 
	if (document.getElementById('span_merge_button').style.display == 'none') \{
	    document.getElementById('span_merge_button').style.display = 'block';
	\}
    \}
    
\}
</script>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>

		<form method="post" onSubmit="return check_new_value()">
		

                <input type="hidden" name="atom_name" value="sectors">
                <input type="hidden" name="sessid" value="%%sessid%%">
                <input type="hidden" name="sector_id" value="">
                <input type="hidden" name="tmpl" value="sectors.html">
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
			<tr>
			    <td nowrap="nowrap">
				~New sector English name~
			    </td>
			    <td>
				<input type="hidden" name="default_langid" id="default_langid" value="1">
				<input type="text" name="new_name" id="new_name" value="">
			    </td>
			    <td>
			    	%%insert_action%%
			    </td>
			    <td width="100%">
			</tr>
		    </table>
		</form>
		
		<!-- form for merge button -->
		<form>
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
		    <tr>
			<td class="main info_header">
			    Target<br>sector
			</td>
			<td class="main info_header">
			    Will be<br>merged
			</td>
			<!-- old caption th class="main info_header" width="15%" colspan="4">Sector English name</th-->
			<td class="main info_header" colspan="2">
			    Sector English name
			</td>
		    </tr>
			%%sectors_rows%%
		    <tr>
			
			
		    <tr>
			<td colspan="4">
			<span style="display: none;" id="span_merge_button" >
			    <input type="submit" value="Merge sectors" onClick="last_check()">
			</span>
			</td>
		    </tr>
		    </table>
		    
		    <input type="hidden" name="command" value="merge_sectors">
		    <input type="hidden" name="tmpl" value="sectors.html">
		    
		</form>
		
		
          </td>
        </tr>
      </table>

    </td>
  </tr>
</table>

<script type="text/javascript">

function last_check() \{
    var ref = document.getElementsByName('sector_id_radio');
    
    if (document.getElementById('checked_sector_1').checked) \{
	if (! document.getElementById('sector_id_radio_1').checked) \{
	    alert("IT should be a target sector in this case");
	\}
	
    \}
    
\}

</script>

<script type="text/javascript">
function check_new_value() \{

    // kill whitespaces
    var str = document.getElementById('new_name').value;
    str = str.replace(/^\s+/, '');
    str = str.replace(/\s+$/, '');
    document.getElementById('new_name').value = str;
    
    if (document.getElementById('new_name').value == '' ) \{
        alert('Empty value');
        return false;
    \}
    
    // new checker for duplicate English name
    var ref = document.getElementsByName('sector_id_radio');
    for (i = 0 ; i < ref.length ; i++ ) \{
	    if (document.getElementById(ref[i].value).text == document.getElementById('new_name').value ) \{
	        alert('Duplicate English name');
	        return false;
	    \}
	\}
\}

</script>

}


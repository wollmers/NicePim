<tr>
	<td class="main info_bold" width="17%" align="right"><span style="color: red;">*</span>~Language~</td>
	<td class="main info_bold" width="83%">%%edit_langid%%</td>
</tr>

<tr>
	<td class="main info_bold" align="right"><span style="color: red;">*</span>~Short description~</td>
	<td class="main info_bold"><input type="text" size="72" name="short_desc" value="%%short_desc%%" style="width: 650px;"></td>
</tr>


<tr>
	<td class="main info_bold" valign="top" align="right">~Marketing text~
		<br/><br/>
		<div><input type="button" value="-" onClick="javascript:replaceSelection(long_desc,'-');" style="width: 125px;"></div>
		<div><input type="button" value="bold" onClick="javascript:replaceSelection(long_desc,'b');" style="width: 125px;"></div>
		<div><input type="button" value="no double spaces" onClick="javascript:refineText(long_desc,'b');" style="width: 125px;"></div>
	</td>
	<td class="main info_bold" valign="top">%%long_desc%%</td>
</tr>

<tr>
	<td class="main info_bold" align="right"><span style="color: red;">*</span>~URL~</td>											
	<td class="main info_bold"><input type="text" size="30" name="official_url" value="%%official_url%%" style="width: 650px;"></td>
</tr>

<tr>
	<td class="main info_bold" valign="top" align="right">~PDF URL~</td>											
	<td class="main info_bold"><input type="text" size="72" name="pdf_url" value="%%pdf_url%%" style="width: 650px;">
	 	or <br /><input type="file" name="pdf_url_filename" style="width: 650px;">
	</td>
</tr>

<tr>
	<td class="main info_bold" valign="top" align="right">~Manual PDF URL~</td>											
	<td class="main info_bold"><input type="text" size="72" name="manual_pdf_url" value="%%manual_pdf_url%%" style="width: 650px;">
	 	or<br> <input type="file" name="manual_pdf_url_filename" style="width: 650px;">
	</td>
</tr>

<tr>
	<td class="main info_bold" valign="top" align="right">
	    ~Warranty info~
	</td>
	<td class="main info_bold" valign="top">
	    <!--textarea cols="72" rows="5" name="warranty_info" style="width: 650px; height: 75px;">%%warranty_info%%</textarea-->
	    <input type="text" name="warranty_info" style="width: 650px;" value="%%warranty_info%%" >
	    <br>
	    <div id="warranty_popup">
	        
	    </div>
	</td>
</tr>

<tr>
	<td class="main info_bold" colspan="2" align="center">
		<table><tr><td>%%update_action%%<td>%%delete_action%%<td>%%insert_action%%</table>
	</td>
</tr>

</table>

</td>
</tr>
</table>

</td>
</tr>
</table>

    <input type="hidden" id="supplier_id" name="supplier_id" value="%%supplier_id%%">
    <input type="hidden" id="catid" name="catid" value="%%catid%%">

</form>

<script language="JavaScript">

    // popup with for description page
    var tmpl = document.getElementsByName('tmpl')[0].value;
    if (tmpl == 'product_description.html' ) \{
        var container = document.getElementById('warranty_popup');
        
            // get params
            var catid = document.getElementById('catid').value;
            var supplier_id = document.getElementsByName('supplier_id')[0].value;
            var session_id = document.getElementsByName('sessid')[0].value;
            var langid = document.getElementById('edit_langid').value;
            
            // create AJAX request
            // warranty_info2 mode
            var tmp1_local = 'tag_id=warranty_info2;supplier_id=' + supplier_id + ';foo=bar;field_name=warranty_info;category_id=' + catid + ';desc_langid=' + langid;
            var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_get_default_warranty_info.html';

            // alert("CATID=" + catid + " SUPPLIER=" + supplier_id + " LANG=" + langid + " SESSION=" + session_id);

            call('get_warranty_info', tmp1_local, tmp2_local);
    \}
    
    document.getElementById('edit_langid').addEvent(
        'change',
        function aaa() \{
            
            // get params
            var supplier_id = document.getElementsByName('supplier_id')[0].value;
            var catid = document.getElementById('catid').value;
            var session_id = document.getElementsByName('sessid')[0].value;
            var langid = document.getElementById('edit_langid').value;
            
            // create AJAX request
            // warranty_info1 mode
            var tmp1_local = 'tag_id=warranty_info1;supplier_id=' + supplier_id + ';foo=bar;field_name=warranty_info;category_id=' + catid + ';desc_langid=' + langid;
            var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_get_default_warranty_info.html';

            // alert("CATID=" + catid + " SUPPLIER=" + supplier_id + " LANG=" + langid + " SESSION=" + session_id);

            call('get_warranty_info', tmp1_local, tmp2_local);
        \}
    );
    
    function set_default() \{
        text = document.getElementById('default_wi').value;
        document.getElementsByName('warranty_info')[0].value = text;
        document.getElementById('warranty_popup').innerHTML = '';
        return;
    \}
</script>

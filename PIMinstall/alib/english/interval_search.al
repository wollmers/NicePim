{
name: interval_search;

$$INCLUDE actions2.al$$

body:

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
		    <tr>
		        <th class="main info_header" width="50%">Intervals</th>
		        <th class="main info_header" width="50%">Elements in each</th>
		    </tr>
			
			%%intervals%%	
				
		    </table>				   
		    
		    
		    
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td style="padding-top:10px">

      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
        <tr>
          <td>
		    <table border="0" cellpadding="3" cellspacing="1" width="50%" align="center">
		    <tr>
		    <td>
Valid values: %%valid%%
<br>
Invalid values: %%invalid%%
<br>
<script type="text/javascript">
    var num = %%valid%%;
    var denum = %%invalid%% + %%valid%%;
    if (denum != 0) \{
        document.write("Sane values for an interval searching: " + Math.floor(num/denum * 10000) / 100 + "%");
    \} 
</script>
<br>

<br>
Last generated: <span>%%updated%%</span>
<br>
<br>
  
  <form method="post">
    <input type="hidden" name="atom_name" value="interval_search">
    <input type="hidden" name="sessid" value="%%sessid%%">
    <input type="hidden" name="tmpl" value="interval_search.html">
    <input type="hidden" name="tmpl_if_success_cmd" value="interval_search.html">
    <input type="hidden" name="category_feature_id" value="%%category_feature_id%%">
    <input type="hidden" name="catid" value="%%catid%%">
    <input type="hidden" name="command" value="refresh_category_feature_intervals">
    <input type="submit" value="Refresh intervals">
  </form>
		    </td>
		    </tr>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>




    
}


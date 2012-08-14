foreign_distributors_body:
	 <!-- list of foreign distributor's exact symbols-->
   <tr>
	 <td colspan="3">
   <input id="merge_distributors" type="checkbox" name="merge_symbols" checked onClick="javascript:anyDistributor();">merge following symbols</input>
   <table cellspacing=0 cellpadding=0 border=0 width=100%>
   <tr>
     <td width="33%" bgcolor="#99CCFF"><p align="left"><font face="Verdana" size="2" color="#FFFFFF">Symbol</font></td>
     <td width="33%" bgcolor="#99CCFF"><p align="left"><font face="Verdana" size="2" color="#FFFFFF">Distributor</font></td>
     <td width="33%" bgcolor="#99CCFF"><p align="left"><font face="Verdana" size="2" color="#FFFFFF">Brand</font></td>
   </tr>
   %%foreign_distributors_rows%%
   </table>
	 </td>
   </tr>
	 <!-- end of -->

<script>
	var dist_id = document.getElementById('distributor_id').value;
anyDistributor();

function anyDistributor() \{
	if (document.getElementById('merge_distributors').checked==true) \{
	document.getElementById('distributor_id').value='';
\}
else \{
	document.getElementById('distributor_id').value=dist_id;
  \}
\}
</script>


foreign_distributors_row:
	<input type="hidden" name="row_%%row_name%%_item" value="%%row_value%%">
	<tr><td><input type="checkbox" name="row_%%row_name%%" value="1" checked>%%foreign_symbol%%</td><td>%%foreign_distname%%</td><td>%%foreign_value%%</td></tr>

foreign_distributors_row_disabled:
	<tr><td><input type="checkbox" disabled>%%foreign_symbol%%</td><td>%%foreign_distname%%</td><td>%%foreign_value%%</td></tr>

foreign_distributors_row_count:
	<input type="hidden" name="row_count" value="%%row_count%%">

{
name: product_rating_conf;
body:

<form method=post enctype="multipart/form-data">
	
	<input type=hidden name=atom_name value="product_raiting_conf">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=tmpl_if_success_cmd value="products_raiting.html">
	<input type=hidden name=tmpl value="product_rating_conf.html">
	<input type=hidden name=command value="set_rating_formula">

<table width="100%">
<tr>
	<td class="main info_bold" style="vertical-align: bottom;" width="10%">
		<table cellpadding="0" cellspacing="0"><tr><td>Formula\:</td>
			<td><img style="cursor: pointer;" title="help" src="img/question.gif" onclick="show_help(event)"/></td>
		</tr></table>	 
	</td>
	<td class="main info_bold">
	 <input type="text"  style="width: 99%" name="formula" value="%%formula%%"/>
	</td>
	
</tr>
<tr>
	<td class="main info_bold">
		<table cellpadding="0" cellspacing="0"><tr><td>Period\:</td>
			<td><img style="cursor: pointer;" title="help" src="img/question.gif" onclick="show_period_help(event)"/></td>
		</tr></table>	 
		  
	</td>
	<td class="main info_bold">
		<input type="text" size="5" value="%%period%%" name="period"/>days
	</td>
</tr>
<tr>
	<td colspan="2" align="center" class="main info_bold">
		<input type="submit" value="save" name="save"/>
		<input type="submit" value="save and recalculate" name="save_start"/> and send an email when the batch process is finished to <input type="text" name="email" value="%%email%%" size="30"> 
	</td>
</tr>
</table>
</form>
<script type="text/javascript">
	function show_help(event)\{
		handleAjaxOverlay(event,'ajax_overlay_result_id',true,false);
		document.getElementById('ajax_overlay_result_id').innerHTML='<DictItem lang="en">product_rating_formula_help</DictItem>';
		\}
	function show_period_help(event)\{
		handleAjaxOverlay(event,'ajax_overlay_result_id',true,false);
		document.getElementById('ajax_overlay_result_id').innerHTML='<DictItem lang="en">product_rating_period_help</DictItem>';
		\}
	
</script>
}

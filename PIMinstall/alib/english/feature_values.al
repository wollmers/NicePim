{
name: feature_values;

feature_val_row: 
<tr>
  <td class="main info_bold" style="margin-bottom: 3px">
		<img style="cursor: pointer" title="push me to see my products" src="img/question.gif" onclick="makeQuery(event,'%%feature_id%%','%%raw_value%%','%%sessid%%','ajax_result',this,10,true)"/>
		%%display_value%%
		%%value_hidden%%
		<td class="main info_bold">%%values_count%%</td>
	</td>
</tr>

update_action: <input type="submit" name="reload" value="Apply">
rows_number:100;	
$$INCLUDE nav_inc.al$$

body:
<div id="hAJAX" style="display: none;"></div>
<script type="text/javascript">
<!--

function makeQuery(event,feature_id,row_value,sessid,result_id,self,limit,doChangePos)\{
	
	if(doChangePos)\{
		if (!document.all) \{
			document.getElementById('the_overlay').style.top=event.pageY+'px';
			document.getElementById('the_overlay').style.left=event.pageX+'px';
		\}
		else\{//IE
			if(document.documentElement.scrollTop)\{
				scrollTop=document.documentElement.scrollTop;
				scrollLeft=document.documentElement.scrollLeft;
			\}else\{
				scrollTop=document.body.scrollTop;
				scrollLeft=document.body.scrollLeft;				
			\}
			document.getElementById('the_overlay').style.top=(event.clientY + scrollTop)+'px';
			document.getElementById('the_overlay').style.left=(event.clientX + scrollLeft)+'px';
		\}
	\}else\{
		document.getElementById('the_overlay').style.display = 'none'; //redraw
	\}
	document.getElementById('the_overlay').style.display = 'inline';
	document.getElementById(result_id).innerHTML = '';
	call('get_products_by_feature_value','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=products_by_feature_value_ajax.html;feature_id='+feature_id+';feature_value='+row_value+';limit='+limit);
\}

function openProductPage(product_id,sessid)\{
	window.open('%%base_url%%;product_id='+product_id+';cproduct_id='+product_id+';tmpl=product_details.html');	
\}

//initGetMouseClickCoor();
var h1 = '22px';
	var h3 = '102px';
	var lastid = '';	
	function focus_textarea(id,lastid) \{
	  document.getElementById(lastid).style.height = h1;
	  //document.getElementById(lastid).style.overflow = 'hidden';
		document.getElementById(id).style.height = h3;
		//document.getElementById(id).style.overflow = 'auto';
	  return id;
	\}
	
// -->
</script>


<h3>Entered values & sample products</h3>

<a href="%%base_url%%;feature_id=%%feature_id%%;tmpl=feature_utilizing_products_categories.html;" target="_blank">Feature utilizing products & categories</a>

<!-- overlayed baloon start -->
<table class="feature_products_overlay" id="the_overlay" cellpadding="0" cellspacing="0" onclick="return false;">
	<tr>
		<td class="overlay_corner overlay_border_v_1" style="background-image:url('/img/overlay/baloon11.gif');"></td> 
		<td class="overlay_border_v_1" style="background-image: url('/img/overlay/baloon13.gif'); background-repeat: repeat-x;">
			<img alt="" src="/img/overlay/baloon12.gif" style="vertical-align: bottom;">
		</td>
		<td class="overlay_corner overlay_border_v_1" style="background-image: url('/img/overlay/baloon14.gif');"></td>
	</tr>
	<tr>
		<td class="overlay_border_v" style="background-image: url('/img/overlay/baloon21.gif');"></td>
		<td>
			<div class="close_cross" onclick="document.getElementById('the_overlay').style.display='none';">x</div>
			<div id="ajax_result"></div>
		</td>
		<td class="overlay_border_v" style="background-image: url('/img/overlay/baloon24.gif');"></td>
	</tr>
	<tr>
		<td class="overlay_corner" style="background-image: url('/img/overlay/baloon31.gif');"></td>
		<td class="overlay_border_h" style="background-image: url('/img/overlay/baloon3_23.gif');"></td>
		<td class="overlay_corner" style="background-image: url('/img/overlay/baloon34.gif');"></td>
	</tr>
</table>
<!-- overlayed baloon end -->
<!-- values begin -->
<form method=post>
	<input type=hidden name=atom_name value="feature_values">
	<input type=hidden name=sessid value="%%sessid%%">
	<input type=hidden name=feature_id value="%%feature_id%%">
	<input type=hidden name=tmpl_if_success_cmd value="features.html">
	<input type=hidden name=tmpl value="feature_values.html">
	<input type=hidden name=command value="create_mapping">
	$$INCLUDE nav_bar2.al$$
	<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td style="padding-top:10px">
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
					<tr>
						<td>
							
							<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
								<tr>
									<th class="main info_header">Value</th>
									<th class="main info_header">New Value</th>
									<th class="main info_header">Mapping</th>
									<th class="main info_header">Usage</th>
								</tr>
								
								%%feature_val_rows%%
								
							</table>
							
						</td>
					</tr>
				</table>
				
			</td>
		</tr>
	</table>
	$$INCLUDE nav_bar2.al$$
	<center>
		<input type=checkbox checked name="maintain_mapping" value=1> Maintain mapping
		<input type=checkbox name="make_dropdown" value=1> Make dropdown<br>
		%%update_action%%
	</center>
</form>
<!-- values end -->

}

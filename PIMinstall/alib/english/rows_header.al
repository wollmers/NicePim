{
name: rows_header;

begin_script:
<script type="text/javascript">
<!--
function white_bg(suffix,langid) \{
	for (var i=1; 1; i++) \{
	if (document.getElementById(suffix+'_'+i)) \{
	if (i!=langid) \{
	document.getElementById(suffix+'_'+i).style.display='none';
	document.getElementById(suffix+'_'+i+'_tab').style.backgroundColor='white';
	\}
	\}
	else \{
	document.getElementById(suffix+'_'+langid).style.display='block';
	document.getElementById(suffix+'_'+langid+'_tab').style.backgroundColor='#AADDFF';
	break;
	\}
	\}
\}

function expand_bg(suffix) \{
	for (var i=1; 1; i++) \{
	if (document.getElementById(suffix+'_'+i)) \{
	document.getElementById(suffix+'_'+i).style.display='block';
	\}
	else break;
	\}
\}
//-->
</script>

expand: <div style="padding: 2px; margin: 0 2px 1px 0; float: left; background-color: white;"><a onClick="javascript:expand_bg('%%suffix%%');">expand</a></div>

body:
<tr>
	<td class="main info_bold" colspan="2">
		<table class="tabs" cellspacing="1" cellpadding="2">
			<tr>
				<td>
					%%expand%%%%header%%<div style="clear: both;"></div>
				<td>
			</tr>
		</table>
	</td>
</tr>

<tr>
	<td class="main info_bold">%%rows%%</td>
</tr>

}

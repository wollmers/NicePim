{
name: product_html_email;
class: html;

body:
<html>
<head>
<title>%%pname%%</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK href="http://prf.icecat.biz/prf/css/takeitnow.css" rel=stylesheet type=text/css>
<script>%%script%%</script>
</head>
 <body bgcolor="#FFFFFF">
 <table border=0 cellpadding=0 cellspacing=0 bgcolor='#FFFFFF' width=740 align=center ><tr><td>
 <table border=0 cellpadding=0 cellspacing=0 bgcolor='#FFFFFF'><tr><td class="bigtitle"><img src='%%base_url%%/img/big_arrow.gif'>&nbsp;%%pname%%</td></tr></table>
 <br>
 <table  border=0 cellpadding=2 cellspacing=1 bgcolor='#FFFFFF'>
 <tr valign='top'>
	<td>
	 <table  border=0 cellpadding=0 cellspacing=1 bgcolor='#CCCCCC'>
		<tr><td valign=top bgcolor=>%%ppic%%</td></tr>
	 </table>
	</td>
	<td valign=top class="mainbold">%%sname%%<br>%%prod_id%%<br><p>%%cname%%<p>%%pdf_url%%</td>
 </tr>
 </table>
 <br>
 <table border=0 cellpadding=2 cellspacing=1 width=740 align=center bgcolor="#ffffff">
 %%description%%
 </table>
 <br>
 <table border=0 cellpadding=2 cellspacing=1 width=740 align=center bgcolor="#ffffff">
 %%warranty_info%%
 </table>
 <br>
 <table border=0 cellpadding=2 cellspacing=1 width=740 align=center bgcolor="#ffffff">
	%%features%%
 </table>
 <br><br>
 %%bundled_head%%
 <table border=0 cellpadding=2 cellspacing=1 width=740 align=center  bgcolor="#ffffff">
	%%bundled%%
 </table>
 <br>
 %%related_head%%
 <table border=0 cellpadding=2 cellspacing=1 width=740 align=center  bgcolor="#ffffff">
	%%related%%
 </table>
 <tr><td><br>
 <table border=0 cellpadding=0 cellspacing=3 width=400 align=right>
	<tr valign=bottom>
	 <td align=center>
	 <form method=post action='%%base_url%%/feedback/redirect.cgi'>
		<input type=submit class='way' name='publish_product' value='%%accept%%'>
		<input type=hidden name=key value='%%key_publish%%'>
		<input type=hidden name=user_id value='%%suserid%%'>
	 </form>
	 </td>
	 <td align=center>
	 <form method=post action='%%base_url%%/feedback/redirect.cgi'>
		<input type=submit class='way' name='edit_product' value='%%edit_product%%'>
		<input type=hidden name=key value='%%key_edit%%'>
	 </form>
	 </td>
	 <td align=center>
	 <form method=post action='%%base_url%%/feedback/redirect.cgi'>
		<input type=submit class='way' name='send_product_complaint' value='%%send_complaint%%'>
		<input type=hidden name=key value='%%key_send_complaint%%'>
	 </form>
	 </td>
	</tr>
	<tr valign=middle>
	 <td align=center class=mainboldlight>
		<a href="%%base_url%%/feedback/redirect.cgi?key=%%key_publish%%" class='mainbold'>%%accept%%</a>&nbsp;&nbsp;
 	 </td>
	 <td align=center class=mainboldlight>
		<a href="%%base_url%%/feedback/redirect.cgi?key=%%key_edit%%" class='mainbold'>%%edit_product%%</a>&nbsp;&nbsp;
 	 </td>
	 <td align=center class=mainboldlight>
		<a href="%%base_url%%/feedback/redirect.cgi?key=%%key_send_complaint%%" class='mainbold'>%%send_complaint%%</a>
		&nbsp;&nbsp;
 	 </td>
	</tr>
 </talbe>
 </form>
 </table>
  </td></tr></table>

 </body>
</html>
}

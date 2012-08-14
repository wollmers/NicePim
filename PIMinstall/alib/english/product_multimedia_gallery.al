{
name: product_multimedia_gallery;

delete_picture_value:Delete picture;

gallery_pic_format:
<td  class="main info_bold" valign="bottom">
	<table cellpadding="3" cellspacing="1" bgcolor="white" border="0" valign="bottom">
		<tr>
			<td class="main info_bold">
				<img src="%%value%%" id="%%id%%" border="1" hspace="0" vspace="0" style="cursor: hand;" onClick='javascript:\{document.gallery_form.gallery_pic.value = document.gallery_form.pic_src_%%id%%.value; document.gallery_form.image.src = this.src; document.gallery_form.gallery_pic.pic_id = this.id;\}'>
			</td>
		</tr>
		<tr>
			<td class="main info_bold" align="center" height="10%" valign="bottom">
				%%pic_size%%
			</td>
		</tr>
	</table>
</td>

<input type="hidden" name="pic_src_%%id%%" value="%%pic_src%%">

body:

<script type="text/javascript">
<!--
 function show_details(id1, id2)\{
   var description = document.getElementById(id1);
  if(id2)\{
     var image = document.getElementById(id2);
  \}
   if (description.style.display != 'block') \{
     description.style.display = 'block';
     if(id2)\{image.src = '../../img/minus.gif'\};
  \} else \{
     description.style.display = 'none';
     if(id2)\{image.src = '../../img/plus.gif'\};
  \}
     return false;
  \}

 var n=1;
 function addone()\{
   if(++n<=15){
     document.getElementById('f'+n).style.display='block';
   \}else\{
     alert('Too much. upload these files first, please');
     n--;
   \}
   document.getElementById('quantity').value=n;  document.getElementById('quantity1').value=n;
 \}
 function delone()\{
   if(n>1)\{
     document.getElementById('f'+n).style.display='none';
     n--;
   \}else\{
     alert('What are you doing?');
   \}
   document.getElementById('quantity').value=n;  document.getElementById('quantity1').value=n;
 \}
// -->
</script>

<br />

<form name="gallery_form" method="post" enctype="multipart/form-data">
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr bgcolor="#99CCFF">
			<th class="main info_header" width="100%" colspan="3"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Gallery</b></th>
		</tr>
	</table>
	<table class="maintxt" cellpadding="3" cellspacing="1"  border="0">
		%%gallery_pics%%
	</table>
	<table width="100%" class="maintxt" cellpadding="3" cellspacing="1" bgcolor="#EBEBEB">
		<tr>
			<td class="main info_bold" valign="top" align="center" bgcolor="white">~Picture URL~</td>
			<td class="main info_bold" valign="top" bgcolor="white"><input type="text" name="gallery_pic" value="%%gallery_pic%%" size="100" class="smallform">
				or<br>
				<input type="file" name="gallery_pic_filename" class="smallform">
			</td>
			<td class="main info_bold" valign="top" align="center" bgcolor="white">
				<img name="image" src="img/white_dot.bmp" border="0" hspace="0" vspace="0">
			</td>
		</tr>
		<tr>
			<td class="main info_bold" width="100%" colspan="3" bgcolor="white" align="right">
				<input type="submit" name="atom_submit" value="Add picture" class="smallform">
				<input type="submit" name="atom_submit" value="Delete picture" class="smallform">
				<a href="#rel" onclick='show_details("related",0)'>Add batch (urls)</a><br>
				<a href="#rel" onclick='show_details("related1",0)'>Add batch (local)</a>
			</td>
		</tr>
	</table>
	
  <input type="hidden" name="atom_name" value="product_multimedia_gallery">
  <input type="hidden" name="sessid" value="%%sessid%%">
  <input type="hidden" name="tmpl_if_success_cmd" value="product_multimedia.html">
  <input type="hidden" name="tmpl" value="product_multimedia.html">
  <input type="hidden" name="product_id" value="%%product_id%%">
  <input type="hidden" name="pic_id" value="">
  <input type="hidden" name="command" value="get_gallery_pic,store_pics_origin_gallery_update,add2editors_journal">
  <input type="hidden" name="precommand" value="store_pics_origin_gallery">
</form>

<!-- gallery (urls) -->
<div id="related" style="display: none;">
	<form method="post">
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td class="main info_bold" align="center">
					<textarea cols="60" rows="10" name="related_batch"></textarea>
				</td>
			</tr>
			<tr>
				<td class="main info_bold" align="center">
					<input type="submit" name="add_related_batch" value="Add batch">
					<input type="hidden" name="atom_name" value="product_multimedia_gallery">
					<input type="hidden" name="sessid" value="%%sessid%%">
					<input type="hidden" name="tmpl_if_success_cmd" value="product_multimedia.html">
					<input type="hidden" name="tmpl" value="product_multimedia.html">
					<input type="hidden" name="product_id" value="%%product_id%%">
					<input type="hidden" name="command" value="add_related_batch_p">
				</td>
			</tr>
		</table>
	</form>
</div>

<!-- gallery (local) -->
<div id="related1" style="display: none;">
	<form name="gallery_batch" method="post" enctype="multipart/form-data">
		<table width="100%">
			<tr>
				<td class="main info_bold" align="center">
					<table border="0">
						<tr>
							<td colspan="2">
								<input size="80" name="gallery_pic_filename1" id="f1" type="file" style="display:block;" class="smallform">
								<input size="80" name="gallery_pic_filename2"  id="f2" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename3"  id="f3" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename4"  id="f4" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename5"  id="f5" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename6"  id="f6" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename7"  id="f7" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename8"  id="f8" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename9"  id="f9" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename10"  id="f10" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename11"  id="f11" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename12"  id="f12" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename13"  id="f13" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename14"  id="f14" type="file" style="display: none;" class="smallform">
								<input size="80" name="gallery_pic_filename15"  id="f15" type="file" style="display: none;" class="smallform">
							</td>
						</tr>
						<tr>
							<td colspan="2"></td>
						</tr>
						<tr>
							<td align="right">
								<table><tr><td><input type="button" onclick="delone();" value="<<< less" class="smallform">
								<td><input type="button" value="1" id="quantity">
								<td><input type="hidden" value="1" name="quantity" id="quantity1">
								<input type="button" onclick="addone();" value="more >>>" class="smallform"></table>
							</td>
						</tr>
						<tr>
							<td colspan="3" align="center">
								<input type="submit" name="add_related_batch" value="Add batch">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		
		<input type="hidden" name="atom_name" value="product_multimedia_gallery">
		<input type="hidden" name="sessid" value="%%sessid%%">
		<input type="hidden" name="tmpl_if_success_cmd" value="product_multimedia.html">
		<input type="hidden" name="tmpl" value="product_multimedia.html">
		<input type="hidden" name="product_id" value="%%product_id%%">
		<input type="hidden" name="command" value="add_related_batch_p">
		
	</form>
</div>

}

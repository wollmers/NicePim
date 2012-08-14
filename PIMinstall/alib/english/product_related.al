{
name: product_related;

wrong_related: <span style="color: red;">bad product related code</span>;
ok_related: <span style="color: green; font-weight: bold;">ok</span>;
ok_in_process_related: <span style="color: green; font-weight: bold;">ok&nbsp;(in process)</span>;
ok_queued_related: <span style="color: green; font-weight: bold;">ok&nbsp;(queued)</span>;
ok_already_have: <span style="color: green; font-weight: bold;">already&nbsp;present</span>;
related_string: <tr><td class="main info_bold"><span style="color: #444444;">&nbsp;%%code%%</span></td></tr>;
related_string_colspan2: <tr><td colspan="2" class="main info_bold">%%content%%</td></tr>;

body: 

<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-top:10px">
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff" align="center">
				<tr>
					<td>
						
						<table border="0" cellpadding="2" cellspacing="1" width="100%" align="center">
							%%related_report%%
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
						
						<table border="0" cellpadding="3" cellspacing="1" width="100%" align="center">
							<tr>
								<td class="main info_bold" colspan="3">
									<form method="post">
										<span class="linksubmit" onClick="javascript: document.getElementById('add_batch').style.display = ''; document.getElementById('add_batch_button').style.display = 'none';" id="add_batch_button">Add relations</span>
										<div style="text-align: center; display: none;" id="add_batch">
											<textarea cols="60" rows="7" name="related_batch"></textarea>
											<br />
											<input type="hidden" name="atom_name" value="product_related">
											<input type="hidden" name="sessid" value="%%sessid%%">
											<input type="hidden" name="tmpl_if_success_cmd" value="product_details.html">
											<input type="hidden" name="tmpl" value="product_details.html">
											<input type="hidden" name="product_id" value="%%product_id%%">
											<input type="hidden" name="command" value="add_related_batch,product2vendor_notification_queue,add2editors_journal">
											
											<input type="submit" name="add_related_batch" value="Add batch">
										</div>
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

<br />

<div id="product_related" style="text-align: center;">
	The product has <a id="a_product_related_ajax" class="linksubmit" onClick="document.getElementById('product_related').innerHTML='<img src=\'./img/ajax-loader.gif\' style=\'padding: 2px;\' />';call('get_product_related','tag_id=product_related;foo=bar','sessid=%%sessid%%;tmpl=product_related_ajax.html;product_id=%%product_id%%');">%%related_count%%</a> relations.
</div>

<script type="text/javascript">
<!--

var obj = document.getElementById('a_product_related_ajax');

if (%%related_count%% < 1) \{
	obj.onclick = false;
	obj.className = '';
\}

// -->
</script>

}

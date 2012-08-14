{
name: price_lists;

pricelists_row:

<tr>
	<td class="main info_bold"><a href="#" id="distri%%no%%" onclick="gogogo(%%no%%)">%%distributor%%</a><input type="hidden" id="code%%no%%" value="%%d_code%%" /></td>
	<td class="main info_bold">%%pl_url%%</td>
	<td class="main info_bold">%%pl_format%%</td>
	<td class="main info_bold">%%modified%%</td>
	<td class="main info_bold">%%active%%</td>
	<td class="main info_bold">%%language%%<input type="hidden" id="lang%%no%%" value="%%langid%%" /></td>
</tr>
<tr>
	<!-- td><input type="button" id="show%%no%%" name="show%%no%%" value="last_cover" onclick="showc(%%no%%);" />
	<input type="button" id="hide%%no%%" name="hide%%no%%" value="hide" style="display:none;" onclick="hidec(%%no%%);" /></td -->
	<td colspan="6" id="cover%%no%%" style="display:">%%cover%%</td>
</tr>


body:
<script type"text/javascript" language="javascript">
	///////////////////// changing activity of pricelist //////////////
	function gogogo(num)\{
		var code = document.getElementById("code"+num).value;
		var lang = document.getElementById("lang"+num).value;
		var active = document.getElementById("active"+num).value;
                document.getElementById("tmpl").value = "price_reports.html";
                document.getElementById("atom_name").value = "price_reports.html";
                document.getElementById("tmpl_if_success_cmd").value = "price_reports.html";
//                document.getElementById("pricelists").target = "_blank";
		document.getElementById("distri_code").value = code;
		document.getElementById("langid").value = lang;
		document.getElementById("active").value = active;
                document.getElementById("pricelists").action = "%%base_url%%;tmpl=price_reports.html";
		document.getElementById("pricelists").submit();
		document.getElementById("tmpl").value = "price_lists.html";
                document.getElementById("atom_name").value = "price_lists.html";
                document.getElementById("tmpl_if_success_cmd").value = "price_lists.html";
		document.getElementById("pricelists").action = "";
	\}
	/////////////////// show last coverage /////////////////////////
	function showc(no)\{
		document.getElementById("show"+no).style.display = 'none';
		document.getElementById("hide"+no).style.display = '';
		document.getElementById("cover"+no).style.display = '';
	\}
	////////////////// hide last coverage ///////////////////////////
	function hidec(no)\{
                document.getElementById("show"+no).style.display = '';
                document.getElementById("hide"+no).style.display = 'none';
                document.getElementById("cover"+no).style.display = 'none';
        \}
</script>
<form method="post" id="pricelists">
	<input type="hidden" name="sessid" value="%%sessid%%">
        <input type="hidden" id="tmpl" name="tmpl" value="price_lists.html">
        <input type="hidden" id="atom_name" name="atom_name" value="price_lists">
        <input type="hidden" id="tmpl_if_success_cmd" name="tmpl_if_success_cmd" value="price_lists.html">
        <table class="tbl-block" cellpadding=3>
		<tr>
			<th class="th-dark">Distribuor</th>
			<th class="th-norm">Pricelist url</th>
			<th class="th-dark">Pricelist format</th>
			<th class="th-norm">Last updated</th>
			<th class="th-dark">Is active</th>
			<th class="th-norm">Language</th>
		</tr>
		%%pricelists_rows%%
	<input type="hidden" name="distri_code" id="distri_code" value="" />
	<input type="hidden" name="langid" id="langid" value="" />
	<input type="hidden" name="active" id="active" value="" />
	</table>

</form>
}

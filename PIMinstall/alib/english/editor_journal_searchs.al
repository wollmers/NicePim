{
name: editor_journal_searchs;

submit_value: Search;
search_editor_dropdown_empty: Any editor;
search_supplier_dropdown_empty: Any brand;
search_distributor_dropdown_empty: Any distributor;

cat_div: ---;
any_cat: Any category;

body:
<br />

<form method=post>

	<table cellspacing=0 cellpadiing=0 border=0 width=100% class="search">
		<tr align=left>
			<td class="search" width=5%>From</td>
			<td nowrap>&nbsp;&nbsp; %%from_day%% %%from_month%% %%from_year%%</td>
			<td colspan=2>%%search_catid%%</td>
			<td colspan=1>%%search_distributor%% </td>
			<td class="search">
 				<div style="float: left;">%%search_isactive%%</div>
 				<div style="float: right; vertical-align:middle; width: 83%">on stock</div>
			</td>
		</tr>
		<tr align=left>
			<td class="search" width=5%>To</td>
			<td nowrap>%%to_day%% %%to_month%% %%to_year%%</td>
			<td>%%search_editor%%</td>
			<td>%%search_supplier%%</td>
			<td>
				<select name=search_changetype class=smallform>
					<option value=''>Any change type</option>
					<option value='product' %%selected1%%>Product</option>
					<option value='product_ean_codes' %%selected8%%>Product EAN code</option>
					<option value='product_feature' %%selected2%%>Product feature</option>
					<option value='product_description' %%selected3%%>Product description</option>
					<option value='product_bundled' %%selected4%%>Product bundled</option>
					<option value='product_related' %%selected5%%>Product related</option>
					<option value='product_gallery' %%selected6%%>Product gallery</option>
					<option value='product_multimedia_object' %%selected7%%>Multimedia object</option>
				</select>
			</td>
			<td><input type=text class=smallform name=search_prodid value='%%search_prodid%%' size=20></td>
		</tr>

		<tr>
			<td class="search" align="right" colspan="6">
				<input type=hidden name=atom_name value="editor_journal_searchs">
				<input type=hidden name=sessid value="%%sessid%%">
				<input type=hidden name=tmpl value="%%tmpl%%">
				<input type=hidden name=editor_id value="%%editor_id%%">
				<input type="hidden" name="reload" value="1"/>
				<input type="submit" style="width:76px;height:25px;padding:0;border:0;font-size:0%;color:transparent;background:transparent url(img/campaign_def/button_search.gif) no-repeat;" class="hover_button" name=new_search>
			</td>
		</tr>
	</table>
</form>

}

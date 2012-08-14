{
name: feed_coverage_summary;
body:
	<div style="text-align: center; margin-top: 10px" class="feed_caption">Coverage summary</div>
	<table align="center" style="border: 1px solid black;">
		<tr>
			<td class="main info_bold">Total count of products in datapack:</td>
			<td class="main info_bold">%%total_count%%</td>
		</tr>
		<tr>
			<td class="main info_bold">
					Deleted as invalid products:
			</td>
			<td class="main info_bold">
				%%invalid%% (%%invalid_pers%%)
			</td>			
		</tr>		
		<tr>
			<td class="main info_bold">
				Total count of existed products:
			</td>
			<td class="main info_bold">
				<a href="%%base_url%%;mi=products;tmpl=products.html;filter=table:%%coverage_cache_table%%">
					%%existed%% (%%existed_pers%%)
				</a>
			</td>
		</tr>
		<tr>
			<td class="main info_bold">
					Duplicates among existed:
			</td>
			<td class="main info_bold">
				%%duplicates%% (%%duplicates_pers%%)
			</td>			
		</tr>					
		<tr>
			<td class="main info_bold">Total count of absent products:</td>
			<td class="main info_bold">%%absent%% (%%absent_pers%%)</td>			
		</tr>
		<tr>
			<td class="main info_bold">			
				Total count of sponsored products:
			</td>
			<td class="main info_bold">
				<a href="%%base_url%%;mi=products;tmpl=products.html;filter=table:%%coverage_cache_table%%,is_sponsored:1">
					%%free%% (%%free_pers%%)
				</a>
			</td>
		</tr>
		<tr>
			<td class="main info_bold">
					Total count of described products:
			</td>
			<td class="main info_bold">
				<a href="%%base_url%%;mi=products;tmpl=products.html;filter=table:%%coverage_cache_table%%,is_described:1">
				%%described%% (%%described_pers%%)
				</a>
			</td>			
		</tr>
		<tr>
			<td class="main info_bold">
					Total count of active products:
			</td>
			<td class="main info_bold">
				<a href="%%base_url%%;mi=products;tmpl=products.html;filter=table:%%coverage_cache_table%%,is_active:1">
				%%onstocks%% (%%onstocks_pers%%)
				</a>
			</td>			
		</tr>
	</table>
}

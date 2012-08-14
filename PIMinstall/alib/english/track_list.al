{
name: track_list;
$$INCLUDE actions2.al$$
body:

<div align="left" style="text-align: center; margin-top: 5px">Name: <input type="text" name="name" value="%%name%%" /></div>
<div align="left" style="text-align: center; margin-top: 5px">~Client:~ <span style="color: red">*</span>%%client_id%%</div>

<div style="text-align: center; margin-top: 20px">		
		<table style="vertical-align: top; border: 1px gray;" align="center">
		 <caption class="feed_caption">Columns assignment</caption>
			<tr>
			<td>
			<table class="feed_config_colums">
				<tr>
					<td>EAN/UPC code <br/>(only needed if Brand + Partno are absent)<span class="red">*</span></td>
					<td><div>%%ean_col%%</div>
						<div style="text-align: right;">Add to list of EAN columns <input type="button" value="+" onclick="addEANcolumn(false)"></div>						
						<div style="text-align: right;">
							<div id="user_choiced_ean_cols" style=" background-color: white; margin-top: 5px; padding: 5px; border: 1px solid gray; text-align: left;"></div>
							<input type="hidden" name="ean_cols" id="feed_ean_cols_id" value="%%ean_cols%%"/>
						</div>
					</td>
				</tr>
				<tr>
					<td>Manufacturer brand name<span class="red">*</span></td>
					<td>%%brand_col%%</td>
				</tr>
				<tr>
					<td>Manufacturer part no (product code)<span class="red">*</span></td>
					<td>%%brand_prodid_col%%</td>
				</tr>
				
			</table>
			
			</td>
			<td>
			<table class="feed_config_colums">
				<tr>
					<td>Product's name</td>
					<td>%%name_col%%</td>
				</tr>			
				<tr>
					<td>Extended column #1: <input type="text" name="ext_col1_name" value="%%ext_col1_name%%" size="10"></td>
					<td>%%ext_col1%%</td>
				</tr>			
				<tr>
					<td>Extended column #2:<input type="text" name="ext_col2_name" value="%%ext_col2_name%%" size="10"></td>
					<td>%%ext_col2%%</td>
				</tr>			
				<tr>
					<td>Extended column #3:<input type="text" name="ext_col3_name" value="%%ext_col3_name%%" size="10"></td>
					<td>%%ext_col3%%</td>
				</tr>			
			

			</table>
			
			</td>
		</tr>
		</table>		 
		<input type="hidden" name="atom_name" value="track_list"/>
		<input type="hidden" name="mi" value="%%mi%%"/>
		<input type="hidden" name="track_list_id" value="%%track_list_id%%"/>
		<input type=hidden   name=tmpl_if_success_cmd value="track_lists.html"/>
		<br/><!--		
		%%update_action%%
		-->		
		 %%insert_action%%
		 
		<script type="text/javascript">
			var savers=document.getElementsByName('atom_submit');
			if(savers[0])\{
				savers[0].onclick=function () \{
					document.getElementById('feed_config_commands').value='add_tracklist_products';
				\};
			\}else\{
				var updaters=document.getElementsByName('atom_update');
				updaters[0].onclick=function () \{
						document.getElementById('feed_config_commands').value='add_tracklist_products';
				\};
			\}
		</script>
</div>
<br/>
<div style="text-align: center;">
	<input type="submit" value="Do coverage" onclick="set_cover_cmd()"/>
	<br/>
	%%coverage_summary%%
</div>
}

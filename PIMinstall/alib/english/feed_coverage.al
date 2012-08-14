{
name: feed_coverage;


report_type_custom_select_value_0: xls;
report_type_custom_select_text_0:  Excel;

report_type_custom_select_value_1: csv;
report_type_custom_select_text_1:  CSV;

link_lang_dropdown_empty_key: en;
link_lang_dropdown_empty: English;

body:

<div style="text-align: center; margin-top: 20px;">
	<table class="feed_config_colums" align="center"  style="vertical-align: top;">
		 <caption class="feed_caption">Columns assignment</caption>
				<tr>
					<td>EAN/UPC code <br/>(only needed if Brand + Partno are absent)<span class="red">*</span></td>
					<td><div style="text-align: right;">%%ean_col%%</div>
						<div style="text-align: right;">Add to list of EAN columns <input type="button" value="+" onclick="addEANcolumn(false)"></div>						
						<div style="text-align: right;">
							<div id="user_choiced_ean_cols" style=" background-color: white; margin-top: 5px; padding: 5px; border: 1px solid gray; text-align: left;">
							</div>
						</div>
					<div style="text-align: right; margin-top: 5px">%%ean_spliter_choice%%</div>
					<input type="hidden" name="feed_ean_cols" id="feed_ean_cols_id" value="%%feed_ean_cols%%"/>
					<!--<input type="button" value="aaa" onclick="alert(document.getElementById('feed_ean_cols_id').value)">						
					-->
					</td>
					<td style="vertical-align: top;">Manufacturer brand name<span class="red">*</span></td>
					<td style="vertical-align: top;">%%brand_col%%</td>
					<td style="vertical-align: top;">Manufacturer part no (product code)<span class="red">*</span></td>
					<td style="vertical-align: top;">%%brand_prodid_col%%</td>					
				</tr> 
			</table>
	<input type="hidden" name="atom_name" value="feed_coverage"/>
	<input type="hidden" name="atom_update"  id="atom_update_hidden" value=""/>
	<input type="hidden" name="mi" value="%%mi%%"/>
	<input type="hidden" name="coverage_cache_table" value="%%coverage_cache_table%%"/>
	<br/>
	<input type="submit" onclick="show_coverage_report()" value="Show coverage"/>
	and send details to address <input type="text" name="user_email" value="%%user_email%%" size="30"/> use as attachments %%report_type%% and language for links %%link_lang%%	
	%%summary_html%%
</div>	
}

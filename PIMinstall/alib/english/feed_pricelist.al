{
name: feed_pricelist;
$$INCLUDE actions2.al$$
body:

<div style="text-align: center; margin-top: 20px">
		<div style="margin-top: 10px"><span>Distributor: </span><span class="feed_caption">%%name%% &nbsp;(%%code%%) </span> Is enabled %%active%%</div>
		<table style="vertical-align: top;" align="center">
		 <caption class="feed_caption">Columns assignment</caption>
			<tr>
			<td>
			<table class="feed_config_colums">
				<tr>
					<td>EAN/UPC code <br/>(only needed if Brand + Partno are absent)<span class="red">*</span></td>
					<td>%%ean_col%%</td></tr>
				<tr>
					<td>Manufacturer brand name<span class="red">*</span></td>
					<td>%%brand_col%%</td>
				</tr>
				<tr>
					<td>Manufacturer part no (product code)<span class="red">*</span></td>
					<td>%%brand_prodid_col%%</td>
				</tr>
				<tr>
					<td>Price incl. VAT</td>
					<td>%%price_vat_col%%</td>
				</tr>
				<tr>
					<td>Country (disrtibutor distinguish postfix)</td>
					<td>%%country_col%%</td>
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
					<td>Price excl. VAT</td>
					<td>%%price_novat_col%%</td>
				</tr>
				<tr>
					<td>Products's description</td>
					<td>%%desc_col%%</td>
				</tr>
				<tr>
					<td>Stock quantity (numerical)</td>
					<td>%%stock_col%%</td>
				</tr>
				<tr>
					<td>Distributor's partcode</td>
					<td>%%distri_prodid_col%%</td>
				</tr>
				<tr>
					<td>Product's category</td>
					<td>%%category_col%%</td>
				</tr>
			</table>
			</td>
		</tr>
		</table>
		<input type="hidden" name="atom_name" value="feed_pricelist"/>
		<input type="hidden" name="mi" value="%%mi%%"/>
		<input type="hidden" name="group_code" value="%%group_code%%"/>
		<input type="hidden" name="code" value="%%group_code%%"/>
		<input type="hidden" name="name" value="%%name%%"/>
		<input type="hidden" name="distributor_pl_id" value="%%distributor_pl_id%%"/>
		<input type="hidden" name="distributor_id" value="%%distributor_id%%"/>
		<input type=hidden name=tmpl_if_success_cmd value="distributors.html"/>
				
		<br/>		
		%%update_action%% %%insert_action%%
		%%link_to_coverage%%
		
		<script type="text/javascript">
			document.getElementById('manualy_download_tr').style.display='none';
			
		</script>
</div>

}

{
name: feed_pricelist;
class: new;
insert_action: <input type="submit" name="atom_submit" value="Add">
update_action: <input type="submit" name="atom_update" value="Save">


body:

<div style="text-align: center; margin-top: 20px">
		
		<table style="vertical-align: top;" align="center">
		 <caption class="feed_caption">Columns assignment <span class="feed_config_colums">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Is enabled %%active%%</span></caption>
			<tr>
			<td>
			<table class="feed_config_colums">
				<tr>
					<td>EAN/UPC code <br/>(only needed if Brand + Partno are absent)<span class="red">*</span></td>
					<td>%%ean_col%%</td></tr>
				<tr>
					<td>Manufacturer brand name<span class="red">*</span></td>
					<td>%%brand_col%%</td>
				</tr>
				<tr>
					<td>Manufacturer part no (product code)<span class="red">*</span></td>
					<td>%%brand_prodid_col%%</td>
				</tr>
				<tr>
					<td>Price incl. VAT</td>
					<td>%%price_vat_col%%</td>
				</tr>
				<tr>
					<td>Country (disrtibutor distinguish postfix)</td>
					<td>%%country_col%%</td>
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
					<td>Price excl. VAT</td>
					<td>%%price_novat_col%%</td>
				</tr>
				<tr>
					<td>Products's description</td>
					<td>%%desc_col%%</td>
				</tr>
				<tr>
					<td>Stock quantity (numerical)</td>
					<td>%%stock_col%%</td>
				</tr>
				<tr>
					<td>Distributor's partcode</td>
					<td>%%distri_prodid_col%%</td>
				</tr>
				<tr>
					<td>Product's category</td>
					<td>%%category_col%%</td>
				</tr>
			</table>
			</td>
		</tr>
		</table>
		<input type="hidden" name="mi" value="%%mi%%"/>
		<input type="hidden" name="distributor_pl_id" value="%%distributor_pl_id%%"/>
		
		<input type="hidden" name="atom_name" value="feed_pricelist"/>
		<input type="hidden" name="distributor_id" value="%%distributor_id%%"/>
		<input type="hidden" name="group_code" id="pricelist_group_code" value="%%group_code%%"/>
		<input type=hidden name=tmpl_if_success_cmd value="distributors.html"/>
		<br/>
		%%update_action%% %%insert_action%%
		
		<script type="text/javascript">
			document.getElementById('manualy_download_tr').style.display='none';
		</script>
</div>

}

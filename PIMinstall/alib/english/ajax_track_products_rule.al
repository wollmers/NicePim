{
name: ajax_track_products_rule;
submit_button_ok: <input type="button" value="OK" onclick="set_rule_prod_id('%%sessid%%',%%track_product_id%%,%%track_list_id%%,'%%main_tmpl%%')"/>
submit_button_err: <span style="color: red;">This product is parked </span>

body:
<div style="background-color: #D4EAF1; height: 100%">
	<div style="height: 100%">
		<table style="vertical-align: middle" cellpadding="0" cellspacing="0">
		<caption>Supplier\: <b>%%supplier_name%%</b></caption>
		<tr>
			<td>This supplier <b>%%supplier_name%%</b> should be changed to:</td>			
			<td colspan="2">%%supplier_id%%</td>
		</tr>
		<tr><td colspan="3"><br/></tr>
		<tr>
			<td style="text-align: right">incorrect code: %%feed_prod_id%%</td>
			<td>=</td>
			<td><input type="text" size="15" id="ajax_rule_prod_id" value="%%rule_prod_id_html%%"/>-correct code</td>
		</tr>
		<tr>
			<td style="text-align: right;">incorrect code: <input type="text" size="15" id="ajax_rule_prod_id_rev" value="%%rule_prod_id_rev%%"/></td>
			<td>=</td>
			<td>correct code - %%feed_prod_id%%</td>
		</tr>
		</table>
		%%button_ok%%
		<input type="hidden" id="ajax_supplier_id_raw" value="%%supplier_id_raw%%">
		<input type="hidden" id="ajax_feed_prod_id" value="%%feed_prod_id%%">
	</div>
</div>
}

{
name: ajax_track_products_rule;
class: return;

body:
	%%is_rule_confirmed_html%%	
	<table cellpadding="0" cellspacing="0" id="%%track_product_id%%_changer_ajaxed"><tr>%%changer%%</tr></table>	
}

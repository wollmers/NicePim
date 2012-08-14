{
name: ajax_track_products_parked;

park_cause_radio_text_1: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />Incorrect code
						 <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >Incorrect code.</span></td>;
park_cause_radio_value_1: prod_id;

park_cause_radio_text_2: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />No info available
					    <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >No info available.</span></td>;
park_cause_radio_value_2: noinfo;

park_cause_radio_text_3: <td><input type="radio" %%checked%% name="%%field%%" value="%%value%%" onclick="add2remark(this)" />Other
						 <span name="strForRemarks" id="strForRemarks_%%value%%" style="display: none;" >Other.</span></td>;
park_cause_radio_value_3: other;

park_cause_radio_text_4: <td><input type="radio" %%checked%% name="%%field%%" value="" onclick="add2remark(this)" />Do not park</td>;
park_cause_radio_value_4: ;

body:
<div style="background-color: #D4EAF1; height: 100%">
	<div>
		Park the product\:<br/>
			%%park_cause%%
	</div>
	<div style="height: 100%">
		<textarea  cols="20" rows="5" id="is_parked_remarks" name="remarks">%%remarks%%</textarea><br/>
		<input type="button" value="confirm" onclick="confirm_call_park('%%sessid%%','%%track_product_id%%')"/>
	</div>
</div>
}

{
name: ajax_track_products_parked;
class: return;

body:
%%is_parked_html%%
<table cellpadding="0" cellspacing="0" id="%%track_product_id%%_changer_ajaxed"><tr>%%changer%%</tr></table>
}

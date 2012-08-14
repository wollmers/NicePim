<div>
	<input type="hidden" name="%%name%%_old" id="%%name%%_old" value="%%value_id%%" />
	<input type="hidden" name="%%name%%" id="%%name%%" value="%%value_id%%" />
	<table cellspacing="0" cellpadding="0" border="0">
		<tr>
			<td>
				<input name="%%name%%_name" id="%%name%%_name" autocomplete="off" 
				onkeyup="
				    javascript:smartDropdownCheckValue(
				        '%%name%%',
				        %%product_id%%+0,
				        '%%sessid%%',
				        0,
				        '%%allow_pcat_choice%%',
				        '%%add_empty%%',
				        %%add_empty_value%%+0,
				        'get_categories_list_by_like_name'
				    );   				    
				" 
				    
				value="%%value%%" type="text" %%attrs%% 
			    />
			</td>
			<td style="width: 16px;">
				<div style="height: 18px; width: 16px; border: 1px solid black; background: white url(img/dropdown_arrow.gif) center; background-repeat: no-repeat;" 
				onmousedown="
				    javascript:smartDropdownCheckValue(
				        '%%name%%',
				        %%product_id%%+0,
				        '%%sessid%%',
				        1,
				        '%%allow_pcat_choice%%',
				        '%%add_empty%%',
				        %%add_empty_value%%+0,
				        'get_categories_list_by_like_name'
				    ); 				    
				" 
				    
				onmouseover="javascript: this.style.borderColor = '#1553A4';" onmouseout="javascript: this.style.borderColor = 'black';"></div>
			</td>
		</tr>
	</table>
	<div class="scroll" id="%%name%%_scroll" style="display: none;">
		<div class="scrolled" id="%%name%%_scrolled">
		</div>
	</div>
	<input type="hidden" name="%%name%%_selected" id="%%name%%_selected" value="0" />
	<input type="hidden" name="%%name%%_value_selected" id="%%name%%_value_selected" value="" />
</div>

<script type="text/javascript">
<!--
	 function close%%name%%SmartDropdown() {
		document.getElementById('%%name%%_scroll').style.display = 'none';
	 }

	 function item%%name%%MouseOver(i,id,value) {
		 var name = document.getElementById('%%name%%_item_'+i).className;
		document.getElementById('%%name%%_item_'+i).className = name+'_sel';
		document.getElementById('%%name%%_selected').value = id;
		document.getElementById('%%name%%_value_selected').value = value;
	 }

	 function item%%name%%MouseOut(i,id,value) {
		 var name = document.getElementById('%%name%%_item_'+i).className;
		 document.getElementById('%%name%%_item_'+i).className = name.replace('_sel','');
		if (document.getElementById('%%name%%_selected').value == id) {
			document.getElementById('%%name%%_selected').value = 0;
			document.getElementById('%%name%%_value_selected').value = '';
		}
	 }

function addEvent(obj,name,func) {
		if (obj.addEventListener) {
				obj.addEventListener(name, func, false);
		}
		else if (obj.attachEvent) {
				obj.attachEvent('on'+name, func);
		}
		else {
				throw 'Error';
		}
}

addEvent(document.getElementById('body'),'click',close%%name%%SmartDropdown);

// -->
</script>

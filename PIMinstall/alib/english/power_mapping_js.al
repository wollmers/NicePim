<script type="text/javascript">
<!--

%%initial_generic_operation_JavaScript_arrays%%

	function hideMove() \{
		for (var i=1;i<=document.getElementById('pattern_max_1').value;i++) \{
			document.getElementById('pattern_move_'+i).style.display="none";
		\}
	\}

	function hideAction() \{
		for (var i=1;i<=document.getElementById('pattern_max_1').value;i++) \{
			document.getElementById('pattern_action_'+i).style.display="none";
		\}
	\}

	function showMoveUpdate() \{
		document.getElementById('moveUpdate').style.display='inline';
	\}

	function doUp(n) \{
		if (n>1) \{
			m = n-1;
			// save in tmp
			order = document.getElementById('pattern_order_'+n).value;
			left = document.getElementById('pattern_left_'+n).value;
			right = document.getElementById('pattern_right_'+n).value;
			right_1 = document.getElementById('pattern_right_1_'+n).value;
			right_2 = document.getElementById('pattern_right_2_'+n).value;
			type = document.getElementById('pattern_type_'+n).value;
			value = document.getElementById('pattern_'+n).innerHTML;
			// m -> n
			document.getElementById('pattern_order_'+n).value = document.getElementById('pattern_order_'+m).value;
			document.getElementById('pattern_left_'+n).value = document.getElementById('pattern_left_'+m).value;
			document.getElementById('pattern_right_'+n).value = document.getElementById('pattern_right_'+m).value;
			document.getElementById('pattern_right_1_'+n).value = document.getElementById('pattern_right_1_'+m).value;
			document.getElementById('pattern_right_2_'+n).value = document.getElementById('pattern_right_2_'+m).value;
			document.getElementById('pattern_type_'+n).value = document.getElementById('pattern_type_'+m).value;
			document.getElementById('pattern_'+n).innerHTML = document.getElementById('pattern_'+m).innerHTML;

			document.getElementById('pattern_'+n).style.backgroundColor = '#DDFFDD';
			// restore to m
			document.getElementById('pattern_order_'+m).value = order;
			document.getElementById('pattern_left_'+m).value = left;
			document.getElementById('pattern_right_'+m).value = right;
			document.getElementById('pattern_right_1_'+m).value = right_1;
			document.getElementById('pattern_right_2_'+m).value = right_2;
			document.getElementById('pattern_type_'+m).value = type;
			document.getElementById('pattern_'+m).innerHTML = value;

			document.getElementById('pattern_'+m).style.backgroundColor = '#DDFFDD';
		\}
	\}

	function doDown(n) \{
		if (n<document.getElementById('pattern_max_1').value) \{
			m = n+1;
			// save in tmp
			order = document.getElementById('pattern_order_'+n).value;
			left = document.getElementById('pattern_left_'+n).value;
			right = document.getElementById('pattern_right_'+n).value;
			right_1 = document.getElementById('pattern_right_1_'+n).value;
			right_2 = document.getElementById('pattern_right_2_'+n).value;
			type = document.getElementById('pattern_type_'+n).value;
			value1 = document.getElementById('pattern_'+n).innerHTML;
			value2 = document.getElementById('pattern_'+n).innerText;
			// m -> n
			document.getElementById('pattern_order_'+n).value = document.getElementById('pattern_order_'+m).value;
			document.getElementById('pattern_left_'+n).value = document.getElementById('pattern_left_'+m).value;
			document.getElementById('pattern_right_'+n).value = document.getElementById('pattern_right_'+m).value;
			document.getElementById('pattern_right_1_'+n).value = document.getElementById('pattern_right_1_'+m).value;
			document.getElementById('pattern_right_2_'+n).value = document.getElementById('pattern_right_2_'+m).value;
			document.getElementById('pattern_type_'+n).value = document.getElementById('pattern_type_'+m).value;
			document.getElementById('pattern_'+n).innerHTML = document.getElementById('pattern_'+m).innerHTML;
			document.getElementById('pattern_'+n).innerText = document.getElementById('pattern_'+m).innerText;
			document.getElementById('pattern_'+n).style.backgroundColor = '#DDFFDD';
			// restore to m
			document.getElementById('pattern_order_'+m).value = order;
			document.getElementById('pattern_left_'+m).value = left;
			document.getElementById('pattern_right_'+m).value = right;
			document.getElementById('pattern_right_1_'+m).value = right_1;
			document.getElementById('pattern_right_2_'+m).value = right_2;
			document.getElementById('pattern_type_'+m).value = type;
			document.getElementById('pattern_'+m).innerHTML = value1;
			document.getElementById('pattern_'+m).innerText = value2;
			document.getElementById('pattern_'+m).style.backgroundColor = '#DDFFDD';
		\}	
	\}

	function patternEdit(n) \{
		// fill up all needed values
		for (var i=1;i<=document.getElementById('pattern_max_1').value;i++) \{
			document.getElementById('pattern_'+i).style.backgroundColor = "";
		\}

    type = document.getElementById('pattern_type_'+n).value;

		document.getElementById(type+'_id').value = document.getElementById('pattern_order_'+n).value;
		document.getElementById('pattern_'+n).style.backgroundColor = '#DDFFDD';

		if (type == 'g') \{
		  // form selection
			document.getElementById('left_select').value = document.getElementById('pattern_left_'+n).value;
			setGOParameterByGOCode('edit',document.getElementById('left_select').value);
			document.getElementById('right_variable_1').value = document.getElementById('pattern_right_1_'+n).value;
			document.getElementById('right_variable_2').value = document.getElementById('pattern_right_2_'+n).value;
		\}
		else \{
			document.getElementById('left_part').value = document.getElementById('pattern_left_'+n).value;
			document.getElementById('right_part').value = document.getElementById('pattern_right_'+n).value;
		\}
		// show specific update, g or p
		document.getElementById('pattern_g_edit').style.display = 'none';
		document.getElementById('pattern_p_edit').style.display = 'none';
		document.getElementById('pattern_g_add').style.display = 'none';
		document.getElementById('pattern_p_add').style.display = 'none';
		document.getElementById('pattern_p_add_link').style.display='inline';
		document.getElementById('pattern_g_add_link').style.display='inline';
		document.getElementById('pattern_'+type+'_edit').style.display = 'inline';
	\}

	function getOrderedList() \{
		document.getElementById('ordered_list').value = '';
		for (var i=1;i<=document.getElementById('pattern_max_1').value;i++) \{
			document.getElementById('ordered_list').value = document.getElementById('ordered_list').value + document.getElementById('pattern_order_'+i).value + ";";
		\}
	\}

	function setGOParameterByGOCode(obj,code) \{
		number = -1;
		for (i=0; i < go_codes.length; i++) \{
			if (go_codes[i] == code) \{
				number = i;
			\}
		\}
		if (number != -1) \{
			if (go_parameters[number] > 0) \{
				document.getElementById(obj+'GOParameters').style.display = 'inline';
				document.getElementById(obj+'GOParameter1').style.display = 'none';	
				document.getElementById(obj+'GOParameter2').style.display = 'none';	
				if (go_parameters[number] == 1) \{
					document.getElementById(obj+'GOParameter1').style.display = 'inline';	
				\}
				else \{
					if (go_parameters[number] == 2) \{
						document.getElementById(obj+'GOParameter1').style.display = 'inline';	
						document.getElementById(obj+'GOParameter2').style.display = 'inline';	
					\}
				\}
			\}
			else \{
				document.getElementById(obj+'GOParameters').style.display = 'none';
			\}
		\}
		else \{
			document.getElementById(obj+'GOParameters').style.display = 'none';
		\}
	\}

//-->
</script>

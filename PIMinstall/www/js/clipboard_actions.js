function delete_(values_select){
 if(values_select.options.selectedIndex != -1){
	values_select.options[values_select.options.selectedIndex] = null;
 }else{
	 alert('Please, pick up a item first');
 }
 return '';
 };

function delete_validation(form,name_txt,this_tmpl,ok_tmpl){
 if(form._delete.checked == 1){
	var where_to= confirm("Do you really want to delete "+name_txt+"?");
	if (where_to== true){
		form.tmpl_if_success_cmd.value= ok_tmpl;
	}else{
		form.tmpl_if_success_cmd.value = this_tmpl;
		form.tmpl.value = this_tmpl;
		form._delete.checked = 0;
		return false;
	}
 }
}

function set_ids(values_select,values_txt){
	for(var i=0; i<values_select.options.length;i++){
		values_txt.value+=values_select.options[i].value+',';
	}
	values_txt.value.substring(0,values_txt.value.length - 1);
}
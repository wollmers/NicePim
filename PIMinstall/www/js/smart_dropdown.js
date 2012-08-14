function smartDropdownCheckValue(
    name,
    p_id,
    sessid,
    all,
    allow_pcat_choice,
    add_empty,
    add_empty_value,
    ajax_func
) { // give the current value and ajax them
		var checkvalue = '';
		
		var edit = document.getElementById(name+'_name');
		
		// all = 1 - [V] - click
		// all = 0 - manual input
		if (all == '0') {
			checkvalue = escape(edit.value);
		}
		
		edit.style.backgroundPosition = '98% center';
		edit.style.backgroundRepeat = 'no-repeat';
		edit.style.backgroundImage = "url('img/ajax-loader.gif')";
//		p_id = p_id + 0;
		
        tmp1 = 'tag_id='+name+';value=' + checkvalue + ';foo=bar;field_name='+name+';allow_pcat_choice='+allow_pcat_choice+';add_empty='+add_empty+';add_empty_value='+add_empty_value; 
        tmp2 = 'sessid='+sessid+';tmpl=ajax_'+ajax_func+'.html;product_id='+p_id+';'+name+'='+document.getElementById(name+'_old').value;

        // get vcats
		call(ajax_func, tmp1, tmp2);
}

function smartDropdownSetValue(id,value,name) { // set the one value from the given list

        // id => catid
        // name => ...
        // value => categoty name string
        
		document.getElementById(name).value = id;
		document.getElementById(name+'_name').value = value.replace("&amp;","&");
		
		// alert('aa');
		
		if (1) {
    		get_family_do_next_request();
    	}

        // remake ajax request (reusage catid => vcats)
        tmp1 = tmp1.replace(/;value=.*?;foo=bar;/, ';value=' + id + ';foo=bar;');
        tmp1 = tmp1.replace(/;tag_id=.*?;/, ';tag_id=vcats_name;');
		tmp2 = tmp2.replace(/;tmpl=.*?html;/, ';tmpl=ajax_get_vcategories.html;');

        // product_detail page
		if (name == 'catid') {
		    dest_id = 'vcats_container_tmp';
		}
		// search atom for products
		if (name == 'search_catid') {
		    dest_id = 'vcats_container_tmp_search';
		}
		// group action for products
		if (name == 'search_category_list') {
		    dest_id = 'vcats_container_tmp_group_action';
		}
		
		document.getElementById(dest_id).innerHTML = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		document.getElementById(dest_id).innerText = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		
		document.getElementById(dest_id).style.backgroundPosition = '98% center';
		document.getElementById(dest_id).style.backgroundRepeat = 'no-repeat';
		document.getElementById(dest_id).style.backgroundImage = "url('img/ajax-loader.gif')";
		
		// get virtual categories
		call('get_vcategories', tmp1, tmp2);
}

function display_redundant_mappings(self) {
	if(self.innerHTML=='show mappings'){
		self.innerHTML='hide mappings';
		document.getElementById('redundant_mapings_id').style.display ='block';
	}else{
		self.innerHTML='show mappings';
		document.getElementById('redundant_mapings_id').style.display ='none';
	}
}

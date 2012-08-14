function ajax_response(response) {
		var id = response[0]; // get the hAJAX id
		hAJAX.erase(id); // erase link to AJAX request from hAJAX
		
		// alert(response);
		// document.getElementById('hAJAX').innerHTML += ' kill(' + id + ') ';
		
		var func = response[1]; // get the function name
		var tag_id = response[2]; // get our specific and weird parameter		
		//		var content = response[3]; // get content
		
		//		alert(response[1]+'\n'+response[2]+'\n'+response[3]);
		
		if (func == 'get_local_feature') {
				if (tag_id != 'id_feat_tab_id_0') {
						var tab = document.getElementById(tag_id);
						// var body = unescape(response[3]);
						// tab.innerHTML=Utf8.decode(body);
//						tab.innerText=response[3];
						tab.innerHTML=response[3];
				}
		}
		else if (func == 'get_supplier_edit') {
				var tab = document.getElementById(tag_id);
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
				if (typeof 'update_title' == 'function') {
					update_title();
				}
		}
		else if (func == 'get_supplier_family_edit') {
				var tab = document.getElementById(tag_id);
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
				//				if (document.getElementById('supplierfamily'+id).length <= 1) {
				//						document.getElementById('supplierfamily'+id).style.disabled = true;
				//				}
		}
		else if (func == 'get_category_edit') {
				var tab = document.getElementById(tag_id);
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
		}
		else if (func == 'get_feature_edit') {
				var tab = document.getElementById(tag_id);
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
		}
		else if (func == 'get_supplier_related_edit') {
				var tab = document.getElementById(tag_id);
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
		}
		else if (func == 'get_allowed_feature_value_report') {
				var tab = document.getElementById(tag_id);
				var result = response[3].substr(2,7);
				tab.style.backgroundColor = result;
				if (result == '#FFDDDD') {
						set_value(tag_id);
				}
				else {
						unset_value(tag_id);
				}
				change_update_active();
		}
		else if (func == 'get_current_mapping_processes') {
				var tab = document.getElementById(tag_id);
				tab.innerHTML=response[3];
		}
		else if (func == 'get_current_generate_report_processes') {
				var tab = document.getElementById(tag_id);
				tab.innerHTML=response[3];
		}
		else if (func == 'get_amount') {
				var tab = document.getElementById(tag_id);
				tab.innerHTML=response[3];
		}
		else if (func == 'get_product_related') {
				var tab = document.getElementById(tag_id);
				tab.innerHTML=response[3];
		}
		else if (func == 'get_products_by_feature_value') {
				var tab = document.getElementById(tag_id);
				tab.innerHTML=response[3];				
		}
		else if (func == 'get_categories_list_by_like_name') {
				var visibleRows = 16;
				var fontHeight = 16;

				document.getElementById(tag_id+'_name').style.backgroundImage = 'none';

				var tab = document.getElementById(tag_id+'_scroll');
				var tab2 = document.getElementById(tag_id+'_scrolled');
				var hght = tab.style.height;
				hght = hght.replace('px','');
				tab.style.display = '';
				// collect the number of rows
				var num = /<\!--\s\((\d+)\:(\d+)\)\s-->/.exec(response[3]);
				var num2 = num[1]; // numrows
				var a = num[2]; // activerow
				if (num[1] > visibleRows) {
						num2 = visibleRows;
				}
				num[1] *= fontHeight;
				num2 *= fontHeight;
				tab.style.height = num2 + 'px';
				tab2.innerHTML = response[3];
				
				var scrollToHeight = (a - (visibleRows / 2)) * fontHeight;

				scrollToHeight = (scrollToHeight < 0) ? 0 : scrollToHeight;
				scrollToHeight = scrollToHeight > (num[1] - hght) ? (num[1] - hght) : scrollToHeight;

				if (tab.scrollTo) {
						tab.scrollTo(0, scrollToHeight);
				}
				
		}
		else if (func == 'get_vcategories') {

		    // resp for catid selector
		    if (tag_id == 'catid') {
		        tab = document.getElementById('vcats_container_tmp');
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
				document.getElementById('vcats_container_tmp').style.backgroundImage = "";
		    } 
		    
		    // resp for search atom
		    if (tag_id == 'search_catid') {
		        tab = document.getElementById('vcats_container_tmp_search');
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
				document.getElementById('vcats_container_tmp_search').style.backgroundImage = "";
				
				document.getElementById('vcat_enable_all').value = "";
				document.getElementById('vcat_enable_list').value = "";
		    }
		    
		    // resp for group action page
		    if (tag_id == 'search_category_list') {
		        tab = document.getElementById('vcats_container_tmp_group_action');
//				tab.innerText=response[3];
				tab.innerHTML=response[3];
				document.getElementById('vcats_container_tmp_group_action').style.backgroundImage = "";
		    }
		}
		else if (func == 'get_track_products') {
			var tab = document.getElementById(tag_id);
			/*
			var ua = navigator.userAgent.toLowerCase(); 
			var IE=false; 
			IE = ua.indexOf('msie');
			*/			
			update_track_product_rows(response);
			document.getElementById('update_button_id').disabled=false;
			document.getElementById('ajax_call_status').value='finished';
			var date_obj = new Date();
			document.getElementById('ajax_call_finished').value=date_obj.getTime();
		}
		else if (func == 'park_track_product') {
			var tab = document.getElementById('ajax_track_products_'+tag_id+'_parked_return').parentNode;
			tab.innerHTML=response[3];

			var tr_container = document.getElementById(tag_id+'_');
			var tr_container_class=tr_container.getAttribute('class');
			tr_container_class=tr_container_class.replace(/(track_product_red|track_product_green)/, '');
			var call_result=document.getElementById('ajax_track_products_'+tag_id+'_parked_return');
			//alert(tr_container_class);
			//alert(response[3]+'      '+call_result.getAttribute('class'));
			tr_container.setAttribute('class',tr_container_class+' '+call_result.getAttribute('class'))
			
			var tb=tab.getElementsByTagName('table');
			var returned_changer=tb[0];
			if(returned_changer){
				var id=returned_changer.getAttribute('id');
				id=id.replace('_ajaxed','');
				document.getElementById(id).innerHTML='';
				var tds=returned_changer.getElementsByTagName('td');
				document.getElementById(id).innerHTML=tds[0].innerHTML;
				tab.removeChild(returned_changer);
			}

		}		
		else if (func == 'get_product_families') {
		    tab = document.getElementById('family_select_container');
//			tab.innerText=response[3];
			tab.innerHTML=response[3];
			document.getElementById('family_select_container').style.backgroundImage = "";
			
			// alert(response[3]);
			update_title();
			try {
				var supplier_id = document.getElementsByName('supplier_id')[0].value;
			} catch (e) {
			}
			try {
				var category_id = document.getElementById('catid').value;
			} catch (e) {
			}
			try {
				var family_id = document.getElementsByName('family_id')[0].value;
			} catch (e) {
			}

			session_id = document.getElementsByName('sessid')[0].value;

			var tmp1_local = 'tag_id=series_id;supplier_id=' + supplier_id + ';foo=bar;field_name=series_id;category_id=' + category_id + ';family_id=' + family_id;

			var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_get_product_series.html';

			call('get_product_series', tmp1_local, tmp2_local);
		}
		else if (func == 'get_product_series') {
			tab = document.getElementById('series_select_container');
			try {
				tab.innerHTML=response[3];
			} catch (e) {
				return;
			}
			document.getElementById('series_select_container').style.backgroundImage = "";
		}
		else if (func == 'get_warranty_info') {
		
		    // remove some strange \n symbols
		    response[3] = response[3].replace('\n', '', 'g');

		    // diffrent destinations for different req mode
		    
		    if (response[2] == 'warranty_info1' ) {
    		    tab = document.getElementsByName('warranty_info')[0];
    		    tab.value = response[3];
    		}
    		else if (response[2] == 'warranty_info2') {
    		    tab = document.getElementById('warranty_popup');
    		    existed = document.getElementsByName('warranty_info')[0].value;
    		    
    		    // if not empty
    		    // if (! response[3] == "" ) {
    		    if (! response[3].match(/^\s*$/) ) {
    		        // alert("(" + response[3]+ ") (" + existed + ")" );
    		    
    		        // ...and if not equal
    		        if (existed != response[3]) {
            		    tab.innerHTML = "<br>Default value for 'warranty info' field is : <br>" + response[3] + "<br>" +
            		    " <a onClick='set_default()' >Click here to replace</a>" +
    	        	    " <input type='hidden' id='default_wi' value='" + response[3] + "'>";
    	        	}
    	    	}
    	    	else {
    	    	    // no default warranty info
    	    	}
    		}
		}
		else if (func == 'sync_all_distri') {
		
    		var arr = response[3].split(/\n/);
    		var len = arr.length;
    		var i;
    		var pair;
    		var place;
    		for (i = 0 ; i < len ; i++ ) {
    		    pair = arr[i].split(/\^/);
  		        try {
  		            place = document.getElementById("sync_ph_" + pair[0]);
  		            place.innerHTML = pair[1];
                } 
                catch (e) {
                    continue;
    		    }
    		}
		}
		else if (func == 'set_map_pair_check') {
			var supplier_id=document.getElementById('manual_supplier_id').options[document.getElementById('manual_supplier_id').selectedIndex].value;
			var prod_id=document.getElementById('manual_map_prod_id').value;
			var sessid=document.getElementById('sessid').value;
			var track_product_id=document.getElementById('current_track_product_id').value;
			var track_list_id=document.getElementById('track_list_id').value;
			if(response[3]){
				call_async('get_map_pair_err','tag_id=ajax_overlay_result_id;foo=bar','sessid='+sessid+';ajaxed=0;tmpl=ajax_track_product_manual_map.html;track_product_id='+track_product_id+';atom_name=ajax_track_product_manual_map;atom_update=.;tmpl=ajax_track_product_manual_map.html;tmpl_if_success_cmd=ajax_track_product_manual_map.html;manual_supplier_id='+supplier_id+';sync_only=1;manual_map_prod_id='+prod_id);				
			}else{
				document.getElementById('the_overlay').style.display='none';
				call_async('set_map_pair','tag_id=page_reload_result;foo=bar','sessid='+sessid+';ajaxed=1;tmpl=track_products.html;search_track_product_id='+track_product_id+';search_atom=track_products;manual_supplier_id='+supplier_id+';manual_map_prod_id='+prod_id+';track_list_id='+track_list_id+';sync_only=1;command=set_track_product_pair');
			}
		}else if(func == 'get_map_pair_err'){
			var tab = document.getElementById(tag_id);
//			tab.innerText=response[3];
			tab.innerHTML=response[3];
		}
		else if (func == 'set_map_pair') {
			var tab = document.getElementById(tag_id);
			/*
			var ua = navigator.userAgent.toLowerCase(); 
			var IE=false; 
			IE = ua.indexOf('msie');
			*/			
			update_track_product_rows(response);
		}else if (func == 'map_track_product') {
			var tab = document.getElementById(tag_id);
			tab.innerHTML=response[3];
			
			var tb=tab.getElementsByTagName('table');
			var returned_changer=tb[0];
			if(returned_changer){
				var id=returned_changer.getAttribute('id');
				id=id.replace('_ajaxed','');
				document.getElementById(id).innerHTML='';
				var tds=returned_changer.getElementsByTagName('td');
				document.getElementById(id).innerHTML=tds[0].innerHTML;
				tab.removeChild(returned_changer);
			}
		}else if (func == 'set_track_poduct_rule'){
			//var tab = document.getElementById(tag_id);
			//tab.innerHTML=response[3];
			update_track_product_rows(response);
		}else if(func == 'delete_track_poduct_rule'){
			var was_update=update_track_product_rows(response);
			if(!was_update){//nothing was changed. It means what user removed not appruved rule. so we have to remove corresponding row 
				document.getElementById(tag_id).innerHTML='';
			}
		}else if (func == 'default'){
			var tab = document.getElementById(tag_id);
			tab.innerHTML=response[3];		
		}else if (func == 'get_google_translations'){
			var return_array=new Array();
			eval('return_array='+response[3]);
			for(var i=0;i<=return_array.length;i++){
				if(return_array[i] && return_array[i].id){
					document.getElementById(return_array[i].id+'_google').value=return_array[i].value;
				}
			}
		}

		
}

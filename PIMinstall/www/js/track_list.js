window.onload = function(){
	
	if(document.getElementById('ajax_call_status')){/* It is track product page*/
		var body=document.getElementsByTagName('body');
		window.onmousemove=function(){
			var date = new Date();
			if(document.getElementById('idle_time_starts')){
				document.getElementById('idle_time_starts').value=date.getTime();
			}
		}
		document.getElementById('ajax_call_status').value='finished';
		var date_obj = new Date();
		if(document.getElementById('ajax_call_finished')){
			document.getElementById('ajax_call_finished').value=date_obj.getTime();
		}
		if(document.getElementById('idle_time_starts')){
			document.getElementById('idle_time_starts').value=date_obj.getTime();
		}
		//url = 'ajax_unmodperl.cgi';
	}
}

function set_cover_cmd(){
	 document.getElementById('feed_config_commands').value='coverage_report_track_list';
}

function handleAjaxOverlay(event,result_id,doChangePos,isRight){
	var overlay_id='';
	if(isRight){
		overlay_id='the_overlay_right';
	}else{
		overlay_id='the_overlay';
	}
	if(doChangePos){
		if (!document.all) {
			document.getElementById(overlay_id).style.top=event.pageY+'px';
			document.getElementById(overlay_id).style.left=event.pageX+'px';
		}
		else{//IE
			if(document.documentElement.scrollTop){
				scrollTop=document.documentElement.scrollTop;
				scrollLeft=document.documentElement.scrollLeft;
			}else{
				scrollTop=document.body.scrollTop;
				scrollLeft=document.body.scrollLeft;				
			}
			document.getElementById(overlay_id).style.top=(event.clientY + scrollTop)+'px';
			document.getElementById(overlay_id).style.left=(event.clientX + scrollLeft)+'px';
		}
	}else{
		document.getElementById(overlay_id).style.display = 'none'; //redraw
	}
	document.getElementById(overlay_id).style.display = 'inline';
	document.getElementById(result_id).innerHTML = '';
}


function call_park(event,sessid,track_product_id,result_id,self,doChangePos){
	handleAjaxOverlay(event,result_id,doChangePos,false);
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any 
	call_async('get_products_by_feature_value','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_products_parked.html;track_product_id='+track_product_id);
}

function add_rule(sessid,track_product_id,result_id,self){
	//call('set_track_poduct_rule','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_list_set_rule.html;command=add_track_product_rule;track_product_id='+track_product_id);
	call('set_track_poduct_rule','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_products_all.html;ajaxed=1;command=add_track_product_rule;track_product_id='+track_product_id);
}

function delete_rule(sessid,track_product_id,result_id,self){
	//call('set_track_poduct_rule','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_list_set_rule.html;command=delete_track_product_rule;track_product_id='+track_product_id);
	call('delete_track_poduct_rule','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_products_all.html;ajaxed=1;command=delete_track_product_rule;track_product_id='+track_product_id);
}

function confirm_call_park(sessid,track_product_id){
	var is_parked=0;
	var remarks='';
	var parked_nodes=document.getElementsByName('park_cause');
	for(var i=0; i<parked_nodes.length;i++){
		if(parked_nodes[i].checked){
			is_parked=parked_nodes[i].value;
		}
	}
	if(document.getElementById('is_parked_remarks').value){
		remarks=document.getElementById('is_parked_remarks').value;
	};
	/*
 	var currNode=document.getElementById('ajax_track_products_'+track_product_id+'_parked_return').parentNode;
 	while(currNode.tagName.toLowerCase() != 'tr' ){
	 	currNode=currNode.parentNode;
	}
 	var remarks_node;
 	var divs=currNode.getElementsByTagName('div');
 	for(var i=0;i<divs.length; i++){
		 if(divs[i].getAttribute('class') == 'cls_remarks'){
			remarks_node=divs[i];
		 }	
	}
 	if(remarks_node){
 		remarks_node.innerHTML=remarks;
 	}
	 */
	if(is_parked!='' && remarks==''){
		alert('Input remarks when parking the product');
		return true;
	}
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any
	remarks=Url.encode(remarks);
	call_async('park_track_product','tag_id='+track_product_id+';foo=bar','ajaxed=1;command=set_is_parked;sessid='+sessid+';tmpl=ajax_track_products_parked_return.html;is_parked='+is_parked+';remarks='+remarks+';track_product_id='+track_product_id);
	document.getElementById('the_overlay').style.display = 'none';
	return true;
}

function get_track_list_editors(event,sessid,track_list_id,result_id,self,doChangePos){	
	handleAjaxOverlay(event,result_id,doChangePos,false);	
	call('get_products_by_feature_value','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_list_editors.html;track_list_id='+track_list_id);
}

function get_rule_prod_id(event,sessid,track_product_id,result_id,self,doChangePos,main_tmpl){	
	handleAjaxOverlay(event,result_id,doChangePos,false);
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any
	call_async('get_products_by_feature_value','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_products_rule.html;main_tmpl='+main_tmpl+';track_product_id='+track_product_id);
}

function get_map_pair(event,sessid,track_product_id,result_id,self,doChangePos){	
	handleAjaxOverlay(event,result_id,doChangePos,false);
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any
	call_async('get_products_by_feature_value','tag_id='+result_id+';foo=bar','sessid='+sessid+';tmpl=ajax_track_product_manual_map.html;track_product_id='+track_product_id);
}

function set_map_pair(event,sessid,track_product_id,doChangePos){	
	//handleAjaxOverlay(event,result_id,doChangePos,false);
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any
	var supplier_id=document.getElementById('manual_supplier_id').options[document.getElementById('manual_supplier_id').selectedIndex].value;
	var prod_id=Url.encode(document.getElementById('manual_map_prod_id').value);
	
	document.getElementById('current_track_product_id').value=track_product_id;
	document.getElementById('set_map_pair_button_id').disabled=true;
	call_async('set_map_pair_check','tag_id=dummy;foo=bar','sessid='+sessid+';ajaxed=0;tmpl=ajax_track_product_manual_map.html;track_product_id='+track_product_id+';atom_name=ajax_track_product_manual_map;atom_update=.;tmpl=ajax_track_product_manual_map_check.html;tmpl_if_success_cmd=ajax_track_product_manual_map_check.html;manual_supplier_id='+supplier_id+';manual_map_prod_id='+prod_id);
}


function set_rule_prod_id(sessid,track_product_id,track_list_id,tmpl){	
	var new_prod_id=document.getElementById('ajax_rule_prod_id').value;	
	var new_prod_id_rev=document.getElementById('ajax_rule_prod_id_rev').value;
	var reverse_rule='';
	var oldRuleSupp=document.getElementById('ajax_supplier_id_raw').value
	var rule_suppl=document.getElementById('supplier_id');
	var rule_supplier_id=rule_suppl.options[rule_suppl.selectedIndex].value;
	if( rule_supplier_id=='' && new_prod_id!=''){
		alert('Cant change the partcode if no supplier given');
		return true;
	}
	if(new_prod_id!='' && new_prod_id_rev!=''){
		alert('Product can have only one rule');
		return true;
	}
	if(new_prod_id==''){
		new_prod_id=new_prod_id_rev;
		reverse_rule='1';
	}
	new_prod_id=Url.encode(new_prod_id);
	document.getElementById('ajax_call_status').value='finished';// break current products renew ajax query if any
	call_async('set_map_pair','tag_id=page_reload_result;foo=bar','sessid='+sessid+
			';ajaxed=1;tmpl='+tmpl+';search_track_product_id='+track_product_id+
			';track_product_id='+track_product_id+
			';search_atom=track_products;supplier_id='+rule_supplier_id+
			';rule_prod_id='+new_prod_id+';track_list_id='+track_list_id+
			';reverse_rule='+reverse_rule+';sync_only=1'+
			';command=set_track_product_rule_prod_id');
	document.getElementById('the_overlay').style.display = 'none';
	return true;
}

function track_list_set_brand_map(self,sessid,track_list_supplier_map_id){
	var supplier_id='';
	if(self.options[self.selectedIndex]){
		supplier_id=self.options[self.selectedIndex].value;
	}
	call('default','tag_id=supplier_edit_'+track_list_supplier_map_id+';foo=bar',
				'sessid='+sessid+';atom_name=ajax_track_list_supplier_map;'+
				'atom_update=.;tmpl=ajax_track_list_supplier_map_return.html;'+
				'tmpl_if_success_cmd=ajax_track_list_supplier_map_return.html;'+
				'track_list_supplier_map_id='+track_list_supplier_map_id+
				';command=set_track_list_brand_map'+
				';map_supplier_id='+supplier_id);
}

function dummy(){}/*Needed for timeout emitation*/

function reload_products_page(sessid,track_list_id){
	var ajax_delta=0;
	if(document.getElementById('idle_time_starts')){
		var date = new Date();			
		var diff=(date.getTime()-document.getElementById('idle_time_starts').value)/1000;		
		if(diff<20*60 && document.getElementById('ajax_call_status').value=='finished'){/*      Change idle time here*/
			document.getElementById('update_button_id').disabled=true;
			ajax_delta=Math.round((date.getTime()-document.getElementById('ajax_call_finished').value)/1000);
			//alert(ajax_delta);			
			document.getElementById('ajax_call_status').value='started';
			call('get_track_products','tag_id=page_reload_result;foo=bar','sessid='+sessid+';ajaxed=1;ajax_delta='+ajax_delta+';tmpl=ajax_track_products_big_renew.html;track_list_id='+track_list_id);			
		}
	}
	/*change refresh time here*/
	setTimeout('reload_products_page(\''+sessid+'\','+track_list_id+')',ajax_delta+60000);
	return true;
}

function add2remark(self){
	var currParent=self.parentNode;
	var i=0;
	while(currParent.nodeName != 'TABLE'){
		currParent=currParent.parentNode;
		i++;
		if(i==50){//just in case
			break;
		}
	}
	var spans=currParent.getElementsByTagName('span');
	var remarks_area=document.getElementById('is_parked_remarks');
	
	for(var i=0;i<spans.length; i++){
		if(spans[i].getAttribute('name') == 'strForRemarks'){			
			remarks_area.value=remarks_area.value.replace(spans[i].innerHTML,'');
			remarks_area.value=remarks_area.value.replace(/[\s]+$/,'');
		}
	}
	
	var strForRemarks=document.getElementById('strForRemarks_'+self.value);
	if(strForRemarks){
		remarks_area.value=strForRemarks.innerHTML;
	}
}

function move_options(from,to){
	var from_options=document.getElementById(from);
	var to_options=document.getElementById(to).options;
	var from_length=from_options.length;
	
	  var selIndex = from_options.selectedIndex;
	  if (selIndex != -1) {
	    for(i=from_options.length-1; i>=0; i--)
	    {
	      if(from_options.options[i].selected)
	      {
	    	to_options[to_options.length]=new Option(from_options.options[i].text, from_options.options[i].value);
	        from_options.options[i] = null;
	      }
	    }
	    if (from_options.length > 0) {
	      from_options.selectedIndex = selIndex == 0 ? 0 : selIndex - 1;
	    }
	  }
}

function doBlink(node,period,id){
	var el;
	var ua = navigator.userAgent.toLowerCase(); 
	var white;
	var curr_class; 
	if(!id){
		if(!node.getAttribute('id')){			
			node.setAttribute('id','tmp_blinking_'+Math.random());
		}
		id=node.getAttribute('id');		
		el=node;
	}else{
		el=document.getElementById(id);
	}
	
	if(ua.indexOf('msie')!=-1){
		white='rgb(255,255,255)';
	}else if(ua.indexOf('opera')!=-1){
		white='#ffffff';	
	}else{
		white='rgb(255, 255, 255)';
	}
	
	if(el.style.backgroundColor== white){
		el.style.backgroundColor = '';		
	}else{
		el.style.backgroundColor = white;
	}	
	el.blinker=setTimeout('doBlink(false,'+period+',\''+id+'\')',period);
	return true;
}

/********** COLUMN Hide functions **************/

function show_columns_overlay(){
    var overlay = new Overlay(document.body,{
	    id: 'overlay',
	    color: '#000',
	    duration: 300,
	    opacity: 0.5,
	    onClick: function() {
	    			this.close();
	    			$('overlay_content').style.display='none';
	    		  },
	    onOpen: function() {
	  		$('overlay_content').style.display='block';
  			
	   }
	   });
	   overlay.open();
	   			   		
}
function update_track_product_rows(response){
	response[3]=response[3].replace('id="main_table"','id="main_table_ajaxed"');
	response[3]=response[3].replace('id="main_table_info"','id="main_table_info_ajaxed"');
	document.getElementById('tmp_ajax_result').innerHTML=response[3];

	var main_table=document.getElementById('main_table_info').tBodies[0];
	var result_trs=document.getElementById('main_table_info_ajaxed').rows;
	var update_done=false;
	for(var i=0; i<result_trs.length; i++ ){
		if(result_trs[i].getAttribute('id')){
			var removed_id=result_trs[i].getAttribute('id').replace(/_[^_]+$/,'_');
			var remove_tr=document.getElementById(removed_id);
			if(remove_tr){
				clearTimeout(remove_tr.blinker);
			}
			if(remove_tr && result_trs[i].innerHTML.replace(/href="[^"]+"/,'').replace(/onclick="[^"]+"/,'')!=remove_tr.innerHTML.replace(/href="[^"]+"/,'').replace(/onclick="[^"]+"/,'')){//sanitary check
				//alert(result_trs[i].innerHTML.replace(/href="[^"]+"/,'').replace(/onclick="[^"]+"/,''));
				//alert(remove_tr[i].innerHTML.replace(/href="[^"]+"/,'').replace(/onclick="[^"]+"/,''));
				result_trs[i].getElementsByTagName('td')[0].innerHTML=remove_tr.getElementsByTagName('td')[0].innerHTML;						
				if(result_trs[i].getAttribute('id')){
					clearTimeout(result_trs[i].blinker);
					result_trs[i].onmouseout=function() {
						clearTimeout(this.blinker);
						this.style.backgroundColor='';
					}
					result_trs[i].setAttribute('id',removed_id);						
					doBlink(result_trs[i],500,false);						
					main_table.insertBefore(result_trs[i], remove_tr);
					main_table.deleteRow(remove_tr.rowIndex);
					update_done=true
				}
			}else{
				
			}
		}			
	}
	return update_done;
}

function show_graphic(data,series_arr,y_max,container_id){
	var y_ticks_num=20;
	var max_x=data[0].length;
	var graph_width=(max_x*35+200);
	var graph_height=(data.length*30);
	if(graph_width>1200){
		graph_width=1200;
	}
	if(graph_height<400){
		graph_height=400;
	}
	
	document.getElementById(container_id).style.width=graph_width+'px';
	document.getElementById(container_id).style.height=graph_height+'px';
	var y_pad=0;
	graph=$.jqplot(container_id,  data,
			{ 
			  title:'Editors activity',
			  axesDefaults: {
    			tickOptions: {
					formatString: '%d'						
				}	    	
			  },				  
			  axes:{
				    yaxis:{min:0,max:y_max,numberTicks: y_ticks_num,pad:y_pad},
				    xaxis:{min:1, max:max_x+8,numberTicks: max_x+8,pad:1}
			  },
			  series:series_arr,
			  legend: {
			        show: false,
			        location: 'ne',     // compass direction, nw, n, ne, e, se, s, sw, w.
			        xoffset: 12,        // pixel offset of the legend box from the x (or x2) axis.
			        yoffset: 12        // pixel offset of the legend box from the y (or y2) axis.
			    },
			  cursor: {
			        showVerticalLine:true,
			        showHorizontalLine:false,
			        showCursorLegend:true,
			        showTooltip: true,
			        zoom:true,
			        followMouse: true 
			    }
			  
			});
	}

function renew_graphic_data(container_id,axis,series_str){	
/*	var x_axis='[';
	var editor_cnt=5;
	var days_cnt=20;
	for(var j=0;j<editor_cnt;j++){
		x_axis=x_axis+'[';
		var last_value=Math.floor(Math.random()*100);
		for(var i=1;i<days_cnt+1; i++){
			last_value=last_value+Math.floor(Math.random()*10);
			x_axis=x_axis+'['+i+','+(last_value)+'],';	
		}
		x_axis=x_axis.replace(/,$/,'');
		x_axis=x_axis+'],';
	}
	x_axis=x_axis.replace(/,$/,'');
	x_axis=x_axis+']';
	var series_str = '[';
	for(var i=1;i<editor_cnt; i++){
		series_str=series_str+"{label:'Editor"+i+"'},";
	}
	series_str=series_str.replace(/,$/,'');
	series_str=series_str+']';
*/
	delete graph;
	graph=null;
	document.getElementById(container_id).style.display='none';
	document.getElementById(container_id).innerHTML='';	
	document.getElementById(container_id).style.display='block';
	var series_arr=new Array();
	eval('series_arr='+series_str);	
	var axis_arr=new Array();
	eval('axis_arr='+axis);
	var max_value=0;
	for(var i=0;i<axis_arr.length; i++){
		for(var j=0;j<axis_arr[i].length; j++){
			if(axis_arr[i][j][1]>max_value){
				max_value=axis_arr[i][j][1];
			}
		}
	}
	show_graphic(axis_arr,series_arr,max_value+20,container_id);
}

function selectCheckBox(event,self){
	if(event.shiftKey){
		self.checked=true;
	} else if(event.ctrlKey){
		self.checked=false;
	};
} 
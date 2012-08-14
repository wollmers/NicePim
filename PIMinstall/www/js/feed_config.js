
window.onload=function(){
	display_csv_settings(document.getElementById('feed_type'));
	atom_submit=document.getElementsByName('atom_submit');
	atom_update=document.getElementsByName('atom_update');
	
	if(document.getElementById('feed_ean_cols_id')!=null && document.getElementById('feed_ean_cols_id').value!=''){
		var arr=new Array;
		if(document.getElementById('feed_ean_cols_id').value.length>0){
			arr=document.getElementById('feed_ean_cols_id').value.split(',');
		}		
		arr=document.getElementById('feed_ean_cols_id').value.split(',');
		for(var i=0;i<arr.length;i++){
			addEANcolumn(arr[i]);
		}
	}
}

function go_to_feed_coverage(){
	tmpl=document.getElementsByName('tmpl');
	
	if(tmpl && tmpl[0].type=='hidden' ){
		document.getElementsByName('tmpl')[0].value='feed_coverage.html';
	}
	mi=document.getElementsByName('mi');	
	if(mi && mi[0].type=='hidden' ){
		document.getElementsByName('mi')[0].value='requests';
	}

}

function display_csv_settings(self){	
	if(self.options[self.selectedIndex].value=='csv'){
		document.getElementById('feed_config_csv_details').style.display='block';
	}else{
		document.getElementById('feed_config_csv_details').style.display='none';		
	}
	
}
function reupload_feed(){	
	if(!document.getElementById('feed_config_file').value && !document.getElementById('feed_config_url').value){
		return false;
	};
	document.getElementById('feed_config_commands').value='reupload_price_feed';
}
function preview_feed(){
	if(document.getElementById('feed_config_file').value){
		document.getElementById('feed_config_commands').value='reupload_price_feed';
		return true;
	};
	document.getElementById('feed_config_commands').value='';
	set_atom_name('feed_config');
}

function set_atom_name(str_name){
	var arr=document.getElementsByName('atom_name');
	for(i=0; i<arr.length; i++){
		//alert(arr[i].value);
		arr[i].value=str_name;
	}
}

function change_delimiter(self){
	//alert(self.value);
	if(self.value != 'custom'){
		document.getElementById('feed_config_delimiter').value=self.value;
	}else{
		document.getElementById('feed_config_delimiter').value='';
	}
}

function show_coverage_report(){
	document.getElementById('feed_config_commands').value='coverage_report_from_file';
	document.getElementById('atom_update_hidden').value='.';
	document.getElementById('feed_config_atom_name').value='';
	document.getElementById('feed_config_atom_name').name='';
}


function addEANcolumn(col){
	var ean_select;
	if(col){
		ean_select=document.getElementById('ean_col').options[col];
	}else{
		ean_select=document.getElementById('ean_col').options[document.getElementById('ean_col').selectedIndex];
	}
	if(!ean_select.value){
		return null;
	}
	if(document.getElementById('choiced_ean_col_'+ean_select.value)!=null && !col){
		alert('This column '+ean_select.innerHTML+' had been added ')
	}else{
		document.getElementById('user_choiced_ean_cols').innerHTML+='<div id="choiced_ean_col_'+ean_select.value+'">'+
		'<input type="button" value="-" onclick="removeEANcolumn(\''+ean_select.value+'\')"/>'+
		ean_select.innerHTML+
		'</div>';		
		var arr=new Array;
		if(document.getElementById('feed_ean_cols_id').value.length>0){
			arr=document.getElementById('feed_ean_cols_id').value.split(',');
		}
		if(!col){
			arr.push(ean_select.value);		
			document.getElementById('feed_ean_cols_id').value=arr.join(',');//.substr(1);
		}
	}
}

function removeEANcolumn(id){	
	document.getElementById('choiced_ean_col_'+id).parentNode.removeChild(document.getElementById('choiced_ean_col_'+id));
	var arr=document.getElementById('feed_ean_cols_id').value.split(',');
	//alert(arr[0]);
	var len=arr.length;
	for(var i=0;i<arr.length;i++){
		if(arr[i]==id){
			arr[i]=arr[len-1];
			arr.pop();
			//break;
		}
	};
	document.getElementById('feed_ean_cols_id').value=arr.join(',');//.substr(1);
}

var Url = {
 
	// public method for url encoding
	encode : function (string) {
		return escape(this._utf8_encode(string));
	},
 
	// public method for url decoding
	decode : function (string) {
		return this._utf8_decode(unescape(string));
	},
 
	// private method for UTF-8 encoding
	_utf8_encode : function (string) {
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";
 
		for (var n = 0; n < string.length; n++) {
 
			var c = string.charCodeAt(n);
 
			if (c < 128) {
				utftext += String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)) {
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else {
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}
 
		}
 
		return utftext;
	},
 
	// private method for UTF-8 decoding
	_utf8_decode : function (utftext) {
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;
 
		while ( i < utftext.length ) {
 
			c = utftext.charCodeAt(i);
 
			if (c < 128) {
				string += String.fromCharCode(c);
				i++;
			}
			else if((c > 191) && (c < 224)) {
				c2 = utftext.charCodeAt(i+1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i += 2;
			}
			else {
				c2 = utftext.charCodeAt(i+1);
				c3 = utftext.charCodeAt(i+2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i += 3;
			}
 
		}
 
		return string;
	}
 
}
function hide_user_integ_sett(self){
	if(self.options[self.selectedIndex].value=='1'){
		document.getElementById('implementation_partner_cont_logo').style.display='block';
	}else{
		document.getElementById('implementation_partner_cont_logo').style.display='none';
	};	
	return '';
}

function hide_user_shop_sett(self){
	if(self.options[self.selectedIndex].value=='shop'){
		document.getElementById('is_implementation_partner_logo_tr').style.display='table-row';
		document.getElementById('is_implementation_partner_tr').style.display='table-row';
	}else{
		document.getElementById('is_implementation_partner_tr').style.display='none';
		document.getElementById('is_implementation_partner_logo_tr').style.display='none';
		
	};	
	return '';
}

function show_feature_dropdown(self,is_left){
	var id=self.getAttribute('id').replace(/[^0-9]+/,'');
	var panel=document.getElementById(id+'_multi_value_panel');
	panel.style.display='block';
	var panel_width=panel.scrollWidth;
	var edit_width=document.getElementById(id).scrollWidth;
	var button_width=document.getElementById(self.getAttribute('id')).scrollWidth;
	if(is_left){
		//alert('this is left');
	}else{
		var xy=findPos(panel);
		//alert(xy[0]);
		//var pos=(panel.style.left-(panel_width-(edit_width+button_width)));		
		if(panel.style.left==''){
			panel.style.left=(xy[0]-(panel_width-(edit_width+button_width)))+'px';
		}
	}
	
	return 1;
}

function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft;
		curtop = obj.offsetTop;
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft;
			curtop += obj.offsetTop;
		}
	}
	return [curleft,curtop];
}

function collect_checkbox_values(panel_id,short_length){
	var panel=document.getElementById(panel_id+'_multi_value_panel');
	var inputs=panel.getElementsByTagName('input');
	var values='';
	var texts='';
	for(var i=0; i<inputs.length; i++){
		if(inputs[i].getAttribute('type') == 'checkbox' && inputs[i].checked==1 ){
			values=values+','+inputs[i].value;
			texts=texts+','+inputs[i].getAttribute('short_value');
		}
	}
	values=values.replace(/^,/,'');
	texts=texts.replace(/^,/,'');
	document.getElementById(panel_id).value=texts;
	panel.style.display='none';
	document.getElementById(panel_id+'_multifeature_hidden').value=values;
	
}

function hide_checkbox_features(id){
	document.getElementById(id+'_multi_value_panel').style.display='none';
}

function show_dictionary(id,self){
	document.getElementById(id).style.display='table-row';
	if(self.savedBorder === undefined){
		self.savedBorder=self.style.border;
	}
	self.style.border='none';
	var others=document.getElementsByClassName('dictionary_tr');
	for(var i=0; i<others.length; i++){
		if(others[i].getAttribute('id') != id){
			others[i].style.display='none';
		}
	}
	var buttons=document.getElementsByClassName('dictionary_choice_button');
	for(var i=0; i<buttons.length; i++){
		if(buttons[i].getAttribute('id') != self.getAttribute('id')){
			buttons[i].style.border=buttons[i].savedBorder;
		}
	}
}

function PopupCenter(pageURL, title,w,h) {
	var left = (screen.width/2)-(w/2);
	var top = (screen.height/2)-(h/2);
	var targetWin = window.open (pageURL, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=y, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
} 

function PopupPic(sessid,sPicURL) {
    window.open( "index.cgi?sessid="+sessid+";tmpl=popup_image.html;url="+sPicURL, "Image","resizable=1,scrollbars=1,HEIGHT=75,WIDTH=75");
}

function expand(s,level,root_id,is_left)
{
  var td = s;
  var d = td.getElementsByTagName("div").item(0);  
  if(td.className!='menu' && td.className!='activeMenu'  ){
	  td.className = "menuHover";
  }
  var td_size=parseInt(d.getAttribute('width'));
  
  d.className = "menuHover";
  
  if(level>0 && is_left){
	  d.style.left='-'+(td_size -1) + 'px';
  }else if(level>0 && !is_left){
	  d.style.left=(td_size +1) + 'px';
  }
  
}

function collapse(s)
{
  var td = s;
  var d = td.getElementsByTagName("div").item(0);
  if(td.className!='menu'){
	  td.className = "menuNormal";
  }
  d.className = "menuNormal";
}
function submenu_color(self,action){
	var ua = navigator.userAgent.toLowerCase();
	if(action=='set'){
		if(ua.indexOf('msie')!=-1){
			self.style.backgroundColor='rgb(235,235,235)';
		}else if(ua.indexOf('opera')!=-1){
			self.style.backgroundColor='#ebebeb';	
		}else{
			self.style.backgroundColor='rgb(235,235,235)';
		}
	}else if(action=='remove'){
		if(ua.indexOf('msie')!=-1){
			self.style.backgroundColor='rgb(255,255,255)';
		}else if(ua.indexOf('opera')!=-1){
			self.style.backgroundColor='#ffffff';	
		}else{
			self.style.backgroundColor='rgb(255, 255, 255)';
		}		
	}
	
}
var req; // request object
var processing = 0; // in process or not?
var cnt = 0; // AJAX requests counter
var url = 'ajax.cgi';
//var url = 'ajax/ajax.cgi';

var hAJAX = new Hash; // Global AJAX requests container

// for mandatory parameters
var tmp1;
var tmp2;

///////////////////////////////////////////////////////////////////////////////////////////////////

function call(func, parameters, params) {
		cnt++;
		
		var parameters_array = parameters.split(';');
		var request = ''; 
		request += '<?xml version="1.0" encoding="ISO-8859-1"?>' + "\n";
		request += '<AjaxRequest>' + "\n";
		request += '<Request ID="' + cnt + '" Function="' + func  + '">'   + "\n";
		
		for (i=0; parameters_array[i]; i++) {
				request += "\t" + '<Parameter ID="' + (i+1) + '"><![CDATA[' + parameters_array[i] + ']]></Parameter>' + "\n"; 
		}
		
		request += '</Request>'     + "\n";
		request += '</AjaxRequest>' + "\n";
		
		add2hash(cnt, request + ';' + params);
		nextAJAXRequest();
} // call

///////////////////////////////////////////////////////////////////////////////////////////////////

function add2hash(cnt, request) {
		if (hAJAX.getLength() > 15) {
				hAJAX.erase(getValue(processing));
		}

		var arr = hAJAX.getKeys();
		var el = null;

		// remove previous added to hash requests
		for (var i = 1; arr[i]; i++) {
				el = hAJAX.get(arr[i]);
				if ((el) && (el.match(/\sFunction="get_categories_list_by_like_name"/))) {
						hAJAX.erase(arr[i]);
				}
		}

		hAJAX.include(cnt, request);
} // add2hash

///////////////////////////////////////////////////////////////////////////////////////////////////

function nextAJAXRequest() {
		if (processing == 0) {			
				var minValue = getValue(0);
				if (minValue) {
						processing = 1; // set processing
						makeRequest(hAJAX.get(minValue));
						hAJAX.set(minValue, '');
						AJAXindication();
				}
		}
} //nextAJAX 

///////////////////////////////////////////////////////////////////////////////////////////////////

function getValue(n) {
		var arr = hAJAX.getKeys();
		arr.sort(intcmp);
		return arr[n];
} // getMinValue

///////////////////////////////////////////////////////////////////////////////////////////////////

function intcmp(a, b) {
		if (Number(a) < Number(b)) {
				return -1;
		}
		if (Number(a) > Number(b)) {
				return 1;
		}
		return 0;
} // intcmp

///////////////////////////////////////////////////////////////////////////////////////////////////

function makeRequest(request) {
		delete req;
		if (window.XMLHttpRequest) {
				req = new XMLHttpRequest();
//				if(req.overrideMimeType){
//						req.overrideMimeType('text/xml');
//				}
		}
		else if (window.ActiveXObject) {
				try {
						req = new ActiveXObject("Msxml2.XMLHTTP");
				}
				catch (e) {
						try {
								req = new ActiveXObject("Microsoft.XMLHTTP");
						}
						catch(e) {
						}
				}
		}
		
		if (!req) {
				alert('Cannot create XMLHTTP instance. Please contact support@iceshop.nl');
				return false;
		}

		//hAJAX.set();

		
		var str = url + '?request=' + request;
//		alert(str);
		req.onreadystatechange = processXML;
		req.open('GET', str, true);
		req.send(null);
} // makeRequest

///////////////////////////////////////////////////////////////////////////////////////////////////

function processXML() {
		if (req.readyState == 4) {
				if (req.status == 200) {
//						var text = decodeURIComponent(req.responseText);
						var text = req.responseText;
						var output = text.split("<ICEcat-AJAX-delimiter>");
						ajax_response(output);
						processing = 0; // unset processing status
						AJAXindication();
						nextAJAXRequest();
				}
				else {
						//alert('There was a problem with the request. Result status: '+req.status);
				}
		}
} // processXML

///////////////////////////////////////////////////////////////////////////////////////////////////

function AJAXindication() {
		var output = '';
		var arr = hAJAX.getKeys();

		for (var i = 0; i < arr.length; i++) {
				if (hAJAX.get(arr[i]) == 0) {
						output += '<img src="./img/green_circle.gif" width="6" height="8" border="0"/>';
				}
				else {
						output += '<img src="./img/gray_circle.gif" width="6" height="8" border="0"/>';
				}
		}

		document.getElementById('hAJAX').innerHTML = output;
} // AJAXindication

function call_async(func, parameters, params) {
	var parameters_array = parameters.split(';');
	var request = ''; 
	request += '<?xml version="1.0" encoding="ISO-8859-1"?>' + "\n";
	request += '<AjaxRequest>' + "\n";
	request += '<Request ID="' + cnt + '" Function="' + func  + '">'   + "\n";
	
	for (i=0; parameters_array[i]; i++) {
			request += "\t" + '<Parameter ID="' + (i+1) + '"><![CDATA[' + parameters_array[i] + ']]></Parameter>' + "\n"; 
	}
	
	request += '</Request>'     + "\n";
	request += '</AjaxRequest>' + "\n";
	request += ';' + params + "\n";
	makeRequest(request);
} // call_async

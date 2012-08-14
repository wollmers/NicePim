function collectToTranslate(id_pattern,langIds,en_langid,sessid){	
	var en_string=document.getElementById(id_pattern+en_langid).value;
	en_string=en_string.replace(/^[\t\s\r\n]+$/,'');
	if(en_string==''){
		return '';
	};
	var langs_text='';
	for(var i=0; i<=langIds.length;i++){
		var transl_input_id=id_pattern+langIds[i];
		var transl_input=document.getElementById(transl_input_id);		
		if(transl_input && (!transl_input.value || transl_input.value.replace(/^[\t\s\r\n]+$/,'')=='')){			
			langs_text=langs_text+','+langIds[i];
		}else if(document.getElementById(transl_input_id+'_google')){// in a name of chrome
			document.getElementById(transl_input_id+'_google').value='';
		};
	};
	document.getElementById(id_pattern+'1'+'_google').value=''; // in a name of chrome
	langs_text=langs_text.replace(/^,/, '');
	langs_text='['+langs_text+']';
	en_string=Url.encode(en_string);
	call('get_google_translations','tag_id=bla_bla;foo=bar','sessid='+sessid+';tmpl=ajax_google_translations.html;en_string='+en_string+';id_pattern='+id_pattern+';lang_ids='+langs_text);
	return '';
}
function copy_translation(from,to){
	if(document.getElementById(from).value !=''){
		document.getElementById(to).value=document.getElementById(from).value;
	}
}
function copy_all_translation(langIds,id_pattern){
	for(var i=0; i<=langIds.length;i++){
		copy_translation(id_pattern+langIds[i]+'_google',id_pattern+langIds[i]);
	}
}

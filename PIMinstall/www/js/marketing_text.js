function setSelRange(inputEl, selStart, selEnd) { 
		if (inputEl.setSelectionRange) { 
				inputEl.focus(); 
				inputEl.setSelectionRange(selStart, selEnd);
		} else if (inputEl.createTextRange) {
				var range = inputEl.createTextRange(); 
				range.collapse(true); 
				range.moveEnd('character', selEnd); 
				range.moveStart('character', selStart); 
				range.select(); 
		} 
}

function strrev(str) {
		if (!str) return '';
		var revstr='';
		for (i = str.length-1; i>=0; i--)
				revstr+=str.charAt(i)
		return revstr;
}

function replaceSelection(obj,t) {
		if (BrowserDetect.browser == 'Explorer') {
				return;
		}

		var len = obj.value.length;
		var start = obj.selectionStart;
		var end = obj.selectionEnd;
		var sel = obj.value.substring(start, end);
		var before = obj.value.substring(0,start);
		var after = obj.value.substring(end,len);
		var b1 = '<b>';
		var b2 = '</b>';

		var offset = obj.scrollTop;
 
		var replace = sel;
		if (t == '-') {
				if (sel != '') {
						replace = sel.replace(/^\s*•+/gm, '-');
						replace = replace.replace(/^\s*\*+/gm, '-');
						replace = replace.replace(/^\s*·+/gm, '-');
						replace = replace.replace(/^\s*\-(\S)/gm, '-$1');
						replace = replace.replace(/^\s*\»+/gm, '-');
						replace = replace.replace(/^\s*\~+/gm, '-');
						replace = replace.replace(/^\s*\#+/gm, '-');
						replace = replace.replace(/^\-+/gm, '- ');
						replace = replace.replace(/^([^\-])/gm, '- $1');
						replace = replace.replace(/^(\-\s+)*/gm, '- ');
				}
		}
		else if (t == 'b') {
				if (sel != '') {
						// check the half-tag problem - hmmm ???
						if ((/^((\/)?b)?>/.test(sel)) || (/<(\/(b)?)?$/.test(sel))) {
								replace = sel;
						}
						else {

								replace = sel.replace(/<\/?b>/ig, "");

								var beforeb1Index = strrev(before).search(/>b</);
								if (beforeb1Index == -1) {
										beforeb1Index = 65536;
								}
								var beforeb2Index = strrev(before).search(/>b\/</);
								if (beforeb2Index == -1) {
										beforeb2Index = 65536;
								}

								var afterb1Index = after.search(/<b>/);
								if (afterb1Index == -1) {
										afterb1Index = 65536;
								}
								var afterb2Index = after.search(/<\/b>/);
								if (afterb2Index == -1) {
										afterb2Index = 65536;
								}
								
								if (beforeb1Index < beforeb2Index) {
										b1 = '';
								}
								
								if (afterb1Index > afterb2Index) {
										b2 = '';
								}
								
								replace = b1 + replace + b2;
						}
				}				
		}
 
		// Here we are replacing the selected text with this one
		obj.value = before + replace + after;
		/* 
		 * Especially for Opera browser, because of incorrect selection range
		 * Firefox and Chrome return only one row
		 */
		var rep_rows = replace.split("\r");
		var extra = rep_rows.length - 1;

		setSelRange(obj, before.length, before.length + replace.length + extra ); // select a new range

		if ((obj.scrollTo) && (offset != 0)) {
				obj.scrollTo(0, offset);
		}
}

function refineText(obj) {
		var text = obj.value;
		text = text.replace(/^\ *(.*?)$/gm, "$1");
		text = text.replace(/^(.*?)\ *$/gm, "$1");
		text = text.replace(/\ {2,}/g, " ");
		obj.value = text;
}

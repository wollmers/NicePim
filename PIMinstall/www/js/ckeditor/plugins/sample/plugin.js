/*
Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

/**
 * @file Code.
 */

//CKEDITOR.plugins.add('code');
CKEDITOR.plugins.add('code', {
	init : function( editor ) {
		CKEDITOR.on ('instanceReady', function(event) {
			var editor = event.editor;
			CKEDITOR.dom.addBlock(editor);
		})
	}
	,
	requires:['selection']
});


(function()
{

	var iceTemplate = '';
	var templateURL = 'http://' + location.hostname + '/js/ckeditor/plugins/sample/newsl/index.html';
	var hashIceTemplate = new Array();

	function storeBlock (blockName) {
		if (hashIceTemplate[blockName] == undefined) {
			var ind1 = iceTemplate.indexOf('<!-- ' + blockName + ' -->');
			var ind2 = iceTemplate.indexOf('<!-- eof ' + blockName + ' -->');
			ind1 += ('<!-- ' + blockName + ' -->').length;
			hashIceTemplate[blockName] = iceTemplate.substr(ind1, ind2 - ind1);
		}
	}

	function getSelectionBounds (editor, selection, blockName) {
		var ranges = selection.getRanges();
		var range = ranges[0];

		nativeSelection = selection.getNative();
		nativeRange = nativeSelection.getRangeAt(0);

		var parsedText = nativeSelection.toString();

		var start = nativeRange.startContainer;
		var end = nativeRange.endContainer;
		var startOffset = nativeRange.startOffset;
		var endOffset = nativeRange.endOffset;
		var root = nativeRange.commonAncestorContainer;

		if(start.nodeName == "#text") start = start.parentNode;
		if(end.nodeName == "#text") end = end.parentNode;

		var concurrentParsedText = root.innerHTML;

		root = start;

		concurrentParsedText = root.innerHTML;

		span = editor.document.createElement('aaoe');

		range.extractContents().appendTo(span);
		range.insertNode(span);

		for (var childItem in root.childNodes) {
			if (root.childNodes[childItem].nodeType == 1 && root.childNodes[childItem].nodeName == 'AAOE') {
				root = root.childNodes[childItem];
				break;
			}
		}

		var re = new RegExp("outer_.*");

		node = root;
		if(node.nodeName == "#text") node = node.parentNode;

		var testBlockName = '';

		while (node != null && node.getAttribute) {
			testBlockName = node.getAttribute('class');
			if (testBlockName == blockName || (testBlockName != null && testBlockName.match(re))) {

				range.setStartBefore(new CKEDITOR.dom.node(node));
				range.setEndAfter(new CKEDITOR.dom.node(node));
				span = editor.document.createElement('aaoe');
				range.extractContents().appendTo(span);
				range.insertNode(span);

				parsedText = concurrentParsedText;

//				range.surroundContents(span);
				node = node.parentNode;

				break;
			}

			node = node.parentNode;
		}

		if(testBlockName == null || (testBlockName != blockName && !testBlockName.match(re))) {
			node = null;
		}

		// check if we are inside known block but not the same as blockName
		if (node != null && testBlockName != blockName) {
			root = node;
			node = null;
		}

		if (parsedText == '') parsedText = '<br />';
		return {
			parsedText: parsedText,
			root: root,
			node: node
		};
	}

	function getSelectionBounds2(editor, selection, blockName) {

		var nativeSelection = selection.getNative();
		var range = nativeSelection.createRange();

		var parsedText = range.htmlText;

		if(!range.duplicate) return null;

		var r1 = range.duplicate();
		var r2 = range.duplicate();
		r1.collapse(true);
		r2.moveToElementText(r1.parentElement());
		r2.setEndPoint("EndToStart", r1);
		start = r1.parentElement();

		r1 = range.duplicate();
		r2 = range.duplicate();
		r2.collapse(false);
		r1.moveToElementText(r2.parentElement());
		r1.setEndPoint("StartToEnd", r2);
		end = r2.parentElement();

		root = range.parentElement();

		root = start;

		range.pasteHTML("<span temp=1>" + parsedText + "</span>");

		for (var childItem in root.childNodes) {
			if (root.childNodes[childItem].nodeName=="SPAN" && root.childNodes[childItem].getAttribute('temp') == 1)  {

				root = root.childNodes[childItem];
				range.moveToElementText(root);

				break;
			}
		}

		var re = new RegExp("outer_.*");

		node = root;
		if(node.nodeName == "#text") node = node.parentNode;

		var testBlockName = '';

		while (node != null && node.getAttribute) {
			testBlockName = node.getAttribute('class');
			if (testBlockName == blockName || (testBlockName != null && testBlockName.match(re))) {

				var temp = node.parentNode;

				node.outerHTML = "<span temp=1>" + node.outerHTML + "</span>";

				for (var childItem in temp.childNodes) {
					if (temp.childNodes[childItem].nodeName=="SPAN" && temp.childNodes[childItem].getAttribute('temp') == 1)  {
						node = temp.childNodes[childItem];
						range.moveToElementText(node);
						break;
					}
				}

				break;

			}
			node = node.parentNode;
		}

		if(testBlockName == null || (testBlockName != blockName && !testBlockName.match(re))) {
			node = null;
		}

		// check if we are inside known block but not the same as blockName
		if (node != null && testBlockName != blockName) {
			root = node;
			node = null;
		}

		//if (parsedText == '') parsedText = '<br />';

		return {
			parsedText: parsedText,
			root: root,
			node: node
		};

	}

	CKEDITOR.dom.getBlock = function (editor, blockName) {

		selection = editor.getSelection();
		nativeSelection = selection.getNative();

		if (CKEDITOR.env.ie) {

			range = selection && selection.getRanges()[0];
			var bounds = getSelectionBounds2(editor, selection, blockName);

		} else {

			var bounds = getSelectionBounds(editor, selection, blockName);

		}

		// check if we are inside same block as blockName
		if (bounds.node != null) {
			bounds.node.innerHTML = bounds.parsedText;
			clearText(bounds.node);
		}else if (iceTemplate == '') {
			var req = new Request.HTML({
				method: 'get',
				onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript) {	
					iceTemplate = responseHTML;
					iceTemplate = iceTemplate.replace(/%%host%%/g, 'http://' + location.hostname);
					storeBlock (blockName);
					bounds.root.innerHTML = hashIceTemplate[blockName].replace(/%%text%%/g, bounds.parsedText);
					clearText(bounds.root);
				},
				url: templateURL
			}).send();
		} else {
			storeBlock (blockName);
			bounds.root.innerHTML = hashIceTemplate[blockName].replace(/%%text%%/g, bounds.parsedText);
			clearText(bounds.root);
		}	
	}

	CKEDITOR.dom.addBlock = function (editor) {
		editor.focus();
		

		var root = editor.document.getBody();

		if (root.getHtml().length <= 12) {

			var req = new Request.HTML({
				method: 'get',
				onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript) {
					iceTemplate = responseHTML;
					iceTemplate = iceTemplate.replace(/%%host%%/g, 'http://' + location.hostname);
					storeBlock ('header');
					storeBlock ('footer');
					root.setHtml(hashIceTemplate['header'] + '<br />' + hashIceTemplate['footer']);
				},
				url: templateURL
				//			url: 'http://d_uglatch.icecat.office/ckeditor/_source/plugins/sample/newsl/index.html'
			}).send();
		}
	}

	function clearText (node) {
		if (node.getAttribute('temp') == '1') {
			node.outerHTML = node.innerHTML;
		} else {
			node = node.parentNode;
			node.innerHTML = node.innerHTML.replace("<aaoe>", "");
			node.innerHTML = node.innerHTML.replace("</aaoe>", "");
		}
	}

})();

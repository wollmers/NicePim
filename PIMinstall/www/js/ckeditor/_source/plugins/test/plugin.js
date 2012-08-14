(function()
{
	CKEDITOR.dom.ee = function (editor) {

		selection = editor.getSelection();
		range = selection && selection.getRanges()[0];

		if ( !range )
			return;

//		var bookmarks = selection.createBookmarks();
//		var bookmarkStart = bookmarks[0].startNode,  bookmarkEnd = bookmarks[0].endNode;

		var para = editor.document.createElement('aaoe');
		range.extractContents().appendTo(para);

		range.insertNode(para);


/*		alert (bookmarkStart);
		alert (bookmarkEnd);*/

		editor.focus();
	}

	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.ee(editor);
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'test',	{
		init : function( editor ) {
			editor.addCommand( 'test', commandObject );
			editor.ui.addButton( 'Test', {
				label : editor.lang.code,
				command : 'test'
			});
		}
	});
})();

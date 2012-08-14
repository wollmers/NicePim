(function()
{
	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.getBlock(editor, 'outer_text');
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'text',	{
		init : function( editor ) {
			editor.addCommand( 'text', commandObject );
			editor.ui.addButton( 'Text', {
				label : 'text framed in blue',
				command : 'text',
				icon : this.path + 'text.gif'
			});
		},

		requires : [ 'code' ]
	});
})();

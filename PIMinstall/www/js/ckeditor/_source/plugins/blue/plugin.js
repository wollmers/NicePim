(function()
{
	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.getBlock(editor, 'outer_blue');
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'blue',	{
		init : function( editor ) {
			editor.addCommand( 'blue', commandObject );
			editor.ui.addButton( 'Blue', {
				label : 'title with blue background',
				command : 'blue',
				icon : this.path + 'blue.gif'
			});
		},

		requires : [ 'code' ]
	});
})();

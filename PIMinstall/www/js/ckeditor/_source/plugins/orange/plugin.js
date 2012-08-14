(function()
{
	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.getBlock(editor, 'outer_orange');
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'orange',	{
		init : function( editor ) {
			editor.addCommand( 'orange', commandObject );
			editor.ui.addButton( 'Orange', {
				label : 'small text with orange background',
				command : 'orange',
				icon : this.path + 'orange.gif'
			});
		},

		requires : [ 'code' ]
	});
})();

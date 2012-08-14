(function()
{
	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.getBlock(editor, 'outer_signature');
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'signature',	{
		init : function( editor ) {
			editor.addCommand( 'signature', commandObject );
			editor.ui.addButton( 'Signature', {
				label : 'blue signature',
				command : 'signature',
				icon : this.path + 'signature.gif'
			});
		},

		requires : [ 'code' ]
	});
})();

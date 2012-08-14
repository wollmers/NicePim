(function()
{
	var commandObject =	{
		exec : function( editor )	{
			CKEDITOR.dom.getBlock(editor, 'outer_title_orange');
			editor.focus();
		}
	};

	CKEDITOR.plugins.add( 'title_orange',	{
		init : function( editor ) {
			editor.addCommand( 'title_orange', commandObject );
			editor.ui.addButton( 'TitleO', {
				label : 'title with orange background',
				command : 'title_orange',
				icon : this.path + 'title_orange.gif'
			});
		},

		requires : [ 'code' ]
	});
})();

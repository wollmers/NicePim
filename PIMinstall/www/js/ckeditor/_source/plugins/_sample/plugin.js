/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

/**
 * @file Code plugin.
 */

(function(){
	var pluginName = 'code';
	CKEDITOR.plugins.add( pluginName,{
		init:function(editor)	{
			editor.addCommand(pluginName,new CKEDITOR.dialogCommand('code'));

			CKEDITOR.dialog.add(pluginName, this.path + 'dialogs/code.js');

			editor.ui.addButton( 'Code',{
				label : 'tralala',
				command : pluginName,
				icon : this.path + 'logo.gif'
			});
		}
	});
})();

CKEDITOR.plugins.add('drupalhelp', {
	init:function(editor) {
		editor.addCommand('drupalhelp', new CKEDITOR.dialogCommand('drupalhelp'));
		editor.ui.addButton('DrupalHelp', {
			label:Drupal.t('Help'),
			icon:this.path + 'images/drupalhelp.gif',
			command:'drupalhelp'
		});

		CKEDITOR.dialog.add('drupalhelp', this.path + 'dialogs/help.js');
		if (editor.addMenuItems) {
			editor.addMenuItems( {
				drupalhelp:{
					label:Drupal.t('Help'),
					command:'drupalhelp',
					group:'drupalhelp',
					order:1
				}
			});
		}
	}
});

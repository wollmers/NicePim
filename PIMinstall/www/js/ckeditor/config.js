/*
Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/


CKEDITOR.editorConfig = function( config )
{

	// Define changes to default configuration here. For example:
	config.uiColor	=	'#99ccff';
	config.width = '900';
	config.height = '480';
	config.removePlugins	=	'elementspath';
	config.extraPlugins += (config.extraPlugins?',code':'code');
	CKEDITOR.plugins.addExternal('code', 'http://' + location.hostname + '/js/ckeditor/plugins/sample/');
	config.extraPlugins += (config.extraPlugins?',title_orange':'title_orange');
	CKEDITOR.plugins.addExternal('title_orange', 'http://' + location.hostname + '/js/ckeditor/plugins/title_orange/');
	config.extraPlugins += (config.extraPlugins?',blue':'blue');
	CKEDITOR.plugins.addExternal('blue',  'http://' + location.hostname + '/js/ckeditor/plugins/blue/');
	config.extraPlugins += (config.extraPlugins?',text':'text');
	CKEDITOR.plugins.addExternal('text',  'http://' + location.hostname + '/js/ckeditor/plugins/text/');
	config.extraPlugins += (config.extraPlugins?',orange':'orange');
	CKEDITOR.plugins.addExternal('orange',  'http://' + location.hostname + '/js/ckeditor/plugins/orange/');
	config.extraPlugins += (config.extraPlugins?',signature':'signature');
	CKEDITOR.plugins.addExternal('signature',  'http://' + location.hostname + '/js/ckeditor/plugins/signature/');


	config.toolbar_MyPanel = [
		['Undo','Redo','Source','Maximize','-','RemoveFormat','SelectAll','Paste','PasteText','PasteFromWord','-','Templates','Image','Table','Link','Unlink','HorizontalRule','TitleO', 'Blue', 'Text', 'Orange', 'Signature'],
		'/',
		['Bold','Italic','Strike','SpecialChar','-','Blockquote','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','-','Format']
	];

	config.toolbar	=	'MyPanel';

//	config.toolbar	=	'Full';
	
};

CKEDITOR.dialog.add(
	'code', function(editor){
		return{
			title:'Code',
			minWidth:400,
			minHeight:200,
			contents:[{
				id:'tab1',
				label:'First Tab',
				title:'First Tab',
				elements:[{
					type:'html',
					id:'content',
					html:'<select size="1" name="chili">'+
					'<option value="code">Header</option>'+
					'<option value="php">Footer</option>'+
					'<option value="php-f">Orange</option>'+
					'<option value="mysql">Title Orange</option>'+
					'<option value="lotusscript">Title Blue</option>'+
					'<option value="js">Text</option>'+
					'<option value="java">Signature</option>'+
					'</select>',
					validate:function(){
						CKEDITOR.config.chili_val=this.getValue();
					}
				},
				{
					id:'input1',
					type:'textarea',
					label:'yapooo',
					validate:function()	{
						if (!this.getValue()){
							var selection = CKEDITOR.instances.editor1.getSelection();
							alert( selection.getType() );
							return false;
						}
						if(CKEDITOR.config.chili_val=='code'){
							var element=editor.document.createElement('div');
							element.setAttribute('class','code');
							element.setText(this.getValue());
						}else{
							var element= editor.document.createElement('div');
				      element.setAttribute('class', 'highlight');
				      var element2= editor.document.createElement('pre');
				      element2.setAttribute('class', CKEDITOR.config.chili_val);
				      element2.setText(this.getValue());
				      element2.appendTo(element);
						}
						editor.insertElement(element);
						CKEDITOR.ENTER_BR;
						return true;
					}
				}]
			}]
		};
	}
);

window.addEvent('domready', function() {

	buttons = $$('.hover_button');

	buttons.addEvent('mouseover',function() {
			if ($(this).tagName.toLowerCase() == 'img') {
					bgImageUrl = /\/button_(.*)\.gif/.exec($(this).src);
					$(this).setStyle('cursor',"pointer");
					$(this).src = "img/campaign_def/button_"+bgImageUrl[1]+"_act.gif";
			}
			else {
					bgImageUrl = /\/button_(.*)\.gif/.exec($(this).getStyle('background-image'));
					$(this).setStyle('cursor',"pointer");
					$(this).setStyle('background-image',"url(img/campaign_def/button_"+bgImageUrl[1]+"_act.gif)");
			}
	});

	buttons.addEvent('mouseout',function() {
			if ($(this).tagName.toLowerCase() == 'img') {
					bgImageUrl = /\/button_(.*)_act\.gif/.exec($(this).src);
					$(this).src = "img/campaign_def/button_"+bgImageUrl[1]+".gif";
			}
			else {
					bgImageUrl = /\/button_(.*)_act\.gif/.exec($(this).getStyle('background-image'));
					$(this).setStyle('background-image',"url(img/campaign_def/button_"+bgImageUrl[1]+".gif)");
			}
	});

});

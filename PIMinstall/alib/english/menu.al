{
name: menu;

general_names: PRODUCTS, CATEGORIES, GROUPS, BRANDS, SOURCES, USERS, COUNTRIES, FEATURES, MEASURES, REQUESTS, RATING, COMPLAINT, CAMPAIGNS
general_mis: products, cats, groups, suppliers, datas, users, countries, features, measures, requests, products_raiting, products_complaint, campaigns;
general_tmpls:products.html, cats.html, feature_groups.html, suppliers.html, data_sources.html, auth.html, countries.html, features.html, measures.html, requests.html, products_raiting.html, products_complaint.html, campaigns.html;

restrict_supplier: requests, datas, countries, features, measures, products_raiting, products_complaint, cats, groups;

general_indicator: mi;


general_item_sel: <td class="%%prefix%% active">
	<div class="wrap">
		<a href="%%base_url%%;tmpl=%%tmpl%%;%%indicator%%=%%item%%;reset_search=1" class="linkmenu">%%name%%</a>
		<div class="leftbord"></div><div class="rightbord"></div>
	</div>
</td>
general_item: <td class="%%prefix%%">
	<div class="wrap">
		<a href="%%base_url%%;tmpl=%%tmpl%%;%%indicator%%=%%item%%;reset_search=1" class="linkmenu">%%name%%</a>
		<div class="leftbord"></div><div class="rightbord"></div>
	</div>
</td>

general_body:
<div id="page_header">
	<table cellspacing="0" id="main-menu">
		<tr> 
			%%items%%
		</tr>
	</table>
	<div id="bg_dots"></div>
</div>

}

{
name: menu2;


restrict_supplier: requests, datas, countries, features, measures, products_raiting, products_complaint, cats, groups;

general_indicator: mi;

left_indicator: &nbsp;&lt;
right_indicator: &nbsp;&gt;

general_item_sel: <td id="menu_%%name%%" width="82px" height="43px" class="menu"  style="padding-top: 23px;text-align: left;background-image: url(/img/menu_active_icecat.gif);" onmouseover="expand(this,0,'menu_%%name%%',%%is_left%%);" onmouseout="collapse(this);">
			   	<center><a href="%%url%%" class="menu" style="color: #eb8c00" >%%name%%</a></center>			   	
		      	     <div class="menuNormal"  width="%%width%%" style="float: left; position: absolute;margin-top: 5px; " >
				        <table width="%%width%%" cellpadding="0" cellspacing="0" style="border: 1px solid gray;border-top: none;">
				
general_item: <td id="menu_%%name%%" width="82px" height="43px" class="menu"  onmouseover="expand(this,0,'menu_%%name%%',%%is_left%%);" onmouseout="collapse(this);">
			   	<center><a href="%%url%%" class="menu" >%%name%%</a></center>			   	
		      	     <div class="menuNormal"   width="%%width%%" style="float: left; position: absolute;margin-top: 4px;" >
				        <table width="%%width%%" cellpadding="0" cellspacing="0" style="border: 1px solid gray; border-top: none;">
			  

menu_item: <tr><td class="menuNormal" style="text-align: center;"><div class="menu_link_container" style=""  onmouseover="submenu_color(this,'set');" onmouseout="submenu_color(this,'remove');"><a class="submenu_link" href="%%url%%">%%name%%</a></div></td></tr>;

menu_container: <tr><td class="menuNormal" width="%%width%%" onmouseover="expand(this,2,'menu_%%name%%',%%is_left%%);" onmouseout="collapse(this);">
				     <center style="height: 20px" onmouseover="submenu_color(this,'set');" onmouseout="submenu_color(this,'remove');"  class="parent_menu_link_container menu_link_container" >
				     		<a href="%%url%%" class="submenu_link">%%left_indicator%% %%name%% %%right_indicator%%</a>
				     </center>
				     <div class="menuNormal"  width="%%width%%" style="float: left;z-index:150; position: absolute;" >
				        <table  width="%%width%%" cellpadding="0" cellspacing="0" style="border: 1px solid gray;" >

 				 
menu_config: <root>
				<menu id="products" name="Products" width="140px" url="%%base_url%%;tmpl=products.html;mi=products;reset_search=1">
					<menu id="menu1" name="Product maps" 	    width="140px" url="%%base_url%%;tmpl=product_maps.html;mi=products"/>
					<menu id="menu2" name="Product relations"   width="140px" url="%%base_url%%;tmpl=relation_groups.html;mi=products"/>
					<menu id="menu3" name="Invalid partnumbers" width="140px" url="%%base_url%%;tmpl=brand_invalid_partnumbers.html;mi=products"/>
					<menu id="menu3" name="Quicktest"           width="140px" url="%%base_url%%;tmpl=quicktest.html;mi=products" restrict="hide_from_all_groups_except(['superuser'])"/>
					<menu id="menu4" name="New product"          width="140px" url="%%base_url%%;tmpl=product_new.html;mi=products" />					
				</menu>
				<menu id="cats" name="Categories" width="180px" url="%%base_url%%;tmpl=cats.html;mi=cats;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="cat_feat_batch" width="250px" name="Batch feature assignment" url="%%base_url%%;tmpl=cat_feat_batch.html;mi=cats"/>
					<menu id="Merge" width="250px" name="Merge" url="%%base_url%%;tmpl=categories_merge.html;mi=cats"/>
				</menu>
				<menu id="groups" name="Groups" width="160px" url="%%base_url%%;tmpl=feature_groups.html;mi=groups;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="feature_values_groups" width="180px" name="Feature value groups" url="%%base_url%%;mi=groups;tmpl=feature_values_groups.html;mi=groups"/>
					<menu id="feature_groups_exp_imp" width="180px" name="Import/export languages" url="%%base_url%%;mi=groups;tmpl=feature_groups_exp_imp.html;mi=groups"/>					
				</menu>
				<menu id="suppliers" name="Brands" width="160px" url="%%base_url%%;tmpl=suppliers.html;mi=suppliers;reset_search=1">
					<menu id="default_warranty_info" width="180px" name="Default warranty" url="%%base_url%%;mi=suppliers;tmpl=default_warranty_info.html;mi=suppliers"/>
					<menu id="product_restrictions" width="180px" name="Product restrictions" url="%%base_url%%;mi=suppliers;tmpl=product_restrictions.html;mi=suppliers"/>										
				</menu>
				<menu id="datas" name="Sources" url="%%base_url%%;tmpl=data_sources.html;mi=datas;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="data_source" width="100px" name="New source" url="%%base_url%%;tmpl=data_source.html;mi=datas;"/>
					<menu id="Distributors" width="100px" name="Distributors" url="%%base_url%%;mi=datas;tmpl=distributors.html;mi=datas;">
						<menu id="distributor_new" width="250px" name="New distributor" url="%%base_url%%;tmpl=distributor_new.html;mi=datas;"/>
					</menu>
				</menu>
				<menu id="users" name="Users" width="102px" url="%%base_url%%;tmpl=auth.html;mi=users;reset_search=1">
					<menu id="editor_journal_list" width="100px" name="Editor journal" url="%%base_url%%;tmpl=editor_journal_list.html;mi=users;" restrict="hide_from_groups(['supplier','guest','shop'])" />
					<menu id="mail_dispatch_edit" width="100px" name="Mailer" url="%%base_url%%;tmpl=mail_dispatch_edit.html;mi=users;" restrict="hide_from_all_groups_except(['superuser','supereditor','category_manager'])">
						<menu id="mail_dispatch_log" width="100px" name="Mailing log" url="%%base_url%%;tmpl=mail_dispatch_log.html;mi=users;" restrict="hide_from_all_groups_except(['superuser','supereditor','category_manager'])"/>
					</menu>
					<menu id="platforms" width="100px" name="Platforms" url="%%base_url%%;tmpl=platforms.html;mi=users;" restrict="hide_from_all_groups_except(['superuser'])"/>
					<menu id="Sectors" width="100px" name="Sectors" url="%%base_url%%;tmpl=sectors.html;mi=users;" restrict="hide_from_all_groups_except(['superuser'])"/>
				</menu>
				<menu id="countries" name="Countries" width="200px" url="%%base_url%%;tmpl=countries.html;mi=countries;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="blacklist" width="180px" name="Blacklist words" url="%%base_url%%;tmpl=blacklist.html;mi=countries;"/>
					<menu id="backup_language_config" width="180px" name="Backup language configurator" url="%%base_url%%;tmpl=backup_language_config.html;mi=countries;"/>
					<menu id="dictionaries" width="198px" name="Dictionary" url="%%base_url%%;tmpl=dictionaries.html;mi=countries;">
						<menu id="dictionary" width="100px" name="New dictionary" url="%%base_url%%;mi=countries;tmpl=dictionary.html;mi=countries;"/>						
					</menu>
					<menu id="country_edit" width="180px" name="New country" url="%%base_url%%;tmpl=country_edit.html;mi=countries;"/>
				</menu>
				<menu id="features" name="Features" is_left="true" url="%%base_url%%;tmpl=features.html;mi=features;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="features_merge" width="180px" name="Merge features" url="%%base_url%%;tmpl=features_merge.html;mi=features;"/>
					<menu id="feature_values_vocabulary" width="180px" name="Feature values vocabulary" url="%%base_url%%;tmpl=feature_values_vocabulary.html;mi=features;">
						<menu id="feature_value_edit" width="155px" name="New feature value" url="%%base_url%%;tmpl=feature_value_edit.html;mi=features;"/>
						<menu id="feature_values_groups" width="179px" name="Feature value groups" url="%%base_url%%;mi=groups;tmpl=feature_values_groups.html;mi=features;">
							<menu id="feature_values_group" width="100px" name="New feature values group" url="%%base_url%%;tmpl=feature_values_group.html;mi=features;"/>
						</menu>
					</menu>
					<menu id="feature_input_types" width="180px" name="Feature input types" url="%%base_url%%;tmpl=feature_input_types.html;mi=features;">
						<menu id="feature_input_type" width="180px" name="New input type" url="%%base_url%%;tmpl=feature_input_type.html;mi=features;"/>						
					</menu>
					<menu id="generic_operations" width="180px" name="Generic operations" url="%%base_url%%;tmpl=generic_operations.html;mi=features;">
						<menu id="generic_operation" width="180px" name="New generic operation" url="%%base_url%%;tmpl=generic_operation.html;mi=features;"/>
					</menu>
					<menu id="measures" name="Units" width="120px" url="%%base_url%%;tmpl=measures.html;mi=features;reset_search=1" restrict="hide_from_groups(['supplier'])">
						<menu id="New unit" width="100px" name="New measure" url="%%base_url%%;tmpl=measure_edit.html;mi=features;"/>
					</menu>					
					<menu id="power_mappings" width="180px" name="Power mappings" url="%%base_url%%;tmpl=power_mappings.html;mi=features;"/>
					<menu id="feature" width="180px" name="New feature" url="%%base_url%%;tmpl=feature.html;tmpl_if_success_cmd=features.html;mi=features;"/>
				</menu>
				<menu id="requests" name="Statistics" is_left="true" url="%%base_url%%;tmpl=requests.html;mi=requests;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="cov_products_reports1" name="Features coverage reports" url="%%base_url%%;mi=coverage;tmpl=cov_features_reports.html;mi=requests;"/>					
					<menu id="cov_products_reports" width="202px" name="Products coverage reports" url="%%base_url%%;mi=coverage;tmpl=cov_products_reports.html;mi=requests;">
						<menu id="feed_coverage" 	    width="200px"  name="Coverage report from file" url="%%base_url%%;mi=requests;tmpl=feed_coverage.html;mi=requests;"/>
						<menu id="cov_distri_reports"   width="200px"  name="Distributor coverage report" url="%%base_url%%;mi=coverage;tmpl=cov_distri_reports.html;mi=requests;"/>
						<menu id="cov_features_reports" width="200px"  name="Features coverage reports" url="%%base_url%%;mi=coverage;tmpl=cov_features_reports.html;mi=requests;"/>						
					</menu>
					<menu id="stock_reports" name="Stock reports" url="%%base_url%%;mi=coverage;tmpl=stock_reports.html;mi=requests;"/>
					<menu id="track_lists" name="User lists" width="201px" url="%%base_url%%;mi=coverage;tmpl=track_lists.html;mi=requests;">
						<menu id="track_products_all" width="200px"  name="Browse Part code rules" url="%%base_url%%;mi=track_lists;tmpl=track_products_all.html;mi=requests;" restrict="hide_from_all_groups_except(['superuser','supereditor'])"/>
						<menu id="track_list_id" width="200px"  name="Add new list" url="%%base_url%%;mi=track_lists;tmpl=track_list.html;track_list_id=;mi=requests;" restrict="hide_from_all_groups_except(['superuser','supereditor'])"/>
						<menu id="track_list_entrusted_editors" width="200px"  name="Entrusted editors" url="%%base_url%%;tmpl=track_list_entrusted_editors.html;mi=requests;" restrict="hide_from_all_groups_except(['superuser','supereditor'])"/>
						<menu id="track_list_supplier_map" width="200px"  name="Brand mapping" url="%%base_url%%;tmpl=track_list_supplier_map.html;mi=requests;" restrict="hide_from_all_groups_except(['superuser','supereditor'])"/>
					</menu>
					<menu id="Scheduled queries" name="Scheduled queries" url="%%base_url%%;mi=coverage;tmpl=stat_queries.html;mi=requests;"/>
					
				</menu>
				<!--menu id="products_raiting" width="100px" name="Rating" url="%%base_url%%;tmpl=products_raiting.html;mi=products_raiting;reset_search=1" restrict="hide_from_groups(['supplier'])">
					<menu id="products_raiting" width="100px" name="Rating formula" url="%%base_url%%;tmpl=product_rating_conf.html;html;mi=products_raiting"/>
				</menu-->
				<!--menu id="products_complaint" name="Complaint" url="%%base_url%%;tmpl=products_complaint.html;mi=products_complaint;reset_search=1" restrict="hide_from_groups(['supplier'])">
					
				</menu-->
				<!--menu id="campaigns" name="Campaigns" url="%%base_url%%;tmpl=campaigns.html;mi=campaigns;reset_search=1" width="83px">
					<menu id="tmpl=campaign_kit" width="300px" name="New" url="%%base_url%%;tmpl=campaign_kit.html;mi=campaigns;"/>
				</menu-->
				
			  </root>
general_body:
<script type="text/javascript" src="/js/common.js"></script>
<table width="100%" height="70px" cellpadding="0" cellspacing="0">
	<tr>
		<!-- LOGO -->
		<td valign="top" ><a href="/"><img border=0 width="181px" height="70px" src="/img/logo_icecat.png" alt="IceCat.biz cool in catalogues."></a></td>
		<td valign="top" width="100%" >
			
			<table cellspacing="0" cellspacing="0" width="100%" height="70px" >
				<tr>
					<td align="right" valign="top" background="/img/top_bg.gif" width="100%" height="43px" style="padding:0;">
						<table cellpadding="0" cellspacing="0" height="43px" style="">
							<tr>
								%%items%%
							</tr>
						</table>
					</td>
				</tr>
			</table>
			
		</td>
	</tr>
</table>


}

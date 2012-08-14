{
name: ajax_product_features_local;

body:
<script type="text/javascript">
	call('get_local_feature','tag_id=id_feat_tab_id_%%tab_id%%;foo=bar','sessid=%%sessid%%;tmpl=product_features_local_ajax.html;product_id=%%product_id%%;cproduct_id=%%product_id%%;langid=%%tab_id%%;lang_tab=%%tab_id%%');
	white_bg('tab_id_%%tab_id%%', 'feat_');
</script>
}


function get_family_do_next_request() {
    
    try {
        // var supplier_id = document.getElementByName('supplier_id').value;
        // var supplier_id = document.getElementsByName('supplier_id')[0].value;
        var supplier_id = document.getElementsByName('supplier_id')[0].value;
        
    } catch (e) {
        // alert('No supplier id');
        return;
    }
    
    try {
        var category_id = document.getElementById('catid').value;
    } catch (e) {
        // alert('No category id');
        return;
    }
    
    if (category_id == 0) return;
    
    // alert('SUPPLIER_ID = (' + supplier_id +  ') CAT_ID = (' + category_id + ')');
    session_id = document.getElementsByName('sessid')[0].value;
    // alert('SID = ' + session_id);
    
    // create AJAX request
    var tmp1_local = 'tag_id=family_id;supplier_id=' + supplier_id + ';foo=bar;field_name=family_id;category_id=' + category_id;
    var tmp2_local = 'sessid=' + session_id + ';tmpl=ajax_get_product_families.html';
    
    call('get_product_families', tmp1_local, tmp2_local);
    
}

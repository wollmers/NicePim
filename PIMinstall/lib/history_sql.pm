package history_sql;

use strict;
use warnings;

use atomsql;
use atomlog;

use Data::Dumper;

BEGIN {
    use Exporter;
    our @ISA;
    our @EXPORT;
    @ISA = qw(Exporter); 
    @EXPORT = qw(
        get_certain_product
        get_previous_product
        get_previous_ej_id_for_fake
        insert_into_ej_product
        
        get_certain_product_name
        get_previous_product_name
        get_previous_ej_id_for_fake_name
        insert_into_ej_product_name
        
        get_certain_product_feature
        insert_into_ej_product_feature_pack
        
        get_certain_product_feature_local
        insert_into_ej_product_feature_local_pack
        
        get_certain_product_description
        get_previous_product_description
        get_previous_ej_id_for_fake_description
        insert_into_ej_product_description
        
        get_certain_product_mmo
        get_previous_product_mmo
        get_previous_ej_id_for_fake_mmo
        insert_into_ej_product_mmo
        
        insert_into_ej
    );
}

my $hdebug = 1;

# ----------------------------------------------------------------------------------------
# editor_journal_product
# ----------------------------------------------------------------------------------------

sub get_certain_product {
    my $id = shift;

    my $ans = do_query("
        SELECT supplier_id, prod_id, catid, user_id, name,
        low_pic, high_pic, publish, public, thumb_pic,
        family_id, series_id, checked_by_supereditor
        FROM product
        WHERE product_id = " . $id
    );
    return $ans;
}

sub get_previous_product {
    my $date = shift;
    my $id = shift;
    
    # get previous if exists
    my $ans = do_query("
        SELECT ejp.supplier_id, ejp.prod_id, ejp.catid, ejp.user_id, ejp.name,
        ejp.low_pic, ejp.high_pic, ejp.publish, ejp.public, ejp.thumb_pic,
        ejp.family_id, ejp.series_id, ejp.checked_by_supereditor
        FROM editor_journal ej
        INNER JOIN editor_journal_product ejp ON (ej.content_id = ejp.content_id)
        WHERE date <= $date
        AND ej.product_table = 'product'
        AND product_table_id = $id
        ORDER BY date DESC LIMIT 1
    ");

    return $ans;
}

sub get_previous_ej_id_for_fake {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT id
        FROM editor_journal
        WHERE product_table_id = $id
        AND product_table = 'product'
        AND date <= $date
        ORDER BY date DESC LIMIT 1
    ")->[0]->[0];
    
    return $ans;
}

sub insert_into_ej_product {
    my $p = shift;

    do_statement("
        INSERT INTO editor_journal_product (
            supplier_id,
            prod_id,
            catid,
            user_id,
            name,
            low_pic,
            high_pic,
            publish,
            public,
            thumb_pic,
            family_id,
            series_id,
            checked_by_supereditor
        )
        VALUES (" .
        $p->[0]->[0] . ", " .
        str_sqlize($p->[0]->[1]) . ", " .
        $p->[0]->[2] . ", " .
        $p->[0]->[3] . ", " .
        str_sqlize($p->[0]->[4]) . ", " .
        str_sqlize($p->[0]->[5]) . ", " .
        str_sqlize($p->[0]->[6]) . ", " .
        str_sqlize($p->[0]->[7]) . ", " .
        str_sqlize($p->[0]->[8]) . ", " .
        str_sqlize($p->[0]->[9]) . ", " .
        $p->[0]->[10] . ", " .
        $p->[0]->[11] . ", " .
        $p->[0]->[12] . ")
    ");
    return;
}

# ----------------------------------------------------------------------------------------
# editor_journal_name
# ----------------------------------------------------------------------------------------

sub get_certain_product_name {
    my $id = shift;
    
    my $ans = do_query("
        SELECT name, langid, product_name_id 
        FROM product_name 
        WHERE product_name_id = " . $id 
    );
    return $ans;
}

sub get_previous_product_name {

    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT name
        FROM editor_journal ej
        INNER JOIN editor_journal_product_name ejpn ON (ej.content_id = ejpn.content_id)
        WHERE product_table_id = $id
        AND ej.product_table = 'product_name'
        AND date <= $date
        ORDER BY date DESC LIMIT 1
    ");
    return $ans;
}

sub get_previous_ej_id_for_fake_name {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT id FROM editor_journal
        WHERE product_table = 'product_name'
        AND date <= $date
        AND product_table_id = $id
        ORDER BY date DESC LIMIT 1
    ");
    return $ans->[0]->[0];
}

sub insert_into_ej_product_name {
    my $name = shift;
    my $langid = shift;

    do_statement("
        INSERT INTO editor_journal_product_name (name, langid)
        VALUES (" . str_sqlize($name) . ", $langid )"
    );
    return;
}

# ----------------------------------------------------------------------------------------
# editor_journal_product_feature
# ----------------------------------------------------------------------------------------

sub get_certain_product_feature {
    my $id = shift;
    
    my $ans = do_query("
        SELECT pf.value, product_feature_id, category_feature_id
        FROM product_feature pf
        WHERE product_feature_id = $id
    ");
    return $ans;
}

sub insert_into_ej_product_feature_pack {
    my $ff = shift;
    
    do_statement("
        INSERT INTO editor_journal_product_feature_pack (data) 
        VALUES (" . str_sqlize($ff) . ")"
    );
    return;
}

# ----------------------------------------------------------------------------------------
# editor_journal_product_feature_local
# ----------------------------------------------------------------------------------------

sub get_certain_product_feature_local {
    my $id = shift;
    my $langid = shift;

    my $ans = do_query("
        SELECT value, product_feature_local_id, category_feature_id
        FROM product_feature_local
        WHERE product_feature_local_id = $id
        AND langid = $langid
    ");
    return $ans;
}

sub insert_into_ej_product_feature_local_pack {
    my $d = shift;

    do_statement("
        INSERT INTO editor_journal_product_feature_local_pack (data) 
        VALUES (" . str_sqlize($d) . ")"
    );
    return;
}


# ----------------------------------------------------------------------------------------
# editor_journal_product_description
# ----------------------------------------------------------------------------------------

sub get_certain_product_description {
    my $id = shift;

    my $ans = do_query("
        SELECT langid, short_desc, long_desc, official_url, warranty_info, pdf_url, manual_pdf_url
        FROM product_description
        WHERE product_description_id = $id
    ");
    return $ans;
}

sub get_previous_product_description {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT ejpd.langid, ejpd.short_desc, ejpd.long_desc, ejpd.official_url, ejpd.warranty_info, ejpd.pdf_url, ejpd.manual_pdf_url
        FROM editor_journal ej
        INNER JOIN editor_journal_product_description ejpd ON (ej.content_id = ejpd.content_id)
        WHERE date <= $date
        AND product_table_id = $id
        AND ej.product_table = 'product_description'
        ORDER BY date DESC LIMIT 1
    ");
    return $ans;
}

sub get_previous_ej_id_for_fake_description {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT id
        FROM editor_journal
        WHERE product_table = 'product_description'
        AND date <= $date
        AND product_table_id = $id
        ORDER BY date DESC LIMIT 1
    ")->[0]->[0];
    return $ans;
}

sub insert_into_ej_product_description {
    my $d = shift;

    do_statement("
        INSERT INTO editor_journal_product_description
        (langid, short_desc, long_desc, official_url, warranty_info, pdf_url, manual_pdf_url)
        VALUES (" .
        $d->[0]->[0] . ", " .
        " " . str_sqlize($d->[0]->[1]) . ", " .
        " " . str_sqlize($d->[0]->[2]) . ", " .
        " " . str_sqlize($d->[0]->[3]) . ", " .
        " " . str_sqlize($d->[0]->[4]) . ", " .
        " " . str_sqlize($d->[0]->[5]) . ", " .
        " " . str_sqlize($d->[0]->[6]) . " ) "
    );
    return;
}

# ----------------------------------------------------------------------------------------
# editor_journal_product_mmo
# ----------------------------------------------------------------------------------------

sub get_certain_product_mmo {
    my $id = shift;

    my $ans = do_query("
        SELECT short_descr, langid, content_type, keep_as_url, type, link
        FROM product_multimedia_object 
        WHERE id = $id
    ");
    return $ans;
}

sub get_previous_product_mmo {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT mm.short_descr, mm.langid, mm.content_type, mm.keep_as_url, mm.type, mm.link
        FROM editor_journal ej
        INNER JOIN editor_journal_product_multimedia_object mm ON (ej.content_id = mm.content_id)
        WHERE date <= $date
        AND ej.product_table = 'product_multimedia_object'
        AND product_table_id = $id
        ORDER BY date DESC LIMIT 1
    ");
    return $ans;
}

sub get_previous_ej_id_for_fake_mmo {
    my $date = shift;
    my $id = shift;

    my $ans = do_query("
        SELECT id FROM editor_journal
        WHERE product_table = 'product_multimedia_object'
        AND date <= $date
        AND product_table_id = $id
        ORDER BY date DESC LIMIT 1
    ")->[0]->[0];
    return $ans;
}

sub insert_into_ej_product_mmo {
    my $d = shift;

    do_statement("
        INSERT INTO editor_journal_product_multimedia_object
        (short_descr, langid, content_type, keep_as_url, type, link)
        VALUES (" .
            str_sqlize($d->[0]->[0]) . ", " .
            $d->[0]->[1] . ", " .
            str_sqlize($d->[0]->[2]) . ", " .
            str_sqlize($d->[0]->[3]) . ", " .
            str_sqlize($d->[0]->[4]) . ", " .
            str_sqlize($d->[0]->[5]) . "
        )
    ");
    return;
}

sub insert_into_ej {
    my $ej = shift;
    
    my $user_id = $ej->{'user_id'};
    my $product_table = $ej->{'product_table'};
    my $product_table_id = $ej->{'product_table_id'};
    my $date = $ej->{'date'};
    my $product_id = $ej->{'product_id'};
    my $supplier_id = $ej->{'supplier_id'};
    my $prod_id = $ej->{'prod_id'};
    my $catid = $ej->{'catid'};
    my $score = $ej->{'score'};
    my $action_type = $ej->{'action_type'};
    my $content_id = $ej->{'content_id'};
    
    do_statement("
         INSERT INTO editor_journal (user_id, product_table, product_table_id, date,product_id, supplier_id, prod_id, catid, score, action_type, content_id)
         VALUES (" .
            $user_id . ", " .
            str_sqlize($product_table) . ", " .
            $product_table_id . ", " .
            $date . ", " .
            $product_id . ", " .
            $supplier_id . ", " .
            str_sqlize($prod_id) . ", " .
            $catid . ", " .
            $score . ", " .
            $action_type . ", " .
            $content_id . ")
    ");
    return;
}

1;

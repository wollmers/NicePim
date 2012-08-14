package atomcfg_history;

use strict;

our $history_config_ref;

BEGIN {
    use Exporter;
    our @ISA;
    our @EXPORT;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        $history_config_ref
    );
}
    # SQL expressions allowed instead field name

    $history_config_ref = {
        product => [
            'high_pic_origin',
        ],
        product_gallery => [
            'link_origin',
        ],
        product_multimedia_object => [
            'link_origin',
        ],
        product_description => [
            'pdf_url_origin',
            'manual_pdf_url_origin',
        ],
    };

1;

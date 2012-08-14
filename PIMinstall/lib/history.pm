package history;

use strict;
use warnings;

use atomcfg_history;
use atomsql;
use atomlog;
use serialize_data;

use Data::Dumper;
use Log::Dispatch;

use constant CUSTOM_HISTORY_LOG => '/home/gcc/logs/custom_history.log';

# local log to manage custom history fields
my $hlog;

BEGIN {
    use Exporter;
    our @ISA;
    our @EXPORT;
    @ISA = qw(Exporter); 
    @EXPORT = qw(
        get_custom_data
        add_custom_data
        get_and_unpack_custom_data
    );
}

sub get_custom_data {
    my $table = shift;
    my $id_name = shift;
    my $id_value = shift;
    
    my @fields = get_custom_history_fields($table);
    my $fields = join(',', @fields );
    my $log = get_hlog();
    
    my $st = "SELECT $fields \n FROM $table \n WHERE $id_name = $id_value";
    my $ans = do_query($st);
    
    # log_printf("---------------------------------");
    # log_printf($st);
    # log_printf("---------------------------------");
    
    # add field name to each custom value
    my %res;
    my $ptr = 0;
    foreach (@fields) {
        $res{$_} = $ans->[0]->[$ptr];
        $ptr++;
    }
    
    # $log->info("[...] " . Dumper(\%res));
    
    return \%res;
}

sub get_custom_history_fields {
    my $table = shift;
    
    my @res = ();
    my $tmp = $history_config_ref->{$table};
    foreach my $f (@$tmp) {
        push @res, $f;
    }
    
    return @res;
}

sub add_custom_data {
    
    my $table = shift;
    my $content_id = shift;
    my $data = shift;
    
    my $log = get_hlog();
    
    if (! $table) {
        $log->info("[ERROR] No table name -- no insertion");
        return;
    }
    if (! $content_id) {
        $log->info("[ERROR] No content_id -- no insertion");
        return;
    }
    
    my $st = "
        INSERT INTO editor_journal_custom (table_name, content_id, data) 
        VALUES (" . str_sqlize($table) . ", $content_id, " . str_sqlize(ser_pack($data)) . ")";
    do_statement($st);
    
    $log->info("[PUT] " . Dumper($data));
    
    return;
}

sub get_and_unpack_custom_data {
    my $table = shift;
    my $content_id = shift;
    
    my $log = get_hlog();
    
    if (! $content_id) {
        $log->info("[ERROR] No content_id -- no selection");
        return {};
    }
    
    # result is a reference to hash
    my $q= "
        SELECT data
        FROM editor_journal_custom
        WHERE table_name = " . str_sqlize($table) . " AND content_id = $content_id
    ";
   
    my $ans = do_query($q);
    $log->info("[GET] " . Dumper($q));
   
    if ($ans) {
         return ser_unpack($ans->[0]->[0]);
    } 
    else {
         return {};
    }
}

sub get_hlog {
    
    return $hlog if ($hlog);

    $hlog = Log::Dispatch->new( 
        outputs => [
            [
                'File',
                min_level => 'info',
                filename => CUSTOM_HISTORY_LOG,
                mode => '>>',
                callbacks => sub {
                    my %h = @_;
                    $h{'message'} =~ s/\n/ /g;
                    $h{'message'} =~ s/\s{1,}/ /g;
                    return sprintf("%s\n", $h{'message'});
                }
            ]
        ]
    );
    return $hlog;
}

1;

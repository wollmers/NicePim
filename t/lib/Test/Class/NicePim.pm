package Test::Class::NicePim;

use strict;
use warnings;

use base qw(Test::Class);
use Test::More;
use File::Basename;

sub setup :Test(setup => 4) {
    my $base_path = dirname(__FILE__) . '/../../../';

    # TODO: reproduce context-setup Error
    #XXX print '__FILE__: ', __FILE__, ' $base_path: ', $base_path, "\n";

    open my $config, '<', \(my $config_scalar = <<"EOT");
...
EOT

    local $SIG{__WARN__} = sub {
        # Config::IniFiles line 522.
        $_[0] =~ m{\A \Qstat() on unopened filehandle\E}xms ? () : warn @_;
    };

}

1;

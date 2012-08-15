package Test::Hyper;
use strict;
use warnings;
use Test::More;
use base qw(Test::Class::Hyper);
use Hyper::Singleton::Context;

sub setup :Test(startup => 2) {
    use_ok('Hyper');
    use_ok('Hyper::Singleton::CGI');
}

sub default_workflow :Test(2) {
    ok( my $hyper = Hyper->new() => 'object creation');
    Hyper::Singleton::CGI->singleton()->param(
        'service' => 'Minimal',
    );
    Hyper::Singleton::CGI->singleton()->param(
        'usecase' => 'One',
    );
    # ToDo: catch/check STDOUT
    { no warnings qw(redefine);
      *Hyper::Template::HTC::output = sub { return q{}; };
    }
    ok( $hyper->work() => 'start default workflow' );
}

1;

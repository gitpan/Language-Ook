#!perl
#

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new (
    module_name         => 'Language::Ook',
    dist_author         => 'Jerome Quelin <jquelin@cpan.org>',
    license             => 'gpl',
    dist_version_from   => 'lib/Language/Ook.pm',
    add_to_cleanup => [
                'Language-Ook-*',
                map { ( '*/' x $_ ) . '*~' } 0..3 ],
    build_requires => { },
    requires       => { },
);

$builder->create_build_script();

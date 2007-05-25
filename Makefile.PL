#!perl
#

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Language::Ook',
    AUTHOR              => 'Jerome Quelin <jquelin@cpan.org>',
    VERSION_FROM        => 'lib/Language/Ook.pm',
    ABSTRACT_FROM       => 'lib/Language/Ook.pm',
    PREREQ_PM           => {},
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => [
                'Language-Ook-*',
                map { ( '*/' x $_ ) . '*~' } 0..3
                ] },
);

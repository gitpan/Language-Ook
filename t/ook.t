#-*- cperl -*-
# $Id: ook.t,v 1.3 2003/02/22 19:08:20 jquelin Exp $
#

use strict;
use File::Spec::Functions;
use Language::Ook;
use POSIX qw! tmpnam !;
use Test;
BEGIN { plan tests => 2 };

# 

# Classic hello world.
my %tests = ( "hello.ook" =>  "Hello, world!\n",
              "test.ook"  =>  "1..1\nok 1\n",
            );
for my $f ( sort keys %tests ) {
    my $file = tmpnam();
    open OUT, ">$file" or die $!;
    my $fh = select OUT;
    my $interp = new Language::Ook;
    $interp->read_file( catfile( "src", $f ) );
    $interp->run_code;
    select $fh;
    close OUT;
    open OUT, "<$file" or die $!;
    my $content;
    {
        local $/;
        $content = <OUT>;
    }
    close OUT;
    unlink $file;
    ok( $content, $tests{$f} );
}

#-*- cperl -*-
# $Id: ook.t,v 1.2 2003/02/22 11:15:00 jquelin Exp $
#

use strict;
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
    $interp->read_file( $f );
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

#!perl
#
# This file is part of Language::Ook.
# Copyright (c) 2002-2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
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
    $interp->read_file( catfile( "examples", $f ) );
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

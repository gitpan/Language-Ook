#-*- cperl -*-
# $Id: ook.t,v 1.1.1.1 2002/10/06 09:07:49 jquelin Exp $
#

use strict;
use Language::Ook;
use POSIX qw! tmpnam !;
use Test;
BEGIN { plan tests => 6 };

# 

# Sanity checks.
eval { 
    my $interp = new Language::Ook;
    $interp->store_code( "Ook? Ook?" );
};
ok( $@, qr/^Unknown Ook instruction 'Ook\? Ook\?'/ );
eval { 
    my $interp = new Language::Ook;
    $interp->store_code( "Ook? blah blah Ook!" );
};
ok( $@, qr/^Syntax Ook error/ );
eval { 
    my $interp = new Language::Ook;
    $interp->store_code( "Ook! Ook?" );
};
ok( $@, qr/^Unmatched 'Ook! Ook\?'/ );
eval {
    my $interp = new Language::Ook;
    $interp->store_code( "Ook? Ook!" );
};
ok( $@, qr/^Unmatched 'Ook\? Ook!'/ );
eval {
    my $interp = new Language::Ook;
    $interp->store_code( "Ook? Ook! Ook! Ook?" );
};
ok( $@, qr/^Unmatched 'Ook\? Ook!'/ );

# Classic hello world.
my $file = tmpnam();
open OUT, ">$file" or die $!;
my $fh = select OUT;
my $interp = new Language::Ook;
$interp->read_file( "hello.ook" );
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
ok( $content, "Hello, world!\n");

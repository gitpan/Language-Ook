# $Id: Ook.pm,v 1.1.1.1 2002/10/06 09:07:49 jquelin Exp $
#
# Copyright (c) 2002 Jerome Quelin <jquelin@cpan.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#

package Language::Ook;

use v5.6;

=head1 NAME

Language::Ook - a Ook! interpreter.


=head1 SYNOPSIS

    use Language::Ook;
    my $interp = new Language::Ook( "program.ook" );
    $interp->run_code;


=head1 DESCRIPTION

A programming language should be writable and readable by orang-utans.
So Ook! is a programming language designed for orang-utans.

Ook! is bijective with BrainFuck, and thus, Turing-complete.

=cut


#---------------#
#   Includes.   #
#---------------#
use strict;
use warnings;
use Carp;

#----------------#
#   Variables.   #
#----------------#
our $VERSION = "0.01";
our %method = 
  ( "Ook. Ook?" => "mv_ptr_up",
    "Ook? Ook." => "mv_ptr_down",
    "Ook. Ook." => "inc_ptr",
    "Ook! Ook!" => "dec_ptr",
    "Ook. Ook!" => "read_cell",
    "Ook! Ook." => "print_cell",
    "Ook! Ook?" => "start_loop",
    "Ook? Ook!" => "end_loop" );


=head1 CONSTRUCTOR

=head2 new( [filename] )

Create a new Ook interpreter. If a filename is provided, then read
and store the content of the file in the cartesian Lahey space
topology of the interpreter.

=cut
sub new {
    # Create and bless the object.
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = 
      { cells => [0], # memory cells
        ptr   => 0,   # pointer to current memory cell
        code  => [],  # code to be executed
        ip    => 0,   # instruction pointer
      };
    bless $self, $class;

    # Read the file if needed.
    my $file = shift;
    defined($file) and $self->read_file( $file );

    # Return the object.
    return $self;
}


=head1 Public methods

=head2 read_file( filename )

Read a file (given as argument) and store its code.

Side effect: clear the previous code.

=cut

sub read_file {
    my ($self, $filename) = @_;

    # Fetch the code.
    my $code;
    open OOK, "<$filename" or croak "$filename: $!";
    {
        local $/; # slurp mode.
        $code = <OOK>;
    }
    close OOK;

    # Store code.
    $self->store_code( $code );
}


=head2 run(  )

Run the code stored.

=cut

sub run_code {
    my $self = shift;

    $self->{ptr} = 0;
    $self->{ip} = 0;
    while ( $self->{ip} < scalar( @{$self->{code}} ) ) {
        $self->tick;
    }
}


=head2 store_code( code )

Store the given code and check wether it is valid Ook! code.

=cut

sub store_code {
    my ($self, $code) = @_;

    my $depth = 0;

    # Parse code.
    $code =~ s/[\n\s]+/ /g;
    while ( $code =~ /(Ook[.?!] Ook[.?!])/g ) {
        exists $method{$1} or croak "Unknown Ook instruction '$1'";
        $depth++ if $1 eq "Ook! Ook?";
        $depth-- if $1 eq "Ook? Ook!";
        $depth < 0 and croak "Unmatched 'Ook? Ook!' instruction";
        push @{$self->{code}}, $1;  # store code.
    }

    # Sanity check.
    $depth != 0 and croak "Unmatched 'Ook! Ook?' instruction";
    $code =~ /(?<!Ook[?.!] )Ook[?.!] (?!Ook[?.!])/ and croak "Syntax Ook error";
}


=head2 tick(  )

Execute the next Ook instruction to be executed.

=cut

sub tick {
    my $self = shift;
    my $meth = $method{ $self->{code}[$self->{ip}] };
    $self->$meth;
    $self->{ip}++;
}

=head1 Private methods

Those methods should B<not> be called directly. Use at your own risks,
you've been warned!


=head2 dec_ptr(  )

Implement the C<Ook! Ook!> instruction.

=cut

sub dec_ptr {
    my $self = shift;
    $self->{cells}[$self->{ptr}]--;
}


=head2 end_loop(  )

Implement the C<Ook? Ook!> instruction.

=cut

sub end_loop {
    my $self = shift;

    # The current cell is null, so don't jump back.
    return if $self->{cells}[$self->{ptr}] == 0;

    # Cell is not null, so jump back to the beginning of the loop.
    my $i = $self->{ip};
    my $depth = 1;

    do {
        $i--;
        $depth++ if $self->{code}[$i] eq "Ook? Ook!";
        $depth-- if $self->{code}[$i] eq "Ook! Ook?";
    } until ( $depth == 0 );
    $self->{ip} = $i;
}


=head2 inc_ptr(  )

Implement the C<Ook. Ook.> instruction.

=cut

sub inc_ptr {
    my $self = shift;
    $self->{cells}[$self->{ptr}]++;
}


=head2 mv_ptr_down(  )

Implement the C<Ook? Ook.> instruction.

=cut

sub mv_ptr_down {
    my $self = shift;

    $self->{ptr}--;
    croak "Can't go beyond 0th element" if $self->{ptr} < 0;
}


=head2 mv_ptr_up(  )

Implement the C<Ook. Ook?> instruction.
Append new cells if the current cells aren't enough.

=cut

sub mv_ptr_up {
    my $self = shift;

    $self->{ptr}++;
    if ( scalar(@{$self->{cells}}) <= $self->{ptr} ) {
        push @{$self->{cells}}, (0)x 1024;
    }
}


=head2 print_cell(  )

Implement the C<Ook! Ook.> instruction.

=cut

sub print_cell {
    my $self = shift;
    print chr($self->{cells}[$self->{ptr}]);
}


=head2 read_cell(  )

Implement the C<Ook. Ook!> instruction.

=cut

sub read_cell {
    my $self = shift;
    $/ = \1;  # read only one char.
    $self->{cells}[$self->{ptr}] = ord( <STDIN> );
}


=head2 start_loop(  )

Implement the C<Ook! Ook?> instruction.

=cut

sub start_loop {
    my $self = shift;

    # The current cell is not null, so don't jump.
    return if $self->{cells}[$self->{ptr}] != 0;

    # Uh, cell is null: jump to end of loop.
    my $i = $self->{ip};
    my $depth = 1;

    do {
        $i++;
        $depth++ if $self->{code}[$i] eq "Ook! Ook?";
        $depth-- if $self->{code}[$i] eq "Ook? Ook!";
    } until ( $depth == 0 );
    $self->{ip} = $i;
}

1;
__END__

=head1 AUTHOR

Jerome Quelin, E<lt>jquelin@cpan.orgE<gt>


=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=head1 SEE ALSO

=over 4

=item L<http://www.dangermouse.net/esoteric/ook.html>

=back

=cut

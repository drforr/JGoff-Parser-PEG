package JGoff::Parser::PEG::VM;

use Moose;                # XXX May be removed later
use Function::Parameters; # XXX WIll probably be removed later

use Readonly;

has pc => ( is => 'rw', isa => 'Num', default => 0 );
has i => ( is => 'rw', isa => 'Num', default => 0 );
has e => ( is => 'rw' );

has S => ( is => 'ro', isa => 'Arr' );

method _push_backtrack ( $new_pc, $new_i ) {
  push @{ $self->e }, [ $new_pc, $new_i ];
}

method _push_fail ( ) {
  push @{ $self->e }, [ 'Fail' ];
}

method _pop_address ( ) {
  pop @{ $self->e };
}

=head1 NAME

JGoff::Parser::PEG::VM - VM for parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use JGoff::Parser::PEG::VM;

    my $foo = JGoff::Parser::PEG::VM->new;
    $foo->run( [ $tuple1, $tuple2, ... ] );
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 run

=cut

method run ( $tuples ) {

my $count = 1000;
  my $done;
  while ( !$done ) {
last if $count-- <= 1;

    my $tuple = $tuples->[$self->pc];
    my $instruction_name = $tuple->[0];
    if ( $instruction_name eq 'Char' ) {
      my $X = $tuple->[1];
      if ( $self->S->[$self->i] eq $X ) {
        $self->pc( $self->pc + 1 );
        $self->i( $self->i + 1 );         # --Char X--> <pc + 1, i + 1, e >
      }
      else {
        $self->_push_fail;
      }
    }
    elsif ( $instruction_name eq 'Any' ) {
      if ( $self->i + 1 <= length( $self->S ) ) { # --Any--> <pc + 1, i + 1, e>
        $self->pc( $self->pc + 1 );
        $self->i( $self->i + 1 );
      } 
      else { # Fail<e>
        $self->_push_fail;
      }
    }
    elsif ( $instruction_name eq 'Choice' ) { # <pc + 1, i, (pc + L,i) : e>
      my $L = $tuple->[1];
      $self->pc( $self->pc + 1 );
      $self->_push_backtrack( $self->pc + $L, $self->i );
    }
    elsif ( $instruction_name eq 'Jump' ) { # <pc + L, i, e>
      my $L = $tuple->[1];
      $self->pc( $self->pc + $L );
    }
    elsif ( $instruction_name eq 'Call' ) { # <pc + L, i, (pc + 1) : e>
      my $L = $tuple->[1];
      $self->pc( $self->pc + $L );
      $self->_push_backtrack( $self->pc + 1 );
    }
    elsif ( $instruction_name eq 'Return' ) { # <pc(1), i, e>
      my $pc1 = $self->pop_address;
      $self->pc( $pc1->[0] );
    }
    elsif ( $instruction_name eq 'Commit' ) { # <pc + L, i, e>
      my $L = $tuple->[1];
      $self->_pop_address; # Don't do anything with it.
      $self->pc( $L );
    }
    elsif ( $instruction_name eq 'Fail' ) { # <pc + L, i, e>
      my ( $pc, $i ) = @{ $self->_pop_address };
      my $pc1 = $self->_pop_address;
      if ( $pc eq 'Fail' ) {
        next; # Keep on popping 'Fail' entries until...
      }
      else {
        $self->pc( $pc );
        $self->i( $i );
      }
    }
  }
}

=head1 AUTHOR

Jeff Goff, C<< <jgoff at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jgoff-lisp-format at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JGoff-Parser-PEG>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JGoff::Parser::PEG


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JGoff-Parser-PEG>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JGoff-Parser-PEG>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JGoff-Parser-PEG>

=item * Search CPAN

L<http://search.cpan.org/dist/JGoff-Parser-PEG/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jeff Goff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of JGoff::Parser::PEG

package JGoff::Parser::PEG::Compile;

use Moose;                # XXX May be removed later
use Function::Parameters; # XXX Will probably be removed later

method _Char ( $character ) { [ Char => $character ] }
method _Any ( ) { [ 'Any' ] }
method _Choice ( $offset ) { [ Choice => $offset ] }
method _Jump ( $offset ) { [ Jump => $offset ] }
method _Call ( $offset ) { [ Call => $offset ] }
method _Return ( ) { [ 'Return' ] }
method _Commit ( $offset ) { [ Commit => $offset ] }
method _Fail ( ) { [ 'Any' ] }

=head1 NAME

JGoff::Parser::PEG::Compile - Compile for parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use JGoff::Parser::PEG::Compile;

    my $compiler = JGoff::Parser::PEG::Compile->new;
    ...

=head1 METHODS

=head2 Concatenate( $p1, $p2 ) # $p1 $p2

=cut

method Concatenate( $p1, $p2 ) {
  return [
    @{ $p1 },
    @{ $p2 }
  ];
}

=head2 Ordered_Choice( $p1, $p2 ) # $p1 / $p2

=cut

method Ordered_Choice( $p1, $p2 ) {
  return [
    $self->_Choice( @{ $p1 } + 2 ),
    @{ $p1 },
    [ Commit => @{ $p2 } + 1 ],
    @{ $p2 }
  ];
}

=head2 Character( $ch ) # 'c'

=cut

method Character( $ch ) {
  return [
    $self->_Char( $ch )
  ];
}

=head2 Any( ) # .

=cut

method Any( ) {
  return [
    $self->_Any( )
  ];
}

=head2 Not( ) # !$p

=cut

method Not( $p ) {
  return [
    $self->_Choice( @{ $p } + 3 ),
    @{ $p },
    $self->_Commit( 1 ),
    $self->_Fail
  ];
}

=head2 Repetition( $p ) # $p*

=cut

method Repetition( $p ) {
  return [
    $self->_Choice( @{ $p } + 2 ),
    @{ $p },
    $self->_Commit( - ( @{ $p } + 1 ) )
  ];
}

=head1 AUTHOR

Jeff Goff, C<< <jgoff at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jgoff-lisp-format at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JGoff-Parser-PEG>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JGoff::Parser::PEG::Compile

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

package JGoff::Parser::PEG::VM;

use Carp qw( croak );
use Moose;                # XXX May be removed later
use Function::Parameters; # XXX WIll probably be removed later
use Readonly;

our $TRACE = 0;
sub TRACE() { $TRACE }

Readonly our $NULL => -1;
Readonly our $CHARSETSIZE => 32; # Extracted from the C source
Readonly our $CHARSETINSTSIZE => 9;

# fail if no char
Readonly our $IAny           => 'IAny';

# fail if char != aux
Readonly our $IChar          => 'IChar';

# fail if char not in buff
Readonly our $ISet           => 'ISet';

# if no char, jump to 'offset'
Readonly our $ITestAny       => 'ITestAny';

# if char != aux, jump to 'offset'
Readonly our $ITestChar      => 'ITestChar';

# if char not in buff, jump to 'offset'
Readonly our $ITestSet       => 'ITestSet';

# read a span of chars in buff
Readonly our $ISpan          => 'ISpan';

# walk back 'aux' characters (fail if not possible)
Readonly our $IBehind        => 'IBehind';

# return from a rule
Readonly our $IRet           => 'IRet';

# end of pattern
Readonly our $IEnd           => 'IEnd';

# stack a choice; next fail will jump to 'offset'
Readonly our $IChoice        => 'IChoice';

# jump to 'offset'
Readonly our $IJmp           => 'IJmp';

# call rule at 'offset'
Readonly our $ICall          => 'ICall';

# call rule number 'key' (must be closed to a ICall)
Readonly our $IOpenCall      => 'IOpenCall';

# pop choice and jump to 'offset'
Readonly our $ICommit        => 'ICommit';

# update top choice to current position and jump
Readonly our $IPartialCommit => 'IPartialCommit';

# "fails" but jump to its own 'offset'
Readonly our $IBackCommit    => 'IBackCommit';

# pop one choice and then fail
Readonly our $IFailTwice     => 'IFailTwice';

# go back to saved state on choice and jump to saved offset
Readonly our $IFail          => 'IFail';

# internal use
Readonly our $IGiveup        => 'IGiveup';

# complete capture of last 'off' chars
Readonly our $IFullCapture   => 'IFullCapture';
 
# start a capture
Readonly our $IOpenCapture   => 'IOpenCapture';

# close a capture
Readonly our $ICloseCapture  => 'ICloseCapture';

 # Close runtime
Readonly our $ICloseRunTime  => 'ICloseRunTime';

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
    $foo->run( [ $tuple1, $tuple2, ... ], [ 'A', 'n', 'd' ] );
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 run

=cut

# {{{ run ( $op, $s )

method run ( $op, $s ) {
  my $e = [ ];
  my $i = 0;
  my $pc = 0;

  push @{ $e }, { pc => -1, i => $NULL }; # XXX Fake a 'IGiveup' instruction.

  my $result;

if ( TRACE ) {
  warn "Tracing on:\n";
}

my $count = 100;
  CONTINUE: while ( 1 ) {
my $fail_count = 10;
last unless $count--;
    my ( $fail, $pushcapture );
    my $opcode = $pc == -1 ? $IGiveup : $op->[ $pc ]->{opcode};

if ( TRACE ) {
  warn "$opcode\n";
}

    if ( $opcode eq $IAny ) {
      TRACE > 1 and warn "IAny: i: $i\n";
      if ( $i < length( $s ) ) {
TRACE > 2 and warn "IAny: if() branch\n";
        $pc++;
        $i++;
        goto CONTINUE;
      }
      else {
TRACE > 2 and warn "IAny: else{} branch\n";
        $fail = 1;
      }
    }
    if ( $opcode eq $IChar ) {
      if ( substr( $s, $i, 1 ) eq $op->[ $pc ]->{aux} ) {
        $pc++; $i++;
        goto CONTINUE;
      }
      else {
        $fail = 1;
      }
    }
    if ( $opcode eq $ISet ) {
      my $c = substr( $s, $i, 1 );
      if ( $op->[ $pc + 1 ]->{buff} eq $c && $i < length( $s ) ) {
        $pc += $CHARSETINSTSIZE;
        $i++;
        goto CONTINUE;
      }
      else {
        $fail = 1;
      }
    }
    if ( $opcode eq $ITestAny ) {
      if ( $i < length( $s ) ) {
        $pc += 2;
      }
      else {
        $pc += $op->[ $pc + 1 ]->{offset};
      }
      goto CONTINUE;
    }
    if ( $opcode eq $ITestChar ) {
      if ( substr( $s, $i, 1 ) eq $op->[ $pc ]->{aux} && $i < length( $s ) ) {
        $pc += 2;
      }
      else {
        $pc += $op->[ $pc + 1 ]->{offset};
      }
      goto CONTINUE;
    }
    if ( $opcode eq $ITestSet ) {
      my $c = substr( $s, $i, 1 );
      if ( $op->[ $pc + 2 ]->{buff} eq $c && $i < length( $s ) ) {
        $pc += 1 + $CHARSETINSTSIZE;
      }
      else {
        $pc += $op->[ $pc + 1 ]->{offset};
      }
      goto CONTINUE;
    }
    if ( $opcode eq $ISpan ) {
die "Operation $ISpan not implemented yet!\n";
      for ( ; $i < length( $s ) ; $i++ ) {
        last if substr( $s, $i, 1 ) eq $op->[ $pc + 1 ]->{buff};
      }
      $pc += $CHARSETINSTSIZE;
    }
    if ( $opcode eq $IBehind ) {
die "Operation $IBehind not implemented yet!\n";
    }
    if ( $opcode eq $IRet ) {
      if ( @{ $e } <= 0 ) {
        die "$IRet: Stack depth < 1!\n";
      }
      if ( !defined( $e->[-1]->{i} ) ) {
        TRACE > 1 and $self->__print_stack( $e );
        die "$IRet: Stack N-1 does not have a string!\n";
      }
      my $top = pop @{ $e };
      $pc = $top->{pc};
    }
    if ( $opcode eq $IEnd ) {
      if ( @{ $e } <= 0 ) {
        die "$IEnd: Stack depth < 1!\n";
      }
      $result = $i;
      last;
    }
    if ( $opcode eq $IChoice ) {
if( TRACE > 2 ) { warn ">:\n" . $self->__print_stack( $e ) }
      push @{ $e }, {
        pc => $pc + $op->[ $pc + 1 ]->{offset},
        i => $i,
      };
if( TRACE > 2 ) { warn "<:\n" . $self->__print_stack( $e ) }
      $pc += 2;
      goto CONTINUE;
    }
    if ( $opcode eq $IJmp ) {
      $pc += $op->[ $pc + 1 ]->{offset};
    }
    if ( $opcode eq $ICall ) {
      push @{ $e }, {
        pc => $pc + 2,
        i => -1, # XXX
      };
      $pc += $op->[ $pc + 1 ]->{offset};
    }
    if ( $opcode eq $IOpenCall ) {
#die "Operation $IOpenCall not implemented yet!\n";
    }
    if ( $opcode eq $ICommit ) {
      pop @{ $e };
      $pc += $op->[ $pc + 1 ]->{offset};
      goto CONTINUE;
    }
    if ( $opcode eq $IPartialCommit ) {
      $e->[ -1 ]->{i} = $i;
      $pc += $op->[ $pc + 1 ]->{offset};
    }
    if ( $opcode eq $IBackCommit ) {
      my $top = pop @{ $e };
      $i = $top->{i};
      $pc += $op->[ $pc + 1 ]->{offset};
#die "Operation $IBackCommit not implemented yet!\n";
    }
    if ( $opcode eq $IFailTwice ) {
      pop @{ $e };
      $fail = 1;
    }
    if ( $opcode eq $IFail ) {
      $fail = 1;
    }
    if ( $opcode eq $IGiveup ) {
      $result = undef;
      last;
    }
    if ( $opcode eq $IFullCapture ) {
die "Operation $IFullCapture not implemented yet!\n";
    }
    if ( $opcode eq $IOpenCapture ) {
die "Operation $IOpenCapture not implemented yet!\n";
    }
    if ( $opcode eq $ICloseCapture ) {
die "Operation $ICloseCapture not implemented yet!\n";
    }
    if ( $opcode eq $ICloseRunTime ) {
die "Operation $ICloseRunTime not implemented yet!\n";
    }

    if ( $fail ) {
      $fail = undef;
$self->__print_stack( $e ) if TRACE > 1;
      my $top;
      while( $e->[-1]->{i} != $NULL ) {
        $top = pop @{ $e };
        $i = $top->{i};
      }
      $pc = $top->{pc} if defined $top;
$self->__print_stack( $e ) if TRACE > 1;
      goto CONTINUE;
    }
    if ( $pushcapture ) {
      $pc++;
    }
  }
  return $result;
}

# }}}

# Char 'x': Tries to match the character 'x' against the current subject
#           position, advancing one position if successful.
#
# Any:      Advances one position if the end of the subject was not reached;
#           it fails otherwise.
#
# Choice l: Pushes a backtrack entry on the stack, where l is the offset
#           of the alternative instruction.
#
# Jump l:   Relative jump to the instruction at offset l.
#
# Call l:   Pushes the address of the next instruction in the stack, and
#           jumps to the instruction at offset l.
#
# Return:   Pops an address from the stack and jumps to it.
#
# Commit l: Commits to a choice, popping the top entry from the stack,
#           throwing it away, and jumping to the instruction at offset l
#
# Fail:     Forces a failure. When any failure occurs, the machine pops the
#           stack until it finds a backtrack entry, then uses that entry plus
#           the stack as the new machine state.

#    { pc, i, e } -- Char x -->
#                    { pc + 1, i + i, e } ; S[i] = x
#    { pc, i, e } -- Char x -->
#                    Fail{e}              ; S[i] != x
#    { pc, i, e } -- Any -->
#                    { pc + 1, i + 1, e } ; i + 1 <= |S| ; i < |S|
#    { pc, i, e } -- Any -->
#                    Fail{e}              ; i + 1 > |S| ; i >= |S|
#
#    { pc,  i,       e } -- Choice L -->
#                        { pc + 1, i, ( pc + L, i ) : e }
#    { pc,  i,       e } -- Jump L -->
#                        { pc + L, i, e }
#    { pc,  i,       e } -- Call L -->
#                        { pc + L, i, ( pc + 1, i ) : e }
#    { pc0, i, pc1 : e } -- Return -->
#                        { pc1, i, e }
#    { pc,  i,   h : e } -- Commit L -->
#                        { pc + L, i, e }
#    { pc,  i,       e } -- Fail -->
#                        Fail{e}
#Fail{          pc : e } -- any -->
#                        Fail{e}
#Fail{ ( pc1, i1 ) : e } -- any -->
#                        { pc, i1, e }
#
#
# The other ops
#
#
#{ pc0, i0, ( pc1, i1 ) : e } -- PartialCommit L -->
#                             { pc0 + L, i0, ( pc1, i0 ) : e }
#{ pc,  i,            h : e } -- FailTwice -->
#                             Fail{e}
#{ pc0, i0, ( pc1, i1 ) : e } -- BackCommit L -->
#                             { pc0 + L, i1, e }
#{ pc, i, e } -- TestChar x L -->
#                { pc + 1, i + 1, e } ; S[i] = x
#{ pc, i, e } -- TestChar x L -->
#                { pc + 1, i, e } ; S[1] != x
#{ pc, i, e } -- TestAny n L -->
#                { pc + n, i + n, e } ; i + n <= |S|
#{ pc, i, e } -- TestAny x L -->
#                { pc + 1, i, e } ; i + n > |S|

=cut

# static const Instruction giveup = {{IGiveup, 0, 0}};

#
# 'unshift' is the equivalent of pop based on how we're augmenting the "stacK".
# 
# { pc, i, h : e } => ( $pc, $i, do { unshift @e } ) = ( $pc, $i, @e );
#

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

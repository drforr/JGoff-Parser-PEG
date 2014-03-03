package JGoff::Parser::PEG::VM;

use Moose;                # XXX May be removed later
use Function::Parameters; # XXX Will probably be removed later
use Readonly;
use YAML;
use JGoff::Parser::PEG::Constants qw(
  $NULL
  $UCHAR_MAX
  $CHARSETSIZE
  $CHARSETINSTSIZE
  $IAny
  $IChar
  $ISet
  $ITestAny
  $ITestChar
  $ITestSet
  $ISpan
  $IBehind
  $IRet
  $IEnd
  $IChoice
  $IJmp
  $ICall
  $IOpenCall
  $ICommit
  $IPartialCommit
  $IBackCommit
  $IFailTwice
  $IFail
  $IGiveup
  $IFullCapture
  $IOpenCapture
  $ICloseCapture
  $ICloseRunTime
  $Cclose
  $Cposition
  $Cconst
  $Cbackref
  $Carg
  $Csimple
  $Ctable
  $Cfunction
  $Cquery
  $Cstring
  $Cnum
  $Csubst
  $Cfold
  $Cruntime
  $Cgroup
);

has capture => (
  is => 'rw',
  isa => 'ArrayRef[HashRef]',
  default => sub { [ ] }
);

our $TRACE = 0;
fun ASSERT ( $code, $format, @args ) {
  die sprintf "%14s: $format\n", $code, @args;
}
fun TRACE0 ( $code, $format, @args ) {
  $TRACE and warn sprintf "%14s: $format\n", $code, @args;
}
fun TRACE1 ( $code, $pc, $format, @args ) {
  $TRACE > 1 and warn sprintf "%14s [pc: %d]: $format\n", $code, $pc, @args;
}

has _coverage => (
  is => 'rw',
  isa => 'HashRef',
  required => 1,
  default => sub { {
asdf => { },
    $IAny           => { },
    $IChar          => { },
    $ISet           => { },
    $ITestAny       => { },
    $ITestChar      => { },
    $ITestSet       => { },
    $ISpan          => { },
    $IBehind        => { },
    $IRet           => { },
    $IEnd           => { },
    $IChoice        => { },
    $IJmp           => { },
    $ICall          => { },
    $IOpenCall      => { },
    $ICommit        => { },
    $IPartialCommit => { },
    $IBackCommit    => { },
    $IFailTwice     => { },
    $IFail          => { },
    $IGiveup        => { },
    $IFullCapture   => { },
    $IOpenCapture   => { },
    $ICloseCapture  => { },
    $ICloseRunTime  => { },
} } );

method cover ( $code, $branch ) {
  if ( $branch ) {
    $self->_coverage->{$code}{$branch}++;
  }
  else {
    $self->_coverage->{$code}{all}++;
  }
}

method covered ( ) {
  my %found;
  my %coverage = %{ $self->_coverage };
  for my $code ( keys %coverage ) {
    next unless $code =~ /^I/;
    next unless $coverage{$code}{all} or ( $coverage{$code}{if} and
                                           $coverage{$code}{else} );
    $found{$code} = $coverage{$code};

  }
  return \%found;
}

method uncovered ( ) {
  my %missing;
  my %coverage = %{ $self->_coverage };
  for my $code ( keys %coverage ) {
    next unless $code =~ /^I/;
    next if $coverage{$code} and
            $coverage{$code}{all} and
            $coverage{$code}{all} > 0;
    $missing{$code}{if} = undef unless $coverage{$code} and
                                       $coverage{$code}{if} and
                                       $coverage{$code}{if} > 0;
    $missing{$code}{else} = undef unless $coverage{$code} and
                                         $coverage{$code}{else} and
                                         $coverage{$code}{else} > 0;

  }
  return \%missing;
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
    $foo->run( [ $tuple1, $tuple2, ... ], q{And} );
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 run

=cut

# {{{ getoffset( p )
fun getoffset ( $op, $pc ) {
  return $op->[ $pc + 1 ]->{offset};
}
# }}}

# {{{ getkind( op )
#
# define getkind(op)             (op->i.aux & 0xF)
#
fun getkind ( $op, $pc ) {
  return $op->[ $pc ]->{aux} & 0xf;
}
# }}}

# {{{ getoff( op )
#
#define getoff(op)              ((op->i.aux >> 4) & 0xF)
#
fun getoff ( $op, $pc ) {
  return ( $op->[ $pc ]->{aux} >> 4 ) & 0xf;
}
# }}}

# {{{ joinkindoff( k, o )
#
# define joinkindoff(k,o)        (k | (o << 4))
#
fun joinkindoff ( $k, $o ) {
  return ( $k | ( $o << 4 ) );
}
# }}}

# {{{ testchar ( $code, $pc, $st, $c )
#
# define testchar(st,c)		st[c >> 3] & (1 << (c & 7))
#
fun testchar ( $code, $pc, $st, $c ) {
  my $c_ord = ord( $c );
  my $rv = $st->[ $c_ord >> 3 ] & ( 1 << ( $c_ord & 7 ) );
  TRACE1( $code, $pc,
          "(c >> 3 = %d, 1 << (c & 7) = %d, buff = [0x%02x]) => %d\n",
          $c_ord >> 3, 1 << ( $c_ord & 7 ), $st->[ $c_ord >> 3 ], $rv );
  return $rv;
}

# }}}

# {{{ run ( $op, $s )

method run ( $op, $s, $ptop ) {
  my $e = [ ];
  my $stack = 0; # Start of the stack, just mimick the C stack for now.
  my $i = 0;
  my $pc = 0;

  # capture is an attribute
  my $captop = 0;
  my $ndyncap = 0;

  $e = [ { pc => -1, i => 0 } ]; # XXX Fake a 'IGiveup' instruction.
  $stack++;

  my $result;
  $TRACE and warn "### Tracing on\n";

my $count = 100;
  CONTINUE: while ( 1 ) {
my $fail_count = 10;
die "*** Too many iterations of while()!" unless $count--;
    my ( $fail, $pushcapture );
    ASSERT( '', "PC $pc past the end of code array!" )
      if $pc > $#{ $op };
    my $code = $pc == -1 ? $IGiveup : $op->[ $pc ]->{code};

    TRACE0( $code, '' );

    if ( $code eq $IEnd ) {
      $self->cover( $IEnd );
      ASSERT( $IEnd, "Stack depth < 1!" )
        if @{ $e } == 0;
      TRACE0( $IEnd, "return %d", $i );
      $self->capture->[$captop]->{kind} = $Cclose;
      $self->capture->[$captop]->{s} = $NULL;
      return $i;
    }
    elsif ( $code eq $IGiveup ) {
      $self->cover( $IGiveup );
      TRACE0( $IGiveup, "return %s", 'undef' );
      return undef;
    }
    elsif ( $code eq $IRet ) {
      $self->cover( $IRet );
      ASSERT( $IRet, "Stack depth < 1!" )
        if @{ $e } == 0;
      ASSERT( $IRet, "Stack N-1 does not have a string!" )
        if !defined( $e->[ $stack - 1 ]->{i} );

      TRACE1( $IRet, $pc, ">> %s", Dump( $e ) );
      $pc = $e->[ --$stack ]->{pc};
      TRACE1( $IRet, $pc, "<< %s", Dump( $e ) );
      goto CONTINUE;
    }
    elsif ( $code eq $IAny ) {
      if ( $i < length( $s ) ) {
        $self->cover( $IAny, 'if' );
        TRACE1( $IAny, $pc, "s < e" );
        $pc++;
        $i++;
        goto CONTINUE;
      }
      else {
        $self->cover( $IAny, 'else' );
        TRACE1( $IAny, $pc, "s >= e, fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $code eq $ITestAny ) {
      if ( $i < length( $s ) ) {
        $self->cover( $ITestAny, 'if' );
        TRACE1( $ITestAny, $pc, "s < e" );
        $pc += 2;
        TRACE1( $ITestAny, $pc, "(pc => %d)", $pc );
      }
      else {
        $self->cover( $ITestAny, 'else' );
        my $offset = getoffset( $op, $pc );
        TRACE1( $ITestAny, $pc, "pc += (pc+1)->offset (%d)", $offset );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $code eq $IChar ) {
      if ( substr( $s, $i, 1 ) eq chr( $op->[ $pc ]->{aux} ) ) {
        $self->cover( $IChar, 'if' );
        TRACE1( $IChar, $pc, "c = aux" );
        $pc++;
        $i++;
        goto CONTINUE;
      }
      else {
        $self->cover( $IChar, 'else' );
        TRACE1( $IChar, $pc, "fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $code eq $ITestChar ) {
      TRACE1( $ITestChar, $pc,
              "[s => '%s', i => %d, *s => '%s', p->i.aux => '%d'] (%d)",
              $s, $i, substr( $s, $i, 1 ), $op->[ $pc ]->{aux},
              ( substr( $s, $i, 1 ) eq chr( $op->[ $pc ]->{aux} ) ) ? 1 : 0 );
      if ( ( substr( $s, $i, 1 ) eq chr( $op->[ $pc ]->{aux} ) ) &&
           ( $i < length( $s ) ) ) {
        $self->cover( $ITestChar, 'if' );
        TRACE1( $ITestChar, $pc,
                "s < e { \$i (%d) < length(\%s) (%d)", $i, $s, length( $s ) );
        $pc += 2;
      }
      else {
        $self->cover( $ITestChar, 'else' );
        my $offset = getoffset( $op, $pc );
        TRACE1( $ITestChar, $pc, "pc += getoffset(p) (%d)", $offset );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $code eq $ISet ) {
      my $c = substr( $s, $i, 1 );
      if ( testchar( $ISet, $pc,
                     $op->[ $pc + 1 ]->{buff}, $c ) && $i < length( $s ) ) {
        $self->cover( $ISet, 'if' );
        TRACE1( $ISet, $pc, "s < e" );
        $pc += $CHARSETINSTSIZE;
        $i++;
        goto CONTINUE;
      }
      else {
        $self->cover( $ISet, 'else' );
        TRACE1( $ISet, $pc, "fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $code eq $ITestSet ) {
      my $c = substr( $s, $i, 1 );
      TRACE1( $ITestSet, $pc, "pc + 2: %d", $pc + 2 );
      if ( testchar( $ITestSet, $pc,
                     $op->[ $pc + 2 ]->{buff}, $c ) && $i < length( $s ) ) {
        $self->cover( $ITestSet, 'if' );
        TRACE1( $ITestSet, $pc,  "s < e (pc + 2: %d)", $pc + 2 );
        $pc += 1 + $CHARSETINSTSIZE;
      }
      else {
        $self->cover( $ITestSet, 'else' );
        TRACE1( $ITestSet, $pc, "pc += (pc+1)->offset" );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $code eq $IBehind ) {
      my $n = $op->[ $pc ]->{aux};
      if ( $n > $i ) {
        $self->cover( $IBehind, 'if' );
        TRACE1( $IBehind, $pc, "n > s - o" );
        $fail = 1;
        goto FAIL;
      }
      else {
        $self->cover( $IBehind, 'else' );
        TRACE1( $IBehind, $pc, "n <= s - o" );
        $i -= $n;
        $pc++;
        goto CONTINUE;
      }
    }
    elsif ( $code eq $ISpan ) {
      $self->cover( $ISpan );
#die "Operation $ISpan not implemented yet!\n";
      # XXX See how $i gets bumped here?
      for ( ; $i < length( $s ) ; $i++ ) {
        my $c = substr( $s, $i, 1 );
        if ( !testchar( $ISpan, $pc,
                        $op->[ $pc + 1 ]->{buff}, $c ) && $i < length( $s ) ) {
          $self->cover( $ISpan, 'if' );
          last;
        }
      }
      $pc += $CHARSETINSTSIZE;
      goto CONTINUE;
    }
    elsif ( $code eq $IJmp ) {
      $self->cover( $IJmp );
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $code eq $IChoice ) {
      $self->cover( $IChoice );
      TRACE1( $IChoice, $pc, ">>> %s", Dump( $e ) );
      $e->[ $stack ]->{pc} = $pc + getoffset( $op, $pc );
      $e->[ $stack ]->{i} = $i;
      $e->[ $stack ]->{caplevel} = $captop;
      $stack++;
      TRACE1( $IChoice, $pc, "<<< %s", Dump( $e ) );
      $pc += 2;
      goto CONTINUE;
    }
    elsif ( $code eq $ICall ) {
      $self->cover( $ICall );
      TRACE1( $ICall, $pc, ">>> %s", Dump( $e ) );
      $e->[ $stack ]->{i} = $NULL;
      $e->[ $stack ]->{pc} = $pc + 2;
      $stack++;
      TRACE1( $ICall, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $code eq $ICommit ) {
      $self->cover( $ICommit );
      TRACE1( $ICommit, $pc, ">>> %s", Dump( $e ) );
      $stack--;
      TRACE1( $ICommit, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $code eq $IPartialCommit ) {
      $self->cover( $IPartialCommit );
      $e->[ $stack - 1 ]->{i} = $i;
      $e->[ $stack - 1 ]->{caplevel} = $captop;
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $code eq $IBackCommit ) {
      $self->cover( $IBackCommit );
      TRACE1( $IBackCommit, $pc, ">>> %s", Dump( $e ) );
      $i = $e->[ --$stack ]->{i};
      $captop = $e->[ $stack ]->{caplevel};
      TRACE1( $IBackCommit, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
#die "Operation $IBackCommit not implemented yet!\n";
      goto CONTINUE;
    }
    elsif ( $code eq $IFailTwice ) {
      $self->cover( $IFailTwice );
      TRACE1( $IFailTwice, $pc, ">>> %s", Dump( $e ) );
      $stack--;
      TRACE1( $IFailTwice, $pc, "<<< %s", Dump( $e ) );
      $fail = 1;
      goto FAIL;
    }
    elsif ( $code eq $IFail ) {
      $self->cover( $IFail );
      $fail = 1;
      goto FAIL;
    }

FAIL:
    if ( $fail ) {
      $fail = undef;
      my $top;
my $stack_count = 10;
      TRACE1( 'fail', $pc, ">>> %s", Dump( $e ) );
      do {
last unless $stack_count--;
        $i = $e->[ --$stack ]->{i};
      } while $i == $NULL;
      if ( $ndyncap > 0 ) { # Are there matching captures?
        $ndyncap -= $self->removedyncap( $self->capture, $e->[ $stack ]->{caplevel}, $captop );
      }
      $captop = $e->[ $stack ]->{caplevel};
      TRACE1( 'fail', $pc, "<<< %s", Dump( $e ) );
      $pc = $e->[ $stack ]->{pc};
      TRACE0( 'fail', ": pc = %d", $pc );
      goto CONTINUE;
    }

    if ( $code eq $ICloseRunTime ) {
die "Opcode $ICloseRunTime not implemented yet!\n";
#      $self->cover( $ICloseRunTime );
#      my $cs = { }; # CapState cs;
#      my ( $rem, $res, $n );
#my $L; # XXX Lua stack
#      my $fr = lua_gettop( $L ) + 1;
#      $cs->{i} = 0; # XXX 'o' in the code
#      $cs->{L} = $L;
#      $cs->{ocap} = $self->capture;
#      $cs->{ptop} = $ptop;
#      $n = runtimecap( $cs, $self->capture, $captop, $i, \$rem ); # XXX call function
#      $captop -= $n;
#      $fr -= $rem;
#      #$res = resdyncaptures( $L, $fr, $i, $j ); # XXX $j is e - o # Get result # XXX
#      if ( $res == -1 ) { # fail?
#        $fail = 1;
#        goto FAIL;
#      }
#      # s = o + res; # XXX
#      $n = lua_gettop( $L ) - $fr + 1; # Number of new captures
#      $ndyncap += $n - $rem;
#      if ( $n > 0 ) { # Any new captures?
#        adddyncaptures( $i, $self->capture, $captop - $n - 2, $n, $fr ); # XXX
#      }
#      $pc++;
#      goto CONTINUE;
    }
    elsif ( $code eq $ICloseCapture ) {
die "Opcode $ICloseCapture not implemented yet!\n";
#      $self->cover( $ICloseCapture );
#      my $i1 = $i;
#      ASSERT( $ICloseCapture, "captop <= 0" )
#        if $captop <= 0;
#      # If possible, convert capture into a full capture
#      if ( $self->capture->[ $captop - 1 ]->{siz} == 0 &&
#        $i1 -$self->capture->[ $captop - 1 ]->{i} < $UCHAR_MAX ) {
#        TRACE0( $ICloseCapture, "Checking uchar_max", '' );
#        $self->capture->[ $captop - 1 ]->{siz} = $i1 - $self->capture->[ $captop - 1 ]->{i} + 1;
#        $pc++;
#use YAML; warn Dump($self->capture);
#        goto CONTINUE;
#      }
#      else {
#        $self->capture->[ $captop ]->{siz} = 1; # Mark entry as closed
#        $self->capture->[ $captop ]->{i} = $i; # Mark entry as closed
#        $pushcapture = 1;
#        goto PUSHCAPTURE;
#      }
    }
    elsif ( $code eq $IOpenCapture ) {
die "Opcode $IOpenCapture not implemented yet!\n";
#      $self->cover( $IOpenCapture );
#      $self->capture->[ $captop ]->{siz} = 0; # Mark entry as open
#      $self->capture->[ $captop ]->{i} = $i;
#      $pushcapture = 1;
#      goto PUSHCAPTURE;
    }
    elsif ( $code eq $IFullCapture ) {
die "Opcode $IFullCapture not implemented yet!\n";
#      $self->cover( $IFullCapture );
#      $self->capture->[ $captop ]->{siz} = getoff( $op, $pc ) + 1; # Save capture size
#      $self->capture->[ $captop ]->{i} = $i - getoff( $op, $pc );
#      $pushcapture = 1;
#      goto PUSHCAPTURE;
    }

#    PUSHCAPTURE: {
#    if ( $pushcapture ) {
#      $self->capture->[ $captop ]->{idx} = $op->[ $pc ]->{key};
#      $self->capture->[ $captop ]->{kind} = _lookup_kind( getkind( $op, $pc ) );
#      # XXX And see if we need to resize the capture array. Blah.
#      $captop++;
#      $pc++;
#      goto CONTINUE;
#    }
#    }

    if ( $code eq $IOpenCall ) {
      $self->_coverage->{$IOpenCall} = { all => 1 }; # No branches to take
die "Operation $IOpenCall not implemented yet!\n";
    }

    # default:
    if ( 1 ) {
      TRACE0( 'default', ": return %d", $NULL );
      return $NULL;
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

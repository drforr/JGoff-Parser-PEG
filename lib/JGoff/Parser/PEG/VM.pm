package JGoff::Parser::PEG::VM;

=pod

#define testchar(st,c)	st[c >> 3] & (1 << (c & 7))

/* {{{ Opcode interpreter
 *
 */
const char *match (lua_State *L, const char *o, const char *s, const char *e,
                   Instruction *op, Capture *capture, int ptop) {
  Stack stackbase[INITBACK];
  Stack *stacklimit = stackbase + INITBACK;
  Stack *stack = stackbase;  /* point to first empty slot in stack */
  int capsize = INITCAPSIZE;
  int captop = 0;  /* point to first empty slot in captures */
  int ndyncap = 0;  /* number of dynamic captures (in Lua stack) */
  const Instruction *p = op;  /* current instruction */
  stack->p = &giveup; stack->s = s; stack->caplevel = 0; stack++;
  lua_pushlightuserdata(L, stackbase);

printf( "*** starting\n" );

#ifdef DISPLAY
printf( "is( $vm->run( \n" );
print_instructions(op);
printf( "  ), q{%s}\n", s );
printf( ");\n\n" );
#endif

  for (;;) {
#ifdef TRACE
trace_instruction( p, op, s, o, stack, stackbase );
#endif
    assert(stackidx(ptop) + ndyncap == lua_gettop(L) && ndyncap <= captop);
    switch ((Opcode)p->i.code) {
      case IEnd: {
        assert(stack == getstackbase(L, ptop) + 1);
        capture[captop].kind = Cclose;
        capture[captop].s = NULL;
#ifdef DISPLAY
printf( "%14s: Returning s - o: %d\n", "IEnd", s - o );
#endif
        return s;
      }
      case IGiveup: {
        assert(stack == getstackbase(L, ptop));
#ifdef DISPLAY
printf( "%14s: Returning NULL\n", "IGiveup" );
#endif
        return NULL;
      }
      case IRet: {
        assert(stack > getstackbase(L, ptop) && (stack - 1)->s == NULL);
#ifdef TRACE
print_stack_items( stack, stackbase );
#endif
        p = (--stack)->p;
#ifdef TRACE
print_stack_items( stack, stackbase );
#endif
        continue;
      }
      case IAny: {
        if (s < e) {
          p++;
          s++;
#ifdef TRACE
          printf( "%14s: s < e\n", "IAny" );
#endif
        }
        else {
#ifdef TRACE
          printf( "%14s: s >= e, fail\n", "IAny" );
#endif
          goto fail;
        }
        continue;
      }
      case ITestAny: {
        if (s < e) {
          p += 2;
#ifdef TRACE
          printf( "%14s: s < e\n", "ITestAny" );
#endif
        }
        else {
          p += getoffset(p);
#ifdef TRACE
          printf( "%14s:: p += %d", "ITestAny", getoffset(p) );
#endif
        }
        continue;
      }
      case IChar: {
        if ((byte)*s == p->i.aux && s < e) {
#ifdef TRACE
          printf( "%14s: s < e\n", "IChar" );
#endif
          p++;
          s++;
        }
        else {
#ifdef TRACE
          printf( "%14s: s >= e, fail\n", "IChar" );
#endif
          goto fail;
        }
        continue;
      }
      case ITestChar: {
        if ((byte)*s == p->i.aux && s < e) {
#ifdef TRACE
          printf( "%14s: s < e\n", "ITestChar" );
#endif
          p += 2;
        }
        else {
#ifdef TRACE
          printf( "%14s:: p += %d", "ITestChar", getoffset(p) );
#endif
          p += getoffset(p);
        }
        continue;
      }
      case ISet: {
        int c = (byte)*s;
        if (testchar((p+1)->buff, c) && s < e) {
#ifdef TRACE
          printf( "%14s: s < e\n", "ISet" );
#endif
          p += CHARSETINSTSIZE;
          s++;
        }
        else {
#ifdef TRACE
          printf( "%14s: s >= e, fail\n", "ISet" );
#endif
          goto fail;
        }
        continue;
      }
      case ITestSet: {
        int c = (byte)*s;
        if (testchar((p + 2)->buff, c) && s < e) {
#ifdef TRACE
          printf( "%14s: s < e\n", "ITestSet" );
#endif
          p += 1 + CHARSETINSTSIZE;
        }
        else {
#ifdef TRACE
          printf( "%14s:: p += %d", "ITestSet", getoffset(p) );
#endif
          p += getoffset(p);
        }
        continue;
      }
      case IBehind: {
        int n = p->i.aux;
        if (n > s - o) {
#ifdef TRACE
          printf( "%14s: n > s - o, fail\n", "IBehind" );
#endif
          goto fail;
        }
        s -= n;
        p++;
        continue;
      }
      case ISpan: {
        for (; s < e; s++) {
          int c = (byte)*s;
          if (!testchar((p+1)->buff, c)) {
#ifdef TRACE
            printf( "%14s: testchar fail\n", "ISpan" );
#endif
            break;
          }
        }
        p += CHARSETINSTSIZE;
        continue;
      }
      case IJmp: {
        p += getoffset(p);
        continue;
      }
      case IChoice: {
        if (stack == stacklimit)
          stack = doublestack(L, &stacklimit, ptop);
        stack->p = p + getoffset(p);
        stack->s = s;
        stack->caplevel = captop;
#ifdef TRACE
printf( "%14s: >>>\n", "IChoice" );
print_stack_items( stack, stackbase );
#endif
        stack++;
#ifdef TRACE
printf( "%14s: <<<\n", "IChoice" );
print_stack_items( stack, stackbase );
#endif
        p += 2;
        continue;
      }
      case ICall: {
        if (stack == stacklimit)
          stack = doublestack(L, &stacklimit, ptop);
        stack->s = NULL;
        stack->p = p + 2;  /* save return address */
#ifdef TRACE
printf( "%14s: >>>\n", "ICall" );
print_stack_items( stack, stackbase );
#endif
        stack++;
#ifdef TRACE
printf( "%14s: <<<\n", "ICall" );
print_stack_items( stack, stackbase );
#endif
        p += getoffset(p);
        continue;
      }
      case ICommit: {
        assert(stack > getstackbase(L, ptop) && (stack - 1)->s != NULL);
#ifdef TRACE
printf( "%14s: >>>\n", "ICommit" );
print_stack_items( stack, stackbase );
#endif
        stack--;
#ifdef TRACE
printf( "%14s: <<<\n", "ICommit" );
print_stack_items( stack, stackbase );
#endif
        p += getoffset(p);
        continue;
      }
      case IPartialCommit: {
        assert(stack > getstackbase(L, ptop) && (stack - 1)->s != NULL);
        (stack - 1)->s = s;
        (stack - 1)->caplevel = captop;
        p += getoffset(p);
        continue;
      }
      case IBackCommit: {
        assert(stack > getstackbase(L, ptop) && (stack - 1)->s != NULL);
#ifdef TRACE
printf( "%14s: >>>\n", "IBackCommit" );
print_stack_items( stack, stackbase );
#endif
        s = (--stack)->s;
#ifdef TRACE
printf( "%14s: <<<\n", "IBackCommit" );
print_stack_items( stack, stackbase );
#endif
        captop = stack->caplevel;
        p += getoffset(p);
        continue;
      }
      case IFailTwice:
        assert(stack > getstackbase(L, ptop));
#ifdef TRACE
printf( "%14s: >>>\n", "IFailTwice" );
print_stack_items( stack, stackbase );
#endif
        stack--;
#ifdef TRACE
printf( "%14s: <<<\n", "IFailTwice" );
print_stack_items( stack, stackbase );
#endif
        /* go through */
      case IFail:
      fail: { /* pattern failed: try to backtrack */
#ifdef TRACE
printf( "%14s: >>>\n", "IFail" );
print_stack_items( stack, stackbase );
#endif
        do {  /* remove pending calls */
          assert(stack > getstackbase(L, ptop));
          s = (--stack)->s;
        } while (s == NULL);
#ifdef TRACE
printf( "%14s: <<<\n", "IFail" );
print_stack_items( stack, stackbase );
#endif
        if (ndyncap > 0)  /* is there matchtime captures? */
          ndyncap -= removedyncap(L, capture, stack->caplevel, captop);
        captop = stack->caplevel;
        p = stack->p;
#ifdef TRACE
printf( "%14s: pc: %d\n", "IFail", op - p );
print_stack_items( stack, stackbase );
#endif
        continue;
      }
      case ICloseRunTime: {
        CapState cs;
        int rem, res, n;
        int fr = lua_gettop(L) + 1;  /* stack index of first result */
        cs.s = o; cs.L = L; cs.ocap = capture; cs.ptop = ptop;
        n = runtimecap(&cs, capture + captop, s, &rem);  /* call function */
        captop -= n;  /* remove nested captures */
        fr -= rem;  /* 'rem' items were popped from Lua stack */
        res = resdyncaptures(L, fr, s - o, e - o);  /* get result */
        if (res == -1)  /* fail? */
          goto fail;
        s = o + res;  /* else update current position */
        n = lua_gettop(L) - fr + 1;  /* number of new captures */
        ndyncap += n - rem;  /* update number of dynamic captures */
        if (n > 0) {  /* any new capture? */
          if ((captop += n + 2) >= capsize) {
            capture = doublecap(L, capture, captop, ptop);
            capsize = 2 * captop;
          }
          /* add new captures to 'capture' list */
          adddyncaptures(s, capture + captop - n - 2, n, fr); 
        }
        p++;
        continue;
      }
      case ICloseCapture: {
        const char *s1 = s;
        assert(captop > 0);
        /* if possible, turn capture into a full capture */
        if (capture[captop - 1].siz == 0 &&
            s1 - capture[captop - 1].s < UCHAR_MAX) {
          capture[captop - 1].siz = s1 - capture[captop - 1].s + 1;
          p++;
          continue;
        }
        else {
          capture[captop].siz = 1;  /* mark entry as closed */
          capture[captop].s = s;
          goto pushcapture;
        }
      }
      case IOpenCapture:
        capture[captop].siz = 0;  /* mark entry as open */
        capture[captop].s = s;
        goto pushcapture;
      case IFullCapture:
        capture[captop].siz = getoff(p) + 1;  /* save capture size */
        capture[captop].s = s - getoff(p);
        /* goto pushcapture; */
      pushcapture: {
        capture[captop].idx = p->i.key;
        capture[captop].kind = getkind(p);
        if (++captop >= capsize) {
          capture = doublecap(L, capture, captop, ptop);
          capsize = 2 * captop;
        }
        p++;
        continue;
      }
      default:
        assert(0);
#ifdef DISPLAY
printf( "%14s: Returns NULL\n", "***default" );
#endif
        return NULL;
    }
  }
}
/* }}} */

=cut

use Carp qw( croak );
use Moose;                # XXX May be removed later
use Function::Parameters; # XXX Will probably be removed later
use Readonly;
use YAML;

our $TRACE = 0;
fun ASSERT ( $opcode, $format, @args ) {
  die sprintf "%14s: %format\n", $opcode, @args;
}
fun TRACE0 ( $opcode, $format, @args ) {
  $TRACE and warn sprintf "%14s: $format\n", $opcode, @args;
}
fun TRACE1 ( $opcode, $pc, $format, @args ) {
  $TRACE > 1 and warn sprintf "%14s [pc: %d]: $format\n", $opcode, $pc, @args;
}

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
    $foo->run( [ $tuple1, $tuple2, ... ], q{And} );
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 run

=cut

# {{{ getoffset( $p )
fun getoffset ( $op, $pc ) {
  return $op->[ $pc + 1 ]->{offset};
}
# }}}

# {{{ testchar ( $opcode, $pc, $st, $c )

fun testchar ( $opcode, $pc, $st, $c ) {
  my $c_ord = ord( $c );
  my $rv = $st->[ $c_ord >> 3 ] & ( 1 << ( $c_ord & 7 ) );
  TRACE1( $opcode, $pc,
          "(c >> 3 = %d, 1 << (c & 7) = %d, buff = [0x%02x]) => %d\n",
          $c_ord >> 3, 1 << ( $c_ord & 7 ), $st->[ $c_ord >> 3 ], $rv );
  return $rv;
}

# }}}

# {{{ run ( $op, $s )

method run ( $op, $s ) {
  my $e = [ ];
  my $stack = 0; # Start of the stack, just mimick the C stack for now.
  my $i = 0;
  my $pc = 0;

  $e = [ { pc => -1, i => 0 } ]; # XXX Fake a 'IGiveup' instruction.
  $stack++;

  my $result;
  $TRACE and warn "### Tracing on\n";

my $count = 100;
  CONTINUE: while ( 1 ) {
my $fail_count = 10;
die "*** Too many iterations of while()!" unless $count--;
    my ( $fail, $pushcapture );
    ASSERT( '', "PC $pc past the end of opcode array!" )
      if $pc > $#{ $op };
    my $opcode = $pc == -1 ? $IGiveup : $op->[ $pc ]->{opcode};

    TRACE0( $opcode, '' );

    if ( $opcode eq $IEnd ) {
      ASSERT( $IEnd, "Stack depth < 1!" )
        if @{ $e } == 0;
      TRACE0( $IEnd, "return %d", $i );
      return $i;
    }
    elsif ( $opcode eq $IGiveup ) {
      TRACE0( $IGiveup, "return %s", 'undef' );
      return undef;
    }
    elsif ( $opcode eq $IRet ) {
      ASSERT( $IRet, "Stack depth < 1!" )
        if @{ $e } == 0;
      ASSERT( $IRet, "Stack N-1 does not have a string!" )
        if !defined( $e->[ $stack - 1 ]->{i} );

      TRACE1( $IRet, $pc, ">> %s", Dump( $e ) );
      $pc = $e->[ --$stack ]->{pc};
      TRACE1( $IRet, $pc, "<< %s", Dump( $e ) );
      goto CONTINUE;
    }
    elsif ( $opcode eq $IAny ) {
      if ( $i < length( $s ) ) {
        TRACE1( $IAny, $pc, "s < e" );
        $pc++;
        $i++;
        goto CONTINUE;
      }
      else {
        TRACE1( $IAny, $pc, "s >= e, fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $opcode eq $ITestAny ) {
      if ( $i < length( $s ) ) {
        TRACE1( $ITestAny, $pc, "s < e" );
        $pc += 2;
        TRACE1( $ITestAny, $pc, "(pc => %d)", $pc );
      }
      else {
        my $offset = getoffset( $op, $pc );
        TRACE1( $ITestAny, $pc, "pc += (pc+1)->offset (%d)", $offset );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $opcode eq $IChar ) {
      if ( substr( $s, $i, 1 ) eq $op->[ $pc ]->{aux} ) {
        TRACE1( $IChar, $pc, "c = aux" );
        $pc++;
        $i++;
        goto CONTINUE;
      }
      else {
        TRACE1( $IChar, $pc, "fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $opcode eq $ITestChar ) {
      TRACE1( $ITestChar, $pc,
              "[s => '%s', i => %d, *s => '%s', p->i.aux => '%c'] (%d)",
              $s, $i, substr( $s, $i, 1 ), $op->[ $pc ]->{aux},
              ( substr( $s, $i, 1 ) eq chr( $op->[ $pc ]->{aux} ) ) ? 1 : 0 );
      if ( ( substr( $s, $i, 1 ) eq chr( $op->[ $pc ]->{aux} ) ) &&
           ( $i < length( $s ) ) ) {
        TRACE1( $ITestChar, $pc,
                "s < e { \$i (%d) < length(\%s) (%d)", $i, $s, length( $s ) );
        $pc += 2;
      }
      else {
        my $offset = getoffset( $op, $pc );
        TRACE1( $ITestChar, $pc, "pc += getoffset(p) (%d)", $offset );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $opcode eq $ISet ) {
      my $c = substr( $s, $i, 1 );
      if ( testchar( $ISet, $pc,
                     $op->[ $pc + 1 ]->{buff}, $c ) && $i < length( $s ) ) {
        TRACE1( $ISet, $pc, "s < e" );
        $pc += $CHARSETINSTSIZE;
        $i++;
        goto CONTINUE;
      }
      else {
        TRACE1( $ISet, $pc, "fail" );
        $fail = 1;
        goto FAIL;
      }
    }
    elsif ( $opcode eq $ITestSet ) {
      my $c = substr( $s, $i, 1 );
      TRACE1( $ITestSet, $pc, "pc + 2: %d", $pc + 2 );
      if ( testchar( $ITestSet, $pc,
                     $op->[ $pc + 2 ]->{buff}, $c ) && $i < length( $s ) ) {
        TRACE1( $ITestSet, $pc,  "s < e (pc + 2: %d)", $pc + 2 );
        $pc += 1 + $CHARSETINSTSIZE;
      }
      else {
        TRACE1( $ITestSet, $pc, "pc += (pc+1)->offset" );
        $pc += getoffset( $op, $pc );
      }
      goto CONTINUE;
    }
    elsif ( $opcode eq $IBehind ) {
      my $n = $op->[ $pc ]->{aux};
      if ( $n > $i ) {
        TRACE1( $IBehind, $pc, "n > s - o" );
        $fail = 1;
        goto FAIL;
      }
      else {
        TRACE1( $IBehind, $pc, "n <= s - o" );
        $i -= $n;
        $pc++;
        goto CONTINUE;
      }
    }
    elsif ( $opcode eq $ISpan ) {
#die "Operation $ISpan not implemented yet!\n";
      # XXX See how $i gets bumped here?
      for ( ; $i < length( $s ) ; $i++ ) {
        my $c = substr( $s, $i, 1 );
        if ( !testchar( $ISpan, $pc,
                        $op->[ $pc + 1 ]->{buff}, $c ) && $i < length( $s ) ) {
          last;
        }
      }
      $pc += $CHARSETINSTSIZE;
      goto CONTINUE;
    }
    elsif ( $opcode eq $IJmp ) {
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $opcode eq $IChoice ) {
      TRACE1( $IChoice, $pc, ">>> %s", Dump( $e ) );
      $e->[ $stack ]->{pc} = $pc + getoffset( $op, $pc );
      $e->[ $stack ]->{i} = $i;
      $stack++;
      TRACE1( $IChoice, $pc, "<<< %s", Dump( $e ) );
      $pc += 2;
      goto CONTINUE;
    }
    elsif ( $opcode eq $ICall ) {
      TRACE1( $ICall, $pc, ">>> %s", Dump( $e ) );
      $e->[ $stack ]->{i} = $NULL;
      $e->[ $stack ]->{pc} = $pc + 2;
      $stack++;
      TRACE1( $ICall, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $opcode eq $ICommit ) {
      TRACE1( $ICommit, $pc, ">>> %s", Dump( $e ) );
      $stack--;
      TRACE1( $ICommit, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $opcode eq $IPartialCommit ) {
      $e->[ $stack - 1 ]->{i} = $i;
      $pc += getoffset( $op, $pc );
      goto CONTINUE;
    }
    elsif ( $opcode eq $IBackCommit ) {
      TRACE1( $IBackCommit, $pc, ">>> %s", Dump( $e ) );
      $i = $e->[ --$stack ]->{i};
      TRACE1( $IBackCommit, $pc, "<<< %s", Dump( $e ) );
      $pc += getoffset( $op, $pc );
#die "Operation $IBackCommit not implemented yet!\n";
      goto CONTINUE;
    }
    elsif ( $opcode eq $IFailTwice ) {
      TRACE1( $IFailTwice, $pc, ">>> %s", Dump( $e ) );
      $stack--;
      TRACE1( $IFailTwice, $pc, "<<< %s", Dump( $e ) );
      $fail = 1;
      goto FAIL;
    }
    elsif ( $opcode eq $IFail ) {
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
      TRACE1( 'fail', $pc, "<<< %s", Dump( $e ) );
      $pc = $e->[ $stack ]->{pc};
      TRACE0( 'fail', ": pc = %d", $pc );
      goto CONTINUE;
    }

    if ( $opcode eq $ICloseRunTime ) {
die "Operation $ICloseRunTime not implemented yet!\n";
    }
    elsif ( $opcode eq $ICloseCapture ) {
die "Operation $ICloseCapture not implemented yet!\n";
    }
    elsif ( $opcode eq $IOpenCapture ) {
die "Operation $IOpenCapture not implemented yet!\n";
    }
    elsif ( $opcode eq $IFullCapture ) {
die "Operation $IFullCapture not implemented yet!\n";
    }

    if ( $pushcapture ) {
      $pc++;
      goto CONTINUE;
    }

    if ( $opcode eq $IOpenCall ) {
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

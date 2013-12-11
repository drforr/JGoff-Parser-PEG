package JGoff::Parser::PEG::VM;

use Carp qw( croak );
use Moose;                # XXX May be removed later
use Function::Parameters; # XXX WIll probably be removed later
use Readonly;

Readonly our $IChar   => 'IChar';
Readonly our $IEnd    => 'IEnd';
Readonly our $IGiveup => 'IGiveup';
Readonly our $IFail   => 'IFail';
Readonly our $IAny    => 'IAny';
Readonly our $IAny    => 'ITestAny';
Readonly our $IRet    => 'IRet';

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

method run ( $op, $s ) {
  my $e = [ { p => { opcode => $IGiveup } } ];
  my $i = 0;
  my $pc = 0;

  my $p;

my $count = 10;
  my $error;
  while ( 1 ) {
last unless $count--;
    my $fail = undef;
    my $opcode = defined $p ? $p->{opcode} : $op->[ $pc ]->{opcode};
    if ( $opcode eq $IEnd ) {
      if ( @{ $e } <= 0 ) {
        die "$IEnd: Stack depth < 1!\n";
      }
      # capture[ captop ].kind = Cclose;
      # capture[ captop ].s    = NULL;
      # return s;
      last;
    }
    elsif ( $opcode eq $IGiveup ) {
      $error = 1;
      last;
    }
    elsif ( $opcode eq $IChar ) {
      if ( substr( $s, $i, 1 ) eq $op->[ $pc ]->{aux} ) {
        $pc++; $i++;
      }
      else {
        $fail = 1;
      }
    }
    elsif ( $opcode eq $IFail ) {
      $fail = 1;
    }
    elsif ( $opcode eq $IAny ) {
      if ( $i < length( $s ) ) {
        $pc++; $i++;
      }
      else {
        $fail = 1;
      }
    }

#    elsif ( $opcode eq $ITestAny ) {
#      if ( $i < length( $s ) {
#        $pc += 2;
#      }
#      else {
#        $pc += $e->[ $pc + 1 ]->{offset};
#      }
#    }
#    elsif ( $opcode eq $IRet ) {
#    }

    if ( $fail ) {
      while ( !defined( $s ) ) {
        pop @{ $e };
        $s = $e->[-1]->{s};
      }
      $p = $e->[-1]->{p};
    }
  }
  return !$error;
}

### {{{ Opcode interpreter - unswizzle program counter
###
###
###const char *match ( lua_State* L,
###                    const char* o, const char* s, const char* e,
###                    Instruction* op,
###                    Capture* capture,
###                    int ptop ) {
###  Stack  stackBase[ INITBACK ];
###  Stack* stackbase  = stackBase;
###  Stack* stacklimit = stackbase + INITBACK;
###  Stack* stack = stackbase;  /* point to first empty slot in stack */
###
###  int stackindex = 0;
###
###  int capsize = INITCAPSIZE;
###  int captop  = 0;  /* point to first empty slot in captures */
###  int ndyncap = 0;  /* number of dynamic captures (in Lua stack) */
###
###  const Instruction* p = op;  /* current instruction */
###
###  int pc = 0; /* Program counter starts at the 0th instruction */
###
###  PPush_stack( &stack, &stackindex, &giveup, 0, s, 0 );
###
###  lua_pushlightuserdata(L, stackbase);
###
###  printf( "s [%s]\n", s );
###  print_instructions( op );
###  printf( "\n" );
###
###  while ( 1 ) {
###    assert( ptop + 4 + ndyncap == lua_gettop(L) && ndyncap <= captop );
###/*
### * XXX The existing implementation stores pointers to opcodes rather than
### * XXX the offset to the opcode. This is apparently for just one reason:
### * XXX at the bottom of the stack there's an IGiveup opcode that doesn't
### * XXX really form part of the VM. Instead it's an opcode that's used when
### * XXX the VM fails.
### *
### * XXX Ordinarily it's not a problem, but because the instruction is on the
### * XXX stack rather than in the *op list, it has to be stored as a pointer.
### * XXX This has the ugly side effect of making *every* instruction stored on
### * XXX the stack a pointer, so we can no longer use the instruction offset.
### *
### * XXX This hack looks to see if the VM has reached the bottom of the stack,
### * XXX and if it has, don't follow the opcode's instruction pointer but
### * XXX instead force the opcode to be IGiveup. Because this immediately exits
### * XXX the VM there's no teardown needed, and everything else gets cleaned
### * XXX up elsewhere.
### *
### * XXX On the perl implementation it won't be used, but I'm doing this so
### * XXX I can remove all references to 'p' in the function.
### *
### */
###    int opcode;
###if ( stackindex == 0 ) {
###  pc = -1;
###  opcode = IGiveup;
###}
###else {
###  opcode = op[pc].i.code;
###}
###if ( p-op != pc && stackindex != 0 ) {
###  printf( "p-op: %d pc: %d\n", p-op,pc );
###}
###    switch (opcode) {
###      case IEnd: {
###        if ( stackindex != 1 ) {
###          printf( "stackindex != 1! Dying.\n" );
###          exit(0);
###        }
###        capture[ captop ].kind = Cclose;
###        capture[ captop ].s    = NULL;
###        return s;
###      }
###      case IGiveup: {
###        if ( stackindex != 0 ) {
###          printf( "stackindex != 0! Dying.\n" );
###          exit(0);
###        }
###        return NULL;
###      }
###      case IRet: {
###        if ( stackindex < 2 ) {
###          printf( "stackindex < 2! Dying.\n" );
###          exit(0);
###        }
###        if ( stackbase[ stackindex - 1 ].s != NULL ) {
###          printf( "stackbase[ stackindex ].s != NULL! Dying.\n" );
###          exit(0);
###        }
###        Pop_stack( &stack, &stackindex );
###        p  = stackbase[ stackindex ].p;
###        pc = stackbase[ stackindex ].pc;
###        continue;
###      }
###      case IAny: {
###        if ( s < e ) { p++; pc++; s++; }
###        else goto fail;
###        continue;
###      }
###      case ITestAny: {
###        if ( s < e ) { p += 2; pc += 2; }
###        else {
###          p += ( p + 1 )->offset;
###          pc += op[ pc + 1 ].offset;
###        }
###        continue;
###      }
###      case IChar: {
###        if ( (byte)*s == op[pc].i.aux && s < e ) { p++; pc++; s++; }
###        else goto fail;
###        continue;
###      }
###      case ITestChar: {
###        if ( (byte)*s == op[pc].i.aux && s < e ) { p += 2; pc += 2; }
###        else {
###          p += ( p + 1 )->offset;
###          pc += op[ pc + 1 ].offset;
###        }
###        continue;
###      }
###      case ISet: {
###        int c = (byte)*s;
###        if ( testchar( op[ pc + 1 ].buff, c ) && s < e ) {
###          p += CHARSETINSTSIZE;
###          pc += CHARSETINSTSIZE;
###          s++;
###        }
###        else goto fail;
###        continue;
###      }
###      case ITestSet: {
###        int c = (byte)*s;
###        if ( testchar( op[ pc + 2 ].buff, c ) && s < e ) {
###          p += 1 + CHARSETINSTSIZE;
###          pc += 1 + CHARSETINSTSIZE;
###        }
###        else {
###          p += ( p + 1 )->offset;
###          pc += op[ pc + 1 ].offset;
###        }
###        continue;
###      }
###      case IBehind: {
###        int n = op[pc].i.aux;
###        if ( n <= ( s - o ) ) { s -= n; p++; pc++; }
###        else goto fail;
###        continue;
###      }
###      case ISpan: {
###        for ( ; s < e; s++ ) {
###          int c = (byte)*s;
###          if ( !testchar( op[ pc + 1 ].buff, c ) ) break;
###        }
###        p += CHARSETINSTSIZE;
###        pc += CHARSETINSTSIZE;
###        continue;
###      }
###      case IJmp: {
###        p += ( p + 1 )->offset;
###        pc += op[ pc + 1 ].offset;
###        continue;
###      }
###      case IChoice: {
###        maybeDoubleStack( L, ptop, &stack, &stacklimit, &stackbase );
###        PPush_stack(
###          &stack, &stackindex, p + ( p + 1 )->offset,
###                               pc + op[ pc + 1 ].offset, s, captop );
###        p += 2;
###        pc += 2;
###        continue;
###      }
###      case ICall: {
###        maybeDoubleStack( L, ptop, &stack, &stacklimit, &stackbase );
###        PPush_stack( &stack, &stackindex, p + 2, pc + 2, NULL, 0 );
###        p += ( p + 1 )->offset;
###        pc += op[ pc + 1 ].offset;
###        continue;
###      }
###      case ICommit: {
###        if ( stackindex < 1 ) {
###          printf( "stackindex < 1! Dying.\n" );
###          exit(0);
###        }
###        if ( stackbase[ stackindex - 1 ].s == NULL ) {
###          printf( "stackbase[ stackindex ].s != NULL! Dying.\n" );
###          exit(0);
###        }
###        Pop_stack( &stack, &stackindex );
###        p += ( p + 1 )->offset;
###        pc += op[ pc + 1 ].offset;
###        continue;
###      }
###      case IPartialCommit: {
###        if ( stackindex < 1 ) {
###          printf( "stackindex < 1! Dying.\n" );
###          exit(0);
###        }
###        if ( stackbase[ stackindex - 1 ].s == NULL ) {
###          printf( "stackbase[ stackindex ].s != NULL! Dying.\n" );
###          exit(0);
###        }
###        stackbase[ stackindex - 1 ].s = s;
###        stackbase[ stackindex - 1 ].caplevel = captop;
###        p += ( p + 1 )->offset;
###        pc += op[ pc + 1 ].offset;
###        continue;
###      }
###      case IBackCommit: {
###        if ( stackindex < 1 ) {
###          printf( "stackindex < 1! Dying.\n" );
###          exit(0);
###        }
###        if ( stackbase[ stackindex - 1 ].s == NULL ) {
###          printf( "stackbase[ stackindex ].s != NULL! Dying.\n" );
###          exit(0);
###        }
###        Pop_stack( &stack, &stackindex );
###        s      = stackbase[ stackindex ].s;
###        captop = stackbase[ stackindex ].caplevel;
###        p  +=   ( p + 1 )->offset;
###        pc += op[ pc + 1 ].offset;
###        continue;
###      }
###      case IFailTwice: {
###        if ( stackindex < 1 ) {
###          printf( "stackindex < 1! Dying.\n" );
###          exit(0);
###        }
###        Pop_stack( &stack, &stackindex );
###        /* go through */
###      }
###      case IFail:
###      fail: { /* pattern failed: try to backtrack */
###        do {  /* remove pending calls */
###          if ( stackindex < 1 ) {
###            printf( "stackindex < 1! Dying.\n" );
###            exit(0);
###          }
###          Pop_stack( &stack, &stackindex );
###          s = stackbase[ stackindex ].s;
###        } while ( s == NULL );
###        if ( ndyncap > 0 )  /* is there matchtime captures? */
###          ndyncap -=
###            removedyncap( L, capture, stackbase[ stackindex ].caplevel,
###                          captop );
###        captop = stackbase[ stackindex ].caplevel;
###        p      = stackbase[ stackindex ].p;
###        pc     = stackbase[ stackindex ].pc;
###        continue;
###      }
###      case ICloseRunTime: {
###        CapState cs;
###        int rem, res, n;
###        int fr = lua_gettop( L ) + 1;  /* stack index of first result */
###        cs.s = o; cs.L = L; cs.ocap = capture; cs.ptop = ptop;
###        n = runtimecap( &cs, capture + captop, s, &rem );  /* call function */
###        captop -= n;  /* remove nested captures */
###        fr -= rem;  /* 'rem' items were popped from Lua stack */
###        res = resdyncaptures( L, fr, s - o, e - o );  /* get result */
###        if ( res == -1 )  /* fail? */
###          goto fail;
###        s = o + res;  /* else update current position */
###        n = lua_gettop( L ) - fr + 1;  /* number of new captures */
###        ndyncap += n - rem;  /* update number of dynamic captures */
###        if ( n > 0 ) {  /* any new capture? */
###          if ( ( captop += n + 2 ) >= capsize ) {
###            capture = doublecap( L, capture, captop, ptop );
###            capsize = 2 * captop;
###          }
###          /* add new captures to 'capture' list */
###          adddyncaptures( s, capture + captop - n - 2, n, fr ); 
###        }
###        p++;
###        pc++;
###        continue;
###      }
###      case ICloseCapture: {
###        const char *s1 = s;
###        if ( captop < 1 ) {
###          printf( "captop < 1! Dying.\n" );
###          exit(0);
###        }
###        /* if possible, turn capture into a full capture */
###        if (      capture[ captop - 1 ].siz == 0 &&
###             s1 - capture[ captop - 1 ].s < UCHAR_MAX ) {
###          capture[ captop - 1 ].siz = s1 - capture[ captop - 1 ].s + 1;
###          p++;
###          pc++;
###          continue;
###        }
###        else {
###          capture[ captop ].siz = 1;  /* mark entry as closed */
###          capture[ captop ].s   = s;
###          goto pushcapture;
###        }
###      }
###      case IOpenCapture: {
###        /* mark entry as open */
###        capture[ captop ].siz = 0;
###        capture[ captop ].s   = s;
###        goto pushcapture;
###      }
###      case IFullCapture: {
###        /* save capture size */
###        capture[ captop ].siz =     ( ( op[pc].i.aux >> 4 ) & 0xF ) + 1;
###        capture[ captop ].s   = s - ( ( op[pc].i.aux >> 4 ) & 0xF );
###        /* fallthru */
###      }
###      pushcapture: {
###        capture[ captop ].idx  =   op[pc].i.key;
###        capture[ captop ].kind = ( op[pc].i.aux & 0xF );
###        if ( ++captop >= capsize ) {
###          capture = doublecap( L, capture, captop, ptop );
###          capsize = 2 * captop;
###        }
###        p++;
###        pc++;
###        continue;
###      }
###      default: {
###        return NULL;
###      }
###    }
###  }
###}
### }}}

=pod

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

    { pc, i, e } -- Char x -->
                    { pc + 1, i + i, e } ; S[i] = x
    { pc, i, e } -- Char x -->
                    Fail{e}              ; S[i] != x
    { pc, i, e } -- Any -->
                    { pc + 1, i + 1, e } ; i + 1 <= |S| ; i < |S|
    { pc, i, e } -- Any -->
                    Fail{e}              ; i + 1 > |S| ; i >= |S|

    { pc,  i,       e } -- Choice L -->
                        { pc + 1, i, ( pc + L, i ) : e }
    { pc,  i,       e } -- Jump L -->
                        { pc + L, i, e }
    { pc,  i,       e } -- Call L -->
                        { pc + L, i, ( pc + 1, i ) : e }
    { pc0, i, pc1 : e } -- Return -->
                        { pc1, i, e }
    { pc,  i,   h : e } -- Commit L -->
                        { pc + L, i, e }
    { pc,  i,       e } -- Fail -->
                        Fail{e}
Fail{          pc : e } -- any -->
                        Fail{e}
Fail{ ( pc1, i1 ) : e } -- any -->
                        { pc, i1, e }

#
# The other ops
#

{ pc0, i0, ( pc1, i1 ) : e } -- PartialCommit L -->
                             { pc0 + L, i0, ( pc1, i0 ) : e }
{ pc,  i,            h : e } -- FailTwice -->
                             Fail{e}
{ pc0, i0, ( pc1, i1 ) : e } -- BackCommit L -->
                             { pc0 + L, i1, e }
{ pc, i, e } -- TestChar x L -->
                { pc + 1, i + 1, e } ; S[i] = x
{ pc, i, e } -- TestChar x L -->
                { pc + 1, i, e } ; S[1] != x
{ pc, i, e } -- TestAny n L -->
                { pc + n, i + n, e } ; i + n <= |S|
{ pc, i, e } -- TestAny x L -->
                { pc + 1, i, e } ; i + n > |S|

=cut

# static const Instruction giveup = {{IGiveup, 0, 0}};

#
# 'unshift' is the equivalent of pop based on how we're augmenting the "stacK".
# 
# { pc, i, h : e } => ( $pc, $i, do { unshift @e } ) = ( $pc, $i, @e );
#
###Readonly my $INITBACK => 100; # Just for giggles, set a limit of 100 elements.
###Readonly my $INITCAPSIZE => 100; # Just for giggles...
###method run ( $op, $S, $capture ) {
###  my @stackbase = ( ); # The C code starts out with INITBACK elements though.
###  my $stacklimit = $INITBACK; # In C, $stacklimit is a pointer to the top.
###  my $stack = 0; # In C, $stack points to the first empty slot.
###                 # Note that this gets adjusted.
###  my $capsize = $INITCAPSIZE;
###  my $captop = 0; # First empty slot...
###  my $dyncap = 0;
###  my $p = 0; # Start of the op list
###  $stackbase[$stack]->{p} = _giveup;
###  $stackbase[$stack]->s = 0; # Index of the first character.
###  $stackbase[$stack]->caplevel = 0;
###  $stack++;
###
###  my $s = 0; # Index into $S
###
###  while ( 1 ) {
###    if ( $op[$p]->{i}{code} eq 'IEnd' ) {
###      $capture[$captop]->{kind} = 'CClose';
###      $capture[$captop]->{s} = undef;
###      return $s;
###    }
###    if ( $op[$p]->{i}{code} eq 'IGiveup' ) {
###      return undef;
###    }
###    if ( $op[$p]->{i}{code} eq 'IRet' ) {
###      $p = $stackbase[--$stack]->{p};
###      next;
###    }
###    if ( $op[$p]->{i}{code} eq 'IAny' ) {
###      $p++;
###      next;
###    }
###  }
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###
###  while ( 1 ) {
###    my $name = $tuples->[$pc]->[0];
###    my $fail;
###
###    if ( $name eq 'End' ) {
###      return $i; # Returns the pointer to the ... last character? Seems useless.
###    }
###    if ( $name eq 'Giveup' ) {
###      return undef;
###    }
###    if ( $name eq 'Ret' ) {
###      next;
###    }
###    if ( $name eq 'Any' ) {
###      if ( $i < length $s ) {
###        next;
###      }
###      $fail = 1;
###      # DO NOT 'next'.
###    }
###    if ( $name eq 'TestAny' ) {
###      next;
###    }
###    if ( $name eq 'Char' ) {
###      if ( substr( $s, $i, 1 ) eq $x and $i < length( $s ) ) {
###        next;
###      }
###      $fail = 1;
###    }
###    if ( $name eq 'TestChar' ) {
###      next;
###    }
###    if ( $name eq 'Set' ) {
###      next;
###    }
###    if ( $name eq 'TestSet' ) {
###      next;
###    }
###    if ( $name eq 'Behind' ) {
###      if ( $n > $i ) {
###        $fail = 1;
###      }
###      else {
###        next;
###      }
###    }
###    if ( $name eq 'Span' ) {
###      next;
###    }
###    if ( $name eq 'Jump' ) {
###      next;
###    }
###    if ( $name eq 'Choice' ) {
###      next;
###    }
###    if ( $name eq 'Call' ) {
###      next;
###    }
###    if ( $name eq 'Commit' ) {
###      next;
###    }
###    if ( $name eq 'PartialCommit' ) {
###      next;
###    }
###    if ( $name eq 'BackCommit' ) {
###      next;
###    }
###    if ( $name eq 'Fail' ) {
###      $fail = 1;
###    }
###    if ( $name eq 'CloseRunTime' ) {
###    }
###
###    if ( $fail ) {
###      next;
###    }
###
###    return;
###
###
###
###
###
###
###    my $name = $tuples->[$pc]->[0];
###    if ( $name eq 'Char' and $S->[$i] eq $tuples->[$pc]->[1] ) {
###      my $x = $tuples->[$pc]->[1];
###      ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e );
###    }
###    elsif ( $name eq 'Char' and $S->[$i] ne $tuples->[$pc]->[1] ) {
###      my $x = $tuples->[$pc]->[1];
#### Fail{e}
###    }
###    elsif ( $name eq 'Any' and $i + 1 <= scalar @{ $s } ) {
###      ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e);
###    }
###    elsif ( $name eq 'Any' and $i + 1 > scalar @{ $s } ) {
#### Fail{e}
###    }
###    elsif ( $name eq 'Choice' ) {
###      my $L = $tuples->[$pc]->[1];
###      ( $pc, $i, @e ) = ( $pc + 1, $i, [ $pc + $L, $i ], @e );
###    }
###    elsif ( $name eq 'Jump' ) {
###      my $L = $tuples->[$pc]->[1];
###      ( $pc, $i, @e ) = ( $pc + L, $i, @e );
###    }
###    elsif ( $name eq 'Call' ) {
###      my $L = $tuples->[$pc]->[1];
###      ( $pc, $i, @e ) = ( $pc + 1, $i, [ $pc + 1, $i ], @e );
###    }
###    elsif ( $name eq 'Return' ) {
###      my ( $pc1 ) = @{ pop @e };
###      ( $pc, $i, @e ) = ( $pc1, $i, @e );
###    }
###    elsif ( $name eq 'Commit' ) {
###      my $h = @{ pop @e };
###      ( $pc, $i, @e ) = ( $pc + L, $i, @e );
###    }
###    elsif ( $name eq 'Fail' ) {
#### Fail{e}
###    }
###    elsif ( @{ $e->[0] } == 1 ) {
#### Fail{ pc : e }
###    }
###    elsif ( @{ $e->[0] } == 1 ) {
###      my ( $pc1, $i1 ) = @{ pop @e };
#### FAIL
###    }
###  }
###}

#method run ( $tuples, $S ) {
#  my ( $pc, $i, @e ) = ( 0, 0, ( ) );
#  my %instruction = (
#    Char => fun ( $x ) {
#      ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e ) if $S->[$i] eq $x;
#      do { warn "Char: Fail\n"; $done = 1 } if $S->[$i] ne $x;
#    },
#
#    Any => fun ( ) {
#      ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e ) if $i + 1 <= scalar @{ $S };
#      do { warn "Any: Fail\n"; $done = 1 }      if $i + 1 > scalar @{ $S };
#    },
#
#    Choice => fun ( $l ) {
#      ( $pc, $i, @e ) = ( $pc + 1, $i, [ $pc + $l, $i ], @e );
#    },
#
#    Jump => fun ( $l ) {
#      ( $pc, $i, @e ) = ( $pc + $l, $i, @e );
#    },
#
#    Call => fun ( $l ) {
#      ( $pc, $i, @e ) = ( $pc + $l, $i, [ $pc + 1 ], @e );
#    },
#
#    Return => fun ( ) {
#      my ( undef, $pc1, undef ) = @{ pop @e };
#      ( $pc, $i, @e ) = ( $pc1, $i, @e );
#    },
#
#    Commit => fun ( $l ) {
#      my $h = @e;
#      ( $pc, $i, @e ) = ( $pc + $l, $i, @e );
#    },
#
#    Fail => fun ( ) {
#      my $done;
#      my $entry;
#my $count = 10;
#      while ( !$done ) {
#last if $count-- <= 1;
#        my ( $pc1, $i1 ) = @{ pop @e };
#        next unless $name eq 'Return';
#        $pc = $pc1;
#        $i = $i1;
#        last;
#      }
#    }
#  );
#
##my $count = 10;
#  my $done;
#  while ( !$done ) {
##last if $count-- <= 1;
#
#    if ( $pc >= @{ $tuples } ) {
#warn "Walked off the edge of the instruction list.\n";
#      last;
#    }
#
#    my ( $instruction_name, @args ) = @{ $tuples->[ $pc ] };
#warn "[$instruction_name]\n";
#
#    my %instruction = (
#
#      Char => fun ( $x ) {
#        ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e ) if $S->[$i] eq $x;
#        do { warn "Char: Fail\n"; $done = 1 } if $S->[$i] ne $x;
#      },
#
#      Any => fun ( ) {
#        ( $pc, $i, @e ) = ( $pc + 1, $i + 1, @e ) if $i + 1 <= scalar @{ $S };
#        do { warn "Any: Fail\n"; $done = 1 }      if $i + 1 > scalar @{ $S };
#      },
#
#      Choice => fun ( $l ) {
#        ( $pc, $i, @e ) = ( $pc + 1, $i, [ $pc + $l, $i ], @e );
#      },
#
#      Jump => fun ( $l ) {
#        ( $pc, $i, @e ) = ( $pc + $l, $i, @e );
#      },
#
#      Call => fun ( $l ) {
#        ( $pc, $i, @e ) = ( $pc + $l, $i, [ $pc + 1 ], @e );
#      },
#
#      Return => fun ( ) {
#        my ( undef, $pc1, undef ) = @{ pop @e };
#        ( $pc, $i, @e ) = ( $pc1, $i, @e );
#      },
#
#      Commit => fun ( $l ) {
#        my $h = @e;
#        ( $pc, $i, @e ) = ( $pc + $l, $i, @e );
#      },
#
#      Fail => fun ( ) {
#        my $done;
#        my $entry;
#  my $count = 10;
#        while ( !$done ) {
#  last if $count-- <= 1;
#          my ( $pc1, $i1 ) = @{ pop @e };
#          next unless $name eq 'Return';
#          $pc = $pc1;
#          $i = $i1;
#          last;
#        }
#      }
#    );
#
#    if ( exists $instruction{$instruction_name} ) {
#      $instruction{$instruction_name}->( @args );
#      next;
#    }
#    else {
#      croak "Instruction named '$instruction_name' not found!\n";
#    }
#  }
#}

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

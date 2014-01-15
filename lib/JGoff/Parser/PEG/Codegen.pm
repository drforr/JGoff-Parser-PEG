package JGoff::Parser::PEG::Codegen;

use Moose;                # XXX May be removed later
use Function::Parameters; # XXX Will probably be removed later
use Readonly;

use JGoff::Parser::PEG::Constants qw(
  $UCHAR_MAX
  $BITSPERCHAR
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

  $TChar
  $TSet
  $TAny
  $TTrue
  $TFalse
  $TRep
  $TSeq
  $TChoice
  $TNot
  $TAnd
  $TCall
  $TOpenCall
  $TRule
  $TGrammar
  $TBehind
  $TCapture
  $TRunTime

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


  $PEnullable
  $PEnofail

  $MAXBEHIND
  $MAXOFF
  $MAXRULES
);

# signals a "no-instruction
Readonly my $NOINST => -1;

Readonly my $fullset => [
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
];

method nofail ( $t ) {
  $self->checkaux( $t, $PEnofail );
}

method nullable ( $t ) {
  $self->checkaux( $t, $PEnullable );
}

method fixedlen( $t ) {
  $self->fixedlenx( $t, 0, 0 );
}

#
# ======================================================
# Analysis and some optimizations
# =======================================================
#

#
# Check whether a charset is empty (IFail), singleton (IChar),
# full (IAny), or none of those (ISet).
#
method charsettype ( $cs, $c ) {
  my $count = 0;
  my $i;
  my $candidate = -1; # candidate position for a char
  for ( $i = 0; $i < $CHARSETSIZE; $i++ ) {
    my $b = $cs->[ $i ];
    if ( $b == 0 ) {
      if ( $count > 1 ) {
        return $ISet; # else set is still empty
      }
    }
    elsif ( $b == 0xFF ) {
      if ( $count < ( $i * $BITSPERCHAR ) ) {
        return $ISet;
      }
      else {
        $count += $BITSPERCHAR; # set is still full
      }
    }
    elsif ( ( $b & ( $b - 1 ) ) == 0 ) { # byte has only one bit?
      if ( $count > 0 ) {
        return $ISet; # set is neither full nor empty
      }
      else {  # set has only one char till now; track it */
        $count++;
        $candidate = $i;
      }
    }
    else {
      return $ISet; # byte is neither empty, full, nor singleton
    }
  }
  if ( $count == 0 ) {
    return $IFail; # empty set
  }
  if ( $count == 1 ) { # XXX $c is *c
    my $b = $cs->[ $candidate ];
    $c = $candidate * $BITSPERCHAR;
    if ( ( $b & 0xF0 ) != 0 ) { $c += 4; $b >>= 4; }
    if ( ( $b & 0x0C ) != 0 ) { $c += 2; $b >>= 2; }
    if ( ( $b & 0x02 ) != 0 ) { $c += 1; }
    return $IChar;
  }
  assert( 0 ) unless
    $count == $CHARSETSIZE * $BITSPERCHAR; # full set
  return $IAny;
}

#
# A few basic operations on Charsets
#
method cs_complement ( $cs ) {
#  $self->loopset( $i, $cs->{cs}->[ $i ] = ~$cs->{cs}->[ $i ] ); # XXX
}

method cs_equal ( $cs1, $cs2 ) {
#  $self->loopset( $i, if (cs1[i] != cs2[i]) return 0); # XXX
  return 1;
}

#
# computes whether sets cs1 and cs2 are disjoint
#
method cs_disjoint ( $cs1, $cs2 ) {
#  $self->loopset( $i, if ((cs1->cs[i] & cs2->cs[i]) != 0) return 0;) # XXX
  return 1;
}

#
# Convert a 'char' pattern (TSet, TChar, TAny) to a charset
#
method tocharset ( $tree, $cs ) {
  if ( $tree->{tag} eq $TSet ) { # copy set
    #$self->loopset(i, cs->cs[i] = treebuffer(tree)[i]); # XXX
    return 1;
  }
  if ( $tree->{tag} eq $TChar ) {  # only one char
    assert( 0 ) unless 0 <= $tree->{n} && $tree->{n} <= $UCHAR_MAX;
    #$self->loopset(i, cs->cs[i] = 0);  # erase all chars # XXX
    $self->setchar( $cs->{cs}, $tree->{n}); # add that one
    return 1;
  }
  if ( $tree->{tag} eq $TAny ) {
    #$self->loopset(i, cs->cs[i] = 0xFF);  # add all to the set # XXX
    return 1;
  }
  return 0;
}

my $numsiblings = []; # XXX
#
# Checks whether a pattern has captures
#
method hascaptures ( $tree ) {
  tailcall: {
    if ( $tree->{tag} eq $TCapture or
         $tree->{tag} eq $TRunTime ) {
      return 1;
    }
    else {
      if ( $numsiblings->[ $tree->{tag} ] == 1 ) {
        # return hascaptures(sib1(tree));
        $tree = $self->sib1( $tree );
        goto tailcall;
      }
      if ( $numsiblings->[ $tree->{tag} ] == 2 ) {
        if ( $self->hascaptures( $self->sib1( $tree ) ) ) {
          return 1;
        }
        $tree = $self->sib2( $tree );
        goto tailcall;
      }
      assert( "foo" ) unless $numsiblings->[ $tree->{tag} ] == 0;
      return 0;
    }
  }
}

#
# Checks how a pattern behaves regarding the empty string,
# in one of two different ways:
# A pattern is *nullable* if it can match without consuming any character;
# A pattern is *nofail* if it never fails for any string
# (including the empty string).
# The difference is only for predicates and run-time captures;
# for other patterns, the two properties are equivalent.
# (With predicates, &'a' is nullable but not nofail. Of course,
# nofail => nullable.)
# These functions are all convervative in the following way:
#    p is nullable => nullable(p)
#    nofail(p) => p cannot fail
# The function assumes that TOpenCall is not nullable;
# this will be checked again when the grammar is fixed.)
# Run-time captures can do whatever they want, so the result
# is conservative.
#
method checkaux ( $tree, $pred ) {
  tailcall: {
    return 0 if
      $tree->{tag} eq $TChar or
      $tree->{tag} eq $TSet or
      $tree->{tag} eq $TAny or
      $tree->{tag} eq $TFalse or
      $tree->{tag} eq $TOpenCall; # not nullable
    return 1 if
      $tree->{tag} eq $TRep or
      $tree->{tag} eq $TTrue; # no fail
    if ( $tree->{tag} eq $TNot or
            $tree->{tag} eq $TBehind ) { # can match empty, but can fail
      return 0 if
        $pred eq $PEnofail;
      return 1; # PEnullable
    }
    elsif ( $tree->{tag} eq $TAnd ) { # can match empty; fail iff body does
      return 1 if
        $pred eq $PEnullable;
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TRunTime ) { # can fail; match empty iff body does
      return 0 if
        $pred eq $PEnofail;
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TSeq ) {
      return 0 if
        !$self->checkaux( $self->sib1( $tree ), $pred );
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TChoice ) {
      return 1 if
        $self->checkaux( $self->sib2( $tree ), $pred );
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TCapture or
            $tree->{tag} eq $TGrammar or
            $tree->{tag} eq $TRule ) {
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TCall ) {
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    assert( "foo" );
    return 0;
  }
}

#
# number of characters to match a pattern (or -1 if variable)
# ('count' avoids infinite loops for grammars)
#
method fixedlenx ( $tree, $count, $len ) {
  tailcall: {
    if ( $tree->{tag} eq $TChar or
         $tree->{tag} eq $TSet or
         $tree->{tag} eq $TAny ) {
      return $len + 1;
    }
    if ( $tree->{tag} eq $TFalse or
            $tree->{tag} eq $TTrue or
            $tree->{tag} eq $TNot or
            $tree->{tag} eq $TAnd or
            $tree->{tag} eq $TBehind ) {
      return $len;
    }
    if ( $tree->{tag} eq $TRep or
            $tree->{tag} eq $TRunTime or
            $tree->{tag} eq $TOpenCall ) {
      return -1;
    }
    if ( $tree->{tag} eq $TCapture or
            $tree->{tag} eq $TRule or
            $tree->{tag} eq $TGrammar ) {
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TCall ) {
      return -1 if
        $count++ >= $MAXRULES; # May be a loop
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TSeq ) {
      $len = $self->fixedlenx( $self->sib1( $tree ), $count, $len );
      return -1 if
        $len < 0;
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TChoice ) {
      my ( $n1, $n2 );
      $n1 = $self->fixedlenx( $self->sib1( $tree ), $count, $len );
      return -1 if
        $n1 < 0;
      $n2 = $self->fixedlenx( $self->sib2( $tree ), $count, $len );
      return $n1 if
        $n1 == $n2;
      return -1;
    }
    assert( "foo" );
    return 0;
  }
}

#
# Computes the 'first set' of a pattern.
# The result is a conservative aproximation:
#   match p ax -> x' for some x ==> a in first(p).
# The set 'follow' is the first set of what follows the
# pattern (full set if nothing follows it).
# The function returns 0 when this set can be used for
# tests that avoid the pattern altogether.
# A non-zero return can happen for two reasons:
# 1) match p '' -> ''            ==> returns 1.
# (tests cannot be used because they always fail for an empty input)
# 2) there is a match-time capture ==> returns 2.
# (match-time captures should not be avoided by optimizations)
#
method getfirst ( $tree, $follow, $firstset ) {
  tailcall: {
    if ( $tree->{tag} eq $TChar or
         $tree->{tag} eq $TSet or
         $tree->{tag} eq $TAny ) {
      $self->tocharset( $tree, $firstset );
      return 0;
    }
    if ( $tree->{tag} eq $TTrue ) {
      #$self->loopset(i, firstset->cs[i] = follow->cs[i]); # XXX
      return 1;
    }
    if ( $tree->{tag} eq $TFalse ) {
      #$self->loopset(i, firstset->cs[i] = 0); # XXX
      return 0;
    }
    if ( $tree->{tag} eq $TChoice ) {
      my $csaux;
      my $e1 = $self->getfirst( $self->sib1( $tree ), $follow, $firstset );
      my $e2 = $self->getfirst( $self->sib2( $tree ), $follow, \$csaux );
      #$self->loopset(i, firstset->cs[i] |= csaux.cs[i]);
      return $e1 | $e2;
    }
    elsif ( $tree->{tag} eq $TSeq ) {
      if (! $self->nullable( $self->sib1( $tree ) ) ) {
        # return getfirst(sib1(tree), fullset, firstset);
        $tree = $self->sib1( $tree ); $follow = $fullset; goto tailcall;
      }
      else {  # FIRST(p1 p2, fl) = FIRST(p1, FIRST(p2, fl))
        my $csaux;
        my $e2 = $self->getfirst( $self->sib2( $tree ), $follow, \$csaux );
        my $e1 = $self->getfirst( $self->sib1( $tree ), \$csaux, $firstset );
        if ( $e1 == 0) { return 0; } # 'e1' ensures that first can be used
        elsif ( ( $e1 | $e2 ) & 2 ) { # one of the children has a matchtime?
          return 2;  # pattern has a matchtime capture
        }
        else {
          return $e2;  # else depends on 'e2'
        }
      }
    }
    elsif ( $tree->{tag} eq $TRep ) {
      $self->getfirst( $self->sib1( $tree ), $follow, $firstset );
      #$self->loopset(i, firstset->cs[i] |= follow->cs[i]);
      return 1;  # accept the empty string
    }
    if ( $tree->{tag} eq $TCapture or
         $tree->{tag} eq $TGrammar or
         $tree->{tag} eq $TRule ) {
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    if ( $tree->{tag} eq $TRunTime ) { # function invalidates any follow info.
      my $e = $self->getfirst( $self->sib1( $tree ), $fullset, $firstset );
      if ( $e ) { return 2; } # function is not "protected"?
      else { return 0; } # pattern inside capture ensures first can be used
    }
    if ( $tree->{tag} eq $TCall ) {
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    if ( $tree->{tag} eq $TAnd ) {
      my $e = $self->getfirst( $self->sib1( $tree ), $follow, $firstset );
      #$self->loopset(i, firstset->cs[i] &= follow->cs[i]); # XXX
      return $e;
    }
    elsif ( $tree->{tag} eq $TNot ) {
      if ( $self->tocharset( $self->sib1( $tree ), $firstset ) ) {
        $self->cs_complement( $firstset );
        return 1;
      }
      # else go through # XXX ???
    }
    elsif ( $tree->{tag} eq $TBehind ) { # instruction gives no new information
      # call 'getfirst' to check for math-time captures */
      my $e = $self->getfirst( $self->sib1( $tree ), $follow, $firstset );
      #$self->loopset(i, firstset->cs[i] = follow->cs[i]);  # uses follow # XXX
      return $e | 1;  # always can accept the empty string
    }
    else {
      assert( 0 );
      return 0;
    }
  }
}

#
# If it returns true, then pattern can fail only depending on the next
# character of the subject
#
method headfail ( $tree ) {
  tailcall: {
    return 1 if
      $tree->{tag} eq $TChar or
      $tree->{tag} eq $TSet or
      $tree->{tag} eq $TFalse;
    return 0 if
      $tree->{tag} eq $TTrue or
      $tree->{tag} eq $TRep or
      $tree->{tag} eq $TRunTime or
      $tree->{tag} eq $TNot or
      $tree->{tag} eq $TBehind;
    if ( $tree->{tag} eq $TCapture or
         $tree->{tag} eq $TGrammar or
         $tree->{tag} eq $TRule or
         $tree->{tag} eq $TAnd ) {
      $tree = $self->sib1( $tree );
      goto tailcall; # return headfail(sib1(tree));
    }
    elsif ( $tree->{tag} eq $TCall ) {
      $tree = $self->sib2( $tree );
      goto tailcall; # return headfail(sib2(tree));
    }
    elsif ( $tree->{tag} eq $TSeq ) {
      return 0 if
        !$self->nofail( $self->sib2( $tree ) );
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    elsif ( $tree->{tag} eq $TChoice ) {
      return 0 if
        ! $self->headfail( $self->sib1( $tree ) );
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    assert( "foo" );
    return 0;
  }
}

#
# Check whether the code generation for the given tree can benefit
# from a follow set (to avoid computing the follow set when it is
# not needed)
#
method needfollow ( $tree ) {
  tailcall: {
    return 0 if
      $tree->{tag} eq $TChar or
      $tree->{tag} eq $TSet or
      $tree->{tag} eq $TAny or
      $tree->{tag} eq $TFalse or
      $tree->{tag} eq $TTrue or
      $tree->{tag} eq $TAnd or
      $tree->{tag} eq $TNot or
      $tree->{tag} eq $TRunTime or
      $tree->{tag} eq $TGrammar or
      $tree->{tag} eq $TCall or
      $tree->{tag} eq $TBehind;
    return 1 if
      $tree->{tag} eq $TChoice or
      $tree->{tag} eq $TRep;
    if ( $tree->{tag} eq $TCapture ) {
      $tree = $self->sib1( $tree );
      goto tailcall;
    }
    if ( $tree->{tag} eq $TSeq ) {
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    assert( "foo" );
    return 0;
  }
}

#
# ======================================================
# Code generation
# ======================================================
#

#
# size of an instruction
#
method sizei ( $i ) {
  return $CHARSETINSTSIZE if
    $i->{code} eq $ISet or
    $i->{code} eq $ISpan;
  return $CHARSETINSTSIZE + 1 if
    $i->{code} eq $ITestSet;
  return 2 if
    $i->{code} eq $ITestChar or
    $i->{code} eq $ITestAny or
    $i->{code} eq $IChoice or
    $i->{code} eq $IJmp or
    $i->{code} eq $ICall or
    $i->{code} eq $IOpenCall or
    $i->{code} eq $ICommit or
    $i->{code} eq $IPartialCommit or
    $i->{code} eq $IBackCommit;
  return 1;
}

#
# state for the compiler
#
#typedef struct CompileState {
#  Pattern *p;  # pattern being compiled */
#  int ncode;  # next position in p->code to be filled */
#  lua_State *L;
#} CompileState;


#
# code generation is recursive; 'opt' indicates that the code is
# being generated under a 'IChoice' operator jumping to its end.
# 'tt' points to a previous test protecting this code. 'fl' is
# the follow set of the pattern.
#
#static void codegen (CompileState *compst, TTree *tree, int opt, int tt,
#                     const Charset *fl);


method reallocprog ( $L, $p, $nsize ) {
  $p->{codesize} = $nsize;
}


method nextinstruction ( $compst ) {
  my $size = $compst->{p}->{codesize};
  if ( $compst->{ncode} >= $size ) {
    $self->reallocprog( $compst->{L}, $compst->{p}, $size * 2 );
  }
  return $compst->{ncode}++;
}

#define getinstr(cs,i)		((cs)->p->code[i])

method getinstr ( $compst, $i ) {
  $compst->{p}->{code}->[ $i ];
}

method addinstruction ( $compst, $op, $aux ) {
  my $i = $self->nextinstruction( $compst );
  $self->getinstr( $compst, $i )->{code} = $op;
  $self->getinstr( $compst, $i )->{aux} = $aux;
  return $i;
}

method addoffsetinst ( $compst, $op ) {
  my $i = $self->addinstruction( $compst, $op, 0 ); # instruction
  $self->addinstruction( $compst, 0, 0 ); # open space for offset # XXX cast
  assert( "foo" ) unless
    $op eq $ITestSet || $self->sizei( $self->getinstr( $compst, $i ) ) == 2;
  return $i;
}

method setoffset ( $compst, $instruction, $offset ) {
  $self->getinstr( $compst, $instruction + 1 )->{offset} = $offset;
}

#
# Add a capture instruction:
# 'op' is the capture instruction; 'cap' the capture kind;
# 'key' the key into ktable; 'aux' is optional offset
#
#
method addinstcap ( $compst, $op, $cap, $key, $aux ) {
  my $i = $self->addinstruction( $compst, $op,
                                 $self->joinkindoff( $cap, $aux ) );
  $self->getinstr( $compst, $i )->{key} = $key;
  return $i;
}

#define gethere(compst) 	((compst)->ncode)

method gethere( $compst ) {
  $compst->{ncode};
}

#define target(code,i)		((i) + code[i + 1].offset)

method target( $code, $i ) {
  $i + $code->[ $i + 1 ]->{offset};
}


method jumptothere ( $compst, $instruction, $target ) {
  if ( $instruction >= 0) {
    $self->setoffset( $compst, $instruction, $target - $instruction );
  }
}


method jumptohere ( $compst, $instruction ) {
  $self->jumptothere( $compst, $instruction, $self->gethere( $compst ) );
}

#
# Code an IChar instruction, or IAny if there is an equivalent
# test dominating it
#
method codechar ( $compst, $c, $tt ) {
  if ( $tt >= 0 &&
       $self->getinstr( $compst, $tt )->{code} eq $ITestChar &&
       $self->getinstr( $compst, $tt )->{aux} == $c ) {
    $self->addinstruction( $compst, $IAny, 0 );
  }
  else {
    $self->addinstruction( $compst, $IChar, $c );
  }
}

#
# Add a charset posfix to an instruction
#
method addcharset ( $compst, $cs ) {
  my $p = $self->gethere( $compst );
  my $i;
  for ( $i = 0; $i < $CHARSETINSTSIZE - 1; $i++ ) {
    $self->nextinstruction( $compst ); # space for buffer
  }
  # fill buffer with charset */
  #$self->loopset( $j, $self->getinstr( $compst, $p )->{buff}->[ $j ] = $cs->[ $j ] ); # XXX
}


#
# code a char set, optimizing unit sets for IChar, "complete"
# sets for IAny, and empty sets for IFail; also use an IAny
# when instruction is dominated by an equivalent test.
#
method codecharset ( $compst, $cs, $tt ) {
  my $c = 0;  # (=) to avoid warnings
  my $op = $self->charsettype( $cs, \$c );
  if ( $op eq $IChar ) {
    $self->codechar( $compst, $c, $tt );
  }
  elsif ( $op eq $ISet ) {
    if ( $tt >= 0 &&
         $self->getinstr( $compst, $tt )->{i}->{code} eq $ITestSet &&
         $self->cs_equa( $cs, $self->getinstr( $compst, $tt + 2 )->{buff} ) ) {
      $self->addinstruction( $compst, $IAny, 0 );
    }
    else {
      $self->addinstruction( $compst, $ISet, 0 );
      $self->adcharset( $compst, $cs );
    }
  }
  else {
    $self->addinstruction( $compst, $op, $c );
  }
}

#
# code a test set, optimizing unit sets for ITestChar, "complete"
# sets for ITestAny, and empty sets for IJmp (always fails).
# 'e' is true iff test should accept the empty string. (Test
# instructions in the current VM never accept the empty string.)
#
method codetestset ( $compst, $cs, $e ) {
  if ( $e ) {
    return $NOINST;
  } # no test
  else {
    my $c = 0;
    my $op = $self->charsettype( $cs->{cs}, \$c ); # XXX Ref
    return $self->addoffsetinst( $compst, $IJmp ) if # always jump
      $op eq $IFail;
    return $self->addoffsetinst( $compst, $ITestAny ) if
      $op eq $IAny;
    if ( $op eq $IChar ) {
      my $i = $self->addoffsetinst( $compst, $ITestChar );
      $self->getinstr( $compst, $i )->{i}->{aux} = $c;
      return $i;
    }
    if ( $op eq $ISet ) {
      my $i = $self->addoffsetinst( $compst, $ITestSet );
      $self->addcharset( $compst, $cs->{cs} );
      return $i;
    }
    assert( 0 );
    return 0;
  }
}

#
# Find the final destination of a sequence of jumps
#
method finaltarget ( $code, $i ) {
  while ( $code->[ $i ]->{i}{code} eq $IJmp ) {
    $i = $self->target( $code, $i );
  }
  return $i;
}

#
# final label (after traversing any jumps)
#
method finallabel ( $code, $i ) {
  return $self->finaltarget( $code, $self->target( $code, $i ) );
}

#
# <behind(p)> == behind n; <p>   (where n = fixedlen(p))
#
method codebehind ( $compst, $tree ) {
  if ( $tree->{n} > 0) {
    $self->addinstruction( $compst, $IBehind, $tree->{n} );
  }
  $self->codegen( $compst, $self->sib1( $tree ), 0, $NOINST, $fullset );
}

#
# Choice; optimizations:
# - when p1 is headfail
# - when first(p1) and first(p2) are disjoint; than
# a character not in first(p1) cannot go to p1, and a character
# in first(p1) cannot go to p2 (at it is not in first(p2)).
# (The optimization is not valid if p1 accepts the empty string,
# as then there is no character at all...)
# - when p2 is empty and opt is true; a IPartialCommit can resuse
# the Choice already active in the stack.
#
method codechoice ( $compst, $p1, $p2, $opt, $fl ) {
  my $emptyp2 = ( $p2->{tag} eq $TTrue );
  my ( $cs1, $cs2 );
  my $e1 = $self->getfirst( $p1, $fullset, \$cs1 );
  if ( $self->headfail( $p1 ) ||
      (!$e1 && ( $self->getfirst( $p2, $fl, \$cs2 ),
               $self->cs_disjoint(\$cs1, \$cs2 ) ) ) ) {
    # <p1 / p2> == test (fail(p1)) -> L1 ; p1 ; jmp L2; L1: p2; L2: */
    my $test = $self->codetestset( $compst, \$cs1, 0 );
    my $jmp = $NOINST;
    $self->codegen( $compst, $p1, 0, $test, $fl );
    if ( !$emptyp2 ) {
      $jmp = $self->addoffsetinst( $compst, $IJmp ); 
    }
    $self->jumptohere( $compst, $test );
    $self->codegen( $compst, $p2, $opt, $NOINST, $fl );
    $self->jumptohere( $compst, $jmp );
  }
  elsif ( $opt && $emptyp2 ) {
    # p1? == IPartialCommit; p1 */
    $self->jumptohere( $compst,
                       $self->addoffsetinst( $compst, $IPartialCommit ) );
    $self->codegen( $compst, $p1, 1, $NOINST, $fullset );
  }
  else {
    # <p1 / p2> == 
    #    test(fail(p1)) -> L1; choice L1; <p1>; commit L2; L1: <p2>; L2: */
    my $pcommit;
    my $test = $self->codetestset( $compst, \$cs1, $e1 );
    my $pchoice = $self->addoffsetinst( $compst, $IChoice );
    $self->codegen( $compst, $p1, $emptyp2, $test, $fullset );
    $pcommit = $self->addoffsetinst( $compst, $ICommit );
    $self->jumptohere( $compst, $pchoice );
    $self->jumptohere( $compst, $test );
    $self->codegen( $compst, $p2, $opt, $NOINST, $fl );
    $self->jumptohere( $compst, $pcommit );
  }
}

#
# And predicate
# optimization: fixedlen(p) = n ==> <&p> == <p>; behind n
# (valid only when 'p' has no captures)
#
method codeand ( $compst, $tree, $tt ) {
  my $n = $self->fixedlen( $tree );
  if ( $n >= 0 && $n <= $MAXBEHIND && ! $self->hascaptures( $tree ) ) {
    $self->codegen( $compst, $tree, 0, $tt, $fullset );
    if ( $n > 0 ) {
      $self->addinstruction( $compst, $IBehind, $n );
    }
  }
  else { # default: Choice L1; p1; BackCommit L2; L1: Fail; L2:
    my $pcommit;
    my $pchoice = $self->addoffsetinst( $compst, $IChoice );
    $self->codegen( $compst, $tree, 0, $tt, $fullset );
    $pcommit = $self->addoffsetinst( $compst, $IBackCommit );
    $self->jumptohere( $compst, $pchoice );
    $self->addinstruction( $compst, $IFail, 0 );
    $self->jumptohere( $compst, $pcommit );
  }
}

#
# Captures: if pattern has fixed (and not too big) length, use
# a single IFullCapture instruction after the match; otherwise,
# enclose the pattern with OpenCapture - CloseCapture.
#
method codecapture ( $compst, $tree, $tt, $fl ) {
  my $len = $self->fixedlen( $self->sib1( $tree ) );
  if ( $len >= 0 && $len <= $MAXOFF && !$self->hascaptures( $self->sib1( $tree ) ) ) {
    $self->codegen( $compst, $self->sib1( $tree ), 0, $tt, $fl );
    $self->addinstcap( $compst, $IFullCapture, $tree->{cap}, $tree->{key}, $len );
  }
  else {
    $self->addinstcap( $compst, $IOpenCapture, $tree->{cap}, $tree->{key}, 0 );
    $self->codegen( $compst, $self->sib1( $tree ), 0, $tt, $fl );
    $self->addinstcap( $compst, $ICloseCapture, $Cclose, 0, 0 );
  }
}

method coderuntime ( $compst, $tree, $tt ) {
  $self->addinstcap( $compst, $IOpenCapture, $Cgroup, $tree->{key}, 0 );
  $self->codegen( $compst, $self->sib1( $tree ), 0, $tt, $fullset );
  $self->addinstcap( $compst, $ICloseRunTime, $Cclose, 0, 0 );
}

#
# Repetion; optimizations:
# When pattern is a charset, can use special instruction ISpan.
# When pattern is head fail, or if it starts with characters that
# are disjoint from what follows the repetions, a simple test
# is enough (a fail inside the repetition would backtrack to fail
# again in the following pattern, so there is no need for a choice).
# When 'opt' is true, the repetion can reuse the Choice already
# active in the stack.
#
method coderep ( $compst, $tree, $opt, $fl ) {
  my $st;
  if ( $self->tocharset( $tree, \$st ) ) {
    $self->addinstruction( $compst, $ISpan, 0 );
    $self->addcharset( $compst, $st->{cs} );
  }
  else {
    my $e1 = $self->getfirst( $tree, $fullset, \$st );
    if ( $self->headfail( $tree ) ||
         (!$e1 && $self->cs_disjoint( \$st, $fl ) ) ) {
      # L1: test (fail(p1)) -> L2; <p>; jmp L1; L2: */
      my $jmp;
      my $test = $self->codetestset( $compst, \$st, 0 );
      $self->codegen( $compst, $tree, $opt, $test, $fullset );
      $jmp = $self->addoffsetinst( $compst, $IJmp );
      $self->jumptohere( $compst, $test );
      $self->jumptothere( $compst, $jmp, $test );
    }
    else {
      # test(fail(p1)) -> L2; choice L2; L1: <p>; partialcommit L1; L2: */
      # or (if 'opt'): partialcommit L1; L1: <p>; partialcommit L1; */
      my ( $commit, $l2 );
      my $test = $self->codetestset( $compst, \$st, $e1 );
      my $pchoice = $NOINST;
      if ( $opt ) {
        $self->jumptohere( $compst,
                           $self->addoffsetinst( $compst, $IPartialCommit ) );
      }
      else {
        $pchoice = $self->addoffsetinst( $compst, $IChoice );
      }
      $l2 = $self->gethere( $compst );
      $self->codegen( $compst, $tree, 0, $NOINST, $fullset );
      $commit = $self->addoffsetinst( $compst, $IPartialCommit );
      $self->jumptothere( $compst, $commit, $l2 );
      $self->jumptohere( $compst, $pchoice );
      $self->jumptohere( $compst, $test );
    }
  }
}

#
# Not predicate; optimizations:
# In any case, if first test fails, 'not' succeeds, so it can jump to
# the end. If pattern is headfail, that is all (it cannot fail
# in other parts); this case includes 'not' of simple sets. Otherwise,
# use the default code (a choice plus a failtwice).
#
method codenot ( $compst, $tree ) {
  my $st;
  my $e = $self->getfirst( $tree, $fullset, $st );
  my $test = $self->codetestset( $compst, $st, $e );
  if ( $self->headfail( $tree ) ) { # test (fail(p1)) -> L1; fail; L1:
    $self->addinstruction( $compst, $IFail, 0 );
  }
  else {
    # test(fail(p))-> L1; choice L1; <p>; failtwice; L1:
    my $pchoice = $self->addoffsetinst( $compst, $IChoice );
    $self->codegen( $compst, $tree, 0, $NOINST, $fullset );
    $self->addinstruction( $compst, $IFailTwice, 0 );
    $self->jumptohere( $compst, $pchoice );
  }
  $self->jumptohere( $compst, $test );
}

#
# change open calls to calls, using list 'positions' to find
# correct offsets; also optimize tail calls
#
method correctcalls ( $compst, $positions, $from, $to ) {
  my $code = $compst->{p}->{code};
  my $i;
  for ( $i = $from; $i < $to; $i += $self->sizei( $code->[ $i ] ) ) {
    if ( $code->[ $i ]->{code} eq $IOpenCall ) {
      my $n = $code->[ $i ]->{key}; # rule number
      my $rule = $positions->[ $n ]; # rule position
      assert( "Foo" ) unless
        ( $rule eq $from ) ||
        ( $code->[ $rule - 1 ]->{code} eq $IRet );
      if ( $code->[ $self->finaltarget( $code, $i + 2 ) ]->{i}->{code} eq $IRet ) { # call; ret ?
        $code->[ $i ]->{i}->{code} = $IJmp; # tail call
      }
      else {
        $code->[ $i ]->{i}->{code} = $ICall;
      }
      $self->jumptothere( $compst, $i, $rule ); # call jumps to respective rule
    }
  }
  assert( "foo" ) unless
    $i == $to;
}

#
# Code for a grammar:
# call L1; jmp L2; L1: rule 1; ret; rule 2; ret; ...; L2:
#
method codegrammar ( $compst, $grammar ) {
  my $positions = []; # MAXRULES
  my $rulenumber = 0;
  my $rule;
  my $firstcall = $self->addoffsetinst( $compst, $ICall ); # call initial rule
  my $jumptoend = $self->addoffsetinst( $compst, $IJmp );  # jump to the end
  my $start = $self->gethere( $compst ); # here starts the initial rule */
  $self->jumptohere( $compst, $firstcall );
  for ( my $rule = $self->sib1( $grammar );
        $rule->{tag} eq $TRule;
        $rule = $self->sib2( $rule ) ) {
    # save rule position
    $positions->[ $rulenumber++ ] = $self->gethere( $compst );
    # code rule
    $self->codegen( $compst, $self->sib1( $rule ), 0, $NOINST, $fullset );
    $self->addinstruction( $compst, $IRet, 0);
  }
  assert( "foo" ) unless
    $rule->{tag} eq $TTrue;
  $self->jumptohere( $compst, $jumptoend );
  $self->correctcalls( $compst, $positions, $start, $self->gethere( $compst ) );
}

method codecall ( $compst, $call ) {
  my $c = $self->addoffsetinst( $compst, $IOpenCall ); # to be corrected later
  $self->getinstr( $compst, $c)->{key} = $self->sib2( $call )->{cap};
  # rule number
  assert( "foo" ) unless
    $self->sib2( $call )->{tag} == $TRule;
}

#
# Code first child of a sequence
# (second child is called in-place to allow tail call)
# Return 'tt' for second child
#
method codeseq1 ( $compst, $p1, $p2, $tt, $fl ) {
  if ( $self->needfollow( $p1 ) ) {
    my $fl1;
    $self->getfirst( $p2, $fl, $fl1 ); # p1 follow is p2 first */
    $self->codegen( $compst, $p1, 0, $tt, $fl1 );
  }
  else {  # use 'fullset' as follow */
    $self->codegen( $compst, $p1, 0, $tt, $fullset );
  }
  if ( $self->fixedlen( $p1 ) != 0 ) {  # can 'p1' consume anything? */
    return $NOINST;  # invalidate test */
  }
  else {
    return $tt;  # else 'tt' still protects sib2 */
  }
}

#
# Main code-generation function: dispatch to auxiliar functions
# according to kind of tree
#
method codegen( $compst, $tree, $opt, $tt, $fl ) {
  tailcall: {
    if ( $tree->{tag} eq $TChar ) {
      $self->codechar( $compst, $tree->{n}, $tt );
    }
    elsif ( $tree->{tag} eq $TAny ) {
      $self->addinstruction( $compst, $IAny, 0 );
    }
    elsif ( $tree->{tag} eq $TSet ) {
      $self->codecharset( $compst, $self->treebuffer( $tree ), $tt );
    }
    elsif ( $tree->{tag} eq $TTrue ) {
    }
    elsif ( $tree->{tag} eq $TFalse ) {
      $self->addinstruction( $compst, $IFail, 0 );
    }
    elsif ( $tree->{tag} eq $TChoice ) {
      $self->codechoice( $compst, $self->sib1( $tree ), $self->sib2( $tree ), $opt, $fl );
    }
    elsif ( $tree->{tag} eq $TRep ) {
      $self->coderep( $compst, $self->sib1( $tree ), $opt, $fl );
    }
    elsif ( $tree->{tag} eq $TBehind ) {
      $self->codebehind( $compst, $tree );
    }
    elsif ( $tree->{tag} eq $TNot ) {
      $self->codenot( $compst, $self->sib1( $tree ) );
    }
    elsif ( $tree->{tag} eq $TAnd ) {
      $self->codeand( $compst, $self->sib1( $tree ), $tt );
    }
    elsif ( $tree->{tag} eq $TCapture ) {
      $self->codecapture( $compst, $tree, $tt, $fl );
    }
    elsif ( $tree->{tag} eq $TRunTime ) {
      $self->coderuntime( $compst, $tree, $tt );
    }
    elsif ( $tree->{tag} eq $TGrammar ) {
      $self->coderuntime( $compst, $tree );
    }
    elsif ( $tree->{tag} eq $TCall ) {
      $self->codecall( $compst, $tree );
    }
    elsif ( $tree->{tag} eq $TSeq ) {
      $tt = $self->codeseq1( $compst,
                             $self->sib1( $tree ),
                             $self->sib2( $tree ), $tt, $fl ); # code 'p1'
      $tree = $self->sib2( $tree );
      goto tailcall;
    }
    else {
      assert( 0 );
    }
  }
}

#
# Optimize jumps and other jump-like instructions.
# * Update labels of instructions with labels to their final
# destinations (e.g., choice L1; ... L1: jmp L2: becomes
# choice L2)
# * Jumps to other instructions that do jumps become those
# instructions (e.g., jump to return becomes a return; jump
# to commit becomes a commit)
#
method peephole ( $compst ) {
  my $code = $compst->{p}->{code};
  my $i;
  for ( $i = 0; $i < $compst->{ncode};
                   $i += $self->sizei( $code->[ $i ] ) ) {
    my $opcode = $code->[ $i ]->{i}->{code};

    if ( $opcode eq $IChoice or
         $opcode eq $ICall or
         $opcode eq $ICommit or
         $opcode eq $IPartialCommit or
         $opcode eq $IBackCommit or
         $opcode eq $ITestChar or
         $opcode eq $ITestSet or
         $opcode eq $ITestAny ) {
      # optimize label
      $self->jumptothere( $compst, $i, $self->finallabel( $code, $i ) );
    }
    elsif ( $opcode eq $IJmp ) {
      my $ft = $self->finaltarget( $code, $i );
      my $_opcode = $code->[ $ft ]->{i}->{code};
      if ( $_opcode eq $IRet or
           $_opcode eq $IFail or
           $_opcode eq $IFailTwice or
           $_opcode eq $IEnd ) {
        # instructions with unconditional implicit jumps
        $code->[ $i ] = $code->[ $ft ]; # jump becomes that instruction
        $code->[ $i + 1 ]->{i}->{code} = $IAny; # 'no-op' for target position
      }
      elsif ( $_opcode eq $ICommit or
              $_opcode eq $IPartialCommit or
              $_opcode eq $IBackCommit ) {
        # inst. with unconditional explicit jumps */
        my $fft = $self->finallabel( $code, $ft );
        $code->[ $i ] = $code->[ $ft ]; # jump becomes that instruction...
        $self->jumptothere( $compst, $i, $fft ); # but must correct its offset
        $i--;
      }
      else {
        $self->jumptothere( $compst, $i, $ft ); # optimize label
      }
    }
  }
  ASSERT( "Foo" ) unless
    $code->[ $i - 1 ]->{i}->{code} eq $IEnd;
}

#
# Compile a pattern
#
method compile ( $L, $p ) {
  my $compst; # CompileState
  $compst->{p} = $p;
  $compst->{ncode} = 0;
  $compst->{L} = $L;
  $self->reallocprog( $L, $p, 2 ); # minimum initial size
  $self->codegen( $compst, $p->{tree}, 0, $NOINST, $fullset );
  $self->addinstruction( $compst, $IEnd, 0 );
  $self->reallocprog( $L, $p, $compst->{ncode} );  # set final size
  $self->peephole( $compst );
  return $p->{code};
}

=head1 NAME

JGoff::Parser::PEG::Codegen - Code generator

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

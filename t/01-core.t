#!perl

use strict;
use warnings;

use Test::More tests => 999;

BEGIN {
  use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
  use_ok( 'JGoff::Parser::PEG::Compile' ) || print "Bail out!";
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!";
}

use strict;
use warnings;

my $vm = JGoff::Parser::PEG::VM->new;

is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                { opcode => 'IEnd' },
              ],
              q{a} ),
    1
);

is( $vm->run( [ { opcode => 'IEnd' },
              ],
              q{a} ),
    0
);

is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                { opcode => 'IEnd' },
              ],
              q{b} ),
    undef
);

is( $vm->run( [ { opcode => 'ITestChar', aux => 'a' }, # ( next offset: 3)
                { opcode => 'ITestAny', offset => 3 }, # (next offset: 13828096)
                { opcode => 'IAny' },
                { opcode => 'IEnd' },
              ],
              q{b} ),
    0
);

is( $vm->run( [ { opcode => 'IFail' },
                { opcode => 'IEnd' },
              ],
              q{a} ),
    undef
);

is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                { opcode => 'IEnd' },
              ],
              q{a} ),
    1
);

is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                { opcode => 'IFail' },
                { opcode => 'IEnd' },
              ],
              q{a} ),
    undef
);

is( $vm->run( [
    { opcode => 'IFail' },
    { opcode => 'IChar', aux => 'a' },
    { opcode => 'IEnd' },
  ],
  q{a} ),
  undef
);

is( $vm->run( [
    { opcode => 'IChar', aux => 'a' },
    { opcode => 'IEnd' },
  ],
  q{a} ),
  1
);

# is( $vm->run( [
#     { opcode => 'IOpenCapture' },
#     { opcode => 'ITestAny', offset => 3 }, # (next offset: 19)
#     { opcode => 'IGiveup' },
#     { opcode => 'ITestSet' }, # ( n-next buff: )
#     { opcode => 'IOpenCall' }, # (next offset: 0)
#     { opcode => 'IAny' },
#     { }, # XXX UNKNOWN OPERATION 254
#     { }, # XXX UNKNOWN OPERATION 255
#     { }, # XXX UNKNOWN OPERATION 255
#     { opcode => 'IAny' },
#     { opcode => 'IAny' },
#     { opcode => 'IAny' },
#     { opcode => 'IAny' },
#     { opcode => 'IAny' },
#     { opcode => 'IJmp' }, # (next offset: -13)
#     { }, # XXX UNKNOWN OPERATION 253
#     { opcode => 'IAny' },
#     { opcode => 'IOpenCapture' }, # (getoff 1)
#     { opcode => 'IJmp' }, # (next offset: -17)
#     { }, # XXX UNKNOWN OPERATION 239
#     { opcode => 'ICloseCapture' },
#     { opcode => 'IEnd' },
#   ],
#   q{} ),
#   256
# );

is( $vm->run( [
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IEnd' },
  ],
  q{aaaa} ),
  3
);

is( $vm->run( [
    { opcode => 'IAny', offset => 335675392 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 23068672 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IEnd' },
  ],
  q{aaaa} ),
  4
);

is( $vm->run( [
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 23068672 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IAny', offset => 0 },
    { opcode => 'IEnd' },
  ],
  q{aaaa} ),
  undef
);

is( $vm->run( [
      { opcode => 'ITestAny', offset => 3 }, # (next offset: 8)
      { opcode => 'IRet', offset => 8 }, # XXX added
      { opcode => 'IChoice' },
      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IFailTwice' },
      { opcode => 'IEnd' },
    ],
    q{aa} ),
   0
);

#is( $vm->run( [
#      { opcode => 'ITestAny', offset => 29097987 }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IChoice' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#    ],
#    q{aaa} ),
#  undef
#);

#{ local $JGoff::Parser::PEG::VM::TRACE = 1;
#is( $vm->run( [
#      { opcode => 'ITestAny', offset => 31457283 }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IChoice' }, # (next offset: 6)
#      { opcode => 'ISpan', offset => 6 }, # (next buff: )
#      { opcode => 'IAny', offset => 31457280 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#    ],
#    q{aaaa} ),
#  undef
#);
#}


### my $compiler = JGoff::Parser::PEG::Compile->new;
### 
### # .
### is_deeply $compiler->Any => [ [ 'Any' ] ];
### 
### # 'C'
### is_deeply $compiler->Character( 'C' ) => [ [ Char => 'C' ] ];
### 
### # 'A' 'n'
### is_deeply
###   $compiler->Concatenate(
###     $compiler->Character( 'A' ),
###     $compiler->Character( 'n' ) ) =>
###   [ [ Char => 'A' ],
###     [ Char => 'n' ]
###   ];
### 
### # 'A' / 'n'
### is_deeply
###   $compiler->Ordered_Choice(
###     $compiler->Character( 'A' ),
###     $compiler->Character( 'n' ) ) =>
###   [ [ Choice => 3 ],
###     [ Char => 'A' ],
###     [ Commit => 2 ],
###     [ Char => 'n' ]
###   ];
### 
### # (an|a)
### is_deeply
###   $compiler->Ordered_Choice(
###     $compiler->Concatenate(
###       $compiler->Character( 'a' ),
###       $compiler->Character( 'n' ) ),
###     $compiler->Character( 'a' ) ) =>
###   [ [ Choice => 4 ], # --\
###     [ Char => 'a' ], #   |
###     [ Char => 'n' ], #   |
###     [ Commit => 2 ], # <-/
###     [ Char => 'a' ]
###   ];

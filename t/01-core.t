#!perl

use strict;
use warnings;

use Test::More tests => 13;

BEGIN {
  use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
  use_ok( 'JGoff::Parser::PEG::Compile' ) || print "Bail out!";
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!";
}

use strict;
use warnings;

my $compiler = JGoff::Parser::PEG::Compile->new;

# .
is_deeply $compiler->Any => [ [ 'Any' ] ];

# 'C'
is_deeply $compiler->Character( 'C' ) => [ [ Char => 'C' ] ];

# 'A' 'n'
is_deeply
  $compiler->Concatenate(
    $compiler->Character( 'A' ),
    $compiler->Character( 'n' ) ) =>
  [ [ Char => 'A' ],
    [ Char => 'n' ]
  ];

# 'A' / 'n'
is_deeply
  $compiler->Ordered_Choice(
    $compiler->Character( 'A' ),
    $compiler->Character( 'n' ) ) =>
  [ [ Choice => 3 ],
    [ Char => 'A' ],
    [ Commit => 2 ],
    [ Char => 'n' ]
  ];

# (an|a)
is_deeply
  $compiler->Ordered_Choice(
    $compiler->Concatenate(
      $compiler->Character( 'a' ),
      $compiler->Character( 'n' ) ),
    $compiler->Character( 'a' ) ) =>
  [ [ Choice => 4 ], # --\
    [ Char => 'a' ], #   |
    [ Char => 'n' ], #   |
    [ Commit => 2 ], # <-/
    [ Char => 'a' ]
  ];

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( $vm->run( [ { opcode => $JGoff::Parser::PEG::VM::IChar,
                    aux => 'a' },
                  { opcode => $JGoff::Parser::PEG::VM::IEnd } ],
                'a' ) );
}

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( !$vm->run( [ { opcode => $JGoff::Parser::PEG::VM::IChar,
                     aux => 'a' },
                   { opcode => $JGoff::Parser::PEG::VM::IEnd } ],
                 'b' ) );
}

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( $vm->run( [ { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IEnd }, ],
                'aaa' ) );
}

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( $vm->run( [ { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IEnd }, ],
                'aaaa' ) );
}

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( !$vm->run( [ { opcode => $JGoff::Parser::PEG::VM::IAny },
                   { opcode => $JGoff::Parser::PEG::VM::IAny },
                   { opcode => $JGoff::Parser::PEG::VM::IAny },
                   { opcode => $JGoff::Parser::PEG::VM::IEnd }, ],
                 'aa' ) );
}

{ my $vm = JGoff::Parser::PEG::VM->new;
  ok( $vm->run( [ { opcode => $JGoff::Parser::PEG::VM::ITestAny,
                    offset => 3 },
                  { opcode => $JGoff::Parser::PEG::VM::IRet },
                  { opcode => $JGoff::Parser::PEG::VM::IChoice },
                  { opcode => $JGoff::Parser::PEG::VM::ISpan },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IAny },
                  { opcode => $JGoff::Parser::PEG::VM::IFailTwice },
                  { opcode => $JGoff::Parser::PEG::VM::IEnd }, ],
                'aa' ) );
}

#{ my $vm = JGoff::Parser::PEG::VM->new;
#  $vm->run(
#    $compiler->Ordered_Choice(
#      $compiler->Concatenate(
#        $compiler->Character( 'a' ),
#        $compiler->Character( 'n' ) ),
#      $compiler->Character( 'a' ) ) =>
#    #[ 'A', 'n' ] );
#    #[ 'a', 'n' ] );
#    [ 'a', 'd' ] );
#    #[ 'a' ] );
#}

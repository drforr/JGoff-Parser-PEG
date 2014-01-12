#!perl

use strict;
use warnings;

use Test::More tests => 18;

BEGIN {
  use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
  use_ok( 'JGoff::Parser::PEG::Compile' ) || print "Bail out!";
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!";
}
use strict;
use warnings;

my $vm = JGoff::Parser::PEG::VM->new;

{
  is( $vm->run( [ { opcode => 'IChar', aux => ord( 'a' ) },
                  { opcode => 'IEnd' },
                ],
                q{a} ),
      1
  );
}

{
  is( $vm->run( [ { opcode => 'IEnd' },
                ],
                q{a} ),
      0
  );
}

{
  is( $vm->run( [ { opcode => 'IChar', aux => ord( 'a' ) },
                  { opcode => 'IEnd' },
                ],
                q{b} ),
      undef
  );
}

{
  is( $vm->run( [ { opcode => 'ITestChar', aux => ord( 'a' ) }, # ( next offset: 3)
                  { opcode => 'ITestAny', offset => 3 }, # (next offset: 138096)
                  { opcode => 'IAny' },
                  { opcode => 'IEnd' },
                ],
                q{b} ),
      0
  );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [ { opcode => 'IFail' },
                  { opcode => 'IEnd' },
                ],
                q{a} ),
      undef
  );
}

{
  is( $vm->run( [ { opcode => 'IChar', aux => ord( 'a' ) },
                  { opcode => 'IEnd' },
                ],
                q{a} ),
      1
  );
}

{
  is( $vm->run( [ { opcode => 'IChar', aux => ord( 'a' ) },
                  { opcode => 'IFail' },
                  { opcode => 'IEnd' },
                ],
                q{a} ),
      undef
  );
}

{
  is( $vm->run( [
      { opcode => 'IFail' },
      { opcode => 'IChar', aux => ord( 'a' ) },
      { opcode => 'IEnd' },
    ],
    q{a} ),
    undef
  );
}

{
  is( $vm->run( [
      { opcode => 'IChar', aux => ord( 'a' ) },
      { opcode => 'IEnd' },
    ],
    q{a} ),
    1
  );
}

{
  is( $vm->run( [
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IAny', offset => 0 },
      { opcode => 'IEnd' },
    ],
    q{aaaa} ),
    3
  );
}

{
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
}

{
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
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
  is( $vm->run( [
        { opcode => 'ITestAny', offset => 3 }, # (next offset: 8)
        { opcode => 'IRet', offset => 8 }, # XXX added
        { opcode => 'IChoice' }, # (next offset: 6)
        { opcode => 'ISpan', offset => 6 }, # ( next buff: )
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IFailTwice' },
        { opcode => 'IEnd' },
      ],
      q{aa} ),
     0
  );
} 

{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
  is( $vm->run( [
        { opcode => 'ITestAny', offset => 29097987 }, # (next offset: 8)
        { opcode => 'IRet', offset => 8 },
        { opcode => 'IChoice' },
        { opcode => 'ISpan', offset => 6 }, # ( next buff: )
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IAny', offset => 0, buff => "\0" },
        { opcode => 'IFailTwice' },
        { opcode => 'IEnd' },
      ],
      q{aaa} ),
    undef
  );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
        { opcode => 'ITestAny', offset => 31457283 }, # (next offset: 8)
        { opcode => 'IRet', offset => 8 },
        { opcode => 'IChoice' }, # (next offset: 6)
        { opcode => 'ISpan', offset => 6 }, # (next buff: )
        { opcode => 'IAny', offset => 31457280 },
        { opcode => 'IAny', offset => 0 },
        { opcode => 'IAny', offset => 0 },
        { opcode => 'IFailTwice' },
        { opcode => 'IEnd' },
      ],
      q{aaaa} ),
    undef
  );
}

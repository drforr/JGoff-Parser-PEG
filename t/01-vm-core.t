#!perl

use strict;
use warnings;

use Test::More tests => 100;

BEGIN {
  use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
  use_ok( 'JGoff::Parser::PEG::Compile' ) || print "Bail out!";
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!";
}
use strict;
use warnings;

my $vm = JGoff::Parser::PEG::VM->new;

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                  { opcode => 'IEnd' },
                ],
                q{a} ), 1 );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [ { opcode => 'IEnd' },
                ],
                q{a} ), 0 );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
                  { opcode => 'IEnd' },
                ],
                q{b} ), undef );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'ITestChar', aux => 'a' }, # ( next offset: 3)
          { opcode => 'ITestAny', offset => 3 }, # (next offset: 24838144)
          { opcode => 'IAny', offset => 24838144, buff => ' ' },
          { opcode => 'IEnd' },
        ],
        q{b} ), 0 );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IFail' },
          { opcode => 'IEnd' },
        ],
        q{a} ), undef );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IChar', aux => 'a' },
          { opcode => 'IEnd' },
        ],
        q{a} ), 1 );
}
   
{ # # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IChar', aux => 'a' },
          { opcode => 'IFail' },
          { opcode => 'IEnd' },
        ],
        q{a} ), undef );
} 

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IChar', aux => 'a' },
          { opcode => 'IEnd' },
        ],
        q{a} ), 1 );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IFail' },
          { opcode => 'IChar', aux => 'a' },
          { opcode => 'IEnd' },
        ],
        q{a} ), undef );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
            { opcode => 'IChar', aux => 'a' },
            { opcode => 'IEnd' },
        ],
        q{a} ), 1 );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IChar', aux => 'a' },
          { opcode => 'IFail' },
          { opcode => 'IEnd' },
      ],
      q{a} ), undef );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IEnd' },
  ],
    q{aaaa} ), 3 );
}

{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
      { opcode => 'IAny', offset => 105185280, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 24903680, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IEnd' },
  ],
    q{aaaa} ), 4 );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IAny', offset => 24903680, buff => ' ' },
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IEnd' },
      ],
      q{aaaa} ), undef );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
          { opcode => 'ITestAny', offset => 3 }, # (next offset: 8)
          { opcode => 'IRet', offset => 8 },
          { opcode => 'IChoice' }, # (next offset: 6)
          { opcode => 'ISpan', offset => 6 }, # ( next buff: )
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IAny', offset => 0, buff => ' ' },
          { opcode => 'IFailTwice' },
          { opcode => 'IEnd' },
      ],
      q{aa} ), 0 );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
      { opcode => 'ITestAny', offset => 25034755 }, # (next offset: 8)
      { opcode => 'IRet', offset => 8 },
      { opcode => 'IChoice' }, # (next offset: 6)
      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IFailTwice' },
      { opcode => 'IEnd' },
  ],
    q{aaa} ), undef );
}
  
{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
  is( $vm->run( [
      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 8)
      { opcode => 'IRet', offset => 8 },
      { opcode => 'IChoice' }, # (next offset: 6)
      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
      { opcode => 'IAny', offset => 24838144, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IAny', offset => 0, buff => ' ' },
      { opcode => 'IFailTwice' },
      { opcode => 'IEnd' },
  ],
    q{aaaa} ), undef );
}
  
#{ local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 9)
#      { opcode => 'IEnd', offset => 9 },
#  ],
#    q{aaaa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => -2147483648, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{aaaa} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IChar', aux => 'a' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo} ), 1 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IChar', aux => 'a' },
#      { opcode => 'IChar', aux => 'l' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo} ), 2 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IChar', aux => 'a' },
#      { opcode => 'IChar', aux => 'l' },
#      { opcode => 'IChar', aux => 'u' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IEnd' },
#  ],
#    q{} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IJmp' }, # (next offset: -29)
#      { }, # XXX UNKNOWN OPERATION 227
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 794886150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IJmp' }, # (next offset: -29)
#      { }, # XXX UNKNOWN OPERATION 227
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 794886150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24903686 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 65542 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IJmp' }, # (next offset: -29)
#      { }, # XXX UNKNOWN OPERATION 227
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 794886150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 34144262 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 34144262 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 34144262 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IJmp' }, # (next offset: -29)
#      { }, # XXX UNKNOWN OPERATION 227
#      { opcode => 'ITestAny', offset => 34144259 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 24838162)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24969222 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 58
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => -65530 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 134152210)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 87
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => -67108858 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 58
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: ÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IChar', aux => ' ' },
#      { opcode => 'IChar', aux => ' ' },
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{alo alo} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ITestAny', offset => 65539 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{1298a1} ), 6 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: -67108846)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{1257a1} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{(al())()} ), 6 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IChar', aux => '(' },
#      { opcode => 'ITestSet' }, # ( n-next buff: ÿÿÿÿÿýÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 29
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: ÿÿÿÿÿüÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ)
#      { opcode => 'IOpenCall' }, # (next offset: -1)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IJmp' }, # (next offset: -21)
#      { }, # XXX UNKNOWN OPERATION 235
#      { opcode => 'IChar', aux => '(' },
#      { opcode => 'IBehind', aux => '' },
#      { opcode => 'ICall' }, # (next offset: -26)
#      { }, # XXX UNKNOWN OPERATION 230
#      { opcode => 'IJmp' }, # (next offset: -27)
#      { }, # XXX UNKNOWN OPERATION 229
#      { opcode => 'IChar', aux => ')' },
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 105185298)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{(al())()} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IChar', aux => '(' },
#      { opcode => 'ITestSet' }, # ( n-next buff: ÿÿÿÿÿýÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ)
#      { }, # XXX UNKNOWN OPERATION 29
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'ITestSet' }, # ( n-next buff: ÿÿÿÿÿüÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ)
#      { opcode => 'IOpenCall' }, # (next offset: -1)
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { }, # XXX UNKNOWN OPERATION 255
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IJmp' }, # (next offset: -21)
#      { }, # XXX UNKNOWN OPERATION 235
#      { opcode => 'IChar', aux => '(' },
#      { opcode => 'IBehind', aux => '' },
#      { opcode => 'ICall' }, # (next offset: -26)
#      { }, # XXX UNKNOWN OPERATION 230
#      { opcode => 'IJmp' }, # (next offset: -27)
#      { }, # XXX UNKNOWN OPERATION 229
#      { opcode => 'IChar', aux => ')' },
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'ITestAny', offset => 105185283 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 24969234)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{((al())()(Ã©))} ), 14 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 34144265)
#      { opcode => 'IEnd' },
#  ],
#    q{(al()()} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestChar', aux => 'f' }, # ( next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IChoice' }, # (next offset: 6)
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: f)
#      { opcode => 'IChar', aux => 'f' },
#      { opcode => 'IChar', aux => 'o' },
#      { opcode => 'IChar', aux => 'r' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'ISet' }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 1815019526 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{foreach} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestChar', aux => 'f' }, # ( next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{foreach} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestChar', aux => 'f' }, # ( next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{for} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 34144265)
#      { opcode => 'IEnd' },
#  ],
#    q{   4achou123...} ), 9 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IChoice' }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 34144271)
#      { opcode => 'IPartialCommit' }, # (next offset: -2)
#      { opcode => 'IBackCommit' }, # (next offset: -2)
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { }, # XXX UNKNOWN OPERATION 24
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IOpenCapture' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ISpan', offset => 24838150 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { }, # XXX UNKNOWN OPERATION 254
#      { }, # XXX UNKNOWN OPERATION 254
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICloseCapture' },
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IJmp' }, # (next offset: -25)
#      { }, # XXX UNKNOWN OPERATION 231
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IPartialCommit' }, # (next offset: -32)
#      { opcode => 'IBackCommit' }, # (next offset: -32)
#      { }, # XXX UNKNOWN OPERATION 224
#      { opcode => 'IEnd' },
#  ],
#    q{ two words, one more  } ), 20 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{  (  (a)} ), 6 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ICall' }, # (next offset: 4)
#      { opcode => 'ITestChar', aux => ' ' }, # ( next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{abc} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{a} ), 1 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 3)
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IEnd' },
#  ],
#    q{a} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{x} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xa} ), 2 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 7)
#      { opcode => 'IBehind', aux => ' ' },
#      { opcode => 'IChoice' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{x} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 7)
#      { opcode => 'IBehind', aux => ' ' },
#      { opcode => 'IChoice' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25100288, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxa} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IChoice' }, # (next offset: 6)
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IChoice' }, # (next offset: 6)
#      { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxa} ), 4 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{xxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{xxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxa} ), 5 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{xxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IOpenCapture', offset => 5 },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxa} ), 5 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 8)
#      { opcode => 'IRet', offset => 8 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2106327040, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IOpenCapture', offset => 0 },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxa} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxa} ), 6 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 0)
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 9)
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => 1815019520, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => 1815019520, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxa} ), 7 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: -65536)
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => 1815019520, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: xEx)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 0)
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 0)
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IOpenCapture', offset => 0 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxa} ), 6 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxa} ), 8 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 24903680)
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 34144256)
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 10)
#      { opcode => 'IChoice' }, # (next offset: 11)
#      { opcode => 'IJmp' }, # (next offset: 34144256)
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxa} ), 9 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 105185290)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 12)
#      { opcode => 'ICall' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxa} ), 10 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 16777216, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 105185290)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 105185290)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 13)
#      { opcode => 'IOpenCall' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxa} ), 11 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IChoice' }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 24969216)
#      { opcode => 'IBackCommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25100288, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: xÿx)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 16777216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 105185290)
#      { opcode => 'IChoice' }, # (next offset: 14)
#      { opcode => 'ICommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 16777216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxa} ), 12 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IChoice' }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1668218880, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IChoice' }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 24969216)
#      { opcode => 'IBackCommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IChoice' }, # (next offset: 15)
#      { opcode => 'IPartialCommit' }, # (next offset: 24969216)
#      { opcode => 'IBackCommit' }, # (next offset: 24969216)
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxa} ), 13 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 19)
#      { opcode => 'IGiveup', offset => 19 },
#      { opcode => 'IChoice' }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IChoice' }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 0)
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1701576704, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 18)
#      { opcode => 'IFail' },
#      { opcode => 'IChoice' }, # (next offset: 16)
#      { opcode => 'IBackCommit' }, # (next offset: 0)
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1701576704, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => -67108864, buff => ' ' },
#      { opcode => 'IAny', offset => -134217728, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxa} ), 14 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 19)
#      { opcode => 'IGiveup', offset => 19 },
#      { opcode => 'IChoice' }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 4653056, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 19)
#      { opcode => 'IGiveup', offset => 19 },
#      { opcode => 'IChoice' }, # (next offset: 17)
#      { opcode => 'IFailTwice' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 4653056, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxa} ), 15 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxa} ), 16 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxa} ), 17 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 393216, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxa} ), 18 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxa} ), 19 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxa} ), 20 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IChoice' }, # (next offset: 24)
#      { }, # XXX UNKNOWN OPERATION 24
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 983040, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => -2054881280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxa} ), 21 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25034755 }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IChoice' }, # (next offset: 25)
#      { }, # XXX UNKNOWN OPERATION 25
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 262144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IChoice' }, # (next offset: 24)
#      { }, # XXX UNKNOWN OPERATION 24
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1081868288, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IChoice' }, # (next offset: 24)
#      { }, # XXX UNKNOWN OPERATION 24
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1086521344, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxa} ), 22 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IChoice' }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IAny', offset => 1966014464, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IChoice' }, # (next offset: 25)
#      { }, # XXX UNKNOWN OPERATION 25
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => -134217728, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IChoice' }, # (next offset: 25)
#      { }, # XXX UNKNOWN OPERATION 25
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => -134217728, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 67043328, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4653056, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 720896, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxa} ), 23 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 105185283 }, # (next offset: 29)
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IChoice' }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 1932394496, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IChoice' }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 1932394496, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IChoice' }, # (next offset: 26)
#      { }, # XXX UNKNOWN OPERATION 26
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 1932394496, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 262144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 25100288, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxa} ), 24 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 30)
#      { }, # XXX UNKNOWN OPERATION 30
#      { opcode => 'IChoice' }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 29)
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IChoice' }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 29)
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IChoice' }, # (next offset: 27)
#      { }, # XXX UNKNOWN OPERATION 27
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 7864320, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 34144256, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxa} ), 25 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 31)
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IChoice' }, # (next offset: 29)
#      { }, # XXX UNKNOWN OPERATION 29
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 825098240, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 30)
#      { }, # XXX UNKNOWN OPERATION 30
#      { opcode => 'IChoice' }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 30)
#      { }, # XXX UNKNOWN OPERATION 30
#      { opcode => 'IChoice' }, # (next offset: 28)
#      { }, # XXX UNKNOWN OPERATION 28
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1815019520, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 1768685568, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IChoice' }, # (next offset: 32)
#      { }, # XXX UNKNOWN OPERATION 32
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 33)
#      { }, # XXX UNKNOWN OPERATION 33
#      { opcode => 'IChoice' }, # (next offset: 31)
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 33)
#      { }, # XXX UNKNOWN OPERATION 33
#      { opcode => 'IChoice' }, # (next offset: 31)
#      { }, # XXX UNKNOWN OPERATION 31
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IChoice' }, # (next offset: 33)
#      { }, # XXX UNKNOWN OPERATION 33
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: xEx)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IChoice' }, # (next offset: 32)
#      { }, # XXX UNKNOWN OPERATION 32
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 6356992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24838147 }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IChoice' }, # (next offset: 32)
#      { }, # XXX UNKNOWN OPERATION 32
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2122121216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 30 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IChoice' }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IChoice' }, # (next offset: 33)
#      { }, # XXX UNKNOWN OPERATION 33
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IChoice' }, # (next offset: 33)
#      { }, # XXX UNKNOWN OPERATION 33
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 247595008, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 131072, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 196608, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 31 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IChoice' }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IChoice' }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IChoice' }, # (next offset: 34)
#      { }, # XXX UNKNOWN OPERATION 34
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IOpenCapture', offset => 0 },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 30 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 16777216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4653056, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 32 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IChoice' }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IChoice' }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IChoice' }, # (next offset: 35)
#      { }, # XXX UNKNOWN OPERATION 35
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 134152192, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IChoice' }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
# [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IChoice' }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4325376, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IChoice' }, # (next offset: 36)
#      { }, # XXX UNKNOWN OPERATION 36
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4325376, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IChoice' }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1246298112, buff => ' ' },
#      { opcode => 'IAny', offset => -65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IChoice' }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IChoice' }, # (next offset: 37)
#      { }, # XXX UNKNOWN OPERATION 37
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1079508992, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1080492032, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 543490048, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 543490048, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 35 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IChoice' }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IChoice' }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IChoice' }, # (next offset: 38)
#      { }, # XXX UNKNOWN OPERATION 38
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 36 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IChoice' }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IChoice' }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1079246848, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1079312384, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1079312384, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1079312384, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IChoice' }, # (next offset: 39)
#      { }, # XXX UNKNOWN OPERATION 39
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 43)
#      { }, # XXX UNKNOWN OPERATION 43
#      { opcode => 'IChoice' }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IChoice' }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 235208704, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IChoice' }, # (next offset: 40)
#      { }, # XXX UNKNOWN OPERATION 40
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 851968, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 369819648, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 655360, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 218103808, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 33554432, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 38 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 44)
#      { }, # XXX UNKNOWN OPERATION 44
#      { opcode => 'IChoice' }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 2021130240, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 43)
#      { }, # XXX UNKNOWN OPERATION 43
#      { opcode => 'IChoice' }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 4259840, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25100288, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 25165827 }, # (next offset: 43)
#      { }, # XXX UNKNOWN OPERATION 43
#      { opcode => 'IChoice' }, # (next offset: 41)
#      { }, # XXX UNKNOWN OPERATION 41
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1635254272, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), 39 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 45)
#      { }, # XXX UNKNOWN OPERATION 45
#      { opcode => 'IChoice' }, # (next offset: 43)
#      { }, # XXX UNKNOWN OPERATION 43
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: xx)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 44)
#      { }, # XXX UNKNOWN OPERATION 44
#      { opcode => 'IChoice' }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 0 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 3 }, # (next offset: 44)
#      { }, # XXX UNKNOWN OPERATION 44
#      { opcode => 'IChoice' }, # (next offset: 42)
#      { }, # XXX UNKNOWN OPERATION 42
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 1633746944, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24969216, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24903680, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IFailTwice' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxa} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24772608, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), undef );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24903683 }, # (next offset: 48)
#      { }, # XXX UNKNOWN OPERATION 48
#      { opcode => 'IChoice' }, # (next offset: 46)
#      { }, # XXX UNKNOWN OPERATION 46
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25034752, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#  
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#      { opcode => 'ITestAny', offset => 24969219 }, # (next offset: 49)
#      { }, # XXX UNKNOWN OPERATION 49
#      { opcode => 'IChoice' }, # (next offset: 47)
#      { }, # XXX UNKNOWN OPERATION 47
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 65536, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 24838144, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 25165824, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 105185280, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'IAny', offset => 0, buff => ' ' },
#      { opcode => 'ICommit' }, # (next offset: 5)
#      { opcode => 'ITestSet' }, # ( n-next buff: x)
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IChar', aux => 'x' },
#      { opcode => 'IEnd' },
#  ],
#    q{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx} ), 3 );
#}
#
#=cut
#
#=pod
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
#                  { opcode => 'IEnd' },
#                ],
#                q{a} ),
#      1
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'IEnd' },
#                ],
#                q{a} ),
#      0
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
#                  { opcode => 'IEnd' },
#                ],
#                q{b} ),
#      undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'ITestChar', aux => 'a' }, # ( next offset: 3)
#                  { opcode => 'ITestAny', offset => 3 }, # (next offset: 138096)
#                  { opcode => 'IAny' },
#                  { opcode => 'IEnd' },
#                ],
#                q{b} ),
#      0
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [ { opcode => 'IFail' },
#                  { opcode => 'IEnd' },
#                ],
#                q{a} ),
#      undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
#                  { opcode => 'IEnd' },
#                ],
#                q{a} ),
#      1
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [ { opcode => 'IChar', aux => 'a' },
#                  { opcode => 'IFail' },
#                  { opcode => 'IEnd' },
#                ],
#                q{a} ),
#      undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#      { opcode => 'IFail' },
#      { opcode => 'IChar', aux => 'a' },
#      { opcode => 'IEnd' },
#    ],
#    q{a} ),
#    undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#      { opcode => 'IChar', aux => 'a' },
#      { opcode => 'IEnd' },
#    ],
#    q{a} ),
#    1
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IEnd' },
#    ],
#    q{aaaa} ),
#    3
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 335675392 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 23068672 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IEnd' },
#    ],
#    q{aaaa} ),
#    4
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 23068672 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IAny', offset => 0 },
#      { opcode => 'IEnd' },
#    ],
#    q{aaaa} ),
#    undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#        { opcode => 'ITestAny', offset => 3 }, # (next offset: 8)
#        { opcode => 'IRet', offset => 8 }, # XXX added
#        { opcode => 'IChoice' }, # (next offset: 6)
#        { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IFailTwice' },
#        { opcode => 'IEnd' },
#      ],
#      q{aa} ),
#     0
#  );
#} 
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#        { opcode => 'ITestAny', offset => 29097987 }, # (next offset: 8)
#        { opcode => 'IRet', offset => 8 },
#        { opcode => 'IChoice' },
#        { opcode => 'ISpan', offset => 6 }, # ( next buff: )
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IAny', offset => 0, buff => "\0" },
#        { opcode => 'IFailTwice' },
#        { opcode => 'IEnd' },
#      ],
#      q{aaa} ),
#    undef
#  );
#}
#
#{ # local $JGoff::Parser::PEG::VM::TRACE = 1;
#  is( $vm->run( [
#        { opcode => 'ITestAny', offset => 31457283 }, # (next offset: 8)
#        { opcode => 'IRet', offset => 8 },
#        { opcode => 'IChoice' }, # (next offset: 6)
#        { opcode => 'ISpan', offset => 6 }, # (next buff: )
#        { opcode => 'IAny', offset => 31457280 },
#        { opcode => 'IAny', offset => 0 },
#        { opcode => 'IAny', offset => 0 },
#        { opcode => 'IFailTwice' },
#        { opcode => 'IEnd' },
#      ],
#      q{aaaa} ),
#    undef
#  );
#}
#
#=cut

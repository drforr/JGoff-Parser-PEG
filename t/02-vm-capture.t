#!perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!\n";
}
use strict;
use warnings;

my $vm = JGoff::Parser::PEG::VM->new;

#{ # local $JGoff::Parser::PEG::VM::TRACE = 2;
#  is( $vm->run( [
#    { opcode => 'IOpenCapture', aux => 11, key => 0 }, # pc: 0
#    { opcode => 'ITestAny' }, # pc: 1
#    { offset => 6 }, # pc: 2
#    { opcode => 'IAny' }, # pc: 3
#    { opcode => 'IFullCapture', aux => 25, key => 1 }, # pc: 4
#    { opcode => 'IJmp' }, # pc: 5
#    { offset => -4 }, # pc: 6
#    { opcode => 'ICloseCapture' }, # pc: 7
#    { opcode => 'IEnd' }, # pc: 8
#  ],   q{} ),
#  256 )
#}

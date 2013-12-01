#!perl

use Test::More tests => 7;

BEGIN {
  use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
  use_ok( 'JGoff::Parser::PEG::Compile' ) || print "Bail out!";
  use_ok( 'JGoff::Parser::PEG::VM' ) || print "Bail out!";
}

use strict;
use warnings;

#my $vm = JGoff::Parser::PEG::VM->new;
#
#$vm->run( [
#  [ Char => 'a' ],
#  [ Char => 'n' ],
#  [ Char => 'd' ]
#] );
#is $vm->pc => 3;
#is $vm->i => 3;

my $compiler = JGoff::Parser::PEG::Compile->new;

# .
is_deeply $compiler->any => [ [ 'Any' ] ];

# 'C'
is_deeply $compiler->character( 'C' ) => [ [ Char => 'C' ] ];

# 'A' 'n'
is_deeply
  $compiler->concatenate(
    $compiler->character( 'A' ),
    $compiler->character( 'n' ) ) =>
  [ [ Char => 'A' ],
    [ Char => 'n' ]
  ];

# 'A' / 'n'
is_deeply
  $compiler->ordered_choice(
    $compiler->character( 'A' ),
    $compiler->character( 'n' ) ) =>
  [ [ Choice => 3 ],
    [ Char => 'A' ],
    [ Commit => 2 ],
    [ Char => 'n' ]
  ];

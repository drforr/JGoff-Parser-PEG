#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'JGoff::Parser::PEG' ) || print "Bail out!\n";
}

diag( "Testing JGoff::Parser::PEG $JGoff::Parser::PEG::VERSION, Perl $], $^X" );



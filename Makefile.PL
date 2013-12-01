use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'JGoff::Parser::PEG',
    AUTHOR              => q{Jeff Goff <jgoff@cpan.org>},
    VERSION_FROM        => 'lib/JGoff/Parser/PEG.pm',
    ABSTRACT_FROM       => 'lib/JGoff/Parser/PEG.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Moose' => 0,
        'Readonly' => 0,
        'Parser::MGC' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'JGoff-Parser-PEG-*' },
    test                => { TESTS => 't/*.t t/format/*.t' },
);

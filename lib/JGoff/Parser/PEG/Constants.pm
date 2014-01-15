package JGoff::Parser::PEG::Constants;

use Exporter qw( import );
use Readonly;

our @EXPORT_OK = qw(
  $BITSPERCHAR
  $UCHAR_MAX
  $NULL
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

  $TChar $TSet $TAny
  $TTrue $TFalse
  $TRep
  $TSeq $TChoice
  $TNot $TAnd
  $TCall
  $TOpenCall
  $TRule
  $TGrammar
  $TBehind
  $TCapture
  $TRunTime

  $PEnullable
  $PEnofail

  $MAXBEHIND
  $MAXOFF
  $MAXRULES
);

Readonly our $MAXBEHIND => 255; # XXX From compiler
Readonly our $MAXOFF => 15; # XXX From compiler
Readonly our $MAXRULES =>  200; # XXX From compiler


Readonly our $BITSPERCHAR     => 8;
Readonly our $NULL            => -1;
Readonly our $UCHAR_MAX       => 999999; # XXX Check this later.
Readonly our $CHARSETSIZE     => 32; # Extracted from the C source
Readonly our $CHARSETINSTSIZE => 9;

# fail if no char
Readonly our $IAny           => 'IAny';

# fail if char != aux
Readonly our $IChar          => 'IChar';

# fail if char not in buff
Readonly our $ISet           => 'ISet';

# if no char, jump to 'offset'
Readonly our $ITestAny       => 'ITestAny';

# if char != aux, jump to 'offset'
Readonly our $ITestChar      => 'ITestChar';

# if char not in buff, jump to 'offset'
Readonly our $ITestSet       => 'ITestSet';

# read a span of chars in buff
Readonly our $ISpan          => 'ISpan';

# walk back 'aux' characters (fail if not possible)
Readonly our $IBehind        => 'IBehind';

# return from a rule
Readonly our $IRet           => 'IRet';

# end of pattern
Readonly our $IEnd           => 'IEnd';

# stack a choice; next fail will jump to 'offset'
Readonly our $IChoice        => 'IChoice';

# jump to 'offset'
Readonly our $IJmp           => 'IJmp';

# call rule at 'offset'
Readonly our $ICall          => 'ICall';

# call rule number 'key' (must be closed to a ICall)
Readonly our $IOpenCall      => 'IOpenCall';

# pop choice and jump to 'offset'
Readonly our $ICommit        => 'ICommit';

# update top choice to current position and jump
Readonly our $IPartialCommit => 'IPartialCommit';

# "fails" but jump to its own 'offset'
Readonly our $IBackCommit    => 'IBackCommit';

# pop one choice and then fail
Readonly our $IFailTwice     => 'IFailTwice';

# go back to saved state on choice and jump to saved offset
Readonly our $IFail          => 'IFail';

# internal use
Readonly our $IGiveup        => 'IGiveup';

# complete capture of last 'off' chars
Readonly our $IFullCapture   => 'IFullCapture';
 
# start a capture
Readonly our $IOpenCapture   => 'IOpenCapture';

# close a capture
Readonly our $ICloseCapture  => 'ICloseCapture';

 # Close runtime
Readonly our $ICloseRunTime  => 'ICloseRunTime';

Readonly our $Cclose    => 'Cclose';
Readonly our $Cposition => 'Cposition';
Readonly our $Cconst    => 'Cconst';
Readonly our $Cbackref  => 'Cbackref';
Readonly our $Carg      => 'Carg';
Readonly our $Csimple   => 'Csimple';
Readonly our $Ctable    => 'Ctable';
Readonly our $Cfunction => 'Cfunction';
Readonly our $Cquery    => 'Cquery';
Readonly our $Cstring   => 'Cstring';
Readonly our $Cnum      => 'Cnum';
Readonly our $Csubst    => 'Csubst';
Readonly our $Cfold     => 'Cfold';
Readonly our $Cruntime  => 'Cruntime';
Readonly our $Cgroup    => 'Cgroup';

Readonly our $TChar => 'TChar';
Readonly our $TSet => 'TSet';
Readonly our $TAny => 'TAny';
Readonly our $TTrue => 'TTrue';
Readonly our $TFalse => 'TFalse';
Readonly our $TRep => 'TRep';
Readonly our $TSeq => 'TSeq';
Readonly our $TChoice => 'TChoice';
Readonly our $TNot => 'TNot';
Readonly our $TAnd => 'TAnd';
Readonly our $TCall => 'TCall';
Readonly our $TOpenCall => 'TOpenCall';
Readonly our $TRule => 'TRule'; # sib1 is rule's pattern, sib2 is 'next' rule
Readonly our $TGrammar => 'TGrammar'; # sib1 is initial (and first) rule
Readonly our $TBehind => 'TBehind';# match behind
Readonly our $TCapture => 'TCapture'; # regular capture
Readonly our $TRunTime => 'TRunTime'; # run-time capture

Readonly our $PEnullable => 0;
Readonly our $PEnofail => 1;

=head1 NAME

JGoff::Parser::PEG::Constants - Constants for the VM

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

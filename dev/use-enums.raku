#!/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [debug]

    Tests use of enums in subs, classes, and methods.

    HERE
    exit
}

my $debug = 0;
++$debug if @*ARGS.shift ~~ /^:i d/;
say "Debugging btype as arg" if $debug;

enum Btype <afm ff>;

class S {
    has Btype $.type is rw;
}

my $o = S.new: :type(afm);
say $o.WHAT;
say $o.type;
info $o.type;

$o.type = ff;
say $o.type;
info $o.type;
info ff;

sub info(Btype $type) {
    if $type ~~ afm {
        say "type afm";
    }
    else {
        say "type ff";
    }
}

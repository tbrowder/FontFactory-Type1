#!/bin/env raku

my ($a, $b, $c) = 1, 2, 3;
if not @*ARGS {
     say "Usage: <prog> go";
     exit;
}

foo;
foo $a;
foo $a, $b;
foo $a, $b, $c;

multi foo($a?) {
    say "foo: \$a is defined";
}
multi foo(|c ($a, $b)) {
    say "foo: \$a and \$b are defined";
}
multi foo(|c ($a, $b, $c)) {
    say "foo: \$a and \$b and \$c are defined";
}

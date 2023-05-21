#!/bin/env raku

my $s;
my $kern;
my $go;
if not @*ARGS {
     say "Usage: <prog> s k";
     exit;
}

for @*ARGS {
    when /^s/ { $s = "s" }
    when /^k/ { $kern = 1 }
}

foo $s, :$kern;

sub bar($s?, :$kern) {
    if $s.defined {
        say "bar: \$s is defined";
    }
    else {
        say "bar: \$s is NOT defined";
    }

    if $kern.defined {
        say "bar: :\$kern is defined";
    }
    else {
        say "bar: \$kern is NOT defined";
    }

}


sub foo($s?, :$kern) {
    if $s.defined {
        say "foo: \$s is defined";
    }
    else {
        say "foo: \$s is NOT defined";
    }

    if $kern.defined {
        say "foo: :\$kern is defined";
    }
    else {
        say "foo: \$kern is NOT defined";
    }
    bar($s, :$kern);
    #bar(|c);
}

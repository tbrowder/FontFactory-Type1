#!/bin/env raku

# prog: try-db1-hash.raku

# create a structure as seen in Font::AFM
my @a = <a b c>;
my @b = <x y z>;

my $n = 0;
my %h;
for @a -> $a {
    for @b -> $b {
        %h{$a}{$b} = ++$n;
    }
}
say %h.gist;

# a simple map application won't work
# do this:
for %h.keys -> $k {
    for %h{$k}.kv -> $k2, $v {
        %h{$k}{$k2} = $v>>.map({$_ * 2});
    }
}
say %h.gist;

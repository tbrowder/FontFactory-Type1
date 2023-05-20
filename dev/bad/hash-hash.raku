#!/bin/env raku

# Given a hash with values consisting of a hash with single numerical values
# update all the values by multiplying them with the same constant.
my %h = [a => {:1x, :2y}, b => {:4x, :8y}];
say %h.gist;

my $h2 = %h>>.map({ $_>>.map({ $_.value *= 2 }) });
say $h2.gist;

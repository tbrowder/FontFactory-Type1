#!/bin/env raku

use Font::AFM;
use Test;

use lib <../lib>; 
use FontFactory::Type1;
use FontFactory::Type1::DocFont;

use lib <../t/lib>;
use Utils;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [debug]

    Exercise various ways of generating
    and testing string bboxes using Times-Roman
      font at 10.3 points.

    Uses both kerned and unkerned text.

    Outputs a list of results for comparison.

    HERE
    exit
}

my $debug = 0;
++$debug if @*ARGS.shift ~~ /^:i d/;

say "Debugging btype as arg" if $debug;
my $has-header = 0;

for <none kern> -> $k {
#for btype.keys.sort -> $type {
#    # for now bypass mix
#    next if $type ~~ /mix/;

    #for <none kern> -> $k {
    for btype.keys.sort -> $type {
        # for now bypass mix
        next if $type ~~ /mix/;


        my StrBBox $box;
        my $bbox;
        if $k ~~ /kern/ {
            $box .= new: :$type, :kern(True);
            $bbox = string-bbox :$type, :$box, :kern;
        }
        else {
            $box .= new: :$type, :kern(False);
            $bbox = string-bbox :$type, :$box;
        }
        die "FATAL: \$box is undefined" if not $box;

        if not $has-header {
            $box.header;
            $has-header = 1;
        }
        # must call the sub in order to use its box input
        $box.output;
    }
}



#!/bin/env raku

use Data::Dump;
use Data::Dump::Tree;
use Font::AFM;
use Test;
use lib <../lib>;
use FontFactory::Type1;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Exercise multiplying values by a factor in hashes and maps
    HERE
    exit
}

my Hash $h = { a => (1,2) };
#say $h.gist;
my $a = $h.deepmap({ $_ * 2 });
#say $a.gist;
$h>>.deepmap({ $_ * 2 });

say f;

sub f {
    my Hash $h = { a => (1,2) };
    #say $h.gist;
    my $a = $h.deepmap({ $_ * 2 });
    #say $a.gist;
    #$a
}

my $afm  = Font::AFM.new: :name<Times-Roman>;
my $size = 10.3;
my $sf   = $size/1000.0;
my $ff   = FontFactory::Type1.new;
my $f    = $ff.get-font: 't10d3';

#is $f.sf, $sf;

if 0 {
say "\$afm type: ", $afm.WHAT;
say "\$afm.Wx type: ", $afm.Wx.WHAT;
say "\$afm.Wx<a> type: ", $afm.Wx<a>.WHAT;
say "\$afm.BBox type: ", $afm.BBox.WHAT;
say "\$afm.BBox<a> type: ", $afm.BBox<a>.WHAT;
#ddt $afm.Wx;
#ddt $afm.BBox;
}

if 0 {
say "\$f type: ", $f.WHAT;
say "\$f.Wx type: ", $f.Wx.WHAT;
say "\$f.Wx<a> type: ", $f.Wx<a>.WHAT;
say "\$f.BBox type: ", $f.BBox.WHAT;
say "\$f.BBox<a> type: ", $f.BBox<a>.WHAT;
#.ddt $f.BBox;
}


=finish

# create structures as seen in Font::AFM
my $bbox := [
    a => [1.1, 2, 3, 4],
    b => [1.1, 2, 3, 4],
    c => [1.1, 2, 3, 4],
];

my $wx := [
    a => 1.1,
    b => 1.1,
    c => 1.1,
];

say "the input data (emulating .BBox):";
say Dump($bbox, :no-postfix, :skip-methods);
# use map
#my $b = %bbox>>.map({ $_ >>*>> 2 });
my $b = $bbox>>.map({ $_ >>*>> 2 });

say "the output data:";
say Dump($b, :no-postfix, :skip-methods);
say();

say "the input data (emulating .Wx):";
say Dump($wx, :no-postfix, :skip-methods);
# use map
my $w = $wx>>.map({ $_ >>*>> 2 });
say "the output data:";
say Dump($w, :no-postfix, :skip-methods);

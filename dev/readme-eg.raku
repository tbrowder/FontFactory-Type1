#!/usr/bin/env raku

use lib <../lib>;

use PDF::Lite;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::Subs;
use FontFactory::Type1::DocFont;

show-fonts;

# use the factory
my $pdf = PDF::Lite.new;
my $ff  = FontFactory::Type1.new :$pdf;

# define a DocFont
# use a name that associates its face and size
my DocFont $t12d1 = $ff.get-font: 't12d1'; # <= use a 'd' for a decimal point
say "name: ", $t12d1.name;
say "size: ", $t12d1.size;

my $text = "my pet cat";
my $size = $t12d1.size;
say "  stringwidth: ", $t12d1.stringwidth($text);
say "  ItalicAngle: ", $t12d1.ItalicAngle;
say "KernData for character <a>";
my $kd = $t12d1.afm.KernData;
if $kd ~~ Hash {
    say "KernData is a hash of hashes, one per character...";
    my $kdv = $kd<V>;
    say "KernData for char V";
    my @c = $kdv.keys.sort;
    for @c[0..^10] -> $c {
        my $v = $kdv{$c};
        say "  $c $v";
    }
}
else {
    say "no data for this font"
}
$text = "A long line of complicated and Weird test to demo the effects of kerning.";
my $w = $t12d1.stringwidth: $text, :kern;
say "width: $w";

# define another DocFont
my DocFont $c10   = $ff.get-font: 'c10';
say "name: {$c10.name}";
say "text: $text";
say "  size: ", $c10.size;
say "  top-bearing: ", $c10.TopBearing;
say "  left-bearing: ", $c10.LeftBearing;
say "  right-bearing: ", $c10.RightBearing;
say "  bottom-bearing: ", $c10.BottomBearing;

say "  UnderlinePosition: ", $c10.UnderlinePosition;
say "  UnderlineThickness: ", $c10.UnderlineThickness;
say "  FontBBox: ", $c10.FontBBox;
say "  stringwidth: ", $c10.stringwidth($text);
my $wx = $c10.Wx<A>;
say "  Width for char A: $wx";
say "KernData for character <a>";
$kd = $c10.afm.KernData;
if $kd ~~ Hash {
    say $kd<a>;
}
else {
    say "Font {$c10.FontName} has no KernData"
}

=begin code
# for typesetting, find the width of a kerned string in PostScript points (72/inch):
$text = "Some string of text to be typeset in a beautiful PDF document.";
my $wk = $t12d1.stringwidth($text, :kern);
say "kerned width: $wk"; # OUTPUT: 
=end code

$text = "Some string of text to be typeset in a beautiful PDF document.";
my $wk = $t12d1.stringwidth($text, :kern);
say "kerned width: $wk"; # OUTPUT: 


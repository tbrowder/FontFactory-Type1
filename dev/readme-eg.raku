#!/usr/bin/env raku

use lib <../lib>;

use PDF::Lite;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::Utils;

show-myfonts;

# use the factory
my $pdf = PDF::Lite.new;
my $ff  = FontFactory::Type1.new :$pdf;

# define a DocFont
# use a name that associates its face and size
my DocFont $ti12d1 = $ff.get-font: 'ti12d1'; # <= use a 'd' for a decimal point
say "name: {$ti12d1.name}";
say "size: {$ti12d1.size}";

my $text = "my pet cat";
my $size = $ti12d1.size;
say "  stringwidth: {$ti12d1.stringwidth($text)}";
say "  ItalicAngle: {$ti12d1.ItalicAngle}";
say "KernData for character <a>";
#say $ti12d1.afm.KernData<a>;
my $kd = $ti12d1.afm.KernData;
if $kd ~~ Hash {
    say $kd<a>;
}
else {
    say "no data for this font"
}
$text = "A long line of complicated and Weird test to demo the effects of kerning.";
my $w = $ti12d1.stringwidth: $text, :kern;
say "width: $w";

# define another DocFont
my DocFont $c10   = $ff.get-font: 'c10';
say "name: {$c10.name}";
say "text: $text";
say "  size: {$c10.size}";
say "  first-line-height: {$c10.first-line-height}";
say "  UnderlinePosition: {$c10.UnderlinePosition}";
say "  UnderlineThickness: {$c10.UnderlineThickness}";
say "  FontBBox: {$c10.FontBBox}";
say "  stringwidth: {$c10.stringwidth($text)}";
#my $wx = $c10.Wx;
#say "  Wx: $wx";
say "KernData for character <a>";
$kd = $c10.afm.KernData;
if $kd ~~ Hash {
    say $kd<a>;
}
else {
    say "Font {$c10.FontName} has no KernData"
}

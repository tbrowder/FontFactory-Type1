use Test;
use Font::AFM;

my $first-line = "StartFontMetrics 4.1";

plan 6;

my @fonts = <
   c.afm
   c
   foo.afm
   foo
>;
 
%*ENV<METRICS> = "./t/fonts";
my ($f, $file, $nam);
for @fonts {
    $file = "./t/fonts/$_";
    if $file.IO.lines.head ne $first-line {
        next;
    }

    lives-ok {
        $f = Font::AFM.new: :name($_);
    }

    isa-ok $f, Font::AFM;

    lives-ok {
        $f.FontName;
    }
}

=finish

#| Human-readable name for a group of fonts that are stylistic
#| variants of a single design. All fonts that are members of such a
#| group should have exactly the same FamilyName. Example of a family
#| name is "Times".
$afm.FamilyName

#| Human-readable name for the weight, or "boldness", attribute of a
#| font. Examples are Roman, Bold, Light.
$afm.Weight

#| Angle in degrees counterclockwise from the vertical of the dominant
#| vertical strokes of the font.
$afm.ItalicAngle

#| If true, the font is a fixed-pitch (monospaced) font.
$afm.IsFixedPitch

#| An array of integers giving the lower-left x, lower-left y, upper-right x, and upper-right y of the font bounding box in relation to its origin. The font bounding box is the smallest rectangle enclosing the shape that would result if all the characters of the font were placed with their origins coincident, and then painted.
$afm.FontBBox

#| A two dimensional hash containing from and to glyphs and kerning widths.
$afm.KernData

#| Recommended distance from the baseline for positioning underline strokes. This number is the y coordinate of the center of the stroke.
$afm.UnderlinePosition

#| Recommended stroke width for underlining.
$afm.UnderlineThickness

#| Version number of the font.
$afm.Version

$afm.Notice
#| Trademark or copyright notice, if applicable.

#| Comments found in the AFM file.
$afm.Comment

#| The name of the standard encoding scheme for the font. Most Adobe fonts use the AdobeStandardEncoding. Special fonts might state FontSpecific.
$afm.EncodingScheme

#| Usually the y-value of the top of the capital H.
$afm.CapHeight

#| Typically the y-value of the top of the lowercase x.
$afm.XHeight

#| Typically the y-value of the top of the lowercase d.
$afm.Ascender

#| Typically the y-value of the bottom of the lowercase p.
$afm.Descender

#| Returns a hash table that maps from glyph names to the width of that glyph.
$afm.Wx

#| Returns a hash table that maps from glyph names to bounding box information in relation to each glyph's origin. The bounding box consist of four numbers: llx, lly, urx, ury.
$afm.BBox

#| Returns the width of the string passed as argument. The string is assumed to contains only characters from %glyphs A second argument can be used to scale the width according to the font size.
$afm.stringwidth($string, $fontsize?, :kern, :%glyphs)

#| Kern the string. Returns an array of string segments, separated by numeric kerning distances, and the overall width of the string.
($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)

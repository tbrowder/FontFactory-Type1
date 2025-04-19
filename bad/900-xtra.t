use Test;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::DocFont;
use FontFactory::Type1::DocFont::StringSub;
use Data::Dump;

my $debug = 0;

my $name  = "Times-Roman";
my $name2 = "Courier";
my $fontsize  = 10.3;
my $fontsize2 = 10;
my ($ff, $f, $f2, $v, $a, $afm, $afm2, $text, $bbox, $bbox2);
my ($width, $llx, $lly, $urx, $ury);
my ($got, $exp);

# use the same string for $text
$text = slurp "t/data/short-test-string.txt";

lives-ok {
    $afm = Font::AFM.new: :$name;
}
lives-ok {
    $afm2 = Font::AFM.new: :name($name2);
}
lives-ok {
    $ff = FontFactory::Type1.new;
}
lives-ok {
    $f = $ff.get-font("t10d3");
}
lives-ok {
    $f2 = $ff.get-font("c10");
}
lives-ok {
    my $f = $ff.get-font("c");
}

$bbox = $afm.BBox<S> >>*>> $f.sf;

#=begin comment
$a = $bbox[3];
$bbox = $afm.BBox<S> >>*>> $f.sf;
$v = $f.TopBearing($text);
is $a, $v, "TopBearing with input string";
$v = $f.tb($text);
is $a, $v, "TopBearing with input string";

if 1 {
    note "bbox:";
    note Dump($bbox);
    note "a:";
    note Dump($a);
    note "v:";
    note Dump($v);
    note "DEBUG early exit"; exit;
}
#=end comment

=finish

$bbox = $afm.BBox<a> >>*>> $f.sf;
$a = $bbox[0];

=begin comment
$v = $f.LeftBearing($text);
is $a, $v, "LeftBearing with input string";
$v = $f.lb($text);
is $a, $v, "LeftBearing with input string, alias";

$bbox = $afm.BBox<p> >>*>> $f.sf;
$a = $bbox[1];
$v = $f.BottomBearing($text);
is $a, $v, "BottomBearing with input string";
$v = $f.bb($text);
is $a, $v, "BottomBearing with input string, alias";
=end comment

#===== without input string =====
$bbox = $afm.FontBBox >>*>> $f.sf;

$a = $bbox[3];
$v = $f.TopBearing;
is $a, $v, "TopBearing without input string";
$v = $f.tb;
is $a, $v, "TopBearing without input string, alias";

$a = $bbox[1];
$v = $f.BottomBearing;
is $a, $v, "BottomBearing without input string";
$v = $f.bb;
is $a, $v, "BottomBearing without input string, alias";

#===== more new methods =====
$a = $afm.BBox<S>[3] - $afm.BBox<p>[1];
$a *= $f.sf;

=begin comment
$v = $f.LineHeight($text);
is $a, $v, "LineHeight with text input";
$v = $f.lh($text);
is $a, $v, "LineHeight with text input, alias";
=end comment

# without an input line
$a = $afm.FontBBox[3] - $afm.FontBBox[1];
$a *= $f.sf;
$v = $f.LineHeight;
is $a, $v, "LineHeight without text input";
$v = $f.lh;
is $a, $v, "LineHeight without text input, alias";

$a = $afm.UnderlinePosition * $f.sf;
$v = $f.UnderlinePosition;
is $a, $v;
$v = $f.up;
is $a, $v, "up alias";

$a = $afm.UnderlineThickness * $f.sf;
$v = $f.UnderlineThickness;
is $a, $v;
$v = $f.ut;
is $a, $v, "ut alias";

is $afm.IsFixedPitch, $f.IsFixedPitch;
is $afm.FontName, $f.FontName;
is $afm.FullName, $f.FullName;
is $afm.FamilyName, $f.FamilyName;
is $afm.Weight, $f.Weight;
is $afm.ItalicAngle, $f.ItalicAngle;
is $afm.Version, $f.Version;
is $afm.Notice, $f.Notice;
is $afm.Comment, $f.Comment;
is $afm.EncodingScheme, $f.EncodingScheme;

is $afm.CapHeight * $f.sf, $f.CapHeight;
is $afm.XHeight * $f.sf, $f.XHeight;
is $afm.Ascender * $f.sf, $f.Ascender;
is $afm.Descender * $f.sf, $f.Descender;

done-testing;

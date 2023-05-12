use Test;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::DocFont;
use Data::Dump;

my $debug = 0;

my $name  = "Times-Roman";
my $name2 = "Courier";
my $fontsize  = 10.3;
my $fontsize2 = 10;
my ($ff, $f, $f2, $v, $a, $afm, $afm2, $text, $bbox, $bbox2);
my ($width, $llx, $lly, $urx, $ury);
my ($got, $exp);

plan 25;

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

$a = $afm.BBox<m>[3] * $f.sf * 0.5;
$v = $f.StrikethroughPosition;
is $a, $v;

$a = $afm.UnderlineThickness * $f.sf;
$v = $f.StrikethroughThickness;
is $a, $v;

# an input string =====
$text = 'a Spoor';

$bbox = $afm.BBox<S> >>*>> $f.sf;
$a = $bbox[3]; $bbox = $afm.BBox<S> >>*>> $f.sf;
$v = $f.TopBearing($text);
is $a, $v, "TopBearing with input string";
$v = $f.tb($text);
is $a, $v, "TopBearing with input string";

if 0 {
    note "bbox:";
    note Dump($bbox);
    note "a:";
    note Dump($a);
    note "v:";
    note Dump($v);
    note "DEBUG early exit"; exit;
}

$text = 'a Spoor';
$bbox = $afm.BBox<a> >>*>> $f.sf;
$a = $bbox[0];
$v = $f.LeftBearing($text);
is $a, $v, "LeftBearing with input string";
$v = $f.lb($text);
is $a, $v, "LeftBearing with input string";

$text = 'a Spoor';
$exp = $afm.stringwidth($text, $f.size);
$exp -= $f.sf * $afm.Wx{$text.comb.tail};
$exp += $f.sf * $afm.BBox{$text.comb.tail}[2];
$got = $f.RightBearing($text);

if 0 {
    note "afm.Wx<a>:";
    note Dump($afm.Wx<a>, :gist, :no-postfix); # - $bbox[2];

    note "afm.Wx<a> * f.sf:";
    note Dump($afm.Wx<a> * $f.sf, :gist, :no-postfix); # - $bbox[2];

    note "afm.BBbox<a>[2]:";
    note Dump($afm.BBox<a>[2], :gist, :no-postfix); # - $bbox[2];

    note "bbox[2]:";
    note Dump($bbox[2], :gist); # - $bbox[2];

    note "f.Wx<a>:";
    note Dump($f.Wx<a>, :gist); # - $bbox[2];

    note "f.BBbox<a>[2]:";
    note Dump($f.BBox<a>[2], :gist); # - $bbox[2];

    #note "bbox:";
    #note Dump($bbox);
    #note "a:";
    #note Dump($a);
    #note "v:";
    #note Dump($v);
    note "DEBUG early exit"; exit;
}
is $got, $exp, "RightBearing with input string 1";
$got = $f.rb($text);
is $got, $exp, "RightBearing with input string 2";

$text = 'a Spoor';
$bbox = $afm.BBox<p> >>*>> $f.sf;
$a = $bbox[1];
$v = $f.BottomBearing($text);
is $a, $v, "BottomBearing with input string";
$v = $f.bb($text);
is $a, $v, "BottomBearing with input string";

#===== without input string =====
$bbox = $afm.FontBBox >>*>> $f.sf;

$a = $bbox[3];
$v = $f.TopBearing;
is $a, $v, "TopBearing without input string";
$v = $f.tb;
is $a, $v, "TopBearing without input string";

$a = $bbox[1];
$v = $f.BottomBearing;
is $a, $v, "BottomBearing without input string";
$v = $f.bb;
is $a, $v, "BottomBearing without input string";

#===== more new methods =====
# with an input line
$text = 'a Spoor';
$a = $afm.BBox<S>[3] - $afm.BBox<p>[1];
$a *= $f.sf;
$v = $f.LineHeight($text);
is $a, $v, "LineHeight with text input";
$v = $f.lh($text);
is $a, $v, "LineHeight with text input";

# without an input line
$a = $afm.FontBBox[3] - $afm.FontBBox[1];
$a *= $f.sf;
$v = $f.LineHeight;
is $a, $v, "LineHeight without text input";
$v = $f.lh;
is $a, $v, "LineHeight without text input";

# StringBBox
$text = "Fo Ko Oo Po Ro To Uo Vo Wo Yo";
  
$llx = 0;
$lly = 0;
$ury = 0;
$urx = 0;
my @chars = $text.comb;
for @chars -> $c is copy {
    if $c !~~ /\S/ {
        # its name is 'space'
        $c = 'space';
    }
    #note "DEBUG: char is '$c'";
    #my $w = $afm.Wx{$c};
    #note "  its width is $w";
    my $ly = $afm.BBox{$c}[1];
    my $uy = $afm.BBox{$c}[3];
    $lly = $ly if $ly < $lly;
    $ury = $uy if $uy > $ury;
}

$width = $afm.stringwidth($text, $f.size);
$lly  *= $f.sf;
$ury  *= $f.sf;

my $fchar = $text.comb.head;
$llx = $f.sf * $afm.BBox{$fchar}[0];
my $lchar = $text.comb.tail;
$urx = $f.sf * $afm.BBox{$lchar}[2];
my $wlchar = $f.sf * $afm.Wx{$lchar};
$urx = $width - $wlchar + $urx;

$exp = ($llx, $lly, $urx, $ury);
$got = $f.StringBBox($text);
is-deeply $got, $exp, "StringBBox, no kern";

$width = $afm.stringwidth($text, $f.size, :kern);

my $fchar = $text.comb.head;
$llx = $f.sf * $afm.BBox{$fchar}[0];
my $lchar = $text.comb.tail;
$urx = $f.sf * $afm.BBox{$lchar}[2];
my $wlchar = $f.sf * $afm.Wx{$lchar};
$urx = $width - $wlchar + $urx;

$exp = ($llx, $lly, $urx, $ury);
$got = $f.StringBBox($text, :kern);
is-deeply $got, $exp, "StringBBox, with kern";


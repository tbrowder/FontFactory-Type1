use Test;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::DocFont;
use Data::Dump;

use lib <./t/lib>;
use Utils;

my $debug = 0;

my $name  = "Times-Roman";
my $name2 = "Courier";
my $fontsize  = 10.3;
my $fontsize2 = 10;

my ($ff, $f, $f2, $v, $a, $afm, $afm2, $text, $text2, $bbox, $bbox1, $bbox2);
my ($width, $width2, $llx, $lly, $urx, $ury);
my ($got, $exp);

#plan 8;

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

$text = 'a Spoor';
$text = 'Bo Do Fo Io Jo Ko Oo Po To Uo Vo Wo Yo';
#$text = 'BoDoFoIoJoKoOoPoToUoVoWoYo';

# test use of kern with afm.stringwidth
$width  = $afm.stringwidth: $text, $fontsize;
$width2 = $f.stringwidth: $text;
is $width2, $width;
note "width 1 without kern: $width" if $debug;

$width  = $afm.stringwidth: $text, $fontsize, :kern;
$width2 = $f.stringwidth: $text, :kern;
is $width2, $width;
note "width 2 with :kern: $width" if $debug;

$width  = $afm.stringwidth: $text, $fontsize, :!kern;
$width2 = $f.stringwidth: $text, :!kern;
is $width2, $width;
note "width 3 with :!kern: $width" if $debug;

$bbox1 = string-bbox $text, :$name, :size($fontsize);
$bbox2 = $f.StringBBox: $text;
is-deeply $bbox2, $bbox1, "StringBBox";

my ($RB1, $RB2);

$bbox1 = string-bbox $text, :$name, :size($fontsize), :kern;
$bbox2 = $f.StringBBox: $text, :kern;
is-deeply $bbox2, $bbox1, "StringBBox, kern";
$bbox2 = $f.sbb: $text, :kern;
is-deeply $bbox2, $bbox1, "StringBBox, kern, alias";

# right bearing
$RB1 = $bbox1[2];
$RB2 = $f.RightBearing: $text, :kern;
is $RB2, $RB1, "RightBearing, kern";
$RB2 = $f.rb:  $text, :kern;
is $RB2, $RB1, "RightBearing, kern, alias";

$bbox1 = string-bbox $text, :$name, :size($fontsize), :!kern;
$bbox2 = $f.StringBBox: $text, :!kern;
is-deeply $bbox2, $bbox1, "StringBBox, no kern";
$bbox2 = $f.sbb: $text, :!kern;
is-deeply $bbox2, $bbox1, "StringBBox, no kern, alias";

# right bearing
$RB1 = $bbox1[2];
$RB2 = $f.RightBearing: $text, :!kern;
is $RB2, $RB1, "RightBearing, no kern";
$RB2 = $f.rb:  $text, :!kern;
is $RB2, $RB1, "RightBearing, no kern, alias";

done-testing;

=finish

note "last char: {$text.comb.tail}";
$bbox = $afm.BBox<r> >>*>> $f.sf;
$exp = $afm.stringwidth($text, $f.size);
note "exp (width): $exp";
my $cw = $f.sf * $afm.Wx{$text.comb.tail};
$exp -= $f.sf * $afm.Wx{$text.comb.tail};
note "exp (less char width $cw): $exp";
my $crb = $f.sf * $afm.BBox{$text.comb.tail}[2];
$exp += $f.sf * $afm.BBox{$text.comb.tail}[2];
note "exp (plus last char right bearing $crb): $exp";

{
my $lc = $text.comb.tail;
my $w = $f.stringwidth($text);
my $lw = $f.Wx{$lc};
my $lcb = $f.BBox{$lc}[2];

note "got (width): $w";
note "got ($w less char width $lw): {$w - $lw}";
note "got (plus last char right bearing $lcb): {$w - $lw + $lcb}";
}

$got = $f.RightBearing($text);

if 0 {

    note "expected:";
    note Dump($exp, :gist, :no-postfix); # - $bbox[2];
    note "got:";
    note Dump($got, :gist, :no-postfix); # - $bbox[2];


    note "afm.Wx<r>:";
    note Dump($afm.Wx<r>, :gist, :no-postfix); # - $bbox[2];
    note "afm.Wx<r> * f.sf:";
    note Dump($afm.Wx<r> * $f.sf, :gist, :no-postfix); # - $bbox[2];

    note "afm.BBbox<r>[2]:";
    note Dump($afm.BBox<r>[2], :gist, :no-postfix); # - $bbox[2];
    note "afm.BBbox<r>[2] * f.sf:";
    #note "bbox[2]:";
    note Dump($afm.BBox<r>[2] * $f.sf, :gist, :no-postfix); # - $bbox[2];
    #note Dump($bbox[2], :gist); # - $bbox[2];

    note "f.Wx<r>:";
    note Dump($f.Wx<r>, :gist); # - $bbox[2];

    note "f.BBbox<r>[2]:";
    note Dump($f.BBox<r>[2], :gist); # - $bbox[2];

    my $wid = $afm.stringwidth($text, $f.size);
    my $wid2 = $f.stringwidth($text);
    note "afm width:";
    note Dump($wid, :gist); # - $bbox[2];
    note "f.width:";
    note Dump($wid2, :gist); # - $bbox[2];

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

$fchar = $text.comb.head;
$llx = $f.sf * $afm.BBox{$fchar}[0];
$lchar = $text.comb.tail;
$urx = $f.sf * $afm.BBox{$lchar}[2];
$wlchar = $f.sf * $afm.Wx{$lchar};
$urx = $width - $wlchar + $urx;

$exp = ($llx, $lly, $urx, $ury);
$got = $f.StringBBox($text, :kern);
is-deeply $got, $exp, "StringBBox, with kern";

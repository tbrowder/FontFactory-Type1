use Test;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::Subs;

use lib <./t/lib>;
use Utils;

# get the Font::AFM object to compare with
my Font::AFM $a;
my $name = "Times-Roman";
my $size = 10.3;

# test 1
lives-ok {
    $a .= core-font($name);
}

# test 2
is $a.FontName, "Times-Roman";

# get the FF equivalent
my $ff;
# test 3
lives-ok {
    $ff = FontFactory::Type1.new;
}

# test 4
my $b;
lives-ok {
    $b = $ff.get-font("t10d3");
}

# test 5
is $b.FontName, "Times-Roman";
# test 6
is $b.size, 10.3;

my $text = "A very long line Excently done eXactly and Carefully to Test Kerning.";

my $width;
my $res;
my $kerned;

my Font::AFM $afm;
my $size2 = 10;
my $width2;

my $c = $ff.get-font("t10");
# test 7
lives-ok {
    $afm .= core-font($name);
}
$width = $afm.stringwidth($text, $size2);
# test 8
is $width, 283.84;
$width2 = $c.stringwidth($text);
# test 9
is $width2, $width;

$width = $afm.stringwidth($text, $size2, :kern);
# test 10
is $width, 282.56;
$width2 = $c.stringwidth($text, :kern);
# test 11
is $width2, $width;

$width = $afm.stringwidth($text);
# test 12
is $width, 28384;
$width2 = $c.afm.stringwidth($text);
# test 13
is $width2, $width;

$width = $afm.stringwidth($text, :kern);
# test 14
is $width, 28256;
$width2 = $c.afm.stringwidth($text, :kern);
# test 15
is $width2, $width;

done-testing;


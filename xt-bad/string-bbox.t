se Test;
use Font::AFM;

use lib <./t/lib>;
use Utils;

my $size = 10.3;
my $name = "./dev/Times-Roman.afm";
my $text = "Some string";

my ($llx, $lly, $urx, $ury);

lives-ok {
    #($llx, $lly, $urx, $ury) = string-bbox($text, $size, :$name);
    ($llx, $lly, $urx, $ury) = string-bbox($text, $size);
}, "no kern";

lives-ok {
    #($llx, $lly, $urx, $ury) = string-bbox($text, $size, :$name, :kern);
    ($llx, $lly, $urx, $ury) = string-bbox($text, $size, :kern);
}, "with kern";

done-testing;


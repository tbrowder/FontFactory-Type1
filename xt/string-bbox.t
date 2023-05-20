use Test;
use Font::AFM;

use lib <./t/lib>;
use Utils;

my $size = 10.3;
my $name = "./dev/Times-Roman.afm";
my $text = "Some string";

my ($llx, $lly, $urx, $ury);

lives-ok {
    ($llx, $lly, $urx, $ury) = string-bbox($text, :$name, :$size);
}

lives-ok {
    ($llx, $lly, $urx, $ury) = string-bbox($text, :$name, :$size, :kern);
}

done-testing;


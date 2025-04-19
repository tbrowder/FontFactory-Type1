use Test;
use Font::AFM;

use FontFactory::Type1;

my $afm  = Font::AFM.new: :name<Times-Roman>;
my $size = 10.3;
my $ff   = FontFactory::Type1.new;
my $f    = $ff.get-font: 't10d3';
my $sf   = $size/1000.0;
my $exp;

is $f.sf, $sf;
for $f.Wx.kv -> $k, $v {
    my $v2 = $afm.Wx{$k}*$sf;
    is $v, $v2;
}

for $f.BBox.kv -> $k, $v {
    my $v2 = $afm.BBox{$k};
    for 0..^4 -> $i {
        is $v[$i], $v2[$i]*$sf;
    }
}

done-testing;

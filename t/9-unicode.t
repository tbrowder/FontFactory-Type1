use Test;

use PDF::Content;
use PDF::Lite;
use Font::AFM;

use FontFactory::Type1;
use FontFactory::Type1::DocFont;
use FontFactory::Type1::Subs;
use FontFactory::Type1::FontList;

my $title = 'french.pdf';
my $pdf;
my $basefont;
my $rawfont;
my $up;
my $ut;
my $page;
my $afm;
my $ffact; # font factory
my $rawafm;
my $docfont;
my $size = 10;
my $x = 10;
my $y = 10;

lives-ok {
   $pdf = PDF::Lite.new;
}, "checking pdf instantiation";

my $ff = FontFactory::Type1.new;
my $f  = $ff.get-font: "t12";

my $text = "Le Caf\xe7 Marly";

lives-ok {
    $page = $pdf.add-page;
}, "checking pdf page generation";

lives-ok {
    my $c = " ";
    my $u = uni2ps $c;
    is $u, "space";
}, "checking sub uni2ps";

done-testing;


use Test;
use PDF::Content;
use PDF::Lite;
use Font::AFM;
use FontFactory;
use FontFactory::Utils;

plan 12;

my $title = 'text.pdf';
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

for %MyFonts.keys {
    # distinguish between PDF::Lite font objects and higher-level composite ones
    lives-ok {
        $rawfont = $pdf.core-font(:family($_));
    }, "checking raw font access, name: $_";
    lives-ok {
        $rawafm  = Font::AFM.core-font($_);
    }, "checking raw Font afm access, name: $_";

    lives-ok {
       $basefont = find-basefont :name($_), :$pdf;
    }, "checking find-docfont , name: $_";
    lives-ok {
        $docfont = select-docfont :$basefont, :size(10);
    }, "checking select-docfont, name: $_, size: $size";
    lives-ok {
        $up   = $docfont.UnderlinePosition;
    }, "checking font afm use for UnderlinePosition";
    lives-ok {
       $ut = $docfont.UnderlineThickness;
    }, "checking font afm use for UnderlineThickness";
    last;
}

lives-ok {
    $page = $pdf.add-page;
}, "checking pdf page generation";

# quickie font factory checks
lives-ok {
    $ffact = FontFactory.new: :$pdf;
}, "getting a font factory";
lives-ok {
    my $f = $ffact.get-font: 't12d1';
}, "getting a font from the -font factory";
lives-ok {
    my $f = $ffact.get-font: 't12d2';
}, "getting a font from the -font factory";
lives-ok {
    my $f = $ffact.get-font: 't12';
}, "getting a font from the -font factory";

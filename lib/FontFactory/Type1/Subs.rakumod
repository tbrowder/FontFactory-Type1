unit module FontFactory::Type1::Subs;

use PDF::Lite;
use Font::AFM;

use FontFactory::Type1::FontList;
use FontFactory::Type1::BaseFont;
use FontFactory::Type1::DocFont;

sub show-fonts is export {
    my $max = 0;
    for %Fonts.keys -> $k {
        my $n = $k.chars;
        $max = $n if $n > $max;
    }

    ++$max; # make room for closing '
    for %Fonts.keys.sort -> $k {
        my $v = %Fonts{$k};
        my $f = $k ~ "'";
        say sprintf("Font family: '%-*.*s (alias: '$v')", $max, $max, $f);
    }
}

sub find-basefont(PDF::Lite :$pdf!,
                  :$name!,  # full or alias
                  --> BaseFont) is export {
    my $fnam; # to hold the recognized font name
    if %Fonts{$name}:exists {
        $fnam = $name;
    }
    elsif %FontAliases{$name.lc}:exists {
        $fnam = %FontAliases{$name.lc};
    }
    else {
        die "FATAL: Font name or alias '$name' is not recognized'";
    }

    # make provision for local fonts
    my ($rawfont, $rawafm);

    # get the PDF::Content::FontObj, if any exists in the core fonts
    $rawfont = $pdf.core-font(:family($fnam));

    my $is-corefont;

    if not $rawfont  {
        $is-corefont = False;
        use PDF::Font::Loader :&load-font;
        use PDF::Content::FontObj;

        # the MICREncoding font is in resources:
        #   /resources/fonts/MICREncoding.pfa
        #   /resources/fonts/MICREncoding.afm
        my $pfa = %?RESOURCES<fonts/MICREncoding.pfa>.absolute;
        my $afm = %?RESOURCES<fonts/MICREncoding.afm>.absolute;

        # the PDF::Content::FontObj:
        $rawfont = load-font :file($pfa); # use the .pfa for PostScript Type 1 fonts

        # also get the afm file
        $rawafm = Font::AFM.new: :name($afm);
    }
    else {
        $is-corefont = True;
        $rawafm = Font::AFM.core-font($fnam);
    }

    my $BF = BaseFont.new: :$pdf, :name($fnam), :$rawfont, :$rawafm, :$is-corefont;
    $BF
}

sub select-docfont(BaseFont :$basefont!,
                   Real :$size!
                   --> DocFont) is export {
    DocFont.new: :$basefont,
                 :name($basefont.name),
                 :font($basefont.rawfont),
                 :afm($basefont.rawafm),
                 :$size;
}

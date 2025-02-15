unit module FontFactory::Type1::Subs;

use PDF::Lite;
use Font::AFM;
use File::Temp;

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

sub find-basefont(
    PDF::Lite :$pdf!,
              :$name!,  # full or alias
    --> BaseFont
    ) is export {
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
        note "FATAL: font '$fnam' is not a core-font.";
        note "       Exiting...";
        exit;
    }
    else {
        $is-corefont = True;
        $rawafm = Font::AFM.core-font($fnam);
    }

    BaseFont.new: :$pdf, :name($fnam), :$rawfont, :$rawafm, :$is-corefont;
}

sub select-docfont(
    BaseFont :$basefont!,
             :$size,
    --> DocFont
    ) is export {
    DocFont.new: :$basefont,
                 :name($basefont.name),
                 :font($basefont.rawfont),
                 :afm($basefont.rawafm),
                 :$size;
}

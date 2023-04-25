unit module FontFactory::Type1::Utils;

use PDF::Lite;
use PDF::Content;
use Text::Utils :wrap-text;
use Font::AFM;

constant %MyFonts is export = [
    # These are the "core" fonts from PostScript (Type 1)
    Courier               => "c",
    Courier-Oblique       => "co",
    Courier-Bold          => "ch",
    Courier-BoldOblique   => "cbo",
    Helvetica             => "h",
    Helvetica-Oblique     => "ho",
    Helvetica-Bold        => "hb",
    Helvetica-BoldOblique => "hbo",
    Times-Roman           => "t",
    Times-Italic          => "ti",
    Times-Bold            => "tb",
    Times-BoldItalic      => "tbi",
    Symbol                => "s",
    Zapfdingbats          => "z",

    # Additional fonts:
    MICREncoding          => "m", # converted from .ttf via fontforge
];

# invert the has and have short names (aliases) as keys
our %MyFontAliases is export = %MyFonts.invert;

sub show-myfonts is export {
    my $max = 0;
    for %MyFonts.keys -> $k {
        my $n = $k.chars;
        $max = $n if $n > $max;
    }

    ++$max; # make room for closing '
    for %MyFonts.keys.sort -> $k {
        my $v = %MyFonts{$k};
        my $f = $k ~ "'";
        say sprintf("Font family: '%-*.*s (alias: '$v')", $max, $max, $f);
    }
}

class BaseFont is export {
    has PDF::Lite $.pdf is required;
    has $.name is required;    #= the recognized font name
    has $.rawfont is required; #= the font object from PDF::Lite
    has Font::AFM $.rawafm is required;  #= the afm object
    has $.is-corefont is required;
}

sub find-basefont(PDF::Lite :$pdf!,
                  :$name!,  # full or alias
                  --> BaseFont) is export {
    my $fnam; # to hold the recognized font name
    if %MyFonts{$name}:exists {
        $fnam = $name;
    }
    elsif %MyFontAliases{$name.lc}:exists {
        $fnam = %MyFontAliases{$name.lc};
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

class DocFont is export {
    has BaseFont $.basefont is required;
    has $.name is required; # font name or alias
    has $.size is required;
    has $.afm is required;  #= the the Font::AFM object
    has $.font is required; #= the PDF::Lite font object
    # convenience attrs
    has $.sf;   #= scale factor for the afm attrs vs the font size

    submethod TWEAK {
        $!sf   = $!size / 1000;
    }

    # Convenience methods (and aliases) from the afm object and size.
    # See Font::AFM for details.
    method first-line-height {
        # distance from baseline to top of highest char in the font,
        # get from bbox ury
        $!afm.FontBBox[3] * $!sf;
    }

    #| UnderlinePosition
    method UnderlinePosition {
        $!afm.UnderlinePosition * $!sf
    }
    method upos {
        self.UnderlinePosition
    }

    method spos {
        # define the position of the strikethrough line
        # as midheight of some character
        constant \schar = 'm';
        my ($llx, $lly, $urx, $ury) = $!afm.BBox{schar}  * $!sf;
        0.5 * ($ury - $lly);
    }
    method sthk {
        # without any other source, use same as underline
        $!afm.UnderlineThickness * $!sf
    }

    #| UnderlineThickness
    method UnderlineThickness {
        $!afm.UnderlineThickness * $!sf
    }
    method uthk {
        self.UnderlineThickness()
    }

    # ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)
    # Kern the string. Returns an array of string segments, separated
    # by numeric kerning distances, and the overall width of the string.
    method kern($string, $fontsize?, :%glyphs?) {
    }

    # A two dimensional hash containing from and to glyphs and kerning widths.
    method KernData {
        $!afm.KernData
    }

    # $afm.stringwidth($string, $fontsize?, Bool:$kern is copy, :%glyphs)
    #| stringwidth
    method stringwidth($string, :$kern, :%glyphs) {
        if $kern {
            $!afm.stringwidth: $string, $!size, :$kern, :%glyphs
        }
        else {
            $!afm.stringwidth: $string, $!size
        }
    }
    =begin comment
    method sw($string, :$kern, :%glyphs) {
        stringwidth: $string, $size,:$kern, :%glyphs
    }
    =end comment

    method IsFixedPitch {
        $!afm.IsFixedPitch
    }

    # other methods
    method FontName {  # usually with no spaces
        $!afm.FontName
    }
    method FullName {
        $!afm.FullName
    }
    method FamilyName {
        $!afm.FamilyName
    }
    method Weight {
        $!afm.Weight
    }
    method ItalicAngle {
        $!afm.ItalicAngle
    }
    method FontBBox {
        $!afm.FontBBox
    }
    method Version {
        $!afm.Version
    }
    method Notice {
        $!afm.Notice
    }
    method Comment {
        $!afm.Comment
    }
    method EncodingScheme {
        $!afm.EncodingScheme
    }
    method CapHeight {
        $!afm.CapHeight
    }
    method XHeight {
        $!afm.XHeight
    }
    method Ascender {
        $!afm.Ascender
    }
    method Descender {
        $!afm.Descender
    }
    method Wx {
        $!afm.Wx
    }
    method BBox {
        $!afm.BBox
    }

    =begin comment
    method ? {}
    method ? {}
    method ? {}
    method ? {}
    =end comment
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

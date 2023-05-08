unit module FontFactory::Type1::FontList;

constant %Fonts is export = [
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
our %FontAliases is export = %Fonts.invert;

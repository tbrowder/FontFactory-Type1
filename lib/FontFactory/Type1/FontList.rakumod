unit module FontFactory::Type1::FontList;

constant %Fonts is export =
    # These are the "core" fonts from PostScript (Type 1)
    Courier               => "c",
    Courier-Oblique       => "co",  # also ci
    Courier-Bold          => "cb",
    Courier-BoldOblique   => "cbo", # also cbi, cob, cib

    Helvetica             => "h",
    Helvetica-Oblique     => "ho",  # also hi
    Helvetica-Bold        => "hb",
    Helvetica-BoldOblique => "hbo", # also hbi, hob, hib

    Times-Roman           => "t",
    Times-Italic          => "ti",  # also to
    Times-Bold            => "tb",
    Times-BoldItalic      => "tbi", # also tbo, tob, tib

    Symbol                => "s",
    Zapfdingbats          => "z",
;

# invert the hash and have short names (aliases) as keys
our %FontAliases is export = %Fonts.invert;
# add some extra keys
# Courier
%FontAliases<ci>  = "Courier-Oblique";
%FontAliases<cbi> = "Courier-BoldOblique";
%FontAliases<cob> = "Courier-BoldOblique";
%FontAliases<cib> = "Courier-BoldOblique";

# Helvetica
%FontAliases<hi>   = "Helvetica-Oblique";
%FontAliases<hbi>  = "Helvetica-BoldOblique";
%FontAliases<hob>  = "Helvetica-BoldOblique";
%FontAliases<hib>  = "Helvetica-BoldOblique";

# Time-Roman
%FontAliases<to>   = "Times-Italic";
%FontAliases<tbo>  = "Times-BoldItalic";
%FontAliases<tob>  = "Times-BoldItalic";
%FontAliases<tib>  = "Times-BoldItalic";

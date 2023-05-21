use FontFactory::Type1::Subs;
use FontFactory::Type1::BaseFont;
use FontFactory::Type1::DocFont;

unit class FontFactory::Type1;

use PDF::Lite;
use Font::AFM;


# needed to access corefonts
has PDF::Lite $.pdf; # can be provided by the caller

# hash of BaseFonts keyed by their alias name
has FontFactory::Type1::BaseFont %.basefonts;

# hash of DocFonts keyed by an alias name which includes the font's size
has FontFactory::Type1::DocFont %.docfonts;

submethod TWEAK {
    # provide if using standalone
    return if $!pdf;
    $!pdf = PDF::Lite.new;
}

method get-font($name --> DocFont) {
    # "name" is a key in a specific format
    my $key;

    # pieces required to get the docfont
    my $alias;
    my $size;

    # pieces of the size
    my $sizint;
    my $sizfrac;
    # examples of valid names:
    #   t12, t2d3, cbo10, ho12d5
    if $name ~~ /^ (<[A..Za..z-]>+) (\d+)  ['d' (\d+)]? $/ {
        $alias   = ~$0;
        $sizint  = ~$1;

        $key  = $alias ~ $sizint;
        $size = $sizint;

        # optional decimal fraction
        $sizfrac = ~$2 if $2.defined;
        if $sizfrac.defined {
            $key  ~= 'd' ~ $sizfrac;
            $size ~= '.' ~ $sizfrac;
        }
        $size .= Real;
    }
    else {
        note "FATAL: You entered the desired font name '$name'.";
        die q:to/HERE/;
        The desired font name must be in the format "<name><size>"
        where "<name>" is a valid font name or alias and "<size>"
        is either an integral number or a decimal number in
        the form "\d+d\d+" (e.g., '12d5' which mean '12.5' PS points).
        HERE
    }

    # if we have the docfont return it
    if %!docfonts{$key}:exists {
        return %!docfonts{$key};
    }
    elsif %!basefonts{$alias}:exists {
        # do we have the basefont?
        my $basefont = %!basefonts{$alias};
        my $docfont = select-docfont :$basefont, :$size;
        %!docfonts{$key} = $docfont;
        return %!docfonts{$key};
    }
    else {
        # we need the whole banana
        my $basefont = find-basefont :pdf($!pdf), :name($alias);
        %!basefonts{$alias} = $basefont;
        my $docfont = select-docfont :$basefont, :$size;
        %!docfonts{$key} = $docfont;
        return %!docfonts{$key};
    }
} # end fontfactory

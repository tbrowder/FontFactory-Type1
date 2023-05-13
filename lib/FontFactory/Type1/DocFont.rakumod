unit class FontFactory::Type1::DocFont is export;

use PDF::Lite;
use Font::AFM;
use FontFactory::Type1::BaseFont;

constant LLX  = 0; # bbox index for left bound
constant LLY  = 1; # bbox index for lower bound
constant URX  = 2; # bbox index for right bound
constant URY  = 3; # bbox index for upper bound

#use Data::Dump;

#| This class represents the final font object and it includes the final size
has BaseFont $.basefont is required;
has          $.name     is required; #= font name or alias
has          $.size     is required; #= desired size in points
has          $.afm      is required; #= the Font::AFM object (note the object is immutable)
has          $.font     is required; #= the PDF::Lite font object
# convenience attrs
has          $.sf;                   #= scale factor for the afm attrs vs the font size

#| calculate the scale factor
submethod TWEAK {
    $!sf = $!size / 1000.0;
}

# Convenience methods (and aliases) from the afm object and size.

#| Define the position of the strikethrough line as the midheight of the lower-case 'm'
method StrikethroughPosition {
    my constant \schar = 'm';
    my ($llx, $lly, $urx, $ury) = $!afm.BBox{schar} >>*>> $!sf; # adjust for the desired font size
    0.5 * ($ury - $lly)
}

#| Not having found any other source to dispute this, use same as underline thickness
method StrikethroughThickness {
    $!afm.UnderlineThickness * $!sf # adjust for the desired font size
}

# See Font::AFM for details.

#| According to the Redbook, Type 1 fonts usually have their left
#| sidebearing at or right of the glyph's origin. The bounding box is
#| always in reference to the origin which has its Y=0 on the baseline
#| and its X=0 is the print point of reference for the caller.  So the
#| left sidebearing is defined as the first character's BBox[0]
#| distance, positive to the right of the origin.  And we define a
#| right sidebearing as total stringwidth less the last char's width plus
#| the right char's right bearing.

#| Get the value of the leftmost outline in a string
method LeftBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[LLX]
    }
    my $char = $s.comb.head;
    $char = 'space' if $char !~~ /\S/;
    self.BBox{$char}[LLX]
}
method lb(Str $s?) {
    self.LeftBearing($s)
}

#| Get the value of the rightmost outline in a string
method RightBearing(Str $s?, :$kern) {
    if not $s.defined {
        return self.FontBBox[URX]
    }
    # get the horizontal bound
    my $str-width = self.stringwidth($s, :$kern);
    my $last-char = $s.comb.tail;
    $last-char    = 'space' if $last-char !~~ /\S/;
    my $lc-urx    = self.BBox{$last-char}[URX];
    my $lc-w      = self.Wx{$last-char};
    my $str-rb    = $str-width - $lc-w + $lc-urx;
    $str-rb
}
method rb(Str $s?, :$kern) {
    self.RightBearing($s)
}

# Returns a list of the bounding box of the input string or the
# FontBBox if a string is not provided.  The user may choose to to kern
# the string.
method StringBBox(Str $s?, :$kern --> List) {
    if not $s.defined {
        return self.FontBBox
    }

    # get the vertical bounds
    my $ury = 0;
    my $lly = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        # a space has a name
        $c = 'space' if $c !~~ /\S/;

        my $uy = self.BBox{$c}[URY];
        $ury = $uy if $uy > $ury;

        my $ly = self.BBox{$c}[LLY];
        $lly   = $ly if $ly < $lly;
    }

    # get the horizontal bounds
    my $llx = self.BBox{$s.comb.head}[LLX];
    my $width = self.stringwidth($s, :$kern);
    my $lchar = $s.comb.tail;
    my $wlchar = self.Wx{$lchar};
    my $urx = self.BBox{$lchar}[URX];
    $urx = $width - $wlchar + $urx;

    $llx, $lly, $urx, $ury
}
method sbb(Str $s?, :$kern --> List) {
    self.StringBBox($s, :$kern)
}

method tb(Str $s?) {
    self.TopBearing($s)
}

#| Get the height of the topmost outline in a string or the entire font if no string is provided
method TopBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[URY];
    }
    my $ury = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        # a space has a name
        $c = 'space' if $c !~~ /\S/;
        my $y = self.BBox{$c}[URY];
        $ury = $y if $y > $ury;
    }
    $ury
}

#| Get the value of the lowest outline outline in a string or the entire font if no string is provided
method BottomBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[LLY];
    }
    my $lly = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        # space has a name
        $c = 'space' if $c !~~ /\S/;
        my $y = self.BBox{$c}[LLY];
        $lly = $y if $y < $lly;
    }
    $lly
}
method bb(Str $s?) {
    self.BottomBearing($s)
}

#| Get the maximum vertical space required for any single line of
#| text or, optionally, for a specific string
method LineHeight(Str $s?) {
    if not $s.defined {
        return self.FontBBox[URY] - self.FontBBox[LLY]
    }
    # get the vertical bounds
    my $ury = 0;
    my $lly = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        # space has a name
        $c = 'space' if $c !~~ /\S/;
        my $uy = self.BBox{$c}[URY];
        $ury = $uy if $uy > $ury;

        my $ly = self.BBox{$c}[LLY];
        $lly   = $ly if $ly < $lly;
    }

    $ury - $lly
}
method lh(Str $s?) {
    self.LineHeight($s)
}

# FontAFM standard methods follow: ==============================

#| UnderlinePosition
method UnderlinePosition {
    $!afm.UnderlinePosition * $!sf # adjust for the desired font size
}

#| UnderlineThickness
method UnderlineThickness {
    $!afm.UnderlineThickness * $!sf # adjust for the desired font size
}

# ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)
# Kern the string. Returns an array of string segments, separated
# by numeric kerning distances, and the overall width of the string.
method kern($string, $fontsize?) {
    #note "TODO: use >>.map and >>*>>";
    #my @arr; #($kerned, $width);
    #@arr = $!afm.kern: $string, $!size; #, :%glyphs;
    #@arr
    $!afm.kern($string, $!size); #, :%glyphs;
}

#| A two-dimensional hash containing from and to glyphs and kerning widths.
method KernData {
    # hash -> hash -> number
    # lizmat's solution
    $!afm.KernData.deepmap({$_ *= $!sf });

    #$!afm.KernData>>.map({ $_>>.map({ $_ * $!sf }) }); #.keys -> $k {
    =begin comment
    note "TODO: use >>.map and >>*>>";
    my $av; # = $!afm.KernData;
    for $!afm.KernData.keys -> $k {
        for $!afm.KernData{$k}.kv -> $k2, $v is copy {
            # adjust for the desired font size
            $v *= $!sf * 1.0;
            $av{$k}{$k2} = $v.Real; # >>*>> $!sf
        }
    }
    $av
    =end comment
}

# $afm.stringwidth($string, $fontsize?, Bool:$kern is copy, :%glyphs)
#| stringwidth
method stringwidth($string, :$kern) {
    if $kern {
        $!afm.stringwidth: $string, $!size, :kern
    }
    else {
        $!afm.stringwidth: $string, $!size, :!kern
    }
}

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

#| array of the overall font bounding box
method FontBBox {
    $!afm.FontBBox >>*>> $!sf # adjust for the desired font size
}

#|
method Version {
    $!afm.Version
}

#|
method Notice {
    $!afm.Notice
}

#|
method Comment {
    $!afm.Comment
}

#|
method EncodingScheme {
    $!afm.EncodingScheme
}

#|
method CapHeight {
    $!afm.CapHeight * $!sf # adjust for the desired font size
}

#|
method XHeight {
    $!afm.XHeight * $!sf # adjust for the desired font size
}

#|
method Ascender {
    $!afm.Ascender * $!sf # adjust for the desired font size
}

#|
method Descender {
    $!afm.Descender * $!sf # adjust for the desired font size
}

#| hash of glyph names and their width
method Wx(--> Hash) {
    $!afm.Wx>>.map({ $_ >>*>> $!sf }) # adjust for the desired font size
}

#| hash of glyph names and their bounding boxes
method BBox(--> Hash) {
    $!afm.BBox>>.map({ $_ >>*>> $!sf }) # multiply hash values by $!sf
}

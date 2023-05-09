unit class FontFactory::Type1::DocFont is export;

use PDF::Lite;
use Font::AFM;
use FontFactory::Type1::BaseFont;

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

#| Get the bounding box for a string
method StringBBox(Str $s, :$kern --> List) {
    my $width;
    if $kern.defined {
        $width = self.stringthwidth($s, :kern);
    }
    else {
        $width = self.stringthwidth($s, :!kern);
    }
    my ($llx, $lly, $urx, $ury) = 0, 0, $width, 0;
    my @chars = $s.comb;
    for @chars -> $char {
        my $bbox = $!afm.BBox{$char};
        my $ly = $bbox[1];
        my $uy = $bbox[3];
        $lly = $ly if $ly > $lly;
        $ury = $uy if $uy > $ury;
    }
    # $llx and $urx are already correct for the desired font size
    $lly *= $!sf; # adjust for the desired font size
    $ury *= $!sf; # adjust for the desired font size

    $llx, $lly, $urx, $ury
}
method sbb() {
}

#| Get the value of the leftmost outline in a string
#|
#| According to the Redbook, Type 1 fonts usually have their left sidebearing at or right of the
#| glyph's origin. The bounding box is always in reference to the origin which has its Y=0 on the
#| baseline and its X=0 is the print point of reference for the caller.
#| So the left sidebearing is defined as the first character's BBox[0] distance, positive to the right of the origin.
#| And we can define a right sidebearing as total stringwidth less the last character's Width - (BBox[3] - BBox[1]).
method LeftBearing(Str $s) {
    my $char = $s.comb.head;
    self.BBox{$char}[0];
}
method lb(Str $s) {
    self.LeftBearing($s)
}

#| Get the value of the rightmost outline in a character
method RightBearing(Str $s) {
    my $char = $s.comb.head;
    my $rb = self.Wx{$char} - self.BBox{$char}[2];
    $rb
}
method rb(Str $s) {
    self.RightBearing($s)
}

#| Get the height of the topmost outline in a string or the entire font if no string is provided
method TopBearing(Str $s?) {
    my $ury = 0;
    my $i   = 3;
    if $s.defined {
        my @chars = $s.comb;
        for @chars -> $c {
            # must ignore spaces for this method
            next if $c !~~ /\S/;
            my $y = self.BBox{$c}[$i];
            $ury = $y if $y > $ury;
        }
    }
    else {
        $ury = self.FontBBox[$i];
    }
    $ury
}
method tb(Str $s?) {
    if $s.defined {
        self.TopBearing($s)
    }
    else {
        self.TopBearing
    }
}

#| Get the value of the bottommost outline in a string or the entire font if no string is provided
method BottomBearing(Str $s?) {
    my $lly = 0;
    my $i   = 1;
    if $s.defined {
        my @chars = $s.comb;
        for @chars -> $c {
            # must ignore spaces for this method
            next if $c !~~ /\S/;
            my $y = self.BBox{$c}[$i];
            $lly = $y if $y < $lly;
        }
    }
    else {
        $lly = self.FontBBox[$i];
    }
    $lly
}
method bb(Str $s?) {
    if $s.defined {
        self.BottomBearing($s)
    }
    else {
        self.BottomBearing
    }
}

#| Get the maximum vertical space required for any single line of
#| text or, optionally, for a specific string
method LineHeight(Str $s?) {
    if $s.defined {
        my $tb = self.TopBearing($s);
        my $bb = self.BottomBearing($s);
        $tb - $bb
    }
    else {
        self.FontBBox[3] - self.FontBBox[1]
    }
}
method lh(Str $s?) {
    if $s.defined {
        self.LineHeight($s)
    }
    else {
        self.LineHeight
    }
}

# FontAFM methods ==============================

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
    my @arr; #($kerned, $width);
    @arr = $!afm.kern: $string, $!size; #, :%glyphs;
    @arr
}

#| A two-dimensional hash containing from and to glyphs and kerning widths.
method KernData {
    my $av; # = $!afm.KernData;
    for $!afm.KernData.keys -> $k {
        for $!afm.KernData{$k}.kv -> $k2, $v is copy {
            # adjust for the desired font size
            $v *= $!sf * 1.0;
            $av{$k}{$k2} = $v.Real; # >>*>> $!sf
        }
    }
    $av
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
method Wx {
    my %h;
    for $!afm.Wx.kv -> $k, $v {
        %h{$k} = $v * $!sf # adjust for the desired font size
    }
    %h
}

#| hash of glyph names and their bounding boxes
method BBox {
    $!afm.BBox>>.map({$_ * $!sf}) # multiply hash values by $!sf
    # adjust for the desired font size
}

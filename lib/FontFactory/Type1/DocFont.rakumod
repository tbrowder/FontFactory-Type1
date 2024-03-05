unit class FontFactory::Type1::DocFont is export;

use PDF::Lite;
use Font::AFM;
use FontFactory::Type1::BaseFont;

constant LLX  = 0; # bbox index for left bound
constant LLY  = 1; # bbox index for lower bound
constant URX  = 2; # bbox index for right bound
constant URY  = 3; # bbox index for upper bound

#| This class represents the final font object and it includes the
#| final size
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

=begin comment
# These chars need translation into names known by PostScript.
# The list may grow and I may mechanically create it.

DEBUG character not known : 'SPACE' (from FF-T1/DocFont.rakumod)
DEBUG character not known : 'APOSTROPHE' (from FF-T1/DocFont.rakumod)
DEBUG character not known : 'AMPERSAND' (from FF-T1/DocFont.rakumod)

DEBUG character not known : 'REVERSE SOLIDUS' (from FF-T1/DocFont.rakumod)
Unknown Adobe PS name for uniname 'VERTICAL LINE' ('|')
Unknown Adobe PS name for uniname 'DIGIT TWO' ('2')
Unknown Adobe PS name for uniname '<control-000A>' ('
=end comment

# .uniname to Adobe PS name
#sub uni2ps($c is copy  --> Str) is export {
sub uni2ps($c is copy) is export {
    my $aname;
    my $u = $c.uniname;
    with $u {
        when /:i space / {
            $aname = $_.lc;
        }
        when /:i apostrophe / {
            $aname = "quoteright";
        }
        when /:i ampersand / {
            $aname = $_.lc;
        }
        when /:i reverse \h+ solidus  / {
            $aname = "backslash";
        }
        when /:i vertical \h+ line / {
            $aname = "bar";
        }
        when /:i digit \h+ two / {
            $aname = "bar";
        }
        when /:i number \h+ sign / {
            $aname = "numbersign";
        }
        when /:i equals \h+ sign / {
            $aname = "equal";
        }
        when /:i quotation \h+ mark / {
            $aname = "quotedbl";
        }
        when /:i right \h+ parenthesis / {
            $aname = "parenright";
        }
        when /:i left \h+ parenthesis / {
            $aname = "parenleft";
        }
        when /:i hyphen '-' minus / {
            $aname = "minus";
        }
        when /:i asterisk / {
            $aname = "asterisk";
        }
        when /:i comma  / {
            $aname = "comma";
        }
        when /:i colon  / {
            $aname = "colon";
        }
        when /:i solidus  / {
            $aname = "slash";
        }
        when /:i digit \h+ (\S+) / {
            my $num = ~$0.lc;
            $aname = $num;
        }
        when /:i control / {
            # really a NEWLINE
            # a '' won't work, need a work-around
            # for now, use a period, later define a 'nospace' character'
            $aname = "period";
        }
        default {
            note "Unknown Adobe PS name for uniname '$_' ('$c')";
        }
    }
    $aname
}

# Convenience methods (and aliases) from the afm object and size.

#| Define the position of the strikethrough line as the midheight of
#| the lower-case 'm'
method StrikethroughPosition {
    my constant \schar = 'm';
    my ($llx, $lly, $urx, $ury) = $!afm.BBox{schar} >>*>> $!sf; # adjust for the desired font size
    0.5 * ($ury - $lly)
}
method sp {
    self.StrikethroughPosition
}

#| Not having found any other source to dispute this, use same as
#| underline thickness
method StrikethroughThickness {
    $!afm.UnderlineThickness * $!sf # adjust for the desired font size
}
method st {
    self.StrikethroughThickness
}

# See Font::AFM for details.

#| According to the Redbook, Type 1 fonts usually have their left
#| sidebearing at or right of the glyph's origin. The bounding box is
#| always in reference to the origin which has its Y=0 on the baseline
#| and its X=0 is the print point of reference for the caller.  So the
#| left sidebearing is defined as the first character's BBox[0]
#| distance, positive to the right of the origin.  And we define a
#| right sidebearing as total stringwidth less the last char's width
#| plus the right char's right bearing.

#| Get the value of the leftmost outline in a string
method LeftBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[LLX]
    }
    my $c = $s.comb.head;
    if self.BBox{$c}:exists {
        return self.BBox{$c}[LLX]
    }
    else {
        $c = uni2ps $c;
        die "FATAL: unknown PS char '$c'" unless self.BBox{$c}:exists;
        return self.BBox{$c}[LLX];
    }
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
    #    my $delta = $Last-width - $Last-urx;
    # amount of width past the $ux of the last char

    my $str-width = self.stringwidth($s, :$kern);

    my ($lc-urx, $lc-w);
    my $last-char = $s.comb.tail;
    if self.BBox{$last-char}:exists {
        $lc-urx    = self.BBox{$last-char}[URX];
        $lc-w      = self.Wx{$last-char};
    }
    else {
        $last-char = uni2ps $last-char;
        die "FATAL: unknown PS char '$last-char'" unless self.BBox{$last-char}:exists;
        $lc-urx    = self.BBox{$last-char}[URX];
        $lc-w      = self.Wx{$last-char};
    }

    my $str-rb    = $str-width - $lc-w + $lc-urx;
    $str-rb
}
method rb(Str $s?, :$kern) {
    self.RightBearing($s, :$kern)
}

#| Get the value of the [advance] width less the rightmost outline in
#| a string.  If the string is not provided, the minimum such value
#| for all glyphs in the font is returned.
method RightBearingFT(Str $s?, :$kern) {
    if not $s.defined {
        my $minrbft = self.FontWx;
        for self.Wx.kv -> $c, $w {
            my $bbox = self.BBox{$c};
            my $rb = $w - $bbox[2];
            $minrbft = $rb if $rb < $minrbft;
        }
        return $minrbft
    }
    # get the horizontal bound
    #    my $delta = $Last-width - $Last-urx;
    # amount of width past the $ux of the last char

    my $last-char = $s.comb.tail;
    my ($lc-w, $bbox);
    if self.BBox{$last-char}:exists {
        $lc-w      = self.Wx{$last-char};
        $bbox      = self.BBox{$last-char};
    }
    else {
        $last-char = uni2ps $last-char;
        die "FATAL: unknown PS char '$last-char'" unless self.BBox{$last-char}:exists;
        $lc-w      = self.Wx{$last-char};
        $bbox      = self.BBox{$last-char};
    }
    my $rbft      = $lc-w - $bbox[2];
    $rbft
}
method rbft(Str $s?, :$kern) {
    self.RightBearingFT($s, :$kern)
}

# Returns a list of the bounding box of the input string or the
# FontBBox if a string is not provided.  The user may choose to to
# kern the string.
method StringBBox(Str $s?, :$kern --> List) {
    if not $s.defined {
        return self.FontBBox
    }

    # get the vertical bounds
    my $ury = 0;
    my $lly = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        my ($ly, $uy) = 0, 0;
        if self.BBox{$c}:exists {
            $uy = self.BBox{$c}[URY];
            $ly = self.BBox{$c}[LLY];
        }
        else {
            $c = uni2ps $c;
            die "FATAL: unknown PS char '$c'" unless self.BBox{$c}:exists;
            $uy = self.BBox{$c}[URY];
            $ly = self.BBox{$c}[LLY];
        }
        $lly   = $ly if $ly < $lly;
        $ury = $uy if $uy > $ury;
    }

    # get the horizontal bounds
    #    my $delta = $Last-width - $Last-urx;
    # amount of width past the $ux of the last char
    my $width;
    if $kern {
        $width = self.stringwidth($s, :kern);  # kerned
        #$width = $!afm.stringwidth($s, self.size, :kern);  # kerned
    }
    else {
        $width = self.stringwidth($s, :!kern); # not kerned
    }

    my $Fchar = $s.comb.head;  # first character
    my $Lchar = $s.comb.tail;  # last character

    my ($Flb, $Lrb, $Lwid);
    if self.BBox{$Fchar}:exists {
        $Flb  = self.BBox{$Fchar}[LLX]; # first character left bearing
    }
    else {
        $Fchar = uni2ps $Fchar;
        die "FATAL: unknown PS char '$Fchar'" unless self.BBox{$Fchar}:exists;
        $Flb  = self.BBox{$Fchar}[LLX]; # first character left bearing
    }
    if self.BBox{$Lchar}:exists {
        $Lrb  = self.BBox{$Lchar}[URX]; # last character right bearing
        $Lwid = self.Wx{$Lchar};        # last character width
    }
    else {
        $Lchar = uni2ps $Lchar;
        die "FATAL: unknown PS char '$Lchar'" unless self.BBox{$Lchar}:exists;
        $Lrb  = self.BBox{$Lchar}[URX]; # last character right bearing
        $Lwid = self.Wx{$Lchar};        # last character width
    }

    my $llx  = $Flb;
    my $urx  = $width - $Lwid + $Lrb;

    $llx, $lly, $urx, $ury
}
method sbb(Str $s?, :$kern --> List) {
    self.StringBBox($s, :$kern)
}

#| Get the height of the topmost outline in a string or the entire
#| font if no string is provided
method TopBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[URY];
    }

    my $ury = 0;
    my @chars = $s.comb;

    for @chars -> $c is copy {
        my $y;
        if self.BBox{$c}:exists {
            $y = self.BBox{$c}[URY];
        }
        else {
            $c = uni2ps $c;
            die "FATAL: unknown PS char '$c'" unless self.BBox{$c}:exists;
            $y = self.BBox{$c}[URY];
        }
        $ury = $y if $y > $ury;
    }
    $ury
}
method tb(Str $s?) {
    self.TopBearing($s)
}

#| Get the value of the lowest outline outline in a string or the
#| entire font if no string is provided
method BottomBearing(Str $s?) {
    if not $s.defined {
        return self.FontBBox[LLY];
    }
    my $lly = 0;
    my @chars = $s.comb;
    for @chars -> $c is copy {
        my $y;
        if self.BBox{$c}:exists {
            $y = self.BBox{$c}[LLY];
        }
        else {
            $c = uni2ps $c;
            die "FATAL: unknown PS char '$c'" unless self.BBox{$c}:exists;
            $y = self.BBox{$c}[LLY];
        }
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
        my ($ly, $uy);
        if self.BBox{$c}:exists {
            $ly = self.BBox{$c}[LLY];
            $uy = self.BBox{$c}[URY];
        }
        else {
            $c = uni2ps $c;
            die "FATAL: unknown PS char '$c'" unless self.BBox{$c}:exists;
            $ly = self.BBox{$c}[LLY];
            $uy = self.BBox{$c}[URY];
        }
        $ury = $uy if $uy > $ury;
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
method up {
    self.UnderlinePosition
}

#| UnderlineThickness
method UnderlineThickness {
    $!afm.UnderlineThickness * $!sf # adjust for the desired font size
}
method ut {
    self.UnderlineThickness
}

# ($kerned, $width) = $afm.kern($string, $fontsize?, :%glyphs?)
# Kern the string. Returns an array of string segments, separated
# by numeric kerning distances, and the overall width of the string.
method kern($string) {
    $!afm.kern($string, $!size); #, :%glyphs;
}

#| A two-dimensional hash containing from and to glyphs and kerning widths.
method KernData {
    # hash -> hash -> number
    # lizmat's solution
    #$!afm.KernData.deepmap({$_ *= $!sf }) # adjust for the desired font size
    $!afm.KernData.deepmap({$_ * $!sf }) # adjust for the desired font size
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

#| Array of the overall font bounding box
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

#| Hash of glyph names and their width
method Wx(--> Hash) {
    $!afm.Wx.deepmap({ $_ * $!sf }) # adjust for the desired font size
}

#| Provides the maximum [advance] width of the font's glyphs
method FontWx {
    my $maxw = 0;
    for $!afm.Wx.kv -> $c, $w {
        $maxw = $w if $w > $maxw;
    }
    $maxw * $!sf # adjust for the desired font size
}

#| Hash of glyph names and their bounding boxes
method BBox(--> Hash) {
    $!afm.BBox.deepmap({ $_ * $!sf }) # adjust for the desired font size
}

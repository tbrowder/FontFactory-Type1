unit module FontFactory::Type1::DocFont::StringSub;

use experimental :cached;

class String is export {
    has $.string;
    has $.left-bearing;
}

sub get-string-metrics($s --> String) is export {
    my $sc = String.new;
    $sc
}

=finish

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

#!/usr/bin/env raku

use Font::AFM;

my $debug = 1;

my $string = "A very long line Excently done eXactly and Carefully to Test Kerning.";

my %f = [
    Times-Roman => 12.3,
    Times-Italic => 12.3,
    Courier => 10,
];

my @res1;
my @res2;
my (@res, $res, $name, $fontsize, $size, $width, $font, $kerned);
for %f.kv -> $name, $size {
    
    my Font::AFM $afm;
    @res = [];

    $afm .= new: :name("./{$name}.afm");

    my $res = $afm.FullName;

    if $debug {
        note qq:to/HERE/;
        DEBUG: 
        name:     $name
        size:     $size
        HERE
    }

    # 1 use lives-ok
    #$afm = Font::AFM.new: "./{$name}.afm";

    =begin comment
    # this line is wrong in PDF::AFM: my Font::AFM $afm .= core-font: $name;
    # my Font::AFM $afm .= core-font: $name;
    =end comment

    =begin comment
    # the following code is also wrong:
    # use Font::Metrics::times-roman;
    # my $bbox = Font::Metrics::times-roman.FontBBox;
    # note "DEBUG: {$bbox.gist}";
    # next;
    =end comment

    =begin comment
    # another try
    use PDF::Lite;
    my $pdf = PDF::Lite.new;
    my $font = $pdf.core-font: :family<Times-Roman>;
    note $font.gist;
    =end comment

    # 2
    $res = $afm.FontName;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    #=begin comment
    # 3
    $res = $afm.FullName;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 4
    $res = $afm.FamilyName;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 5
    $res = $afm.Weight;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 6
    $res = $afm.ItalicAngle;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 7
    $res = $afm.IsFixedPitch;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 8
    $res = $afm.FontBBox;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 9
    $res = $afm.KernData;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 10
    $res = $afm.UnderlinePosition;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 11
    $res = $afm.UnderlineThickness;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 12
    $res = $afm.Version;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 13
    $res = $afm.Notice;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 14
    $res = $afm.Comment;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 15
    $res = $afm.EncodingScheme;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 16
    $res = $afm.CapHeight;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 17
    $res = $afm.XHeight;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 18
    $res = $afm.Ascender;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 19
    $res = $afm.Descender;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 20
    $res = $afm.Wx;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 21
    $res = $afm.BBox;
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 22
    my $fontsize = $size;
    $res = $afm.stringwidth($string, $fontsize, :kern);
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 23
    $res = $afm.stringwidth($string, $fontsize, :!kern);
    note "DEBUG: \$res = '$res'" if $debug;
    @res.push: $res;

    # 24
    my %glyphs;
    ($kerned, $width) = $afm.kern($string, $fontsize, :kern, :%glyphs);
    note "DEBUG: \$kerned = '$kerned'" if $debug;
    @res.push: $kerned;
    note "DEBUG: \$width = '$width'" if $debug;
    @res.push: $width;

    # save the data
    if $_ ~~ /1/ {
        @res1 = @res;
    }
    elsif $_ ~~ /2/ {
        @res2 = @res;
    }
    #=end comment
}

say @res1.raku;
say @res2.raku;

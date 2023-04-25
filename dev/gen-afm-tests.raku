#!/usr/bin/env raku

use Font::AFM;

my $debug = 0;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Generates a set of tests for the 'Font::AFM' methods.
    HERE
    exit
}
++$debug if @*ARGS.head ~~ /d/;

my $kern-test-string = "With Viry City Did Fir Yp Care To Test Kern On Pip Que Rg";

my %results = [
    Times-Roman  => [],
    Times-Italic => [],
    Courier      => [],
];
my %f = [
    Times-Roman  => 12.3,
    Times-Italic => 12.3,
    Courier      => 10,
];
my @k = %f.keys.sort;

my (@res, $res, $name, $fontsize, $size, $width, $font, $kerned);

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

for @k -> $name {
    my $size = %f{$name};
    note "DEBUG: name: $name";
    note "DEBUG: size: $size";

    my Font::AFM $afm;

    # 1 use lives-ok
    # the name here should be an absolute path
    my $path = "./{$name}".IO.absolute;
    #$afm = Font::AFM.new: :name($path); #"./{$name}.afm");
    $afm = Font::AFM.new: :$name; #"./{$name}.afm");

    # 2
    $res = $afm.FontName;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 3
    $res = $afm.FullName;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 4
    $res = $afm.FamilyName;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 5
    $res = $afm.Weight;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 6
    $res = $afm.ItalicAngle;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 7
    $res = $afm.IsFixedPitch;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 8
    $res = $afm.FontBBox;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res.gist";

    # 9
    $res = $afm.KernData;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "KernData"; # $res";

    # 10
    $res = $afm.UnderlinePosition;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 11
    $res = $afm.UnderlineThickness;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 12
    $res = $afm.Version;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 13
    $res = $afm.Notice;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 14
    $res = $afm.Comment;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 15
    $res = $afm.EncodingScheme;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 16
    $res = $afm.CapHeight;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 17
    $res = $afm.XHeight;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 18
    $res = $afm.Ascender;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 19
    $res = $afm.Descender;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 20
    $res = $afm.Wx;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "Wx"; #$res";

    # 21
    $res = $afm.BBox;
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "BBox"; #$res";

    # 22
    my $fontsize = $size;
    $res = $afm.stringwidth($string, $fontsize, :kern);
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 23
    $res = $afm.stringwidth($string, $fontsize, :!kern);
    note "DEBUG: \$res = '$res'" if $debug;
    %results{$name}.push: "$res";

    # 24
    my %glyphs;
    ($kerned, $width) = $afm.kern($string, $fontsize, :kern, :%glyphs);
    note "DEBUG: \$kerned = '$kerned'" if $debug;
    %results{$name}.push: "$kerned";
    note "DEBUG: \$width = '$width'" if $debug;
    %results{$name}.push: "$width";
}
note %results.gist;

use Test;
use Font::AFM;

my $debug = 0;

if not @*ARGS  {
    print qq:to/HERE/;
    Usage: go

    Shows the methods for module 'Font::AFM'.
    HERE
    exit
}

my $afm = Font::AFM.new: :name<Times-Roman>;
#say $afm.FontName;

say "methods:";
#my @m = $afm.^methods(:local).gist.words;
my @m = $afm.^methods.gist.words;
say "  $_" for @m;
my %h = $afm.metrics;
my @k = $afm.metrics.keys.sort;
for @k -> $k {
    my $v = %h{$k};
    say "$k => $v";
}



=finish

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

sub test2(Font::AFM $a, FontFactory::Type1 $b) {
    # the two arg classes should have the same metrics
    my ($av, $bv);
    =begin comment
    # 1 use lives-ok
    # the name here should be an absolute path
    my $path = "./{$name}".IO.absolute;
    #$afm = Font::AFM.new: :name($path); #"./{$name}.afm");
    $afm = Font::AFM.new: :$name; #"./{$name}.afm");
    =end comment

    # 2
    $res = $a.FontName;
    $res = $b.FontName;

    # 3
    $res = $afm.FullName;
    $res = $afm.FullName;

    # 4
    $res = $afm.FamilyName;
    $res = $afm.FamilyName;

    # 5
    $res = $afm.Weight;
    $res = $afm.Weight;

    # 6
    $res = $afm.ItalicAngle;
    $res = $afm.ItalicAngle;

    # 7
    $res = $afm.IsFixedPitch;
    $res = $afm.IsFixedPitch;

    # 8
    $res = $afm.FontBBox;
    $res = $afm.FontBBox;

    # 9
    $res = $afm.KernData;
    $res = $afm.KernData;

    # 10
    $res = $afm.UnderlinePosition;
    $res = $afm.UnderlinePosition;

    # 11
    $res = $afm.UnderlineThickness;
    $res = $afm.UnderlineThickness;

    # 12
    $res = $afm.Version;
    $res = $afm.Version;

    # 13
    $res = $afm.Notice;
    $res = $afm.Notice;

    # 14
    $res = $afm.Comment;
    $res = $afm.Comment;

    # 15
    $res = $afm.EncodingScheme;
    $res = $afm.EncodingScheme;

    # 16
    $res = $afm.CapHeight;
    $res = $afm.CapHeight;

    # 17
    $res = $afm.XHeight;
    $res = $afm.XHeight;

    # 18
    $res = $afm.Ascender;
    $res = $afm.Ascender;

    # 19
    $res = $afm.Descender;
    $res = $afm.Descender;

    # 20
    $res = $afm.Wx;
    $res = $afm.Wx;

    # 21
    $res = $afm.BBox;
    $res = $afm.BBox;

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

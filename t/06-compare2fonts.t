use Test;
use Font::AFM;
use FontFactory::Type1;

my $debug = 0;

my $name = "Times-Roman";
my $fontsize = 10.3;

my $afm-obj;
my $ff;

subtest {
    plan 2;

    lives-ok {
        $afm-obj = Font::AFM.new: :$name;
    }

    lives-ok {
        $ff = FontFactory::Type1.new;
    }
}

my $ff-font = $ff.get-font("t10d3");

subtest {
    plan 18;
    test2 :$afm-obj, :$fontsize, :$ff-font;
}


=begin comment 
if 0 {
    # this line is wrong in PDF::AFM: my Font::AFM $a .= core-font: $name;
    my Font::AFM $a .= core-font: $name;
}
=end comment
=begin comment
if 0 {
    # the following code is also wrong:
    use Font::Metrics::times-roman;
    my $bbox = Font::Metrics::times-roman.FontBBox;
    note "DEBUG: {$bbox.gist}";
}
=end comment
=begin comment
if 0 {
    # this works
    # another try
    use PDF::Lite;
    my $pdf = PDF::Lite.new;
    my $font = $pdf.core-font: :family<Times-Roman>;
    note $font.gist;
}
=end comment

#sub test2(Font::AFM :$afm-obj, 
#          :$fontsize,
#          :$ff-font,

sub test2(Font::AFM :$afm-obj, 
          :$fontsize,
          :$ff-font,
         ) {
    my $a = $afm-obj;
    my $b = $ff-font;

    # the two arg classes should have the same metrics
    my ($av, $bv);

    =begin comment
    # 1 use lives-ok
    # the name here should be an absolute path
    my $path = "./{$name}".IO.absolute;
    #$a = Font::AFM.new: :name($path); #"./{$name}.afm");
    $a = Font::AFM.new: :$name; #"./{$name}.afm");
    =end comment

    # test 1
    $av = $a.FontName;
    $bv = $b.FontName;
    is $av, $bv;

    # test 2
    $av = $a.FullName;
    $bv = $b.FullName;
    is $av, $bv;

    # test 3
    $av = $a.FamilyName;
    $bv = $b.FamilyName;
    is $av, $bv;

    # test 4
    $av = $a.Weight;
    $bv = $b.Weight;
    is $av, $bv;

    # test 5
    $av = $a.ItalicAngle;
    $bv = $b.ItalicAngle;
    is $av, $bv;

    # test 6
    $av = $a.IsFixedPitch;
    $bv = $b.IsFixedPitch;
    is $av, $bv;

    # test 7
    $av = $a.FontBBox;
    $bv = $b.FontBBox;
    is $av, $bv;

    # test 8
    $av = $a.KernData;
    $bv = $b.KernData;
    is $av, $bv;

    # test 9
# Failed test at ../t/06-compare2fonts.t line 109
# expected: '-1.03'
#      got: '-100'
    $av = $a.UnderlinePosition;
    $bv = $b.UnderlinePosition;
    is $av, $bv, "UnderLinePosition";

    # test 10
# Failed test at ../t/06-compare2fonts.t line 114
# expected: '0.515'
#      got: '50'
    $av = $a.UnderlineThickness;
    $bv = $b.UnderlineThickness;
    is $av, $bv, "UnderlineThickness";

    # test 11
    $av = $a.Version;
    $bv = $b.Version;
    is $av, $bv;

    # test 12
    $av = $a.Notice;
    $bv = $b.Notice;
    is $av, $bv;

    # test 13
    $av = $a.Comment;
    $bv = $b.Comment;
    is $av, $bv;

    # test 14
    $av = $a.EncodingScheme;
    $bv = $b.EncodingScheme;
    is $av, $bv;

    # test 15
    $av = $a.CapHeight;
    $bv = $b.CapHeight;
    is $av, $bv;

    # test 16
    $av = $a.XHeight;
    $bv = $b.XHeight;
    is $av, $bv;

    # test 17
    $av = $a.Ascender;
    $bv = $b.Ascender;
    is $av, $bv;

    # test 18
    $av = $a.Descender;
    $bv = $b.Descender;
    is $av, $bv;

    =begin comment
    # TODO the following 5 need deeper tests:

    # test 19
    $av = $a.Wx;
    $av = $a.Wx;
    is $av, $bv;

    # test 20
    $av = $a.BBox;
    $av = $a.BBox;
    is $av, $bv;

    # test 21
    my $fontsize = $size;
    $av = $a.stringwidth($string, $fontsize, :kern);
    note "DEBUG: \$av = '$av'" if $debug;
    %avults{$name}.push: "$av";

    # test 22
    $av = $a.stringwidth($string, $fontsize, :!kern);
    note "DEBUG: \$av = '$av'" if $debug;
    %avults{$name}.push: "$av";

    # test 23
    my %glyphs;
    ($kerned, $width) = $a.kern($string, $fontsize, :kern, :%glyphs);
    note "DEBUG: \$kerned = '$kerned'" if $debug;
    %avults{$name}.push: "$kerned";
    note "DEBUG: \$width = '$width'" if $debug;
    %avults{$name}.push: "$width";
    =end comment
}

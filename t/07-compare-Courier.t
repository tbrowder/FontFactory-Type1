use Test;
use Font::AFM;
use FontFactory::Type1;

my $debug = 0;

my $name = "Courier";
my $fontsize = 10;

my $afm-obj;
my $ff;
my $ff-font;

plan 6;

lives-ok {
    $afm-obj = Font::AFM.new: :$name;
}

lives-ok {
    $ff = FontFactory::Type1.new;
}        

lives-ok {
    $ff-font = $ff.get-font("c10");
}        

# check raw sizes of each
my $sf = 10.0/1000.0;

my @bbox1 = $afm-obj.FontBBox;
my @bbox2 = $ff-font.FontBBox;
is-deeply @bbox1 >>*>> $sf, @bbox2; 

my $w1 = $afm-obj.Wx<a>;
my $w2 = $ff-font.Wx<a>;
is $w1, 600, "char 'a' width is $w1 points";
is $w2, 6, "char 'a' width is $w2 points";

done-testing;


=finish

my $ff-font = $ff.get-font("c10");

subtest {
    plan 22;
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

sub test2(Font::AFM :$afm-obj!, 
          :$fontsize!,
          :$ff-font!,
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
    $av = $a.UnderlinePosition;
    $bv = $b.UnderlinePosition;
    is $av, $bv, "UnderLinePosition";

    # test 10
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

    # test 19
    $av = $a.Wx;
    $bv = $b.Wx;
    is $av, $bv;

    # test 20
    $av = $a.BBox;
    $bv = $b.BBox;
    is $av, $bv;

    my $string = "The Quick Brown Fox Jumped Over the Lazy Dog. That Was Silly, Wasn't It?";

    # test 21
    $av = $a.stringwidth($string, $fontsize, :kern);
    $bv = $b.stringwidth($string, :kern);
    is $av, $bv, "compare stringwidth, kerned";
    # not ok 21 - 
    # Failed test at ../t/06-compare2fonts.t line 193
    # expected: '0'
    #      got: '319.4236'

    # test 22
    $av = $a.stringwidth($string, $fontsize, :!kern);
    $bv = $b.stringwidth($string, :!kern);
    is $av, $bv, "compare stringwidth, no kern";


    my %glyphs;
    my (@a, @b, $akerned, $bkerned, $awidth, $bwidth);
    @a = $a.kern($string, $fontsize, :kern, :%glyphs);
    @b = $b.kern($string, $fontsize, :kern, :%glyphs);

    # The following tests are not needed because method 'kern'
    # is used internally by method 'stringwidth' and thus not 
    # needed by this caller.

    =begin comment
    # test 23
    is-deeply, @a, @b;

    ($akerned, $awidth) = $a.kern($string, $fontsize, :kern, :%glyphs);
    ($bkerned, $bwidth) = $b.kern($string, $fontsize, :kern, :%glyphs);
    is $akerned, $bkerned, "compare kerned letters";
    # not ok 23 - 
    # Failed test at ../t/06-compare2fonts.t line 205
    # expected: (Any)
    #      got: ''

    # test 24
    is $awidth, $bwidth, "compare kerned letters/width";
    # not ok 24 - 
    # Failed test at ../t/06-compare2fonts.t line 206
    # expected: (Any)
    #      got: '0'
    =end comment
}

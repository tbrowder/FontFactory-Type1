use Test;
use Font::AFM;
use FontFactory::Type1;
use lib <./t/lib>;
use Utils;

my $debug = 0;

my $name = "Times-Roman";
my $fontsize = 10.3;

my $afm-obj;
my $ff;

plan 2; # 2 subtests

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

sub test2(Font::AFM :$afm-obj!,
          :$fontsize!,
          :$ff-font!,
         ) {
    my $a = $afm-obj;
    my $b = $ff-font;
    my $sf = $fontsize / 1000.0; # scale factor

    # the two arg classes should have the same metrics
    # after adjusting by the scale factor
    my ($av, $bv);

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
    # array
    $av = $a.FontBBox;
    $bv = $b.FontBBox;
    is-deeply $av >>*>> $sf, $bv;

    # test 8
    # two-dimensional hash
    # see helper prog /dev/try-db1-hash.raku
    # hash -> hash -> number
    $av = $a.KernData.deepmap({ $_ * $sf });
    # hash -> hash -> number
#    $!afm.KernData>>.map({ $_>>.map({ $_ * $!sf }) }); #.keys -> $k {
    $bv = $b.KernData;

    =begin comment
    # unpack the structure to multiply Font::AFM values by the scale factor
    # see helper prog /dev/try-db1-hash.raku
    for $av.keys -> $k {
        for $av{$k}.kv -> $k2, $v is copy {
            $av{$k}{$k2} = $v *= $sf;
        }
    }
    # now do the test
    =end comment
    is-deeply $av, $bv, "2d-hash check, multi-test 8";

    # test 9
    $av = $a.UnderlinePosition;
    $bv = $b.UnderlinePosition;
    is $av*$sf, $bv, "UnderLinePosition";

    # test 10
    $av = $a.UnderlineThickness;
    $bv = $b.UnderlineThickness;
    is $av*$sf, $bv, "UnderlineThickness";

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
    is $av*$sf, $bv;

    # test 16
    $av = $a.XHeight;
    $bv = $b.XHeight;
    is $av*$sf, $bv;

    # test 17
    $av = $a.Ascender;
    $bv = $b.Ascender;
    is $av*$sf, $bv;

    # test 18
    $av = $a.Descender;
    $bv = $b.Descender;
    is $av*$sf, $bv, "test 18";

    # test 19
    # hash keyed by char, value char width
    $av = afmWx; # $a.Wx>>.map({$_ >>*>> $sf});
    $bv = $b.Wx;
    if 0 {
        for $av.keys -> $k {
            my $v = $av{$k} * $sf;
            $av{$k} = $v; #.Array; #List;
        }
    }

    #is-deeply $aav, $bv, "test 19";
    #is-deeply $av>>.map({$_ * $sf}), $bv, "test 19";
    is-deeply $av, $bv, "test 19";

    # test 20
    # hash of lists keyed by character name
    $av = afmBBox; #$a.BBox>>.map({$_ >>*>> $sf});
    $bv = $b.BBox;
    is-deeply $av, $bv, "compare my BBox with the test's, test 20";

    my $string = "The Quick Brown Fox Jumped Over the Lazy Dog. That Was Silly, Wasn't It?";

    # test 21
    $av = $a.stringwidth($string, $fontsize, :kern);
    $bv = $b.stringwidth($string, :kern);
    is $av, $bv, "compare stringwidth, kerned";

    # test 22
    $av = $a.stringwidth($string, $fontsize, :!kern);
    $bv = $b.stringwidth($string, :!kern);
    is $av, $bv, "compare stringwidth, no kern";

    # The following tests are not really needed because method 'kern'
    # is used internally by method 'stringwidth' and thus not
    # needed by this caller.

    my ($akerned, $awidth) = $a.kern($string, $fontsize, :kern);
    my ($bkerned, $bwidth) = $b.kern($string, :kern);

    # test 23
    is $awidth, $bwidth, "compare kerned letters/width";

    # test 24
    is-deeply $akerned.kv, $bkerned.kv;
}

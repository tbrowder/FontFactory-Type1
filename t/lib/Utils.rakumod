unit module Utils;

use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::DocFont;

constant LLX is export  = 0;
constant LLY is export  = 1;
constant URX is export  = 2;
constant URY is export  = 3;

constant Text is export = "Bo Do Fo Go Jo Ko Oo Po To Uo Vo Wo Yo";

constant $factory is export = FontFactory::Type1.new;

enum btype is export <afm mix ff>;

class StrBBox is export {
    # constant values for all classes
    has       $.name = "Times-Roman";
    has       $.size = 10.3;
    has       $.text = Text;

    #has $.type is required; # afm, ff, mix
    has $.type = 'ff'; #is required; # afm, ff, mix
    has $.kern is required;

    # calculated values returned by running the sub
    # 10 items
    has $.llx is rw = 0;
    has $.lly is rw = 0;
    has $.urx is rw = 0;
    has $.ury is rw = 0;
    has $.left-char is rw = "";
    has $.left-bearing is rw = 0;
    has $.right-char is rw = "";
    has $.right-char-width is rw = 0;
    has $.right-bearing is rw = 0;
    has $.width is rw = 0;

    has $.delta is rw = 0;

    method header {
        # look at the calculation for the right bearing part of the bbox

        print qq:to/HERE/;
        llx, lly, urx, ury, left-char, left-bearing, right-char, right-char-width, right-bearing, width, type, kern, delta,
        HERE
    }

    method output  {
        print qq:to/HERE/;
        $!llx, $!lly, $!urx, $!ury, $!left-char, $!left-bearing, $!right-char, $!right-char-width, $!right-bearing, $!width, $!type, $!kern, $!delta,
        HERE
    }

} # end class Bbox

sub afmFontBBox($name = "Times-Roman", :$size = 10.3, :$sf --> Array) is export {
    my $factor = $sf.defined ?? $sf !! ($size/1000.0);

    my $afm = Font::AFM.new: :$name;
    my Array $a;

    $a = $afm.FontBBox >>*>> $factor;
    $a
}

sub afmWx($name = "Times-Roman", :$size = 10.3, :$sf --> Hash) is export {
    my $factor = $sf.defined ?? $sf !! ($size/1000.0);

    my $afm = Font::AFM.new: :$name;
    my Hash $h;

    for $afm.Wx.kv -> $k, $v {
        $h{$k} = $v * $factor;
    }
    $h
}

sub afmBBox($name = "Times-Roman", :$size = 10.3, :$sf --> Hash) is export {
    my $factor = $sf.defined ?? $sf !! ($size/1000.0);

    my $afm = Font::AFM.new: :$name;
    my Hash $h;

    for $afm.BBox.kv -> $k, $v {
        $h{$k} = $v >>*>> $factor;
    }
    $h
}

sub string-bbox(
    # defaults:
    $text = Text, 
    :$name = <Times-Roman>, 
    :$size = 10.3, 
    #:$type!, # = 'ff', # afm, mix, ff
    :$type= 'ff'; #!, # = 'ff', # afm, mix, ff
    # options
    :$kern, 
    StrBBox :$box, # export all data for debugging
    :$debug,
) is export {
    # for convenience
    my $s = $text;

    my $afm = Font::AFM.new: :$name;
    my $f   = $factory.get-font: 't10d3';

    # common variables among the three types
    my ($llx, $lly, $urx, $ury) = 0, 0, 0, 0;
    my ($lx, $ly, $ux, $uy);
    constant SPACE = 'space';

    my $sf = $size / 1000.0;

    my $o = $type eq "afm" ?? $afm !! $f;
    my $use-afm = $type eq "afm" ?? True !! False;

    # get the vertical bounds
    for $s.comb -> $c is copy {
        $c = SPACE if $c !~~ /\S/;

        #my $ly = $afm.BBox{$c}[LLY];
        $ly = $o.BBox{$c}[LLY];
        $lly = $ly if $ly < $lly;

        #my $uy = $afm.BBox{$c}[URY];
        my $uy = $o.BBox{$c}[URY];
        $ury = $uy if $uy > $ury;
    } 
    $lly *= $sf if $use-afm;
    $ury *= $sf if $use-afm;

    # get the horizontal bounds
    my $width;
    if $kern {
        # kerned
        if $use-afm {
            $width = $afm.stringwidth($s, $size, :kern);  
        }
        else {
            $width = $f.stringwidth($s, :kern);  
        }
    }
    else {
        # not kerned
        if $use-afm {
            $width = $afm.stringwidth($s, $size, :!kern);  
        }
        else {
            $width = $f.stringwidth($s, :!kern);  
        }
    }

    my $First-char = $s.comb.head;                      # first character
    my $Last-char  = $s.comb.tail;                      # last character

    my ($First-llx, $Last-urx, $Last-width);
    $First-llx  = $o.BBox{$First-char}[LLX]; # left bearing
    $Last-urx   = $o.BBox{$Last-char}[URX];  # right bearing of the last character
    $Last-width = $o.Wx{$Last-char};         # width of last character

    $First-llx  *= $sf if $use-afm;
    $Last-urx   *= $sf if $use-afm;
    $Last-width *= $sf if $use-afm;

    =begin comment
    my $First-llx  = $sf * $afm.BBox{$First-char}[LLX]; # left bearing
    my $Last-urx   = $sf * $afm.BBox{$Last-char}[URX];  # right bearing
    my $Last-width = $sf * $afm.Wx{$Last-char};         # width of last character
    =end comment

    $llx = $First-llx;
    my $delta = $Last-width - $Last-urx; # amount of width past the $ux of the last char
    #$urx = $width - $Last-width + $Last-urx;
    $urx = $width - $delta; #$Last-width + $Last-urx;

    if $box.defined {
        # fill in with current data
        $box.llx = $llx; 
        $box.lly = $lly; 
        $box.urx = $urx; 
        $box.ury = $ury;
        $box.left-char = $First-char;
        $box.left-bearing = $First-llx; 
        $box.right-char = $Last-char;
        $box.right-char-width = $Last-width; 
        $box.right-bearing = $Last-urx; 
        $box.width = $width; 
        # extra for debugging
        $box.delta = $delta;
    }

    # return the solution
    $llx, $lly, $urx, $ury
}


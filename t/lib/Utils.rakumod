unit module Utils;

use Font::AFM;

constant LLX = 0;
constant LLX = 1;
constant URX = 2;
constant URX = 3;

sub string-bbox($s, :$name!, :$size!, :$kern, :$debug) is export {
    my $afm = Font::AFM.new: :$name;

    my ($llx, $lly, $urx, $ury) = 0, 0, 0, 0;

    # get the vertical bounds
    for $s.comb -> $c is copy {
        $c = 'space' if !~~ /\S/;
        my $ly = $afm.BBox{$c}[LLY];
        $lly = $ly if $ly < $lly;
        my $uy = $afm.BBox{$c}[URY];
        $ury = $uy if $uy > $ury;
    } 

    # get the horizontal bounds
    my $width = $afm.stringwidth($s, $size, :$kern); # string width, kerned if requested
    my $Fchar = $s.comb.head;                        # first character
    my $Lchar = $s.comb.tail;                        # last character
    my $Flb   = $afm.BBox{$Fchar}[LLX];              # left bearing
    my $Lrb   = $afm.BBox{$Fchar}[URX];              # right bearing
    my $Lwid  = $afm.Wx{$Lchar};                     # width of last character
    $llx = $Flb;
    $urx = $width - $Lwid + $Lrb

    # the solution
    $llx, $lly, $urx, $ury
}


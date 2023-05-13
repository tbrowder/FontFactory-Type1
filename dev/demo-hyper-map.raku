#!/bin/env raku

use Data::Dump;

my $sf = 10.3/1000;
 
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} BBox | KernData [debug]

    Shows a dump of the selected data structure 
      before and after a hyper or map have been
      applied to multiply all numerical values 
      by a common factor: $sf
    HERE
    exit;
}

my $debug = 0;
my $B     = 0;
my $K     = 0;

for @*ARGS {
    when /^:i d/ { ++$debug }
    when /^:i b/ { 
        ++$B;
    }
    when /^:i k/ {
        ++$K;
    }
    default {
        say "FATAL: Unknown arg '$_'";
        exit;
    }
}

# create structures as seen in Font::AFM KernData and BBox
#   hash -> hash -> number       (KernData)
#   hash -> list of four numbers (BBox)
my @a = <a b>;
my @b = <x y>;
my @c = 10, -10, 850, 750;  

my $n = 600;
my $kd; # KernData;
my $bb; # BBox;
for @a -> $a {
    $bb{$a} = |@c;
    for @b -> $b {
        $kd{$a}{$b} = $n += 10;
    }
}

if $debug {
    say "the input data (emulating .BBox):"; 
    say Dump($bb, :4indent, :!color, :no-postfix);
    say "the input data (emulating .:KernData):";
    say Dump($kd, :4indent, :!color, :no-postfix);
    say "Early exit..."; exit;
}

if $B {
    BBox(:$bb, :$sf);
}
elsif $K {
    KernData(:$kd, :$sf);
}

say();
say "Normal end.";

#=== subroutines ===
sub BBox(:$bb, :$sf) is export {
    say "Updating the .BBox with the scale factor: $sf"; 
    say();
    say "Original:";
    say "  ", $bb.gist;

    my $bb2 = $bb>>.map({ $_ >>*>> $sf });

    say();
    say "Scaled for the using font:";
    say "  ", $bb2.gist;
    say "Looks good!";
    
}

sub KernData(:$kd, :$sf) is export {
    # solution provided by Lizmat on #raku, 2023-05-13
    say "Updating the .KernData with the scale factor: $sf"; 
    say();
    say "Original:";
    say "  ", $kd.gist;

    my $kd2 = $kd.deepmap({$_ *= $sf });

    say();
    say "Scaled for the using font:";
    say "  ", $kd2.gist;
    say "Looks good!";
}


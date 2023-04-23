#!/usr/bin/env raku

use lib <./lib ../lib>;

use PDF::Lite;
use FontFactory::Type1;
use FontFactory::Type1::Utils;

show-myfonts;

# use the factory
my $pdf = PDF::Lite.new;
my $ff  = FontFactory::Type1.new :$pdf;

# define a DocFont
# use a name that associates its face and size
my $t12d1 = $ff.get-font: 't12d1'; # <= use a 'd' for a decimal point
say "name: {$t12d1.name}";
say "size: {$t12d1.size}";

# define another DocFont
my $c10   = $ff.get-font: 'c10';
say "name: {$c10.name}";
say "size: {$c10.size}";

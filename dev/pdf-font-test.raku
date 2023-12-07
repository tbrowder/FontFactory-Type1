#!/usr/bin/env raku

# needed to access corefonts
use PDF::Content::Font::CoreFont;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go
      
    Exercisises PDF::Content::Font::CoreFont
    HERE
    exit;
}


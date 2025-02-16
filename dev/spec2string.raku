#!/usr/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <spec string>

    Converts special octal or hex codes in the input string
      to the corresponding Unicode glyphs:

        \\nnn   - an octal glyph

        E<Xnn> - a hex glyph

    HERE
    exit;
}


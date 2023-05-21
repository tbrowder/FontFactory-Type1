[![Actions Status](https://github.com/tbrowder/FontFactory-Type1/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FontFactory-Type1/actions) [![Actions Status](https://github.com/tbrowder/FontFactory-Type1/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FontFactory-Type1/actions) [![Actions Status](https://github.com/tbrowder/FontFactory-Type1/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FontFactory-Type1/actions)

NAME
====

**FontFactory::Type1** - Provides the standard *Adobe PostScript* fonts in a friendly package for use with many *PDF::** modules.

**WARNING** The previous version had some erroneous methods and shoud not be used!>

WARNING: THIS VERSION (v.0.0.1) HAS SERIOUS PROBLEMS AND IT SHOULD NOT BE USED. A NEW VERSION WILL BE RELEASED SOON
==================================================================================================================

SYNOPSIS
========

Find the fonts available in the current version along with their aliases:

```raku
use FontFactory::Type1;
use FontFactory::Type1::Subs;

show-fonts;

# output:
Font family: 'Courier'               (alias: 'c')
Font family: 'Courier-Bold'          (alias: 'ch')
Font family: 'Courier-BoldOblique'   (alias: 'cbo')
Font family: 'Courier-Oblique'       (alias: 'co')
Font family: 'Helvetica'             (alias: 'h')
Font family: 'Helvetica-Bold'        (alias: 'hb')
Font family: 'Helvetica-BoldOblique' (alias: 'hbo')
Font family: 'Helvetica-Oblique'     (alias: 'ho')
Font family: 'MICREncoding'          (alias: 'm')
Font family: 'Symbol'                (alias: 's')
Font family: 'Times-Bold'            (alias: 'tb')
Font family: 'Times-BoldItalic'      (alias: 'tbi')
Font family: 'Times-Italic'          (alias: 'ti')
Font family: 'Times-Roman'           (alias: 't')
Font family: 'Zapfdingbats'          (alias: 'z')
```

(NOTE: font family `MICREncoding` is **not** usable in commercial programs without more investigation. See the notes later in this document.)

Get a copy of the factory for use in your program:

```raku
my $ff = FontFactory::Type1.new;
```

Define a `DocFont`. Use a name that indicates its face and size for easy use later. For fractional points use a 'd' for the decimal point:

```raku
my $t12d1 = $ff.get-font: 't12d1';
say "name: {$t12d1.name}"; # OUTPUT: «name: Times-Roman␤»
say "size: {$t12d1.size}"; # OUTOUT: «size: 12.1␤»
```

Define another `DocFont`:

```raku
my $c10 = $ff.get-font: 'c10';
say "name: {$c10.name}"; # OUTPUT: «name: Courier␤»
say "size: {$c10.size}"; # OUTOUT: «size: 10␤»
```

In addition to those attributes, all the attributes from `Font::AFM` are also available plus some added for convenience, For example:

    # for typesetting, find the width of a kerned string in PostScript points (72/inch):
    my $text = "Some string of text to be typeset in a beautiful PDF document.";
    my $wk = $t12d1.stringwidth($text, :kern);
    say "kerned width: $wk"; # OUTPUT: kerned width: 302.3064

DESCRIPTION
===========

**FontFactory::Type1** provides easy access to the Adobe standard Type 1 fonts (and their metrics) as used in PDF document creation using modules such as:

  * PDF::Lite

  * PDF::Document (WIP)

  * PDF::Writer (WIP)

  * Slidemaker (WIP)

  * CheckWriter (WIP)

A future module, **FontFactory::TT**, will provide the same benefits for *TrueType* (and *OpenType*) fonts, but it will require the user to provide his or her own font files (the author recommends using Google's free fonts as a starting point for a collection of fonts);

See the accompanying [METHODS](METHODS.md) for details on the methods and their use in your own PDF document.

MICR Encoding (MICRE) font
--------------------------

The MICR Encoding font for bank checks was obtained from [1001fonts.com](https://www.1001fonts.com/micr-encoding-font.html).

The downloaded file was named `micr-encoding.zip` (which was deleted after unzipping it).

When file `micr-encoding.zip` was unzipped into the <unzipped> directory, the following files were found:

      '!DigitalGraphicLabs.html'
      '!license.txt'
      micrenc.ttf

The two files in single quotes were renamed to:

    DigitalGraphicLabs.html
    license.txt

The license basically says the font is free to use for non-commercial purposes.

The font was transformed to an Adobe PostScript Type 1 font by creating `.pfa` and `.afm` files using program `fontforge`. See the complete unzipped package and all the files in directory `/dev/fonts` and the accompanying file `README.fontforge` for the procedures used.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.


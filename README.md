NAME
====

**FontFactory** - Provides the standard PostSript fonts in a friendly package for use with many 'PDF::*' modules

SYNOPSIS
========

```raku
use FontFactory;
use PDF::Document;

my $ff = FontFactory.new;
$ff.show-fonts;
```

DESCRIPTION
===========

**FontFactory** provides easy access to the Adobe standard Type 1 fonts used in PDF document creation using mdules such as:

  * PDF::Lite

  * PDF::Document

A future module, **FontFactoryTT** will provide the same benefits for *TrueType* fonts, but it will require the user to provide his or her own font files (the author recommends using Google's free fonts as a starting point for a collection of fonts);

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2023 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.


**Digital Typesetting**
=======================

Modern typesetting involves using text and digital typefaces (fonts) placed on a page mimicing the earlier printing era with hand-placed lead type on a printing press, covered with a thin layer of ink, and pressed against paper to produce a printed page. While retaining some of the old terminology, modern typesetting results in more accurate and easier production of beautiful printed products.

A few terms need to be explained to understand the application of digital fonts using this module as well as **Font::AFM** which is central to it.

Placing a single line of text using a font of a specific size (expressed as a hight of N points where there are 72 points per inch) involves knowledge both a single character's metrics as well as its collective metrics when gathered as a multi-glyph line.

A glyph is a digital character in the chosen font and it has the following metric characteristics described for our use in placing the character:

  * Origin - Vertically centered on the baseline of the line of text, it is the reference point to be used when placing the glyph on the desired baseline.

  * Bounding box ('bbox' or 'BBox') 

    1 - The rectangle that bounds the horizontal and vertical limits of the outline of a glyph. The bounding box is described as a list of four numbers, expressed as PostScript points (72 per inch), representing the `x` and `y` coordinates of the lower-left corner and the `x` and `y` coordinates of the upper-right corner from the glyph's origin. 

    2 - The same as the first definition but applied to a set of glyphs as a line of text.

  * Width 

    1 - The horizontal distance from a glyph's origin to the right to the point where the next glyph's origin is designed to be placed. 

    2 - The same as the first definition but applied to a set of glyphs as a line of text.

  * Font bounding box - The rectangle that bounds the smallest outline which encompasses all the glyphs in the font when placed with their origins at the same point.

  * Left bearing - The `x` value of the left side of a glyph's bounding box.

  * Top bearing - The `y` value of the top side of of a glyph's bounding box.

  * Bottom bearing - The `y` value of the bottom side of a glyph's bounding box.

  * Right bearing - The `x` value of the right side of a glyph's bounding box.

  * Scale factor - A font's metrics are typically described as being in a rectangular coordinate system with a width of 1000 units. To get the equivalent of the dimensions in the chosen point size the values are multiplied by a scale factor: point size / 1000.

    For example, given a character, say 'B', in a font with a size of 12.3 points with its glyph's raw metrics width being 700 units, find the glyph's final width in points:

        scale factor = 12.3/1000 = 0.0123
        width = 0.0123 x 700 = 8.61

**class DocFont methods**
=========================

The following methods are convenience methods not found in module `Font::AFM` but are constructed fron data therein and have been adjusted for the `DocFont` object's font size.

Some methods have short aliases for convenience in coding.

**Methods not in Font::AFM**
----------------------------

### **StrikethroughPosition**

Provides the position of the strikethrough line as the midheight of the lower-case 'm'

    method StrikethroughPosition {...}

alias: `sp`

### **StrikethroughThickness**

Provides the suggested thickness of the strikethrough line for the font size

    method StrikethroughThickness {...}

alias: `st`

### **LeftBearing**

The left sidebearing is defined as the first character's BBox[0] distance from its origin.

    method LeftBearing(Str $s?) {...}

alias: `lb`

### **RightBearing**

Get the value of the rightmost outline in a character or string

    method RightBearing(Str $s?) {...}

alias: `rb`

### **TopBearing**

Get the value of the topmost outline in a character or string

    method TopBearing(Str $s?) {...}

alias: `tb`

### **BottomBearing**

Get the value of the bottommost outline in a character or string

    method BottomBearing(Str $s?) {...}

alias: `bb`

### **LineHeight**

Get the maximum vertical space required for any single line of text or, optionally, for a specific string

    method LineHeight(Str $s?) {...}

alias: `lh`

### **StringBBox**

Returns a list of the bounding box of the input string or the FontBBox if a string is not provided. The user may choose to to kern the string.

    method StringBBox(Str $s?, Bool :$kern --> List) {...}

alias: `sbb`

**Methods found in Font::AFM**
------------------------------

The following methods return the data extracted from Adobe's `afm` file for the given font. The data returned by this module have the values adjusted for the `DocFont` object's font size.

### **Wx**

Hash of glyph names and their width

    method Wx(--> Hash) {...}

### **BBox**

Hash of glyph names and their bounding boxes

    method BBox(--> Hash) {...}

### **stringwidth**

Provides the width of string for the font size. The kerned width is provided if `$kern` is `True`.

    method stringwidth($string, Bool :$kern) {...}

### **FontBBox**

Array of the overall font bounding box

    method FontBBox(--> Array) {...}

### **UnderlinePosition**

Provides the designed distance of the underline below the baseline for the font size

    method UnderlinePosition {...}

alias: `up`

### **UnderlineThickness**

Provides the designed thickness of the underline for the font size

    method UnderlineThickness {...}

alias: `ut`

### **IsFixedPitch**

    method IsFixedPitch {...}

### **FontName**

Usually with no spaces

    method FontName {...}

### **FullName**

    method FullName {...}

### **FamilyName**

    method FamilyName {...}

### **Weight**

    method Weight {...}

### **ItalicAngle**

    method ItalicAngle {...}

### **Version**

    method Version {...}

### **Notice**

    method Notice {...}

### **Comment**

    method Comment {...}

### ****

    method X() {...}

### **EncodingScheme**

    method EncodingScheme {...}

### **CapHeight**

    method CapHeight {...}

### **XHeight**

    method XHeight {...}

### **Ascender**

    method Ascender {...}

Not needed by the normal user
-----------------------------

The following two methods are included for completeness, but should not be needed. The author believes they should be `private` methods only used during the construction of the C>Font::AFM> class.

### **kern**

Kern the string. Returns an array of string segments, separated by numeric kerning distances, and the overall width of the string.

    method kern($string --> List) {...}

### **KernData**

A two-dimensional hash containing glyphs as keys, each with a hash of kerning characters and kern widths for the top-level glyph.

    method KernData(--> Hash) {...}


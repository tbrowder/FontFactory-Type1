unit class FontFactory::Type1::BaseFont is export;

use PDF::Lite;
use Font::AFM;

#| This class represents a Font::AFM instance
#| Its methods are mostly the same as those of Font::AFM with some additions
has PDF::Lite $.pdf is required;
has $.name is required;              #= the name as recognized by PDF::Lite
has $.rawfont is required;           #= the font object from PDF::Lite
has Font::AFM $.rawafm is required;  #= the afm object
has $.is-corefont is required;       #= used to distinguish non-core fonts

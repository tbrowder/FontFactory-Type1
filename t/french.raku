#!/usr/bin/env raku

say "Le Caf\xep Marly";

=finish

my $tgt-jd    = 2_459_332.611; # target Julian date in days
# JPL solution: 2021-04-28T02:39:50.40Z
my $tgt-jd2   = 1_700_332.611; # target Julian date in days
# JPL solution: -0058-04-04T19:39:50.40Z

# Unix (POSIX) time (UTC)         |  1970-01-01T00:00:00Z | 2_440_587.5
my $pos-jd    = 2_440_587.5;   # POSIX reference epoch in Julian days from JPL, agrees with Wikipedia
                

my $tgt-pos   = $tgt-jd - $pos-jd; # convert to POSIX days
my $tgt-pos2  = $tgt-jd2 - $pos-jd; # convert to POSIX days
my $tgt-sec   = $tgt-pos * 24 * 60 * 60; # convert to seconds
my $tgt-sec2  = $tgt-pos2 * 24 * 60 * 60; # convert to seconds

my $dt-ref    = DateTime.new: '1970-01-01T00:00:00Z'; # convert POSIX reference date to UTC
my $pos-sec   = $dt-ref.posix;           # whole seconds
say ($pos-sec == 0);

my $delta-sec  = $tgt-sec - $pos-sec;
my $delta-sec2 = $tgt-sec2 - $pos-sec;

my $dt-tgt    = DateTime.new($delta-sec);
my $dt-tgt2   = DateTime.new($delta-sec2);

say "output 1:      {$dt-tgt.utc}"; # OUTPUT: <<
say "JPL solution:  2021-04-28T02:39:50.40Z";

say "output 2:     {$dt-tgt2.utc}"; # OUTPUT: <<
say "JPL solution: -0058-04-04T19:39:50.40Z";

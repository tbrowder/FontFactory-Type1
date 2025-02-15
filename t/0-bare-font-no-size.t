use Test;
use Font::AFM;
use FontFactory::Type1;
use FontFactory::Type1::DocFont;
use FontFactory::Type1::DocFont::StringSub;
use Data::Dump;

my $debug = 0;

my ($ff, $f, $f2, $v, $a, $afm, $afm2, $text, $bbox, $bbox2);
my ($width, $llx, $lly, $urx, $ury);

$ff = FontFactory::Type1.new;

my @c = <c cb ci co cbi cbo cob cib>;
my @h = <h hb hi ho hbi hbo hob hib>;
my @t = <t tb ti to tbi tbo tob tib>;

for @c { lives-ok { $f = $ff.get-font($_); }, "testing no-size Courier";     }
for @h { lives-ok { $f = $ff.get-font($_); }, "testing no-size Helvetica";   }
for @t { lives-ok { $f = $ff.get-font($_); }, "testing no-size Times-Roman"; }

$f = $ff.get-font: "c";
is $f.size, False;

done-testing;

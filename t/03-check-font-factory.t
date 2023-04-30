use Test;
use Proc::Easier;
use FontFactory::Type1;

plan 2;

lives-ok {
    my $args = "./dev/check-fonts.raku";
    my $cmd  = cmd $args;
}, "checking bulk font setting";

lives-ok {
    my $args = "./dev/readme-eg.raku";
    my $cmd  = cmd $args;
}, "checking bulk font setting (2)";

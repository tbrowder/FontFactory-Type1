my $s = "abcABC";
for $s.comb -> $c is copy {
    say "char $c, uniname: ", $c.uniname;
    say "dd $c: ", dd $c;
}

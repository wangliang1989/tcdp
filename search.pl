#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min max);

# 台站
my @station = ("STA01");
# 设置震源信息 0/360/0/90/-90/90
my $d = 10;
my @strike;
for (my $strike = 0; $strike <= 360; $strike = $strike + $d) {
    push @strike, $strike;
}
my @dip;
for (my $dip = 0; $dip <= 90; $dip = $dip + $d) {
    push @dip, $dip;
}
my @rake;
for (my $rake = -90; $rake <= 90; $rake = $rake + $d) {
    push @rake, $rake;
}
unlink "compare.pdf";
mkdir "search";
chdir "search" or die;
open (OUT, "> out");
foreach my $strike (@strike) {
    foreach my $dip (@dip) {
        foreach my $rake (@rake) {
            my $meca = "$strike/$dip/$rake";

            foreach my $sta (@station) {
                system "syn -M-0.5/$meca -D0.1/0.5 -A45 -O${sta}.z -G/home/peterpan/tcdp/tcdp/tcdp_1.8/0.3_1.008.grn.0";
                open(SAC, "| sac > debug") or die "Error in opening SAC\n";
                print SAC "cut 0.2 0.4\n";
                print SAC "r ${sta}.z\n";
                print SAC "w a\n";
                print SAC "q\n";
                close(SAC);
                open(SAC, "| sac > debug") or die "Error in opening SAC\n";
                print SAC "cut 0.4 0.6\n";
                print SAC "r ${sta}.z\n";
                print SAC "w b\n";
                print SAC "q\n";
                close(SAC);
                my (undef, $a1) = split m/\s+/, `saclst depmax f a`;
                my (undef, $a2) = split m/\s+/, `saclst depmin f a`;
                my (undef, $b1) = split m/\s+/, `saclst depmax f b`;
                my (undef, $b2) = split m/\s+/, `saclst depmin f b`;
                my $a;
                my $b;
                if ($a1 > (0 - $a2)) {
                    $a = $a1;
                }else{
                    $a = 0 - $a2;
                }
                if ($b1 > (0 - $b2)) {
                    $b = $b1;
                }else{
                    $b = 0 - $b2;
                }
                if ($a > $b) {
                    print OUT "YES $meca $a $b\n";
                    open(SAC, "| sac") or die "Error in opening SAC\n";
                    print SAC "cut 0 1\n";
                    print SAC "r ${sta}.*\n";
                    print SAC "bd sgf\n";
                    print SAC "p1\n";
                    print SAC "save temp.pdf\n";
                    print SAC "q\n";
                    close(SAC);
                    if (-e '../compare.pdf') {
                        system "cpdf ../compare.pdf temp.pdf -o ../compare.pdf";
                    }else{
                        system "mv temp.pdf ../compare.pdf";
                    }
                }else{
                    print OUT "NO $meca $a $b\n";
                }
            }
        }
    }
}
chdir "../" or die;

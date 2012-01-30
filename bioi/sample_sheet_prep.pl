#!/usr/bin/perl
use warnings;
use strict;
use Switch;

my @data = `cat in.csv`;

open OUT, ">SampleSheet.csv";
print OUT $data[0];
for ( my $i = 1; $i < @data; $i++ )
{
    my @split = split ",", $data[$i];
    my $s1    = "$split[0],$split[1],$split[2],$split[3]";
    my $s2    = "$split[5],$split[6],$split[7],$split[8],$split[9]";
    switch ( $split[4] )
    {
        case 1  { print OUT "$s1,ATCACG,$s2" }
        case 2  { print OUT "$s1,CGATGT,$s2" }
        case 3  { print OUT "$s1,TTAGGC,$s2" }
        case 4  { print OUT "$s1,TGACCA,$s2" }
        case 5  { print OUT "$s1,ACAGTG,$s2" }
        case 6  { print OUT "$s1,GCCAAT,$s2" }
        case 7  { print OUT "$s1,CAGATC,$s2" }
        case 8  { print OUT "$s1,ACTTGA,$s2" }
        case 9  { print OUT "$s1,GATCAG,$s2" }
        case 10 { print OUT "$s1,TAGCTT,$s2" }
        case 11 { print OUT "$s1,GGCTAC,$s2" }
        case 12 { print OUT "$s1,CTTGTA,$s2" }
    }
}
close OUT;

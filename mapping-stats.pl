#!/usr/bin/perl
use warnings;
use strict;

my $file     = shift;
my @data     = split "\n", `samtools idxstats $file`;
my $mapped   = 0;
my $unmapped = 0;
foreach my $line ( @data )
{
    my ($m, $u) = $line =~ /\S+\s+(\S+)\s+(\S+)/;
    $mapped   += $m;
    $unmapped += $u;
}

print "File\t\t\tMapped\t\tUnmapped\t% Mapped\t\tTotal\n";
print "$file:\t$mapped\t$unmapped\t",$mapped/($unmapped+$mapped) * 100, "\t", $mapped+$unmapped, "\n";
